library xecast initializer init requires xebasic
//******************************************************************************
// xecast 0.9
// ------
//  Because dummy casters REALLY ARE this complicated!
//
//******************************************************************************

//==============================================================================
 globals
    private constant integer MAXINSTANCES         = 8190
    //this is a lot, unless you leak xecast objects (which is a bad thing)
    
    private constant integer INITIAL_DUMMY_COUNT  = 12
    
    //don't allow to keep more than DUMMY_STACK_LIMIT innactive dummy units :
    private constant integer DUMMY_STACK_LIMIT    = 50
    
    // If your map does not give visibility to all players, or
    // for other reasons, you might want xecast to work on
    // units that are not visible to the player, in that case
    // change this to true, else it is just a performance loss.
    private constant boolean FORCE_INVISIBLE_CAST = false

    //When AUTO_RESET_MANA_COOLDOWN is set to true, xecast will reset
    // the dummy unit's cooldown and mana before casting every spell.
    // it is a performance penalty, so if you are sure that all dummy spells
    // in your map got 0 mana and cooldown cost, you may set it to false.    
    private constant boolean AUTO_RESET_MANA_COOLDOWN = true 
 endglobals

//=========================================================================
// Please notice all textmacros in this library are considered private.
//  in other words: DON'T RUN THOSE TEXTMACROS!
//
private keyword structinit

globals
    private real EPSILON=0.001 //noticed in war3 this is the sort of precision we want...
endglobals

