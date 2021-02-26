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

   TOOLBAREX and TOOLBUTTONEX controls source code
   (C)2005 Janusz Pora <januszpora@onet.eu>

   ---------------------------------------------------------------------------*/

#define _WIN32_IE            0x0501
#define _WIN32_WINNT         0x0502

#include <mgdefs.h>

#include <commctrl.h>

#define NUM_TOOLBAR_BUTTONS  10

extern HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                                HB_BOOL bAlphaFormat, int iAlpfaConstant );

LRESULT APIENTRY  ToolBarExFunc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam );

HINSTANCE GetInstance( void );
HINSTANCE GetResources( void );

static LPTBBUTTON lpSaveButtons;
static int        nResetCount, buttonCount;
static int        isInSizeMsg = 0;

HB_FUNC( INITTOOLBAR )
{
   HWND hwnd;
   HWND hwndTB;
   int  Style = WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | TBSTYLE_TOOLTIPS;

   int ExStyle   = 0;
   int TbExStyle = TBSTYLE_EX_DRAWDDARROWS;

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 14 ) )
      ExStyle = ExStyle | WS_EX_CLIENTEDGE;

   if( hb_parl( 10 ) )
      Style = Style | TBSTYLE_FLAT;

   if( hb_parl( 11 ) )
      Style = Style | CCS_BOTTOM;

   if( hb_parl( 12 ) )
      Style = Style | TBSTYLE_LIST;

   if( hb_parl( 13 ) )
      Style = Style | CCS_NOPARENTALIGN | CCS_NODIVIDER | CCS_NORESIZE;

   if( hb_parl( 15 ) )
      Style = Style | TBSTYLE_WRAPABLE;

   if( hb_parl( 16 ) )
      Style = Style | CCS_ADJUSTABLE;

   hwndTB = CreateWindowEx( ExStyle, TOOLBARCLASSNAME, ( LPSTR ) NULL, Style, 0, 0, 0, 0, hwnd, ( HMENU ) HB_PARNL( 3 ), GetInstance(), NULL );

   if( hb_parni( 6 ) && hb_parni( 7 ) )
   {
      SendMessage( hwndTB, TB_SETBUTTONSIZE, hb_parni( 6 ), hb_parni( 7 ) );
      SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( hb_parni( 6 ), hb_parni( 7 ) ) );
   }

   SendMessage( hwndTB, TB_SETEXTENDEDSTYLE, 0, ( LPARAM ) TbExStyle );

   ShowWindow( hwndTB, SW_SHOW );
   HB_RETNL( ( LONG_PTR ) hwndTB );
}

HB_FUNC( INITTOOLBUTTON )
{
   HWND        hwndTB = ( HWND ) HB_PARNL( 1 );
   HWND        himage = NULL;
   TBADDBITMAP tbab;
   TBBUTTON    tbb[ NUM_TOOLBAR_BUTTONS ];
   int         index;
   int         nPoz;
   int         nBtn;
   int         Style = TBSTYLE_BUTTON;

   memset( tbb, 0, sizeof tbb );

   if( hb_parclen( 8 ) > 0 )
      himage = ( HWND ) HMG_LoadPicture( hb_parc( 8 ), -1, -1, hwndTB, 1, 1, -1, 0, HB_FALSE, 255 );

   // Add the bitmap containing button images to the toolbar.

   if( hb_parl( 11 ) )
      Style |= TBSTYLE_AUTOSIZE;

   nBtn       = 0;
   tbab.hInst = NULL;
   tbab.nID   = ( UINT_PTR ) himage;
   nPoz       = SendMessage( hwndTB, TB_ADDBITMAP, ( WPARAM ) 1, ( LPARAM ) &tbab );

   // Add the strings

   if( hb_parclen( 2 ) > 0 )
   {
      index = SendMessage( hwndTB, TB_ADDSTRING, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) );
      tbb[ nBtn ].iString = index;
   }

   if( hb_parl( 12 ) )
      Style |= BTNS_CHECK;

   if( hb_parl( 13 ) )
      Style |= BTNS_GROUP;

   if( hb_parl( 14 ) )
      Style |= BTNS_DROPDOWN;

   if( hb_parl( 15 ) )
      Style |= BTNS_WHOLEDROPDOWN;

   SendMessage( hwndTB, TB_AUTOSIZE, 0, 0 );

   // Button New

   tbb[ nBtn ].iBitmap   = nPoz;
   tbb[ nBtn ].idCommand = hb_parni( 3 );
   tbb[ nBtn ].fsState   = TBSTATE_ENABLED;
   tbb[ nBtn ].fsStyle   = ( BYTE ) Style;
   nBtn++;

   if( hb_parl( 10 ) )
   {
      tbb[ nBtn ].fsState = 0;
      tbb[ nBtn ].fsStyle = TBSTYLE_SEP;
      nBtn++;
   }

   SendMessage( hwndTB, TB_BUTTONSTRUCTSIZE, ( WPARAM ) sizeof( TBBUTTON ), 0 );

   SendMessage( hwndTB, TB_ADDBUTTONS, ( WPARAM ) nBtn, ( LPARAM ) &tbb );

   ShowWindow( hwndTB, SW_SHOW );

   HB_RETNL( ( LONG_PTR ) himage );
}

