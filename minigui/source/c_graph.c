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
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2018, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include <commctrl.h>

#ifdef __cplusplus
extern "C" {
#endif
extern BOOL Array2ColorRef( PHB_ITEM aCRef, COLORREF * cr );
extern HFONT PrepareFont( const char *, int, int, int, int, int, int, int );
#ifdef __cplusplus
}
#endif

HB_FUNC( TEXTDRAW )
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
      int   bold      = hb_parl( 11 ) ? FW_BOLD : FW_NORMAL;
      DWORD italic    = ( DWORD ) hb_parl( 12 );
      DWORD underline = ( DWORD ) hb_parl( 13 );
      DWORD strikeout = ( DWORD ) hb_parl( 14 );
      DWORD angle     = hb_parnl( 16 );

      HFONT    font;
      HGDIOBJ  hgdiobj;
      int      iBkMode;
      COLORREF crBkColor = CLR_INVALID;
      COLORREF crFgColor = CLR_INVALID;
      RECT     rect;

      font = PrepareFont( hb_parc( 9 ), hb_parni( 10 ), bold, italic, underline, strikeout, angle, DEFAULT_CHARSET );

      hgdiobj = SelectObject( hDC, font );

      if( hb_parl( 15 ) )
         iBkMode = SetBkMode( hDC, TRANSPARENT );
      else
      {
         iBkMode = SetBkMode( hDC, OPAQUE );

         if( Array2ColorRef( hb_param( 8, HB_IT_ANY ), &crBkColor ) )
            crBkColor = SetBkColor( hDC, crBkColor );
      }

      if( Array2ColorRef( hb_param( 7, HB_IT_ANY ), &crFgColor ) )
         SetTextColor( hDC, crFgColor );

      SetRect( &rect, hb_parni( 3 ), hb_parni( 2 ), hb_parni( 6 ), hb_parni( 5 ) );

      hb_retl( ExtTextOut( hDC, hb_parni( 3 ), hb_parni( 2 ), ETO_OPAQUE, &rect, hb_parc( 4 ), hb_parclen( 4 ), NULL )
               ? HB_TRUE : HB_FALSE );

      SelectObject( hDC, hgdiobj );

      if( 0 != iBkMode )
         SetBkMode( hDC, iBkMode );

      if( CLR_INVALID != crBkColor )
         SetBkColor( hDC, crBkColor );

      if( CLR_INVALID != crFgColor )
         SetTextColor( hDC, crFgColor );

      DeleteObject( font );

      if( bDC )
         ReleaseDC( hWnd, hDC );
   }
   else
      hb_retl( HB_FALSE );
}

