/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   Copyright 2005 Andy Wos <andywos@unwired.com.au>

   Added to MiniGUI project (1.0 Experimental Build 9a)
   by Jacek Kubica <kubica@wssk.wroc.pl>

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
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include "hbapiitm.h"

#ifndef __WINE_UXTHEME_H
#define __WINE_UXTHEME_H

#include <commctrl.h>

#ifdef __XCC__
#ifndef _NO_W32_PSEUDO_MODIFIERS
  #define IN
  #define OUT
#ifndef OPTIONAL
  #define OPTIONAL
#endif
#endif
#endif

typedef HANDLE HTHEME;

HRESULT WINAPI CloseThemeData( HTHEME hTheme );
HRESULT WINAPI DrawThemeBackground( HTHEME, HDC, int, int, const RECT *, const RECT * );

#define DTBG_CLIPRECT         0x00000001
#define DTBG_DRAWSOLID        0x00000002
#define DTBG_OMITBORDER       0x00000004
#define DTBG_OMITCONTENT      0x00000008
#define DTBG_COMPUTINGREGION  0x00000010
#define DTBG_MIRRORDC         0x00000020

typedef struct _DTBGOPTS
{
   DWORD dwSize;
   DWORD dwFlags;
   RECT  rcClip;
} DTBGOPTS, * PDTBGOPTS;

HRESULT WINAPI DrawThemeBackgroundEx( HTHEME, HDC, int, int, const RECT *, const DTBGOPTS * );
HRESULT WINAPI DrawThemeEdge( HTHEME, HDC, int, int, const RECT *, UINT, UINT, RECT * );
HRESULT WINAPI DrawThemeIcon( HTHEME, HDC, int, int, const RECT *, HIMAGELIST, int );
HRESULT WINAPI DrawThemeParentBackground( HWND, HDC, RECT * );

#define DTT_GRAYED             0x1

HRESULT WINAPI DrawThemeText( HTHEME, HDC, int, int, LPCWSTR, int, DWORD, DWORD, const RECT * );

#define ETDT_DISABLE           0x00000001
#define ETDT_ENABLE            0x00000002
#define ETDT_USETABTEXTURE     0x00000004
#define ETDT_ENABLETAB         ( ETDT_ENABLE | ETDT_USETABTEXTURE )

HRESULT WINAPI EnableThemeDialogTexture( HWND, DWORD );
HRESULT WINAPI EnableTheming( BOOL );
HRESULT WINAPI GetCurrentThemeName( LPWSTR, int, LPWSTR, int, LPWSTR, int );

#define STAP_ALLOW_NONCLIENT   ( 1 << 0 )
#define STAP_ALLOW_CONTROLS    ( 1 << 1 )
#define STAP_ALLOW_WEBCONTENT  ( 1 << 2 )

DWORD WINAPI GetThemeAppProperties( void );
HRESULT WINAPI GetThemeBackgroundContentRect( HTHEME, HDC, int, int, const RECT *, RECT * );
HRESULT WINAPI GetThemeBackgroundExtent( HTHEME, HDC, int, int, const RECT *, RECT * );
HRESULT WINAPI GetThemeBackgroundRegion( HTHEME, HDC, int, int, const RECT *, HRGN * );
HRESULT WINAPI GetThemeBool( HTHEME, int, int, int, BOOL * );
HRESULT WINAPI GetThemeColor( HTHEME, int, int, int, COLORREF * );

HRESULT WINAPI GetThemeDocumentationProperty( LPCWSTR, LPCWSTR, LPWSTR, int );
HRESULT WINAPI GetThemeEnumValue( HTHEME, int, int, int, int * );
HRESULT WINAPI GetThemeFilename( HTHEME, int, int, int, LPWSTR, int );
HRESULT WINAPI GetThemeFont( HTHEME, HDC, int, int, int, LOGFONTW * );
HRESULT WINAPI GetThemeInt( HTHEME, int, int, int, int * );

#define MAX_INTLIST_COUNT  10
typedef struct _INTLIST
{
   int iValueCount;
   int iValues[ MAX_INTLIST_COUNT ];
} INTLIST, * PINTLIST;