LONG WidestBtn( LPCTSTR pszStr, HWND hwnd )
{
   SIZE    sz;
   LOGFONT lf;
   HFONT   hFont;
   HDC     hdc;

   SystemParametersInfo( SPI_GETICONTITLELOGFONT, sizeof( LOGFONT ), &lf, 0 );

   hdc   = GetDC( hwnd );
   hFont = CreateFontIndirect( &lf );
   SelectObject( hdc, hFont );

   GetTextExtentPoint32( hdc, pszStr, strlen( pszStr ), &sz );

   ReleaseDC( hwnd, hdc );
   DeleteObject( hFont );

   return MAKELONG( sz.cx, sz.cy );
}

HB_FUNC( INITTOOLBAREX )
{
   HWND hwnd;
   HWND hwndTB;
   int  Style = WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | TBSTYLE_TOOLTIPS;

   int   ExStyle   = 0;
   int   TbExStyle = TBSTYLE_EX_DRAWDDARROWS | TBSTYLE_EX_HIDECLIPPEDBUTTONS;
   DWORD nPadd;

   INITCOMMONCONTROLSEX icex;

   icex.dwSize = sizeof( INITCOMMONCONTROLSEX );
   icex.dwICC  = ICC_BAR_CLASSES;
   InitCommonControlsEx( &icex );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( hb_parl( 14 ) )
      ExStyle = ExStyle | WS_EX_CLIENTEDGE;

   if( hb_parl( 10 ) )
      Style = Style | TBSTYLE_FLAT;

   if( hb_parl( 11 ) )
      Style = Style | CCS_BOTTOM;

   if( hb_parl( 12 ) )
      Style = Style | TBSTYLE_LIST;

   if( hb_parl( 13 ) )
      Style = Style | CCS_NOPARENTALIGN | CCS_NODIVIDER | CCS_NORESIZE;

   if( hb_parl( 15 ) )
      TbExStyle = TbExStyle | TBSTYLE_EX_MIXEDBUTTONS;

   if( hb_parl( 16 ) )
      Style = Style | TBSTYLE_WRAPABLE;

   if( hb_parl( 17 ) )
      Style = Style | CCS_ADJUSTABLE;


   hwndTB = CreateWindowEx( ExStyle, TOOLBARCLASSNAME, ( LPSTR ) NULL, Style, 0, 0, 0, 0, hwnd, ( HMENU ) HB_PARNL( 3 ), GetInstance(), NULL );

   if( hb_parni( 6 ) && hb_parni( 7 ) )
   {
      SendMessage( hwndTB, TB_SETBUTTONSIZE, hb_parni( 6 ), hb_parni( 7 ) );
      nPadd = SendMessage( hwndTB, TB_GETPADDING, 0, 0 );
      SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( hb_parni( 6 ) - LOWORD( nPadd ), hb_parni( 7 ) - HIWORD( nPadd ) ) );
   }

   SendMessage( hwndTB, TB_SETBUTTONWIDTH, 0, ( LPARAM ) MAKELONG( hb_parni( 6 ), hb_parni( 6 ) ) );
   SendMessage( hwndTB, TB_SETEXTENDEDSTYLE, 0, ( LPARAM ) TbExStyle );

   ShowWindow( hwndTB, SW_SHOW );
   HB_RETNL( ( LONG_PTR ) hwndTB );
}

HB_FUNC( INITTOOLBUTTONEX )
{
   HWND          hwndTB;
   HWND          himage;
   BITMAP        bm;
   TBADDBITMAP   tbab;
   TBBUTTON      lpBtn;
   TBBUTTON      tbb[ NUM_TOOLBAR_BUTTONS ];
   DWORD         tSize;
   char          cBuff[ 255 ] = "";
   int           index, i;
   int           nPoz, xBtn;
   int           nBtn, tmax;
   int           Style;
   DWORD         TbStyle;
   int           ix;
   int           iy;
   int           px;
   int           py;
   OSVERSIONINFO osvi;

   memset( tbb, 0, sizeof tbb );

   hwndTB  = ( HWND ) HB_PARNL( 1 );
   nBtn    = 0;
   tmax    = 0;
   ix      = 0;
   iy      = 0;
   xBtn    = SendMessage( hwndTB, TB_BUTTONCOUNT, 0, 0 );
   TbStyle = SendMessage( hwndTB, TB_GETSTYLE, 0, 0 );
   Style   = TBSTYLE_BUTTON;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( &osvi );

   // Add the strings

   if( hb_parclen( 2 ) )
   {
      index = SendMessage( hwndTB, TB_ADDSTRING, 0, ( LPARAM ) ( LPCTSTR ) hb_parc( 2 ) );
      tbb[ nBtn ].iString = index;
      Style = Style | BTNS_SHOWTEXT;
      tSize = WidestBtn( hb_parc( 2 ), hwndTB );
      tmax  = HIWORD( tSize );
      for( i = 0; i < xBtn; i++ )
      {
         SendMessage( hwndTB, TB_GETBUTTON, i, ( LPARAM ) &lpBtn );
         SendMessage( hwndTB, TB_GETBUTTONTEXT, lpBtn.idCommand, ( LPARAM ) ( LPCTSTR ) cBuff );
         tSize = WidestBtn( cBuff, hwndTB );
         if( tmax < HIWORD( tSize ) )
            tmax = HIWORD( tSize );
      }
   }

   tSize = SendMessage( hwndTB, TB_GETPADDING, 0, 0 );
   px    = LOWORD( tSize );
   py    = HIWORD( tSize );

   if( hb_parl( 16 ) )
   {
      ix = hb_parni( 6 ) - px;
      iy = hb_parni( 7 ) - py;
   }

   himage = ( HWND ) LoadImage( GetResources(), hb_parc( 8 ), IMAGE_BITMAP, ix, iy, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if( himage == NULL )
      himage = ( HWND ) LoadImage( NULL, hb_parc( 8 ), IMAGE_BITMAP, ix, iy, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );
   if( himage == NULL )
      himage = ( HWND ) HMG_LoadPicture( hb_parc( 8 ), -1, -1, hwndTB, 1, 1, -1, 0, HB_FALSE, 255 );

   if( himage != NULL )
   {
      tSize = SendMessage( hwndTB, TB_GETPADDING, 0, 0 );
      px    = LOWORD( tSize );
      py    = HIWORD( tSize );
      if( GetObject( himage, sizeof( BITMAP ), &bm ) != 0 )
      {
         ix = bm.bmWidth;
         iy = bm.bmHeight;
         if( TbStyle & TBSTYLE_LIST )
            tmax = 0;

         if( ( ix + px ) > hb_parni( 6 ) )
            ix = hb_parni( 6 ) - px;
         else
            px = hb_parni( 6 ) - ix;

         if( ( iy + tmax + py ) > hb_parni( 7 ) )
            iy = hb_parni( 7 ) - tmax - py;
         else
            py = hb_parni( 7 ) - tmax - iy;

         if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT && osvi.dwMajorVersion <= 4 )
         {
            if( ! ( TbStyle & TBSTYLE_LIST ) )
               SendMessage( hwndTB, TB_SETPADDING, 0, MAKELPARAM( px, py ) );
         }
         else if( ! ( Style & BTNS_SHOWTEXT ) )
            SendMessage( hwndTB, TB_SETPADDING, 0, MAKELPARAM( px, py ) );

         SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( ix, iy ) );
      }
   }

   // Add the bitmap containing button images to the toolbar.

   if( hb_parl( 11 ) )
      Style = Style | TBSTYLE_AUTOSIZE;

   nBtn = 0;
   if( hb_parni( 17 ) > -1 )
   {
      if( xBtn == 0 )
      {
         if( hb_parni( 18 ) > IDB_HIST_LARGE_COLOR )
         {
            SendMessage( hwndTB, TB_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) ( HIMAGELIST ) HB_PARNL( 18 ) );
            if( hb_parni( 19 ) )
               SendMessage( hwndTB, TB_SETHOTIMAGELIST, ( WPARAM ) 0, ( LPARAM ) ( HIMAGELIST ) HB_PARNL( 19 ) );

            tbab.nID = hb_parni( 18 );
         }
         else
         {
            tbab.hInst = HINST_COMMCTRL;
            tbab.nID   = hb_parni( 18 );
            SendMessage( hwndTB, TB_ADDBITMAP, ( WPARAM ) 1, ( LPARAM ) &tbab );
         }
      }

      nPoz = hb_parni( 17 );
   }
   else
   {
      tbab.hInst = NULL;
      tbab.nID   = ( UINT_PTR ) ( HBITMAP ) himage;
      nPoz       = SendMessage( hwndTB, TB_ADDBITMAP, ( WPARAM ) 1, ( LPARAM ) &tbab );
   }

   if( hb_parl( 12 ) )
      Style = Style | BTNS_CHECK;

   if( hb_parl( 13 ) )
      Style = Style | BTNS_GROUP;

   if( hb_parl( 14 ) )
      Style = Style | BTNS_DROPDOWN;

   if( hb_parl( 15 ) )
      Style = Style | BTNS_WHOLEDROPDOWN;

   SendMessage( hwndTB, TB_AUTOSIZE, 0, 0 );

   // Button New

   tbb[ nBtn ].iBitmap   = nPoz;
   tbb[ nBtn ].idCommand = hb_parni( 3 );
   tbb[ nBtn ].fsState   = TBSTATE_ENABLED;
   tbb[ nBtn ].fsStyle   = ( BYTE ) Style;
   nBtn++;

   if( hb_parl( 10 ) )
   {
      tbb[ nBtn ].fsState = 0;
      tbb[ nBtn ].fsStyle = TBSTYLE_SEP;
      nBtn++;
   }

   SendMessage( hwndTB, TB_BUTTONSTRUCTSIZE, ( WPARAM ) sizeof( TBBUTTON ), 0 );

   SendMessage( hwndTB, TB_ADDBUTTONS, nBtn, ( LPARAM ) &tbb );

   ShowWindow( hwndTB, SW_SHOW );

   HB_RETNL( ( LONG_PTR ) himage );
}

