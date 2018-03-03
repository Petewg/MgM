/***************************************************************
   This file contains the special painting routines used by TSBrowse Class
   Last update: 04/19/2017
***************************************************************/

#define _WIN32_IE     0x0500
#define _WIN32_WINNT  0x0400

#include <mgdefs.h>
#include <commctrl.h>

#include "hbvm.h"

void         WndBoxDraw( HDC, LPRECT, HPEN, HPEN, int, BOOL );
void         cDrawCursor( HWND, LPRECT, long, COLORREF );
static void  DrawCheck( HDC, LPRECT, HPEN, int, BOOL );
static void  GoToPoint( HDC, int, int );
static void  DegradColor( HDC, RECT *, COLORREF, signed long );

static HWND hwndMDIClient;

LRESULT CALLBACK WndProcBrw( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "EVENTS" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushLong( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushLong( wParam );
      hb_vmPushLong( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );

   if( r != 0 )
      return r;
   else
      return DefWindowProc( hWnd, message, wParam, lParam );
}

LRESULT CALLBACK WndProcMDI( HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam )
{
   static PHB_SYMB pSymbol = NULL;
   long int        r;

   if( ! pSymbol )
      pSymbol = hb_dynsymSymbol( hb_dynsymGet( "EVENTS" ) );

   if( pSymbol )
   {
      hb_vmPushSymbol( pSymbol );
      hb_vmPushNil();
      hb_vmPushLong( ( LONG_PTR ) hWnd );
      hb_vmPushLong( message );
      hb_vmPushLong( wParam );
      hb_vmPushLong( lParam );
      hb_vmDo( 4 );
   }

   r = hb_parnl( -1 );

   if( r != 0 )
      return r;
   else
      return DefFrameProc( hWnd, hwndMDIClient, message, wParam, lParam );
}

HB_FUNC( REGISTER_CLASS )
{
   WNDCLASS WndClass;
   HBRUSH   hbrush;

   WndClass.style = CS_DBLCLKS;
   hwndMDIClient  = ( HB_ISNIL( 3 ) ? 0 : ( HWND ) HB_PARNL( 3 ) );
   if( hwndMDIClient )
      WndClass.lpfnWndProc = WndProcMDI;
   else
      WndClass.lpfnWndProc = WndProcBrw;

   WndClass.cbClsExtra = 0;
   WndClass.cbWndExtra = 0;
   WndClass.hInstance  = GetModuleHandle( NULL );
   WndClass.hIcon      = 0;
   WndClass.hCursor    = LoadCursor( NULL, IDC_ARROW );
   hbrush = ( HB_ISNIL( 2 ) ? 0 : ( HBRUSH ) HB_PARNL( 2 ) );
   WndClass.hbrBackground = hbrush;
   WndClass.lpszMenuName  = NULL;
   WndClass.lpszClassName = hb_parc( 1 );

   if( ! RegisterClass( &WndClass ) )
   {
      MessageBox( 0, "Window Registration Failed!", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
      ExitProcess( 0 );
   }

   HB_RETNL( ( LONG_PTR ) hbrush );
}

HB_FUNC( _CREATEWINDOWEX )
{
   HWND   hWnd;
   DWORD  dwExStyle  = hb_parnl( 1 );
   LPCSTR cClass     = ( LPCSTR ) hb_parc( 2 );
   LPCSTR cTitle     = ( LPCSTR ) hb_parc( 3 );
   int    nStyle     = hb_parni( 4 );
   int    x          = HB_ISNIL( 5 ) ? 0 : hb_parni( 5 );
   int    y          = HB_ISNIL( 6 ) ? 0 : hb_parni( 6 );
   int    nWidth     = HB_ISNIL( 7 ) ? 0 : hb_parni( 7 );
   int    nHeight    = HB_ISNIL( 8 ) ? 0 : hb_parni( 8 );
   HWND   hWndParent = ( HWND ) HB_PARNL( 9 );
   HMENU  hMenu      = ( HMENU ) NULL;
   HANDLE hInstance  = ( HANDLE ) HB_PARNL( 11 );

   hWnd = CreateWindowEx( dwExStyle, cClass, cTitle, nStyle, x, y, nWidth, nHeight, hWndParent, hMenu, ( HINSTANCE ) hInstance, NULL );

   HB_RETNL( ( LONG_PTR ) hWnd );
}

void MaskRegion( HDC hdc, RECT * rct, COLORREF cTransparentColor, COLORREF cBackgroundColor )
{
   HDC      hdcTemp, hdcObject, hdcBack, hdcMem;
   POINT    ptSize;
   COLORREF cColor;
   HBITMAP  bmAndObject, bmAndBack, bmBackOld, bmObjectOld, bmAndTemp, bmTempOld, bmAndMem, bmMemOld;
   HBRUSH   hBrush, hBrOld;

   ptSize.x = rct->right - rct->left + 1;
   ptSize.y = rct->bottom - rct->top + 1;

   hBrush = CreateSolidBrush( cBackgroundColor );

   hdcTemp   = CreateCompatibleDC( hdc );
   hdcObject = CreateCompatibleDC( hdc );
   hdcBack   = CreateCompatibleDC( hdc );
   hdcMem    = CreateCompatibleDC( hdc );

   bmAndTemp   = CreateCompatibleBitmap( hdc, ptSize.x, ptSize.y );
   bmAndMem    = CreateCompatibleBitmap( hdc, ptSize.x, ptSize.y );
   bmAndObject = CreateBitmap( ptSize.x, ptSize.y, 1, 1, NULL );
   bmAndBack   = CreateBitmap( ptSize.x, ptSize.y, 1, 1, NULL );

   bmTempOld   = ( HBITMAP ) SelectObject( hdcTemp, bmAndTemp );
   bmMemOld    = ( HBITMAP ) SelectObject( hdcMem, bmAndMem );
   bmBackOld   = ( HBITMAP ) SelectObject( hdcBack, bmAndBack );
   bmObjectOld = ( HBITMAP ) SelectObject( hdcObject, bmAndObject );

   hBrOld = ( HBRUSH ) SelectObject( hdcMem, hBrush );

   BitBlt( hdcTemp, 0, 0, ptSize.x, ptSize.y, hdc, rct->left, rct->top, SRCCOPY );

   SetMapMode( hdcTemp, GetMapMode( hdc ) );

   cColor = SetBkColor( hdcTemp, cTransparentColor );

   BitBlt( hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY );

   SetBkColor( hdcTemp, cColor );

   BitBlt( hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, NOTSRCCOPY );
   PatBlt( hdcMem, 0, 0, ptSize.x, ptSize.y, PATCOPY );
   BitBlt( hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND );
   BitBlt( hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND );
   BitBlt( hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT );
   BitBlt( hdc, rct->left, rct->top, ptSize.x, ptSize.y, hdcMem, 0, 0, SRCCOPY );

   DeleteObject( SelectObject( hdcMem, hBrOld ) );
   DeleteObject( SelectObject( hdcTemp, bmTempOld ) );
   DeleteObject( SelectObject( hdcMem, bmMemOld ) );
   DeleteObject( SelectObject( hdcBack, bmBackOld ) );
   DeleteObject( SelectObject( hdcObject, bmObjectOld ) );
   DeleteDC( hdcMem );
   DeleteDC( hdcBack );
   DeleteDC( hdcObject );
   DeleteDC( hdcTemp );
}

void DrawBitmap( HDC hDC, HBITMAP hBitmap, int wRow, int wCol, int wWidth, int wHeight, DWORD dwRaster )
{
   HDC    hDCmem = CreateCompatibleDC( hDC );
   BITMAP bitmap;

   if( ! dwRaster )
      dwRaster = SRCCOPY;

   SelectObject( hDCmem, hBitmap );
   GetObject( hBitmap, sizeof( BITMAP ), ( LPVOID ) &bitmap );
   if( wWidth && ( wWidth != bitmap.bmWidth || wHeight != bitmap.bmHeight ) )
      StretchBlt( hDC, wCol, wRow, wWidth, wHeight, hDCmem, 0, 0, bitmap.bmWidth, bitmap.bmHeight, dwRaster );
   else
      BitBlt( hDC, wCol, wRow, bitmap.bmWidth, bitmap.bmHeight, hDCmem, 0, 0, dwRaster );

   DeleteDC( hDCmem );
}

void DrawMasked( HDC hDC, HBITMAP hbm, int wRow, int wCol )
{
   HDC      hDcBmp = CreateCompatibleDC( hDC );
   HDC      hDcMask;
   HBITMAP  hBmpMask, hOldBmp2, hOldBmp1 = ( HBITMAP ) SelectObject( hDcBmp, hbm );
   BITMAP   bm;
   COLORREF rgbBack;

   if( GetPixel( hDcBmp, 0, 0 ) != GetSysColor( 15 ) )
   {
      GetObject( hbm, sizeof( BITMAP ), ( LPSTR ) &bm );
      hDcMask  = CreateCompatibleDC( hDC );
      hBmpMask = CreateCompatibleBitmap( hDcMask, bm.bmWidth, bm.bmHeight );
      hOldBmp2 = ( HBITMAP ) SelectObject( hDcMask, hBmpMask );
      rgbBack  = SetBkColor( hDcBmp, GetPixel( hDcBmp, 0, 0 ) );
      BitBlt( hDcMask, wRow, wCol, bm.bmWidth, bm.bmHeight, hDcBmp, 0, 0, SRCCOPY );
      SetBkColor( hDcBmp, rgbBack );

      BitBlt( hDC, wRow, wCol, bm.bmWidth, bm.bmHeight, hDcBmp, 0, 0, SRCINVERT );
      BitBlt( hDC, wRow, wCol, bm.bmWidth, bm.bmHeight, hDcMask, 0, 0, SRCAND );
      BitBlt( hDC, wRow, wCol, bm.bmWidth, bm.bmHeight, hDcBmp, 0, 0, SRCINVERT );

      BitBlt( hDcBmp, 0, 0, bm.bmWidth, bm.bmHeight, hDC, wRow, wCol, SRCCOPY );

      SelectObject( hDcMask, hOldBmp2 );
      DeleteObject( hBmpMask );
      DeleteDC( hDcMask );
   }

   SelectObject( hDcBmp, hOldBmp1 );
   DeleteDC( hDcBmp );
}

HB_FUNC( TSDRAWCELL )
{
   HWND     hWnd         = ( HWND ) HB_PARNL( 1 );
   HDC      hDC          = ( HDC ) HB_PARNL( 2 );
   int      nRow         = hb_parni( 3 );
   int      nColumn      = hb_parni( 4 );
   int      nWidth       = hb_parni( 5 );
   LPSTR    cData        = ( LPSTR ) hb_parc( 6 );
   int      nLen         = hb_parclen( 6 );
   DWORD    nAlign       = hb_parnl( 7 );
   COLORREF clrFore      = hb_parnl( 8 );
   COLORREF clrBack      = hb_parnl( 9 );
   HFONT    hFont        = ( HFONT ) HB_PARNL( 10 );
   HBITMAP  hBitMap      = ( HBITMAP ) HB_PARNL( 11 );
   int      nHeightCell  = hb_parni( 12 );
   BOOL     b3DLook      = hb_parl( 13 );
   int      nLineStyle   = hb_parni( 14 );
   COLORREF clrLine      = hb_parnl( 15 );
   int      nHeadFoot    = hb_parni( 16 );
   int      nHeightHead  = hb_parni( 17 );
   int      nHeightFoot  = hb_parni( 18 );
   int      nHeightSuper = hb_parni( 19 );
   int      nHeightSpec  = hb_parni( 20 );
   BOOL     bAdjBmp      = hb_parl( 21 );
   BOOL     bMultiLine   = hb_parl( 22 );
   int      nVAlign      = hb_parni( 23 );
   int      nVertText    = hb_parni( 24 );
   COLORREF clrTo        = hb_parnl( 25 );
   BOOL     bOpaque      = hb_parl( 26 );
   //HBRUSH   wBrush       = ( HBRUSH ) HB_PARNL( 27 );
   BOOL     b3DInv       = ( HB_ISNIL( 28 ) ? FALSE : ! hb_parl( 28 ) );
   BOOL     b3D          = ( HB_ISNIL( 28 ) ? FALSE : TRUE );
   COLORREF nClr3DL      = hb_parnl( 29 );
   COLORREF nClr3DS      = hb_parnl( 30 );
   long     lCursor      = hb_parnl( 31 );
   BOOL     bSelec       = ( HB_ISNIL( 32 ) ? FALSE : hb_parl( 32 ) );

   int ixLayOut = HIWORD( nAlign );
   int iAlign   = LOWORD( nAlign );

   BOOL  bGrid      = ( nLineStyle > 0 ? TRUE : FALSE );
   BOOL  bHeader    = ( nHeadFoot == 1 ? TRUE : FALSE );
   BOOL  bFooter    = ( nHeadFoot == 2 ? TRUE : FALSE );
   BOOL  bSuper     = ( nHeadFoot == 3 ? TRUE : FALSE );
   BOOL  bSpecHd    = ( nHeadFoot == 4 ? TRUE : FALSE );
   BOOL  bChecked   = ( nVertText == 3 ? TRUE : FALSE );
   BOOL  bBrush     = FALSE;
   BOOL  bDegrad    = ( bBrush || clrTo == clrBack ? FALSE : TRUE );
   HFONT hOldFont   = NULL;
   BOOL  bDestroyDC = FALSE;
   HPEN  hGrayPen   = CreatePen( PS_SOLID, 1, clrLine );
   HPEN  hWhitePen  = CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNHIGHLIGHT ) );

   RECT   rct;
   BITMAP bm;
   int    nTop, nLeft, nBkOld, iFlags;
   SIZE   size;
   int    iTxtW = 0;

   memset( &bm, 0, sizeof( BITMAP ) );

   if( GetTextExtentPoint32( hDC, cData, nLen, &size ) )
      iTxtW = size.cx;

   if( ! hDC )
   {
      bDestroyDC = TRUE;
      hDC        = GetDC( hWnd );
   }

   if( hFont )
      hOldFont = ( HFONT ) SelectObject( hDC, hFont );

   GetClientRect( hWnd, &rct );

   SetTextColor( hDC, clrFore );
   SetBkColor( hDC, clrBack );
   if( nRow == 0 )
   {
      if( bSpecHd )
         rct.top = ( nHeightHead + nHeightSuper - ( nHeightSuper ? 1 : 0 ) );
      else
         rct.top = ( bHeader ? nHeightSuper - ( nHeightSuper ? 1 : 0 ) : 0 );
   }
   else
      rct.top = ( bFooter ? rct.bottom - nHeightFoot + 1 : nHeightHead + nHeightSuper - ( nHeightSuper ? 1 : 0 ) + nHeightSpec + ( nHeightCell * ( nRow - 1 ) ) );

   rct.bottom = rct.top + ( bHeader ? nHeightHead : ( bSuper ? nHeightSuper : nHeightCell ) - 1 );
   rct.bottom = ( bSpecHd ?  rct.bottom + nHeightSpec  : rct.bottom );

   /* Don't let left side go beyond rct.right of Client Rect. */

   if( nColumn - ( rct.right - rct.left ) <= 0 )
   {
      rct.left = nColumn;

      /* if nWidth == -1 or -2, it indicates the last column so go to limit,
         Don't let right side go beyond rct.right of Client Rect. */

      if( ( nWidth >= 0 ) && ( ( rct.left + nWidth - rct.right ) <= 0 ) )  // negative values have different meanings
         rct.right = rct.left + nWidth;

      if( ! bDegrad )
      {
         rct.bottom += ( bHeader ? 0 : 1 );
         rct.right  += 1;

         if( ! bBrush )
            ExtTextOut( hDC, rct.left, rct.top, ETO_OPAQUE | ETO_CLIPPED, &rct, "", 0, 0 );
//         else
//            FillRect( hDC, &rct, wBrush );

         rct.bottom -= ( bHeader ? 0 : 1 );
         rct.right  -= 1;
      }
      else
         DegradColor( hDC, &rct, clrBack, clrTo );

      if( hBitMap )
      {
         if( ! bAdjBmp )
         {
            GetObject( hBitMap, sizeof( BITMAP ), ( LPSTR ) &bm );
            nTop = rct.top + ( ( rct.bottom - rct.top + 1 ) / 2 ) - ( bm.bmHeight / 2 );

            switch( ixLayOut )   // bitmap layout x coordinate
            {
               case 0:           // column left
                  nLeft = rct.left;
                  break;

               case 1:           // column center (text -if any- may overwrite the bitmap)
                  nLeft = rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) - ( bm.bmWidth / 2 ) - 1;
                  break;

               case 2:           // column right
                  nLeft = rct.right - ( bm.bmWidth + 1 );
                  break;

               case 3:           // left of centered text
                  nLeft = HB_MAX( rct.left, rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) - ( iTxtW / 2 ) - bm.bmWidth - 2 );
                  break;

               case 4:           // right of centered text
                  nLeft = rct.left + ( ( rct.right - rct.left + 1 ) / 2 ) + ( iTxtW / 2 ) + 2;
                  break;

               default:          // a value > 4 means specific pixel location from column left
                  nLeft = rct.left + ixLayOut;
                  break;
            }
         }
         else
         {
            nTop  = rct.top;
            nLeft = rct.left;
         }

         if( b3DLook )
         {
            if( bAdjBmp )
            {
               nTop = rct.top + 1;
               DrawBitmap( hDC, hBitMap, nTop, rct.left - 1, rct.right - rct.left + 1, rct.bottom - rct.top - 1, bSelec ? 0 : SRCAND );
               hBitMap = 0;

               if( ! bOpaque )
                  MaskRegion( hDC, &rct, GetPixel( hDC, nLeft, nTop ), GetBkColor( hDC ) );
            }
            else if( bOpaque )
               DrawBitmap( hDC, hBitMap, nTop, nLeft, 0, 0, bSelec ? 0 : SRCAND );
            else
               DrawMasked( hDC, hBitMap, nTop, nLeft );
         }
         else
         {
            if( bAdjBmp )
            {
               DrawBitmap( hDC, hBitMap, rct.top, rct.left - 2, rct.right - rct.left + 3, rct.bottom - rct.top - 1, bSelec ? 0 : SRCAND );
               hBitMap = 0;

               if( ! bOpaque )
                  MaskRegion( hDC, &rct, GetPixel( hDC, nLeft, nTop ), GetBkColor( hDC ) );
            }
            else if( bOpaque )
               DrawBitmap( hDC, hBitMap, nTop, nLeft, 0, 0, bSelec ? 0 : SRCAND );
            else
               DrawMasked( hDC, hBitMap, nTop, nLeft );
         }
      }

      if( nLen )
      {
         if( iAlign == DT_LEFT )
            rct.left += ( 2 + ( hBitMap && ixLayOut == 0 ? bm.bmWidth + 1 : 0 ) );

         if( iAlign == DT_RIGHT )
            rct.right -= ( 2 + ( hBitMap && ixLayOut == 2 ? bm.bmWidth + 1 : 0 ) );

         if( nVertText == 1 )
         {
            rct.right  += ( 4 * nLen );
            rct.bottom += 10;
         }

         iFlags = iAlign | DT_NOPREFIX | nVAlign * 4 | ( bMultiLine && nVAlign < 2 ? 0 : DT_SINGLELINE );

         if( ( nVertText == 3 || nVertText == 4 ) )
            DrawCheck( hDC, &rct, hWhitePen, iAlign, bChecked );
         else
         {
            nBkOld = SetBkMode( hDC, TRANSPARENT );

            if( b3D )
            {
               rct.top    -= 1;
               rct.left   -= 1;
               rct.bottom -= 1;
               rct.right  -= 1;

               SetTextColor( hDC, b3DInv ? nClr3DS : nClr3DL );
               DrawTextEx( hDC, cData, nLen, &rct, iFlags, NULL );

               rct.top    += 2;
               rct.left   += 2;
               rct.bottom += 2;
               rct.right  += 2;

               SetTextColor( hDC, b3DInv ? nClr3DL : nClr3DS );
               DrawTextEx( hDC, cData, nLen, &rct, iFlags, NULL );

               rct.top    -= 1;
               rct.left   -= 1;
               rct.bottom -= 1;
               rct.right  -= 1;

               SetTextColor( hDC, clrFore );
            }

            DrawTextEx( hDC, cData, nLen, &rct, iFlags, NULL );
            SetBkMode( hDC, nBkOld );
         }

         if( iAlign == DT_LEFT )
            rct.left -= ( 2 + ( hBitMap && ixLayOut == 0 ? bm.bmWidth + 1 : 0 ) );

         if( iAlign == DT_RIGHT )
            rct.right += ( 2 + ( hBitMap && ixLayOut == 2 ? bm.bmWidth + 1 : 0 ) );

         if( nVertText == 1 )
         {
            rct.right  -= ( 4 * nLen );
            rct.bottom -= 10;
         }
      }

      if( b3DLook )
      {
         bHeader = ( bSuper ? bSuper : bHeader );

         if( ( nWidth != -2 ) && bGrid )  // -1 draw gridline in phantom column; -2 don't draw gridline in phantom column
            WndBoxDraw( hDC, &rct, hWhitePen, hGrayPen, b3DLook ? 4 : nLineStyle, bHeader );

         if( lCursor )
            cDrawCursor( hWnd, &rct, lCursor, clrFore );
      }
      else
      {
         bHeader = ( bFooter ? bFooter : ( bHeader || bSuper ) );

         if( ( nWidth != -2 ) && bGrid )  // -1 draw gridline in phantom column; -2 don't draw gridline in phantom column
            WndBoxDraw( hDC, &rct, hGrayPen, hGrayPen, nLineStyle, bHeader );

         if( lCursor )
            cDrawCursor( hWnd, &rct, lCursor, clrFore );
      }
   }

   DeleteObject( hGrayPen );
   DeleteObject( hWhitePen );

   if( hFont )
      SelectObject( hDC, hOldFont );

   if( bDestroyDC )
      ReleaseDC( hWnd, hDC );
}

