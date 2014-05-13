library GameManager initializer init /*
********************************************************************************
* 	Library for game control
*       Currently supported game mode:
*           -sp : shuffle player
*           -nv : no voting
*           -ni : no infighting
*
********************************************************************************
*
*   */ uses /*
*
*       */ UnitManager /*
*       */ ItemManager /*
*       */ Commands /*
*
*******************************************************************************/
	/***************************************************************************
	* Globals
	***************************************************************************/

	/***************************************************************************
	* Prerequisite Functions(private only)
	***************************************************************************/

	/***************************************************************************
	* Modules
	***************************************************************************/
	
	/***************************************************************************
	* Structs
	***************************************************************************/
	struct Game extends array
		    //private static method gameInfo
		// Perform action accoding to selected game mode    
		private static method performGameMode takes nothing returns nothing
		    local string msg = ""
		    local boolean b = false
		    if Params.flagGameModeNm then
		        set msg = msg + MSG_HostSelected + " " + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameModeNm)
		    endif
		    
		    if Params.flagGameModeSp then
		        set msg = msg + MSG_HostSelected + " " + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameModeSp)
		    endif
		    
		    set msg = msg + ", " + CST_STR_GameParam + " "
		    if Params.flagGameParamNv then
		        set msg = msg + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameParamNv)
		        set b = true
		    endif
		    
		    if Params.flagGameParamNi then
		        if b then
		            set msg = msg + "/"
		        endif
		        set msg = msg + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameParamNi)
		        set b = true
		    endif
		    
		    set msg = msg + "\n\n"
		    // Save mode msg for later use
		    set GameInfoCmd.msg = msg
		    
		    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Beaware, msg)
		    // Shuffle players
		    if Params.flagGameModeSp then
		        call ShufflePlayer()
		    endif
		    
		endmethod
		
		private static method adjustMapSize takes nothing returns nothing
		    local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
	        local integer mapSize = Hunter.count - 1
		    /*
	        if Hunter.count < 1 then
	            Farmer.win()
	        endif
	        
	        if Farmer.count < 1 then
	            Hunter.win()
	        endif
	        */
	        if mapSize < 0 then
	            set mapSize = 0
	        endif
	        
	        // Resize map
	        loop
	            exitwhen ap.end
	            // Adjust map size upon hunters number
	            call Map.resize(ap.get,mapSize)
	            set ap = ap.next
	        endloop
	        
		endmethod
		
		// DO NOT MODIFY THIS METHOD UNLESS YOU KNOW WHAT YOU ARE DOING
	    static method initialize takes nothing returns nothing
	        call FogEnable(false)
	        call FogMaskEnable(false)
            //call BJDebugMsg(MSG_GameInitializing)
            call ShowMsgToAll(MSG_GameInitializing)
	        call TriggerSleepAction(2.0)
	        // For better performance, generate begin items/neutral unit at beginning
	        //call UnitManager.createBeiginNeutralAggrUnits()
	        //call ItemManager.createBeginMapItems()
	        //call BJDebugMsg(MSG_GameInitializingDone)
	        call ShowMsgToAll(MSG_GameInitializingDone)
	        //debug call BJDebugMsg("Waiting host for chosing game mode...")
	        
	        if GetHostPlayer() == GetLocalPlayer() then
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_YouAreHost)
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_PlsSelectGameMode)
	        else
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_HostIs + COLOR_YELLOW + GetPlayerName(GetHostPlayer())+ "|r")
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_WaitHostSelectGameMode)
	        endif

	        call TriggerSleepAction(10.0)

	        call thistype.performGameMode()
	        
	        // Disable game mode commands
	        call InvalidGameModeCommands()
	        
	        // Shuffle players
	        /*
	        if Params.flagGameModeSp then
		        call ShufflePlayer()
		    endif
		    */
		    
		    // Adjust map size, put it here since it relies on numbers of hunters
		    call thistype.adjustMapSize()
		    
		    // For better performance, generate begin items/neutral unit at beginning
	        // Do this after map adjustion since these funcions need to know playerable
	        // bound
		    call UnitManager.createBeginNeutralAggrUnits()
	        call ItemManager.createBeginMapItems()

		    // Enable game utils commands
		    call EnableGameUtilCommands()
		    
		    // Start event listener
		    call EventManager.listen()

		endmethod
	    
	    static method start takes nothing returns nothing
	        call FogEnable(true)
	        call FogMaskEnable(true)

	        call TriggerSleepAction(2.0)
	        if not Params.flagGameParamNv then
                // Vote for play time
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Tips, MSG_VoteForPlayTime)
                call PlayTime.vote()
            else
                // No need to vote for play time, start game
                call PlayTime.setTime(CST_OT_PlayTime)
                call PlayTime.countdownStart()
            endif
	        
            // Init Farmer/Hunter units
	    endmethod
	endstruct
	/***************************************************************************
	* Common Use Functions
	***************************************************************************/
	
	/***************************************************************************
	* Functions that would be called on event fired
	***************************************************************************/
	
	/***************************************************************************
	* Functions that would be called on timer expired
	***************************************************************************/
	
	/***************************************************************************
	* Library Initiation
	***************************************************************************/
	private function init takes nothing returns nothing
	endfunction
endlibrary