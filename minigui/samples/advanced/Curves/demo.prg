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

#include "minigui.ch"

STATIC lBusy := .F.

//////////////////////////////////////////////////////////////////////////////
PROCEDURE Main()

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 800 HEIGHT 600 ;
      TITLE "Draw Curves - Contributed by Grigory Filatov" ;
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
         MENUITEM "Do it!" ACTION RefreshPaint()
         MENUITEM "Exit" ACTION ThisWindow.Release()
      END POPUP
   END MENU

   @ 10, Form_1.Width - 120 BUTTON Button_1 ;
      CAPTION 'Close' ;
      ACTION Form_1.Release

   END WINDOW

   CENTER   WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

//////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE OnInit

   Form_1.Button_1.Setfocus()

   CLEAN MEMORY

RETURN

//////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE RefreshPaint()

   lBusy := .F.

   Form_1.ReDraw()

RETURN

#define PS_SOLID  0
//////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION DrawCurves()

   STATIC nHeight, nWidth

   LOCAL hWnd := Form_1.Handle
   LOCAL hDC, pPS
   LOCAL nI, hPen, hOldPen
   LOCAL cPoints

   IF HB_ISNIL( nHeight )
      nHeight := Form_1.Height -20
      nWidth  := Form_1.Width  -20
   ENDIF

   IF ! lBusy .AND. GetUpdateRect(  hWnd, NIL ) /*Not INTERNALPAINT*/

      hDC := BeginPaint( hWnd, @pPS )

      FOR nI := 1 TO 20
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
      NEXT

      EndPaint( hWnd, pPS )

      lBusy := .T.

   ENDIF

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
#ifdef __XHARBOUR__
/*
 Declaration of DLLs using syntax in CallDll.Lib borrowed from HMG official
 Carlos Britos
*/

DECLARE PolyBezier( hDC, Points, Amount ) IN GDI32.DLL

DECLARE CreatePen( Style, Width, Color ) IN GDI32.DLL

#else

DECLARE DLL_TYPE_LONG PolyBezier( DLL_TYPE_LONG hDC, DLL_TYPE_LPSTR Points, DLL_TYPE_LONG Amount ) ;
      IN GDI32.DLL

DECLARE DLL_TYPE_LONG CreatePen( DLL_TYPE_LONG Style, DLL_TYPE_LONG Width, DLL_TYPE_LONG Color ) ;
      IN GDI32.DLL

#endif
