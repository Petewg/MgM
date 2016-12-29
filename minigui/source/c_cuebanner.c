/*-------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This  program is free software; you can redistribute it and/or modify it
   under  the  terms  of the GNU General Public License as published by the
   Free  Software  Foundation; either version 2 of the License, or (at your
   option) any later version.

   This  program  is  distributed  in  the hope that it will be useful, but
   WITHOUT   ANY   WARRANTY;   without   even   the   implied  warranty  of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You  should have received a copy of the GNU General Public License along
   with  this  software;  see  the  file COPYING. If not, write to the Free
   Software  Foundation,  Inc.,  59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As  a  special exception, you have permission for additional uses of the
   text contained in this release of Harbour Minigui.

   The  exception  is  that,  if  you link the Harbour Minigui library with
   other  files to produce an executable, this does not by itself cause the
   resulting  executable  to  be covered by the GNU General Public License.
   Your  use  of  that  executable  is  in  no way restricted on account of
   linking the Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ----------------------------------------------------------------------*/

/* P.Ch. 16.10. */

#include <mgdefs.h>
#include "hbapierr.h"

#ifndef __XHARBOUR__
   #include "hbwinuni.h"
#else
typedef wchar_t HB_WCHAR;
#endif

#if ( ! defined( EM_GETCUEBANNER ) )
   #if ( ! defined( ECM_FIRST ) )
      #define ECM_FIRST     0x1500
   #endif
   #define EM_GETCUEBANNER  ( ECM_FIRST + 2 )
#endif

HB_FUNC( GETCUEBANNERTEXT )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      HB_WCHAR * lpWCStr = ( HB_WCHAR * ) hb_xgrab( 256 * sizeof( HB_WCHAR ) );

      if( SendMessage( hwnd, EM_GETCUEBANNER, ( WPARAM ) ( LPWSTR ) lpWCStr, ( LPARAM ) 256 ) )
      {
         #ifdef __XHARBOUR__
         hb_retc( ( const char * ) hb_wctomb( lpWCStr ) );
         #else
         hb_retstrlen_u16( HB_CDP_ENDIAN_NATIVE, lpWCStr, 256 );
         #endif
      }
      else
      {
         hb_retc_null();
      }

      hb_xfree( lpWCStr );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

HB_FUNC( SENDMESSAGESTRINGW )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      HB_WCHAR * lpWCStr = ( HB_WCHAR * ) ( ( hb_parclen( 4 ) == 0 ) ? NULL : hb_mbtowc( hb_parc( 4 ) ) );

      HB_RETNL( ( LONG_PTR ) SendMessage( hwnd, ( UINT ) hb_parni( 2 ),
                                          ( WPARAM ) hb_parl( 3 ), ( LPARAM ) ( LPCWSTR ) lpWCStr ) );
      if( NULL != lpWCStr )
      {
         hb_xfree( lpWCStr );
      }
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}
