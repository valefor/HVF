library ShopSystem requires Table, RegisterPlayerUnitEvent
/*
    Version 1.2 by Adiktuz
    
    Credits to Bribe and Magtheridon96 for Table and RegisterPlayerUnitEvent
    
    A simple shop system which allows you to have multiple shops/shopping category inside a single shop.
    
        If you've read my tutorial about sub-shops maybe you'll be asking what is the difference of this 
    to the system in the tutorial. Well, this one uses only one shop per player. Also with this one, all 
    items sold should be set via the trigger editor. 
    
        You can create an infinite-level shop with this one.
        
        You can only register 11 items per catergory
    
    Requirements:
        JNGP with the latest jass helper
        knowledge on how to call functions
        knowledge on how to obtain rawcodes
        knowledge on copying object data and adjusting them
     
    Make sure that the shops you will register with this system doesn't have any items sold
    on its object data 
     
    How to use:

    
    1) Copy the dummy shop, the dummy select unit ability and the dummy click ability from the object editor into your map.
    2) Make sure that you adjust the settings of the dummy shop in case it cannot recognize the dummy
        select unit ability.
    3) Copy this system and Bribe's Table library into your map.
    4) Adjust some of the globals to fit your new map.
    4) Start registering your main shops and items. See attached example trigger for better understanding.
    
    Creating category items
    
    1) Make a new item based on power ups
    2) Add the Dummy Click ability
    3) Make sure you set gold cost to 0 and set model used to none
    
    Functions to toggle shop/item availability
    
    shopAvailableForPlayer(player p, boolean what)
    shopAvailableForPlayerId(integer id, boolean what)
    
    --> Enables or disables the shop system for the player p, or the player with
        PlayerId of id, depending on the setting of boolean what
    
    itemAvailableForPlayer(integer itemid, player p, boolean what)
    itemAvailableForPlayerId(integer itemid, player p, boolean what)
    
    --> Enables or disables the item with the rawcode itemid for player p or the player with
        PlayerId of id, depending on the setting of boolean what
        
*/
    
    globals
        private Table ShopTable
        private Table WhichShop
        private Table MainShop
        private unit array DummyShop
        private boolean array CanShop
        // The next constant is required in order to avoid conflict when more than one player
        // is buying from the same shop
        private constant integer DUMMY_SHOP_ID = 'n00V' 
        private hashtable ItemHash = InitHashtable()
    endglobals
    
    private module init
        static method onInit takes nothing returns nothing
            local integer i = 0
            set ShopTable = Table.create()
            set WhichShop = Table.create()
            set MainShop = Table.create()
            set thistype.items = Table.create()
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function MainShops.selectShop)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELL_ITEM, function thistype.changeItems)
            loop
                if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                    set DummyShop[i] = CreateUnit(Player(i),DUMMY_SHOP_ID, 0.0, 0.0, 0.0)
                    // I make the player own it because if not and they are not visible to the player
                    // the selection action actually runs before the dummy gets moved so the selection becomes empty
                    set CanShop[i] = true
                endif
                set i = i + 1
                exitwhen i > 11
            endloop
        endmethod
    endmodule
    

    struct Shops extends array
        
        //integer array items [11]
        static Table items
        integer itemnum
        private static integer instanceCount = 0
        private static thistype recycle = 0
        private thistype recycleNext
        
        
        static method clearShop takes integer id returns nothing
            local integer i = 0
            local thistype this = WhichShop[id]
            loop
                call RemoveItemFromStock(DummyShop[id], thistype.items[this*11 + i])
                set i = i + 1
                exitwhen i > this.itemnum
            endloop
        endmethod
        
        static method changeItems takes nothing returns boolean
            local player p = GetOwningPlayer(GetBuyingUnit())
            local integer i = 0
            local thistype this = ShopTable[GetItemTypeId(GetSoldItem())]
            local integer id = GetPlayerId(p)
            if this == 0 then
                set p = null
                return false
            endif
            call thistype.clearShop(id)
            set WhichShop[id] = this
            loop
                if not LoadBoolean(ItemHash, id, thistype.items[this*11 + i]) then
                    call AddItemToStock(DummyShop[id], thistype.items[this*11 + i], 1,1)
                endif
                set i = i + 1
                exitwhen i == this.itemnum
            endloop
            set p = null
            return false
        endmethod
        
        static method forceChangeItems takes integer baseItem, integer id returns boolean
            local integer i = 0
            local thistype this = ShopTable[baseItem]
            call thistype.clearShop(id)
            set WhichShop[id] = this
            loop
                if not LoadBoolean(ItemHash, id, thistype.items[this*11 + i]) then
                    call AddItemToStock(DummyShop[id], thistype.items[this*11 + i], 1,1)
                endif
                set i = i + 1
                exitwhen i == this.itemnum
            endloop
            return false
        endmethod
        
        static method addItemLink takes integer itemBaseId, integer itemAddId returns nothing
            local thistype this = ShopTable[itemBaseId]
            if this.itemnum < 11 then
                set thistype.items[this*11 + this.itemnum] = itemAddId
                set this.itemnum = this.itemnum + 1
            else
                debug BJDebugMsg("Item list already full")
            endif
        endmethod
        
        static method removeItem takes integer baseItemId, integer itemId returns nothing
            local thistype this = ShopTable[baseItemId]
            local integer i = 0
            loop
                if this.items[this*11 + i] == itemId then
                    set this.itemnum = this.itemnum - 1
                    set thistype.items[this*11 + i] = thistype.items[this*11 + this.itemnum]
                    debug BJDebugMsg("REMOVED " + I2S(thistype.items[this*11 + i]))
                    return
                endif
                set i = i + 1
                exitwhen i == this.itemnum
            endloop
        endmethod
        
        static method duplicate takes integer baseItemId, integer itemId returns nothing
            local thistype base = ShopTable[baseItemId]
            local thistype that //= .allocate()
            local integer i = 0
            if (recycle == 0) then
                set instanceCount = instanceCount + 1
                set that = instanceCount
            else
                set that = recycle
                set recycle = recycle.recycleNext
            endif
            set ShopTable[itemId] = that
            set that.itemnum = base.itemnum
            loop
                set thistype.items[that*11 + i] = thistype.items[base*11 + i]
                set i = i + 1
                exitwhen i == base.itemnum
            endloop
        endmethod
        
        static method register takes integer itemId returns nothing
            local thistype this //= .allocate()
            if (recycle == 0) then
                set instanceCount = instanceCount + 1
                set this = instanceCount
            else
                set this = recycle
                set recycle = recycle.recycleNext
            endif
            set ShopTable[itemId] = this
        endmethod
        
        implement init
    endstruct
    
    struct MainShops extends array
        
        private static integer instanceCount = 0
        private static thistype recycle = 0
        private thistype recycleNext
        
        integer baseItem
        
        static method selectShop takes nothing returns boolean
            local unit u = GetTriggerUnit()
            local thistype this = MainShop[GetHandleId(u)]
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            if this == 0 or not CanShop[id] then
                set p = null
                return false
            endif
            // If you click the portait, it will still point your camera towards the main shop
            call SetUnitX(DummyShop[id], GetUnitX(u))
            call SetUnitY(DummyShop[id], GetUnitY(u))
            call Shops.forceChangeItems(this.baseItem, id)
            if GetLocalPlayer() == p then
                call ClearSelection()
                call SelectUnit(DummyShop[id], true)
            endif
            return false
        endmethod
        
        static method register takes unit shop, integer baseItem returns nothing
            local thistype this //= .allocate()
            
            if (recycle == 0) then
                set instanceCount = instanceCount + 1
                set this = instanceCount
            else
                set this = recycle
                set recycle = recycle.recycleNext
            endif
            
            set MainShop[GetHandleId(shop)] = this
            set this.baseItem = baseItem
        endmethod
        
    endstruct
    
    function shopAvailableForPlayer takes player p, boolean what returns nothing
        set CanShop[GetPlayerId(p)] = what
    endfunction
    
    function shopAvailableForPlayerId takes integer id, boolean what returns nothing
        set CanShop[id] = what
    endfunction
    
    function itemAvailableForPlayer takes integer itemid, player p, boolean what returns nothing
        call SaveBoolean(ItemHash, GetPlayerId(p), itemid, not what)
    endfunction
    
    function itemAvailableForPlayerId takes integer itemid, integer id, boolean what returns nothing
        call SaveBoolean(ItemHash, id, itemid, not what)
    endfunction
    
endlibrary
