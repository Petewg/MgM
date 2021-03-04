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
    Copyright 1999-2021, https://harbour.github.io/

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

LRESULT APIENTRY  LabelSubClassFunc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam );
static WNDPROC LabelOldWndProc;

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetInstance( void );

HB_FUNC( INITLABEL )
{
   HWND hWnd;
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );

   int Style   = WS_CHILD;
   int ExStyle = 0;

   if( hb_parl( 9 ) || hb_parl( 10 ) )
      Style |= SS_NOTIFY;

   if( hb_parl( 11 ) )
      Style |= WS_BORDER;

   if( hb_parl( 13 ) )
      Style |= WS_HSCROLL;

   if( hb_parl( 14 ) )
      Style |= WS_VSCROLL;

   if( ! hb_parl( 16 ) )
      Style |= WS_VISIBLE;

   if( hb_parl( 17 ) )
      Style |= ES_RIGHT;

   if( hb_parl( 18 ) )
      Style |= ES_CENTER;

   if( hb_parl( 19 ) )
      Style |= SS_CENTERIMAGE;

   if( hb_parl( 20 ) )
      Style |= SS_NOPREFIX;

   if( hb_parl( 12 ) )
      ExStyle |= WS_EX_CLIENTEDGE;

   if( hb_parl( 15 ) )
      ExStyle |= WS_EX_TRANSPARENT;

   hWnd = CreateWindowEx( ExStyle,
                          WC_STATIC,
#ifndef UNICODE
                          hb_parc( 2 ),
#else
                          AnsiToWide( ( char * ) hb_parc( 2 ) ),
#endif
                          Style,
                          hb_parni( 4 ),
                          hb_parni( 5 ),
                          hb_parni( 6 ),
                          hb_parni( 7 ),
                          hWndParent,
                          ( HMENU ) HB_PARNL( 3 ),
                          GetInstance(),
                          NULL );

   if( hb_parl( 10 ) )
      LabelOldWndProc = ( WNDPROC ) SetWindowLongPtr( ( HWND ) hWnd, GWLP_WNDPROC, ( LONG_PTR ) LabelSubClassFunc );

   HB_RETNL( ( LONG_PTR ) hWnd );
}

#define _OLD_STYLE  0
LRESULT APIENTRY LabelSubClassFunc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   TRACKMOUSEEVENT tme;
   static PHB_SYMB pSymbol        = NULL;
   static BOOL     bMouseTracking = FALSE;
   long r = 0;

#if _OLD_STYLE
   BOOL bCallUDF = FALSE;
#endif
   if( Msg == WM_MOUSEMOVE || Msg == WM_MOUSELEAVE )
   {
      if( Msg == WM_MOUSEMOVE )
      {
         if( bMouseTracking == FALSE )
         {
            tme.cbSize      = sizeof( TRACKMOUSEEVENT );
            tme.dwFlags     = TME_LEAVE;
            tme.hwndTrack   = hWnd;
            tme.dwHoverTime = HOVER_DEFAULT;

            if( _TrackMouseEvent( &tme ) == TRUE )
            {
#if _OLD_STYLE
               bCallUDF = TRUE;
#endif
               bMouseTracking = TRUE;
            }
#if _OLD_STYLE
         }
         else
         {
            bCallUDF = FALSE;
#endif
         }
      }
      else
      {
#if _OLD_STYLE
         bCallUDF = TRUE;
#endif
         bMouseTracking = FALSE;
      }
#if _OLD_STYLE
      if( bCallUDF == TRUE )
      {
#endif
      if( ! pSymbol )
         pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OLABELEVENTS" ) );

      if( pSymbol && hb_vmRequestReenter() )
      {
         hb_vmPushSymbol( pSymbol );
         hb_vmPushNil();
         hb_vmPushNumInt( ( LONG_PTR ) hWnd );
         hb_vmPushLong( Msg );
         hb_vmPushNumInt( wParam );
         hb_vmPushNumInt( lParam );
         hb_vmDo( 4 );

         r = hb_parnl( -1 );

         hb_vmRequestRestore();
      }
#if _OLD_STYLE
   }
#endif
      return ( r != 0 ) ? r : CallWindowProc( LabelOldWndProc, hWnd, 0, 0, 0 );
   }

   bMouseTracking = FALSE;

   return CallWindowProc( LabelOldWndProc, hWnd, Msg, wParam, lParam );
}
#undef _OLD_STYLE
