/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Function Main
Local p1, p2, p3, p4, p5

	p1 := p2 := p3 := p4 := p5 := .T.

	SET FONT TO 'MS Shell Dlg', 12

	DEFINE WINDOW Form_1 ;
		CLIENTAREA 500, 400 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN ;
		ON SIZE SizeTest()

		DEFINE MAIN MENU

			DEFINE POPUP 'Style'
				MENUITEM 'Visible Page 1' ACTION ( p1 := !p1, Form_1.p1.Checked := p1, SetTab_1(Form_1.Tab_1.Value) ) NAME p1 CHECKED
				MENUITEM 'Visible Page 2' ACTION ( p2 := !p2, Form_1.p2.Checked := p2, SetTab_1(Form_1.Tab_1.Value) ) NAME p2 CHECKED
				MENUITEM 'Visible Page 3' ACTION ( p3 := !p3, Form_1.p3.Checked := p3, SetTab_1(Form_1.Tab_1.Value) ) NAME p3 CHECKED
				MENUITEM 'Visible Page 4' ACTION ( p4 := !p4, Form_1.p4.Checked := p4, SetTab_1(Form_1.Tab_1.Value) ) NAME p4 CHECKED
				MENUITEM 'Visible Page 5' ACTION ( p5 := !p5, Form_1.p5.Checked := p5, SetTab_1(Form_1.Tab_1.Value) ) NAME p5 CHECKED
				SEPARATOR 
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP

			DEFINE POPUP 'Help'
				MENUITEM 'About' ACTION MsgInfo( MiniguiVersion(), 'Tab Control Demo', , .f. )
			END POPUP

		END MENU

		SetTab_1()

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil


Procedure SizeTest()

	Form_1.Tab_1.Width := Form_1.Width - 40
	Form_1.Tab_1.Height := Form_1.Height - 80

Return


#define COLOR_BTNFACE 15

Procedure SetTab_1( nValue )
Local nColor := GetSysColor( COLOR_BTNFACE )
Local aColor := { GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) }

	DEFAULT nValue := 1

	IF IsControlDefined(Tab_1, Form_1)
		Form_1.Tab_1.Release
	ENDIF

	DEFINE TAB Tab_1 ;
		OF Form_1 ;
		AT 10,10 ;
		WIDTH Form_1.Width - 40 ;
		HEIGHT Form_1.Height - 80 ;
		VALUE nValue ;
		BACKCOLOR aColor ;
		HOTTRACK ;
		HTFORECOLOR BLUE ;
		HTINACTIVECOLOR GRAY

	IF Form_1.p1.Checked

		PAGE 'Page &1' TOOLTIP 'Page 1'

		      @ 100,100 BUTTON Button_1 CAPTION "Test" WIDTH 50 HEIGHT 50 ACTION MsgInfo( 'Test!' )

		END PAGE

	ENDIF

	IF Form_1.p2.Checked

		PAGE 'Page &2' TOOLTIP 'Page 2'

		END PAGE

	ENDIF

	IF Form_1.p3.Checked

		PAGE 'Page &3' TOOLTIP 'Page 3'

		END PAGE

	ENDIF

	IF Form_1.p4.Checked

		PAGE 'Page &4' TOOLTIP 'Page 4'

		END PAGE

	ENDIF

	IF Form_1.p5.Checked

		PAGE 'Page &5' TOOLTIP 'Page 5'

		END PAGE

	ENDIF

	END TAB

Return
