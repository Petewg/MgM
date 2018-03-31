/*
 * MiniGUI Flashing Window Demo
*/

#include "hmg.ch"

#define APP_TITLE "Hello World!"

PROCEDURE Main

   LOCAL hWnd, lResult

   SET MULTIPLE ON

   hWnd := FindWindow( APP_TITLE )

   IF hWnd > 0

      IF IsIconic( hWnd )
         _Restore( hWnd )
      ELSE
         SetActiveWindow( hWnd )
         _Minimize( hWnd )
         _Restore( hWnd )
      ENDIF

   ELSE

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE APP_TITLE ;
		MAIN ;
		ON MINIMIZE Flashing( This.Name, 5, {|| IsIconic( This.Handle ) } )

		ON KEY CONTROL + SPACE ACTION _Minimize( FindWindow( APP_TITLE ) ) TO lResult

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

   ENDIF

RETURN

/*
 *	Flashing( [<cFormName>], [<nBlinks>], [<bWhen>] )
*/
FUNCTION Flashing( cForm, nBlinks, bWhen )

	LOCAL lResult

	DEFAULT cForm := ThisWindow.Name, nBlinks := 300, bWhen := { || .T. }

	IF ( lResult := Eval( bWhen ) )
		FLASH WINDOW &cForm COUNT nBlinks INTERVAL iif( IsWinNT(), 200, 0 )
	ENDIF

RETURN lResult


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
