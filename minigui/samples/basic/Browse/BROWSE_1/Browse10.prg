/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/

 * MiniGUI 1.0 Experimantal Build 6 - Browse10 Demo
 * (c) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 *
 * New property - ColumnWidth(nColumn) for BROWSE/GRID controls
 * New methods for BROWSE/GRID controls
   - ColumnAutoFit(nColumn)  - set column width to best fit regarding to column contents
   - ColumnAutoFitH(nColumn) - set column width to best fit regarding to column header contents
   - ColumnsAutoFit  - set widths of all columns in control to best fit regarding to column contents
   - ColumnsAutoFitH - set widths of all columns in control to best fit regarding to column header contents
*/

#include "minigui.ch"
#include "Dbstruct.ch"

Function Main
Local var := 'Test'

	REQUEST DBFCDX , DBFFPT

	SET CENTURY ON
	SET DELETED ON

	SET BROWSESYNC ON	

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI 1.0 Experimantal Build 6 - Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
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

			POPUP 'New Functions Tests'

				ITEM 'GetColumnWidth Column 1 Browse 1 '         ACTION MsgBox( str(Form_1.Browse_1.ColumnWidth(1)) ) 
				ITEM 'GetColumnWidth Column 2 Browse 1'          ACTION MsgBox( str(Form_1.Browse_1.ColumnWidth(2)) )
				ITEM 'GetColumnWidth Column 3 Browse 1'          ACTION MsgBox( str(Form_1.Browse_1.ColumnWidth(3)) )
				SEPARATOR
				ITEM 'SetColumnWidth Column 1 Browse 1 To 100 '  ACTION {|| (Form_1.Browse_1.ColumnWidth(1) := 100)}
				ITEM 'SetColumnWidth Column 1 Browse 2 To 100 '  ACTION {|| (Form_1.Browse_1.ColumnWidth(2) := 100)}
				ITEM 'SetColumnWidth Column 1 Browse 3 To 100 '  ACTION {|| (Form_1.Browse_1.ColumnWidth(3) := 100)}
				SEPARATOR
				ITEM 'SetColumnWidth Column 1 Browse 1 To Auto'  ACTION Form_1.Browse_1.ColumnAutoFit(1)
				ITEM 'SetColumnWidth Column 1 Browse 1 To AutoH' ACTION Form_1.Browse_1.ColumnAutoFitH(2)
				ITEM 'SetColumnWidth Column 2 Browse 1 To Auto'  ACTION Form_1.Browse_1.ColumnAutoFit(1)
				ITEM 'SetColumnWidth Column 2 Browse 1 To AutoH' ACTION Form_1.Browse_1.ColumnAutoFitH(2)
				SEPARATOR
				ITEM 'Set Auto Width for Browse_1'               ACTION Form_1.Browse_1.ColumnsAutoFit
				ITEM 'Set Auto Width for Browse_2'               ACTION Form_1.Browse_2.ColumnsAutoFit
				ITEM 'Set Auto Width for Browse_3'               ACTION Form_1.Browse_3.ColumnsAutoFit
				SEPARATOR
				ITEM 'Set AutoFit Widths for Browse_1 (header)'  ACTION Form_1.Browse_1.ColumnsAutoFitH
				ITEM 'Set AutoFit Widths for Browse_2(header)'   ACTION Form_1.Browse_2.ColumnsAutoFitH
				ITEM 'Set AutoFit Widths for Browse_3(header)'   ACTION Form_1.Browse_3.ColumnsAutoFitH

			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM ''
		END STATUSBAR

		DEFINE TAB Tab_1 ;
			AT 0,10 ;
			WIDTH 600 ;
			HEIGHT 400 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control' ;
			ON CHANGE ( DoMethod ( 'Form_1' , 'Browse_' + Ltrim( Str( Form_1.Tab_1.Value ) ) , 'SetFocus' ), ;
				DoMethod ( 'Form_1' , 'Browse_' + Ltrim( Str( Form_1.Tab_1.Value ) ) , 'Refresh' ) , ChangeTest() )

			PAGE 'Page 1'

				@ 40,20 BROWSE Browse_1									;
					WIDTH 560  										;
					HEIGHT 340 										;	
					HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
					WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
					WORKAREA &var ;
					FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
					TOOLTIP 'Browse Test' ;
					ON CHANGE ChangeTest() ;
					JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
					DELETE ;
					LOCK ;
					EDIT INPLACE 
			END PAGE

			PAGE 'Page &2'

				@ 40,20 BROWSE Browse_2									;
					WIDTH 560  										;
					HEIGHT 340 										;	
					HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
					WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
					WORKAREA &var ;
					FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
					TOOLTIP 'Browse Test' ;
					ON CHANGE ChangeTest() ;
					JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
					DELETE ;
					LOCK ;
					EDIT INPLACE 
			END PAGE

			PAGE 'Page 3'

				@ 40,20 BROWSE Browse_3									;
					WIDTH 560  										;
					HEIGHT 340 										;	
					HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
					WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
					WORKAREA &var ;
					FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
					TOOLTIP 'Browse Test' ;
					ON CHANGE ChangeTest() ;
					JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
					DELETE ;
					LOCK ;
					EDIT INPLACE 
			END PAGE

		END TAB

	END WINDOW

	CENTER WINDOW Form_1

	Form_1.Browse_1.SetFocus

	ACTIVATE WINDOW Form_1

Return Nil


Procedure OpenTables()

	if !file("test.dbf")
		CreateTable()
	endif

	Use Test Via "DBFCDX"
	Go Top

	Form_1.Browse_1.Value := RecNo()	
	
Return

Procedure CloseTables()

	Use

Return

Procedure ChangeTest()

	Form_1.StatusBar.Item(1) := 'RecNo() ' + Alltrim ( Str ( GetProperty ( 'Form_1', 'Browse_' + Ltrim( Str( Form_1.Tab_1.Value ) ) , 'Value' ) ) )

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

        DBCREATE("Test", aDbf, "DBFCDX")

	Use test Via "DBFCDX"
	zap

	For i:= 1 To 100
		append blank
		Replace code with i 
		Replace First With 'First Name '+ Str(i)
		Replace Last With 'Last Name '+ Str(i)
		Replace Married With .t.
		replace birth with date()+i-10000
	Next i

	Index on field->code to code

	Use

Return
