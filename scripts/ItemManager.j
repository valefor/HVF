library ItemManager initializer init/* v0.0.1 Xandria
*/  uses    TimeManager     /*  
*/          HVF             /*
********************************************************************************
* HVF item manager
*******************************************************************************/

struct ItemManager

    /***************************************************************************
    * Enumerators
    ***************************************************************************/
    private static method enumCreateRandomItem takes nothing returns nothing
        call CreateItem(ChooseRandomItemEx(8, ITEM_TYPE_ANY), GetDestructableX(GetEnumDestructable()), GetDestructableY(GetEnumDestructable()))
    endmethod
    
    private static method createBeginMapItems takes nothing returns boolean
        local real x
        local real y
        local integer numberOfItem = 0
        
        loop
            set x = MapLocation.randomX
            set y = MapLocation.randomY
            call CreateItem(CST_ITI_MagicSeed, x, y)
            call CreateItem(CST_ITI_MythticGrass, x, y)
            call CreateItem(CST_ITI_MythticFlower, x, y)
            set numberOfItem = numberOfItem + 1
            exitwhen numberOfItem > CST_INT_MaxItemCount
        endif

        return false
    endmethod
    
    // Create a random item in whole map for every 10 secs
    private static method createMapRandomItem takes nothing returns boolean
        local real x = MapLocation.randomX
        local real y = MapLocation.randomY
        
        // GetRandomReal(GetRectMinX(playableRect), GetRectMaxX(playableRect))
        call CreateItem(ChooseRandomItemEx(8, ITEM_TYPE_ANY), x, y)
        
        return false
    endmethod

    // Create a random item at secret garden and magic tree for every 30 secs
    private static method createRandomItemAtSgAndMagicTree takes nothing returns boolean
        local location loc = GetRandomLocInRect(CST_RGN_SecretGarden)
        
        // Create a random item in secret garden
        call CreateItem(ChooseRandomItemEx(8, ITEM_TYPE_ANY), GetLocationX(loc), GetLocationY(loc))
        
        // Create a random item under magic tree
        call EnumDestructablesInRect(CST_RGN_WaterLand1, null, function enumCreateRandomItem)
        call EnumDestructablesInRect(CST_RGN_WaterLand2, null, function enumCreateRandomItem)
        call EnumDestructablesInRect(CST_RGN_WaterLand3, null, function enumCreateRandomItem)
        call EnumDestructablesInRect(CST_RGN_SecretGarden, null, function enumCreateRandomItem)
        
        call RemoveLocation(loc)
        set loc = null
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