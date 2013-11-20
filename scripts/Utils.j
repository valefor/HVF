library Utils

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
endlibrary