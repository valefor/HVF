library EventManager initializer init/* v0.0.1 Xandria
*/  uses    SimpleTrigger   /*  
*/          HVF             /*
********************************************************************************
* HVF event manager
********************************************************************************
* call KillUnit()/RemoveUnit() will trigger events

*******************************************************************************/

struct EventManager
    static trigger trigSelectHero
    static trigger trigFarmerUnitDeath
    static trigger trigFarmerFarmingBuildingFinish
    static trigger trigFarmerFarmingBuildingUpgrade
    static trigger trigFarmerSpellCast
    static trigger trigFarmerUnitIssuedOrder
    
    /***************************************************************************
    * Bind selected Hunter Hero to Player
    ***************************************************************************/
    private static method onSelectHero takes nothing returns boolean    
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetSoldUnit()))+ ":Selecte a Hero") 
        if Hunter.contain(GetOwningPlayer(GetSoldUnit())) then
            call Hunter[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
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
    
    /***************************************************************************
    * When player unit die, update counters
    ***************************************************************************/
    // Event Filter
    // Event Listener
    private static method onFarmerUnitDeath takes nothing returns boolean    
        local unit dyingUnit = GetDyingUnit()
        local unit killingUnit = GetDyingUnit()
        local integer dyingUnitTypeId = GetUnitTypeId(dyingUnit)
        local integer killingUnitTypeId = GetUnitTypeId(killingUnit)
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(dyingUnit))]
        local Hunter h = Hunter[GetPlayerId(GetOwningPlayer(killingUnit))]
        
        debug call BJDebugMsg(GetUnitName(GetTriggerUnit()) + " die") 
        // If farmer Hero die
        if dyingUnitTypeId == CST_UTI_FarmerHero then
            if Hunter.contain(GetOwningPlayer(killingUnit)) then
                set f.deaths=f.deaths + 1
                set h.kills=h.kills + 1
                // Give Hunter reward for killing
                // Revive Farmer Hero at random location
            else // Farmer hero was killed by ally or neutral 
            endif
        endif
        
        // If farmer farming animal die
        call f.removeFarmingAminal(dyingUnit)
        
        // If farmer farming building is destroyed/canceled
        call f.removeFarmingBuilding(dyingUnit, false)
        
        
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
    // Event Listener
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
    // Event Listener
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
    // Event Listener
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
    // Event Listener
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
    private static method onPlayerLeave takes nothing returns boolean
        local player pLeave = GetTriggerPlayer()
        local boolean bIsHunter = Hunter.contain(pLeave)
        
        // remove player from group
        if bIsHunter then
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunter")
            call Hunter.removeLeaving(pLeave)
        else
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmer")
            call Farmer.removeLeaving(pLeave)
        endif
        
        // remove unit of this player
        // or share control/vision of leaving player with other playing players?
        
        if Hunter.count == 0 then
            call Farmer.win()
        endif
        
        if Farmer.count == 0 then
            call Hunter.win()
        endif
        
        set pLeave = null
        return false
    endmethod
        
    // Start listen on events
    static method listen takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]
        local Hunter h = Hunter[Hunter.first]
        local region r=CreateRegion()
        
        call RegionAddRect(r,GetWorldBounds())
        
        debug call BJDebugMsg("Event manager: start to listen")
        // Register a leave action callback of player leave event
        call Players.LEAVE.register(Filter(function thistype.onPlayerLeave))
        
        call TriggerRegisterEnterRegion(CreateTrigger(),r,Filter(function thistype.filterUnitEnterMap))
        set r=null
        
        // Hero Tavern belongs to 'Neutral Passive Player'
        call TriggerRegisterPlayerUnitEvent(trigSelectHero, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, null)
        
        loop
            exitwhen f.end
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
        set thistype.trigSelectHero = CreateTrigger()
        set thistype.trigFarmerUnitDeath = CreateTrigger()
        set thistype.trigFarmerFarmingBuildingFinish = CreateTrigger()
        set thistype.trigFarmerFarmingBuildingUpgrade = CreateTrigger()
        set thistype.trigFarmerSpellCast = CreateTrigger()
        set thistype.trigFarmerUnitIssuedOrder = CreateTrigger()
        
        
        // Set up triggers handle function
        call TriggerAddCondition( trigSelectHero,Condition(function thistype.onSelectHero) )
        call TriggerAddCondition( trigFarmerUnitDeath,Condition(function thistype.onFarmerUnitDeath) )
        call TriggerAddCondition( trigFarmerFarmingBuildingFinish,Condition(function thistype.onFarmerFarmingBuildingFinish) )
        call TriggerAddCondition( trigFarmerFarmingBuildingUpgrade,Condition(function thistype.onFarmerFarmingBuildingUpgrade) )
        call TriggerAddCondition( trigFarmerSpellCast,Condition(function thistype.onFarmerSpellCast) )
        call TriggerAddCondition( trigFarmerUnitIssuedOrder,Condition(function thistype.onFarmerUnitIssuedOrder) )
    endmethod
    
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing
    call EventManager.listen()
endfunction


endlibrary