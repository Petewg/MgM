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
    Copyright 1999-2016, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts of this code are contributed for MiniGUI Project
   used here under permission of authors :

   Copyright 2005 (C) Andy Wos <andywos@unwired.com.au>
 + DrawGlyph()
   Copyright 2005 (C) Jacek Kubica <kubica@wssk.wroc.pl>
 + GetBitmapSize(),GetIconSize(),DrawGlyphMask()
   Copyright 2009 (C) Andi Jahja <harbour@cbn.net.id>
 + GetImageSize()
   ---------------------------------------------------------------------------*/

#include <mgdefs.h>
#include "hbapiitm.h"
#include "hbapifs.h"

HANDLE   ChangeBmpFormat( HBITMAP, HPALETTE );
WORD     GetDIBColors( LPSTR );

extern HINSTANCE g_hInstance;

HB_FUNC( WNDCOPY )
{
   HWND     hWnd = ( HWND ) HB_PARNL( 1 );
   HDC      hDC  = GetDC( hWnd );
   HDC      hMemDC;
   RECT     rc;
   HBITMAP  hBitmap;
   HBITMAP  hOldBmp;
   HPALETTE hPal  = 0;
   BOOL     bRect = hb_parl( 2 );
   LPSTR    File  = ( char * ) hb_parc( 3 );
   HANDLE   hDIB;
   BITMAPFILEHEADER   bmfHdr;
   LPBITMAPINFOHEADER lpBI;
   HANDLE filehandle;
   DWORD  dwDIBSize;
   DWORD  dwWritten;
   DWORD  dwBmBitsSize;

   if( bRect )
      GetWindowRect( hWnd, &rc );
   else
      GetClientRect( hWnd, &rc );

   hMemDC  = CreateCompatibleDC( hDC );
   hBitmap = CreateCompatibleBitmap( hDC, rc.right - rc.left, rc.bottom - rc.top );
   hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );
   BitBlt( hMemDC, 0, 0, rc.right - rc.left, rc.bottom - rc.top, hDC, 0, 0, SRCCOPY );
   SelectObject( hMemDC, hOldBmp );
   hDIB = ChangeBmpFormat( hBitmap, hPal );

   filehandle = CreateFile( File, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL );

   lpBI = ( LPBITMAPINFOHEADER ) GlobalLock( hDIB );
   if( ! lpBI )
   {
      CloseHandle( filehandle );
      return;
   }

   if( lpBI->biSize != sizeof( BITMAPINFOHEADER ) )
   {
      GlobalUnlock( hDIB );
      CloseHandle( filehandle );
      return;
   }

   bmfHdr.bfType = ( ( WORD ) ( 'M' << 8 ) | 'B' );

   dwDIBSize = *( LPDWORD ) lpBI + ( GetDIBColors( ( LPSTR ) lpBI ) * sizeof( RGBTRIPLE ) );

   dwBmBitsSize      = ( ( ( ( lpBI->biWidth ) * ( ( DWORD ) lpBI->biBitCount ) ) + 31 ) / 32 * 4 ) * lpBI->biHeight;
   dwDIBSize        += dwBmBitsSize;
   lpBI->biSizeImage = dwBmBitsSize;

   bmfHdr.bfSize      = dwDIBSize + sizeof( BITMAPFILEHEADER );
   bmfHdr.bfReserved1 = 0;
   bmfHdr.bfReserved2 = 0;

   bmfHdr.bfOffBits = ( DWORD ) sizeof( BITMAPFILEHEADER ) + lpBI->biSize + ( GetDIBColors( ( LPSTR ) lpBI ) * sizeof( RGBTRIPLE ) );

   WriteFile( filehandle, ( LPSTR ) &bmfHdr, sizeof( BITMAPFILEHEADER ), &dwWritten, NULL );

   WriteFile( filehandle, ( LPSTR ) lpBI, dwDIBSize, &dwWritten, NULL );

   GlobalUnlock( hDIB );
   CloseHandle( filehandle );

   DeleteDC( hMemDC );
   GlobalFree( hDIB );
   ReleaseDC( hWnd, hDC );
}

