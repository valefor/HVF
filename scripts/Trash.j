        public method buthcerAllAnimal takes nothing returns nothing
            local group animals = CreateGroup()
            local unit toBeKilled //= FirstOfGroup()
            local integer gold = this.allAnimalIncome
            // Kill sheeps
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Sheep)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill pigs
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Pig)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill snakes
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Snake)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill chickens
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Chicken)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            call DestroyGroup(animals)
            set animals=null
            
            call AdjustPlayerStateBJ(gold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            
        endmethod
        
        /*
        static method enumSpawnSheep takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            local unit u
            local location rallyPoint = GetUnitRallyPoint(GetEnumUnit())
            
            set u = CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Sheep, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            call IssuePointOrderByIdLoc(u, ORDERID_smart, rallyPoint)
            call IssueTargetOrderById(u, ORDERID_smart, GetUnitRallyUnit(GetEnumUnit()))
            set f.sheepCount = f.sheepCount + 1
            
            call RemoveLocation(rallyPoint)
            set rallyPoint = null
            set u = null
        endmethod
        static method enumSpawnPig takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            local unit u
            local location rallyPoint = GetUnitRallyPoint(GetEnumUnit())
            
            set u = CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Pig, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            call IssuePointOrderByIdLoc(u, ORDERID_smart, rallyPoint)
            call IssueTargetOrderById(u, ORDERID_smart, GetUnitRallyUnit(GetEnumUnit()))
            set f.pigCount = f.pigCount + 1
            
            call RemoveLocation(rallyPoint)
            set rallyPoint = null
            set u = null
        endmethod
        static method enumSpawnSnake takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            call CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Snake, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            set f.snakeCount = f.snakeCount + 1
        endmethod
        static method enumSpawnChicken takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            call CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Chicken, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            set f.chickenCount = f.chickenCount + 1
        endmethod
        */
        
 function ItemTable000000_DropItems takes nothing returns nothing
    local widget trigWidget= null
    local unit trigUnit= null
    local integer itemID= 0
    local boolean canDrop= true
    set trigWidget=bj_lastDyingWidget
    if ( trigWidget == null ) then
        set trigUnit=GetTriggerUnit()
    endif
    if ( trigUnit != null ) then
        set canDrop=not IsUnitHidden(trigUnit)
        if ( canDrop and GetChangingUnit() != null ) then
            set canDrop=( GetChangingUnitPrevOwner() == Player(PLAYER_NEUTRAL_AGGRESSIVE) )
        endif
    endif
    if ( canDrop ) then
        // Item set 0
        call RandomDistReset()
        call RandomDistAddItem('engs', 10)
        call RandomDistAddItem(- 1, 90)
        set itemID=RandomDistChoose()
        if ( trigUnit != null ) then
            call UnitDropItem(trigUnit, itemID)
        else
            call WidgetDropItem(trigWidget, itemID)
        endif
    endif
    set bj_lastDyingWidget=null
    call DestroyTrigger(GetTriggeringTrigger())
endfunction

struct TimerManager extends array
    // Periodic Timers(PT)
    readonly static TimerPointer pt5s
    readonly static TimerPointer pt10s
    readonly static TimerPointer pt15s
    readonly static TimerPointer pt30s
    readonly static TimerPointer pt60s
    
    // Onetime Timers(OT)
    readonly static TimerPointer otGameStart
    readonly static TimerPointer otSelectHero
    readonly static TimerPointer otDetectionOn
    readonly static TimerPointer otDetectionOff
    readonly static TimerPointer otPlayTimeOver
    
    private static integer ptTickCount
    private static integer otTickCount
    
    // !DEPRECATED
    static method getTimer takes real timeout returns TimerPointer
        if timeout == CST_OT_SelectHero then
            return otSelectHero
        elseif timeout == CST_PT_1s then
            return pt10s
        elseif timeout == CST_PT_10s then
            return pt10s
        elseif timeout == CST_PT_15s then
            return pt15s
        elseif timeout == CST_PT_30s then
            return pt30s
        elseif timeout == CST_PT_60s then
            return pt60s
        else
            debug call BJDebugMsg("Unsupported timeout:" + R2S(timeout))
        endif
        return 0
    endmethod
    
    // Format any reals to OT timer count, something like 10.01, xx.01
    static method formatOtTimeout takes real c returns real
        local integer n = R2I(c/1)
        return I2R(n)+0.01
    endmethod
    
    static method isPeriodicTimer takes real timeout returns boolean
        local integer n = R2I(timeout/1)
        if (timeout - n) != 0.00 then
            //debug call BJDebugMsg("Is not a periodic timer")
            return false
        endif
        return true
    endmethod
    
    private static method onPtExpired takes nothing returns nothing
        set ptTickCount = ptTickCount + 1
        
        debug call BJDebugMsg("Periodic timer timeout")
        if IsIntDividableBy(ptTickCount, 12) then
            call TriggerEvaluate(thistype.pt60s.trigger)
        endif
        if IsIntDividableBy(ptTickCount, 6) then
            call TriggerEvaluate(thistype.pt30s.trigger)
        endif
        if IsIntDividableBy(ptTickCount, 3) then
            call TriggerEvaluate(thistype.pt15s.trigger)
        endif
        if IsIntDividableBy(ptTickCount, 2) then
            call TriggerEvaluate(thistype.pt10s.trigger)
        endif
        /*
        if tp == pt1s then
            debug call BJDebugMsg("Periodic timer(1s) timeout")
        elseif tp == pt10s then
            debug call BJDebugMsg("Periodic timer(10s) timeout")
        elseif tp == pt15s then
            debug call BJDebugMsg("Periodic timer(15s) timeout")
        elseif tp == pt30s then
            debug call BJDebugMsg("Periodic timer(30s) timeout")
        elseif tp == pt60s then
            debug call BJDebugMsg("Periodic timer(60s) timeout")
        endif
        */
    endmethod
    
    private static method onOtExpired takes nothing returns nothing
        local TimerPointer tp = TimerPool[GetExpiredTimer()]
        
        debug call BJDebugMsg("Periodic timer timeout")
        call TriggerEvaluate(tp.trigger)
        
        // If timer is not periodic timer, recycle it
        if not isPeriodicTimer(tp.timeout) then
            call tp.destroy()
        endif
    endmethod
    
    // It's used by other module to register actions at timer expired
    static method register takes real timeout, boolexpr action returns triggercondition
        return thistype.getTimer(timeout).register(action)
    endmethod
    
    static method start takes nothing returns nothing
        // PT - we select 5s as base timer
        call TimerStart(thistype.pt5s.timer, thistype.pt5s.timeout, true, function thistype.onPtExpired)
        //call TimerStart(thistype.pt10s.timer, thistype.pt10s.timeout, true, function thistype.onExpire)
        //call TimerStart(thistype.pt15s.timer, thistype.pt15s.timeout, true, function thistype.onExpire)
        //call TimerStart(thistype.pt30s.timer, thistype.pt30s.timeout, true, function thistype.onExpire)
        //call TimerStart(thistype.pt60s.timer, thistype.pt60s.timeout, true, function thistype.onExpire)
        // OT
        call TimerStart(thistype.otGameStart.timer, 0, false, function thistype.onOtExpired)
        call TimerStart(thistype.otSelectHero.timer, thistype.otSelectHero.timeout, false, function thistype.onOtExpired)
        call TimerStart(thistype.otDetectionOn.timer, thistype.otDetectionOn.timeout, false, function thistype.onOtExpired)
        // Detection off time depends on play time
        set thistype.otDetectionOff.timeout = thistype.otPlayTimeOver.timeout - thistype.otDetectionOn.timeout + 0.01
        call TimerStart(thistype.otDetectionOff.timer, thistype.otDetectionOff.timeout, false, function thistype.onOtExpired)
        call TimerStart(thistype.otPlayTimeOver.timer, thistype.otPlayTimeOver.timeout, false, function thistype.onOtExpired)
        /*
        debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otSelectHero.timeout)+ ") start")
        debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otDetectionOn.timeout)+ ") start")
        debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otDetectionOff.timeout)+ ") start")
        debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otPlayTimeOver.timeout)+ ") start")
        */
    endmethod
    
    private static method onInit takes nothing returns nothing
        // set VAR_INT_PlayTimeDelta to 1 seconds in debug mode to fast debugging
        // debug set VAR_INT_PlayTimeDelta = 1
        set ptTickCount = 0
        set otTickCount = 0
        
        // PT
        set pt5s = TimerPointer.create()
        set pt10s = TimerPointer.create()
        set pt15s = TimerPointer.create()
        set pt30s = TimerPointer.create()
        set pt60s = TimerPointer.create()
        // !Don't forget to set timeout for these timers
        set pt5s.timeout = CST_PT_5s
        set pt10s.timeout = CST_PT_10s
        set pt15s.timeout = CST_PT_15s
        set pt30s.timeout = CST_PT_30s
        set pt60s.timeout = CST_PT_60s
        
        // OT
        set otGameStart = TimerPointer.create()
        set otSelectHero = TimerPointer.create()
        set otDetectionOn = TimerPointer.create()
        set otDetectionOff = TimerPointer.create()
        set otPlayTimeOver = TimerPointer.create()
        // !Don't forget to set timeout for these timers
        set otSelectHero.timeout = CST_OT_SelectHero
        set otDetectionOn.timeout = thistype.formatOtTimeout(CST_OT_Detect*VAR_INT_PlayTimeDelta)
        set otPlayTimeOver.timeout = thistype.formatOtTimeout(CST_OT_PlayTime*VAR_INT_PlayTimeDelta)
    endmethod
    
endstruct

function CreateUnitsForPlayer0 takes nothing returns nothing
    local player p= Player(0)
    local unit u
    local integer unitID
    local trigger t
    local real life
    set u=CreateUnit(p, 'necr', - 7490.1, - 3191.5, 153.080)
    set t=CreateTrigger()
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_DEATH)
    call TriggerRegisterUnitEvent(t, u, EVENT_UNIT_CHANGE_OWNER)
    call TriggerAddAction(t, function ItemTable000000_DropItems)
