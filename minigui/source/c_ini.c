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

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
   LPSTR  WideToAnsi( LPWSTR );
#endif

HB_FUNC( GETPRIVATEPROFILESTRING )
{
   DWORD   nSize   = 1024;
   TCHAR * bBuffer = ( TCHAR * ) hb_xgrab( nSize );
   DWORD   dwLen;

#ifndef UNICODE
   LPCSTR lpSection  = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : NULL;
   LPCSTR lpEntry    = HB_ISCHAR( 2 ) ? hb_parc( 2 ) : NULL;
   LPCSTR lpDefault  = hb_parc( 3 );
   LPCSTR lpFileName = hb_parc( 4 );
#else
   LPCWSTR lpSection  = HB_ISCHAR( 1 ) ? AnsiToWide( ( char * ) hb_parc( 1 ) ) : NULL;
   LPCWSTR lpEntry    = HB_ISCHAR( 2 ) ? AnsiToWide( ( char * ) hb_parc( 2 ) ) : NULL;
   LPCWSTR lpDefault  = AnsiToWide( ( char * ) hb_parc( 3 ) );
   LPCWSTR lpFileName = AnsiToWide( ( char * ) hb_parc( 4 ) );
   LPSTR   pStr;
#endif

   while( TRUE )
   {
      dwLen = GetPrivateProfileString( lpSection, lpEntry, lpDefault, bBuffer, nSize, lpFileName );
      if( ( ( ( lpSection == NULL ) || ( lpEntry == NULL ) ) && ( nSize - dwLen == 2 ) ) || ( ( lpSection && lpEntry ) && ( nSize - dwLen == 1 ) ) )
      {
         hb_xfree( bBuffer );
         nSize  *= 2;
         bBuffer = ( TCHAR * ) hb_xgrab( nSize );
      }
      else
         break;
   }

   if( dwLen )
   {
#ifndef UNICODE
      hb_retclen( ( TCHAR * ) bBuffer, dwLen );
#else
      pStr = WideToAnsi( bBuffer );
      hb_retclen( ( char * ) pStr, dwLen );
      hb_xfree( pStr );
#endif
   }
   else
   {
#ifndef UNICODE
      hb_retc( lpDefault );
#else
      pStr = WideToAnsi( ( LPWSTR ) lpDefault );
      hb_retc( pStr );
      hb_xfree( pStr );
#endif
   }

   hb_xfree( bBuffer );
}

HB_FUNC( WRITEPRIVATEPROFILESTRING )
{
#ifndef UNICODE
   LPCSTR lpSection  = hb_parc( 1 );
   LPCSTR lpEntry    = HB_ISCHAR( 2 ) ? hb_parc( 2 ) : NULL;
   LPCSTR lpData     = HB_ISCHAR( 3 ) ? hb_parc( 3 ) : NULL;
   LPCSTR lpFileName = hb_parc( 4 );
#else
   LPCWSTR lpSection  = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPCWSTR lpEntry    = HB_ISCHAR( 2 ) ? AnsiToWide( ( char * ) hb_parc( 2 ) ) : NULL;
   LPCWSTR lpData     = HB_ISCHAR( 3 ) ? AnsiToWide( ( char * ) hb_parc( 3 ) ) : NULL;
   LPCWSTR lpFileName = AnsiToWide( ( char * ) hb_parc( 4 ) );
#endif

   hb_retl( WritePrivateProfileString( lpSection, lpEntry, lpData, lpFileName ) );
}

HB_FUNC( DELINIENTRY )
{
#ifndef UNICODE
   LPCSTR lpSection  = hb_parc( 1 );
   LPCSTR lpEntry    = hb_parc( 2 );
   LPCSTR lpFileName = hb_parc( 3 );
#else
   LPCWSTR lpSection  = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPCWSTR lpEntry    = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPCWSTR lpFileName = AnsiToWide( ( char * ) hb_parc( 3 ) );
#endif
   hb_retl( WritePrivateProfileString( lpSection,      // Section
                                       lpEntry,        // Entry
                                       NULL,           // String
                                       lpFileName ) ); // INI File
}

