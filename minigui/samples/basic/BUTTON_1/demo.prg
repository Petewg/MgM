/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * ButtonEx Demo
 * (C) 2005-2009 Jacek Kubica <kubica@wssk.wroc.pl>
*/

#include "minigui.ch"

Function Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 345 ;
		HEIGHT 450 ;
		MAIN;
		TITLE 'Button Test' ;
		NOSIZE ;
		NOMAXIMIZE

		DEFINE MAIN MENU
			POPUP 'Enabled Property Test'
				ITEM 'Disable Button 1' ACTION Form_1.Button_1.Enabled := .f.
				ITEM 'Enable Button 1'  ACTION Form_1.Button_1.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 2' ACTION Form_1.Button_2.Enabled := .f.
				ITEM 'Enable Button 2'  ACTION Form_1.Button_2.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 3' ACTION Form_1.Button_3.Enabled := .f.
				ITEM 'Enable Button 3'  ACTION Form_1.Button_3.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 4' ACTION Form_1.Button_4.Enabled := .f.
				ITEM 'Enable Button 4'  ACTION Form_1.Button_4.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 5' ACTION Form_1.Button_5.Enabled := .f.
				ITEM 'Enable Button 5'  ACTION Form_1.Button_5.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 6' ACTION Form_1.Button_6.Enabled := .f.
				ITEM 'Enable Button 6'  ACTION Form_1.Button_6.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 7' ACTION Form_1.Button_7.Enabled := .f.
				ITEM 'Enable Button 7'  ACTION Form_1.Button_7.Enabled := .t.
				SEPARATOR
				ITEM 'Disable Button 8' ACTION Form_1.Button_8.Enabled := .f.
				ITEM 'Enable Button 8'  ACTION Form_1.Button_8.Enabled := .t.
			END POPUP
			POPUP 'Picture Property Test'
				ITEM 'Set Button 1 Picture' ACTION Form_1.Button_1.Picture := 'button5.bmp'
				ITEM 'Get Button 1 Picture' ACTION MsgInfo( Form_1.Button_1.Picture )
				SEPARATOR
				ITEM 'Set Button 2 Picture' ACTION Form_1.Button_2.Picture := 'button5.bmp'
				ITEM 'Get Button 2 Picture' ACTION MsgInfo( Form_1.Button_2.Picture )
				SEPARATOR
				ITEM 'Set Button 3 Picture' ACTION Form_1.Button_3.Picture := 'button5.bmp'
				ITEM 'Get Button 3 Picture' ACTION MsgInfo( Form_1.Button_3.Picture )
				SEPARATOR
				ITEM 'Set Button 4 Picture' ACTION Form_1.Button_4.Picture := 'button5.bmp'
				ITEM 'Get Button 4 Picture' ACTION MsgInfo( Form_1.Button_4.Picture )
				SEPARATOR
				ITEM 'Set Button 5 Picture' ACTION Form_1.Button_5.Picture := 'button5.bmp'
				ITEM 'Get Button 5 Picture' ACTION MsgInfo( Form_1.Button_5.Picture )
				SEPARATOR
				ITEM 'Set Button 6 Picture' ACTION Form_1.Button_6.Picture := 'button5.bmp'
				ITEM 'Get Button 6 Picture' ACTION MsgInfo( Form_1.Button_6.Picture )
				SEPARATOR
				ITEM 'Set Button 7 Picture' ACTION Form_1.Button_7.Picture := 'button5.bmp'
				ITEM 'Get Button 7 Picture' ACTION MsgInfo( Form_1.Button_7.Picture )
				SEPARATOR
				ITEM 'Set Button 8 Picture' ACTION Form_1.Button_8.Picture := 'button5.bmp'
				ITEM 'Get Button 8 Picture' ACTION MsgInfo( Form_1.Button_8.Picture )
			END POPUP

		END MENU

	@ 10,10 BUTTONEX BUTTON_1 ;
			CAPTION "Please..."+CRLF+"Click Me!" ;
			PICTURE "button.bmp" ;
			ACTION MsgInfo('Thanks!') ;
			WIDTH 120 ;
			HEIGHT 60

	@ 110,10 BUTTONEX BUTTON_2 ;
			CAPTION "Click Me!" ;
			PICTURE "button.bmp" ;
			ACTION MsgInfo('Thanks!') ;
			LEFTTEXT ;
			WIDTH 120 ;
			HEIGHT 60

	@ 210,10 BUTTONEX BUTTON_3 ;
			CAPTION "Click Me!" ;
			PICTURE "button.bmp" ;
			ACTION MsgInfo('Thanks!') ;
			VERTICAL ;
			WIDTH 120 ;
			HEIGHT 60

	@ 310,10 BUTTONEX BUTTON_4 ;
			CAPTION "Click Me!" ;
			PICTURE "button.bmp" ;
			ACTION MsgInfo('Thanks!') ;
			VERTICAL ;
			UPPERTEXT ;
			WIDTH 120 ;
			HEIGHT 60

	DEFINE BUTTONEX BUTTON_5
		ROW			10
		COL			200
		CAPTION			"Please..."+CRLF+"Click This!"
		ACTION			MsgInfo('Thanks!')
		PICTURE			"button.BMP"
		WIDTH			120
		HEIGHT			60
	END BUTTONEX

	DEFINE BUTTONEX BUTTON_6
		ROW			110
		COL			200
		CAPTION			"Click This!"
		ACTION			MsgInfo('Thanks!')
		PICTURE			"button.BMP"
		WIDTH			120
		HEIGHT			60
		LEFTTEXT		.T.
	END BUTTONEX

	DEFINE BUTTONEX BUTTON_7
		ROW			210
		COL			200
		CAPTION			"Click This!"
		ACTION			MsgInfo('Thanks!')
		PICTURE			"button.BMP"
		WIDTH			120
		HEIGHT			60
		VERTICAL		.T.
	END BUTTONEX

	DEFINE BUTTONEX BUTTON_8
		ROW			310
		COL			200
		CAPTION			"Click This!"
		ACTION			MsgInfo('Thanks!')
		PICTURE			"button.BMP"
		WIDTH			120
		HEIGHT			60
		VERTICAL		.T.
		UPPERTEXT		.T.
	END BUTTONEX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil
