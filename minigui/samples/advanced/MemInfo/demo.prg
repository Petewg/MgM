/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "Memory Info"
#define VERSION " version 1.2"
#define COPYRIGHT " Grigory Filatov, 2007-2017"

#define NUMERIC 0
#define DIGITAL 9

#define	IDB_ICONFONT	1001
#define	IDB_ICONFONT2	1002

Static nAvailableMem := 0, nStyle

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	Default nStyle To DIGITAL

	DEFINE WINDOW Form_1 		;
		TITLE PROGRAM 		;
		MAIN NOSHOW 		;
		NOTIFYTOOLTIP PROGRAM	;
		ON INIT Start()		;
		ON RELEASE ShowNotifyIcon( This.Handle, .F., NIL, NIL )

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION ChangeTrayIcon()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure Start()
*--------------------------------------------------------*
Local i := GetFormIndex( This.Name )
Local nFreeMem := MemoryStatus(2)
Local nAvailable := Round( nFreeMem / MemoryStatus(1), 2 )
Local lState := ( nFreeMem < 0.1 * MemoryStatus(1) )
Local nIcon := iif(IsWinNT(), IDB_ICONFONT, IDB_ICONFONT2)
Local hIcon := LoadNumericIcon( nFreeMem, nAvailable, lState, nStyle, nIcon )

	CLEAN MEMORY

	Form_1.NotifyTooltip := 'Free RAM: ' + Ltrim(Transform(nFreeMem, "9999")) + ;
		' MB, Used swap: ' + Ltrim(Transform(MemoryStatus(3)-MemoryStatus(4), "999999")) + ' MB'

	ShowNotifyIcon( _HMG_aFormhandles[i], .T., hIcon, _HMG_aFormNotifyIconToolTip[i] )

	nAvailableMem := nFreeMem

	DEFINE NOTIFY MENU OF Form_1

		ITEM 'About...'			ACTION ShellAbout( "About " + PROGRAM + "# ", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, hIcon )

		SEPARATOR	

		POPUP 'Icon Style'

			ITEM 'Numerical'	ACTION ( nStyle := NUMERIC, nAvailableMem := 0, ;
				Form_1.Dig.Checked := .f., Form_1.Num.Checked := .t. ) NAME NUM

			ITEM 'Digital'		ACTION ( nStyle := DIGITAL, nAvailableMem := 0, ;
				Form_1.Dig.Checked := .t., Form_1.Num.Checked := .f. ) NAME DIG CHECKED

		END POPUP

		SEPARATOR	

		ITEM 'Exit'			ACTION Form_1.Release

	END MENU

Return

*--------------------------------------------------------*
Static Procedure ChangeTrayIcon()
*--------------------------------------------------------*
Local i := GetFormIndex( ThisWindow.Name )
Local nFreeMem := MemoryStatus(2)
Local nAvailable := Round( nFreeMem / MemoryStatus(1), 2 )
Local lState := ( nFreeMem < 0.1 * MemoryStatus(1) )
Local nIcon := iif(IsWinNT(), IDB_ICONFONT, IDB_ICONFONT2)
Local hIcon := LoadNumericIcon( nFreeMem, nAvailable, lState, nStyle, nIcon )

	IF nAvailableMem != nFreeMem

		Form_1.NotifyTooltip := 'Free RAM: ' + Ltrim(Transform(nFreeMem, "9999")) + ;
		' MB, Used swap: ' + Ltrim(Transform(MemoryStatus(3)-MemoryStatus(4), "999999")) + ' MB'

		ChangeNotifyIcon( _HMG_aFormhandles[i], hIcon, _HMG_aFormNotifyIconToolTip[i] )

		nAvailableMem := nFreeMem

	ENDIF

Return

/*
 * C-level
*/
#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

static HBITMAP m_bmFont = NULL; // font used in icon