HANDLE ChangeBmpFormat( HBITMAP hBitmap, HPALETTE hPal )
{
   BITMAP bm;
   BITMAPINFOHEADER   bi;
   LPBITMAPINFOHEADER lpbi;
   DWORD   dwLen;
   HGLOBAL hDIB;
   HGLOBAL h;
   HDC     hDC;
   WORD    biBits;

   if( ! hBitmap )
      return 0;

   if( ! GetObject( hBitmap, sizeof( bm ), ( LPSTR ) &bm ) )
      return 0;

   if( hPal == 0 )
      hPal = ( HPALETTE ) GetStockObject( DEFAULT_PALETTE );

   biBits = ( WORD ) ( bm.bmPlanes * bm.bmBitsPixel );

   if( biBits <= 1 )
      biBits = 1;
   else if( biBits <= 4 )
      biBits = 4;
   else if( biBits <= 8 )
      biBits = 8;
   else
      biBits = 24;

   bi.biSize          = sizeof( BITMAPINFOHEADER );
   bi.biWidth         = bm.bmWidth;
   bi.biHeight        = bm.bmHeight;
   bi.biPlanes        = 1;
   bi.biBitCount      = biBits;
   bi.biCompression   = BI_RGB;
   bi.biSizeImage     = 0;
   bi.biXPelsPerMeter = 0;
   bi.biYPelsPerMeter = 0;
   bi.biClrUsed       = 0;
   bi.biClrImportant  = 0;

   dwLen = bi.biSize + ( GetDIBColors( ( LPSTR ) &bi ) * sizeof( RGBTRIPLE ) );

   hDC = GetDC( NULL );

   hPal = SelectPalette( hDC, hPal, FALSE );
   RealizePalette( hDC );

   hDIB = GlobalAlloc( GHND, dwLen );

   if( ! hDIB )
   {
      SelectPalette( hDC, hPal, TRUE );
      RealizePalette( hDC );
      ReleaseDC( NULL, hDC );
      return 0;
   }

   lpbi = ( LPBITMAPINFOHEADER ) GlobalLock( hDIB );

   *lpbi = bi;

   GetDIBits( hDC, hBitmap, 0, ( UINT ) bi.biHeight, NULL, ( LPBITMAPINFO ) lpbi, DIB_RGB_COLORS );

   bi = *lpbi;
   GlobalUnlock( hDIB );

   if( bi.biSizeImage == 0 )
      bi.biSizeImage = ( ( ( ( DWORD ) bm.bmWidth * biBits ) + 31 ) / 32 * 4 ) * bm.bmHeight;

   dwLen = bi.biSize + ( GetDIBColors( ( LPSTR ) &bi ) * sizeof( RGBTRIPLE ) ) + bi.biSizeImage;

   h = GlobalReAlloc( hDIB, ( SIZE_T ) dwLen, 0 );
   if( h )
      hDIB = h;
   else
   {
      GlobalFree( hDIB );
      hDIB = NULL;
      SelectPalette( hDC, hPal, TRUE );
      RealizePalette( hDC );
      ReleaseDC( NULL, hDC );
      return hDIB;
   }

   lpbi = ( LPBITMAPINFOHEADER ) GlobalLock( hDIB );

   if
   (
      GetDIBits
      (
         hDC,
         hBitmap,
         0,
         ( UINT ) bi.biHeight,
         ( LPSTR ) lpbi + ( WORD ) lpbi->biSize + ( GetDIBColors( ( LPSTR ) lpbi ) * sizeof( RGBTRIPLE ) ),
         ( LPBITMAPINFO ) lpbi,
         DIB_RGB_COLORS
      ) == 0
   )
   {
      GlobalFree( hDIB );
      hDIB = NULL;
      SelectPalette( hDC, hPal, TRUE );
      RealizePalette( hDC );
      ReleaseDC( NULL, hDC );
      return hDIB;
   }

   bi = *lpbi;

   GlobalUnlock( hDIB );
   SelectPalette( hDC, hPal, TRUE );
   RealizePalette( hDC );
   ReleaseDC( NULL, hDC );

   return hDIB;
}

WORD GetDIBColors( LPSTR lpDIB )
{
   WORD wBitCount = ( ( LPBITMAPCOREHEADER ) lpDIB )->bcBitCount;

   return wBitCount;
}

// HMG 1.0 Experimental Build 9a
// Author: J.Kubica <kubica@wssk.wroc.pl>

/*
 * Function GetBitmapSize() - modified by P.Chornyj
 * for Harbour MiniGUI 1.3 Extended (Build 33)
 */
