library AutoIndex
//===========================================================================
// Information:
//==============
//
//     AutoIndex is a very simple script to utilize. Just call GetUnitId(unit)
// to get get the unique value assigned to a particular unit. The GetUnitId
// function is extremely fast because it inlines directly to a GetUnitUserData
// call. AutoIndex automatically assigns an ID to each unit as it enters the
// map, and instantly frees that ID as the unit leaves the map. Detection of
// leaving units is accomplished in constant time without a periodic scan.
//
//     AutoIndex uses UnitUserData by default. If something else in your map
// would conflict with that, you can set the UseUnitUserData configuration
// constant to false, and a hashtable will be used instead. Note that hash-
// tables are about 60% slower.
//
//     If you turn on debug mode, AutoIndex will be able to display several
// helpful error messages. The following issues will be detected:
//   -Passing a removed or decayed unit to GetUnitId
//   -Code outside of AutoIndex has overwritten a unit's UserData value.
//   -GetUnitId was used on a filtered unit (a unit you don't want indexed).
//
//     AutoIndex provides events upon indexing or deindexing units. This
// effectively allows you to notice when units enter or leave the game. Also
// included are the AutoData, AutoCreate, and AutoDestroy modules, which allow
// you to fully utilize AutoIndex's enter/leave detection capabilities in
// conjunction with your structs.
//
//===========================================================================
// How to install AutoIndex:
//===========================
//
// 1.) Copy and paste this script into your map.
// 2.) Save it to allow the ObjectMerger macro to generate the "Leave Detect"
//     ability for you. Close and re-open the map. After that, disable the macro
//     to prevent the delay while saving.
//
//===========================================================================
// How to use AutoIndex:
//=======================
//
//     So you can get a unique integer for each unit, but how do you use that to
// attach data to a unit? GetUnitId will always return a number in the range of
// 1-8190. This means it can be used as an array index, as demonstrated below:
/*
    globals
        integer array IntegerData
        real array RealData
        SomeStruct array SomeStructData
    englobals

    function Example takes nothing returns nothing
        local unit u = CreateUnit(Player(0), 'hpea', 0., 0., 0.)
        local integer id = GetUnitId(u)
            //You now have a unique index for the unit, so you can
            //attach or retrieve data about the unit using arrays.
            set IntegerData[id] = 5
            set RealData[id] = 25.0
            set SomeStructData[id] = SomeStruct.create()
            //If you have access to the same unit in another function, you can
            //retrieve the data by using GetUnitId() and reading the arrays.
    endfunction
*/
//     The UnitFilter function in the configuration section is provided so that
// you can make AutoIndex completely ignore certain unit-types. Ignored units
// won't be indexed or fire indexed/deindexed events. You may want to filter out
// dummy casters or system-private units, especially ones that use UnitUserData
// internally. xe dummy units are automatically filtered.
//
//===========================================================================
// How to use OnUnitIndexed / OnUnitDeindexed:
//=============================================
//
//     AutoIndex will fire the OnUnitIndexed event when a unit enters the map,
// and the OnUnitDeindexed event when a unit leaves the map. Functions used
// as events must take a unit and return nothing. An example is given below:
/*
    function UnitEntersMap takes unit u returns nothing
        call BJDebugMsg(GetUnitName(u)+" with ID "+I2S(GetUnitId(u))+" entered the map.")
    endfunction //Using GetUnitId() during Indexed events works fine...

    function UnitLeavesMap takes unit u returns nothing
        call BJDebugMsg(GetUnitName(u)+" with ID "+I2S(GetUnitId(u))+" left the map.")
    endfunction  //So does using GetUnitId() during Deindexed events.

    function Init takes nothing returns nothing
        call OnUnitIndexed(UnitEntersMap)
        call OnUnitDeindexed(UnitLeavesMap)
    endfunction
*/
//     If you call OnUnitIndexed during map initialization, every existing
// unit will be considered as entering the map. This saves you from the need
// to manually enumerate preplaced units (or units created by initialization
// code that ran before OnUnitIndexed was called).
//
//     OnUnitDeindexed runs while a unit still exists, which means you can
// still do things such as destroy special effects attached to the unit.
// The unit will cease to exist immediately after the event is over.
//
//===========================================================================
// AutoIndex API:
//================
//
// GetUnitId(unit) -> integer
//   This function returns a unique ID in the range of 1-8190 for the
//   specified unit. Returns 0 if a null unit was passed. This function
//   inlines directly to GetUnitUserData or LoadInteger if debug mode
//   is disabled. If debug mode is enabled, this function will print
//   an error message when passed a decayed or filtered unit.
//
// IsUnitIndexed(unit) -> boolean
//   This function returns a boolean indicating whether the specified
//   unit has been indexed. The only time this will return false is
//   for units you have filtered using the UnitFilter function, or
//   for xe dummy units. You can use this function to easily detect
//   dummy units and avoid performing certain actions on them.
//
// OnUnitIndexed(IndexFunc)
//   This function accepts an IndexFunc, which must take a unit and
//   return nothing. The IndexFunc will be fired instantly whenever
//   a unit enters the map. You may use GetUnitId on the unit. When
//   you call this function during map initialization, every existing
//   unit will be considered as entering the map.
//
// OnUnitDeindexed(IndexFunc)
//   Same as above, but runs whenever a unit is leaving the map. When
//   this event runs, the unit still exists, but it will cease to exist
//   as soon as the event ends. You may use GetUnitId on the unit.
//
//===========================================================================
// How to use AutoData:
//======================
//
//     The AutoData module allows you to associate one or more instances
// of the implementing struct with units, as well as iterate through all
// of the instances associated with each unit.
//
//     This association is accomplished through the "me" instance member,
// which the module will place in the implementing struct. Whichever unit
// you assign to "me" becomes the owner of that instance. You may change
// ownership by reassigning "me" to another unit at any time, or you may
// make the instance unowned by assigning "me" to null.
//
//     AutoData implements the static method operator [] in your struct
// to allow you to access instances from their owning units. For example,
// you may type: local StructName s = StructName[u]. If u has been set
// to own an instance of StructName, s will be set to that instance.
//
//     So, what happens if you assign the same owning unit to multiple
// instances? You may use 2D array syntax to access instances assigned to
// the same unit: local StructName s = StructName[u][n], where u is the
// owning unit, and n is the index beginning with 0 for each unit. You
// can access the size of a unit's instance list (i.e. the number of
// instances belonging to the unit) by using the .size instance member.
/*
    struct Example
        implement AutoData
        static method create takes unit u returns Example
            local Example this = allocate()
                set me = u //Assigning the "me" member from AutoData.
            return this
        endmethod
    endstruct
    function Test takes nothing returns nothing
        local unit u = CreateUnit(Player(0), 'hpea', 0., 0., 0.)
        local Example e1 = Example.create(u)
        local Example e2 = Example.create(u)
        local Example e3 = Example.create(u)
        local Example e
            call BJDebugMsg(I2S(Example[u].size)) //Prints 3 because u owns e1, e2, and e3.
            set e = Example[u][GetRandomInt(0, Example[u].size - 1)] //Random instance belonging to u.
            set e = Example[u]  //This is the fastest way to iterate the instances belonging
            loop                //to a specific unit, starting with the first instance.
                exitwhen e == 0 //e will be assigned to 0 when no instances remain.
                call BJDebugMsg(I2S(e)) //Prints the values of e1, e2, e3.
                set e = e[e.index + 1] //"e.index" refers to the e's position in u's instance list.
            endloop                    //Thus, index + 1 is next, and index - 1 is previous.
    endfunction                        //This trick allows you to avoid a local counter.
*/
//   AutoData restrictions:
//   -You may not implement AutoData in any struct which has already
//    declared static or non-static method operator [].
//   -AutoData will conflict with anything named "me", "size", or
//    "index" in the implementing struct.
//   -AutoData may not be implemented in structs that extend array.
//   -You may not declare your own destroy method. (This restriction
//    can be dropped as soon as JassHelper supports module onDestroy).
//
//   AutoData information:
//   -You do not need to null the "me" member when destroying an
//    instance. That is done for you automatically during destroy().
//    (But if you use deallocate(), you must null "me" manually.)
//   -StructName[u] and StructName[u][0] refer to the same instance,
//    which is the first instance that was associated with unit u.
//   -StructName[u][StructName[u].size - 1] refers to the instance that
//    was most recently associated with unit u.
//   -Instances keep their relative order in the list when one is removed.
//
//===========================================================================
// How to use AutoCreate:
//=======================
//
//     The AutoCreate module allows you to automatically create instances
// of the implementing struct for units as they enter the game. AutoCreate
// automatically implements AutoData into your struct. Any time an instance
// is automatically created for a unit, that instance's "me" member will be
// assigned to the entering unit.
//
//   AutoCreate restrictions:
//   -All of the same restrictions as AutoData.
//   -If your struct's allocate() method takes parameters (i.e. the parent
//    type's create method takes parameters), you must declare a create
//    method and pass those extra parameters to allocate yourself.
//
//   AutoCreate information:
//   -You may optionally declare the createFilter method, which specifies
//    which units should recieve an instance as they enter the game. If
//    you do not declare it, all entering units will recieve an instance.
//   -You may optionally declare the onCreate method, which will run when
//    AutoCreate automatically creates an instance. (This is just a stand-
//    in until JassHelper supports the onCreate method.)
//   -You may declare your own create method, but it must take a single
//    unit parameter (the entering unit) if you do so.
/*
    struct Example
        private static method createFilter takes unit u returns boolean
            return GetUnitTypeId(u) == 'hfoo' //Created only for Footmen.
        endmethod
        private method onCreate takes nothing returns nothing
            call BJDebugMsg(GetUnitName(me)+" entered the game!")
        endmethod
        implement AutoCreate
    endstruct
*/
//===========================================================================
// How to use AutoDestroy:
//=========================
// 
//     The AutoDestroy module allows you to automatically destroy instances
// of the implementing struct when their "me" unit leaves the game. AutoDestroy
// automatically implements AutoData into your struct. You must assign a unit
// to the "me" member of an instance for this module to have any effect.
//
//   AutoDestroy restrictions:
//   -All of the same restrictions as AutoData.
//
//   AutoDestroy information:
//   -If you also implement AutoCreate in the same struct, remember that it
//    assigns the "me" unit automatically. That means you can have fully
//    automatic creation and destruction.
/*
    struct Example
        static method create takes unit u returns Example
            local Example this = allocate()
                set me = u //You should assign a unit to "me",
            return this    //otherwise AutoDestroy does nothing.
        endmethod          //Not necessary if using AutoCreate.
        private method onDestroy takes nothing returns nothing
            call BJDebugMsg(GetUnitName(me)+" left the game!")
        endmethod
        implement AutoDestroy
    endstruct
*/
//===========================================================================
// Configuration:
//================

