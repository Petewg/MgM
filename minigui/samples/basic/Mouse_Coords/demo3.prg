/*
 * MiniGUI Window Demo
 * (c) 2007-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main
  
	SET CONTEXTMENU OFF  // Activate right mouse click event

	DEFINE WINDOW Form_1 ;
		AT 100,100 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON MOUSECLICK MsgInfo( IF(LeftMouseClick(), "Left", IF(RightMouseClick(), "Right", "Middle"))+ " mouse button is clicked!" )

		DEFINE CONTEXT MENU
			ITEM 'Item 1'       ACTION MsgInfo ('Item 1') 
			ITEM 'Item 2'       ACTION MsgInfo ('Item 2')
			SEPARATOR
			ITEM 'Item 3'       ACTION MsgInfo ('Item 3')
		END MENU

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
			DEFAULT .T.
		END BUTTON

	END WINDOW

	ACTIVATE WINDOW Form_1

Return


Function LeftMouseClick

Return ( _HMG_MouseState == 1 )


Function RightMouseClick

Return ( _HMG_MouseState == 2 )