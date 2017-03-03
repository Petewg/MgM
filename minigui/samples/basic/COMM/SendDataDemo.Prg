/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	Set StationName To 'Roberto_Station'
	Set CommPath 	To hb_DirTemp()

	DEFINE WINDOW Form_0 ;
		AT 0, 0 ;
		WIDTH 360 HEIGHT 480 ;
		TITLE 'MiniGUI Communications Demo  - SEND DATA STATION' ;
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
		
		DEFINE BUTTON Button_1
			COL 50
			ROW 200
			WIDTH 250
			HEIGHT 40
			CAPTION ">>> Send Data >>>"
			ACTION SendTest()
			FONTNAME "COURIER NEW"
			FONTSIZE 14
			FONTBOLD .T.
			FONTITALIC .F.
			FONTUNDERLINE .F.
			FONTSTRIKEOUT .F.
			FONTCOLOR {000,000,255}
			ONGOTFOCUS NIL
			ONLOSTFOCUS NIL
			HELPID NIL
			FLAT .T.
			NOTABSTOP .F.
			TRANSPARENT .T.
		END BUTTON

	END WINDOW

	// CENTER WINDOW Form_0

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

	SendData ( 'John_Station' , "# Start of transmission #" + hb_EoL() )
	
	SendData ( 'John_Station' , 100 )

	SendData ( 'John_Station' , Date() )

	SendData ( 'John_Station' , Time() )

	SendData ( 'John_Station' , .t. )

	SendData ( 'John_Station' , aData )

	SendData ( 'John_Station' , aMultiData )
	
	SendData ( 'John_Station' , "# End of transmission #" + hb_EoL() )

Return
