library GameManager initializer init /*
********************************************************************************
* 	Library for game control
*
********************************************************************************
*
*   */ uses /*
*   
*       */ ForceManager /*
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
            call SetPlayerTechMaxAllowed(GetLocalPlayer(), CST_INT_MAX_HEROS, CST_INT_TECHID_HERO)
	        
            debug call BJDebugMsg("Initializing game...")
	        call TriggerSleepAction(2.0)
	        debug call BJDebugMsg("Initializing finished...")
	        debug call BJDebugMsg("Waiting host for chosing game mode...")
	        if GetHostPlayer() == GetLocalPlayer() then
	            call DisplayTextToPlayer(GetLocalPlayer(), "Please select game mode in 10 seconds")
	        else
	            call DisplayTextToPlayer(GetLocalPlayer(), "Waiting host for chosing game mode...")
	        endif
	        call TriggerSleepAction(10.0)
	        // Disable host commands
	        if GetHostPlayer() == GetLocalPlayer() then
	            call ShufflePlayerCmd.disable()
	        endif
	        // Enable game utils commands
	        BJDebugMsg("Please vote for play time...")
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