library UnitManager initializer init/* v0.0.1 Xandria
*/  uses    TimeManager     /*
********************************************************************************
*     HVF Unit management : For use of managing HuntersVsFarmers Neutral units
********************************************************************************
CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
GetOwningPlayer
*******************************************************************************/
    struct UnitManager extends array
        // Create neutral aggresive units randomly every 30s
        private static method createRandomNeutralAggrUnits takes nothing returns boolean
            local integer i = 0
            local unit u
            
            debug call BJDebugMsg("Create random units")
            
            if GetPlayerState(Player(PLAYER_NEUTRAL_AGGRESSIVE), PLAYER_STATE_RESOURCE_FOOD_USED) <= 100 then
                debug call BJDebugMsg("Create random units")
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Rabbit, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_RabbitMeat, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Deer, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_Venision, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Dog, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_DogMeat, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Vulture, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_VultureMeat, GetUnitX(u), GetUnitY(u)))
            endif
            
            set u = null
            return false
        endmethod
        
        // Create neutral aggresive units at beginning
        // This function can't be condition or filter
        static method createBeginNeutralAggrUnits takes nothing returns boolean
            local integer i = 0
            local unit u
            
            loop
                exitwhen i >= 10
                /*
                call BJDebugMsg("X:" + R2S(GetLocationX(rndLoc))+ ", Y:"+ R2S(GetLocationY(rndLoc)) )
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Rabbit, GetLocationX(rndLoc), GetLocationY(rndLoc), bj_UNIT_FACING)
                call UnitAddItem(u, CreateItem(CST_ITI_RabbitMeat, GetUnitX(u), GetUnitY(u)))
                call RemoveLocation(rndLoc)
                //call TriggerSleepAction(0.01)
                set rndLoc = GetRandomLocInRect(playableRect)
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Deer, GetLocationX(rndLoc), GetLocationY(rndLoc), bj_UNIT_FACING)
                call UnitAddItem(u, CreateItem(CST_ITI_Venision, GetUnitX(u), GetUnitY(u)))
                call RemoveLocation(rndLoc)
                //call TriggerSleepAction(0.01)
                set rndLoc = GetRandomLocInRect(playableRect)
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Dog, GetLocationX(rndLoc), GetLocationY(rndLoc), bj_UNIT_FACING)
                call UnitAddItem(u, CreateItem(CST_ITI_DogMeat, GetUnitX(u), GetUnitY(u)))
                call RemoveLocation(rndLoc)
                //call TriggerSleepAction(0.01)
                set rndLoc = GetRandomLocInRect(playableRect)
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Vulture, GetLocationX(rndLoc), GetLocationY(rndLoc), bj_UNIT_FACING)
                call UnitAddItem(u, CreateItem(CST_ITI_VultureMeat, GetUnitX(u), GetUnitY(u)))
                call RemoveLocation(rndLoc)
                //call TriggerSleepAction(0.01)
                set rndLoc = GetRandomLocInRect(playableRect)
                */
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Rabbit, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_RabbitMeat, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Deer, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_Venision, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Dog, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_DogMeat, GetUnitX(u), GetUnitY(u)))
                
                set u = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), CST_UTI_Vulture, Map.randomX, Map.randomY, CST_Facing_Unit)
                call UnitAddItem(u, CreateItem(CST_ITI_VultureMeat, GetUnitX(u), GetUnitY(u)))
                
                set i = i + 1
            endloop
            set u = null
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            // call TimerManager.otGameStart.register(Filter(function thistype.createBeiginNeutralAggrUnits))
            call TimerManager.pt30s.register(Filter(function thistype.createRandomNeutralAggrUnits))
        endmethod
    endstruct
             
    
    /***************************************************************************
    * Library Initiation
    ***************************************************************************/
    private function init takes nothing returns nothing
    endfunction
endlibrary
