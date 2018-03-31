/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "MiniGUI.ch"
#include "i_qhtm.ch"
#include "i_winuser.ch"

Procedure Main
local cfile := "about.htm"
local cHtml := Memoread( cfile )

if !qhtm_init()
	return
endif

SET EVENTS FUNCTION TO MYEVENTS

DEFINE WINDOW Form_1 AT 0, 0		;
	WIDTH 415			;
	HEIGHT 230			;
	TITLE "QHTM demo"		;
	ICON "demo.ico"			;
	MAIN NOMAXIMIZE NOSIZE		;
	ON RELEASE qhtm_end()

	if !file(cfile)
	      cfile := GetFile( { {"HTML files (*.htm)", "*.htm"}, {"All files (*.*)", "*.*"} }, ;
			"Select a file", GetStartupFolder(), , .T. )
	endif

	@ 10,12 QHTM Html_1 ;
		VALUE cHtml ;
		WIDTH Form_1.Width - 28 ;
		HEIGHT Form_1.Height - GetTitleHeight() - 32 ;
		ON CHANGE {|lParam| QHTM_MessageBox( "The link is: " + QHTM_GetLink( lParam ) ) } ;
		BORDER
END WINDOW

Center Window Form_1

Activate Window Form_1

Return


*------------------------------------------------------------------------------*
function MyEvents ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
Local i

	do case

        ***********************************************************************
	case nMsg == WM_NOTIFY
        ***********************************************************************

		i := Ascan ( _HMG_aControlIds , wParam )

		If i > 0

			If _HMG_aControlType [i] = "QHTM"

				if valtype( _HMG_aControlChangeProcedure [i] ) == 'B'
					Eval( _HMG_aControlChangeProcedure [i], lParam )
				EndIf

			EndIf

		EndIf

	otherwise

		Return Events ( hWnd, nMsg, wParam, lParam )

    endcase

Return (0)
