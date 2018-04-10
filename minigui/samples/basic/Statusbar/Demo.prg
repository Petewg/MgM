/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	SET DEFAULT ICON TO GetStartupFolder() + "\new.ico"
	SET CENTERWINDOW RELATIVE PARENT

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 400 ;
		TITLE 'MiniGUI StatusBar Demo (Based Upon a Contribution Of Janusz Pora)' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE MAIN MENU 
			POPUP '&StatusBar Test'
				ITEM 'Set StatusBar Item 1'	ACTION Form_1.StatusBar.Item(1) := "New value 1"
				ITEM 'Set StatusBar Item 2'	ACTION Form_1.StatusBar.Item(2) := "New value 2"
				ITEM 'Set StatusBar Item Icon' ;
					ACTION ( Form_1.StatusBar.Icon (3) := 'New.ico', Form_1.StatusBar.Item(3) := "A Smile!" )
				ITEM 'Open Other Window...'	ACTION Modal_Click()
                        END POPUP
			POPUP '&Help'
				ITEM '&About'			ACTION MsgInfo ("MiniGUI StatusBar Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8
			STATUSITEM "Item 1" 	ACTION MsgInfo('Click! 1')
			STATUSITEM "Item 2" 	WIDTH 100 ACTION MsgInfo('Click! 2') 
			STATUSITEM 'A Car!'	WIDTH 100 ICON 'Car.Ico'
			CLOCK 
			DATE 
		END STATUSBAR

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Procedure Modal_Click
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 ;
		TITLE 'StatusBar Test' ;
		MODAL NOSIZE

		DEFINE STATUSBAR 

			STATUSITEM "Modal 1" 	WIDTH 100 ACTION MsgInfo('Click! 1') 
			STATUSITEM "Modal 2" 	WIDTH 100 ACTION MsgInfo('Click! 2')

		END STATUSBAR

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

Return
