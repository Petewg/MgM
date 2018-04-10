/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"

#define COLOR_BTNFACE 15

Function Main

	SET FONT TO 'Arial', 10

	DEFINE WINDOW Form_1 ;
		MAIN ;
		CLIENTAREA 640, 480 ;
		TITLE 'Colored Tab Control Demo' ;
		; // Init a colored label of the first Tab page
		ON INIT SizePageBack( 1, .F. ) ;
		ON SIZE SizeTest()

		DEFINE MAIN MENU

			DEFINE POPUP 'Style'
				MENUITEM 'Top pages' ACTION ( SetTab_1(), SizePageBack( 1, .F. ) )
				MENUITEM 'Bottom pages' ACTION ( SetTab_1( .T. ), SizePageBack( 1, .T. ) )
				SEPARATOR 
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP

			DEFINE POPUP 'Tests'
				MENUITEM 'Change Page' ACTION Form_1.Tab_1.Value := 2
				MENUITEM 'Get Page Count' ACTION MsgInfo( Form_1.Tab_1.ItemCount )
				SEPARATOR
				* Optional Syntax (Refer button as Tab child )
				MENUITEM 'Get Button Caption' ACTION MsgInfo ( Form_1.Tab_1(1).Button_1.Caption ) 
				MENUITEM 'Set Button Caption' ACTION Form_1.Tab_1(1).Button_1.Caption := 'New'
			END POPUP

		END MENU

	END WINDOW

	SetTab_1()

	Form_1.Center

	Form_1.Activate

Return Nil


Static Procedure SizeTest()

	Form_1.Tab_1.Width := Form_1.ClientWidth - 24
	Form_1.Tab_1.Height := Form_1.ClientHeight - 24

	SizePageBack( Form_1.Tab_1.Value, _HMG_ActiveTabBottom )

Return


Procedure SetTab_1( lBottomStyle )
	Local nColor := GetSysColor( COLOR_BTNFACE )
	Local aColor := { GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) }
	Local aTabColors := {}

	AAdd( aTabColors, { 159, 191, 236 } ) // Office_2003 Blue
	AAdd( aTabColors, { 251, 230, 148 } ) // Office_2003 Orange
	AAdd( aTabColors, { 255, 178, 178 } ) // LightRed
	AAdd( aTabColors, { 195, 224, 133 } ) // Purple
	AAdd( aTabColors, { 178, 135, 214 } ) // DarkBlue

	DEFAULT lBottomStyle := .F.

	IF IsControlDefined( Tab_1, Form_1 )
		Form_1.Tab_1.Release
	ENDIF

	DEFINE TAB Tab_1 ;
		OF Form_1 ;
		AT 10, 10 ;
		WIDTH Form_1.ClientWidth - 24 ;
		HEIGHT Form_1.ClientHeight - 24 ;
		VALUE 1 ;
		BACKCOLOR aColor ;
		HOTTRACK ;
		HTFORECOLOR BLACK ;
		HTINACTIVECOLOR WHITE ;
		ON CHANGE SizePageBack( Form_1.Tab_1.Value, lBottomStyle )

		_HMG_ActiveTabBottom := lBottomStyle

		PAGE 'Page &1' IMAGE 'Exit' TOOLTIP 'TabPage 1'

		      @ 24, 2 LABEL Page_1 VALUE "" WIDTH 0 HEIGHT 0 BACKCOLOR aTabColors[ 1 ]

		      @ 100,100 BUTTON Button_1 CAPTION "Test" WIDTH 50 HEIGHT 50 ACTION MsgInfo('Test!')

		END PAGE

		PAGE 'Page &2' IMAGE 'Info' TOOLTIP 'TabPage 2'

		      @ 24, 2 LABEL Page_2 VALUE "" WIDTH 0 HEIGHT 0 BACKCOLOR aTabColors[ 2 ]

		END PAGE

		PAGE 'Page &3' IMAGE 'Check' TOOLTIP 'TabPage 3'

		      @ 24, 2 LABEL Page_3 VALUE "" WIDTH 0 HEIGHT 0 BACKCOLOR aTabColors[ 3 ]

		END PAGE

		PAGE 'Page &4' IMAGE 'Check' TOOLTIP 'TabPage 4'

		      @ 24, 2 LABEL Page_4 VALUE "" WIDTH 0 HEIGHT 0 BACKCOLOR aTabColors[ 4 ]

		END PAGE

		PAGE 'Page &5' IMAGE 'Check' TOOLTIP 'TabPage 5'

		      @ 24, 2 LABEL Page_5 VALUE "" WIDTH 0 HEIGHT 0 BACKCOLOR aTabColors[ 5 ]

		END PAGE

	END TAB

	// Assign the colors to the Tab bookmarks
	Form_1.Tab_1.Cargo := aTabColors

Return


Static Procedure SizePageBack( nValue, lBottomStyle )
	Local cName := 'Page_' + hb_ntos( nValue )
	Local nH := GetBookmarkHeight()

	Form_1.&(cName).Row := iif( lBottomStyle, 2, iif( Empty(nH), 24, nH - 1 ) )
	Form_1.&(cName).Width := Form_1.Tab_1.Width - iif( IsThemed(), 4, GetBorderWidth() )
	Form_1.&(cName).Height := Form_1.Tab_1.Height - iif( Empty(nH), 26, nH + 1 )

Return


Static Function GetBookmarkHeight()
	Local idx := Form_1.Tab_1.Index

Return _HMG_aControlMiscData1 [idx] [1]
