/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'RunCmd'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2006-2015 Grigory Filatov'

DECLARE WINDOW Form_2

*--------------------------------------------------------*
Procedure Main( cCmd )
*--------------------------------------------------------*
    Local hWnd, cCmd2Run := ""

    cCmd2Run := IFEMPTY( cCmd, "", cCmd )

    IF IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) )

	hWnd := FindWindow( PROGRAM )

	IF hWnd > 0

		IF IsIconic( hWnd )
			_Restore( hWnd )
		ENDIF

		SetForegroundWindow( hWnd )

		IF !EMPTY( cCmd2Run )
			SendCopyDataMsg( hWnd, cCmd2Run )
		ENDIF

	ENDIF

    ELSE

	SET EVENTS FUNCTION TO MYEVENTS

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE '' ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT OpenDialog( cCmd2Run )

	END WINDOW

	ACTIVATE WINDOW Form_1

    ENDIF

Return

*--------------------------------------------------------*
Static Procedure OpenDialog( cCmd2Run )
*--------------------------------------------------------*
   Local hIcon

   DEFINE WINDOW Form_2 ;
	AT 0,0 ;
	WIDTH 360 HEIGHT 164 + IF(IsXPThemeActive(), 6, 0);
	TITLE PROGRAM ;
	ICON 'MAIN' ;
	CHILD ;
	NOMAXIMIZE NOMINIMIZE NOSIZE ;
	ON INIT ( Form_2.Text_1.Setfocus, ;
		DragAcceptFiles( GetFormHandle('Form_2'), .T. ) ) ;
	ON PAINT ( hIcon := LoadTrayIcon( GetInstance(), "MAIN", 32, 32 ), ;
		DrawIcon( GetFormHandle("Form_2"), 12, 14, hIcon ), ;
		DestroyIcon( hIcon ) ) ;
	ON INTERACTIVECLOSE ReleaseAllWindows()

     DEFINE LABEL Label_1
            ROW    14
            COL    56
            WIDTH  270
            HEIGHT 32
            VALUE "Enter the name of an executable program file, folder or document to open."
            FONTNAME "MS Sans Serif"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            VISIBLE .T.
            TRANSPARENT .F.
            AUTOSIZE  .F.
     END LABEL  

     DEFINE LABEL Label_2
            ROW    65
            COL    12
            WIDTH  40
            HEIGHT 20
            VALUE "&Open:"
            FONTNAME "MS Sans Serif"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            VISIBLE .T.
            TRANSPARENT .F.
            AUTOSIZE  .F.
     END LABEL  

     DEFINE BUTTON Button_1
            ROW    104
            COL    186
            WIDTH  74
            HEIGHT 23
            CAPTION "&Run"
            ACTION  RunCommand( Form_2.Text_1.Value )
            FONTNAME  "MS Sans Serif"
            FONTSIZE  9
            TOOLTIP  ""
            FONTBOLD  .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            FLAT    .F.
            TABSTOP .T.
            VISIBLE .T.
            TRANSPARENT .F.
     END BUTTON  

     DEFINE BUTTON Button_2
            ROW    104
            COL    268
            WIDTH  74
            HEIGHT 23
            CAPTION "Close"
            ACTION  Form_2.Release
            FONTNAME  "MS Sans Serif"
            FONTSIZE  9
            TOOLTIP  ""
            FONTBOLD  .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            FLAT    .F.
            TABSTOP .T.
            VISIBLE .T.
            TRANSPARENT .F.
     END BUTTON  

     DEFINE TEXTBOX Text_1
            ROW    62
            COL    56
            WIDTH  262
            HEIGHT 21
            VALUE  cCmd2Run
            FONTNAME "MS Sans Serif"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Form_2.Button_1.Enabled := !Empty(Form_2.Text_1.Value)
            FONTBOLD  .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER RunCommand( Form_2.Text_1.Value )
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
     END TEXTBOX 

     DEFINE BUTTONEX Button_Browse
            ROW    62
            COL    322
            WIDTH  20
            HEIGHT 21
            PICTURE "BROWSE"
            ACTION ( Browse( Form_2.Text_1.Value ), Form_2.Text_1.Setfocus )
            TOOLTIP "Browse for File"
            FLAT .F.
            TABSTOP .T.
            VISIBLE .T.
            TRANSPARENT .F.
     IF IsXPThemeActive()
        END BUTTONEX
     ELSE
        END BUTTON
     ENDIF

     ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   Form_2.Button_1.Enabled := !Empty(Form_2.Text_1.Value)

   CENTER WINDOW Form_2

   ACTIVATE WINDOW Form_2

