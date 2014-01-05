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