/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003-2012 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Focus It'
#define COPYRIGHT ' Grigory Filatov, 2003-2012'

Static hActiveWnd := 0
Static lOnTop := .T.

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
	Local bAction

	SET MULTIPLE OFF

	SET GLOBAL HOTKEYS ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON "MAIN" ;
		NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
		ON NOTIFYCLICK ( lOnTop := ! lOnTop, ;
			Form_1.Timer_1.Enabled := ! Form_1.Timer_1.Enabled, ;
			Form_1.NotifyIcon := IF(Form_1.Timer_1.Enabled, "MAIN", "STOP"), ;
			Form_1.OnTop.Checked := lOnTop )

		bAction := _GetNotifyIconLeftClick ( Application.FormName )

		DEFINE NOTIFY MENU 
			ITEM 'On &Top Focused Window' + Chr(9) + 'Shift+Esc' ;
				ACTION Eval( bAction ) NAME OnTop CHECKED
			SEPARATOR
			ITEM '&Mail to author...' ;
				ACTION ShellExecute(0, "open", "rundll32.exe", ;
					"url.dll,FileProtocolHandler " + ;
					"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Focus%20It%20Feedback:" + ;
					"&body=How%20are%20you%2C%20Grigory%3F", , 1)
			ITEM '&About...'	ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + ' version 1.1' + ;
					CRLF + "Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
			SEPARATOR
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

		// Define global hotkey
		ON KEY SHIFT+ESCAPE ACTION Eval( bAction )

		DEFINE TIMER Timer_1 INTERVAL 250 ACTION SetActiveWindow()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return Nil

*--------------------------------------------------------*
Function SetActiveWindow()
*--------------------------------------------------------*
	Local hWnd := GetWindowFromPoint()

	IF !EMPTY( hWnd ) .AND. hActiveWnd # hWnd .AND. IsCursorOnDesktop( GetCursorPos() )

		IF lOnTop
			SetWindowPos( hActiveWnd, -2, 0, 0, 0, 0, 3 )
			SetWindowPos( hWnd, -1, 0, 0, 0, 0, 3 )
		ENDIF

		hActiveWnd := hWnd

		SetForegroundWindow( hWnd )

	ENDIF

Return Nil

*--------------------------------------------------------*
Function IsCursorOnDesktop( aCursorPos )
*--------------------------------------------------------*
	Local aAreaDesk := GetDesktopArea()

Return ( aCursorPos[1] > aAreaDesk[1] .and. aCursorPos[1] > aAreaDesk[2] .and. ;
	aCursorPos[2] < aAreaDesk[3] .and. aCursorPos[2] < aAreaDesk[4] )

*--------------------------------------------------------*
Function _GetNotifyIconLeftClick ( FormName )
*--------------------------------------------------------*
	Local i := GetFormIndex ( FormName )

Return ( _HMG_aFormNotifyIconLeftClick [i] )


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC ( GETWINDOWFROMPOINT )
{
	HWND hWnd;
	POINT pt;

	GetCursorPos(&pt);

	hWnd = WindowFromPoint(pt);

	if ( hWnd != NULL )
		hb_retnl ( (LONG) hWnd );
	else
		hb_retnl ( 0 );
}

#pragma ENDDUMP