HB_FUNC( GETSIZETOOLBAR )
{
   SIZE          lpSize;
   TBBUTTON      lpBtn;
   int           i, nBtn;
   OSVERSIONINFO osvi;
   HWND          hwndTB;

   hwndTB = ( HWND ) HB_PARNL( 1 );

   SendMessage( hwndTB, TB_GETMAXSIZE, 0, ( LPARAM ) &lpSize );

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( &osvi );
   nBtn = SendMessage( hwndTB, TB_BUTTONCOUNT, 0, 0 );
   for( i = 0; i < nBtn; i++ )
   {
      SendMessage( hwndTB, TB_GETBUTTON, i, ( LPARAM ) &lpBtn );
      if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT && osvi.dwMajorVersion <= 4 )
         if( lpBtn.fsStyle & TBSTYLE_SEP )
            lpSize.cx = lpSize.cx + 3;

      if( lpBtn.fsStyle & BTNS_DROPDOWN )
         lpSize.cx = lpSize.cx + 16;
   }

   hb_retnl( MAKELONG( lpSize.cy, lpSize.cx ) );
}

HB_FUNC( MAXTEXTBTNTOOLBAR )  //(HWND hwndTB, int cx, int cy)
{
   char cString[ 255 ] = "";
   HWND hwndTB;

   int      i, nBtn;
   int      tmax = 0;
   int      ty   = 0;
   DWORD    tSize;
   DWORD    Style;
   TBBUTTON lpBtn;

   hwndTB = ( HWND ) HB_PARNL( 1 );
   nBtn   = SendMessage( hwndTB, TB_BUTTONCOUNT, 0, 0 );
   for( i = 0; i < nBtn; i++ )
   {
      SendMessage( hwndTB, TB_GETBUTTON, i, ( LPARAM ) &lpBtn );
      SendMessage( hwndTB, TB_GETBUTTONTEXT, lpBtn.idCommand, ( LPARAM ) ( LPCTSTR ) cString );

      tSize = WidestBtn( cString, hwndTB );
      ty    = HIWORD( tSize );

      if( tmax < LOWORD( tSize ) )
         tmax = LOWORD( tSize );
   }

   if( tmax == 0 )
   {
      SendMessage( hwndTB, TB_SETBUTTONSIZE, hb_parni( 2 ), hb_parni( 3 ) );   //  -ty);
      SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( hb_parni( 2 ), hb_parni( 3 ) ) );
   }
   else
   {
      Style = SendMessage( hwndTB, TB_GETSTYLE, 0, 0 );
      if( Style & TBSTYLE_LIST )
      {
         SendMessage( hwndTB, TB_SETBUTTONSIZE, hb_parni( 2 ), hb_parni( 3 ) + 2 );
         SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( hb_parni( 3 ), hb_parni( 3 ) ) );
      }
      else
      {
         SendMessage( hwndTB, TB_SETBUTTONSIZE, hb_parni( 2 ), hb_parni( 3 ) - ty + 2 );
         SendMessage( hwndTB, TB_SETBITMAPSIZE, 0, ( LPARAM ) MAKELONG( hb_parni( 3 ) - ty, hb_parni( 3 ) - ty ) );
      }

      SendMessage( hwndTB, TB_SETBUTTONWIDTH, 0, ( LPARAM ) MAKELONG( hb_parni( 2 ), hb_parni( 2 ) + 2 ) );
   }

   SendMessage( hwndTB, TB_AUTOSIZE, 0, 0 ); //JP62
}

