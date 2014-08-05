library EventManager initializer init/* v0.0.1 Xandria
*/  uses    SimpleTrigger   /*  
*/          HVF             /*
*/          EasyItemStacknSplit /*
********************************************************************************
* HVF event manager
********************************************************************************
* call KillUnit()/RemoveUnit() will trigger events

*******************************************************************************/

struct EventManager
    static trigger trigSelectHero
    static trigger trigPlantTree 
    static trigger trigFinishBuild
    static trigger trigHunterUnitDeath
    static trigger trigSellItem
    static trigger trigPickupItem
    static trigger trigFarmerUnitDeath
    static trigger trigFarmerFarmingBuildingFinish
    static trigger trigFarmerFarmingBuildingUpgrade
    static trigger trigFarmerSpellCast
    static trigger trigFarmerUnitIssuedOrder
    
    static TimerPointer tpReviveHunterHero
    static TimerPointer tpReviveFarmerHero
    
    /***************************************************************************
    * Bind selected Hunter Hero to Player
    ***************************************************************************/
    private static method onSelectHero takes nothing returns boolean    
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetSoldUnit()))+ ":Selecte a Hero") 
        if Hunter.contain(GetOwningPlayer(GetSoldUnit())) then
            call Hunter[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
        else
            call Farmer[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
        endif
        
        // Every Hunter players has selected a hero
        /*
        if Hunter.heroSelectedCount == Hunter.count then
            debug call BJDebugMsg("Every Hunter players has selected a hero")
            // destroy this trigger which has no actions, no memory leak
            call DestroyTrigger(GetTriggeringTrigger())
            set trigSelectHero = null
        endif
        */
        
        return false
    endmethod
    
    /***************************************************************************
    * Item sold,update counter
    ***************************************************************************/
    private static method onSellItem takes nothing returns boolean
        local item i = GetSoldItem()
        local unit u = GetBuyingUnit()
        local Farmer f
        
        // If farmer steal wood from shop in hunter base
        if GetItemTypeId(i) == CST_ITI_HunterWood and Farmer.contain(GetOwningPlayer(u)) then
            set f = Farmer[GetPlayerId(GetOwningPlayer(u))]
            set f.woodCount = f.woodCount + 1
        endif
        
        return false
    endmethod
    
    /***************************************************************************
    * When unit enter map, update counters
    ***************************************************************************/
    private static method filterUnitEnterMap takes nothing returns boolean
        local unit enteringUnit = GetFilterUnit()
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(enteringUnit))]
        
        debug call BJDebugMsg(GetUnitName(enteringUnit) + " enter map") 
        if Farmer.contain(GetOwningPlayer(enteringUnit)) then
            call f.addFarmingBuilding(enteringUnit,false)
            call f.addFarmingAminal(enteringUnit)
        endif
        
        
        set enteringUnit = null
        return false
    endmethod
    
    // Event Filter
    private static method filterPlantTree takes nothing returns boolean
        return true
        //return GetUnitTypeId(GetFilterUnit()) == CST_BTI_SmallTree or GetUnitTypeId(GetFilterUnit()) == CST_BTI_MagicTree
    endmethod
    // Event Handler
    private static method onPlantTree takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local Farmer f 
        local Hunter h
        
        debug call BJDebugMsg("Start to build " + GetUnitName(GetTriggerUnit()))
        if GetUnitTypeId(GetTriggerUnit()) == CST_BTI_SmallTree then
            call RemoveUnit(GetTriggerUnit())
            call CreateDestructable(CST_DTI_SummerTree, GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()), GetRandomDirectionDeg(), 1, 0)
            if Farmer.contain(GetOwningPlayer(u)) then
                set f = Farmer[GetPlayerId(GetOwningPlayer(u))]
                set f.treeCount = f.treeCount + 1
            endif
        elseif GetUnitTypeId(GetTriggerUnit()) == CST_BTI_MagicTree then
            call RemoveUnit(GetTriggerUnit())
            call CreateDestructable(CST_DTI_MagicTree, GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()), GetRandomDirectionDeg(), 1, 0)
        /* For debug use
        elseif GetUnitTypeId(GetTriggerUnit()) == 'hwtw' then
            debug call BJDebugMsg("Start to build " + GetUnitName(GetTriggerUnit()))
            call RemoveUnit(GetTriggerUnit())
            call CreateDestructable(CST_DTI_SummerTree, GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()), GetRandomDirectionDeg(), 1, 0)
        */
        endif
        set u = null
        return false
    endmethod
    
    /***************************************************************************
    * When build is finished, update counter
    ***************************************************************************/
    // Event Filter
    private static method onFinishBuild takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local Farmer f 
        local Hunter h
        if Farmer.contain(GetOwningPlayer(u)) then
            set f = Farmer[GetPlayerId(GetOwningPlayer(u))]
            if GetUnitTypeId(u) == CST_BTI_TowerBase then
                set f.towerCount = f.towerCount + 1
            endif
        endif
        set u = null
        return false
    endmethod
    
    /***************************************************************************
    * When hunter/farmer pickup item, need to check if the item is tower base
    ***************************************************************************/
    // Event Filter
    private static method filterPickupItem takes nothing returns boolean
        // return IsUnitHunterHero(GetFilterUnit())
        return true
    endmethod
    // Event Handler
    private static method onPickupItem takes nothing returns boolean
        local item manItem = GetManipulatedItem()
        local Hunter h
        
        debug call BJDebugMsg("Call function: onPickupItem")
        
        // Hunter hero can not take tower base
        if Hunter.contain(GetTriggerPlayer()) and manItem !=null then
            if GetItemTypeId(manItem) == CST_ITI_TowerBase then
                set h = Hunter[GetPlayerId(GetTriggerPlayer())]
                //call BJDebugMsg("[1]Item:"+GetItemName(manItem)+", Charges:"+I2S(GetItemCharges(manItem))+", Player:"+GetPlayerName(h.get))
                call RemoveItem(manItem)
                call BJDebugMsg("Current lumber:" + R2S(GetPlayerState(h.get, PLAYER_STATE_LUMBER_GATHERED)))
                call AdjustPlayerStateBJ(10, h.get, PLAYER_STATE_RESOURCE_LUMBER)
                call ShowNoticeToPlayer(h.get, MSG_NoticeHunterCantTakeTowerBase)
                //call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Beaware, ARGB(CST_COLOR_Beaware).str())
                //call SetPlayerState(h.get, PLAYER_STATE_LUMBER_GATHERED, GetPlayerState(h.get, PLAYER_STATE_LUMBER_GATHERED) + 10)
            else
                set manItem = null
                return true
            endif
            set manItem = null
            return false
        endif
        
        set manItem = null
        return true
    endmethod
    
    /***************************************************************************
    * When hunter player unit die
    ***************************************************************************/
    // Event Filter
    private static method filterHunterUnitDeath takes nothing returns boolean
        // return IsUnitHunterHero(GetFilterUnit())
        return true
    endmethod
    private static method reviveHunterHero takes nothing returns nothing
        local Hunter h = thistype.tpReviveHunterHero.count
        
        call h.reviveHero()
    endmethod
    // Event Handler
    private static method actHunterUnitDeath takes nothing returns boolean
        local unit dyingUnit = GetDyingUnit()
        local unit killingUnit = GetKillingUnit()
        local Hunter h = Hunter[GetPlayerId(GetTriggerPlayer())]
        local Farmer f
        
        if IsUnitHunterHero(dyingUnit) or GetUnitTypeId(dyingUnit) == CST_UTI_HunterHeroSkeleton then
            // Hunter hero was killed, give a giant skeleton as hunter hero
            // set thistype.tpReviveHunterHero.count = h
            // In order to display hero death anima, we need to postponed revive
            // call TimerStart(thistype.tpReviveHunterHero.timer, 1.25, false, function thistype.reviveHunterHero)
            
            // Since we are in action, we can use poll wait
            call PolledWait(1.25)
            call h.reviveHero()
        endif
        if Farmer.contain(GetOwningPlayer(killingUnit)) then
            set f = Farmer[GetPlayerId(GetOwningPlayer(killingUnit))]
            set f.killCount = f.killCount + 1
        endif
        set dyingUnit = null
        set killingUnit = null
        return false
    endmethod
    
    /***************************************************************************
    * When farmer player unit die, update counters
    ***************************************************************************/
    // Event Filter
    private static method reviveFarmerHero takes nothing returns nothing
        // Buggy here, GetExpiredTimer() may not be the timer point you want!!
        // local TimerPointer tp = TimerPool[GetExpiredTimer()]
        local Farmer f = thistype.tpReviveFarmerHero.count
        
        call f.reviveHero()
    endmethod
    
    // Event Handler
    private static method actFarmerUnitDeath takes nothing returns boolean    
        local unit dyingUnit = GetDyingUnit()
        local unit killingUnit = GetKillingUnit()
        local integer dyingUnitTypeId = GetUnitTypeId(dyingUnit)
        local integer killingUnitTypeId = GetUnitTypeId(killingUnit)
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(dyingUnit))]
        local Hunter h = Hunter[GetPlayerId(GetOwningPlayer(killingUnit))]

        debug call BJDebugMsg(GetUnitName(GetTriggerUnit()) + " die") 
        // If farmer Hero die
        if dyingUnitTypeId == CST_UTI_FarmerHero then
            call f.killAllUnits()
            if Hunter.contain(GetOwningPlayer(killingUnit)) then
                set f.deaths=f.deaths + 1
                set h.kills=h.kills + 1
                // Give Hunter reward for killing
                // Revive Farmer Hero at random location
                call ShowMsgToAll( ARGB.fromPlayer(h.get).str(GetPlayerName(h.get)) +CST_STR_Killed+ ARGB.fromPlayer(f.get).str(GetPlayerName(f.get)) )
            elseif Farmer.contain(GetOwningPlayer(killingUnit)) then
                // Farmer hero was killed by ally, punish all farmers
                call ShowNoticeToAllPlayer(MSG_NoticeFarmerKilledByAlly)
                set f = Farmer[Farmer.first]
                loop
                    exitwhen f.end
                    if f.get == GetOwningPlayer(killingUnit) then
                        call SetPlayerState(f.get, PLAYER_STATE_RESOURCE_GOLD, R2I(GetPlayerState(f.get, PLAYER_STATE_RESOURCE_GOLD)/2))
                    else
                        call SetPlayerState(f.get, PLAYER_STATE_RESOURCE_GOLD, R2I(GetPlayerState(f.get, PLAYER_STATE_RESOURCE_GOLD)/4*3))
                    endif
                    set f = f.next
                endloop
                set f = Farmer[GetPlayerId(GetOwningPlayer(dyingUnit))]
            else
                //Farmer hero was killed by neutral, impossible
            endif
            // set thistype.tpReviveFarmerHero.count = f
            // In order to display hero death anima, we need to postponed revive
            // call TimerStart(thistype.tpReviveFarmerHero.timer, 1.25, false, function f.reviveHero)
            // Since we are in action, we can use poll wait
            call PolledWait(1.25)
            call f.reviveHero()
        else
            // If farmer farming animal die
            call f.removeFarmingAminal(dyingUnit)
            
            // If farmer farming building is destroyed/canceled
            call f.removeFarmingBuilding(dyingUnit, false)
        endif
        
        set dyingUnit = null
        set killingUnit = null
        return false
    endmethod
    
    /***************************************************************************
    * When farmer building is finished/canceled, update counters
    ***************************************************************************/
    // Event Filter
    private static method filterFarmerFarmingBuildingFinish takes nothing returns boolean
        //return IsUnitFarmerFarmingBuilding(GetFilterUnit())
        return true
    endmethod
    // Event Handler
    private static method onFarmerFarmingBuildingFinish takes nothing returns boolean    
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetTriggerUnit()))+ " build a " + GetUnitName(GetTriggerUnit()))
        return false
    endmethod
    
    /***************************************************************************
    * When farmer building is upgraded, update counters
    ***************************************************************************/
    // Event Filter
    private static method filterFarmerFarmingBuildingUpgrade takes nothing returns boolean
        //return IsUnitFarmerFarmingBuilding(GetFilterUnit())
        return true
    endmethod
    // Event Handler
    private static method onFarmerFarmingBuildingUpgrade takes nothing returns boolean    
        local unit updatedUnit = GetTriggerUnit()
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(updatedUnit))]
        
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetTriggerUnit()))+ " upgrade to " + GetUnitName(GetTriggerUnit())) 
        call f.upgradeFarmingBuilding(updatedUnit)
        
        return false
    endmethod
    
    /***************************************************************************
    * When farmer spell is casted, update counters
    ***************************************************************************/
    // Event Filter
    private static method filterFarmerSpellCast takes nothing returns boolean
        //return IsUnitFarmerFarmingBuilding(GetFilterUnit())
        return true
    endmethod
    // Event Handler
    private static method onFarmerSpellCast takes nothing returns boolean    
        local unit spellCastUnit = GetTriggerUnit() // GetSpellAbilityUnit
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(spellCastUnit))]
        local integer castedSpellId = GetSpellAbilityId()
        
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(spellCastUnit))+ " cast spell: " + GetObjectName(castedSpellId)) 
        
        if castedSpellId == CST_ABI_ButcherOne then
            call f.butcherAnimal(spellCastUnit)
        elseif castedSpellId == CST_ABI_ButcherAll then
            call f.butcherAllAnimal()
        elseif castedSpellId == CST_ABI_AllAnimalSpawnOn then
            call f.allAnimalSpawnOn()
        elseif castedSpellId == CST_ABI_AllAnimalSpawnOff then
            call f.allAnimalSpawnOff()
        elseif castedSpellId == CST_ABI_AnimalAutoLoad then
            call f.animalAutoLoad()
        elseif castedSpellId == CST_ABI_AnimalLoadAll then
            call f.animalLoadAll()
        elseif castedSpellId == CST_ABI_AnimalUnloadAll then
            call f.animalUnloadAll()
        elseif castedSpellId == 'A000' then
            call KillUnit(spellCastUnit)
            call AdjustPlayerStateBJ(15, f.get, PLAYER_STATE_RESOURCE_GOLD)
        elseif castedSpellId == 'A001' then
            call f.butcherAllAnimal()
        endif
        //call f.upgradeFarmingBuilding(spellCastUnit)
        
        return false
    endmethod
    
    /***************************************************************************
    * When farmer unit issues orders, update counters
    ***************************************************************************/
    // Event Filter
    private static method filterFarmerUnitIssuedOrder takes nothing returns boolean
        //return IsUnitFarmerFarmingBuilding(GetFilterUnit())
        return true
    endmethod
    // Event Handler
    private static method onFarmerUnitIssuedOrder takes nothing returns boolean    
        local unit orderedUnit = GetOrderedUnit() // GetSpellAbilityUnit
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(orderedUnit))]
        local integer orderId = GetIssuedOrderId()
        
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(orderedUnit))+ " issued order: " + OrderId2String(orderId)) 
        
        if orderId == ORDERID_bearform then
            call f.transform2Ns(orderedUnit)
        elseif orderId == ORDERID_unbearform then
            call f.transform2As(orderedUnit)
        endif
        
        return false
    endmethod

    /***************************************************************************
    * Do clean-up work for leaving player
    ***************************************************************************/
    public static method markLeavingPlayer takes player pLeave returns boolean
        local boolean bIsHunter = Hunter.contain(pLeave)
        
        // remove player from group
        call ShowMsgToAll(ARGB.fromPlayer(pLeave).str(GetPlayerName(pLeave)) + ARGB(COLOR_ARGB_RED).str(CST_STR_HasLeftGame))
        if bIsHunter then
            call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunter")
            call Hunter.markAsLeave(pLeave)
        else
            call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmer")
            call Farmer.markAsLeave(pLeave)
        endif

        if Hunter.isAllLeave then
            call ShowMsgToAll(ARGB(COLOR_ARGB_GREEN).str(MSG_AllHuntersFleed))
            call FarmerWin()
        endif
        
        if Farmer.isAllLeave then
            call ShowMsgToAll(ARGB(COLOR_ARGB_GREEN).str(MSG_AllFarmersFleed))
            call HunterWin()
        endif
        
        set pLeave = null
        return false
    endmethod
    
    private static method onPlayerLeave takes nothing returns boolean
        call thistype.markLeavingPlayer(GetTriggerPlayer())
        return false
    endmethod
    
    /***************************************************************************
    * No-Infighting mode is on, When unit issues attack order, forbid it
    ***************************************************************************/
    // Event Handler
    private static method onUnitIssuedAttackOrder takes nothing returns boolean
        local integer orderId = GetIssuedOrderId()
        local integer targetUti = GetUnitTypeId(GetOrderTargetUnit())
        
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetOrderedUnit()))+ " issued order: " + OrderId2String(orderId)) 
        if GetIssuedOrderId() == ORDERID_attack and (targetUti == CST_UTI_FarmerHero or IsUnitHunterHero(GetOrderTargetUnit())) then
            debug call BJDebugMsg(GetUnitName(GetOrderedUnit())+" is trying to attack " + GetUnitName(GetOrderTargetUnit()))
            if InSameForce(GetOwningPlayer(GetOrderTargetUnit()), GetOwningPlayer(GetOrderedUnit())) then
                call IssueImmediateOrderById(GetOrderedUnit(), ORDERID_holdposition)
            endif
        endif
        return false
    endmethod
    
    // Forbid infighting
    static method forbidInfighting takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]
        local Hunter h = Hunter[Hunter.first]
        local trigger trigUnitIssuedAttackOrder = CreateTrigger()
        
        call TriggerAddCondition( trigUnitIssuedAttackOrder,Condition(function thistype.onUnitIssuedAttackOrder) )
        
        loop
            exitwhen h.end
            call TriggerRegisterPlayerUnitEvent(trigUnitIssuedAttackOrder, f.get, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
            set h= h.next
        endloop
        
        loop
            exitwhen f.end
            call TriggerRegisterPlayerUnitEvent(trigUnitIssuedAttackOrder, f.get, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, null)
            set f= f.next
        endloop
        
        set trigUnitIssuedAttackOrder = null
    endmethod
    
    
    // Start listen on events
    static method listen takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]
        local Hunter h = Hunter[Hunter.first]
        local trigger cancelTrigger = CreateTrigger()
        local trigger preloadTrigger = CreateTrigger()
        local region r=CreateRegion()
        
        call RegionAddRect(r,GetWorldBounds())
        
        // Integrate item stacking system, register cb
        call EasyItemStacknSplit_RegisterCb(Filter(function thistype.onPickupItem))
        
        debug call BJDebugMsg("Event manager: start to listen")
        // Register a leave action callback of player leave event
        call Players.LEAVE.register(Filter(function thistype.onPlayerLeave))
        
        call TriggerRegisterEnterRegion(CreateTrigger(),r,Filter(function thistype.filterUnitEnterMap))
        set r=null
        
        // Hero Tavern belongs to 'Neutral Passive Player'
        call TriggerRegisterPlayerUnitEvent(trigSelectHero, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, null)
        call TriggerRegisterPlayerUnitEvent(trigSellItem, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL_ITEM, null)
        
        loop
            exitwhen h.end
            call TriggerRegisterPlayerUnitEvent(trigSelectHero, h.get, EVENT_PLAYER_UNIT_SELL, null)
            call TriggerRegisterPlayerUnitEvent(trigHunterUnitDeath, h.get, EVENT_PLAYER_UNIT_DEATH, Filter(function thistype.filterHunterUnitDeath))
            call TriggerRegisterPlayerUnitEvent(trigPlantTree, h.get, EVENT_PLAYER_UNIT_CONSTRUCT_START, Filter(function thistype.filterPlantTree))
            set h= h.next
        endloop
        
        loop
            exitwhen f.end
            call TriggerRegisterPlayerUnitEvent(trigPlantTree, f.get, EVENT_PLAYER_UNIT_CONSTRUCT_START, Filter(function thistype.filterPlantTree))
            call TriggerRegisterPlayerUnitEvent(trigFinishBuild, h.get, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, null)
            call TriggerRegisterPlayerUnitEvent(trigFarmerUnitDeath, f.get, EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerRegisterPlayerUnitEvent(trigFarmerFarmingBuildingFinish, f.get, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, Filter(function thistype.filterFarmerFarmingBuildingFinish))
            call TriggerRegisterPlayerUnitEvent(trigFarmerFarmingBuildingUpgrade, f.get, EVENT_PLAYER_UNIT_UPGRADE_FINISH, Filter(function thistype.filterFarmerFarmingBuildingUpgrade))
            call TriggerRegisterPlayerUnitEvent(trigFarmerSpellCast, f.get, EVENT_PLAYER_UNIT_SPELL_CAST, Filter(function thistype.filterFarmerSpellCast))
            call TriggerRegisterPlayerUnitEvent(trigFarmerUnitIssuedOrder, f.get, EVENT_PLAYER_UNIT_ISSUED_ORDER, Filter(function thistype.filterFarmerUnitIssuedOrder))
            set f= f.next
        endloop
        
    endmethod
    
    private static method onInit takes nothing returns nothing
        // Init triggers
        set thistype.trigSellItem = CreateTrigger()
        set thistype.trigSelectHero = CreateTrigger()
        set thistype.trigPlantTree = CreateTrigger()
        set thistype.trigFinishBuild = CreateTrigger()
        set thistype.trigHunterUnitDeath = CreateTrigger()
        set thistype.trigPickupItem = CreateTrigger()
        set thistype.trigFarmerUnitDeath = CreateTrigger()
        set thistype.trigFarmerFarmingBuildingFinish = CreateTrigger()
        set thistype.trigFarmerFarmingBuildingUpgrade = CreateTrigger()
        set thistype.trigFarmerSpellCast = CreateTrigger()
        set thistype.trigFarmerUnitIssuedOrder = CreateTrigger()
        
        //set thistype.tpReviveHunterHero = TimerPointer.create()
        //set thistype.tpReviveFarmerHero = TimerPointer.create()
        
        // Set up triggers handle function
        call TriggerAddCondition( trigSellItem,Condition(function thistype.onSellItem) )
        call TriggerAddCondition( trigSelectHero,Condition(function thistype.onSelectHero) )
        call TriggerAddCondition( trigPlantTree,Condition(function thistype.onPlantTree) )
        call TriggerAddCondition( trigFinishBuild,Condition(function thistype.onFinishBuild) )
        call TriggerAddCondition( trigPickupItem,Condition(function thistype.onPickupItem) )
        // call TriggerAddCondition( trigHunterUnitDeath,Condition(function thistype.onHunterUnitDeath) )
        // call TriggerAddCondition( trigFarmerUnitDeath,Condition(function thistype.onFarmerUnitDeath) )
        call TriggerAddCondition( trigFarmerFarmingBuildingFinish,Condition(function thistype.onFarmerFarmingBuildingFinish) )
        call TriggerAddCondition( trigFarmerFarmingBuildingUpgrade,Condition(function thistype.onFarmerFarmingBuildingUpgrade) )
        call TriggerAddCondition( trigFarmerSpellCast,Condition(function thistype.onFarmerSpellCast) )
        call TriggerAddCondition( trigFarmerUnitIssuedOrder,Condition(function thistype.onFarmerUnitIssuedOrder) )
        
        // Postponed is really a troublesome issue, must use trigger action
        call TriggerAddAction( trigHunterUnitDeath,function thistype.actHunterUnitDeath )
        call TriggerAddAction( trigFarmerUnitDeath,function thistype.actFarmerUnitDeath )
    endmethod
    
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing
    // call EventManager.listen()
endfunction


endlibrary