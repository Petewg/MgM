/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

* Value property selects a record by its number (RecNo())
* Value property returns selected record number (recNo())
* Browse control does not change the active work area
* Browse control does not change the record pointer in any area
* (nor change selection when it changes)
* You can programatically refresh it using refresh method.
* Variables called <MemVar>.<WorkAreaName>.<FieldName> are created for
* validation in browse editing window. You can use it in VALID array.
* Using APPEND clause you can add records to table associated with WORKAREA
* clause. The hotkey to add records is Alt+A.
* Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea
* Using DELETE clause allows to mark selected record for deletion pressing <Del> key

* Enjoy !

#include "minigui.ch"

Function Main
	Local bColor := { || if ( recno()/2 == int(recno()/2) , { 255,255,255 } , { 240,240,240 } ) }	

	SET CENTURY ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo ' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Set Browse Value'	ACTION Form_1.Browse_1.Value := 500
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
			STATUSITEM 'Edit Record, Change "TYPE" and Bitmap will be Updated'
		END STATUSBAR

		@ 10,10 BROWSE Browse_1									;
		WIDTH 610  										;
		HEIGHT 390 										;
                HEADERS { 'Type', 'First Name' , 'Last Name', 'Birth Date',  'Biography' } ;
		WIDTHS { 22, 150 , 150 , 150 , 116 } ;
		WORKAREA Test ;
		FIELDS { 'Test->Types' , 'Test->First' , 'Test->Last' , 'Test->Birth' ,  'Test->Bio' } ;
		VALUE 1 ;
		DYNAMICBACKCOLOR { , bColor, bColor, bColor, bColor } ;
		FONT "MS Sans Serif" SIZE 9;
		EDIT ;
		NOLINES ;
		IMAGE {"br0","br1","br2","br3","br4","br5","br6","br7","br8","br9"};
		JUSTIFY { ,, BROWSE_JTFY_CENTER, } // BROWSE_JTFY_LEFT por defecto, no es necesario escribirlo

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()
/*
	Use test
	zap

	For i:= 1 To 500000
		append blank
		Replace code with i
		Replace First With 'First Name '+ Str(i)
		Replace Last With 'Last Name '+ Str(i)
		Replace Married With .t.
		replace birth with date()+i-10000
	Next i

	Index On Code To Code
	Use

*/
	Use test New

	Form_1.Title := Form_1.Title + '(' + Ltrim(Str(Test->(LastRec()))) + ' Records)'

Return

Procedure CloseTables()
	Use
Return

