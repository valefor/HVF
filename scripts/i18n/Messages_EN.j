globals
    /***************************************************************************
    * Language
    ***************************************************************************/
    constant integer CST_LANG_I18N = CST_LANG_EN
    
    /***************************************************************************
    * Literalization
    ***************************************************************************/
    // For game time voting
    constant string CST_STR_PlayTimeTitle= "请选择游戏时间"
    constant string CST_STR_PlayTime40m="40分钟游戏时间(对猎人有利)"
    constant string CST_STR_PlayTime50m="50分钟游戏时间"
    constant string CST_STR_PlayTime60m="60分钟游戏时间(对农民有利)"
    
    constant string CST_STR_RemainedTime="剩余游戏时间"
    
    // Common str
    constant string CST_STR_Level= "等级"
    constant string CST_STR_Number= "Number:"
    
    constant string CST_STR_Hunter= "The Hunter"
    constant string CST_STR_Farmer= "The Farmer"
    constant string CST_STR_FarmerScoreBoard= "Farmer Score Board"
    constant string CST_STR_HunterScoreBoard= "Hunter Score Board"
    constant string CST_STR_Player= "Player"
    constant string CST_STR_Kills= "Kills"
    constant string CST_STR_Deaths= "Deaths"
    constant string CST_STR_Status= "Status"
    constant string CST_STR_StatusPlaying= "Playing"
    constant string CST_STR_StatusHasLeft= "Has Left"
    constant string CST_STR_EnemyInfo= "Enemy Info"
    
    constant string CST_STR_GameInfo= "游戏信息"
    constant string CST_STR_GameModeSp= "洗牌模式"
    constant string CST_STR_GameModeSpIntro= "所有玩家将会被重新洗牌，，随机分配为农民或猎人"
    constant string CST_STR_GameModeNv= "禁止投票模式"
    constant string CST_STR_GameModeNvIntro= "不对游戏时间进行投票，使用默认游戏时间（50分钟）进行游戏"
    constant string CST_STR_GameModeNi= "禁止内斗模式"
    constant string CST_STR_GameModeNiIntro= "禁止内斗，盟友单位之间无法强制攻击"
    
    // The following nick name must be identical with that in propername list
    constant string CST_STR_FarmerProperNameGreedy= "Greedy"
    constant string CST_STR_FarmerProperNameKiller= "WolfKiller"
    constant string CST_STR_FarmerProperNameNomader= "Nomader"
    constant string CST_STR_FarmerProperNameCoward= "Coward"
    constant string CST_STR_FarmerProperNameWoody= "Woody"
    constant string CST_STR_FarmerProperNameMaster= "Master"
    constant string CST_STR_FarmerProperNameDefender= "Defender"
    constant string CST_STR_FarmerProperNamePlague= "Plague"
    
    /***************************************************************************
    * The messages delivered to players
    *   Messages always be string, so name begins with 'MSG'
    ***************************************************************************/
    constant string MSG_GameInitializing    = "Initializing game..."
    constant string MSG_GameInitializingDone= "Initializing finished..."
    
    // *** Kick player
    constant string MSG_KickPlayerClaim = "声明：\n你正在使用|cffff0000踢人（-kick）|r命令，作者赋予你这项权利是为了提供给大家一个良好的游戏环境，素质游戏从我做起。\n"
    constant string MSG_SelectNumberToKick = "选择你想踢出的玩家的|cff008000编号|r：\n"
    constant string MSG_CantKickYourself = "You must be kidding me, you can't kick yourself!"
    constant string MSG_HasBeenKicked = "has been kicked out by host"
    constant string MSG_YouHaveBeenKicked = "You have been kicked out by host"
    
    // *** Shuffle player
    constant string MSG_ShufflePlayerTo= "Shuffling player to:"
    constant string MSG_ShufflePlayerTo= "Shuffling player to:"
    
    // *** Select game mode
    constant string MSG_HostIs = "Host is:"
    constant string MSG_HostSelected = "Host selected"
    constant string MSG_YouAreHost = "You are host!"
    constant string MSG_PlsSelectGameMode  = "Please select game mode in 10 seconds"
    constant string MSG_CantSelectGameMode  = "Game has started, can't select game mode"
    constant string MSG_WaitHostSelectGameMode  = "Please wait host for choosing game mode..."
endglobals