//! external ObjectMerger w3a Adef lvdt anam "Leave Detect" aart "" arac 0
//Save your map with this Object Merger call enabled, then close and reopen your
//map. Disable it by removing the exclamation to remove the delay while saving.

globals
    private constant integer LeaveDetectAbilityID = 'lvdt'
    //This rawcode must match the parameter after "Adef" in the
    //ObjectMerger macro above. You may change both if you want.
    
    private constant boolean UseUnitUserData = true
    //If this is set to true, UnitUserData will be used. You should only set
    //this to false if something else in your map already uses UnitUserData.
    //A hashtable will be used instead, but it is about 60% slower.
    
    private constant boolean SafeMode = true
    //This is set to true by default so that GetUnitId() will ALWAYS work.
    //If if this is set to false, GetUnitId() may fail to work in a very
    //rare circumstance: creating a unit that has a default-on autocast
    //ability, and using GetUnitId() on that unit as it enters the game,
    //within a trigger that detects any order. Set this to false for a
    //performance boost only if you think you can avoid this issue.
    
    private constant boolean AutoDataFastMode = true
    //If this is set to true, AutoData will utilize one hashtable per time
    //it is implemented. If this is set to false, all AutoDatas will share
    //a single hashtable, but iterating through the instances belonging to
    //a unit will become about 12.5% slower. Your map will break if you
    //use more than 255 hashtables simultaneously. Only set this to false
    //if you suspect you will run out of hashtable instances.
