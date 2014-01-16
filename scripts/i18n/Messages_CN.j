globals
    /***************************************************************************
    * Language
    ***************************************************************************/
    constant integer CST_LANG_I18N = CST_LANG_CN

    /***************************************************************************
    * Literalization
    ***************************************************************************/
    // For game time voting
    constant string CST_STR_PlayTimeTitle= "请选择游戏时间"
    constant string CST_STR_PlayTime40m="40分钟游戏时间(对猎人有利)"
    constant string CST_STR_PlayTime50m="50分钟游戏时间"
    constant string CST_STR_PlayTime60m="60分钟游戏时间(对农民有利)"
    
    constant string CST_STR_RemainedTime="剩余游戏时间"
    
    constant string CST_STR_Hunter= "猎人"
    constant string CST_STR_Farmer= "农民"
    constant string CST_STR_FarmerScoreBoard= "农民排行榜"
    constant string CST_STR_HunterScoreBoard= "猎人排行榜"
    constant string CST_STR_Player= "玩家"
    constant string CST_STR_Kills= "击杀数"
    constant string CST_STR_Deaths= "死亡数"
    constant string CST_STR_Status= "在线状态"
    constant string CST_STR_StatusPlaying= "正在游戏"
    constant string CST_STR_StatusHasLeft= "已经离开"
    constant string CST_STR_EnemyInfo= "敌方情报"
    
    // The following nick name must be identical with that in propername list
    constant string CST_STR_FarmerProperNameGreedy= "敛财者"
    constant string CST_STR_FarmerProperNameKiller= "杀狼者"
    constant string CST_STR_FarmerProperNameNomader= "游牧者"
    constant string CST_STR_FarmerProperNameCoward= "胆小鬼"
    constant string CST_STR_FarmerProperNameWoody= "伐木工"
    constant string CST_STR_FarmerProperNameMaster= "老农民"
    constant string CST_STR_FarmerProperNameDefender= "炮塔狂"
    constant string CST_STR_FarmerProperNamePlague= "瘟疫农"
    
    /***************************************************************************
    * The messages delivered to players
    *   Messages always be string, so name begins with 'MSG'
    ***************************************************************************/
    constant string MSG_GameInitializing    = "游戏初始化..."
    constant string MSG_GameInitializingDone= "游戏初始化完毕..."
    
    // *** Kick player
    constant string MSG_KickPlayerClaim     = "声明：\n你正在使用|cffff0000踢人（-kick）|r命令，作者赋予你这项权利是为了提供给大家一个良好的游戏环境，素质游戏从我做起。\n"
    constant string MSG_SelectNumberToKick  = "选择你想踢出的玩家的|cff008000编号|r：\n"
    constant string MSG_CantKickYourself    = "你他妈在逗我？不能踢出你自己！"
    constant string MSG_HasBeenKicked       = "已经被踢出游戏"
    constant string MSG_YouHaveBeenKicked   = "你已经被主机踢出游戏！"
    
    // *** Select game mode
    constant string MSG_HostSelected = "主机选择了"
    constant string MSG_HostIs = "主机是："
    constant string MSG_YouAreHost = "你是主机"
    constant string MSG_PlsSelectGameMode  = "请在10秒内选择游戏模式"
    constant string MSG_CantSelectGameMode  = "游戏已经开始，无法选择游戏模式！"
    constant string MSG_WaitHostSelectGameMode  = "请等待主机选择游戏模式..."
    
endglobals