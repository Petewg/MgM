/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * GETBOX Valid in Tab demo
 * (C) 2007 Jack Daniels <jd10jd10@yahoo.com>
*/

#include "minigui.ch"

*----------------------
function main
*----------------------

set navigation extended

define window form_1 ;
	at 0,0 width 500 height 350 ;
	title "Getbox Valid demo 2 by Jack Daniels" ;
	main ;
	on interactiveclose CheckValids(1)

	define tab tab_1 at 10,10 width 400 height 250 on change {|page| CheckValids(page)}
		page "First Tab"
			// GetBox_1 with wrong initial value
			@  50,40 getbox getbox_1 value 60
		end page
		page "Second Tab"
			// TextBox_1 with wrong initial value
			@  50,40 textbox textbox_1 value space(10)
			@ 100,40 textbox textbox_2 on gotfocus CheckValids(2)
			@ 150,40 textbox textbox_3 on gotfocus CheckValids(2)
		end page
	end tab

	define statusbar keyboard
	end statusbar

end window

form_1.center
form_1.activate

return Nil

*----------------------
function CheckValids( page )
*----------------------
local retval := .T.

switch page
	case 1
		if form_1.getbox_1.value < 101
			form_1.statusbar.item(1) := "GetBox 1 value must be > 100"
			form_1.getbox_1.setfocus
			retval := .F.
		endif
		exit
	case 2
		if empty(form_1.textbox_1.value)
			form_1.statusbar.item(1) := "TextBox 1 value is wrong"
			form_1.textbox_1.setfocus
			retval := .F.
		endif
endswitch

if retval
	form_1.statusbar.item(1) := form_1.title
endif

return retval
