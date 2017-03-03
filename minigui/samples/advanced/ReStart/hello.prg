/*
 * MiniGUI Hello World Demo
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON INTERACTIVECLOSE MsgYesNo( "Are you sure?", "Do you want to exit?" )

		DEFINE HYPERLINK Label_1
			ROW	40
			COL	50
			VALUE	"Restart  This  Application"
			ADDRESS	"proc:\\RestartApp('hello.exe')"
			AUTOSIZE .T.
			HANDCURSOR .T.
		END HYPERLINK

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function RestartApp( cAppName )

Return WinExec( "restart " + cAppName + " " + hb_ntos(Application.Handle) )


#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

// Use WinExec( ..., 9 ) to execute the _same_ external application
// using the previous one if already running.

HB_FUNC( WINEXEC )
{
   int Mode = ( hb_pcount() > 1 ) ? hb_parni( 2 ) : SW_HIDE;

   hb_retni( WinExec( hb_parc( 1 ), Mode ) );
}

#pragma ENDDUMP