HB_FUNC( GETBITMAPSIZE )
{
   PHB_ITEM aResult = hb_itemArrayNew( 3 );
   HBITMAP  hBitmap;
   BITMAP   bm;

   if( GetObjectType( ( HGDIOBJ ) HB_PARNL( 1 ) ) == OBJ_BITMAP )
   {
      hBitmap = ( HBITMAP ) HB_PARNL( 1 );
      GetObject( hBitmap, sizeof( bm ), &bm );

      HB_arraySetNL( aResult, 1, bm.bmWidth );
      HB_arraySetNL( aResult, 2, bm.bmHeight );
      HB_arraySetNL( aResult, 3, bm.bmBitsPixel );
   }
   else
   {
      HB_arraySetNL( aResult, 1, 0 );
      HB_arraySetNL( aResult, 2, 0 );
      HB_arraySetNL( aResult, 3, 4 );
   }

   hb_itemReturnRelease( aResult );
}

/*
   Harbour MiniGUI 1.3 Extended (Build 33)
   Author P.Chornyj

   Function BitmapSize()
   ---------------------
   Syntax
     BitmapSize( cBitmap ) --> aTarget

   Arguments
     <cBitmap> is the name of the bitmap file or resource

   Returns
     BitmapSize() returns an array has the following structure:
     ----------------------------------------------------------
     Position     Metasymbol     i_bitmap.ch
     ----------------------------------------------------------
     1            nWidth         BM_WIDTH
     2            nHeight        BM_HEIGHT
     3            nBitsPerPixel  BM_BITSPIXEL
     ----------------------------------------------------------
     If file or resource are not found or corrupt,
     BitmapSize returns an array {0, 0, 4} for compatibility
 */
HB_FUNC( BITMAPSIZE )
{
   PHB_ITEM aResult = hb_itemArrayNew( 3 );
   HBITMAP  hBitmap;
   BITMAP   bm;

   hBitmap = ( HBITMAP ) LoadImage( 0, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );

   if( hBitmap == NULL )
      hBitmap = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

   if( hBitmap != NULL )
   {
      GetObject( hBitmap, sizeof( BITMAP ), &bm );

      HB_arraySetNL( aResult, 1, bm.bmWidth );
      HB_arraySetNL( aResult, 2, bm.bmHeight );
      HB_arraySetNL( aResult, 3, bm.bmBitsPixel );

      DeleteObject( hBitmap );
   }
   else
   {
      HB_arraySetNL( aResult, 1, 0 );
      HB_arraySetNL( aResult, 2, 0 );
      HB_arraySetNL( aResult, 3, 4 );
   }

   hb_itemReturnRelease( aResult );
}

HB_FUNC( GETICONSIZE )
{
   PHB_ITEM aArray = hb_itemArrayNew( 2 );
   BITMAP   bm;
   HICON    hIcon = ( HICON ) HB_PARNL( 1 );
   ICONINFO sIconInfo;

   if( hIcon )
      if( GetIconInfo( hIcon, &sIconInfo ) )
      {
         GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), &bm );
         HB_arraySetNL( aArray, 1, bm.bmWidth );
         HB_arraySetNL( aArray, 2, bm.bmHeight );

         DeleteObject( sIconInfo.hbmMask );
         DeleteObject( sIconInfo.hbmColor );

         hb_itemReturnRelease( aArray );
      }
}

HBITMAP Icon2Bmp( HICON hIcon )
{
   HDC      hDC    = GetDC( NULL );
   HDC      hMemDC = CreateCompatibleDC( hDC );
   ICONINFO icon;
   BITMAP   bitmap;
   HBITMAP  hBmp;
   HBITMAP  hOldBmp;

   GetIconInfo( ( HICON ) hIcon, &icon );
   GetObject( icon.hbmColor, sizeof( BITMAP ), ( LPVOID ) &bitmap );
   hBmp    = CreateCompatibleBitmap( hDC, bitmap.bmWidth, bitmap.bmHeight );
   hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBmp );

   PatBlt( hMemDC, 0, 0, bitmap.bmWidth, bitmap.bmHeight, WHITENESS );
   DrawIconEx( hMemDC, 0, 0, hIcon, bitmap.bmWidth, bitmap.bmHeight, 0, NULL, DI_NORMAL );
   SelectObject( hMemDC, hOldBmp );
   DeleteDC( hMemDC );
   DeleteObject( icon.hbmMask );
   DeleteObject( icon.hbmColor );

   ReleaseDC( NULL, hDC );

   return hBmp;
}

/*
 * Function IconMask2Bmp converts icon mask to bitmap
 */
