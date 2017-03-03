/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * ListView SORT ORDER COLUMN 
 * Author: BADIK <badik@mail.ru>
*/

#include "minigui.ch"
#include "Dbstruct.ch"

Function Main
LOCAL aDbfStruct, i, nColumn := 0, aColumns := {}

	SET CENTURY ON
	SET DELETED ON

	SET BROWSESYNC ON	

	OpenTables()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Set Browse Value'	ACTION Form_1.Browse_1.Value := Val ( InputBox ('Set Browse Value','') )
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
			STATUSITEM ''
		END STATUSBAR

		@ 10,10 BROWSE Browse_1									;
			WIDTH 610  										;
			HEIGHT 390 										;	
			HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
			WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
			WORKAREA Test ;
			FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
			TOOLTIP 'Browse Test' ;
			ON CHANGE ChangeTest() ;
			JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
			DELETE ;
			LOCK ;
			EDIT APPEND

	END WINDOW

	aDbfStruct := test->( dbStruct() )

	IF !FILE('test.ini')
		BEGIN INI FILE 'test.ini'

		for i = 1 to Len(aDbfStruct)
			SET SECTION "Columns" ENTRY Alltrim ( Str ( i ) ) TO i
		next

		END INI
	ENDIF

	BEGIN INI FILE 'test.ini'

		for i = 1 to Len(aDbfStruct)
			GET nColumn SECTION "Columns" ENTRY Alltrim ( Str ( i ) ) DEFAULT i
			AAdd( aColumns, nColumn )
		next

	END INI

	_SetColumnOrderArray( "Browse_1", "Form_1", aColumns )

	Form_1.Browse_1.SetFocus

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()

	if !file("test.dbf")
		CreateTable()
	endif

	Use Test
	Set Index To Code
	Go Top

Return

Procedure CloseTables()
LOCAL aColumns :=_GetColumnOrderArray( "Browse_1", "Form_1" ), i

	BEGIN INI FILE 'test.ini'
		for i := 1 to Len(aColumns)
			SET SECTION "Columns" ENTRY Alltrim ( Str ( i ) ) TO aColumns[i]
		next
	END INI

	Use

Return

Procedure ChangeTest()
	Form_1.StatusBar.Item(1) := 'RecNo: ' + Alltrim ( Str ( RecNo ( ) ) )
Return 

Procedure CreateTable
LOCAL aDbf[6][4], i

        aDbf[1][ DBS_NAME ] := "Code"
        aDbf[1][ DBS_TYPE ] := "Numeric"
        aDbf[1][ DBS_LEN ]  := 10
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "First"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 25
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Last"
        aDbf[3][ DBS_TYPE ] := "Character"
        aDbf[3][ DBS_LEN ]  := 25
        aDbf[3][ DBS_DEC ]  := 0
        //
        aDbf[4][ DBS_NAME ] := "Married"
        aDbf[4][ DBS_TYPE ] := "Logical"
        aDbf[4][ DBS_LEN ]  := 1
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "Birth"
        aDbf[5][ DBS_TYPE ] := "Date"
        aDbf[5][ DBS_LEN ]  := 8
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Bio"
        aDbf[6][ DBS_TYPE ] := "Memo"
        aDbf[6][ DBS_LEN ]  := 10
        aDbf[6][ DBS_DEC ]  := 0
        //

        dbCreate("Test", aDbf)

	Use test

	For i:=1 To 200
		append blank
		Replace code with i 
		Replace First With 'First Name '+ Str(i)
		Replace Last With 'Last Name '+ Str(i)
		Replace Married With .t.
		replace birth with Date()+i-10000
	Next i

	Index On Field->Code To Code
	Use

Return

*--------------------------------------------------------------------
Function _GetColumnOrderArray( ControlName , ParentForm )
*--------------------------------------------------------------------
Local i, nColumn, aSort
	i := GetControlIndex( ControlName , ParentForm )
	nColumn := Len(_HMG_aControlCaption [i])
	aSort := Array(nColumn)
	ListView_GetColumnOrderArray( _HMG_aControlHandles [i], nColumn, @aSort )
Return aSort

*--------------------------------------------------------------------
Function _SetColumnOrderArray( ControlName , ParentForm, aSort )
*--------------------------------------------------------------------
Local i, nColumn
	i := GetControlIndex( ControlName , ParentForm )
	nColumn := Len(_HMG_aControlCaption [i])
	ListView_SetColumnOrderArray( _HMG_aControlHandles [i], nColumn, aSort )
Return Nil


#pragma BEGINDUMP
#define _WIN32_IE      0x0500
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC ( LISTVIEW_GETCOLUMNORDERARRAY )
{
	int nColumn = hb_parni(2);
	LPINT pnOrder = (LPINT) malloc(nColumn*sizeof(int));
	int i;

	ListView_GetColumnOrderArray( (HWND) hb_parnl(1), nColumn, pnOrder );

	for (i=0; i<nColumn; i++) 
	{ 
		HB_STORNI(pnOrder[i]+1, 3, i+1);
	}
}

HB_FUNC ( LISTVIEW_SETCOLUMNORDERARRAY )
{
	int nColumn = hb_parni(2);
	LPINT pnOrder = (LPINT) malloc(nColumn*sizeof(int));
	int i;

	for (i=0; i<nColumn; i++) 
	{ 
		pnOrder[i] = HB_PARNI(3, i+1) - 1;
	}

	ListView_SetColumnOrderArray( (HWND) hb_parnl(1), nColumn, pnOrder );
}

#pragma ENDDUMP
