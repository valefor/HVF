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
*       */ TimeManager /*
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
	
	    static method initialize takes nothing returns nothing
	        // Set max allowed hero to 1
	        // !!!! Here GetLocalPlayer would cause desync !!!!
            //call SetPlayerTechMaxAllowed(GetLocalPlayer(), CST_INT_TECHID_HERO, CST_INT_MAX_HEROS)
	        
            debug call BJDebugMsg("Initializing game...")
	        call TriggerSleepAction(2.0)
	        debug call BJDebugMsg("Initializing finished...")
	        //debug call BJDebugMsg("Waiting host for chosing game mode...")
	        
	        if GetHostPlayer() == GetLocalPlayer() then
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "Please select game mode in 10 seconds")
	        else
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 10, "Waiting host:" +GetPlayerName(GetHostPlayer())+ " for chosing game mode...")
	        endif

	        call TriggerSleepAction(5.0)
	        debug call BJDebugMsg("Debug1")
	        
	        // Disable host commands
	        call ShufflePlayerCmd.cmd.enable(false)
	        
	        // Enable game utils commands
	        call BJDebugMsg("Please vote for play time...")
	        // Vote for play time
	        call PlayTime.vote()
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