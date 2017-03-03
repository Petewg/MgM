/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )

static lDialogCancelled

Procedure Main()

	Set Font To "Tahoma", 9
	Set Default Icon To GetStartupFolder() + "\new.ico"

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'InputBox Demo' ;
		MAIN ;
		TOPMOST 

		@ 50 , 100 BUTTON Button_1 ;
			CAPTION "InputBox Test" ;
			ACTION CLick() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 100 , 100 BUTTON Button_2 ;
			CAPTION "InputBox (Timeout) Test" ;
			ACTION TClick() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 150 , 100 BUTTON Button_3 ;
			CAPTION "InputBox (Timeout) Test 2" ;
			ACTION TClick2() ;
	                WIDTH 200 ;
			HEIGHT 30

		@ 200 , 100 BUTTON Button_4 ;
			CAPTION "InputBox MultiLine Test" ;
			ACTION TClick3() ;
	                WIDTH 200 ;
			HEIGHT 30

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Procedure Click

	MsgInfo ( InputBox ( 'Enter text. Please be so kind to read this long description ;-)' , 'InputBox Demo' , 'Default Value' ) )

Return


Procedure TClick

	MsgInfo ( InputBox ( 'Enter text' , 'InputBox Demo' , 'Default Value' , 5000 ) )

Return


Procedure TClick2

	MsgInfo ( InputBox ( 'Enter text' , 'InputBox Demo' , 'Default Value' , 5000 , 'Timeout Value', , @lDialogCancelled ) )

	MsgInfo ( "Dialog Cancelled: " + hb_ValToStr( lDialogCancelled ) , "Result" )

Return


Procedure TClick3

	MsgInfo ( InputBox ( 'Enter text' , 'InputBox Demo' , 'String 1' + CRLF + 'String 2' , , , .T. , @lDialogCancelled ) )

	MsgInfo ( "Dialog Cancelled: " + hb_ValToStr( lDialogCancelled ) , "Result" )

Return