endglobals

private function UnitFilter takes unit u returns boolean
    return true
endfunction
//Make this function return false for any unit-types you want to ignore.
//Ignored units won't be indexed or fire OnUnitIndexed/OnUnitDeindexed
//events. The unit parameter "u" to refers to the unit being filtered.
//Do not filter out xe dummy units; they are automatically filtered.

//===========================================================================
// AutoData / AutoCreate / AutoDestroy modules:
//==============================================

function interface AutoCreator takes unit u returns nothing
function interface AutoDestroyer takes unit u returns nothing

globals                
    hashtable AutoData = null //If AutoDataFastMode is disabled, this hashtable will be
endglobals                    //initialized and shared between all AutoData implementations.

module AutoData
    private static hashtable ht
    private static thistype array data
    private static integer array listsize
    private static key typeid //Good thing keys exist to identify each implementing struct.
    private unit meunit
    private integer id
    
    readonly integer index //The user can avoid using a local counter because this is accessable.
    
    static method operator [] takes unit u returns thistype
        return data[GetUnitId(u)]
    endmethod //This is as fast as retrieving an instance from a unit gets.
    
    method operator [] takes integer index returns thistype
        static if AutoDataFastMode then //If fast mode is enabled...
            return LoadInteger(ht, id, index)
        else //Each instance has its own hashtable to associate unit and index.
            return LoadInteger(AutoData, id, index*8190+typeid)
        endif //Otherwise, simulate a 3D array associating unit, struct-type ID, and index.
    endmethod //Somehow, this version is 12.5% slower just because of the math.
    
    private method setIndex takes integer index, thistype data returns nothing
        static if AutoDataFastMode then //Too bad you can't have a module-private operator []=.
            call SaveInteger(ht, id, index, data)
        else
            call SaveInteger(AutoData, id, index*8190+typeid, data)
        endif
    endmethod
    
    private method remove takes nothing returns nothing
        if meunit == null then //If the struct doesn't have an owner...
            return             //Nothing needs to be done.
        endif
        loop
            exitwhen index == listsize[id]        //The last value gets overwritten by 0.
            call setIndex(index, this[index + 1]) //Shift each element down by one.
            set this[index].index = index         //Update the shifted instance's index.
            set index = index + 1
        endloop 
        set listsize[id] = listsize[id] - 1
        set data[id] = this[0] //Ensure thistype[u] returns the same value as thistype[u][0].
        set meunit = null
    endmethod
    
    private method add takes unit u returns nothing
        if meunit != null then     //If the struct has an owner...
            call remove()          //remove it first.
        endif
        set meunit = u
        set id = GetUnitId(u)      //Cache GetUnitId for slight performance boost.
        if data[id] == 0 then      //If this is the first instance for this unit...
            set data[id] = this    //Update the value that thistype[u] returns.
        endif
        set index = listsize[id]   //Remember the index for removal.
        call setIndex(index, this) //Add to the array.
        set listsize[id] = index + 1
    endmethod
    
    method operator me takes nothing returns unit
        return meunit
    endmethod
    
    method operator me= takes unit u returns nothing
        if u != null then //If assigning "me" a non-null value...
            call add(u)   //Add this instance to that unit's array.
        else              //If assigning "me" a null value...
            call remove() //Remove this instance from that unit's array.
        endif
    endmethod
    
    method operator size takes nothing returns integer
        return listsize[id]
    endmethod
    
    method destroy takes nothing returns nothing
        call deallocate()
        call remove() //This makes removal automatic when an instance is destroyed.
    endmethod
    
    private static method onInit takes nothing returns nothing
        static if AutoDataFastMode then        //If fast mode is enabled...
            set ht = InitHashtable()           //Initialize one hashtable per instance.
        else                                   //If fast mode is disabled...
            if AutoData == null then           //If the hashtable hasn't been initialized yet...
                set AutoData = InitHashtable() //Initialize the shared hashtable.
            endif
        endif
    endmethod
