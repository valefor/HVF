library TimeManager initializer init/* v0.0.1 Xandria
*************************************************************************************
*     HVF Time Management library which provides game time utils
*************************************************************************************
*
*   */ uses /*
*   
*       */ Dialog /*
*       */ Core   /*  core functions must be loaded first
*       */ TimerUtils /*
*       */ TimerPool /*
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

* ! Care about this:
A dialog pauses the game when testing in single player. Thus why the event doesn't fire.
In multiplayer however, this trigger should work.
*************************************************************************************/

    /***************************************************************************
    * Globals
    ***************************************************************************/    
    globals
        private button array btsSelect
        private integer iMultiple     = 60
    endglobals
    /***************************************************************************
    * Prerequisite Functions(private only)
    ***************************************************************************/

    /***************************************************************************
    * Modules
    ***************************************************************************/
    
    /***************************************************************************
    * Structs
    ***************************************************************************/
    struct TimerManager extends array
        // Periodic Timers(PT)
        private static TimerPointer pt1s
        private static TimerPointer pt10s
        private static TimerPointer pt15s
        private static TimerPointer pt30s
        private static TimerPointer pt60s
        
        // Onetime Timers(OT)
        private static TimerPointer otSelectHero
        
        static method getTimer takes real timeout returns TimerPointer
            if timeout == CST_OT_SELECTHERO then
                return otSelectHero
            elseif timeout == CST_PT_1s then
                return pt10s
            elseif timeout == CST_PT_10s then
                return pt10s
            elseif timeout == CST_PT_15s then
                return pt15s
            elseif timeout == CST_PT_30s then
                return pt30s
            elseif timeout == CST_PT_60s then
                return pt60s
            else
                debug call BJDebugMsg("Unsupported timeout:" + R2S(timeout))
            endif
            return 0
        endmethod
        
        static method setTimerData takes real timeout, integer data returns nothing
            set thistype.getTimer(timeout).count = data
        endmethod
        
        static method getTimerData takes real timeout returns integer
            return thistype.getTimer(timeout).count
        endmethod
        
        private static method onExpire takes nothing returns nothing
            debug call BJDebugMsg("Periodic timer timeout")
            /*
            if TimerPool[GetExpiredTimer()] == pt1s then
                debug call BJDebugMsg("Periodic timer(1s) timeout")
            elseif TimerPool[GetExpiredTimer()] == pt10s then
                debug call BJDebugMsg("Periodic timer(10s) timeout")
            elseif TimerPool[GetExpiredTimer()] == pt15s then
                debug call BJDebugMsg("Periodic timer(15s) timeout")
            elseif TimerPool[GetExpiredTimer()] == pt30s then
                debug call BJDebugMsg("Periodic timer(30s) timeout")
            elseif TimerPool[GetExpiredTimer()] == pt60s then
                debug call BJDebugMsg("Periodic timer(60s) timeout")
            endif
            */
            call TriggerEvaluate(TimerPool[GetExpiredTimer()].trigger)
        endmethod
        
        static method register takes real timeout, boolexpr action returns triggercondition
            return thistype.getTimer(timeout).register(action)
        endmethod
        
        static method start takes nothing returns nothing
            // PT
            call TimerStart(thistype.pt10s.timer, CST_PT_10s, true, function thistype.onExpire)
            call TimerStart(thistype.pt15s.timer, CST_PT_15s, true, function thistype.onExpire)
            call TimerStart(thistype.pt30s.timer, CST_PT_30s, true, function thistype.onExpire)
            call TimerStart(thistype.pt60s.timer, CST_PT_60s, true, function thistype.onExpire)
            
            // OT
            call TimerStart(thistype.otSelectHero.timer, CST_OT_SELECTHERO, false, function thistype.onExpire)
        endmethod
        
        private static method onInit takes nothing returns nothing
            set pt1s = TimerPointer.create()
            set pt10s = TimerPointer.create()
            set pt15s = TimerPointer.create()
            set pt30s = TimerPointer.create()
            set pt60s = TimerPointer.create()
            
            set otSelectHero = TimerPointer.create()
        endmethod
        
    endstruct
    
    struct PlayTime extends array
        private static Dialog voteDialog
        //private static button array selectionBts
        private static real playTime = 0.0
        private static integer selects = 0
    
        // Static Methods
        private static method countdownPlayTime takes nothing returns nothing
            local timer tmCountDown = NewTimer()
            local timerdialog dgRemainedTime = CreateTimerDialog(tmCountDown)
            local SimpleTrigger tgCdPlayTime = SimpleTrigger.get(GetTriggeringTrigger())
            
            // Show Timer Dialog
            call TimerStart(tmCountDown, R2I(thistype.playTime*iMultiple), false, null)
            call TimerDialogSetTitle(dgRemainedTime, CST_STR_REMAINED_TIME)
            call TimerDialogSetTimeColor(dgRemainedTime, 0, 255, 0, 20)
            call TimerDialogDisplay(dgRemainedTime, true)
            
            debug call BJDebugMsg("Start timer countdown!")
            call PolledWait( (R2I(thistype.playTime)-10) * iMultiple )
            // do something here
            debug call BJDebugMsg("10 seconds left!")
            call TimerDialogSetTitleColor(dgRemainedTime, 255, 0, 0, 10)
            
            call PolledWait( 10 * iMultiple )
            
            // timeout
            debug call BJDebugMsg("Timeout!")
            call TimerDialogDisplay(dgRemainedTime, false)
            call DestroyTimerDialog(dgRemainedTime)
            call ReleaseTimer(tmCountDown)
            set dgRemainedTime = null
            set tmCountDown = null
            call tgCdPlayTime.destroy()
            // 
        endmethod
        
        private static method gameStart takes nothing returns nothing
            // Start play time countdown
            local SimpleTrigger tgCdPlayTime = SimpleTrigger.create()
            debug call BJDebugMsg("Game Start!")
            // If we need to use such PolledWait/PauseGame game time functions, 
            // trigger action is the only choice 
            call tgCdPlayTime.addAction(function thistype.countdownPlayTime)
            call tgCdPlayTime.execute()
            
            // Start Timers
            call TimerManager.start()
        endmethod
        
        // callback for clicking vote buttons
        private static method onVote takes nothing returns boolean
            local Dialog      dgClicked  = Dialog.getClickedDialog()
            local button      btClicked   = Dialog.getClickedButton()
            
            debug call BJDebugMsg("Dialog button clicked!!!")
            set thistype.selects = thistype.selects + 1
            if btClicked == btsSelect[0] then
                set thistype.playTime = thistype.playTime + 40.0
            elseif btClicked == btsSelect[1] then
                set thistype.playTime = thistype.playTime + 50.0
            elseif btClicked == btsSelect[2] then
                set thistype.playTime = thistype.playTime + 60.0
            endif
    
            debug call BJDebugMsg("Hide dialog to player")
            // hide dialog to player, will destroy it later
            call dgClicked.display(GetTriggerPlayer(), false)        
            
            debug call BJDebugMsg("Vote check")
            // if voting is over, countdown play time
            if thistype.selects == Human.count then
                debug call BJDebugMsg("All players have voted!")
                // calculate play time
                set thistype.playTime = thistype.playTime/thistype.selects
                debug call BJDebugMsg("Game time is set to " + I2S(R2I(thistype.playTime)) + " minutes.")
                // show play time dialog
                //call StartCountdownPlayTime()
                call thistype.gameStart()
            endif
            debug call BJDebugMsg("Seletes:" + I2S(thistype.selects))
            debug call BJDebugMsg("Total:" + I2S(Human.count))
            set btClicked = null
            return false 
        endmethod
    
        // callback for vote time expired
        private static method onVoteTimeExpired takes nothing returns boolean
            debug call BJDebugMsg("Time for voting is up," + I2S(Human.count - thistype.selects) +" players haven't vote yet!")
            // clean up
            call DestroyTimer(GetExpiredTimer())
            call voteDialog.destroy()
            
            if thistype.selects == Human.count then
                return false
            endif
            
            loop 
                exitwhen thistype.selects == Human.count
                // default play time is 50 minites
                set thistype.playTime = thistype.playTime + 50.0
                set thistype.selects = thistype.selects + 1
            endloop
            // calculate play time
            set thistype.playTime = thistype.playTime/thistype.selects 
            call thistype.gameStart()
            return false
        endmethod
        
        private static method createVoteDialog takes nothing returns nothing
            local Human human = Human[Human.first]
            
            debug call BJDebugMsg("ShowVoteDialog!")
            
            set voteDialog = Dialog.create()
            set voteDialog.title  = CST_STR_PLAYTIME_TITLE
            set btsSelect[0] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_40,    "A"), 'A')
            set btsSelect[1] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_50,    "B"), 'B')
            set btsSelect[2] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_60,    "C"), 'C')
        endmethod
        
        private static method startVote takes nothing returns nothing
            local Human human = Human[Human.first]
            debug call BJDebugMsg("Vote for play time!")
            call DestroyTimer(GetExpiredTimer())
        
            // Create vote dialog
            call thistype.createVoteDialog()
            
            // Register callback for clicking dialog.
            call thistype.voteDialog.registerClickEvent(Condition(function thistype.onVote))
            
            // Set timeout for vote
            call TimerStart(CreateTimer(), CST_OT_VOTE, false, function thistype.onVoteTimeExpired)

            // Only display dialog to human player
            loop
                debug call BJDebugMsg("ShowVoteDialog to player:" + GetPlayerName(human.get))
                call voteDialog.display(human.get, true)
                set human = human.next
                exitwhen human.end
            endloop
        endmethod
        
        public static method vote takes nothing returns nothing
            // dialogs can't be displayed on init and the scope's init-func is run during init
            // so we need to use TimerStart to call functions which need to show dialog
            call TimerStart(CreateTimer(), 0, false, function thistype.startVote)
            // register a onetime timer to terminate voting after 15 seconds
        endmethod
        
        private static method onInit takes nothing returns nothing
            
        endmethod
    endstruct
    
    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/
    // Action for 15s periodic timer
    private function OnTimerExpired15s takes nothing returns nothing
        
    endfunction 
    
    // Action for 60s periodic timer
    private function OnTimerExpired60s takes nothing returns nothing
        // Give free gold to farmer according to times of being killed
        // Give bonus gold to hunter for killing farmers
        // call Force.addGoldToForce(Force.getHunterForce())
    endfunction
    
    private function init takes nothing returns nothing
        // set iMultiple to 1 seconds in debug mode to fast debugging
        debug set iMultiple = 1
        // dialogs can't be displayed on init and the scope's init-func is run during init
        // so we need to use TimerStart to call functions which need to show dialog
        //call TimerStart(CreateTimer(), 0, false, function TimeVote)
    endfunction 
    
endlibrary
