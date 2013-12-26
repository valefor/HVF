globals
    /* ==============================Constants=============================== */

    /***************************************************************************
    * Literalization
    ***************************************************************************/
    // For game time voting
    constant string CST_STR_PLAYTIME_TITLE= "请选择游戏时间"
    constant string CST_STR_PLAYTIME_40="40分钟游戏时间(对猎人有利)"
    constant string CST_STR_PLAYTIME_50="50分钟游戏时间"
    constant string CST_STR_PLAYTIME_60="60分钟游戏时间(对农民有利)"
    
    constant string CST_STR_REMAINED_TIME="剩余游戏时间"
    
    constant string CST_STR_HUNTER= "猎人"
    constant string CST_STR_FARMER= "农民"

    /***************************************************************************
    * Game Parameters
    ***************************************************************************/
    // *** Limitaition
    constant integer CST_INT_TechidHero='HERO'
    constant integer CST_INT_MaxHeros=1
    constant integer CST_INT_MaxHunters=4
    constant integer CST_INT_MaxFarmers=8
    
    // *** Timers - Onetime Timer(postfix must be '.01')
    // Game host has 10 seconds to choose game mode
    constant real CST_OT_GameMode=10.01
    // You have 15 seconds to vote for your favorite play time
    constant real CST_OT_Vote=15.01
    // Hunter player should select a hero within 45s after game starts
    constant real CST_OT_SelectHero=45.01
    // Detect (Minitues)
    constant real CST_OT_Detect=10.0
    // Default play time (Minitues)
    constant real CST_OT_PlayTime=60.0
    constant integer CST_INT_MAXOT = 3
    
    // *** Timers - Periodic Timer
    constant real CST_PT_1s=1.0
    constant real CST_PT_10s=10.0
    constant real CST_PT_15s=15.0
    constant real CST_PT_30s=30.0
    constant real CST_PT_60s=60.0
    constant integer CST_INT_MAXPT = 5
    
    // *** Extra bonus for random hero
    constant integer CST_INT_RandomBonusLife=20
    constant integer CST_INT_RandomBonusArmor=1
    constant integer CST_INT_RandomBonusStr=0
    constant integer CST_INT_RandomBonusAgi=3
    constant integer CST_INT_RandomBonusInt=2
    
    // *** Magnification of resource bonus
    constant integer CST_INT_GoldMagForDeath=20
    constant integer CST_INT_GoldMagForKilling=5   
    constant integer CST_INT_LumberMagForKilling=1
    
    // *** Skill points of initial hero
    constant integer CST_INT_InitHunterSkillPoints=3
    constant integer CST_INT_InitFarmerSkillPoints=2
    
    
    /* ==============================Variables=============================== */
    // *** Deltas, for debug use
    // 60 seconds, 1 means one minute, 1 means one second in debug mode
    integer VAR_INT_PlayTimeDelta=60
endglobals