void WndBoxDraw( HDC hDC, RECT * rct, HPEN hPUpLeft, HPEN hPBotRit, int nLineStyle, BOOL bHeader )
{
   HPEN hOldPen = ( HPEN ) SelectObject( hDC, hPUpLeft );
   HPEN hBlack  = CreatePen( PS_SOLID, 1, 0 );

   switch( nLineStyle )
   {
      case 0:
         break;

      case 1:
         SelectObject( hDC, hPBotRit );
         GoToPoint( hDC, rct->left, rct->bottom - ( bHeader ? 1 : 0 ) );
         LineTo( hDC, rct->right - 1, rct->bottom - ( bHeader ? 1 : 0 ) );
         LineTo( hDC, rct->right - 1, rct->top - 1 );
         if( bHeader )
            LineTo( hDC, rct->left - 1, rct->top - 1 );
         break;

      case 2:
         SelectObject( hDC, hPBotRit );
         GoToPoint( hDC, rct->right - 1, rct->bottom );
         LineTo( hDC, rct->right - 1, rct->top - 1 );
         break;

      case 3:
         SelectObject( hDC, hPBotRit );
         GoToPoint( hDC, rct->left, rct->bottom );
         LineTo( hDC, rct->right, rct->bottom );
         break;

      case 4:
         SelectObject( hDC, hPUpLeft );
         GoToPoint( hDC, rct->left, rct->bottom );
         LineTo( hDC, rct->left, rct->top );
         LineTo( hDC, rct->right, rct->top );
         SelectObject( hDC, hPBotRit );
         GoToPoint( hDC, rct->left, rct->bottom - ( bHeader ? 1 : 0 ) );
         LineTo( hDC, rct->right - 1, rct->bottom - ( bHeader ? 1 : 0 ) );
         LineTo( hDC, rct->right - 1, rct->top - 1 );
         break;

      case 5:
         rct->top    += 1;
         rct->left   += 1;
         rct->bottom -= 1;
         rct->right  -= 1;
         DrawFocusRect( hDC, rct );
         break;
   }

   SelectObject( hDC, hOldPen );
   DeleteObject( hBlack );
}

