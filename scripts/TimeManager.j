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
*************************************************************************************
*** Some useful tips
Function TimerStart starts any timer whether it's running or not.
This function takes 4 arguments:

A Timer: The timer that is going to be started.
A Real: The interval or timeout of the timer.
A Boolean: Determines whether it's a one-shot timer or a periodic timer.
A code: The code that will execute whenever a timer expires.
The function TimerStart has been proven to be faster than ResumeTimer.
You don't need to pause a timer in order to start it.

Using a timeout of 0 will cause the timer to append the thread, meaning it will execute as soon as the thread finishes execution.
This is pretty handy, because some things can't be detected or done unless you wait for the next thread. For example, sounds can't be 
played in the same thread that they are created in, and thus, we use 0-timeout timers to play them.
*************************************************************************************/

	globals
        private button array btsSelect
        private real 		rPlayTime 	= 0.0
        private integer 	iSelects 	= 0
        private integer 	iMultiple 	= 60
    endglobals
    
    private function Countdown30sLeft takes nothing returns nothing
    	debug call BJDebugMsg("30 seconds left!")
    endfunction
    
    private function CountdownEnd takes nothing returns nothing
    	debug call BJDebugMsg("Timeout!")
    endfunction
    
    private function CountdownPlayTime takes nothing returns nothing
    	local timer tmCountDown = CreateTimer()
    	local timerdialog dgRemainedTime = CreateTimerDialog(tmCountDown)
    	
    	call TimerStart(tmCountDown, R2I(rPlayTime), false, null)
    	call TimerDialogSetTitle(dgRemainedTime, CST_STR_REMAINED_TIME)
    	call TimerDialogDisplay(dgRemainedTime, true)
    	
    	debug call BJDebugMsg("Start timer countdown!")
    	//call PolledWait(5.0)
    	call PolledWait(R2I(rPlayTime)-30)
    	// do something here
    	debug call BJDebugMsg("30 seconds left!")
    	
    	call PolledWait(30)
    	
    	// timeout
    	//call PolledWait(5.0)
    	debug call BJDebugMsg("Timeout!")
    	call TimerDialogDisplay(dgRemainedTime, false)
    	call DestroyTimerDialog(dgRemainedTime)
    	call DestroyTimer(tmCountDown)
    	set dgRemainedTime = null
    	set tmCountDown = null
    	// memory leak here!
    	//TriggerRemoveAction(GetTriggeringTrigger(),CountdownPlayTime)
    endfunction
    
    private function StartCountdownPlayTime takes nothing returns nothing
    	local trigger tgCdPlayTime = CreateTrigger()
    	call TriggerAddAction(tgCdPlayTime, function CountdownPlayTime)
    	
    	call TriggerExecute(tgCdPlayTime)
    endfunction
    
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
        	// calculate play time
        	set rPlayTime = rPlayTime/iSelects
        	debug call BJDebugMsg("Game time is set to " + I2S(R2I(rPlayTime)) + " minutes.")
        	call dgClicked.destroy()
        	// show play time dialog
        	call StartCountdownPlayTime()
        endif
        set btClicked = null
        return false 
    endfunction
    
	private function AppendHotkey takes string source, string hotkey returns string
        return "|cffffcc00[" + hotkey + "]|r " + source
    endfunction

    private function ShowVoteDialog takes nothing returns nothing 
    	local Dialog dgSelection = Dialog.create()
        local Human human = Human[Human.first]
        
        debug call BJDebugMsg("ShowVoteDialog!")
        
        set dgSelection.title  = CST_STR_PLAYTIME_TITLE
        set btsSelect[0] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_40,    "A"), 'A')
        set btsSelect[1] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_50,    "B"), 'B')
        set btsSelect[2] = dgSelection.addButton(AppendHotkey(CST_STR_PLAYTIME_60,    "C"), 'C')
        
        // register callback
        call dgSelection.registerClickEvent(Condition(function DialogEvent))
        // only display dialog to human player
        loop
        	debug call BJDebugMsg("ShowVoteDialog to player:" + GetPlayerName(human.get))
        	call dgSelection.display(human.get, true)
        	set human = human.next
        	exitwhen human.end
        endloop
        //call dgSelection.displayAll(true)
        
    endfunction
    
    function TimeVote takes nothing returns nothing
    	debug call BJDebugMsg("Vote for play time!")
    	call DestroyTimer(GetExpiredTimer())
    	call ShowVoteDialog()
    endfunction
    
    private function init takes nothing returns nothing
    	// set iMultiple to 1 seconds in debug mode to fast debugging
    	set iMultiple = 1
    	// dialogs can't be displayed on init and the scope's init-func is run during init
    	// so we need to use TimerStart to call functions which need to show dialog
    	//call TimerStart(CreateTimer(), 0, false, function TimeVote)
    endfunction 
    
endlibrary