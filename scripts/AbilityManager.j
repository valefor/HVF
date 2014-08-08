library AbilityManager initializer init /* v0.0.1 by Xandria
*/  uses    HVF           /*
********************************************************************************
*   Ability Manager: Manage abilities of Roles in HVF
*******************************************************************************/


struct AbilityManager

    static trigger trigABHunterHide
    // Add ability to hunter according to hunter role
    static method addHunterAbility takes player p, unit u, returns nothing
        
    endmethod
    
    // Add ability to farmer according to hunter role
    static method addFarmerAbility takes nothing returns nothing
    endmethod
    
    static method disableFakeAbilities takes nothing returns nothing
        call DisableAbilityForAll()
    endmethod
    
    static method init takes nothing returns boolean
        local Hunter h = Hunter[Hunter.first]
        
        loop
            exitwhen h.end
            set h= h.next
        endloop
        
        return false
        
    endmethod
    
    private static method onInit takes nothing returns nothing
        // Init triggers
        set thistype.trigABHunterHide = CreateTrigger()
        
        call thistype.disableFakeAbilities()
        
        // call TimerManager.onGameStart.register(Filter(function thistype.init))
    endmethod
    
endstruct

    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
    endfunction

endlibrary
