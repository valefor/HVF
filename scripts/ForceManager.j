library ForceManager initializer init/* v0.0.1 Xandria
*/  uses 	 Alloc         /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/           PlayerManager /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/           PlayerAlliance /*
*************************************************************************************
* 	HVF Force management : For use of managing HuntersVsFarmers forces
*
*************************************************************************************

call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
*************************************************************************************/

	globals
		private force fcFarmers = null // Force Farmer
        private force fcHunters = null	// Force Hunter
        private integer iNbrFarmers	// Number of Farmer
        private integer iNbrHunters	// Number of Hunter
    endglobals
    
    struct Force extends array
    
    	static method addFarmer takes player p returns nothing
    		call ForceAddPlayer(fcFarmers, p)
    	endmethod
    	
    	static method addHunter takes player p returns nothing
    		call ForceAddPlayer(fcHunters, p)
    	endmethod
    	
    	static method removeFarmer takes player p returns nothing
    		call ForceRemovePlayer(fcFarmers, p)
    	endmethod
    	
    	static method removeHunter takes player p returns nothing
    		call ForceRemovePlayer(fcHunters, p)
    	endmethod
    	
    	static method isFarmer takes player p returns boolean
    		return IsPlayerInForce(p, fcFarmers)
    	endmethod
    	
    	static method isHunter takes player p returns boolean
    		return IsPlayerInForce(p, fcHunters)                                          
    	endmethod
    	
    	static method getFarmerForce takes player p returns force
    		return fcFarmers
    	endmethod
    	
    	static method getHunterForce takes player p returns force
    		return fcHunters
    	endmethod
    	
    	static method inSameForce takes player p, player p2 returns boolean
    		if isFarmer(p)  then
    			if isFarmer(p2) then
    				return true
    			endif
    		else
    			if isHunter(p2) then
    				return true
    			endif
    		endif
    		return false
    	endmethod
    	
    	private static method setupTeam takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		
    		loop
    			exitwhen ap.end
    			if isFarmer(ap.get) then
    				call SetPlayerTeam(ap.get, 0)
    			else
    				call SetPlayerTeam(ap.get, 1)
    			endif
    			set ap = ap.next
    		endloop
    		
    	endmethod
    	
    	// Temporary solution
    	private static method setupAlly takes nothing returns nothing
    		local ActivePlayer sourcePlayer = ActivePlayer[ActivePlayer.first]
    		local ActivePlayer targetPlayer
    		
    		loop
    			exitwhen sourcePlayer.end
    			set targetPlayer = sourcePlayer.next
    			loop
    				exitwhen targetPlayer.end
    				if inSameForce(sourcePlayer.get, targetPlayer.get) then
    					call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_NEUTRAL_VISION)
    				else 
    					call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_UNALLIED)
    				endif
    				set targetPlayer = targetPlayer.next
    			endloop
    			set sourcePlayer = sourcePlayer.next
    		endloop
    		
    	endmethod
    	
    	static method shufflePlayer takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		local integer iPlayerNbr = ActivePlayer.count
    		local integer iFarmerCount = 0
    		local integer iHunterCount = 0
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
    		call ForceClear(fcFarmers)
    		call ForceClear(fcHunters)
    		
    		loop
    			exitwhen ap.end
    			if iHunterCount < iNbrHunters and iFarmerCount < iNbrFarmers then
    				if GetRandomInt(0,1) == 1 then
    					debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunters")
    					call addHunter(ap.get)
    					set iHunterCount = iHunterCount + 1
    				else
    					debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmers")
						call addFarmer(ap.get)
						set iFarmerCount = iFarmerCount + 1
					endif
				else
					if iFarmerCount == iNbrFarmers then
						debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunters")
    					call addHunter(ap.get)
    					set iHunterCount = iHunterCount + 1
					else
						debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmers")
						call addFarmer(ap.get)
						set iFarmerCount = iFarmerCount + 1
					endif
    			endif
    			set ap = ap.next
    		endloop
    		
    		debug call BJDebugMsg("Shuffling finished! Number of Farmers:" + I2S(iNbrFarmers) + ", Number of Hunters:" +I2S(iNbrHunters))
    		call setupTeam()
    		call setupAlly()
    		
    	endmethod
    	
    	// It has default game alliance
    	static method defaultGrouping takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		loop
    			if GetPlayerId(ap.get) > 5 and GetPlayerId(ap.get) < 10 then
    				debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Hunters")
    				call ForceAddPlayer(fcHunters, ap.get)
    				set iNbrHunters = iNbrHunters + 1
    			else
    				debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Farmers")
    				call ForceAddPlayer(fcFarmers, ap.get)
    				set iNbrFarmers = iNbrFarmers + 1
    			endif
        		
        		set ap = ap.next
        		exitwhen ap.end
        	endloop
    	endmethod
    	
    	private static method rmPlayerFromGroup takes nothing returns boolean
    		local player pLeave = GetTriggerPlayer()
    			if isHunter(pLeave) then
    				debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunters")
    				call removeHunter(pLeave)
    			else
    				debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmers")
    				call removeFarmer(pLeave)
    			endif
    		set pLeave = null
    		return false
    	endmethod
    	
    	private static method onInit takes nothing returns nothing
    		// Register a leave action callback of player leave event
    		call Players.LEAVE.register(Filter(function thistype.rmPlayerFromGroup))
    	endmethod
    endstruct
    
    struct Hunters extends array
    	player owner
    	unit hero
    endstruct
    
    struct Farmers extends array
    endstruct
    
    private function init takes nothing returns nothing
    	set fcFarmers = CreateForce()
    	set fcFarmers = CreateForce()
    	
    	// Grouping players to Hunters/Farmers force by default
    	call Force.defaultGrouping()
    endfunction
endlibrary