HRESULT WINAPI GetThemeIntList( HTHEME, int, int, int, INTLIST * );

typedef struct _MARGINS
{
   int cxLeftWidth;
   int cxRightWidth;
   int cyTopHeight;
   int cyBottomHeight;
} MARGINS, * PMARGINS;

HRESULT WINAPI GetThemeMargins( HTHEME, HDC, int, int, int, RECT *, MARGINS * );
HRESULT WINAPI GetThemeMetric( HTHEME, HDC, int, int, int, int * );

typedef enum
{
   TS_MIN,
   TS_TRUE,
   TS_DRAW
} THEMESIZE;

HRESULT WINAPI GetThemePartSize( HTHEME, HDC, int, int, RECT *, THEMESIZE, SIZE * );
HRESULT WINAPI GetThemePosition( HTHEME, int, int, int, POINT * );

typedef enum
{
   PO_STATE,
   PO_PART,
   PO_CLASS,
   PO_GLOBAL,
   PO_NOTFOUND
} PROPERTYORIGIN;

HRESULT WINAPI GetThemePropertyOrigin( HTHEME, int, int, int, PROPERTYORIGIN * );
HRESULT WINAPI GetThemeRect( HTHEME, int, int, int, RECT * );
HRESULT WINAPI GetThemeString( HTHEME, int, int, int, LPWSTR, int );
BOOL WINAPI GetThemeSysBool( HTHEME, int );
COLORREF WINAPI GetThemeSysColor( HTHEME, int );
HBRUSH WINAPI GetThemeSysColorBrush( HTHEME, int );
HRESULT WINAPI GetThemeSysFont( HTHEME, int, LOGFONTW * );
HRESULT WINAPI GetThemeSysInt( HTHEME, int, int * );
int WINAPI GetThemeSysSize( HTHEME, int );
HRESULT WINAPI GetThemeSysString( HTHEME, int, LPWSTR, int );
HRESULT WINAPI GetThemeTextExtent( HTHEME, HDC, int, int, LPCWSTR, int, DWORD, const RECT *, RECT * );
HRESULT WINAPI GetThemeTextMetrics( HTHEME, HDC, int, int, TEXTMETRICW * );
HTHEME WINAPI GetWindowTheme( HWND );

#define HTTB_BACKGROUNDSEG          0x0000
#define HTTB_FIXEDBORDER            0x0002
#define HTTB_CAPTION                0x0004
#define HTTB_RESIZINGBORDER_LEFT    0x0010
#define HTTB_RESIZINGBORDER_TOP     0x0020
#define HTTB_RESIZINGBORDER_RIGHT   0x0040
#define HTTB_RESIZINGBORDER_BOTTOM  0x0080
#define HTTB_RESIZINGBORDER         ( HTTB_RESIZINGBORDER_LEFT | HTTB_RESIZINGBORDER_TOP | HTTB_RESIZINGBORDER_RIGHT | HTTB_RESIZINGBORDER_BOTTOM )
#define HTTB_SIZINGTEMPLATE         0x0100
#define HTTB_SYSTEMSIZINGMARGINS    0x0200

HRESULT WINAPI HitTestThemeBackground( HTHEME, HDC, int, int, DWORD, const RECT *, HRGN, POINT, WORD * );
BOOL WINAPI IsAppThemed( void );
BOOL WINAPI IsThemeActive( void );
BOOL WINAPI IsThemeBackgroundPartiallyTransparent( HTHEME, int, int );
BOOL WINAPI IsThemeDialogTextureEnabled( void );
BOOL WINAPI IsThemePartDefined( HTHEME, int, int );
HTHEME WINAPI OpenThemeData( HWND, LPCWSTR );
void WINAPI SetThemeAppProperties( DWORD );
HRESULT WINAPI SetWindowTheme( HWND, LPCWSTR, LPCWSTR );
#endif

BOOL Array2Rect( PHB_ITEM aRect, RECT * rc );
BOOL Array2Point( PHB_ITEM aPoint, POINT * pt );
BOOL Array2ColorRef( PHB_ITEM aCRef, COLORREF * cr );