HB_FUNC( TSBRWSCROLL )
{
   HWND  hWnd          = ( HWND ) HB_PARNL( 1 );
   int   iRows         = hb_parni( 2 );
   HFONT hFont         = ( HFONT ) HB_PARNL( 3 );
   int   nHeightCell   = hb_parni( 4 );
   int   nHeightHead   = hb_parni( 5 );
   int   nHeightFoot   = hb_parni( 6 );
   int   nHeightSuper  = hb_parni( 7 );
   int   nHeightSpecHd = hb_parni( 8 );

   HFONT hOldFont = NULL;
   HDC   hDC      = GetDC( hWnd );
   RECT  rct;

   if( hFont )
      hOldFont = ( HFONT ) SelectObject( hDC, hFont );

   GetClientRect( hWnd, &rct );

   rct.top    += ( nHeightHead + nHeightSuper - ( nHeightSuper ? 1 : 0 ) + nHeightSpecHd - ( nHeightSpecHd ? 1 : 0 ) ); // exclude heading from scrolling
   rct.bottom -= nHeightFoot;                                                                                           // exclude footing from scrolling
   rct.bottom -= ( ( rct.bottom - rct.top ) % nHeightCell );                                                            // exclude unused portion at bottom
   if( iRows > 0 )
      rct.bottom -= nHeightCell;
   else
      rct.top += nHeightCell;

   ScrollWindowEx( hWnd, 0, ( int ) -( nHeightCell * iRows ), 0, &rct, 0, 0, 0 );

   if( hFont )
      SelectObject( hDC, hOldFont );

   ReleaseDC( hWnd, hDC );
}

