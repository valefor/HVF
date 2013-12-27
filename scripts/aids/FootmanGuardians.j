library FootmanGuardians

struct FootmanGuardians extends array
    //! runtextmacro AIDS()
    // Footmen
    private unit a
    private unit b
    private trigger t
    
    private static method OnDamage takes nothing returns boolean
        // Forwards damage as pure damage.
        local thistype d=thistype[GetTriggerUnit()]
        call UnitDamageTargetBJ( GetEventDamageSource(), d.a, GetEventDamage(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL )
        call UnitDamageTargetBJ( GetEventDamageSource(), d.b, GetEventDamage(), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_UNIVERSAL )
        return false
    endmethod
    
    private static method AIDS_filter takes unit u returns boolean
        return GetUnitTypeId(u)!='hfoo' and (not IsUnitType(u, UNIT_TYPE_STRUCTURE))// Don't make this struct for footmen.
    endmethod
    private method AIDS_onCreate takes nothing returns nothing
        call BJDebugMsg("Create Footman Guardian")
        set this.a=CreateUnit(Player(0),'hfoo',GetUnitX(this.unit),GetUnitY(this.unit),0)
        set this.b=CreateUnit(Player(0),'hfoo',GetUnitX(this.unit),GetUnitY(this.unit),0)
    
        
        call BJDebugMsg(I2S('hfoo'))
        set this.t=CreateTrigger()
        call TriggerAddCondition(this.t,Condition(function thistype.OnDamage))
        call TriggerRegisterUnitEvent(this.t,this.unit, EVENT_UNIT_DAMAGED )
    endmethod
    private method AIDS_onDestroy takes nothing returns nothing
        call BJDebugMsg("|cFFFF0000AIDS Debug:|r An unit died.")
        call DestroyTrigger(this.t)
        set this.t=null
        
        call RemoveUnit(this.a)
        call RemoveUnit(this.b)
        set this.a=null
        set this.b=null
    endmethod
endstruct

endlibrary