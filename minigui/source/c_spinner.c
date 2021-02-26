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
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2017, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#define _WIN32_IE  0x0501

#include <mgdefs.h>

#include <commctrl.h>

#include "hbvm.h"

#ifndef WC_EDIT
#define WC_EDIT               "Edit"
#endif

#if ( defined( __BORLANDC__ ) && _WIN32_WINNT >= 0x501 ) || defined ( __XCC__ )
#define ICC_STANDARD_CLASSES  0x00004000
#endif

LRESULT CALLBACK  OwnSpinProc( HWND hedit, UINT Msg, WPARAM wParam, LPARAM lParam );

HINSTANCE GetInstance( void );

HB_FUNC( INITSPINNER )
{
   HWND hwnd, hedit, hupdown;
   int  Style1 = ES_NUMBER | WS_CHILD | ES_AUTOHSCROLL;
   int  Style2 = WS_CHILD | WS_BORDER | UDS_ARROWKEYS | UDS_ALIGNRIGHT | UDS_SETBUDDYINT | UDS_NOTHOUSANDS;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_STANDARD_CLASSES;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 11 ) )
   {
      Style1 = Style1 | WS_VISIBLE;
      Style2 = Style2 | WS_VISIBLE;
   }

   if( ! hb_parl( 12 ) )
      Style1 = Style1 | WS_TABSTOP;

   if( hb_parl( 13 ) )
      Style2 = Style2 | UDS_WRAP;

   if( hb_parl( 14 ) )
      Style1 = Style1 | ES_READONLY;

   if( hb_parl( 15 ) )
      Style2 = Style2 | UDS_HORZ | UDS_ALIGNRIGHT;  /* P.Ch. 10.16. */

   hedit = CreateWindowEx
           (
      WS_EX_CLIENTEDGE,
      WC_EDIT,
      "",
      Style1,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 10 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
           );

   i.dwICC = ICC_UPDOWN_CLASS;  /* P.Ch. 10.16. */
   InitCommonControlsEx( &i );

   hupdown = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      UPDOWN_CLASS,
      "",
      Style2,
      hb_parni( 3 ) + hb_parni( 5 ),
      hb_parni( 4 ),
      15,
      hb_parni( 10 ),
      hwnd,
      ( HMENU ) 0,
      GetInstance(),
      NULL
             );

   SendMessage( hupdown, UDM_SETBUDDY, ( WPARAM ) hedit, ( LPARAM ) NULL );
   SendMessage( hupdown, UDM_SETRANGE32, ( WPARAM ) hb_parni( 8 ), ( LPARAM ) hb_parni( 9 ) );

   // 2006.08.13 JD
   SetProp( ( HWND ) hedit, "oldspinproc", ( HWND ) GetWindowLongPtr( ( HWND ) hedit, GWLP_WNDPROC ) );
   SetWindowLongPtr( hedit, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnSpinProc );

   hb_reta( 2 );
   HB_STORVNL( ( LONG_PTR ) hedit, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) hupdown, -1, 2 );
}

HB_FUNC( SETSPINNERINCREMENT )
{
   UDACCEL inc;

   inc.nSec = 0;
   inc.nInc = hb_parnl( 2 );

   SendMessage( ( HWND ) HB_PARNL( 1 ), UDM_SETACCEL, ( WPARAM ) 1, ( LPARAM ) &inc );
}

// 2006.08.13 JD
LRESULT CALLBACK OwnSpinProc( HWND hedit, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hedit, "oldspinproc" );

   switch( Msg )
   {
      case WM_DESTROY:
         SetWindowLongPtr( hedit, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OldWndProc );
         RemoveProp( hedit, "oldspinproc" );
         break;

      case WM_CONTEXTMENU:
      case WM_GETDLGCODE:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OSPINEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hedit );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );  /* P.Ch. 10.16. */

         return ( r != 0 ) ? r : CallWindowProc( OldWndProc, hedit, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hedit, Msg, wParam, lParam );
}