endfunction

function Trig_StackingConditions takes nothing returns boolean
    return ((GetItemCharges(GetManipulatedItem()) > 0))
endfunction

function Trig_StackingActions takes nothing returns nothing
    set bj_forLoopAIndex = 1
    set bj_forLoopAIndexEnd = 6
    loop
        exitwhen bj_forLoopAIndex > bj_forLoopAIndexEnd
        if ((GetItemTypeId(GetManipulatedItem()) == GetItemTypeId(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA()))) and (GetManipulatedItem() != UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA()))) then
            call SetItemCharges( UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA()), ( GetItemCharges(UnitItemInSlotBJ(GetManipulatingUnit(), GetForLoopIndexA())) + GetItemCharges(GetManipulatedItem()) ) )
            call RemoveItem( GetManipulatedItem() )
        else
        endif
        set bj_forLoopAIndex = bj_forLoopAIndex + 1
    endloop
endfunction

//===========================================================================
function InitTrig_Stacking takes nothing returns nothing
    set gg_trg_Stacking = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Stacking, EVENT_PLAYER_UNIT_PICKUP_ITEM )
    call TriggerAddCondition(gg_trg_Stacking, Condition(function Trig_StackingConditions))
    call TriggerAddAction(gg_trg_Stacking, function Trig_StackingActions)
endfunction


// units\orc\WolfRider\WolfRider.mdl

