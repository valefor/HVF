//==============================================================================
//                Bonus -- State modification system -- v1.3
//==============================================================================
//
//  AUTHOR:
//       * Cohadar
//
//  PURPOUSE:
//       * Easy changing of units' max life, max mana, armor, damage, str, agi, int, 
//         move speed, attack speed, evasion, critical...
//         (or anything else you put in)
//
//  EXAMPLES:
//       * set Bonus_Life[whichUnit] = 4    // will add 400 life (DELTA = 100)
//       * set Bonus_Armor[whichUnit] = 10  // will add 10 armor (DELTA = 1)
//       * set Bonus_Damage[whichUnit] = 5  // will add 25 damage (DELTA = 5)
//       * set Bonus_Evasion[whichUnit] = 4 // will add 20% evasion (DELTA = 5%)
//
//  PLUGINS:
//       * Abilities needed by Bonus system are created with plugins
//         If you do not need some bonus type simply do not use that type plugin
//
//  PROS: 
//       * It removes the need for using abilties with 100 levels
//         (significantly reduces map loading time)
//       * It can be easily extended for other bonus types
//
//  CONS:
//       * You have to be smart enough to calculate wanted modification from DELTA
//       * System does not support negative values
//
//  DETAILS:
//       * DELTA is the smallest value of modification (bonus resolution)
//         DELTA is the bonus value in first bonus ability
//       * COUNT is the number of custom abilities used per bonus
//         Valid bonus ranges for binary bonuses are 0..(2^COUNT)-1
//         Valid bonus ranges for linear bonuses are 0..COUNT
//         Bonus is multiplied by DELTA to get the resulting modification
//         For example bonus 7 will change units' life by 700 
//         because life delta is set to 100
//
//  HOW TO IMPORT:
//       * Just create a trigger named Bonus
//         convert it to text and replace the whole trigger text with this one
//       * Create needed abilities with Bonus Plugins
//
//==============================================================================
library Bonus initializer Init

//===========================================================================
globals
    private constant integer MAX_CODES = 20 // max number of abilities per bonus
endglobals    

//===========================================================================
interface IBonus
    method operator DELTA takes nothing returns integer
    method operator MAXBONUS takes nothing returns integer
    method operator[] takes unit whichUnit returns integer
    method operator[]= takes unit whichUnit, integer bonus returns nothing
endinterface

//===========================================================================
//  This one is for stackable item abilities (life, mana, armor, str...)
//===========================================================================
private struct BinaryBonus extends IBonus
    private integer firstCode
    private integer count
    private integer delta
    private integer maxbonus
    private static integer array POWZ // powers of 2 for binary algorithm

    //-----------------------------------------------------------------------
    static method create takes integer firstCode, integer count, integer delta returns BinaryBonus
        local BinaryBonus bb = BinaryBonus.allocate()
        set bb.firstCode = firstCode
        set bb.count = count
        set bb.delta = delta
        set bb.maxbonus = .POWZ[count]-1
        return bb
    endmethod
    
    //-----------------------------------------------------------------------
    method operator DELTA takes nothing returns integer
        return .delta
    endmethod
    
    //-----------------------------------------------------------------------
    method operator MAXBONUS takes nothing returns integer
        return .maxbonus
    endmethod
    
    //-----------------------------------------------------------------------
    method operator[] takes unit whichUnit returns integer
        local integer bonus = 0
        local integer i = .count-1
        loop
            exitwhen i<0
            if GetUnitAbilityLevel(whichUnit, .firstCode+i)>0 then
                set bonus = bonus + .POWZ[i]
            endif
            set i = i - 1
        endloop    
        return bonus    
    endmethod
    
    //-----------------------------------------------------------------------
    method operator[]= takes unit whichUnit, integer bonus returns nothing
        local integer i = .count-1

        if bonus < 0 then
            call BJDebugMsg("|c00ff0000"+SCOPE_PREFIX+"$NAME$["+GetUnitName(whichUnit)+"] = "+I2S(bonus)+" // bonus underflow")
        endif        
        if bonus > .POWZ[.count]-1 then
            call BJDebugMsg("|c00ff0000"+SCOPE_PREFIX+"$NAME$["+GetUnitName(whichUnit)+"] = "+I2S(bonus)+" // bonus overflow")
        endif        
        
        loop
            exitwhen i<0
            if bonus >= .POWZ[i] then
                set bonus = bonus - .POWZ[i]
                if GetUnitAbilityLevel(whichUnit, .firstCode+i)==0 then
                    call UnitAddAbility(whichUnit, .firstCode+i)
                    call UnitMakeAbilityPermanent(whichUnit, true, .firstCode+i)
                endif
            else
                if GetUnitAbilityLevel(whichUnit, .firstCode+i)>0 then
                    call UnitMakeAbilityPermanent(whichUnit, false, .firstCode+i)
                    call UnitRemoveAbility(whichUnit, .firstCode+i)
                endif
            endif
            set i = i - 1
        endloop    
    endmethod
    
    //-----------------------------------------------------------------------
    private static method onInit takes nothing returns nothing
        local integer i = 0
        local integer pow = 1
        loop
            exitwhen i > MAX_CODES
            set .POWZ[i] = pow
            set i = i + 1
            set pow = pow * 2
        endloop
    endmethod
