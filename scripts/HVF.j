library HVF initializer init/* v0.0.1 Xandria
*/  uses    Alloc           /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/          PlayerManager   /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/          PlayerAlliance  /*  List
*/          StatsManager    /* -> TimeManager
*/          Board           /*
*/          ErrorMessage    /*
*/          ORDERID         /*
********************************************************************************
*     HVF Force management : For use of managing HuntersVsFarmers forces
*
********************************************************************************

CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
*******************************************************************************/
    function FarmerWin takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            call DisplayTimedTextToPlayer(f.get, 0, 0, CST_MSGDUR_Normal, ARGB(COLOR_ARGB_GREEN).str(MSG_YouWin))
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Normal, ARGB(COLOR_ARGB_RED).str(MSG_YouLose))
            set h = h.next
        endloop
        
        // Must be set here, before quiting from game, 
        // calculate some stats
        call StatsManager.updateStats(true,true)
        
        /*
        if TimeManager.getPlayedTime() > 10 then
            set temp = temp + 2
        endif
        */
        call StatsBoard.redisplay()
        call ShowMsgToAll(MSG_GameWillEnd)
        call TimerStart(CreateTimer(), 10, false, function Farmer.win)
        call TimerStart(CreateTimer(), 10, false, function Hunter.lose)
        call PauseAllUnitsBJ(true)
        return false
    endfunction
    
    function HunterWin takes nothing returns boolean
        local Farmer f = Farmer[Farmer.first]    
        local Hunter h = Hunter[Hunter.first]

        loop
            exitwhen f.end
            call DisplayTimedTextToPlayer(f.get, 0, 0, CST_MSGDUR_Normal, ARGB(COLOR_ARGB_RED).str(MSG_YouLose))
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Normal, ARGB(COLOR_ARGB_GREEN).str(MSG_YouWin))
            set h = h.next
        endloop
        
        // Must be set here, before quiting from game, 
        // calculate some stats
        call StatsManager.updateStats(false,true)
        call StatsBoard.redisplay()
        call ShowMsgToAll(MSG_GameWillEnd)
        call TimerStart(CreateTimer(), 10, false, function Farmer.lose)
        call TimerStart(CreateTimer(), 10, false, function Hunter.win)
        call PauseAllUnitsBJ(true)
        return false
    endfunction
    
    /***************************************************************************
    * Modules
    ***************************************************************************/
    // Force related utils    
    module Force
        implement DualLinkedList
        static force fc
        
        boolean bLeave
        
        public method delegateByOthers takes boolean shareControl returns boolean
            local thistype role = thistype[thistype.first]
            local integer gold = GetPlayerState(this.get,PLAYER_STATE_RESOURCE_GOLD)
            local integer lumber = GetPlayerState(this.get,PLAYER_STATE_RESOURCE_LUMBER)
            local integer goldToD = R2I(gold/thistype.humanPlayerNumber)
            local integer lumberToD = R2I(lumber/thistype.humanPlayerNumber)
            loop
                exitwhen role.end
                if not role.leave and GetPlayerController(role.get) == MAP_CONTROL_USER then
                    call AdjustPlayerStateBJ(0-gold, this.get, PLAYER_STATE_RESOURCE_GOLD)
                    call AdjustPlayerStateBJ(goldToD, role.get, PLAYER_STATE_RESOURCE_GOLD)
                    call AdjustPlayerStateBJ(0-lumber, this.get, PLAYER_STATE_RESOURCE_LUMBER)
                    call AdjustPlayerStateBJ(lumberToD, role.get, PLAYER_STATE_RESOURCE_LUMBER)
                    if shareControl then
                        // DO NOT USE full control, otherwise w r fucked up by
                        // the bullshit 'Team resource bar'
                        call Ally( this.get, role.get, ALLIANCE_ALLIED_ADVUNITS )
                    endif
                endif
                set role= role.next
            endloop
            
            // We may be fucked up by the 'Team resource bar', re-display our board
            if shareControl then
                call StatsBoard.redisplay()
            endif
            // refresh board
            call StatsBoard.refresh()
            return false
        endmethod

        public method operator leave takes nothing returns boolean
            return .bLeave
        endmethod
        
        public method operator leave= takes boolean val returns nothing
            set .bLeave = val
            if not .bLeave then
                return
            endif
            // fresh board
            set StatsBoard.hb[CST_BDCOL_ST][.bIndex].text = CST_STR_StatusHasLeft
            set StatsBoard.fb[CST_BDCOL_ST][.bIndex].text = CST_STR_StatusHasLeft
            // share control of this leaving player with other players who are in-game
            call .delegateByOthers(true)
        endmethod
        
        // Static Methods
        public static method operator isAllLeave takes nothing returns boolean
            local thistype role = thistype[thistype.first]
            loop
                exitwhen role.end
                if not role.leave then
                    return false
                endif
                set role= role.next
            endloop
            return true
        endmethod
        
        public static method operator humanPlayerNumber takes nothing returns integer
            local thistype role = thistype[thistype.first]
            local integer count = 0
            loop
                exitwhen role.end
                if GetPlayerController(role.get) == MAP_CONTROL_USER and GetPlayerSlotState(role.get) == PLAYER_SLOT_STATE_PLAYING then
                    set count = count + 1
                endif
                set role= role.next
            endloop
            return count
        endmethod
        
        public static method markAsLeave takes player p returns nothing
            local thistype r = thistype[GetPlayerId(p)]
            set r.leave = true
        endmethod
        
        // If there is a human player in this group, we should delegate all robots
        // players to human players
        public static method delegateAllRobots takes nothing returns nothing
            local thistype role = thistype[thistype.first]
            
            if thistype.humanPlayerNumber <= 0 then
                return
            endif
            
            loop
                exitwhen role.end
                if GetPlayerController(role.get) == MAP_CONTROL_COMPUTER then
                    // Mark this computer as leave and delege it to other human player
                    set role.leave = true
                endif
                set role= role.next
            endloop
        endmethod
        
        // Distribute the resoures of leaving player to the players in-game
        public static method distributeResources takes nothing returns nothing
            local thistype role = thistype[thistype.first]
            
            loop
                exitwhen role.end
                if role.leave then
                    call role.delegateByOthers(false)
                endif
                set role= role.next
            endloop
        endmethod
        /***********************************************************************
        * Players Management
        ***********************************************************************/
        public static method add takes player p returns nothing
            local integer playerId = GetPlayerId(p)
            set thistype.count_p = thistype.count_p + 1
            set thistype[16].previous_p.next_p = playerId
            set thistype[playerId].previous_p = thistype[16].previous_p
            set thistype[16].previous_p = playerId
            set thistype[playerId].next_p = 16
            set thistype[playerId].get_p = p
            call ForceAddPlayer(thistype.fc, p)
        endmethod
        
        public static method remove takes player p returns nothing
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
            local thistype r = thistype.first
            loop
                exitwhen r.end
                call thistype.remove(r.get)
                set r = r.next
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
    
    // Unit related utils    
    private module HunterVars
        unit hero
        // specific attributes
        integer killCount
        boolean isRandomHero
        boolean isPending

        integer index   // Index of hunter
        integer heroMaxLevel
        integer heroSurviveTime
        
        unit heroBox    // The hunter hero box
        unit dummy      // The dummy unit
        
        AbilitySelector as  // Ability selector
        // Instance method
        /***********************************************************************
        * Operators
        ***********************************************************************/
        public method operator kills takes nothing returns integer
            return this.killCount
        endmethod
        
        public method operator kills= takes integer val returns nothing
            set this.killCount = val
            // fresh board
            set StatsBoard.hb[CST_BDCOL_KL][.bIndex].text = I2S(this.killCount)
            set StatsBoard.fb[CST_BDCOL_KL][.bIndex].text = I2S(this.killCount)
        endmethod
        
        /***********************************************************************
        * Filters
        ***********************************************************************/
        private static method filterKillAllUnits takes nothing returns boolean
            call KillUnit(GetFilterUnit())
            return false
        endmethod
        
        /***********************************************************************
        * Iteration all units of this player
        ***********************************************************************/
        private method iterateUnits takes filterfunc filter returns nothing
            local group dummyGroup = CreateGroup()
            
            call GroupEnumUnitsOfPlayer(dummyGroup, this.get, filter)
            
            call DestroyGroup(dummyGroup)
            set dummyGroup = null
        endmethod
        
        /***********************************************************************
        * Util functions
        ***********************************************************************/
        private static method isAllHerosDie takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            
            loop
                exitwhen h.end
                if h.hero != null and IsUnitHunterHero(h.hero) and not IsUnitType(h.hero, UNIT_TYPE_DEAD) then
                    return false
                endif
                set h=h.next
            endloop
            return true
        endmethod
        
        public method reviveHero takes nothing returns nothing
            // If it's first blood, that means hunter hero die
            // Notice, now skeleton is a unit not a hero, we can not use ReviveHero
            if IsUnitHunterHero(this.hero) then
                //set this.hero = CreateUnitAtLoc(this.get, CST_UTI_HunterHeroSkeleton, Map.heroReviveLoc, CST_Facing_Unit)
                // If all hunter hero die, farmer win
                // Update boards
                set .heroSurviveTime= TimerManager.getPlayedTime()
                set .heroMaxLevel   = GetHeroLevel(.hero)
                set StatsBoard.hb[CST_BDCOL_PN][.bIndex].icon = GetHeroAvatar(this.hero)
                set StatsBoard.fb[CST_BDCOL_PN][.bIndex].icon = GetHeroAvatar(this.hero)
                if thistype.isAllHerosDie() then
                    call ShowMsgToAll(ARGB(COLOR_ARGB_RED).str(MSG_AllHuntersBeingKilled))
                    call FarmerWin()
                endif
            endif
            if not Params.flagGameModeDr then
                set this.hero = CreateUnitAtLoc(this.get, CST_UTI_HunterHeroSkeleton, Map.heroReviveLoc, CST_Facing_Unit)
                call PanCameraToTimedLocForPlayer(this.get, Map.heroReviveLoc, 0.50)
            endif
        endmethod
        
        // Clean up these temp creeps
        private method cleanUp takes nothing returns nothing
            if .isPending then
                call .as.destroy()
                set .as = -1
            endif
            
            if .heroBox != null then
                call RemoveUnit(.heroBox)
                set .heroBox = null
            endif
        endmethod
        
        private method initHero takes nothing returns nothing
            local real x = GetUnitX(.heroBox)
            local real y = GetUnitY(.heroBox)
            
            // Debug use
            call SetHeroLevelBJ(this.hero, 4, false)
            // We are finished
            call this.cleanUp()
            set .isPending = false
            // Give hunter hero 3 skill points at beginning
            call UnitModifySkillPoints(this.hero, CST_INT_InitHunterSkillPoints - GetHeroSkillPoints(this.hero))
            // Give items
            call CreateHunterBeginItems(this.hero)
            // Update boards
            set StatsBoard.hb[CST_BDCOL_PN][.bIndex].icon = GetHeroAvatar(this.hero)
            set StatsBoard.fb[CST_BDCOL_PN][.bIndex].icon = GetHeroAvatar(this.hero)
            // Now we are settle down, remember to remove Invulnerable
            call UnitRemoveAbility(.dummy, CST_ABI_Invulnerable)
            set .dummy = null
            // Add itemBox and here we go
            call CreateUnit(this.get, CST_BTI_HunterItemBox, Map.itemBoxXs[.index], Map.itemBoxYs[.index], CST_Facing_Building)
            // Move camera to hero
            call PanCameraToTimedForPlayer(this.get, GetLocationX(Map.heroReviveLoc), GetLocationY(Map.heroReviveLoc), 0.50)
        endmethod
        
        public method createRandomHero takes unit u returns nothing

            // Do clean work
            if .hero != null then
                call RemoveUnit(.hero)
                set .hero = null
            endif
            
            if u != null then
                call RemoveUnit(u)
            endif
            
            debug call BJDebugMsg("Center X of Map.regionHeroRevive:" + R2S(GetRectCenterX(Map.regionHeroRevive)))
            debug call BJDebugMsg("Create random hero at location >> X:" + R2S(GetLocationX(loc))+ ", Y:"+ R2S(GetLocationY(loc)) )
            debug call BJDebugMsg("Create random hero for " + GetPlayerName(this.get))
            
            set this.hero = CreateUnit(this.get, GetRandomHeroUti(), GetLocationX(Map.heroReviveLoc), GetLocationY(Map.heroReviveLoc), 0)
            set this.isRandomHero = true
            // Give random hunter hero extra bonus such as life(+2000) agi(+3) int(+2)... 
            set Bonus_Life[hero]=CST_INT_RandomBonusLife
            set Bonus_Armor[hero]=CST_INT_RandomBonusArmor
            set Bonus_Agi[hero]=CST_INT_RandomBonusAgi
            set Bonus_Int[hero]=CST_INT_RandomBonusInt
            call this.initHero()

        endmethod
        
        public method setHero takes unit u returns nothing
        
            if u == null or GetUnitTypeId(u) == CST_UTI_HunterHeroRandom then
                call this.createRandomHero(u)
            elseif GetUnitTypeId(u) == CST_UTI_HunterHeroFree then
                // First replace heroBox with abilityBox 
                call this.cleanUp()
                set .as = AbilitySelector.create( CreateUnit(.get, CST_BTI_HunterAbilityShop, Map.itemBoxXs[.index], Map.itemBoxYs[.index], CST_Facing_Building) )
                set .hero = u
                // Pause this unit
                // call PauseUnit(.hero,true)
                call SetUnitTurnSpeed(.hero, 0.0)
                call SetUnitMoveSpeed(.hero, 0.0)
                // Lock camera
                call SetCameraTargetControllerNoZForPlayer(.get, .hero, 0, 0, false )
                // Reset camera
                // call ResetToGameCameraForPlayer( Player(0), 0 )
                // Tell player to select abilities within 60 seconds
                // TimerGetRemaining
                set this.isPending = true
                call DisplayTimedTextToPlayer(this.get, 0, 0, CST_MSGDUR_Normal, MSG_PlsSelectAbilities+ ARGB(COLOR_ARGB_RED).str(R2S(TimerManager.getOtRemainingTime(TimerManager.otSelectHero))) +MSG_WithinXSeconds)
            else
                set .hero = u
                call this.initHero()
            endif
        endmethod
        
        public method heroInfo takes nothing returns string
            return ""
        endmethod
        
        method initHunterVars takes nothing returns nothing
            set .killCount = 0
            set .hero = null
            set .isRandomHero = false
            set .isPending  = false
            set .bLeave = false
            set .heroMaxLevel   = 0
            set .heroSurviveTime= 0
            
            set .as = -1
            
            call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, this.get)
            call AdjustPlayerStateBJ(CST_INT_HunterBeginGold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            call AdjustPlayerStateBJ(CST_INT_HunterBeginLumber, this.get, PLAYER_STATE_RESOURCE_LUMBER)
            
            // Set camera to hunter base
            call PanCameraToTimedLocForPlayer(this.get, Map.heroReviveLoc, 0.50)
        endmethod
        
        method deleteHunterVars takes nothing returns nothing
            // Kill/Remove all units
            call iterateUnits(Filter(function thistype.filterKillAllUnits))
            
        endmethod
        
    endmodule
    
    private module FarmerVars
        unit hero
        // Farming building counter
        integer sheepFoldCount
        integer pigenCount
        integer snakeHoleCount
        integer cageCount
        // Farming building(No Spawn) counter
        integer sheepFoldNsCount
        integer pigenNsCount
        integer snakeHoleNsCount
        integer cageNsCount
        // Farming animal counter
        integer sheepCount
        integer pigCount
        integer snakeCount
        integer chickenCount
        
        integer killCount
        integer deathCount
        integer towerCount
        integer treeCount
        integer woodCount
        integer role
        integer lifes
        string heroIntro
        
        // Instance method
        /***********************************************************************
        * Operators
        ***********************************************************************/
        public method operator deaths takes nothing returns integer
            return .deathCount
        endmethod
        
        public method operator deaths= takes integer val returns nothing
            set .deathCount = val
            // fresh board
            set StatsBoard.hb[CST_BDCOL_DE][.bIndex].text = I2S(this.deathCount)
            set StatsBoard.fb[CST_BDCOL_DE][.bIndex].text = I2S(this.deathCount)
            
        endmethod
        
        public method operator animalCount takes nothing returns integer
            return (.sheepCount + .pigCount + .snakeCount + .chickenCount)
        endmethod
        
        // Salary for every x minutes/seconds depends on animalType*animalCount
        public method operator salary takes nothing returns integer
            local integer money = (CST_INT_SalaryBaseSheep*sheepCount) + (CST_INT_SalaryBasePig*pigCount) + (CST_INT_SalaryBaseSnake*snakeCount) + (CST_INT_SalaryBaseChicken*chickenCount)
            
            // Nomader has more salary
            if this.role == CST_INT_FarmerRoleNomader then
                set money = R2I(money * CST_INT_GoldMagForNomader)
            endif
            return money
        endmethod
        
        // Income for killing all animals
        public method operator allAnimalIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepCount) + (CST_INT_PriceOfPig*pigCount) + (CST_INT_PriceOfSnake*snakeCount) + (CST_INT_PriceOfChicken*chickenCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * CST_INT_GoldMagForGreedy)
            endif
            return money
        endmethod
        
        // Income for killing overflow animals
        public method operator overflowIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepFoldCount) + (CST_INT_PriceOfPig*pigenCount) + (CST_INT_PriceOfSnake*snakeHoleCount) + (CST_INT_PriceOfChicken*cageCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * CST_INT_GoldMagForGreedy)
            endif
            return money
        endmethod
        // Income from no spawn buildings
        public method operator noSpawnIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepFoldNsCount) + (CST_INT_PriceOfPig*pigenNsCount) + (CST_INT_PriceOfSnake*snakeHoleNsCount) + (CST_INT_PriceOfChicken*cageNsCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * CST_INT_GoldMagForGreedy)
            endif
            return money
        endmethod
        // Income from death..., hmm, weird
        public method operator deathIncome takes nothing returns integer
            return CST_INT_GoldMagForDeath*deathCount
        endmethod
        
        /***********************************************************************
        * Filters
        ***********************************************************************/
        private static method filterBindHero takes nothing returns boolean
            //local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(enteringUnit))]
            local Farmer f = Farmer[GetPlayerId(GetFilterPlayer())]
            
            if GetUnitTypeId(GetFilterUnit()) == CST_UTI_FarmerHero then
                call f.setHero(GetFilterUnit())
                // Init hero
                call f.initHero()
            endif
            return false
        endmethod
        private static method filterKillAllUnits takes nothing returns boolean
            if GetUnitTypeId(GetFilterUnit()) != CST_UTI_FarmerHero then
                call KillUnit(GetFilterUnit())
            endif
            return false
        endmethod
        private static method filterButcherAllAnimal takes nothing returns boolean
            local unit toBeKilled = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(toBeKilled)
            
            if unitTypeId == CST_UTI_Sheep or unitTypeId == CST_UTI_Pig or unitTypeId == CST_UTI_Snake or unitTypeId == CST_UTI_Chicken then
                call KillUnit(toBeKilled)
            endif
            // debug call BJDebugMsg("Kill " + GetUnitName(toBeKilled)) 
            set toBeKilled = null
            return false
        endmethod
        private static method filterAllAnimalSpawnOn takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(filterUnit)
            
            if unitTypeId == CST_BTI_SheepFoldNs or unitTypeId == CST_BTI_PigenNs or unitTypeId == CST_BTI_SnakeHoleNs or unitTypeId == CST_BTI_CageNs then
                call IssueImmediateOrderById( filterUnit, ORDERID_unbearform )
            endif
            set filterUnit = null
            return false
        endmethod
        private static method filterAllAnimalSpawnOff takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(filterUnit)
            
            if unitTypeId == CST_BTI_SheepFold or unitTypeId == CST_BTI_Pigen or unitTypeId == CST_BTI_SnakeHole or unitTypeId == CST_BTI_Cage then
                call IssueImmediateOrderById( filterUnit, ORDERID_bearform )
            endif
            set filterUnit = null
            return false
        endmethod
        private static method filterAnimalAutoLoad takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(filterUnit)
            
            if unitTypeId == CST_BTI_SheepFold or unitTypeId == CST_BTI_Pigen or unitTypeId == CST_BTI_SnakeHole or unitTypeId == CST_BTI_Cage or unitTypeId == CST_BTI_SheepFoldNs or unitTypeId == CST_BTI_PigenNs or unitTypeId == CST_BTI_SnakeHoleNs or unitTypeId == CST_BTI_CageNs then
                call IssueTargetOrderById( filterUnit, ORDERID_smart , filterUnit )
            endif
            set filterUnit = null
            return false
        endmethod
        private static method filterAnimalLoadAll takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(filterUnit)
            
            if unitTypeId == CST_BTI_SheepFold or unitTypeId == CST_BTI_Pigen or unitTypeId == CST_BTI_SnakeHole or unitTypeId == CST_BTI_Cage or unitTypeId == CST_BTI_SheepFoldNs or unitTypeId == CST_BTI_PigenNs or unitTypeId == CST_BTI_SnakeHoleNs or unitTypeId == CST_BTI_CageNs then
                call IssueImmediateOrderById( filterUnit, ORDERID_battlestations )
            endif
            set filterUnit = null
            return false
        endmethod
        private static method filterAnimalUnloadAll takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local integer unitTypeId = GetUnitTypeId(filterUnit)
            
            if unitTypeId == CST_BTI_SheepFold or unitTypeId == CST_BTI_Pigen or unitTypeId == CST_BTI_SnakeHole or unitTypeId == CST_BTI_Cage or unitTypeId == CST_BTI_SheepFoldNs or unitTypeId == CST_BTI_PigenNs or unitTypeId == CST_BTI_SnakeHoleNs or unitTypeId == CST_BTI_CageNs then
                call IssueImmediateOrderById( filterUnit, ORDERID_standdown )
            endif
            set filterUnit = null
            return false
        endmethod
        private static method filterSpawnFarmingAnimal takes nothing returns boolean
            local unit filterUnit = GetFilterUnit()
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(filterUnit))]
            local location rallyPoint = GetUnitRallyPoint(filterUnit)
            local integer utiB = GetUnitTypeId(filterUnit) // Building UTI
            local unit u
            local integer utiA // Animal UTI
            
            debug call BJDebugMsg("filterSpawnFarmingAnimal > Player " + GetPlayerName(GetOwningPlayer(filterUnit)))
            debug call BJDebugMsg("filterSpawnFarmingAnimal > Unitname " + GetUnitName(filterUnit))
            debug call BJDebugMsg("filterSpawnFarmingAnimal > Uti " + I2S(GetUnitTypeId(filterUnit)))
            if utiB == CST_BTI_SheepFold then
                set utiA = CST_UTI_Sheep
                debug call BJDebugMsg("filterSpawnFarmingAnimal > create sheep")
                // No need to increace here... onEnterMap will detect it
                // set f.sheepCount = f.sheepCount + 1
            elseif utiB == CST_BTI_Pigen then
                set utiA = CST_UTI_Pig
            elseif utiB == CST_BTI_SnakeHole then
                set utiA = CST_UTI_Snake
            elseif utiB == CST_BTI_Cage then
                set utiA = CST_UTI_Chicken
            else
                call RemoveLocation(rallyPoint)
                set u = null
                set filterUnit = null 
                return false
            endif
            debug call BJDebugMsg("filterSpawnFarmingAnimal > create unit")
            set u = CreateUnit(GetOwningPlayer(filterUnit), utiA, GetUnitX(filterUnit), GetUnitY(filterUnit), CST_Facing_Unit)
            call IssuePointOrderByIdLoc(u, ORDERID_smart, rallyPoint)
            call IssueTargetOrderById(u, ORDERID_smart, GetUnitRallyUnit(filterUnit))
            
            
            call RemoveLocation(rallyPoint)
            set rallyPoint = null
            set u = null
            set filterUnit = null 
            return false
        endmethod
        
        /***********************************************************************
        * Iteration all units of this player
        ***********************************************************************/
        private method iterateUnits takes filterfunc filter returns nothing
            local group dummyGroup = CreateGroup()
            
            call GroupEnumUnitsOfPlayer(dummyGroup, this.get, filter)
            
            call DestroyGroup(dummyGroup)
            set dummyGroup = null
        endmethod
        
        /***********************************************************************
        * Util functions
        ***********************************************************************/
        // Butcher a animal, get money
        public method butcherAnimal takes unit animal returns nothing
            local integer money = 0
            if GetUnitTypeId(animal) == CST_UTI_Sheep then
                set money = CST_INT_PriceOfSheep
            elseif GetUnitTypeId(animal) == CST_UTI_Pig then
                set money = CST_INT_PriceOfPig
            elseif GetUnitTypeId(animal) == CST_UTI_Snake then
                set money = CST_INT_PriceOfSnake
            elseif GetUnitTypeId(animal) == CST_UTI_Chicken then
                set money = CST_INT_PriceOfChicken
            endif
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * CST_INT_GoldMagForGreedy)
            endif                   
            call KillUnit(animal)
            call AdjustPlayerStateBJ(money, this.get, PLAYER_STATE_RESOURCE_GOLD)
        endmethod
        
        // Butcher all animals immediately, return gold for killed animals
        public method butcherAllAnimal takes nothing returns nothing
            local integer gold = this.allAnimalIncome
            
            call iterateUnits(Filter(function thistype.filterButcherAllAnimal))
            call this.resetAnimalCounts()
            call AdjustPlayerStateBJ(gold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            
            // Animal count should be set to 0
            debug call ThrowWarning(this.allAnimalIncome != 0, "HVF", "butcherAllAnimal", "Farmer", this, " animal count is not cleared.")
        endmethod
        // Kill all units except farmer hero
        public method killAllUnits takes nothing returns nothing
            // Master will do butcher before at its death
            if this.role == CST_INT_FarmerRoleMaster then
                call butcherAllAnimal()
            endif
            call iterateUnits(Filter(function thistype.filterKillAllUnits))
            call this.resetFarmingCounts()
        endmethod
        public method allAnimalSpawnOn takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterAllAnimalSpawnOn))
        endmethod
        public method allAnimalSpawnOff takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterAllAnimalSpawnOff))
        endmethod
        public method animalAutoLoad takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterAnimalAutoLoad))
        endmethod
        public method animalLoadAll takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterAnimalLoadAll))
        endmethod
        public method animalUnloadAll takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterAnimalUnloadAll))
        endmethod
        // Create animal beside farming building for every 60 secs
        public method spawnAnimal takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterSpawnFarmingAnimal))
        endmethod
        // Transform build to No Spawn building
        public method transform2Ns takes unit building returns nothing
            call removeFarmingBuilding(building, true)
        endmethod
        // Transform build to Auto Spawn building
        public method transform2As takes unit building returns nothing
            call addFarmingBuilding(building, true)
        endmethod
        
        private method initHero takes nothing returns nothing
            local item tempItem
            
            if this.hero != null then
                set tempItem = CreateItem(CST_ITI_RetrainBook, GetUnitX(this.hero), GetUnitY(this.hero)) //GetUnitX
                call SetUnitState(this.hero, UNIT_STATE_MANA, GetUnitState(this.hero, UNIT_STATE_MAX_MANA) * 1)
                // Add one ability to make sure the success of
                // using of retrain book ... 
                call UnitAddAbility(this.hero, CST_ABI_FReveal)
                call UnitAddItem(this.hero, tempItem)
                call UnitUseItem(this.hero, UnitItemInSlot(this.hero, 0))
                call UnitRemoveItem(this.hero, tempItem)
                call RemoveItem(tempItem)
                call SetHeroLevelBJ(this.hero, 1, false)
                call UnitModifySkillPoints(this.hero, CST_INT_InitFarmerSkillPoints - GetHeroSkillPoints(this.hero))
                // In death race mode, bless Stealth/Invincible to newly revived hero
                if Params.flagGameModeDr then
                    set tempItem = CreateItem(CST_ITI_InvincibleNoCD, GetUnitX(this.hero), GetUnitY(this.hero))
                    call UnitAddItem(this.hero, tempItem)
                    call UnitUseItem(this.hero, UnitItemInSlot(this.hero, 0) )
                    call UnitRemoveItem(this.hero, tempItem)
                    call RemoveItem(tempItem)
                endif
                // Reset cooldown of items and abilities
                call UnitResetCooldown(this.hero)
            endif
            
            set tempItem = null
            call PanCameraToTimedForPlayer(this.get, GetUnitX(this.hero), GetUnitY(this.hero), 0.50)
        endmethod
        
        public method setHero takes unit u returns nothing
            local string properName
            set this.hero = u
            
            set properName = GetHeroProperName(this.hero)
            // Set role at first attach
            if properName == CST_STR_FarmerProperNamePlague then
                set this.role = CST_INT_FarmerRolePlague
                set this.heroIntro = CST_STR_FarmerIntroPlague
                call SetPlayerTechResearched(this.get, CST_TCI_Plague, 5)
            elseif properName == CST_STR_FarmerProperNameGreedy then
                set this.role = CST_INT_FarmerRoleGreedy
                set this.heroIntro = CST_STR_FarmerIntroGreedy
            elseif properName == CST_STR_FarmerProperNameKiller then
                set this.role = CST_INT_FarmerRoleKiller
                set this.heroIntro = CST_STR_FarmerIntroKiller
                call SetPlayerTechResearched(this.get, CST_TCI_Level1Upgrade, 1)
            elseif properName == CST_STR_FarmerProperNameNomader then
                set this.role = CST_INT_FarmerRoleNomader
                set this.heroIntro = CST_STR_FarmerIntroNomader
            elseif properName == CST_STR_FarmerProperNameCoward then
                set this.role = CST_INT_FarmerRoleCoward
                set this.heroIntro = CST_STR_FarmerIntroCoward
                call UnitAddAbility(this.hero, CST_ABI_NightVision)
                call SetPlayerTechResearched(this.get, CST_TCI_HeroLifeUp, 2)
            elseif properName == CST_STR_FarmerProperNameWoody then
                set this.role = CST_INT_FarmerRoleWoody
                set this.heroIntro = CST_STR_FarmerIntroWoody
            elseif properName == CST_STR_FarmerProperNameMaster then
                set this.role = CST_INT_FarmerRoleMaster
                set this.heroIntro = CST_STR_FarmerIntroMaster
            elseif properName == CST_STR_FarmerProperNameDefender then
                set this.role = CST_INT_FarmerRoleDefender
                set this.heroIntro = CST_STR_FarmerIntroDefender
                call SetPlayerTechResearched(this.get, CST_TCI_TowerLifeUp, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_TowerHealing, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_TowerVisionUp, 1)
            endif
        endmethod
        
        // Farmers Hero burn up their lifes
        private static method isAllHerosDie takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            
            loop
                exitwhen f.end
                if f.lifes > 0 then
                    return false
                endif
                set f=f.next
            endloop
            return true
        endmethod
        
        // Revive hero at random location
        public method reviveHero takes nothing returns nothing
            local real x = Map.randomX
            local real y = Map.randomY
            
            // If hero hasn't been created
            if this.hero == null then
                call this.setHero( CreateUnit(this.get, CST_UTI_FarmerHero, x, y, 0) )
                // x Don't check farmer hero is dead or not... since 
                // x IsUnitType(this.hero, UNIT_TYPE_DEAD) may return false
            elseif IsUnitType(this.hero, UNIT_TYPE_DEAD) then
                if Params.flagGameModeDr then
                    set this.lifes = this.lifes - 1
                    call ShowNoticeToPlayer(this.get,MSG_YouHave+I2S(this.lifes)+MSG_ChancesToReive)
                    if this.lifes <= 0 then
                        // If all farmers hero burn up their lifes, hunter win
                        if thistype.isAllHerosDie() then
                            call Farmer.lose()
                            call Hunter.win()
                        endif
                        call ShowErrorToAllPlayer(CST_STR_Player+": '"+GetPlayerName(this.get)+"' "+MSG_HasExhaustAllLifes)
                        return
                    endif
                endif
                // Hero die, revive it
                call ReviveHero(this.hero, x, y, false)
            endif
            
            // Init hero
            call initHero()
            
        endmethod
        
        // Add a farming building to group
        // Note, 'fromNs' means transfer No Spawn building to Auto Spawn building
        public method addFarmingBuilding takes unit building, boolean fromNs returns nothing
            local integer bti = GetUnitTypeId(building)
            // Add Auto Spawn building
            if not fromNs then
                if bti == CST_BTI_SheepFold then
                    set sheepFoldCount = sheepFoldCount + 1
                elseif bti == CST_BTI_Pigen then
                    set pigenCount = pigenCount + 1
                elseif bti == CST_BTI_SnakeHole then
                    set snakeHoleCount = snakeHoleCount + 1
                elseif bti == CST_BTI_Cage then
                    set cageCount = cageCount + 1
                endif
            endif
            
            // Transfer No Spawn building to Auto Spawn building
            if fromNs then
                if bti == CST_BTI_SheepFoldNs then
                    set sheepFoldCount = sheepFoldCount + 1
                    set sheepFoldNsCount = sheepFoldNsCount - 1
                elseif bti == CST_BTI_PigenNs then
                    set pigenCount = pigenCount + 1
                    set pigenNsCount = pigenNsCount - 1
                elseif bti == CST_BTI_SnakeHoleNs then
                    set snakeHoleCount = snakeHoleCount + 1
                    set snakeHoleNsCount = snakeHoleNsCount - 1
                elseif bti == CST_BTI_CageNs then
                    set cageCount = cageCount + 1
                    set cageNsCount = cageNsCount - 1
                endif
            endif
        endmethod
        
        // Upgrade a farming building
        public method upgradeFarmingBuilding takes unit building returns nothing
            if GetUnitTypeId(building) == CST_BTI_Pigen then
                set sheepFoldCount = sheepFoldCount - 1
                set pigenCount = pigenCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_SnakeHole then
                set pigenCount = pigenCount - 1
                set snakeHoleCount = snakeHoleCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_Cage then
                set snakeHoleCount = snakeHoleCount - 1
                set cageCount = cageCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_PigenNs then
                set sheepFoldNsCount = sheepFoldNsCount - 1
                set pigenNsCount = pigenNsCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_SnakeHoleNs then
                set pigenNsCount = pigenNsCount - 1
                set snakeHoleNsCount = snakeHoleNsCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_CageNs then
                set snakeHoleNsCount = snakeHoleNsCount - 1
                set cageNsCount = cageNsCount + 1
            endif
        endmethod
        
        // Note, 'toNs' means transfer building to No Spawn building
        public method removeFarmingBuilding takes unit building, boolean toNs returns nothing
            local integer bti = GetUnitTypeId(building)
            if bti == CST_BTI_SheepFold then
                set sheepFoldCount = sheepFoldCount - 1
                if toNs then
                    set sheepFoldNsCount = sheepFoldNsCount + 1 
                endif
            elseif bti == CST_BTI_Pigen then
                set pigenCount = pigenCount - 1
                if toNs then
                    set pigenNsCount = pigenNsCount + 1 
                endif
            elseif bti == CST_BTI_SnakeHole then
                set snakeHoleCount = snakeHoleCount - 1
                if toNs then
                    set snakeHoleNsCount = snakeHoleNsCount + 1 
                endif
            elseif bti == CST_BTI_Cage then
                set cageCount = cageCount - 1
                if toNs then
                    set cageNsCount = cageNsCount + 1 
                endif
            endif
            
            // Remove No Spawn building
            if not toNs then
                if bti == CST_BTI_SheepFoldNs then
                    set sheepFoldNsCount = sheepFoldNsCount - 1
                elseif bti == CST_BTI_PigenNs then
                    set pigenNsCount = pigenNsCount - 1
                elseif bti == CST_BTI_SnakeHoleNs then
                    set snakeHoleNsCount = snakeHoleNsCount - 1
                elseif bti == CST_BTI_CageNs then
                    set cageNsCount = cageNsCount - 1
                endif
            endif
        endmethod
        
        public method addFarmingAminal takes unit animal returns nothing
            if GetUnitTypeId(animal) == CST_UTI_Sheep then
                set sheepCount = sheepCount + 1
            elseif GetUnitTypeId(animal) == CST_UTI_Pig then
                set pigCount = pigCount + 1
            elseif GetUnitTypeId(animal) == CST_UTI_Snake then
                set snakeCount = snakeCount + 1
            elseif GetUnitTypeId(animal) == CST_UTI_Chicken then
                set chickenCount = chickenCount + 1
            endif
        endmethod
        
        public method removeFarmingAminal takes unit animal returns nothing
            if GetUnitTypeId(animal) == CST_UTI_Sheep then
                set sheepCount = sheepCount - 1
            elseif GetUnitTypeId(animal) == CST_UTI_Pig then
                set pigCount = pigCount - 1
            elseif GetUnitTypeId(animal) == CST_UTI_Snake then
                set snakeCount = snakeCount - 1
            elseif GetUnitTypeId(animal) == CST_UTI_Chicken then
                set chickenCount = chickenCount - 1
            endif
        endmethod
        
        private method resetAnimalCounts takes nothing returns nothing
            set sheepCount      = 0
            set pigCount        = 0
            set snakeCount      = 0
            set chickenCount    = 0
        endmethod
        
        private method resetFarmingCounts takes nothing returns nothing
            call this.resetAnimalCounts()
            set sheepFoldNsCount= 0
            set pigenNsCount    = 0
            set snakeHoleNsCount= 0
            set cageNsCount     = 0
            
            set sheepCount      = 0
            set pigCount        = 0
            set snakeCount      = 0
            set chickenCount    = 0
        endmethod
        
        method initFarmerVars takes nothing returns nothing
            // *** Desyncs here!
            //set sheepFolds  = CreateGroup()
            //set pigens      = CreateGroup()
            //set snakeHoles  = CreateGroup()
            //set cages       = CreateGroup()
            
            call this.resetFarmingCounts()
            
            set .lifes          = CST_INT_MaxLifePoints
            set .role           = CST_INT_FarmerRoleInvalid
            set .bLeave         = false
            set .killCount      = 0
            set .towerCount     = 0
            set .treeCount      = 0
            set .woodCount      = 0
            set .deathCount     = 0

            // Bind predefined hero to farmer
            // call iterateUnits(Filter(function thistype.filterBindHero))
            // Set begin resource, limitations
            debug call BJDebugMsg("Init gold:" + I2S(CST_INT_HunterBeginGold))
            call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, this.get)
            call AdjustPlayerStateBJ(CST_INT_FarmerBeginGold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            call AdjustPlayerStateBJ(CST_INT_FarmerBeginLumber, this.get, PLAYER_STATE_RESOURCE_LUMBER)
            call SetPlayerTechMaxAllowed(this.get, CST_BTI_Slaughterhouse, 1)
            call SetPlayerTechMaxAllowed(this.get, CST_BTI_ArmsRecycler, 1)
            
            // Set camera to farmer hero
            // call PanCameraToTimedForPlayer(this.get, GetUnitX(this.hero), GetUnitY(this.hero), 0.50)
        endmethod
        
        method deleteFarmerVars takes nothing returns nothing
            // Kill/Remove all units
            call iterateUnits(Filter(function thistype.filterKillAllUnits))
            call RemoveUnit(this.hero)
            
        endmethod
        
    endmodule
    
    /***************************************************************************
    * Structs
    ***************************************************************************/
    /***************************************************************************
    **** Hunter
    ***************************************************************************/
    // Associate players with their force , units, data.
    struct Hunter extends array
        // Staitic [Module]
        implement Force
        implement StatsBoardModule
        // Instance [Vars]
        implement HunterVars
        
        StatsRecord sr      // Statistics record
        
        // Instance methods
        
        // When these 2 hunters have same score, we must distinguish who is better 
        method isBetterThan takes thistype h returns boolean
            if .killCount < h.killCount then
                return false
            elseif .killCount == h.killCount then
                if GetPlayerState(.get,PLAYER_STATE_GOLD_GATHERED) < GetPlayerState(h.get,PLAYER_STATE_GOLD_GATHERED) then
                    return false
                endif
            endif
            
            return true
        endmethod
        
        method calculateMerit takes nothing returns integer
            local integer merit = R2I(.killCount * CST_MRT_Mag)
            
            if merit > CST_MRT_Max then
                set merit = CST_MRT_Max
            endif
            return merit
        endmethod
        
        method calculateScore takes boolean last returns integer
            local integer score = 0
            local integer gold = GetPlayerState(.get,PLAYER_STATE_GOLD_GATHERED)
            local integer surviveTime
            local integer maxLevel
            
            // Check if hero is still survive
            if GetUnitTypeId(.hero) != CST_UTI_HunterHeroSkeleton then
                set surviveTime = TimerManager.getPlayedTime()
                set maxLevel = GetHeroLevel(.hero)
            else
                set surviveTime = .heroSurviveTime
                set maxLevel = .heroMaxLevel
            endif
            
            if .killCount < 1 then 
            elseif .killCount < 5 then
                set score = score + 1
            elseif .killCount < 10 then
                set score = score + 2
            elseif .killCount < 20 then
                set score = score + 3
            elseif .killCount < 30 then
                set score = score + 4
            else
                set score = score + 5
            endif
            
            if gold < 500 then
            
            elseif gold < 1000 then
                set score = score + 1
            elseif gold < 2000 then
                set score = score + 2
            elseif gold < 3500 then
                set score = score + 3
            elseif gold < 6000 then
                set score = score + 4
            else
                set score = score + 5
            endif
            
            if maxLevel < 5 then 
            elseif maxLevel < 10 then
                set score = score + 1
            elseif maxLevel < 15 then
                set score = score + 2
            elseif maxLevel < 20 then
                set score = score + 3
            elseif maxLevel < 25 then
                set score = score + 4
            else
                set score = score + 5
            endif
            
            if surviveTime < 20 then 
            elseif surviveTime < 30 then
                set score = score + 1
            elseif surviveTime < 35 then
                set score = score + 2
            elseif surviveTime < 40 then
                set score = score + 3
            elseif last then
                set score = score + 5
            endif
        
            return score
        endmethod
        
        private method createBeginUnits takes integer i returns nothing
            local real x = GetLocationX(Map.heroReviveLoc)
            local real y = GetLocationY(Map.heroReviveLoc)
            set .index = i
            set .heroBox = CreateUnit(this.get, CST_BTI_HunterHeroBox, Map.itemBoxXs[i], Map.itemBoxYs[i], CST_Facing_Building)
            set .dummy = CreateUnit(this.get, CST_UTI_HunterWorker, GetRandomReal(GetRectMinX(Map.regionHeroRevive), GetRectMaxX(Map.regionHeroRevive)), GetRandomReal(GetRectMinY(Map.regionHeroRevive), GetRectMaxY(Map.regionHeroRevive)), CST_Facing_Unit)
            call UnitAddAbility(.dummy,CST_ABI_Invulnerable)
        endmethod
        
        private method updateRankAndTitle takes nothing returns nothing
            local integer rl = StatsManager.evalRankLevel(.sr.HunterScore)
            local integer tci = CST_TCI_RankFirst + rl
            local boolean isE = StatsManager.isElite(.sr)
            local string rText = CST_STR_HRankNeophyte
            local string rIcon = ICON_Empty
            
            if rl < CST_RL_Soldier and isE then 
                set rText = CST_STR_HRankEliteHunter
            elseif rl == CST_RL_Soldier then
                set rText = CST_STR_HRankSoldier
                set rIcon = ICON_MEDAL_Soldier
                if isE then
                    set rText = CST_STR_HRankEliteSoldier
                endif
            elseif rl == CST_RL_Rider then
                set rText = CST_STR_HRankRider
                set rIcon = ICON_MEDAL_Rider
                if isE then
                    set rText = CST_STR_HRankEliteRider
                endif
            elseif rl == CST_RL_Guard then
                set rText = CST_STR_HRankGuard
                set rIcon = ICON_MEDAL_Guard
                
                call SetPlayerTechResearched(this.get, CST_TCI_RankGuard, 1)
                if isE then
                    set rText = CST_STR_HRankEliteGuard
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteGuard, 1)
                endif
            elseif rl == CST_RL_Ranger then
                set rText = CST_STR_HRankRanger
                set rIcon = ICON_MEDAL_Ranger
                
                call SetPlayerTechResearched(this.get, CST_TCI_RankGuard, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankRanger, 1)
                if isE then
                    set rText = CST_STR_HRankEliteRanger
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteGuard, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteRanger, 1)
                endif
            elseif rl == CST_RL_General then
                set rText = CST_STR_HRankGeneral
                set rIcon = ICON_MEDAL_General
                
                call SetPlayerTechResearched(this.get, CST_TCI_RankGuard, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankRanger, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankGeneral, 1)
                if isE then
                    set rText = CST_STR_HRankGranGeneral
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteGuard, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteRanger, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranGeneral, 1)
                endif
            elseif rl == CST_RL_Captain then
                set rText = CST_STR_HRankCaptain
                set rIcon = ICON_MEDAL_Captain
                
                call SetPlayerTechResearched(this.get, CST_TCI_RankGuard, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankRanger, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankGeneral, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankCaptain, 1)
                if isE then
                    set rText = CST_STR_HRankGranCaptain
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteGuard, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteRanger, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranGeneral, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranCaptain, 1)
                endif
            elseif rl == CST_RL_Marshal then
                set rText = CST_STR_HRankMarshal
                set rIcon = ICON_MEDAL_Marshal
                
                call SetPlayerTechResearched(this.get, CST_TCI_RankGuard, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankRanger, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankGeneral, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankCaptain, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_RankMarshal, 1)
                if isE then
                    set rText = CST_STR_HRankGranMarshal
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteGuard, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankEliteRanger, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranGeneral, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranCaptain, 1)
                    call SetPlayerTechResearched(this.get, CST_TCI_RankGranMarshal, 1)
                endif
            endif
            
            // Update board
            set StatsBoard.hb[CST_BDCOL_RK][.bIndex].text = rText
            set StatsBoard.hb[CST_BDCOL_RK][.bIndex].icon = rIcon
        endmethod
        
        private method initInstance takes nothing returns nothing
            call this.initHunterVars()
            set this.sr = StatsRecord.create(this.get)
            // After stats record being read, update rank and title
            call this.updateRankAndTitle()
           
        endmethod
        
        private method deleteInstance takes nothing returns nothing
            call this.deleteHunterVars()
        endmethod

        private method commitStats takes boolean win returns nothing
           
            set this.sr.HunterPlays = this.sr.HunterPlays + 1
            
            if win then
                set this.sr.Wins = this.sr.Wins + 1
                set this.sr.HunterWins = this.sr.HunterWins + 1
            else
            
            endif
            
            // Last commit the stats record
            call this.sr.save(this.get)
        endmethod
        
        // Static methods
        // Print force info
        static method info takes boolean showHeroInfo returns string
            local string str = " " + ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Hunter) + "(" + CST_STR_Number + ARGB(COLOR_ARGB_GREEN).str(I2S(thistype.count)) + ")" + "\n"
            local thistype p = thistype[thistype.first]
            local ARGB ac
            
            if thistype.count > 0 then
                loop
                    exitwhen p.end
                    set ac = ARGB.fromPlayer(p.get)
                    set str = str + "  " + I2S(GetPlayerId(p.get)+1) + " - " + ac.str(GetPlayerName(p.get))
                    if showHeroInfo then
                        set str = str + "[" + ARGB(COLOR_ARGB_ORANGE).str(GetUnitName(p.hero)) + ", "+CST_STR_Level+ARGB(COLOR_ARGB_GREEN).str(I2S(GetHeroLevel(p.hero)))+"]"
                    endif
                    set str = str + "\n"
                    set p = p.next
                endloop
            endif
            return str
        endmethod
        public static method removeLeaving takes player p returns nothing
            local thistype h = thistype[GetPlayerId(p)]

            /*
            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][h.rowIndex].text = CST_STR_StatusHasLeft
                set Farmer.statsBoard[CST_BDCOL_ST][h.erowIndex].text = CST_STR_StatusHasLeft
            else
            
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
            */
            // remove unit of this player
            // or share control/vision of leaving player with other playing players?
            call h.deleteInstance()
            call thistype.remove(p)
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
                call AdjustPlayerStateSimpleBJ(h.get, PLAYER_STATE_RESOURCE_GOLD, iGold)
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
                if h.hero == null or h.isPending then
                    debug call BJDebugMsg(GetPlayerName(h.get)+" hasn't selected hero")
                    call h.setHero(null)
                endif
                set h= h.next
            endloop
            return false
        endmethod
        
        // On game start
        private static method init takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            local integer i = 0
            
            loop
                exitwhen h.end
                // Init instance vars
                call h.initInstance()
                call h.createBeginUnits(i)
                set i = i + 1
                set h = h.next
            endloop
            // Delegate computer player
            call thistype.delegateAllRobots()
            return false
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerManager.onGameStart.register(Filter(function thistype.init))
            
            call TimerManager.pt60s.register(Filter(function thistype.goldBonusForKilling))
            call TimerManager.pt60s.register(Filter(function thistype.distributeResources))
            call TimerManager.otSelectHero.register(Filter(function thistype.onSelectHeroExpire))
            // Play time is over, hunters win
            // call TimerManager.otPlayTimeOver.register(Filter(function thistype.win))
        endmethod
        
    endstruct
    
    /***************************************************************************
    **** Farmer
    ***************************************************************************/
    struct Farmer extends array
        // Staitic [Module]
        implement Force
        implement StatsBoardModule
        // Instance [Vars]
        implement FarmerVars
        
        // Statistics record 
        StatsRecord sr
        
        private static integer exp = 0
        private static integer expTick=0
        
        // Instance methods
        
        // When these 2 hunters have same score, we must distinguish who is better 
        method isBetterThan takes thistype f returns boolean
            if .killCount < f.killCount then
                return false
            elseif .killCount == f.killCount then
                if GetPlayerState(.get,PLAYER_STATE_GOLD_GATHERED) < GetPlayerState(f.get,PLAYER_STATE_GOLD_GATHERED) then
                    return false
                endif
            endif
            
            return true
        endmethod
        
        method calculateWealth takes nothing returns integer
            local integer wealth = R2I(GetPlayerState(.get,PLAYER_STATE_GOLD_GATHERED)/CST_WEL_Mag)
            
            if wealth > CST_WEL_Max then
                set wealth = CST_WEL_Max
            endif
            return wealth
        endmethod
        
        method calculateScore takes boolean last returns integer
            local integer score = 0
            local integer gold = GetPlayerState(.get,PLAYER_STATE_GOLD_GATHERED)
            
            set score = score + .killCount * 3
            if gold < 5000 then
            
            elseif gold < 20000 then
                set score = score + 1
            elseif gold < 50000 then
                set score = score + 2
            elseif gold < 100000 then
                set score = score + 3
            elseif gold < 200000 then
                set score = score + 4
            else
                set score = score + 5
            endif
            
            if gold < 20000 then
                if .woodCount < 1 then 
                elseif .woodCount < 5 then
                    set score = score + 1
                elseif .woodCount < 10 then
                    set score = score + 2
                elseif .woodCount < 20 then
                    set score = score + 3
                else
                    set score = score + 4
                endif
                
                if .towerCount < 20 then 
                elseif .towerCount < 30 then
                    set score = score + 1
                elseif .towerCount < 50 then
                    set score = score + 2
                elseif .towerCount < 80 then
                    set score = score + 3
                else
                    set score = score + 5
                endif
                
                if .treeCount < 20 then 
                elseif .treeCount < 30 then
                    set score = score + 1
                else
                    set score = score + 2
                endif
            elseif last then
                if .deathCount > 8 then 
                elseif .deathCount > 5 then
                    set score = score + 1
                elseif .deathCount > 3 then
                    set score = score + 2
                elseif .deathCount > 1 then
                    set score = score + 3
                else
                    set score = score + 6
                endif
            endif
            
            return score
        
        endmethod
        
        private method initInstance takes nothing returns nothing
            call this.initFarmerVars()
            set this.sr = StatsRecord.create(this.get)
        endmethod
        
        private method deleteInstance takes nothing returns nothing
            call this.deleteFarmerVars()
        endmethod

        private method commitStats takes boolean win returns nothing
            set this.sr.FarmerPlays = this.sr.FarmerPlays + 1
            
            if win then
                set this.sr.Wins = this.sr.Wins + 1
                set this.sr.FarmerWins = this.sr.FarmerWins + 1
            else
            
            endif
            
            // Last commit the stats record
            call this.sr.save(this.get)
        endmethod
        
        // Static methods
        // Print force info
        static method info takes boolean showHeroInfo returns string
            local string str = " " + ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Farmer) + "(" + CST_STR_Number + ARGB(COLOR_ARGB_GREEN).str(I2S(thistype.count)) + ")" + "\n"
            local thistype p = thistype[thistype.first]
            local ARGB ac
            
            if thistype.count > 0 then
                loop
                    exitwhen p.end
                    set ac = ARGB.fromPlayer(p.get)
                    set str = str + "  " + I2S(GetPlayerId(p.get)+1) + " - " + ac.str(GetPlayerName(p.get))
                    if showHeroInfo then
                        set str = str + "[" + ARGB(COLOR_ARGB_ORANGE).str(GetHeroProperName(p.hero)) + ", "+CST_STR_Level+ARGB(COLOR_ARGB_GREEN).str(I2S(GetHeroLevel(p.hero)))+"]"
                    endif
                    set str = str + "\n"
                    set p = p.next
                endloop
            endif
            return str
        endmethod
        
        public static method removeLeaving takes player p returns nothing
            local thistype f = thistype[GetPlayerId(p)]

            /*
            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][f.rowIndex].text = CST_STR_StatusHasLeft
                set Hunter.statsBoard[CST_BDCOL_ST][f.erowIndex].text = CST_STR_StatusHasLeft
            else
            
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
            */
            // remove unit of this player
            // or share control/vision of leaving player with other playing players?
            call f.deleteInstance()
            call thistype.remove(p)
        endmethod

        // Get total animals' count
        public static method getTotalAnimalCount takes nothing returns integer
            local thistype f = thistype[thistype.first]
            local integer totalAnimalCount = 0

            loop
                exitwhen f.end
                set totalAnimalCount = totalAnimalCount + f.animalCount
                set f= f.next
            endloop
            
            return totalAnimalCount
        endmethod
        
        // Farmer's income settlement
        private static method incomeSettlement takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            local integer gold = 0
            
            loop
                exitwhen f.end
                debug call BJDebugMsg("IncomeSettlement for farmer:" + GetPlayerName(f.get))
                // Spawn animals
                // If total aminal count doesn't exceed CST_INT_MaxAnimals, spawn
                if thistype.getTotalAnimalCount() < CST_INT_MaxAnimals then
                    debug call BJDebugMsg("TotalAnimalCount:" + I2S(thistype.getTotalAnimalCount()))
                    debug call BJDebugMsg("Spawn animal for" + GetPlayerName(f.get))
                    call f.spawnAnimal()
                    set gold = 0
                // Else don't spawn, give overflow gold to players
                else
                    set gold = f.overflowIncome
                endif
                // settlement
                set gold = gold + f.noSpawnIncome + f.deathIncome
                call AdjustPlayerStateBJ(gold, f.get, PLAYER_STATE_RESOURCE_GOLD)
                // If farmer is 'woody' give extra lumber income
                if f.role == CST_INT_FarmerRoleWoody then
                    call AdjustPlayerStateBJ(R2I(gold*0.15), f.get, PLAYER_STATE_RESOURCE_LUMBER)
                endif
                set f= f.next
            endloop
            
        endmethod
        
        // Farmer's salary settlement
        private static method salarySettlement takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            //local integer gold = 0
            
            debug call BJDebugMsg("Salary!")
            loop
                exitwhen f.end
                call AdjustPlayerStateBJ(f.salary + CST_INT_SalaryAlms, f.get, PLAYER_STATE_RESOURCE_GOLD)
                set f= f.next
            endloop
        endmethod
        
        private static method aquireFreeExp takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            
            debug call BJDebugMsg("Give free exp to farmers")
            
            set thistype.expTick = thistype.expTick + 1
            
            if not IsIntDividableBy(thistype.expTick, CST_INT_ExpTickStep) then
                return
            endif
            set thistype.exp = thistype.exp + CST_INT_ExpAddForTick
            
            loop
                exitwhen f.end
                debug call BJDebugMsg("Give " +I2S(thistype.exp)+ "exp to farmer:" + GetPlayerName(f.get))
                if f.hero != null then
                    call AddHeroXP(f.hero, thistype.exp, true)
                endif
                set f= f.next
            endloop
        endmethod
            
        // On game start
        private static method init takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            local integer i = 0
            // Init statistics board
            // call thistype.initStatsBoard()
            loop
                exitwhen f.end
                // Init instance vars
                call f.initInstance()
                
                // Create hero at random location
                call f.reviveHero()
                
                // Display stats board
                debug call BJDebugMsg("Display board to farmer:" + GetPlayerName(f.get))
                // set statsBoard.visible[f.get] = true
                
                // Test
                /*
                loop
                    exitwhen i >= 8
                    set i = i + 1
                    call CreateUnitAtLoc(f.get, 'Nbrn', GetPlayerStartLocationLoc(f.get), bj_UNIT_FACING)
                endloop
                */
                set f = f.next
            endloop
            
            // Delegate computer player
            call thistype.delegateAllRobots()
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            // Init and display multiboard at game start
            call TimerManager.onGameStart.register(Filter(function thistype.init))
            
            call TimerManager.pt15s.register(Filter(function thistype.salarySettlement))
            call TimerManager.pt60s.register(Filter(function thistype.incomeSettlement))
            call TimerManager.pt60s.register(Filter(function thistype.aquireFreeExp))
            call TimerManager.pt60s.register(Filter(function thistype.distributeResources))
            
            // Play time is over, farmers lose
            // call TimerManager.otPlayTimeOver.register(Filter(function thistype.lose))
        endmethod
    endstruct
    
    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/
    
    function InSameForce takes player p, player p2 returns boolean
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
                    //debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunter")
                    call DisplayTimedTextToPlayer(ap.get, 0, 0, CST_MSGDUR_Normal, MSG_ShufflePlayerTo+ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Hunter))
                    call Hunter.add(ap.get)
                    set iHunterCount = iHunterCount + 1
                else
                    call DisplayTimedTextToPlayer(ap.get, 0, 0, CST_MSGDUR_Normal, MSG_ShufflePlayerTo+ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Farmer))
                    call Farmer.add(ap.get)
                    set iFarmerCount = iFarmerCount + 1
                endif
            else
                if iFarmerCount == iNbrFarmers then
                    call DisplayTimedTextToPlayer(ap.get, 0, 0, CST_MSGDUR_Normal, MSG_ShufflePlayerTo+ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Hunter))
                    call Hunter.add(ap.get)
                    set iHunterCount = iHunterCount + 1
                else
                    call DisplayTimedTextToPlayer(ap.get, 0, 0, CST_MSGDUR_Normal, MSG_ShufflePlayerTo+ARGB(COLOR_ARGB_YELLOW).str(CST_STR_Farmer))
                    call Farmer.add(ap.get)
                    set iFarmerCount = iFarmerCount + 1
                endif
            endif
            set ap = ap.next
        endloop
        
        debug call BJDebugMsg("Shuffling finished! Number of Farmer:" + I2S(iNbrFarmers) + ", Number of Hunter:" +I2S(iNbrHunters))
        //call BJDebugMsg(Farmer.info(false))
        //call BJDebugMsg(Hunter.info(false))
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Beaware, Farmer.info(false))
        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Beaware, Hunter.info(false))
        // Re-assemble team and alliance after shuffling
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
    * Library Initiation
    ***************************************************************************/
    private function init takes nothing returns nothing
        // Grouping players to Hunter/Farmer force by default
        call LoadDefaultSetting()
        // Play time is over, hunters win
        call TimerManager.otPlayTimeOver.register(Filter(function HunterWin))
    endfunction
endlibrary
