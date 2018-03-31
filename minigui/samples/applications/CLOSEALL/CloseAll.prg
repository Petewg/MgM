/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2002-2014 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define WM_CLOSE        0x0010
#define WM_DESTROY      0x0002

#define PROGRAM 'CloseAll'
#define COPYRIGHT ' Grigory Filatov, 2002-2014'
#define VERSION ' version 1.3'

STATIC hIcon, lAsk2Save := .t., lTrayTasks := .f., lShutDown := .f.

*--------------------------------------------------------*
Function Main
*--------------------------------------------------------*

	SET MULTIPLE OFF WARNING

	hIcon := LoadTrayIcon( GetInstance(), "SHUT", 32, 32 )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
		ON NOTIFYCLICK CloseApps( This.Handle ) ;
		ON RELEASE ( DestroyIcon( hIcon ), ErrorLevel( -1 ) )

		DEFINE NOTIFY MENU 
			ITEM '&Shutdown Windows'  ACTION {|| lShutDown := !lShutDown, ;
					Form_1.Shutdown.Checked := lShutDown } NAME Shutdown
			ITEM 'Add &Tray tasks'	  ACTION {|| lTrayTasks := !lTrayTasks, ;
					Form_1.TrayTasks.Checked := lTrayTasks } NAME TrayTasks
			ITEM '&Ask to save'	  ACTION {|| lAsk2Save := !lAsk2Save, ;
					Form_1.AskSave.Checked := lAsk2Save } NAME AskSave CHECKED
			SEPARATOR	
			ITEM '&Mail to author...' ACTION ShellExecute(0, "open", "rundll32.exe", ;
							"url.dll,FileProtocolHandler " + ;
							"mailto:gfilatov@freemail.ru?cc=&bcc=" + ;
							"&subject=Close%20All%20Feedback" + ;
							"&body=How%20are%20you%2C%20Grigory%3F", , 1)
			ITEM 'A&bout...'		ACTION ShellAbout( "About " + PROGRAM + "#", ;
					PROGRAM + VERSION + CRLF + Chr(169) + COPYRIGHT, hIcon )
			SEPARATOR	
			ITEM 'E&xit'		  ACTION Form_1.Release
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_1

Return Nil

#define GW_HWNDFIRST	0
#define GW_HWNDLAST	1
#define GW_HWNDNEXT	2
#define GW_HWNDPREV	3
#define GW_OWNER	4
#define GW_CHILD	5
*--------------------------------------------------------*
Function CloseApps( hOwnWnd )
*--------------------------------------------------------*
LOCAL aWindows := {}, cTitle, iWindow
LOCAL hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )  // Get the first window

	Form_1.NotifyIcon := "PRESSED"
	SysWait()

	WHILE hWnd != 0  // Loop through all the windows
		cTitle := GetWindowText( hWnd )
		IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.; // If it is an owner window
			IsWindowVisible( hWnd ) .AND.;      // If it is a visible window
			hWnd != hOwnWnd .AND.;              // If it is not this app
			!EMPTY( cTitle ) .AND.;             // If the window has a title
			!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
			!( cTitle == "Program Manager" )    // If it is not the Program Manager

			AADD( aWindows, hWnd )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )  // Get the next window
	ENDDO

	if lTrayTasks
		hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )
		WHILE hWnd != 0  // Loop through all the windows
			cTitle := GetWindowText( hWnd )
			IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.; // If it is an owner window
				!IsWindowVisible( hWnd ) .AND.;     // If it is a visible window
				hWnd != hOwnWnd .AND.;              // If it is not this app
				!EMPTY( cTitle ) .AND.;             // If the window has a title
				!( "MS_" $ cTitle ) .AND.;          // If it is not System apps
				!( "DDE" $ cTitle ) .AND.;          // If it is not System apps
				!( "SYSTEM" $ cTitle ) .AND.;       // If it is not System apps
				!( "SENS" $ cTitle ) .AND.;         // If it is not System apps
				!( "WIN95" $ cTitle ) .AND.;        // If it is not System apps
				!( "Spooler" $ cTitle ) .AND.;      // If it is not System apps
				!( "Thread" $ cTitle ) .AND.;       // If it is not System apps
				!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
				!( cTitle == "Program Manager" )    // If it is not the Program Manager

				AADD( aWindows, hWnd )
			ENDIF

			hWnd := GetWindow( hWnd, GW_HWNDNEXT )  // Get the next window
		ENDDO

	endif

        FOR EACH iWindow IN aWindows
		PostMessage( iWindow, IF(lAsk2Save, WM_CLOSE, WM_DESTROY), 0, 0 ) // Close the window
		DO EVENTS
	NEXT

	SysWait()
	Form_1.NotifyIcon := "MAIN"

	if lShutDown
		WinExit()
	endif

