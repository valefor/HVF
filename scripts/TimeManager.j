library TimeManager initializer init/* v0.0.1 Xandria
*************************************************************************************
* 	HVF Core library which provides some useful functions
*************************************************************************************
*
*   */ uses /*
*   
*       New*/ Dialog /*
*

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
        private button array selectBtns
        private real playTime = 0.0
        private integer selects = 0
        private integer multiple = 60
    endglobals
    
    private function DialogEvent takes nothing returns boolean
        local Dialog  log = Dialog.getClickedDialog()
        local button  b   = Dialog.getClickedButton()
        
        if IsSinglePlayer() then
            debug call BJDebugMsg("You are soloing")
        endif
        
        debug call BJDebugMsg("Dialog button clicked")
        set selects = selects + 1
        if b == selectBtns[0] then
            set playTime = playTime + 40.0
        elseif b == selectBtns[1] then
            set playTime = playTime + 50.0
        elseif b == selectBtns[2] then
            set playTime = playTime + 60.0
        endif
                
        if selects == Human.count then
        	debug call BJDebugMsg("All players have voted!")
        	debug call BJDebugMsg("Game time is set to " + I2S(R2I(playTime/selects)) + " minutes.")
        	call log.destroy()
        	set b = null
        endif
        return false 
    endfunction
    
	private function AppendHotkey takes string source, string hotkey returns string
        return "|cffffcc00[" + hotkey + "]|r " + source
    endfunction

    private function ShowSelectDialog takes nothing returns nothing 
        local Dialog log = Dialog.create()
        local Human human = Human[Human.first]
        
        set log.title  = CST_STR_PLAYTIME_TITLE
        set selectBtns[0] = log.addButton(AppendHotkey(CST_STR_PLAYTIME_40,    "A"), 'A')
        set selectBtns[1] = log.addButton(AppendHotkey(CST_STR_PLAYTIME_50,    "B"), 'B')
        set selectBtns[2] = log.addButton(AppendHotkey(CST_STR_PLAYTIME_60,    "C"), 'C')
        
        // register callback
        call log.registerClickEvent(Condition(function DialogEvent))
        // only display dialog to human player
        loop
        	call log.display(human.get, true)
        	set human = human.next
        	exitwhen human.end
        endloop
        //call log.displayAll(true)
        
    endfunction
    
    function TimeVote takes nothing returns nothing
    	call ShowSelectDialog()
    endfunction
    
    private function init takes nothing returns nothing
    	// set multiple to 1 seconds in debug mode to fast debugging
    	set multiple = 1
    	call TimerStart(CreateTimer(), 0, false, function TimeVote)
    endfunction 
    
endlibrary