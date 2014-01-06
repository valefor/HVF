library ItemManager initializer init/* v0.0.1 Xandria
*/  uses    TimeManager     /*  
*/          HVF             /*
********************************************************************************
* HVF item manager
*******************************************************************************/

struct ItemManager
    private static method createBeginMapItems takes nothing returns boolean
        local rect playableRect = GetPlayableMapRect()
        local integer numberOfItem = 0
        
        loop
            set loc = GetRandomLocInRect(playableRect)
            call CreateItem(CST_ITI_MagicSeed, GetLocationX(loc), GetLocationY(loc))
            call CreateItem(CST_ITI_MythticGrass, GetLocationX(loc), GetLocationY(loc))
            call CreateItem(CST_ITI_MythticFlower, GetLocationX(loc), GetLocationY(loc))
            call RemoveLocation(loc)
            set numberOfItem = numberOfItem + 1
            exitwhen numberOfItem > CST_INT_MaxItemCount
        endif
        
        call RemoveRect(playableRect)
        set loc = null
        set playableRect = null
        return false
    endmethod
    
    // Create a random item in whole map for every 10 secs
    private static method createMapRandomItem takes nothing returns nothing
        return false
    endmethod

    // Create a random item at secret garden and magic tree for every 30 secs
    private static method createRandomItemAtSgAndMagicTree takes nothing returns nothing
        return false
    endmethod
                  
    private static method onInit takes nothing returns nothing
        call TimerManager.otGameStart.register(Filter(function thistype.createBeginMapItems))
        call TimerManager.pt10s.register(Filter(function thistype.createMapRandomItem))
        call TimerManager.pt30s.register(Filter(function thistype.createRandomItemAtSgAndMagicTree))
    endmethod
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing

endfunction

endlibrary