typedef HTHEME ( WINAPI * fnOpenThemeData )( HWND hwnd, LPCWSTR pszClassList );
typedef HRESULT ( WINAPI * fnCloseThemeData )( HTHEME hTheme );
typedef HRESULT ( WINAPI * fnDrawThemeBackground )( HTHEME hTheme, HDC hdc, int iPartId, int iStateId, const RECT * pRect, const RECT * pClipRect );
typedef HRESULT ( WINAPI * fnGetThemeBackgroundContentRect )
(
   HTHEME hTheme,
   HDC hdc,
   int iPartId,
   int iStateId,
   const RECT * pBoundingRect,
   RECT * pContentRect
);
typedef HRESULT ( WINAPI * fnDrawThemeText )
(
   HTHEME hTheme,
   HDC hdc,
   int iPartId,
   int iStateId,
   LPCWSTR pszText,
   int iCharCount,
   DWORD dwTextFlags,
   DWORD dwTextFlags2,
   const RECT * pRect
);
typedef HRESULT ( WINAPI * fnHitTestThemeBackground )
(
   HTHEME hTheme,
   OPTIONAL HDC hdc,
   int iPartId,
   int iStateId,
   DWORD dwOptions,
   const RECT * pRect,
   OPTIONAL HRGN hrgn,
   POINT ptTest,
   OUT WORD * pwHitTestCode
);
typedef BOOL ( WINAPI * fnIsAppThemed )( void );
typedef COLORREF ( WINAPI * fnGetThemeSysColor )( HTHEME hTheme, int iColorId );
typedef HRESULT ( WINAPI * fnGetThemeSysFont )( HTHEME hTheme, int iFontId, OUT LOGFONT * plf );
typedef HRESULT ( WINAPI * fnDrawThemeIcon )
(
   HTHEME hTheme,
   HDC hdc,
   int iPartId,
   int iStateId,
   const RECT * pRect,
   HIMAGELIST himl,
   int iImageIndex
);
typedef HRESULT ( WINAPI * fnGetThemeTextExtent )
(
   HTHEME hTheme,
   HDC hdc,
   int iPartId,
   int iStateId,
   LPCWSTR pszText,
   int iCharCount,
   DWORD dwTextFlags,
   const RECT * pRect,
   OUT RECT * pExtent
);
typedef HRESULT ( WINAPI * fnDrawThemeParentBackground )( HWND hwnd, HDC hdc, OPTIONAL RECT * prc );
typedef HRESULT ( WINAPI * fnDrawThemeEdge )
(
   HTHEME hTheme,
   HDC hdc,
   int iPartId,
   int iStateId,
   const RECT * pDestRect,
   UINT uEdge,
   UINT uFlags,
   OPTIONAL OUT RECT * pContentRect
);
typedef HRESULT ( WINAPI * fnGetThemeRect )( HTHEME hTheme, int iPartId, int iStateId, int iPropId, RECT * pPoint );
typedef HRESULT ( WINAPI * fnGetThemePartSize )( HTHEME hTheme, HDC hdc, int iPartId, int iStateId, RECT * prc, THEMESIZE eSize, SIZE * psz );
typedef void ( WINAPI * fnSetThemeAppProperties )( DWORD dwFlags );
typedef DWORD ( WINAPI * fnGetThemeAppProperties )( void );
typedef HTHEME ( WINAPI * fnGetWindowTheme )( HWND hWnd );
typedef BOOL ( WINAPI * fnIsThemeActive )( void );
typedef HRESULT ( WINAPI * fnSetWindowTheme )( HWND hwnd, LPCWSTR pszSubAppName, LPCWSTR pszSubIdList );
typedef HRESULT ( WINAPI * fnEnableThemeDialogTexture )( HWND hwnd, DWORD dwFlags );
typedef HRESULT ( WINAPI * fnGetThemeColor )( HTHEME hTheme, int iPartId, int iStateId, int iPropId, COLORREF * pColor );

static HINSTANCE hUxTheme;

