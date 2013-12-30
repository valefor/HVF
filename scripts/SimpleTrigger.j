library SimpleTrigger /* v0.0.1 Xandria
*/  uses      Alloc,        /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/           ErrorMessage  /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*************************************************************************************
*     SimpleTrigger : A Simple Trigger wrapper
*
*************************************************************************************
*************************************************************************************/
    globals
        private hashtable ht
    endglobals
    
    struct SimpleTrigger extends array
        implement Alloc    
        
        trigger trig
        private triggeraction ta
        private integer data
    
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            set this.trig = CreateTrigger()
            set this.ta = null
            set this.data = 0
            // before return, bind this customzied 'SimpleTrigger' to real w3c trigger
            call bind()
            return this
        endmethod
        
        static method get takes trigger t returns SimpleTrigger
            return LoadInteger(ht,0,GetHandleId(t) )
        endmethod
        
        private static method onInit takes nothing returns nothing
            set ht = InitHashtable()
        endmethod
        
        private method bind takes nothing returns nothing
            call SaveInteger(ht,0,GetHandleId(this.trig), this)
        endmethod
        
        method setData takes integer data returns nothing
            set this.data = data
        endmethod
        
        method getData takes nothing returns integer
            return .data
        endmethod
        
        method destroy takes nothing returns nothing
            if ta != null then
                call TriggerRemoveAction(this.trig, this.ta)
                set .ta = null
            endif
            call DestroyTrigger(.trig)
            set this.trig = null
            call this.deallocate()
        endmethod
        
        method addAction takes code func returns nothing
            set ta = TriggerAddAction(this.trig, func)
        endmethod
        
        method addCondition takes boolexpr condition returns nothing
            call TriggerAddCondition(this.trig, condition)
        endmethod
        
        method execute takes nothing returns nothing
            call TriggerExecute(this.trig)
        endmethod
    endstruct
    
endlibrary