HB_FUNC( ISBUTTONBARCHECKED )          // hb_parni(2) -> Position in ToolBar
{
   TBBUTTON lpBtn;

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETBUTTON, hb_parni( 2 ), ( LPARAM ) &lpBtn );
   hb_retl( SendMessage( ( HWND ) HB_PARNL( 1 ), TB_ISBUTTONCHECKED, lpBtn.idCommand, 0 ) );
}

HB_FUNC( CHECKBUTTONBAR )              // hb_parni(2) -> Position in ToolBar
{
   TBBUTTON lpBtn;

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETBUTTON, hb_parni( 2 ), ( LPARAM ) &lpBtn );
   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_CHECKBUTTON, lpBtn.idCommand, hb_parl( 3 ) );
}

HB_FUNC( ISBUTTONENABLED )             // hb_parni(2) -> Position in ToolBar
{
   TBBUTTON lpBtn;

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETBUTTON, hb_parni( 2 ), ( LPARAM ) &lpBtn );
   hb_retl( SendMessage( ( HWND ) HB_PARNL( 1 ), TB_ISBUTTONENABLED, lpBtn.idCommand, 0 ) );
}

HB_FUNC( GETBUTTONBARRECT )
{
   RECT rc;

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETITEMRECT, ( WPARAM ) hb_parnl( 2 ), ( LPARAM ) &rc );
   hb_retnl( MAKELONG( rc.left, rc.bottom ) );
}

HB_FUNC( GETBUTTONPOS )
{
   hb_retnl( ( ( ( NMTOOLBAR FAR * ) HB_PARNL( 1 ) )->iItem ) );
}

HB_FUNC( SETBUTTONTIP )
{
   LPTOOLTIPTEXT lpttt;

   lpttt = ( LPTOOLTIPTEXT ) HB_PARNL( 1 );
   lpttt->lpszText = ( LPSTR ) hb_parc( 2 );
}

HB_FUNC( SETTOOLBUTTONCAPTION )
{
   TBBUTTONINFO tbinfo;

   tbinfo.cbSize  = sizeof( tbinfo );
   tbinfo.dwMask  = TBIF_TEXT;
   tbinfo.pszText = ( LPSTR ) hb_parc( 3 );

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_SETBUTTONINFO, hb_parni( 2 ), ( LPARAM ) &tbinfo );
}

HB_FUNC( SETTOOLBUTTONIMAGE )
{
   TBBUTTONINFO tbinfo;

   tbinfo.cbSize = sizeof( tbinfo );
   tbinfo.dwMask = TBIF_IMAGE;
   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETBUTTONINFO, hb_parni( 2 ), ( LPARAM ) &tbinfo );

   tbinfo.iImage = hb_parni( 3 );
   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_SETBUTTONINFO, hb_parni( 2 ), ( LPARAM ) &tbinfo );
}

HB_FUNC( REPLACETOOLBUTTONIMAGE )
{
   HWND    hwndTB     = ( HWND ) HB_PARNL( 1 );
   HBITMAP hBitmapOld = ( HBITMAP ) HB_PARNL( 2 );
   int     iImageIdx  = hb_parl( 4 ) ? I_IMAGECALLBACK : I_IMAGENONE;
   int     nButtonID  = ( int ) hb_parni( 5 );
   HBITMAP hBitmapNew;

   hBitmapNew = ( HBITMAP ) HMG_LoadPicture( hb_parc( 3 ), -1, -1, hwndTB, 1, 1, -1, 0, HB_FALSE, 255 );

   if( ( hBitmapOld != NULL ) && ( hBitmapNew != NULL ) )
   {
      TBREPLACEBITMAP tbrb;
      tbrb.hInstOld = NULL;
      tbrb.nIDOld   = ( UINT_PTR ) hBitmapOld;
      tbrb.hInstNew = NULL;
      tbrb.nIDNew   = ( UINT_PTR ) hBitmapNew;
      tbrb.nButtons = 1;
      SendMessage( hwndTB, TB_REPLACEBITMAP, 0, ( LPARAM ) &tbrb );
   }
   else
   {
      TBBUTTONINFO tbinfo;
      int          iBitMapIndex;

      if( hBitmapNew != NULL )
      {
         TBADDBITMAP tbab;
         tbab.hInst   = NULL;
         tbab.nID     = ( UINT_PTR ) hBitmapNew;
         iBitMapIndex = SendMessage( hwndTB, TB_ADDBITMAP, ( WPARAM ) 1, ( LPARAM ) &tbab );
      }
      else
         iBitMapIndex = iImageIdx;

      tbinfo.cbSize = sizeof( tbinfo );
      tbinfo.dwMask = TBIF_IMAGE;
      SendMessage( hwndTB, TB_GETBUTTONINFO, ( WPARAM ) nButtonID, ( LPARAM ) &tbinfo );

      tbinfo.iImage = iBitMapIndex;
      SendMessage( hwndTB, TB_SETBUTTONINFO, ( WPARAM ) nButtonID, ( LPARAM ) &tbinfo );
   }

   HB_RETNL( ( LONG_PTR ) hBitmapNew );
}