Return

*--------------------------------------------------------*
Procedure Browse( cFileName )
*--------------------------------------------------------*
   Local cFile := GetFile( { { "Executable Files (*.exe;*.com;*.bat;*.pif)", ;
	"*.exe;*.com;*.bat;*.pif" }, { "All Files (*.*)", "*.*" } }, ;
	"Browse for File", cFilePath( cFileName ) )

	IF FILE( cFile )
        	Form_2.Text_1.Value := cFile
	ENDIF

Return

*--------------------------------------------------------*
Procedure RunCommand( cRunCmd )
*--------------------------------------------------------*

	IF FILE( cRunCmd )
		ShellExecute( 0, "open", Form_2.Text_1.Value, , , 1 )
		Form_2.Text_1.Setfocus
	ELSEIF IsDirectory( cRunCmd )
		ShellExecute( 0, "open", "explorer.exe", Form_2.Text_1.Value, , 1 )
		Form_2.Text_1.Setfocus
	ENDIF

Return

#define WM_COPYDATA           74
#define CDM_RUNCMD         52888 // 0xCE98
#define WM_DROPFILES         563 // 0x0233

*------------------------------------------------------------------------------*
Function MyEvents ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
   Local nCargo, cCmd

    do case

        ***********************************************************************
	case nMsg == WM_COPYDATA
	**********************************************************************

		cCmd := GetCopyDataMsg( lParam, @nCargo )

		IF !EMPTY(cCmd) .AND. nCargo == CDM_RUNCMD .AND. FILE( StrTran(cCmd, '"', "") )

			Form_2.Text_1.Value := cCmd
			Form_2.Text_1.Setfocus
		ENDIF

        ***********************************************************************
	case nMsg == WM_DROPFILES
        ***********************************************************************

		IF IsIconic( hWnd )
			_Restore( hWnd )
		ENDIF

		SetForegroundWindow( hWnd )

	        cCmd := DragQueryFile( wParam )

        	Form_2.Text_1.Value := cCmd

	        DragFinish( wParam )

	otherwise

		Return Events ( hWnd, nMsg, wParam, lParam )

    endcase

Return (0)


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
#endif

HB_FUNC( SENDCOPYDATAMSG )
{
	HWND hwnd;
	COPYDATASTRUCT cds;

	hwnd = (HWND) hb_parnl( 1 );

	cds.dwData = 0xCE98;
	cds.lpData = (char *) hb_parc( 2 );
	cds.cbData = strlen( (char*) cds.lpData );

	SendMessage( hwnd, WM_COPYDATA, 0, (LPARAM) &cds );
}

HB_FUNC( GETCOPYDATAMSG )
{
	PCOPYDATASTRUCT pcds = (PCOPYDATASTRUCT) hb_parnl( 1 );
	if( pcds )
	{
		if( pcds->lpData )
			hb_retclen(  pcds->lpData,  pcds->cbData );
		else
			hb_retc( "" );
	}
	else
		hb_retc( "" );

	if ISBYREF( 2 )
		hb_stornl( pcds->dwData, 2 );
}

HB_FUNC( ISICONIC )
{
	hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC ( FINDWINDOW )
{
	hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

HB_FUNC( DRAGQUERYFILE )
{
	HDROP hDrop = ( HDROP ) hb_parnl( 1 );
	TCHAR lpBuffer[ MAX_PATH + 1 ];

	DragQueryFile( hDrop, 0, lpBuffer, MAX_PATH );
	hb_retc( lpBuffer );
}

HB_FUNC( DRAWICON )
{
	HWND hWnd = (HWND) hb_parnl( 1 );
	HDC hDC;

	hDC = GetDC( hWnd );
 
	hb_retl( DrawIcon( (HDC) hDC, hb_parni( 2 ), hb_parni( 3 ), (HICON) hb_parnl( 4 ) ) );

	ReleaseDC( hWnd, hDC );
}

HB_FUNC( DESTROYICON )
{
	DestroyIcon( (HICON) hb_parnl( 1 ) );
}

#pragma ENDDUMP
