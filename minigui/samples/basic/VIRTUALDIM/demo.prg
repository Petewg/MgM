#include "minigui.ch"
#include "Dbstruct.ch"

* Toolbar's & SplitBox's parent window can't be a 'Virtual Dimensioned' window. 
* Use 'Virtual Dimensioned' splitchild's instead.

Function Main

	SET AUTOSCROLL ON

	SET SCROLLSTEP TO 15

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		VIRTUAL WIDTH 1300 ;
		VIRTUAL HEIGHT 800 ;
		TITLE 'Virtual Dimensioned Window Demo' ;
		MAIN ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		@ 100,10 BUTTON Button_1 ;
		CAPTION 'Vert. ScrollBar Value' ;
		ACTION MsgInfo( Str ( Form_Main.VScrollBar.Value ) ) ;
		WIDTH 150 HEIGHT 25 

		@ 200,10 BUTTON Button_2 ;
		CAPTION 'Horiz. ScrollBar Value' ;
		ACTION MsgInfo( Str ( Form_Main.HScrollBar.Value ) ) ;
		WIDTH 150 HEIGHT 25 

		@ 300,10 BUTTON Button_3 ;
		CAPTION '3' ;
		ACTION MsgInfo('3') ;
		WIDTH 100 HEIGHT 25 

		@ 400,10 BUTTON Button_4 ;
		CAPTION '4' ;
		ACTION MsgInfo('4') ;
		WIDTH 100 HEIGHT 25 

		@ 500,10 BUTTON Button_5 ;
		CAPTION '5' ;
		ACTION MsgInfo('5') ;
		WIDTH 100 HEIGHT 25 

		@ 600,10 BUTTON Button_6 ;
		CAPTION '6' ;
		ACTION MsgInfo('6') ;
		WIDTH 100 HEIGHT 25 

		@ 700,10 BUTTON Button_7 ;
		CAPTION '7' ;
		ACTION MsgInfo('7') ;
		WIDTH 100 HEIGHT 25 

		@ 100,300 SPINNER Spinner_1 ;
		RANGE 0,10 ;
		VALUE 5 ;
		WIDTH 100 ;
		TOOLTIP 'Range 0,10' 

		@ 150,300 BROWSE Browse_1									;
			WIDTH 300  										;
			HEIGHT 150 										;	
			HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
			WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
			WORKAREA Test ;
			FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } 

		@ 350,300 RADIOGROUP Radio_1 ;
		OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
		VALUE 1 ;
		WIDTH 100 ;
		TOOLTIP 'RadioGroup' 

	END WINDOW

	CENTER WINDOW Form_Main
	ACTIVATE WINDOW Form_Main

Return Nil

Procedure OpenTables()

	if !file("test.dbf")
		CreateTable()
	endif

	Use Test Index Code
	Go Top

	Form_Main.Browse_1.Value := RecNo()	
	
Return

Procedure CloseTables()
	Use
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

        DBCREATE("Test", aDbf)

	Use test

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