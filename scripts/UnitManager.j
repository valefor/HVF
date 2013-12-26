library UnitManager initializer init/* v0.0.1 Xandria
********************************************************************************
*     HVF Unit management : For use of managing HuntersVsFarmers units
*
*   */ uses /*
*   
*       */ Bonus /*
*       */ Core           /*  core functions must be loaded first
********************************************************************************
CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
GetOwningPlayer
*******************************************************************************/

    
    /***************************************************************************
    * Prerequisite Functions
    ***************************************************************************/
    
    /***************************************************************************
    * Modules
    ***************************************************************************/
    
    /***************************************************************************
    * Structs
    ***************************************************************************/
    
    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/
    public function IsUnitHunterHero takes unit u returns boolean
        // Hunter Heros' raw codes lays between 'U002' - 'U00D',If we find the 
        // raw code of a unit is in this range, we can consider this unit as a Hunter Hero
        return (GetUnitTypeId(u) < CST_UTI_HunterHeroLastcode) and (GetUnitTypeId(u) > CST_UTI_HunterHeroFirstcode)
    endfunction
    
    public function IsUnitFarmerHero takes unit u returns boolean
        return GetUnitTypeId(u) == CST_UTI_FarmerHero
    endfunction
    
    // Generate a randome hunter hero for player
    function GenRandomHunterHeroForPlayer takes player p, location loc returns unit
        local integer iRandom = GetRandomInt(1, CST_INT_MaxHunterHeroType)
        // Notice, 'location' would leak
        local location rctLoc = GetRectCenter(CST_RCT_DefaultBirthPlace)
        local integer iUnitTypeId
        
        if loc !=null then
            set rctLoc = loc
        endif
        /*
        if iRandom == 1 then
            set iUnitTypeId = 'U003'
        elseif iRandom == 2 then
            set iUnitTypeId = 'U004'
        elseif iRandom == 3 then
            set iUnitTypeId = 'U005'
        elseif iRandom == 4 then
            set iUnitTypeId = 'U006'
        elseif iRandom == 5 then
            set iUnitTypeId = 'U007'
        elseif iRandom == 6 then
            set iUnitTypeId = 'U008'
        elseif iRandom == 7 then
            set iUnitTypeId = 'U009'
        elseif iRandom == 8 then
            set iUnitTypeId = 'U00A'
        elseif iRandom == 9 then
            set iUnitTypeId = 'U00B'
        endif
        */
        return CreateUnitAtLoc(p, CST_UTI_HunterHeroFirstcode+iRandom, rctLoc, 0)
    endfunction
    
    // Give random hunter hero extra bonus such as life(+1000) str(+3) ... 
    function BonusRandomHunterHero takes unit hero returns nothing
        // extra bonus
        set Bonus_Life[hero]=CST_INT_RandomBonusLife
        set Bonus_Armor[hero]=CST_INT_RandomBonusArmor
        set Bonus_Agi[hero]=CST_INT_RandomBonusAgi
        set Bonus_Int[hero]=CST_INT_RandomBonusInt
    
        // give hunter hero 3 skill points
        // call UnitModifySkillPoints(unit, 3)
    endfunction
    
    /***************************************************************************
    * Library Initiation
    ***************************************************************************/
    private function init takes nothing returns nothing
    endfunction
endlibrary