HBITMAP IconMask2Bmp( HICON hIcon )
{
   HDC      hDC    = GetDC( 0 );
   HDC      hMemDC = CreateCompatibleDC( hDC );
   ICONINFO icon;
   BITMAP   bitmap;
   HBITMAP  hBmp;
   HBITMAP  hOldBmp;

   GetIconInfo( ( HICON ) hIcon, &icon );
   GetObject( icon.hbmColor, sizeof( BITMAP ), ( LPVOID ) &bitmap );
   hBmp    = CreateCompatibleBitmap( hDC, bitmap.bmWidth, bitmap.bmHeight );
   hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBmp );

   PatBlt( hMemDC, 0, 0, bitmap.bmWidth, bitmap.bmHeight, WHITENESS );
   DrawIconEx( hMemDC, 0, 0, hIcon, bitmap.bmWidth, bitmap.bmHeight, 0, NULL, DI_MASK );
   SelectObject( hMemDC, hOldBmp );
   DeleteDC( hMemDC );
   DeleteObject( icon.hbmMask );
   DeleteObject( icon.hbmColor );
   ReleaseDC( 0, hDC );
   return hBmp;
}

/*
 * DrawGlyph(HDC hDC, int x, int y, int dx, int dy, HBITMAP hBmp, COLORREF rgbTransparent, BOOL disabled, BOOL stretched)
 * (c) Andy Wos <andywos@unwired.com.au>
 */
HB_FUNC( DRAWGLYPH )
{
   HDC      hDC  = ( HDC ) HB_PARNL( 1 );
   int      x    = hb_parni( 2 );
   int      y    = hb_parni( 3 );
   int      dx   = hb_parni( 4 );
   int      dy   = hb_parni( 5 );
   HBITMAP  hBmp = ( HBITMAP ) HB_PARNL( 6 );
   COLORREF rgbTransparent = RGB( 255, 255, 255 );
   BOOL     disabled       = hb_parl( 8 );
   BOOL     stretched      = HB_ISNIL( 9 ) ? FALSE : hb_parl( 9 );
   BOOL     bHasBkColor    = ! HB_ISNIL( 7 );

   HDC hDCMem;
   HDC hDCMask;
   HDC hDCStretch;
   HDC hDCNoBlink;

   HBITMAP  hBmpDefault;
   HBITMAP  hBmpTransMask;
   HBITMAP  hBmpStretch = NULL;
   HBITMAP  hBmpIcon    = NULL;
   HBITMAP  hBmpNoBlink;
   HBITMAP  hBmpNoBlinkOld;
   BITMAP   bitmap;
   ICONINFO icon;
   HBRUSH   hBr;
   HBRUSH   hOld;

   if( bHasBkColor )
      rgbTransparent = ( COLORREF ) hb_parnl( 7 );

   // is it a bitmap?
   if( ( UINT ) GetObject( hBmp, sizeof( BITMAP ), ( LPVOID ) &bitmap ) != sizeof( BITMAP ) )
   {
      // is it an icon?
      if( ! GetIconInfo( ( HICON ) hBmp, &icon ) )
         return;

      DeleteObject( icon.hbmMask );
      DeleteObject( icon.hbmColor );

      if( ! icon.fIcon )
         return;

      if( ! disabled && ! stretched )
      {
         // just simply draw it - nothing to do
         // (API is faster and the transparent colour is more accurate)
         DrawIconEx( hDC, x, y, ( HICON ) hBmp, dx, dy, 0, NULL, DI_NORMAL );
         return;
      }
      else
      {
         if( ! stretched )
            // convert icon to bitmap mask.
            hBmp = IconMask2Bmp( ( HICON ) hBmp );
         else
            // convert icon to bitmap.
            hBmp = Icon2Bmp( ( HICON ) hBmp );

         hBmpIcon = hBmp;

         // ignore colour given by the user, if any
         rgbTransparent = RGB( 255, 255, 255 );
         bHasBkColor    = TRUE;
         GetObject( hBmp, sizeof( BITMAP ), ( LPVOID ) &bitmap );
      }
   }

   hDCMem = CreateCompatibleDC( hDC );

   if( stretched )
   {
      dx = ( dx > 0 ? dx : bitmap.bmWidth );
      dy = ( dy > 0 ? dy : bitmap.bmHeight );
      hBmpStretch = CreateCompatibleBitmap( hDC, dx, dy );
      SelectObject( hDCMem, hBmpStretch );
      hDCStretch  = CreateCompatibleDC( hDC );
      hBmpDefault = ( HBITMAP ) SelectObject( hDCStretch, hBmp );
      StretchBlt( hDCMem, 0, 0, dx, dy, hDCStretch, 0, 0, bitmap.bmWidth, bitmap.bmHeight, SRCCOPY );
      SelectObject( hDCStretch, hBmpDefault );
      DeleteDC( hDCStretch );
   }
   else
   {
      dx = ( dx > 0 ? HB_MIN( dx, bitmap.bmWidth ) : bitmap.bmWidth );
      dy = ( dy > 0 ? HB_MIN( dy, bitmap.bmHeight ) : bitmap.bmHeight );
      hBmpDefault = ( HBITMAP ) SelectObject( hDCMem, hBmp );
   }

   // prime the "no blink" device context
   hDCNoBlink     = CreateCompatibleDC( hDC );
   hBmpNoBlink    = CreateCompatibleBitmap( hDC, dx, dy );
   hBmpNoBlinkOld = ( HBITMAP ) SelectObject( hDCNoBlink, hBmpNoBlink );
   BitBlt( hDCNoBlink, 0, 0, dx, dy, hDC, x, y, SRCCOPY );
   SetBkColor( hDCNoBlink, RGB( 255, 255, 255 ) );    //White
   SetTextColor( hDCNoBlink, RGB( 0, 0, 0 ) );        //Black

   // was background colour given?
   // no? get the color automatically
   if( ! bHasBkColor )
      rgbTransparent = GetPixel( hDCMem, 0, 0 );

   // build mask based on transparent color.
   hDCMask       = CreateCompatibleDC( hDCNoBlink );
   hBmpTransMask = CreateBitmap( dx, dy, 1, 1, NULL );
   SelectObject( hDCMask, hBmpTransMask );
   SetBkColor( hDCMem, rgbTransparent );
   BitBlt( hDCMask, 0, 0, dx, dy, hDCMem, 0, 0, SRCCOPY );

   if( disabled )
   {
      hBr  = CreateSolidBrush( GetSysColor( COLOR_BTNHIGHLIGHT ) );
      hOld = ( HBRUSH ) SelectObject( hDCNoBlink, hBr );
      BitBlt( hDCNoBlink, 1, 1, dx - 0, dy - 0, hDCMask, 0, 0, 12060490 );
      SelectObject( hDCNoBlink, hOld );
      DeleteObject( hBr );
      hBr  = CreateSolidBrush( GetSysColor( COLOR_BTNSHADOW ) );
      hOld = ( HBRUSH ) SelectObject( hDCNoBlink, hBr );
      BitBlt( hDCNoBlink, 0, 0, dx - 0, dy - 0, hDCMask, 0, 0, 12060490 );
      SelectObject( hDCNoBlink, hOld );
      DeleteObject( hBr );
   }
   else
   {
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMem, 0, 0, SRCINVERT );
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMask, 0, 0, SRCAND );
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMem, 0, 0, SRCINVERT );
   }

   BitBlt( hDC, x, y, dx, dy, hDCNoBlink, 0, 0, SRCCOPY );

   // clean up
   SelectObject( hDCMem, hBmpDefault );
   SelectObject( hDCMask, hBmpDefault );
   SelectObject( hDCNoBlink, hBmpNoBlinkOld );
   DeleteDC( hDCMem );
   DeleteDC( hDCMask );
   DeleteDC( hDCNoBlink );
   DeleteObject( hBmpTransMask );
   DeleteObject( hBmpNoBlink );
   if( stretched )
      DeleteObject( hBmpStretch );

   if( hBmpIcon )
      DeleteObject( hBmpIcon );

}

