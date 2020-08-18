/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2020, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include <commctrl.h>
#include "hbapiitm.h"
#include "hbvm.h"

#ifndef WC_STATIC
#define WC_STATIC  "Static"
#endif

LRESULT APIENTRY ChkLabelFunc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam );
static WNDPROC LabelOldWndProc;

extern HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                                HB_BOOL bAlphaFormat, int iAlpfaConstant );
HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

typedef struct
{
   BOOL    lCheck;                        // is checked ?
   WNDPROC oldproc;                       // need to remember the old window procedure
   int     cxLeftEdge, cxRightEdge;       // size of the current window borders.
   int     cxButton;
   int     cxSpace;
   BOOL    lLeftCheck;
   HBITMAP himage;
   HBITMAP himagemask;
   HBITMAP himage2;
   HBITMAP himagemask2;
} INSCHK, * PINSCHK;


HBITMAP CreateBitmapMask( HBITMAP hbmColour, COLORREF crTransparent )
{
   HDC     hdcMem, hdcMem2;
   HBITMAP hbmMask;
   BITMAP  bm;

   GetObject( hbmColour, sizeof( BITMAP ), &bm );
   hbmMask = CreateBitmap( bm.bmWidth, bm.bmHeight, 1, 1, NULL );

   hdcMem  = CreateCompatibleDC( 0 );
   hdcMem2 = CreateCompatibleDC( 0 );

   SelectObject( hdcMem, hbmColour );
   SelectObject( hdcMem2, hbmMask );

   SetBkColor( hdcMem2, crTransparent );

   BitBlt( hdcMem2, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY );

   BitBlt( hdcMem, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem2, 0, 0, SRCINVERT );

   DeleteDC( hdcMem );
   DeleteDC( hdcMem2 );

   return hbmMask;
}

void GetCheck( INSCHK * pbtn, RECT * rect )
{

   if( ! ( pbtn->lLeftCheck ) )
      rect->left = rect->right - pbtn->cxButton;
   else
      rect->right = rect->left + pbtn->cxButton;

   if( pbtn->cxRightEdge > pbtn->cxLeftEdge )
      OffsetRect( rect, pbtn->cxRightEdge - pbtn->cxLeftEdge, 0 );

}

BOOL InsertCheck( HWND hWnd, HBITMAP himage, HBITMAP himage2, int BtnWidth, BOOL lCheck, BOOL lLeftCheck )
{
   INSCHK * pbtn;

   pbtn = ( INSCHK * ) HeapAlloc( GetProcessHeap(), 0, sizeof( INSCHK ) );

   if( ! pbtn )
      return FALSE;

   pbtn->lCheck     = lCheck;
   pbtn->lLeftCheck = lLeftCheck;
   pbtn->cxButton   = HB_MAX( BtnWidth, GetSystemMetrics( SM_CXVSCROLL ) );
   pbtn->himage     = himage;
   pbtn->himage2    = himage2;
   pbtn->cxSpace    = GetSystemMetrics( SM_CXSIZEFRAME ) / 4;

   if( himage != NULL )
      pbtn->himagemask = CreateBitmapMask( himage, RGB( 0, 0, 0 ) );
   else
      pbtn->himagemask = NULL;

   if( himage2 != NULL )
      pbtn->himagemask2 = CreateBitmapMask( himage2, RGB( 0, 0, 0 ) );
   else
      pbtn->himagemask2 = NULL;

   // associate our button state structure with the window

   SetWindowLongPtr( hWnd, GWLP_USERDATA, ( LONG_PTR ) pbtn );

   // force the edit control to update its non-client area

   SetWindowPos( hWnd, 0, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOZORDER );

   return TRUE;
}

static void DrawCheck( HWND hWnd, INSCHK * pbtn, RECT * prect )
{
   HDC     hdc;
   HBITMAP hBitmap      = pbtn->himage;
   HBITMAP hBitmapMask  = pbtn->himagemask;
   HBITMAP hBitmap2     = pbtn->himage2;
   HBITMAP hBitmapMask2 = pbtn->himagemask2;
   BITMAP  bm;

   hdc = GetWindowDC( hWnd );

   if( hBitmap == NULL )
   {
      FillRect( hdc, prect, GetSysColorBrush( COLOR_WINDOW ) );
      SetBkMode( hdc, TRANSPARENT );
      DrawText( hdc, "V", 1, prect, DT_CENTER | DT_VCENTER | DT_SINGLELINE );
   }
   else
   {
      int wRow = prect->top;
      int wCol = prect->left;

      HDC hdcMem = CreateCompatibleDC( hdc );

      if( pbtn->lCheck )
      {
         HBITMAP hbmOld = ( HBITMAP ) SelectObject( hdcMem, hBitmapMask );
         GetObject( hBitmap, sizeof( bm ), &bm );

         BitBlt( hdc, wCol, wRow, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCAND );

         SelectObject( hdcMem, hBitmap );
         BitBlt( hdc, wCol, wRow, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCPAINT );
         SelectObject( hdcMem, hbmOld );
      }
      else if( hBitmap2 != NULL )
      {
         HBITMAP hbmOld = ( HBITMAP ) SelectObject( hdcMem, hBitmapMask2 );
         GetObject( hBitmap2, sizeof( bm ), &bm );

         BitBlt( hdc, wCol, wRow, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCAND );

         SelectObject( hdcMem, hBitmap2 );
         BitBlt( hdc, wCol, wRow, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCPAINT );
         SelectObject( hdcMem, hbmOld );
      }
      DeleteDC( hdcMem );

   }

   ReleaseDC( hWnd, hdc );
}

