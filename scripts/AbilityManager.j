library AbilityManager initializer init /* v0.0.1 by Xandria
*/  uses    Core           /*
********************************************************************************
*   Ability Manager: Manage abilities of Roles in HVF
*******************************************************************************/
globals
    constant integer AM_ABI_MAX  = 6 // 5 abilities and 1 empty slot
    constant integer AM_PAGE_MAX = 3
endglobals

//! textmacro MAP_ITI_TO_ABI takes NAME
    set thistype.itemAbilityMap[CST_ITI_Book$NAME$] = CST_ABI_Learn$NAME$
//! endtextmacro
    
type AbilityList extends integer array[AM_ABI_MAX]
type AbilityShop extends unit array[AM_PAGE_MAX]

struct AbilitySelector extends array
    
    private static integer ic = 1 // instance count
    private static Table itemAbilityMap
    
    private integer page
    private real x
    private real y
    
    // To support multi-page shop, should use array unit here
    // unit array shop
    AbilityShop shop
    AbilityList abiList
    
    integer abiCount
    
    // Add learnable ability
    public method addLnbAbility takes integer abi returns nothing
        set .abiCount = .abiCount + 1
        set .abiList[.abiCount] = abi
        
        if .abiCount == 5 then
            call this.done()
        endif
    endmethod
    
    public method grantAbility takes unit hero returns nothing
        local integer slot = 0
        local integer i = 1
        local integer abi
        
        // If hero template is TP1/TP2 which means the first slot should be ScoutEye
        if GetUnitTypeId(hero) == CST_UTI_HunterHeroFreeTP1 or GetUnitTypeId(hero) == CST_UTI_HunterHeroFreeTP2 then
            set slot = 1
        endif
        
        loop
            exitwhen i > abiCount
            debug call BJDebugMsg("grantAbility >>>> i:"+ I2S(i))
     
            if abiList[i] != CST_ABI_LearnScoutEye and abiList[i] != CST_ABI_LearnZergling then
                set abi = abiList[i] + slot
                set slot = slot + 1
                debug call BJDebugMsg("grantAbility >>>> slot:"+ I2S(slot))
            else
                set abi = abiList[i]
            endif
            call AbilityManager.learn(hero, abi)
            set i = i + 1
        endloop
    endmethod
    
    public method load takes nothing returns nothing
        if .shop == null then
            return
        endif
        
        call AddItemToStock(.shop[0], CST_ITI_BookScoutEye, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookEnhanceArmor, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookEvasion, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookEnsnare, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookFarSight, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookTeleportation, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookLandMine, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookMindBomb, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BookInvisibility, 1, 1)
        call AddItemToStock(.shop[0], CST_ITI_BtnNext, 1, 1)
        call AddItemToStock(.shop[1], CST_ITI_BookZergling, 1, 1)
        call AddItemToStock(.shop[1], CST_ITI_BtnPrev, 1, 1)
        call AddItemToStock(.shop[AM_PAGE_MAX - 1], CST_ITI_BtnReset, 1, 1)
        call AddItemToStock(.shop[AM_PAGE_MAX - 1], CST_ITI_BtnOk, 1, 1)
    endmethod
    
    public method clear takes nothing returns nothing
        if .shop == null then
            return
        endif
        
        call RemoveItemFromStock(.shop[0], CST_ITI_BookScoutEye)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookEnhanceArmor)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookEvasion)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookEnsnare)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookFarSight)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookTeleportation)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookLandMine)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookMindBomb)
        call RemoveItemFromStock(.shop[0], CST_ITI_BookInvisibility)
        call RemoveItemFromStock(.shop[0], CST_ITI_BtnNext)
        call RemoveItemFromStock(.shop[1], CST_ITI_BookZergling)
        call RemoveItemFromStock(.shop[1], CST_ITI_BtnPrev)
        call RemoveItemFromStock(.shop[AM_PAGE_MAX - 1], CST_ITI_BtnReset)
        call RemoveItemFromStock(.shop[AM_PAGE_MAX - 1], CST_ITI_BtnOk)
    endmethod
    
    public method refresh takes nothing returns nothing
        set .abiCount = 0
        call this.clear()
        call this.load()
    endmethod
    
    public method set takes integer pageIndex returns nothing
        // Impossible?
        if (pageIndex < 0 and pageIndex > AM_PAGE_MAX - 1) then
            return
        endif
        
        if (pageIndex != .page) then
            call SetUnitX(.shop[.page], CST_LOCATION_INVX)
            call SetUnitY(.shop[.page], CST_LOCATION_INVY)
            set .page = pageIndex
        endif
        call SetUnitX(.shop[.page], .x)
        call SetUnitY(.shop[.page], .y)
        call ClearSelection()
        call SelectUnit(.shop[.page], true)
    endmethod
    
    public method reset takes nothing returns nothing
        set .abiCount = 0
        call this.refresh()
        // Show first page
        call this.set(0)
    endmethod
    
    public method done takes nothing returns nothing
        set .abiCount = 0
        // Done here, show confirmation
        call this.set(AM_PAGE_MAX - 1)
    endmethod
    
    public method next takes nothing returns nothing
        call this.set(.page + 1)
    endmethod
    
    public method prev takes nothing returns nothing
        call this.set(.page - 1)
    endmethod
    
    public method dispatch takes integer iti returns nothing
        if (iti == CST_ITI_BtnReset) then
            call this.reset()
        elseif (iti == CST_ITI_BtnNext) then
            call this.next()
        elseif (iti == CST_ITI_BtnPrev) then
            call this.prev()
        else
            call this.addLnbAbility(thistype.itemAbilityMap[iti])
        endif
    endmethod
    
    // Get correct hero template according to selected abilities
    public method getHunterHeroTemplate takes nothing returns integer
        local integer i = 1
        local integer j = 1
        
        loop
        exitwhen i > abiCount
        if abiList[i] == CST_ABI_LearnScoutEye or abiList[i] == CST_ABI_LearnZergling then
            loop
            exitwhen j > abiCount
            if j!=i and ( abiList[j] == CST_ABI_LearnZergling or abiList[j] == CST_ABI_LearnScoutEye ) then
                return CST_UTI_HunterHeroFreeTP2
            endif
            set j = j + 1
            endloop
            if abiList[i] == CST_ABI_LearnScoutEye then
                return CST_UTI_HunterHeroFreeTP1
            else
                return CST_UTI_HunterHeroFreeTP3
            endif
        endif
        set i = i + 1
        endloop
        return CST_UTI_HunterHeroFreeTP4
    endmethod
    
    static method create takes player p, integer abiShop, real x, real y returns thistype
        local thistype this = ic
        local integer i = 0
        set ic = ic + 1
        
        set .abiList = AbilityList.create()
        //set .shop = abiShop
        set .shop = AbilityShop.create()
        set .abiCount = 0
        set .page = 0
        // Initiate shops
        loop
        exitwhen i >= AM_PAGE_MAX
            set .shop[i] = CreateUnit(p, abiShop, CST_LOCATION_INVX, CST_LOCATION_INVX, CST_Facing_Building)
        set i = i + 1
        endloop
        set .x = x
        set .y = y
        call this.load()
        call this.set(0)

        return this
    endmethod
    
    public method destroy takes nothing returns nothing
        local integer i = 0
        call this.clear()
        // Destory shops
        loop
        exitwhen i >= AM_PAGE_MAX
            call RemoveUnit(.shop[i])
            set .shop[i] = null
        set i = i + 1
        endloop
        // call RemoveUnit(.shop)
        call .abiList.destroy()
        call .shop.destroy()
    endmethod
    
    private static method onInit takes nothing returns nothing
        set thistype.itemAbilityMap = TableArray.create()
        
        //! runtextmacro MAP_ITI_TO_ABI("ScoutEye")
        //! runtextmacro MAP_ITI_TO_ABI("EnhanceArmor")
        //! runtextmacro MAP_ITI_TO_ABI("Evasion")
        //! runtextmacro MAP_ITI_TO_ABI("Ensnare")
        //! runtextmacro MAP_ITI_TO_ABI("FarSight")
        //! runtextmacro MAP_ITI_TO_ABI("Teleportation")
        //! runtextmacro MAP_ITI_TO_ABI("LandMine")
        //! runtextmacro MAP_ITI_TO_ABI("MindBomb")
        //! runtextmacro MAP_ITI_TO_ABI("Invisibility")
        //! runtextmacro MAP_ITI_TO_ABI("Zergling")
    endmethod
    
