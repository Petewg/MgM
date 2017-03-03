/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main
Local aItemsWidth := { 0, 100, 100, 100 }

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 ;
		HEIGHT 600 ;
		TITLE 'Change Statusbar Item Width Demo' ;
		MAIN 

		DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 8

			STATUSITEM 'Fixed Item <&W>idth:' ACTION MsgInfo('Click! 1')
			STATUSITEM 'Item &2' WIDTH aItemsWidth[2] ACTION ResizeItem( 2 )
			STATUSITEM 'Item &3' WIDTH aItemsWidth[3] ACTION ResizeItem( 3 )
			STATUSITEM 'Item &4' WIDTH aItemsWidth[4] ACTION ResizeItem( 4 )

		END STATUSBAR

	END WINDOW

	Form_1.StatusBar.Width(1) := Form_1.StatusBar.Width(1) + 32
	Form_1.StatusBar.Item(1) := Form_1.StatusBar.Item(1) + Str(Form_1.StatusBar.Width(1), 4)

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*-------------------------------------------------------------
Procedure ResizeItem( nItem )
*-------------------------------------------------------------

	Form_1.StatusBar.Width( nItem ) := IF(Form_1.StatusBar.Width( nItem ) > 100, 100, 200)

Return