static HICON MakeIcon_Numerical( DWORD dwFreeMemory, FLOAT dwAvailMemory, BOOL bMemState, UINT glifOffset, UINT IconFont )
{
	HICON hIcon;
	ICONINFO ii;
	char szFree[32];

	RECT r;
	UINT i, ox, sl;
	UINT ofs;

	// creating DC for painting icon
	HDC hDC, hDC2, hTempDC;
	HBITMAP hbmColor;
	HBITMAP hbmMask;
	HBRUSH hbrColor,hbrColor2;
	UINT iState;
	LOGBRUSH logbr;

	// load font for icon (if haven't already done it)
	if ( m_bmFont == NULL )
		m_bmFont = (HBITMAP)LoadImage( GetModuleHandle(NULL), MAKEINTRESOURCE(IconFont), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );

	// paint icon
	hTempDC = CreateDC( "DISPLAY", NULL, NULL, NULL );
	hDC = CreateCompatibleDC( hTempDC );
	hDC2 = CreateCompatibleDC( hTempDC );
	hbmColor = CreateCompatibleBitmap( hTempDC, 16, 16 );
	hbmMask = CreateBitmap(  16, 16, 1, 1, NULL );
	iState = SaveDC( hDC );
	logbr.lbColor = bMemState ? RGB(255,0,0) : RGB(0,255,0);
	logbr.lbStyle = BS_SOLID;
	hbrColor = CreateBrushIndirect( &logbr );
	hbrColor2 = CreateSolidBrush( RGB(216,204,200) );
	
	SelectObject( hDC, hbmColor );
	SelectObject( hDC2, m_bmFont );
	SetRect( &r, 0, 0, 16, 16 );

	if ( glifOffset > 0 )
	{
		FillRect( hDC, &r, (HBRUSH)GetStockObject( WHITE_BRUSH ) );
		SetRect( &r, 0, 0, 16, 10 );
		FillRect( hDC, &r, (HBRUSH)GetStockObject( BLACK_BRUSH ) );
	}
	else
	{
		OSVERSIONINFO osvi;
		osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
		GetVersionEx ( &osvi );
		if( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
			FillRect( hDC, &r, (HBRUSH)hbrColor2 );
		else
			FillRect( hDC, &r, (HBRUSH)GetStockObject( WHITE_BRUSH ) );
	}

	sprintf( szFree, "%i", dwFreeMemory );

	if ( strlen(szFree) == 4 )
	{
		sl = strlen( szFree )*4;
		ox = (16-sl)/2;
		for( i=0; i<4; i++ )
		{
			ofs = szFree[i]-0x30;
			BitBlt( hDC, ox+(i*4), 1, 4, 8, hDC2, ofs*4, 0+glifOffset, SRCCOPY );
		}
	}
	else
	{
		sl = strlen( szFree )*5;
		ox = (16-sl)/2;
		for( i=0; i<3; i++ )
		{
			ofs = szFree[i]-0x30;
			BitBlt( hDC, ox+(i*5), 1, 5, 8, hDC2, ofs*5, 18+glifOffset, SRCCOPY );
		}
	}

	SetRect( &r, 0, 10, 16, 15 );
	FillRect( hDC, &r, (HBRUSH)GetStockObject( BLACK_BRUSH ) );
	SetRect( &r, 1, 11, 1+(UINT)(14.0*dwAvailMemory), 14 );
	FillRect( hDC, &r, hbrColor );

	SelectObject( hDC, hbmMask );
	SelectObject( hDC2, hbmColor );
	BitBlt( hDC, 0, 0, 16, 16, hDC2, 0, 0, SRCCOPY );

	RestoreDC( hDC, iState );

	// finally make trayicon
	ii.fIcon = TRUE;
	ii.hbmColor = hbmColor;
	ii.hbmMask = hbmMask;
	hIcon = CreateIconIndirect( &ii );
	DeleteObject( hbmMask );
	DeleteObject( hbmColor );

	// releasing GDI objects
	DeleteDC( hDC2 );
	DeleteDC( hDC );
	DeleteDC( hTempDC );
	DeleteObject( hbmColor );
	DeleteObject( hbmMask );
	DeleteObject( hbrColor );
	DeleteObject( hbrColor2 );

	return hIcon;
}

HB_FUNC( LOADNUMERICICON )
{
	HICON himage;

	himage = ( HICON ) MakeIcon_Numerical( ( DWORD ) hb_parnl( 1 ), 
		( FLOAT ) hb_parnd( 2 ), ( BOOL ) hb_parl( 3 ), ( INT ) hb_parni( 4 ), ( INT ) hb_parni( 5 ) ) ;

	HB_RETNL( ( LONG_PTR ) himage );
}

#pragma ENDDUMP