endstruct

struct AbilityManager

    static trigger trigABHunterHide
    // Add ability to hunter according to hunter role
    static method addHunterAbility takes player p, unit u returns nothing
        
    endmethod
    
    // Add ability to farmer according to hunter role
    static method addFarmerAbility takes nothing returns nothing
    endmethod

    private static method disableFakeAbilities takes nothing returns nothing
        call DisableAbilityForAll(CST_ABI_FakeAbiS1L3)
        call DisableAbilityForAll(CST_ABI_FakeAbiS1L5)
        call DisableAbilityForAll(CST_ABI_FakeAbiS2L3)
        call DisableAbilityForAll(CST_ABI_FakeAbiS3L3)
        call DisableAbilityForAll(CST_ABI_FakeAbiS4L3)
        call DisableAbilityForAll(CST_ABI_FakeAbiS5L3)
        call DisableAbilityForAll(CST_ABI_FakeAbiS5L40)
    endmethod
    
    // 'abi' must be a learnable ability id
    static method learn takes unit hero, integer abi returns nothing
        debug call BJDebugMsg("Learn ability")
        call UnitAddAbility(hero, abi)
        call UnitRemoveAbility(hero, abi)
    endmethod
    
    // NB: the shop must have 'Asid' ability, otherwise we are fucked up
    // by using AddItemToStock, it doesn't work at all
    /*
    static method initAbilityShop takes real x, real y returns nothing
        local unit shop = CreateUnit(Player(15), CST_BTI_HunterAbilityShop, x, y, 270.0)
        
        call MainShops.register(shop, CST_ITI_BookScoutEye)
        call Shops.register(CST_ITI_BookScoutEye)
        //call AddItemToStock(shop, 'I00P', 1, 1)
    endmethod
    */
    
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