HB_FUNC( SETROWSBUTTON )               //SetRowsButton( hwndTB , nRow , fLarger )
{
   RECT rc;

   SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) TB_SETROWS, ( WPARAM ) MAKEWPARAM( hb_parni( 2 ), hb_parl( 3 ) ), ( LPARAM ) &rc );

   hb_reta( 2 );
   HB_STORVNL( rc.right - rc.left, -1, 1 );
   HB_STORVNL( rc.bottom - rc.top, -1, 2 );
}

HB_FUNC( RESIZESPLITBOXITEM )          //ResizeSplitBoxItem (hwndSB , nBandIndex, cx, cy, cxId )
{
   REBARBANDINFO rbBand;

   rbBand.cbSize = sizeof( REBARBANDINFO );
   rbBand.fMask  = RBBIM_CHILDSIZE | RBBIM_IDEALSIZE;
   SendMessage( ( HWND ) HB_PARNL( 1 ), RB_GETBANDINFO, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &rbBand );

   rbBand.fStyle     = rbBand.fStyle | RBBS_USECHEVRON;
   rbBand.cxMinChild = hb_parni( 3 );
   rbBand.cyMinChild = hb_parni( 4 );
   rbBand.cxIdeal    = hb_parni( 5 );
   rbBand.cx         = hb_parni( 5 );

   SendMessage( ( HWND ) HB_PARNL( 1 ), RB_SETBANDINFO, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &rbBand );
}

HB_FUNC( SETCHEVRONSTYLESPLITBOXITEM ) //SetChevronStyleSplitBoxItem (hwndSB , nBandIndex, cxIdeal )
{
   INT r;
   REBARBANDINFO rbBand;

   rbBand.cbSize = sizeof( REBARBANDINFO );
   rbBand.fMask  = RBBIM_STYLE | RBBIM_IDEALSIZE;

   SendMessage( ( HWND ) HB_PARNL( 1 ), RB_GETBANDINFO, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &rbBand );

   rbBand.fStyle  = rbBand.fStyle | RBBS_USECHEVRON;
   rbBand.cxIdeal = hb_parni( 3 ) + 50;

   r = SendMessage( ( HWND ) HB_PARNL( 1 ), RB_SETBANDINFO, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &rbBand );
   if( r == 0 )
      hb_retl( FALSE );
   else
      hb_retl( TRUE );
}

int TestHidenBtn( HWND tbHwnd, RECT rcRb, INT dv, INT nBtn )
{
   RECT rcDst, rcBt;
   int  nBtnV = 0;
   int  i;

   for( i = 0; i < nBtn; i++ )
   {
      SendMessage( ( HWND ) tbHwnd, TB_GETITEMRECT, ( WPARAM ) ( UINT ) i, ( LPARAM ) &rcBt );

      rcBt.left   += dv;
      rcBt.top    += rcRb.top;
      rcBt.right  += dv;
      rcBt.bottom += rcRb.top;

      IntersectRect( &rcDst, &rcRb, &rcBt );
      if( EqualRect( &rcDst, &rcBt ) )
         nBtnV++;
   }

   return nBtnV;
}

HB_FUNC( CREATEPOPUPCHEVRON )          //CreatePopUpChevron(hwndRebar, lParam)
{
   RECT rcRb;
   RECT rcTB;
   RECT rcRR;
   RECT rcCvr;
   int  uBand;
   int  tx;
   int  dv;
   int  nBtn;
   LPNMREBARCHEVRON lpRB;
   REBARBANDINFO    rbbi;
   HWND tbHwnd;

   GetWindowRect( ( HWND ) HB_PARNL( 1 ), &rcRR );

   lpRB  = ( LPNMREBARCHEVRON ) HB_PARNL( 2 );
   uBand = lpRB->uBand;
   rcCvr = lpRB->rc;

   SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) RB_GETRECT, ( WPARAM ) uBand, ( LPARAM ) &rcRb );

   rcRb.right -= ( ( rcCvr.right - rcCvr.left ) );
   rbbi.cbSize = sizeof( REBARBANDINFO );
   rbbi.fMask  = RBBIM_SIZE | RBBIM_CHILD | RBBIM_CHILDSIZE;

   SendMessage( ( HWND ) HB_PARNL( 1 ), RB_GETBANDINFO, ( WPARAM ) uBand, ( LPARAM ) ( LPREBARBANDINFO ) &rbbi );

   tbHwnd = ( HWND ) rbbi.hwndChild;
   GetWindowRect( ( HWND ) tbHwnd, &rcTB );
   dv   = rcTB.left - rcRR.left + 1;
   nBtn = ( INT ) SendMessage( ( HWND ) tbHwnd, TB_BUTTONCOUNT, 0, 0 );

   tx = TestHidenBtn( ( HWND ) tbHwnd, rcRb, dv, nBtn );

   hb_reta( 7 );
   HB_STORVNL( rcCvr.left, -1, 1 );
   HB_STORVNL( rcCvr.top, -1, 2 );
   HB_STORVNL( rcCvr.right, -1, 3 );
   HB_STORVNL( rcCvr.bottom, -1, 4 );
   HB_STORVNL( ( LONG_PTR ) tbHwnd, -1, 5 );
   HB_STORNI( tx, -1, 6 );
   HB_STORNI( nBtn, -1, 7 );
}

