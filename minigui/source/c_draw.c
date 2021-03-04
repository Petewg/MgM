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
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2021, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 */

#include <mgdefs.h>

#include "hbapiitm.h"

#if defined( __BORLANDC__ ) || defined( __WATCOMC__ )
WINGDIAPI BOOL WINAPI GdiFlush( void );
#endif

extern HB_EXPORT BOOL Array2ColorRef( PHB_ITEM aCRef, COLORREF * cr );
extern HB_EXPORT BOOL Array2Rect( PHB_ITEM aRect, RECT * rc );
extern HB_EXPORT PHB_ITEM Rect2Array( RECT * rc );


HB_FUNC( BEGINPAINT )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      PAINTSTRUCT ps;

      HB_RETNL( ( LONG_PTR ) BeginPaint( hWnd, &ps ) );

      hb_storclen( ( const char * ) &ps, sizeof( PAINTSTRUCT ), 2 );
   }
   else
      HB_RETNL( ( LONG_PTR ) NULL );
}

HB_FUNC( ENDPAINT )
{
   HWND hWnd         = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   PAINTSTRUCT * pps = ( PAINTSTRUCT * ) hb_parc( 2 );

   if( IsWindow( hWnd ) && pps )
      hb_retl( EndPaint( hWnd, pps ) );
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( DRAWFOCUSRECT )
{
   DRAWITEMSTRUCT * pps = ( DRAWITEMSTRUCT * ) HB_PARNL( 1 );

   if( pps )
   {
      InflateRect( &pps->rcItem, -3, -3 );
      DrawFocusRect( pps->hDC, &pps->rcItem );
      InflateRect( &pps->rcItem, +3, +3 );
   }
}

HB_FUNC( DRAWSTATE )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hDC;
   BOOL bDC = FALSE;

   if( IsWindow( hWnd ) )
   {
      hDC = GetDC( hWnd );
      bDC = TRUE;
   }
   else
      hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
   {
      HBRUSH   hBrush = ( HBRUSH ) NULL;
      COLORREF crBrush;
      LPARAM   lpData;
      WPARAM   wData   = ( WPARAM ) hb_parclen( 4 );
      HB_ISIZ  fuFlags = hb_parns( 10 );

      if( Array2ColorRef( hb_param( 2, HB_IT_ANY ), &crBrush ) )
         hBrush = CreateSolidBrush( crBrush );

      if( wData > 0 )
         lpData = ( LPARAM ) hb_parc( 4 );
      else
         lpData = ( LPARAM ) ( LONG_PTR ) HB_PARNL( 4 );

      hb_retl( DrawState( hDC, hBrush, NULL, lpData, wData, hb_parni( 6 ), hb_parni( 7 ), hb_parni( 8 ), hb_parni( 9 ), ( UINT ) fuFlags )
               ? HB_TRUE : HB_FALSE );

      if( bDC )
         ReleaseDC( hWnd, hDC );

      if( hb_parl( 11 ) )
      {
         if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_BITMAP )
            DeleteObject( ( HBITMAP ) lpData );
         else
            DestroyIcon( ( HICON ) lpData );
      }
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( GETUPDATERECT )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      if( HB_ISNIL( 2 ) )
         hb_retl( GetUpdateRect( hWnd, NULL, hb_parl( 3 ) ) ? HB_TRUE : HB_FALSE );
      else
      {
         RECT rc;

         hb_retl( GetUpdateRect( hWnd, &rc, hb_parl( 3 ) ) ? HB_TRUE : HB_FALSE );
#ifndef __XHARBOUR__
         hb_itemParamStoreRelease( 2, Rect2Array( &rc ) );
#endif
      }
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( GDIFLUSH )
{
   hb_retl( GdiFlush() ? HB_TRUE : HB_FALSE );
}

HB_FUNC( GRAYSTRING )
{
   int nCount = hb_parni( 5 );
   int nLen   = ( int ) hb_parclen( 4 );

   if( nCount > 0 )
      nCount = HB_MIN( nCount, nLen );
   else
      nCount = nLen;

   if( nLen > 0 )
   {
      HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
      HDC  hDC;
      BOOL bDC = FALSE;

      if( IsWindow( hWnd ) )
      {
         hDC = GetDC( hWnd );
         bDC = TRUE;
      }
      else
         hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

      if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
      {
         HBRUSH       hBrush = ( HBRUSH ) NULL;
         COLORREF     crBrush;
         const char * lpData = hb_parc( 4 );

         if( Array2ColorRef( hb_param( 2, HB_IT_ANY ), &crBrush ) )
            hBrush = CreateSolidBrush( crBrush );

         hb_retl( GrayString( hDC, hBrush, NULL, ( LPARAM ) lpData, nCount, hb_parni( 6 ), hb_parni( 7 ), hb_parni( 8 ), hb_parni( 9 ) )
                  ? HB_TRUE : HB_FALSE );

         if( bDC )
            ReleaseDC( hWnd, hDC );
      }
      else
         hb_retl( HB_FALSE );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( INVALIDATERECT )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      BOOL bRect = FALSE;
      RECT rc;

      if( ( hb_pcount() > 2 ) && ( ! HB_ISNIL( 3 ) ) )
      {
         bRect = Array2Rect( hb_param( 3, HB_IT_ANY ), &rc );

         if( ! bRect )
         {
            rc.left   = hb_parni( 3 );
            rc.top    = hb_parni( 4 );
            rc.right  = hb_parni( 5 );
            rc.bottom = hb_parni( 6 );

            bRect = TRUE;
         }
      }

      hb_retl( InvalidateRect( hWnd, bRect ? &rc : NULL, hb_parni( 2 ) /* erase-background flag */ )
               ? HB_TRUE : HB_FALSE );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( REDRAWWINDOW )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      UINT uiFlags = RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW;

      if( HB_TRUE == hb_parl( 2 ) )
         uiFlags |= RDW_INTERNALPAINT;

      hb_retl( RedrawWindow( hWnd, NULL, NULL, uiFlags ) ? HB_TRUE : HB_FALSE );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( C_SETBACKCOLOR )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hDC;
   BOOL bDC = FALSE;

   if( IsWindow( hWnd ) )
   {
      hDC = GetDC( hWnd );
      bDC = TRUE;
   }
   else
      hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
   {
      COLORREF cr;

      if( ! Array2ColorRef( hb_param( 2, HB_IT_ANY ), &cr ) )
         cr = ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) );

      hb_retns( ( HB_ISIZ ) SetBkColor( hDC, cr  ) );

      if( bDC )
         ReleaseDC( hWnd, hDC );
   }
   else
      hb_retns( ( HB_ISIZ ) CLR_INVALID );
}

