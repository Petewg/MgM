/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	Set StationName To 'Roberto_Station'
	Set CommPath 	To 'C:\'

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Communications Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'SendData'		ACTION SendTest()
				ITEM 'Exit'		ACTION Form_0.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Communications Demo") 
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_0

	ACTIVATE WINDOW Form_0

Return Nil

Procedure SendTest
Local aData := {} , aMultiData := {}

	aAdd ( aData , 'Juan' 	 )
	aAdd ( aData , 'Carlos'  )
	aAdd ( aData , 'Roberto' )

	aAdd ( aMultiData , {'John','Smith','555-5555'} )
	aAdd ( aMultiData , {'Peter','Gomez','543-8372'} )
	aAdd ( aMultiData , {'Albert','Anderson','854-8273'} )

	SendData ( 'John_Station' , 100 )

	SendData ( 'John_Station' , Date() )

	SendData ( 'John_Station' , Time() )

	SendData ( 'John_Station' , .t. )

	SendData ( 'John_Station' , aData )

	SendData ( 'John_Station' , aMultiData )

Return
