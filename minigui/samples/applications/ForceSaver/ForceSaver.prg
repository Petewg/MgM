/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright (c) 2004-06 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'ForceSaver'
#define COPYRIGHT ' Grigory Filatov, 2004-2017'

#define RSP_NORMAL	0
#define RSP_SERVICE	1

#define SPI_SCREENSAVERRUNNING 97
#define SC_SCREENSAVE 61760   // &HF140

*--------------------------------------------------------*
Procedure Main( cCmdLine )
*--------------------------------------------------------*
	DEFAULT cCmdLine := ""

	SET MULTIPLE OFF WARNING

	IF !EMPTY( cCmdLine ) .AND. LOWER( SUBSTR( cCmdLine, 2) ) == 'service'

		ServiceProcess( RSP_SERVICE )

		DEFINE WINDOW Form_1 ;
			TITLE PROGRAM ;
			MAIN NOSHOW
	ELSE
		DEFINE WINDOW Form_1 ;
			TITLE PROGRAM ;
			MAIN NOSHOW ;
			NOTIFYICON "MAIN" ;
			NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu" ;
			ON NOTIFYCLICK RunSSaver()

		DEFINE NOTIFY MENU 
			ITEM '&Launch Screen Saver'	ACTION RunSSaver()	NAME LAUNCH
			SEPARATOR
			ITEM '&Mail to author...' ;
				ACTION ShellExecute(0, "open", "rundll32.exe", ;
					"url.dll,FileProtocolHandler " + ;
					"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Force%20Saver%20Feedback:" + ;
					"&body=How%20are%20you%2C%20Grigory%3F", , 1)
			ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + ' version 1.0' + CRLF + ;
					"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
			SEPARATOR
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

		SET DEFAULT MENUITEM LAUNCH OF Form_1

	ENDIF

	END WINDOW

	DEFINE TIMER Timer_1 OF Form_1 ;
		INTERVAL 1000 ;
		ACTION CheckTopLeftCorner()

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Function CheckTopLeftCorner()
*--------------------------------------------------------*
   Local aPos := GetCursorPos()

   IF aPos[1] = 0 .AND. aPos[2] = 0
	SetCursorPos(1, 1)
	DO EVENTS
	RunSSaver()
   ENDIF

Return NIL

*--------------------------------------------------------*
Function RunSSaver()
*--------------------------------------------------------*
Return SendMessage( GetFormHandle("Form_1"), WM_SYSCOMMAND, SC_SCREENSAVE )

*--------------------------------------------------------*
Procedure ServiceProcess( mode )
*--------------------------------------------------------*
	Local nProcessId

	DEFAULT mode := RSP_NORMAL

	nProcessId := GCP()

	If Abs( nProcessId ) > 0

		RSProcess( nProcessId, mode )

	Endif

Return

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG RegisterServiceProcess( DLL_TYPE_LONG nProcessID, DLL_TYPE_LONG nMode ) ;
	IN KERNEL32.DLL ;
	ALIAS RSProcess

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG GetCurrentProcessId() ;
	IN KERNEL32.DLL ;
	ALIAS GCP
