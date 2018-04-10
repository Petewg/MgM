/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Procedure Main

	SET CENTURY ON

	SET DATE AMERICAN

//	SET DATE GERMAN

	SET FONT TO _GetSysFont() , 10

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 ;
		HEIGHT 400 ;
		TITLE 'Statusbar Demo' ;
		MAIN 

		DEFINE STATUSBAR

			STATUSITEM MiniGUIVersion() FONTCOLOR BLUE

//			KEYBOARD

			STATUSDATE FONTCOLOR BLUE

			IF "/" $ Set( 4 )

				CLOCK AMPM FONTCOLOR BLUE
			ELSE
				CLOCK FONTCOLOR BLUE
			ENDIF

		END STATUSBAR
 
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return