/*
 * Function DRAWGLYPHMASK create and draw bimap mask - first pixel is treated as transparent color
 * Based upon function DrawGlyph by Andy Wos <andywos@unwired.com.au>
 */
HB_FUNC( DRAWGLYPHMASK )
{
   HDC      hDC  = ( HDC ) HB_PARNL( 1 );
   int      dx   = hb_parni( 4 );
   int      dy   = hb_parni( 5 );
   HBITMAP  hBmp = ( HBITMAP ) HB_PARNL( 6 );
   COLORREF rgbTransparent;
   HWND     hwnd = ( HWND ) HB_PARNL( 10 );

   HDC hDCMem;
   HDC hDCMask;

   HBITMAP hBmpDefault;
   HBITMAP hBmpTransMask;

   BITMAP bitmap;

   GetObject( hBmp, sizeof( BITMAP ), ( LPVOID ) &bitmap );

   SetBkColor( hDC, RGB( 255, 255, 255 ) );           //White
   SetTextColor( hDC, RGB( 0, 0, 0 ) );               //Black
   hDCMem = CreateCompatibleDC( hDC );

   dx = ( dx > 0 ? HB_MIN( dx, bitmap.bmWidth ) : bitmap.bmWidth );
   dy = ( dy > 0 ? HB_MIN( dy, bitmap.bmHeight ) : bitmap.bmHeight );
   hBmpDefault    = ( HBITMAP ) SelectObject( hDCMem, hBmp );
   rgbTransparent = GetPixel( hDCMem, 0, 0 );

   // build mask based on transparent color
   hDCMask       = CreateCompatibleDC( hDC );
   hBmpTransMask = CreateBitmap( dx, dy, 1, 1, NULL );

   SelectObject( hDCMask, hBmpTransMask );
   SetBkColor( hDCMem, rgbTransparent );
   BitBlt( hDCMask, 0, 0, dx, dy, hDCMem, 0, 0, SRCCOPY );

   // handle to bitmaped button mask
   if( hwnd != NULL )
      SendMessage( hwnd, ( UINT ) BM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hBmpTransMask );

   SelectObject( hDCMem, hBmpDefault );
   SelectObject( hDCMask, hBmpDefault );
   DeleteDC( hDCMem );
   DeleteDC( hDCMask );

}

