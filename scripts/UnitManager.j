library UnitManager initializer init/* v0.0.1 Xandria
********************************************************************************
* 	HVF Unit management : For use of managing HuntersVsFarmers units
*
*   */ uses /*
*   
*       */ Bonus /*
*       */ Core   		/*  core functions must be loaded first
*       */ ForceManager /*
********************************************************************************

CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
GetOwningPlayer
*******************************************************************************/
	/***************************************************************************
	* Used Object Id:
	*	Hunter Heros:
	*		'U008'	:	Assaulter	(冲锋者)
	*		'U009'	:	Darter		(飞奔者)
	*		'U004'	:	Peeper		(窥视者)
	*		'U003'	:	Miner		(埋雷者)
	*		'U00A'	:	Balancer	(平衡者)
	*		'U007'	:	Sneaker		(偷袭者)
	*		'U006'	:	Pelter		(投雷者)
	*		'U00B'	:	Butcher		(屠宰者)
	*		'U005'	:	Dogger		(训犬者)
	*		'U00C'	:	RandomHero	(随机猎人)
	*		'U00D'	:	LastRawCodeIdx
	*		'U001'	:	FirstRawCodeIdx
	*		
	*	Farmer Heros:
	*		'H00P'	:	FarmerHero
	*
	*	Buildings	-	Animal	[IsUnitType(unit, UNIT_TYPE_STRUCTURE)]
	*		'h002'	:	SheepFold
	*		'h001'	:	Pigen
	*		'h00U'	:	SnakeHole
	*		'h00V'	:	Cage
	***************************************************************************/

	/***************************************************************************
	* Globals
	***************************************************************************/
	globals
		private integer iMaxHunterHeroType	= 9
		private integer iFirstHunterHeroRC	= 'U001'	// First Hunter Hero Raw Code
		private integer iLastHunterHeroRC	= 'U00D'	// Last Hunter Hero Raw Code
		private rect	rctDefaultBirthPlace = Rect(- 6464.0, - 2464.0, - 5984.0, - 1952.0)
		//private location locHeroShop = Location(- 6240.0, - 2208.0)
	endglobals
	
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
		// Hunter Heros' raw codes lays between 'U001' - 'U00D',If we find the 
		// raw code of a unit is in this range, we can consider this unit as a Hunter Hero
		return (GetUnitTypeId(u) < iLastHunterHeroRC) and (GetUnitTypeId(u) > iFirstHunterHeroRC)
	endfunction
	
	public function IsUnitFarmerHero takes unit u returns boolean
		return GetUnitTypeId(u) == 'H00P'
	endfunction
	
	// Generate a randome hunter hero for player
	private function GenRandomHunterHeroForPlayer takes player p, location loc returns unit
		local integer iRandom = GetRandomInt(1, iMaxHunterHeroType)
		// Notice, 'location' would leak
		local location rctLoc = GetRectCenter(rctDefaultBirthPlace)
		local integer iUnitTypeId
		
		if loc !=null then
			set rctLoc = loc
		endif
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
		return CreateUnitAtLoc(p, iUnitTypeId, rctLoc, 0)
	endfunction
	
	// Give random hunter hero extra bonus such as life(+1000) str(+3) ... 
	private function BonusRandomHunterHero takes unit hero returns nothing
		// extra bonus
		set Bonus_Life[hero]=CST_INT_RANDBONUS_LIFE
		set Bonus_Armor[hero]=CST_INT_RANDBONUS_ARMOR
		set Bonus_Agi[hero]=CST_INT_RANDBONUS_AGI
		set Bonus_Int[hero]=CST_INT_RANDBONUS_INT
	
		// give hunter hero 3 skill points
		// call UnitModifySkillPoints(unit, 3)
	endfunction
	
	/***************************************************************************
	* Functions that would be called on event fired
	***************************************************************************/
    private function OnSelectHero takes nothing returns boolean    
    	debug call BJDebugMsg(GetPlayerName(GetOwningPlayer(GetSoldUnit()))+ ":Selecte a Hero") 
    	if Hunter.contain(GetOwningPlayer(GetSoldUnit())) then
    		call Hunter[GetPlayerId(GetOwningPlayer(GetSoldUnit()))].setHero(GetSoldUnit())
    	endif
    	
    	// All Hunter players have selected a hero
    	if Hunter.heroSelectedCount == Hunter.count then
    		debug call BJDebugMsg("All Hunter players have selected a hero")
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
    
	/***************************************************************************
	* Functions that would be called on timer expired
	***************************************************************************/
	function OnHeroSelectTimerExpired takes nothing returns nothing
	endfunction
	
	/***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
    	// Bind Selected Hunter Hero to Player
    	call BindSelectedHero()
    endfunction
endlibrary