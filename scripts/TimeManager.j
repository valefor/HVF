library TimeManager initializer init/* v0.0.1 Xandria
*************************************************************************************
* 	HVF Time Management library which provides game time utils
*************************************************************************************
*
*   */ uses /*
*   
*       */ Dialog /*
*       */ Core   /*  core functions must be loaded first
*
*************************************************************************************/

	globals
        private button array btsSelect
        private real 		rPlayTime 	= 0.0
        private integer 	iSelects 	= 0
        private integer 	iMultiple 	= 60
    endglobals
    
    private function DialogEvent takes nothing returns boolean
        local Dialog  	dgClicked 	= Dialog.getClickedDialog()
        local button  	btClicked   = Dialog.getClickedButton()
        
        if IsSinglePlayer() then
            debug call BJDebugMsg("You are soloing")
        endif
        
        debug call BJDebugMsg("Dialog button clicked")
        set iSelects = iSelects + 1
        if btClicked == btsSelect[0] then
            set rPlayTime = rPlayTime + 40.0
        elseif btClicked == btsSelect[1] then
            set rPlayTime = rPlayTime + 50.0
        elseif btClicked == btsSelect[2] then
            set rPlayTime = rPlayTime + 60.0
        endif
                
        if iSelects == Human.count then
        	debug call BJDebugMsg("All players have voted!")
        	debug call BJDebugMsg("Game time is set to " + I2S(R2I(rPlayTime/iSelects)) + " minutes.")
        	call dgClicked.destroy()
        	set btClicked = null
        endif
        return false 
    endfunction
    
	private function AppendHotkey takes string source, string hotkey returns string
        return "|cffffcc00[" + hotkey + "]|r " + source
    endfunction

    private function ShowSelectDialog takes nothing returns nothing 
    	local Dialog dgSelection = Dialog.create()
        local Human human = Human[Human.first]
        
        debug call BJDebugMsg("ShowSelectDialog!")
        
        set dgSelection.title  = CST_STR_PLAYTIME_TITLE
        set btsSelect[0] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_40,    "A"), 'A')
        set btsSelect[1] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_50,    "B"), 'B')
        set btsSelect[2] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_60,    "C"), 'C')
        
        // register callback
        call dgSelection.registerClickEvent(Condition(function DialogEvent))
        // only display dialog to human player
        loop
        	debug call BJDebugMsg("ShowSelectDialog to player:" + GetPlayerName(human.get))
        	call dgSelection.display(human.get, true)
        	set human = human.next
        	exitwhen human.end
        endloop
        //call dgSelection.displayAll(true)
        
    endfunction
    
    function TimeVote takes nothing returns nothing
    	debug call BJDebugMsg("Vote for play time!")
    	call DestroyTimer(GetExpiredTimer())
    	call ShowSelectDialog()
    endfunction
    
    private function init takes nothing returns nothing
    	// set iMultiple to 1 seconds in debug mode to fast debugging
    	set iMultiple = 1
    	// dialogs can't be displayed on init and the scope's init-func is run during init
    	// so we need to use TimerStart to call functions which need to show dialog
    	//call TimerStart(CreateTimer(), 0, false, function TimeVote)
    endfunction 
    
endlibrary