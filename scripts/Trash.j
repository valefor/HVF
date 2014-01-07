        public method buthcerAllAnimal takes nothing returns nothing
            local group animals = CreateGroup()
            local unit toBeKilled //= FirstOfGroup()
            local integer gold = this.allAnimalIncome
            // Kill sheeps
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Sheep)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill pigs
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Pig)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill snakes
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Snake)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            set animals=null
            // Kill chickens
            set animals=GetUnitsOfPlayerAndTypeId(this.get, CST_UTI_Chicken)
            loop
                set toBeKilled = FirstOfGroup(animals)
                exitwhen toBeKilled == null
                call GroupRemoveUnit(animals, toBeKilled)
                call KillUnit(toBeKilled)
            endloop
            call DestroyGroup(animals)
            set animals=null
            
            call AdjustPlayerStateBJ(gold, this.get, PLAYER_STATE_RESOURCE_GOLD)
            
        endmethod
        
        /*
        static method enumSpawnSheep takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            local unit u
            local location rallyPoint = GetUnitRallyPoint(GetEnumUnit())
            
            set u = CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Sheep, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            call IssuePointOrderByIdLoc(u, ORDERID_smart, rallyPoint)
            call IssueTargetOrderById(u, ORDERID_smart, GetUnitRallyUnit(GetEnumUnit()))
            set f.sheepCount = f.sheepCount + 1
            
            call RemoveLocation(rallyPoint)
            set rallyPoint = null
            set u = null
        endmethod
        static method enumSpawnPig takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            local unit u
            local location rallyPoint = GetUnitRallyPoint(GetEnumUnit())
            
            set u = CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Pig, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            call IssuePointOrderByIdLoc(u, ORDERID_smart, rallyPoint)
            call IssueTargetOrderById(u, ORDERID_smart, GetUnitRallyUnit(GetEnumUnit()))
            set f.pigCount = f.pigCount + 1
            
            call RemoveLocation(rallyPoint)
            set rallyPoint = null
            set u = null
        endmethod
        static method enumSpawnSnake takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            call CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Snake, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            set f.snakeCount = f.snakeCount + 1
        endmethod
        static method enumSpawnChicken takes nothing returns nothing
            local thistype f = thistype[GetPlayerId(GetOwningPlayer(GetEnumUnit()))]
            call CreateUnit(GetOwningPlayer(GetEnumUnit()), CST_UTI_Chicken, GetUnitX(GetEnumUnit()), GetUnitY(GetEnumUnit()), bj_UNIT_FACING)
            set f.chickenCount = f.chickenCount + 1
        endmethod
        */