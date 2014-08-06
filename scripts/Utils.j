library Utils/*
********************************************************************************
*     Utils library that contais many functions for miscellaneous use
*
*******************************************************************************/

    globals
        private sound errorSound
        private sound hintSound
    endglobals

    /***************************************************************************
    * Common Use Functions
    ***************************************************************************/
    // String uitls
    function StringStripLeft takes string text, string chars returns string 
        local integer len    = StringLength(text)
        local integer ch_len = StringLength(chars)
        local integer index  = 0
        local integer i = 0
        local string  s = ""
        /* Preliminary Check */
        if ch_len > len then
            return text
        endif
        /* Loop Through Leading Chars */
        loop
            exitwhen i == len 
            set s = SubString(text, i, i+ch_len)
            if s == chars then
                set index = i+ch_len
            elseif index == 0 then
                return text
            else
                return SubString(text, index, len)
            endif
            set i = i + ch_len
        endloop
        return ""
    endfunction
    
    function StringStripRight takes string text, string chars returns string 
        local integer ch_len = StringLength(chars)
        local integer i      = StringLength(text)
        local integer index  = 0
        local string  s = ""
        /* Preliminary Check */
        if ch_len > i then
            return text
        endif
        /* Loop Through Leading Chars */
        loop
            exitwhen i <= 0 
            set s = SubString(text, i-ch_len, i)
            if s == chars then
                set index = i-ch_len
            elseif index == 0 then
                return text
            else
                return SubString(text, 0, index)
            endif
            set i = i - ch_len
        endloop
        return ""
    endfunction
    
    function StringStrip takes string text, string chars returns string 
        set text = StringStripLeft(text, chars)
        return StringStripRight(text, chars)
    endfunction
    
    // Tint string with given color
    function Tint takes string str, string colorCode returns string
        return colorCode + str + COLOR_END
    endfunction
    
    function AppendHotkey takes string source, string hotkey returns string
        return "|cffffcc00[" + hotkey + "]|r " + source
    endfunction

    // Get Random Real
    function GetRandomRectX takes rect r returns real
        call SetRandomSeed(GetRandomInt(0, 1000000))
        return GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
    endfunction
    
    function GetRandomRectY takes rect r returns real
        call SetRandomSeed(GetRandomInt(0, 1000000))
        return GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
    endfunction
    
    function IsIntDividableBy takes integer dividen, integer divisor returns boolean
        //local integer result = dividen/divisor
        //local integer mod = dividen - result*divisor
        return dividen - R2I(R2I(dividen/divisor)*divisor) == 0
    endfunction
    
    // Show messages at different level at mid-bottom of screen
    function ShowErrorToPlayer takes player p, string str returns nothing
        local string msg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n[*" +ARGB(CST_COLOR_Important).str(MSG_Important)+ "*]" + ARGB(CST_COLOR_Important).str(str)
        if GetLocalPlayer() == p then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(p, 0.52, 0.96, CST_MSGDUR_Beaware, msg)
            // !!!Buggy StartSound!!! which will cause jass skip next statement
            //call StartSound (errorSound)
        endif
    endfunction
    
    function ShowNoticeToPlayer takes player p, string str returns nothing
        local string msg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n[*" +ARGB(CST_COLOR_Beaware).str(MSG_Beaware)+ "*]" + ARGB(CST_COLOR_Beaware).str(str)
        if GetLocalPlayer() == p then
            call ClearTextMessages()
            call DisplayTimedTextToPlayer(p, 0.52, 0.96, CST_MSGDUR_Beaware, msg)
            //call StartSound (hintSound)
        endif
    endfunction
    
    function ShowErrorToAllPlayer takes string str returns nothing
        local integer i = 0
        loop
            call ShowErrorToPlayer(Player(i),str)
            set i = i + 1
            exitwhen i == 12
        endloop
    endfunction
    
    function ShowNoticeToAllPlayer takes string str returns nothing
        local integer i = 0
        loop
            call ShowNoticeToPlayer(Player(i),str)
            set i = i + 1
            exitwhen i == 12
        endloop
    endfunction

    // Show normal message to all player with specific argb color
    function ShowMsgToAll takes string str returns nothing
        local integer i = 0
        loop
            call DisplayTimedTextToPlayer(Player(i), 0, 0, CST_MSGDUR_Normal, str)
            set i = i + 1
            exitwhen i == 12
        endloop
    endfunction
    
    // Show normal message to all player with specific duration
    function ShowDurMsgToAll takes string str, real dur returns nothing
        local integer i = 0
        loop
            call DisplayTimedTextToPlayer(Player(i), 0, 0, dur, str)
            set i = i + 1
            exitwhen i == 12
        endloop
    endfunction
    
    // Show game version info
    function ShowVersionInfo takes nothing returns nothing
        call ShowMsgToAll(CST_STR_Version+CST_STR_VersionTag+ARGB(CST_COLOR_Beaware).str(CST_STR_VersionMain+"."+CST_STR_VersionSub))
    endfunction
    
    function FlyEnable takes unit u returns nothing
        call UnitAddAbility(u,'Amrf')
        call UnitRemoveAbility(u,'Amrf')
    endfunction
    
    private function init takes nothing returns nothing
        set errorSound=CreateSoundFromLabel("InterfaceError",false,false,false,10,10)
        set hintSound=CreateSoundFromLabel("Hint", false, false, false, 10, 10)
        //call StartSound( error )  //apparently the bug in which you play a sound for the first time
                                    //and it doesn't work is not there anymore in patch 1.22
    endfunction
endlibrary
