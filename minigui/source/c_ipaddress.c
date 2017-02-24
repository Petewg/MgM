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

extern HINSTANCE g_hInstance;

HB_FUNC( INITIPADDRESS )
{
   HWND hWnd;
   HWND hIpAddress;
   int  Style = WS_CHILD;

   INITCOMMONCONTROLSEX icex;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_INTERNET_CLASSES;
   InitCommonControlsEx( &icex );

   hWnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 7 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 8 ) )
      Style = Style | WS_TABSTOP;

   hIpAddress = CreateWindowEx
                (
      WS_EX_CLIENTEDGE,
      WC_IPADDRESS,
      "",
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hWnd,
      ( HMENU ) HB_PARNL( 2 ),
      g_hInstance,
      NULL
                );

   HB_RETNL( ( LONG_PTR ) hIpAddress );
}

HB_FUNC( SETIPADDRESS )
{
   HWND hWnd;
   BYTE v1, v2, v3, v4;

   hWnd = ( HWND ) HB_PARNL( 1 );

   v1 = ( BYTE ) hb_parni( 2 );
   v2 = ( BYTE ) hb_parni( 3 );
   v3 = ( BYTE ) hb_parni( 4 );
   v4 = ( BYTE ) hb_parni( 5 );

   SendMessage( hWnd, IPM_SETADDRESS, 0, MAKEIPADDRESS( v1, v2, v3, v4 ) );
}

HB_FUNC( GETIPADDRESS )
{
   HWND  hWnd;
   DWORD pdwAddr;
   INT   v1, v2, v3, v4;

   hWnd = ( HWND ) HB_PARNL( 1 );

   SendMessage( hWnd, IPM_GETADDRESS, 0, ( LPARAM ) ( LPDWORD ) &pdwAddr );

   v1 = FIRST_IPADDRESS( pdwAddr );
   v2 = SECOND_IPADDRESS( pdwAddr );
   v3 = THIRD_IPADDRESS( pdwAddr );
   v4 = FOURTH_IPADDRESS( pdwAddr );

   hb_reta( 4 );
   HB_STORNI( ( INT ) v1, -1, 1 );
   HB_STORNI( ( INT ) v2, -1, 2 );
   HB_STORNI( ( INT ) v3, -1, 3 );
   HB_STORNI( ( INT ) v4, -1, 4 );
}