Return Nil

*--------------------------------------------------------*
Procedure SysWait( nWait )
*--------------------------------------------------------*
Local iTime := Seconds()

	DEFAULT nWait TO .15

	REPEAT
		DO EVENTS
	UNTIL Seconds() - iTime < nWait

Return

#define EWX_LOGOFF	0
#define EWX_SHUTDOWN	1
#define EWX_REBOOT	2
#define EWX_FORCE	4
#define EWX_POWEROFF	8
*--------------------------------------------------------*
Procedure WinExit
*--------------------------------------------------------*

   if IsWinNT()
      EnablePermissions()
   endif

   if ! ExitWindows(EWX_SHUTDOWN, 0)
      ShowError()
   endif

Return

*--------------------------------------------------------*
EXIT PROCEDURE _AccelerateExit
*--------------------------------------------------------*
LOCAL b, r

   if ! lShutDown
	lAsk2Save := .t.
	lTrayTasks := .t.

	Set InteractiveClose Off

	DEFINE WINDOW Splash ;
		AT 0,0 ;
		WIDTH 350 HEIGHT 100 ;
		CHILD NOCAPTION	;
		TOPMOST	;
		MINWIDTH 350 ;
		MINHEIGHT 100 ;
		MAXWIDTH 350 ;
		MAXHEIGHT 100 ;
		ON INIT ( DrawIcon( This.Handle, 18, 18, hIcon ), CloseApps( Application.Handle ) ) ;
		FONT 'MS Sans Serif' ;
		SIZE 9

		b := Splash.Height-2*GetBorderHeight()
		r := Splash.Width-2*GetBorderWidth()

		DRAW PANEL IN WINDOW Splash ;
			AT 0, 0 ;
			TO b, r

		DRAW PANEL IN WINDOW Splash ;
			AT 1, 1 ;
			TO b-1, r-1

		@ 32,85 LABEL Label_1 VALUE "Accelerating, please wait..." AUTOSIZE ;
			FONT 'Tahoma' ;
			SIZE 12

		@ 70,85 LABEL Label_2 VALUE PROGRAM + VERSION + '  ' + Chr(169) + COPYRIGHT AUTOSIZE

	END WINDOW

	CENTER WINDOW Splash

	ACTIVATE WINDOW Splash NOWAIT
	InkeyGUI(2000)
   endif

RETURN


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( SHOWERROR )

{
   LPVOID lpMsgBuf;
   DWORD dwError  = GetLastError();

   FormatMessage( 
      FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
      NULL,
      dwError,
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
      (LPTSTR) &lpMsgBuf,
      0,
      NULL 
   );
   
   MessageBox(NULL, (LPCSTR)lpMsgBuf, "Shutdown", MB_OK | MB_ICONEXCLAMATION);
   // Free the buffer
   LocalFree( lpMsgBuf );
}

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( EXITWINDOWS )

{
   hb_retl( ExitWindowsEx( (UINT) hb_parni( 1 ), (DWORD) hb_parnl( 2 ) ) );
}

HB_FUNC( DRAWICON )
{
   HWND hWnd = (HWND) hb_parnl( 1 );
   HDC hDC;

   hDC = GetDC( hWnd );
 
   hb_retl( DrawIcon( (HDC) hDC, hb_parni( 2 ), hb_parni( 3 ), (HICON) hb_parnl( 4 ) ) );

   ReleaseDC( hWnd, hDC );
}

HB_FUNC( DESTROYICON )
{
   DestroyIcon( (HICON) hb_parnl( 1 ) );
}

#pragma ENDDUMP
