library Commands initializer init /* v0.0.1 by Adrian
***********************************************************************************************
*
*   HVF Command System.
*
************************************************************************************************
*
*   */ uses /*
*   
*       New*/ ChatCommand    /*  hiveworkshop.com/forums/submissions-414/system-chatcommand-219132/#post2181374
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
	
	private function init takes nothing returns nothing
        call ChatCommand.create("hi",function CommandResponse)
        call ChatCommand.create(HelloCmd.CHAT_COMMAND,function HelloCmd.onCommand)
        call ChatCommand.create(SwapCmd.CHAT_COMMAND,function SwapCmd.onCommand)
        // command "-hi" created
    endfunction
	
endlibrary