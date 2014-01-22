library TimeManager initializer init/* v0.0.1 Xandria
*************************************************************************************
*     HVF Time Management library which provides game time utils
*************************************************************************************
*
*   */ uses /*
*   
*       */ Dialog   /*
*       */ Core     /*  core functions must be loaded first
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
        readonly static TimerPointer ptBase // The only one that would start as a timer
        readonly static TimerPointer pt10s
        readonly static TimerPointer pt15s
        readonly static TimerPointer pt30s
        readonly static TimerPointer pt60s
        
        // Onetime Timers(OT)
        readonly static TimerPointer otBase // The only one that would start as a timer
        readonly static TimerPointer otSelectHero
        readonly static TimerPointer otDetectionOn
        readonly static TimerPointer otDetectionOff
        readonly static TimerPointer otPlayTimeOver
        
        private static integer ptTickCount
        private static integer otTickCount

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
        
        static method isTimerValid takes TimerPointer tp returns boolean
            return tp.count != -1
        endmethod
        
        static method disableTimer takes TimerPointer tp returns nothing
            set tp.count = -1
        endmethod
        
        private static method onPtExpired takes nothing returns nothing
            set ptTickCount = ptTickCount + 1
            
            debug call BJDebugMsg("Periodic timer timeout")
            if IsIntDividableBy(ptTickCount, thistype.pt60s.count) then
                call TriggerEvaluate(thistype.pt60s.trigger)
            endif
            if IsIntDividableBy(ptTickCount, thistype.pt30s.count) then
                call TriggerEvaluate(thistype.pt30s.trigger)
            endif
            if IsIntDividableBy(ptTickCount, thistype.pt15s.count) then
                call TriggerEvaluate(thistype.pt15s.trigger)
            endif
            if IsIntDividableBy(ptTickCount, thistype.pt10s.count) then
                call TriggerEvaluate(thistype.pt10s.trigger)
            endif
        endmethod
        
        private static method onOtExpired takes nothing returns nothing
            set otTickCount = otTickCount + 1
            
            debug call BJDebugMsg("Single timer timeout")
            if isTimerValid(otPlayTimeOver) and IsIntDividableBy(otTickCount, thistype.otPlayTimeOver.count) then
                call TriggerEvaluate(thistype.otPlayTimeOver.trigger)
                call disableTimer(otPlayTimeOver)
            elseif isTimerValid(otDetectionOff) and IsIntDividableBy(otTickCount, thistype.otDetectionOff.count) then
                call TriggerEvaluate(thistype.otDetectionOff.trigger)
                call disableTimer(otDetectionOff)
            elseif isTimerValid(otDetectionOn) and IsIntDividableBy(otTickCount, thistype.otDetectionOn.count) then
                call TriggerEvaluate(thistype.otDetectionOn.trigger)
                call disableTimer(otDetectionOn)
            elseif isTimerValid(otSelectHero) and IsIntDividableBy(otTickCount, thistype.otSelectHero.count) then
                call TriggerEvaluate(thistype.otSelectHero.trigger)
                call disableTimer(otSelectHero)
            endif
            
            // If timer is not periodic timer, recycle it
            //if not isPeriodicTimer(tp.timeout) then
            //    call tp.destroy()
            //endif
        endmethod
        
        // This should only be call just before timer starts
        private static method setTimerCount takes nothing returns nothing
            set pt10s.count = R2I(pt10s.timeout/CST_PT_base)
            set pt15s.count = R2I(pt15s.timeout/CST_PT_base)
            set pt30s.count = R2I(pt30s.timeout/CST_PT_base)
            set pt60s.count = R2I(pt60s.timeout/CST_PT_base)
            
            // Detection off time depends on play time
            set thistype.otDetectionOff.timeout = thistype.otPlayTimeOver.timeout - thistype.otDetectionOn.timeout + 0.01
            
            set otSelectHero.count = R2I(otSelectHero.timeout/CST_OT_base)
            set otDetectionOn.count = R2I(otDetectionOn.timeout/CST_OT_base)
            set otDetectionOff.count = R2I(otDetectionOff.timeout/CST_OT_base)
            set otPlayTimeOver.count = R2I(otPlayTimeOver.timeout/CST_OT_base)
        endmethod
        
        
        // It's used by other module to register actions at timer expired
        static method register takes real timeout, boolexpr action returns triggercondition
            return thistype.getTimer(timeout).register(action)
        endmethod
        
        static method start takes nothing returns nothing
            call thistype.setTimerCount()
        
            // PT - we select 5s as base periodic timer
            call TimerStart(thistype.ptBase.timer, thistype.ptBase.timeout, true, function thistype.onPtExpired)
           
            // OT - we select 60s as base single timer
            call TimerStart(thistype.otBase.timer, thistype.otBase.timeout, true, function thistype.onOtExpired)
        endmethod
        
        private static method onInit takes nothing returns nothing
            // set VAR_INT_PlayTimeDelta to 1 seconds in debug mode to fast debugging
            // debug set VAR_INT_PlayTimeDelta = 1
            set ptTickCount = 0
            set otTickCount = 0
            
            // PT
            set ptBase = TimerPointer.create()
            set pt10s = TimerPointer.create()
            set pt15s = TimerPointer.create()
            set pt30s = TimerPointer.create()
            set pt60s = TimerPointer.create()
            // !Don't forget to set timeout for these timers
            set ptBase.timeout = CST_PT_5s
            set pt10s.timeout = CST_PT_10s
            set pt15s.timeout = CST_PT_15s
            set pt30s.timeout = CST_PT_30s
            set pt60s.timeout = CST_PT_60s
            
            // OT
            set otBase = TimerPointer.create()
            set otSelectHero = TimerPointer.create()
            set otDetectionOn = TimerPointer.create()
            set otDetectionOff = TimerPointer.create()
            set otPlayTimeOver = TimerPointer.create()
            // !Don't forget to set timeout for these timers
            set otBase.timeout = CST_OT_base
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

        static method setTime takes real t returns nothing
            set thistype.playTime = t
        endmethod
        
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
            call TimerDialogSetTitle(thistype.remainedTimeDialog, CST_STR_RemainedTime)
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
        
        public static method countdownStart takes nothing returns nothing
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
                call thistype.countdownStart()
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
            call thistype.countdownStart()
            return false
        endmethod
        
        private static method createVoteDialog takes nothing returns nothing
            local Human human = Human[Human.first]
            
            //debug call BJDebugMsg("ShowVoteDialog!")
            
            set voteDialog = Dialog.create()
            set voteDialog.title  = CST_STR_PlayTimeTitle
            set btsSelect[0] = voteDialog.addButton(AppendHotkey(CST_STR_PlayTime40m,    "A"), 'A')
            set btsSelect[1] = voteDialog.addButton(AppendHotkey(CST_STR_PlayTime50m,    "B"), 'B')
            set btsSelect[2] = voteDialog.addButton(AppendHotkey(CST_STR_PlayTime60m,    "C"), 'C')
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
            if not Params.flagGameModeNv then
                call TimerStart(CreateTimer(), 0, false, function thistype.startVote)
            else
                // No need to vote for play time, start game
                set thistype.playTime = CST_OT_PlayTime 
                call thistype.countdownStart()
            endif
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
