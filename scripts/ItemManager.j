library ItemManager initializer init/* v0.0.1 Xandria
*/  uses    TimeManager     /*  
*/          HVF             /*
********************************************************************************
* HVF item manager
*******************************************************************************/

struct ItemManager
    private static method generateBeginMapItems takes nothing returns nothing
    endmethod

    private static method onInit takes nothing returns nothing
        call TimerManager.otGameStart.register(Filter(function thistype.generateBeginMapItems))
        call TimerManager.pt10s.register(Filter(function thistype.generateBeginMapItems))
        call TimerManager.pt30s.register(Filter(function thistype.generateBeginMapItems))
    endmethod
endstruct

/*******************************************************************************
* Library Initiation
*******************************************************************************/
private function init takes nothing returns nothing

endfunction

endlibrary