HB_FUNC( TSBRWHSCROLL )
{
   HWND hWnd   = ( HWND ) HB_PARNL( 1 );
   int  iCols  = hb_parni( 2 );
   int  nLeft  = hb_parni( 3 );
   int  nRight = hb_parni( 4 );

   HDC  hDC = GetDC( hWnd );
   RECT rct;

   GetClientRect( hWnd, &rct );

   if( nLeft )
      rct.left = nLeft;

   if( nRight )
      rct.right = nRight;

   ScrollWindowEx( hWnd, iCols, 0, 0, &rct, 0, 0, 0 );

   ReleaseDC( hWnd, hDC );
}

HB_FUNC( ROWFROMPIX )
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   int  iPixR = hb_parni( 2 );
   int  iCell = hb_parni( 3 );
   int  iHead = hb_parni( 4 );
   int  iFoot = hb_parni( 5 );
   int  iSupH = hb_parni( 6 );
   int  iSpcH = hb_parni( 7 );

   RECT rct;
   int  iRow;

   GetClientRect( hWnd, &rct );

   if( iPixR <= ( rct.top + iHead + iSupH ) )
      iRow = 0;
   else if( iPixR >= ( rct.top + iHead + iSupH ) && iPixR <= ( rct.top + iHead + iSupH + iSpcH ) )
      iRow = -2;
   else if( iPixR >= ( rct.bottom - iFoot ) )
      iRow = -1;
   else
   {
      rct.top += ( iHead + iSupH + iSpcH );
      iRow     = ( ( iPixR - rct.top ) / iCell ) + 1;
   }

   hb_retni( iRow );
}

