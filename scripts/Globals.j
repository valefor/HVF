globals
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
    constant integer CST_INT_TECHID_HERO='HERO'
    constant integer CST_INT_MAX_HEROS=1
    constant integer CST_INT_MAX_HUNTERS=4
    constant integer CST_INT_MAX_FARMERS=8
    
    // *** Timers - Onetime Timer
    // Game host has 10 seconds to choose game mode
    constant real CST_OT_GAMEMODE=10.0
    // You have 15 seconds to vote for your favorite play time
    constant real CST_OT_VOTE=15.0
    constant integer CST_INT_MAXOT = 2
    
    // *** Timers - Periodic Timer
    constant real CST_PT_1s=1.0
    constant real CST_PT_10s=10.0
    constant real CST_PT_15s=15.0
    constant real CST_PT_30s=30.0
    constant real CST_PT_60s=60.0
    constant integer CST_INT_MAXPT = 5
    
    // *** Extra bonus for random hero
    constant integer CST_INT_RANDBONUS_LIFE=20
    constant integer CST_INT_RANDBONUS_ARMOR=1
    constant integer CST_INT_RANDBONUS_STR=0
    constant integer CST_INT_RANDBONUS_AGI=3
    constant integer CST_INT_RANDBONUS_INT=2
    
    // *** Magnification of resource bonus
    constant integer CST_INT_GOLDMAG_FM_DEAD=20
    constant integer CST_INT_GOLDMAG_HT_KILL=5    
    constant integer CST_INT_LUMBERMAG_HT_KILL=1
    
    // ** Skill points of initial hero
    constant integer CST_INT_HT_INIT_SKILLPOINTS=3
    constant integer CST_INT_FM_INIT_SKILLPOINTS=2
endglobals
