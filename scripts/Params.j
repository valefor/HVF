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
    constant string COLOR_RED 		= "|cffff0000"
    constant string COLOR_YELLOW 	= "|cffffff00"
    constant string COLOR_BLUE 	= "|cffffff00"
    
    constant integer COLOR_ARGB_RED     = 0xFFFF0000
    constant integer COLOR_ARGB_YELLOW  = 0xFFFFFF00
    
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
