library ChatCommand/* v1.3.0 by Bills
***********************************************************************************************
*
*   This system allows fast commands development.
*
************************************************************************************************
*
*   */ uses /*
*   
*       New*/ Table    /*  hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*
************************************************************************************************
*
*   SETTINGS
*
*/
globals
    // prefix of all commands
    public constant string PREFIX = "-"

    // alert/error message
    private constant string ALERT_MSG_INAVLID = "|cFFF00000Command Invalid|r"
endglobals
/*
********************************************************************************************
*
*   struct ChatCommand
*
*
*       Constructor
*       -----------------------
*
*           static method create takes string whichCommand, code onCommand returns thistype
*
*       Operators
*       -----------------------
*
*           static method operator [] takes string whichCommand returns ChatCommand
*               -   this operator returns (if exists) the instance of a ChatCommand
*               -   exemple: ChatCommand["ar"]
*
*       Members
*       -----------------------
*
*           readonly boolean enabled
*               -   indicates whether the command is enabled
*
*       Methods
*       -----------------------
*
*           method enable takes boolean flag returns nothing
*               -   Enable or disable a command
*
*           method fire takes player whichPlayer, string commandData returns boolean
*               -   Executes a command for a determined player
*               -   Returns true on success
*
*       Event Responses
*       -----------------------
*
*           readonly static ChatCommand eventCommand
*               -    struct of typed command
*
*           readonly static string eventString
*               -    the command in string
*
*           readonly static player eventPlayer
*               -    player that triggered the command
*
*           readonly static integer eventPlayerId
*               -    id of above player
*
*           readonly static string eventData
*               -    data of command (everything after of the first space)
*
****************************************************************************************
*
*   module ChatCommandModule
*
*           this module creates a command using 1 static member and 1 static method:
*               -   static constant string CHAT_COMMAND
*               -   static method onCommand takes nothing returns nothing
*
*****************************************************************************************
*
*    Exemples
*
*        - using struct
*
*            struct CmdExemple extends array
*                static constant string CHAT_COMMAND = "hello"
*
*                static method onCommand takes nothing returns nothing
*                    call BJDebugMsg("Hello Player "+ I2S(ChatCommand.eventPlayerId+1))
*                endmethod
*
*                implement ChatCommandModule
*            endstruct
*
*        - now using a single function
*
*            library Cmd initializer init
*                function CommandResponse takes nothing returns nothing
*                    call BJDebugMsg("Hello Player "+ I2S(ChatCommand.eventPlayerId+1))
*                endfunction
*
*                private function init takes nothing returns nothing
*                    call ChatCommand.create("hello", function CommandResponse)
*                endfunction
*            endlibrary
*
*****************************************************************************************/
    struct ChatCommand extends array

        readonly static thistype eventCommand
        readonly static string eventString
        readonly static player eventPlayer
        readonly static integer eventPlayerId
        readonly static string eventData

        private static Table instances
        private static trigger trig
        private static integer ic = 1 // instance count
        private static integer PREFIX_LEN

        readonly boolean enabled
        private boolexpr callback
        private string command

        static method operator [] takes string command returns thistype
            return instances[StringHash(command)]
        endmethod

        static method create takes string command, code callback returns thistype
            local thistype this = ic
            static if DEBUG_MODE then
                if ChatCommand[command] != 0 then
                    call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[ChatCommand] Warning: Attempted to overwrite \"-"+command+"\" command")
                    return 0
                endif
            endif
            set ic = ic + 1
            
            //call BJDebugMsg("Debug1 cmd:" + command)
            //call BJDebugMsg("Debug1 cmd hash:" + I2S(StringHash(command)))
            //call BJDebugMsg("Debug1 this:" + I2S(this))
            set instances[StringHash(command)] = this
            //call BJDebugMsg("Debug2 this:" + I2S(this))
            //call BJDebugMsg("Debug2 cmd:" + I2S(instances[StringHash(command)]))
            set this.command = command
            set this.enabled = true
            set this.callback = Filter(callback)
            return this
        endmethod

        method fire takes player which, string data returns boolean
            if enabled then
                set eventCommand = this
                set eventString = command
                set eventPlayer = which
                set eventPlayerId = GetPlayerId(which)
                set eventData = data
                call TriggerAddCondition(trig,callback)
                call TriggerEvaluate(trig)
                call TriggerClearConditions(trig)
                return true
            else
            	debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"[ChatCommand] Warning: command \"-"+command+"\" has been disabled")
            endif
            return false
        endmethod
        
        method enable takes boolean flag returns nothing
            set enabled = flag
        endmethod
        
        private static method eventListener takes nothing returns boolean
            local string chat = StringStrip(GetEventPlayerChatString()," ")
            local string char
            local string str = ""
            local string data = ""
            local integer i = PREFIX_LEN-1
            local integer strlen = StringLength(chat)
            local thistype cmd
            if SubString(chat,0,PREFIX_LEN) != PREFIX or strlen <= PREFIX_LEN then
                return false
            endif
            loop
                set i = i+1
                set char = SubString(chat,i,i+1)
                exitwhen char == " " or i == strlen
                set str = str + char
            endloop
            
            //call BJDebugMsg("Debug str:" + str)
            //call BJDebugMsg("Debug strHash:" + I2S(StringHash(str)))
            //call BJDebugMsg("Debug instance:" + I2S(instances[StringHash(str)]))
            set cmd = ChatCommand[str]
            if cmd != 0 then
            	call BJDebugMsg("Debug cmd:" + cmd.command)
                loop
                    set i = i+1
                    set char = SubString(chat,i,i+1)
                    exitwhen i >= strlen
                    set data = data + char
                endloop
                
                call cmd.fire(GetTriggerPlayer(),StringStrip(data, " "))
            endif
            return false
        endmethod
        
        static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()
            local integer i = 0
            loop
                exitwhen i>12
                call TriggerRegisterPlayerChatEvent(t, Player(i), PREFIX, false )
                set i=i+1
            endloop
            call TriggerAddCondition(t, Filter(function thistype.eventListener))
            set t = null
            set instances = Table.create()
            set trig = CreateTrigger()
            set PREFIX_LEN = StringLength(PREFIX)
        endmethod
    endstruct
    
    module ChatCommandModule
        // static constant string CHAT_COMMAND = "command"
        // static method onCommand takes nothing returns nothing
        // endmethod
        
        private static method onInit takes nothing returns nothing
            //call BJDebugMsg("Create command " + CHAT_COMMAND + " via struct")
        	call ChatCommand.create(CHAT_COMMAND, function thistype.onCommand)
        endmethod
    endmodule

endlibrary