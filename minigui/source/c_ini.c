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

#include <mgdefs.h>

HB_FUNC( GETPRIVATEPROFILESTRING )
{
   DWORD  nSize   = 1024;
   char * bBuffer = ( char * ) hb_xgrab( nSize );
   DWORD  dwLen;
   char * lpSection  = HB_ISCHAR( 1 ) ? ( char * ) hb_parc( 1 ) : NULL;
   char * lpEntry    = HB_ISCHAR( 2 ) ? ( char * ) hb_parc( 2 ) : NULL;
   char * lpDefault  = ( char * ) hb_parc( 3 );
   char * lpFileName = ( char * ) hb_parc( 4 );

   while( TRUE )
   {
      dwLen = GetPrivateProfileString( lpSection, lpEntry, lpDefault, bBuffer, nSize, lpFileName );
      if( ( ( ( lpSection == NULL ) || ( lpEntry == NULL ) ) && ( nSize - dwLen == 2 ) ) || ( ( lpSection && lpEntry ) && ( nSize - dwLen == 1 ) ) )
      {
         hb_xfree( bBuffer );
         nSize  *= 2;
         bBuffer = ( char * ) hb_xgrab( nSize );
      }
      else
         break;
   }

   if( dwLen )
      hb_retclen( ( char * ) bBuffer, dwLen );
   else
      hb_retc( lpDefault );

   hb_xfree( bBuffer );
}

HB_FUNC( WRITEPRIVATEPROFILESTRING )
{
   char * lpSection  = ( char * ) hb_parc( 1 );
   char * lpEntry    = HB_ISCHAR( 2 ) ? ( char * ) hb_parc( 2 ) : NULL;
   char * lpData     = HB_ISCHAR( 3 ) ? ( char * ) hb_parc( 3 ) : NULL;
   char * lpFileName = ( char * ) hb_parc( 4 );

   hb_retl( WritePrivateProfileString( lpSection, lpEntry, lpData, lpFileName ) );
}

HB_FUNC( DELINIENTRY )
{
   hb_retl( WritePrivateProfileString( hb_parc( 1 ),     // Section
                                       hb_parc( 2 ),     // Entry
                                       NULL,             // String
                                       hb_parc( 3 ) ) ); // INI File
}

HB_FUNC( DELINISECTION )
{
   hb_retl( WritePrivateProfileString( hb_parc( 1 ),     // Section
                                       NULL,             // Entry
                                       "",               // String
                                       hb_parc( 2 ) ) ); // INI File
}

// (JK) HMG 1.0 Experimental build 6

HB_FUNC( _GETPRIVATEPROFILESECTIONNAMES )
{
   char   bBuffer[ 32767 ];
   DWORD  dwLen;
   char * lpFileName = ( char * ) hb_parc( 1 );

   dwLen = GetPrivateProfileSectionNames( bBuffer, sizeof( bBuffer ), lpFileName );
   hb_retclen( ( char * ) bBuffer, dwLen );
}

// Used to retrieve all key/value pairs of a given section.

HB_FUNC( _GETPRIVATEPROFILESECTION )
{
   char   bBuffer[ 32767 ];
   DWORD  dwLen;
   char * lpFileName    = ( char * ) hb_parc( 2 );
   char * lpSectionName = ( char * ) hb_parc( 1 );

   dwLen = GetPrivateProfileSection( lpSectionName, bBuffer, sizeof( bBuffer ), lpFileName );
   hb_retclen( ( char * ) bBuffer, dwLen );
}
