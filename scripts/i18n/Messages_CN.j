globals
    /***************************************************************************
    * Language
    ***************************************************************************/
    constant integer CST_LANG_I18N = CST_LANG_CN

    /***************************************************************************
    * Literalization
    ***************************************************************************/
    // HVF Advertisement
    constant string CST_STR_HVFAdv = "请尽情享受|cff008000《猎人VS农民》|r带给您的快乐，有任何问题和建议请联系|cffcc99ffQQ2872618576|r，或者E-mail：|cffcc99ffhvfdev@qq.com|r"
    
    // 11 Platform declaration
    constant string CST_STR_11Declaration= "系统检测到您正在11平台建主游戏中，您的战绩和技术统计将被保存，请坚持到底！另：不图不挂，素质游戏从我做起！"
    constant string CST_STR_Non11Declaration= "系统检测到您正在非11平台建主游戏中，您的战绩和技术统计将无法被保存"
    
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
    constant string CST_STR_GameModeInfo= "游戏模式信息:"
    constant string CST_STR_GameModeNm= "普通模式（默认）"
    constant string CST_STR_GameModeSp= "洗牌模式"
    constant string CST_STR_GameModeSpIntro= "所有玩家将会被随机分配为农民或猎人"
    constant string CST_STR_GameModeDr= "死亡竞赛模式"
    constant string CST_STR_GameModeDrIntro= "猎人无法复活为骷髅，农民只有5次重生机会。"
    
    
    constant string CST_STR_GameParam  = "游戏参数:"
    constant string CST_STR_GameParamInfo  = "游戏参数信息:"
    constant string CST_STR_GameParamNa= "禁止调整"
    constant string CST_STR_GameParamNaIntro= "禁止自动调整地图大小，使用最大地图进行游戏"
    constant string CST_STR_GameParamNv= "禁止投票"
    constant string CST_STR_GameParamNvIntro= "不对游戏时间进行投票，使用默认游戏时间（50分钟）进行游戏"
    constant string CST_STR_GameParamNi= "禁止内斗"
    constant string CST_STR_GameParamNiIntro= "禁止内斗，盟友单位之间无法强制攻击"
    
    constant string CST_STR_GameUtil    = "游戏辅助命令:"
    constant string CST_STR_GameUtilHIntro  = "显示帮助信息"
    constant string CST_STR_GameUtilGiIntro = "显示基本游戏信息"
    constant string CST_STR_GameUtilSaIntro = "显示盟友基本信息"
    constant string CST_STR_GameUtilSeIntro = "显示敌方基本信息"
    constant string CST_STR_GameUtilSmIntro = "显示游戏模式信息"
    
    constant string CST_STR_Killed= "杀死了"
    
    constant string CST_STR_HeroChar= "英雄特性："
    
    // The following nick name must be identical with that in propername list
    // *** Farmers
    constant string CST_STR_FarmerProperNameGreedy= "敛财者"
    constant string CST_STR_FarmerProperNameKiller= "杀狼者"
    constant string CST_STR_FarmerProperNameNomader= "游牧者"
    constant string CST_STR_FarmerProperNameCoward= "胆小鬼"
    constant string CST_STR_FarmerProperNameWoody= "伐木工"
    constant string CST_STR_FarmerProperNameMaster= "老农民"
    constant string CST_STR_FarmerProperNameDefender= "炮塔狂"
    constant string CST_STR_FarmerProperNamePlague= "瘟疫农"
    
    constant string CST_STR_FarmerIntroGreedy= "屠宰所得的钱额外+30%"
    constant string CST_STR_FarmerIntroKiller= "军队初始就具有一级单兵升级系统。"
    constant string CST_STR_FarmerIntroNomader= "牲口的产钱能力额外+50%"
    constant string CST_STR_FarmerIntroCoward= "农民有夜视能力，而且初始就具备2级的农民HP升级研究（即初始就比其他农民多了20点HP）。"
    constant string CST_STR_FarmerIntroWoody= "根据牲口棚数量和种类每分钟会补助额外木材(每次金钱收入的15%)。。"
    constant string CST_STR_FarmerIntroMaster= "被杀时如果拥有屠宰场所有牲口自动屠宰。"
    constant string CST_STR_FarmerIntroDefender= "塔初始就具备1级防御1级恢复和1级视野。"
    constant string CST_STR_FarmerIntroPlague= "初始具备5级瘟疫。"
    
    // *** Hunters
    constant string CST_STR_HunterRandomBonus= "随机奖励："
    constant string CST_STR_HunterRandomNone= "无"
    constant string CST_STR_HunterRandomBonusContent= "HP+1000, 护甲+1, 敏捷+3, 智力+2"
    
    /***************************************************************************
    * The messages delivered to players
    *   Messages are always string, so name begins with 'MSG'
    ***************************************************************************/
    constant string MSG_GameInitializing    = "游戏初始化..."
    constant string MSG_GameInitializingDone= "游戏初始化完毕..."
    constant string MSG_GameWillStart= "游戏马上开始..."
    constant string MSG_GameWinTipsHunter= "游戏开始！\n  |cFFFFFF00猎人胜利条件|r:在倒计时结束前没有全部阵亡,或者所有农民玩家退出游戏"
    constant string MSG_GameWinTipsFarmer= "游戏开始！\n  |cFFFFFF00农民胜利条件|r:在倒计时结束前杀死所有猎人,或者所有猎人玩家退出游戏"
    constant string MSG_GameStartTipsHunter= "现在你必须在基地里面的英雄商店选择一名猎人以进行游戏，随机猎人会有神秘奖励的哟！"
    constant string MSG_GameStartTipsFarmer= "现在赶紧找个隐蔽的地方藏起来并且造些羊圈发展吧！"
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
    
    // *** Death Race
    constant string MSG_YouHave = "你还剩下<"
    constant string MSG_ChancesToReive = ">次重生机会！"
    constant string MSG_HasExhaustAllLifes = "已经耗尽重生次数，彻底死亡！"
    
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

    // *** Help Msg
    // Common
    constant string HELP_C_1_HelpCommand = "使用|cffff0000-help|r命令来查看一些有用的游戏信息和命令"
    
    // For Hunter
    
    constant string HELP_H_1_ItemBox = "猎人出生点附近有工具箱，里面有一些物资和一个重要的|cffff0000便携商店|r"
    constant string HELP_H_2_HellFire = "地狱火是不错的道具,可以用来杀死农民,击晕敌人.地狱火还可以攻击并挖掉树木"
    constant string HELP_H_3_NeuAnimal= "购买一个野生动物巡视地图或者监视某个区域是很有效的。"
    constant string HELP_H_4_RocketLauncher= "火箭筒是不错的远程射杀武器.两枚火箭可以杀死没有升级过HP的农民."
    constant string HELP_H_5_MagicSeed= "商店里的魔法树种子是很有意思的东西，种在水里会结出很多的花草和种子。你可以卖掉或者使用它们。"
    constant string HELP_H_6_TechResearch= "你可以在基地里的物品箱里面研究一些技能."
    constant string HELP_H_7_MineInShop= "购买的地雷不可以伤害建筑.但可以对农民的部队造成极大的伤害."
    constant string HELP_H_8_HowToDestoryTower= "遇到农民成群的塔了?不要硬冲,如果你的猎人有地雷技能,你可以充分利用地雷技能拆除塔群.你也可以用高级奇美拉拆除敌人箭塔。"
    constant string HELP_H_9_Avantar= "瞬间强化技能是非常有用的技能,在战斗的时候效果非常好.在物品箱里面研究以获得使用."
    constant string HELP_H_10_SkeletonFighter= "如果你死了,请你不要随便退出游戏.你还可以操纵一个骷髅.这个骷髅可以无限复活.在研究升级以后还可以变得更强大.精良的骷髅是农民塔群和士兵的噩梦.后期更是猎人的移动传送点."
    constant string HELP_H_11_InvisiblePotion= "隐形药水是非常有用的东西,逃命和暗杀农民必备."
    constant string HELP_H_12_StunMine= "你可以考虑使用晕眩地雷来拖延农民军队的进攻."
    constant string HELP_H_13_TeleportAndEscape= "活用传送权杖和传送技能，配合队友能逃出农民部队的包围圈。"
    constant string HELP_H_14_HideAndWin= "时间不多了！采取一切猥琐手段隐蔽自己，保护活着的队友，不要让农民部队找到并杀死所有猎人，坚持就是胜利！"
    
    // For Farmer
    constant string HELP_F_1_HideAndFarming = "猎人需要购买消耗品来砍树，因此树是农民的天然保护伞，能保护农民不被猎人的侦查守卫发现，不要使用|cffff0000大面积砍树|r技能，躲在树丛中猥琐发展吧！"
    constant string HELP_F_2_FarmerChar = "不同角色的农民拥有不同的优势！！请用|cffff0000-gi|r命令来查看农民特点"
    constant string HELP_F_3_PigenUpgrade= "初期不要升级羊圈.过早升级羊圈其实是不划算的,先造多一些再升级效果会比较好."
    constant string HELP_F_4_PunishInfighting= "注意：一个农民自杀或者被盟友杀死会减少所有农民1/3的金钱！！"
    constant string HELP_F_5_HideYourBase= "你的基地不能造得太暴露,否则很容易被猎人发现."
    constant string HELP_F_6_Slaughterhouse= "屠宰场是非常有用的,当你急需钱的时候可以屠宰牲口一次性获得大量的钱."
    constant string HELP_F_7_TechResearch= "注意研究你的建筑物(在工程站研究),这对提升基地防御能力是非常重要的."
    constant string HELP_F_8_ConscriptionStrategy= "有钱的时候不要急于出兵杀掉猎人,研究科技提升部队的战斗力是非常关键的.过早地把钱投入到生产部队上只会让你的部队白白葬送在猎人的屠刀下."
    constant string HELP_F_9_FarmerShop= "商店是农民的关键建筑之一.商店里出售各种有用的物品."
    constant string HELP_F_10_WoodingAxe= "商店里的斧子可以被使用来采集木材.采集到的木材会送回到农民的商店."
    constant string HELP_F_11_Avatar= "农民的分身技能是相当有用的技能,可以帮助农民建造一些建筑.你也可以让分身携带斧子采集木材或者潜入猎人的基地以较便宜的价格购买一些东西."
    constant string HELP_F_12_SuperTank= "超级坦克是农民部队的终极物理兵种，拥有超强的攻防，注意超级坦克需要特种兵来驾驶才能发挥威力！"
    constant string HELP_F_13_ArchMage= "大法师是农民部队的终极魔法兵种，拥有超多实用的魔法技能，配合其他兵种能快速有效地追杀猎人！"
    constant string HELP_F_14_SlaughterThemAll= "时间不多了，不惜一起代价杀光猎人！赢得胜利！"
    
    // *** Quest
    constant string QST_Q_TitleHunterGameRule = "|cffffff00***猎人游戏规则***|r"
    constant string QST_Q_IntroHunterGameRule = "|cffff99cc胜利条件|r：|n<|cff99cc00普通模式|r>倒计时结束前猎人英雄没有全部阵亡|n|n|cffff99cc玩法简介|r：|n<|cff99cc00前期|r>猎人们通过侦查，不断杀死农民，分散压制农民，不能让农民顺利的起基地发展|n<|cff99cc00中期|r>猎人需要与队友配合，重点突击，强攻已经建立防御的农民基地，各个击破。如果处于劣势，尽量通过打野来获取经验和恢复道具。侦查不要间断，击杀落单的农民，压缩农民的生存和发展空间。|n<|cff99cc00后期|r>这时农民一般都具备了较强的实力，再去冲塔阵破农民基地比较难了，成功的前中期压制保证了此时猎人的生存空间，确保农民实力无法碾压猎人，否则就只能GG思密达了。。。|n<|cff99cc00提示|r>：|n  1.不断地放置侦查守卫，不要放过任何一个可疑的点。|n  2.购买一些辅助装备和雇佣兵能大大增加侦查效率和击杀成功率"
    constant string QST_Q_TitleFarmerGameRule = "|cffffff00***猎人游戏规则***|r"
    constant string QST_Q_IntroFarmerGameRule = "|cffff99cc胜利条件|r：|n<|cff99cc00普通模式|r>倒计时结束前杀死所有猎人，或者所有猎人玩家退出游戏|n|n|cffff99cc玩法简介|r：|n<|cff99cc00前期|r>农民伯伯们在夜幕和树丛的掩护下，躲避猎人的追杀和侦查，养羊挣钱，发展才是硬道理！|n<|cff99cc00中期|r>单独或者配合队友选一块战略要地起塔，用塔阵来防御自己的经济和科技建筑以及保护自身安全。构建属于自己的王国吧！|n<|cff99cc00后期|r>这时农民一般都具备了较强的实力，如果你是农民核心，请出兵去歼灭猎人，如果你酱油了，做一些辅助工作吧，比如：侦查猎人行踪、骚扰猎人逃跑路线、帮大哥位农民拉兵控制等等。|n<|cff99cc00提示|r>：|n  1.玩农民就是要猥琐，各种躲猫猫，各种调戏猎人~|n  2.农民可以去猎人基地购买猎人商店的低价木材，值得冒险！"
    constant string QST_Q_TitleHunterTips    = "猎人基本技巧"
    constant string QST_Q_IntroHunterTips    = "猎人主要是看个人的技巧：|n这里列出几个发现敌人的方法：|n1，利用岗哨守卫的技能（不可以反隐形）。|n2，购买猫头鹰、者侦查狼等雇用兵为你搜索地图。|n3，花一些木头进行大面积探测。|n4，如果农民用了隐身，可以用尘土之影来发现。|n|n砍树的方法：|n1，自己用技能手雷炸开。|n2，用物品砍树的斧头。|n3，用物品地狱火。|n4，用雇佣兵树木砍伐者。|n|n其他：猎人基地的门对于猎人可以轻易开关，对于农民自身则很难打开。 "
    constant string QST_Q_TitleFarmerTips    = "农民基本技巧"
    constant string QST_Q_IntroFarmerTips    = "1、你会随机出生在地图的一个地方如果你在树林里，开始建造，如果不是，按A砍开树木找一个不会被猎人发现的地方开始建造。|n2、首先建造羊圈，然后等待钱增加，钱够了再造羊圈，或者升级为猪圈，蛇穴，鸡棚。等钱到了足够的钱就可以造屠宰场屠宰牲口以直接得到金币。|n3、你可以任意用箭塔，门和墙来防御猎人。|n4、当钱足够开始研究科技，并且造兵，足够强大了就可以去杀猎人了。|n5、只要你的农民死了，你的基地和所有单位就会毁灭(研究的科技不会丢失)。|n6、农民每2分钟提升等级，死亡以后级别从一重新开始。越到后来每2分钟得到的经验值越多。 "

    constant string QST_O_TitleVersion  = "|cffffff00***版本信息***|r"
    constant string QST_O_IntroVersion  = "|cffff99cc当前版本：|n<|r|cff99cc00猎人VS农民 v7.0|r|cffff99cc>|r：只支持魔兽争霸1.24及以上版本|n|n|cffff99cc网址：|n<官网> |r：valefor.github.io/HVF|cffff99cc|n<官网Wiki> |r：github.com/valefor/HVF/wiki|n|n|cffff99cc改动：|n<|r|cff99cc00Bug修正|r|cffff99cc> |r：请查看官网获取更多信息|n|cffff99cc<|r|cff99cc00新增特点|r|cffff99cc>|r：请查看官网获取更多信息|n|cffff99cc<|r|cff99cc00属性调整|r|cffff99cc>|r：请查看官网获取更多信息"
    constant string QST_O_TitleCommand  = "游戏命令"
    constant string QST_O_IntroCommand  = "主机命令(|cffff6800主机可用|r)：|n  |cff99cc00-kick|r：|cffffff00踢出玩家，比如-kick 2，玩家2将被踢出游戏|r|n|n游戏辅助命令（|cffff6800所有人可用|r）:|n  |cff99cc00-help|r:|cffffff00显示帮助信息|r|n  |cff99cc00-gi|r  :|cffffff00显示基本游戏信息（Game Info）|r|n  |cff99cc00-sa|r  :|cffffff00显示盟友基本信息（Show Ally）|r|n  |cff99cc00-se|r  :|cffffff00显示敌方基本信息（Show Enemy）|r|n"
    constant string QST_O_TitleJoinUs   = "加入我们"
    constant string QST_O_IntroJoinUs   = "|cffcc99ff招|r|cffb8a3e6贤|r|cffa4adcc纳|r|cff8fb7b3士|r|cff7bc199，|r|cff66cc80请|r|cff52d666加|r|cff3ee04d入|r|cff29ea33我|r|cff15f41a们|r|cff00ff00！|r|n|n喜欢这个游戏的朋友可以加入我们的群：|n|cffcc99ff66750713|r、|cffcc99ff207303262|r|n欢迎建了|cff008000《猎人VS农民》|r游戏群的玩家朋友和我联系，我会在出新版本的时候把你们的游戏群在游戏里注上的。|n请尽情享受|cff008000《猎人VS农民》|r带给您的快乐，有任何问题和建议请联系|cffcc99ffQQ2872618576|r，或者E-mail：|cffcc99ffhvfdev@qq.com|r"

endglobals