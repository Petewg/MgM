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
#include <shellapi.h>

extern HINSTANCE g_hInstance;

// BOOL WINAPI DestroyIcon( HICON hIcon )
HB_FUNC( DESTROYICON )
{
   hb_retl( DestroyIcon( ( HICON ) ( LONG_PTR ) HB_PARNL( 1 ) ) );
}   

// HICON LoadIcon( HINSTANCE hInstance, LPCTSTR lpIconName )
HB_FUNC( LOADICON )
{
   HINSTANCE hinstance = ( HB_ISNIL( 1 ) ? NULL : ( HINSTANCE ) ( LONG_PTR ) HB_PARNL( 1 ) );

   HB_RETNL( ( LONG_PTR ) LoadIcon( hinstance, HB_ISCHAR( 2 ) ? hb_parc( 2 ) : MAKEINTRESOURCE( hb_parni( 2 ) ) ) );
}

// HICON ExtractIcon( HINSTANCE hInst, LPCTSTR lpszExeFileName, UINT nIconIndex )
HB_FUNC( EXTRACTICON )
{
   HB_RETNL( ( LONG_PTR ) ExtractIcon( g_hInstance, hb_parc( 1 ), ( UINT ) hb_parni( 2 ) ) );
}

// UINT ExtractIconEx( LPCTSTR lpszFile, int nIconIndex, HICON *phiconLarge, HICON *phiconSmall, UINT nIcons )
HB_FUNC( EXTRACTICONEX )
{
   int nIconIndex = hb_parni( 2 );

   if( nIconIndex == -1 )
   {
      hb_retni( ExtractIconEx( hb_parc( 1 ), -1, NULL, NULL, 0 ) );
   }
   else
   {
      // TODO
      HICON hIconLarge, hIconSmall;
      UINT  nIconCount = ExtractIconEx( hb_parc( 1 ), nIconIndex, &hIconLarge, &hIconSmall, 1 );

      if( nIconCount > 0 )
      {
         hb_reta( 2 );

         HB_STORVNL( ( LONG_PTR ) hIconLarge, -1, 1 );
         HB_STORVNL( ( LONG_PTR ) hIconSmall, -1, 2 );
      }
   }
}
