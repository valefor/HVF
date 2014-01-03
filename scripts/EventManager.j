library EventManager initializer init/* v0.0.1 Xandria
*/  uses    SimpleTrigger   /*  
*/          HVF             /*
********************************************************************************
* HVF event manager
*******************************************************************************/

struct EventManager
    static trigger trigSelectHero
    static trigger trigFarmerUnitDeath
    static trigger trigFarmerFarmingBuildingFinish
    
    /***************************************************************************
    * Bind selected Hunter Hero to Player
    ***************************************************************************/
    private static method onSelectHero takes nothing returns boolean    
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetSoldUnit()))+ ":Selecte a Hero") 
        if Hunter.contain(GetOwningPlayer(GetSoldUnit())) then
            call Hunter[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
        endif
        
        // Every Hunter players has selected a hero
        if Hunter.heroSelectedCount == Hunter.count then
            debug call BJDebugMsg("Every Hunter players has selected a hero")
            // destroy this trigger which has no actions, no memory leak
            call DestroyTrigger(GetTriggeringTrigger())
            set trigSelectHero = null
        endif
        
        return false
    endmethod
    
    /***************************************************************************
    * When unit enter map, update counters
    ***************************************************************************/
    private static method filterUnitEnterMap takes nothing returns boolean
        local unit enteringUnit = GetFilterUnit()
        
        call addFarmingBuilding(enteringUnit)
        call addFarmingAminal(enteringUnit)
        
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
        
        // If farmer farming building is destroyed
        call f.removeFarmingBuilding(dyingUnit)
        
        
        set dyingUnit = null
        set killingUnit = null
        
        return false
    endmethod
    
    /***************************************************************************
    * When player building is finished, update counters
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
        
        debug call BJDebugMsg("Event manager: start to listen")
        // Register a leave action callback of player leave event
        call Players.LEAVE.register(Filter(function thistype.onPlayerLeave))
        
        call TriggerRegisterEnterRegion(CreateTrigger(),r,Filter(function filterUnitEnterMap))
        
        // Hero Tavern belongs to 'Neutral Passive Player'
        call TriggerRegisterPlayerUnitEvent(trigSelectHero, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, null)
        
        loop 
            exitwhen f.end
            call TriggerRegisterPlayerUnitEvent(trigFarmerUnitDeath, f.get, EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerRegisterPlayerUnitEvent(trigFarmerFarmingBuildingFinish, f.get, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, Filter(function thistype.filterFarmerFarmingBuildingFinish))
            set f= f.next
        endloop
    endmethod
    
    private static method onInit takes nothing returns nothing
        // Init triggers
        set thistype.trigSelectHero = CreateTrigger()
        set thistype.trigFarmerUnitDeath = CreateTrigger()
        set thistype.trigFarmerFarmingBuildingFinish = CreateTrigger()
        
        // Set up triggers handle function
        call TriggerAddCondition( trigSelectHero,Condition(function thistype.onSelectHero) )
        call TriggerAddCondition( trigFarmerUnitDeath,Condition(function thistype.onFarmerUnitDeath) )
        call TriggerAddCondition( trigFarmerFarmingBuildingFinish,Condition(function thistype.onFarmerFarmingBuildingFinish) )
    endmethod
    
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing
    call EventManager.listen()
endfunction


endlibrary