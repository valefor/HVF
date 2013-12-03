//===========================================================================
//  PUI -- Perfect Unit Indexing by Cohadar -- v6.2
//===========================================================================
//
//  PURPOUSE:
//       * Extending UnitUserData()
//       * This is basically perfect hashing algorithm for units
//
//  HOW TO USE:
//       * You have two functions at your disposal: 
//           GetUnitIndex(unit) -> index
//           GetIndexUnit(index) -> unit
//
//       * Put you custom unit properties in struct that extends arrays.
//         Use unit index as id of that struct.
//         There is an example of this in demo map.
//         
//  PROS:
//       * Unit indexes are assigned only to units that actually need them.
//       * Unit index will be automatically recycled when unit is removed from the game.
//       * Automatically detects null unit handles and removed unit handles (in debug mode)
//
//  CONS:
//       * This system needs exclusive access to UnitUserData
//
//  DETAILS:
//       * Uses internal vJass struct index allocation/deallocation algorithm.
//       * Periodically checks and recycles unit indexes
//
//  THANKS TO:
//       * Vexorian - for his help with PUI textmacro
//       * Builder Bob - for testing and bugfinding
//       * Joker(Div) - bugfinding
//
//  HOW TO IMPORT:
//       * Just create a trigger named PUI
//       * convert it to text and replace the whole trigger text with this one
//
//===========================================================================


library PUI initializer Init

//===========================================================================
globals    
    // maximum number of indexed units on your map at a single moment of time
    private constant integer MAX_INDEXES = 1024  // up to 8192
    
    // period of recycling, 32 indexes per second
    private constant real PERIOD = 0.03125   
    
    // current check index
    private integer C = 0 
endglobals

//===========================================================================
// Using internal struct algorithm for index allocation/dealocation
// This way I don't have to write messy code of my own
//===========================================================================
private struct UnitIndex
    unit u
    
    //----------------------------------------------------------
    static method create takes unit whichUnit returns UnitIndex
        local UnitIndex index 
        
        // check for null unit handle
        debug if whichUnit == null then
        debug     call BJDebugMsg("|c00FF0000ERROR: PUI - Index requested for null unit")
        debug     return 0
        debug endif
        
        set index = UnitIndex.allocate()
        set index.u = whichUnit
        call SetUnitUserData(whichUnit, index)
        
        // check for removed unit handle
        debug if GetUnitUserData(whichUnit) == 0 then
        debug     call BJDebugMsg("|c00FFCC00WARNING: PUI - Bad unit handle")
        debug     return 0
        debug endif        
        
        return index
    endmethod
    
    //----------------------------------------------------------
    static method Recycler takes nothing returns boolean
        local UnitIndex index = C
        set C = C + 1
        if C == MAX_INDEXES then
            set C = 0
        endif
        if index.u != null then
            if (GetUnitUserData(index.u) == 0) then
                set index.u = null
                call index.destroy()
            endif
        endif
        return false
    endmethod
endstruct

//===========================================================================
//  Returns index of some unit, if unit has no index it gets a new one.
//===========================================================================
function GetUnitIndex takes unit whichUnit returns integer
    local UnitIndex index = GetUnitUserData(whichUnit)
    if index == 0 then
        set index = UnitIndex.create(whichUnit)
    endif
    return index
endfunction

//===========================================================================
//  Return unit that has specified index, or null in no such unit exists.
//===========================================================================
function GetIndexUnit takes integer index returns unit
    local UnitIndex i = index
    if i.u != null then
        if GetUnitUserData(i.u) == index then
            return i.u
        endif
    endif
    return null
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger()
    call TriggerRegisterTimerEvent(trig, PERIOD, true)
    call TriggerAddCondition(trig, Condition(function UnitIndex.Recycler))
endfunction

endlibrary

//***************************************************************************
//
//  PUI TEXTMACROS
// 
//***************************************************************************

//===========================================================================
//  Allowed PUI_PROPERTY TYPES are: unit, integer, real, boolean, string
//  Do NOT put handles that need to be destroyed here (timer, trigger, ...)
//  Instead put them in a struct and use PUI textmacro
//===========================================================================
//! textmacro PUI_PROPERTY takes VISIBILITY, TYPE, NAME, DEFAULT
$VISIBILITY$ struct $NAME$
    private static unit   array pui_unit
    private static $TYPE$ array pui_data
    
    //-----------------------------------------------------------------------
    //  Returns default value when first time used
    //-----------------------------------------------------------------------
    static method operator[] takes unit whichUnit returns $TYPE$
        local integer pui = GetUnitIndex(whichUnit)
        if .pui_unit[pui] != whichUnit then
            set .pui_unit[pui] = whichUnit
            set .pui_data[pui] = $DEFAULT$
        endif
        return .pui_data[pui]
    endmethod
    
    //-----------------------------------------------------------------------
    static method operator[]= takes unit whichUnit, $TYPE$ whichData returns nothing
        local integer pui = GetUnitIndex(whichUnit)
        set .pui_unit[pui] = whichUnit
        set .pui_data[pui] = whichData
    endmethod
endstruct
//! endtextmacro

