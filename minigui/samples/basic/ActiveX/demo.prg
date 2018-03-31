/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Activex Sample: Inspired by Freewin Activex inplementation by 
 * Oscar Joel Lira Lira http://sourceforge.net/projects/freewin
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 800 ;
		HEIGHT 500 ;
		TITLE 'ActiveX Component Demo' ;
		MAIN ;
		ON MAXIMIZE ( Win1.Test.Width := (Win1.Width) - 100, Win1.Test.Height := (Win1.Height) - 100 ) ;
		ON SIZE ( Win1.Test.Width := (Win1.Width) - 100, Win1.Test.Height := (Win1.Height) - 100 ) ;
		ON RELEASE Win1.Test.Release

		DEFINE MAIN MENU

			POPUP "Test"
				MENUITEM "Navigate" ACTION TestNavigate()
			END POPUP 			

		END MENU

		@ 10 , 50 ACTIVEX Test ;
			WIDTH 700  ;
			HEIGHT 400  ;
			PROGID "shell.explorer.2"
/* OR
		DEFINE ACTIVEX Test
			ROW 10
			COL 50
			WIDTH 700  
			HEIGHT 400  
			PROGID "shell.explorer.2"  
		END ACTIVEX
*/
	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1

Return

*------------------------------------------------------------------------------*
Procedure TestNavigate()
*------------------------------------------------------------------------------*
Local oObject
Local cAddress

	cAddress := InputBox ('Navigate:','Enter Address','http://hmgextended.com')

	If .Not. Empty (cAddress)

		oObject := Win1.Test.XObject
		oObject:Navigate(cAddress)

		* Look for following alternatives

//		oObject := GetProperty('Win1','Test','XObject')
//		oObject:Navigate(cAddress)
// OR
//		Win1.Test.XObject:Navigate(cAddress)
// OR
//		GetProperty('Win1','Test','XObject'):Navigate(cAddress)

	EndIf

Return

