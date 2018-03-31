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
* (nor change selection when it changes) when SET BROWSESYNC is OFF (the default)
* You can programatically refresh it using refresh method.
* Variables called <MemVar>.<WorkAreaName>.<FieldName> are created for 
* validation in browse editing window. You can use it in VALID array.
* Using APPEND clause you can add records to table associated with WORKAREA
* clause. The hotkey to add records is Alt+A.
* Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea
* Using DELETE clause allows to mark selected record for deletion pressing <Del> key
* The leftmost column in a browse control must be left aligned.

* Enjoy !

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
		TITLE 'MiniGUI Browse Demo' ;
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
Local aDbf[6][4], i

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
