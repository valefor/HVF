library StatsManager initializer init /* v0.0.1 by Xandria
*/  uses    Alloc         /*
*/          TimeManager   /*
*/          YDWERecord    /*
********************************************************************************
*   Statistic Manager: Manage statistics of player
*******************************************************************************/

globals     

    // *** Title
    constant string CST_STR_TitleDiors          = "吊丝一枚"
    constant string CST_STR_TitleMillionaire    = "百万富翁"
    constant string CST_STR_TitleTowerDestroyer = "艹塔狂魔"
    constant string CST_STR_TitleTowerBuilder   = "造塔狂魔"
    constant string CST_STR_TitleSlaughter      = "屠夫"
    constant string CST_STR_TitleSafer          = "不破金身"
    
    // *** Merit Rank 
    // Hunter
    constant string CST_STR_HRankNeophyte= "新手猎人"
    constant string CST_STR_HRankSoldier = "战士"
    constant string CST_STR_HRankRider   = "骑士"
    constant string CST_STR_HRankGuard   = "禁卫"
    constant string CST_STR_HRankRanger  = "游侠"
    constant string CST_STR_HRankGeneral = "将军"
    constant string CST_STR_HRankCaptain = "统帅"
    constant string CST_STR_HRankMarshal = "元帅"
    
    // Hunter Elite
    constant string CST_STR_HRankEliteHunter = "精英猎人"
    constant string CST_STR_HRankEliteSoldier= "精英战士"
    constant string CST_STR_HRankEliteRider  = "精英骑士"
    constant string CST_STR_HRankEliteGuard  = "精英禁卫"
    constant string CST_STR_HRankEliteRanger = "精英游侠"
    constant string CST_STR_HRankGranGeneral = "大将军"
    constant string CST_STR_HRankGranCaptain = "大统帅"
    constant string CST_STR_HRankGranMarshal = "大元帅"
    
    // Farmer
    constant string CST_STR_FRankNeophyte   = "新手农民"
    constant string CST_STR_FRankLord       = "地主"
    constant string CST_STR_FRankWizard     = "巫师"
    constant string CST_STR_FRankWitchcraft = "妖术师"
    constant string CST_STR_FRankWarlock    = "术士"
    constant string CST_STR_FRankMage       = "法师"
    constant string CST_STR_FRankCurse      = "禁咒法师"
    constant string CST_STR_FRankSage       = "贤者"
    
    // Farmer Elite
    
    // *** Board Icons
    // Common
    constant string ICON_Empty  = "UI\\Widgets\\Console\\Undead\\undead-inventory-slotfiller.blp"
    constant string ICON_Farmer = "ReplaceableTextures\\CommandButtons\\BTNKobold.blp"
    constant string ICON_Gold   = "UI\\Feedback\\Resources\\ResourceGold.blp"
    constant string ICON_Lumber = "UI\\Feedback\\Resources\\ResourceLumber.blp"
    constant string ICON_Integral  = "ReplaceableTextures\\CommandButtons\\BTNIntegral.blp"
    constant string ICON_MVPCrown   = "ReplaceableTextures\\CommandButtons\\BTNCrownMVP.blp"
    // Medals
    constant string ICON_MEDAL_Soldier   = "ReplaceableTextures\\CommandButtons\\BTNMedalSoldier.blp"
    constant string ICON_MEDAL_Rider     = "ReplaceableTextures\\CommandButtons\\BTNMedalRider.blp"
    constant string ICON_MEDAL_Guard     = "ReplaceableTextures\\CommandButtons\\BTNMedalGuard.blp"
    constant string ICON_MEDAL_Ranger    = "ReplaceableTextures\\CommandButtons\\BTNMedalRanger.blp"
    constant string ICON_MEDAL_General   = "ReplaceableTextures\\CommandButtons\\BTNMedalGeneral.blp"
    constant string ICON_MEDAL_Captain   = "ReplaceableTextures\\CommandButtons\\BTNMedalCaptain.blp"
    constant string ICON_MEDAL_Marshal   = "ReplaceableTextures\\CommandButtons\\BTNMedalMarshal.blp"
    
    // Emblems
    constant string ICON_EMBLEM_Lord     = "ReplaceableTextures\\CommandButtons\\BTNEmblemLord.blp"
    constant string ICON_EMBLEM_Wizard   = "ReplaceableTextures\\CommandButtons\\BTNEmblemWizard.blp"
    constant string ICON_EMBLEM_Witchcraft = "ReplaceableTextures\\CommandButtons\\BTNEmblemWitchcraft.blp"
    constant string ICON_EMBLEM_Warlock  = "ReplaceableTextures\\CommandButtons\\BTNEmblemWarlock.blp"
    constant string ICON_EMBLEM_Mage     = "ReplaceableTextures\\CommandButtons\\BTNEmblemMage.blp"
    constant string ICON_EMBLEM_Curse    = "ReplaceableTextures\\CommandButtons\\BTNEmblemCurse.blp"
    constant string ICON_EMBLEM_Sage     = "ReplaceableTextures\\CommandButtons\\BTNEmblemSage.blp"
    
    // Title
    constant string ICON_TITLE_Diors     = "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp"
    
    // *** Board layout
    // Board Column
    constant integer CST_BDCOL_PN=0   // Player name
    constant integer CST_BDCOL_KL=1   // Kills
    constant integer CST_BDCOL_DE=2   // Deaths
    constant integer CST_BDCOL_GD=3   // Gold
    constant integer CST_BDCOL_LB=4   // Lumber
    constant integer CST_BDCOL_SC=5   // Scores
    constant integer CST_BDCOL_TT=6   // Title
    constant integer CST_BDCOL_RK=7   // Rank
    constant integer CST_BDCOL_ST=8   // Status
    constant integer CST_BDCOL_DF=9   // DEBUG FLAG
    
    // Rank Level
    constant integer CST_RL_Soldier =1
    constant integer CST_RL_Rider   =2
    constant integer CST_RL_Guard   =3
    constant integer CST_RL_Ranger  =4
    constant integer CST_RL_General =5
    constant integer CST_RL_Captain =6
    constant integer CST_RL_Marshal =7
    
    // Rank Level Score
    constant integer CST_RLS_1      =100
    constant integer CST_RLS_2      =500
    constant integer CST_RLS_3      =1000
    constant integer CST_RLS_4      =2000
    constant integer CST_RLS_5      =4000
    constant integer CST_RLS_6      =7000
    constant integer CST_RLS_7      =10000
    
    // The Score Magnification
    constant real   CST_MAG_1       =0.25
    constant real   CST_MAG_2       =0.75
    constant real   CST_MAG_3       =1.25
    constant real   CST_MAG_4       =1.50
    
    // MVP, Wealth, Merit
    constant integer CST_RND_Base   =10
    constant integer CST_ELT_Base   =60
    constant integer CST_MVP_Base   =2
    constant integer CST_MVP_Bonus  =10
    constant integer CST_WEL_Max    =200
    constant integer CST_WEL_Mag    =1000
    constant integer CST_MRT_Max    =200
    constant integer CST_MRT_Mag    =10
    
    
