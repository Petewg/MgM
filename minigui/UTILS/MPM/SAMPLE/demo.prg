/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

*Set Procedure To Other.Prg

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN 

	END WINDOW

	InOtherPrg()

	Form_1.Center

	Form_1.Activate

Return Nil

STATIC PROCEDURE TEST

RETURN