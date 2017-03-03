/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"
#define NTRIM( n ) LTrim( Str( n ) )
#define APP_TITLE 'Main Window'

FUNCTION Main()
Local nWnd := 1

	WHILE IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) + "_" + NTRIM(nWnd) )
		nWnd++
	END

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE IF(nWnd > 1, "[" + NTRIM(nWnd) + "] ", "") + APP_TITLE ;
		MAIN

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

RETURN NIL