endglobals

// This struct is used for 11 platform record
// Note: pls extends from array and implements Alloc, vJass compiler won't
// manage allocation/deallocation for us, we do it by ourself
struct StatsRecord extends array

    implement Alloc
    
    integer Rounds
    integer WinRate
    integer HunterScore
    integer FarmerScore
    integer Wealth
    integer Merit
    integer Flees
    integer MVPs
    
    integer Wins
    integer HunterPlays
    integer HunterWins
    integer FarmerPlays
    integer FarmerWins
    
    // Put vars which should not be saved to 11 from here
    boolean isMVP
    integer oldFlees
    integer oldHunterScore
    integer oldFarmerScore
    integer score
    integer merit
    integer wealth
    
    public static method create takes player p returns thistype
        local thistype this = thistype.allocate()
        
        set .Rounds = YDWERecordGetI(p, CST_STR_11ProfRounds)
        set .oldFlees= YDWERecordGetI(p, CST_STR_11ProfFlees)
        set .oldHunterScore= YDWERecordGetI(p, CST_STR_11ProfHunterScore)
        set .oldFarmerScore= YDWERecordGetI(p, CST_STR_11ProfFarmerScore)
        set .Flees  = oldFlees
        set .HunterScore = oldHunterScore
        set .FarmerScore = oldFarmerScore
        set .score  = 0
        set .isMVP  = false
        
        set .WinRate     = YDWERecordGetI(p, CST_STR_11ProfWinRate)     
        
        set .Wealth      = YDWERecordGetI(p, CST_STR_11ProfWealth)
        set .Merit       = YDWERecordGetI(p, CST_STR_11ProfMerit)
        set .MVPs        = YDWERecordGetI(p, CST_STR_11ProfMVPs)
        
        set .Wins        = YDWERecordGetI(p, CST_STR_11ProfWins)
        set .HunterPlays = YDWERecordGetI(p, CST_STR_11ProfHunterPlays)
        set .HunterWins  = YDWERecordGetI(p, CST_STR_11ProfHunterWins)
        set .FarmerPlays = YDWERecordGetI(p, CST_STR_11ProfFarmerPlays)
        set .FarmerWins  = YDWERecordGetI(p, CST_STR_11ProfFarmerWins)
        
        // call this.initSave(p)
        
        return this
    endmethod

    // Some fields need to be save when loading game
    public method initSave takes player p returns nothing
        call YDWERecordSetI( p, CST_STR_11ProfRounds, .Rounds )
        call YDWERecordSetI( p, CST_STR_11ProfFlees, .Flees )
        call YDWERecordSave( p )
    endmethod
    
    // Update records
    public method update takes nothing returns nothing
        set .WinRate = R2I( .Wins/.Rounds )
    endmethod
    
    // Normal commit
    public method save takes player p returns nothing
        call YDWERecordSetI(p, CST_STR_11ProfWinRate, .WinRate)     
        call YDWERecordSetI(p, CST_STR_11ProfHunterScore, .HunterScore)
        call YDWERecordSetI(p, CST_STR_11ProfFarmerScore, .FarmerScore)
        call YDWERecordSetI(p, CST_STR_11ProfWealth, .Wealth)
        call YDWERecordSetI(p, CST_STR_11ProfMerit, .Merit)
        call YDWERecordSetI(p, CST_STR_11ProfMVPs, .MVPs)
        
        call YDWERecordSetI(p, CST_STR_11ProfWins, .Wins)
        call YDWERecordSetI(p, CST_STR_11ProfHunterPlays, .HunterPlays)
        call YDWERecordSetI(p, CST_STR_11ProfHunterWins, .HunterWins)
        call YDWERecordSetI(p, CST_STR_11ProfFarmerPlays, .FarmerPlays)
        call YDWERecordSetI(p, CST_STR_11ProfFarmerWins, .FarmerWins)
        
        call YDWERecordSave( p )
    endmethod
    
    private static method setTitle takes nothing returns nothing
        call YDWERecordSetTitle( 0, CST_STR_11ProfRounds )
        call YDWERecordSetTitle( 1, CST_STR_11ProfWinRate )
        call YDWERecordSetTitle( 2, CST_STR_11ProfHunterScore )
        call YDWERecordSetTitle( 3, CST_STR_11ProfFarmerScore )
        call YDWERecordSetTitle( 4, CST_STR_11ProfWealth )
        call YDWERecordSetTitle( 5, CST_STR_11ProfMerit )
        call YDWERecordSetTitle( 6, CST_STR_11ProfFlees )
        call YDWERecordSetTitle( 7, CST_STR_11ProfMVPs )
    endmethod
    
    private static method onInit takes nothing returns nothing
        call thistype.setTitle()
    endmethod

    /*
    call SetPlayerState(whichPlayer, whichPlayerState, GetPlayerState(whichPlayer, whichPlayerState) + delta)
    
    */
