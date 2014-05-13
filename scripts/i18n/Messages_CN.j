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
    
    // Common str
    constant string CST_STR_Level= "等级"
    constant string CST_STR_Number= "玩家人数："
    
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
    
    constant string CST_STR_GameInfo= "游戏信息"
    constant string CST_STR_GameModeNm= "普通模式（默认）"
    constant string CST_STR_GameModeSp= "洗牌模式"
    constant string CST_STR_GameModeSpIntro= "所有玩家将会被重新洗牌，，随机分配为农民或猎人"
    
    constant string CST_STR_GameParam  = "游戏参数:"
    constant string CST_STR_GameParamNv= "禁止投票"
    constant string CST_STR_GameParamNvIntro= "不对游戏时间进行投票，使用默认游戏时间（50分钟）进行游戏"
    constant string CST_STR_GameParamNi= "禁止内斗"
    constant string CST_STR_GameParamNiIntro= "禁止内斗，盟友单位之间无法强制攻击"
    
    constant string CST_STR_Killed= "杀死了"
    
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
    *   Messages are always string, so name begins with 'MSG'
    ***************************************************************************/
    constant string MSG_GameInitializing    = "游戏初始化..."
    constant string MSG_GameInitializingDone= "游戏初始化完毕..."
    constant string MSG_GameWillStart= "游戏马上开始..."
    constant string MSG_GameStartTipsHunter= "游戏开始！\n  |cFFFFFF00猎人胜利条件|r:在倒计时结束前没有全部阵亡,或者所有农民玩家退出游戏"
    constant string MSG_GameStartTipsFarmer= "游戏开始！\n  |cFFFFFF00农民胜利条件|r:在倒计时结束前杀死所有猎人,或者所有猎人玩家退出游戏"
    
    constant string MSG_VoteForPlayTime="请投票选择游戏时间！"
    
    // *** Base
    constant string MSG_Important   = "重要"
    constant string MSG_Notice      = "注意"
    constant string MSG_Beaware     = "留意"
    constant string MSG_Tips        = "提示"
    
    // *** Kick player
    constant string MSG_KickPlayerClaim     = "声明：\n你正在使用|cffff0000踢人（-kick）|r命令，作者赋予你这项权利是为了提供给大家一个良好的游戏环境，素质游戏从我做起。\n"
    constant string MSG_SelectNumberToKick  = "选择你想踢出的玩家的|cff008000编号|r：\n"
    constant string MSG_CantKickYourself    = "你他妈在逗我？不能踢出你自己！"
    constant string MSG_HasBeenKicked       = "已经被踢出游戏"
    constant string MSG_YouHaveBeenKicked   = "你已经被主机踢出游戏！"
    
    // *** Shuffle player
    constant string MSG_ShufflePlayerModeSelected= "主机已经选择了洗牌模式，玩家将会被随机分配阵营..."
    constant string MSG_ShufflePlayerTo= "你已经被随机分配为："
    constant string MSG_ShufflePlayerDone= "洗牌结束！"
    
    // *** Select game mode
    constant string MSG_HostSelected = "主机选择了"
    constant string MSG_HostIs = "主机是："
    constant string MSG_YouAreHost = "你是主机"
    constant string MSG_PlsSelectGameMode  = "请在10秒内选择游戏模式"
    constant string MSG_CantSelectGameMode  = "游戏已经开始，无法选择游戏模式！"
    constant string MSG_WaitHostSelectGameMode  = "请等待主机选择游戏模式..."
    
    // *** Notice
    constant string MSG_NoticeHunterCantTakeTowerBase = "猎人不能携带塔基,删除物品并给与猎人奖励(+10木材)！"
    constant string MSG_NoticeFarmerKilledByAlly = "农民被盟友杀死了，所有农民减少1/4金钱，凶手减少1/2金钱！"
endglobals