HB_FUNC( DELINISECTION )
{
#ifndef UNICODE
   LPCSTR lpSection  = hb_parc( 1 );
   LPCSTR lpFileName = hb_parc( 2 );
#else
   LPCWSTR lpSection  = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPCWSTR lpFileName = AnsiToWide( ( char * ) hb_parc( 2 ) );
#endif
   hb_retl( WritePrivateProfileString( lpSection,      // Section
                                       NULL,           // Entry
                                       TEXT( "" ),     // String
                                       lpFileName ) ); // INI File
}

static TCHAR * FindFirstSubString( TCHAR * Strings )
{
   TCHAR * p = Strings;

   if( *p == 0 )
      p = NULL;
   return p;
}

static TCHAR * FindNextSubString( TCHAR * Strings )
{
   TCHAR * p = Strings;

   p = p + lstrlen( Strings ) + 1;
   if( *p == 0 )
      p = NULL;
   return p;
}

static INT FindLenSubString( TCHAR * Strings )
{
   INT     i = 0;
   TCHAR * p = Strings;

   if( ( p = FindFirstSubString( p ) ) != NULL )
      for( i = 1; ( p = FindNextSubString( p ) ) != NULL; i++ )
         ;
   return i;
}

// (JK) HMG 1.0 Experimental build 6

HB_FUNC( _GETPRIVATEPROFILESECTIONNAMES )
{
   TCHAR   bBuffer[ 32767 ];
   TCHAR * p;
   INT     i, nLen;

#ifndef UNICODE
   LPCSTR lpFileName = hb_parc( 1 );
#else
   LPCWSTR lpFileName = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPSTR   pStr;
#endif

   ZeroMemory( bBuffer, sizeof( bBuffer ) );
   GetPrivateProfileSectionNames( bBuffer, sizeof( bBuffer ) / sizeof( TCHAR ), lpFileName );

   p    = ( TCHAR * ) bBuffer;
   nLen = FindLenSubString( p );
   hb_reta( nLen );
   if( nLen > 0 )
   {
#ifndef UNICODE
      HB_STORC( ( p = FindFirstSubString( p ) ), -1, 1 );
      for( i = 2; ( p = FindNextSubString( p ) ) != NULL; i++ )
         HB_STORC( p, -1, i );
#else
      p    = FindFirstSubString( p );
      pStr = WideToAnsi( p );
      HB_STORC( pStr, -1, 1 );
      for( i = 2; ( p = FindNextSubString( p ) ) != NULL; i++ )
      {
         pStr = WideToAnsi( p );
         HB_STORC( pStr, -1, i );
      }
      hb_xfree( pStr );
#endif
   }
}

// Used to retrieve all key/value pairs of a given section.

HB_FUNC( _GETPRIVATEPROFILESECTION )
{
   TCHAR   bBuffer[ 32767 ];
   TCHAR * p;
   INT     i, nLen;

#ifndef UNICODE
   LPCSTR lpSectionName = hb_parc( 1 );
   LPCSTR lpFileName    = hb_parc( 2 );
#else
   LPCWSTR lpSectionName = AnsiToWide( ( char * ) hb_parc( 1 ) );
   LPCWSTR lpFileName    = AnsiToWide( ( char * ) hb_parc( 2 ) );
   LPSTR   pStr;
#endif

   ZeroMemory( bBuffer, sizeof( bBuffer ) );
   GetPrivateProfileSection( lpSectionName, bBuffer, sizeof( bBuffer ) / sizeof( TCHAR ), lpFileName );
   p    = ( TCHAR * ) bBuffer;
   nLen = FindLenSubString( p );
   hb_reta( nLen );
   if( nLen > 0 )
   {
#ifndef UNICODE
      HB_STORC( ( p = FindFirstSubString( p ) ), -1, 1 );
      for( i = 2; ( p = FindNextSubString( p ) ) != NULL; i++ )
         HB_STORC( p, -1, i );
#else
      p    = FindFirstSubString( p );
      pStr = WideToAnsi( p );
      HB_STORC( pStr, -1, 1 );
      for( i = 2; ( p = FindNextSubString( p ) ) != NULL; i++ )
      {
         pStr = WideToAnsi( p );
         HB_STORC( pStr, -1, i );
      }
      hb_xfree( pStr );
#endif
   }
}
