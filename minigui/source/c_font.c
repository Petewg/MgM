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
 */

#include <mgdefs.h>

#include "hbapiitm.h"
#include "hbapierr.h"

#ifdef __XCC__
# define HB_ISBLOCK  ISBLOCK
#endif

HFONT PrepareFont( const char * FontName, int FontSize, int Weight, DWORD Italic, DWORD Underline, DWORD StrikeOut, DWORD Angle, DWORD charset )
{
   HDC hDC = GetDC( HWND_DESKTOP );

   FontSize = -MulDiv( FontSize, GetDeviceCaps( hDC, LOGPIXELSY ), 72 );

   ReleaseDC( HWND_DESKTOP, hDC );

   return CreateFont( FontSize, 0, Angle, 0, Weight, Italic, Underline, StrikeOut, charset,
                      OUT_TT_PRECIS,
                      CLIP_DEFAULT_PRECIS,
                      DEFAULT_QUALITY,
                      FF_DONTCARE,
                      FontName
                      );
}

HB_FUNC( INITFONT )
{
   HFONT font;
   int   bold      = hb_parl( 3 ) ? FW_BOLD : FW_NORMAL;
   DWORD italic    = ( DWORD ) hb_parl( 4 );
   DWORD underline = ( DWORD ) hb_parl( 5 );
   DWORD strikeout = ( DWORD ) hb_parl( 6 );
   DWORD angle     = hb_parnl( 7 );
   DWORD charset   = hb_parnldef( 8, DEFAULT_CHARSET );

   font = PrepareFont( hb_parc( 1 ), hb_parni( 2 ), bold, italic, underline, strikeout, angle, charset );

   HB_RETNL( ( LONG_PTR ) font );
}

HB_FUNC( _SETFONT )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      HFONT font;
      int   bold      = hb_parl( 4 ) ? FW_BOLD : FW_NORMAL;
      DWORD italic    = ( DWORD ) hb_parl( 5 );
      DWORD underline = ( DWORD ) hb_parl( 6 );
      DWORD strikeout = ( DWORD ) hb_parl( 7 );
      DWORD angle     = hb_parnl( 8 );
      DWORD charset   = hb_parnldef( 9, DEFAULT_CHARSET );

      font = PrepareFont( hb_parc( 2 ), hb_parni( 3 ), bold, italic, underline, strikeout, angle, charset );

      SendMessage( ( HWND ) hwnd, ( UINT ) WM_SETFONT, ( WPARAM ) font, ( LPARAM ) 1 );

      HB_RETNL( ( LONG_PTR ) font );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5001, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

HB_FUNC( _SETFONTHANDLE )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )
   {
      if( GetObjectType( ( HGDIOBJ ) HB_PARNL( 2 ) ) == OBJ_FONT )
         SendMessage( hwnd, ( UINT ) WM_SETFONT, ( WPARAM ) ( HFONT ) HB_PARNL( 2 ), ( LPARAM ) 1 );
      else
         hb_errRT_BASE_SubstR( EG_ARG, 5050 + OBJ_FONT, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
   }
   else
      hb_errRT_BASE_SubstR( EG_ARG, 5001, "MiniGUI Error", HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );
}

HB_FUNC( GETSYSTEMFONT )
{
   LOGFONT lfDlgFont;
   NONCLIENTMETRICS ncm;

   ncm.cbSize = sizeof( ncm );
   SystemParametersInfo( SPI_GETNONCLIENTMETRICS, ncm.cbSize, &ncm, 0 );

   lfDlgFont = ncm.lfMessageFont;

   hb_reta( 2 );
   HB_STORC( lfDlgFont.lfFaceName, -1, 1 );
   HB_STORNI( 21 + lfDlgFont.lfHeight, -1, 2 );
}

/*
   Added by P.Ch. for 16.12.
   Parts of this code based on an original work by Dr. Claudio Soto (January 2014)

   EnumFontsEx ( [ hDC ], [ cFontFamilyName ], [ nCharSet ], [ nPitch ], [ nFontType ], [ SortCodeBlock ], [ @aFontName ] )
             --> return array { { cFontName, nCharSet, nPitchAndFamily, nFontType }, ... }
 */

static int CALLBACK _EnumFontFamExProc( const LOGFONT * lpelfe, const TEXTMETRIC * lpntme, DWORD dwFontType, LPARAM pArray );

HB_FUNC( ENUMFONTSEX )
{
   HDC      hdc;
   LOGFONT  lf;
   PHB_ITEM pArray     = hb_itemArrayNew( 0 );
   BOOL     bReleaseDC = FALSE;

   memset( &lf, 0, sizeof( LOGFONT ) );

   if( GetObjectType( ( HGDIOBJ ) HB_PARNL( 1 ) ) == OBJ_DC )
      hdc = ( HDC ) HB_PARNL( 1 );
   else
   {
      hdc        = GetDC( NULL );
      bReleaseDC = TRUE;
   }

   if( hb_parclen( 2 ) > 0 )
      hb_strncpy( lf.lfFaceName, hb_parc( 2 ), HB_MIN( LF_FACESIZE - 1, hb_parclen( 2 ) ) );
   else
      lf.lfFaceName[ 0 ] = '\0';

   lf.lfCharSet        = ( BYTE ) hb_parni( 3 );
   lf.lfPitchAndFamily = ( BYTE ) ( hb_parnidef( 4, DEFAULT_PITCH ) | FF_DONTCARE );
   /* TODO - nFontType */

   EnumFontFamiliesEx( hdc, &lf, _EnumFontFamExProc, ( LPARAM ) pArray, 0 );

   if( bReleaseDC )
      ReleaseDC( NULL, hdc );

   if( HB_ISBLOCK( 6 ) )
      hb_arraySort( pArray, NULL, NULL, hb_param( 6, HB_IT_BLOCK ) );

   if( HB_ISBYREF( 7 ) )
   {
      PHB_ITEM aFontName = hb_param( 7, HB_IT_ANY );
      int      nLen      = hb_arrayLen( pArray ), i;

      hb_arrayNew( aFontName, nLen );

      for( i = 1; i <= nLen; i++ )
         hb_arraySetC( aFontName, i, hb_arrayGetC( hb_arrayGetItemPtr( pArray, i ), 1 ) );
   }

   hb_itemReturnRelease( pArray );
}

static int CALLBACK _EnumFontFamExProc( const LOGFONT * lpelfe, const TEXTMETRIC * lpntme, DWORD dwFontType, LPARAM pArray )
{
   if( lpelfe->lfFaceName[ 0 ] != '@' )
   {
      PHB_ITEM pSubArray = hb_itemArrayNew( 4 );

      hb_arraySetC( pSubArray, 1, lpelfe->lfFaceName );
      hb_arraySetNL( pSubArray, 2, lpntme->tmCharSet );
      hb_arraySetNI( pSubArray, 3, lpelfe->lfPitchAndFamily & FIXED_PITCH );
      hb_arraySetNI( pSubArray, 4, dwFontType & TRUETYPE_FONTTYPE );

      hb_arrayAddForward( ( PHB_ITEM ) pArray, pSubArray );
      hb_itemRelease( pSubArray );
   }

   return 1;
}
