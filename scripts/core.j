library Core initializer init/* v0.0.1 Xandria
*************************************************************************************
* 	HVF Core library which provides some useful functions
*
* 
*
*************************************************************************************
*	I'd like to put name convention here
*	function		:	funcion FunctionName
*	struct			:	struct StructName
*	struct.method	:	method methodName
*	struct.initializer: onInit
*	library.initializer: init
*************************************************************************************
*	TriggerExecute 	: Execute Trigger's action, ignore Trigger's conditions
native TriggerExecute       takes trigger whichTrigger returns nothing

*	TriggerEvaluate : Execute Trigger's conditions, ignore Trigger's action
native TriggerEvaluate      takes trigger whichTrigger returns boolean


// Runs the trigger's actions if the trigger's conditions evaluate to true.

function ConditionalTriggerExecute takes trigger trig returns nothing
    if TriggerEvaluate(trig) then
        call TriggerExecute(trig)
    endif
endfunction
*************************************************************************************/

	globals
		private boolean bSinglePlayer = ReloadGameCachesFromDisk()
	endglobals

	function IsSinglePlayer takes nothing returns boolean
		return bSinglePlayer
	endfunction
	struct TimeManager
	endstruct
	
	/*
	**************************************************************************************
	* Prevent Save : hiveworkshop.com/forums/jass-resources-412/snippet-preventsave-158048/
	*	@provide by TriggerHappy
	**************************************************************************************
	*/
	globals
        boolean GameAllowSave = true
    endglobals
    
    globals
        private dialog DummyDialog = DialogCreate()
        private timer  DummyTimer  = CreateTimer()
        private player localplayer
    endglobals
    
    function PreventSave takes player p, boolean flag returns nothing
    	if (p == localplayer) then
    		set GameAllowSave = not flag
    	endif
    endfunction
    
    private function Exit takes nothing returns nothing
    	call DialogDisplay(localplayer, DummyDialog, false)
    endfunction
    
    private function StopSave takes nothing returns boolean
    	if not GameAllowSave then
    		call DialogDisplay(localplayer, DummyDialog, true)
    	endif
    	call TimerStart(DummyTimer, 0.00, false, function Exit)
    	return false  	
    endfunction
    
    // library initilaizer
    private function init takes nothing returns nothing
    	local trigger t = CreateTrigger()
    	set localplayer = GetLocalPlayer()
    	
    	call TriggerRegisterGameEvent(t, EVENT_GAME_SAVE)
    	call TriggerAddCondition(t, function StopSave)
    endfunction
    
endlibrary
