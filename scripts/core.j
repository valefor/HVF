library_once Core

	globals
		private boolean bSinglePlayer = ReloadGameCachesFromDisk()
	endglobals

	function IsSinglePlayer takes nothing returns boolean
		return bSinglePlayer
	endfunction
	struct TimeManager
	endstruct
endlibrary
