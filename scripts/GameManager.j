library GameManager initializer init /*
********************************************************************************
* 	Library for game control
*       Currently supported game mode:
*           -sp : shuffle player
*           -dr : death race
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
		    local string msg = MSG_HostSelected
		    local boolean b = false
		    if Params.flagGameModeNm then
		        set msg = msg + " " + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameModeNm)
		    endif
		    
		    if Params.flagGameModeSp then
		        set msg = msg + " " + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameModeSp)
		        set b = true
		    endif
		    
		    if Params.flagGameModeDr then
		        if b then
		            set msg = msg + "/"
		        endif
		        set msg = msg + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameModeDr)
		        set b = true
		    endif
		    
		    set b = false
		    set msg = msg + ", " + CST_STR_GameParam + " "
		    if Params.flagGameParamNv then
		        set msg = msg + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameParamNv)
		        set b = true
		    endif
		    
		    if Params.flagGameParamNa then
		        if b then
		            set msg = msg + "/"
		        endif
		        set msg = msg + ARGB(COLOR_ARGB_BLUE).str(CST_STR_GameParamNa)
		        set b = true
		    endif
		    
		    set msg = msg + "\n\n"
		    // Save mode msg for later use
		    set ShowGameInfoCmd.msg = msg
		    
		    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Beaware, msg)
		    // Shuffle players
		    if Params.flagGameModeSp then
		        call ShufflePlayer()
		    endif
		    
		    // Last perform game parameters
		    call performGameParam()
		    
		endmethod
		
		// Perform action accoding to selected game parameters    
		private static method performGameParam takes nothing returns nothing
		    // Adjust map size, put it here since it relies on numbers of hunters
		    if Params.flagGameParamNa then
		        call thistype.adjustMapSize(Map.mapSize)
		    else
		        call thistype.adjustMapSize(Hunter.count - 1)
		    endif
		    
		    // Setup game time, start game 
		    if not Params.flagGameParamNv then
                // Vote for play time
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Tips, MSG_VoteForPlayTime)
                call PlayTime.vote()
            else
                // No need to vote for play time, start game
                call PlayTime.setTime(CST_OT_PlayTime)
                call PlayTime.countdownStart()
            endif
		endmethod
		
		// Show welcome to every players
		private static method showWelcome takes nothing returns nothing
		    call ShowDurMsgToAll(CST_STR_HVFAdv, CST_MSGDUR_Important)
		    
		    // Check If we are in 11 platform
	        if YDWEPlatformIsInPlatform() then
	            call ShowMsgToAll(ARGB(COLOR_ARGB_LIGHT_PURPLE).str(CST_STR_11Declaration))
	        else
	            call ShowMsgToAll(ARGB(COLOR_ARGB_RED).str(CST_STR_Non11Declaration))
	        endif
		endmethod
		
		// Show begin message to every players
		private static method showBeginMsg takes nothing returns nothing
		    local Hunter h = Hunter[Hunter.first]
		    local Farmer f = Farmer[Farmer.first]
		    local string tag = "[*" + ARGB(CST_COLOR_Beaware).str(MSG_Beaware) + "*]"
		    loop
                exitwhen f.end
                call DisplayTimedTextToPlayer(f.get, 0, 0, CST_MSGDUR_Beaware, MSG_GameWinTipsFarmer)
                call DisplayTimedTextToPlayer(f.get, 0, 0, CST_MSGDUR_Beaware, tag+MSG_GameStartTipsFarmer)
                set f = f.next
            endloop
            
            loop
                exitwhen h.end
                call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Beaware, MSG_GameWinTipsHunter)
                call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Beaware, tag+MSG_GameStartTipsHunter)
                set h = h.next
            endloop
		endmethod
		
		private static method adjustMapSize takes integer size returns nothing
		    local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
		    /*
	        if Hunter.count < 1 then
	            Farmer.win()
	        endif
	        
	        if Farmer.count < 1 then
	            Hunter.win()
	        endif
	        */
	        if size < 0 then
	            set size = 0
	        endif
	        
	        // Resize map
	        loop
	            exitwhen ap.end
	            // Adjust map size upon hunters number
	            call Map.resize(ap.get,size)
	            set ap = ap.next
	        endloop
	        
		endmethod
		
		// DO NOT MODIFY THIS METHOD UNLESS YOU KNOW WHAT YOU ARE DOING
	    static method initialize takes nothing returns nothing
	        call FogEnable(false)
	        call FogMaskEnable(false)
            call ShowMsgToAll(MSG_GameInitializing)
	        call TriggerSleepAction(2.0)
	        call ShowMsgToAll(CST_STR_Version+CST_STR_VersionTag+ARGB(CST_COLOR_Beaware).str(CST_STR_VersionMain+"."+CST_STR_VersionSub))
	        call TriggerSleepAction(2.0)

	        call ShowMsgToAll(MSG_GameInitializingDone)
	        //debug call BJDebugMsg("Waiting host for chosing game mode...")
	        
	        if GetHostPlayer() == GetLocalPlayer() then
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_YouAreHost)
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_PlsSelectGameMode)
	            call ShowModeCmd.onCommand()
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, ShowModeCmd.msg)
	            
	        else
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_HostIs + COLOR_YELLOW + GetPlayerName(GetHostPlayer())+ "|r")
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_WaitHostSelectGameMode)
	        endif

	        call TriggerSleepAction(10.0)

	        call thistype.performGameMode()
	        
	        // Disable game mode commands
	        call InvalidGameModeCommands()
	        
		    // For better performance, generate begin items/neutral unit at beginning
	        // Do this after map adjustion since these funcions need to know playerable
	        // bound
		    call UnitManager.createBeginNeutralAggrUnits()
	        call ItemManager.createBeginMapItems()

		    // Enable game utils commands
		    call EnableGameUtilCommands()
		    
		    // Start event listener
		    call EventManager.listen()
		    
		    // Game start, show welcome msg
		    call thistype.showWelcome()

		endmethod
	    
	    static method start takes nothing returns nothing
	        call FogEnable(true)
	        call FogMaskEnable(true)

	        call TriggerSleepAction(10.0)
	        
	        call showBeginMsg()
	        // Last perform game parameters
		    // call performGameParam()
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