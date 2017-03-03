/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2005 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

Function Main

 	DEFINE WINDOW Form_1 ;
		AT 0,0 WIDTH 348 HEIGHT 176 ;
		TITLE "3-State Checkbox HMG Demo" ;
		MAIN

		ON KEY ALT+X  action ThisWindow.Release
		ON KEY ESCAPE action ThisWindow.Release

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!'
		END STATUSBAR
		DEFINE MAIN MENU 
			POPUP '&CheckBox'
				ITEM 'Set 3-State CheckBox on CHECKED'		ACTION SetCheck(1)
				ITEM 'Set 3-State CheckBox on UNCHECKED'	ACTION SetCheck(0)
				ITEM 'Set 3-State CheckBox on INDETERMINAT'	ACTION SetCheck(2)
			    	SEPARATOR	
				ITEM '&Exit'		ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo ("MiniGUI 3-State Checkbox Demo") 
			END POPUP
		END MENU


		@ 23,34 CHECKBOX CheckBox_1 CAPTION  "CheckBox_1" WIDTH 100 HEIGHT 28
		@ 23,203 CHECKBOX CheckBox_2 CAPTION "3-StateBox" WIDTH 100 HEIGHT 28 THREESTATE

		// altsyntax test
		DEFINE CHECKBOX Check_1a
			ROW	50
			COL	34
			CAPTION 'Check 1a' 
			VALUE .T. 
			TOOLTIP 'CheckBox' 
			ONCHANGE PLAYOK()
 		END CHECKBOX

		DEFINE CHECKBOX Check_1b
			ROW	50
			COL	203
			CAPTION 'Check 3-State ' 
			VALUE .T. 
			TOOLTIP '3-State CheckBox' 
			ONCHANGE ChangeInfo()
			THREESTATE .T.
		END CHECKBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Function SetCheck(typ)
    do case
    case typ == 0
        Form_1.CheckBox_2.Value := .F.
    case typ == 1
        Form_1.CheckBox_2.Value := .T.
    otherwise
        Form_1.CheckBox_2.Value := NIL
    endcase

Return Nil

Function ChangeInfo()
    Local ret
    ret:=Form_1.Check_1b.Value
    if valtype(ret) == 'U'
        MsgInfo('CheckBox is INDETERMINAT')
    elseif ret == .t.
        MsgInfo('CheckBox is CHECKED')
    else
        MsgInfo('CheckBox is UNCHECKED')
    endif

Return Nil
