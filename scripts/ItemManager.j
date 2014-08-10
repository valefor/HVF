library ItemManager initializer init/* v0.0.1 Xandria
*/  uses    TimeManager     /*  
*/                       /*
********************************************************************************
* HVF item manager
*******************************************************************************/

struct ItemManager extends array

    /***************************************************************************
    * Enumerators
    ***************************************************************************/
    private static method enumCreateRandomItem takes nothing returns nothing
        if ( (GetDestructableTypeId(GetEnumDestructable()) == CST_DTI_MagicTree) and (GetDestructableLife(GetEnumDestructable()) > 0) ) then
            call CreateItem(ChooseRandomItemEx(ITEM_TYPE_ANY, 8), GetDestructableX(GetEnumDestructable()), GetDestructableY(GetEnumDestructable()))
        endif
    endmethod
    
    static method createBeginMapItems takes nothing returns boolean
        local real x
        local real y
        local integer numberOfItem = 0
        local integer maxItems = CST_INT_MaxItemCount * (Map.mapSize + 1)
        //local destructable mt
        debug call BJDebugMsg("Create begin items")
        
        // Create a magic three in secret garden
        //set mt = CreateDeadDestructable(CST_DTI_MagicTree, GetRectMinX(Map.regionSecretGarden), GetRectMaxY(Map.regionSecretGarden), 39.000, 1.063, 0)
        //call SetDestructableLife(mt, GetDestructableMaxLife(mt))
        //set mt = null
        
        loop
            set x = Map.randomX
            set y = Map.randomY
            call CreateItem(CST_ITI_MagicSeed, x, y)
            call CreateItem(CST_ITI_MythticGrass, x, y)
            call CreateItem(CST_ITI_MythticFlower, x, y)
            set numberOfItem = numberOfItem + 1
            exitwhen numberOfItem > maxItems
        endloop

        return false
    endmethod
    
    // Create a random item in whole map for every 10 secs
    private static method createMapRandomItem takes nothing returns boolean
        local real x = Map.randomX
        local real y = Map.randomY
        
        // GetRandomReal(GetRectMinX(playableRect), GetRectMaxX(playableRect))
        call CreateItem(ChooseRandomItemEx(ITEM_TYPE_ANY, 8), x, y)
        
        return false
    endmethod

    // Create a random item at secret garden and magic tree for every 30 secs
    private static method createRandomItemAtSgAndMagicTree takes nothing returns boolean
        local location loc = GetRandomLocInRect(Map.regionSecretGarden)
        
        // Create a random item in secret garden
        call CreateItem(ChooseRandomItemEx(ITEM_TYPE_ANY, 8), GetLocationX(loc), GetLocationY(loc))
        
        // Create a random item under magic tree
        call EnumDestructablesInRect(Map.regionWaterLand1, null, function thistype.enumCreateRandomItem)
        call EnumDestructablesInRect(Map.regionWaterLand2, null, function thistype.enumCreateRandomItem)
        call EnumDestructablesInRect(Map.regionWaterLand3, null, function thistype.enumCreateRandomItem)
        call EnumDestructablesInRect(Map.regionSecretGarden, null, function thistype.enumCreateRandomItem)
        
        call RemoveLocation(loc)
        set loc = null
        return false
    endmethod
                  
    private static method onInit takes nothing returns nothing
        // call TimerManager.otGameStart.register(Filter(function thistype.createBeginMapItems))
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