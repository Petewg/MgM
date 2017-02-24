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

#ifdef MAKELONG
#undef MAKELONG
#endif
#define MAKELONG( a, b )  ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )

extern HINSTANCE g_hInstance;

HB_FUNC( INITPROGRESSBAR )
{
   HWND hwnd;
   HWND hbutton;

   int Style = WS_CHILD;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_PROGRESS_CLASS;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 9 ) )
      Style = Style | PBS_VERTICAL;

   if( hb_parl( 10 ) )
      Style = Style | PBS_SMOOTH;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_VISIBLE;

   hbutton = CreateWindowEx
             (
      WS_EX_CLIENTEDGE,
      PROGRESS_CLASS,
      0,
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hwnd,
      ( HMENU ) HB_PARNL( 2 ),
      g_hInstance,
      NULL
             );

   SendMessage( hbutton, PBM_SETRANGE, 0, MAKELONG( hb_parni( 7 ), hb_parni( 8 ) ) );
   SendMessage( hbutton, PBM_SETPOS, ( WPARAM ) hb_parni( 12 ), 0 );

   HB_RETNL( ( LONG_PTR ) hbutton );
}