endmodule

module AutoCreate
    implement AutoData //AutoData is necessary for AutoCreate.

    private static method creator takes unit u returns nothing
        local thistype this
        local boolean b = true                          //Assume that the instance will be created.
            static if thistype.createFilter.exists then //If createFilter exists...
                set b = createFilter(u)                 //evaluate it and update b.
            endif
            if b then                                   //If the instance should be created...
                static if thistype.create.exists then   //If the create method exists...
                    set this = create(u)                //Create the instance, passing the entering unit.
                else                                    //If the create method doesn't exist...
                    set this = allocate()               //Just allocate the instance.
                endif
                set me = u                              //Assign the instance's owner as the entering unit.
                static if thistype.onCreate.exists then //If onCreate exists...
                    call onCreate()                     //Call it, because JassHelper should do this anyway.
                endif
            endif
    endmethod

    private static method onInit takes nothing returns nothing
        call AutoIndex.addAutoCreate(thistype.creator)
    endmethod //During module initialization, pass the creator function to AutoIndex.
endmodule

module AutoDestroy
    implement AutoData //AutoData is necessary for AutoDestroy.
    
    static method destroyer takes unit u returns nothing
        loop
            exitwhen thistype[u] == 0
            call thistype[u].destroy()
        endloop
    endmethod //Destroy each instance owned by the unit until none are left.

    private static method onInit takes nothing returns nothing
        call AutoIndex.addAutoDestroy(thistype.destroyer)
    endmethod //During module initialization, pass the destroyer function to AutoIndex.
