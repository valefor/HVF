library Commands initializer init /* v0.0.1 by Xandria
***********************************************************************************************
*
*   HVF Command System.
*
************************************************************************************************
*
*   */ uses /*
*   
*       */ ChatCommand  /*  hiveworkshop.com/forums/submissions-414/system-chatcommand-219132/#post2181374
*       */ EventManager /* 
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
    /* ==============================Host command============================ */
	// *** Super Commands
	private struct KickPlayerCmd extends array
        readonly static constant string CHAT_COMMAND = "kick"
        
        static method onCommand takes nothing returns nothing
            local string prompt = MSG_KickPlayerClaim
            local integer playerNo = S2I(StringStrip(ChatCommand.eventData," "))
            local Hunter h = Hunter[Hunter.first]
            local Farmer f = Farmer[Farmer.first]
            debug call BJDebugMsg("OnCommand('-kick') callback")
            if GetTriggerPlayer() != GetHostPlayer() then
                return
            endif
            
            if StringStrip(ChatCommand.eventData," ") == "" or playerNo == 0 then
                set prompt = prompt + MSG_SelectNumberToKick
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
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal,prompt)
            else
                // Host can't kick himself
                if Player(playerNo-1) != GetHostPlayer() then
                    call BJDebugMsg(COLOR_RED + GetPlayerName(Player(playerNo-1)) + "|r " + MSG_HasBeenKicked)
                    //call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,60,"Hello "+ ChatCommand.eventData)
                    call CustomDefeatBJ(Player(playerNo-1), MSG_YouHaveBeenKicked)
                else 
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantKickYourself)
                endif
            endif
            // disable this command
            // call ChatCommand.eventCommand.enable(false)
        endmethod
    
        //implement ChatCommandModule
    endstruct
    
    // *** Game Mode Commands
    struct ShufflePlayerCmd extends array
        readonly static constant string CHAT_COMMAND = "sp"
        static ChatCommand cmd
        static boolean valid = true
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-sp') callback")

            // Only do shuffling when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                if not thistype.valid then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantSelectGameMode)
                    call ChatCommand.eventCommand.enable(false)
                    return
                endif

                //call BJDebugMsg(MSG_ShufflePlayerModeSelected)
                call ShowMsgToAll(MSG_HostSelected+ARGB(COLOR_ARGB_LIGHT_BLUE).str(CST_STR_GameModeSp)+", "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameModeSpIntro))
                
                set Params.flagGameModeNm = false
                set Params.flagGameModeSp = true
                // this is a one shoot command, disable this command from now
                call ChatCommand.eventCommand.enable(false)
            endif
        endmethod
    endstruct
    
    // *** Game Mode Commands
    struct DeathRaceCmd extends array
        readonly static constant string CHAT_COMMAND = "dr"
        static ChatCommand cmd
        static boolean valid = true
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-dr') callback")

            // Only do shuffling when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                if not thistype.valid then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantSelectGameMode)
                    call ChatCommand.eventCommand.enable(false)
                    return
                endif

                //call BJDebugMsg(MSG_ShufflePlayerModeSelected)
                call ShowMsgToAll(MSG_HostSelected+ARGB(COLOR_ARGB_LIGHT_BLUE).str(CST_STR_GameModeDr)+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameModeDrIntro))
                
                set Params.flagGameModeNm = false
                set Params.flagGameModeDr = true
                // this is a one shoot command, disable this command from now
                call ChatCommand.eventCommand.enable(false)
            endif
        endmethod
    endstruct

    // *** Game Params Commands
    struct NoAdjustCmd extends array
        readonly static constant string CHAT_COMMAND = "na"
        static ChatCommand cmd
        static boolean valid = true
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-na') callback")

            // Only perform this command when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                if not thistype.valid then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantSelectGameMode)
                    call ChatCommand.eventCommand.enable(false)
                    return
                endif
                set Params.flagGameParamNa = true
                // this is a one shoot command, disable this command from now
                call ChatCommand.eventCommand.enable(false)
            endif
        endmethod
    endstruct
    
    struct NoVotingCmd extends array
        readonly static constant string CHAT_COMMAND = "nv"
        static ChatCommand cmd
        static boolean valid = true
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-nv') callback")

            // Only perform this command when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                if not thistype.valid then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantSelectGameMode)
                    call ChatCommand.eventCommand.enable(false)
                    return
                endif
                set Params.flagGameParamNv = true
                // this is a one shoot command, disable this command from now
                call ChatCommand.eventCommand.enable(false)
            endif
        endmethod
    endstruct
    
    struct NoInfightCmd extends array
        readonly static constant string CHAT_COMMAND = "ni"
        static ChatCommand cmd
        static boolean valid = true
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-ni') callback")

            // Only perform this command when host player order this command
            if GetTriggerPlayer() == GetHostPlayer() then
                if not thistype.valid then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_CantSelectGameMode)
                    call ChatCommand.eventCommand.enable(false)
                    return
                endif
                
                call EventManager.forbidInfighting()
                set Params.flagGameParamNi = true
                // this is a one shoot command, disable this command from now
                call ChatCommand.eventCommand.enable(false)
            endif
        endmethod
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
    
    /* =============================Normal command=========================== */
    // *** Utils command(every one)
    struct ShowGameInfoCmd extends array
        readonly static constant string CHAT_COMMAND = "gi"
        static string msg = ""
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-gi') callback")

            call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, MSG_HostIs + ARGB(COLOR_ARGB_RED).str(GetPlayerName(GetHostPlayer())) + "\n")
            call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, msg)
            if Hunter.contain(GetTriggerPlayer()) then
                
                if Hunter[GetPlayerId(GetTriggerPlayer())].isRandomHero then
                    call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, CST_STR_HunterRandomBonus+CST_STR_HunterRandomBonusContent+"\n")
                endif
            else
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, ARGB(COLOR_ARGB_PURPLE).str(CST_STR_HeroChar))
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, Farmer[GetPlayerId(GetTriggerPlayer())].heroIntro+"\n\n")
            endif
        endmethod
    endstruct
    
    struct ShowModeCmd extends array
        readonly static constant string CHAT_COMMAND = "sm"
        static string msg = CST_STR_GameModeInfo
        private static boolean isMsgInited = false
                                                                                          
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-sm') callback")
            if not isMsgInited then
                call initMsg()
            endif
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, CST_MSGDUR_Normal, thistype.msg)
        endmethod
        
        private static method initMsg takes nothing returns nothing
            set msg = msg + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-sp")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameModeSpIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-dr")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameModeDrIntro) + "\n"
            set msg = msg + "\n\n" + CST_STR_GameParamInfo + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-na")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameParamNaIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-nv")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameParamNvIntro) + "\n"
            
            set isMsgInited = true
        endmethod
    endstruct
    
    struct ShowHelpCmd extends array
        readonly static constant string CHAT_COMMAND = "help"
        static string msg = CST_STR_GameUtil
        private static boolean isMsgInited = false

        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-help') callback")
            if not isMsgInited then
                call initMsg()
            endif
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, CST_MSGDUR_Normal, thistype.msg)
        endmethod
        
        private static method initMsg takes nothing returns nothing
            set msg = msg + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-help")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameUtilHIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-gi")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameUtilGiIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-sa")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameUtilSaIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-se")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameUtilSeIntro) + "\n"
            set msg = msg + "    " + ARGB(COLOR_ARGB_LIGHT_BLUE).str("-sm")+": "+ARGB(COLOR_ARGB_GREEN).str(CST_STR_GameUtilSmIntro) + "\n"

            set isMsgInited = true
        endmethod
    endstruct
    
    struct ShowAllyInfoCmd extends array
        readonly static constant string CHAT_COMMAND = "sa"
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-ma') callback")

            if Hunter.contain(GetTriggerPlayer()) then
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, Hunter.info(true))
            else
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, Farmer.info(true))
            endif
        endmethod
    endstruct
    
    struct ShowEnemyInfoCmd extends array
        readonly static constant string CHAT_COMMAND = "se"
        
        static method onCommand takes nothing returns nothing
            debug call BJDebugMsg("OnCommand('-me') callback")

            if Hunter.contain(GetTriggerPlayer()) then
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, Farmer.info(true))
            else
                call DisplayTimedTextToPlayer(ChatCommand.eventPlayer,0,0,CST_MSGDUR_Normal, Hunter.info(true))
            endif
        endmethod
    endstruct
    
    // Call this function to enable game command
    function InstallCommand takes nothing returns nothing
        // Add some test command in debug mode
        static if (DEBUG_MODE) then
            //call ChatCommand.create(RandomHeroCmd.CHAT_COMMAND,function RandomHeroCmd.onCommand)
        endif
    endfunction
    
    /***************************************************************************
	* Common Use Functions
	***************************************************************************/
	function InvalidGameModeCommands takes nothing returns nothing
	    set ShufflePlayerCmd.valid = false
	    set DeathRaceCmd.valid = false
	    set NoVotingCmd.valid = false
	    set NoInfightCmd.valid = false
	    set NoAdjustCmd.valid = false
	endfunction
	
	function EnableGameUtilCommands takes nothing returns nothing
        call ChatCommand.create(KickPlayerCmd.CHAT_COMMAND,function KickPlayerCmd.onCommand)
        call ChatCommand.create(ShowHelpCmd.CHAT_COMMAND,function ShowHelpCmd.onCommand)
        call ChatCommand.create(ShowAllyInfoCmd.CHAT_COMMAND,function ShowAllyInfoCmd.onCommand)
        call ChatCommand.create(ShowEnemyInfoCmd.CHAT_COMMAND,function ShowEnemyInfoCmd.onCommand)
        call ChatCommand.create(ShowGameInfoCmd.CHAT_COMMAND,function ShowGameInfoCmd.onCommand)
        call ChatCommand.create(ShowModeCmd.CHAT_COMMAND,function ShowModeCmd.onCommand)
	endfunction
	
    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
        // The following command need to be set up before game starts
        // Add 'sp' command to host player at beginning 
        set ShufflePlayerCmd.cmd = ChatCommand.create(ShufflePlayerCmd.CHAT_COMMAND,function ShufflePlayerCmd.onCommand)
        set DeathRaceCmd.cmd = ChatCommand.create(DeathRaceCmd.CHAT_COMMAND,function DeathRaceCmd.onCommand)
        set NoVotingCmd.cmd = ChatCommand.create(NoVotingCmd.CHAT_COMMAND,function NoVotingCmd.onCommand)
        set NoInfightCmd.cmd = ChatCommand.create(NoInfightCmd.CHAT_COMMAND,function NoInfightCmd.onCommand)
        set NoAdjustCmd.cmd = ChatCommand.create(NoAdjustCmd.CHAT_COMMAND,function NoAdjustCmd.onCommand)
    endfunction
    
endlibrary
