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
    Copyright 1999-2020, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include <commctrl.h>

#ifndef WC_BUTTON
# define WC_BUTTON         "Button"
#endif

#ifndef BCM_FIRST
# define BCM_FIRST         0x1600
# define BCM_SETIMAGELIST  ( BCM_FIRST + 0x0002 )
#endif

HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                         HB_BOOL bAlphaFormat, int iAlpfaConstant );

HIMAGELIST HMG_SetButtonImageList( HWND hButton, const char * FileName, int Transparent, UINT uAlign );

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 ) || ( defined ( __MINGW32__ ) && defined ( __MINGW32_VERSION ) ) || defined ( __XCC__ )
typedef struct
{
   HIMAGELIST himl;
   RECT       margin;
   UINT       uAlign;
} BUTTON_IMAGELIST, * PBUTTON_IMAGELIST;
#endif

HB_FUNC( INITCHECKBOX )
{
   HWND hwnd;
   HWND hbutton;

   int Style;
   int ExStyle = 0;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | WS_CHILD;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_TABSTOP;

   if( hb_parl( 12 ) )
      Style = Style | BS_LEFTTEXT;

   if( hb_parl( 6 ) )
      Style = Style | BS_MULTILINE;

   Style |= ( hb_parl( 7 ) ? BS_AUTO3STATE : BS_AUTOCHECKBOX );

   if( hb_parl( 13 ) )
      ExStyle |= WS_EX_TRANSPARENT;

   hbutton = CreateWindowEx
             (
      ExStyle,
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      hb_parni( 9 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITCHECKBUTTON )
{
   HWND hwnd;
   HWND hbutton;
   int  Style;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | WS_CHILD | BS_AUTOCHECKBOX | BS_PUSHLIKE;

   if( ! hb_parl( 10 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_TABSTOP;

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 8 ),
      hb_parni( 9 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITIMAGECHECKBUTTON )
{
   HWND       hwnd;
   HWND       hbutton;
   HWND       himage;
   int        Style;
   HIMAGELIST himl;
   int        Transparent = hb_parnidef( 7, 0 );

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | BS_BITMAP | WS_CHILD | BS_AUTOCHECKBOX | BS_PUSHLIKE;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_TABSTOP;

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 9 ),
      hb_parni( 10 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   if( ! hb_parl( 13 ) )
   {
      himage = ( HWND ) HMG_LoadPicture( hb_parc( 8 ), -1, -1, hwnd, 0, Transparent, -1, 0, HB_FALSE, 255 );

      SendMessage( hbutton, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

      hb_reta( 2 );
      HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
      HB_STORVNL( ( LONG_PTR ) himage, -1, 2 );
   }
   else
   {
      himl = HMG_SetButtonImageList( hbutton, hb_parc( 8 ), Transparent, BUTTON_IMAGELIST_ALIGN_CENTER );

      hb_reta( 2 );
      HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
      HB_STORVNL( ( LONG_PTR ) himl, -1, 2 );
   }
}