long InitUxTheme( void )
{
   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   return ( LONG_PTR ) hUxTheme;
}

void EndUxTheme( void )
{
   if( hUxTheme != NULL )
   {
      FreeLibrary( hUxTheme );
      hUxTheme = NULL;
   }
}

HB_FUNC( INITUXTHEME )
{
   HB_RETNL( ( LONG_PTR ) InitUxTheme() );
}

HB_FUNC( ENDUXTHEME )
{
   EndUxTheme();
}

HB_FUNC( ISTHEMEACTIVE )
{
   BOOL bRet = FALSE;

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnIsThemeActive pfn = ( fnIsThemeActive ) GetProcAddress( hUxTheme, "IsThemeActive" );
      if( pfn )
         bRet = ( BOOL ) pfn();
   }

   hb_retl( bRet );
}

HB_FUNC( ISAPPTHEMED )
{
   BOOL bRet = FALSE;

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnIsAppThemed pfn = ( fnIsAppThemed ) GetProcAddress( hUxTheme, "IsAppThemed" );
      if( pfn )
         bRet = ( BOOL ) pfn();
   }

   hb_retl( bRet );
}

HB_FUNC( OPENTHEMEDATA )
{
   HTHEME nRet = ( HTHEME ) NULL;
   HWND   hWnd = ( HWND ) HB_PARNL( 1 );

   LPCWSTR pszClassList = ( LPCWSTR ) hb_parc( 2 );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnOpenThemeData pfn = ( fnOpenThemeData ) GetProcAddress( hUxTheme, "OpenThemeData" );
      if( pfn )
         nRet = ( HTHEME ) pfn( hWnd, pszClassList );
   }

   if( nRet != NULL )
      HB_RETNL( ( LONG_PTR ) nRet );
}

HB_FUNC( CLOSETHEMEDATA )
{
   HRESULT nRet = S_FALSE;

   HTHEME hTheme = ( HTHEME ) HB_PARNL( 1 );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnCloseThemeData pfn = ( fnCloseThemeData ) GetProcAddress( hUxTheme, "CloseThemeData" );
      if( pfn )
         nRet = ( HRESULT ) pfn( hTheme );
   }

   if( nRet != ( LONG_PTR ) NULL )
      HB_RETNL( ( LONG_PTR ) nRet );
}

HB_FUNC( DRAWTHEMEBACKGROUND )
{
   HRESULT nRet = S_FALSE;

   HTHEME hTheme   = ( HTHEME ) HB_PARNL( 1 );
   HDC    hDC      = ( HDC ) HB_PARNL( 2 );
   int    iPartId  = hb_parni( 3 );
   int    iStateId = hb_parni( 4 );

   RECT pRect;
   RECT pClipRect;

   Array2Rect( hb_param( 5, HB_IT_ARRAY ), &pRect );
   Array2Rect( hb_param( 6, HB_IT_ARRAY ), &pClipRect );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnDrawThemeBackground pfn = ( fnDrawThemeBackground ) GetProcAddress( hUxTheme, "DrawThemeBackground" );
      if( pfn )
         nRet = ( HRESULT ) pfn( hTheme, hDC, iPartId, iStateId, &pRect, &pClipRect );
   }

   hb_retl( ( nRet == S_OK ) );
}

HB_FUNC( DRAWTHEMEPARENTBACKGROUND )
{
   HRESULT nRet = S_FALSE;

   HWND hWnd = ( HWND ) HB_PARNL( 1 );
   HDC  hDC  = ( HDC ) HB_PARNL( 2 );
   RECT pRect;

   if( HB_ISARRAY( 7 ) )
      Array2Rect( hb_param( 3, HB_IT_ARRAY ), &pRect );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnDrawThemeParentBackground pfn = ( fnDrawThemeParentBackground ) GetProcAddress( hUxTheme, "DrawThemeParentBackground" );
      if( pfn )
         nRet = ( HRESULT ) pfn( hWnd, hDC, &pRect );
   }

   hb_retl( ( nRet == S_OK ) );
}

