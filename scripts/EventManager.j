library EventManager initializer init/* v0.0.1 Xandria
*/  uses    SimpleTrigger   /*  
*/          HVF             /*
********************************************************************************
* HVF event manager
*******************************************************************************/

struct EventManager
    static trigger trigSelectHero  
    
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
    * Do clean-up work for leaving player
    ***************************************************************************/
    private static method onPlayerLeave takes nothing returns boolean
        local player pLeave = GetTriggerPlayer()
        local boolean bIsHunter = Hunter.contain(pLeave)
        
        // remove player from group
        if bIsHunter then
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunter")
            call Hunter.remove(pLeave)
        else
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmer")
            call Farmer.remove(pLeave)
        endif
        
        // remove unit of this player
        // or share control/vision of leaving player with other playing players?
        
        set pLeave = null
        return false
    endmethod
        
    // Start listen on events
    static method listen takes nothing returns nothing
        // Register a leave action callback of player leave event
        call Players.LEAVE.register(Filter(function thistype.onPlayerLeave))
        
        // Hero Tavern belongs to 'Neutral Passive Player'
        call TriggerRegisterPlayerUnitEvent(trigSelectHero, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, null)
    endmethod
    
    private static method onInit takes nothing returns nothing
        set thistype.trigSelectHero = CreateTrigger()
        
        call TriggerAddCondition( trigSelectHero,Condition(function thistype.onSelectHero) )
    endmethod
    
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing
    // Register a leave action callback of player leave event
    call EventManager.listen()
endfunction


endlibrary