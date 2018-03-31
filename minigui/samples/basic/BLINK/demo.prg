/*
 * MiniGUI Blinking Label Demo
 *
 */

#include "minigui.ch"

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Hello World!' ;
		MAIN

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			CAPTION 'Blink ON'
			ACTION ( Form_1.Label_1.Blink := .T., Form_1.Label_2.Value := "ON" )
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			CAPTION 'Blink OFF'
			ACTION ( Form_1.Label_1.Blink := .F., Form_1.Label_2.Value := "OFF" )
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	70
			COL	10
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

		@ 15,150 LABEL Label_1 ;
			VALUE 'Blink Test:' AUTOSIZE ;
			ACTION ( This.Blink := .T., Form_1.Label_2.Value := "ON" )

		@ 15,220 LABEL Label_2 ;
			VALUE Space(6) AUTOSIZE ;
			TRANSPARENT ;
			ACTION Form_1.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN
