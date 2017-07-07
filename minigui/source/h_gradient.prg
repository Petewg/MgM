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
   author: Copyright 2007-2017 (C) P.Chornyj <myorg63@mail.ru>
 */

#include "minigui.ch"

#ifndef __XHARBOUR__
  /* SWITCH ... ; CASE ... ; DEFAULT ; ... ; END */
  #xcommand DEFAULT => OTHERWISE
#endif

/*
 * HMG 1.3 Extended Build 33
 * Author: P.Chornyj <myorg63@mail.ru>
 */

INIT PROCEDURE InitGradientFunc()

   _InitGradientFunc()

RETURN

EXIT PROCEDURE ExitGradientFunc()

   _ExitGradientFunc()

RETURN

/*
 * HMG 1.2 Extended Builds 30-33
 * Author: P.Chornyj <myorg63@mail.ru>
 */
FUNCTION DrawGradient( window, row, col, rowr, colr, aColor1, aColor2, vertical, border )

   LOCAL i := GetFormIndex ( window )
   LOCAL FormHandle := _HMG_aFormHandles [i]
   LOCAL hDC
   LOCAL color1, color2

   IF IsEnabledGradient()

      hDC := GetDC( FormHandle )

      hb_default( @aColor1, { 0, 0, 0 } )
      hb_default( @aColor2, { 255, 0, 0 } )
      hb_default( @vertical, .F. )
      hb_default( @border, 0 )  // 0 - none, 1 - ?, 2 - box, 3 - panel

      color1 := RGB ( aColor1[1], aColor1[2], aColor1[3] )
      color2 := RGB ( aColor2[1], aColor2[2], aColor2[3] )

      SWITCH border
      CASE 1
         EXIT

      CASE 2  // box
         WndBoxIn( hDC, row, col, rowr, colr )
         FillGradient( hDC, row + 1, col + 1, rowr - 1, colr - 1, vertical, color1, color2 )
         EXIT

      CASE 3  // panel
         WndBoxRaised( hDC, row, col, rowr, colr )
         FillGradient( hDC, row + 1, col + 1, rowr - 1, colr - 1, vertical, color1, color2 )
         EXIT

      DEFAULT
         FillGradient( hDC, row, col, rowr, colr, vertical, color1, color2 )
      END SWITCH

      ReleaseDC( FormHandle, hDC )
    
      SWITCH border
      CASE 1
         EXIT
 
      CASE 2  // box
         AAdd( _HMG_aFormGraphTasks [i], ;
            { || hDC := GetDC( FormHandle ), ;
            WndBoxIn( hDC, row, col, rowr, colr ), ;
            FillGradient( hDC, row + 1, col + 1, rowr - 1, colr - 1, vertical, color1, color2 ), ;
            ReleaseDC( FormHandle, hDC ) } )
         EXIT

      CASE 3  // panel
         AAdd( _HMG_aFormGraphTasks [i], ;
            { || hDC := GetDC( FormHandle ), ;
            WndBoxRaised( hDC, row, col, rowr, colr ), ;
            FillGradient( hDC, row + 1, col + 1, rowr - 1, colr - 1, vertical, color1, color2 ), ;
            ReleaseDC( FormHandle, hDC ) } )
         EXIT

      DEFAULT  // border none
         AAdd( _HMG_aFormGraphTasks [i], ;
            {|| FillGradient( hDC := GetDC( FormHandle ), row, col, rowr, colr, vertical, color1, color2 ), ;
            ReleaseDC( FormHandle, hDC ) } )
      END SWITCH

   ENDIF

RETURN NIL

/*
 * C-level
 */
#pragma BEGINDUMP

#include <mgdefs.h>

#if defined ( __MINGW32__ ) && ( _WIN32_WINNT < 0x0500 )
#define GRADIENT_FILL_RECT_H    0x00000000
#define GRADIENT_FILL_RECT_V    0x00000001
#define GRADIENT_FILL_TRIANGLE  0x00000002
#define GRADIENT_FILL_OP_FLAG   0x000000ff
#endif

BOOL    EnabledGradient( void );
BOOL    FillGradient( HDC hDC, RECT * rect, BOOL vertical, COLORREF crFrom, COLORREF crTo );
HBRUSH  LinearGradientBrush( HDC pDC, long cx, long cy, COLORREF cFrom, COLORREF cTo, BOOL bVert );

typedef BOOL ( WINAPI * AlphaBlendPtr )( HDC, int, int, int, int, HDC, int, int, int, int, BLENDFUNCTION );
typedef BOOL ( WINAPI * TransparentBltPtr )( HDC, int, int, int, int, HDC, int, int, int, int, UINT );
typedef BOOL ( WINAPI * GradientFillPtr )( HDC, CONST PTRIVERTEX, DWORD, CONST PVOID, DWORD, DWORD );

static HINSTANCE s_hDLL = NULL;

static GradientFillPtr   f_GradientFill   = NULL;
static AlphaBlendPtr     f_AlphaBlend     = NULL;
static TransparentBltPtr f_TransparentBlt = NULL;

