library Core initializer init/* v0.0.1 Xandria
********************************************************************************
*     HVF Core library which provides some useful functions
*
********************************************************************************
*
*   */ uses /*
*   
*       New*/ Utils /*
*
********************************************************************************
*    *** NAMING ***
*    I'd like to put name convention here
*    struct            :    struct StructName
*    function/method    :
*        normal funcion        :    function FunctionName
*        struct.method        :    method methodName
*        struct.initializer    :    onInit
*        library.initializer    :     init
*    constant :    
*        global    :    CST_$TYPE$_NAME
*        local    :    $TYPE-UPPERCASE$_NAME, and they should always be defined as a global
*    variable :    
*    "I don't intent to seperate global and local variable since we can mix them together
*    in vJass, but we shall keep in mind what kind they are"
*        primitive and normal declaration : 
*            boolean -> bVar, bsVarArray
*            button     -> btVar, btsVarArray
*            dialog     -> dgVar, ``
*            integer -> iVar, ``
*            real     -> rVar, ``
*            rect    -> rctVar, ``
*            player     -> pVar, ``
*            timer     -> tmVar, ``
*            trigger -> tgVar, ``

*        Declarations in Struct : free style, choose what you like, keep name simple & meaningful
*
*    *** Optional ***
*    Here list some optional name convention, but any way I don't like '_' o_O
*    and it's not necessary since vJass has provided a nice encapsulation
*    private    function/method/var/global    :    p_something
********************************************************************************
*    TriggerExecute     : Execute Trigger's action, ignore Trigger's conditions
native TriggerExecute       takes trigger whichTrigger returns nothing

*    TriggerEvaluate : Execute Trigger's conditions, ignore Trigger's action
native TriggerEvaluate      takes trigger whichTrigger returns boolean

Both open a new thread (and so halt the previous one, since jass doesn't support multi-threads).
But TriggerEvaluate is faster, plus you don't need to remove a trigger-condition when you destroy a trigger, 
you will have to remove a trigger-action if you destroy a trigger, else you will leak the action (TriggerClearActions only disable actions but doesn't free the memory)
Use TriggerRemoveAction instead
Just be aware that obviously you can't use TriggerSleepAction and so also PolledWait in a trigger condition for an obvious reason (which is in most cases hardly a con).
I believe you can't also use some few functions in a trigger condition, such as PauseGame if i remember correctly.

// Runs the trigger's actions if the trigger's conditions evaluate to true.

function ConditionalTriggerExecute takes trigger trig returns nothing
    if TriggerEvaluate(trig) then
        call TriggerExecute(trig)
    endif
endfunction

TriggerSleepAction and PolledWait both can't be less than 0.10

TriggerSleepAction doesn't pause when a player about to disconnet(waiting for player message)

Use PolledWait because of the above reason.

functions
GetUnitsOfPlayerAll
The "defend" ability has a bug that make it fire an
"undefend" order when a unit dies, gets removed or gets revived
// Custom hero unit type id
*******************************************************************************/

    /*
    ****************************************************************************
    * IsSinglePlayer takes nothing returns boolean
    *    Detect whether player is soloing
    ****************************************************************************
    */
    globals
        private boolean bSinglePlayer     = ReloadGameCachesFromDisk()
    endglobals

    function IsSinglePlayer takes nothing returns boolean
        return bSinglePlayer
    endfunction
    
    /*
    **************************************************************************************
    * Prevent Save : hiveworkshop.com/forums/jass-resources-412/snippet-preventsave-158048/
    *    @provide by TriggerHappy
    **************************************************************************************
    */
    globals
        boolean bGameAllowSave = true
    endglobals
    
    globals
        private dialog dgDummy = DialogCreate()
        private timer  tmDummy = CreateTimer()
        private player pLocalplayer
    endglobals
    
    function EnableSave takes player p, boolean flag returns nothing
        if (p == pLocalplayer) then
            set bGameAllowSave = flag
        endif
    endfunction
    
    private function DummyExit takes nothing returns nothing
        call DialogDisplay(pLocalplayer, dgDummy, false)
    endfunction
    
    private function StopSave takes nothing returns boolean
        if not bGameAllowSave then
            call DialogDisplay(pLocalplayer, dgDummy, true)
        endif
        call TimerStart(tmDummy, 0.00, false, function DummyExit)
        return false      
    endfunction
    
    private function PreventSave takes nothing returns nothing
        local trigger tgGameSave = CreateTrigger()
        //set pLocalplayer = GetLocalPlayer()
        
        call TriggerRegisterGameEvent(tgGameSave, EVENT_GAME_SAVE)
        call TriggerAddCondition(tgGameSave, function StopSave)
    endfunction
    
    /*
    ****************************************************************************
    * GetHostPlayer takes nothing returns player
    *    Detect Host who creates this game
    ****************************************************************************
    */
    globals
        private player pHost = null
    endglobals
    
    private function DetectHost takes nothing returns nothing
        local gamecache gc = InitGameCache("Map.w3v")
        call StoreInteger ( gc, "Map", "Host", GetPlayerId(GetLocalPlayer ())+1)
        call TriggerSyncStart ()
        call SyncStoredInteger ( gc, "Map", "Host" )
        call TriggerSyncReady ()
        set pHost = Player( GetStoredInteger ( gc, "Map", "Host" )-1)
        call FlushGameCache( gc )
        set gc = null
    endfunction
    
    function GetHostPlayer takes nothing returns player
        if pHost == null then
            // if DetectHost fails, we use first Human player as Host
            set pHost = Human[Human.first].get            
        endif
        return pHost
    endfunction
    
    // library initilaizer
    private function init takes nothing returns nothing
        // Prevent Save Action
        // call PreventSave()
        
        // Detect Host who creates this game
        call DetectHost()
        
    endfunction
    
endlibrary
