/*
 * PaintDegrade() v1.0
 *
 * Degradado de Colores en Ventanas / Dialogos
 * Basado en un trabajo de TheFull
 *
 * Daniel Andrade - 19/03/2003
 * C�digo FREE
 *
 */
// ------------------------------------------------------------------*
// Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

#include "minigui.ch"

#define CLR_RED             128               // RGB( 128,   0,   0 )
#define CLR_GREEN         32768               // RGB(   0, 128,   0 )
#define CLR_BLUE        8388608               // RGB(   0,   0, 128 )
#define CLR_CYAN        8421376               // RGB(   0, 128, 128 )
#define CLR_MAGENTA     8388736               // RGB( 128,   0, 128 )
#define CLR_BROWN         32896               // RGB( 128, 128,   0 )
#define CLR_GRAY        8421504               // RGB( 128, 128, 128 )

STATIC lDegPure := .F., lDegInvert := .T., lDegZigZag := .T., nDegColor

FUNCTION Main()

   LOCAL aColor, nPos

   nPos      := 1
   aColor    := { CLR_RED, CLR_GREEN, CLR_BLUE, CLR_CYAN, CLR_MAGENTA, CLR_BROWN, CLR_GRAY }
   nDegColor := aColor[ nPos ]

   DEFINE WINDOW Form_Main ;
      AT 0, 0 ;
      WIDTH 600 HEIGHT 400 ;
      TITLE 'Ejemplo Degradado en Ventanas' ;
      MAIN ;
      ON PAINT paint_it( This.Handle )

   DEFINE MAIN MENU

      DEFINE POPUP "&Opciones"

         MENUITEM "Color &Puro" NAME Item_1 ;
            ACTION ( Form_Main.Item_1.Checked := ( lDegPure := ! lDegPure ), refresh_it( ThisWindow.Handle ) )

         Form_Main.Item_1.Checked := lDegPure

         MENUITEM "Pintado &Invertido" NAME Item_2 ;
            ACTION ( Form_Main.Item_2.Checked := ( lDegInvert := ! lDegInvert ), refresh_it( ThisWindow.Handle ) )

         Form_Main.Item_2.Checked := lDegInvert

         MENUITEM "Pintado &ZigZag" NAME Item_3 ;
            ACTION ( Form_Main.Item_3.Checked := ( lDegZigZag := ! lDegZigZag ), refresh_it( ThisWindow.Handle ) )

         Form_Main.Item_3.Checked := lDegZigZag

         MENUITEM "Cambiar &Color" ;
            ACTION ( nPos := iif( nPos >= 7, 1, nPos + 1 ), nDegColor := aColor[ nPos ], refresh_it( ThisWindow.Handle ) )

         SEPARATOR

         MENUITEM "&Salir" ACTION Form_Main.Release

      END POPUP

      DEFINE POPUP 'H&elp'

         ITEM 'About' ACTION MsgInfo ( "Free GUI Library For Harbour", "MiniGUI PaintDegrade() Demo" )

      END POPUP

   END MENU

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

RETURN NIL

/*
*/
FUNCTION paint_it( hWnd )

   PaintDegrade( hWnd, nDegColor, 4, lDegPure, lDegInvert, lDegZigZag )

RETURN NIL

#define WM_PAINT 15

/*
*/
FUNCTION refresh_it( hWnd )

   SendMessage( hWnd, WM_PAINT, 0, 0 )

RETURN NIL

/*
 * C-level
*/
#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( PAINTDEGRADE )
{
   HWND     hWnd    = ( HWND ) hb_parni( 1 );
   COLORREF nColor  = hb_parnl( 2 );
   int      nJumps  = hb_parnl( 3 );
   BOOL     lPure   = hb_parl( 4 );
   BOOL     lInvert = hb_parl( 5 );
   BOOL     lZigZag = hb_parl( 6 );
   HDC      hDC;
   RECT     rct;
   int      nBlue, nGreen, nRed;
   HBRUSH   hBrush;
   int      nTop, nBottom, nSteps, nFor;
   BOOL     bRepaint = FALSE;

   GetClientRect( hWnd, &rct );
   hDC = GetDC( hWnd );

   if( lPure )
   {
      hBrush = CreateSolidBrush( nColor );
      FillRect( hDC, &rct, hBrush );
      DeleteObject( hBrush );
   }
   else
   {
      nTop    = rct.top;
      nBottom = rct.bottom;

      nRed   = GetRValue( nColor );
      nGreen = GetGValue( nColor );
      nBlue  = GetBValue( nColor );

      nSteps  = ( ( nBottom - nTop ) / nJumps );
      nSteps -= ( nSteps % 2 == 0 ? 0 : 1 );

      rct.bottom = 0;

      for( nFor = 0; nFor <= nSteps; nFor++ )
      {
         rct.bottom += nJumps;

         hBrush = CreateSolidBrush( RGB( nRed, nGreen, nBlue ) );
         FillRect( hDC, &rct, hBrush );
         DeleteObject( hBrush );

         rct.top += nJumps;

         if( lZigZag && nFor == ( nSteps / 2 ) )
            lInvert = ! lInvert;

         if( lInvert )
         {
            nBlue  += ( nBlue < 255 ? 1 : 0 );
            nGreen += ( nGreen < 255 ? 1 : 0 );
            nRed   += ( nRed < 255 ? 1 : 0 );
         }
         else
         {
            nBlue  -= ( nBlue > 0 ? 1 : 0 );
            nGreen -= ( nGreen > 0 ? 1 : 0 );
            nRed   -= ( nRed > 0 ? 1 : 0 );
         }
      }
      InvalidateRect( hWnd, &rct, bRepaint );
   }

   ReleaseDC( hWnd, hDC );
}

#pragma ENDDUMP
