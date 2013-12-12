library ForceManager initializer init/* v0.0.1 Xandria
*/  uses 	 Alloc         /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/           PlayerManager /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/           PlayerAlliance /*
*/           UnitManager 	/*
********************************************************************************
* 	HVF Force management : For use of managing HuntersVsFarmers forces
*
********************************************************************************

CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
*******************************************************************************/
    
	/***************************************************************************
	* Modules
	***************************************************************************/
	// Force related utils	
    private module ForceVars
    	static force fc
    	
    	// Static Methods
		private static method addToForce takes player p returns nothing
    		local integer playerId = GetPlayerId(p)
    		set .count_p = .count_p + 1
    		set thistype[16].previous_p.next_p = playerId
    		set thistype[playerId].previous_p = thistype[16].previous_p
    		set thistype[16].previous_p = playerId
    		set thistype[playerId].next_p = 16
    		set thistype[playerId].get_p = p
    		call ForceAddPlayer(thistype.fc, p)
    	endmethod
    	
    	private static method removeFromForce takes player p returns nothing
    		local integer playerId = GetPlayerId(p)
    		set .count_p = .count_p - 1
    		set thistype[playerId].previous_p.next_p = thistype[playerId].next_p
    		set thistype[playerId].next_p.previous_p = thistype[playerId].previous_p
    		set thistype[playerId].get_p = null
    		call ForceRemovePlayer(thistype.fc, p)
    	endmethod
    	
    	public static method contain takes player p returns thistype
    		return IsPlayerInForce(p, thistype.fc)
    	method
    	
    	public static method findByPlayer takes player p returns thistype
    		return thistype[GetPlayerId(p)]
    	method
    	
    	public static method clear takes nothing returns nothing
    		local thistype role = thistype.first
    		loop
    			exitwhen role.end
    			call thistype.remove(role.get)
    			set role = role.next
    		endloop
    		call ForceClear(thistype.fc)
    	method
    	
    	private static method onInit takes nothing returns nothing
    		set thistype[16].end_p = true
    		set thistype[16].next_p = 16
    		set thistype[16].previous_p = 16
    		set thistype[16].get_p = null
    		
    		// Create Force
    		set fc = CreateForce()
    	endmethod
	endmodule
	
	/***************************************************************************
	* Structs
	***************************************************************************/
	// Associate players with their force , units, data.
    struct Hunter extends array
    	implement PlayerVars
    	implement ForceVars
    	implement HunterUnitVars
    	
    	// specific attributes
    	integer killCount = 0
    	
    	// Static Methods
		public static method add takes player p returns nothing
    		call addToForce(p)
    	endmethod
    	
    	public static method remove takes player p returns nothing
    		call removeFromForce(p)
    		call setHero(null)
    	endmethod
    	
    	public method randomizeHeroLoc takes nothing returns nothing
        endmethod
        
        public static method goldBonusForKilling takes nothing returns nothing
        	local thistype h = thistype[thistype.first]
        	local integer iGold = 0
        	loop
				exitwhen h.end
				set iGold = 5 * h.killCount
				call AdjustPlayerStateSimpleBJ(h.get, PLAYER_STATE_GOLD_GATHERED, iGold)
				set h= h.next
			endloop
        endmethod
    	
    endstruct
    
    struct Farmer extends array
    	implement PlayerVars
    	implement ForceVars
    	implement FarmerUnitVars
    	
    	integer deathCount = 0
    	
    	// Static Methods
		public static method add takes player p returns nothing
    		call addToForce(p)
    	endmethod
    	
    	public static method remove takes player p returns nothing
    		call removeFromForce(p)
    	endmethod
    	
    	public static method goldCompensateForDeath takes nothing returns nothing
        	local thistype f = thistype[thistype.first]
        	local integer iGold = 0
        	local integer iLumber = 0
        	loop
				exitwhen f.end
				set iGold = 5 * f.deathCount
				set iLumber = f.deathCount
				call AdjustPlayerStateSimpleBJ(f.get, PLAYER_STATE_GOLD_GATHERED, iGold)
				call AdjustPlayerStateSimpleBJ(f.get, PLAYER_STATE_RESOURCE_LUMBER, iLumber)
				set f= f.next
			endloop
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
		local integer iNbrFarmers	// Number of Farmer
		local integer iNbrHunters	// Number of Hunter
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
		
		// re-assemble team and alliance after shuffling
		call SetupTeam()
		call SetupAlly()
		
	endfunction
    	
	// It has default game alliance
	private function LoadDefaultSetting takes nothing returns nothing
		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
		loop
			// Set max allowed hero to 1
			call SetPlayerTechMaxAllowed(CST_INT_MAX_HEROS, CST_INT_TECHID_HERO, ap.get)
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
    	
	// Do clean-up work for leaving player
	private function RemoveLeavingPlayer takes nothing returns boolean
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
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
    	// Register a leave action callback of player leave event
    	call Players.LEAVE.register(Filter(function RemoveLeavingPlayer))
    	// Grouping players to Hunter/Farmer force by default
    	call LoadDefaultSetting()
    endfunction
endlibrary