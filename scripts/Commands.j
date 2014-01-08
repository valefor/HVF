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
*       */ Core         /*  core functions must be loaded first
*       */ HVF          /*  HVF main functionality
*
************************************************************************************************
*
*   SETTINGS
*
*/

/*
************************************************************************************************
*    !Be careful: I recommend to create 'commands' with function, since vJass Compiler will generate such codes

call ExecuteFunc("s__Commands___HelloCmd_ChatCommandModule___onInit")

call ExecuteFunc("s__Commands___SwapCmd_ChatCommandModule___onInit")

call ExecuteFunc("s__Dialog_Alloc___onInit")
call ExecuteFunc("s__Dialog_Dialog__DialogInit___onInit")

    call ExecuteFunc("s__ChatCommand_onInit")

* Notice the "s__ChatCommand_onInit" is the last function call! That means when we try to do onInit on struct HelloCmd, 
* required onInit of struct ChatCommand hasn't been initialized at all...it unsafe i think
*
*******************************************************************************/

    /***************************************************************************
	* Prerequisite Functions(private only)
	***************************************************************************/
    
    
    /***************************************************************************
	* Structs
	***************************************************************************/
    private struct KickPlayerCmd extends array
        readonly static constant string CHAT_COMMAND = "kick"
        
        static method onCommand takes nothing returns nothing
            local string prompt = "声明：\n你正在使用|cffff0000踢人（-kick）|r命令，作者赋予你这项权利是为了提供给大家一个良好的游戏环境，素质游戏从我做起。\n"
            local integer playerNo = S2I(StringStrip(ChatCommand.eventData," "))
            local Hunter h = Hunter[Hunter.first]
            local Farmer f = Farmer[Farmer.first]
            debug call BJDebugMsg("OnCommand('-kick') callback")
            if GetTriggerPlayer() != GetHostPlayer() then
                return
            endif
            
            if StringStrip(ChatCommand.eventData," ") == "" or playerNo == 0 then
                set prompt = prompt + "选择你想踢出的玩家的|cff008000编号|r：\n"
                if Hunter.count > 0 then
                    set prompt = prompt + " " + CST_STR_Hunter + "\n"
                    loop
                        exitwhen h.end
                        if h.get != GetHostPlayer() then
                            set prompt = prompt + "  " + I2S(GetPlayerId(h.get)+1) + " - " + GetPlayerName(h.get) + "\n"
                        endif
                        set h = h.next
                    endloop
                endif
                
                if Farmer.count > 0 then
                    set prompt = prompt + " " + CST_STR_Farmer + "\n"
                    loop
                        exitwhen f.end
                        if f.get != GetHostPlayer() then
                            set prompt = prompt + "  " + I2S(GetPlayerId(f.get)+1) + " - " + GetPlayerName(f.get) + "\n"
                        endif
                        set f = f.next
                    endloop
                endif
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,prompt)
            else
                // Host can't kick himself
                if Player(playerNo-1) != GetHostPlayer() then
                    call BJDebugMsg("Player:" + GetPlayerName(Player(playerNo-1)) + " has been kicked out by host!")
                    //call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hello "+ ChatCommand.eventData)
                    call CustomDefeatBJ(Player(playerNo-1), "You have been kicked out by host")
                endif
            endif
            // disable this command
            // call ChatCommand.eventCommand.enable(false)
        endmethod
    
        //implement ChatCommandModule
    endstruct

    private function CommandResponse takes nothing returns nothing
        //with function 
        local string prompt = "声明：|n你正在使用|cffff0000踢人（-kick）|r命令，作者赋予你这项权利是为了提供给大家一个良好的游戏环境，素质游戏从我做起。|n"
        if StringStrip(ChatCommand.eventData," ") == "" then
            set prompt = prompt + "选择你想踢出的玩家的|cff008000编号|r：|n"
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
    
    struct ShufflePlayerCmd extends array
        readonly static constant string CHAT_COMMAND = "sp"
        static ChatCommand cmd
        
        static method onCommand takes nothing returns nothing
            call BJDebugMsg("OnCommand callback")
            
            // Only do shuffling when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                call BJDebugMsg("ShufflePlayer")
                call ShufflePlayer()
                // this is a one shoot command, disable this command from now
                //call ChatCommand.eventCommand.enable(false)
            endif
            
            
        endmethod
        
        static method disable takes nothing returns nothing
            // disable this command
            call cmd.enable(false)
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
    
    /***************************************************************************
	* Common Use Functions
	***************************************************************************/
	public function DisableHostCommands takes nothing returns nothing
	    call ShufflePlayerCmd.disable()
	endfunction
	
	public function EnableGameUtilCommands takes nothing returns nothing
	endfunction
	
    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
        // The following command need to be set up before game starts
        set ShufflePlayerCmd.cmd = ChatCommand.create(ShufflePlayerCmd.CHAT_COMMAND,function ShufflePlayerCmd.onCommand)
        // Add 'sp' command to host player at beginning
        // !!!! Here GetLocalPlayer would cause desync !!!!
        //if GetLocalPlayer() == GetHostPlayer() then
        //endif
        // command "-kick" created
        call ChatCommand.create(KickPlayerCmd.CHAT_COMMAND,function KickPlayerCmd.onCommand)
    endfunction
    
endlibrary
