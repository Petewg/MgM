/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

DECLARE WINDOW Win_2
DECLARE WINDOW Win_3

FUNCTION Main

	LOCAL i, cForm

	DEFINE WINDOW Win_1 ;
		TITLE 'Hello World!' ;
		/*WINDOWTYPE*/ MAIN ;
		ON INIT ( Win_2.Show, Win_3.Show )

	END WINDOW

	DEFINE WINDOW Win_2 ;
		TITLE 'Child Window' ;
		/*WINDOWTYPE*/ CHILD

	END WINDOW

	DEFINE WINDOW Win_3 ;
		TITLE 'Modal Window' ;
		/*WINDOWTYPE*/ MODAL

	END WINDOW

	FOR i := 1 TO 3
		cForm := "Win_" + Str( i, 1 )
		_DefineHotKey( cForm, 0, VK_ESCAPE, hb_MacroBlock( "_ReleaseWindow('" + cForm + "')" ) )
	NEXT

	Win_2.Center
	Win_3.Center

	ACTIVATE WINDOW ALL

RETURN NIL
