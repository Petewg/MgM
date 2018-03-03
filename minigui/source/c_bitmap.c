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

HANDLE   DibFromBitmap( HBITMAP, HPALETTE );
WORD     GetDIBColors( LPSTR );

HINSTANCE GetResources( void );

HB_FUNC( SAVEWINDOWBYHANDLE )
{
   HWND     hWnd = ( HWND ) HB_PARNL( 1 );
   HDC      hDC  = GetDC( hWnd );
   HDC      hMemDC;
   RECT     rc;
   HBITMAP  hBitmap;
   HBITMAP  hOldBmp;
   HPALETTE hPal = 0;
   HANDLE   hDIB;
   const char *       File   = hb_parc( 2 );
   int                top    = hb_parni( 3 );
   int                left   = hb_parni( 4 );
   int                bottom = hb_parni( 5 );
   int                right  = hb_parni( 6 );
   BITMAPFILEHEADER   bmfHdr;
   LPBITMAPINFOHEADER lpBI;
   HANDLE             filehandle;
   DWORD              dwDIBSize;
   DWORD              dwWritten;
   DWORD              dwBmBitsSize;

   if( top != -1 && left != -1 && bottom != -1 && right != -1 )
   {
      rc.top    = top;
      rc.left   = left;
      rc.bottom = bottom;
      rc.right  = right;
   }
   else
   {
      GetClientRect( hWnd, &rc );
   }

   hMemDC  = CreateCompatibleDC( hDC );
   hBitmap = CreateCompatibleBitmap( hDC, rc.right - rc.left, rc.bottom - rc.top );
   hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );
   BitBlt( hMemDC, 0, 0, rc.right - rc.left, rc.bottom - rc.top, hDC, rc.top, rc.left, SRCCOPY );
   SelectObject( hMemDC, hOldBmp );
   hDIB = DibFromBitmap( hBitmap, hPal );

   filehandle = CreateFile( File, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL );

   lpBI = ( LPBITMAPINFOHEADER ) GlobalLock( hDIB );
   if( lpBI && lpBI->biSize == sizeof( BITMAPINFOHEADER ) )
   {
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
   }

   GlobalUnlock( hDIB );
   CloseHandle( filehandle );

   DeleteObject( hBitmap );
   DeleteDC( hMemDC );
   GlobalFree( hDIB );
   ReleaseDC( hWnd, hDC );
}

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
   hDIB = DibFromBitmap( hBitmap, hPal );

   filehandle = CreateFile( File, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL );

   lpBI = ( LPBITMAPINFOHEADER ) GlobalLock( hDIB );
   if( lpBI && lpBI->biSize == sizeof( BITMAPINFOHEADER ) )
   {
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
   }

   GlobalUnlock( hDIB );
   CloseHandle( filehandle );

   DeleteDC( hMemDC );
   GlobalFree( hDIB );
   ReleaseDC( hWnd, hDC );
}

WORD DibNumColors( VOID FAR * pv )
{
   int bits;
   LPBITMAPINFOHEADER lpbi;
   LPBITMAPCOREHEADER lpbc;

   lpbi = ( ( LPBITMAPINFOHEADER ) pv );
   lpbc = ( ( LPBITMAPCOREHEADER ) pv );

   /*  With the BITMAPINFO format headers, the size of the palette
    *  is in biClrUsed, whereas in the BITMAPCORE - style headers, it
    *  is dependent on the bits per pixel ( = 2 raised to the power of
    *  bits/pixel).
    */
   if( lpbi->biSize != sizeof( BITMAPCOREHEADER ) )
   {
      if( lpbi->biClrUsed != 0 )
         return ( WORD ) lpbi->biClrUsed;
      bits = lpbi->biBitCount;
   }
   else
      bits = lpbc->bcBitCount;

   switch( bits )
   {
      case 1:
         return 2;
      case 4:
         return 16;
      case 8:
         return 256;
      default:
         /* A 24 bitcount DIB has no color table */
         return 0;
   }
}

static WORD PaletteSize( VOID FAR * pv )
{
   LPBITMAPINFOHEADER lpbi;
   WORD NumColors;

   lpbi = ( LPBITMAPINFOHEADER ) pv;

   NumColors = DibNumColors( lpbi );

   if( lpbi->biSize == sizeof( BITMAPCOREHEADER ) )
      return ( WORD ) ( NumColors * sizeof( RGBTRIPLE ) );
   else
      return ( WORD ) ( NumColors * sizeof( RGBQUAD ) );
}

