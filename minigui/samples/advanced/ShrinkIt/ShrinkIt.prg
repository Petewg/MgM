/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2004-2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Shrink It'
#define COPYRIGHT ' Grigory Filatov, 2004-2006'
#define NTRIM( n ) hb_ntos( n )

#define GW_HWNDFIRST		0
#define GW_HWNDLAST		1
#define GW_HWNDNEXT		2
#define GW_HWNDPREV		3
#define GW_OWNER		4
#define GW_CHILD		5

Static aList := {}

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		ON RELEASE iif(LEN( aList ) > 0, RestoreAllWindows(), ) ;
		NOTIFYICON "MAIN" ;
		NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
		ON NOTIFYCLICK iif(Empty(aList), ShrinkActiveWindow(), RestoreWindow())

		DEFINE NOTIFY MENU 
			ITEM '&Restore Window'	ACTION RestoreWindow() NAME WinRestore
			ITEM '&Shrink The Active Window' ;
				ACTION ShrinkActiveWindow()
			SEPARATOR
			ITEM '&Mail to author...' ;
				ACTION ShellExecute( 0, "open", "rundll32.exe", ;
					"url.dll,FileProtocolHandler " + ;
					"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Shrink%20It%20Feedback:" + ;
					"&body=How%20are%20you%2C%20Grigory%3F", , 1 )
			ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + ' version 1.1' + ;
					CRLF + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
			SEPARATOR
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

	END WINDOW

	Form_1.WinRestore.Enabled := .F.

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure ShrinkActiveWindow()
*--------------------------------------------------------*
LOCAL nActiveWnd := GetFirstActiveWindow(), nActiveHeight, nShrinkHeight

	IF .NOT. EMPTY( nActiveWnd )

		nActiveHeight := GetWindowHeight( nActiveWnd )
		nShrinkHeight := GetTitleHeight() + 2

		IF nActiveHeight > nShrinkHeight

			Aadd( aList, { nActiveWnd, nActiveHeight } )

			Form_1.NotifyTooltip := PROGRAM + ": " + NTRIM(LEN(aList)) + " window(s)"
			Form_1.WinRestore.Enabled := .T.

			_SetWindowHeight( nActiveWnd, nShrinkHeight )
		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Procedure RestoreWindow()
*--------------------------------------------------------*

	_SetWindowHeight( aTail( aList ) [1], aTail( aList ) [2] )

	ADEL( aList, LEN(aList) )
	ASIZE( aList, LEN(aList) - 1 )

	Form_1.NotifyTooltip := PROGRAM + ": " + NTRIM(LEN(aList)) + " window(s)"

	IF EMPTY( aList )
		Form_1.WinRestore.Enabled := .F.
	ENDIF

Return

*--------------------------------------------------------*
Procedure RestoreAllWindows()
*--------------------------------------------------------*

	WHILE LEN( aList ) > 0
		RestoreWindow()
	END

Return

*-----------------------------------------------------------------------------*
Procedure _SetWindowHeight( hWnd, Height )
*-----------------------------------------------------------------------------*
LOCAL actpos := { 0, 0, 0, 0 }

	GetWindowRect( hWnd, actpos )

	MoveWindow( hWnd, actpos[1], actpos[2], actpos[3] - actpos[1], Height, .T. )

Return

*--------------------------------------------------------*
Function GetFirstActiveWindow()
*--------------------------------------------------------*
LOCAL ahWnd := {}, nActiveWnd := 0
LOCAL hWnd := GetWindow( _HMG_MainHandle, GW_HWNDFIRST )                // Get the first window

	WHILE hWnd != 0                                                 // Loop through all the windows

		IF IsWindowVisible( hWnd ) .AND.;                       // If it is a visible window
			hWnd != _HMG_MainHandle .AND.;                  // If it is not this app
			ASCAN( aList, { |e| e[1] = hWnd } ) == 0 .AND.; // If the window is not shrinked
			!EMPTY( GetWindowText( hWnd ) ) .AND.;          // If the window has a title
			!IsIconic( hWnd ) .AND.;                        // If the window is not minimized
			!( GetWindowText( hWnd ) == "Program Manager" ) // If it is not the Program Manager

			AADD( ahWnd, hWnd )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )                  // Get the next window

	END

	IF LEN( ahWnd ) > 0
		nActiveWnd := ahWnd[ 1 ]                                // Return First Active Window
	ENDIF

Return nActiveWnd
