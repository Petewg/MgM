/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005-2009 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM   'Tray Icon for Outlook Express'
#define COPYRIGHT ' 2005-2009 Grigory Filatov'
#define OE        'Outlook Express'

#define WM_CLOSE           0x0010

#define GW_HWNDFIRST		0
#define GW_HWNDLAST		1
#define GW_HWNDNEXT		2
#define GW_HWNDPREV		3
#define GW_OWNER		4
#define GW_CHILD		5

Static aList := {}, lHide := .f.

*--------------------------------------------------------*
Procedure Main( cCmdLine )
*--------------------------------------------------------*

	DEFAULT cCmdLine := ""

	IF !EMPTY(cCmdLine) .AND. LOWER(SUBSTR(cCmdLine, 2)) == 'hide'
		lHide := .t.
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		ON INIT ( FindOE(), IIF( EMPTY(aList), MakeMenu(), ) ) ;
		NOTIFYICON "MAIN" ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK IIF( EMPTY(aList), StartOE(), ;
				IIF( Form_1.WinShow.Enabled == .T., RestoreOEWindow(), HideOEWindow() ) )

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure MakeMenu()
*--------------------------------------------------------*

	DEFINE NOTIFY MENU OF Form_1
		IF EMPTY(aList)
			ITEM '&Start ' + OE	ACTION StartOE()
		ELSE
			ITEM '&Show ' + OE	ACTION RestoreOEWindow() NAME WinShow
			ITEM '&Hide ' + OE	ACTION HideOEWindow() NAME WinHide
			ITEM '&Close ' + OE 	ACTION CloseOEWindow()

			Form_1.WinShow.Enabled := .f.
			Form_1.WinHide.Enabled := .t.
		ENDIF
			SEPARATOR
			ITEM '&Mail to author...' ;
						ACTION ShellExecute(0, "open", "rundll32.exe", ;
							"url.dll,FileProtocolHandler " + ;
							"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
							"&subject=Tray%20OE%20Feedback:" + ;
							"&body=How%20are%20you%2C%20Grigory%3F", , 1)
			ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + ' version 1.1' + ;
					CRLF + "Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
			SEPARATOR
			ITEM 'E&xit'		ACTION IF(lReleaseCheck(), Form_1.Release, )
	END MENU

Return

#define IDYES     1
#define IDNO      0
#define IDCANCEL -1
*--------------------------------------------------------*
Function lReleaseCheck()
*--------------------------------------------------------*
	LOCAL nRet, lRet := .T.

	IF !EMPTY(aList)

		IF Form_1.WinShow.Enabled == .T.

			nRet := MsgYesNoCancel ( "Do you want to close the session of " + OE + " also?" , "Exit" )

			do case
				case nRet == IDYES
					PostMessage( aList[1], WM_CLOSE, 0, 0 )

				case nRet == IDNO
					RestoreOEWindow()

				otherwise
					lRet := .F.
			endcase
		ENDIF
	ENDIF

Return lRet

*--------------------------------------------------------*
Procedure FindOE()
*--------------------------------------------------------*
	LOCAL aTitles := GetTitles( _HMG_MainHandle )
	LOCAL nChoice := Ascan( aTitles, {|e| OE $ e[1] } )

	IF !Empty(nChoice)

		IF IsControlDefined( Timer_1, Form_1 )
			Form_1.Timer_1.Release
		ENDIF

		aList := {}
		Aadd( aList, aTitles[ nChoice ][ 2 ] )

		DEFINE TIMER Timer_2 OF Form_1 ;
			INTERVAL 250 ;
			ACTION IIF( IsIconic(aList[1]), ;
				( HideOEWindow(), Form_1.Timer_2.Enabled := .f. ), Form_1.Timer_2.Enabled := .t. )

		MakeMenu()

		IF lHide
			HideOEWindow()
		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Procedure StartOE()
*--------------------------------------------------------*
	LOCAL cRunFile := GetRunFile("msimn.exe")

	IF FILE(cRunFile)

		EXECUTE FILE cRunFile

		DEFINE TIMER Timer_1 ;
			OF Form_1 ;
			INTERVAL 100 ;
			ACTION FindOE()
	ENDIF

Return

*--------------------------------------------------------*
Procedure CloseOEWindow()
*--------------------------------------------------------*

	IF !EMPTY(aList)

		IF IsControlDefined( Timer_2, Form_1 )
			Form_1.Timer_2.Release
		ENDIF

		PostMessage( aList[1], WM_CLOSE, 0, 0 )

		aList := {}
		MakeMenu()
	ENDIF

Return

*--------------------------------------------------------*
Procedure HideOEWindow()
*--------------------------------------------------------*

	IF !EMPTY(aList)

		HideWindow( aList[1] )

		Form_1.WinShow.Enabled := .t.
		Form_1.WinHide.Enabled := .f.
		DO EVENTS
	ENDIF

Return

*--------------------------------------------------------*
Procedure RestoreOEWindow()
*--------------------------------------------------------*

	IF !EMPTY(aList)

		ShowWindow( aList[1] )
		IF IsControlDefined( Timer_2, Form_1 ) .AND. Form_1.Timer_2.Enabled == .F.
			_Restore( aList[1] )
			Form_1.Timer_2.Enabled := .t.
		ENDIF

		Form_1.WinShow.Enabled := .f.
		Form_1.WinHide.Enabled := .t.
		DO EVENTS
	ENDIF

Return

*--------------------------------------------------------*
Function GetTitles( hOwnWnd )
*--------------------------------------------------------*
	LOCAL aTasks := {}, cTitle, ;
	hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )        // Get the first window

	WHILE hWnd != 0                                   // Loop through all the windows

		cTitle := GetWindowText( hWnd )

		IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;  // If it is an owner window
			IsWindowVisible( hWnd ) .AND.;      // If it is a visible window
			hWnd != hOwnWnd .AND.;              // If it is not this app
			!EMPTY( cTitle ) .AND.;             // If the window has a title
			!( "DOS Session" $ cTitle ) .AND.;  // If it is not DOS session
			!( cTitle == "Program Manager" )    // If it is not the Program Manager

			AADD( aTasks, { cTitle, hWnd } )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )     // Get the next window
	ENDDO

Return aTasks

*--------------------------------------------------------*
Function GetRunFile( cFile )
*--------------------------------------------------------*
	LOCAL oReg, cVar, nPos

	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows\CurrentVersion\App Paths\" + cFile, .f. )
	cVar := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) ) // i.e look for (Default) key
	oReg:close()

	If Empty( cVar )
		oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Software\Clients\Mail\Outlook Express\shell\open\command" )
		cVar := oReg:Get( Nil, "" )                 // i.e look for (Default) key
		oReg:close()

		If ( nPos := RAt( " /", cVar ) ) > 0        // look for param placeholder without the quotes (ie notepad)
			cVar := StrTran( SubStr( cVar, 1, nPos - 1 ), '"', '' )
		Endif
	Endif

	If Empty( cVar )
		oReg := TReg32():New( HKEY_CLASSES_ROOT, "\mailto\shell\open\command" )
		cVar := oReg:Get( Nil, "" )                 // i.e look for (Default) key
		oReg:close()

		If ( nPos := RAt( " /", cVar ) ) > 0        // look for param placeholder without the quotes (ie notepad)
			cVar := StrTran( SubStr( cVar, 1, nPos - 1 ), '"', '' )
		Endif
	Endif

	If IsWinNT()
		cVar := StrTran( cVar, "%ProgramFiles%", GetProgramFilesFolder() )
	Endif

Return cVar


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

#pragma ENDDUMP
