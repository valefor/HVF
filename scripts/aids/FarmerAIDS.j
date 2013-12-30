library FarmerAIDS/* v0.0.1 Xandria
*/  uses    AIDS    /*  
*/          HVF     /*
********************************************************************************
* AIDS struct for farmer units
*******************************************************************************/

// Hero
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
        
    endmethod
    
    private method AIDS_onCreate takes nothing returns nothing
        set this.trig=CreateTrigger()
        call TriggerAddCondition(this.trig,Condition(function thistype.onDeath))
        call TriggerRegisterUnitEvent(this.trig, this.unit, EVENT_UNIT_DEATH )
    endmethod    
endstruct

struct FarmerUnit extends array
    //! runtextmacro AIDS()
    private static method AIDS_filter takes unit u returns boolean
        return GetUnitTypeId(u)==CST_UTI_FarmerHero
    endmethod
endstruct

struct FarmerBuilding extends array
    //! runtextmacro AIDS()
    private static method AIDS_filter takes unit u returns boolean
        return GetUnitTypeId(u)==CST_UTI_FarmerHero
    endmethod
endstruct

endlibrary