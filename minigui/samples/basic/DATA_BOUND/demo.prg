/*
* MiniGUI DATA-BOUND Controls Demo
* (c) 2003 Roberto Lopez
*
* Revised by Grigory Filatov, 2006-2010
*/

#include "minigui.ch"

Procedure Main

	SET DELETED ON

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 728 ;
		HEIGHT 400 ;
		TITLE 'Data-Bound Controls Test' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 88,24 FLAT RIGHTTEXT BORDER

			BUTTON TOP				;
				CAPTION '&Top'			;
				PICTURE 'primero.bmp'		;
				ACTION  ( TEST->(DbGoTop()) , Refresh() )

			BUTTON PREVIOUS				;
				CAPTION '&Previous'		;
			 	PICTURE 'anterior.bmp'		;
				ACTION ( TEST->(DbSkip(-1)) , Refresh() )

			BUTTON NEXT				;
				CAPTION '&Next'			;
			 	PICTURE 'siguiente.bmp'		;
				ACTION ( TEST->(DbSkip(1)) , iif ( TEST->(eof()) , TEST->(DbGoBottom()) , Nil ) , Refresh() )

			BUTTON BOTTOM				;
				CAPTION '&Bottom'		;
				PICTURE 'ultimo.bmp'		;
				ACTION ( TEST->(DbGoBottom()) , Refresh() )

			BUTTON ADD				;
				CAPTION '&Append'		;
				PICTURE 'agregar.bmp'		;
				ACTION  ( New() , Refresh() )

			BUTTON DEL				;
				CAPTION '&Delete'		;
				PICTURE 'suprimir.bmp'		;
				ACTION  ( DelRec() , Refresh() )

			BUTTON SAVE				;
				CAPTION '&Save'			;
				PICTURE 'guardar.bmp'		;
				ACTION ( Save() , Refresh() )

			BUTTON UNDO				;
				CAPTION '&Undo'			;
				PICTURE 'deshacer.bmp'		;
				ACTION ( Refresh() )

		END TOOLBAR

		@ 60,10 LABEL LABEL_1 VALUE 'Code:'
		@ 90,10 LABEL LABEL_2 VALUE 'First Name'
		@ 120,10 LABEL LABEL_3 VALUE 'Last Name'
		@ 150,10 LABEL LABEL_4 VALUE 'Birth Date:'
		@ 180,10 LABEL LABEL_5 VALUE 'Married:'
		@ 210,10 LABEL LABEL_6 VALUE 'Bio:'

		@ 60,200 TEXTBOX TEXT_1;
			WIDTH 150 ;
			FIELD TEST->CODE ;
			NUMERIC ;
			MAXLENGTH 10

		@ 90,200 TEXTBOX TEXT_2;
			WIDTH 150 ;
			FIELD TEST->FIRST ;
			MAXLENGTH 30

		@ 120,200 TEXTBOX TEXT_3;
			WIDTH 150 ;
			FIELD TEST->LAST ;
			MAXLENGTH 30

		@ 150,200 DATEPICKER DATE_4 ;
			WIDTH 150 ;
			FIELD TEST->BIRTH ;
			SHOWNONE

		@ 180,200 CHECKBOX CHECK_5 ;
			CAPTION '' ;
			FIELD TEST->MARRIED

		@ 210,200 EDITBOX EDIT_6 ;
			WIDTH 150 ;
			FIELD TEST->BIO ;
			HEIGHT 100

	END WINDOW

	Win_1.Text_1.SetFocus

	Win_1.Center

	ACTIVATE WINDOW Win_1

Return

Procedure Refresh

	Win_1.Text_1.Refresh
	Win_1.Text_2.Refresh
	Win_1.Text_3.Refresh
	Win_1.Date_4.Refresh
	Win_1.Check_5.Refresh
	Win_1.Edit_6.Refresh

	Win_1.Text_1.SetFocus

Return

Procedure Save

	select test

	IF RLOCK()

		Win_1.Text_1.Save
		Win_1.Text_2.Save
		Win_1.Text_3.Save
		Win_1.Date_4.Save
		Win_1.Check_5.Save
		Win_1.Edit_6.Save

		UNLOCK
	ENDIF

	select 0
Return

Procedure New
Local n

	select test

	DbGoBottom()
	n := TEST->CODE

	APPEND BLANK
	TEST->CODE := ++n

	select 0
Return

Procedure DelRec

	select test

	IF RLOCK()

		DELETE

		UNLOCK
	ENDIF

	WHILE Deleted()
		DbSkip(-1)
	END

	select 0
Return

Procedure OpenTables 

	USE TEST SHARED

	IF !FILE( 'TEST.NTX' )
		INDEX ON FIELD->CODE TO TEST
	ENDIF

	select 0

Return

Procedure CloseTables

	select test
	USE
	ERASE TEST.NTX

Return
