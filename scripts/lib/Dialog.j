library Dialog/* v.1.0.0.0
**************************************************
*
*   A struct wrapper for easy dialog creation.
*
**************************************************
*
*/  requires Alloc,        /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/           Table,        /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/[/url]
*/           ErrorMessage  /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
* 
**************************************************
*
*   struct Dialog 
*
*       static method create() returns thistype
*           
*           Creates a new dialog and returns its instance.
*
*       method operator title= takes string s
*
*           Sets the title message for the dialog.
*
*       method addButton( string text, integer hotkey ) returns button
*
*           Adds a button to the dialog that reads <text>.
*           The hotkey serves as a shortcut to press a dialog 
*           button. Example input: 'a', 'b', 512 (esc).
*
*       method display( player p, boolean flag )
*           
*           Shows/hides a dialog for a particular player. 
*
*       method displayAll( boolean flag )
*
*           Shows/hides a dialog for all players. 
*
*       method clear()
*   
*           Clears a dialog of its message and buttons.
*
*       method destroy()
*
*           Destroys a dialog and its instance.
*
*   -- Event API --
*
*       method registerClickEvent( boolexpr b )
*
*           Registers when a dialog button is clicked.
*
*       static method getClickedDialog() returns Dialog
*       static method getClickedButton() returns button
*       static method getPlayer() returns player
*
*            Event responses.
*
**************************************************/

	globals
		private Table instance = 0
	endglobals
	
	private module DialogInit
		private static method onInit takes nothing returns nothing
			set instance = Table.create()
		endmethod
	endmodule
	
	struct Dialog extends array
		implement Alloc
		implement DialogInit
		
		private dialog dlg
		private trigger click
		
		// static method
		static method getClickedDialog takes nothing returns thistype
			return instance[GetHandleId(GetClickedDialog())]
		endmethod
		
		static method getClickedButton takes nothing returns button
			return GetClickedButton()
		endmethod
	
		static method getPlayer takes nothing returns player
			return GetTriggerPlayer()
		endmethod
		
		// instance method
		method operator title= takes string text returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "title=", "Dialog", this, "Attempted to set title of null dialog.")
			call DialogSetMessage(this.dlg, text)
		endmethod
		
		method addButton takes string text, integer hotkey returns button
			debug call ThrowError(this.dlg==null, "Dialog", "addButton", "Dialog", this, "Attempted to add button to null dialog.")
			return DialogAddButton(this.dlg, text, hotkey)
		endmethod
		
		method display takes player p, boolean flag returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "display", "Dialog", this, "Attempted to display null dialog.")
			call DialogDisplay(p, this.dlg, flag)
		endmethod
		
		method displayAll takes boolean flag returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "display", "Dialog", this, "Attempted to display null dialog.")
			call DialogDisplay(GetLocalPlayer(), this.dlg, flag)
		endmethod
		
		method clear takes nothing returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "clear", "Dialog", this, "Attempted to clear null dialog.")
			call DialogClear(this.dlg)
		endmethod
		
		method registerClickEvent takes boolexpr b returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "registerClickEvent", "Dialog", this, "Attempted to register click event for null dialog.")
            debug call ThrowError(b==null, "Dialog", "registerClickEvent", "Dialog", this, "Attempted to register click event to null boolexpr.")
			
            if this.click == null then
            	set instance[GetHandleId(this.dlg)] = this
            	set this.click = CreateTrigger()
            	call TriggerRegisterDialogEvent(this.click, this.dlg)
            endif
            call TriggerAddCondition(this.click, b)
		endmethod
		
		method destroy takes nothing returns nothing
			debug call ThrowError(this.dlg==null, "Dialog", "destroy", "Dialog", this, "Attempted to destroy null dialog.")
			
			if this.click != null then
				call DestroyTrigger(this.click)
				call instance.remove(GetHandleId(this.dlg))
				set .click = null
			endif
			
			call DialogClear(this.dlg)
			call DialogDestroy(this.dlg)
			set this.dlg = null
			call this.deallocate()
		endmethod
		
		static method create takes nothing returns thistype
			local thistype this = thistype.allocate()
			set this.dlg = DialogCreate()
			return this
		endmethod
		
	endstruct
endlibrary