HB_FUNC( GETBUTTONBAR )                // hb_parni(2) -> Position in ToolBar
{
   TBBUTTON lpBtn;
   BOOL     lSep;
   BOOL     lEnable;

   SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETBUTTON, hb_parni( 2 ), ( LPARAM ) &lpBtn );

   lSep    = ( lpBtn.fsStyle & TBSTYLE_SEP ) ? TRUE : FALSE;
   lEnable = ( lpBtn.fsState & TBSTATE_ENABLED ) ? TRUE : FALSE;

   hb_reta( 4 );
   HB_STORNI( lpBtn.iBitmap, -1, 1 );
   HB_STORNI( lpBtn.idCommand, -1, 2 );
   HB_STORL( lSep, -1, 3 );
   HB_STORL( lEnable, -1, 4 );
}

HB_FUNC( GETIMAGELIST )                // GetImageList(tbhwnd, posBtn)
{
   HIMAGELIST himl;
   HBITMAP    himage;
   IMAGEINFO  ImageInfo;

   himl = ( HIMAGELIST ) SendMessage( ( HWND ) HB_PARNL( 1 ), TB_GETIMAGELIST, 0, 0 );
   ImageList_GetImageInfo( himl, ( INT ) hb_parni( 2 ), &ImageInfo );

   himage = ImageInfo.hbmImage;

   HB_RETNL( ( LONG_PTR ) himage );
}

HB_FUNC( SETCHEVRONIMAGE )             // SetChevronImage(hMenu, id_Command, image)
{
   SetMenuItemBitmaps( ( HMENU ) HB_PARNL( 1 ), hb_parni( 2 ), MF_BYCOMMAND, ( HBITMAP ) HB_PARNL( 3 ), ( HBITMAP ) HB_PARNL( 3 ) );
}

HB_FUNC( DESTROYMENU )
{
   DestroyMenu( ( HMENU ) HB_PARNL( 1 ) );
}

HB_FUNC( ADJUSTFLOATTOOLBAR )          // AdjustFloatToolbar(HWND hwndMain,HWND hwndft,HWND hwndTB)
{
   HWND  hwndTB;
   RECT  rc;
   int   nbuttons, height, width;
   POINT pt;

   hwndTB = ( HWND ) HB_PARNL( 3 );

   SendMessage( hwndTB, TB_GETITEMRECT, 0, ( LPARAM ) &rc );
   nbuttons = SendMessage( hwndTB, TB_BUTTONCOUNT, 0, 0 );

   height = rc.bottom + GetSystemMetrics( SM_CYCAPTION ) + GetSystemMetrics( SM_CYFRAME ) + 2 * GetSystemMetrics( SM_CYDLGFRAME );
   width  = ( nbuttons ) * rc.right;
   width += 2 * GetSystemMetrics( SM_CXDLGFRAME );
   pt.x   = pt.y = 50;

   MapWindowPoints( ( HWND ) HB_PARNL( 1 ), HWND_DESKTOP, ( LPPOINT ) &pt, 1 );
   MoveWindow( ( HWND ) HB_PARNL( 2 ), pt.x, pt.y, width, height, TRUE );
}

