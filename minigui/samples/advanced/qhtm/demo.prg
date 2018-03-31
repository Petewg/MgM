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
local cfile := "winlist.htm"

if !qhtm_init()
	return
endif

SET EVENTS FUNCTION TO MYEVENTS

DEFINE WINDOW Form_1 AT 0, 0		;
	WIDTH 830			;
	HEIGHT 600			;
	TITLE "QHTM demo"		;
	ICON "demo.ico"			;
	MAIN 				;
	ON MAXIMIZE qhtm_resize()	;
	ON SIZE qhtm_resize()		;
	ON RELEASE qhtm_end()		;
	BACKCOLOR WHITE

	if !file(cfile)
	      cfile := GetFile( { {"HTML files (*.htm)", "*.htm"}, {"All files (*.*)", "*.*"} }, ;
			"Select a file", GetStartupFolder(), , .T. )
	endif

	@ 0,0 QHTM Html_1 ;
		FILE cfile ;
		WIDTH Form_1.Width - GetBorderWidth()*2 ;
		HEIGHT Form_1.Height - GetTitleHeight() - GetBorderHeight()*2 ;
		ON CHANGE {|lParam| QHTM_MessageBox( "The link is: " + QHTM_GetLink( lParam ) ) }

END WINDOW

Center Window Form_1

Activate Window Form_1

Return

Procedure qhtm_resize
local width := Form_1.Width - GetBorderWidth()*2, height := Form_1.Height - GetTitleHeight() - GetBorderHeight()*2

//	Form_1.Html_1.Width := width
//	Form_1.Html_1.Height := height
	_SetControlSizePos ( "Html_1", "Form_1", 0, 0, width, height )

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
