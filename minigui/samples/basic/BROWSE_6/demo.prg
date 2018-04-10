/*
* MiniGUI HeaderImage Property Test
* (c) 2008 Roberto Lopez
*/

#include "minigui.ch"
#include "Dbstruct.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Change Column 1 Header Image'	ACTION Form_1.Browse_1.HeaderImage(1) := 10
				MENUITEM 'Change Column 2 Header Image'	ACTION Form_1.Browse_1.HeaderImage(2) := 9
				MENUITEM 'Change Column 3 Header Image'	ACTION Form_1.Browse_1.HeaderImage(3) := 8
				MENUITEM 'Change Column 4 Header Image'	ACTION Form_1.Browse_1.HeaderImage(4) := 7
				MENUITEM 'Change Column 5 Header Image'	ACTION Form_1.Browse_1.HeaderImage(5) := 6
				MENUITEM 'Change Column 6 Header Image'	ACTION Form_1.Browse_1.HeaderImage(6) := 5
				SEPARATOR
				MENUITEM 'Erase All Columns Header Images'	ACTION EraseAllImages()
				MENUITEM 'Restore All Columns Header Images'	ACTION SetHeaderImages()
			END POPUP
		END MENU

		DEFINE BROWSE Browse_1
			ROW		10
			COL		10
			WIDTH		605
			HEIGHT		410
			HEADERIMAGES	{ '00.bmp' , '01.bmp' , '02.bmp' , '03.bmp' , '04.bmp' , '05.bmp' , '06.bmp' , '07.bmp' , '08.bmp' , '09.bmp' }
			HEADERS		{ 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' }
			WIDTHS		{ 150 , 150 , 150 , 150 , 150 , 150 }
			WORKAREA	Test
			FIELDS		{ 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' }
		END BROWSE

	END WINDOW

	SetHeaderImages()

	Form_1.Center

	Form_1.Activate

Return Nil

Function EraseAllImages()
Local atemp := Array(6)

	Aeval( atemp, {|x,i| Form_1.Browse_1.HeaderImage(i) := 0} )

Return Nil

Function SetHeaderImages()
Local atemp := Array(6)

	Aeval( atemp, {|x,i| Form_1.Browse_1.HeaderImage(i) := i} )

Return Nil

Procedure OpenTables()

	if !file("test.dbf")
		CreateTable()
	endif

	Use Test Index Code
	Go Top

	Form_1.Browse_1.Value := RecNo()
	
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

	Use Test

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
