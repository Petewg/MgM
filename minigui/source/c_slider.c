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

HINSTANCE GetInstance( void );

HB_FUNC( INITSLIDER )
{
   HWND hTrackBar;
   int  Style = WS_CHILD, iSelMin = 0, iSelMax = 0;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_BAR_CLASSES;
   InitCommonControlsEx( &i );

   if( hb_parl( 9 ) )
      Style |= TBS_VERT;

   Style |= ( hb_parl( 10 ) ? TBS_NOTICKS : TBS_AUTOTICKS );

   if( hb_parl( 11 ) )
      Style |= TBS_BOTH;

   if( hb_parl( 12 ) )
      Style |= TBS_TOP;

   if( hb_parl( 13 ) )
      Style |= TBS_LEFT;

   if( ! hb_parl( 14 ) )
      Style |= WS_VISIBLE;

   if( ! hb_parl( 15 ) )
      Style |= WS_TABSTOP;

   if( hb_parl( 16 ) )  /* P.Ch. 16.10 */
   {
      Style  |= TBS_ENABLESELRANGE;
      iSelMin = HB_MIN( hb_parnidef( 17, 0 ), hb_parnidef( 18, 0 ) );
      iSelMax = HB_MAX( hb_parnidef( 17, 0 ), hb_parnidef( 18, 0 ) );
   }

   hTrackBar = CreateWindow
               (
      TRACKBAR_CLASS,
      0,
      Style,
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      ( HWND ) HB_PARNL( 1 ),
      ( HMENU ) HB_PARNL( 2 ),
      GetInstance(),
      NULL
               );

   SendMessage( hTrackBar, TBM_SETRANGE, ( WPARAM ) TRUE, MAKELONG( hb_parni( 7 ), hb_parni( 8 ) ) );

   if( ( hb_parl( 16 ) ) && ( iSelMin != iSelMax ) )
   {
      SendMessage( hTrackBar, TBM_SETSEL, ( WPARAM ) TRUE, MAKELONG( iSelMin, iSelMax ) );  /* P.Ch. 16.10 */
   }

   HB_RETNL( ( LONG_PTR ) hTrackBar );
}
