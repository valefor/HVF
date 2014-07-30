library StatsManager initializer init /* v0.0.1 by Xandria
*/  uses    Alloc         /*
*/          TimeManager   /*
*/          YDWERecord    /*
********************************************************************************
*   Statistic Manager: Manage statistics of player
*******************************************************************************/

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
    static Board bd = -1
    
    static method createAndInit takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]
        local integer i = 2
        
        set bd = Board.create()
        call bd.clear()
        
        set bd.title = CST_STR_ScoreBoard
        // set statsBoard.all.width = 0.02
        call statsBoard.all.setDisplay(true, true)
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

    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
    endfunction

endlibrary
