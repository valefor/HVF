library TimeManager initializer init/* v0.0.1 Xandria
*************************************************************************************
*     HVF Time Management library which provides game time utils
*************************************************************************************
*
*   */ uses /*
*   
*       */ Dialog   /*
*       */ Core     /*  core functions must be loaded first
*       */ Event    /*
*       */ TimerUtils /*
*       */ TimerPool/*
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
        readonly static TimerPointer pt1s
        readonly static TimerPointer pt10s
        readonly static TimerPointer pt15s
        readonly static TimerPointer pt30s
        readonly static TimerPointer pt60s
        
        // Onetime Timers(OT)
        readonly static TimerPointer otGameStart
        readonly static TimerPointer otSelectHero
        readonly static TimerPointer otDetectionOn
        readonly static TimerPointer otDetectionOff
        readonly static TimerPointer otPlayTimeOver
        
        // !DEPRECATED
        static method getTimer takes real timeout returns TimerPointer
            if timeout == CST_OT_SelectHero then
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
        
        // Format any reals to OT timer count, something like 10.01, xx.01
        static method formatOtTimeout takes real c returns real
            local integer n = R2I(c/1)
            return I2R(n)+0.01
        endmethod
        
        static method isPeriodicTimer takes real timeout returns boolean
            local integer n = R2I(timeout/1)
            if (timeout - n) != 0.00 then
                //debug call BJDebugMsg("Is not a periodic timer")
                return false
            endif
            return true
        endmethod
        
        private static method onExpire takes nothing returns nothing
            local TimerPointer tp = TimerPool[GetExpiredTimer()]
            //debug call BJDebugMsg("Timer timeout")
            /*
            if tp == pt1s then
                debug call BJDebugMsg("Periodic timer(1s) timeout")
            elseif tp == pt10s then
                debug call BJDebugMsg("Periodic timer(10s) timeout")
            elseif tp == pt15s then
                debug call BJDebugMsg("Periodic timer(15s) timeout")
            elseif tp == pt30s then
                debug call BJDebugMsg("Periodic timer(30s) timeout")
            elseif tp == pt60s then
                debug call BJDebugMsg("Periodic timer(60s) timeout")
            endif
            */
            call TriggerEvaluate(tp.trigger)
            
            // If timer is not periodic timer, recycle it
            if not isPeriodicTimer(tp.timeout) then
                call tp.destroy()
            endif
        endmethod
        
        // It's used by other module to register actions at timer expired
        static method register takes real timeout, boolexpr action returns triggercondition
            return thistype.getTimer(timeout).register(action)
        endmethod
        
        static method start takes nothing returns nothing
            // PT
            call TimerStart(thistype.pt10s.timer, thistype.pt10s.timeout, true, function thistype.onExpire)
            call TimerStart(thistype.pt15s.timer, thistype.pt15s.timeout, true, function thistype.onExpire)
            call TimerStart(thistype.pt30s.timer, thistype.pt30s.timeout, true, function thistype.onExpire)
            call TimerStart(thistype.pt60s.timer, thistype.pt60s.timeout, true, function thistype.onExpire)
            
            // OT
            call TimerStart(thistype.otGameStart.timer, 0.01, false, function thistype.onExpire)
            call TimerStart(thistype.otSelectHero.timer, thistype.otSelectHero.timeout, false, function thistype.onExpire)
            call TimerStart(thistype.otDetectionOn.timer, thistype.otDetectionOn.timeout, false, function thistype.onExpire)
            // Detection off time depends on play time
            set thistype.otDetectionOff.timeout = thistype.otPlayTimeOver.timeout - thistype.otDetectionOn.timeout + 0.01
            call TimerStart(thistype.otDetectionOff.timer, thistype.otDetectionOff.timeout, false, function thistype.onExpire)
            call TimerStart(thistype.otPlayTimeOver.timer, thistype.otPlayTimeOver.timeout, false, function thistype.onExpire)
            
            /*
            debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otSelectHero.timeout)+ ") start")
            debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otDetectionOn.timeout)+ ") start")
            debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otDetectionOff.timeout)+ ") start")
            debug call BJDebugMsg("Onetime timer(" +R2S(thistype.otPlayTimeOver.timeout)+ ") start")
            */
        endmethod
        
        private static method onInit takes nothing returns nothing
            // set VAR_INT_PlayTimeDelta to 1 seconds in debug mode to fast debugging
            debug set VAR_INT_PlayTimeDelta = 1
            
            // PT
            set pt1s = TimerPointer.create()
            set pt10s = TimerPointer.create()
            set pt15s = TimerPointer.create()
            set pt30s = TimerPointer.create()
            set pt60s = TimerPointer.create()
            // !Don't forget to set timeout for these timers
            set pt1s.timeout = CST_PT_1s
            set pt10s.timeout = CST_PT_10s
            set pt15s.timeout = CST_PT_15s
            set pt30s.timeout = CST_PT_30s
            set pt60s.timeout = CST_PT_60s
            
            // OT
            set otGameStart = TimerPointer.create()
            set otSelectHero = TimerPointer.create()
            set otDetectionOn = TimerPointer.create()
            set otDetectionOff = TimerPointer.create()
            set otPlayTimeOver = TimerPointer.create()
            // !Don't forget to set timeout for these timers
            set otSelectHero.timeout = CST_OT_SelectHero
            set otDetectionOn.timeout = thistype.formatOtTimeout(CST_OT_Detect*VAR_INT_PlayTimeDelta)
            set otPlayTimeOver.timeout = thistype.formatOtTimeout(CST_OT_PlayTime*VAR_INT_PlayTimeDelta)
        endmethod
        
    endstruct
    
    struct PlayTime extends array
        private static Dialog voteDialog
        private static timerdialog remainedTimeDialog
        //private static Event TIMEOVER
        //private static button array selectionBts
        private static real playTime = 0.0
        private static integer selects = 0
    
        
        /*
        static method timeover takes nothing returns nothing
            call TIMEOVER.fire()
        endmethod
        
        static method registerTimeoverEvent takes boolexpr c returns nothing
            call TIMEOVER.register(c)
        endmethod
        */
        static method yellowAlert takes nothing returns boolean
            return false
        endmethod
        
        static method redAlert takes nothing returns boolean
            debug call BJDebugMsg("10 seconds left!")
            call TimerDialogSetTitleColor(thistype.remainedTimeDialog, 255, 0, 0, 10)
            return false
        endmethod
        
        // Static Methods
        private static method showTimerDialog takes nothing returns nothing
            //local timer tmCountDown = NewTimer()
            //local SimpleTrigger tgCdPlayTime = SimpleTrigger.get(GetTriggeringTrigger())
            set thistype.remainedTimeDialog = CreateTimerDialog(TimerManager.otPlayTimeOver.timer)
            
            // Show Timer Dialog
            //call TimerStart(tmCountDown, R2I(thistype.playTime*iMultiple), false, timeover)
            call TimerDialogSetTitle(thistype.remainedTimeDialog, CST_STR_REMAINED_TIME)
            call TimerDialogSetTimeColor(thistype.remainedTimeDialog, 0, 255, 0, 20)
            call TimerDialogDisplay(thistype.remainedTimeDialog, true)
            
            // call PolledWait( (R2I(thistype.playTime)-10) * iMultiple )
            // do something here

            // call PolledWait( 10 * iMultiple )
            // timeout
            /*
            debug call BJDebugMsg("Timeout!")
            call TimerDialogDisplay(dgRemainedTime, false)
            call DestroyTimerDialog(dgRemainedTime)
            call ReleaseTimer(tmCountDown)
            set dgRemainedTime = null
            set tmCountDown = null
            call tgCdPlayTime.destroy()
            */ 
        endmethod
        
        private static method gameStart takes nothing returns nothing
            // If we need to use such PolledWait/PauseGame game time functions, 
            // trigger action is the only choice
            // local SimpleTrigger tgCdPlayTime = SimpleTrigger.create()
            // call tgCdPlayTime.addAction(function thistype.countdownPlayTime)
            // call tgCdPlayTime.execute()
            // Start play time countdown
            debug call BJDebugMsg("Game Start!")
            
            // Set timer timeout 
            set TimerManager.otPlayTimeOver.timeout = TimerManager.formatOtTimeout(thistype.playTime*VAR_INT_PlayTimeDelta)
            call TimerManager.otDetectionOff.register(Filter(function thistype.redAlert))
            // Create and show timer dialog
            call thistype.showTimerDialog()

            // Start Timers
            call TimerManager.start()
        endmethod
        
        // callback for clicking vote buttons
        private static method onVote takes nothing returns boolean
            local Dialog      dgClicked  = Dialog.getClickedDialog()
            local button      btClicked   = Dialog.getClickedButton()
            
            //debug call BJDebugMsg("Dialog button clicked!!!")
            set thistype.selects = thistype.selects + 1
            if btClicked == btsSelect[0] then
                set thistype.playTime = thistype.playTime + 40.0
            elseif btClicked == btsSelect[1] then
                set thistype.playTime = thistype.playTime + 50.0
            elseif btClicked == btsSelect[2] then
                set thistype.playTime = thistype.playTime + 60.0
            endif
    
            //debug call BJDebugMsg("Hide dialog to player")
            // hide dialog to player, will destroy it later
            call dgClicked.display(GetTriggerPlayer(), false)        
            
            //debug call BJDebugMsg("Vote check")
            // if voting is over, countdown play time
            if thistype.selects == Human.count then
                //debug call BJDebugMsg("All players have voted!")
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
        static method onVoteTimeExpired takes nothing returns boolean
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
            
            //debug call BJDebugMsg("ShowVoteDialog!")
            
            set voteDialog = Dialog.create()
            set voteDialog.title  = CST_STR_PLAYTIME_TITLE
            set btsSelect[0] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_40,    "A"), 'A')
            set btsSelect[1] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_50,    "B"), 'B')
            set btsSelect[2] = voteDialog.addButton(AppendHotkey(CST_STR_PLAYTIME_60,    "C"), 'C')
        endmethod
        
        private static method startVote takes nothing returns nothing
            local Human human = Human[Human.first]
            //debug call BJDebugMsg("Vote for play time!")
            call DestroyTimer(GetExpiredTimer())
        
            // Create vote dialog
            call thistype.createVoteDialog()
            
            // Register callback for clicking dialog.
            call thistype.voteDialog.registerClickEvent(Condition(function thistype.onVote))
            
            // Set timeout for vote
            call TimerStart(CreateTimer(), CST_OT_Vote, false, function thistype.onVoteTimeExpired)

            // Only display dialog to human player
            debug call BJDebugMsg("Total number players:" + I2S(Human.count))
            loop
                debug call BJDebugMsg("ShowVoteDialog to player:" + GetPlayerName(human.get))
                call voteDialog.display(human.get, true)
                set human = human.next
                exitwhen human.end
            endloop
        endmethod
        
        static method vote takes nothing returns nothing
            // dialogs can't be displayed on init and the scope's init-func is run during init
            // so we need to use TimerStart to call functions which need to show dialog
            debug call BJDebugMsg("Play.vote")
            call TimerStart(CreateTimer(), 0, false, function thistype.startVote)
            // register a onetime timer to terminate voting after 15 seconds
        endmethod
        
        private static method onInit takes nothing returns nothing
        endmethod
    endstruct
    
    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/
    private function init takes nothing returns nothing
        // dialogs can't be displayed on init and the scope's init-func is run during init
        // so we need to use TimerStart to call functions which need to show dialog
        //call TimerStart(CreateTimer(), 0, false, function TimeVote)
    endfunction 
    
endlibrary