HB_FUNC( SBGETHEIGHT )   // ( hWnd, hFont, nTotal )
{
   HWND  hWnd   = ( HWND ) HB_PARNL( 1 );
   HFONT hFont  = ( HFONT ) HB_PARNL( 2 );
   int   iTotal = hb_parni( 3 );

   TEXTMETRIC tm;

   RECT  rct;
   HDC   hDC = GetDC( hWnd );
   HFONT hOldFont = NULL;
   LONG  lTotHeight, lReturn;

   if( iTotal < 2 )
   {
      if( hFont )
         hOldFont = ( HFONT ) SelectObject( hDC, hFont );

      GetTextMetrics( hDC, &tm );
      if( hFont )
         SelectObject( hDC, hOldFont );

      ReleaseDC( hWnd, hDC );
      lReturn = ( iTotal == 1 ? tm.tmAveCharWidth : tm.tmHeight );
      hb_retnl( lReturn );
   }
   else
   {
      GetWindowRect( hWnd, &rct );
      lTotHeight = rct.bottom - rct.top + 1;
      ReleaseDC( hWnd, hDC );
      hb_retnl( lTotHeight );
   }
}

HB_FUNC( COUNTROWS )     // ( hWnd, nHeightCell, nHeightHead, nHeightFoot, nHeightSuper, nHeightSpec ) -> nRows
{
   HWND hWnd  = ( HWND ) HB_PARNL( 1 );
   int  iCell = hb_parni( 2 );

   int iHead = hb_parni( 3 );
   int iFoot = hb_parni( 4 );
   int iSupH = hb_parni( 5 );
   int iSpcH = hb_parni( 6 );

   RECT rct;
   int  iRows, iFree;

   GetClientRect( hWnd, &rct );

   iFree = rct.bottom - rct.top + 1 - iSupH - iHead - iFoot - iSpcH;
   iRows = iFree / iCell;

   hb_retni( iRows );
}

