library StatsManager initializer init /* v0.0.1 by Xandria
*/  uses    Alloc         /*
*/          TimeManager   /*
*/          YDWERecord    /*
********************************************************************************
*   Statistic Manager: Manage statistics of player
*******************************************************************************/

globals     

    // *** Board Icons
    // Common
    constant string ICON_Empty = "UI\\Widgets\\Console\\Undead\\undead-inventory-slotfiller.blp"
    constant string ICON_Farmer = "ReplaceableTextures\\CommandButtons\\BTNKobold.blp"
    constant string ICON_Gold = "UI\\Feedback\\Resources\\ResourceGold.blp"
    constant string ICON_Lumber = "UI\\Feedback\\Resources\\ResourceLumber.blp"
    constant string ICON_Crown = "ReplaceableTextures\\CommandButtons\\BTNCrownGold.blp"
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
    
    integer oldFlees
    
    public static method create takes player p returns thistype
        local thistype this = thistype.allocate()
        
        set .Rounds = YDWERecordGetI(p, CST_STR_11ProfRounds) + 1
        set .oldFlees= YDWERecordGetI(p, CST_STR_11ProfFlees)
        set .Flees  = oldFlees + 1
        
        set .WinRate     = YDWERecordGetI(p, CST_STR_11ProfWinRate)     
        set .HunterScore = YDWERecordGetI(p, CST_STR_11ProfHunterScore)
        set .FarmerScore = YDWERecordGetI(p, CST_STR_11ProfFarmerScore)
        set .Wealth      = YDWERecordGetI(p, CST_STR_11ProfWealth)
        set .Merit       = YDWERecordGetI(p, CST_STR_11ProfMerit)
        set .MVPs        = YDWERecordGetI(p, CST_STR_11ProfMVPs)
        
        set .Wins        = YDWERecordGetI(p, CST_STR_11ProfWins)
        set .HunterPlays = YDWERecordGetI(p, CST_STR_11ProfHunterPlays)
        set .HunterWins  = YDWERecordGetI(p, CST_STR_11ProfHunterWins)
        set .FarmerPlays = YDWERecordGetI(p, CST_STR_11ProfFarmerPlays)
        set .FarmerWins  = YDWERecordGetI(p, CST_STR_11ProfFarmerWins)
        
        call this.initSave(p)
        
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
        set .WinRate = R2I(.Wins/.Rounds)
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
        set hb[CST_BDCOL_SC][0].icon = ICON_Crown
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
        set fb[CST_BDCOL_SC][0].icon = ICON_Crown
        call fb[CST_BDCOL_SC][0].setDisplay(false, true)
        set fb[CST_BDCOL_TT][0].text = CST_STR_Title
        set fb[CST_BDCOL_RK][0].text = CST_STR_Rank
        set fb[0][1].text = CST_STR_Farmer
        set fb[0][1].color = COLOR_ARGB_RED
        loop
            exitwhen f.end
            set f.bIndex = i
            // Farmer
            set fb[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
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
            set fb[CST_BDCOL_RK][i].text = CST_STR_FRankLord
            set fb[CST_BDCOL_RK][i].icon = ICON_EMBLEM_Lord
            call fb[CST_BDCOL_RK][i].setDisplay(true, true)
            // Hunter
            set hb[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
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
            set hb[CST_BDCOL_RK][i].text = CST_STR_FRankLord
            set hb[CST_BDCOL_RK][i].icon = ICON_EMBLEM_Lord
            call hb[CST_BDCOL_RK][i].setDisplay(true, true)
            
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
            set fb[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
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
            set fb[CST_BDCOL_RK][i].text = CST_STR_HRankSoldier
            set fb[CST_BDCOL_RK][i].icon = ICON_MEDAL_Soldier
            call fb[CST_BDCOL_RK][i].setDisplay(true, true)
            // Hunter
            set hb[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
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
            set hb[CST_BDCOL_RK][i].text = CST_STR_HRankSoldier
            set hb[CST_BDCOL_RK][i].icon = ICON_MEDAL_Soldier
            call hb[CST_BDCOL_RK][i].setDisplay(true, true)
            set i = i + 1
            set h = h.next
        endloop

        // Set column width
        set hb.all.width = 0.02
        set fb.all.width = 0.02
        set hb.col[CST_BDCOL_PN].width = 0.07
        set hb.col[CST_BDCOL_TT].width = 0.07
        set hb.col[CST_BDCOL_RK].width = 0.07
        
        set fb.col[CST_BDCOL_PN].width = 0.07
        set fb.col[CST_BDCOL_TT].width = 0.07
        set fb.col[CST_BDCOL_RK].width = 0.07
        
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
        set h = Hunter[Hunter.first]
        set f = Farmer[Farmer.first] 
        loop
            exitwhen f.end
            set fb.visible[f.get] = true
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set hb.visible[h.get] = true
            set h = h.next
        endloop
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerManager.onGameStart.register(Filter(function thistype.createAndInit))
    endmethod
endstruct

struct StatsManager extends array   

    public static method isIn11Platform takes nothing returns boolean
        return YDWEPlatformIsInPlatform()
    endmethod
    
    static method updateGlobalStats takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        // Calculate who is the MVP
        loop
            exitwhen f.end
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set h = h.next
        endloop
        return false
    endmethod
    
    // When timer otDetectionOn expire, we consider that player can have
    // some scores
    private static method afterGameStart takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            call f.sr.save(f.get)
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            call h.sr.save(h.get)
            set h = h.next
        endloop
        return false
    endmethod
    
    // When timer otDetectionOff expire,that means few time left, 
    // we consider that player is a non-flee player although he can quit game earlier then
    // Also here is a candidate timepoint to calculate MVP
    private static method beforeGameTimeover takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            set f.sr.Flees = f.sr.oldFlees
            call f.sr.save(f.get)
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            set h.sr.Flees = h.sr.oldFlees
            call h.sr.save(h.get)
            set h = h.next
        endloop
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
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
