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

#define _WIN32_IE  0x0501

#include <mgdefs.h>

#include <shlobj.h>
#include <commctrl.h>
#ifdef __XCC__
#include "unknwn.h"
#endif

#if defined ( __MINGW32__ ) && defined ( __MINGW32_VERSION )

#define Pager_ForwardMouse( hwnd, bForward ) \
   ( void ) SendMessage( ( hwnd ), PGM_FORWARDMOUSE, ( WPARAM ) ( bForward ), 0 )

#define Pager_SetBorder( hwnd, iBorder ) \
   ( int ) SendMessage( ( hwnd ), PGM_SETBORDER, 0, ( LPARAM ) ( iBorder ) )

#define Pager_GetBorder( hwnd ) \
   ( int ) SendMessage( ( hwnd ), PGM_GETBORDER, 0, 0 )

#define Pager_SetPos( hwnd, iPos ) \
   ( int ) SendMessage( ( hwnd ), PGM_SETPOS, 0, ( LPARAM ) ( iPos ) )

#define Pager_GetPos( hwnd ) \
   ( int ) SendMessage( ( hwnd ), PGM_GETPOS, 0, 0 )

#define Pager_SetButtonSize( hwnd, iSize ) \
   ( int ) SendMessage( ( hwnd ), PGM_SETBUTTONSIZE, 0, ( LPARAM ) ( iSize ) )

#define Pager_GetButtonSize( hwnd ) \
   ( int ) SendMessage( ( hwnd ), PGM_GETBUTTONSIZE, 0, 0 )

#endif

/* missing constants in Watcom */
#if defined( __WATCOMC__ )
#define PGF_CALCWIDTH   1
#define PGF_CALCHEIGHT  2
#endif

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif
HINSTANCE GetInstance( void );

HB_FUNC( GETHANDLEREBAR )  // GetHandleRebar(hPager)
{
   HWND hRebar = ( HWND ) GetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), GWLP_USERDATA );

   HB_RETNL( ( LONG_PTR ) hRebar );
}

HB_FUNC( ADDTOPAGER )      // AdToPager (hwndPG , hToolBar)
{
   HWND hPager = ( HWND ) HB_PARNL( 1 );
   HWND hTool  = ( HWND ) HB_PARNL( 2 );

   SendMessage( hPager, PGM_SETCHILD, 0, ( LPARAM ) hTool );
   SendMessage( hPager, PGM_RECALCSIZE, 0, 0 );
}

HB_FUNC( SETBKCOLORPAGER ) // SetBkColorPager(hwndPG , COLOR[])
{
   SendMessage( ( HWND ) HB_PARNL( 1 ), PGM_SETBKCOLOR, 0, ( LPARAM ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( PAGERCALCSIZE )   // PagerCalcSize(lParam , nWidth)
{
   NMPGCALCSIZE * lpCalcSize;

   lpCalcSize = ( LPNMPGCALCSIZE ) HB_PARNL( 1 );
   if( lpCalcSize->dwFlag == PGF_CALCWIDTH )
      lpCalcSize->iWidth = ( INT ) hb_parni( 2 );

   if( lpCalcSize->dwFlag == PGF_CALCHEIGHT )
      lpCalcSize->iHeight = ( INT ) hb_parni( 2 );
}

HB_FUNC( PAGERSCROLL )     // PagerScroll(lParam , nScroll)
{
   NMPGSCROLL * lpScroll;

   lpScroll = ( LPNMPGSCROLL ) HB_PARNL( 1 );
   lpScroll->iScroll = ( INT ) hb_parnl( 2 );
}

HB_FUNC( INITPAGER )       // InitPager ( ParentForm, hRebar, nWidth, nHeight, vertical, autoscroll )
{
   HWND hPager;
   int  Style = WS_CHILD | WS_VISIBLE;
   int  nWidth, nHeight;
   HWND hRebar;
   REBARBANDINFO rbBand;
#ifndef UNICODE
   LPSTR  lpText = ( char * ) hb_parc( 6 );
#else
   LPWSTR lpText = AnsiToWide( ( char * ) hb_parc( 6 ) );
#endif

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_COOL_CLASSES | ICC_BAR_CLASSES | ICC_PAGESCROLLER_CLASS;
   InitCommonControlsEx( &i );

   hRebar  = ( HWND ) HB_PARNL( 1 );
   nWidth  = ( INT ) hb_parni( 2 );
   nHeight = ( INT ) hb_parni( 3 );

   if( hb_parl( 4 ) )
      Style = Style | PGS_VERT;
   else
      Style = Style | PGS_HORZ;

   if( hb_parl( 5 ) )
      Style = Style | PGS_AUTOSCROLL;

   ZeroMemory( &rbBand, sizeof( REBARBANDINFO ) );
   rbBand.cbSize     = sizeof( REBARBANDINFO );
   rbBand.fMask      = RBBIM_TEXT | RBBIM_STYLE | RBBIM_CHILD | RBBIM_CHILDSIZE | RBBIM_SIZE | RBBS_BREAK | RBBIM_COLORS;
   rbBand.fStyle     = RBBS_CHILDEDGE;
   rbBand.cxMinChild = 0;
   rbBand.cyMinChild = 0;

   hPager = CreateWindowEx( 0, WC_PAGESCROLLER, NULL, Style, 0, 0, 0, 0, hRebar, NULL, GetInstance(), NULL );

   if( hb_parclen( 6 ) > 0 )
      rbBand.lpText = lpText;

   rbBand.hwndChild = hPager;

   if( hb_parl( 4 ) )
   {
      rbBand.cyMinChild = nWidth ? nWidth : 0;
      rbBand.cxMinChild = 0;
      rbBand.cx         = nHeight;
   }
   else
   {
      rbBand.cxMinChild = 0;
      rbBand.cyMinChild = nHeight ? nHeight : 0;
      rbBand.cx         = nWidth;
   }

   SendMessage( hRebar, RB_INSERTBAND, ( WPARAM ) -1, ( LPARAM ) &rbBand );

   SetWindowLongPtr( hPager, GWLP_USERDATA, ( LONG_PTR ) hRebar );

   HB_RETNL( ( LONG_PTR ) hPager );
}

HB_FUNC( PAGERFORWARDMOUSE )
{
   Pager_ForwardMouse( ( HWND ) HB_PARNL( 1 ), ( BOOL ) hb_parl( 2 ) );
}

HB_FUNC( PAGERGETBUTTONSIZE )
{
   hb_retni( ( INT ) Pager_GetButtonSize( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( PAGERSETBUTTONSIZE )
{
   Pager_SetButtonSize( ( HWND ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ) );
}

HB_FUNC( PAGERGETBORDER )
{
   hb_retni( ( INT ) Pager_GetBorder( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( PAGERSETBORDER )
{
   hb_retni( ( INT ) Pager_SetBorder( ( HWND ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ) ) );
}

HB_FUNC( PAGERGETPOS )
{
   hb_retni( ( INT ) Pager_GetPos( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( PAGERSETPOS )
{
   hb_retni( ( INT ) Pager_SetPos( ( HWND ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ) ) );
}
