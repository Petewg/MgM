/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Memvar memvartestcode
Memvar memvartestfirst
Memvar memvartestlast
Memvar memvartestbirth

Function Main

	REQUEST DBFCDX , DBFFPT

	SET CENTURY ON
	SET DELETED ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Set Browse Value'	ACTION Form_1.Browse_1.Value := 50
				ITEM 'Get Browse Value'	ACTION MsgInfo ( Str ( Form_1.Browse_1.Value ) )
				ITEM 'Refresh Browse'	ACTION Form_1.Browse_1.Refresh
				SEPARATOR
				ITEM 'Exit'		ACTION Form_1.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready'
			STATUSITEM '<Enter> / Double Click To Edit' WIDTH 200
			STATUSITEM 'Alt+A: Append' WIDTH 120
		END STATUSBAR

		@ 10,10 BROWSE Browse_1									;
		WIDTH 610  										;
		HEIGHT 390 										;	
		HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
		WORKAREA Test ;
		FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		VALUE 1 ;
		EDIT /*INPLACE*/ APPEND DELETE ;
		VALID { { || MemVar.Test.Code <= 1000 } , { || !Empty(MemVar.Test.First) } , { || !Empty(MemVar.Test.Last) } , { || Year(MemVar.Test.Birth) >= 1900 } , , } ;
		VALIDMESSAGES { 'Code Range: 0-1000', 'First Name Cannot Be Empty', , , ,  } ;
		LOCK 

	END WINDOW

	CENTER WINDOW Form_1

	Form_1.Browse_1.SetFocus

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()
	Use Test Via "DBFCDX" Shared
Return

Procedure CloseTables()
	Use
Return
