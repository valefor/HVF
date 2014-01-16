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
