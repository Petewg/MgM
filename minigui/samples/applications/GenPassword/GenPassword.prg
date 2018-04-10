/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2014-2016 Grigory Filatov
 */

#include "minigui.ch"

STATIC cSet1, cSet2

FUNCTION Main
   LOCAL width, height, fhandle, enabled
   LOCAL frmTitle, btnCaption, chk1Caption, chk2Caption, chk3Caption, chk4Caption, lblCaption

   cSet1 := 'QqWwEeRrTtYyUuIioPpAaSsDdFfGgHhJjKkLlZzXxCcVvBbNnMm'
   cSet2 := '1234567890-_'

   //SET LANGUAGE TO RUSSIAN

   IF Upper( Left( Set( _SET_LANGUAGE ), 2 ) ) == 'RU'
	frmTitle    := 'Генератор паролей'
	btnCaption  := 'Другой'
	lblCaption  := 'Символов в пароле'
	chk1Caption := 'Запомнить в буфере обмена'
	chk2Caption := 'Не использовать заглавную букву О'
	chk3Caption := 'Не использовать цифры'
	chk4Caption := 'Пароль только из цифр'
   ELSE
	frmTitle    := 'Password Generator'
	btnCaption  := 'Another'
	lblCaption  := 'Symbols in password'
	chk1Caption := 'Store a password to Clipboard'
	chk2Caption := "Don't use the upper letter O"
	chk3Caption := "Don't use the digits"
	chk4Caption := 'Password have the digits only'
   ENDIF

	SET FONT TO 'Tahoma' , 10

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 330 ;
		HEIGHT 225 ;
		TITLE frmTitle ;
		ICON 'LOCK' ;
		MAIN ;
		NOSIZE ;
		ON INIT GenPass() ;
		ON MOUSECLICK MoveActiveWindow()

		SetProperty( 'Form_1', 'TitleBar', .F. )
		SetProperty( 'Form_1', 'SysMenu', .F. )

		Width := GetProperty( 'Form_1', 'width' )
		Height := GetProperty( 'Form_1', 'height' )

		DRAW LINE IN WINDOW Form_1 ;
			AT 0, 0 TO 0, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW Form_1 ;
			AT Height, 0 TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW Form_1 ;
			AT 0, 0 TO Height, 0 ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW LINE IN WINDOW Form_1 ;
			AT 0, Width TO Height, Width ;
			PENCOLOR BLACK ;
			PENWIDTH 2

		DRAW ICON IN WINDOW Form_1 AT 8, 24 PICTURE "LOCK" WIDTH 32 HEIGHT 32

		DEFINE LABEL Label_1
			ROW	15
			COL	84
			VALUE	frmTitle
			AUTOSIZE  .T.
			FONTCOLOR BLUE
		END LABEL

		DEFINE BUTTON Button_1
			ROW	50
			COL	13
			WIDTH	57
			HEIGHT	24
			CAPTION btnCaption
			ACTION	GenPass()
			FONTSIZE 8
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTONEX Button_2
			ROW	8
			COL	298
			WIDTH	24
			HEIGHT	22
			PICTURE 'CLOSE'
			ACTION	ThisWindow.Release
			FLAT .T.
		END BUTTONEX

		DEFINE TEXTBOX Textbox_1
			ROW	50
			COL	76
			WIDTH	238
			HEIGHT	25
			VALUE	''
			FONTNAME 'Arial'
			FONTSIZE 13
			FONTBOLD .T.
		END TEXTBOX

		DEFINE CHECKBOX Checkbox_1
			ROW	82
			COL	84
			CAPTION chk1Caption
			VALUE	.T.
			AUTOSIZE .T.
		END CHECKBOX

		DEFINE SPINNER Spinner_1
			ROW	112
			COL	270
			WIDTH	44
			HEIGHT	24
			VALUE	10
			RANGEMIN 4
			RANGEMAX 100
		END SPINNER

		fhandle := GetControlFontHandle( 'Spinner_1', 'Form_1' )

		DEFINE LABEL Label_2
			ROW	116
			COL	GetProperty( 'Form_1', 'Spinner_1', 'Col' ) - GetTextWidth( , lblCaption, fhandle ) - 8
			VALUE	lblCaption
			AUTOSIZE .T.
		END LABEL

		DEFINE CHECKBOX Checkbox_2
			ROW	144
			COL	84
			CAPTION chk2Caption
			VALUE	.T.
			AUTOSIZE .T.
		END CHECKBOX

		DEFINE CHECKBOX Checkbox_3
			ROW	168
			COL	84
			CAPTION chk3Caption
			VALUE	.F.
			AUTOSIZE .T.
		END CHECKBOX

		DEFINE CHECKBOX Checkbox_4
			ROW	192
			COL	84
			CAPTION chk4Caption
			VALUE	.F.
			AUTOSIZE .T.
			ONCHANGE ( enabled := Form_1.Checkbox_4.Value, ;
				Form_1.Checkbox_2.Enabled := ! enabled, ;
				Form_1.Checkbox_3.Enabled := ! enabled )
		END CHECKBOX

		ON KEY ESCAPE ACTION ThisWindow.Release
		ON KEY RETURN ACTION GenPass()
		
	END WINDOW

	CENTER WINDOW Form_1
    
	ACTIVATE WINDOW Form_1

RETURN Nil


PROCEDURE GenPass()
   LOCAL nLen := Form_1.Spinner_1.Value
   LOCAL cPass := ""
   LOCAL cSet
   LOCAL nCnt, i, cLet

   DO CASE
   CASE Form_1.Checkbox_3.Value .AND. Form_1.Checkbox_3.Enabled
	cSet := cSet1
   CASE Form_1.Checkbox_4.Value
	cSet := cSet2
   OTHERWISE
	cSet := cSet1 + cSet2
   ENDCASE

   IF ! Form_1.Checkbox_2.Value .AND. ! Form_1.Checkbox_4.Value
	cSet += "O"
   ENDIF

   nCnt := Len( cSet )

   FOR i := 1 TO nLen

      cLet := SubStr( cSet, Random( nCnt ), 1 )
      cPass += cLet

   NEXT

   Form_1.Textbox_1.Value := cPass

   IF Form_1.Checkbox_1.Value
	System.Clipboard := cPass
   ENDIF

RETURN


FUNCTION GetControlFontHandle( ControlName, FormName )
   LOCAL k := GetControlIndex( ControlName, FormName )

RETURN _HMG_aControlFontHandle [k]


#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )
	DEFAULT hWnd := GetActiveWindow()

	PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

RETURN