int ResizeToolbar( HWND hwndTB, int widthTb )
{
   RECT  rcb, rc;
   int   n, width, height, nrow;
   HWND  hwndParent;
   DWORD style;
   int   nButtons, bwidth, nBtnRow;
   int   heightTB;

   hwndTB  = ( HWND ) HB_PARNL( 1 );
   widthTb = hb_parni( 2 );

   SendMessage( hwndTB, TB_GETITEMRECT, 0, ( LPARAM ) &rc );
   bwidth = rc.right;
   if( widthTb < bwidth )
      return 0;

   GetWindowRect( hwndTB, &rc );
   heightTB = rc.bottom - rc.top;

   nButtons = SendMessage( hwndTB, TB_BUTTONCOUNT, 0, 0 );

   memset( &rcb, 0, sizeof( RECT ) );
   if( bwidth > 0 )
      n = widthTb / ( bwidth );
   else
      return 0;

   if( nButtons % n == 0 )
      nrow = nButtons / n;
   else
      nrow = nButtons / n + 1;

   SendMessage( hwndTB, TB_SETROWS, MAKEWPARAM( nrow, TRUE ), ( LPARAM ) &rcb );
   SendMessage( hwndTB, TB_AUTOSIZE, 0, 0 );

   hwndParent = GetParent( hwndTB );
   style      = GetWindowLong( hwndParent, GWL_STYLE );
   AdjustWindowRect( &rcb, style, 0 );
   MapWindowPoints( hwndParent, HWND_DESKTOP, ( LPPOINT ) &rcb, 2 );

   nBtnRow = nButtons / ( nrow );
   if( nrow > 1 )
      nBtnRow += nButtons & 1;

   width  = nBtnRow * bwidth;
   width += 2 * GetSystemMetrics( SM_CXDLGFRAME );
   width += 2 * GetSystemMetrics( SM_CXBORDER );
   height = rcb.bottom - rcb.top;
   if( ! ( width == widthTb ) || ! ( height == heightTB ) )
      MoveWindow( hwndParent, rcb.left, rcb.top, width, height, TRUE );

   return 1;
}

HB_FUNC( RESIZEFLOATTOOLBAR )          // ResizeFloatToolbar(HWND hwndTB,int widthTb )
{
   HWND hwndTB  = ( HWND ) HB_PARNL( 1 );
   int  widthTb = hb_parni( 2 );

   if( isInSizeMsg )
      hb_retl( FALSE );

   isInSizeMsg = 1;

   if( hwndTB )
      ResizeToolbar( hwndTB, widthTb );

   isInSizeMsg = 0;

   hb_retl( TRUE );
}

HB_FUNC( TOOLBAREXCUSTFUNC )     // ToolBarExCustFunc( hWnd, Msg, wParam, lParam )
{
   TBBUTTON   lpBtn;
   UINT       Msg    = ( UINT ) hb_parni( 2 );
   LPARAM     lParam = ( LPARAM ) HB_PARNL( 4 );
   LPTBNOTIFY lpTB   = ( LPTBNOTIFY ) lParam;
   int        i;

   switch( Msg )
   {
      case WM_NOTIFY:
         switch( ( ( LPNMHDR ) lParam )->code )
         {
            case TBN_BEGINADJUST: //Start customizing the toolbar.

               nResetCount = SendMessage( lpTB->hdr.hwndFrom, TB_BUTTONCOUNT, 0, 0 );
               buttonCount = nResetCount;

               lpSaveButtons = ( LPTBBUTTON ) GlobalAlloc( GPTR, sizeof( TBBUTTON ) * nResetCount );
               for( i = 0; i < nResetCount; i++ )
                  SendMessage( lpTB->hdr.hwndFrom, TB_GETBUTTON, i, ( LPARAM ) ( lpSaveButtons + i ) );

               hb_retl( TRUE );
               break;

            case TBN_GETBUTTONINFO:
            {
               LPTBNOTIFY lpTbNotify = ( LPTBNOTIFY ) lParam;

               if( lpTbNotify->iItem >= buttonCount || lpTbNotify->iItem < 0 )
                  hb_retl( FALSE );
               else
               {
                  SendMessage( lpTB->hdr.hwndFrom, TB_GETBUTTON, lpTbNotify->iItem, ( LPARAM ) &lpBtn );
                  lpTbNotify->tbButton = lpSaveButtons[ lpTbNotify->iItem ];

                  hb_retl( TRUE );
               }
            }
            break;

            case TBN_RESET:
            {
               int nCount;

               nCount = SendMessage( lpTB->hdr.hwndFrom, TB_BUTTONCOUNT, 0, 0 );
               for( i = nCount - 1; i >= 0; i-- )
                  SendMessage( lpTB->hdr.hwndFrom, TB_DELETEBUTTON, i, 0 );

               SendMessage( lpTB->hdr.hwndFrom, TB_ADDBUTTONS,
                            ( WPARAM ) nResetCount, ( LPARAM ) lpSaveButtons );

               hb_retl( TRUE );
            }
            break;

            case TBN_ENDADJUST:

               GlobalFree( ( HGLOBAL ) lpSaveButtons );
               hb_retl( TRUE );
               break;

            default:
               hb_retl( FALSE );
               break;
         }
   }
}
