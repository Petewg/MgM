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

/*
   File:           c_cursor.c
   Contributors:   Jacek Kubica <kubica@wssk.wroc.pl>
                   Grigory Filatov <gfilatov@inbox.ru>
   Description:    Mouse Cursor Shapes handling for MiniGUI
   Status:         Public Domain
 */

#include <mgdefs.h>

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

HB_FUNC( LOADCURSOR )
{
   HINSTANCE hInstance    = HB_ISNIL( 1 ) ? NULL : ( HINSTANCE ) HB_PARNL( 1 );
   LPCSTR    lpCursorName = ( hb_parinfo( 2 ) & HB_IT_STRING ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) );

   HB_RETNL( ( LONG_PTR ) LoadCursor( hInstance, lpCursorName ) );
}

HB_FUNC( LOADCURSORFROMFILE )
{
   HB_RETNL( ( LONG_PTR ) LoadCursorFromFile( ( LPCSTR ) hb_parc( 1 ) ) );
}

HB_FUNC( SETRESCURSOR )
{
   HB_RETNL( ( LONG_PTR ) SetCursor( ( HCURSOR ) HB_PARNL( 1 ) ) );
}

HB_FUNC( FILECURSOR )
{
   HB_RETNL( ( LONG_PTR ) SetCursor( LoadCursorFromFile( ( LPCSTR ) hb_parc( 1 ) ) ) );
}

HB_FUNC( CURSORHAND )
{
#if ( WINVER >= 0x0500 )
   HB_RETNL( ( LONG_PTR ) SetCursor( LoadCursor( NULL, IDC_HAND ) ) );
#else
   HB_RETNL( ( LONG_PTR ) SetCursor( LoadCursor( GetInstance(), "MINIGUI_FINGER" ) ) );
#endif
}

HB_FUNC( SETWINDOWCURSOR )
{
   HCURSOR ch;
   LPCSTR  lpCursorName = ( hb_parinfo( 2 ) & HB_IT_STRING ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) );

   ch = LoadCursor( ( HB_ISCHAR( 2 ) ) ? GetResources() : NULL, lpCursorName );

   if( ( ch == NULL ) && HB_ISCHAR( 2 ) )
      ch = LoadCursorFromFile( lpCursorName );

   if( ch != NULL )
      SetClassLongPtr( ( HWND ) HB_PARNL( 1 ),  // window handle
                       GCLP_HCURSOR,            // change cursor
                       ( LONG_PTR ) ch );       // new cursor
}

HB_FUNC( SETHANDCURSOR )
{
   SetClassLong( ( HWND ) HB_PARNL( 1 ), GCLP_HCURSOR,
#if ( WINVER >= 0x0500 )
                 ( LONG_PTR ) LoadCursor( NULL, IDC_HAND ) );
#else
                 ( LONG_PTR ) LoadCursor( GetInstance(), "MINIGUI_FINGER" ) );
#endif
}
