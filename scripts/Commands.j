library Commands initializer init /* v0.0.1 by Adrian
***********************************************************************************************
*
*   HVF Command System.
*
************************************************************************************************
*
*   */ uses /*
*   
*       */ ChatCommand  /*  hiveworkshop.com/forums/submissions-414/system-chatcommand-219132/#post2181374
*       */ Core    		/*  core functions must be loaded first
*
************************************************************************************************
*
*   SETTINGS
*
*/

/*
************************************************************************************************
*	!Be careful: I recommend to create 'commands' with function, since vJass Compiler will generate such codes

call ExecuteFunc("s__Commands___HelloCmd_ChatCommandModule___onInit")

call ExecuteFunc("s__Commands___SwapCmd_ChatCommandModule___onInit")

call ExecuteFunc("s__Dialog_Alloc___onInit")
call ExecuteFunc("s__Dialog_Dialog__DialogInit___onInit")

    call ExecuteFunc("s__ChatCommand_onInit")

* Notice the "s__ChatCommand_onInit" is the last function call! That means when we try to do onInit on struct HelloCmd, 
* required onInit of struct ChatCommand hasn't been initialized at all...it unsafe i think
*
************************************************************************************************
*/
	private struct HelloCmd extends array
		readonly static constant string CHAT_COMMAND = "hello"
		
		static method onCommand takes nothing returns nothing
			call BJDebugMsg("OnCommand callbackld")
			if ChatCommand.eventData == "" then
				call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hello Player "+ I2S(ChatCommand.eventPlayerId+1))
			else
				call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hello "+ ChatCommand.eventData)
			endif
			// disable this command
			// call ChatCommand.eventCommand.enable(false)
		endmethod
	
		//implement ChatCommandModule
	endstruct

	private function CommandResponse takes nothing returns nothing
        //with function 
        if ChatCommand.eventData == "" then
            call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hi Player "+ I2S(ChatCommand.eventPlayerId+1))
        else
            call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hi "+ ChatCommand.eventData)
        endif
    endfunction
    
    private struct SwapCmd extends array
		readonly static constant string CHAT_COMMAND = "swap"
		
		static method onCommand takes nothing returns nothing
			call BJDebugMsg("OnCommand callback")
			if ChatCommand.eventData == "" then
				call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Swap Player "+ I2S(ChatCommand.eventPlayerId+1))
			else
				call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Swap "+ ChatCommand.eventData)
			endif
			// disable this command
			// call ChatCommand.eventCommand.enable(false)
		endmethod
	
		// implement ChatCommandModule
	endstruct
	
	private struct ShufflePlayerCmd extends array
		readonly static constant string CHAT_COMMAND = "sp"
		static ChatCommand cmd
		
		static method onCommand takes nothing returns nothing
			call BJDebugMsg("OnCommand callback")
			
			call Force.shufflePlayer()
			
			// this is a one shoot command, disable this command from now
			call ChatCommand.eventCommand.enable(false)
		endmethod
		
		static method disable takes nothing returns nothing
			// disable this
			call ChatCommand.eventCommand.enable(false)
		endmethod
	
		// implement ChatCommandModule
	endstruct
	
	private struct RandomHeroCmd extends array
		readonly static constant string CHAT_COMMAND = "random"
		static ChatCommand cmd
		
		static method onCommand takes nothing returns nothing
			debug call BJDebugMsg("OnCommand('random') callback")
			
			// do something here
			
			// this is a one shoot command, disable this command from now
			call ChatCommand.eventCommand.enable(false)
		endmethod
		
		static method disable takes nothing returns nothing
			// disable this command
			call ChatCommand.eventCommand.enable(false)
		endmethod
	
		// implement ChatCommandModule
	endstruct
	
	// Call this function to enable game command
	function InstallCommand takes nothing returns nothing
		// Add some test command in debug mode
        static if (DEBUG_MODE) then
        	call ChatCommand.create(RandomHeroCmd.CHAT_COMMAND,function RandomHeroCmd.onCommand)
        endif
	endfunction
	
	private function init takes nothing returns nothing
        // The following command need to be set up before game starts
        
        // Add 'sp' command to host player
        if GetLocalPlayer() == GetHostPlayer() then
        	set ShufflePlayerCmd.cmd = ChatCommand.create(ShufflePlayerCmd.CHAT_COMMAND,function ShufflePlayerCmd.onCommand)
        endif
        
        // command "-hi" created
    endfunction
	
endlibrary