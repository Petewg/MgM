/*
 * MiniGUI Icon Viewer Demo
 *
 * Copyright (c) 2004-2005 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define APP_TITLE "Icon viewer"
#define VERSION " v.1.0"
#define COPYRIGHT " 2004-2005 Grigory Filatov"

Static cFileName := "", lOpened := .f.

/*
 *	Main()
 */
Procedure Main
Local hWnd, w := GetDesktopRectWidth(), h := GetDesktopRectHeight()

	SET DATE GERMAN

	DEFINE WINDOW Win_1 ;
		AT GetDesktopRectTop(), GetDesktopRectLeft() ;
		WIDTH w ;
		HEIGHT h ;
		TITLE APP_TITLE ;
		ICON "MAIN" ;
		MAIN ;
		ON PAINT IconShow() ;
		ON SIZE ButtonsResize() ;
		ON MAXIMIZE IF( lOpened, DoMethod( "Win_1", "Restore" ), ButtonsResize() ) ;
		FONT "Tahoma" SIZE 9

		DEFINE STATUSBAR 
			STATUSITEM "Copyright " + Chr(169) + COPYRIGHT
			KEYBOARD
			DATE
			CLOCK
		END STATUSBAR

		@ h-90, w-270 BUTTON Btn_Open ; 
			CAPTION '&Open a file...' ; 
			ACTION OpenFile() ; 
			WIDTH 120 ; 
			HEIGHT 26 ; 
			TOOLTIP "Open a file for view of icon" ;
			BOLD

		@ h-90, w-146 BUTTON Btn_Exit ; 
			CAPTION 'E&xit' ; 
			ACTION Win_1.Release ; 
			WIDTH 120 ; 
			HEIGHT 26 ; 
			TOOLTIP "Close this program" ;
			BOLD

		DEFINE CONTEXT MENU 
			ITEM 'Open a file...'	ACTION OpenFile()
			SEPARATOR	
			ITEM 'About'			ACTION MsgAbout()
		END MENU

	END WINDOW

	ACTIVATE WINDOW Win_1

Return

/*
 *	IconShow()
 */
FUNCTION IconShow()
Local i, y, z, x, bb, IcoL, s_, w

	Win_1.Btn_Open.Setfocus

	if lOpened
		Win_1.Row := GetDesktopRectTop()
		Win_1.Col := GetDesktopRectLeft()
		Win_1.Width := GetDesktopRectWidth()
		Win_1.Height := GetDesktopRectHeight()
		z := -32
		bb := -1
		x := ExtractIconEx(cFileName, -1, s_, IcoL, 1)
		if x == 0
			lOpened := .f.
			MsgStop('Icons is missing!', 'Warning', , .f.)
			Win_1.Title := APP_TITLE
		else
			w := Win_1.Width / 32
			for i := 0 to x / w
				x := -32 ; z += 32
				for y := 0 to w
					x+=32 ; bb++
					IcoL := ExtractIcon(cFileName, bb)
					DrawIcon(_HMG_MainHandle, x, z, IcoL)
					DestroyIcon(IcoL)
				next
				if z > 95
					x := 0
				endif
			next
		endif
	endif

RETURN NIL

/*
 *	OpenFile()
 */
FUNCTION OpenFile()
Local cOpenFile := Getfile( { {"All files with icons", "*.dll;*.exe;*.ico"}, ;
		{"All files", "*.*"} }, "Open a File" )

	cFileName := cOpenFile

	if !empty(cFileName).and.file(cFileName)
		Win_1.Title := cFileName + " - " + APP_TITLE
		lOpened := .t.
		InvalidateRect( GetFormHandle("Win_1") )
		Win_1.Maximize
		Win_1.Restore
	endif

RETURN NIL

/*
 *	ButtonsResize()
 */
FUNCTION ButtonsResize()

	Win_1.Btn_Open.Row := Win_1.Height-90
	Win_1.Btn_Open.Col := Win_1.Width-270
	Win_1.Btn_Exit.Row := Win_1.Height-90
	Win_1.Btn_Exit.Col := Win_1.Width-146

RETURN NIL

/*
 *	MsgAbout()
 */
Function MsgAbout()
return MsgInfo( APP_TITLE + VERSION + " - FREEWARE" + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	padc("This program is Freeware!", 30) + CRLF + ;
	padc("Copying is allowed!", 36), "About", , .f. )


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

HB_FUNC (GETDESKTOPRECTTOP) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.top);
}

HB_FUNC (GETDESKTOPRECTLEFT) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.left);
}

HB_FUNC ( GETDESKTOPRECTWIDTH )
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.right - rect.left);
}

HB_FUNC ( GETDESKTOPRECTHEIGHT )
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.bottom - rect.top);
}

HB_FUNC ( EXTRACTICONEX )
{
	HICON iLarge;
	HICON iSmall;
	UINT  nIcons=hb_parni(5);

	hb_retni( ExtractIconEx( (LPCSTR) hb_parc( 1 ),
					hb_parni( 2 )     ,
					&iLarge           ,
					&iSmall           ,
					nIcons	) );
}

HB_FUNC ( DRAWICON )
{
	HWND hwnd;
	HDC hdc;

	hwnd  = (HWND) hb_parnl( 1 ) ;
	hdc   = GetDC( hwnd ) ;
 
	hb_retl( DrawIcon( (HDC) hdc , hb_parni( 2 ) , hb_parni( 3 ) , (HICON) hb_parnl( 4 ) ) ) ;
	ReleaseDC( hwnd, hdc ) ;
}

HB_FUNC ( DESTROYICON )
{
	DestroyIcon( (HICON) hb_parnl( 1 ) );
}

#pragma ENDDUMP
