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
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2018, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#ifndef WC_BUTTON
#define WC_BUTTON  "Button"
#endif

HINSTANCE GetInstance( void );

HB_FUNC( INITRADIOGROUP )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = BS_NOTIFY | WS_CHILD | BS_AUTORADIOBUTTON | WS_GROUP;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 11 ) )
      Style = Style | BS_LEFTTEXT;

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      28,
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITRADIOBUTTON )
{
   HWND hwnd;
   HWND hbutton;
   int  Style = BS_NOTIFY | WS_CHILD | BS_AUTORADIOBUTTON;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 9 ) )
      Style = Style | WS_VISIBLE;

   if( hb_parl( 10 ) )
      Style = Style | BS_LEFTTEXT;

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      28,
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}
