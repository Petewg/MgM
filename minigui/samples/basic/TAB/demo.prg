/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-12 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN ;
		ON SIZE SizeTest()

		DEFINE MAIN MENU

			DEFINE POPUP 'Style'
				MENUITEM 'Top pages' ACTION SetTab_1()
				MENUITEM 'Bottom pages' ACTION SetTab_1( .t. )
				SEPARATOR 
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP

			DEFINE POPUP 'Tests'
				MENUITEM 'Change Page' ACTION Form_1.tab_1.Value := 2
				MENUITEM 'Get Page Count' ACTION MsgInfo(Str(Form_1.tab_1.ItemCount))
				SEPARATOR
				MENUITEM 'Add Page' ACTION Form_1.Tab_1.AddPage ( 2 , 'New Page' , 'Info.Bmp' , 'New Page' )
				MENUITEM 'Delete Page' ACTION Form_1.tab_1.DeletePage ( 2 )
				SEPARATOR
				MENUITEM 'Change Image' ACTION Form_1.Tab_1.Image( 1 ) := 'Info.Bmp'
				MENUITEM 'Replace Image' ACTION Form_1.Tab_1.Image( 1 ) := 'Exit.Bmp'
				SEPARATOR
				MENUITEM 'Change Caption' ACTION Form_1.Tab_1.Caption( 1 ) := 'Caption'
				MENUITEM 'Replace Caption' ACTION Form_1.Tab_1.Caption( 1 ) := 'Page 1'
				SEPARATOR
				MENUITEM 'Change Tooltip of Page 3' ACTION Form_1.Tab_1.Tooltip( 3 ) := 'TabPage 3'
				MENUITEM 'Get Tooltip of Page 3' ACTION MsgInfo( GetProperty ( 'Form_1', 'Tab_1', 'Tooltip', 3 ) )
				SEPARATOR
				MENUITEM 'Get Row' ACTION MsgInfo(Str(Form_1.tab_1.Row))
				MENUITEM 'Get Col' ACTION MsgInfo(Str(Form_1.tab_1.Col))
				MENUITEM 'Get Width' ACTION MsgInfo(Str(Form_1.tab_1.Width))
				MENUITEM 'Get Height' ACTION MsgInfo(Str(Form_1.tab_1.Height))
				SEPARATOR
				MENUITEM 'Set Row' ACTION Form_1.tab_1.Row := Val( InputBox('',''))
				MENUITEM 'Set Col' ACTION Form_1.tab_1.Col:= Val( InputBox('',''))
				MENUITEM 'Set Width' ACTION Form_1.tab_1.Width:= Val( InputBox('',''))
				MENUITEM 'Set Height' ACTION Form_1.tab_1.Height:= Val( InputBox('',''))
				SEPARATOR
				* Optional Syntax (Refer button as tab child )
				MENUITEM 'Get Button Caption' ACTION MsgInfo ( Form_1.Tab_1(1).Button_1.Caption ) 
				MENUITEM 'Set Button Caption' ACTION Form_1.Tab_1(1).Button_1.Caption := 'New'
			END POPUP

		END MENU

		SetTab_1()

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil


Procedure SizeTest()

	Form_1.Tab_1.Width := Form_1.Width - 30
	Form_1.Tab_1.Height := Form_1.Height - 100

Return


#define COLOR_BTNFACE 15

Procedure SetTab_1( lBottomStyle )
Local nColor := GetSysColor( COLOR_BTNFACE )
Local aColor := {GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor )}

	Default lBottomStyle := .f.

	IF IsControlDefined(Tab_1, Form_1)
		Form_1.Tab_1.Release
	ENDIF

	DEFINE TAB Tab_1 ;
		OF Form_1 ;
		AT 10,10 ;
		WIDTH 600 ;
		HEIGHT 400 ;
		VALUE 1 ;
		BACKCOLOR aColor ;
		HOTTRACK ;
		HTFORECOLOR BLUE ;
		HTINACTIVECOLOR GRAY ;
		ON CHANGE MsgInfo( 'Page is changed!' )

		_HMG_ActiveTabBottom := lBottomStyle

		PAGE 'Page &1' IMAGE 'Exit.Bmp' TOOLTIP 'TabPage 1'

		      @ 100,100 BUTTON Button_1 CAPTION "Test" WIDTH 50 HEIGHT 50 ACTION MsgInfo('Test!')

		END PAGE

		PAGE 'Page &2' IMAGE 'Info.Bmp' TOOLTIP 'TabPage 2'

		END PAGE

		PAGE 'Page &3' IMAGE 'Check.Bmp'

		END PAGE

	END TAB

Return