HB_FUNC( SETBKMODE )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hDC;
   BOOL bDC = FALSE;

   if( IsWindow( hWnd ) )
   {
      hDC = GetDC( hWnd );
      bDC = TRUE;
   }
   else
      hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
   {
      hb_retni( SetBkMode( hDC, hb_parnidef( 2, OPAQUE ) ) );

      if( bDC )
         ReleaseDC( hWnd, hDC );
   }
   else
      hb_retni( 0 );
}

HB_FUNC( UPDATEWINDOW )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
      hb_retl( UpdateWindow( hWnd ) ? HB_TRUE : HB_FALSE );
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( VALIDATERECT )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      BOOL bRect = FALSE;
      RECT rc;

      if( ( hb_pcount() > 1 ) && ( ! HB_ISNIL( 2 ) ) )
      {
         bRect = Array2Rect( hb_param( 2, HB_IT_ANY ), &rc );

         if( ! bRect )
         {
            rc.left   = hb_parni( 2 );
            rc.top    = hb_parni( 3 );
            rc.right  = hb_parni( 4 );
            rc.bottom = hb_parni( 5 );

            bRect = TRUE;
         }
      }

      hb_retl( ValidateRect( hWnd, bRect ? &rc : NULL ) );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( WINDOWFROMDC )
{
   HDC hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   HB_RETNL( ( LONG_PTR ) WindowFromDC( hDC ) );
}
