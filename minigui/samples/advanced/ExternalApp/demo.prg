/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

#define WM_CLOSE           0x0010

#define GW_HWNDFIRST		0
#define GW_HWNDLAST		1
#define GW_HWNDNEXT		2
#define GW_HWNDPREV		3
#define GW_OWNER		4
#define GW_CHILD		5

Static cAppTitle

FUNCTION Main()
Local nLang := nHex( SubStr( I2Hex( GetUserLangID() ), 3 ) )

	IF nLang == 25
		cAppTitle := "????????????"
	ELSEIF nLang == 10 .OR. nLang == 22
		cAppTitle := "Calculadora"
   ELSEIF nLang == 8
      cAppTitle := "Αριθμομηχανή"
	ELSE //IF nLang == 9
		cAppTitle := "Calculator"
	ENDIF


	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 200 ;
		TITLE "Minimize/Restore Calc Demo" ;
		MAIN ;
		ON INIT StartIt() ;
		ON RELEASE CloseIt()

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	150
			CAPTION 'Minimize/Restore Calc' 
			ACTION MinimizeIt()
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	150
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

RETURN Nil


FUNCTION StartIt()
Local aTitles := GetTitles( Application.Handle )

	IF EMPTY( aScan( aTitles, {|e| cAppTitle $ e[1] } ) )

		_Execute ( 0, , "Calc", , , 5 )

	ENDIF

RETURN Nil


FUNCTION CloseIt()
Local aTitles := GetTitles( Application.Handle )
Local hWnd, n

	IF ( n := aScan( aTitles, {|e| cAppTitle $ e[1] } ) ) > 0

		hWnd := aTitles[ n ][ 2 ]

		PostMessage ( hWnd, WM_CLOSE, 0, 0 )

	ENDIF

RETURN Nil


FUNCTION MinimizeIt()
Local aTitles := GetTitles( Application.Handle )
Local hWnd, n

	IF ( n := aScan( aTitles, {|e| cAppTitle $ e[1] } ) ) > 0

		hWnd := aTitles[ n ][ 2 ]

		IF IsIconic( hWnd )

			Restore( hWnd )

		ELSE

			_Minimize( hWnd )

		ENDIF

	ELSE

		MsgStop( "Cannot find application window!", "Error" )

	ENDIF

RETURN Nil


FUNCTION GetTitles( hOwnWnd )
Local aTasks := {}, cTitle := "", ;
	hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )        // Get the first window

	WHILE hWnd != 0                                   // Loop through all the windows

		cTitle := GetWindowText( hWnd )

		IF GetWindow( hWnd, GW_OWNER ) = 0 .AND.;  // If it is an owner window
			IsWindowVisible( hWnd ) .AND.;     // If it is a visible window
			hWnd != hOwnWnd .AND.;             // If it is not this app
			!EMPTY( cTitle ) .AND.;            // If the window has a title
			!( "DOS Session" $ cTitle ) .AND.; // If it is not DOS session
			!( cTitle == "Program Manager" )   // If it is not the Program Manager

			aAdd( aTasks, { cTitle, hWnd } )
		ENDIF

		hWnd := GetWindow( hWnd, GW_HWNDNEXT )     // Get the next window
	ENDDO

RETURN aTasks


STATIC FUNCTION nHex( cHex )
Local n, nChar, nResult := 0
Local nLen := Len( cHex )

	FOR n = 1 TO nLen
		nChar := Asc( Upper( SubStr( cHex, n, 1 ) ) )
		nResult += ( ( nChar - If( nChar <= 57, 48, 55 ) ) * ( 16 ^ ( nLen - n ) ) )
	NEXT

RETURN nResult


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC ( GETUSERLANGID )
{
   hb_retni( GetUserDefaultLangID() );
}

static char * u2Hex( WORD wWord )
{
    static far char szHex[ 5 ];

    WORD i= 3;

    do
    {
        szHex[ i ] = 48 + ( wWord & 0x000F );

        if( szHex[ i ] > 57 )
            szHex[ i ] += 7;

        wWord >>= 4;

    }
    while( i-- > 0 );

    szHex[ 4 ] = 0;

    return szHex;
}

HB_FUNC ( I2HEX )
{
   hb_retc( u2Hex( hb_parni( 1 ) ) );
}

#pragma ENDDUMP