#define WIDTHBYTES( i )  ( ( i + 31 ) / 32 * 4 )

HANDLE DibFromBitmap( HBITMAP hbm, HPALETTE hpal )
{
   BITMAP bm;
   BITMAPINFOHEADER       bi;
   BITMAPINFOHEADER FAR * lpbi;
   DWORD  dwLen;
   WORD   biBits;
   HANDLE hdib;
   HANDLE h;
   HDC    hdc;

   if( ! hbm )
      return NULL;

   if( hpal == NULL )
      hpal = ( HPALETTE ) GetStockObject( DEFAULT_PALETTE );

   GetObject( hbm, sizeof( bm ), ( LPSTR ) &bm );

   biBits = ( WORD ) ( bm.bmPlanes * bm.bmBitsPixel );

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

   dwLen = bi.biSize + PaletteSize( &bi );

   hdc  = GetDC( NULL );
   hpal = SelectPalette( hdc, hpal, FALSE );
   RealizePalette( hdc );

   hdib = GlobalAlloc( GHND, dwLen );

   if( ! hdib )
   {
      SelectPalette( hdc, hpal, FALSE );
      ReleaseDC( NULL, hdc );
      return NULL;
   }

   lpbi = ( LPBITMAPINFOHEADER ) GlobalLock( hdib );

   memcpy( ( char * ) lpbi, ( char * ) &bi, sizeof( bi ) );

   /*  call GetDIBits with a NULL lpBits param, so it will calculate the
    *  biSizeImage field for us
    */
   GetDIBits( hdc, hbm, 0L, ( DWORD ) bi.biHeight,
              ( LPBYTE ) NULL, ( LPBITMAPINFO ) lpbi, ( DWORD ) DIB_RGB_COLORS );

   memcpy( ( char * ) &bi, ( char * ) lpbi, sizeof( bi ) );
   GlobalUnlock( hdib );

   /* If the driver did not fill in the biSizeImage field, make one up */
   if( bi.biSizeImage == 0 )
   {
      bi.biSizeImage = WIDTHBYTES( ( DWORD ) bm.bmWidth * biBits ) * bm.bmHeight;
   }

   /*  realloc the buffer big enough to hold all the bits */
   dwLen = bi.biSize + PaletteSize( &bi ) + bi.biSizeImage;

   h = GlobalReAlloc( hdib, dwLen, 0 );
   if( h )
      hdib = h;
   else
   {
      GlobalFree( hdib );

      SelectPalette( hdc, hpal, FALSE );
      ReleaseDC( NULL, hdc );
      return NULL;
   }

   /*  call GetDIBits with a NON-NULL lpBits param, and actualy get the
    *  bits this time
    */
   lpbi = ( LPBITMAPINFOHEADER ) GlobalLock( hdib );

   if( GetDIBits( hdc, hbm, 0L, ( DWORD ) bi.biHeight,
                  ( LPBYTE ) lpbi + ( WORD ) lpbi->biSize + PaletteSize( lpbi ),
                  ( LPBITMAPINFO ) lpbi, ( DWORD ) DIB_RGB_COLORS ) == 0 )
   {
      GlobalUnlock( hdib );

      SelectPalette( hdc, hpal, FALSE );
      ReleaseDC( NULL, hdc );
      return NULL;
   }

   GlobalUnlock( hdib );
   SelectPalette( hdc, hpal, FALSE );
   ReleaseDC( NULL, hdc );

   return hdib;
}

WORD GetDIBColors( LPSTR lpDIB )
{
   WORD wBitCount = ( ( LPBITMAPCOREHEADER ) lpDIB )->bcBitCount;

   return wBitCount;
}

