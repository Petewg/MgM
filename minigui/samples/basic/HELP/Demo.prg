/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "MGHelp.h"

Function Main()

	SET DATE GERMAN

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 400 ;
		TITLE 'MiniGUI Help Demo' ;
		ICON 'demo.ico' ;
		MAIN ;
		FONT 'MS Sans Serif' SIZE 10 ;
		HELPBUTTON

		SET HELPFILE TO 'MGHelp.hlp' 

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM 'Open' ACTION MsgInfo('Open Click!')
				SEPARATOR
				ITEM 'Exit' ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&Help '		ACTION DISPLAY HELP MAIN 
				ITEM '&Context'		ACTION DISPLAY HELP CONTEXT IDH_0001
				ITEM '&PopUp Help'	ACTION DISPLAY HELP POPUP IDH_0002
				SEPARATOR
				ITEM '&About'		ACTION MsgInfo ( MiniGUIVersion(), "About" )
			END POPUP
		END MENU

		DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
			STATUSITEM "F1 - Help" WIDTH 100
			CLOCK 
			DATE 
		END STATUSBAR

	        @ 100,120 LABEL Label VALUE "Press F1..."

		@ 150,100 BUTTON Button_1 ;
		CAPTION 'Button_1' ;
		ACTION MsgInfo('Click Button_1!') ;
		HELPID IDH_0002

		@ 200,100 BUTTON Button_2 ;
		CAPTION 'Button_2' ;
		ACTION MsgInfo('Click Button_2!') ;
		HELPID IDH_0003

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
