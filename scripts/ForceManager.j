library ForceManager initializer init/* v0.0.1 Xandria
*/  uses    Alloc           /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/          PlayerManager   /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/          PlayerAlliance  /*  List
*/          TimeManager     /*
*/          UnitManager     /*
********************************************************************************
*     HVF Force management : For use of managing HuntersVsFarmers forces
*
********************************************************************************

CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
*******************************************************************************/
    /***************************************************************************
    * Modules
    ***************************************************************************/
    // Unit related utils    
    private module HunterUnitVars
        unit hero
        static integer heroSelectedCount = 0
        
        public method operator hasHero takes nothing returns boolean
            return hero != null
        endmethod
        
        public method setHero takes unit hero returns nothing
            local boolean bInitHero = false
            if not this.hasHero then
                // set and initiate hero
                if hero != null then
                    set heroSelectedCount = heroSelectedCount + 1
                    set bInitHero = true
                endif
            else
                // delete hero
                if hero == null then
                    set heroSelectedCount = heroSelectedCount - 1 
                endif
            endif
            set this.hero = hero
            if bInitHero then
                // Give hunter hero 3 skill points at beginning
                call UnitModifySkillPoints(this.hero, CST_INT_InitHunterSkillPoints - GetHeroSkillPoints(this.hero))
            endif
        endmethod
        
    endmodule
    
    private module FarmerUnitVars
        unit hero
        
        // Randomize location of farmer hero
        public method randomizeHeroLoc takes unit hero   returns nothing
        endmethod
    endmodule
    
    // Force related utils    
    module ForceVars
        implement DualLinkedList
        static force fc
        
        // Static Methods
        public static method addToForce takes player p returns nothing
            local integer playerId = GetPlayerId(p)
            set thistype.count_p = thistype.count_p + 1
            set thistype[16].previous_p.next_p = playerId
            set thistype[playerId].previous_p = thistype[16].previous_p
            set thistype[16].previous_p = playerId
            set thistype[playerId].next_p = 16
            set thistype[playerId].get_p = p
            call ForceAddPlayer(thistype.fc, p)
        endmethod
        
        public static method removeFromForce takes player p returns nothing
            local integer playerId = GetPlayerId(p)
            set thistype.count_p = thistype.count_p - 1
            set thistype[playerId].previous_p.next_p = thistype[playerId].next_p
            set thistype[playerId].next_p.previous_p = thistype[playerId].previous_p
            set thistype[playerId].get_p = null
            call ForceRemovePlayer(thistype.fc, p)
        endmethod
        
        public static method contain takes player p returns boolean
            return IsPlayerInForce(p, thistype.fc)
        endmethod
        
        public static method findByPlayer takes player p returns thistype
            return thistype[GetPlayerId(p)]
        endmethod
        
        public static method clear takes nothing returns nothing
            local thistype role = thistype.first
            loop
                exitwhen role.end
                call thistype.remove(role.get)
                set role = role.next
            endloop
            call ForceClear(thistype.fc)
        endmethod
        
        static method win takes nothing returns boolean
            local thistype role = thistype[thistype.first]
            loop
                exitwhen role.end
                call CustomVictoryBJ(role.get, true, true)
                set role= role.next
            endloop
            return false
        endmethod
        
        static method lose takes nothing returns boolean
            local thistype role = thistype[thistype.first]
            loop
                exitwhen role.end
                call CustomDefeatBJ(role.get, "You lose! Game over...")
                set role= role.next
            endloop
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            set thistype[16].end_p = true
            set thistype[16].next_p = 16
            set thistype[16].previous_p = 16
            set thistype[16].get_p = null
            
            // Create Force
            set fc = CreateForce()
        endmethod
    endmodule
    
    /***************************************************************************
    * Structs
    ***************************************************************************/
    // Associate players with their force , units, data.
    struct Hunter extends array
        
        implement ForceVars
        implement HunterUnitVars
        
        // specific attributes
        integer killCount
        
        // Static Methods
        public static method add takes player p returns nothing
            call thistype.addToForce(p)
            set thistype[GetPlayerId(p)].killCount = 0
        endmethod
        
        public static method remove takes player p returns nothing
            call thistype.removeFromForce(p)
            call thistype[GetPlayerId(p)].setHero(null)
        endmethod
        
        // Give bonus gold for killing farmers in every 60s
        private static method goldBonusForKilling takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            local integer iGold = 0
            local integer iLumber = 0
            
            debug call BJDebugMsg("Give bonus gold for killing farmers")
            
            loop
                exitwhen h.end
                set iGold = CST_INT_GoldMagForKilling * h.killCount
                set iLumber = h.killCount
                call AdjustPlayerStateSimpleBJ(h.get, PLAYER_STATE_GOLD_GATHERED, iGold)
                call AdjustPlayerStateSimpleBJ(h.get, PLAYER_STATE_RESOURCE_LUMBER, iLumber)
                set h= h.next
            endloop
            return false
        endmethod
        
        // Select a random hero for players who haven't select a hero
        private static method onSelectHeroExpire takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            debug call BJDebugMsg("Select a random hero for players who haven't select a hero")
            loop
                exitwhen h.end
                if h.hero == null then
                    debug call BJDebugMsg(GetPlayerName(h.get)+" hasn't selected hero")
                    //set h.hero = GenRandomHunterHeroForPlayer(h.get, null)
                endif
                set h= h.next
            endloop
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerManager.pt60s.register(Filter(function thistype.goldBonusForKilling))
            call TimerManager.otSelectHero.register(Filter(function thistype.onSelectHeroExpire))
            // Play time is over, hunters win
            call TimerManager.otPlayTimeOver.register(Filter(function thistype.win))
        endmethod
        
    endstruct
    
    struct Farmer extends array
        implement ForceVars
        implement FarmerUnitVars
        
        integer deathCount
        
        // Static Methods
        public static method add takes player p returns nothing
            call addToForce(p)
        endmethod
        
        public static method remove takes player p returns nothing
            call removeFromForce(p)
        endmethod
        
        public static method goldCompensateForDeath takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            local integer iGold = 0
            
            debug call BJDebugMsg("Give bonus gold for farmers")
            
            loop
                exitwhen f.end
                debug call BJDebugMsg("Give bonus to farmer:" + GetPlayerName(f.get))
                set iGold = CST_INT_GoldMagForDeath * f.deathCount
                call AdjustPlayerStateBJ(iGold, f.get, PLAYER_STATE_RESOURCE_GOLD)
                //call AdjustPlayerStateSimpleBJ(f.get, PLAYER_STATE_GOLD_GATHERED, 10)
                set f= f.next
            endloop
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerManager.pt60s.register(Filter(function thistype.goldCompensateForDeath))
            // Play time is over, farmers lose
            call TimerManager.otPlayTimeOver.register(Filter(function thistype.lose))
        endmethod
    endstruct
    
    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/    
    public function InSameForce takes player p, player p2 returns boolean
        if Farmer.contain(p)  then
            if Farmer.contain(p2) then
                return true
            endif
        else
            if Hunter.contain(p2) then
                return true
            endif
        endif
        return false
    endfunction
        
    private function SetupTeam takes nothing returns nothing
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            call SetPlayerTeam(f.get, 0)
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            call SetPlayerTeam(h.get, 1)
            set h = h.next
        endloop
        
    endfunction
        
    // Temporary solution
    private function SetupAlly takes nothing returns nothing
        local ActivePlayer sourcePlayer = ActivePlayer[ActivePlayer.first]
        local ActivePlayer targetPlayer
        
        loop
            exitwhen sourcePlayer.end
            set targetPlayer = sourcePlayer.next
            loop
                exitwhen targetPlayer.end
                if InSameForce(sourcePlayer.get, targetPlayer.get) then
                    call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_NEUTRAL_VISION)
                else 
                    call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_UNALLIED)
                endif
                set targetPlayer = targetPlayer.next
            endloop
            set sourcePlayer = sourcePlayer.next
        endloop
        
    endfunction
    
    // expose this function to global    
    function ShufflePlayer takes nothing returns nothing
        local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
        local integer iPlayerNbr = ActivePlayer.count
        local integer iFarmerCount = 0
        local integer iHunterCount = 0
        local integer iNbrFarmers    // Number of Farmer
        local integer iNbrHunters    // Number of Hunter
        local integer iHunterMaxNbr
        local integer m
        local integer n
        
        debug call BJDebugMsg("Shuffling players!")
        
        // Calculate number of hunters/farmers
        set m = iPlayerNbr/3
        set n = iPlayerNbr - (m*3)
        
        set iHunterMaxNbr = m
        if n != 0 then
            set iHunterMaxNbr = iHunterMaxNbr + 1
        endif
        set iNbrHunters = iHunterMaxNbr
        set iNbrFarmers = iPlayerNbr - iNbrHunters
        
        // Clear force
        call Hunter.clear()
        call Farmer.clear()
        
        loop
            exitwhen ap.end
            if iHunterCount < iNbrHunters and iFarmerCount < iNbrFarmers then
                if GetRandomInt(0,1) == 1 then
                    debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunter")
                    call Hunter.add(ap.get)
                    set iHunterCount = iHunterCount + 1
                else
                    debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmer")
                    call Farmer.add(ap.get)
                    set iFarmerCount = iFarmerCount + 1
                endif
            else
                if iFarmerCount == iNbrFarmers then
                    debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunter")
                    call Hunter.add(ap.get)
                    set iHunterCount = iHunterCount + 1
                else
                    debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmer")
                    call Farmer.add(ap.get)
                    set iFarmerCount = iFarmerCount + 1
                endif
            endif
            set ap = ap.next
        endloop
        
        debug call BJDebugMsg("Shuffling finished! Number of Farmer:" + I2S(iNbrFarmers) + ", Number of Hunter:" +I2S(iNbrHunters))
        
        // re-assemble team and alliance after shuffling
        call SetupTeam()
        call SetupAlly()
        
    endfunction
    
    // It has default game alliance
    private function LoadDefaultSetting takes nothing returns nothing
        local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
        loop
            // Set max allowed hero to 1
            call SetPlayerTechMaxAllowed(ap.get, CST_INT_TechidHero, CST_INT_MaxHeros)
            if GetPlayerId(ap.get) > 5 and GetPlayerId(ap.get) < 10 then
                debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Hunter")
                call Hunter.add(ap.get)
            else
                debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Farmer")
                call Farmer.add(ap.get)
            endif
            
            set ap = ap.next
            exitwhen ap.end
        endloop
    endfunction
    
    /***************************************************************************
    * Functions that would be called on event fired
    ***************************************************************************/
    private function OnSelectHero takes nothing returns boolean    
        debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetSoldUnit()))+ ":Selecte a Hero") 
        if Hunter.contain(GetOwningPlayer(GetSoldUnit())) then
            call Hunter[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
        endif
        
        // Every Hunter players has selected a hero
        if Hunter.heroSelectedCount == Hunter.count then
            debug call BJDebugMsg("Every Hunter players has selected a hero")
            // destroy this trigger which has no actions, no memory leak
            call DestroyTrigger(GetTriggeringTrigger())
        endif
        return false
    endfunction
    
    private function BindSelectedHero takes nothing returns nothing
        local trigger tgSelectedHero = CreateTrigger()
        call TriggerAddCondition( tgSelectedHero,Condition(function OnSelectHero) )
        // Hero Tavern belongs to 'Neutral Passive Player'
        call TriggerRegisterPlayerUnitEvent(tgSelectedHero, Player(PLAYER_NEUTRAL_PASSIVE), EVENT_PLAYER_UNIT_SELL, null)
        set tgSelectedHero = null
    endfunction  
    
    // Do clean-up work for leaving player
    private function OnPlayerLeave takes nothing returns boolean
        local player pLeave = GetTriggerPlayer()
        local boolean bIsHunter = Hunter.contain(pLeave)
        
        // remove player from group
        if bIsHunter then
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunter")
            call Hunter.remove(pLeave)
        else
            debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmer")
            call Farmer.remove(pLeave)
        endif
        
        // remove unit of this player
        // or share control/vision of leaving player with other playing players?
        
        set pLeave = null
        return false
    endfunction
    
    /***************************************************************************
    * Functions that would be called on timer expired
    ***************************************************************************/
    function OnHeroSelectTimerExpired takes nothing returns nothing
    endfunction
    
    /***************************************************************************
    * Library Initiation
    ***************************************************************************/
    private function init takes nothing returns nothing
        // Register a leave action callback of player leave event
        call Players.LEAVE.register(Filter(function OnPlayerLeave))
        // Grouping players to Hunter/Farmer force by default
        call LoadDefaultSetting()
        // Bind selected Hunter Hero to Player
        call BindSelectedHero()
    endfunction
endlibrary
