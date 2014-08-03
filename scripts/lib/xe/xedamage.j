library xedamage initializer init requires xebasic
//************************************************************************
// xedamage 0.8
// --------
//  For all your damage and targetting needs.
//
//************************************************************************

//===========================================================================================================
    globals
        private constant integer   MAX_SUB_OPTIONS = 3
        
        private constant real      FACTOR_TEST_DAMAGE = 0.01 
        // a low damage to do on units to test their damage factors for specific
        // attacktype/damagetype combos.
        // You'll need something as high as 20.0 to make it work well with armor resistances.
        // (Yes, you read it correctly, 20 ...
        //
        // If you use such a large value, there may be conflicts with some things relying on damage
        // (ie they are not away of the isDummyDamage tag that xedamage posseses.) which may be quite bad if you think about it...
        // then maybe it is better to change it to 0.01 ... then will work fine, just fine - but it will generally ignore armor - 
        // I am leaving it as 0.01 by default, because honestly, I'd rather make it ignore armor than have a lot of people sending me
        // rants about how they detect 20.0 damage where none is visible...
        private constant real      MAX_DAMAGE_FACTOR = 3.00
        // The maximum damage factor in the map. I think 3 is fine.
       

        //=======================================================
        private constant real      EPSILON = 0.000000001
        private unit     dmger
        private constant integer   MAX_SPACE = 8190 // MAX_SPACE/MAX_SUB_OPTIONS is the instance limit for xedamage, usually big enough...
    endglobals

    private keyword structInit

    struct xedamage[MAX_SPACE]

        //----
        // fields and methods for a xedamage object, they aid determining valid targets and special
        // damage factor conditions.
        //
        // Notice the default values.
        //
        boolean damageSelf    = false  // the damage and factor methods  usually have a source unit parameter
                                       // xedamage would consider this unit as immune unless you set damageSelf to true

        boolean damageAllies  = false  // Alliance dependent target options.
        boolean damageEnemies = true   // *
        boolean damageNeutral = true   // *
        boolean ranged        = true   // Is the attack ranged? This has some effect on the AI of the affected units
                                       // true by default, you may not really need to modify this.

        boolean visibleOnly   = false  // Should only units that are visible for source unit's owner be affected?
        boolean deadOnly      = false  // Should only corpses be affected by "the damage"? (useful when using xedamage as a target selector)
        boolean alsoDead      = false  // Should even corpses and alive units be considered?

        boolean damageTrees   = false  //Also damage destructables? Notice this is used only in certain methods.
                                       //AOE for example targets a circle, so it can affect the destructables
                                       //in that circle, a custom spell using xedamage for targetting configuration
                                       //could also have an if-then-else implemented so it can verify if it is true
                                       //then affect trees manually.

        //
        // Damage type stuff:
        //    .dtype : the "damagetype" , determines if the spell is physical, magical or ultimate.
        //    .atype : the "attacktype" , deals with armor.
        //    .wtype : the "weapontype" , determines the sound effect to be played when damage is done.
        //
        //  Please use common.j/blizzard.j/ some guide to know what damage/attack/weapon types can be used
        //
        damagetype dtype  = DAMAGE_TYPE_UNIVERSAL
        attacktype atype  = ATTACK_TYPE_NORMAL
        weapontype wtype  = WEAPON_TYPE_WHOKNOWS

        //
        // Damage type 'tag' people might use xedamage.isInUse() to detect xedamage usage, there are other static
        //  variables like xedamage.CurrentDamageType and xedamage.CurrentDamageTag. The tag allows you to specify
        //  a custom id for the damage type ** Notice the tag would aid you for some spell stuff, for example,
        //  you can use it in a way similar to Rising_Dusk's damage system.
        //
        integer    tag    = 0

        //
        // if true, forceDamage will make xedamage ignore dtype and atype and try as hard as possible to deal 100%
        // damage.
        boolean    forceDamage = false


        //
        // Ally factor! Certain spells probably have double purposes and heal allies while harming enemies. This
        // field allows you to do such thing.
        //
        real     allyfactor = 1.0

        //
        // field: .exception = SOME_UNIT_TYPE
        // This field adds an exception unittype (classification), if the unit belongs to this unittype it will
        // be ignored.
        //
        method operator exception= takes unittype ut returns nothing
            set this.use_ex=true
            set this.ex_ut=ut
        endmethod

        //
        // field: .required = SOME_UNIT_TYPE
        // This field adds a required unittype (classification), if the unit does not belong to this unittype
        //  it will be ignored.
        //
        method operator required= takes unittype ut returns nothing
            set this.use_req=true
            set this.req_ut=ut
        endmethod
        private boolean  use_ex    =  false
        private unittype ex_ut = null

        private boolean  use_req   = false
        private unittype req_ut  = null


        private unittype array fct[MAX_SUB_OPTIONS]
        private real     array fc[MAX_SUB_OPTIONS]
        private integer  fcn=0

        //
        // method .factor(SOME_UNIT_TYPE, factor)
        //  You might call factor() if you wish to specify a special damage factor for a certain classification,
        // for example call d.factor(UNIT_TYPE_STRUCTURE, 0.5) makes xedamage do half damage to structures.
        //
        method factor takes unittype ut, real fc returns nothing
            if(this.fcn==MAX_SUB_OPTIONS) then
                debug call BJDebugMsg("In one instance of xedamage, you are doing too much calls to factor(), please increase MAX_SUB_OPTIONS to allow more, or cut the number of factor() calls")
                return
            endif
            set this.fct[this.fcn] = ut
            set this.fc[this.fcn] = fc
            set this.fcn = this.fcn+1
        endmethod

        private integer  array abifct[MAX_SUB_OPTIONS]
        private real     array abifc[MAX_SUB_OPTIONS]
        private integer  abifcn=0

        //
        // method .abilityFactor('abil', factor)
        //  You might call abilityFactor() if you wish to specify a special damage factor for units that have a
        // certain ability/buff.
        // for example call d.abilityFactor('A000', 1.5 ) makes units that have the A000 ability take 50% more
        // damage than usual.
        //
        
        method abilityFactor takes integer abilityId, real fc returns nothing
            if(this.abifcn==MAX_SUB_OPTIONS) then
                debug call BJDebugMsg("In one instance of xedamage, you are doing too much calls to abilityFactor(), please increase MAX_SUB_OPTIONS to allow more, or cut the number of abilityFactor() calls")
                return
            endif
            set this.abifct[this.abifcn] = abilityId
            set this.abifc[this.abifcn] = fc
            set this.abifcn = this.abifcn+1
        endmethod

        private boolean  usefx  = false
        private string   fxpath
        private string   fxattach

        //
        // method .useSpecialEffect("effect\\path.mdl", "origin")
        // Makes it add (and destroy) an effect when damage is performed.
        //
        method useSpecialEffect takes string path, string attach returns nothing
            set this.usefx = true
            set this.fxpath=path
            set this.fxattach=attach
        endmethod


        //********************************************************************
        //* Now, the usage stuff:
        //*

        //================================================================================
        // static method xedamage.isInUse()  will return true during a unit damaged
        // event in case this damage was caused by xedamage, in this case, you can
        // read variables like CurrentDamageType, CurrentAttackType and CurrentDamageTag
        // to be able to recognize what sort of damage was done.
        //
        readonly static damagetype CurrentDamageType=null
        readonly static attacktype CurrentAttackType=null
        readonly static integer    CurrentDamageTag =0

        private static integer    inUse = 0
        static method isInUse takes nothing returns boolean 
            return (inUse>0) //inline friendly.
        endmethod
        
        readonly static boolean isDummyDamage = false

        //========================================================================================================
        // This function calculates the damage factor caused by a certain attack and damage
        // type, it is static : xedamage.getDamageTypeFactor(someunit, ATTAcK_TYPE_NORMAL, DAMAGE_TYPE_FIRE, 100)
        //
        static method getDamageTypeFactor takes unit u, attacktype a, damagetype d returns real
         local real hp=GetWidgetLife(u)
         local real mana=GetUnitState(u,UNIT_STATE_MANA)
         local real r
         local real fc = FACTOR_TEST_DAMAGE

            //Since a unit is in that point, we don't need checks.
            call SetUnitX(dmger,GetUnitX(u))
            call SetUnitY(dmger,GetUnitY(u))

            call SetUnitOwner(dmger,GetOwningPlayer(u),false)
            set r=hp
            if (hp< FACTOR_TEST_DAMAGE*MAX_DAMAGE_FACTOR) then
                 call SetWidgetLife(u, hp + FACTOR_TEST_DAMAGE*MAX_DAMAGE_FACTOR )
                 set r = hp + FACTOR_TEST_DAMAGE*MAX_DAMAGE_FACTOR
                 set fc = GetWidgetLife(u)-hp + EPSILON
            endif
            set isDummyDamage = true
            call UnitDamageTarget(dmger,u, fc ,false,false,a,d,null)
            static if DEBUG_MODE then
                if IsUnitType(u, UNIT_TYPE_DEAD) and (hp>0.405) then
                    call BJDebugMsg("xedamage: For some reason, the unit being tested by getDamageTypeFactor has died. Verify MAX_DAMAGE_FACTOR is set to a correct value. ") 
                endif
            endif
            
            set isDummyDamage = false
            call SetUnitOwner(dmger,Player(15),false)
            if (mana>GetUnitState(u,UNIT_STATE_MANA)) then
                //Unit had mana shield, return 1 and restore mana too.
                call SetUnitState(u,UNIT_STATE_MANA,mana)
                set r=1
            else
                set r= (r-GetWidgetLife(u)) / fc
            endif
            call SetWidgetLife(u,hp)
         return r
        endmethod


        private method getTargetFactorCore takes unit source, unit target, boolean usetypes returns real
         local player p=GetOwningPlayer(source)
         local boolean allied=IsUnitAlly(target,p)
         local boolean enemy =IsUnitEnemy(target,p)
         local boolean neutral=allied
         local real   f
         local real   negf=1.0
         local integer i

            if(this.damageAllies != this.damageNeutral) then
                set neutral= allied and not (GetPlayerAlliance(GetOwningPlayer(target),p, ALLIANCE_HELP_REQUEST ))
                //I thought accuracy was not as important as speed , I think that REQUEST is false is enough to consider
                // it neutral.
                //set neutral= allied and not (GetPlayerAlliance(GetOwningPlayer(target),p, ALLIANCE_HELP_RESPONSE ))
                //set neutral= allied and not (GetPlayerAlliance(GetOwningPlayer(target),p, ALLIANCE_SHARED_XP ))
                //set neutral= allied and not (GetPlayerAlliance(GetOwningPlayer(target),p, ALLIANCE_SHARED_SPELLS ))
                set allied= allied and not(neutral)
            endif

            if (not this.damageAllies) and allied then
                return 0.0
            elseif (not this.damageEnemies) and enemy then
                return 0.0
            elseif( (not this.damageSelf) and (source==target) ) then
                return 0.0
            elseif (not this.damageNeutral) and neutral  then
                return 0.0
            elseif( this.use_ex and IsUnitType(target, this.ex_ut) ) then
                return 0.0
            elseif( this.visibleOnly and not IsUnitVisible(target,p) ) then
                return 0.0
            elseif ( this.deadOnly and not IsUnitType(target,UNIT_TYPE_DEAD) ) then
                return 0.0
            elseif ( not(this.alsoDead) and IsUnitType(target,UNIT_TYPE_DEAD) ) then
                return 0.0               
            endif

            set f=1.0
            
            if ( IsUnitAlly(target,p) ) then
                set f=f*this.allyfactor
                if(f<=-EPSILON) then
                    set f=-f
                    set negf=-1.0
                endif
            endif
            if (this.use_req and not IsUnitType(target,this.req_ut)) then
                return 0.0
            endif

            set i=.fcn-1
            loop
                exitwhen (i<0)
                if( IsUnitType(target, this.fct[i] ) ) then
                    set f=f*this.fc[i]
                    if(f<=-EPSILON) then
                        set f=-f
                        set negf=-1.0
                    endif
                endif
                set i=i-1
            endloop
            set i=.abifcn-1
            loop
                exitwhen (i<0)
                if( GetUnitAbilityLevel(target,this.abifct[i] )>0 ) then
                    set f=f*this.abifc[i]
                    if(f<=-EPSILON) then
                        set f=-f
                        set negf=-1.0
                    endif
                endif
                set i=i-1
            endloop
            set f=f*negf

            if ( f<EPSILON) and (f>-EPSILON) then
                return 0.0
            endif
            if( this.forceDamage or not usetypes ) then
                return f
            endif
            set f=f*xedamage.getDamageTypeFactor(target,this.atype,this.dtype)

            if ( f<EPSILON) and (f>-EPSILON) then
                return 0.0
            endif

            return f
        endmethod

        //====================================================================
        // With this you might decide if a unit is a valid target for a spell.
        //
        method getTargetFactor takes unit source, unit target returns real
            return this.getTargetFactorCore(source,target,true)
        endmethod

        //======================================================================
        // a little better, I guess
        //
        method allowedTarget takes unit source, unit target returns boolean
            return (this.getTargetFactorCore(source,target,false)!=0.0)
        endmethod


        //=======================================================================
        // performs damage to the target unit, for unit 'source'. 
        //
        method damageTarget takes unit source, unit target, real damage returns boolean
         local damagetype dt=.CurrentDamageType
         local attacktype at=.CurrentAttackType
         local integer    tg=.CurrentDamageTag
         local real       f = this.getTargetFactorCore(source,target,false)
         local real       pl

            if(f!=0.0) then
                set .CurrentDamageType = .dtype
                set .CurrentAttackType = .atype
                set .CurrentDamageTag  = .tag

                
                set .inUse = .inUse +1
                set pl=GetWidgetLife(target)
                call UnitDamageTarget(source,target,  f*damage, true, .ranged, .atype, .dtype, .wtype )
                set .inUse = .inUse -1
                set .CurrentDamageTag = tg
                set .CurrentDamageType = dt
                set .CurrentAttackType = at
                if(pl != GetWidgetLife(target) ) then
                    if(usefx) then
                         call DestroyEffect(  AddSpecialEffectTarget(this.fxpath, target, this.fxattach) )
                    endif
                    return true
                endif
            endif
            return false
        endmethod

        //=======================================================================================
        // The same as damageTarget, but it forces a specific damage value, good if you already
        // know the target.
        //
        method damageTargetForceValue takes unit source, unit target, real damage returns nothing
         local damagetype dt=.CurrentDamageType
         local attacktype at=.CurrentAttackType
         local integer    tg=.CurrentDamageTag

                set .CurrentDamageType = .dtype
                set .CurrentAttackType = .atype
                set .CurrentDamageTag  = .tag

                if( usefx) then
                    call DestroyEffect(  AddSpecialEffectTarget(this.fxpath, target, this.fxattach) )
                endif
                
                set .inUse = .inUse +1
                call UnitDamageTarget(source,target,  damage, true, .ranged, null, null, .wtype )
                set .inUse = .inUse -1
                set .CurrentDamageTag  = tg
                set .CurrentDamageType = dt
                set .CurrentAttackType = at
        endmethod

        //=====================================================================================
        // Notice: this will not Destroy the group, but it will certainly empty the group.
        //
        method damageGroup takes unit source, group targetGroup, real damage returns integer
         local damagetype dt=.CurrentDamageType
         local attacktype at=.CurrentAttackType
         local integer    tg=.CurrentDamageTag
         local unit       target
         local real       f
         local integer    count=0
         local real hp

            set .CurrentDamageType = .dtype
            set .CurrentAttackType = .atype
            set .CurrentDamageTag  = .tag
            set .inUse = .inUse +1
            loop
                set target=FirstOfGroup(targetGroup)
                exitwhen (target==null)
                call GroupRemoveUnit(targetGroup,target)
                set f= this.getTargetFactorCore(source,target,false)
                if (f!=0.0) then
                    set count=count+1
                    if(usefx) then
                        set hp = GetWidgetLife(target)
                    endif

                    call UnitDamageTarget(source,target, f*damage, true, .ranged, .atype, .dtype, .wtype )
                    if(usefx and (hp > GetWidgetLife(target)) ) then
                        call DestroyEffect(  AddSpecialEffectTarget(this.fxpath, target, this.fxattach) )
                    endif                 

                endif
            endloop


            set .inUse = .inUse -1
            set .CurrentDamageTag=tg
            set .CurrentDamageType = dt
            set .CurrentAttackType = at
         return count
        endmethod

        private static xedamage instance
        private integer countAOE
        private unit    sourceAOE
        private real    AOEx
        private real    AOEy
        private real    AOEradius
        private real    AOEdamage
        private static boolexpr filterAOE
        private static boolexpr filterDestAOE
        private static group    enumgroup
        private static rect     AOERect

        private static method damageAOE_Enum takes nothing returns boolean
         local unit target=GetFilterUnit()
         local xedamage this=.instance //adopting a instance.
         local real f
         local real hp
         
             if( not IsUnitInRangeXY(target,.AOEx, .AOEy, .AOEradius) ) then
                 set target=null
                 return false
             endif
             set f=.getTargetFactorCore(.sourceAOE, target, false)
             if(f!=0.0) then
                 set .countAOE=.countAOE+1
                 if(this.usefx) then
                      set hp =GetWidgetLife(target)
                 endif
                 call UnitDamageTarget(.sourceAOE,target, f*this.AOEdamage, true, .ranged, .atype, .dtype, .wtype )
                 if(this.usefx and (hp > GetWidgetLife(target) ) ) then
                     call DestroyEffect(  AddSpecialEffectTarget(this.fxpath, target, this.fxattach) )
                 endif                                  
             endif

          set .instance= this //better restore, nesting IS possible!
          set target=null
          return false
        endmethod

        private static method damageAOE_DestructablesEnum takes nothing returns boolean
         local destructable target=GetFilterDestructable()
         local xedamage this=.instance //adopting a instance.
         local real     dx=.AOEx-GetDestructableX(target)
         local real     dy=.AOEy-GetDestructableY(target)

             if( dx*dx + dy*dy >= .AOEradius+EPSILON )  then
                 set target=null
                 return false
             endif
             set .countAOE=.countAOE+1
             if(.usefx) then
                 call DestroyEffect(  AddSpecialEffectTarget(this.fxpath, target, this.fxattach) )
             endif             
             call UnitDamageTarget(.sourceAOE,target, this.AOEdamage, true, .ranged, .atype, .dtype, .wtype )

          set .instance= this //better restore, nesting IS possible!
          set target=null
          return false
        endmethod
        //==========================================================================================
        // will affect trees if damageTrees is true!
        // 
        method damageAOE takes unit source, real x, real y, real radius, real damage returns integer
         local damagetype dt=.CurrentDamageType
         local attacktype at=.CurrentAttackType
         local integer    tg=.CurrentDamageTag

            set .CurrentDamageType = .dtype
            set .CurrentAttackType = .atype
            set .CurrentDamageTag  = .tag
            set .inUse = .inUse +1
            set .instance=this
            set .countAOE=0
            set .sourceAOE=source
            set .AOEx=x
            set .AOEradius=radius
            set .AOEy=y
            set .AOEdamage=damage
            call GroupEnumUnitsInRange(.enumgroup,x,y,radius+XE_MAX_COLLISION_SIZE, .filterAOE)
            if(.damageTrees) then
                call SetRect(.AOERect, x-radius, y-radius, x+radius, y+radius)
                set .AOEradius=.AOEradius*.AOEradius
                call EnumDestructablesInRect(.AOERect, .filterDestAOE, null)
            endif
            set .inUse = .inUse -1
            set .CurrentDamageTag  = tg
            set .CurrentDamageType = dt
            set .CurrentAttackType = at
         return .countAOE
        endmethod

        method damageAOELoc takes unit source, location loc, real radius, real damage returns integer
            return .damageAOE(source, GetLocationX(loc), GetLocationY(loc), radius, damage)
        endmethod

        //==========================================================================================
        // only affects trees, ignores damageTrees
        // 
        method damageDestructablesAOE takes unit source, real x, real y, real radius, real damage returns integer
            set .instance=this
            set .countAOE=0
            set .sourceAOE=source
            set .AOEx=x
            set .AOEradius=radius*radius
            set .AOEy=y
            set .AOEdamage=damage
            //if(.damageTrees) then
                call SetRect(.AOERect, x-radius, y-radius, x+radius, y+radius)
                call EnumDestructablesInRect(.AOERect, .filterDestAOE, null)
            //endif
         return .countAOE
        endmethod
        method damageDestructablesAOELoc takes unit source, location loc, real radius, real damage returns integer
            return .damageDestructablesAOE(source,GetLocationX(loc), GetLocationY(loc), radius, damage)
        endmethod

        //'friend' with the library init
        static method structInit takes nothing returns nothing
            set .AOERect= Rect(0,0,0,0)
            set .filterAOE= Condition(function xedamage.damageAOE_Enum)
            set .filterDestAOE = Condition( function xedamage.damageAOE_DestructablesEnum)
            set .enumgroup = CreateGroup()
        endmethod
    endstruct

    private function init takes nothing returns nothing
        set dmger=CreateUnit(Player(15), XE_DUMMY_UNITID , 0.,0.,0.)
        call UnitAddAbility(dmger,'Aloc')
        call xedamage.structInit()
    endfunction




endlibrary



