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

   Parts of this code is contributed and used here under permission of his author:
       Copyright 2005 (C) Jacek Kubica <kubica@wssk.wroc.pl>
   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include <shellapi.h>
#include <commctrl.h>
#include <math.h>

#include "hbapiitm.h"
#include "hbvm.h"

#ifndef WC_BUTTON
# define WC_BUTTON         "Button"
#endif

#ifndef BCM_FIRST
# define BCM_FIRST         0x1600
# define BCM_SETIMAGELIST  ( BCM_FIRST + 0x0002 )
#endif

static HBRUSH     CreateGradientBrush( HDC hDC, INT nWidth, INT nHeight, COLORREF Color1, COLORREF Color2 );
HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                         HB_BOOL bAlphaFormat, int iAlpfaConstant );
LRESULT CALLBACK  OwnButtonProc( HWND hbutton, UINT msg, WPARAM wParam, LPARAM lParam );

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

HB_FUNC( INITBUTTON )
{
   HWND hwnd;
   HWND hbutton;
   int  Style;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | WS_CHILD | ( hb_parl( 14 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON ); //JK

   if( hb_parl( 10 ) )
      Style = Style | BS_FLAT;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_TABSTOP;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_VISIBLE;

   if( hb_parl( 13 ) )
      Style = Style | BS_MULTILINE;

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hb_parni( 7 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

HB_FUNC( INITIMAGEBUTTON )
{
   HWND  hwnd;
   HWND  hbutton;
   HWND  himage;
   HICON hIcon;
   int   Style;
   int   ImgStyle;

   HIMAGELIST       himl;
   BUTTON_IMAGELIST bi;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | WS_CHILD | ( hb_parl( 13 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON ); //JK

   Style |= ( ( hb_parc( 14 ) == NULL ) ? BS_BITMAP : BS_ICON );                        //JK

   if( hb_parl( 9 ) )
      Style = Style | BS_FLAT;

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
      hb_parni( 6 ),
      hb_parni( 7 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   if( hb_parl( 10 ) )
      ImgStyle = 0;
   else
      ImgStyle = LR_LOADTRANSPARENT;

   if( hb_parc( 14 ) == NULL )
   {
      if( ! hb_parl( 17 ) )
      {
         himage = ( HWND ) LoadImage( GetResources(), hb_parc( 8 ), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | ImgStyle );

         if( himage == NULL )
            himage = ( HWND ) LoadImage( NULL, hb_parc( 8 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | ImgStyle );

         if( himage == NULL )
            himage = ( HWND ) HMG_LoadPicture( hb_parc( 8 ), -1, -1, hwnd, 0, hb_parl( 10 ) ? 0 : 1, -1, 0, HB_FALSE, 255 );

         SendMessage( hbutton, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

         hb_reta( 2 );
         HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
         HB_STORVNL( ( LONG_PTR ) himage, -1, 2 );
      }
      else
      {
         himl = ImageList_LoadImage
                (
            GetResources(),
            hb_parc( 8 ),
            0,
            6,
            CLR_DEFAULT,
            IMAGE_BITMAP,
            LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | ImgStyle
                );

         if( himl == NULL )
            himl = ImageList_LoadImage
                   (
               GetResources(),
               hb_parc( 8 ),
               0,
               6,
               CLR_DEFAULT,
               IMAGE_BITMAP,
               LR_LOADFROMFILE | LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | ImgStyle
                   );

         bi.himl          = himl;
         bi.margin.left   = 10;
         bi.margin.top    = 10;
         bi.margin.bottom = 10;
         bi.margin.right  = 10;
         bi.uAlign        = 4;

         SendMessage( ( HWND ) hbutton, ( UINT ) BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) &bi );

         hb_reta( 2 );
         HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
         HB_STORVNL( ( LONG_PTR ) himl, -1, 2 );
      }
   }
   else
   {
      if( ! hb_parl( 15 ) )
      {
         hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 14 ), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

         if( hIcon == NULL )
            hIcon = ( HICON ) LoadImage( 0, hb_parc( 14 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );
      }
      else
      {
         hIcon = ( HICON ) ExtractIcon( GetInstance(), hb_parc( 14 ), hb_parni( 16 ) );

         if( hIcon == NULL )
            hIcon = ( HICON ) ExtractIcon( GetInstance(), "user.exe", 0 );
      }

      if( hb_parl( 17 ) )
      {
         BITMAP   bm;
         ICONINFO sIconInfo;

         GetIconInfo( hIcon, &sIconInfo );
         GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), ( LPVOID ) &bm );

         himl = ImageList_Create( bm.bmWidth, bm.bmHeight, ILC_COLOR32 | ILC_MASK, 1, 0 );

         bi.himl          = himl;
         bi.margin.left   = 10;
         bi.margin.top    = 10;
         bi.margin.bottom = 10;
         bi.margin.right  = 10;
         bi.uAlign        = 4;

         ImageList_AddIcon( bi.himl, hIcon );

         SendMessage( ( HWND ) hbutton, ( UINT ) BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) &bi );

         DeleteObject( sIconInfo.hbmMask );
         DeleteObject( sIconInfo.hbmColor );
         DestroyIcon( hIcon );

         hb_reta( 2 );
         HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
         HB_STORVNL( ( LONG_PTR ) himl, -1, 2 );
      }
      else
      {
         SendMessage( hbutton, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_ICON, ( LPARAM ) hIcon );

         hb_reta( 2 );
         HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
         HB_STORVNL( ( LONG_PTR ) hIcon, -1, 2 );
      }
   }
}

HB_FUNC( INITOWNERBUTTON )
{
   HWND  hwnd;
   HWND  hbutton;
   HWND  himage;
   HICON hIcon;
   int   Style;
   int   ImgStyle;

   hwnd = ( HWND ) HB_PARNL( 1 );

   Style = BS_NOTIFY | WS_CHILD | BS_OWNERDRAW;

   Style |= ( ( hb_parc( 14 ) == NULL ) ? BS_BITMAP : BS_ICON );

   if( hb_parl( 9 ) )
      Style = Style | BS_FLAT;

   if( ! hb_parl( 11 ) )
      Style = Style | WS_VISIBLE;

   if( ! hb_parl( 12 ) )
      Style = Style | WS_TABSTOP;

   Style |= ( hb_parl( 13 ) ? BS_DEFPUSHBUTTON : BS_PUSHBUTTON );

   hbutton = CreateWindow
             (
      WC_BUTTON,
      hb_parc( 2 ),
      Style,
      hb_parni( 4 ),
      hb_parni( 5 ),
      hb_parni( 6 ),
      hb_parni( 7 ),
      hwnd,
      ( HMENU ) HB_PARNL( 3 ),
      GetInstance(),
      NULL
             );

   SetProp( ( HWND ) hbutton, "oldbtnproc", ( HWND ) GetWindowLongPtr( ( HWND ) hbutton, GWLP_WNDPROC ) );
   SetWindowLongPtr( hbutton, GWLP_WNDPROC, ( LONG_PTR ) ( WNDPROC ) OwnButtonProc );

   if( hb_parl( 10 ) )
      ImgStyle = 0;
   else
      ImgStyle = LR_LOADTRANSPARENT;

   if( hb_parc( 14 ) == NULL )
   {
      himage = ( HWND ) LoadImage( GetResources(), hb_parc( 8 ), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | ImgStyle );

      if( himage == NULL )
         himage = ( HWND ) LoadImage( NULL, hb_parc( 8 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | ImgStyle );

      hb_reta( 2 );
      HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
      HB_STORVNL( ( LONG_PTR ) himage, -1, 2 );
   }
   else
   {
      hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 14 ), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

      if( hIcon == NULL )
         hIcon = ( HICON ) LoadImage( NULL, hb_parc( 14 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

      if( hIcon == NULL )
         hIcon = ( HICON ) ExtractIcon( GetInstance(), hb_parc( 14 ), 0 );

      hb_reta( 2 );
      HB_STORVNL( ( LONG_PTR ) hbutton, -1, 1 );
      HB_STORVNL( ( LONG_PTR ) hIcon, -1, 2 );
   }
}

HB_FUNC( _SETBTNPICTURE )
{
   HWND hwnd;
   HWND himage;

   hwnd = ( HWND ) HB_PARNL( 1 );

   himage = ( HWND ) LoadImage( GetResources(), hb_parc( 2 ), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

   if( himage == NULL )
      himage = ( HWND ) LoadImage( NULL, hb_parc( 2 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT );

   if( himage == NULL )
      himage = ( HWND ) HMG_LoadPicture( hb_parc( 2 ), hb_parni( 3 ), hb_parni( 4 ), hwnd, 0, 1, -1, 0, HB_FALSE, 255 );

   SendMessage( hwnd, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   HB_RETNL( ( LONG_PTR ) himage );
}

HB_FUNC( _GETBTNPICTUREHANDLE )
{
   HWND hwnd;
   HWND himage = 0;

   hwnd = ( HWND ) HB_PARNL( 1 );

   himage = ( HWND ) SendMessage( hwnd, ( UINT ) BM_GETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) himage );

   HB_RETNL( ( LONG_PTR ) himage );
}

HB_FUNC( _SETMIXEDBTNPICTURE )
{
   HIMAGELIST       himl;
   BUTTON_IMAGELIST bi;

   himl = ImageList_LoadImage
          (
      GetResources(),
      hb_parc( 2 ),
      0,
      6,
      CLR_DEFAULT,
      IMAGE_BITMAP,
      LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS
          );

   if( himl == NULL )
      himl = ImageList_LoadImage
             (
         GetResources(),
         hb_parc( 2 ),
         0,
         6,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_LOADFROMFILE | LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS
             );

   bi.himl          = himl;
   bi.margin.left   = 10;
   bi.margin.top    = 10;
   bi.margin.bottom = 10;
   bi.margin.right  = 10;
   bi.uAlign        = 4;

   SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) &bi );

   HB_RETNL( ( LONG_PTR ) himl );
}

// HMG 1.0 Experimental Build 8e
HB_FUNC( _SETBTNICON )
{
   HWND  hwnd;
   HICON hIcon;

   hwnd = ( HWND ) HB_PARNL( 1 );

   hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 2 ), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( NULL, hb_parc( 2 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   SendMessage( hwnd, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_ICON, ( LPARAM ) hIcon );

   HB_RETNL( ( LONG_PTR ) hIcon );
}

HB_FUNC( _SETMIXEDBTNICON )
{
   HWND     hwnd;
   HICON    hIcon;
   BITMAP   bm;
   ICONINFO sIconInfo;

   HIMAGELIST       himl;
   BUTTON_IMAGELIST bi;

   hwnd = ( HWND ) HB_PARNL( 1 );

   hIcon = ( HICON ) LoadImage( GetResources(), hb_parc( 2 ), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( NULL, hb_parc( 2 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   GetIconInfo( hIcon, &sIconInfo );
   GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), ( LPVOID ) &bm );

   himl = ImageList_Create( bm.bmWidth, bm.bmHeight, ILC_COLOR32 | ILC_MASK, 1, 0 );

   bi.himl          = himl;
   bi.margin.left   = 10;
   bi.margin.top    = 10;
   bi.margin.bottom = 10;
   bi.margin.right  = 10;
   bi.uAlign        = 4;

   ImageList_AddIcon( bi.himl, hIcon );

   SendMessage( hwnd, ( UINT ) BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) &bi );

   DeleteObject( sIconInfo.hbmMask );
   DeleteObject( sIconInfo.hbmColor );
   DestroyIcon( hIcon );

   HB_RETNL( ( LONG_PTR ) himl );
}

HB_FUNC( DRAWBUTTON )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 4 );

   UINT iFocus     = hb_parni( 2 );
   UINT iState     = hb_parni( 3 );
   UINT iMouseOver = hb_parni( 5 );
   UINT iFlat      = hb_parni( 6 );

   if( iFocus == 1 || iMouseOver == 1 )
      InflateRect( &pps->rcItem, -1, -1 );

   DrawFrameControl( pps->hDC, &pps->rcItem, DFC_BUTTON, ( ! iFlat ) ? iState : ( iState | DFCS_FLAT ) );

   if( iFocus == 1 )
   {
      HPEN   OldPen   = ( HPEN ) SelectObject( pps->hDC, GetStockObject( BLACK_PEN ) );
      HBRUSH OldBrush = ( HBRUSH ) SelectObject( pps->hDC, GetStockObject( NULL_BRUSH ) );

      InflateRect( &pps->rcItem, 1, 1 );
      Rectangle( pps->hDC, pps->rcItem.left, pps->rcItem.top, pps->rcItem.right, pps->rcItem.bottom );

      SelectObject( pps->hDC, OldBrush );
      SelectObject( pps->hDC, OldPen );
   }
}

/*
   Function GETOWNBTNHANDLE return value of hwndItem DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNHANDLE )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      HB_RETNL( ( LONG_PTR ) pps->hwndItem );
}

/*
   Function GETOWNBTNSTATE return value of itemState DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNSTATE )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      hb_retnl( ( LONG ) pps->itemState );
}

/*
   Function GETOWNBTNDC return value of hDC DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNDC )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      HB_RETNL( ( LONG_PTR ) pps->hDC );
}

/*
   Function GETOWNBTNITEMACTION return value of itemID DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNITEMID )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      hb_retnl( ( LONG ) pps->itemID );
}

/*
   Function GETOWNBTNITEMACTION return value of itemAction DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNITEMACTION )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      hb_retnl( ( LONG ) pps->itemAction );
}

/*
   Function GETOWNBTNCTLTYPE return value of CtlType DRAWITEMSTRUCT member
 */
HB_FUNC( GETOWNBTNCTLTYPE )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
      hb_retni( ( UINT ) pps->CtlType );
}

/*
   Function GETOWNBTNRECT return array with button rectangle coords
 */
HB_FUNC( GETOWNBTNRECT )
{
   RECT     rc;
   PHB_ITEM aMetr       = hb_itemArrayNew( 4 );
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   rc = pps->rcItem;

   HB_arraySetNL( aMetr, 1, rc.left );
   HB_arraySetNL( aMetr, 2, rc.top );
   HB_arraySetNL( aMetr, 3, rc.right );
   HB_arraySetNL( aMetr, 4, rc.bottom );

   hb_itemReturnRelease( aMetr );
}

LRESULT CALLBACK OwnButtonProc( HWND hButton, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;
   TRACKMOUSEEVENT tme;
   WNDPROC         OldWndProc;

   OldWndProc = ( WNDPROC ) ( LONG_PTR ) GetProp( hButton, "oldbtnproc" );

   switch( Msg )
   {
      case WM_LBUTTONDBLCLK:
         SendMessage( hButton, WM_LBUTTONDOWN, wParam, lParam );
         break;

      case WM_MOUSEMOVE:
         tme.cbSize      = sizeof( TRACKMOUSEEVENT );
         tme.dwFlags     = TME_LEAVE;
         tme.hwndTrack   = hButton;
         tme.dwHoverTime = 0;
         _TrackMouseEvent( &tme );

         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OBTNEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hButton );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         return ( r != 0 ) ? r : DefWindowProc( hButton, Msg, wParam, lParam );

      case WM_MOUSELEAVE:
         if( ! pSymbol )
            pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OBTNEVENTS" ) );

         if( pSymbol )
         {
            hb_vmPushSymbol( pSymbol );
            hb_vmPushNil();
            hb_vmPushNumInt( ( LONG_PTR ) hButton );
            hb_vmPushLong( Msg );
            hb_vmPushNumInt( wParam );
            hb_vmPushNumInt( lParam );
            hb_vmDo( 4 );
         }

         r = hb_parnl( -1 );

         return ( r != 0 ) ? r : DefWindowProc( hButton, Msg, wParam, lParam );
   }

   return CallWindowProc( OldWndProc, hButton, Msg, wParam, lParam );
}

/*
 * Added in Build 16.12
 */
HB_FUNC( CREATEBUTTONBRUSH )
{
   HB_RETNL( ( LONG_PTR ) CreateGradientBrush( ( HDC ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ),
                                               ( COLORREF ) hb_parnl( 4 ), ( COLORREF ) hb_parnl( 5 ) ) );
}

static HBRUSH CreateGradientBrush( HDC hDC, INT nWidth, INT nHeight, COLORREF Color1, COLORREF Color2 )
{
   HDC     hDCComp;
   HBITMAP hBitmap;
   HBRUSH  hBrush, hBrushOld, hBrushPat;
   RECT    rcF;
   int     r1, g1, b1, r2, g2, b2;
   int     nCount;
   int     i;

   r1 = GetRValue( Color1 );
   g1 = GetGValue( Color1 );
   b1 = GetBValue( Color1 );
   r2 = GetRValue( Color2 );
   g2 = GetGValue( Color2 );
   b2 = GetBValue( Color2 );

   hDCComp = CreateCompatibleDC( hDC );
   hBitmap = CreateCompatibleBitmap( hDC, nWidth, nHeight );
   SelectObject( hDCComp, hBitmap );

   rcF.left   = 0;
   rcF.top    = 0;
   rcF.right  = nWidth;
   rcF.bottom = nHeight;
   nCount     = ( int ) ceil( ( ( nWidth > nHeight ) ? nHeight : nWidth ) / 2 );

   for( i = 0; i < nCount; i++ )
   {
      hBrush    = CreateSolidBrush( RGB( r1 + ( i * ( r2 - r1 ) / nCount ), g1 + ( i * ( g2 - g1 ) / nCount ), b1 + ( i * ( b2 - b1 ) / nCount ) ) );
      hBrushOld = SelectObject( hDCComp, hBrush );
      FillRect( hDCComp, &rcF, hBrush );
      SelectObject( hDCComp, hBrushOld );
      DeleteObject( hBrush );

      InflateRect( &rcF, -1, -1 );
   }

   hBrushPat = CreatePatternBrush( hBitmap );

   DeleteDC( hDCComp );
   DeleteObject( hBitmap );

   return hBrushPat;
}
