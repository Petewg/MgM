/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )

Memvar Test

Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Hello World!' ;
		MAIN 

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'HTTP GET' ACTION TestHttp()
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Procedure TestHttp()
Local Response
Private Test

	OPEN CONNECTION Test SERVER 'www.hmgextended.com' PORT 80 HTTP

	GET URL '/' TO Response CONNECTION Test 

	CLOSE CONNECTION Test 

	MsgInfo (Response)

Return
