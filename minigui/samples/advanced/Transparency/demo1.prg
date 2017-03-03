/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "hmg.ch"

PROCEDURE Main

DEFINE WINDOW Form_1 ; 
	AT 0, 0 ; 
	WIDTH 450 ; 
	HEIGHT 350 ; 
	TITLE 'Transparency Color Sample' ; 
	MAIN 

	DEFINE LISTBOX ListBox_1 
		ROW 0 
		COL 1 
		WIDTH 440 
		HEIGHT 160 
		ITEMS { ' - 01 -' , ' - 02 -' , ' - 03 -' } 
		BACKCOLOR BLACK
		FONTCOLOR GREEN
		FONTBOLD .T. 
		VALUE 2 
	END LISTBOX 

	DEFINE BUTTONEX Button_1 
		ROW 220 
		COL 170 
		WIDTH 250 
		HEIGHT 28 
		CAPTION "Set Black Color Transparency ON" 
		ACTION SetColorTransparency( BLACK )
		FONTCOLOR BLUE
		FLAT .T. 
	END BUTTONEX

	DEFINE BUTTONEX Button_2 
		ROW 260 
		COL 170 
		WIDTH 250 
		HEIGHT 28 
		CAPTION "Set Black Color Transparency OFF" 
		ACTION SetTransparencyOff() 
		FONTCOLOR BLUE
		FLAT .T. 
	END BUTTONEX

END WINDOW 

CENTER WINDOW Form_1 
ACTIVATE WINDOW Form_1 

RETURN

/* 
*/ 
PROCEDURE SetTransparencyOff() 

	SET WINDOW Form_1 TRANSPARENT TO OPAQUE

RETURN

/* 
*/ 
PROCEDURE SetColorTransparency( aColor ) 

	SET WINDOW Form_1 TRANSPARENT TO COLOR aColor

RETURN
