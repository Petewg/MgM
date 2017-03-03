/*
* MiniGUI Window MinMax Size Demo
* (c) 2007 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Static lMinMax := .T.

*-----------------------------------------------------------------------------*
Function Main
*-----------------------------------------------------------------------------*
	SET FONT TO "Arial", 10

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		MINWIDTH 150 ;
		MINHEIGHT 250 ;
		MAXWIDTH 1024 ;
		MAXHEIGHT 768 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON MAXIMIZE IF(lMinMax, Form_1.Center, )

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH   120
			HEIGHT  40
			CAPTION 'Child Window' 
			ACTION Child_CLick()
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	60
			COL	10
			WIDTH   120
			HEIGHT  40
			CAPTION 'Modal Window' 
			ACTION Modal_CLick()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	110
			COL	10
			WIDTH   120
			HEIGHT  40
			CAPTION 'Disable Restriction'
			ACTION OnOff_CLick( .F. )
			MULTILINE .T.
		END BUTTON

		DEFINE BUTTON Button_4
			ROW	160
			COL	10
			WIDTH   120
			HEIGHT  40
			CAPTION 'Enable Restriction'
			ACTION OnOff_CLick( .T. )
			MULTILINE .T.
		END BUTTON

		DEFINE BUTTON Button_5
			ROW	210
			COL	10
			WIDTH   120
			HEIGHT  40
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return nil

*-----------------------------------------------------------------------------*
Procedure Child_CLick
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 400 ;
		TITLE 'Child Window' ;
		CHILD ;
		ON MAXIMIZE ThisWindow.Center

		Form_2.MinWidth := 200
		Form_2.MinHeight := 200
		Form_2.MaxWidth := 800
		Form_2.MaxHeight := 600

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Form_2.Center

	Form_2.Activate

Return

*-----------------------------------------------------------------------------*
Procedure Modal_CLick
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_3 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 400 ;
		MINWIDTH 200 ;
		MINHEIGHT 200 ;
		TITLE 'Modal Window' ;
		MODAL
/*
		Form_3.MaxWidth := 800
		Form_3.MaxHeight := 600
*/
		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Form_3.Center

	Form_3.Activate

Return

*-----------------------------------------------------------------------------*
Procedure OnOff_CLick( lOnOff )
*-----------------------------------------------------------------------------*
Local nW := ThisWindow.Width, nH := ThisWindow.Height, cWindow := ThisWindow.Name

	lMinMax := lOnOff

	IF lOnOff
		ThisWindow.MinWidth := 150
		ThisWindow.MinHeight := 250
		ThisWindow.MaxWidth := 1024
		ThisWindow.MaxHeight := 768
		ThisWindow.Width := nW
		ThisWindow.Height := nH
	ELSE
		RESET MINMAXINFO OF &cWindow TO DEFAULT
	ENDIF

Return
