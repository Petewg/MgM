/* MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This    program  is  free  software;  you can redistribute it and/or modify
   it under  the  terms  of the GNU General Public License as published by the
   Free  Software   Foundation;  either  version 2 of the License, or (at your
   option) any later version.

   This   program   is   distributed  in  the hope that it will be useful, but
   WITHOUT    ANY    WARRANTY;    without   even   the   implied  warranty  of
   MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You   should  have  received a copy of the GNU General Public License along
   with   this   software;   see  the  file COPYING. If not, write to the Free
   Software   Foundation,   Inc.,   59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As   a   special  exception, you have permission for additional uses of the
   text  contained  in  this  release  of  Harbour Minigui.

   The   exception   is that,   if   you  link  the  Harbour  Minigui  library
   with  other    files   to  produce   an   executable,   this  does  not  by
   itself   cause  the   resulting   executable    to   be  covered by the GNU
   General  Public  License.  Your    use  of that   executable   is   in   no
   way  restricted on account of linking the Harbour-Minigui library code into
   it.

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

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */

#include <mgdefs.h>
#include "hbapifs.h"

extern HINSTANCE g_hInstance;

#if defined( __XHARBOUR__ )

HB_FUNC( RCDATATOFILE )
{
   HMODULE hModule = g_hInstance;
   HRSRC   hResInfo;
   HGLOBAL hResData;
   LPVOID  lpData;
   DWORD   dwSize, dwRet;
   HANDLE  hFile;

   hResInfo = FindResource( hModule, MAKEINTRESOURCE( hb_parnl( 1 ) ), RT_RCDATA );

   if( NULL == hResInfo )
   {
      hb_retnl( -1 );
      return;
   }

   hResData = LoadResource( hModule, hResInfo );

   if( NULL == hResData )
   {
      hb_retnl( -2 );
      return;
   }

   lpData = LockResource( hResData );

   if( NULL == lpData )
   {
      FreeResource( hResData );
      hb_retnl( -3 );
      return;
   }

   dwSize = SizeofResource( hModule, hResInfo );

   hFile = CreateFile( hb_parc( 2 ), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, ( DWORD ) 0, NULL );

   if( INVALID_HANDLE_VALUE == hFile )
   {
      FreeResource( hResData );
      hb_retnl( -4 );
      return;
   }

   WriteFile( hFile, lpData, dwSize, &dwRet, NULL );

   FreeResource( hResData );

   if( dwRet != dwSize )
   {
      dwRet = -5;
   }

   CloseHandle( hFile );

   hb_retnl( dwRet );
}

#else

HB_FUNC( RCDATATOFILE )
{
   HMODULE hModule = ( HMODULE ) ( 0 != HB_PARNL( 4 ) ? ( HINSTANCE ) HB_PARNL( 4 ) : g_hInstance );
   /* lpType is RT_RCDATA by default */
   LPTSTR  lpType = ( hb_parclen( 3 ) > 0 ) ? ( LPTSTR ) hb_parc( 3 ) : MAKEINTRESOURCE( hb_parnldef( 3, 10 ) );
   HRSRC   hResInfo;
   HGLOBAL hResData;
   DWORD   dwResult = 0;

   if( hb_parclen( 1 ) > 0 )
      hResInfo = FindResourceA( hModule, hb_parc( 1 ), lpType );
   else
      hResInfo = FindResource( hModule, MAKEINTRESOURCE( hb_parnl( 1 ) ), lpType );

   if( NULL != hResInfo )
   {
      hResData = LoadResource( hModule, hResInfo );

      if( NULL == hResData )
         dwResult = -2;  // can't load
   }
   else
      dwResult = -1;  // can't find

   if( 0 == dwResult )
   {
      LPVOID lpData = LockResource( hResData );

      if( NULL != lpData )
      {
         DWORD    dwSize = SizeofResource( hModule, hResInfo );
         PHB_FILE pFile;

         pFile = hb_fileExtOpen( hb_parcx( 2 ), NULL, FO_CREAT | FO_WRITE | FO_EXCLUSIVE | FO_PRIVATE, NULL, NULL );

         if( NULL != pFile )
         {
            dwResult = ( DWORD ) hb_fileWrite( pFile, ( const void * ) lpData, ( HB_SIZE ) dwSize, -1 );

            if( dwResult != dwSize )
               dwResult = -5;  // can't write

            hb_fileClose( pFile );
         }
         else
            dwResult = -4;  // can't open
      }
      else
         dwResult = -3;  // can't lock

      FreeResource( hResData );
   }

   hb_retnl( dwResult );
}

#endif /* __XHARBOUR__ */