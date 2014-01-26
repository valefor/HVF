library HVF initializer init/* v0.0.1 Xandria
*/  uses    Alloc           /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/          PlayerManager   /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/          PlayerAlliance  /*  List
*/          TimeManager     /*
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
    /***************************************************************************
    * Modules
    ***************************************************************************/
    // Statistics
    private module StatsBoard
        static Board statsBoard = -1
        integer rowIndex
        integer erowIndex
        
        static method createStatsBoard takes nothing returns nothing
            set statsBoard = Board.create()
        endmethod
    endmodule
    
    // Force related utils    
    module Force
        implement DualLinkedList
        static force fc
        
        // Static Methods
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
            set thistype.statsBoard[CST_BDCOL_KL][rowIndex].text = I2S(this.killCount)
            set Farmer.statsBoard[CST_BDCOL_KL][erowIndex].text = I2S(this.killCount)
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
                if h.hero != null and IsUnitHunterHero(h.hero) then
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
                set this.hero = CreateUnitAtLoc(this.get, CST_UTI_HunterHeroSkeleton, MapLocation.heroReviveLoc, CST_Facing_Unit)
                // If all hunter hero die, farmer win
                if thistype.isAllHerosDie() then
                    call Farmer.win()
                    call Hunter.lose()
                endif
            else
                set this.hero = CreateUnitAtLoc(this.get, CST_UTI_HunterHeroSkeleton, MapLocation.heroReviveLoc, CST_Facing_Unit)
            endif
            call PanCameraToTimedLocForPlayer(this.get, MapLocation.heroReviveLoc, 0.50)
        endmethod
        
        private method initHero takes nothing returns nothing
            // Give hunter hero 3 skill points at beginning
            call UnitModifySkillPoints(this.hero, CST_INT_InitHunterSkillPoints - GetHeroSkillPoints(this.hero))
            // Give items
        endmethod
        
        public method createRandomHero takes location l returns nothing
            local location loc = Location(GetLocationX(MapLocation.heroReviveLoc), GetLocationY(MapLocation.heroReviveLoc))
            
            debug call BJDebugMsg("Center X of MapLocation.regionHeroRevive:" + R2S(GetRectCenterX(MapLocation.regionHeroRevive)))
            debug call BJDebugMsg("Create random hero at location >> X:" + R2S(GetLocationX(loc))+ ", Y:"+ R2S(GetLocationY(loc)) )
            if l !=null then
                call RemoveLocation(loc)
                set loc = l
            endif
            debug call BJDebugMsg("Create random hero for " + GetPlayerName(this.get))
            
            set this.hero = CreateUnitAtLoc(this.get, GetRandomHeroUti(), loc, 0)
            // Give random hunter hero extra bonus such as life(+2000) agi(+3) int(+2)... 
            set Bonus_Life[hero]=CST_INT_RandomBonusLife
            set Bonus_Armor[hero]=CST_INT_RandomBonusArmor
            set Bonus_Agi[hero]=CST_INT_RandomBonusAgi
            set Bonus_Int[hero]=CST_INT_RandomBonusInt
            call this.initHero()
            
            call RemoveLocation(loc)
            set loc = null
        endmethod
        
        public method setHero takes unit u returns nothing
            if u != null then
                if GetUnitTypeId(u) == CST_UTI_HunterHeroRandom then
                    call this.createRandomHero(GetUnitLoc(u))
                    call RemoveUnit(u)
                else
                    set this.hero = u
                    call this.initHero()
                endif
            endif
        endmethod
        
        method initHunterVars takes nothing returns nothing
            set this.killCount = 0
            set this.hero = null
            
            call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, this.get)
            call AdjustPlayerStateBJ(CST_INT_HunterBeginGold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            call AdjustPlayerStateBJ(CST_INT_HunterBeginLumber, this.get, PLAYER_STATE_RESOURCE_LUMBER)
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
        
        integer deathCount
        integer role
        
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
            set thistype.statsBoard[CST_BDCOL_DE][rowIndex].text = I2S(.deathCount)
            set Hunter.statsBoard[CST_BDCOL_KL][erowIndex].text = I2S(.deathCount)
        endmethod
        
        public method operator animalCount takes nothing returns integer
            return (.sheepCount + .pigCount + .snakeCount + .chickenCount)
        endmethod
        
        // Salary for every x minutes/seconds depends on animalType*animalCount
        public method operator salary takes nothing returns integer
            local integer money = (CST_INT_SalaryBaseSheep*sheepCount) + (CST_INT_SalaryBasePig*pigCount) + (CST_INT_SalaryBaseSnake*snakeCount) + (CST_INT_SalaryBaseChicken*chickenCount)
            
            // Nomader has more salary
            if this.role == CST_INT_FarmerRoleNomader then
                set money = R2I(money * 1.5)
            endif
            return money
        endmethod
        
        // Income for killing all animals
        public method operator allAnimalIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepCount) + (CST_INT_PriceOfPig*pigCount) + (CST_INT_PriceOfSnake*snakeCount) + (CST_INT_PriceOfChicken*chickenCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * 1.3)
            endif
            return money
        endmethod
        
        // Income for killing overflow animals
        public method operator overflowIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepFoldCount) + (CST_INT_PriceOfPig*pigenCount) + (CST_INT_PriceOfSnake*snakeHoleCount) + (CST_INT_PriceOfChicken*cageCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * 1.3)
            endif
            return money
        endmethod
        // Income from no spawn buildings
        public method operator noSpawnIncome takes nothing returns integer
            local integer money = (CST_INT_PriceOfSheep*sheepFoldNsCount) + (CST_INT_PriceOfPig*pigenNsCount) + (CST_INT_PriceOfSnake*snakeHoleNsCount) + (CST_INT_PriceOfChicken*cageNsCount)
            // Greedy has more money for butcher animal
            if this.role == CST_INT_FarmerRoleGreedy then
                set money = R2I(money * 1.3)
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
                set money = R2I(money * 1.3)
            endif                   
            call KillUnit(animal)
            call AdjustPlayerStateBJ(money, this.get, PLAYER_STATE_RESOURCE_GOLD)
        endmethod
        
        // Butcher all animals immediately, return gold for killed animals
        public method butcherAllAnimal takes nothing returns nothing
            local integer gold = this.allAnimalIncome
            
            call iterateUnits(Filter(function thistype.filterButcherAllAnimal))
            
            call AdjustPlayerStateBJ(gold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            
            // Animal count should be set to 0
            debug call ThrowWarning(this.allAnimalIncome != 0, "HVF", "butcherAllAnimal", "Farmer", this, " animal count is not cleared.")
        endmethod
        // Kill all units except farmer hero
        public method killAllUnits takes nothing returns nothing
            call iterateUnits(Filter(function thistype.filterKillAllUnits))
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
            local item retrainBook
            
            if this.hero != null then
                set retrainBook = CreateItem(CST_ITI_RetrainBook, GetUnitX(this.hero), GetUnitY(this.hero)) //GetUnitX
                call SetUnitState(this.hero, UNIT_STATE_MANA, GetUnitState(this.hero, UNIT_STATE_MAX_MANA) * 1)
                call UnitResetCooldown(this.hero)
                // call UnitAddItem(this.hero, retrainBook)
                call UnitUseItem(this.hero, retrainBook)
                call SetHeroLevelBJ(this.hero, 1, false)
                call UnitModifySkillPoints(this.hero, CST_INT_InitFarmerSkillPoints - GetHeroSkillPoints(this.hero))
                call RemoveItem(retrainBook)
            endif
            
            set retrainBook = null
        endmethod
        
        public method setHero takes unit u returns nothing
            local string properName
            set this.hero = u
            
            set properName = GetHeroProperName(this.hero)
            // Set role at first attach
            if properName == CST_STR_FarmerProperNamePlague then
                set this.role = CST_INT_FarmerRolePlague
                call SetPlayerTechResearched(this.get, CST_TCI_Plague, 5)
            elseif properName == CST_STR_FarmerProperNameGreedy then
                set this.role = CST_INT_FarmerRoleGreedy
            elseif properName == CST_STR_FarmerProperNameKiller then
                set this.role = CST_INT_FarmerRoleKiller
                call SetPlayerTechResearched(this.get, CST_TCI_Level1Upgrade, 1)
            elseif properName == CST_STR_FarmerProperNameNomader then
                set this.role = CST_INT_FarmerRoleNomader
            elseif properName == CST_STR_FarmerProperNameCoward then
                set this.role = CST_INT_FarmerRoleCoward
                call UnitAddAbility(this.hero, CST_ABI_NightVision)
                call SetPlayerTechResearched(this.get, CST_TCI_HeroLifeUp, 2)
            elseif properName == CST_STR_FarmerProperNameWoody then
                set this.role = CST_INT_FarmerRoleWoody
            elseif properName == CST_STR_FarmerProperNameMaster then
                set this.role = CST_INT_FarmerRoleMaster
            elseif properName == CST_STR_FarmerProperNameDefender then
                set this.role = CST_INT_FarmerRoleDefender
                call SetPlayerTechResearched(this.get, CST_TCI_TowerLifeUp, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_TowerHealing, 1)
                call SetPlayerTechResearched(this.get, CST_TCI_TowerVisionUp, 1)
            endif
            
            call initHero()
        endmethod
        
        // Revive hero at random location
        public method reviveHero takes nothing returns nothing
            local real x = MapLocation.randomX
            local real y = MapLocation.randomY
            
            // If hero hasn't been created
            if this.hero == null then
                call this.setHero( CreateUnit(this.get, CST_UTI_FarmerHero, x, y, 0) )
            elseif IsUnitType(this.hero, UNIT_TYPE_DEAD) then
                // Hero die, revive it
                call ReviveHero(this.hero, x, y, false)
            else
                return
            endif
            
            call initHero()
            call PanCameraToTimedForPlayer(this.get, x, y, 0.50)
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
        
        method initFarmerVars takes nothing returns nothing
            // *** Desyncs here!
            //set sheepFolds  = CreateGroup()
            //set pigens      = CreateGroup()
            //set snakeHoles  = CreateGroup()
            //set cages       = CreateGroup()
            
            set sheepFoldCount  = 0
            set pigenCount      = 0
            set snakeHoleCount  = 0
            set cageCount       = 0
            
            set sheepFoldNsCount= 0
            set pigenNsCount    = 0
            set snakeHoleNsCount= 0
            set cageNsCount     = 0
            
            set sheepCount      = 0
            set pigCount        = 0
            set snakeCount      = 0
            set chickenCount    = 0
            
            set deathCount      = 0
            set role            = CST_INT_FarmerRoleInvalid
            
            // Bind predefined hero to farmer
            // call iterateUnits(Filter(function thistype.filterBindHero))
            // Set begin resource, limitations
            debug call BJDebugMsg("Init gold:" + I2S(CST_INT_HunterBeginGold))
            call SetPlayerFlagBJ(PLAYER_STATE_GIVES_BOUNTY, true, this.get)
            call AdjustPlayerStateBJ(CST_INT_FarmerBeginGold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            call AdjustPlayerStateBJ(CST_INT_FarmerBeginLumber, this.get, PLAYER_STATE_RESOURCE_LUMBER)
            call SetPlayerTechMaxAllowed(this.get, CST_BTI_Slaughterhouse, 1)
            call SetPlayerTechMaxAllowed(this.get, CST_BTI_ArmsRecycler, 1)
        endmethod
        
        method deleteFarmerVars takes nothing returns nothing
        endmethod
        
    endmodule
    
    /***************************************************************************
    * Structs
    ***************************************************************************/
    // Associate players with their force , units, data.
    struct Hunter extends array
        // Staitic [Module]
        implement Force
        implement StatsBoard
        // Instance [Vars]
        implement HunterVars
        
        // Instance methods
        private method initInstance takes nothing returns nothing
            call this.initHunterVars()
        endmethod
        
        private method deleteInstance takes nothing returns nothing
            call this.deleteHunterVars()
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
                        set str = str + "[" + ARGB(COLOR_ARGB_ORANGE).str(GetHeroProperName(p.hero)) + ", "+CST_STR_Level+ARGB(COLOR_ARGB_GREEN).str(I2S(GetHeroLevel(p.hero)))+"]"
                    endif
                    set str = str + "\n"
                    set p = p.next
                endloop
            endif
            return str
        endmethod
        public static method removeLeaving takes player p returns nothing
            local thistype h = thistype[GetPlayerId(p)]

            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][h.rowIndex].text = "Left"
                set Farmer.statsBoard[CST_BDCOL_ST][h.erowIndex].text = "Left"
            else
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
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
                    call h.createRandomHero(null)
                endif
                set h= h.next
            endloop
            return false
        endmethod
        
        static method initStatsBoard takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            local Farmer f = Farmer[Farmer.first]
            local integer i = 2
            call thistype.createStatsBoard()
            call thistype.statsBoard.clear()
            set statsBoard.title = CST_STR_HunterScoreBoard
            set statsBoard.all.width = 0.02
            call statsBoard.all.setDisplay(true, false)
            set statsBoard[0][0].text = CST_STR_Hunter
            set statsBoard[0][0].color = COLOR_ARGB_RED
            set statsBoard[CST_BDCOL_PN][1].text = CST_STR_Player
            set statsBoard[CST_BDCOL_KL][1].text = CST_STR_Kills
            set statsBoard[CST_BDCOL_ST][1].text = CST_STR_Status
            debug set statsBoard[CST_BDCOL_DF][1].text = "Row"
            loop
                exitwhen h.end
                set h.rowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
                set statsBoard[CST_BDCOL_KL][i].text = I2S(h.killCount)
                set statsBoard[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set h= h.next
                
            endloop
            
            // Enemy Stats
            set statsBoard[0][i].text   = CST_STR_EnemyInfo
            set statsBoard[0][i].width  = 0.04
            set i = i + 1
            set statsBoard[CST_BDCOL_PN][i].text = CST_STR_Player
            set statsBoard[CST_BDCOL_DE][i].text = CST_STR_Deaths
            set statsBoard[CST_BDCOL_ST][i].text = CST_STR_Status
            set i = i + 1
            loop
                exitwhen f.end
                set f.erowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
                set statsBoard[CST_BDCOL_DE][i].text = I2S(f.deathCount)
                set statsBoard[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set f= f.next
            endloop
            set statsBoard.col[CST_BDCOL_PN].width = 0.04
            set statsBoard.col[CST_BDCOL_ST].width = 0.03
            return false
        endmethod
        
        // On game start
        private static method init takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            local integer i = 0
            // Init statistics board
            call thistype.initStatsBoard()
            
            loop
                exitwhen h.end
                // Init instance vars
                call h.initInstance()
                call CreateHunterBeginUnits(h.get,i)
                
                // Display stats board
                debug call BJDebugMsg("Display board to hunter:" + GetPlayerName(h.get))
                set statsBoard.visible[h.get] = true
                set i = i + 1
                set h = h.next
            endloop
            
            return false
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerManager.onGameStart.register(Filter(function thistype.init))
            
            call TimerManager.pt60s.register(Filter(function thistype.goldBonusForKilling))
            call TimerManager.otSelectHero.register(Filter(function thistype.onSelectHeroExpire))
            // Play time is over, hunters win
            call TimerManager.otPlayTimeOver.register(Filter(function thistype.win))
        endmethod
        
    endstruct
    
    // *** Farmer
    struct Farmer extends array
        // Staitic [Module]
        implement Force
        implement StatsBoard
        // Instance [Vars]
        implement FarmerVars
        
        private static integer exp = 0
        private static integer expTick
        
        private method initInstance takes nothing returns nothing
            call this.initFarmerVars()
        endmethod
        
        private method deleteInstance takes nothing returns nothing
            call this.deleteFarmerVars()
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

            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][f.rowIndex].text = CST_STR_StatusHasLeft
                set Hunter.statsBoard[CST_BDCOL_ST][f.erowIndex].text = CST_STR_StatusHasLeft
            else
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
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
            local integer iGold = 0
            
            debug call BJDebugMsg("Give free exp to farmers")
            
            set thistype.expTick = thistype.expTick + 1
            
            if (thistype.expTick - R2I(thistype.expTick/CST_INT_ExpTickStep)*CST_INT_ExpTickStep) != 0 then
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
        
        static method initStatsBoard takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            local Hunter h = Hunter[Hunter.first]
            local integer i = 2
            call thistype.createStatsBoard()
            call thistype.statsBoard.clear()
            set statsBoard.title = CST_STR_FarmerScoreBoard
            set statsBoard.all.width = 0.02
            call statsBoard.all.setDisplay(true, false)
            set statsBoard[0][0].text = CST_STR_Farmer
            set statsBoard[0][0].color = COLOR_ARGB_RED
            set statsBoard[CST_BDCOL_PN][1].text = CST_STR_Player
            set statsBoard[CST_BDCOL_DE][1].text = CST_STR_Deaths
            set statsBoard[CST_BDCOL_ST][1].text = CST_STR_Status
            debug set statsBoard[CST_BDCOL_DF][1].text = "Row"

            loop
                exitwhen f.end
                set f.rowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
                set statsBoard[CST_BDCOL_DE][i].text = I2S(f.deathCount)
                set statsBoard[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set f= f.next
            endloop
            
            // Enemy Stats
            set statsBoard[0][i].text   = CST_STR_EnemyInfo
            set statsBoard[0][i].width  = 0.04
            set i = i + 1
            set statsBoard[CST_BDCOL_PN][i].text = CST_STR_Player
            set statsBoard[CST_BDCOL_KL][i].text = CST_STR_Kills
            set statsBoard[CST_BDCOL_ST][i].text = CST_STR_Status
            set i = i + 1
            loop
                exitwhen h.end
                set h.erowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
                set statsBoard[CST_BDCOL_KL][i].text = I2S(h.killCount)
                set statsBoard[CST_BDCOL_ST][i].text = CST_STR_StatusPlaying
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set h= h.next
            endloop
            set statsBoard.col[CST_BDCOL_PN].width = 0.04
            set statsBoard.col[CST_BDCOL_ST].width = 0.03
            return false
        endmethod
        
        // On game start
        private static method init takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            local integer i = 0
            // Init statistics board
            call thistype.initStatsBoard()
            loop
                exitwhen f.end
                // Init instance vars
                call f.initInstance()
                
                // Create hero at random location
                call f.reviveHero()
                
                // Display stats board
                debug call BJDebugMsg("Display board to farmer:" + GetPlayerName(f.get))
                set statsBoard.visible[f.get] = true
                
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
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            // Init and display multiboard at game start
            call TimerManager.onGameStart.register(Filter(function thistype.init))
            
            call TimerManager.pt15s.register(Filter(function thistype.salarySettlement))
            call TimerManager.pt60s.register(Filter(function thistype.incomeSettlement))
            call TimerManager.pt60s.register(Filter(function thistype.aquireFreeExp))
            
            // Play time is over, farmers lose
            call TimerManager.otPlayTimeOver.register(Filter(function thistype.lose))
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
        call BJDebugMsg(Farmer.info(false))
        call BJDebugMsg(Hunter.info(false))
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
    endfunction
endlibrary