HB_FUNC( LINEDRAW )
{
   HWND    hWnd1;
   HDC     hdc1;
   HGDIOBJ hgdiobj1;
   HPEN    hpen;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 7 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 6, 1 ), ( int ) HB_PARNI( 6, 2 ), ( int ) HB_PARNI( 6, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   MoveToEx( hdc1, ( int ) hb_parni( 3 ), ( int ) hb_parni( 2 ), NULL );
   LineTo( hdc1, ( int ) hb_parni( 5 ), ( int ) hb_parni( 4 ) );
   SelectObject( hdc1, hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( RECTDRAW )
{
   HWND     hWnd1;
   HDC      hdc1;
   HGDIOBJ  hgdiobj1, hgdiobj2;
   HPEN     hpen;
   HBRUSH   hbrush;
   LOGBRUSH br;

   hWnd1 = ( HWND ) HB_PARNL( 1 );
   hdc1  = GetDC( ( HWND ) hWnd1 );
   hpen  = CreatePen( PS_SOLID, ( int ) hb_parni( 7 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 6, 1 ), ( int ) HB_PARNI( 6, 2 ), ( int ) HB_PARNI( 6, 3 ) ) );

   hgdiobj1 = SelectObject( hdc1, hpen );
   if( hb_parl( 9 ) )
   {
      hbrush   = CreateSolidBrush( ( COLORREF ) RGB( ( int ) HB_PARNI( 8, 1 ), ( int ) HB_PARNI( 8, 2 ), ( int ) HB_PARNI( 8, 3 ) ) );
      hgdiobj2 = SelectObject( hdc1, hbrush );
   }
   else
   {
      br.lbStyle = BS_HOLLOW;
      hbrush     = CreateBrushIndirect( &br );
      hgdiobj2   = SelectObject( hdc1, hbrush );
   }

   Rectangle( hdc1, ( int ) hb_parni( 3 ), ( int ) hb_parni( 2 ), ( int ) hb_parni( 5 ), ( int ) hb_parni( 4 ) );
   SelectObject( hdc1, hgdiobj1 );
   SelectObject( hdc1, hgdiobj2 );
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( ROUNDRECTDRAW )
{
   HWND     hWnd1;
   HDC      hdc1;
   HGDIOBJ  hgdiobj1, hgdiobj2;
   HPEN     hpen;
   HBRUSH   hbrush;
   LOGBRUSH br;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 9 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 8, 1 ), ( int ) HB_PARNI( 8, 2 ), ( int ) HB_PARNI( 8, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   if( hb_parl( 11 ) )
   {
      hbrush   = CreateSolidBrush( ( COLORREF ) RGB( ( int ) HB_PARNI( 10, 1 ), ( int ) HB_PARNI( 10, 2 ), ( int ) HB_PARNI( 10, 3 ) ) );
      hgdiobj2 = SelectObject( hdc1, hbrush );
   }
   else
   {
      br.lbStyle = BS_HOLLOW;
      hbrush     = CreateBrushIndirect( &br );
      hgdiobj2   = SelectObject( hdc1, hbrush );
   }

   RoundRect
   (
      hdc1,
      ( int ) hb_parni( 3 ),
      ( int ) hb_parni( 2 ),
      ( int ) hb_parni( 5 ),
      ( int ) hb_parni( 4 ),
      ( int ) hb_parni( 6 ),
      ( int ) hb_parni( 7 )
   );
   SelectObject( hdc1, hgdiobj1 );
   SelectObject( hdc1, hgdiobj2 );
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( ELLIPSEDRAW )
{
   HWND     hWnd1;
   HDC      hdc1;
   HGDIOBJ  hgdiobj1, hgdiobj2;
   HPEN     hpen;
   HBRUSH   hbrush;
   LOGBRUSH br;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 7 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 6, 1 ), ( int ) HB_PARNI( 6, 2 ), ( int ) HB_PARNI( 6, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   if( hb_parl( 9 ) )
   {
      hbrush   = CreateSolidBrush( ( COLORREF ) RGB( ( int ) HB_PARNI( 8, 1 ), ( int ) HB_PARNI( 8, 2 ), ( int ) HB_PARNI( 8, 3 ) ) );
      hgdiobj2 = SelectObject( hdc1, hbrush );
   }
   else
   {
      br.lbStyle = BS_HOLLOW;
      hbrush     = CreateBrushIndirect( &br );
      hgdiobj2   = SelectObject( hdc1, hbrush );
   }

   Ellipse( hdc1, ( int ) hb_parni( 3 ), ( int ) hb_parni( 2 ), ( int ) hb_parni( 5 ), ( int ) hb_parni( 4 ) );
   SelectObject( hdc1, hgdiobj1 );
   SelectObject( hdc1, hgdiobj2 );
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( ARCDRAW )
{
   HWND    hWnd1;
   HDC     hdc1;
   HGDIOBJ hgdiobj1;
   HPEN    hpen;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 11 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 10, 1 ), ( int ) HB_PARNI( 10, 2 ), ( int ) HB_PARNI( 10, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   Arc
   (
      hdc1,
      ( int ) hb_parni( 3 ),
      ( int ) hb_parni( 2 ),
      ( int ) hb_parni( 5 ),
      ( int ) hb_parni( 4 ),
      ( int ) hb_parni( 7 ),
      ( int ) hb_parni( 6 ),
      ( int ) hb_parni( 9 ),
      ( int ) hb_parni( 8 )
   );
   SelectObject( hdc1, hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( PIEDRAW )
{
   HWND     hWnd1;
   HDC      hdc1;
   HGDIOBJ  hgdiobj1, hgdiobj2;
   HPEN     hpen;
   HBRUSH   hbrush;
   LOGBRUSH br;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 11 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 10, 1 ), ( int ) HB_PARNI( 10, 2 ), ( int ) HB_PARNI( 10, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   if( hb_parl( 13 ) )
   {
      hbrush   = CreateSolidBrush( ( COLORREF ) RGB( ( int ) HB_PARNI( 12, 1 ), ( int ) HB_PARNI( 12, 2 ), ( int ) HB_PARNI( 12, 3 ) ) );
      hgdiobj2 = SelectObject( hdc1, hbrush );
   }
   else
   {
      br.lbStyle = BS_HOLLOW;
      hbrush     = CreateBrushIndirect( &br );
      hgdiobj2   = SelectObject( hdc1, hbrush );
   }

   Pie
   (
      hdc1,
      ( int ) hb_parni( 3 ),
      ( int ) hb_parni( 2 ),
      ( int ) hb_parni( 5 ),
      ( int ) hb_parni( 4 ),
      ( int ) hb_parni( 7 ),
      ( int ) hb_parni( 6 ),
      ( int ) hb_parni( 9 ),
      ( int ) hb_parni( 8 )
   );
   SelectObject( hdc1, hgdiobj1 );
   SelectObject( hdc1, hgdiobj2 );
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( POLYGONDRAW )
{
   HWND     hWnd1;
   HDC      hdc1;
   HGDIOBJ  hgdiobj1, hgdiobj2;
   HPEN     hpen;
   HBRUSH   hbrush;
   LOGBRUSH br;
   POINT    apoints[ 1024 ];
   int      number = hb_parinfa( 2, 0 );
   int      i;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 5 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 4, 1 ), ( int ) HB_PARNI( 4, 2 ), ( int ) HB_PARNI( 4, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   if( hb_parl( 7 ) )
   {
      hbrush   = CreateSolidBrush( ( COLORREF ) RGB( ( int ) HB_PARNI( 6, 1 ), ( int ) HB_PARNI( 6, 2 ), ( int ) HB_PARNI( 6, 3 ) ) );
      hgdiobj2 = SelectObject( hdc1, hbrush );
   }
   else
   {
      br.lbStyle = BS_HOLLOW;
      hbrush     = CreateBrushIndirect( &br );
      hgdiobj2   = SelectObject( hdc1, hbrush );
   }

   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 2, i + 1 );
      apoints[ i ].y = HB_PARNI( 3, i + 1 );
   }

   Polygon( hdc1, apoints, number );
   SelectObject( hdc1, hgdiobj1 );
   SelectObject( hdc1, hgdiobj2 );
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( POLYBEZIERDRAW )
{
   HWND    hWnd1;
   HDC     hdc1;
   HGDIOBJ hgdiobj1;
   HPEN    hpen;
   POINT   apoints[ 1024 ];
   DWORD   number = ( DWORD ) hb_parinfa( 2, 0 );
   DWORD   i;

   hWnd1    = ( HWND ) HB_PARNL( 1 );
   hdc1     = GetDC( ( HWND ) hWnd1 );
   hpen     = CreatePen( PS_SOLID, ( int ) hb_parni( 5 ), ( COLORREF ) RGB( ( int ) HB_PARNI( 4, 1 ), ( int ) HB_PARNI( 4, 2 ), ( int ) HB_PARNI( 4, 3 ) ) );
   hgdiobj1 = SelectObject( hdc1, hpen );
   for( i = 0; i <= number - 1; i++ )
   {
      apoints[ i ].x = HB_PARNI( 2, i + 1 );
      apoints[ i ].y = HB_PARNI( 3, i + 1 );
   }

   PolyBezier( hdc1, apoints, number );
   SelectObject( hdc1, hgdiobj1 );
   DeleteObject( hpen );
   ReleaseDC( hWnd1, hdc1 );
}

void WndDrawBox( HDC hDC, RECT * rct, HPEN hPUpLeft, HPEN hPBotRit )
{
   HPEN  hOldPen = ( HPEN ) SelectObject( hDC, hPUpLeft );
   POINT pt;

   MoveToEx( hDC, rct->left, rct->bottom, &pt );

   LineTo( hDC, rct->left, rct->top );
   LineTo( hDC, rct->right, rct->top );
   SelectObject( hDC, hPBotRit );

   MoveToEx( hDC, rct->left, rct->bottom, &pt );

   LineTo( hDC, rct->right, rct->bottom );
   LineTo( hDC, rct->right, rct->top - 1 );

   SelectObject( hDC, hOldPen );
}

void WindowBoxIn( HDC hDC, RECT * pRect )
{
   HPEN hWhite = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNHIGHLIGHT ) );
   HPEN hGray  = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNSHADOW ) );

   WndDrawBox( hDC, pRect, hGray, hWhite );

   DeleteObject( hGray );
   DeleteObject( hWhite );
}

void WindowRaised( HDC hDC, RECT * pRect )
{
   HPEN hGray  = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNSHADOW ) );
   HPEN hWhite = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNHIGHLIGHT ) );

   WndDrawBox( hDC, pRect, hWhite, hGray );

   DeleteObject( hGray );
   DeleteObject( hWhite );
}

HB_FUNC( WNDBOXIN )
{
   RECT rct;

   rct.top    = hb_parni( 2 );
   rct.left   = hb_parni( 3 );
   rct.bottom = hb_parni( 4 );
   rct.right  = hb_parni( 5 );

   WindowBoxIn( ( HDC ) HB_PARNL( 1 ), &rct );
}

HB_FUNC( WNDBOXRAISED )
{
   RECT rct;

   rct.top    = hb_parni( 2 );
   rct.left   = hb_parni( 3 );
   rct.bottom = hb_parni( 4 );
   rct.right  = hb_parni( 5 );

   WindowRaised( ( HDC ) HB_PARNL( 1 ), &rct );
}