//===========================================================================
//  Never destroy PUI structs directly.
//  Use .release() instead, will call .destroy()
//  The best option is never to release or destroy PUI structs manually
//    because they will be recycled automatically with unit handle.
//===========================================================================
//! textmacro PUI
    private static unit    array pui_unit
    private static integer array pui_data
    private static integer array pui_id
    
    //-----------------------------------------------------------------------
    //  Returns zero if no struct is attached to unit
    //-----------------------------------------------------------------------
    static method operator[] takes unit whichUnit returns integer
        local integer pui = GetUnitIndex(whichUnit)
        if .pui_data[pui] != 0 then
            if .pui_unit[pui] != whichUnit then
                // recycled handle detected
                call .destroy(.pui_data[pui])
                set .pui_unit[pui] = null
                set .pui_data[pui] = 0            
            endif
        endif
        return .pui_data[pui]
    endmethod
    
    //-----------------------------------------------------------------------
    //  This will overwrite already attached struct if any
    //-----------------------------------------------------------------------
    static method operator[]= takes unit whichUnit, integer whichData returns nothing
        local integer pui = GetUnitIndex(whichUnit)
        if .pui_data[pui] != 0 then
            call .destroy(.pui_data[pui])
        endif
        set .pui_unit[pui] = whichUnit
        set .pui_data[pui] = whichData
        set .pui_id[whichData] = pui
    endmethod

    //-----------------------------------------------------------------------
    //  If you do not call release struct will be destroyed when unit handle gets recycled
    //-----------------------------------------------------------------------
    method release takes nothing returns nothing
        local integer pui= .pui_id[integer(this)]
        call .destroy()
        set .pui_unit[pui] = null
        set .pui_data[pui] = 0
    endmethod
//! endtextmacro

//***************************************************************************
//
//  PUI MODULE  (does the same stuff as PUI textmacro)
// 
//***************************************************************************

//===========================================================================
//  Never destroy PUI structs directly.
//  Use .release() instead, will call .destroy()
//  The best option is never to release or destroy PUI structs manually
//    because they will be recycled automatically with unit handle.
//===========================================================================
module PUI
    private static unit    array pui_unit
    private static integer array pui_data
    private static integer array pui_id
    
    //-----------------------------------------------------------------------
    //  Returns zero if no struct is attached to unit
    //-----------------------------------------------------------------------
    static method operator[] takes unit whichUnit returns integer
        local integer pui = GetUnitIndex(whichUnit)
        if .pui_data[pui] != 0 then
            if .pui_unit[pui] != whichUnit then
                // recycled handle detected
                call .destroy(.pui_data[pui])
                set .pui_unit[pui] = null
                set .pui_data[pui] = 0            
            endif
        endif
        return .pui_data[pui]
    endmethod
    
    //-----------------------------------------------------------------------
    //  This will overwrite already attached struct if any
    //-----------------------------------------------------------------------
    static method operator[]= takes unit whichUnit, integer whichData returns nothing
        local integer pui = GetUnitIndex(whichUnit)
        if .pui_data[pui] != 0 then
            call .destroy(.pui_data[pui])
        endif
        set .pui_unit[pui] = whichUnit
        set .pui_data[pui] = whichData
        set .pui_id[whichData] = pui
    endmethod

    //-----------------------------------------------------------------------
    //  If you do not call release struct will be destroyed when unit handle gets recycled
    //-----------------------------------------------------------------------
    method release takes nothing returns nothing
        local integer pui= .pui_id[integer(this)]
        call .destroy()
        set .pui_unit[pui] = null
        set .pui_data[pui] = 0
    endmethod
endmodule

/* Example

scope YourSpell

//===========================================================================
private struct Data
    unit whichUnit
    private static Data array PUI  //<---------

    //-------------------------------------------------------------------------  
    static method create takes unit whichUnit returns Data
        local Data ret = Data.allocate()
        set ret.whichUnit = whichUnit
        set Data.PUI[GetUnitIndex(whichUnit)] = ret // create unit->Data link
        return ret
    endmethod
    
    //-------------------------------------------------------------------------  
    static method Get takes unit whichUnit returns Data
        local integer index
    
        set index = GetUnitIndex(whichUnit) // PUI
        if Data.PUI[index] == 0 then
            debug call BJDebugMsg("|c00FFCC00"+"Data struct created on first use for unit: " + GetUnitName(whichUnit))
            return Data.create(whichUnit)
        endif
        
        return Data.PUI[index]
    endmethod    

    //-------------------------------------------------------------------------  
    method onDestroy takes nothing returns nothing
        set Data.PUI[GetUnitIndex(.whichUnit)] = 0 // break unit->Data link
    endmethod    
endstruct

endscope


scope StructExample initializer Init

//===========================================================================
//  If we want struct to be attachable to units we run PUI macro inside it.
//  Putting 5-6 unit properties inside struct is more efficient 
//  than declaring 5 PUI_PROPERTY each for itself
//===========================================================================
private struct UnitData
    //! runtextmacro PUI()
    integer KillCounter = 0
    
    // you can add any of your own stuff here
endstruct

//===========================================================================
private function Actions takes nothing returns nothing
    local unit killer = GetKillingUnit()
    local UnitData dat = UnitData[killer]
    
    // is struct attached?
    if dat == 0 then
        set dat = UnitData.create() // if not create it
        set UnitData[killer] = dat // and attach it
    endif

    // again it is simple
    set dat.KillCounter = dat.KillCounter + 1
    
    // do some other stuff with your struct...
endfunction

//===========================================================================
//  WARNING: never destroy PUI structs directly use release() method instead
//  In fact it is best that you never destroy them manually,
//  they will be destroyed automatically when unit is removed from game.
//===========================================================================

//===========================================================================
private function Conditions takes nothing returns boolean
    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( trig, Condition( function Conditions ) )
    call TriggerAddAction( trig, function Actions )
endfunction

endscope

*/
