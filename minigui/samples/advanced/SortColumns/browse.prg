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
LOCAL aWidths := { 100 , 150 , 150 , 150 , 150 , 150 }

	SET CENTURY ON
	SET DELETED ON

	SET BROWSESYNC ON	

	OpenTables()

	aDbfStruct := test->( DbStruct() )

	IF !FILE('test.ini')
		BEGIN INI FILE 'test.ini'

		FOR i = 1 TO Len(aDbfStruct)
			SET SECTION "Columns" ENTRY hb_ntos ( i ) TO i
		NEXT

		SET SECTION "Columns" ENTRY "Widths" TO aWidths

		END INI
	ENDIF

	BEGIN INI FILE 'test.ini'

		FOR i = 1 TO Len(aDbfStruct)
			GET nColumn SECTION "Columns" ENTRY hb_ntos ( i ) DEFAULT i
			AAdd( aColumns, nColumn )
		NEXT

		GET aWidths SECTION "Columns" ENTRY "Widths"

	END INI

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Set Browse Value'		ACTION Form_1.Browse_1.Value := Val ( InputBox ('Set Browse Value','') )
				ITEM 'Get Browse Value'		ACTION MsgInfo ( Form_1.Browse_1.Value )
				ITEM 'Get Columns Width'	ACTION MsgDebug ( GetColumnsWidth( "Browse_1", "Form_1", aColumns ) )
				ITEM 'Refresh Browse'		ACTION Form_1.Browse_1.Refresh
				SEPARATOR
				ITEM 'Exit'			ACTION Form_1.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'			ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM ''
		END STATUSBAR

		@ 10,10 BROWSE Browse_1									;
			WIDTH 610  										;
			HEIGHT 390 										;	
			HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
			WIDTHS aWidths ;
			WORKAREA Test ;
			FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
			TOOLTIP 'Browse Test' ;
			ON CHANGE ChangeTest() ;
			JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } ;
			DELETE ;
			LOCK ;
			EDIT APPEND

	END WINDOW

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

		FOR i := 1 TO Len(aColumns)
			SET SECTION "Columns" ENTRY hb_ntos ( i ) TO aColumns[i]
		NEXT

		SET SECTION "Columns" ENTRY "Widths" TO GetColumnsWidth( "Browse_1", "Form_1", aColumns )

	END INI

	Use

Return

Procedure ChangeTest()
	Form_1.StatusBar.Item(1) := 'RecNo: ' + hb_ntos ( RecNo() )
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

        DBCREATE("Test", aDbf)

	Use test

	For i:=1 To 200
		append blank
		Replace code with i 
		Replace First With 'First Name '+ Str(i)
		Replace Last With 'Last Name '+ Str(i)
		Replace Married With .t.
		replace birth with date()+i-10000
	Next i

	Index On Field->Code To Code
	Use

Return

*--------------------------------------------------------------------
Function _GetColumnOrderArray( ControlName, ParentForm )
*--------------------------------------------------------------------
Local i, nColumns, aSort
	i := GetControlIndex( ControlName, ParentForm )
	nColumns := ListView_GetColumnCount( _HMG_aControlHandles [i] )
	aSort := Array( nColumns )
	ListView_GetColumnOrderArray( _HMG_aControlHandles [i], nColumns, @aSort )
Return aSort

*--------------------------------------------------------------------
Function _SetColumnOrderArray( ControlName, ParentForm, aSort )
*--------------------------------------------------------------------
Local i, nColumns
	i := GetControlIndex( ControlName, ParentForm )
	nColumns := ListView_GetColumnCount( _HMG_aControlHandles [i] )
	ListView_SetColumnOrderArray( _HMG_aControlHandles [i], nColumns, aSort )
Return Nil

*--------------------------------------------------------------------
Function GetColumnsWidth( ControlName , ParentForm, aColumns )
*--------------------------------------------------------------------
Local nColumn, aWidths := {}
Local h := GetControlHandle( ControlName , ParentForm )
	FOR nColumn := 1 TO Len( aColumns )
		AAdd( aWidths, ListView_GetColumnWidth( h, nColumn - 1 ) )
	NEXT
Return aWidths

*--------------------------------------------------------------------
#include <sortcolumns.c>
*--------------------------------------------------------------------
