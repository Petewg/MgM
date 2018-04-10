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
				MENUITEM "Play File" ACTION Test()
			END POPUP 			

		END MENU

		DEFINE ACTIVEX Test
			ROW 10
			COL 50
			WIDTH 700  
			HEIGHT 400  
			PROGID "WMPlayer.OCX.7"  
		END ACTIVEX

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1

Return

Procedure Test()

	Win1.Test.XObject:url := "c:\\minigui\\samples\\basic\\resourcedemo\\sample.wav"

Return

