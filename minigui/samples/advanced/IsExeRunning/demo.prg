/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

#define APP_TITLE 'Main Window'
#define MsgAlert( c ) MsgEXCLAMATION( c, "Warning", , .f. )

FUNCTION Main()
Local hWnd

    IF IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) )

	MsgAlert( "The " + APP_TITLE + " is already running!" )

	hWnd := FindWindow( APP_TITLE )

	IF hWnd > 0

		IF IsIconic( hWnd )
			Restore( hWnd )
		ELSE
			SetForeGroundWindow( hWnd )
		ENDIF
	ELSE

		MsgStop( "Cannot find application window!", "Error", , .f. )

	ENDIF

    ELSE

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE APP_TITLE ;
		MAIN

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

    ENDIF

RETURN NIL


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