endstruct

//===========================================================================
//  This one is for non-stackable abilities (move speed, evasion, critical, ...)
//===========================================================================
private struct LinearBonus extends IBonus
    private integer firstCode
    private integer count
    private integer delta
    private integer maxbonus

    //-----------------------------------------------------------------------
    private static method hideSpellBook takes integer abilId returns nothing
        local integer p = 0
        loop
            call SetPlayerAbilityAvailable(Player(p), abilId, false)
            set p = p + 1
            exitwhen p == bj_MAX_PLAYER_SLOTS
        endloop         
    endmethod    
    
    //-----------------------------------------------------------------------
    static method create takes integer firstCode, integer count, integer delta, boolean spellBook returns LinearBonus
        local LinearBonus lb = LinearBonus.allocate()
        local integer i
        set lb.firstCode = firstCode
        set lb.count = count
        set lb.delta = delta
        set lb.maxbonus = count
        if spellBook then
            set i = 0
            loop
                exitwhen i>=count
                call .hideSpellBook(firstCode+i)
                set i = i + 1
            endloop    
        endif
        return lb
    endmethod
    
    //-----------------------------------------------------------------------
    method operator DELTA takes nothing returns integer
        return .delta
    endmethod
    
    //-----------------------------------------------------------------------
    method operator MAXBONUS takes nothing returns integer
        return .maxbonus
    endmethod
    
    //-----------------------------------------------------------------------
    method operator[] takes unit whichUnit returns integer
        local integer bonus = 0
        local integer i = .count-1
        loop
            exitwhen i<0
            if GetUnitAbilityLevel(whichUnit, .firstCode+i)>0 then
                return i+1
            endif
            set i = i - 1
        endloop    
        return 0   
    endmethod
    
    //-----------------------------------------------------------------------
    method operator[]= takes unit whichUnit, integer bonus returns nothing
        local integer i = .count-1

        if bonus < 0 then
            call BJDebugMsg("|c00ff0000"+SCOPE_PREFIX+"$NAME$["+GetUnitName(whichUnit)+"] = "+I2S(bonus)+" // bonus underflow")
            set bonus = 0
        endif        
        if bonus > .count then
            call BJDebugMsg("|c00ff0000"+SCOPE_PREFIX+"$NAME$["+GetUnitName(whichUnit)+"] = "+I2S(bonus)+" // bonus overflow")
            set bonus = .count 
        endif        
        
        loop
            exitwhen i<0
            if GetUnitAbilityLevel(whichUnit, .firstCode+i)>0 then
                call UnitMakeAbilityPermanent(whichUnit, false, .firstCode+i)
                call UnitRemoveAbility(whichUnit, .firstCode+i)
                exitwhen true
            endif
            set i = i - 1
        endloop
        
        if bonus > 0 then
            call UnitAddAbility(whichUnit, .firstCode+bonus-1)
            call UnitMakeAbilityPermanent(whichUnit, true, .firstCode+bonus-1)
        endif   
    endmethod
endstruct

//===========================================================================
//  Bonus struct global variables
//===========================================================================
globals
    public IBonus Life
    public IBonus Mana
    public IBonus Armor
    public IBonus Damage
    public IBonus Str
    public IBonus Agi
    public IBonus Int
    public IBonus AttackSpeed
    public IBonus MoveSpeed    
    public IBonus Evasion
    public IBonus Critical
endglobals

//===========================================================================
//  Init bonus structs
//===========================================================================
private function Init takes nothing returns nothing
    set Life   = BinaryBonus.create('A8L0', 8, 100)
    set Mana   = BinaryBonus.create('A8M0', 8, 100)
    
    set Armor  = BinaryBonus.create('A8D0', 8, 1)
    set Damage = BinaryBonus.create('A8T0', 8, 5)
    
    set Str    = BinaryBonus.create('A8S0', 8, 1)
    set Agi    = BinaryBonus.create('A8A0', 8, 1)
    set Int    = BinaryBonus.create('A8I0', 8, 1)
    
    set AttackSpeed = BinaryBonus.create('A8H0', 7, 5)
    set MoveSpeed   = LinearBonus.create('A8P1', 10, 5, false)    
    
    set Evasion  = LinearBonus.create('A8E1', 8, 5, true)
    set Critical = LinearBonus.create('A8C1', 8, 5, true)
endfunction

endlibrary