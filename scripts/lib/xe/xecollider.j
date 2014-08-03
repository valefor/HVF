library xecollider initializer init requires xefx, xebasic
//****************************************************************
//*
//* xecollider 0.9
//* --------------
//*  A xecollider object is a special effect that has a collision
//* size that can trigger a hit event and also many options to
//* configure its automatic movement.
//*
//*  Please use .terminate() instead of .destroy() this ensures
//* that it will be safe to destroy it (else you would have to
//* worry about destroying it during the animation loop/etc.)
//*
//*  To use this struct is a little different than the other
//* current parts of xe. Instead of just creating the xecollider
//* (which works, but it would only be a xefx that can have speed)
//* you probably need to make it do something special on the
//* unit hit event... For this reason, you need to make a new
//* struct extending xecollider that declares an onUnitHit method
//* you may also declare a loopControl method, very useful, can
//* help you reduce 'attaching'.
//*
//****************************************************************

//================================================================
    globals
        private constant real DEFAULT_COLLISION_SIZE  =   50.0 // These are defaults, on one hand you can change them
        private constant real DEFAULT_MAX_SPEED       = 1500.0 // on the other hand, if a spell relies on the defaults
        private constant real DEFAULT_EXPIRATION_TIME =    5.0 // changing them would make the behavior vary...

        private constant real PI2 = 6.28318 //It might not be wise to change this
    endglobals

    //===========================================================================
    // So, this exists merely so you can declare your own event handler methods
    // if interfaces make your brain blow out, please skip the next four lines.
    //
    private interface eventHandler
        method onUnitHit takes unit hitTarget returns nothing defaults nothing
        method loopControl takes nothing returns nothing defaults nothing
    endinterface

    //===========================================================================
    struct xecollider extends eventHandler
     // use terminate() instead of .destroy() to "kill" the collider.
     // don't worry, terminate will call destroy automatically.

        //============================================================================
        // delegates:
        //   We are delegating a xefx object so that people call all the xefx methods
        //  and member from a xecollider object. This means that from a user
        // perspective a xecollider is also an instance of xefx. 
        //
        //   Notable ones are: .x , .y , .fxpath and .z ,
        // check out xefx's documentation for more info.
        //
        private delegate xefx fx

        //##==========================================================================
        // public variables:
        //
        public real expirationTime = DEFAULT_EXPIRATION_TIME

        // Movement speed for the missile.
        public real speed          = 0.0

        // Speed added per second (notice you can use a negative value here)
        public real acceleration   = 0.0

        // If there is acceleration, it is wise to have a cap...
        public real maxSpeed       = DEFAULT_MAX_SPEED
        public real minSpeed       = 0.0

        public real angleSpeed     = 0.0 //The increment in radians per second to the
                                         // direction angle, allows curved movement.

        private static integer lastSeen = 0
        private group   seen

        //##==========================================================================
        // public methods:
        //

        //----
        // Well, it is a good idea to actually create the missiles.
        // notice that if your custom missile struct needs to declare its own create
        // method, you can call this as allocate(x,y,dir).
        //
        // Sorry, no Loc version.
        //
        public static method create takes real x, real y, real dir returns xecollider
         local xecollider xc= xecollider.allocate()
            set xc.fx = xefx.create(x,y,dir)
            set xc.dir=dir
            set xecollider.V[xecollider.N]=xc
            set xecollider.N=xecollider.N+1
            if(xecollider.N==1) then
                call TimerStart(xecollider.T, XE_ANIMATION_PERIOD, true, xecollider.timerLoopFunction )
            endif
            if(.lastSeen < integer(xc)) then //with this I do group recycling
                set .lastSeen = integer(xc)
                set xc.seen = CreateGroup()
            endif

         return xc
        endmethod

        //----
        // The direction is just the angle in radians to which the missile's model faces
        // and the automatic movement uses.
        //
        method operator direction takes nothing returns real
            return this.dir
        endmethod
        method operator direction= takes real v returns nothing
            set this.dir=v
            set this.fx.xyangle=v
        endmethod

        //----
        // The collisionSize
        //
        method operator collisionSize takes nothing returns real
            return this.csize
        endmethod
        method operator collisionSize= takes real value returns nothing
            set this.csize = value
            //good long attribute name, but we use csize in the loop
            //don't worry this gets inlined, it would also be helpful if
            //I ever decide to add a control for assignment.
        endmethod



        //---
        // targetUnit is a unit to follow (or try to follow), notice that homing
        // options require an angleSpeed different to 0.0
        //
        public method  operator targetUnit takes nothing returns unit
            return this.homingTargetUnit
        endmethod
        public method  operator targetUnit= takes unit u returns nothing
            if(u==null) then
                set this.angleMode= ANGLE_NO_MOVEMENT
            else
                set this.angleMode= ANGLE_HOMING_UNIT
            endif
            set this.homingTargetUnit=u
        endmethod

        //----
        // targetPoint is a point to reach (or try to reach), notice that homing
        // options require an angleSpeed different to 0.0
        //
        public method setTargetPoint takes real x, real y returns nothing
            set this.angleMode= ANGLE_HOMING_POINT
            set this.homingTargetX=x
            set this.homingTargetY=y
        endmethod
        public method setTargetPointLoc takes location loc returns nothing
            set this.angleMode= ANGLE_HOMING_POINT
            set this.homingTargetX=GetLocationX(loc)
            set this.homingTargetY=GetLocationY(loc)
        endmethod

        //----
        // Call this in case you used targetUnit or TargetPoint so the missile
        // forgets the order to home that target.
        //
        public method forgetTarget takes nothing returns nothing
            set this.angleMode = ANGLE_NO_MOVEMENT
        endmethod
        
        public method operator rotating takes nothing returns boolean
            return (angleMode ==ANGLE_ROTATING) 
        endmethod
        public method operator rotating= takes boolean val returns nothing
            if(val) then
                 set angleMode = ANGLE_ROTATING
            elseif (angleMode == ANGLE_ROTATING) then
                 set angleMode = ANGLE_NO_MOVEMENT
            endif
        endmethod
        
        private boolean silent = false
        private method destroy takes nothing returns nothing
            call GroupClear(this.seen)
            if(this.silent) then
                call this.fx.hiddenDestroy()
            else
                call this.fx.destroy()
            endif
            call .deallocate()
        endmethod

        method terminate takes nothing returns nothing
            set this.dead=true
            set this.fxpath=""
        endmethod
        // declare hiddenDestroy so people don't call directly on the delegate xefx
        method hiddenDestroy takes nothing returns nothing
            set silent = true
            call terminate()
        endmethod


        //--------
        private static timer      T
        private static integer    N=0
        private static xecollider array V

        private static code       timerLoopFunction  //I use a code var so create can be above the timerloop function, more readable
        
        private        boolean dead=false


        private real csize = DEFAULT_COLLISION_SIZE
       


        private          real dir


        private static constant integer ANGLE_HOMING_UNIT =1
        private static constant integer ANGLE_HOMING_POINT=2
        private static constant integer ANGLE_NO_MOVEMENT=0
        private static constant integer ANGLE_ROTATING=3
        
        private                 integer angleMode  =0

        private unit homingTargetUnit = null
        private real homingTargetX
        private real homingTargetY


        private static real       newx
        private static real       newy
        private static group      enumGroup
        private static group      tempGroup

        private static unit array picked
        private static integer    pickedN

        static method timerLoop takes nothing returns nothing
         local integer i=0
         local integer c=0
         local xecollider this
         local real d
         local real ns
         local real wa
         local real df1
         local real df2
         local unit u
         local group g

            loop
               exitwhen (i== xecollider.N )

               set this=.V[i] //adopt-a-instance
               set this.expirationTime = this.expirationTime - XE_ANIMATION_PERIOD
               if(.dead or (this.expirationTime <=0.0) ) then
                   call this.destroy()
               else
                   set ns=this.angleSpeed*XE_ANIMATION_PERIOD
                   if (ns!=0.0) then
                       if(this.angleMode== ANGLE_HOMING_UNIT ) then
                           set u=this.homingTargetUnit
                           if ( (GetUnitTypeId(u)==0) or IsUnitType(u, UNIT_TYPE_DEAD) ) then
                               set this.angleMode= ANGLE_NO_MOVEMENT
                               set this.homingTargetUnit = null
                           else
                               set this.homingTargetX=GetUnitX(u)
                               set this.homingTargetY=GetUnitY(u)
                           endif
                           set u=null
                       endif    
                       if (this.angleMode == ANGLE_ROTATING)  then
                           //nothing (ns is already ns)
                       elseif( this.angleMode != ANGLE_NO_MOVEMENT) then 
                           if(ns<=0) then
                               set ns=-ns
                           endif
                           set wa=Atan2(this.homingTargetY - this.y , this.homingTargetX-this.x)

                           //if(wa<0.0) then
                           //    set wa=wa+PI2
                           //endif
                           set df1=wa-this.dir
                           set df2=(PI2+wa)-this.dir

                           if (df1<=0) then
                               if(df2<=0) then
                                   if(df2>=df1) then
                                       set df1=df2
                                   endif
                               else
                                   if(-df1>=df2) then
                                       set df1=df2
                                   endif
                               endif
                           else
                               if(df2<=0) then
                                   if(-df2<=df1) then
                                       set df1=df2
                                   endif
                               else
                                   if(df2<=df1) then
                                       set df1=df2
                                   endif
                               endif
                           endif
                           if(df1<=0) then
                               if(-df1>=ns) then
                                   set ns=-ns
                               else
                                   set ns=df1
                               endif
                           else
                               if(df1<=ns) then
                                   set ns=df1
                               endif
                           endif

                       else
                            set ns = 0
                       endif
                       set d=this.dir
                       set d = d + ns
                       if(d>=PI2) then
                           set d=d - PI2
                       elseif(d<0) then
                           set d=d + PI2
                       endif
                       set this.dir = d
                       set this.xyangle = d
                   endif

                   // function calls are expensive, damned we are, long code inside of loop
                   // correct software dev. tells us this should go to another function,
                   // but this is Jass, not real life.

                   set ns = this.speed + this.acceleration*XE_ANIMATION_PERIOD
                   if ( ns<this.minSpeed) then
                       set ns=this.minSpeed
                   elseif (ns>this.maxSpeed) then
                       set ns=this.maxSpeed
                   endif
                   set d=((this.speed+ns)/2) * XE_ANIMATION_PERIOD
                   set this.speed=ns
                   set .newx= .x+d*Cos(this.dir)
                   set .newy= .y+d*Sin(this.dir)
                   set .x=.newx
                   set .y=.newy

                   call GroupEnumUnitsInRange( .enumGroup, .newx, .newy, .csize + XE_MAX_COLLISION_SIZE, null)
                   loop
                       set u=FirstOfGroup(.enumGroup)
                       exitwhen u==null
                       call GroupRemoveUnit(.enumGroup, u)
                       if not IsUnitType(u, UNIT_TYPE_DEAD)  and not(this.dead) and (GetUnitTypeId(u)!=XE_DUMMY_UNITID) and IsUnitInRangeXY(u, .newx, .newy, .csize) then
                           call GroupAddUnit(.tempGroup, u)
                           if  not IsUnitInGroup (u, this.seen ) then
                               call this.onUnitHit(u)
                           endif
                       endif
                   endloop

                   set g=.tempGroup
                   call GroupClear(this.seen)
                   set .tempGroup=this.seen
                   set this.seen=g
                   set g=null

                   set .V[c]=this
                   set c=c+1
                   if( this.loopControl.exists and not this.dead ) then
                       call this.loopControl()
                   endif
               endif
               set i=i+1
            endloop
            //call BJDebugMsg("}")
            set xecollider.N=c
            if(c==0) then
                call PauseTimer(xecollider.T)
            endif

        endmethod

        //============================================================================
        // you aren't supposed to call doInit yourself, try not to do it.
        //
        static method doInit takes nothing returns nothing
            set xecollider.enumGroup = CreateGroup()
            set xecollider.tempGroup = CreateGroup()
            set xecollider.timerLoopFunction = (function xecollider.timerLoop)
            set xecollider.T=CreateTimer()
        endmethod
    endstruct

    private function init takes nothing returns nothing
        call xecollider.doInit()
    endfunction
endlibrary


