library xepreload requires xebasic, optional TimerUtils
//******************************************************************************
// xepreload 0.9
// ---------
// Ah, the joy of preloading abilities, it is such a necessary evil...
// Notice you are not supposed to use this system in places outside map init
//
// This one does the preloading and tries to minimize the hit on loading time
// for example, it only needs one single native call per ability preloaded.
//
//******************************************************************************

//==============================================================================
    globals
        private unit dum=null
    endglobals
    private keyword DebugIdInteger2IdString

    //inline friendly (when debug mode is off..)
    function XE_PreloadAbility takes integer abilid returns nothing
        call UnitAddAbility(dum, abilid)
        static if DEBUG_MODE then
            if(dum==null) then
                call BJDebugMsg("XE_PreloadAbility: do not load abilities after map init or during modules' onInit")
            elseif GetUnitAbilityLevel(dum, abilid) == 0 then
                call BJDebugMsg("XE_PreloadAbility: Ability "+DebugIdInteger2IdString.evaluate(abilid)+" does not exist.")
            endif
        endif
    endfunction
    // ................................................................................

    //================================================================================
    // Convert a integer id value into a 4-letter id code.
    // * Taken from cheats.j so I don't have to code it again.
    // * Used only on debug so making a whole library for it seemed silly
    // * Private so people don't begin using xepreload just to call this function....
    // * It will not work correctly if you paste this code in the custom script section
    //   due to the infamous % bug. Then again, if you do that then you probably 
    // deserve it....
    //
    private function DebugIdInteger2IdString takes integer value returns string
     local string charMap = ".................................!.#$%&'()*+,-./0123456789:;<=>.@ABCDEFGHIJKLMNOPQRSTUVWXYZ[.]^_`abcdefghijklmnopqrstuvwxyz{|}~................................................................................................................................."
     local string result = ""
     local integer remainingValue = value
     local integer charValue
     local integer byteno

     set byteno = 0
     loop
         set charValue = ModuloInteger(remainingValue, 256)
         set remainingValue = remainingValue / 256
         set result = SubString(charMap, charValue, charValue + 1) + result
 
         set byteno = byteno + 1
         exitwhen byteno == 4
     endloop
     return result
    endfunction

    //--------------------------------
    private function kill takes nothing returns nothing
        call RemoveUnit(dum)
        set dum=null
        static if (LIBRARY_TimerUtils ) then
            call ReleaseTimer( GetExpiredTimer() )
        else
            call DestroyTimer(GetExpiredTimer())
        endif
    endfunction
    
    private struct init extends array
    private static method onInit takes nothing returns nothing
     local timer t
        set dum = CreateUnit( Player(15), XE_DUMMY_UNITID, 0,0,0)
        if( dum == null) then
            debug call BJDebugMsg("xePreload : XE_DUMMY_UNITID ("+DebugIdInteger2IdString.evaluate(XE_DUMMY_UNITID)+") not added correctly to the map.")
        endif
        static if (LIBRARY_TimerUtils) then
            set t=NewTimer()
        else
            set t=CreateTimer()
        endif
        call TimerStart(t,0.0,false,function kill)
        set t=null
    endmethod
    endstruct

endlibrary
