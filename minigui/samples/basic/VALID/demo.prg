/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Revised by Grigory Filatov, 2013
*/

#include "minigui.ch"

#xtranslate VALID <condition> [ MESSAGE <message> ] ;
=> ;
ON LOSTFOCUS _DoValid ( <condition> , <message> )

Memvar _HMG_IsValidInProgress

Function Main

	SET MULTIPLE OFF WARNING

	SET NAVIGATION EXTENDED

	Public _HMG_IsValidInProgress := .F.

	_HMG_DialogCancelled := .F.

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN ;
		ON INIT Form_1.Text_1.SetFocus ;
		ON INTERACTIVECLOSE _HMG_DialogCancelled := .T.

		@ 10,10 TEXTBOX Text_1 ;
			VALUE 11 ;
			NUMERIC ;
			VALID This.Value < 10

		@ 40,10 TEXTBOX Text_2 ;
			VALUE 11 ;
			NUMERIC ;
			VALID This.Value < 10	;
			MESSAGE 'Only values < 10 !'

		@ 80,10 BUTTON Button_1 ;
			CAPTION 'Exit with validation' ;
			ACTION ThisWindow.Release() ;
			WIDTH 120 ;
			HEIGHT 42

		@ 130,10 BUTTON Button_2 ;
			CAPTION 'Exit without validation' ;
			ACTION ThisWindow.Release() ;
			WIDTH 120 ;
			HEIGHT 42 ;
			MULTILINE

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return Nil


Function _DoValid ( Expression , Message )

	If _HMG_IsValidInProgress .Or. This.FocusedControl == "Button_2" .Or. _HMG_DialogCancelled

		Return Nil

	Else

		If ValType ( Message ) = "U"
			Message := "Invalid Entry"
		EndIf

		_HMG_IsValidInProgress := .T.
		If ( Expression , Nil , ( MsgStop ( Message, 'Error' ) , This.SetFocus ) ) 
		_HMG_IsValidInProgress := .F.

	EndIf

Return Nil