HB_FUNC( SBMPHEIGHT )    // ( hBmp )
{
   HBITMAP hBmp = ( HBITMAP ) HB_PARNL( 1 );
   BITMAP  bm;

   GetObject( hBmp, sizeof( BITMAP ), ( LPSTR ) &bm );

   hb_retni( bm.bmHeight );
}

HB_FUNC( SBMPWIDTH )
{
   HBITMAP hBmp = ( HBITMAP ) HB_PARNL( 1 );
   BITMAP  bm;

   GetObject( hBmp, sizeof( BITMAP ), ( LPSTR ) &bm );

   hb_retni( bm.bmWidth );
}

static void DrawCheck( HDC hDC, LPRECT rct, HPEN hWhitePen, int nAlign, BOOL bChecked )
{
   RECT   lrct;
   HPEN   hOldPen;
   HBRUSH hOldBrush;

   HBRUSH hGrayBrush  = CreateSolidBrush( RGB( 192, 192, 192 ) );
   HBRUSH hWhiteBrush = CreateSolidBrush( RGB( 255, 255, 255 ) );
   HPEN   hBlackPen   = CreatePen( PS_SOLID, 1, RGB( 0, 0, 0 ) );
   HPEN   hLGrayPen   = CreatePen( PS_SOLID, 1, RGB( 192, 192, 192 ) );
   HPEN   hGrayPen    = CreatePen( PS_SOLID, 1, RGB( 128, 128, 128 ) );

   hOldBrush = ( HBRUSH ) SelectObject( hDC, hGrayBrush );

   lrct.top = rct->top + ( ( ( rct->bottom - rct->top + 1 ) / 2 ) - 8 );

   switch( nAlign )
   {
      case 0:  lrct.left = rct->left; break;
      case 1:  lrct.left = rct->left + ( ( rct->right - rct->left + 1 ) / 2 ) - 8; break;
      case 2:  lrct.left = rct->right - 16; break;
      default: lrct.left = rct->left;
   }

   lrct.bottom = lrct.top + 16;
   lrct.right  = lrct.left + 16;

   lrct.left   -= 1;
   lrct.top    -= 1;
   lrct.right  += 1;
   lrct.bottom += 1;

   hOldPen = ( HPEN ) SelectObject( hDC, hBlackPen );
   Rectangle( hDC, lrct.left, lrct.top, lrct.right, lrct.bottom );

   lrct.left   += 1;
   lrct.top    += 1;
   lrct.right  -= 1;
   lrct.bottom -= 1;

   FillRect( hDC, &lrct, hGrayBrush );

   lrct.top    += 2;
   lrct.left   += 2;
   lrct.right  -= 1;
   lrct.bottom -= 1;

   FillRect( hDC, &lrct, hWhiteBrush );

   SelectObject( hDC, hOldBrush );
   DeleteObject( hGrayBrush );
   DeleteObject( hWhiteBrush );

   lrct.right  -= 1;
   lrct.bottom -= 1;

   SelectObject( hDC, hGrayPen );
   Rectangle( hDC, lrct.left, lrct.top, lrct.right, lrct.bottom );

   lrct.top    += 1;
   lrct.left   += 1;
   lrct.right  -= 1;
   lrct.bottom -= 1;

   SelectObject( hDC, hBlackPen );
   Rectangle( hDC, lrct.left, lrct.top, lrct.right, lrct.bottom );

   lrct.top  += 1;
   lrct.left += 1;

   SelectObject( hDC, hWhitePen );
   Rectangle( hDC, lrct.left, lrct.top, lrct.right, lrct.bottom );

   lrct.top    += 1;
   lrct.right  -= 2;
   lrct.bottom -= 1;

   if( bChecked )
   {
      GoToPoint( hDC, lrct.right, lrct.top );

      SelectObject( hDC, hBlackPen );

      LineTo( hDC, lrct.right - 4, lrct.bottom - 3 );
      LineTo( hDC, lrct.right - 6, lrct.bottom - 5 );

      GoToPoint( hDC, lrct.right, lrct.top + 1 );
      LineTo( hDC, lrct.right - 4, lrct.bottom - 2 );
      LineTo( hDC, lrct.right - 6, lrct.bottom - 4 );

      GoToPoint( hDC, lrct.right, lrct.top + 2 );
      LineTo( hDC, lrct.right - 4, lrct.bottom - 1 );
      LineTo( hDC, lrct.right - 6, lrct.bottom - 3 );
   }

   SelectObject( hDC, hOldPen );
   DeleteObject( hGrayPen );
   DeleteObject( hLGrayPen );
   DeleteObject( hBlackPen );
}

