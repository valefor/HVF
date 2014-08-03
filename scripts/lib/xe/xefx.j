library xefx initializer init requires xebasic, optional xedummy
//**************************************************
// xefx 0.9
// --------
//  Recommended: ARGB (adds ARGBrecolor method)
//  For your movable fx needs
//
//**************************************************

//==================================================
 globals
    private constant integer MAX_INSTANCES = 8190 //change accordingly.

    //Delay in order to show the death animation of the effect correctly when xefx is destroyed.
    //You may need to increase this if you are using effects with longer death animations.
    private constant real    MIN_RECYCLE_DELAY = 4.0

    //The delay does not need to be exact so we do cleanup in batches instead of individually.
    //This determines how often the recycler runs, should be less than MIN_RECYCLE_DELAY.
    private constant real    RECYCLE_INTERVAL = 0.5

    //if this is true and the xedummy library is present, units will be recycled instead of removed.
    private constant boolean RECYCLE_DUMMY_UNITS = true
    
    private timer    recycler
 endglobals

   private struct recyclebin
       unit u

       private recyclebin next=0
       private static recyclebin array list
       private static integer readindex=1
       private static integer writeindex=0
       private static integer count=0

       static method Recycle takes nothing returns nothing
            local recyclebin this = .list[readindex]
            loop
                exitwhen this==0
                static if RECYCLE_DUMMY_UNITS and LIBRARY_xedummy then
                    call XE_ReleaseDummyUnit(this.u)
                else
                    call RemoveUnit(this.u)
                endif
                set this.u=null
                set .count=.count-1
                call this.destroy()
                set this=this.next
            endloop
            set .list[readindex]=0
            set .writeindex=.readindex
            set .readindex=.readindex+1
            if .readindex>R2I(MIN_RECYCLE_DELAY/RECYCLE_INTERVAL+1.0) then
                set .readindex=0
            endif
            if count!=0 then
                call TimerStart(recycler, RECYCLE_INTERVAL, false, function recyclebin.Recycle)
            endif
       endmethod
       
       static method create takes unit u returns recyclebin
           local recyclebin this=recyclebin.allocate()
           if .count==0 then
                call TimerStart(recycler, RECYCLE_INTERVAL, false, function recyclebin.Recycle)
           endif
           set .count=.count+1
           set .u=u
           call SetUnitOwner(u,Player(15),false)
           set .next=.list[.writeindex]
           set .list[.writeindex]=this
           return this
       endmethod
   endstruct



   private function init takes nothing returns nothing
       set recycler=CreateTimer()
   endfunction

   struct xefx[MAX_INSTANCES]
       public integer tag=0
       private unit   dummy
       private effect fx=null
       private real   zang=0.0
       private integer r=255
       private integer g=255
       private integer b=255
       private integer a=255

       private integer abil=0

       static method create takes real x, real y, real facing returns xefx
        local xefx this=xefx.allocate()
           static if RECYCLE_DUMMY_UNITS and LIBRARY_xedummy then
               set this.dummy= XE_NewDummyUnit(Player(15), x,y, facing*bj_RADTODEG)
           else
               set this.dummy= CreateUnit(Player(15), XE_DUMMY_UNITID, x,y, facing*bj_RADTODEG)
               call UnitAddAbility(this.dummy,XE_HEIGHT_ENABLER)
               call UnitAddAbility(this.dummy,'Aloc')
               call UnitRemoveAbility(this.dummy,XE_HEIGHT_ENABLER)
               call SetUnitX(this.dummy,x)
               call SetUnitY(this.dummy,y)
           endif
        return this
       endmethod

       method operator owner takes nothing returns player
           return GetOwningPlayer(this.dummy)
       endmethod

       method operator owner= takes player p returns nothing
           call SetUnitOwner(this.dummy,p,false)
       endmethod

       method operator teamcolor= takes playercolor c returns nothing
           call SetUnitColor(this.dummy,c)
       endmethod

       method operator scale= takes real value returns nothing
           call SetUnitScale(this.dummy,value,value,value)
       endmethod

       //! textmacro XEFX_colorstuff takes colorname, colorvar
       method operator $colorname$ takes nothing returns integer
           return this.$colorvar$
       endmethod
       method operator $colorname$= takes integer value returns nothing
           set this.$colorvar$=value
           call SetUnitVertexColor(this.dummy,this.r,this.g,this.b,this.a)
       endmethod
       //! endtextmacro
       //! runtextmacro XEFX_colorstuff("red","r")
       //! runtextmacro XEFX_colorstuff("green","g")
       //! runtextmacro XEFX_colorstuff("blue","b")
       //! runtextmacro XEFX_colorstuff("alpha","a")

       method recolor takes integer r, integer g , integer b, integer a returns nothing
           set this.r=r
           set this.g=g
           set this.b=b
           set this.a=a
           call SetUnitVertexColor(this.dummy,this.r,this.g,this.b,this.a)
       endmethod

       implement optional ARGBrecolor

       method operator abilityid takes nothing returns integer
           return this.abil
       endmethod

       method operator abilityid= takes integer a returns nothing
           if(this.abil!=0) then
               call UnitRemoveAbility(this.dummy,this.abil)
           endif

           if(a!=0) then
               call UnitAddAbility(this.dummy,a)
           endif
           set this.abil=a
       endmethod
       
       method operator abilityLevel takes nothing returns integer
           return GetUnitAbilityLevel( this.dummy, this.abil)
       endmethod
       
       method operator abilityLevel= takes integer newLevel returns nothing
           call SetUnitAbilityLevel(this.dummy, this.abil, newLevel)
       endmethod

       method flash takes string fx returns nothing
           call DestroyEffect(AddSpecialEffectTarget(fx,this.dummy,"origin"))
       endmethod

       method operator xyangle takes nothing returns real
           return GetUnitFacing(this.dummy)*bj_DEGTORAD
       endmethod
       method operator xyangle= takes real value returns nothing
           call SetUnitFacing(this.dummy,value*bj_RADTODEG)
       endmethod

       method operator zangle takes nothing returns real
           return this.zang
       endmethod

       method operator zangle= takes real value returns nothing
        local integer i=R2I(value*bj_RADTODEG+90.5)
           set this.zang=value
           if(i>=180) then
               set i=179
           elseif(i<0) then
               set i=0
           endif
               
           call SetUnitAnimationByIndex(this.dummy, i  )
       endmethod


       method operator x takes nothing returns real
           return GetUnitX(this.dummy)
       endmethod
       method operator y takes nothing returns real
           return GetUnitY(this.dummy)
       endmethod
       method operator z takes nothing returns real
           return GetUnitFlyHeight(this.dummy)
       endmethod

       method operator z= takes real value returns nothing
           call SetUnitFlyHeight(this.dummy,value,0)
       endmethod

       method operator x= takes real value returns nothing
           call SetUnitX(this.dummy,value)
       endmethod

       method operator y= takes real value returns nothing
           call SetUnitY(this.dummy,value)
       endmethod

       method operator fxpath= takes string newpath returns nothing
           if (this.fx!=null) then
               call DestroyEffect(this.fx)
           endif
           if (newpath=="") then
               set this.fx=null
           else
               set this.fx=AddSpecialEffectTarget(newpath,this.dummy,"origin")
           endif

       endmethod
       
       method hiddenReset takes string newfxpath, real newfacing returns nothing
        local real x = GetUnitX(this.dummy)
        local real y = GetUnitY(this.dummy)
        local real z = this.z
        local real za = this.zangle
        local integer level = this.abilityLevel
           set .fxpath=null
           static if RECYCLE_DUMMY_UNITS and LIBRARY_xedummy then
               if(this.abil!=0) then
                   call UnitRemoveAbility(this.dummy,this.abil)
               endif
               call recyclebin.create(this.dummy)
               set this.dummy=XE_NewDummyUnit(Player(15), x,y, newfacing*bj_RADTODEG)
           else
               call RemoveUnit(this.dummy)
               set this.dummy= CreateUnit(Player(15), XE_DUMMY_UNITID, x,y, newfacing*bj_RADTODEG)
               call UnitAddAbility(this.dummy,XE_HEIGHT_ENABLER)
               call UnitAddAbility(this.dummy,'Aloc')
               call UnitRemoveAbility(this.dummy,XE_HEIGHT_ENABLER)
               call SetUnitX(this.dummy,x)
               call SetUnitY(this.dummy,y)
           endif
           set .fxpath=newfxpath
           if(level != 0) then
               call UnitAddAbility(this.dummy, this.abil) 
               call SetUnitAbilityLevel(this.dummy, this.abil, level)
           endif
           set this.z = z
           set zangle = za
       endmethod


       method destroy takes nothing returns nothing
           if(this.abil!=0) then
               call UnitRemoveAbility(this.dummy,this.abil)
           endif
           if(this.fx!=null) then
               call DestroyEffect(this.fx)
               set this.fx=null
           endif
           call recyclebin.create(this.dummy)
           set this.dummy=null
           call this.deallocate()
       endmethod

       method hiddenDestroy takes nothing returns nothing           
           call ShowUnit(dummy,false)
           call destroy()
       endmethod
       
   endstruct

endlibrary




