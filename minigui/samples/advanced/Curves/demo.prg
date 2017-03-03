/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#ifdef __XHARBOUR__
  #define __CALLDLL__
#endif

#include "hmg.ch"

#define PROGRAM 'Draw Curves'


Static lBusy := .f.

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 HEIGHT 600 ;
		TITLE PROGRAM + " - Contributed by Grigory Filatov" ;
		MAIN ;
		ICON "demo.ico" ;
		NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON INIT OnInit() ;
		ON PAINT DrawCurves() ;
		ON GOTFOCUS RefreshPaint() ;
		BACKCOLOR WHITE ;
		FONT "MS Sans Serif" SIZE 8

		DEFINE MAIN MENU
			DEFINE POPUP "Test"
			MENUITEM "Do it!"  ACTION RefreshPaint()
			MENUITEM "Exit"    ACTION ThisWindow.Release()
			END POPUP
		END MENU

		@ 10,Form_1.Width - 120 BUTTON Button_1 ;
		CAPTION 'Close' ;
		ACTION Form_1.Release

	END WINDOW

	Form_1.Center

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
PROCEDURE OnInit
*--------------------------------------------------------*

	Form_1.Button_1.Setfocus

	CLEAN MEMORY

RETURN

#define WM_PAINT	15
*--------------------------------------------------------*
Static Procedure RefreshPaint()
*--------------------------------------------------------*

	ERASE WINDOW Form_1

	lBusy := .F.

	SendMessage( _HMG_MainHandle, WM_PAINT, 0, 0 )

	DoEvents()

Return

#define PS_SOLID	0
*--------------------------------------------------------*
Function DrawCurves()
*--------------------------------------------------------*
local nHeight := Form_1.Height - 20, nWidth := Form_1.Width - 20
local hWnd := GetActiveWindow()
local hDC
local n, hPen, hOldPen
local cPoints

IF .NOT. lBusy

   hDC := GetDC( hWnd )

   for n := 1 to 20
      hPen    := CreatePen( PS_SOLID, 5, Random( 65535 ) )
      hOldPen := SelectObject( hDC, hPen )

      cPoints := L2Bin( Random( nWidth  ) ) + ;
                 L2Bin( Random( nHeight ) ) + ;
                 L2Bin( Random( nWidth  ) ) + ;
                 L2Bin( Random( nHeight ) ) + ;
                 L2Bin( Random( nWidth  ) ) + ;
                 L2Bin( Random( nHeight ) ) + ;
                 L2Bin( Random( nWidth  ) ) + ;
                 L2Bin( Random( nHeight ) )

      PolyBezier( hDC, cPoints, 4 )
      SelectObject( hDC, hOldPen )

      DeleteObject( hPen )
   next

   ReleaseDC( hWnd, hDC )

   lBusy := .T.

ENDIF

return nil


#ifdef __XHARBOUR__
/*
 Declaration of DLLs using syntax in CallDll.Lib borrowed from HMG official
 Carlos Britos
*/

  DECLARE GetDC( hWnd ) IN USER32.DLL

  DECLARE ReleaseDC( hWnd, hDC ) IN USER32.DLL

  DECLARE PolyBezier( hDC, Points, Amount ) IN GDI32.DLL

  DECLARE CreatePen( Style, Width, Color ) IN GDI32.DLL

  DECLARE SelectObject( hDC, hGDIobj ) IN GDI32.DLL

  DECLARE DeleteObject( hGDIobj ) IN GDI32.DLL

#else

  // DECLARE GetDC( hWnd ) IN USER32.DLL

  // DECLARE ReleaseDC( hWnd, hDC ) IN USER32.DLL

  // DECLARE static PolyBezier( hDC, Points, Amount ) IN GDI32.DLL

  // DECLARE CreatePen( Style, Width, Color ) IN GDI32.DLL

  // DECLARE SelectObject( hDC, hGDIobj ) IN GDI32.DLL

  // DECLARE DeleteObject( hGDIobj ) IN GDI32.DLL

 
 
// #include "hbdll32.ch"
// DECLARE  PolyBezier(  hDC,  Points,  Amount ) IN GDI32.DLL

#endif


STATIC FUNCTION PolyBezier( hDC, Points, Amount )
   RETURN CallDLL32( "PolyBezier", "GDI32.DLL", hDC, Points, Amount )


#pragma begindump
#include <mgdefs.h>
#include <windows.h>
#include <commctrl.h>

#include "hbapi.h"
#include "item.api"


HB_FUNC( CREATEPEN )
{
   HPEN     hpen;
   int      fnPenStyle = hb_parni( 1 );   // pen style
   int      nWidth     = hb_parni( 2 );   // pen width
   COLORREF crColor    = hb_parni( 3 );   // pen color

   hpen = CreatePen( fnPenStyle, nWidth, crColor );

   HB_RETNL( ( LONG_PTR ) hpen );
}
#pragma enddump