HB_FUNC( SETWINDOWTHEME )
{
   HRESULT nRet = S_FALSE;

   HWND    hWnd = ( HWND ) HB_PARNL( 1 );
   LPCWSTR pszSubAppName = ( LPCWSTR ) hb_parc( 2 );
   LPCWSTR pszSubIdList  = ( LPCWSTR ) hb_parc( 3 );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnSetWindowTheme pfn = ( fnSetWindowTheme ) GetProcAddress( hUxTheme, "SetWindowTheme" );
      if( pfn )
         nRet = ( HRESULT ) pfn( hWnd, pszSubAppName, pszSubIdList );
   }

   hb_retl( ( nRet == S_OK ) );
}

HB_FUNC( ENABLETHEMEDIALOGTEXTURE )
{
   HRESULT nRet = S_FALSE;

   HWND  hWnd  = ( HWND ) HB_PARNL( 1 );
   DWORD flags = hb_parnl( 2 );

   if( hUxTheme == NULL )
      hUxTheme = LoadLibraryEx( "uxtheme.dll", NULL, 0 );

   if( hUxTheme )
   {
      fnEnableThemeDialogTexture pfn = ( fnEnableThemeDialogTexture ) GetProcAddress( hUxTheme, "EnableThemeDialogTexture" );
      if( pfn )
         nRet = ( HRESULT ) pfn( hWnd, flags );
   }

   hb_retl( ( nRet == S_OK ) );
}

HB_FUNC( PTINRECT )
{
   POINT point;
   RECT  rect;
   HB_BOOL bIn = HB_FALSE;

   if( ( Array2Point( hb_param( 1, HB_IT_ANY ), &point ) && Array2Rect( hb_param( 2, HB_IT_ANY ), &rect ) ) )
   {
      bIn = PtInRect( &rect, point ) ? HB_TRUE : HB_FALSE;
   }

   hb_retl( bIn );
}

BOOL Array2Rect( PHB_ITEM aRect, RECT * rc )
{
   if( HB_IS_ARRAY( aRect ) && hb_arrayLen( aRect ) == 4 )
   {
      rc->left   = HB_arrayGetNL( aRect, 1 );
      rc->top    = HB_arrayGetNL( aRect, 2 );
      rc->right  = HB_arrayGetNL( aRect, 3 );
      rc->bottom = HB_arrayGetNL( aRect, 4 );

      return TRUE;
   }

   return FALSE;
}

BOOL Array2Point( PHB_ITEM aPoint, POINT * pt )
{
   if( HB_IS_ARRAY( aPoint ) && hb_arrayLen( aPoint ) == 2 )
   {
      pt->x = HB_arrayGetNL( aPoint, 1 );
      pt->y = HB_arrayGetNL( aPoint, 2 );

      return TRUE;
   }

   return FALSE;
}

BOOL Array2ColorRef( PHB_ITEM aCRef, COLORREF * cr )
{
   if( HB_IS_ARRAY( aCRef ) && hb_arrayLen( aCRef ) == 3 )
   {
      BYTE r, g, b;
   
      r = ( USHORT ) HB_arrayGetNL( aCRef, 1 );
      g = ( USHORT ) HB_arrayGetNL( aCRef, 2 );
      b = ( USHORT ) HB_arrayGetNL( aCRef, 3 );

      * cr = RGB( r, g, b );

      return TRUE;
   }

   return FALSE;
}

HB_EXPORT PHB_ITEM Rect2Array( RECT * rc )
{
   PHB_ITEM aRect = hb_itemArrayNew( 4 );

   HB_arraySetNL( aRect, 1, rc->left );
   HB_arraySetNL( aRect, 2, rc->top );
   HB_arraySetNL( aRect, 3, rc->right );
   HB_arraySetNL( aRect, 4, rc->bottom );

   return aRect;
}

HB_EXPORT PHB_ITEM Point2Array( POINT * pt )
{
   PHB_ITEM aPoint = hb_itemArrayNew( 2 );

   HB_arraySetNL( aPoint, 1, pt->x );
   HB_arraySetNL( aPoint, 2, pt->y );

   return aPoint;
}
