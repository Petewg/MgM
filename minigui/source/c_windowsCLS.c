/*
   MINIGUI - Harbour Win32 GUI library source code

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
#include "hbapierr.h"
#include "hbapistr.h"

#ifdef __XHARBOUR__
#define hb_storclen_buffer  hb_storclenAdopt
#endif


BOOL _isValidCtrlClassA( HWND hwndTip, const char * ClassName ); /* P.Ch. 16.10. */

BOOL _isValidCtrlClassA( HWND hwndTip, const char * ClassName  )
{
   char lpClassName[ 256 ];
   int  iLen = 0;

   if( IsWindow( hwndTip ) )
      iLen = GetClassNameA( hwndTip, lpClassName, 256 );

   if( ( iLen > 0 ) && ( strncmp( ( const char * ) lpClassName, ClassName, iLen ) == 0 ) )
      return TRUE;
   else
      return FALSE;
}

/*
   cClassName := GetClassName( nHwnd )
   IF ! Empty( cClassName )
      ..
   ..
 */
HB_FUNC( GETCLASSNAME )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      char ClassName[ 256 ];
      int  iLen;

      iLen = GetClassNameA( hwnd, ClassName, sizeof( ClassName ) / sizeof( char ) );

      if( iLen > 0 )
         hb_retclen( ( const char * ) ClassName, iLen );
      else
         hb_retc_null();
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

/*
   cClassName := Space( 32 )
   ..
   nLen := GetClassNameByRef( nHwnd, @cClassName )
   IF nLen > 0
      ..
   ..
 */
HB_FUNC( GETCLASSNAMEBYREF )
{
   HWND    hwnd = ( HWND ) HB_PARNL( 1 );
   HB_SIZE nLen = hb_parcsiz( 2 ); // fixed P.Ch. 16.12.

   hb_retni( 0 );

   if( IsWindow( hwnd ) && nLen > 1 )
   {
      char * pBuffer = ( char * ) hb_xgrab( nLen + 1 );

      if( pBuffer )
      {
         int nResult = GetClassNameA( hwnd, pBuffer, nLen );

         if( nResult > 0 )
            hb_retni( hb_storclen_buffer( pBuffer, ( HB_SIZE ) nResult, 2 ) );
         else
            hb_xfree( pBuffer );
      }
   }
}

HB_FUNC( GETWINDOWLONG )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
      HB_RETNL( GetWindowLongPtr( hwnd, hb_parni( 2 ) ) );
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

/*
   nCtlStyle := GetWindowStyle( Form_1.Button_1.Handle )

   IF hb_bitAnd( nCtlStyle, WS_TABSTOP ) != 0
      SetWindowStyle( nButtonHandle, WS_TABSTOP, .F. )   // Turn WS_TABSTOP style off
   ELSE
      SetWindowStyle( nButtonHandle, WS_TABSTOP, .T. )   // Turn WS_TABSTOP style on
   ENDIF
 */
HB_FUNC( GETWINDOWSTYLE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
      HB_RETNL( GetWindowLongPtr( hwnd, GWL_STYLE ) );
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

/*
   nOldStyle := SetWindowStyle( Form_1.Button_1.Handle, WS_TABSTOP, .T. )

   IF nOldStyle == 0
      MsgExclamation( "Cannot add WS_TABSTOP style to Button_1", "Warning!")
   ENDIF
 */
HB_FUNC( SETWINDOWSTYLE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      LONG_PTR nOldStyle = GetWindowLongPtr( hwnd, GWL_STYLE );
      LONG_PTR nNewStyle = ( LONG_PTR ) HB_PARNL( 2 );

      HB_RETNL( SetWindowLongPtr( hwnd, GWL_STYLE, ( ( BOOL ) hb_parl( 3 ) ) ? nOldStyle | nNewStyle : nOldStyle & ( ~nNewStyle ) ) );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

/*
   IF GetClassName( nCtlHandle ) == "Button" .AND. IsWindowHasStyle( nCtlHandle, WS_TABSTOP )
      SetWindowStyle( nCtlHandle, WS_TABSTOP, .F. )   // Turn WS_TABSTOP style off
   ELSE
      SetWindowStyle( nCtlHandle, WS_TABSTOP, .T. )   // Turn WS_TABSTOP style on
   ENDIF
 */
HB_FUNC( ISWINDOWHASSTYLE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      LONG_PTR Style = GetWindowLongPtr( hwnd, GWL_STYLE );

      hb_retl( ( Style & ( LONG_PTR ) HB_PARNL( 2 ) ) ? HB_TRUE : HB_FALSE );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

HB_FUNC( ISWINDOWHASEXSTYLE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      LONG_PTR nExStyle = GetWindowLongPtr( hwnd, GWL_EXSTYLE );

      hb_retl( ( nExStyle & ( LONG_PTR ) HB_PARNL( 2 ) ) ? HB_TRUE : HB_FALSE );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 3012, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}
