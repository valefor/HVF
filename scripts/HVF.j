library HVF initializer init/* v0.0.1 Xandria
*/  uses    Alloc           /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/          PlayerManager   /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/          PlayerAlliance  /*  List
*/          TimeManager     /*
*/          UnitManager     /*
*/          Board           /*
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
        static integer heroSelectedCount = 0
        // specific attributes
        integer killCount
        
        // Instance method
        public method operator kills takes nothing returns integer
            return this.killCount
        endmethod
        
        public method operator kills= takes integer val returns nothing
            set this.killCount = val
            // fresh board
            set thistype.statsBoard[CST_BDCOL_KL][rowIndex].text = I2S(this.killCount)
        endmethod
        
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
        
        method initHunterVars takes nothing returns nothing
            set this.killCount = 0
            set this.hero = null
        endmethod
        
        method deleteHunterVars takes nothing returns nothing
            call this.setHero(null)
        endmethod
        
    endmodule
    
    private module FarmerVars
        unit hero
        
        // Farming building group
        group sheepFolds
        group pigens
        group snakeHoles
        group cages
        // Farming building counter
        integer sheepFoldCount
        integer pigenCount
        integer snakeHoleCount
        integer cageCount
        // Farming animal counter
        integer sheepCount
        integer pigCount
        integer snakeCount
        integer chickenCount
        
        integer deathCount
        integer role
        // Instance method
        public method operator deaths takes nothing returns integer
            return .deathCount
        endmethod
        
        public method operator deaths= takes integer val returns nothing
            set .deathCount = val
            // fresh board
            set thistype.statsBoard[CST_BDCOL_DE][rowIndex].text = I2S(.deathCount)
        endmethod
        
        public method operator animalCount takes nothing returns integer
            return (.sheepCount + .pigCount + .snakeCount + .chickenCount)
        endmethod
        
        // Salary for every x minutes/seconds depends on animalType*animalCount
        public method operator salary takes nothing returns integer
            return (CST_INT_SalaryBaseSheep*sheepCount) + (CST_INT_SalaryBasePig*pigCount) + (CST_INT_SalaryBaseSnake*snakeCount) + (CST_INT_SalaryBaseChicken*chickenCount)
        endmethod
        
        // Income for killing overflow animals
        public method operator overflowIncome takes nothing returns integer
            return (CST_INT_PriceOfSheep*sheepFoldCount) + (CST_INT_PriceOfPig*pigenCount) + (CST_INT_PriceOfSnake*snakeHoleCount) + (CST_INT_PriceOfChicken*cageCount)
        endmethod
        
        // Killing all animals immediately, return gold for killed animals
        public method killAllAnimalsToGetGold takes nothing returns integer
        endmethod
        
        public method addFarmingBuilding takes unit building returns nothing
            if GetUnitTypeId(building) == CST_BTI_SheepFold then
                call GroupAddUnit(sheepFolds,building)
                set sheepFoldCount = sheepFoldCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_Pigen then
                call GroupAddUnit(pigens,building)
                set pigenCount = pigenCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_SnakeHole then
                call GroupAddUnit(snakeHoles,building)
                set snakeHoleCount = snakeHoleCount + 1
            elseif GetUnitTypeId(building) == CST_BTI_Cage then
                call GroupAddUnit(cages,building)
                set cageCount = cageCount + 1
            endif
        endmethod
        
        public method removeFarmingBuilding takes unit building returns nothing
            if GetUnitTypeId(building) == CST_BTI_SheepFold then
                call GroupRemoveUnit(sheepFolds,building)
                set sheepFoldCount = sheepFoldCount - 1
            elseif GetUnitTypeId(building) == CST_BTI_Pigen then
                call GroupRemoveUnit(pigens,building)
                set pigenCount = pigenCount - 1
            elseif GetUnitTypeId(building) == CST_BTI_SnakeHole then
                call GroupRemoveUnit(snakeHoles,building)
                set snakeHoleCount = snakeHoleCount - 1
            elseif GetUnitTypeId(building) == CST_BTI_Cage then
                call GroupRemoveUnit(cages,building)
                set cageCount = cageCount - 1
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
        
        method enumSpawnSheep takes nothing returns nothing
            call CreateUnitAtLoc(GetOwningPlayer(GetEnumUnit()), CST_UTI_Sheep, GetUnitLoc(GetEnumUnit()), bj_UNIT_FACING)
            set sheepCount = sheepCount + 1
        endmethod
        method enumSpawnPig takes nothing returns nothing
            call CreateUnitAtLoc(GetOwningPlayer(GetEnumUnit()), CST_UTI_Pig, GetUnitLoc(GetEnumUnit()), bj_UNIT_FACING)
            set pigCount = pigCount + 1
        endmethod
        method enumSpawnSnake takes nothing returns nothing
            call CreateUnitAtLoc(GetOwningPlayer(GetEnumUnit()), CST_UTI_Snake, GetUnitLoc(GetEnumUnit()), bj_UNIT_FACING)
            set snakeCount = snakeCount + 1
        endmethod
        method enumSpawnChicken takes nothing returns nothing
            call CreateUnitAtLoc(GetOwningPlayer(GetEnumUnit()), CST_UTI_Chicken, GetUnitLoc(GetEnumUnit()), bj_UNIT_FACING)
            set chickenCount = chickenCount + 1
        endmethod
        
        method spawnAnimal takes nothing returns nothing
            call ForGroup(sheepFolds, function this.enumSpawnSheep)
            call ForGroup(pigens, function this.enumSpawnPig)
            call ForGroup(snakeHoles, function this.enumSpawnSnake)
            call ForGroup(cages, function this.enumSpawnChicken)
        endmethod
        
        
        
        method initFarmerVars takes nothing returns nothing
            set sheepFolds  = CreateGroup()
            set pigens      = CreateGroup()
            set snakeHoles  = CreateGroup()
            set cages       = CreateGroup()
            
            set sheepFoldCount  = 0
            set pigenCount      = 0
            set snakeHoleCount  = 0
            set cageCount       = 0
            
            set sheepCount      = 0
            set pigCount        = 0
            set snakeCount      = 0
            set chickenCount    = 0
            
            set deathCount      = 0
            set role            = CST_INT_FarmerRoleInvalid
        endmethod
        
        method deleteFarmerVars takes nothing returns nothing
        endmethod
        
        // Randomize location of farmer hero
        public method randomizeHeroLoc takes unit hero   returns nothing
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
        private method instanceInit takes nothing returns nothing
            call this.initHunterVars()
        endmethod
        
        private method instanceDelete takes nothing returns nothing
            call this.deleteHunterVars()
        endmethod
        
        // Static methods
        public static method removeLeaving takes player p returns nothing
            local thistype h = thistype[GetPlayerId(p)]

            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][h.rowIndex].text = "Left"
                set Farmer.statsBoard[CST_BDCOL_ST][h.erowIndex].text = "Left"
            else
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
            
            call thistype.remove(p)
            call h.instanceDelete()
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
        
        static method initStatsBoard takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            local Farmer f = Farmer[Farmer.first]
            local integer i = 2
            call thistype.createStatsBoard()
            call thistype.statsBoard.clear()
            set statsBoard.title = "Hunter Score Board"
            set statsBoard.all.width = 0.02
            call statsBoard.all.setDisplay(true, false)
            set statsBoard[0][0].text = "The Hunter"
            set statsBoard[0][0].color = 0xFFFF00
            set statsBoard[CST_BDCOL_PN][1].text = "Player"
            set statsBoard[CST_BDCOL_KL][1].text = "Kills"
            set statsBoard[CST_BDCOL_ST][1].text = "Status"
            debug set statsBoard[CST_BDCOL_DF][1].text = "Row"
            loop
                exitwhen h.end
                set h.rowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
                set statsBoard[CST_BDCOL_KL][i].text = I2S(h.killCount)
                set statsBoard[CST_BDCOL_ST][i].text = "Playing"
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set h= h.next
                
            endloop
            
            // Enemy Stats
            set statsBoard[0][i].text   = "The Farmer"
            set statsBoard[0][i].width  = 0.04
            set i = i + 1
            set statsBoard[CST_BDCOL_PN][i].text = "Player"
            set statsBoard[CST_BDCOL_DE][i].text = "Deaths"
            set statsBoard[CST_BDCOL_ST][i].text = "Status"
            set i = i + 1
            loop
                exitwhen f.end
                set f.erowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
                set statsBoard[CST_BDCOL_DE][i].text = I2S(f.deathCount)
                set statsBoard[CST_BDCOL_ST][i].text = "Playing"
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set f= f.next
            endloop
            set statsBoard.col[CST_BDCOL_PN].width = 0.04
            set statsBoard.col[CST_BDCOL_ST].width = 0.03
            return false
        endmethod
        
        // On game start
        private static method onGameStart takes nothing returns boolean
            local thistype h = thistype[thistype.first]
            
            loop
                exitwhen h.end
                // Init instance vars
                call h.instanceInit()
                
                // Display stats board
                debug call BJDebugMsg("Display board to hunter:" + GetPlayerName(h.get))
                set statsBoard.visible[h.get] = true
                
                set h= h.next
            endloop
            
            // Init statistics board
            call thistype.initStatsBoard()
            
            return false
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerManager.pt60s.register(Filter(function thistype.goldBonusForKilling))
            call TimerManager.otGameStart.register(Filter(function thistype.onGameStart))
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
        
        private method instanceInit takes nothing returns nothing
            call this.initFarmerVars()
        endmethod
        
        private method instanceDelete takes nothing returns nothing
            call this.deleteFarmerVars()
        endmethod

        // Static methods
        public static method removeLeaving takes player p returns nothing
            local thistype f = thistype[GetPlayerId(p)]

            if statsBoard != -1 then
                set thistype.statsBoard[CST_BDCOL_ST][f.rowIndex].text = "Left"
                set Hunter.statsBoard[CST_BDCOL_ST][f.erowIndex].text = "Left"
            else
                debug call BJDebugMsg("Stats Board is uninitialized")
            endif
            call thistype.remove(p)
        endmethod

        // Get total animals' count
        public static method getTotalAnimalCount takes nothing returns integer
            local thistype h = thistype[thistype.first]
            local integer totalAnimalCount = 0

            loop
                exitwhen h.end
                set totalAnimalCount = totalAnimalCount + f.animalCount
                set h= h.next
            endloop
            
            return totalAnimalCount
        endmethod
        
        private static method goldCompensateForDeath takes nothing returns nothing
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
        
        private static method giveFarmingGold takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            
            debug call BJDebugMsg("Salary!")
            loop
                exitwhen f.end
                debug call BJDebugMsg("Spawn Animal for:" + GetPlayerName(f.get))
                call f.spawnAnimal()
                //call AdjustPlayerStateSimpleBJ(f.get, PLAYER_STATE_GOLD_GATHERED, 10)
                set f= f.next
            endloop
        endmethod
        
        private static method spawnAnimal takes nothing returns nothing
            local thistype f = thistype[thistype.first]
            
            debug call BJDebugMsg("Spawn Animal")
            // If total aminal count doesn't exceed CST_INT_MaxAnimals, spawn
            if thistype.getTotalAnimalCount < CST_INT_MaxAnimals then
                loop
                    exitwhen f.end
                    debug call BJDebugMsg("Spawn Animal for:" + GetPlayerName(f.get))
                    call f.spawnAnimal()
                    set f= f.next
                endloop
                f = thistype[thistype.first]
            // Else don't spawn, give overflow gold to players
            else
                loop
                    exitwhen f.end
                    debug call BJDebugMsg("Spawn Animal for:" + GetPlayerName(f.get))
                    call AdjustPlayerStateBJ(iGold, f.get, PLAYER_STATE_RESOURCE_GOLD)
                    set f= f.next
                endloop
            endif
            
        endmethod
        
        static method initStatsBoard takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            local Hunter h = Hunter[Hunter.first]
            local integer i = 2
            call thistype.createStatsBoard()
            call thistype.statsBoard.clear()
            set statsBoard.title = "Farmer Score Board"
            set statsBoard.all.width = 0.02
            call statsBoard.all.setDisplay(true, false)
            set statsBoard[0][0].text = "The Farmer"
            set statsBoard[0][0].color = 0xFFFF00
            set statsBoard[CST_BDCOL_PN][1].text = "Player"
            set statsBoard[CST_BDCOL_DE][1].text = "Deaths"
            set statsBoard[CST_BDCOL_ST][1].text = "Status"
            debug set statsBoard[CST_BDCOL_DF][1].text = "Row"

            loop
                exitwhen f.end
                set f.rowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(f.get)
                set statsBoard[CST_BDCOL_DE][i].text = I2S(f.deathCount)
                set statsBoard[CST_BDCOL_ST][i].text = "Playing"
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set f= f.next
            endloop
            
            // Enemy Stats
            set statsBoard[0][i].text   = "The Hunter"
            set statsBoard[0][i].width  = 0.04
            set i = i + 1
            set statsBoard[CST_BDCOL_PN][i].text = "Player"
            set statsBoard[CST_BDCOL_KL][i].text = "Kills"
            set statsBoard[CST_BDCOL_ST][i].text = "Status"
            set i = i + 1
            loop
                exitwhen h.end
                set h.erowIndex = i
                set statsBoard[CST_BDCOL_PN][i].text = GetPlayerName(h.get)
                set statsBoard[CST_BDCOL_KL][i].text = I2S(h.killCount)
                set statsBoard[CST_BDCOL_ST][i].text = "Playing"
                debug set statsBoard[CST_BDCOL_DF][i].text = I2S(i)
                set i = i + 1
                set h= h.next
            endloop
            set statsBoard.col[CST_BDCOL_PN].width = 0.04
            set statsBoard.col[CST_BDCOL_ST].width = 0.03
            return false
        endmethod
        
        // On game start
        private static method onGameStart takes nothing returns boolean
            local thistype f = thistype[thistype.first]
            // Init statistics board
            call thistype.initStatsBoard()
            loop
                exitwhen f.end
                // Init instance vars
                call f.instanceInit()
                
                // Display stats board
                debug call BJDebugMsg("Display board to farmer:" + GetPlayerName(f.get))
                set statsBoard.visible[f.get] = true

                set f = f.next
            endloop
            return false
        endmethod
        
        private static method onInit takes nothing returns nothing
            call TimerManager.pt60s.register(Filter(function thistype.goldCompensateForDeath))
            // Init and display multiboard at game start
            call TimerManager.otGameStart.register(Filter(function thistype.onGameStart))
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
    * Functions that would be called on event fired
    ***************************************************************************/
    // Bind selected Hunter Hero to Player
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
        // Grouping players to Hunter/Farmer force by default
        call LoadDefaultSetting()
    endfunction
endlibrary