/*
   Harbour MiniGUI 1.3 Extended (Build 33)
   Author P.Chornyj

   Function LoadBitmap()
   ---------------------
   Syntax
     LoadBitmap( cBitmap ) --> nHandle

   Arguments
     <cBitmap> is the name of resource

   Returns
     If the function succeeds,
     the return value is the handle to the specified bitmap.
     If the function fails, the return value is 0.
 */
HB_FUNC( LOADBITMAP )
{
   HBITMAP hBitmap;

   hBitmap = ( HBITMAP ) LoadImage( g_hInstance, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );

   if( hBitmap == NULL )
      hBitmap = ( HBITMAP ) LoadImage( 0, hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   HB_RETNL( ( LONG_PTR ) hBitmap );
}

/*
 * DrawGlyph for C-level
 *
 * Harbour MiniGUI 1.3 Extended (Build 34)
 */
VOID DrawGlyph( HDC hDC, int x, int y, int dx, int dy, HBITMAP hBmp, COLORREF rgbTransparent, BOOL disabled, BOOL stretched )
{
   HDC      hDCMem, hDCMask, hDCStretch, hDCNoBlink;
   HBITMAP  hBmpDefault, hBmpTransMask, hBmpStretch = NULL;
   HBITMAP  hBmpIcon = NULL;
   HBITMAP  hBmpNoBlink, hBmpNoBlinkOld;
   BITMAP   bitmap;
   ICONINFO icon;
   HBRUSH   hBr, hOld;
   BOOL     bHasBkColor = ! HB_ISNIL( 7 );

   // is it a bitmap?
   if( ( UINT ) GetObject( hBmp, sizeof( BITMAP ), ( LPVOID ) &bitmap ) != sizeof( BITMAP ) )
   {
      // is it an icon?
      if( ! GetIconInfo( ( HICON ) hBmp, &icon ) )
         return;

      DeleteObject( icon.hbmMask );
      DeleteObject( icon.hbmColor );

      if( ! icon.fIcon )
         return;

      if( ! disabled && ! stretched )
      {
         DrawIconEx( hDC, x, y, ( HICON ) hBmp, dx, dy, 0, NULL, DI_NORMAL );
         return;
      }
      else
      {
         if( ! stretched )
            // convert icon to bitmap mask.
            hBmp = IconMask2Bmp( ( HICON ) hBmp );
         else
            // convert icon to bitmap.
            hBmp = Icon2Bmp( ( HICON ) hBmp );

         hBmpIcon = hBmp;

         // ignore colour given by the user, if any
         rgbTransparent = RGB( 255, 255, 255 );
         bHasBkColor    = TRUE;
         GetObject( hBmp, sizeof( BITMAP ), ( LPVOID ) &bitmap );
      }
   }

   hDCMem = CreateCompatibleDC( hDC );

   if( stretched )
   {
      dx = ( dx > 0 ? dx : bitmap.bmWidth );
      dy = ( dy > 0 ? dy : bitmap.bmHeight );

      hBmpStretch = CreateCompatibleBitmap( hDC, dx, dy );
      SelectObject( hDCMem, hBmpStretch );
      hDCStretch  = CreateCompatibleDC( hDC );
      hBmpDefault = ( HBITMAP ) SelectObject( hDCStretch, hBmp );

      StretchBlt( hDCMem, 0, 0, dx, dy, hDCStretch, 0, 0, bitmap.bmWidth, bitmap.bmHeight, SRCCOPY );

      SelectObject( hDCStretch, hBmpDefault );
      DeleteDC( hDCStretch );
   }
   else
   {
      dx = ( dx > 0 ? HB_MIN( dx, bitmap.bmWidth ) : bitmap.bmWidth );
      dy = ( dy > 0 ? HB_MIN( dy, bitmap.bmHeight ) : bitmap.bmHeight );
      hBmpDefault = ( HBITMAP ) SelectObject( hDCMem, hBmp );
   }

   // prime the "no blink" device context
   hDCNoBlink     = CreateCompatibleDC( hDC );
   hBmpNoBlink    = CreateCompatibleBitmap( hDC, dx, dy );
   hBmpNoBlinkOld = ( HBITMAP ) SelectObject( hDCNoBlink, hBmpNoBlink );
   BitBlt( hDCNoBlink, 0, 0, dx, dy, hDC, x, y, SRCCOPY );
   SetBkColor( hDCNoBlink, RGB( 255, 255, 255 ) );
   SetTextColor( hDCNoBlink, RGB( 0, 0, 0 ) );

   // was background colour given?
   // no? get the color automatically
   if( ! bHasBkColor )
      rgbTransparent = GetPixel( hDCMem, 0, 0 );

   // build mask based on transparent color.
   hDCMask       = CreateCompatibleDC( hDCNoBlink );
   hBmpTransMask = CreateBitmap( dx, dy, 1, 1, NULL );
   SelectObject( hDCMask, hBmpTransMask );
   SetBkColor( hDCMem, rgbTransparent );
   BitBlt( hDCMask, 0, 0, dx, dy, hDCMem, 0, 0, SRCCOPY );

   if( disabled )
   {
      hBr  = CreateSolidBrush( GetSysColor( COLOR_BTNHIGHLIGHT ) );
      hOld = ( HBRUSH ) SelectObject( hDCNoBlink, hBr );
      BitBlt( hDCNoBlink, 1, 1, dx - 0, dy - 0, hDCMask, 0, 0, 12060490 );
      SelectObject( hDCNoBlink, hOld );
      DeleteObject( hBr );

      hBr  = CreateSolidBrush( GetSysColor( COLOR_BTNSHADOW ) );
      hOld = ( HBRUSH ) SelectObject( hDCNoBlink, hBr );
      BitBlt( hDCNoBlink, 0, 0, dx - 0, dy - 0, hDCMask, 0, 0, 12060490 );
      SelectObject( hDCNoBlink, hOld );
      DeleteObject( hBr );
   }
   else
   {
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMem, 0, 0, SRCINVERT );
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMask, 0, 0, SRCAND );
      BitBlt( hDCNoBlink, 0, 0, dx, dy, hDCMem, 0, 0, SRCINVERT );
   }

   BitBlt( hDC, x, y, dx, dy, hDCNoBlink, 0, 0, SRCCOPY );

   // clean up
   SelectObject( hDCMem, hBmpDefault );
   SelectObject( hDCMask, hBmpDefault );
   SelectObject( hDCNoBlink, hBmpNoBlinkOld );

   DeleteDC( hDCMem );
   DeleteDC( hDCMask );
   DeleteDC( hDCNoBlink );

   DeleteObject( hBmpTransMask );
   DeleteObject( hBmpNoBlink );

   if( stretched )
      DeleteObject( hBmpStretch );

   if( hBmpIcon )
      DeleteObject( hBmpIcon );
}

