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

#if ( defined( __BORLANDC__ ) && defined( _WIN64 ) )
#define PtrToLong( p )   ( ( LONG ) (p) )
#endif

HB_FUNC( REGCLOSEKEY )
{
   HKEY hwHandle = ( HKEY ) HB_PARNL( 1 );

   hb_retnl( ( RegCloseKey( hwHandle ) == ERROR_SUCCESS ) ? ERROR_SUCCESS : -1 );
}

HB_FUNC( REGOPENKEYEXA )
{
   HKEY    hwKey   = ( HKEY ) HB_PARNL( 1 );
   LPCTSTR lpValue = hb_parc( 2 );
   long    lError;
   HKEY    phwHandle;

   lError = RegOpenKeyExA( ( HKEY ) hwKey, lpValue, 0, ( REGSAM ) hb_parnl( 4 ), &phwHandle );

   if( lError != ERROR_SUCCESS )
      hb_retnl( -1 );
   else
   {
      HB_STORNL( PtrToLong( phwHandle ), 5 );
      hb_retnl( 0 );
   }
}

HB_FUNC( REGQUERYVALUEEXA )
{
   long  lError;
   DWORD lpType   = hb_parnl( 4 );
   DWORD lpcbData = 0;

   lError = RegQueryValueExA( ( HKEY ) HB_PARNL( 1 ), ( LPTSTR ) hb_parc( 2 ), NULL, &lpType, NULL, &lpcbData );

   if( lError == ERROR_SUCCESS )
   {
      BYTE * lpData;

      lpData = ( BYTE * ) hb_xgrab( lpcbData + 1 );
      lError = RegQueryValueExA( ( HKEY ) HB_PARNL( 1 ), ( LPTSTR ) hb_parc( 2 ), NULL, &lpType, ( BYTE * ) lpData, &lpcbData );

      if( lError != ERROR_SUCCESS )
         hb_retnl( -1 );
      else
      {
         HB_STORNL( ( long ) lpType, 4 );
         hb_storc( ( char * ) lpData, 5 );
         HB_STORNL( ( long ) lpcbData, 6 );

         hb_retnl( 0 );
      }

      hb_xfree( lpData );
   }
   else
      hb_retnl( -1 );
}

HB_FUNC( REGENUMKEYEXA )
{
   FILETIME ft;
   long     bErr;
   TCHAR    Buffer[ 255 ];
   DWORD    dwBuffSize = 255;
   TCHAR    Class[ 255 ];
   DWORD    dwClass = 255;

   bErr = RegEnumKeyEx( ( HKEY ) HB_PARNL( 1 ), hb_parnl( 2 ), Buffer, &dwBuffSize, NULL, Class, &dwClass, &ft );

   if( bErr != ERROR_SUCCESS )
      hb_retnl( -1 );
   else
   {
      hb_storc( Buffer, 3 );
      HB_STORNL( ( long ) dwBuffSize, 4 );
      hb_storc( Class, 6 );
      HB_STORNL( ( long ) dwClass, 7 );

      hb_retnl( 0 );
   }
}

HB_FUNC( REGSETVALUEEXA )
{
   DWORD nType = hb_parnl( 4 );

   if( nType != REG_DWORD )
   {
      if( RegSetValueExA( ( HKEY ) HB_PARNL( 1 ), hb_parc( 2 ), ( DWORD ) 0, hb_parnl( 4 ), ( BYTE * ) hb_parc( 5 ), ( DWORD ) hb_parclen( 5 ) + 1 ) == ERROR_SUCCESS )
         hb_retnl( 0 );
      else
         hb_retnl( -1 );
   }
   else
   {
      DWORD nSpace = hb_parnl( 5 );
      if( RegSetValueExA( ( HKEY ) HB_PARNL( 1 ), hb_parc( 2 ), ( DWORD ) 0, hb_parnl( 4 ), ( BYTE * ) &nSpace, sizeof( REG_DWORD ) ) == ERROR_SUCCESS )
         hb_retnl( 0 );
      else
         hb_retnl( -1 );
   }
}

HB_FUNC( REGCREATEKEY )
{
   HKEY hKey;

   if( RegCreateKey( ( HKEY ) HB_PARNL( 1 ), hb_parc( 2 ), &hKey ) == ERROR_SUCCESS )
   {
      HB_STORNL( PtrToLong( hKey ), 3 );
      hb_retnl( 0 );
   }
   else
      hb_retnl( -1 );
}

HB_FUNC( REGENUMVALUEA )
{
   DWORD lpType = 1;
   TCHAR Buffer[ 255 ];
   DWORD dwBuffSize = 255;
   DWORD dwClass    = 255;
   long  lError;

   lError = RegEnumValueA( ( HKEY ) HB_PARNL( 1 ), hb_parnl( 2 ), Buffer, &dwBuffSize, NULL, &lpType, NULL, &dwClass );

   if( lError != ERROR_SUCCESS )
      hb_retnl( -1 );
   else
   {
      hb_storc( Buffer, 3 );
      HB_STORNL( ( long ) dwBuffSize, 4 );
      HB_STORNL( ( long ) lpType, 6 );
      HB_STORNL( ( long ) dwClass, 8 );

      hb_retnl( lError );
   }
}

HB_FUNC( REGDELETEKEY )
{
   hb_retnl( RegDeleteKey( ( HKEY ) HB_PARNL( 1 ), hb_parc( 2 ) ) );
}

HB_FUNC( REGDELETEVALUEA )
{
   if( RegDeleteValueA( ( HKEY ) HB_PARNL( 1 ), hb_parc( 2 ) ) == ERROR_SUCCESS )
      hb_retnl( 0 );
   else
      hb_retnl( -1 );
}

HB_FUNC( REGCONNECTREGISTRY )
{
   LPCTSTR lpValue = hb_parc( 1 );
   HKEY    hwKey   = ( ( HKEY ) HB_PARNL( 2 ) );
   long    lError;
   HKEY    phwHandle;

   lError = RegConnectRegistry( lpValue, ( HKEY ) hwKey, &phwHandle );

   if( lError != ERROR_SUCCESS )
      hb_retnl( -1 );
   else
   {
      HB_STORNL( PtrToLong( phwHandle ), 3 );
      hb_retnl( lError );
   }
}