struct xecast[MAXINSTANCES]

    public integer abilityid    = 0    //ID (rawcode) of the ability to cast
    public integer level        = 1    //Level of the ability to cast

    public real    recycledelay = 0.0  //Please notice, some spells need a recycle delay
                                       // This is, a time period before they get recycle.
                                       // For example, some spells are not instant, there is
                                       // also the problem with damaging spells, this recycle
                                       // delay must be large enough to contain all the time
                                       // in which the spell can do damage.


    public player  owningplayer=Player(15)  //which player to credit for the ability cast?
                                            //notice this can also affect what units are targeteable

    //==================================================================================================
    // You need an order id for the ability so the dummy unit is able to cast it, two ways to assign it
    //   set instance.orderid     = 288883            //would assign an integer orderid
    //   set instance.orderstring = "chainlightning"  //would assign an orderstring
    //                                                 (as those in the object editor)
    //
    method operator orderid= takes integer v returns nothing 
        set .oid=v
    endmethod
    method operator orderstring= takes string s returns nothing
        set .oid=OrderId(s)
    endmethod

    //=================================================================================================
    // Finally, you can determine from which point to cast the ability: z is the height coordinate.
    //
    public boolean customsource=false //Use a custom casting source?

    public real    sourcex     // Determine the casting source for the dummy spell, require customsource =true
    public real    sourcey     // You might prefer to use the setSourcePoint method
    public real    sourcez=0.0 //

    method setSourcePoint takes real x, real y, real z returns nothing
       set .sourcex=x
       set .sourcey=y
       set .sourcez=z
       set .customsource=true
    endmethod

    method setSourceLoc takes  location loc, real z returns nothing
       set .sourcex=GetLocationX(loc)
       set .sourcey=GetLocationY(loc)
       set .sourcez=z
       set .customsource=true
    endmethod


    private boolean autodestroy  = false
    //========================================================================================================
    // you are always allowed to use .create() but you can also use createBasic which sets some things that
    // are usually necessary up.
    //
    public static method createBasic takes integer abilityID, integer orderid, player owner returns xecast
     local xecast r=xecast.allocate()
        if(r==0) then
            debug call BJDebugMsg("Warning: unbelievable but you actually used all xecast instances in your map! Please make sure you are not forgetting to destroy those what you create intensively, if that's not the case, then you'll have to increase xecast MAXINSTANCES")
        endif
        set r.oid=orderid
        set r.abilityid=abilityID
        set r.owningplayer=owner
     return r
    endmethod

    //========================================================================================================
    // Just like the above one, but the instance will self destruct after a call to any cast method
    // (recommended)
    //
    public static method createBasicA takes integer abilityID, integer orderid, player owner returns xecast
     local xecast r=xecast.allocate()
        if(r==0) then
            debug call BJDebugMsg("Warning: unbelievable but you actually used all xecast instances in your map! Please make sure you are not forgetting to destroy those what you create intensively, if that's not the case, then you'll have to increase xecast MAXINSTANCES")
        endif
        set r.oid=orderid
        set r.abilityid=abilityID
        set r.owningplayer=owner
        set r.autodestroy=true
     return r
    endmethod

    //==========================================================================================================
    // Just like create, but the struct instance self destructs after a call to any cast method
    // (Recommended)
    //
    public static method createA takes nothing returns xecast
     local xecast r=xecast.allocate()
        set r.autodestroy=true
     return r
    endmethod

    //==========================================================================================================
    // So, create the dummy, assign options and cast the skill!
    // .castOnTarget(u)       : If you want to hit a unit u with the ability, supports FORCE_INVISIBLE_CAST.
    // .castOnWidgetTarget(w) : If you want to hit a widget w with the ability.
    // .castOnPoint(x,y)      : If you want to hit a point (x,y) with the ability.
    // .castInPoint(x,y)      : For spells like warstomp which do not have a target.
    // .castOnAOE(x,y,radius) : Classic area of effect cast. Considers collision size.
    // .castOnGroup(g)        : Cast unit the unit group g, notice it will empty the group yet not destroy it.
    //

    //**********************************************************************************************************
    // The implementation of such methods follows: 

    private static  unit array dummystack
    private static  integer    top=0
    private static  unit       instantdummy

    private integer oid=0

    private static timer       gametime
    private static timer       T
    private static unit array  recycle
    private static real array  expiretime
    private static integer     rn=0

    //==========================================================================================================
    // private dorecycle method, sorry but I need this up here.
    //
    private static method dorecycle takes nothing returns nothing
     local unit u =.recycle[0]
     local integer l
     local integer r
     local integer p
     local real    lt
        call IssueImmediateOrder(u,"stop")// bugfix, see: http://www.wc3c.net/showpost.php?p=1131163&postcount=5
        call UnitRemoveAbility(u,GetUnitUserData(u))
        call SetUnitUserData(u,0)
        call SetUnitFlyHeight(u,0,0)
        call PauseUnit(u,false)
        if(.top==DUMMY_STACK_LIMIT) then
            call RemoveUnit(u)
        else
            set .dummystack[.top]=u
            set .top=.top+1
        endif
        set .rn=.rn-1
        if(.rn==0) then
            return
        endif
        set p=0
        set lt=.expiretime[.rn]
        loop
            set l=p*2+1
            exitwhen l>=.rn
            set r=p*2+2
            if(r>=.rn)then
                if(.expiretime[l]<lt) then
                    set .expiretime[p]=.expiretime[l]
                    set .recycle[p]=.recycle[l]
                    set p=l
                else
                    exitwhen true
                endif
            elseif (lt<=.expiretime[l]) and (lt<=.expiretime[r]) then
                exitwhen true
            elseif (.expiretime[l]<.expiretime[r]) then
                set .expiretime[p]=.expiretime[l]
                set .recycle[p]=.recycle[l]
                set p=l
            else
                set .expiretime[p]=.expiretime[r]
                set .recycle[p]=.recycle[r]
                set p=r
            endif
        endloop
        set .recycle[p]=.recycle[.rn]
        set .expiretime[p]=lt
        call TimerStart(.T, .expiretime[0]-TimerGetElapsed(.gametime), false, function xecast.dorecycle)
    endmethod

    private static trigger abilityRemove


    // Repetitive process and no inline implemented for large functions, so for now it is a textmacro:
    //! textmacro xecast_allocdummy
        if(.recycledelay<EPSILON) then
            set dummy=.instantdummy
            call SetUnitOwner(dummy,.owningplayer,false)
        elseif (.top>0) then
            set .top=.top-1
            set dummy=.dummystack[.top]
            call SetUnitOwner(dummy,.owningplayer,false)
        else
            set dummy=CreateUnit(.owningplayer,XE_DUMMY_UNITID,0,0,0)
            call TriggerRegisterUnitEvent(.abilityRemove,dummy,EVENT_UNIT_SPELL_ENDCAST)
            call UnitAddAbility(dummy,'Aloc')
            call UnitAddAbility(dummy,XE_HEIGHT_ENABLER)
            call UnitRemoveAbility(dummy,XE_HEIGHT_ENABLER)
        endif
        call UnitAddAbility(dummy, abilityid)
        static if AUTO_RESET_MANA_COOLDOWN then
            call UnitResetCooldown(dummy)
            call SetUnitState(dummy, UNIT_STATE_MANA, 10000.0)
        endif
        if(level>1) then
            call SetUnitAbilityLevel(dummy, abilityid, level)
        endif
    //! endtextmacro
    private static integer cparent
    private static integer current
    private static real    cexpire
    //! textmacro xecast_deallocdummy
        if(.recycledelay>=EPSILON) then
            set .cexpire=TimerGetElapsed(.gametime)+.recycledelay
            set .current=.rn
            set .rn=.rn+1
            loop
                exitwhen (.current==0)
                set .cparent=(.current-1)/2
                exitwhen (.expiretime[.cparent]<=.cexpire)
                set .recycle[.current]=.recycle[.cparent]
                set .expiretime[.current]=.expiretime[.cparent]
                set .current=.cparent
            endloop
            set .expiretime[.current]=.cexpire
            set .recycle[.current]=dummy
            call SetUnitUserData(dummy,.abilityid)
            call TimerStart(.T, .expiretime[0]-TimerGetElapsed(.gametime), false, function xecast.dorecycle)
        else
            call SetUnitUserData(dummy,0)
            call SetUnitFlyHeight(dummy,0,0)
            call UnitRemoveAbility(dummy,.abilityid)
        endif
    //! endtextmacro

    method castOnTarget takes unit target returns nothing
     local unit dummy
     local unit tar
        //! runtextmacro xecast_allocdummy()
        if (.customsource) then
            call SetUnitX(dummy,.sourcex)
            call SetUnitY(dummy,.sourcey)
            call SetUnitFlyHeight(dummy,.sourcez,0.0)
        else
            call SetUnitX(dummy,GetWidgetX(target))
            call SetUnitY(dummy,GetWidgetY(target))
        endif
        static if (FORCE_INVISIBLE_CAST) then
            call UnitShareVision(target, .owningplayer, true)
            call IssueTargetOrderById(dummy,this.oid,target)
            call UnitShareVision(target, .owningplayer, false)
        else
            call IssueTargetOrderById(dummy,this.oid,target)
        endif

        //! runtextmacro xecast_deallocdummy()
        if(.autodestroy ) then
            call this.destroy()
        endif
    endmethod

    //accepts units, items and destructables, if you know it is
    // a unit it is better to use castOnTarget since that would
    // be able to use FORCE_INVISIBLE_CAST if necessary.
    //
    method castOnWidgetTarget takes widget target returns nothing
     local unit dummy
     local unit tar
        //! runtextmacro xecast_allocdummy()
        if (.customsource) then
            call SetUnitX(dummy,.sourcex)
            call SetUnitY(dummy,.sourcey)
            call SetUnitFlyHeight(dummy,.sourcez,0.0)
        else
            call SetUnitX(dummy,GetWidgetX(target))
            call SetUnitY(dummy,GetWidgetY(target))
        endif
        call IssueTargetOrderById(dummy,this.oid,target)

        //! runtextmacro xecast_deallocdummy()
        if(.autodestroy ) then
            call this.destroy()
        endif
    endmethod



    method castOnPoint takes real x, real y returns nothing
     local unit dummy
        //! runtextmacro xecast_allocdummy()
        if (.customsource) then
            call SetUnitX(dummy,.sourcex)
            call SetUnitY(dummy,.sourcey)
            call SetUnitFlyHeight(dummy,.sourcez,0.0)
        else
            call SetUnitX(dummy,x)
            call SetUnitY(dummy,y)
        endif
        call IssuePointOrderById(dummy,this.oid,x,y)
        //! runtextmacro xecast_deallocdummy()
        if(.autodestroy ) then
            call this.destroy()
        endif
    endmethod
    method castOnLoc takes location loc returns nothing
        //debug call BJDebugMsg("Warning: Locations are in use")
        //nah but I should 
        call .castOnPoint(GetLocationX(loc),GetLocationY(loc))
    endmethod

    //ignores custom source x and y (for obvious reasons)
    method castInPoint takes real x, real y returns nothing
     local unit dummy
        //! runtextmacro xecast_allocdummy()
        if (.customsource) then
            call SetUnitFlyHeight(dummy,.sourcez,0.0)
        endif
        call SetUnitX(dummy, x)
        call SetUnitY(dummy, y)
        call IssueImmediateOrderById(dummy,this.oid)
        //! runtextmacro xecast_deallocdummy()
        if(.autodestroy ) then
            call this.destroy()
        endif
    endmethod
    method castInLoc takes location loc returns nothing
        //debug call BJDebugMsg("Warning: Locations are in use")
        //nah but I should 
        call .castInPoint(GetLocationX(loc),GetLocationY(loc))
    endmethod


    //===================================================================================================
    // For method castOnAOE:
    //
    private static group    enumgroup
    private static real     aoex
    private static real     aoey
    private static real     aoeradius
    private static xecast   cinstance
    private static boolexpr aoefunc

    // Might look wrong, but this is the way to make it consider collision size, a spell that
    // got a target circle and uses this method will let the user know which units it will
    // hit with the mass cast.
    static method filterAOE takes nothing returns boolean
     local unit u=GetFilterUnit()
        if IsUnitInRangeXY(u, .aoex, .aoey, .aoeradius) then
            call .cinstance.castOnTarget(u)
        endif
     set u=null
     return false
    endmethod

    //
    method castOnAOE takes real x, real y, real radius returns nothing
     local boolean ad=this.autodestroy

        if(ad) then
            set this.autodestroy=false
        endif
        set .aoex=x
        set .aoey=y
        set .aoeradius=radius
        set .cinstance=this
        call GroupEnumUnitsInRange(.enumgroup,x,y,radius + XE_MAX_COLLISION_SIZE , .aoefunc)
        if(ad) then
            call this.destroy()
        endif
    endmethod

    method castOnAOELoc takes location loc,real radius returns nothing
        call .castOnAOE(GetLocationX(loc),GetLocationY(loc),radius)
    endmethod

    //==================================================================================================
    // A quick and dirt castOnGroup method, perhaps it'll later have castOntarget inlined, but not now
    //
    method castOnGroup takes group g returns nothing
     local boolean ad=this.autodestroy    
     local unit t
        if(ad) then
            set this.autodestroy=false
        endif

        loop
            set t=FirstOfGroup(g)
            exitwhen(t==null)
            call GroupRemoveUnit(g,t)
            call .castOnTarget(t)
        endloop
        if(ad) then
            call this.destroy()
        endif
    endmethod

    private static method removeAbility takes nothing returns boolean
     local unit u=GetTriggerUnit()
         if(GetUnitUserData(u)!=0) then
             call PauseUnit(u,true)
         endif
        //This is necessary, picture a value for recycle delay that's higher than the casting time,
        //for example if the spell does dps, if you leave the dummy caster with the ability and it 
        //is owned by an AI player it will start casting the ability on player units, so it is
        // a good idea to pause it...

     set u=null
     return true
    endmethod

    //===================================================================================================
    // structinit is a scope private keyword.
    //
    static method structinit takes nothing returns nothing
     local integer i=INITIAL_DUMMY_COUNT+1
     local unit u
        set .aoefunc=Condition(function xecast.filterAOE)
        set .enumgroup=CreateGroup()
        set .abilityRemove = CreateTrigger()
        loop
            exitwhen (i==0)
            set u=CreateUnit(Player(15),XE_DUMMY_UNITID,0,0,0)
            call TriggerRegisterUnitEvent(.abilityRemove,u,EVENT_UNIT_SPELL_ENDCAST)
            call UnitAddAbility(u,'Aloc')
            call UnitAddAbility(u,XE_HEIGHT_ENABLER)
            call UnitRemoveAbility(u,XE_HEIGHT_ENABLER)
            set .dummystack[.top]=u
            set .top=.top+1
            set i=i-1
        endloop
        call TriggerAddCondition(.abilityRemove, Condition(function xecast.removeAbility ) )
        set .top=.top-1
        set .instantdummy=.dummystack[.top]
        set .T=CreateTimer()
        set .gametime=CreateTimer()
        call TimerStart(.gametime,12*60*60,false,null)
    endmethod


endstruct


private function init takes nothing returns nothing
    call xecast.structinit()
endfunction

endlibrary


