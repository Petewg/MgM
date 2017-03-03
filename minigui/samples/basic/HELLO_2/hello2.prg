/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

DECLARE WINDOW Win_2

Function Main

	DEFINE WINDOW Win_1 ;
		TITLE 'Hello World!' ;
		/*WINDOWTYPE*/ MAIN ;
		ON GOTFOCUS iif( IsWindowDefined( Win_2 ), Win_2.Setfocus(), NIL )

	END WINDOW

	DEFINE WINDOW Win_2 ;
		TITLE 'Child Window' ;
		/*WINDOWTYPE*/ CHILD

	END WINDOW

	DEFINE WINDOW Win_3 ;
		TITLE 'Modal Window' ;
		/*WINDOWTYPE*/ MODAL

	END WINDOW

	Win_2.Center
	Win_3.Center

	ACTIVATE WINDOW Win_3, Win_2, Win_1

Return Nil