HB_FUNC( INITCHKLABEL )
{
   HWND    hwnd;
   HWND    hbutton;
   HBITMAP himage;
   HBITMAP himage2;

   int BtnWidth = hb_parni( 7 );

   int Style   = WS_CHILD | SS_NOTIFY;
   int ExStyle = 0;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 12 ) )
      ExStyle = ExStyle | WS_EX_CLIENTEDGE;

   if( hb_parl( 11 ) )
      Style |= WS_BORDER;

   if( hb_parl( 13 ) )
      Style |= WS_HSCROLL;

   if( hb_parl( 14 ) )
      Style |= WS_VSCROLL;

   if( hb_parl( 15 ) )
      ExStyle = ExStyle | WS_EX_TRANSPARENT;

   if( ! hb_parl( 16 ) )
      Style |= WS_VISIBLE;

   if( hb_parl( 17 ) )
      Style |= ES_RIGHT;

   if( hb_parl( 18 ) )
      Style |= ES_CENTER;

   if( hb_parl( 23 ) )
      Style |= SS_CENTERIMAGE;

   hbutton = CreateWindowEx
             (
      ExStyle,
      WC_STATIC,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hb_parni( 7 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   if( hb_parc( 19 ) != NULL )
      himage = HMG_LoadPicture( hb_parc( 19 ), -1, -1, NULL, 0, 0, -1, 0, HB_FALSE, 255 );
   else
      himage = NULL;

   if( hb_parc( 20 ) != NULL )
      himage2 = HMG_LoadPicture( hb_parc( 20 ), -1, -1, NULL, 0, 0, -1, 0, HB_FALSE, 255 );
   else
      himage2 = NULL;

   InsertCheck( hbutton, himage, himage2, BtnWidth, hb_parl( 22 ), hb_parl( 21 ) );

   LabelOldWndProc = ( WNDPROC ) SetWindowLongPtr( ( HWND ) hbutton, GWLP_WNDPROC, ( LONG_PTR ) ChkLabelFunc );
   SetWindowPos( hbutton, 0, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOZORDER );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( SETCHKLABEL )
{
   HWND     hWnd = ( HWND ) HB_PARNL( 1 );
   INSCHK * pbtn = ( INSCHK * ) GetWindowLongPtr( hWnd, GWLP_USERDATA );
   RECT     rect;

   pbtn->lCheck = hb_parl( 2 );

   GetWindowRect( hWnd, &rect );
   OffsetRect( &rect, -rect.left, -rect.top );
   ShowWindow( hWnd, SW_HIDE );
   InvalidateRect( hWnd, &rect, TRUE );

   GetCheck( pbtn, &rect );
   DrawCheck( hWnd, pbtn, &rect );
   ShowWindow( hWnd, SW_SHOW );
}

HB_FUNC( GETCHKLABEL )
{
   HWND     hWnd = ( HWND ) HB_PARNL( 1 );
   INSCHK * pbtn = ( INSCHK * ) GetWindowLongPtr( hWnd, GWLP_USERDATA );

   hb_retl( ( BOOL ) pbtn->lCheck );
}

LRESULT APIENTRY ChkLabelFunc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   RECT *          prect;
   RECT oldrect;
   RECT rect;
   TRACKMOUSEEVENT tme;

   INSCHK * pbtn = ( INSCHK * ) GetWindowLongPtr( hWnd, GWLP_USERDATA );

   switch( Msg )
   {
      case WM_NCCALCSIZE:
         prect   = ( RECT * ) lParam;
         oldrect = *prect;

         CallWindowProc( LabelOldWndProc, hWnd, Msg, wParam, lParam );
         SendMessage( hWnd, WM_SETREDRAW, 1, 0 );
         if( ! pbtn )
            return 0;

         if( pbtn->lLeftCheck )
         {
            pbtn->cxLeftEdge  = prect->left - oldrect.left;
            pbtn->cxRightEdge = oldrect.right - prect->right;
            prect->left      += pbtn->cxButton + pbtn->cxSpace;
         }
         else
         {
            pbtn->cxLeftEdge  = prect->left - oldrect.left;
            pbtn->cxRightEdge = oldrect.right - prect->right;
            prect->right     -= pbtn->cxButton + pbtn->cxSpace;
         }

         return 0;

      case WM_NCPAINT:
         CallWindowProc( LabelOldWndProc, hWnd, Msg, wParam, lParam );
         if( pbtn->lCheck )
         {
            GetWindowRect( hWnd, &rect );
            OffsetRect( &rect, -rect.left, -rect.top );
            GetCheck( pbtn, &rect );
            DrawCheck( hWnd, pbtn, &rect );
         }
         else
         if( pbtn->himage2 != NULL )
         {
            GetWindowRect( hWnd, &rect );
            OffsetRect( &rect, -rect.left, -rect.top );
            GetCheck( pbtn, &rect );
            DrawCheck( hWnd, pbtn, &rect );
         }
         return 0;

      case WM_MOUSEMOVE:
         tme.cbSize      = sizeof( TRACKMOUSEEVENT );
         tme.dwFlags     = TME_LEAVE;
         tme.hwndTrack   = hWnd;
         tme.dwHoverTime = HOVER_DEFAULT;
         _TrackMouseEvent( &tme );

         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OLABELEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hWnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         return ( r != 0 ) ? r : CallWindowProc( LabelOldWndProc, hWnd, 0, 0, 0 );

      case WM_MOUSELEAVE:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OLABELEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hWnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         return ( r != 0 ) ? r : CallWindowProc( LabelOldWndProc, hWnd, 0, 0, 0 );
   }

   return CallWindowProc( LabelOldWndProc, hWnd, Msg, wParam, lParam );
}
