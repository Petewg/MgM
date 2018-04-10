/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/


#include "minigui.ch"
#include "Dbstruct.ch"

Function Main
Local bColor := { || if ( deleted() , RGB( 255, 0, 0 ) , RGB( 255, 255, 255 ) ) }	
Local var := 'Test'

	REQUEST DBFCDX

	SET EXCLUSIVE ON
	SET CENTURY ON
	SET DELETED OFF

	SET BROWSESYNC ON	

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTable() ;
		ON RELEASE CloseTable()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Append'	ACTION Append_record()
				ITEM 'Delete/Undelete'	ACTION Delete_record()
				SEPARATOR
				ITEM 'Exit'	ACTION Form_1.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'	ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP

		END MENU

		DEFINE STATUSBAR
			STATUSITEM ''
		END STATUSBAR

		@ 10,10 BROWSE Browse_1 ;
			WIDTH 610 ; 
			HEIGHT 313 ; 	
			HEADERS { 'X' , 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
			WIDTHS { 30 , 150 , 150 , 150 , 150 , 150 , 150 } ;
			WORKAREA &var ;
			FIELDS {'Test->(iif(deleted(),"*"," "))' , 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
			ON CHANGE ChangeTest() ;
			JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER} ;
			TOOLTIP 'Browse Test' ;
			DYNAMICBACKCOLOR { bColor, bColor, bColor, bColor, bColor, bColor, bColor } ;
                        READONLY { .T. , .F. , .F. , .F. , .F. , .F. , .F. } ;
			EDIT

                @ 350,150 BUTTON Button_1 ;
                          CAPTION 'Append record' ;
                          WIDTH 140 ;
                          ACTION Append_record() ;
                          TOOLTIP 'Append a new record'

                @ 350,300 BUTTON Button_2 ;
                          CAPTION 'Delete/Undelete' ;
                          WIDTH 140 ;
                          ACTION Delete_record() ;
                          TOOLTIP 'Delete / Recall the current record'

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure OpenTable()

	if !file("test.dbf")
		CreateTable()
	endif

	Use Test Index Code Via "DBFCDX"
	Go Top

	Form_1.Browse_1.Value := RecNo()

	Form_1.Browse_1.ColumnsAutoFitH

	Form_1.Browse_1.SetFocus

Return


Procedure CloseTable()

	Use

Return


Procedure ChangeTest()

	Form_1.StatusBar.Item(1) := 'RecNo: ' + Alltrim ( Str ( GetProperty ( 'Form_1', 'Browse_1', 'Value' ) ) )

Return 


Procedure Append_record()
Local i := GetControlIndex ( "Browse_1", "Form_1" ), n

   Test->( DbGoBottom() )
   n := Test->Code

   Test->( DbAppend() )
   Test->Code := n + 1
   Test->birth := date()-Max(10000, Random(20000))+Random(Test->( LastRec()))

   Form_1.Browse_1.Value := Test->( RecNo() )

   _BrowseEdit ( _hmg_acontrolhandles[i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .f. , _HMG_aControlFontColor [i] )

   Form_1.Browse_1.SetFocus

Return


Procedure Delete_record()

   iif(Test->(Deleted()), Test->(DbRecall()), Test->(DbDelete()))

   Form_1.Browse_1.Refresh
   Form_1.Browse_1.SetFocus

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

        DBCREATE("Test", aDbf, "DBFCDX")

	Use test Via "DBFCDX"

	For i:= 1 To 100
		append blank
		Replace code with i 
		Replace First With 'First Name '+ Ltrim(Str(i))
		Replace Last With 'Last Name '+ Ltrim(Str(i))
		Replace Married With ( i/2 == int(i/2) )
		replace birth with date()-Max(10000, Random(20000))+Random(LastRec())
	Next i

	Index on field->code to code

	Use

Return
