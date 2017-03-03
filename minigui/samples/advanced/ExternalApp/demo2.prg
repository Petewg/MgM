/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define GW_HWNDFIRST		0
#define GW_HWNDLAST		1
#define GW_HWNDNEXT		2
#define GW_HWNDPREV		3
#define GW_OWNER		4
#define GW_CHILD		5

#define APP_TITLE_EN 'Notepad'
#define APP_TITLE_RU "Блокнот"	// Russian

FUNCTION Main()

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 200 ;
		TITLE "Minimize/Maximize Notepad Demo" ;
		MAIN ;
		TOPMOST ;
		ON INIT StartIt()

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	180
			CAPTION 'Minimize/Maximize Notepad'
			ACTION MinimizeIt()
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	180
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

RETURN Nil

FUNCTION StartIt()
Local aTitles := GetTitles( Application.Handle )

	IF EMPTY( aScan( aTitles, {|e| APP_TITLE_EN $ e[1] } ) )

		_Execute ( 0, , "Notepad", , , 5 )

	ENDIF

RETURN Nil

FUNCTION MinimizeIt()
Local aTitles := GetTitles( Application.Handle )
Local hWnd, n

	IF ( n := aScan( aTitles, {|e| APP_TITLE_EN $ e[1] } ) ) > 0

		hWnd := aTitles[ n ][ 2 ]

		IF IsIconic( hWnd )

			Maximize( hWnd )

		ELSE

			Minimize( hWnd )

		ENDIF

	ELSE

		MsgStop( "Cannot find application window!", "Error" )

	ENDIF

RETURN Nil

*--------------------------------------------------------*
Function GetTitles( hOwnWnd )
*--------------------------------------------------------*
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

Return ( aTasks )
