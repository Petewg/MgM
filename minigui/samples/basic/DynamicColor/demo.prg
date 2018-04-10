/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

* Enjoy !

#include "minigui.ch"

Memvar MEMVARTESTCODE
Memvar MEMVARTESTFIRST
Memvar MEMVARTESTLAST
Memvar MEMVARTESTBIRTH
 
Function Main
Local b1, b2, b3, b4, b5, b6, bk1, bk2, bk3, bk4, bk5, bk6

	SET CENTURY ON

	b1 := { || RGB(255,255,255) }
	b2 := { || RGB(255,255,0) }
	b3 := { || RGB(20,26,158) }
	b4 := { || RGB(12,15,46) }
	b5 := { || RGB(120,0,128) }
	b6 := { || RGB(255,255,255) }
	bk1 := { || RGB(240,55,23) }
	bk2 := { || RGB(0,0,0) }
	bk3 := { || RGB(200,200,10) }
	bk4 := { || RGB(200,200,200) }
	bk5 := { || RGB(20,200,200) }
	bk6 := { || RGB(0,0,150) }
	
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
				ITEM 'Get Browse Value'	ACTION MsgInfo ( Str (  Form_1.Browse_1.Value ) )
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

		@ 6,10 BROWSE Browse_1									;
		WIDTH 610  										;
		HEIGHT 394 										;	
		HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		WIDTHS { 150 , 150 , 150 , 100 , 150 , 150 } ;
		WORKAREA Test ;
		FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		VALUE 1 ;
		DYNAMICFORECOLOR { b1, b2, b3, b4, b5, b6 } ;
		DYNAMICBACKCOLOR { bk1, bk2, bk3, bk4, bk5, bk6 } ;
		EDIT APPEND ;
		VALID { { || MemVar.Test.Code <= 1000 } , { || !Empty(MemVar.Test.First) } , { || !Empty(MemVar.Test.Last) } , { || Year(MemVar.Test.Birth) >= 1900 } , , } ;
		VALIDMESSAGES { 'Code Range: 0-1000', 'First Name Cannot Be Empty', , , ,  } ;
		JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER } ;
		READONLY { .T. , .F. , .F. , .F. , .F. , .T. } ;
		LOCK

	END WINDOW

	CENTER WINDOW Form_1

	Form_1.Browse_1.SetFocus

	ACTIVATE WINDOW Form_1

Return Nil


Procedure OpenTables()

	Use Test New Shared

	Form_1.Browse_1.DisableUpdate
	Form_1.Browse_1.ColumnsAutoFitH
	Form_1.Browse_1.EnableUpdate

Return


Procedure CloseTables()

	Close Test

Return