static void GoToPoint( HDC hDC, int ix, int iy )
{
   POINT pt;

   MoveToEx( hDC, ix, iy, &pt );
}

static void DegradColor( HDC hDC, RECT * rori, COLORREF cFrom, signed long cTo )
{
   float  clr1r, clr1g, clr1b, clr2r, clr2g, clr2b;
   float  iEle, iRed, iGreen, iBlue;
   BOOL   bDir, bHoriz = cTo < 0;
   long   iTot = ( ! bHoriz ? ( rori->bottom + 2 - rori->top ) : ( rori->right + 2 - rori->left ) );
   RECT   rct;
   HBRUSH hOldBrush, hBrush;

   rct.top    = rori->top;
   rct.left   = rori->left;
   rct.bottom = rori->bottom;
   rct.right  = rori->right;

   clr1r = GetRValue( cFrom );
   clr1g = GetGValue( cFrom );
   clr1b = GetBValue( cFrom );

   cTo   = ( cTo < 0 ? -cTo : cTo );
   clr2r = GetRValue( cTo );
   clr2g = GetGValue( cTo );
   clr2b = GetBValue( cTo );

   iRed   = clr2r - clr1r;
   iGreen = clr2g - clr1g;
   iBlue  = clr2b - clr1b;

   iRed   = ( iRed / iTot );
   iGreen = ( iGreen / iTot );
   iBlue  = ( iBlue / iTot );

   iRed   = ( iRed < 0 ? -iRed : iRed );
   iGreen = ( iGreen < 0 ? -iGreen : iGreen );
   iBlue  = ( iBlue < 0 ? -iBlue : iBlue );

   if( ! bHoriz )
      rct.bottom = rct.top + 1;
   else
      rct.right = rct.left + 1;

   hBrush    = CreateSolidBrush( RGB( clr1r, clr1g, clr1b ) );
   hOldBrush = ( HBRUSH ) SelectObject( hDC, hBrush );
   FillRect( hDC, &rct, hBrush );

   for( iEle = 1; iEle < iTot; iEle++ )
   {
      bDir = ( clr2r >= clr1r ? TRUE : FALSE );
      if( bDir )
         clr1r += iRed;
      else
         clr1r -= iRed;

      clr1r = ( clr1r < 0 ? 0 : clr1r > 255 ? 255 : clr1r );

      bDir = ( clr2g >= clr1g ? TRUE : FALSE );
      if( bDir )
         clr1g += iGreen;
      else
         clr1g -= iGreen;

      clr1g = ( clr1g < 0 ? 0 : clr1g > 255 ? 255 : clr1g );

      bDir = ( clr2b >= clr1b ? TRUE : FALSE );
      if( bDir )
         clr1b += iBlue;
      else
         clr1b -= iBlue;

      clr1b = ( clr1b < 0 ? 0 : clr1b > 255 ? 255 : clr1b );

      SelectObject( hDC, hOldBrush );
      DeleteObject( hBrush );
      hBrush = CreateSolidBrush( RGB( clr1r, clr1g, clr1b ) );
      SelectObject( hDC, hBrush );
      FillRect( hDC, &rct, hBrush );

      if( ! bHoriz )
      {
         rct.top++;
         rct.bottom++;
      }
      else
      {
         rct.left++;
         rct.right++;
      }
   }

   SelectObject( hDC, hOldBrush );
   DeleteObject( hBrush );
}

