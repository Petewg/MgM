/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   GETBOX Control Source Code
   Copyright 2006 Jacek Kubica <kubica@wssk.wroc.pl>
   http://www.wssk.wroc.pl/~kubica

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
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>
#include <commctrl.h>
#include "richedit.h"
#include "hbapiitm.h"
#include "hbstack.h"
#include "hbvm.h"

#ifndef WC_EDIT
#define WC_EDIT    "Edit"
#define WC_BUTTON  "Button"
#endif

#ifdef MAKELONG
#undef MAKELONG
#endif
#define MAKELONG( a, b )  ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

#define GBB1       2
#define GBB2       3

LRESULT CALLBACK  OwnGetProc( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam );

extern HINSTANCE g_hInstance;

HB_FUNC( INITGETBOX )
{
   HWND hwnd;                    // Handle of the parent window/form.
   HWND hedit;                   // Handle of the child window/control.
   int  iStyle;                  // GETBOX window base style.
   int  ibtnStyle1, ibtnStyle2;  // BUTTON window base style.
   HWND himage, himage2;
   HWND hBtn1, hBtn2;
   BOOL fBtns, fBtn2;
   int  BtnWidth  = 0;
   int  BtnWidth2 = 0;

   fBtns = hb_parl( 20 );
   fBtn2 = hb_parl( 22 );

   // Get the handle of the parent window/form.

   hwnd = ( HWND ) HB_PARNL( 1 );
   if( fBtns )
   {
      BtnWidth  = ( HB_ISNIL( 19 ) ? 0 : ( int ) hb_parni( 19 ) );
      BtnWidth  = ( BtnWidth >= GetSystemMetrics( SM_CYSIZE ) ? BtnWidth : GetSystemMetrics( SM_CYSIZE ) );
      BtnWidth2 = ( fBtn2 ? BtnWidth : 0 );
   }
   iStyle = WS_CHILD | ES_AUTOHSCROLL | WS_CLIPCHILDREN;

   if( hb_parl( 12 ) )  // if <lNumeric> is TRUE, then ES_NUMBER style is added.
      iStyle = iStyle | ES_NUMBER;

   // Set to a numeric TEXTBOX, so don't worry about other "textual" styles.

   else
   {
      if( hb_parl( 10 ) ) // if <lUpper> is TRUE, then ES_UPPERCASE style is added.
         iStyle = iStyle | ES_UPPERCASE;

      if( hb_parl( 11 ) ) // if <lLower> is TRUE, then ES_LOWERCASE style is added.
         iStyle = iStyle | ES_LOWERCASE;
   }

   if( hb_parl( 13 ) )  // if <lPassword> is TRUE, then ES_PASSWORD style is added.
      iStyle = iStyle | ES_PASSWORD;

   if( hb_parl( 14 ) )
      iStyle = iStyle | ES_RIGHT;

   if( hb_parl( 15 ) )
      iStyle = iStyle | ES_READONLY;

   if( ! hb_parl( 16 ) )
      iStyle = iStyle | WS_VISIBLE;

   if( ! hb_parl( 17 ) )
      iStyle = iStyle | WS_TABSTOP;

   // Creates the child control.

   hedit = CreateWindowEx
           (
      hb_parl( 23 ) ? 0 : WS_EX_CLIENTEDGE,
      WC_EDIT,
      "",
      iStyle,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      ( HWND ) hwnd,
      ( HMENU ) NULL,
      g_hInstance,
      NULL
           );

   SetProp( ( HWND ) hedit, "OldWndProc", ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SetWindowLongPtr( hedit, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnGetProc );

   SendMessage( hedit, ( UINT ) EM_LIMITTEXT, ( WPARAM ) hb_parni( 9 ), ( LPARAM ) 0 );

   if( hb_parc( 18 ) != NULL )
   {
      himage = ( HWND ) LoadImage( g_hInstance, hb_parc( 18 ), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage == NULL )
         himage = ( HWND ) LoadImage( 0, hb_parc( 18 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage != NULL )
      {
         BITMAP bm;
         GetObject( himage, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth - 4 || bm.bmHeight > hb_parni( 6 ) - 5 )
         {
            DeleteObject( himage );
            himage = ( HWND ) LoadImage( g_hInstance, hb_parc( 18 ), IMAGE_BITMAP, BtnWidth - 4, hb_parni(
                                            6 ) - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
            if( himage == NULL )
               himage = ( HWND ) LoadImage( 0, hb_parc( 18 ), IMAGE_BITMAP, BtnWidth - 4, hb_parni(
                                               6 ) - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage = NULL;

   if( hb_parc( 21 ) != NULL )
   {
      himage2 = ( HWND ) LoadImage( g_hInstance, hb_parc( 21 ), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 == NULL )
         himage2 = ( HWND ) LoadImage( 0, hb_parc( 21 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

      if( himage2 != NULL )
      {
         BITMAP bm;
         GetObject( himage2, sizeof( BITMAP ), &bm );
         if( bm.bmWidth > BtnWidth2 - 4 || bm.bmHeight > hb_parni( 6 ) - 5 )
         {
            DeleteObject( himage2 );
            himage2 = ( HWND ) LoadImage( g_hInstance, hb_parc( 21 ), IMAGE_BITMAP, BtnWidth2 - 4, hb_parni(
                                             6 ) - 6, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

            if( himage2 == NULL )
               himage2 = ( HWND ) LoadImage( 0, hb_parc( 21 ), IMAGE_BITMAP, BtnWidth2 - 4, hb_parni(
                                                6 ) - 6, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
         }
      }
   }
   else
      himage2 = NULL;

   ibtnStyle1 = BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE;

   if( himage != NULL )
      ibtnStyle1 = ibtnStyle1 | BS_BITMAP;

   ibtnStyle2 = BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE;

   if( himage2 != NULL )
      ibtnStyle2 = ibtnStyle2 | BS_BITMAP;

   if( fBtns )
      hBtn1 = CreateWindow
                 ( WC_BUTTON,
                 "...",
                 ibtnStyle1,
                 hb_parni( 5 ) - BtnWidth - 3,
                 -1,
                 BtnWidth,
                 hb_parni( 6 ) - 2,
                 ( HWND ) hedit,
                 ( HMENU ) GBB1,
                 g_hInstance,
                 NULL
                 );
   else
      hBtn1 = 0;

   if( fBtn2 )
      hBtn2 = CreateWindow
                 ( WC_BUTTON,
                 "...",
                 ibtnStyle2,
                 hb_parni( 5 ) - BtnWidth - BtnWidth2 - 3,
                 -1,
                 BtnWidth,
                 hb_parni( 6 ) - 2,
                 ( HWND ) hedit,
                 ( HMENU ) GBB2,
                 g_hInstance,
                 NULL
                 );
   else
      hBtn2 = 0;

   if( himage != NULL )
      SendMessage( hBtn1, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   if( himage2 != NULL )
      SendMessage( hBtn2, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage2 );

   SendMessage( hedit, EM_SETMARGINS, EC_LEFTMARGIN | EC_RIGHTMARGIN, MAKELONG( 0, BtnWidth + BtnWidth2 + 2 ) );

   hb_reta( 5 );
   HB_STORVNL( ( LONG_PTR ) hedit, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) hBtn1, -1, 2 );
   HB_STORVNL( ( LONG_PTR ) hBtn2, -1, 3 );
   HB_STORVNL( ( LONG_PTR ) himage, -1, 4 );
   HB_STORVNL( ( LONG_PTR ) himage2, -1, 5 );
}

HB_FUNC( CHECKBIT )
{
   hb_retl( hb_parnl( 1 ) & ( 1 << ( hb_parni( 2 ) - 1 ) ) );
}

HB_FUNC( GETTEXTHEIGHT )               // returns the height of a string in pixels
{
   HDC   hDC        = ( HDC ) HB_PARNL( 1 );
   HWND  hWnd       = ( HWND ) NULL;
   BOOL  bDestroyDC = FALSE;
   HFONT hFont      = ( HFONT ) HB_PARNL( 3 );
   HFONT hOldFont   = ( HFONT ) NULL;
   SIZE  sz;

   if( ! hDC )
   {
      bDestroyDC = TRUE;
      hWnd       = GetActiveWindow();
      hDC        = GetDC( hWnd );
   }

   if( hFont )
      hOldFont = ( HFONT ) SelectObject( hDC, hFont );

   GetTextExtentPoint32( hDC, hb_parc( 2 ), hb_parclen( 2 ), &sz );

   if( hFont )
      SelectObject( hDC, hOldFont );

   if( bDestroyDC )
      ReleaseDC( hWnd, hDC );

   hb_retni( sz.cy );
}

LRESULT CALLBACK OwnGetProc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hwnd, "OldWndProc" );
   switch( Msg )
   {
      case WM_NCDESTROY:
         return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );

      case WM_GETDLGCODE:
         return DLGC_WANTALLKEYS + DLGC_WANTARROWS + DLGC_WANTCHARS + DLGC_HASSETSEL;

      case EM_DISPLAYBAND:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );
         if( r != 0 )
            return r;
         else
            return DefWindowProc( hwnd, Msg, wParam, lParam );

      case WM_CHAR:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return DefWindowProc( hwnd, Msg, wParam, lParam );

      case EM_CANPASTE:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );
         if( r != 0 )
            return r;
         else
            return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );

      case WM_PASTE:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return DefWindowProc( hwnd, Msg, wParam, lParam );

      case WM_KILLFOCUS:
      case WM_SETFOCUS:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );

      case WM_KEYDOWN:
      case WM_KEYUP:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return DefWindowProc( hwnd, Msg, wParam, lParam );

      case WM_CUT:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hwnd );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         if( r != 0 )
            return r;
         else
            return DefWindowProc( hwnd, Msg, wParam, lParam );

      case WM_COMMAND:
         if( lParam != 0 && HIWORD( wParam ) == BN_CLICKED )
         {
            if( ! pSymbol )
               pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OGETEVENTS" ) );

            if( pSymbol )
            {
               hb_vmPushSymbol( pSymbol );
               hb_vmPushNil();
               hb_vmPushNumInt( ( LONG_PTR ) hwnd );
               hb_vmPushLong( Msg );
               hb_vmPushNumInt( wParam );
               hb_vmPushNumInt( lParam );
               hb_vmDo( 4 );
            }

            r = hb_parnl( -1 );
            if( r )
               return TRUE;
            else
               return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
         }
   }
   return CallWindowProc( OldWndProc, hwnd, Msg, wParam, lParam );
}
