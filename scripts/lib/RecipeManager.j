library RecipeManager initializer init uses Table
    
    //               ¤           v0.7b           ¤
    //              ( *'*-._.-*'*-._.-*'*-._.-*'* )
    //               )         RecipeManager     (
    //              (    Created by Artificial    )
    //               )*'*-._.-*'*-._.-*'*-._.-*'*(
    //              ¤                             ¤
    //
    //                  How to use the RecipeSYS
    //                  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    //  ---- Adding recipes
    //      Adding recipes is rather easy. You just call a function
    //      and give it some arguments. The function you call is
    //      recipe.create, and is called like this:
    //
    //          call recipe.create(i1, i2, i3, i4, i5, i6, result, sfx, attPoint, charges, chargeType)
    //
    //      i1 - i6 are the raw codes* of the items required for the
    //      recipe to combine. result is the raw code of the item they
    //      will combine to. sfx is the path of the special effect you
    //      want to use (give "" for default), and attPoint the attachment
    //      point of it ("" for default). The boolean charges is whether
    //      the result should have some other amount of charges than the
    //      default one. If it is true, chargeType determines what amount
    //      of charges the result will get when combined (-1 => amount of
    //      charges left in the ingredient with most charges, 0 => sum of
    //      charges left in the ingredients, anything else => the number
    //      given as the argument).
    //
    //     * You can find out the rawcodes by going to the object
    //       editor and pressing ctrl + D. The first 4 characters
    //       are the rawcode of the item. When calling the function,
    //       remember to put the rawcode between ' and ' in case
    //       you want it to work.
    //
    //      If you want the recipe to require less than 6 items, just give
    //      zeros as ingredient arguments.
    //
    //          --- AddRecipe Wrappers
    //              You can also add recipes using some of the wrapper
    //              functions: AddRecipe, AddRecipeEx, AddRecipeWithCharges,
    //              and AddRecipeWithChargesEx.
    //              
    //              AddRecipe               takes i1, i2, i3, i4, i5, i6, result
    //              AddRecipeEx             takes i1, i2, i3, i4, i5, i6, result, sfx, attPoint
    //              AddRecipeWithCharges    takes i1, i2, i3, i4, i5, i6, result, chargeType
    //              AddRecipeWithChargesEx  takes i1, i2, i3, i4, i5, i6, result, chargeType, sfx, attPoint
    //
    //  ---- Removing Recipes
    //      There are two ways of removing recipes: destroyin a specific
    //      recipe and removing recipes by the result (removes all recipes
    //      with that item as result).
    //      Removing a specific recipe is done by calling the .destroy method
    //      for that recipe, and removing by result is done by using the
    //      RemoveRecipeByResult function, eg. like this:
    //
    //          call RemoveRecipeByResult('belv')
    //
    //  ---- Changing the Result / Ingredients
    //      Because of how the system works, you can't just do set r.result = 'aooo',
    //      but you must use the methods SetResult and SetIngredient.
    //      SetResult takes only the new item's raw code, and SetIngredient takes that
    //      and the ingredient number (0 - 5).
    //      
    //          call re.SetIngredient('rde1', 0)
    //
    //  ---- Disassembling Items
    //      Disassembling an item that is a result of some recipe would cause
    //      the item to be replaced with the ingredients of the recipe.
    //      Example of usage:
    //
    //          call DisassembleItem(GetManipulatedItem(), GetTriggerUnit())
    //
    //      The first argument is the item to be disassembled and the second
    //      one is the unit to give the ingredients to. In case you don't want
    //      to give the items to an unit, give null as the unit argument.
    //      You also have the DisassembleItemByRecipe function, which takes
    //      one argument more: the recipe whose ingredients you want the item
    //      to be disassembled to.
    //
    //      There are a few restrictions with the disassembling:
    //          - If the item being disassemled isn't created by the system,
    //            and used on an item that is the result of several recipes
    //            the system will just give the items that are required for one
    //            of the recipes.
    //          - When used on an recipe added via the charged recipe thingy
    //            the ingredient items won't recieve the amount of items they
    //            had when the result was made, but the default amount of charges.
    //
    //          Note: If you are using the function with the 'A unit Loses an item'
    //                event you'll need to add a little wait before the function
    //                call in case you want the items to be created at the position
    //                where the item was dropped. And the wait is also needed when
    //                the item being disassembled is the result of a recipe that has
    //                only the same type of items as ingredients (or at least I think so).
    //
    //  ---- Disabling and Re-Enabling Recipes
    //      Instead of removing a recipe to disable it and then adding the
    //      recipe again you can also disable and enable the recipe.
    //      This is done by setting the enabled member of the recipe to false
    //      (or to true if enabling). You can also use the EnableRecipeByResult
    //      function:
    //
    //          call EnableRecipeByResult('fgdg', false)
    //
    //      That would disable the recipes that have the item 'fgdg' as result.
    //      The enabling of the recipe would happen with the same function, but
    //      with true as the boolean argument.
    //
    //  ---- Disabling/Re-enabling the System
    //      If you need to disable/enable the system for some time, you can use these lines:
    //
    //          call DisableTrigger(RecipeSYS_TRIGGER)
    //          call EnableTrigger(RecipeSYS_TRIGGER)
    //
    //      Note, that this only disables the combining of items by the system itself,
    //      if you're using a combining trigger of your own, you'll need to disable that
    //      trigger.
    //
    //  ---- Manual Checking For Recipes
    //      In case you'd want to use some other event than the 'A unit Acquires an
    //      item', you can set AUTO_COMBINE to false, and create a trigger that has
    //      the event you want (eg. 'A unit Starts the effect of an ability'), and
    //      then call the RecipeSYS_Combine function from there. The arguments it takes
    //      are the item that should be checked if it belongs to a recipe and the unit
    //      the result should be created to (if any is created).
    //      The function returns a boolean depending on whether it combined the item
    //      to something or not. And if it combined something, you can refer to the
    //      created item with bj_lastCreatedItem (Last created item in GUI).
    //
    //     Strengths of RecipeSYS
    //     ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    //     - Supports having several items of the same type as
    //       ingredients in the same recipe.
    //     - Supports having the same item type as an ingredient in
    //       several recipes.
    //     - Allows to specify the special effect and it's attachment
    //       point (each recipe can have its own ones, if you wish so).
    //     - All you need to do is add the recipes.
    //     - You can remove recipes.
    //     - You can add recipes with results that have charges.
    //     - The amount of charges can be predefined, the sum of charges
    //       left in the ingredients, or the amount of charges in the
    //       ingredient with most charges.
    //     - You can disable and enable single recipes or the whole sytem.
    //     - You can disassemble items.
    //     - You can disable the automatic combining of items, and create
    //       a trigger that combines items manually (so you can have any
    //       event you want).
    //
    //     Weaknesses of RecipeSYS
    //     ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    //     - Don't know if it's optimized as much as it could nor if it's
    //       the best recipe system out there. ^_^
    //     - The item disassembling has some restrictions, and doesn't work
    //       flawlessy with the 'A unit Loses an item' event (see the Test2
    //       trigger in the demo map or the instructions of the function for
    //       additional information).
    //     - The max amount of item types you can use in recipes as
    //       ingredients is 8190 / AMOUNT_ING and as results 8190 / AMOUNT_RES.
    //
    //                  How to import RecipeSYS
    //                  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    //      Two easy steps:
    //          - Copy this trigger to your map.
    //          - Copy the trigger 'Table' to your map.
    //        Alternatively:
    //          - Create a trigger named 'RecipeSYS' in your map.
    //          - Convert it to Jass (Custom Script) and replace all
    //            of the code in there with the code in this trigger.
    //          - Create a trigger named 'Table' in your map.
    //          - Convert it to Jass (Custom Script) and replace all
    //            of the code in there with the code in the trigger 'Table'.
    
    globals
        
    //          ¤                           ¤
    //         ( *'*-._.-*'*-._.-*'*-._.-*'* )
    //          )  RecipeSYS configuration  (
    //         ( *'*-._.-*'*-._.-*'*-._.-*'* )
    //         ¤                             ¤
        
        private constant boolean AUTO_COMBINE = true
        //Whether you want the system to automatically combine
        //the ingredients of a recipe to the result when a unit
        //has all of them.
        private constant boolean NEED_PICK_UP = true
        // Whether the item actually has to be picked up by the
        // unit in order for the recipe to combine, or if it's
        // enough for the unit to be ordered to pick the item
        // (this as false will make you able to "pick" the last
        // ingredient needed for the recipe and combine the recipe
        // even if the inventory is full (still plays the sound "Inventory
        // is full" and displayes the message, but they can be hidden in
        // game interface)).
        private constant real MAX_RANGE = 200.
        // How far away from the item can the unit be in order to
        // be able to "pick it up" when NEED_PICK_UP is false.
        private constant string SFX_PATH  = "Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl"
        //The path of the default effect.
        private constant string SFX_POINT = "origin"
        //The default attachment point.
        private constant integer AMOUNT_ING = 10
        //The amount of recipes an item can be an ingredient in.
        private constant integer AMOUNT_RES = 10
        //The amount of recipes an item can be a result in.
        
    //          ¤                           ¤
    //         ( *'*-._.-*'*-._.-*'*-._.-*'* )
    //          )DO NOT EDIT PAST THIS POINT(
    //         ( *'*-._.-*'*-._.-*'*-._.-*'* )
    //          )Well, you can if you really(
    //         ( want to, but only if you    )
    //          )know what you're doing. And(
    //         ( it's not needed, anyways.   )
    //          )*'*-._.-*'*-._.-*'*-._.-*'*(
    //         ¤                             ¤
        
        private constant real MAX_RANGE_POW2 = MAX_RANGE * MAX_RANGE
        public constant trigger TRIGGER = CreateTrigger()
        private Table ING_TABLE
        private Table RES_TABLE
        private HandleTable COMBINE_TABLE
    endglobals
    
    private type ingIn extends recipe array [AMOUNT_ING]
    private type resIn extends recipe array [AMOUNT_RES]
    
    struct recipe
        readonly integer array items [6]
        readonly integer result
        integer chargeType
        string sfx
        string point
        boolean resultHasCharges
        boolean enabled
        
        static method create takes integer i1, integer i2, integer i3, integer i4, integer i5, integer i6, integer result, string sfx, string attPoint, boolean charges, integer chargetype returns recipe
            local recipe i = recipe.allocate()
            local ingIn ing
            local resIn res
            local boolean error = false // Stupid 1.24
            local boolean array b
            local integer j = 0
            local integer k
            local integer l = 0
            set i.items[0] = i1
            set i.items[1] = i2
            set i.items[2] = i3
            set i.items[3] = i4
            set i.items[4] = i5
            set i.items[5] = i6
            set i.result   = result
            set i.enabled  = true
            set i.resultHasCharges  = charges
            set i.chargeType        = chargetype
            
            //To prevent linking the recipe to the item type twice.
            set b[0] = true
            set b[1] = i2 != i1
            set b[2] = i3 != i2 and i3 != i1
            set b[3] = i4 != i3 and i4 != i2 and i4 != i1
            set b[4] = i5 != i4 and i5 != i3 and i5 != i2 and i5 != i1
            set b[5] = i6 != i5 and i6 != i4 and i6 != i3 and i6 != i2 and i6 != i1
            
            //Set the SFX things (default or specified).
            if sfx == "" then
                set i.sfx = SFX_PATH
            else
                set i.sfx = sfx
            endif
            if attPoint == "" then
                set i.point = SFX_POINT
            else
                set i.point = attPoint
            endif
            
            //Linking the recipe to the item types.
            loop
                if i.items[j] != 0 and b[j] then
                    set k = ING_TABLE[i.items[j]]
                    if k != 0 then
                        //Item type is in another recipe aswell.
                        set ing = ingIn(k)
                        set k = 0
                        //Seek for an open slot.
                        loop
                            exitwhen error or ing[k] == 0
                            set k = k + 1
                            if k == ingIn.size then
                                debug call BJDebugMsg("|cffff0202RecipeSYS Error:|r AMOUNT_ING is too small!")
                                set error = true
                            endif
                        endloop
                    else
                        //First appearance for the item type.
                        set ing = ingIn.create()
                        set k = 0
                    endif
                    
                    exitwhen error
                    
                    set ing[k] = i
                    set ING_TABLE[i.items[j]] = integer(ing)
                endif
                set j = j + 1
                exitwhen j == 6
            endloop
            
            if not error then
                set k = RES_TABLE[i.result]
                if k != 0 then
                    //Item type is in some other recipe, too.
                    set res = resIn(k)
                    set k = 0
                    loop
                        exitwhen error or res[k] == 0
                        set k = k + 1
                        if k == resIn.size then
                            debug call BJDebugMsg("|cffff0202RecipeSYS Error:|r AMOUNT_RES too small!")
                            set error = true
                        endif
                    endloop
                else
                    //First time being in a recipe for the item type.
                    set res = resIn.create()
                endif
                
                if not error then
                    set res[k] = i
                    set RES_TABLE[i.result] = integer(res)
                endif
            endif
            
            if error then
                call i.destroy()
                return recipe(0)
            else
                return i
            endif
        endmethod
        
        private method ClearRecipeFromIngredient takes integer it returns nothing
            local integer i = 0
            local integer j = 0
            local integer k
            local ingIn ing = ingIn(ING_TABLE[it])
            
            if it == 0 or integer(ing[0]) == 0 then
                return
            endif
            
            //Finding the right array slot and setting it's value to 0.
            loop
                exitwhen i == ingIn.size
                if ing[i] == this then
                    set j = i + 1
                    
                    //Finding the last used array slot.
                    loop
                        exitwhen j == ingIn.size or ing[j] == 0
                        set j = j + 1
                    endloop
                    set j = j - 1
                    
                    set ing[i] = ing[j]
                    set ing[j] = 0
                    exitwhen true
                endif
                
                set i = i + 1
            endloop
            
            //Free the array and flush if the slots are empty.
            if integer(ing[0]) == 0 then
                call ING_TABLE.flush(it)
                call ing.destroy()
            endif
        endmethod
        
        private method ClearRecipeFromResult takes integer it returns nothing
            local integer i = 0
            local integer j
            local resIn res = resIn(RES_TABLE[it])
            
            if it == 0 then
                return
            endif
            
            //Finding the right array slot and setting it's value to 0.
            loop
                exitwhen i == resIn.size
                if res[i] == this then
                    set j = i + 1
                    
                    //Finding the last used array slot.
                    loop
                        exitwhen j == resIn.size or res[j] == 0
                        set j = j + 1
                    endloop
                    set j = j - 1
                    
                    set res[i] = res[j]
                    set res[j] = 0
                    exitwhen true
                endif
                
                set i = i + 1
            endloop
            
            //Free the array slots and flush if it's empty.
            if res[0] == 0 then
                call RES_TABLE.flush(it)
                call res.destroy()
            endif
        endmethod
        
        // Used in SetIngredient to clear the old slot.
        private method ClearSlot takes integer slot returns nothing
            local integer i = 0
            
            loop
                exitwhen i == 6
                if slot != i and .items[i] == .items[slot] then
                    // If the item is several times in the recipe,
                    // setting this one to 0 is enough.
                    set .items[slot] = 0
                    return
                endif
                set i = i + 1
            endloop
            
            // Otherwise we need to clear the recipe from the item.
            call .ClearRecipeFromIngredient(.items[slot])
        endmethod
        
        method SetIngredient takes integer id, integer slot returns nothing
            local ingIn ing
            call .ClearSlot(slot)
            set .items[slot] = id
            set slot = ING_TABLE[id]
            if slot != 0 then
                //Item type is in another recipe aswell.
                set ing = ingIn(slot)
                set slot = 0
                //Seek for an open slot.
                loop
                    exitwhen ing[slot] == 0
                    set slot = slot + 1
                    if slot == ingIn.size then
                        debug call BJDebugMsg("|cffff0202RecipeSYS Error:|r AMOUNT_ING is too small!")
                        return
                    endif
                endloop
            else
                //First appearance for the item type.
                set ing = ingIn.create()
                set slot = 0
            endif
            set ing[slot] = this
            set ING_TABLE[id] = integer(ing)
        endmethod
        
        method SetResult takes integer id returns nothing
            local resIn res
            local integer k = RES_TABLE[id]
            call .ClearRecipeFromResult(.result)
            set .result = id
            
            if k != 0 then
                //Item type is in some other recipe, too.
                set res = resIn(k)
                set k = 0
                loop
                    exitwhen res[k] == 0
                    set k = k + 1
                    if k == resIn.size then
                        debug call BJDebugMsg("|cffff0202RecipeSYS Error:|r AMOUNT_RES too small!")
                        return
                    endif
                endloop
            else
                //First time being in a recipe for the item type.
                set res = resIn.create()
            endif
            set res[k] = this
            set RES_TABLE[.result] = integer(res)
        endmethod
        
        method onDestroy takes nothing returns nothing
            local integer i = 0
            loop
                call .ClearRecipeFromIngredient(.items[i])
                set i = i + 1
                exitwhen i == 6
            endloop
            
            call .ClearRecipeFromResult(.result)
            set .result = 0
        endmethod
    endstruct
    
    //****************************************************
    //**    Recipes Without Charges                     **
    //****************************************************
    
    function AddRecipe takes integer item1, integer item2, integer item3, integer item4, integer item5, integer item6, integer result returns recipe
        return recipe.create(item1, item2, item3, item4, item5, item6, result, "", "", false, 0)
    endfunction
    
    function AddRecipeEx takes integer item1, integer item2, integer item3, integer item4, integer item5, integer item6, integer result, string sfx, string attachmentPoint returns recipe
        return recipe.create(item1, item2, item3, item4, item5, item6, result, sfx, attachmentPoint, false, 0)
    endfunction
    
    //****************************************************
    //**    Recipes With Charges                        **
    //****************************************************
    
    function AddRecipeWithCharges takes integer item1, integer item2, integer item3, integer item4, integer item5, integer item6, integer result, integer chargeType returns recipe
        return recipe.create(item1, item2, item3, item4, item5, item6, result, "", "", true, chargeType)
    endfunction
    
    function AddRecipeWithChargesEx takes integer item1, integer item2, integer item3, integer item4, integer item5, integer item6, integer result, integer chargeType, string sfx, string attachmentPoint returns recipe

        return recipe.create(item1, item2, item3, item4, item5, item6, result, sfx, attachmentPoint, true, chargeType)
    endfunction
    
    //****************************************************
    //**    Removing Recipes                            **
    //****************************************************
    
    function RemoveRecipeByResult takes integer result returns nothing
        local resIn res = resIn(RES_TABLE[result])
        
        loop
            exitwhen integer(res[0]) == 0
            call res[0].destroy()
        endloop
    endfunction
    
    //****************************************************
    //**    Disabling and enabling recipes              **
    //****************************************************
    
    function EnableRecipeByResult takes integer result, boolean enable returns nothing
        local resIn res = resIn(RES_TABLE[result])
        local integer i = 0
        
        loop
            exitwhen integer(res[i]) == 0
            set res[i].enabled = enable
            set i = i + 1
        endloop
    endfunction
    
    //****************************************************
    //**    Disassembling Combined Items                **
    //****************************************************
    
    function DisassembleItemByRecipe takes item whichItem, unit whichUnit, recipe re returns nothing
        local integer i = 0
        local real x = GetItemX(whichItem)
        local real y = GetItemY(whichItem)
        local boolean b = IsTriggerEnabled(GetTriggeringTrigger())
        local boolean c = IsTriggerEnabled(TRIGGER)
        
        if re.result == GetItemTypeId(whichItem) then
            if b then
                //Avoid clashing with some events.
                call DisableTrigger(GetTriggeringTrigger())
            endif
            call COMBINE_TABLE.flush(whichItem)
            call RemoveItem(whichItem)
            
            //Should the items be created for a unit or at ground?
            if whichUnit == null then
                loop
                    call CreateItem(re.items[i], x, y)
                    set i = i + 1
                    exitwhen i == 6
                endloop
            else
                if c then
                    //Preventing infinite loop.
                    call DisableTrigger(TRIGGER)
                endif
                
                loop
                    call UnitAddItemById(whichUnit, re.items[i])
                    set i = i + 1
                    exitwhen i == 6
                endloop
                
                if c then
                    call EnableTrigger(TRIGGER)
                endif
            endif
            
            if b then
                call EnableTrigger(GetTriggeringTrigger())
            endif
        endif
    endfunction
    
    function DisassembleItem takes item whichItem, unit whichUnit returns nothing
        local integer id = GetItemTypeId(whichItem)
        local resIn r = resIn(RES_TABLE[id])
        local recipe re = recipe(COMBINE_TABLE[whichItem])
        
        if integer(re) == 0 or re.result != id then //The last one just in case the recipe has been destroyed.
            if integer(r[0]) == 0 then
                return
            endif
            set re = r[0]
        endif
        
        call DisassembleItemByRecipe(whichItem, whichUnit, re)
    endfunction
    
    //****************************************************
    //**    Combining                                   **
    //****************************************************
    
    private function DoCombine takes recipe rec, unit u, item noncarried returns boolean
        local integer array itemsReq
        local integer noncarriedId = GetItemTypeId(noncarried)
        local integer itemInSlot
        local integer topCharges = 0
        local integer sumCharges = 0
        local integer i = 0
        local integer j = 0
        local item resu
        local item array itemsToCombine
        
        //Setting the items.
        loop
            set itemsReq[i] = rec.items[i]
            set i = i + 1
            exitwhen i == 6
        endloop
        
        set i = 0
        //Finding the items.
        loop
            set itemInSlot = GetItemTypeId(UnitItemInSlot(u, i))
            loop
                if itemsReq[j] == noncarriedId and noncarried != null then
                    set itemsToCombine[j] = noncarried
                    set itemsReq[j] = 0
                    set noncarried  = null
                    exitwhen true
                elseif itemsReq[j] == itemInSlot and itemInSlot != 0 then
                    set itemsToCombine[j] = UnitItemInSlot(u, i)
                    set itemsReq[j] = 0
                    exitwhen true
                endif
                set j = j + 1
                exitwhen j == 6
            endloop
            set j = 0
            set i = i + 1
            exitwhen i == 6
        endloop
        set noncarried = null
        
        set i = 0
        set j = 0
        //Checking if all items were found.
        loop
            if itemsReq[i] != 0 then
                loop
                    set itemsToCombine[j] = null
                    set j = j + 1
                    exitwhen j == 6
                endloop
                return false
            endif
            set i = i + 1
            exitwhen i == 6
        endloop
        
        set i = 0
        //Remove the old items.
        loop
            //Set the different charge amounts in case the result has charges.
            set j = GetItemCharges(itemsToCombine[i])
            set sumCharges = sumCharges + j
            if j > topCharges then
                set topCharges = j
            endif
            
            call COMBINE_TABLE.flush(itemsToCombine[i])
            call RemoveItem(itemsToCombine[i])
            set itemsToCombine[i] = null
            set i = i + 1
            exitwhen i == 6
        endloop
        
        //Create the result.
        set resu = UnitAddItemById(u, rec.result)
        call DestroyEffect(AddSpecialEffectTarget(rec.sfx, u, rec.point))
        
        //Set charges if it should have any.
        if rec.resultHasCharges then
            if rec.chargeType == 0 then
                call SetItemCharges(resu, sumCharges)
            elseif rec.chargeType == -1 then
                call SetItemCharges(resu, topCharges)
            else
                call SetItemCharges(resu, rec.chargeType)
            endif
        endif
        
        //Set the data if wanted.
        set COMBINE_TABLE[resu] = integer(rec)
        
        set bj_lastCreatedItem = resu
        set resu = null
        return true
    endfunction
    
    //****************************************************
    //**    Recipe Finding                              **
    //****************************************************
    
    function GetRecipeItemCombinedFrom takes item i returns recipe
        local recipe r = recipe(COMBINE_TABLE[i])
        if integer(r) == 0 or GetItemTypeId(i) != r.result then
            set r = ingIn(ING_TABLE[GetItemTypeId(i)])[0]
        endif
        return r
    endfunction
    
    public function Combine takes item check, unit u returns boolean
        local boolean isCarried = UnitHasItem(u, check)
        local ingIn r = ingIn(ING_TABLE[GetItemTypeId(check)])
        local integer i = 0
        
        if check == null then
            return false
        endif
        
        loop
            exitwhen integer(r[i]) == 0 or i == r.size
            
            if r[i].enabled then
                if isCarried then
                    if DoCombine(r[i], u, null) then
                        return true
                    endif
                else
                    if DoCombine(r[i], u, check) then
                        return true
                    endif
                endif
            endif
            set i = i + 1
        endloop
        
        return false
    endfunction
    
    private function Check takes nothing returns boolean
        local real dx
        local real dy
        
        if GetIssuedOrderId() == OrderId("smart") then
            if GetOrderTargetItem() == null then
                return false
            endif
            set dx = GetItemX(GetOrderTargetItem()) - GetUnitX(GetTriggerUnit())
            set dy = GetItemY(GetOrderTargetItem()) - GetUnitY(GetTriggerUnit())
            if dx * dx + dy * dy <= MAX_RANGE_POW2 then
                return Combine(GetOrderTargetItem(), GetTriggerUnit())
            endif
            return false
        endif
        
        return Combine(GetManipulatedItem(), GetTriggerUnit())
    endfunction
    
    //=====================================================================
    private function SafeFilt takes nothing returns boolean
        return true
    endfunction
    //=====================================================================
    
    private function init takes nothing returns nothing
        local integer index = 0
        if AUTO_COMBINE then
            loop
                call TriggerRegisterPlayerUnitEvent(TRIGGER, Player(index), EVENT_PLAYER_UNIT_PICKUP_ITEM, Filter(function SafeFilt))
                if not NEED_PICK_UP then
                    call TriggerRegisterPlayerUnitEvent(TRIGGER, Player(index), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, Filter(function SafeFilt))
                endif
                set index = index + 1
                exitwhen index == bj_MAX_PLAYER_SLOTS
            endloop
            call TriggerAddCondition(TRIGGER, Condition(function Check))
        endif
        set ING_TABLE = Table.create()
        set RES_TABLE = Table.create()
        set COMBINE_TABLE = HandleTable.create()
    endfunction
    
endlibrary