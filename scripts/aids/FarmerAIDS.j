library FarmerAIDS/* v0.0.1 Xandria
*/  uses    AIDS    /*  
*/          HVF     /*
********************************************************************************
* AIDS struct for farmer units
*******************************************************************************/

// When units Entering the map
struct FarmerHero extends array
    //! runtextmacro AIDS()
    private trigger trig
    
    private static method AIDS_filter takes unit u returns boolean
        return GetUnitTypeId(u)==CST_UTI_FarmerHero
    endmethod
    
    private static method onDeath takes nothing returns boolean
        local Farmer f = Farmer[GetPlayerId(GetOwningPlayer(GetDyingUnit()))]
        local Hunter h = Hunter[GetPlayerId(GetOwningPlayer(GetKillingUnit()))]
        
        if Hunter.contain(GetOwningPlayer(GetKillingUnit())) then
            set f.deaths=f.deaths + 1
            set h.kills=h.kills + 1
            // Give Hunter reward for killing
            // Revive Farmer Hero at random location
        else // Farmer hero was killed by ally or neutral 
        endif
        return false
    endmethod
    
    private method AIDS_onCreate takes nothing returns nothing
        set this.trig=CreateTrigger()
        call TriggerAddCondition(this.trig,Condition(function thistype.onDeath))
        //call TriggerRegisterUnitEvent(this.trig, this.unit, EVENT_UNIT_DEATH )
    endmethod

    // Hero unit won't be removed from map in game    
endstruct

struct FarmerFarmingUnit extends array
    //! runtextmacro AIDS()
    private static method AIDS_filter takes unit u returns boolean
        return GetUnitTypeId(u)==CST_UTI_Sheep or GetUnitTypeId(u)==CST_UTI_Pig or GetUnitTypeId(u)==CST_UTI_Snake or GetUnitTypeId(u)==CST_UTI_Chicken
    endmethod
endstruct

struct FarmerFarmingBuilding extends array
    //! runtextmacro AIDS()
    private trigger trig
    private static method AIDS_filter takes unit u returns boolean
        //return IsUnitType(u, UNIT_TYPE_STRUCTURE)
        return GetUnitTypeId(u)==CST_BTI_SheepFold or GetUnitTypeId(u)==CST_BTI_Pigen or GetUnitTypeId(u)==CST_BTI_SnakeHole or GetUnitTypeId(u)==CST_BTI_Cage
    endmethod
    
    private static method onDeath takes nothing returns boolean
        debug call BJDebugMsg("A building is destroyed ")
        return false
    endmethod
    
    private method AIDS_onCreate takes nothing returns nothing
        debug call BJDebugMsg("Build a building")
        set this.trig=CreateTrigger()
        call TriggerAddCondition(this.trig,Condition(function thistype.onDeath))
        call TriggerRegisterUnitEvent(this.trig, this.unit, EVENT_UNIT_DEATH )
    endmethod
    
    private method AIDS_onDestroy takes nothing returns nothing
        call BJDebugMsg("|cFFFF0000AIDS Debug:|r A building is removed.")
    endmethod
endstruct

endlibrary