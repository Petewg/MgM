/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2010 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Minimize All'
#define COPYRIGHT '(c) 2010 Grigory Filatov'
#define VERSION ' version 1.0'

#define WS_EX_TOOLWINDOW        0x00000080

*--------------------------------------------------------*
Function Main
*--------------------------------------------------------*
   Local hRegionHandle
   Local aWinSize := BmpSize( "BUTTON" )
   Local nTop := GetDesktopHeight() - GetTaskBarHeight() - aWinSize [2]
   Local nLeft := 0

	SET MULTIPLE OFF WARNING

	DEFINE WINDOW Form_1 ;
		AT nTop, nLeft ;
		WIDTH aWinSize [1] ;
		HEIGHT aWinSize [2] ;
		MAIN ;
		TOPMOST ;
		NOCAPTION ;
		NOSIZE ;
		ON INIT ( SET REGION OF Form_1 BITMAP BUTTON ;
			TRANSPARENT COLOR FUCHSIA TO hRegionHandle ) ;
		ON RELEASE DeleteObject( hRegionHandle )

		@ 0,0 IMAGE Image_1 ;
			PICTURE 'BUTTON' ;
			WIDTH Form_1.Width HEIGHT Form_1.Height ;
			ACTION Keybd_Win_D()

		DEFINE CONTEXT MENU CONTROL Image_1
			MENUITEM "About" ACTION MsgInfo(PROGRAM + VERSION + CRLF + CRLF + COPYRIGHT, "About")
			SEPARATOR
			MENUITEM "Exit" ACTION Form_1.Release
		END MENU

	END WINDOW

	/* Remove the program button from Task Bar via changing a Main window style
	*/
	ChangeStyle( Application.Handle, WS_EX_TOOLWINDOW, , .t. )

	ACTIVATE WINDOW Form_1

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#define VK_D	68

HB_FUNC( KEYBD_WIN_D )
{
	keybd_event(
		VK_LWIN,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	keybd_event(
		VK_D,		// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	keybd_event
	(
		VK_D,		// virtual-key code
		0,		// hardware scan code
		KEYEVENTF_KEYUP,// flags specifying various function options
		0		// additional data associated with keystroke
	);

	keybd_event
	(
		VK_LWIN,	// virtual-key code
		0,		// hardware scan code
		KEYEVENTF_KEYUP,// flags specifying various function options
		0		// additional data associated with keystroke
	);

}

#pragma ENDDUMP
