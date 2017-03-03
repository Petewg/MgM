/*
 * MiniGUI Hello World Demo
 * (c) 2002-2004 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Hello World!' ;
		MAIN

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			CAPTION 'Action 1'
			ACTION MsgBox(This.Title,'Message')
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			CAPTION 'Change Action 1'
			ACTION ( Form_1.Button_1.Action := {|| MsgBox(GetProperty('Form_1','Title'),'New title')}, ;
				Form_1.Button_1.Action )
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	70
			COL	10
			CAPTION 'New Timer Action'
			ACTION Form_1.Timer_1.Action := {|| SetProperty('Form_1','Label_2','Value', Str(Memory(0)/1024) + ' MB')}
		END BUTTON

		DEFINE BUTTON Button_4
			ROW	100
			COL	10
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

		@ 15,150 LABEL Label_1 ;
			VALUE 'Timer Test:' 

		@ 15,220 LABEL Label_2 TRANSPARENT

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION Form_1.Label_2.Value := Time() 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return