/*
 * Function GetImageSize()
 * Author: Andi Jahja <harbour@cbn.net.id>
 */
BOOL GetImageSize( const char * fn, int * x, int * y )
{
   unsigned char buf[ 24 ];
   long          len;

   FILE * f = hb_fopen( fn, "rb" );

   if( ! f )
      return FALSE;

   fseek( f, 0, SEEK_END );

   len = ftell( f );

   fseek( f, 0, SEEK_SET );

   if( len < 24 )
   {
      fclose( f );
      return FALSE;
   }

   // Strategy:
   // reading GIF dimensions requires the first 10 bytes of the file
   // reading PNG dimensions requires the first 24 bytes of the file
   // reading JPEG dimensions requires scanning through jpeg chunks
   // In all formats, the file is at least 24 bytes big, so we'll read
   // that always
   fread( buf, 1, 24, f );

   // For JPEGs, we need to read the first 12 bytes of each chunk.
   // We'll read those 12 bytes at buf+2...buf+14, i.e. overwriting
   // the existing buf.
   if( buf[ 0 ] == 0xFF && buf[ 1 ] == 0xD8 && buf[ 2 ] == 0xFF && buf[ 3 ] == 0xE0 &&
       buf[ 6 ] == 'J' && buf[ 7 ] == 'F' && buf[ 8 ] == 'I' && buf[ 9 ] == 'F' )
   {
      long pos = 2;
      while( buf[ 2 ] == 0xFF )
      {
         if( buf[ 3 ] == 0xC0 || buf[ 3 ] == 0xC1 || buf[ 3 ] == 0xC2 ||
             buf[ 3 ] == 0xC3 || buf[ 3 ] == 0xC9 || buf[ 3 ] == 0xCA ||
             buf[ 3 ] == 0xCB )
            break;
         pos += 2 + ( buf[ 4 ] << 8 ) + buf[ 5 ];
         if( pos + 12 > len )
            break;
         fseek( f, pos, SEEK_SET );
         fread( buf + 2, 1, 12, f );
      }
   }

   fclose( f );

   // JPEG: (first two bytes of buf are first two bytes of the jpeg
   // file; rest of buf is the DCT frame
   if( buf[ 0 ] == 0xFF && buf[ 1 ] == 0xD8 && buf[ 2 ] == 0xFF )
   {
      *y = ( buf[ 7 ] << 8 ) + buf[ 8 ];
      *x = ( buf[ 9 ] << 8 ) + buf[ 10 ];
      return TRUE;
   }

   // GIF: first three bytes say "GIF", next three give version
   // number. Then dimensions
   if( buf[ 0 ] == 'G' && buf[ 1 ] == 'I' && buf[ 2 ] == 'F' )
   {
      *x = buf[ 6 ] + ( buf[ 7 ] << 8 );
      *y = buf[ 8 ] + ( buf[ 9 ] << 8 );
      return TRUE;
   }

   // PNG: the first frame is by definition an IHDR frame, which gives
   // dimensions
   if( buf[ 0 ] == 0x89 && buf[ 1 ] == 'P' && buf[ 2 ] == 'N' && buf[ 3 ] == 'G' &&
       buf[ 4 ] == 0x0D && buf[ 5 ] == 0x0A && buf[ 6 ] == 0x1A && buf[ 7 ] == 0x0A
       && buf[ 12 ] == 'I' && buf[ 13 ] == 'H' && buf[ 14 ] == 'D' &&
       buf[ 15 ] == 'R' )
   {
      *x = ( buf[ 16 ] << 24 ) + ( buf[ 17 ] << 16 ) + ( buf[ 18 ] << 8 ) + ( buf[ 19 ] << 0 );
      *y = ( buf[ 20 ] << 24 ) + ( buf[ 21 ] << 16 ) + ( buf[ 22 ] << 8 ) + ( buf[ 23 ] << 0 );
      return TRUE;
   }

   return FALSE;
}