HB_FUNC( C_HASALPHA ) // hBitmap --> lYesNo
{
   HANDLE hDib;
   BOOL   bAlphaChannel = FALSE;
   HDC    hDC = GetDC( GetDesktopWindow() );

   if( GetDeviceCaps( hDC, BITSPIXEL ) < 32 )
   {
      ReleaseDC( GetDesktopWindow(), hDC );
      hb_retl( FALSE );
      return;
   }

   ReleaseDC( GetDesktopWindow(), hDC );

   hDib = DibFromBitmap( ( HBITMAP ) HB_PARNL( 1 ), ( HPALETTE ) NULL );

   if( hDib )
   {
      LPBITMAPINFO    lpbmi = ( LPBITMAPINFO ) GlobalLock( hDib );
      unsigned char * uc    = ( LPBYTE ) lpbmi + ( WORD ) lpbmi->bmiHeader.biSize + PaletteSize( lpbmi );
      unsigned long   ul;

      for( ul = 0; ul < lpbmi->bmiHeader.biSizeImage && ! bAlphaChannel; ul += 4 )
         if( uc[ ul + 3 ] != 0 )
            bAlphaChannel = TRUE;

      GlobalUnlock( hDib );
      GlobalFree( hDib );
   }

   hb_retl( bAlphaChannel );
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

   hBitmap = ( HBITMAP ) LoadImage( GetResources(), hb_parc( 1 ), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );

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

HB_FUNC_TRANSLATE( HB_GETIMAGESIZE, HMG_GETIMAGESIZE )
/*
 * Syntax: hmg_GetImageSize( cPicFile )
 * Parameter: cPicFile = graphic file (JPG, GIF, PNG)
 * Return: 2 dim array -> array[1] = width, array[2] = height
 */
HB_FUNC( HMG_GETIMAGESIZE )
{
   int x = 0, y = 0;

   GetImageSize( hb_parcx( 1 ), &x, &y );

   hb_reta( 2 );
   HB_STORNI( x, -1, 1 );
   HB_STORNI( y, -1, 2 );
}

/*
   Harbour MiniGUI 1.3 Extended (Build 33)
   Author P.Chornyj

   Function BitmapSize()
   ---------------------
   Syntax
     BitmapSize( xBitmap ) --> aTarget

   Arguments
     <xBitmap> is the NAME of the bitmap file or resource
     or
     <xBitmap> is the handle to OBJ_BITMAP

   Returns
     BitmapSize() returns an array has the following structure:
     ----------------------------------------------------------
     Position     Metasymbol     i_bitmap.ch
     ----------------------------------------------------------
     1            nWidth         BM_WIDTH
     2            nHeight        BM_HEIGHT
     3            nBitsPerPixel  BM_BITSPIXEL
     ----------------------------------------------------------
     If file or resource are not found or corrupt, or is not OBJ_BITMAP,
     BitmapSize returns an array {0, 0, 4} for compatibility
 */

static void _arraySet( PHB_ITEM pArray, int Width, int Height, int BitsPixel )
{
   HB_arraySetNL( pArray, 1, Width );
   HB_arraySetNL( pArray, 2, Height );
   HB_arraySetNL( pArray, 3, BitsPixel );
}

HB_FUNC( GETBITMAPSIZE )
{
   PHB_ITEM pResult = hb_itemArrayNew( 3 );
   HBITMAP  hBitmap = NULL;
   BOOL     bDelete = TRUE;

   if( hb_parclen( 1 ) > 0 )
   {
      const char * pszName = hb_parc( 1 );

      hBitmap = ( HBITMAP ) LoadImage( GetResources(), pszName, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

      if( hBitmap == NULL )
         hBitmap = ( HBITMAP ) LoadImage( 0, pszName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );
   }
   else
   {
      if( GetObjectType( ( HGDIOBJ ) HB_PARNL( 1 ) ) == OBJ_BITMAP )
      {
         hBitmap = ( HBITMAP ) HB_PARNL( 1 );
         bDelete = FALSE;
      }
   }

   _arraySet( pResult, 0, 0, 4 );

   if( hBitmap != NULL )
   {
      BITMAP bm;

      if( GetObject( hBitmap, sizeof( BITMAP ), &bm ) )
         _arraySet( pResult, bm.bmWidth, bm.bmHeight, bm.bmBitsPixel );

      if( bDelete )
         DeleteObject( hBitmap );
   }

   hb_itemReturnRelease( pResult );
}

HB_FUNC( GETICONSIZE )
{
   PHB_ITEM pResult = hb_itemArrayNew( 3 );
   HICON    hIcon   = ( HICON ) HB_PARNL( 1 );

   _arraySet( pResult, 0, 0, 4 );

   if( hIcon )
   {
      ICONINFO sIconInfo;

      if( GetIconInfo( hIcon, &sIconInfo ) )
      {
         BITMAP bm;

         if( GetObject( sIconInfo.hbmColor, sizeof( BITMAP ), &bm ) )
            _arraySet( pResult, bm.bmWidth, bm.bmHeight, bm.bmBitsPixel );

         DeleteObject( sIconInfo.hbmMask );
         DeleteObject( sIconInfo.hbmColor );
      }
   }

   hb_itemReturnRelease( pResult );
}
