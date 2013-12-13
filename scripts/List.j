library List/* by Xanria
********************************************************************************
*     Library Instruction
*
*******************************************************************************/

    /***************************************************************************
    * Modules
    ***************************************************************************/
    // Data Structure
    // Dual Linked List
    module DualLinkedList
        thistype next_p
        thistype previous_p
        player get_p
        boolean end_p
        static integer count_p = 0
        
        public method operator next takes nothing returns thistype
            return next_p
        endmethod
        public method operator previous takes nothing returns thistype
            return previous_p
        endmethod
        public method operator get takes nothing returns player
            return get_p
        endmethod
        public method operator end takes nothing returns boolean
            return end_p
        endmethod
        public static method operator count takes nothing returns integer
            return count_p
        endmethod
        public static method operator last takes nothing returns integer
            return thistype[16].previous
        endmethod
        public static method operator first takes nothing returns integer
            return thistype[16].next
        endmethod
    endmodule

endlibrary    
    