void cDrawCursor( HWND hWnd, RECT * rctc, long lCursor, COLORREF nClr )
{
   HDC      hDC = GetDC( hWnd );
   HRGN     hReg;
   COLORREF lclr = ( lCursor == 1 ? RGB( 5, 5, 5 ) : lCursor == 2 ? nClr : ( COLORREF ) lCursor );
   HBRUSH   hBr;
   RECT     rct;

   if( lCursor != 3 )
   {
      hBr  = CreateSolidBrush( lclr );
      hReg = CreateRectRgn( rctc->left, rctc->top, rctc->right - 1, rctc->bottom );

      FrameRgn( hDC, hReg, hBr, 2, 2 );

      DeleteObject( hReg );
      DeleteObject( hBr );
   }
   else
   {
      rct.top    = rctc->top + 1;
      rct.left   = rctc->left + 1;
      rct.bottom = rctc->bottom - 1;
      rct.right  = rctc->right - 1;

      DrawFocusRect( hDC, &rct );
   }

   ReleaseDC( hWnd, hDC );
}

HB_FUNC( GETSCRLRANGE )  // ( hWnd, nFlags )
{
   int iMin = 0, iMax = 0;

   GetScrollRange( ( HWND ) HB_PARNL( 1 ), // its hWnd
                   hb_parni( 2 ),          // Scroll bar flags
                   &iMin, &iMax );

   hb_reta( 2 );  // { nMin, nMax }
   HB_STORNI( iMin, -1, 1 );
   HB_STORNI( iMax, -1, 2 );
}

HB_FUNC( INITEDSPINNER )
{
   HWND hwnd;
   HWND hedit;
   HWND hupdown;
   int  Style = WS_CHILD | WS_VISIBLE | UDS_ARROWKEYS | UDS_ALIGNRIGHT | UDS_SETBUDDYINT | UDS_NOTHOUSANDS | UDS_HOTTRACK;
   int  iMin, iMax;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_UPDOWN_CLASS;
   InitCommonControlsEx( &i );

   hwnd  = ( HWND ) HB_PARNL( 1 );
   hedit = ( HWND ) HB_PARNL( 2 );

   iMin  = hb_parni( 7 );
   iMax  = hb_parni( 8 );

   hupdown = CreateUpDownControl( Style, hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ), hb_parni( 6 ), hwnd, 0, GetModuleHandle( NULL ),
                                  hedit, iMax, iMin, hb_parni( 9 ) );

   SendMessage( hupdown, UDM_SETRANGE32, ( WPARAM ) iMin, ( LPARAM ) iMax );

   HB_RETNL( ( LONG_PTR ) hupdown );
}

HB_FUNC( SETINCREMENTSPINNER )
{
   UDACCEL inc;

   SendMessage( ( HWND ) HB_PARNL( 1 ), UDM_GETACCEL, ( WPARAM ) 1, ( LPARAM ) &inc );

   inc.nSec = 1;
   inc.nInc = hb_parni( 2 );

   SendMessage( ( HWND ) HB_PARNL( 1 ), UDM_SETACCEL, ( WPARAM ) 1, ( LPARAM ) &inc );
}
