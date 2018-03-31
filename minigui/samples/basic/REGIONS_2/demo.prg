/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2005-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'HMG Skin Demo'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005-2007 Grigory Filatov'

Static lMove := .F.

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	Set InteractiveClose Off

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT CreateSkinedForm(0, 0, .F.) ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK HideShow()

	END WINDOW

	ACTIVATE WINDOW Form_0

Return

*--------------------------------------------------------*
Static Procedure CreateSkinedForm( nTop, nLeft, lMinimized )
*--------------------------------------------------------*
Local cFileSkin := GetStartupFolder() + "\Bitmaps\logo.bmp", aWinSize

	IF !FILE(cFileSkin)
		MsgStop( "Can not find the skin!", PROGRAM )
		Quit
	ENDIF

	aWinSize := BmpSize( cFileSkin )

	DEFINE WINDOW Form_1 ;
		AT nTop, nLeft ;
		WIDTH aWinSize[1] HEIGHT aWinSize[2] ;
		CHILD ;
		TOPMOST NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ( ( SET REGION OF Form_1 BITMAP &cFileSkin TRANSPARENT COLOR { 255, 0, 255 } ), ;
				Form_1.Topmost := .f., r_menu(), IF(lMinimized, Form_1.Hide, ) ) ;
		ON MOUSEMOVE CheckRect() ;
		ON MOUSECLICK MoveActiveWindow()

		@ 0,0 IMAGE Image_1 ;
			PICTURE cFileSkin ;
			WIDTH Form_1.Width HEIGHT Form_1.Height

	END WINDOW

	IF EMPTY(nTop) .AND. EMPTY(nLeft)
		CENTER WINDOW Form_1
	ENDIF

	ACTIVATE WINDOW Form_1

Return

Procedure CheckRect()

	if CheckExit( { 009, 287, 028, 300 } )
		if  !lMove
			lMove := .t.
			SetHandCursor( GetActiveWindow() )
		endif
	elseif lMove == .t.
		lMove := .f.
		SetArrowCursor( GetActiveWindow() )
	endif
Return

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161
*--------------------------------------------------------*
Procedure MoveActiveWindow(hWnd)
*--------------------------------------------------------*
	default hWnd := GetActiveWindow()

	if CheckExit( { 009, 287, 028, 300 } )
		Form_1.Hide
		r_menu()
	else
		PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)
		RC_Cursor("CATCH")
	endif
Return

*--------------------------------------------------------*
Static Procedure HideShow()
*--------------------------------------------------------*

   IF IsWindowVisible( GetFormHandle( "Form_1" ) )
	Form_1.Hide
   ELSE
	Form_1.Topmost := .t.
	Form_1.Show
	Form_1.Topmost := .f.
   ENDIF

   r_menu()

Return

*--------------------------------------------------------*
Static Procedure r_menu()
*--------------------------------------------------------*

	DEFINE NOTIFY MENU OF Form_0
		ITEM IF( IsWindowVisible( GetFormHandle( "Form_1" ) ), '&Hide', '&Show' ) ;
					ACTION HideShow()
		ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
		SEPARATOR	
		ITEM '&Exit'		ACTION Form_0.Release
	END MENU

Return

*--------------------------------------------------------*
Static Function CheckExit( aRowCol )
*--------------------------------------------------------*
Local nY1 := aRowCol[ 1 ], ;
      nX1 := aRowCol[ 2 ], ;
      nY2 := aRowCol[ 3 ], ;
      nX2 := aRowCol[ 4 ]
Local nRow, nCol, aCursor := GetCursorPos(), lExit

	nRow := aCursor[1] - Form_1.Row
	nCol := aCursor[2] - Form_1.Col

	if nRow > nY1 .and. nRow < nY2 .and. nCol > nX1 .and. nCol < nX2
		lExit := .T.
	else
		lExit := .F.
	endif

Return lExit