BOOL EnabledGradient( void )
{
   return s_hDLL != NULL ? TRUE : FALSE;
}

HB_FUNC( ISENABLEDGRADIENT )
{
   hb_retl( EnabledGradient() );
}

HB_FUNC( _INITGRADIENTFUNC )
{
   s_hDLL = LoadLibrary( "gdi32.dll" );

   if( s_hDLL != NULL )
   {
      f_AlphaBlend     = ( AlphaBlendPtr ) GetProcAddress( s_hDLL, "GdiAlphaBlend" );
      f_TransparentBlt = ( TransparentBltPtr ) GetProcAddress( s_hDLL, "GdiTransparentBlt" );
      f_GradientFill   = ( GradientFillPtr ) GetProcAddress( s_hDLL, "GdiGradientFill" );

      if( ( f_AlphaBlend == NULL ) && ( f_TransparentBlt == NULL ) &&
          ( f_GradientFill == NULL ) )
      {
         FreeLibrary( s_hDLL );
         s_hDLL = NULL;
      }
   }

   if( s_hDLL == NULL )
   {
      s_hDLL = LoadLibrary( "msimg32.dll" );

      if( s_hDLL != NULL )
      {
         f_AlphaBlend     = ( AlphaBlendPtr ) GetProcAddress( s_hDLL, "AlphaBlend" );
         f_TransparentBlt = ( TransparentBltPtr ) GetProcAddress( s_hDLL, "TransparentBlt" );
         f_GradientFill   = ( GradientFillPtr ) GetProcAddress( s_hDLL, "GradientFill" );

         if( ( f_AlphaBlend == NULL ) && ( f_TransparentBlt == NULL ) &&
             ( f_GradientFill == NULL ) )
         {
            FreeLibrary( s_hDLL );
            s_hDLL = NULL;
         }
      }
   }

   hb_retl( EnabledGradient() ? HB_TRUE : HB_FALSE );
}

HB_FUNC( _EXITGRADIENTFUNC )
{
   if( s_hDLL != NULL )
   {
      FreeLibrary( s_hDLL );
      s_hDLL = NULL;
   }
}

HB_FUNC( ALPHABLEND )
{
   BOOL bRes = FALSE;
   HDC  hdc1 = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hdc2 = ( HDC ) ( LONG_PTR ) HB_PARNL( 6 );

   if( ( GetObjectType( hdc1 ) & ( OBJ_DC | OBJ_MEMDC ) ) && ( GetObjectType( hdc2 ) & ( OBJ_DC | OBJ_MEMDC ) ) )
   {
      if( ( s_hDLL != NULL ) && ( f_AlphaBlend != NULL ) )
      {
         BLENDFUNCTION bf;

         bf.BlendOp    = AC_SRC_OVER;
         bf.BlendFlags = 0;
         bf.SourceConstantAlpha = ( BYTE ) hb_parnl( 11 );
         bf.AlphaFormat         = ( BYTE ) hb_parni( 12 );

         bRes = f_AlphaBlend( hdc1,
                              hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ), hb_parnl( 5 ),
                              hdc2,
                              hb_parnl( 7 ), hb_parnl( 8 ), hb_parnl( 9 ), hb_parnl( 10 ),
                              bf );
      }
   }

   hb_retl( bRes ? HB_TRUE : HB_FALSE );
}

HB_FUNC( TRANSPARENTBLT )
{
   BOOL bRes = FALSE;
   HDC  hdc1 = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hdc2 = ( HDC ) ( LONG_PTR ) HB_PARNL( 6 );

   if( ( GetObjectType( hdc1 ) & ( OBJ_DC | OBJ_MEMDC ) ) && ( GetObjectType( hdc2 ) & ( OBJ_DC | OBJ_MEMDC ) ) )
   {
      if( ( s_hDLL != NULL ) && ( f_TransparentBlt != NULL ) )
      {
         int   iStretchMode = hb_parnidef( 12, COLORONCOLOR );
         BOOL  bHiRes       = ( iStretchMode == HALFTONE );
         POINT pt = { 0, 0 };

         if( bHiRes )
            GetBrushOrgEx( hdc1, &pt );

         SetStretchBltMode( hdc1, iStretchMode );

         if( bHiRes )
            SetBrushOrgEx( hdc1, pt.x, pt.y, NULL );

         bRes = f_TransparentBlt( hdc1,
                                  hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ), hb_parnl( 5 ),
                                  hdc2,
                                  hb_parnl( 7 ), hb_parnl( 8 ), hb_parnl( 9 ), hb_parnl( 10 ),
                                  ( COLORREF ) hb_parnl( 11 ) );
      }
   }

   hb_retl( bRes ? HB_TRUE : HB_FALSE );
}