endmodule

//===========================================================================
// AutoIndex struct:
//===================

function interface IndexFunc takes unit u returns nothing

hook RemoveUnit AutoIndex.hook_RemoveUnit
hook ReplaceUnitBJ AutoIndex.hook_ReplaceUnitBJ
debug hook SetUnitUserData AutoIndex.hook_SetUnitUserData

private keyword getIndex
private keyword getIndexDebug
private keyword isUnitIndexed
private keyword onUnitIndexed
private keyword onUnitDeindexed

struct AutoIndex
    private static trigger   enter      = CreateTrigger()
    private static trigger   order      = CreateTrigger()
    private static trigger   creepdeath = CreateTrigger()
    private static group     preplaced  = CreateGroup()
    private static timer     allowdecay = CreateTimer()
    private static hashtable ht

    private static boolean array dead
    private static boolean array summoned
    private static boolean array animated
    private static boolean array nodecay
    private static boolean array removing
    
    private static IndexFunc array indexfuncs
    private static integer indexfuncs_n = -1
    private static IndexFunc array deindexfuncs
    private static integer deindexfuncs_n = -1
    private static IndexFunc indexfunc
    
    private static AutoCreator array creators
    private static integer creators_n = -1
    private static AutoDestroyer array destroyers
    private static integer destroyers_n = -1
    
    private static unit array allowdecayunit
    private static integer allowdecay_n = -1
    
    private static boolean duringinit = true
    private static boolean array altered
    private static unit array idunit
    
    //===========================================================================

    static method getIndex takes unit u returns integer
        static if UseUnitUserData then
            return GetUnitUserData(u)
        else
            return LoadInteger(ht, 0, GetHandleId(u))
        endif
    endmethod //Resolves to an inlinable one-liner after the static if.
    
    static method getIndexDebug takes unit u returns integer
            if u == null then
                return 0
            elseif GetUnitTypeId(u) == 0 then
                call BJDebugMsg("AutoIndex error: Removed or decayed unit passed to GetUnitId.")
            elseif idunit[getIndex(u)] != u and GetIssuedOrderId() != 852056 then
                call BJDebugMsg("AutoIndex error: "+GetUnitName(u)+" is a filtered unit.")
            endif
        return getIndex(u)
    endmethod //If debug mode is enabled, use the getIndex method that shows errors.
    
    private static method setIndex takes unit u, integer index returns nothing
        static if UseUnitUserData then
            call SetUnitUserData(u, index)
        else
            call SaveInteger(ht, 0, GetHandleId(u), index)
        endif
    endmethod //Resolves to an inlinable one-liner after the static if.
    
    static method isUnitIndexed takes unit u returns boolean
        return u != null and idunit[getIndex(u)] == u
    endmethod
    
    static method isUnitAnimateDead takes unit u returns boolean
        return animated[getIndex(u)]
    endmethod //Don't use this; use IsUnitAnimateDead from AutoEvents instead.
    
    //===========================================================================
    
    private static method onUnitIndexed_sub takes nothing returns nothing
        call indexfunc.evaluate(GetEnumUnit())
    endmethod
    static method onUnitIndexed takes IndexFunc func returns nothing
        set indexfuncs_n = indexfuncs_n + 1
        set indexfuncs[indexfuncs_n] = func
        if duringinit then //During initialization, evaluate the indexfunc for every preplaced unit.
            set indexfunc = func
            call ForGroup(preplaced, function AutoIndex.onUnitIndexed_sub)
        endif
    endmethod
    
    static method onUnitDeindexed takes IndexFunc func returns nothing
        set deindexfuncs_n = deindexfuncs_n + 1
        set deindexfuncs[deindexfuncs_n] = func
    endmethod
    
    static method addAutoCreate takes AutoCreator func returns nothing
        set creators_n = creators_n + 1
        set creators[creators_n] = func
    endmethod
    
    static method addAutoDestroy takes AutoDestroyer func returns nothing
        set destroyers_n = destroyers_n + 1
        set destroyers[destroyers_n] = func
    endmethod
    
    //===========================================================================
    
    private static method hook_RemoveUnit takes unit whichUnit returns nothing
        set removing[getIndex(whichUnit)] = true
    endmethod //Intercepts whenever RemoveUnit is called and sets a flag.
    private static method hook_ReplaceUnitBJ takes unit whichUnit, integer newUnitId, integer unitStateMethod returns nothing
        set removing[getIndex(whichUnit)] = true
    endmethod //Intercepts whenever ReplaceUnitBJ is called and sets a flag.
    
    private static method hook_SetUnitUserData takes unit whichUnit, integer data returns nothing
        static if UseUnitUserData then
            if idunit[getIndex(whichUnit)] == whichUnit then
                if getIndex(whichUnit) == data then
                    call BJDebugMsg("AutoIndex error: Code outside AutoIndex attempted to alter "+GetUnitName(whichUnit)+"'s index.")
                else
                    call BJDebugMsg("AutoIndex error: Code outside AutoIndex altered "+GetUnitName(whichUnit)+"'s index.")
                    if idunit[data] != null then
                        call BJDebugMsg("AutoIndex error: "+GetUnitName(whichUnit)+" and "+GetUnitName(idunit[data])+" now have the same index.")
                    endif
                    set altered[data] = true
                endif
            endif
        endif //In debug mode, intercepts whenever SetUnitUserData is used on an indexed unit.
    endmethod //Displays an error message if outside code tries to alter a unit's index.
    
    //===========================================================================
    
    private static method allowDecay takes nothing returns nothing
        local integer n = allowdecay_n
            loop
                exitwhen n < 0
                set nodecay[getIndex(allowdecayunit[n])] = false
                set allowdecayunit[n] = null
                set n = n - 1
            endloop
            set allowdecay_n = -1
    endmethod //Iterate through all the units in the stack and allow them to decay again.
    
    private static method detectStatus takes nothing returns boolean
        local unit u = GetTriggerUnit()
        local integer index = getIndex(u)
        local integer n
            
            if idunit[index] == u then //Ignore non-indexed units.
                if not IsUnitType(u, UNIT_TYPE_DEAD) then
                
                    if dead[index] then         //The unit was dead, but now it's alive.
                        set dead[index] = false //The unit has been resurrected.
                        //! runtextmacro optional RunAutoEvent("Resurrect")
                        //If AutoEvents is in the map, run the resurrection events.
                        
                        if IsUnitType(u, UNIT_TYPE_SUMMONED) and not summoned[index] then
                            set summoned[index] = true //If the unit gained the summoned flag,
                            set animated[index] = true //it's been raised with Animate Dead.
                            //! runtextmacro optional RunAutoEvent("AnimateDead")
                            //If AutoEvents is in the map, run the Animate Dead events.
                        endif
                    endif
                else
                
                    if not removing[index] and not dead[index] and not animated[index] then
                        set dead[index] = true               //The unit was alive, but now it's dead.
                        set nodecay[index] = true            //A dead unit can't decay for at least 0. seconds.
                        set allowdecay_n = allowdecay_n + 1  //Add the unit to a stack. After the timer
                        set allowdecayunit[allowdecay_n] = u //expires, allow the unit to decay again.
                        call TimerStart(allowdecay, 0., false, function AutoIndex.allowDecay)
                        //! runtextmacro optional RunAutoEvent("Death")
                        //If AutoEvents is in the map, run the Death events.
                        
                    elseif removing[index] or (dead[index] and not nodecay[index]) or (not dead[index] and animated[index]) then
                        //If .nodecay was false and the unit is dead and was previously dead, the unit decayed.
                        //If .animated was true and the unit is dead, the unit died and exploded.
                        //If .removing was true, the unit is being removed or replaced.
                        set n = deindexfuncs_n
                        loop //Run the OnUnitDeindexed events.
                            exitwhen n < 0
                            call deindexfuncs[n].evaluate(u)
                            set n = n - 1
                        endloop
                        set n = destroyers_n
                        loop //Destroy AutoDestroy structs for the leaving unit.
                            exitwhen n < 0
                            call destroyers[n].evaluate(u)
                            set n = n - 1
                        endloop
                        call AutoIndex(index).destroy() //Free the index by destroying the AutoIndex struct.
                        set idunit[index] = null        //Null this unit reference to prevent a leak.
                    endif
                endif
            endif
        set u = null
        return false
    endmethod

    //===========================================================================
    
    private static method unitEntersMap takes unit u returns nothing
        local integer index
        local integer n = 0
            if getIndex(u) != 0 then
                return //Don't index a unit that already has an ID.
            endif
            static if LIBRARY_xebasic then
                if GetUnitTypeId(u) == XE_DUMMY_UNITID then
                    return //Don't index xe dummy units.
                endif
            endif
            if not UnitFilter(u) then
                return //Don't index units that fail the unit filter.
            endif
            set index = create()
            call setIndex(u, index) //Assign an index to the entering unit.
            
            call UnitAddAbility(u, LeaveDetectAbilityID)                 //Add the leave detect ability to the entering unit.
            call UnitMakeAbilityPermanent(u, true, LeaveDetectAbilityID) //Prevent it from disappearing on morph.
            set dead[index] = IsUnitType(u, UNIT_TYPE_DEAD)              //Reset all of the flags for the entering unit.
            set summoned[index] = IsUnitType(u, UNIT_TYPE_SUMMONED)      //Each of these flags are necessary to detect
            set animated[index] = false                                  //when a unit leaves the map.
            set nodecay[index] = false
            set removing[index] = false
            debug set altered[index] = false    //In debug mode, this flag tracks wheter a unit's index was altered.
            set idunit[index] = u               //Attach the unit that is supposed to have this index to the index.
            
            if duringinit then                  //If a unit enters the map during initialization...
                call GroupAddUnit(preplaced, u) //Add the unit to the preplaced units group. This ensures that
            endif                               //all units are noticed by OnUnitIndexed during initialization.
            loop //Create AutoCreate structs for the entering unit.
                exitwhen n > creators_n
                call creators[n].evaluate(u)
                set n = n + 1
            endloop
            set n = 0
            loop //Run the OnUnitIndexed events.
                exitwhen n > indexfuncs_n
                call indexfuncs[n].evaluate(u)
                set n = n + 1
            endloop
    endmethod
    
    private static method onIssuedOrder takes nothing returns boolean
            static if SafeMode then     //If SafeMode is enabled, perform this extra check.
                if getIndex(GetTriggerUnit()) == 0 then  //If the unit doesn't already have
                    call unitEntersMap(GetTriggerUnit()) //an index, then assign it one.
                endif
            endif
        return GetIssuedOrderId() == 852056 //If the order is Undefend, allow detectStatus to run.
    endmethod
    
    private static method initEnteringUnit takes nothing returns boolean
            call unitEntersMap(GetFilterUnit())
        return false
    endmethod
    
    //===========================================================================
    
    private static method afterInit takes nothing returns nothing
        set duringinit = false               //Initialization is over; set a flag.
        call DestroyTimer(GetExpiredTimer()) //Destroy the timer.
        call GroupClear(preplaced)           //The preplaced units group is
        call DestroyGroup(preplaced)         //no longer needed, so clean it.
        set preplaced = null
    endmethod
    
    private static method onInit takes nothing returns nothing
        local region maparea = CreateRegion()
        local rect bounds = GetWorldBounds()
        local group g = CreateGroup()
        local integer i = 15
            static if not UseUnitUserData then
                set ht = InitHashtable() //Only create a hashtable if it will be used.
            endif
            loop
                exitwhen i < 0
                call SetPlayerAbilityAvailable(Player(i), LeaveDetectAbilityID, false)
                //Make the LeaveDetect ability unavailable so that it doesn't show up on the command card of every unit.
                call TriggerRegisterPlayerUnitEvent(order, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
                //Register the "EVENT_PLAYER_UNIT_ISSUED_ORDER" event for each player.
                call GroupEnumUnitsOfPlayer(g, Player(i), function AutoIndex.initEnteringUnit)
                //Enum every non-filtered unit on the map during initialization and assign it a unique
                //index. By using GroupEnumUnitsOfPlayer, even units with Locust can be detected.
                set i = i - 1
            endloop
            call TriggerAddCondition(order, And(function AutoIndex.onIssuedOrder, function AutoIndex.detectStatus))
            //The detectStatus method will fire every time a non-filtered unit recieves an undefend order.
            //And() is used here to avoid using a trigger action, which starts a new thread and is slower.
            call TriggerRegisterPlayerUnitEvent(creepdeath, Player(12), EVENT_PLAYER_UNIT_DEATH, null)
            call TriggerAddCondition(creepdeath, function AutoIndex.detectStatus)
            //The detectStatus method must also fire when a neutral hostile creep dies, in case it was
            //sleeping. Sleeping creeps don't fire undefend orders on non-damaging deaths.
            call RegionAddRect(maparea, bounds) //GetWorldBounds() includes the shaded boundry areas.
            call TriggerRegisterEnterRegion(enter, maparea, function AutoIndex.initEnteringUnit)
            //The filter function of an EnterRegion trigger runs instantly when a unit is created.
            call TimerStart(CreateTimer(), 0., false, function AutoIndex.afterInit)
            //After any time elapses, perform after-initialization actions.
        call GroupClear(g)
        call DestroyGroup(g)
        call RemoveRect(bounds)
        set g = null
        set bounds = null
    endmethod
    
endstruct

//===========================================================================
// User functions:
//=================

function GetUnitId takes unit u returns integer
    static if DEBUG_MODE then             //If debug mode is enabled...
        return AutoIndex.getIndexDebug(u) //call the debug version of GetUnitId.
    else                                  //If debug mode is disabled...
        return AutoIndex.getIndex(u)      //call the normal, inlinable version.
    endif
endfunction

function IsUnitIndexed takes unit u returns boolean
    return AutoIndex.isUnitIndexed(u)
endfunction

function OnUnitIndexed takes IndexFunc func returns nothing
    call AutoIndex.onUnitIndexed(func)
endfunction

function OnUnitDeindexed takes IndexFunc func returns nothing
    call AutoIndex.onUnitDeindexed(func)
endfunction

endlibrary