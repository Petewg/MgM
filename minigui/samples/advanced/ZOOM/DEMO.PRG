/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2012 Rossine <qiinfo@ig.com.br>
*/

#include "minigui.ch"

#define SRCCOPY  0x00CC0020

**************
PROCEDURE Main
**************

   DEFINE WINDOW Form_1 ;
      MAIN ;
      CLIENTAREA 550, 350 ;
      TITLE 'Zoom' ;
      NOMAXIMIZE NOSIZE

      DEFINE LABEL Label_1
         ROW 5
         COL 5
         WIDTH 120
         HEIGHT 40
         VALUE ""
         CLIENTEDGE .T.
      END LABEL

      DEFINE LABEL Label_2
         ROW 50
         COL 5
         WIDTH 120
         HEIGHT 30
         VALUE ""
         FONTNAME "Courier New"
         FONTSIZE 12
         FONTBOLD .T.
         FONTCOLOR { 255, 255, 255 }
         BACKCOLOR { 000, 105, 000 }
         CENTERALIGN .T.
         CLIENTEDGE .T.
      END LABEL

      DEFINE MAIN MENU

         POPUP 'Zoom'

         ITEM 'Factor 1' NAME Factor1 ACTION check_menu( 1 )
         ITEM 'Factor 2' NAME Factor2 ACTION check_menu( 2 )
         ITEM 'Factor 3' NAME Factor3 ACTION check_menu( 3 ) CHECKED
         ITEM 'Factor 4' NAME Factor4 ACTION check_menu( 4 )
         ITEM 'Factor 5' NAME Factor5 ACTION check_menu( 5 )
         SEPARATOR
         ITEM 'Exit' ACTION Form_1.Release

         END POPUP

      END MENU

      ON KEY ESCAPE ACTION ThisWindow.Release()

      DEFINE TIMER oTimer INTERVAL 40 ACTION ZoomImage()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

*************************************
STATIC FUNCTION check_menu( nFactor )
*************************************

   LOCAL n

   FOR n := 1 TO 5
      SetProperty( "Form_1", "Factor" + Str( n, 1 ), "Checked", ( n == nFactor ) )
   NEXT

RETURN NIL

*************************
STATIC FUNCTION GetZoom()
*************************

   LOCAL n
   LOCAL nZoom := 3

   FOR n := 1 TO 5
      IF GetProperty( "Form_1", "Factor" + Str( n, 1 ), "Checked" ) == .T.
         nZoom := n
         EXIT
      ENDIF
   NEXT

RETURN nZoom

***************************
STATIC FUNCTION ZoomImage()
***************************

   LOCAL nZoom
   LOCAL hDeskTop
   LOCAL aPos
   LOCAL hWnd
   LOCAL hDC
   LOCAL hPen
   LOCAL hOldPen, aColor
   LOCAL nTop, nLeft, nWidth, nHeight

   nZoom := GetZoom()

   hDeskTop := GetDC( 0 )

   aPos := GetCursorPos()

   aColor := nRGB2Arr( GetPixel( hDeskTop, aPos[ 2 ], aPos[ 1 ] ) )
   Form_1.Label_1.Backcolor := aColor
   Form_1.Label_2.Value := StrZero( aColor[ 1 ], 3 ) + "," + StrZero( aColor[ 2 ], 3 ) + "," + StrZero( aColor[ 3 ], 3 )

   hWnd := ThisWindow.Handle
   hDC := GetDC( hWnd )
   hPen := CreatePen( 0, 1, 255 )

   nTop := 10
   nLeft := 130
   nWidth := 400
   nHeight := 300

   Moveto( hDC, nLeft - 1, nTop - 1 )
   Lineto( hDC, nLeft + nWidth, nTop - 1 )
   Lineto( hDC, nLeft + nWidth, nTop + nHeight )
   Lineto( hDC, nLeft - 1, nTop + nHeight )
   Lineto( hDC, nLeft - 1, nTop - 1 )

   StretchBlt( hDC, nLeft, nTop, nWidth, nHeight, hDeskTop, aPos[ 2 ] - nWidth / ( 2 * nZoom ), aPos[ 1 ] - nHeight / ( 2 * nZoom ), nWidth / nZoom, nHeight / nZoom, SRCCOPY )

   hOldPen := SelectObject( hDC, hPen )

   Moveto( hDC, nLeft + nWidth / 2 + 1, nTop - 1 )
   Lineto( hDC, nLeft + nWidth / 2 + 1, nTop + nHeight + 1 )

   Moveto( hDC, nLeft + 1, nTop + nHeight / 2 + 1 )
   Lineto( hDC, nLeft + nWidth + 1, nTop + nHeight / 2 + 1 )

   SelectObject( hDC, hOldPen )
   DeleteObject( hPen )

   ReleaseDC( hWnd, hDC )

   ReleaseDC( 0, hDeskTop )

RETURN NIL


#pragma BEGINDUMP

#include "mgdefs.h"

HB_FUNC( STRETCHBLT )
{
   hb_retl( StretchBlt( ( HDC ) HB_PARNL( 1 ) ,
                        hb_parni( 2 ) ,
                        hb_parni( 3 ) ,
                        hb_parni( 4 ) ,
                        hb_parni( 5 ) ,
                        ( HDC ) HB_PARNL( 6 ) ,
                        hb_parni( 7 ) ,
                        hb_parni( 8 ) ,
                        hb_parni( 9 ) ,
                        hb_parni( 10 ) ,
                        ( DWORD ) hb_parnl( 11 )
                        ) );
}

HB_FUNC( GETPIXEL )
{
   hb_retnl( GetPixel( ( HDC ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

#pragma ENDDUMP
