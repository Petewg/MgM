/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "hmg.ch" 

Function Main() 
	LOCAL nTra := 128

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 300 ;
		HEIGHT 300 ;
		TITLE 'Transparent window' ;
		MAIN ;
		NOSIZE NOMAXIMIZE ;
		ON INIT ( SET WINDOW Win_1 TRANSPARENT TO nTra )

		@ 200,100 BUTTON But1 ;
			CAPTION "Click Me" ;
			HEIGHT 35 WIDTH 100 ;
			ACTION ( nTra := iif(nTra == 128, 255, 128), SET WINDOW Win_1 TRANSPARENT TO nTra )

	END WINDOW

	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

RETURN NIL
