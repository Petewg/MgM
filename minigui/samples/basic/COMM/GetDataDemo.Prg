/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	Set StationName	To 'John_Station'
	Set CommPath	To 'C:\'

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Communications Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'GetData'		ACTION GetTest()
				ITEM 'Exit'		ACTION Form_0.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Communications Demo") 
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_0

	ACTIVATE WINDOW Form_0

Return Nil

Procedure GetTest()
Local r , i

	Repeat

		r := GetData()

		If Valtype (r) == 'A'

			If Valtype ( r [1] ) != 'A'

				Aeval ( r, { |i| MsgInfo( i ) } )

			Else

				For Each i In r

					Aeval ( i, { |j| MsgInfo( j ) } )

				Next

			EndIf

		ElseIf r # Nil

			MsgInfo( r )

		EndIf

	Until r # Nil

Return
