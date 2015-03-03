library AbilityManager initializer init /* v0.0.1 by Xandria
*/  uses    Core           /*
********************************************************************************
*   Ability Manager: Manage abilities of Roles in HVF
*******************************************************************************/

type AbilityList extends integer array[6]

struct AbilitySelector extends array
    
    private static integer ic = 1 // instance count
    
    private integer page 
    
    unit shop
    AbilityList abiList
    integer abiCount
    
    // Add learnable ability
    public method addLnbAbility takes integer abi returns nothing
        set .abiCount = .abiCount + 1
        set .abiList[.abiCount] = abi
        
        if .abiCount == 5 then
            set .page = 2
            call this.clearShop()
            call AddItemToStock(.shop, CST_ITI_BtnReset, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BtnOk, 1, 1)
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
            call AbilityManager.learn(hero,abi)
            set i = i + 1
        endloop
    endmethod
    
    public method initShop takes nothing returns nothing
        if .shop == null then
            return
        endif
        
        if page == 1 then
            call AddItemToStock(.shop, CST_ITI_BookScoutEye, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookEnhanceArmor, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookEvasion, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookEnsnare, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookFarSight, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookTeleportation, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookLandMine, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookMindBomb, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookInvisibility, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BookZergling, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BtnReset, 1, 1)
        else
            call AddItemToStock(.shop, CST_ITI_BtnReset, 1, 1)
            call AddItemToStock(.shop, CST_ITI_BtnOk, 1, 1)
        endif
    endmethod
    
    public method refreshShop takes nothing returns nothing
        set .abiCount = 0
        call this.clearShop()
        call this.initShop()
    endmethod
    
    public method resetShop takes nothing returns nothing
        set .abiCount = 0
        set .page = 1
        call this.clearShop()
        call this.initShop()
    endmethod

    public method clearShop takes nothing returns nothing
        if .shop == null then
            return
        endif
        
        call RemoveItemFromStock(.shop, CST_ITI_BookScoutEye)
        call RemoveItemFromStock(.shop, CST_ITI_BookEnhanceArmor)
        call RemoveItemFromStock(.shop, CST_ITI_BookEvasion)
        call RemoveItemFromStock(.shop, CST_ITI_BookEnsnare)
        call RemoveItemFromStock(.shop, CST_ITI_BookFarSight)
        call RemoveItemFromStock(.shop, CST_ITI_BookTeleportation)
        call RemoveItemFromStock(.shop, CST_ITI_BookLandMine)
        call RemoveItemFromStock(.shop, CST_ITI_BookMindBomb)
        call RemoveItemFromStock(.shop, CST_ITI_BookInvisibility)
        call RemoveItemFromStock(.shop, CST_ITI_BookZergling)
        call RemoveItemFromStock(.shop, CST_ITI_BtnReset)
        call RemoveItemFromStock(.shop, CST_ITI_BtnOk)
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
    
    static method create takes unit abiShop returns thistype
        local thistype this = ic
        set ic = ic + 1
        
        set .abiList = AbilityList.create() 
        set .shop = abiShop
        set .abiCount = 0
        set .page = 1
        call this.initShop()
        
        return this
    endmethod
    
    public method destroy takes nothing returns nothing
        call this.clearShop()
        call RemoveUnit(.shop)
        call abiList.destroy()
        set .shop = null
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
