library Params initializer init/* v0.0.1 Xandria
********************************************************************************
* 	Library for game parameters
*******************************************************************************/
globals
    /* ==============================Constants=============================== */
    constant integer CST_INT_TechidHero='HERO'
    
    constant integer CST_INT_FarmerRoleInvalid=0
    constant integer CST_INT_FarmerRoleGreedy=111
    constant integer CST_INT_FarmerRoleKiller=222
    constant integer CST_INT_FarmerRoleNomader=333
    constant integer CST_INT_FarmerRoleCoward=444
    constant integer CST_INT_FarmerRoleWoody=555
    constant integer CST_INT_FarmerRoleMaster=666
    constant integer CST_INT_FarmerRoleDefender=777
    constant integer CST_INT_FarmerRolePlague=888
    
    /***************************************************************************
    * Color
    ***************************************************************************/
    constant string COLOR_END       = "|r"
    
    constant string COLOR_RED       = "|cFFFF0000"
    constant string COLOR_GREEN     = "|cFF00FF00"
    constant string COLOR_BLUE      = "|cFF0000FF"
    constant string COLOR_YELLOW    = "|cFFFFFF00"
    constant string COLOR_BLACK     = "|cFF000000"
    constant string COLOR_WHITE     = "|cFFFFFFFF"
    constant string COLOR_CYAN      = "|cFF1CE6B9"
    constant string COLOR_PURPLE    = "|cFF540081"
    constant string COLOR_ORANGE    = "|cFFFE8A0E"
    constant string COLOR_PINK      = "|cFFE55BB0"
    constant string COLOR_AQUA      = "|cFF106246"
    constant string COLOR_BROWN     = "|cFF4E2A04"
    constant string COLOR_LIGHT_GRAY= "|cFF959697"
    constant string COLOR_LIGHT_BLUE= "|cFF7EBFF1"
    
    
    constant integer COLOR_ARGB_RED     = 0xFFFF0000
    constant integer COLOR_ARGB_GREEN   = 0xFF00FF00
    constant integer COLOR_ARGB_BLUE    = 0xFF0000FF
    constant integer COLOR_ARGB_YELLOW  = 0xFFFFFF00
    constant integer COLOR_ARGB_BLACK   = 0xFF000000
    constant integer COLOR_ARGB_WHITE   = 0xFFFFFFFF
    constant integer COLOR_ARGB_CYAN    = 0xFF1CE6B9
    constant integer COLOR_ARGB_PURPLE  = 0xFF540081
    constant integer COLOR_ARGB_ORANGE  = 0xFFFE8A0E
    constant integer COLOR_ARGB_PINK    = 0xFFE55BB0
    constant integer COLOR_ARGB_AQUA    = 0xFF106246
    constant integer COLOR_ARGB_BROWN   = 0xFF4E2A04
    constant integer COLOR_ARGB_LIGHT_GRAY   = 0xFF959697
    constant integer COLOR_ARGB_LIGHT_BLUE   = 0xFF7EBFF1
    
    /***************************************************************************
    * I18N
    ***************************************************************************/
    constant integer CST_LANG_CN = 0
    constant integer CST_LANG_EN = 1
    
    /***************************************************************************
    * Game Parameters
    ***************************************************************************/
    // *** Limitaition
    constant integer CST_INT_MaxHeros=1
    constant integer CST_INT_MaxHunters=4
    constant integer CST_INT_MaxFarmers=8
    constant integer CST_INT_MaxAnimals=550
    
    // *** Begin resource
    constant integer CST_INT_FarmerBeginGold=43
    constant integer CST_INT_FarmerBeginLumber=0
    constant integer CST_INT_HunterBeginGold=43
    constant integer CST_INT_HunterBeginLumber=10
    
    // *** Timers - Onetime Timer(postfix must be '.01')
    // Game host has 10 seconds to choose game mode
    constant real CST_OT_GameMode=10.01
    // You have 15 seconds to vote for your favorite play time
    constant real CST_OT_Vote=15.01
    // Hunter player should select a hero within 45s after game starts
    constant real CST_OT_SelectHero=15.01
    // Detect (Minitues)
    constant real CST_OT_Detect=10.0
    // Default play time (Minitues)
    constant real CST_OT_PlayTime=50.0
    constant integer CST_INT_MAXOT = 3
    
    // *** Timers - Periodic Timer
    constant real CST_PT_1s=1.0
    constant real CST_PT_5s=5.0
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
    
    // *** Salary based on aminal type (every 15secs)
    constant integer CST_INT_SalaryAlms=1
    constant integer CST_INT_SalaryBaseSheep=1
    constant integer CST_INT_SalaryBasePig=2
    constant integer CST_INT_SalaryBaseSnake=3
    constant integer CST_INT_SalaryBaseChicken=4
    
    // *** Price of animal, when animal is killed, player gets such gold
    constant integer CST_INT_PriceOfSheep=10
    constant integer CST_INT_PriceOfPig=20
    constant integer CST_INT_PriceOfSnake=30
    constant integer CST_INT_PriceOfChicken=40
    
    // *** Items
    constant integer CST_INT_MaxItemCount=77
    
    // *** Exp increace 100 for 3 tick(minutes)
    constant integer CST_INT_ExpAddForTick=100
    constant integer CST_INT_ExpTickStep=3
    
    // *** Board layout
    // Board Column
    constant integer CST_BDCOL_PN=0   // Player name
    constant integer CST_BDCOL_KL=1   // Kills
    constant integer CST_BDCOL_DE=1   // Deaths
    constant integer CST_BDCOL_ST=2   // Status
    constant integer CST_BDCOL_DF=9   // DEBUG FLAG
    
    // *** Message display duration
    constant integer CST_MSGDUR_Important=60
    constant integer CST_MSGDUR_Beaware =30
    constant integer CST_MSGDUR_Normal  =10
    constant integer CST_MSGDUR_Tips    =5
    
    /* ==============================Variables=============================== */
    // *** Deltas, for debug use
    // 60 seconds, 1 means one minute, 1 means one second in debug mode
    integer VAR_INT_PlayTimeDelta=60
endglobals

struct Params extends array
    // Game Mode
    static boolean flagGameModeSp   = false
    static boolean flagGameModeNv   = false
    static boolean flagGameModeNi   = false
    
    // Medal
endstruct

/***************************************************************************
* Library Initiation
***************************************************************************/
private function init takes nothing returns nothing
endfunction
    
    
endlibrary