HB_FUNC( FILLGRADIENT )
{
   BOOL bRes = FALSE;
   HDC  hdc  = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   if( GetObjectType( hdc ) & ( OBJ_DC | OBJ_MEMDC ) )
   {
      RECT rect;

      rect.top    = hb_parni( 2 );
      rect.left   = hb_parni( 3 );
      rect.bottom = hb_parni( 4 );
      rect.right  = hb_parni( 5 );

      bRes = ( FillGradient( hdc, &rect, hb_parl( 6 ),
                             ( COLORREF ) hb_parnl( 7 ), ( COLORREF ) hb_parnl( 8 ) ) );
   }

   hb_retl( bRes ? HB_TRUE : HB_FALSE );
}

BOOL FillGradient( HDC hDC, RECT * rect, BOOL vertical, COLORREF crFrom, COLORREF crTo )
{
   BOOL bRes = FALSE;

   if( ( s_hDLL != NULL ) && ( f_GradientFill != NULL ) )
   {
      TRIVERTEX     rcVertex[ 2 ];
      GRADIENT_RECT gRect;

      rcVertex[ 0 ].y     = rect->top;
      rcVertex[ 0 ].x     = rect->left;
      rcVertex[ 0 ].Red   = ( unsigned short ) ( GetRValue( crFrom ) << 8 );
      rcVertex[ 0 ].Green = ( unsigned short ) ( GetGValue( crFrom ) << 8 );
      rcVertex[ 0 ].Blue  = ( unsigned short ) ( GetBValue( crFrom ) << 8 );
      rcVertex[ 0 ].Alpha = 0;

      rcVertex[ 1 ].y     = rect->bottom;
      rcVertex[ 1 ].x     = rect->right;
      rcVertex[ 1 ].Red   = ( unsigned short ) ( GetRValue( crTo ) << 8 );
      rcVertex[ 1 ].Green = ( unsigned short ) ( GetGValue( crTo ) << 8 );
      rcVertex[ 1 ].Blue  = ( unsigned short ) ( GetBValue( crTo ) << 8 );
      rcVertex[ 1 ].Alpha = 0;

      gRect.UpperLeft  = 0;
      gRect.LowerRight = 1;

      bRes = f_GradientFill( hDC, rcVertex, 2, &gRect, 1,
                             vertical ? GRADIENT_FILL_RECT_V : GRADIENT_FILL_RECT_H );
   }

   return bRes;
}

HB_FUNC( CREATEGRADIENTBRUSH )
{
   HWND hwnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hdc;

   if( ! IsWindow( hwnd ) )
      hwnd = GetDesktopWindow();

   hdc = GetDC( hwnd );

   HB_RETNL( ( LONG_PTR ) LinearGradientBrush( hdc, hb_parnl( 2 ), hb_parnl( 3 ),
                                               ( COLORREF ) hb_parnl( 4 ), ( COLORREF ) hb_parnl( 5 ),
                                               hb_parl( 6 ) ) );
   ReleaseDC( hwnd, hdc );
}

HBRUSH LinearGradientBrush( HDC pDC, long cx, long cy, COLORREF crFrom, COLORREF crTo, BOOL bVert )
{
   HDC     memDC;
   HBITMAP memBmp;
   HBRUSH  pGradientBrush = ( HBRUSH ) NULL;

   memDC  = CreateCompatibleDC( pDC );
   memBmp = CreateCompatibleBitmap( pDC, cx, cy );

   if( memDC && memBmp )
   {
      TRIVERTEX     rcVertex[ 2 ];
      GRADIENT_RECT gRect;

      rcVertex[ 0 ].x     = 0;
      rcVertex[ 0 ].y     = 0;
      rcVertex[ 0 ].Red   = ( unsigned short ) ( GetRValue( crFrom ) << 8 );
      rcVertex[ 0 ].Green = ( unsigned short ) ( GetGValue( crFrom ) << 8 );
      rcVertex[ 0 ].Blue  = ( unsigned short ) ( GetBValue( crFrom ) << 8 );
      rcVertex[ 0 ].Alpha = 0;

      rcVertex[ 1 ].x     = cx;
      rcVertex[ 1 ].y     = cy;
      rcVertex[ 1 ].Red   = ( unsigned short ) ( GetRValue( crTo ) << 8 );
      rcVertex[ 1 ].Green = ( unsigned short ) ( GetGValue( crTo ) << 8 );
      rcVertex[ 1 ].Blue  = ( unsigned short ) ( GetBValue( crTo ) << 8 );
      rcVertex[ 1 ].Alpha = 0;

      gRect.UpperLeft  = 0;
      gRect.LowerRight = 1;

      SelectObject( memDC, memBmp );

      if( s_hDLL != NULL )
      {
         if( f_GradientFill != NULL )
         {
            f_GradientFill( memDC, rcVertex, 2, &gRect, 1,
                            bVert ? GRADIENT_FILL_RECT_V : GRADIENT_FILL_RECT_H );
         }
      }
      pGradientBrush = CreatePatternBrush( memBmp );

      DeleteObject( memBmp );
      DeleteObject( memDC );
   }

   return pGradientBrush;
}

#pragma ENDDUMP
