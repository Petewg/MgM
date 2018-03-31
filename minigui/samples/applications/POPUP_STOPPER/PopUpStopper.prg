/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Pop-Up Stopper'
#define COPYRIGHT ' Grigory Filatov, 2003-2008'

STATIC lEnable := .t., aApps := {}, hMainWnd := 0, lFound := .f.

Function Main( ... )
	LOCAL aWild, lBeep := .F.

	aWild := { ... }
	IF LEN( aWild ) > 0
		lBeep := "/beep" $ aWild[ 1 ]
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON 'ON' ;
		NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
		ON NOTIFYCLICK ( lEnable := !lEnable, Form_1.Enable.Checked := lEnable, ;
			Form_1.NotifyToolTip := PROGRAM + IF(lEnable, ": ON", ": OFF"), ;
			Form_1.NotifyIcon := IF(lEnable, "ON", "OFF") )

		DEFINE NOTIFY MENU 
			ITEM '&Do Not Allow Browser Pop-up Windows'	  ACTION ( lEnable := !lEnable, ;
					Form_1.NotifyToolTip := PROGRAM + IF(lEnable, ": ON", ": OFF"), ;
					Form_1.NotifyIcon := IF(lEnable, "ON", "OFF"), ;
					Form_1.Enable.Checked := lEnable ) NAME Enable CHECKED
			SEPARATOR	
			ITEM '&Mail to author...' ACTION ShellExecute(0, "open", "rundll32.exe", ;
							"url.dll,FileProtocolHandler " + ;
							"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
							"&subject=Pop-Up%20Stopper%20Feedback" + ;
							"&body=How%20are%20you%2C%20Grigory%3F", , 1)
			ITEM 'A&bout...'		ACTION ShellAbout( "", PROGRAM + ' version 1.1' + ;
					CRLF + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
			SEPARATOR	
			ITEM 'E&xit'		  ACTION ThisWindow.Release
		END MENU

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION PopUpStop( lBeep )

	END WINDOW

	ACTIVATE WINDOW Form_1

Return Nil

#define GW_HWNDFIRST	0
#define GW_HWNDLAST	1
#define GW_HWNDNEXT	2
#define GW_HWNDPREV	3
#define GW_OWNER	4
#define GW_CHILD	5

#define WM_CLOSE        0x0010
*--------------------------------------------------------*
Function CloseApp( nItem )
*--------------------------------------------------------*
	LOCAL cAppTitle := aApps[nItem][1], ;
		hWnd := GetWindow( _HMG_MainHandle, GW_HWNDFIRST )  // Get the first window

	Form_1.Timer_1.Enabled := .F.

	WHILE hWnd != 0  // Loop through all the windows

		IF ALLTRIM( GetWindowText( hWnd ) ) == ALLTRIM( cAppTitle )
			PostMessage( aApps[nItem][2], WM_CLOSE, 0, 0 ) // Close the window
			DO EVENTS
			EXIT
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )  // Get the next window

	ENDDO

	Form_1.Timer_1.Enabled := .T.

Return Nil

*--------------------------------------------------------*
Function aTasks()
*--------------------------------------------------------*
	LOCAL aTasks := {}, cTitle := ""
	LOCAL hWnd := GetWindow( _HMG_MainHandle, GW_HWNDFIRST )  // Get the first window

	WHILE hWnd != 0  // Loop through all the windows
		cTitle := GetWindowText( hWnd )

		IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;  // If it is an owner window
			IsWindowVisible( hWnd ) .AND.;      // If it is a visible window
			hWnd != _HMG_MainHandle .AND.;      // If it is not this app
			!EMPTY( cTitle ) .AND.;             // If the window has a title
			!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
			!( cTitle == "Program Manager" )    // If it is not the Program Manager

			AADD( aTasks, { cTitle, hWnd } )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )  // Get the next window
	ENDDO

Return aTasks

*--------------------------------------------------------*
Procedure PopUpStop( lBeep )
*--------------------------------------------------------*
	Local nItem := 0, cAppTitle
	Local nVersion := Val(Left(GetIEversion(), 1))
	Local cStopTitle := IF(nVersion < 7, " - Microsoft Internet Explorer", " - Internet Explorer")

	IF lEnable
		aApps := aTasks()

		Aeval(aApps, {|e| IF(cStopTitle$e[1], nItem++, )})

		IF EMPTY(nItem)
			hMainWnd := 0
			lFound := .F.

		ELSEIF nItem = 1
			Aeval(aApps, {|e| IF(cStopTitle$e[1], hMainWnd := e[2], )})
			lFound := .T.

		ELSEIF nItem > 1
			For nItem := 1 To Len(aApps)

				cAppTitle := aApps[nItem][1]

				IF cStopTitle $ cAppTitle
					IF lFound .AND. aApps[nItem][2] # hMainWnd
						IF lBeep
							PLAY WAVE 'STOP' FROM RESOURCE
						ENDIF
						CloseApp(nItem)
					ELSEIF EMPTY(hMainWnd)
						hMainWnd := aApps[nItem][2]
						lFound := .T.
					ENDIF
				ENDIF
			Next
		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Function GetIEversion()
*--------------------------------------------------------*
Return( GetRegistryValue( HKEY_LOCAL_MACHINE, "Software\Microsoft\Internet Explorer", "Version" ) )
