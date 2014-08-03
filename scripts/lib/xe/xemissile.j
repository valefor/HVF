library xemissile requires xefx, xebasic
//****************************************************************
//*
//* xemissile 0.9
//* -------------
//*  A xemissile object is a special effect that moves like a
//* WC3's attack or spell missile.
//*
//*  Please use .terminate() instead of .destroy() this ensures
//* that it will be safe to destroy it (else you would have to
//* worry about destroying it during the animation loop/etc.)
//*
//*  This struct is used similarly to xecollider. Instead of just
//* creating the xemissile (which works, but it would only be a
//* xefx that can move like a missile) you probably need to make
//* it do something special when it reaches its target...
//* For this reason, you need to make a new struct extending
//* xemissile that declares an onHit method, you may also declare
//* a loopControl method.
//*
//****************************************************************


    //===========================================================================
    // So, this exists merely so you can declare your own event handler methods
    // if interfaces make your brain blow out, please skip the next four lines.
    //
    private interface eventHandler
        method onHit takes nothing returns nothing defaults nothing
        method loopControl takes nothing returns nothing defaults nothing
    endinterface
    
    //===========================================================================

    private struct missile extends eventHandler
        private delegate xefx fx

        // movement duration parameter.
        private real time
        // xy movement parameters.
        private real mx
        private real my
        private real mvx
        private real mvy
        private real mvxy = 1.0
        // z movement parameters.
        private real mz
        private real mvz
        private real maz
        private static location l  = Location(0.0,0.0)
        // target parameters.
        private real tx = 0.0
        private real ty = 0.0
        private real tz = 0.0
        private unit tu = null
        public real zoffset = 0.0
        
        private boolean update = true
        private boolean launched = false
        private boolean dead = false
        
        public method operator x takes nothing returns real
            return .mx
        endmethod
        public method operator y takes nothing returns real
            return .my
        endmethod
        public method operator z takes nothing returns real
            call MoveLocation(.l, .mx,.my)
            return mz-GetLocationZ(.l)
        endmethod
        
        public method operator x= takes real r returns nothing
            set .update=true
            set .mx=r
        endmethod
        public method operator y= takes real r returns nothing
            set .update=true
            set .my=r
        endmethod
        public method operator z= takes real r returns nothing
            set .update=true
            call MoveLocation(.l, .mx,.my)
            set .mz=r+GetLocationZ(.l)
        endmethod

        public method operator speed takes nothing returns real
            return .mvxy/XE_ANIMATION_PERIOD
        endmethod
        public method  operator speed= takes real newspeed returns nothing
            local real factor=newspeed*XE_ANIMATION_PERIOD/.mvxy
            if newspeed<=0.0 then
                debug call BJDebugMsg("xemissile speed error: speed must be a non-zero positive value.")
                return
            endif
            set .mvxy=newspeed*XE_ANIMATION_PERIOD
            if .launched then
                set .time=.time/factor
                set .mvx=.mvx*factor
                set .mvy=.mvy*factor
                set .mvz=.mvz*factor
                set .maz=.maz*factor*factor
            endif
        endmethod

        public method operator targetUnit takes nothing returns unit
            return this.tu
        endmethod
        public method operator targetUnit= takes unit u returns nothing
            set .update=true
            set .tu=u
            set .tx=GetUnitX(u)
            set .ty=GetUnitY(u)
            call MoveLocation(.l, .tx,.ty)
            set .tz=GetUnitFlyHeight(u)+GetLocationZ(.l)+.zoffset
        endmethod
        
        public method setTargetPoint takes real x, real y, real z returns nothing
            set .update=true
            set .tu=null
            set .tx=x
            set .ty=y
            call MoveLocation(.l, .tx,.ty)
            set .tz=z+GetLocationZ(.l)
        endmethod

        //-------- Missile launcher

        public method launch takes real speed, real arc returns nothing
            local real dx=.tx-.mx
            local real dy=.ty-.my
            local real d=SquareRoot(dx*dx+dy*dy)
            local real a=Atan2(dy, dx)
            local real dz=.tz-.mz
            set .mvxy=speed*XE_ANIMATION_PERIOD
            if speed<=0.0 then
                debug call BJDebugMsg("xemissile launch error: speed must be a non-zero positive value.")
                return
            elseif d>0.0 then
                set .time=d/speed
            else
                set .time=XE_ANIMATION_PERIOD
            endif
            set .mvz=( (d*arc)/(.time/4.0) + dz/.time )*XE_ANIMATION_PERIOD // Do some mathemagics to get a proper arc.

            set .dead=.dead and not(.launched) // In case this is called from the onHit method to bounce the missile.
            
            if not .dead and not .launched then
                set .launched=true
                set .V[.N]=this
                set .N=.N+1
                if(.N==1) then
                    call TimerStart(.T, XE_ANIMATION_PERIOD, true, xemissile.timerLoopFunction )
                endif
            endif
        endmethod
        
        //-------- Constructors and destructors

        static method create takes real x, real y, real z, real a returns missile
         local missile this=missile.allocate()
            set .mx=x
            set .my=y
            call MoveLocation(.l, x,y)
            set .mz=z+GetLocationZ(.l)

            set .fx = xefx.create(x,y,a)
            set .fx.z = z
         return this
        endmethod

        private boolean silent=false
        private method destroy takes nothing returns nothing
            if(this.silent) then
                call this.fx.hiddenDestroy()
            else
                call this.fx.destroy()
            endif
            call .deallocate()
        endmethod

        method terminate takes nothing returns nothing
            set this.dead=true
            set this.fx.zangle=0.0
            set this.fxpath=""
        endmethod
        // declare hiddenDestroy so people don't call directly on the delegate xefx
        method hiddenDestroy takes nothing returns nothing
            set silent = true
            call terminate()
        endmethod

        //-------- Main engine

        private static timer      T
        private static integer    N=0
        private static xemissile array V
        private static code       timerLoopFunction  //I use a code var so create can be above the timerloop function, more readable

        private static method timerLoop takes nothing returns nothing
         local integer i=0
         local integer c=0
         local thistype this
         
         local real dx
         local real dy
         local real d
         local real a

            loop
                exitwhen (i==.N )

                set this=.V[i] //adopt-a-instance
                if .dead then
                    set .launched=false
                    set this.fx.zangle=0.0
                    call .destroy()
                else
                    if .tu!=null and GetUnitTypeId(.tu)!=0 then
                        set .update=true
                        set .tx=GetUnitX(.tu)
                        set .ty=GetUnitY(.tu)
                        call MoveLocation(.l, .tx,.ty)
                        set .tz=GetUnitFlyHeight(.tu)+GetLocationZ(.l)+.zoffset
                    endif
                    if .update then
                        set .update=false
                        set dx=.tx-.mx
                        set dy=.ty-.my
                        set d=SquareRoot(dx*dx+dy*dy)
                        set a=Atan2(dy,dx)
                        if d>0.0 then
                            set .time=d/.mvxy*XE_ANIMATION_PERIOD
                        else
                            set .time=XE_ANIMATION_PERIOD
                        endif
                        set .mvx=Cos(a)*.mvxy
                        set .mvy=Sin(a)*.mvxy
                        set .fx.xyangle=a
                        set .maz=2*((.tz-.mz)/.time/.time*XE_ANIMATION_PERIOD*XE_ANIMATION_PERIOD-(.mvz*XE_ANIMATION_PERIOD)/.time)
                    endif
                    
                    set .mx=.mx+.mvx
                    set .my=.my+.mvy
                    set a=.maz/2.0
                    set .mvz=.mvz+a
                    set .mz=.mz+.mvz
                    set .mvz=.mvz+a

                    set .fx.x=.mx
                    set .fx.y=.my
                    call MoveLocation(.l, .mx,.my)
                    set .fx.z=.mz-GetLocationZ(.l)
                    set .fx.zangle=Atan2(.mvz, .mvxy)
                    
                    set .time=.time-XE_ANIMATION_PERIOD
                    if .time<=0.0 then
                        set .dead=true
                        call this.onHit()
                        if .dead then
                            set .fxpath=""
                        endif
                    endif

                    set .V[c]=this
                    set c=c+1
                    if( this.loopControl.exists and not this.dead ) then
                        call this.loopControl()
                    endif
                endif
                set i=i+1
            endloop
            set .N=c
            if(c==0) then
                call PauseTimer(.T)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            set .timerLoopFunction = (function missile.timerLoop)
            set .T=CreateTimer()
        endmethod
    endstruct

    //===========================================================================

    struct xemissile extends missile
        public static method create takes real x,real y,real z, real tx,real ty,real tz returns xemissile
         local xemissile xm = xemissile.allocate(x,y,z, Atan2(ty-y,tx-x))
            call xm.setTargetPoint(tx,ty,tz)
         return xm
        endmethod
    endstruct

    struct xehomingmissile extends xemissile
        public static method create takes real x,real y,real z, unit target,real zoffset returns xehomingmissile
         local xehomingmissile xm = xehomingmissile.allocate(x,y,z, GetUnitX(target), GetUnitY(target), 0.0)
            set xm.zoffset=zoffset
            set xm.targetUnit=target
         return xm
        endmethod
    endstruct

endlibrary