/*
 * Syntax: hb_GetImageSize( cPicFile )
 * Parameter: cPicFile = graphic file (JPG, GIF, PNG)
 * Return: 2 dim array -> array[1] = width, array[2] = height
 */
HB_FUNC( HB_GETIMAGESIZE )
{
   int x = 0, y = 0;

   GetImageSize( hb_parcx( 1 ), &x, &y );

   hb_reta( 2 );
   HB_STORNI( x, -1, 1 );
   HB_STORNI( y, -1, 2 );
}

HB_FUNC( LOADICONBYNAME )
{
   HICON hIcon;

   hIcon = ( HICON ) LoadImage( g_hInstance, hb_parc( 1 ), IMAGE_ICON, 0, 0, LR_DEFAULTCOLOR );

   if( hIcon == NULL )
      hIcon = ( HICON ) LoadImage( 0, hb_parc( 1 ), IMAGE_ICON, 0, 0, LR_LOADFROMFILE | LR_DEFAULTCOLOR );

   HB_RETNL( ( LONG_PTR ) hIcon );
}

HB_FUNC( DRAWICONEX )
{
   HWND   hwnd  = ( HWND ) HB_PARNL( 1 );
   HICON  hIcon = ( HICON ) HB_PARNL( 4 );
   HDC    hdc   = GetDC( hwnd );
   HBRUSH hbrFlickerFreeDraw = CreateSolidBrush( hb_parni( 7 ) );

   hb_retl( DrawIconEx( hdc, hb_parni( 2 ), hb_parni( 3 ), hIcon, hb_parni( 5 ), hb_parni( 6 ), 0, hbrFlickerFreeDraw, DI_NORMAL ) );

   DeleteObject( hbrFlickerFreeDraw );
   DestroyIcon( hIcon );

   ReleaseDC( hwnd, hdc );
}
