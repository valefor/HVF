/*******************************************************************
*       _   ___  ___
*      /_\ / __|/ __|
*     / _ \\__ \\__ \
*    /_/ \_|___//___/
*    v5.1.1.0
*    By Magtheridon96
*
*    - This is an advanced player streak system.
*       - Features:
*           - Kill Streaks
*           - Multikills
*           - Assists
*           - Combo-breaker
*           - Streak/Multikill/Combo-breaker sounds
*           - Texttags for Gold Gaining/Losing after each kill
*           - Storage for total kills, deaths, assists, suicides, 
*             denies, streaks, multikills, streaks of any type,
*             multikills of any type and combobreakers.
*           - Events for everything except assists
*           - Useful Event-responses
*       - It is:
*           - Dynamic
*           - Easy to Use
*           - Easy to Configure
*           - Very Configurable
*
*       - It also supports a lot of systems.
*         AutoIndex was not supported because the only damage detection
*         systems that were written based on it were far too troublesome.
*
*   Requirements:
*   -------------
*
*       - A Damage Detection System.
*         Supports:
*               - DamageEvent   By Nestharus        (hiveworkshop.com/forums/jass-resources-412/snippet-damageevent-186829/)
*               - Damage        By Jesus4Lyf        (thehelper.net/forums/showthread.php/131287-Damage)
*               - Damage        By Dirac            (thehelper.net/forums/showthread.php/168144-Damage-Struct)
*
*       - A Unit Indexer.
*         Supports:
*               - UnitIndexer   By Nestharus        (hiveworkshop.com/forums/jass-resources-412/system-unit-indexer-172090/)
*               - AIDS          By Jesus4Lyf        (thehelper.net/forums/showthread.php/130752-Advanced-Indexing-Data-Storage)
*
*       - A Sound System.
*         Supports:
*               - SoundTools    By Magtheridon96    (hiveworkshop.com/forums/jass-resources-412/system-soundtools-207308/)
*               - SoundUtils    By Rising_Dusk      (wc3c.net/showthread.php?t=107433)
*
*       - An Event Handler.
*         Supports:
*               - Event         By Nestharus        (hiveworkshop.com/forums/jass-resources-412/snippet-event-186555/)
*               - Event         By Jesus4Lyf        (thehelper.net/forums/showthread.php/126846-Event)
*
*       - Table By Bribe
*           - hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
*       - TimerUtils By Vexorian
*           - wc3c.net/showthread.php?t=101322
*
*       Optional:
*       ---------
*
*           - RegisterPlayerUnitEvent By Magtheridon96
*               - hiveworkshop.com/forums/jass-resources-412/snippet-registerplayerunitevent-203338/
*
*   Configurable Functions:
*   -----------------------
*
*       - function GetBounty           takes integer killerPlayerId, integer dyingPlayerId, unit killingUnit, unit dyingUnit                                                 returns integer
*       - function GetLostGold         takes integer killerPlayerId, integer dyingPlayerId, unit killingUnit, unit dyingUnit, integer killingBounty                          returns integer
*       - function GetAssistGold       takes integer killerPlayerId, integer dyingPlayerId, unit killingUnit, unit dyingUnit, integer killingBounty, integer numberAssisters returns integer
*
*       - function KillingPlayerFilter takes integer playerId                                                                                                                returns boolean
*       - function AssistPlayerFilter  takes integer playerId                                                                                                                returns boolean
*       - function DyingPlayerFilter   takes integer playerId                                                                                                                returns boolean
*
*       - function GetFirstbloodString takes string killingName                                                                                                              returns string
*       - function GetKillString       takes string killingName, string dyingName, string bounty                                                                             returns string
*       - function GetEndString        takes string killingName, string dyingName, string streak, string bounty                                                              returns string
*
*       - function GetSuicideString    takes integer killingPlayerId, string killingName                                                                                     returns string
*       - function GetDenialString     takes integer killingPlayerId, string killingName, integer dyingPlayerId, string dyingName                                            returns string
*
*   How To Import:
*   --------------
*
*       1- The first thing you need to do is import the required systems and set them up.
*          This system supports DamageEvent by Nestharus, Damage by Jesus4Lyf and Damage
*          by Dirac. In the Demo map, DamageEvent and all of the systems it uses including
*          UnitIndexer are enabled. To import all the needed scripts, just copy and paste
*          whatever is not disabled.
*
*          There are some systems that require more than just simple copying and pasting 
*          though. UnitIndexer requires you to import the Undefend-based ability and configure
*          the ability Id in the globals of the code.
*
*       2- Now that all your systems are implemeted, you should configure this system.
*          After this documentation, there is a globals block. You need to configure it
*          based on the systems you implemented/are using.
*
*       3- Now, you need to configure the rest of the globals and functions to your liking.
*
*       4- Read the 'Setup' section of this documentation to understand how to configure
*          and create streaks and multikills. You will need to define the streaks and 
*          multikills you want, else you will have fatal errors.
*
*       5- Test this system. If certain errors occur during initialization, the system
*          will notify you and exit Warcraft III.
*
*   Setup:
*   ------
*
*       - You will face fatal errors if you do not setup this system.
*       - It is very important that you read these.
*       
*       Streaks:
*       --------
*
*           - The first thing you need to do is set the minimum streak index:
*
*               call StreakSystem.setMinimumStreak(3)
*
*           - This means that 3 kills will give you the first streak.
*           - Now, we need to start creating the streaks.
*           - We will call the function newStreak like this:
*
*               call StreakSystem.newStreak("haxxor spree", "is on a haxxor spree", "war3mapImported\\HaxxingSpree.mp3", 2489)
*
*           - The first parameter is the name of this spree. This string will be 
*             used for the text that is displayed when a player ends a streak.
*           - The second parameter is the string snippet that is displayed when
*             a player achieves a certain streak. It is concatenated with the name
*             of the player of course.
*           - The third parameter is the filepath of the sound that is played
*             when a player achieves a certain streak.
*           - The fourth parameter is the duration of the sound in milliseconds.
*
*       Multikills:
*       -----------
*
*           - With this setup, there is no catch. You would start calling newMultikill
*             immediately.
*
*               call StreakSystem.newMultikill("got a Triple Kill!", "war3mapImported\\tripleKIll.wav", 1991)
*
*           - The first parameter is the string snippet that is displayed when
*             a player achieves a certain multikill. It is concatenated with the
*             name of the player of course.
*           - The second parameter is the filepath of the sound that is played
*             when a player achieves a certain streak.
*           - The third parameter is the duration of the sound in milliseconds.
*
*       Firstblood:
*       -----------
*
*           - The only thing that can be configured externally is the firstblood sound.
*           - The firstblood string can be configured using the configurable function
*             mentioned above: GetFirstbloodString
*
*               call StreakSystem.setFirstBloodSound("war3mapImported\\firstblood.wav", 1230)
*
*           - The first parameter is the filepath of the sound that is played
*             when a player achieves firstblood.
*           - The second parameter is the duration of the sound in milliseconds.
*
*       Combobreaker:
*       -------------
*
*           - To configure the combo-breaker sound, we use the following function:
*
*               call StreakSystem.setComboBreakerSound("war3mapImported\\combobreaker.wav", 2102)
*
*           - The first parameter is the filepath of the sound that is played
*             when a player breakes a combo.
*           - The second parameter is the duration of the sound in milliseconds.
*
*   Event Responses:
*   ----------------
*
*       - StreakSystem.getKillingUnitId()
*       - StreakSystem.getKillingUnit()
*       - StreakSystem.getDyingUnitId()
*       - StreakSystem.getDyingUnit()
*       - StreakSystem.getKillingPlayerId()
*       - StreakSystem.getKillingPlayer()
*       - StreakSystem.getDyingPlayerId()
*       - StreakSystem.getDyingPlayer()
*           - For: FIRSTBLOOD, STREAK, END_STREAK, MULTIKILL, COMBO_BREAKER, SUICIDE, DENIAL
*           - These can be used inside END_MULTIKILL if DEATH_END_MULTI is set to true. They will only
*             return valid data if a unit dies and loses a multikill.
*           - Warning: Calling StreakSystem.getKillingPlayer() or StreakSystem.getDyingPlayer() inside
*             a function registered to END_MULTIKILL will crash the game if the multikill simply faded.
*             Use the Id counterparts instead.
*
*       - StreakSystem.getEndedMultikill()
*       - StreakSystem.getMultikillLoserId()
*       - StreakSystem.getMultikillLoser()
*           - For: END_MULTIKILL
*
*       - StreakSystem.getAchievedStreak()
*           - For: STREAK
*       - StreakSystem.getEndedStreak()
*           - For: END_STREAK
*       - StreakSystem.getAchievedMultikill()
*           - For: MULTIKILL
*       - StreakSystem.getComboBroken()
*           - For: COMBO_BREAKER
*
*   API:
*   ----
*
*       - struct StreakSystem extends array
*
*           - static boolean enabled
*               - Tells whether the system is enabled or not.
*           - static boolean firstblood
*               - Tells whether firstblood was taken or not.
*
*           - static Event FIRSTBLOOD
*               - This event fires when a hero takes firstblood
*           - static Event STREAK
*               - This event fires when a hero is on a streak
*           - static Event MULTIKILL
*               - This event fires when a hero gets a multikill
*           - static Event END_STREAK
*               - This event fires when a streak is ended
*           - static Event END_MULTIKILL
*               - This event fires when a multikill is no longer valid
*           - static Event COMBO_BREAKER
*               - This event fires when a hero gets a combo-breaker
*           - static Event SUICIDE
*               - This event fires when a hero kills himself
*           - static Event DENIAL
*               - This event fires when a hero kills his own ally
*
*           - static method newStreak takes string streakName, string streakDisplay, string soundPath, integer duration returns nothing
*           - static method newMultikill takes string text, string soundPath, integer duration returns nothing
*               - These two functions create a streak-type and a multikill-type. The duration is in milliseconds.
*               - Since it is not very clear what the arguments should be, here is an example:
*                   - call StreakSystem.newStreak("killing spree", "is on a killing spree!", "war3mapImported\\KillingSpree.mp3", 2489)
*                   - call StreakSystem.newMultikill("is on a Rampage!!!", "war3mapImported\\Rampage.wav", 1991)
*               - As you can see, the function newStreak takes the name of the streak, then the form of the 
*                 streak message, then the path of the streak sound and finally, the duration of the streak 
*                 sound in milliseconds. The newMultikill function takes the form of the multikill message,
*                 then the path of the multikill sound and finally, the duration of that sound in milliseconds.
*
*           - static method setFirstBloodSound takes string path, integer duration returns nothing
*           - static method setComboBreakerSound takes string path, integer duration returns nothing
*               - These two functions are used to configure the sounds that are played when a player gets 
*                 firstblood/a combo-breaker.
*
*           - static method setMinimumStreak takes integer i returns nothing
*               - This sets the minimum streak value.
*
*           - static method setColor takes integer playerId, string color returns nothing
*               - This function reconfigures the player color used in the system.
*                 Player colors are already configured by default, but you may 
*                 need this just in case player colors change in-game.
*
*           - static method getKillingUnitId takes nothing returns UnitIndex
*           - static method getKillingUnit takes nothing returns unit
*           - static method getDyingUnitId takes nothing returns UnitIndex
*           - static method getDyingUnit takes nothing returns unit
*           - static method getKillingPlayerId takes nothing returns integer
*           - static method getKillingPlayer takes nothing returns player
*           - static method getDyingPlayerId takes nothing returns integer
*           - static method getDyingPlayer takes nothing returns player
*               - These functions retrieve the killing players and units and the 
*                 dying units and players for event responses.
*
*           - static method getAchievedStreak takes nothing returns integer
*           - static method getEndedStreak takes nothing returns integer
*           - static method getAchievedMultikill takes nothing returns integer
*           - static method getEndedMultikill takes nothing returns integer
*           - static method getMultikillLoserId takes nothing returns integer
*           - static method getMultikillLoser takes nothing returns player
*           - static method getComboBroken takes nothing returns integer
*               - These functions retrieve the streak and multikill data for
*                 for event responses.
*            
*           - static method getKills takes player whichPlayer returns integer
*           - static method getDeaths takes player whichPlayer returns integer
*           - static method getDenies takes player whichPlayer returns integer
*           - static method getSuicides takes player whichPlayer returns integer
*           - static method getAssists takes player whichPlayer returns integer
*           - static method getStreaks takes player whichPlayer returns integer
*           - static method getMultikills takes player whichPlayer returns integer
*           - static method getCombobreakers takes player whichPlayer returns integer
*           - static method getMultikillsOfType takes player whichPlayer returns integer
*           - static method getStreaksOfType takes player whichPlayer returns integer
*               - These functions are used to get the total stats of a player.
*
*           - static method getKillsById takes integer playerId returns integer
*           - static method getDeathsById takes integer playerId returns integer
*           - static method getDeniesById takes integer playerId returns integer
*           - static method getSuicidesById takes integer playerId returns integer
*           - static method getAssistsById takes integer playerId returns integer
*           - static method getStreaksById takes integer playerId returns integer
*           - static method getMultikillsById takes integer playerId returns integer
*           - static method getCombobreakersById takes integer playerId returns integer
*           - static method getMultikillsOfTypeById takes integer playerId returns integer
*           - static method getStreaksOfTypeById takes integer playerId returns integer
*               - These functions are used to get the total stats of a player given his Id.
*
*           - static method getCurrentStreak takes player p returns integer
*           - static method getCurrentMultikill takes player p returns integer
*               - These functions are used to get the current streak of a player
*                 or his current multikills.
*
*           - static method getCurrentStreakById takes integer playerId returns integer
*           - static method getCurrentMultikillById takes integer playerId returns integer
*               - These functions are used to get the current streak of a player
*                 or his current multikills given his Id.
*
*           - static method resetStreak takes integer playerId returns nothing
*           - static method resetStreaks takes nothing returns nothing
*               - These functions are used to either reset the streak of one or all players.
*
*           - static method resetAssist takes integer unitId returns nothing
*           - static method resetAssists takes nothing returns nothing
*               - These functions are used to either reset the streak associated with one or all units.
*
*           - static method operator goldGain takes nothing returns boolean
*           - static method operator goldGain= takes boolean b returns nothing
*           - static method operator goldLoss takes nothing returns boolean
*           - static method operator goldLoss= takes boolean b returns nothing
*               - Management of KillingPlayer-Goldgain and DyingPlayer-Goldloss.
*
*           - static method operator bountyBase takes nothing returns integer
*           - static method operator bountyBase= takes integer i returns nothing
*           - static method operator bountyIncrement takes nothing returns integer
*           - static method operator bountyIncrement= takes integer i returns nothing
*               - Management of Bounty Formula.
*
*******************************************************************/
library ASS requires optional DamageEvent, optional Damage, optional UnitIndexer, optional AIDS, optional SoundTools, optional SoundUtils, Table, optional RegisterPlayerUnitEvent, TimerUtils, Event

    /*
    *   Configuration
    */
    globals
        /*
        *   Whether you have Event by Nestharus or Jesus4Lyf is unknown to me.
        *   Hence, I put up this boolean for configuration. If you are using
        *   Damage and thus AIDS and Event by Jesus4Lyf, then set this to false.
        */
        private constant boolean EVENT_BY_NESTHARUS = true
        /*
        *   Whether you have Damage by Jesus4Lyf or Dirac is unknown to me.
        *   Hence, I put up this boolean for configuration.
        */
        private constant boolean DAMAGE_BY_JESUS4LYF = false
    endglobals
    
    /*
    *   System Configuration
    */
    globals
        // Max interval between Multikills (seconds)
        private constant    real            MULTI_TIME              = 10
        // Multikill Update Interval (seconds)
        private constant    real            MULTI_UPDATE            = 1
        // Are sounds 3D?
        private constant    boolean         S3D                     = false
        // Firstblood bonus
        private constant    integer         FIRST_GOLD              = 200
        // Duration of the text messages
        private constant    real            TEXT_DURATION           = 8.00
        // Interval between streak and multikill sounds
        private constant    real            INTERVAL                = 0.50
        // Assist Decay time (seconds)
        private constant    real            ASSIST_DECAY            = 45
        // Assist Update Interval (seconds)
        private constant    real            ASSIST_UPDATE           = 1
        // Can the heroes of leavers get streaks?
        private constant    boolean         LEAVER_HEROES           = true
        // Leavers can assist?
        private constant    boolean         LEAVER_CAN_ASSIST       = true
        // Initial Gold base
        private             integer         baseGold                = 210
        // Gold increment according to formulas
        private             integer         goldIncrement           = 10
        // Do you lose gold when you die?
        private             boolean         loseGold                = true
        // Do you gain gold when you kill?
        private             boolean         gainGold                = true
        // Do you want floating texts?
        private constant    boolean         TEXTTAGS                = true
        // Texttag configuration: Age
        private constant    real            TEXTTAG_AGE             = 2.
        // Texttag configuration: Fade-point
        private constant    real            TEXTTAG_FADE            = 1.5
        // Texttag configuration: Size
        private constant    real            TEXTTAG_SIZE            = 0.024
        // Texttag configuration: Velocity X
        private constant    real            TEXTTAG_X               = 0.
        // Texttag configuration: Velocity Y
        private constant    real            TEXTTAG_Y               = 0.0355
        // Give gold to assisters?
        private constant    boolean         ASSIST_GOLD             = true
        // Does Suicide end a streak?
        private constant    boolean         SUICIDE_ENDS            = true
        // When you deny a hero, do you get a kill?
        private constant    boolean         DENIES_COUNT_KILLS      = false
        // When you get denied, do you get a death?
        private constant    boolean         DENIES_COUNT_DEATHS     = false
        // Does suicide count as a death?
        private constant    boolean         SUICIDE_DEATH           = true
        // Does a Death end a multikill?
        private constant    boolean         DEATH_END_MULTI         = false
        // Do you want to have the Combo-breaker message and sound feature?
        private constant    boolean         COMBO_BREAKER           = true
        // Minimum Streak to end to get a Combo-breaker
        private constant    integer         COMBO_BREAKER_MIN       = 3
        // Should the suicide event fire before the end streak event? Or after?
        // This is only important if SUICIDE_ENDS is set to true.
        private constant    boolean         SUICIDE_FIRE_FIRST      = true
    endglobals
    
    private keyword Streak
    private keyword Multikill
    
    private function GetBounty takes integer killingId, integer dyingId, unit killingUnit, unit dyingUnit returns integer
        return baseGold + goldIncrement * Streak[dyingId] + goldIncrement * Streak[killingId]
    endfunction
    
    private function GetLostGold takes integer killingId, integer dyingId, unit killingUnit, unit dyingUnit, integer gold returns integer
        return gold / 3
    endfunction
    
    private function GetAssistGold takes integer killingId, integer dyingId, unit killingUnit, unit dyingUnit, integer gold, integer numberAssisters returns integer
        return gold / numberAssisters
    endfunction
    
    private function KillingPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function AssistPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function DyingPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function StreakPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function MultikillPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function CombobreakerPlayerFilter takes integer playerId returns boolean
        return playerId < 12
    endfunction
    
    private function GetFirstbloodString takes string killingName returns string
        return killingName + " just drew |cffff0000firstblood|r!"
    endfunction
    
    private function GetKillString takes string killingName, string dyingName, string bounty returns string
        return killingName + " pwned " + dyingName + "'s head for |cffffcc00" + bounty + "|r gold."
    endfunction
    
    private function GetEndString takes string killingName, string dyingName, string streak, string bounty returns string
        return dyingName + streak + " streak has been ended by " + killingName + " for |cffffcc00" + bounty + "|r gold."
    endfunction
    
    private function GetSuicideString takes string dyingName returns string
        return dyingName + "|r has killed himself!"
    endfunction
    
    private function GetDenialString takes string killingName, string dyingName returns string
        return killingName + "|r has denied his ally " + dyingName + "|r!"
    endfunction
    
    private module Init
        private static method onInit takes nothing returns nothing
            /*
            *   Player color strings configuration.
            */
            set thistype.colors[0]  = "|cffff0303"
            set thistype.colors[1]  = "|cff0042ff"
            set thistype.colors[2]  = "|cff1ce6b9"
            set thistype.colors[3]  = "|cff540081"
            set thistype.colors[4]  = "|cfffffc01"
            set thistype.colors[5]  = "|cfffeba0e"
            set thistype.colors[6]  = "|cff20c000"
            set thistype.colors[7]  = "|cffe55bb0"
            set thistype.colors[8]  = "|cff959697"
            set thistype.colors[9]  = "|cff7ebff1"
            set thistype.colors[10] = "|cff106246"
            set thistype.colors[11] = "|cff4e2a04"
        endmethod
    endmodule
    
    /*
    *   Configuration Ends Here
    */
    
    private struct PlayerActive extends array
        private static boolean array playerOff
        static method operator [] takes integer i returns boolean
            return not playerOff[i]
        endmethod
        private static method run takes nothing returns boolean
            set playerOff[GetPlayerId(GetTriggerPlayer())] = true
            return false
        endmethod
        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            local integer i = 15
            loop
                call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE)
                exitwhen i == 0
                set i = i - 1
            endloop
            call TriggerAddCondition(t, Condition(function thistype.run))
            set t = null
        endmethod
    endstruct
    
    private module InitEventHandler
        private static method onInit takes nothing returns nothing
            set FIRSTBLOOD = Event.create()
            set STREAK = Event.create()
            set MULTIKILL = Event.create()
            set END_STREAK = Event.create()
            set END_MULTIKILL = Event.create()
            set COMBO_BREAKER = Event.create()
            set SUICIDE = Event.create()
            set DENIAL = Event.create()
        endmethod
    endmodule
    
    private struct EventHandler extends array
        readonly static Event FIRSTBLOOD
        readonly static Event STREAK
        readonly static Event MULTIKILL
        readonly static Event END_STREAK
        readonly static Event END_MULTIKILL
        readonly static Event COMBO_BREAKER
        readonly static Event SUICIDE
        readonly static Event DENIAL
        
        static integer killingUnitId = 0
        static integer dyingUnitId = 0
        static integer killingPlayerId = 0
        static integer dyingPlayerId = 0
        static integer streakAchieved = 0
        static integer streakEnded = 0
        static integer multikillAchieved = 0
        static integer multikillEnded = 0
        static integer multikillLoserId = 0
        static integer comboBroken = 0
        static unit dyingUnit = null
        static unit killingUnit = null
        
        implement InitEventHandler
    endstruct
    
    private struct Multikill extends array
        private static integer array value
        private static real array counters
        
        method operator multikill takes nothing returns integer
            return value[this]
        endmethod
        
        method operator multikill= takes integer i returns nothing
            set value[this] = i
        endmethod
        
        method operator counter takes nothing returns real
            return counters[this]
        endmethod
        
        method operator counter= takes real r returns nothing
            set counters[this] = r
        endmethod
        
        static method reset takes integer this returns nothing
            set value[this] = 0
            set counters[this] = 0
        endmethod
        
        static method resetAll takes nothing returns nothing
            local integer i = 15
            loop
                call reset(i)
                exitwhen i == 0
                set i = i - 1
            endloop
        endmethod
        
        private static method updateMulti takes nothing returns nothing
            local integer index = 15
            loop
                set counters[index] = counters[index] - MULTI_UPDATE
                
                if counters[index] <= 0 then
                    /*
                    *   Cache Event Response Data and Fire Event.
                    */
                    set EventHandler.multikillLoserId = index
                    set EventHandler.multikillEnded = value[index]
                    set value[index] = 0
                    
                    set EventHandler.killingUnitId = 0
                    set EventHandler.dyingUnitId = 0
                    set EventHandler.killingUnit = null
                    set EventHandler.dyingUnit = null
                    set EventHandler.killingPlayerId = -1
                    set EventHandler.dyingPlayerId = -1
                    
                    call EventHandler.END_MULTIKILL.fire()
                endif
                
                exitwhen index == 0
                set index = index - 1
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerStart(CreateTimer(), MULTI_UPDATE, true, function thistype.updateMulti)
        endmethod
    endstruct
    
    private struct Streak extends array
        private static integer array value
        
        static method operator [] takes integer i returns integer
            return value[i]
        endmethod
        
        static method operator []= takes integer i, integer v returns nothing
            set value[i] = v
        endmethod
        
        static method reset takes integer i returns nothing
            set value[i] = 0
        endmethod
        
        static method resetAll takes nothing returns nothing
            local integer i = 15
            loop
                call reset(i)
                exitwhen i == 0
                set i = i - 1
            endloop
        endmethod
    endstruct
    
    private function Exit takes nothing returns nothing
        loop
            call ExecuteFunc(Exit.name)
        endloop
    endfunction
    
    private struct Assist extends array
        private static Table array counters
        private static Table array assisting
        
        private static integer array count
        private static integer array next
        private static integer array prev
        private static boolean array inList
        private static boolean array allocated
        
        static method operator [] takes integer i returns thistype
            return i
        endmethod
        
        method operator [] takes integer i returns boolean
            return assisting[this].boolean[i]
        endmethod
        
        method operator []= takes integer i, boolean b returns nothing
            set assisting[this].boolean[i] = b
        endmethod
        
        method operator counter takes nothing returns integer
            return counters[this]
        endmethod
        
        method operator counter= takes integer i returns nothing
            set counters[this] = i
        endmethod
        
        method operator number takes nothing returns integer
            return count[this]
        endmethod
        
        method operator number= takes integer i returns nothing
            set count[this] = i
        endmethod
        
        static method reset takes integer unitId returns nothing
            /*
            *   Set the number of assisting players to 0,
            *   and flush all the data in the tables.
            */
            set count[unitId] = 0
            call assisting[unitId].flush()
            call counters[unitId].flush()
        endmethod
        
        static method resetAll takes nothing returns nothing
            local integer this = next[0]
            loop
                exitwhen this == 0
                call reset(this)
                set this = next[this]
            endloop
        endmethod
        
        static if not LIBRARY_UnitIndexer and not LIBRARY_AIDS then
            private static unit crashThread
            private static integer crashThreadInt
        endif
        
        private static method getIndexed takes nothing returns unit
            static if LIBRARY_UnitIndexer then
                return GetIndexedUnit()
            elseif LIBRARY_AIDS then
                return AIDS_GetEnteringIndexUnit()
            else
                return crashThread
            endif
        endmethod
        
        private static method getIndexedId takes nothing returns integer
            static if LIBRARY_UnitIndexer then
                return GetIndexedUnitId()
            elseif LIBRARY_AIDS then
                return AIDS_GetIndexOfEnteringUnitAllocated()
            else
                return crashThreadInt
            endif
        endmethod
        
        private static method getDeindexed takes nothing returns unit
            static if LIBRARY_UnitIndexer then
                return GetIndexedUnit()
            elseif LIBRARY_AIDS then
                return GetIndexUnit(AIDS_GetDecayingIndex())
            else
                return crashThread
            endif
        endmethod
        
        private static method getDeindexedId takes nothing returns integer
            static if LIBRARY_UnitIndexer then
                return GetIndexedUnitId()
            elseif LIBRARY_AIDS then
                return AIDS_GetDecayingIndex()
            else
                return crashThreadInt
            endif
        endmethod
        
        private static method index takes nothing returns boolean
            if IsUnitType(getIndexed(), UNIT_TYPE_HERO) then
                /*
                *   Make sure tables are initialized
                */
                if counters[getIndexedId()] == 0 then
                    set counters[getIndexedId()] = Table.create()
                    set assisting[getIndexedId()] = Table.create()
                endif
                set allocated[getIndexedId()] = true
            endif
            return false
        endmethod
        
        private static method deindex takes nothing returns boolean
            if IsUnitType(getDeindexed(), UNIT_TYPE_HERO) then
                /*
                *   Reset data
                */
                set count[getDeindexedId()] = 0
                call counters[getDeindexedId()].flush()
                call assisting[getDeindexedId()].flush()
                set allocated[getDeindexedId()] = false
            endif
            return false
        endmethod
        
        private static integer damageTargetId = 0
        private static integer damageSourceId = 0
        private static unit damageTarget = null
        
        private static method filter takes player p, integer id returns boolean
            static if LEAVER_CAN_ASSIST then
                return allocated[damageTargetId] and AssistPlayerFilter(id) and damageSourceId != 0 and (not assisting[damageTargetId].boolean[id]) and IsUnitEnemy(damageTarget, p) and damageSourceId != damageTargetId
            else
                return allocated[damageTargetId] and AssistPlayerFilter(id) and damageSourceId != 0 and (not assisting[damageTargetId].boolean[id]) and IsUnitEnemy(damageTarget, p) and damageSourceId != damageTargetId and PlayerActive[id]
            endif
        endmethod
        
        private static method onDamage takes nothing returns boolean
            local integer id
            local player p
            
            /*
            *   Data configuration based on system implemented.
            */
            static if LIBRARY_DamageEvent then
                set p = GetOwningPlayer(DamageEvent.source)
                set id = GetPlayerId(p)
                set damageTarget = DamageEvent.target
                set damageTargetId = DamageEvent.targetId
                set damageSourceId = DamageEvent.sourceId
            elseif LIBRARY_Damage then
                static if DAMAGE_BY_JESUS4LYF then
                    set p = GetOwningPlayer(GetEventDamageSource())
                    set id = GetPlayerId(p)
                    set damageTarget = GetTriggerUnit()
                    set damageTargetId = GetUnitId(damageTarget)
                    set damageSourceId = GetUnitId(GetEventDamageSource())
                else
                    set p = GetOwningPlayer(Damage.source)
                    set id = GetPlayerId(p)
                    set damageTarget = Damage.target
                    set damageTargetId = Damage.targetId
                    set damageSourceId = Damage.sourceId
                endif
            endif
            
            if filter(p, id) then
                
                /*
                *   If the target is not in the list, we add him.
                */
                if not inList[damageTargetId] then
                    set inList[damageTargetId] = true
                    set next[damageTargetId] = 0
                    set prev[damageTargetId] = prev[0]
                    set next[prev[0]] = damageTargetId
                    set prev[0] = damageTargetId
                endif
                
                /*
                *   Mark player as assisting, increase assister count and reset assist counter
                */
                set assisting[damageTargetId].boolean[id] = true
                set count[damageTargetId] = count[damageTargetId] + 1
                set counters[damageTargetId].real[id] = ASSIST_DECAY
            endif
            
            set p = null
            return false
        endmethod
        
        private static method updateAssist takes nothing returns nothing
            local integer assist = next[0]
            local integer index = 15
            local real n = 0
            loop
                exitwhen assist == 0
                loop
                    if assisting[assist].boolean[index] then
                        set n = counters[assist].real[index] - ASSIST_UPDATE
                        set counters[assist].real[index] = n
                        
                        if n <= 0 then
                            /*
                            *   Mark the player as not assisting, decrease
                            *   the assisting player count, and check if we
                            *   can remove the target from the assists list
                            */
                            set assisting[assist].boolean[index] = false
                            set count[assist] = count[assist] - 1
                            if count[assist] == 0 then
                                set prev[next[assist]] = prev[assist]
                                set next[prev[assist]] = next[assist]
                                set inList[assist] = false
                            endif
                        endif
                    endif
                    
                    exitwhen index == 0
                    set index = index - 1
                endloop
                set index = 15
                set assist = next[assist]
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            static if LIBRARY_Damage then
                local trigger t = CreateTrigger()
            endif
            static if LIBRARY_UnitIndexer then
                call RegisterUnitIndexEvent(Condition(function thistype.index), UnitIndexer.INDEX)
                call RegisterUnitIndexEvent(Condition(function thistype.deindex), UnitIndexer.DEINDEX)
            elseif LIBRARY_AIDS then
                call AIDS_RegisterOnEnterAllocated(Condition(function thistype.index))
                call AIDS_RegisterOnDeallocate(Condition(function thistype.deindex))
            else
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "ERROR: NO UNIT INDEXING SYSTEM FOUND.")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "SHUTING DOWN IN: 5")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "4")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "3")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "2")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "1")
                call TriggerSleepAction(1)
                call Exit()
            endif
            
            static if LIBRARY_DamageEvent then
                call DamageEvent.ANY.register(Condition(function thistype.onDamage), 0)
            elseif LIBRARY_Damage then
                static if DAMAGE_BY_JESUS4LYF then
                    call Damage_RegisterEvent(t)
                    call TriggerAddCondition(t, Condition(function thistype.onDamage))
                    set t = null
                else
                    call RegisterGlobalDamage(function thistype.onDamage)
                endif
            else
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "ERROR: NO DAMAGE DETECTING SYSTEM FOUND.")
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "SHUTING DOWN IN: 5")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "4")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "3")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "2")
                call TriggerSleepAction(1)
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "1")
                call TriggerSleepAction(1)
                call Exit()
            endif
            
            call TimerStart(CreateTimer(), ASSIST_UPDATE, true, function thistype.updateAssist)
        endmethod
    endstruct
    
    private struct MessageHandler extends array
        private static string queue = ""
        
        static method print takes string s returns nothing
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, TEXT_DURATION, s)
        endmethod
        
        static method enqueue takes string s returns nothing
            set queue = queue + s + "\n"
        endmethod
        
        static method printQueue takes nothing returns nothing
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, TEXT_DURATION, queue)
        endmethod
        
        static method clearQueue takes nothing returns nothing
            set queue = ""
        endmethod
    endstruct
    
    static if TEXTTAGS then
        private struct TextTagHandler extends array
            private static method createText takes player p, real cameraCenter, string s returns nothing
                local texttag tag = CreateTextTag()
                call SetTextTagText(tag, s, TEXTTAG_SIZE)
                call SetTextTagPos(tag, GetCameraEyePositionX(), GetCameraEyePositionY() + cameraCenter, 16.0)
                call SetTextTagVelocity(tag, TEXTTAG_X, TEXTTAG_Y)
                call SetTextTagVisibility(tag, GetLocalPlayer() == p)
                call SetTextTagFadepoint(tag, TEXTTAG_FADE)
                call SetTextTagLifespan(tag, TEXTTAG_AGE)
                call SetTextTagPermanent(tag, false)
                set tag = null
            endmethod
            
            static method plus takes player p, real cameraCenter, string s returns nothing
                call createText(p, cameraCenter, "|cffffcc00+" + s)
            endmethod
            
            static method minus takes player p, real cameraCenter, string s returns nothing
                call createText(p, cameraCenter, "|cffff0000-" + s)
            endmethod
        endstruct
    endif
    
    private struct PlayerStatHandler extends array
        static integer array kills
        static integer array deaths
        static integer array assists
        static integer array denies
        static integer array suicides
        
        static integer array streaks
        static integer array multikills
        static integer array combobreakers
        
        static Table array streakTypes
        static Table array multikillTypes
        
        private static method onInit takes nothing returns nothing
            local integer i = 15
            loop
                set streakTypes[i] = Table.create()
                set multikillTypes[i] = Table.create()
                exitwhen i == 0
                set i = i - 1
            endloop
        endmethod
    endstruct
    
    struct StreakSystem extends array
        private static integer maxStreak = 0
        private static integer minStreak = 0
        private static integer maxMultikill = 1
        
        static if LIBRARY_SoundTools then
            private static Sound firstSound
            private static Sound comboBreaker
            
            private static Sound array sounds
            private static Sound array multiSound
        elseif LIBRARY_SoundUtils then
            private static integer firstSound
            private static integer comboBreaker
            
            private static integer array sounds
            private static integer array multiSound
        endif
        
        private static string array strings
        private static string array multiString
        private static string array endString
        private static string array colors
        
        static boolean firstblood = false
        static boolean enabled = true
        
        private static key cacheKey
        private static Table cache = cacheKey
        
        /*
        *   Event Response Get Functions
        */
        static method getKillingUnitId takes nothing returns integer
            return EventHandler.killingUnitId
        endmethod
        static method getKillingUnit takes nothing returns unit
            return EventHandler.killingUnit
        endmethod
        static method getDyingUnitId takes nothing returns integer
            return EventHandler.dyingUnitId
        endmethod
        static method getDyingUnit takes nothing returns unit
            return EventHandler.dyingUnit
        endmethod
        static method getKillingPlayerId takes nothing returns integer
            return EventHandler.killingPlayerId
        endmethod
        static method getKillingPlayer takes nothing returns player
            return Player(EventHandler.killingPlayerId)
        endmethod
        static method getDyingPlayerId takes nothing returns integer
            return EventHandler.dyingPlayerId
        endmethod
        static method getDyingPlayer takes nothing returns player
            return Player(EventHandler.dyingPlayerId)
        endmethod
        static method getAchievedStreak takes nothing returns integer
            return EventHandler.streakAchieved
        endmethod
        static method getEndedStreak takes nothing returns integer
            return EventHandler.streakEnded
        endmethod
        static method getAchievedMultikill takes nothing returns integer
            return EventHandler.multikillAchieved
        endmethod
        static method getEndedMultikill takes nothing returns integer
            return EventHandler.multikillEnded
        endmethod
        static method getMultikillLoserId takes nothing returns integer
            return EventHandler.multikillLoserId
        endmethod
        static method getMultikillLoser takes nothing returns player
            return Player(EventHandler.multikillLoserId)
        endmethod
        static method getComboBroken takes nothing returns integer
            return EventHandler.comboBroken
        endmethod
        
        /*
        *   Event registration functions
        */
        static if EVENT_BY_NESTHARUS then
            static method registerFirstbloodEvent takes code c returns nothing
                call EventHandler.FIRSTBLOOD.register(Filter(c))
                return
            endmethod
            static method registerStreakEvent takes code c returns nothing
                call EventHandler.STREAK.register(Filter(c))
                return
            endmethod
            static method registerMultikillEvent takes code c returns nothing
                call EventHandler.MULTIKILL.register(Filter(c))
                return
            endmethod
            static method registerStreakEndEvent takes code c returns nothing
                call EventHandler.END_STREAK.register(Filter(c))
                return
            endmethod
            static method registerMultikillEndEvent takes code c returns nothing
                call EventHandler.END_MULTIKILL.register(Filter(c))
                return
            endmethod
            static method registerCombobreakerEvent takes code c returns nothing
                call EventHandler.COMBO_BREAKER.register(Filter(c))
                return
            endmethod
            static method registerSuicideEvent takes code c returns nothing
                call EventHandler.SUICIDE.register(Filter(c))
                return
            endmethod
            static method registerDenialEvent takes code c returns nothing
                call EventHandler.DENIAL.register(Filter(c))
                return
            endmethod
        else
            static method registerFirstbloodEvent takes trigger t returns nothing
                call EventHandler.FIRSTBLOOD.register(t)
            endmethod
            static method registerStreakEvent takes trigger t returns nothing
                call EventHandler.STREAK.register(t)
            endmethod
            static method registerMultikillEvent takes trigger t returns nothing
                call EventHandler.MULTIKILL.register(t)
            endmethod
            static method registerStreakEndEvent takes trigger t returns nothing
                call EventHandler.END_STREAK.register(t)
            endmethod
            static method registerMultikillEndEvent takes trigger t returns nothing
                call EventHandler.END_MULTIKILL.register(t)
            endmethod
            static method registerCombobreakerEvent takes trigger t returns nothing
                call EventHandler.COMBO_BREAKER.register(t)
            endmethod
            static method registerSuicideEvent takes trigger t returns nothing
                call EventHandler.SUICIDE.register(t)
            endmethod
            static method registerDenialEvent takes trigger t returns nothing
                call EventHandler.DENIAL.register(t)
            endmethod
        endif
        
        /*
        *   API Get Total Stat Functions
        */
        static method getKills takes player p returns integer
            return PlayerStatHandler.kills[GetPlayerId(p)]
        endmethod
        static method getDeaths takes player p returns integer
            return PlayerStatHandler.deaths[GetPlayerId(p)]
        endmethod
        static method getDenies takes player p returns integer
            return PlayerStatHandler.denies[GetPlayerId(p)]
        endmethod
        static method getSuicides takes player p returns integer
            return PlayerStatHandler.suicides[GetPlayerId(p)]
        endmethod
        static method getAssists takes player p returns integer
            return PlayerStatHandler.assists[GetPlayerId(p)]
        endmethod
        static method getStreaks takes player p returns integer
            return PlayerStatHandler.streaks[GetPlayerId(p)]
        endmethod
        static method getMultikills takes player p returns integer
            return PlayerStatHandler.multikills[GetPlayerId(p)]
        endmethod
        static method getCombobreakers takes player p returns integer
            return PlayerStatHandler.combobreakers[GetPlayerId(p)]
        endmethod
        static method getStreaksOfType takes player p, integer typ returns integer
            return PlayerStatHandler.streakTypes[GetPlayerId(p)][typ]
        endmethod
        static method getMultikillsOfType takes player p, integer typ returns integer
            return PlayerStatHandler.multikillTypes[GetPlayerId(p)][typ]
        endmethod
        
        static method getCurrentStreak takes player p returns integer
            return Streak[GetPlayerId(p)]
        endmethod
        static method getCurrentMultikill takes player p returns integer
            return Multikill(GetPlayerId(p)).multikill
        endmethod
        
        /*
        *   API Get Total Stat ById Functions
        */
        static method getKillsById takes integer id returns integer
            return PlayerStatHandler.kills[id]
        endmethod
        static method getDeathsById takes integer id returns integer
            return PlayerStatHandler.deaths[id]
        endmethod
        static method getDeniesById takes integer id returns integer
            return PlayerStatHandler.denies[id]
        endmethod
        static method getSuicidesById takes integer id returns integer
            return PlayerStatHandler.suicides[id]
        endmethod
        static method getAssistsById takes integer id returns integer
            return PlayerStatHandler.assists[id]
        endmethod
        static method getStreaksById takes integer id returns integer
            return PlayerStatHandler.streaks[id]
        endmethod
        static method getMultikillsById takes integer id returns integer
            return PlayerStatHandler.multikills[id]
        endmethod
        static method getCombobreakersById takes integer id returns integer
            return PlayerStatHandler.combobreakers[id]
        endmethod
        static method getStreaksOfTypeById takes integer id, integer typ returns integer
            return PlayerStatHandler.streakTypes[id][typ]
        endmethod
        static method getMultikillsOfTypeById takes integer id, integer typ returns integer
            return PlayerStatHandler.multikillTypes[id][typ]
        endmethod
        
        static method getCurrentStreakById takes integer id returns integer
            return Streak[id]
        endmethod
        static method getCurrentMultikillById takes integer id returns integer
            return Multikill(id).multikill
        endmethod
        
        /*
        *   Streak and Multikill Create Functions
        */
        static method newStreak takes string streakName, string streakDisplay, string soundPath, integer duration returns nothing
            set maxStreak = maxStreak + 1
            
            set strings[maxStreak] = " " + streakDisplay
            set endString[maxStreak] = "'s " + streakName
            
            static if LIBRARY_SoundTools then
                set sounds[maxStreak] = NewSound(soundPath, duration, false, S3D)
            elseif LIBRARY_SoundUtils then
                set sounds[maxStreak] = DefineSound(soundPath, duration, false, S3D)
            endif
        endmethod
        
        static method newMultikill takes string text, string soundPath, integer duration returns nothing
            set maxMultikill = maxMultikill + 1
            set multiString[maxMultikill] = " " + text
            static if LIBRARY_SoundTools then
                set multiSound[maxMultikill] = NewSound(soundPath, duration, false, S3D)
            elseif LIBRARY_SoundUtils then
                set multiSound[maxMultikill] = DefineSound(soundPath, duration, false, S3D)
            endif
        endmethod
        
        static method setMinimumStreak takes integer i returns nothing
            set minStreak = i
            set maxStreak = i - 1
        endmethod
        
        static method setFirstBloodSound takes string path, integer duration returns nothing
            static if LIBRARY_SoundTools then
                set firstSound = NewSound(path, duration, false, S3D)
            elseif LIBRARY_SoundUtils then
                set firstSound = DefineSound(path, duration, false, S3D)
            endif
        endmethod
        
        static method setComboBreakerSound takes string path, integer duration returns nothing
            static if LIBRARY_SoundTools then
                set comboBreaker = NewSound(path, duration, false, S3D)
            elseif LIBRARY_SoundUtils then
                set comboBreaker = DefineSound(path, duration, false, S3D)
            endif
        endmethod
        
        /*
        *   Color Configuration
        */
        static method setColor takes integer playerId, string color returns nothing
            set thistype.colors[playerId] = color
        endmethod
        
        /*
        *   Gold Gain/Loss Control
        */
        static method operator goldGain takes nothing returns boolean
            return gainGold
        endmethod
        static method operator goldGain= takes boolean b returns nothing
            set gainGold = b
        endmethod
        static method operator goldLoss takes nothing returns boolean
            return loseGold
        endmethod
        static method operator goldLoss= takes boolean b returns nothing
            set loseGold = b
        endmethod
        
        /*
        *   Bounty Formula Control
        */
        static method operator bountyBase takes nothing returns integer
            return baseGold
        endmethod
        static method operator bountyBase= takes integer v returns nothing
            set baseGold = v
        endmethod
        static method operator bountyIncrement takes nothing returns integer
            return goldIncrement
        endmethod
        static method operator bountyIncrement= takes integer v returns nothing
            set goldIncrement = v
        endmethod
        
        /*
        *   Streak Functions
        */
        static method resetStreak takes integer playerId returns nothing
            call Streak.reset(playerId)
        endmethod
        static method resetAllStreaks takes nothing returns nothing
            call Streak.resetAll()
        endmethod
        
        /*
        *   Multikill Functions
        */
        static method resetMultikill takes integer playerId returns nothing
            call Multikill.reset(playerId)
        endmethod
        static method resetAllMultikills takes nothing returns nothing
            call Multikill.resetAll()
        endmethod
        
        /*
        *   Assist Functions
        */
        static method resetAssist takes integer unitId returns nothing
            call Assist.reset(unitId)
        endmethod
        static method resetAllAssists takes nothing returns nothing
            call Assist.resetAll()
        endmethod
        
        /*
        *   Simple wrapper for gold gaining.
        */
        private static method addGold takes player p, integer amount returns nothing
            call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + amount)
        endmethod
        
        private static method doMulti takes nothing returns nothing
            local timer tmr = GetExpiredTimer()
            local integer handleId = GetHandleId(tmr)
            local integer multi = GetTimerData(tmr)
            
            /*
            *   Make sure the multikill is greater than 1 and still valid
            */
            if cache.real[handleId] > 0 and multi > 1 then
            
                /*
                *   Checking if the multikill is greater than the maximum multikill,
                *   then displaying the correct message and playing the correct sound
                */
                if multi > maxMultikill then
                    call MessageHandler.print(cache.string[handleId] + multiString[maxMultikill])
                    call RunSound(multiSound[maxMultikill])
                else
                    call MessageHandler.print(cache.string[handleId] + multiString[multi])
                    call RunSound(multiSound[multi])
                endif
            endif
            
            call ReleaseTimer(tmr)
            set tmr = null
        endmethod
        
        private static method onDeath takes nothing returns nothing
            /*
            *   These variables are for storing basic data like the killing unit,
            *   the dying unit, the killing player, etc...
            */
            local unit dyingUnit
            local unit killingUnit
            local player dyingPlayer
            local player killingPlayer
            local integer dyingId
            local integer killingId
            
            /*
            *   Local variables that will be needed later.
            */
            local integer index = 0
            local integer bounty
            local integer unitIdDying
            local integer unitIdKilling
            local integer timerId
            local string assistString = ""
            local string killingName
            local string dyingName
            local player tempPlayer
            local timer delayTimer
            
            /*
            *   These locals will only be declared if TEXTTAGS is set to true.
            */
            static if TEXTTAGS then
                local integer assistGold
                local integer lostGold
                local texttag tag
                local real cameraCenter
            endif
            
            /*
            *   Make sure the dying unit is a hero and the system is enabled
            */
            if enabled and IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then
            
                set dyingUnit = GetTriggerUnit()
                set killingUnit = GetKillingUnit()
                set dyingPlayer = GetTriggerPlayer()
                set killingPlayer = GetOwningPlayer(killingUnit)
                set killingId = GetPlayerId(killingPlayer)
                set dyingId = GetPlayerId(dyingPlayer)
                
                if KillingPlayerFilter(killingId) and DyingPlayerFilter(dyingId) and killingUnit != null and killingPlayer != null then
                    static if LEAVER_STREAK then
                        /*
                        *   Check if the player has left.
                        */
                        if not PlayerActive[killingId] then
                            set dyingUnit = null
                            set killingUnit = null
                            set dyingPlayer = null
                            set killingPlayer = null
                            return
                        endif
                    endif
                    
                    /*
                    *   Check if the killing player and the dying player are allies.
                    */
                    if IsPlayerAlly(killingPlayer, dyingPlayer) then
                        
                        call resetAssist(GetUnitUserData(dyingUnit))
                        
                        if killingPlayer != dyingPlayer then
                            /*
                            *   Total Stat Incrementation
                            */
                            set PlayerStatHandler.denies[killingId] = PlayerStatHandler.denies[killingId] + 1
                            static if DENIES_COUNT_DEATHS then
                                set PlayerStatHandler.deaths[dyingId] = PlayerStatHandler.deaths[dyingId] + 1
                            endif
                            static if DENIES_COUNT_KILLS then
                                set PlayerStatHandler.kills[killingId] = PlayerStatHandler.kills[killingId] + 1
                            endif
                            
                            /*
                            *   We print the allied-player-denial message.
                            */
                            call MessageHandler.print(GetDenialString(colors[killingId] + GetPlayerName(killingPlayer), colors[dyingId] + GetPlayerName(dyingPlayer)))
                            
                            /*
                            *   We store the event data responses and fire the event.
                            */
                            set EventHandler.killingUnitId = GetUnitUserData(killingUnit)
                            set EventHandler.killingUnit = killingUnit
                            set EventHandler.killingPlayerId = killingId
                            set EventHandler.dyingUnitId = GetUnitUserData(dyingUnit)
                            set EventHandler.dyingUnit = dyingUnit
                            set EventHandler.dyingPlayerId = dyingId
                            call EventHandler.DENIAL.fire()
                        else
                            /*
                            *   Total Stat Incrementations
                            */
                            set PlayerStatHandler.suicides[killingId] = PlayerStatHandler.suicides[killingId] + 1
                            static if SUICIDE_DEATH then
                                set PlayerStatHandler.deaths[dyingId] = PlayerStatHandler.deaths[dyingId] + 1
                            endif
                            
                            /*
                            *   We print the suicide message.
                            */
                            call MessageHandler.print(GetSuicideString(colors[killingId] + GetPlayerName(dyingPlayer)))
                            
                            /*
                            *   We store the event data responses.
                            */
                            set EventHandler.killingUnitId = GetUnitUserData(killingUnit)
                            set EventHandler.killingUnit = killingUnit
                            set EventHandler.killingPlayerId = killingId
                            set EventHandler.dyingUnitId = EventHandler.killingUnitId
                            set EventHandler.dyingUnit = EventHandler.killingUnit
                            set EventHandler.dyingPlayerId = killingId
                            
                            static if SUICIDE_ENDS then
                                /*
                                *   Cache event data and reset streak
                                */
                                set EventHandler.streakEnded = Streak[killingId]
                                set Streak[killingId] = 0
                            endif
                            
                            /*
                            *   Fire suicide and streak-end 
                            */
                            static if SUICIDE_FIRE_FIRST then
                                call EventHandler.SUICIDE.fire()
                                static if SUICIDE_ENDS then
                                    call EventHandler.END_STREAK.fire()
                                endif
                            else
                                static if SUICIDE_ENDS then
                                    call EventHandler.END_STREAK.fire()
                                endif
                                call EventHandler.SUICIDE.fire()
                            endif
                        endif
                        
                        /*
                        *   Null all the locals and return.
                        */
                        set dyingUnit = null
                        set killingUnit = null
                        set dyingPlayer = null
                        set killingPlayer = null
                        return
                    endif
                    
                    /*
                    *   Increase kills of killing player and deaths of dying player
                    */
                    set PlayerStatHandler.kills[killingId] = PlayerStatHandler.kills[killingId] + 1
                    set PlayerStatHandler.deaths[dyingId] = PlayerStatHandler.deaths[dyingId] + 1
                    
                    /*
                    *   Increase streak of killing player and reset multikill counter
                    */
                    set Streak[killingId] = Streak[killingId] + 1
                    set Multikill(killingId).counter = MULTI_TIME
                    
                    set unitIdDying = GetUnitUserData(dyingUnit)
                    set unitIdKilling = GetUnitUserData(killingUnit)
                    
                    /*
                    *   Event response data
                    */
                    set EventHandler.killingUnitId = unitIdKilling
                    set EventHandler.dyingUnitId = unitIdDying
                    set EventHandler.killingUnit = killingUnit
                    set EventHandler.dyingUnit = dyingUnit
                    set EventHandler.killingPlayerId = killingId
                    set EventHandler.dyingPlayerId = dyingId
                    
                    static if DEATH_END_MULTI then
                        /*
                        *   Cache event data, reset multikills of dying player and fire event
                        */
                        set EventHandler.multikillEnded = Multikill(dyingId).multikill
                        set EventHandler.multikillLoserId = dyingId
                        
                        set Multikill(dyingId).multikill = 0
                        set Multikill(dyingId).counter = 0
                        
                        call EventHandler.END_MULTIKILL.fire()
                    endif
                    
                    /*
                    *   The bounty of the killing player.
                    */
                    set bounty = GetBounty(killingId, dyingId, killingUnit, dyingUnit)
                    
                    /*
                    *   Get the colored names of the killing player and dying player.
                    */
                    set killingName = colors[killingId] + GetPlayerName(killingPlayer) + "|r"
                    set dyingName = colors[dyingId] + GetPlayerName(dyingPlayer) + "|r"
                    
                    static if TEXTTAGS then
                        set assistGold = 0
                        set lostGold = 0
                        /*
                        *   We are dividing the camera distance by 2 to be used while placing the texttag
                        *   at the center of the screen for the player. This will be equal to half the length of
                        *   your field of view. Interesting, ey?
                        */
                        set cameraCenter = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) / 2
                    endif
                    
                    /*
                    *   If the number of assisters is one, it means that only the killing player fought the unit.
                    *   If the number of assisters is greater than one, there is at least one assister, so:
                    */
                    if Assist[unitIdDying].number > 1 then
                    
                        set assistString = " Assists: "
                        
                        /*
                        *   We loop through all the players
                        */
                        loop
                            set tempPlayer = Player(index)
                            
                            /*
                            *   Check if the player is an enemy to the dying player and if he assisted in the kill.
                            */
                            if Assist[unitIdDying][index] and index != killingId and index != dyingId and PlayerActive[index] then
                                
                                /*
                                *   Add player name to assist string and increase total assists
                                */
                                set assistString = assistString + colors[index] + GetPlayerName(tempPlayer) + "|r/"
                                set PlayerStatHandler.assists[index] = PlayerStatHandler.assists[index] + 1
                                
                                static if ASSIST_GOLD then
                                    static if TEXTTAGS then
                                        /*
                                        *   Give assisting player gold and create texttag
                                        */
                                        set assistGold = GetAssistGold(killingId, dyingId, killingUnit, dyingUnit, bounty, Assist[unitIdDying].number)
                                        call addGold(tempPlayer, assistGold)
                                        call TextTagHandler.plus(tempPlayer, cameraCenter, I2S(assistGold))
                                    else
                                        /*
                                        *   Give assisting player gold
                                        */
                                        call addGold(tempPlayer, GetAssistGold(killingId, dyingId, killingUnit, dyingUnit, bounty, Assist[unitIdDying].number))
                                    endif
                                endif
                            endif
                            
                            exitwhen index == 15
                            set index = index + 1
                        endloop
                        
                        /*
                        *   Adjust assist string.
                        */
                        set assistString = SubString(assistString, 0, StringLength(assistString) - 1)
                    endif
                    
                    call Assist.reset(unitIdDying)
                    
                    /*
                    *   If bounty-gain is enabled, give gold to the 
                    *   player and create a texttag if that feature
                    *   is selected.
                    */
                    if gainGold then
                        call addGold(killingPlayer, bounty)
                        static if TEXTTAGS then
                            call TextTagHandler.plus(killingPlayer, cameraCenter, I2S(bounty))
                        endif
                    endif
                    
                    /*
                    *   If gold-loss is enabled, we remove gold from the player
                    *   and create a texttag if the feature is selected.
                    */
                    if loseGold then
                        static if TEXTTAGS then
                            set lostGold = GetLostGold(killingId, dyingId, killingUnit, dyingUnit, bounty)
                            call addGold(dyingPlayer, -lostGold)
                            call TextTagHandler.minus(dyingPlayer, cameraCenter, I2S(lostGold))
                        else
                            call addGold(dyingPlayer, -(GetLostGold(killingId, dyingId, killingUnit, dyingUnit, bounty)))
                        endif
                    endif
                    
                    if firstblood then
                        
                        /*
                        *   Evaluate dying player streak
                        */
                        if Streak[dyingId] >= minStreak and Streak[dyingId] <= maxStreak then
                            call MessageHandler.enqueue(GetEndString(killingName, dyingName, endString[Streak[dyingId]], I2S(bounty)) + assistString)
                            set EventHandler.streakEnded = Streak[dyingId]
                            call EventHandler.END_STREAK.fire()
                            
                            /*
                            *   Combobreaker evaluation
                            */
                            if Streak[dyingId] >= COMBO_BREAKER_MIN then
                                set PlayerStatHandler.combobreakers[killingId] = PlayerStatHandler.combobreakers[killingId] + 1
                                call RunSound(comboBreaker)
                                set EventHandler.comboBroken = Streak[dyingId]
                                call EventHandler.COMBO_BREAKER.fire()
                            endif
                        elseif Streak[dyingId] > maxStreak then
                            /*
                            *   Display End Streak Message and fire event
                            */
                            call MessageHandler.enqueue(GetEndString(killingName, dyingName, endString[maxStreak], I2S(bounty)) + assistString)
                            set EventHandler.streakEnded = maxStreak
                            call EventHandler.END_STREAK.fire()
                            
                            /*
                            *   Run combo breaker sound, increase total combo breakers and fire event
                            */
                            set PlayerStatHandler.combobreakers[killingId] = PlayerStatHandler.combobreakers[killingId] + 1
                            call RunSound(comboBreaker)
                            set EventHandler.comboBroken = Streak[dyingId]
                            call EventHandler.COMBO_BREAKER.fire()
                        else
                            /*
                            *   Display Ordinary Kill Message
                            */
                            call MessageHandler.enqueue(GetKillString(killingName, dyingName, I2S(bounty)) + assistString)
                        endif
                        
                        /*
                        *   Evaluate killing player streak
                        */
                        if Streak[killingId] >= minStreak and Streak[killingId] <= maxStreak then
                            call MessageHandler.enqueue(killingName + strings[Streak[killingId]])
                            call RunSound(sounds[Streak[killingId]])
                            
                            /*
                            *   Smart Algorithm for streak/streak-type tracking
                            */
                            if Streak[killingId] == minStreak then
                                set PlayerStatHandler.streaks[killingId] = PlayerStatHandler.streaks[killingId] + 1
                            else
                                set PlayerStatHandler.streakTypes[killingId][Streak[killingId] - 1] = PlayerStatHandler.streakTypes[killingId][Streak[killingId] - 1] - 1
                            endif
                            
                            /*
                            *   Increase the number of streak types for player and fire event
                            */
                            set PlayerStatHandler.streakTypes[killingId][Streak[killingId]] = PlayerStatHandler.streakTypes[killingId][Streak[killingId]] + 1
                            set EventHandler.streakAchieved = Streak[killingId]
                            call EventHandler.STREAK.fire()
                        elseif Streak[killingId] > maxStreak then
                        
                            /*
                            *   We display the streak message of the maximum streak value because 
                            *   the streak of the killing player is too large and we play the streak sound.
                            */
                            call MessageHandler.enqueue(killingName + strings[maxStreak])
                            call RunSound(sounds[maxStreak])
                            
                            /*
                            *   Store the achieved streak and fire the Streak event
                            */
                            set EventHandler.streakAchieved = maxStreak
                            call EventHandler.STREAK.fire()
                        endif
                    else
                        /*
                        *   Register firstblood as taken, display messages, give gold, play sound and fire event
                        */
                        set firstblood = true
                        
                        call MessageHandler.enqueue(GetKillString(killingName, dyingName, I2S(bounty)) + assistString)
                        call MessageHandler.enqueue(GetFirstbloodString(killingName))
                        
                        call RunSound(firstSound)
                        call addGold(killingPlayer, FIRST_GOLD)
                        call EventHandler.FIRSTBLOOD.fire()
                        
                        static if TEXTTAGS then
                            call TextTagHandler.plus(killingPlayer, cameraCenter - 35., I2S(FIRST_GOLD))
                        endif
                    endif
                    
                    /*
                    *   Increase current multikills by 1 and reset dying player streak
                    */
                    set Multikill[killingId].multikill = Multikill[killingId].multikill + 1
                    set Streak[dyingId] = 0
                    
                    /*
                    *   Evaluation of killing player multikills
                    */
                    if Multikill[killingId].multikill > 1 then
                        /*
                        *   Create a timer and store multikill data in it to display
                        *   multikill message after a delay
                        */
                        set delayTimer = NewTimerEx(Multikill[killingId].multikill)
                        set timerId = GetHandleId(delayTimer)
                        set cache.real[timerId] = Multikill[killingId].counter
                        set cache.string[timerId] = killingName
                        call TimerStart(delayTimer, INTERVAL, false, function thistype.doMulti)
                        
                        /*
                        *   Smart Algorithm for multikill/multikill-type detection
                        */
                        if Multikill[killingId].multikill == 2 then
                            set PlayerStatHandler.multikills[killingId] = PlayerStatHandler.multikills[killingId] + 1
                        elseif Multikill[killingId].multikill <= maxMultikill then
                            set PlayerStatHandler.multikillTypes[killingId][Multikill[killingId].multikill - 1] = PlayerStatHandler.multikillTypes[killingId][Multikill[killingId].multikill - 1] - 1
                        endif
                        
                        /*
                        *   Increase number of multikill types and fire event
                        */
                        set PlayerStatHandler.multikillTypes[killingId][Multikill[killingId].multikill] = PlayerStatHandler.multikillTypes[killingId][Multikill[killingId].multikill] + 1
                        set EventHandler.multikillAchieved = Multikill[killingId].multikill
                        call EventHandler.MULTIKILL.fire()
                    endif
                    
                    /*
                    *   Print all enqueued strings and clear queue
                    */
                    call MessageHandler.printQueue()
                    call MessageHandler.clearQueue()
                    
                    /*
                    *   Null data
                    */
                    set tempPlayer = null
                    set delayTimer = null
                endif
                
                /*
                *   Null data
                */
                set dyingUnit = null
                set killingUnit = null
                set dyingPlayer = null
                set killingPlayer = null
            endif
        endmethod
        
        implement Init
        
        private static method onInit takes nothing returns nothing
            static if LIBRARY_RegisterPlayerUnitEvent then
                call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            else
                local trigger t = CreateTrigger()
                local code c = function thistype.onDeath
                call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
                call TriggerAddCondition(t, Condition(c))
                set t = null
            endif
        endmethod
    endstruct
    
endlibrary