endstruct

struct StatsBoard extends array
    static Board hb = -1    // Hunter Board
    static Board fb = -1    // Farmer Board
    
    static method createAndInit takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]
        local integer i = 2
        
        set hb = Board.create()
        set fb = Board.create()
        call hb.clear()
        call fb.clear()
        
        // Common
        set hb.title = CST_STR_ScoreBoard
        set fb.title = CST_STR_ScoreBoard
        call hb.all.setDisplay(true, false)
        call fb.all.setDisplay(true, false)

        //set statsBoard[CST_BDCOL_PN][0].text = CST_STR_Player
        // set hb[CST_BDCOL_PN][0].width = 0.07
        // *** Hunter's Board
        set hb[CST_BDCOL_KL][0].text = CST_STR_Kills
        set hb[CST_BDCOL_DE][0].text = CST_STR_Deaths
        set hb[CST_BDCOL_GD][0].icon = ICON_Gold
        call hb[CST_BDCOL_GD][0].setDisplay(false, true)
        set hb[CST_BDCOL_LB][0].icon = ICON_Lumber
        call hb[CST_BDCOL_LB][0].setDisplay(false, true)
        set hb[CST_BDCOL_SC][0].icon = ICON_Integral
        call hb[CST_BDCOL_SC][0].setDisplay(false, true)
        set hb[CST_BDCOL_TT][0].text = CST_STR_Title
        set hb[CST_BDCOL_RK][0].text = CST_STR_Rank
        set hb[0][1].text = CST_STR_Farmer
        set hb[0][1].color = COLOR_ARGB_RED
   
        // *** Farmer's Board
        set fb[CST_BDCOL_KL][0].text = CST_STR_Kills
        set fb[CST_BDCOL_DE][0].text = CST_STR_Deaths
        set fb[CST_BDCOL_GD][0].icon = ICON_Gold
        call fb[CST_BDCOL_GD][0].setDisplay(false, true)
        set fb[CST_BDCOL_LB][0].icon = ICON_Lumber
        call fb[CST_BDCOL_LB][0].setDisplay(false, true)
        set fb[CST_BDCOL_SC][0].icon = ICON_Integral
        call fb[CST_BDCOL_SC][0].setDisplay(false, true)
        set fb[CST_BDCOL_TT][0].text = CST_STR_Title
        set fb[CST_BDCOL_RK][0].text = CST_STR_Rank
        set fb[0][1].text = CST_STR_Farmer
        set fb[0][1].color = COLOR_ARGB_RED
        loop
            exitwhen f.end
            set f.bIndex = i
            // Farmer
            set fb[CST_BDCOL_PN][i].text = ARGB.fromPlayer(f.get).str(GetPlayerName(f.get))
            set fb[CST_BDCOL_PN][i].icon = ICON_Farmer
            call fb[CST_BDCOL_PN][i].setDisplay(true, true)
            //set fb[CST_BDCOL_KL][i].text = I2S(0)
            set fb[CST_BDCOL_DE][i].text = I2S(f.deathCount)
            set fb[CST_BDCOL_GD][i].text = I2S(0)
            set fb[CST_BDCOL_LB][i].text = I2S(0)
            set fb[CST_BDCOL_SC][i].text = I2S(f.sr.FarmerScore)
            set fb[CST_BDCOL_TT][i].text = CST_STR_TitleDiors
            set fb[CST_BDCOL_TT][i].icon = ICON_TITLE_Diors
            call fb[CST_BDCOL_TT][i].setDisplay(true, true)
            set fb[CST_BDCOL_RK][i].text = CST_STR_FRankNeophyte
            set fb[CST_BDCOL_RK][i].icon = ICON_Empty
            call fb[CST_BDCOL_RK][i].setDisplay(true, true)
            set fb[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
            // Hunter
            set hb[CST_BDCOL_PN][i].text = ARGB.fromPlayer(f.get).str(GetPlayerName(f.get))
            set hb[CST_BDCOL_PN][i].icon = ICON_Farmer
            call hb[CST_BDCOL_PN][i].setDisplay(true, true)
            //set hb[CST_BDCOL_KL][i].text = I2S(0)
            set hb[CST_BDCOL_DE][i].text = I2S(f.deathCount)
            //set hb[CST_BDCOL_GD][i].text = I2S(0)
            //set hb[CST_BDCOL_LB][i].text = I2S(0)
            set hb[CST_BDCOL_SC][i].text = I2S(f.sr.FarmerScore)
            set hb[CST_BDCOL_TT][i].text = CST_STR_TitleDiors
            set hb[CST_BDCOL_TT][i].icon = ICON_TITLE_Diors
            call hb[CST_BDCOL_TT][i].setDisplay(true, true)
            set hb[CST_BDCOL_RK][i].text = CST_STR_FRankNeophyte
            set hb[CST_BDCOL_RK][i].icon = ICON_Empty
            call hb[CST_BDCOL_RK][i].setDisplay(true, true)
            set hb[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
            set i = i + 1
            set f = f.next
        endloop
        
        set fb[0][i].text = CST_STR_Hunter
        set fb[0][i].color = COLOR_ARGB_GREEN
        set hb[0][i].text = CST_STR_Hunter
        set hb[0][i].color = COLOR_ARGB_GREEN
        set i = i + 1
        loop
            exitwhen h.end
            set h.bIndex = i
            // Farmer
            set fb[CST_BDCOL_PN][i].text = ARGB.fromPlayer(h.get).str(GetPlayerName(h.get))
            set fb[CST_BDCOL_PN][i].icon = ICON_Empty
            call fb[CST_BDCOL_PN][i].setDisplay(true, true)
            set fb[CST_BDCOL_KL][i].text = I2S(h.killCount)
            //set fb[CST_BDCOL_DE][i].text = I2S(0)
            //set fb[CST_BDCOL_GD][i].text = I2S(0)
            //set fb[CST_BDCOL_LB][i].text = I2S(0)
            set fb[CST_BDCOL_SC][i].text = I2S(h.sr.HunterScore)
            set fb[CST_BDCOL_TT][i].text = CST_STR_TitleDiors
            set fb[CST_BDCOL_TT][i].icon = ICON_TITLE_Diors
            call fb[CST_BDCOL_TT][i].setDisplay(true, true)
            set fb[CST_BDCOL_RK][i].text = CST_STR_HRankNeophyte
            set fb[CST_BDCOL_RK][i].icon = ICON_Empty
            call fb[CST_BDCOL_RK][i].setDisplay(true, true)
            set fb[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
            // Hunter
            set hb[CST_BDCOL_PN][i].text = ARGB.fromPlayer(h.get).str(GetPlayerName(h.get))
            set hb[CST_BDCOL_PN][i].icon = ICON_Empty
            call hb[CST_BDCOL_PN][i].setDisplay(true, true)
            set hb[CST_BDCOL_KL][i].text = I2S(h.killCount)
            //set hb[CST_BDCOL_DE][i].text = I2S(0)
            set hb[CST_BDCOL_GD][i].text = I2S(0)
            set hb[CST_BDCOL_LB][i].text = I2S(0)
            set hb[CST_BDCOL_SC][i].text = I2S(h.sr.HunterScore)
            set hb[CST_BDCOL_TT][i].text = CST_STR_TitleDiors
            set hb[CST_BDCOL_TT][i].icon = ICON_TITLE_Diors
            call hb[CST_BDCOL_TT][i].setDisplay(true, true)
            set hb[CST_BDCOL_RK][i].text = CST_STR_HRankNeophyte
            set hb[CST_BDCOL_RK][i].icon = ICON_Empty
            call hb[CST_BDCOL_RK][i].setDisplay(true, true)
            set hb[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
            set i = i + 1
            set h = h.next
        endloop

        // Set column width
        set hb.all.width = 0.02
        set fb.all.width = 0.02
        set hb.col[CST_BDCOL_PN].width = 0.07
        set hb.col[CST_BDCOL_TT].width = 0.07
        set hb.col[CST_BDCOL_RK].width = 0.07
        set hb.col[CST_BDCOL_GD].width = 0.04
        set hb.col[CST_BDCOL_LB].width = 0.04
        set hb.col[CST_BDCOL_SC].width = 0.03
        set hb.col[CST_BDCOL_ST].width = 0.03
        
        set fb.col[CST_BDCOL_PN].width = 0.07
        set fb.col[CST_BDCOL_TT].width = 0.07
        set fb.col[CST_BDCOL_RK].width = 0.07
        set fb.col[CST_BDCOL_GD].width = 0.04
        set fb.col[CST_BDCOL_LB].width = 0.04
        set fb.col[CST_BDCOL_SC].width = 0.03
        set fb.col[CST_BDCOL_ST].width = 0.03
        
        // Set column color
        set hb.col[CST_BDCOL_KL].color = COLOR_ARGB_RED
        set hb.col[CST_BDCOL_DE].color = COLOR_ARGB_BLUE
        set hb.col[CST_BDCOL_GD].color = COLOR_ARGB_YELLOW
        set hb.col[CST_BDCOL_LB].color = COLOR_ARGB_GREEN
        set hb.col[CST_BDCOL_SC].color = COLOR_ARGB_LIGHT_BLUE
        set hb.col[CST_BDCOL_TT].color = COLOR_ARGB_PURPLE
        set hb.col[CST_BDCOL_RK].color = COLOR_ARGB_ORANGE
        
        set fb.col[CST_BDCOL_KL].color = COLOR_ARGB_RED
        set fb.col[CST_BDCOL_DE].color = COLOR_ARGB_BLUE
        set fb.col[CST_BDCOL_GD].color = COLOR_ARGB_YELLOW
        set fb.col[CST_BDCOL_LB].color = COLOR_ARGB_GREEN
        set fb.col[CST_BDCOL_SC].color = COLOR_ARGB_LIGHT_BLUE
        set fb.col[CST_BDCOL_TT].color = COLOR_ARGB_PURPLE
        set fb.col[CST_BDCOL_RK].color = COLOR_ARGB_ORANGE
        
        // Display the board
        call thistype.redisplay()
    endmethod
    
    // Hide All boards and show this board again 
    static method redisplay takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]
        
        call MultiboardSuppressDisplay(true)
        call MultiboardSuppressDisplay(false)
        set h = Hunter[Hunter.first]
        set f = Farmer[Farmer.first] 
        loop
            exitwhen f.end
            set fb.visible[f.get] = true
            set fb.minimized = false
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set hb.visible[h.get] = true
            set hb.minimized = false
            set h = h.next
        endloop
    endmethod
    
    // Some stats on the board need to be refreshed timely 
    static method refresh takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            // Not the PLAYER_STATE_GOLD_GATHERED/PLAYER_STATE_LUMBER_GATHERED
            set fb[CST_BDCOL_GD][f.bIndex].text = I2S( GetPlayerState(f.get,PLAYER_STATE_RESOURCE_GOLD) )
            set fb[CST_BDCOL_LB][f.bIndex].text = I2S( GetPlayerState(f.get,PLAYER_STATE_RESOURCE_LUMBER) )
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set hb[CST_BDCOL_GD][h.bIndex].text = I2S( GetPlayerState(h.get,PLAYER_STATE_RESOURCE_GOLD) )
            set hb[CST_BDCOL_LB][h.bIndex].text = I2S( GetPlayerState(h.get,PLAYER_STATE_RESOURCE_LUMBER) )
            set h = h.next
        endloop
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerManager.onGameStart.register(Filter(function thistype.createAndInit))
        
        // Refresh the board every 10 seconds
        call TimerManager.pt10s.register(Filter(function thistype.refresh))
    endmethod
endstruct

struct StatsManager extends array   

    static real scoreMag = CST_MAG_1
    
    public static method isIn11Platform takes nothing returns boolean
        return YDWEPlatformIsInPlatform()
    endmethod
    
    // Evaluate the rank level of given score
    static method evalRankLevel takes integer score returns integer
        if score < CST_RLS_1 then
            return 0
        elseif score < CST_RLS_2 then
            return 1
        elseif score < CST_RLS_3 then
            return 2
        elseif score < CST_RLS_4 then
            return 3
        elseif score < CST_RLS_5 then
            return 4
        elseif score < CST_RLS_6 then
            return 5
        elseif score < CST_RLS_7 then
            return 6
        else
            return 7
        endif
    endmethod
    
    static method isElite takes StatsRecord sr returns boolean
        return sr.Rounds >= CST_RND_Base and sr.WinRate >= CST_ELT_Base
    endmethod
    
    // Set magnification from player/role numbers
    static method setMag takes nothing returns nothing
        local integer fn = Farmer.humanPlayerNumber    
        local integer hn = Hunter.humanPlayerNumber
        local real mag = CST_MAG_1

        if fn < 3 then
            set mag = CST_MAG_1
        elseif fn < 5 then
            set mag = CST_MAG_2
        elseif fn < 7 then
            set mag = CST_MAG_3
        endif
        
        if hn < 2 then
            set mag = CST_MAG_1
        elseif hn < 3 then
            set mag = CST_MAG_2
        elseif hn < 4 then
            set mag = CST_MAG_3
        endif
        
        set thistype.scoreMag = mag
    endmethod
    
    static method updateStats takes boolean farmerWin, boolean last returns nothing
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]
        local integer fMaxScoreIdx = Farmer.first
        local integer hMaxScoreIdx = Hunter.first
        local integer fMaxScore = 0
        local integer hMaxScore = 0
        local integer temp = 0
        
        if TimerManager.getPlayedTime() < 10 then
            return
        endif
        
        // Calculate scores and decide who is the MVP
        loop
            exitwhen f.end
            if not f.leave then // <<
            
            if last and farmerWin then
                set temp = temp + 4
                set f.sr.Wins = f.sr.Wins + 1 
                set f.sr.FarmerWins = f.sr.FarmerWins + 1
                set f.sr.WinRate = R2I( (f.sr.Wins/f.sr.Rounds)*100 )
            endif
            set temp = temp + f.calculateScore(last)
            set temp = R2I(temp*StatsManager.scoreMag)
            if TimerManager.getPlayedTime() >= 10 then
                set temp = temp + 2
            endif
            if f.sr.score < temp then
                set f.sr.score = temp
            endif
            if fMaxScore < temp then
                set fMaxScore = temp
                set fMaxScoreIdx = GetPlayerId(f.get)
            elseif fMaxScore == temp then
                if f.isBetterThan(Farmer[fMaxScoreIdx]) then
                    set fMaxScoreIdx = GetPlayerId(f.get)
                endif
            endif

            set f.sr.wealth = f.calculateWealth()
            endif       // >>
            set f = f.next
        endloop
        
        set temp = 0
        loop
            exitwhen h.end
            if not h.leave then // <<
            
            if last and not farmerWin then
                set temp = temp + 4
                set h.sr.Wins = h.sr.Wins + 1 
                set h.sr.HunterWins = h.sr.HunterWins + 1
                set h.sr.WinRate = R2I( (h.sr.Wins/h.sr.Rounds)*100 )
            endif
            set temp = temp + h.calculateScore(last)
            set temp = R2I(temp*StatsManager.scoreMag)
            if TimerManager.getPlayedTime() >= 10 then
                set temp = temp + 2
            endif
            if h.sr.score < temp then
                set h.sr.score = temp
            endif
            if hMaxScore < temp then
                set hMaxScore = temp
                set hMaxScoreIdx = GetPlayerId(h.get)
            elseif hMaxScore == temp then
                if h.isBetterThan(Hunter[hMaxScoreIdx]) then
                    set hMaxScoreIdx = GetPlayerId(h.get)
                endif
            endif
            
            set h.sr.merit = h.calculateMerit()
 
            endif               // >>
            set h = h.next
        endloop
        
        set f = Farmer[fMaxScoreIdx]
        set h = Farmer[hMaxScoreIdx]
        
        // Choose MVP
        if last then // <<
        
        if fMaxScore >= CST_MVP_Base then
            if hMaxScore < CST_MVP_Base or hMaxScore < fMaxScore then
                set f.sr.score = f.sr.score + CST_MVP_Bonus
                set f.sr.MVPs = f.sr.MVPs + 1
                set f.sr.isMVP = true
            elseif  ( (hMaxScore == fMaxScore) and (GetRandomInt(1, 2)==1)) then
                set f.sr.score = f.sr.score + CST_MVP_Bonus
                set f.sr.MVPs = f.sr.MVPs + 1
                set f.sr.isMVP = true
            else//if hMaxScore >  fMaxScore then
                set h.sr.score = h.sr.score + CST_MVP_Bonus
                set h.sr.MVPs = h.sr.MVPs + 1
                set h.sr.isMVP = true
            endif
        else
            if hMaxScore >= CST_MVP_Base then
                set h.sr.score = h.sr.score + CST_MVP_Bonus
                set h.sr.MVPs = h.sr.MVPs + 1
                set h.sr.isMVP = true
            endif
        endif
        
        endif // >>
        call thistype.showAndSaveStats()
    endmethod
    
    static method showAndSaveStats takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        // Save the score and re-display the score column
        loop
            exitwhen f.end
            set f.sr.FarmerScore = f.sr.oldFarmerScore + f.sr.score
            set f.sr.Wealth = f.sr.Wealth + f.sr.wealth
            call f.sr.save(f.get)
            //set StatsBoard.fb[CST_BDCOL_SC][f.bIndex].text = I2S(f.sr.FarmerScore) + "(+" + I2S(f.sr.score) + ")"
            //set StatsBoard.hb[CST_BDCOL_SC][f.bIndex].text = I2S(f.sr.FarmerScore) + "(+" + I2S(f.sr.score) + ")"
            set StatsBoard.fb[CST_BDCOL_SC][f.bIndex].text = "+" + I2S(f.sr.score)
            set StatsBoard.hb[CST_BDCOL_SC][f.bIndex].text = "+" + I2S(f.sr.score)
            if f.sr.isMVP then
                set StatsBoard.fb[CST_BDCOL_SC][f.bIndex].icon = ICON_MVPCrown
                set StatsBoard.hb[CST_BDCOL_SC][f.bIndex].icon = ICON_MVPCrown
                call StatsBoard.fb[CST_BDCOL_SC][f.bIndex].setDisplay(true, true)
                call StatsBoard.hb[CST_BDCOL_SC][f.bIndex].setDisplay(true, true)
            endif
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set h.sr.HunterScore = h.sr.oldHunterScore + h.sr.score
            set h.sr.Merit = h.sr.Merit + h.sr.merit
            call h.sr.save(h.get)
            //set StatsBoard.fb[CST_BDCOL_SC][h.bIndex].text = I2S(h.sr.HunterScore) + "(+" + I2S(h.sr.score) + ")"
            //set StatsBoard.hb[CST_BDCOL_SC][h.bIndex].text = I2S(h.sr.HunterScore) + "(+" + I2S(h.sr.score) + ")"
            set StatsBoard.fb[CST_BDCOL_SC][h.bIndex].text = "+" + I2S(h.sr.score)
            set StatsBoard.hb[CST_BDCOL_SC][h.bIndex].text = "+" + I2S(h.sr.score)
            if h.sr.isMVP then
                set StatsBoard.fb[CST_BDCOL_SC][h.bIndex].icon = ICON_MVPCrown
                set StatsBoard.hb[CST_BDCOL_SC][h.bIndex].icon = ICON_MVPCrown
                call StatsBoard.fb[CST_BDCOL_SC][h.bIndex].setDisplay(true, true)
                call StatsBoard.hb[CST_BDCOL_SC][h.bIndex].setDisplay(true, true)
            endif
            set h = h.next
        endloop

        return false
    endmethod
    
    private static method updateScore takes nothing returns boolean
        call StatsManager.updateStats(true,false)
        return false
    endmethod
    
    // When timer otDetectionOn expire, we consider that player can have
    // some scores
    private static method afterGameStart takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            set f.sr.Rounds = f.sr.Rounds + 1
            set f.sr.Flees = f.sr.Flees + 1
            set f.sr.FarmerPlays = f.sr.FarmerPlays + 1
            set f.sr.FarmerScore = f.sr.oldFarmerScore + 2
            set f.sr.score = f.sr.score + 2
            //call f.sr.save(f.get)
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set h.sr.Rounds = h.sr.Rounds + 1
            set h.sr.Flees = h.sr.Flees + 1
            set h.sr.HunterPlays = h.sr.HunterPlays + 1
            set h.sr.HunterScore = h.sr.oldHunterScore + 2
            set h.sr.score = h.sr.score + 2
            //call h.sr.save(h.get)
            set h = h.next
        endloop
        
        call showAndSaveStats()
        return false
    endmethod
    
    // When timer otDetectionOff expire,that means few time left, 
    // we consider that player is a non-flee player although he can quit game earlier then
    // Also here is a candidate timepoint to calculate MVP
    private static method beforeGameTimeover takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        // Set the magnification
        call thistype.setMag()
        
        // From now, update scores every minitue
        call TimerManager.pt60s.register(Filter(function thistype.updateScore))
        
        loop
            exitwhen f.end
            set f.sr.Flees = f.sr.oldFlees
            //call f.sr.save(f.get)
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set h.sr.Flees = h.sr.oldFlees
            //call h.sr.save(h.get)
            set h = h.next
        endloop
        call StatsManager.updateStats(true,false)
        return false
    endmethod
    
    private static method init takes nothing returns boolean
        // Set the magnification
        call thistype.setMag()
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        //call TimerManager.otDetectionOn.register(Filter(function thistype.init))
        call TimerManager.otDetectionOn.register(Filter(function thistype.afterGameStart))
        call TimerManager.otDetectionOff.register(Filter(function thistype.beforeGameTimeover))
    endmethod

endstruct

// Statistics
module StatsBoardModule
    // Board Index
    integer bIndex
        
endmodule

    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
    endfunction

endlibrary
