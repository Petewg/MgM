/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   HOTKEYBOX Control Source Code
   Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>

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

#include <mgdefs.h>

#include <commctrl.h>

HINSTANCE GetInstance( void );

void InterpretHotKey( UINT setting, TCHAR * szKeyName )
{
   BOOL Ctrl, Alt, Shift;
   UINT WorkKey, uCode, uVKey;

   uCode      = ( setting & 0x0000FF00 ) >> 8;
   uVKey      = setting & 255;
   *szKeyName = 0;

   Ctrl  = uCode & HOTKEYF_CONTROL;
   Alt   = uCode & HOTKEYF_ALT;
   Shift = uCode & HOTKEYF_SHIFT;

   strcat( szKeyName, Ctrl ? "Ctrl + " : "" );
   strcat( szKeyName, Shift ? "Shift + " : "" );
   strcat( szKeyName, Alt ? "Alt + " : "" );

   WorkKey = MapVirtualKey( uVKey, 0 );

   if( uCode & 0x00000008 )  // extended key
      WorkKey = 0x03000000 | ( WorkKey << 16 );
   else
      WorkKey = 0x02000000 | ( WorkKey << 16 );

   GetKeyNameText( WorkKey, szKeyName + strlen( szKeyName ), 100 );
}

HB_FUNC( C_GETHOTKEYNAME )
{
   HWND  hWnd;
   WORD  wHotKey;
   TCHAR szKeyName[ 100 ];

   hWnd = ( HWND ) HB_PARNL( 1 );

   wHotKey = ( WORD ) SendMessage( hWnd, HKM_GETHOTKEY, 0, 0 );

   InterpretHotKey( wHotKey, szKeyName );

   hb_retclen( szKeyName, 100 );
}

HB_FUNC( INITHOTKEYBOX )
{
   HWND hWnd;
   HWND hwndHotKey;
   int  Style = WS_CHILD;

   hWnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 8 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 9 ) )
      Style = Style | WS_TABSTOP;

   hwndHotKey = CreateWindowEx
                (
      0,
      HOTKEY_CLASS,
      "",
      Style,
      hb_parni( 2 ),
      hb_parni( 3 ),
      hb_parni( 4 ),
      hb_parni( 5 ),
      hWnd,
      NULL,
      GetInstance(),
      NULL
                );

   HB_RETNL( ( LONG_PTR ) hwndHotKey );
}

HB_FUNC( SETHOTKEYVALUE )
{
   HWND hWnd;
   WORD wHotKey;

   hWnd = ( HWND ) HB_PARNL( 1 );

   wHotKey = ( WORD ) hb_parnl( 2 );

   if( wHotKey != 0 )
      SendMessage( hWnd, HKM_SETHOTKEY, wHotKey, 0 );

   SendMessage( hWnd, HKM_SETRULES, ( WPARAM ) HKCOMB_NONE | HKCOMB_S,  // invalid key combinations
                MAKELPARAM( HOTKEYF_ALT, 0 ) );                         // add ALT to invalid entries
}

HB_FUNC( C_GETHOTKEYVALUE )
{
   HWND hWnd;
   WORD wHotKey;
   UINT uVirtualKeyCode;
   UINT uModifiers;
   UINT iModifierKeys;

   hWnd = ( HWND ) HB_PARNL( 1 );

   wHotKey = ( WORD ) SendMessage( hWnd, HKM_GETHOTKEY, 0, 0 );

   uVirtualKeyCode = LOBYTE( LOWORD( wHotKey ) );
   uModifiers      = HIBYTE( LOWORD( wHotKey ) );
   iModifierKeys   =                                                        //
                     ( ( uModifiers & HOTKEYF_CONTROL ) ? MOD_CONTROL : 0 ) //
                     | ( ( uModifiers & HOTKEYF_ALT ) ? MOD_ALT : 0 )       //
                     | ( ( uModifiers & HOTKEYF_SHIFT ) ? MOD_SHIFT : 0 );

   hb_reta( 2 );
   HB_STORVNL( ( UINT ) uVirtualKeyCode, -1, 1 );
   HB_STORNI( ( UINT ) iModifierKeys, -1, 2 );
}

HB_FUNC( C_GETHOTKEY )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );
   WORD wHotKey;

   wHotKey = ( WORD ) SendMessage( hWnd, HKM_GETHOTKEY, 0, 0 );

   hb_retnl( ( WORD ) wHotKey );
}
