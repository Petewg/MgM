/*
   MINIGUI - Harbour Win32 GUI library source code

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
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */

#ifndef CINTERFACE
# define CINTERFACE
#endif

#include <mgdefs.h>
#include <commctrl.h>
#include <olectl.h>
#ifdef __XCC__
# include "ocidl.h"
#endif

#include "hbgdiplus.h"

#include "hbapiitm.h"
#include "hbvm.h"

#ifndef WC_STATIC
# define WC_STATIC  "Static"
#endif

#define LOGHIMETRIC_TO_PIXEL( hm, ppli )  MulDiv( ( hm ), ( ppli ), 2540 ) // ppli = Point per Logic Inch
#define PIXEL_TO_LOGHIMETRIC( px, ppli )  MulDiv( ( px ), 2540, ( ppli ) ) // ppli = Point per Logic Inch

LRESULT APIENTRY ImageSubClassFunc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam );

HB_EXPORT IStream * HMG_CreateMemStreamFromResource( HINSTANCE instance, const char * res_type, const char * res_name );
HB_EXPORT IStream * HMG_CreateMemStream( const BYTE * pInit, UINT cbInitSize );
HB_EXPORT HBITMAP   HMG_GdiCreateHBITMAP( HDC hDC_mem, int width, int height, WORD iBitCount );

HB_EXPORT HBITMAP   HMG_LoadImage( const char * pszImageName, const char * pszTypeOfRes );
HB_EXPORT HBITMAP   HMG_LoadPicture( const char * pszName, int width, int height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                                     HB_BOOL bAlphaFormat, int iAlpfaConstant );
HB_EXPORT HBITMAP   HMG_OleLoadPicturePath( const char * pszURLorPath );

extern HINSTANCE g_hInstance;
static WNDPROC   s_Image_WNDPROC;

// ================================================================================== //

HB_EXPORT IStream * HMG_CreateMemStreamFromResource( HINSTANCE hinstance, const char * res_name, const char * res_type )
{
   HRSRC     resource;
   DWORD     res_size;
   HGLOBAL   res_global;
   void *    res_data;
   wchar_t * res_nameW;
   wchar_t * res_typeW;
   IStream * stream;

   if( NULL == res_name || NULL == res_type )
      return NULL;

   res_nameW = hb_mbtowc( res_name );
   res_typeW = hb_mbtowc( res_type );

   resource = FindResourceW( hinstance, res_nameW, res_typeW );

   hb_xfree( res_nameW );
   hb_xfree( res_typeW );

   if( NULL == resource )
      return NULL;

   res_size   = SizeofResource( hinstance, resource );
   res_global = LoadResource( hinstance, resource );

   if( NULL == res_global )
      return NULL;

   res_data = LockResource( res_global );

   if( NULL == res_data )
      return NULL;

   stream = HMG_CreateMemStream( ( const BYTE * ) res_data, ( UINT ) res_size );

   return stream;
}

HB_EXPORT IStream * HMG_CreateMemStream( const BYTE * pInit, UINT cbInitSize )
{
   HMODULE   hShlDll = LoadLibrary( TEXT( "shlwapi.dll" ) );
   IStream * stream  = NULL;

   if( NULL != hShlDll )
   {
      typedef IStream * ( __stdcall * SHCreateMemStreamPtr )( const BYTE * pInit, UINT cbInitSize );

      SHCreateMemStreamPtr f_SHCreateMemStream = ( SHCreateMemStreamPtr ) GetProcAddress( hShlDll, ( LPCSTR ) 12 );

      if( f_SHCreateMemStream != NULL )
         stream = f_SHCreateMemStream( pInit, cbInitSize );

      FreeLibrary( hShlDll );
   }
   return stream;
}

HB_EXPORT HBITMAP HMG_GdiCreateHBITMAP( HDC hDC_mem, int width, int height, WORD iBitCount )
{
   LPBYTE     pBits;
   HBITMAP    hBitmap;
   BITMAPINFO BI;

   BI.bmiHeader.biSize          = sizeof( BITMAPINFOHEADER );
   BI.bmiHeader.biWidth         = width;
   BI.bmiHeader.biHeight        = height;
   BI.bmiHeader.biPlanes        = 1;
   BI.bmiHeader.biBitCount      = iBitCount;
   BI.bmiHeader.biCompression   = BI_RGB;    // TODO
   BI.bmiHeader.biSizeImage     = 0;
   BI.bmiHeader.biXPelsPerMeter = 0;
   BI.bmiHeader.biYPelsPerMeter = 0;
   BI.bmiHeader.biClrUsed       = 0;
   BI.bmiHeader.biClrImportant  = 0;

   hBitmap = CreateDIBSection( hDC_mem, ( BITMAPINFO * ) &BI, DIB_RGB_COLORS, ( VOID ** ) &pBits, NULL, 0 );

   return hBitmap;
}

static HBITMAP HMG_GdipLoadBitmap( const char * res_name, const char * res_type )
{
   HBITMAP    hBitmap  = ( HBITMAP ) NULL;
   GpStatus   status   = 1;
   GpBitmap * gpBitmap = NULL;
   wchar_t *  res_nameW;

   if( NULL == res_name )
      return hBitmap;  // NULL

   res_nameW = hb_mbtowc( res_name );

   if( NULL != fn_GdipCreateBitmapFromResource )
      status = fn_GdipCreateBitmapFromResource( g_hInstance, res_nameW, &gpBitmap );

   if( Ok != status && NULL != res_type )
   {
      IStream * stream;

      stream = HMG_CreateMemStreamFromResource( g_hInstance, res_name, res_type );

      if( NULL != stream )
      {
         if( NULL != fn_GdipCreateBitmapFromStream )
            status = fn_GdipCreateBitmapFromStream( stream, &gpBitmap );

         stream->lpVtbl->Release( stream );
      }
   }

   if( Ok != status && NULL != fn_GdipCreateBitmapFromFile )
   {
      UINT uOldErrorMode = SetErrorMode( SEM_NOOPENFILEERRORBOX );

      status = fn_GdipCreateBitmapFromFile( res_nameW, &gpBitmap );

      SetErrorMode( uOldErrorMode );
   }

   if( Ok == status )
   {
      ARGB BkColor = 0xFF000000UL;  // TODO

      if( NULL != fn_GdipCreateHBITMAPFromBitmap )
         fn_GdipCreateHBITMAPFromBitmap( gpBitmap, &hBitmap, BkColor );

      if( NULL != fn_GdipDisposeImage )
         fn_GdipDisposeImage( gpBitmap );
   }

   hb_xfree( res_nameW );

   return hBitmap;
}

LRESULT APIENTRY ImageSubClassFunc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   static BOOL bMouseTracking = FALSE;

   if( Msg == WM_MOUSEMOVE || Msg == WM_MOUSELEAVE )
   {
      long r = 0;
      static PHB_SYMB pSymbol = NULL;

      if( Msg == WM_MOUSEMOVE )
      {
         if( bMouseTracking == FALSE )
         {
            TRACKMOUSEEVENT tme;

            tme.cbSize      = sizeof( TRACKMOUSEEVENT );
            tme.dwFlags     = TME_LEAVE;
            tme.hwndTrack   = hWnd;
            tme.dwHoverTime = HOVER_DEFAULT;

            bMouseTracking = _TrackMouseEvent( &tme );
         }
      }
      else
         bMouseTracking = FALSE;

      if( ! pSymbol )
         pSymbol = hb_dynsymSymbol( hb_dynsymGet( "OLABELEVENTS" ) );

      if( pSymbol && hb_vmRequestReenter() )
      {
         hb_vmPushSymbol( pSymbol );
         hb_vmPushNil();
         hb_vmPushNumInt( ( LONG_PTR ) hWnd );
         hb_vmPushLong( Msg );
         hb_vmPushNumInt( wParam );
         hb_vmPushNumInt( lParam );
         hb_vmDo( 4 );

         r = hb_parnl( -1 );

         hb_vmRequestRestore();
      }
      return ( r != 0 ) ? r : CallWindowProc( s_Image_WNDPROC, hWnd, 0, 0, 0 );
   }
   bMouseTracking = FALSE;

   return CallWindowProc( s_Image_WNDPROC, hWnd, Msg, wParam, lParam );
}

HB_FUNC( INITIMAGE )
{
   HWND hWnd;
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   int  Style      = WS_CHILD | SS_BITMAP;

   if( ! hb_parl( 5 ) )
      Style |= WS_VISIBLE;

   if( hb_parl( 6 ) || hb_parl( 7 ) )
      Style |= SS_NOTIFY;

   hWnd = CreateWindowEx( 0, WC_STATIC, NULL, Style, hb_parni( 3 ), hb_parni( 4 ), 0, 0, hWndParent, ( HMENU ) HB_PARNL( 2 ), g_hInstance, NULL );

   if( hb_parl( 7 ) )
      s_Image_WNDPROC = ( WNDPROC ) SetWindowLongPtr( hWnd, GWLP_WNDPROC, ( LONG_PTR ) ImageSubClassFunc );

   HB_RETNL( ( LONG_PTR ) hWnd );
}

HB_FUNC( C_SETPICTURE )
{
   HWND    hWnd    = ( HWND ) HB_PARNL( 1 );
   HBITMAP hBitmap = NULL;

   if( IsWindow( hWnd ) && ( hb_parclen( 2 ) > 0 ) )
   {
      hBitmap = HMG_LoadPicture
                (
         hb_parc( 2 ),                 // Filename, resource or URL
         hb_parni( 3 ),                // Width
         hb_parni( 4 ),                // Height
         hWnd,                         // Handle of parent window
         hb_parni( 5 ),                // Scale factor
         hb_parni( 6 ),                // Transparent
         hb_parnl( 7 ),                // BackColor
         hb_parni( 8 ),                // Adjust factor
         hb_parldef( 9, HB_FALSE ),    // Bitmap with alpha channel
         hb_parnidef( 10, 255 )
                );

      if( hBitmap != NULL )
      {
         HBITMAP hOldBitmap = ( HBITMAP ) SendMessage( hWnd, STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hBitmap );

         if( hOldBitmap != NULL )
            DeleteObject( hOldBitmap );
      }
   }
   HB_RETNL( ( LONG_PTR ) hBitmap );
}

HB_FUNC( C_GETRESPICTURE )
{
   HBITMAP hBitmap;

   hBitmap = HMG_LoadImage( hb_parc( 1 ), hb_parc( 2 ) );

   HB_RETNL( ( LONG_PTR ) hBitmap );
}

//****************************************************************************************************************
// HMG_LoadImage (const char *FileName) -> hBitmap (Load: JPG, GIF, WMF, TIF, PNG)
//****************************************************************************************************************
HB_EXPORT HBITMAP HMG_LoadImage( const char * pszImageName, const char * pszTypeOfRes )
{
   HBITMAP hBitmap;

   HB_SYMBOL_UNUSED( pszTypeOfRes );

   // Find PNG Image in resourses
   hBitmap = HMG_GdipLoadBitmap( pszImageName, "PNG" );
   // If fail: find JPG Image in resourses
   if( hBitmap == NULL )
      hBitmap = HMG_GdipLoadBitmap( pszImageName, "JPG" );
   // If fail: find GIF Image in resourses
   if( hBitmap == NULL )
      hBitmap = HMG_GdipLoadBitmap( pszImageName, "GIF" );
   // If fail: find TIF Image in resourses
   if( hBitmap == NULL )
      hBitmap = HMG_GdipLoadBitmap( pszImageName, "TIF" );
   // If fail: find WMF Image in resourses
   if( hBitmap == NULL )
      hBitmap = HMG_GdipLoadBitmap( pszImageName, "WMF" );
   // If fail: PNG, JPG, GIF, WMF and TIF Image in disk
   if( hBitmap == NULL )
      hBitmap = HMG_GdipLoadBitmap( pszImageName, NULL );

   return hBitmap;
}

//****************************************************************************************************************
// HMG_LoadPicture (Name, width, height, ...) -> hBitmap (Load: BMP, GIF, JPG, TIF, WMF, EMF, PNG)
//****************************************************************************************************************
HB_EXPORT HBITMAP HMG_LoadPicture( const char * pszName, int width, int height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage, HB_BOOL bAlphaFormat, int iAlphaConstant )
{
   UINT    fuLoad = ( Transparent == 0 ) ? LR_CREATEDIBSECTION : LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT;
   HBITMAP old_hBitmap, new_hBitmap, hBitmap_old, hBitmap_new = NULL;
   RECT    rect, rect2;
   BITMAP  bm;
   LONG    bmWidth, bmHeight;
   HDC     hDC, memDC1, memDC2;

   if( NULL == pszName )
      return NULL;

   if( bAlphaFormat == HB_FALSE ) // Firstly find BMP image in resourses (.EXE file)
   {
      hBitmap_new = ( HBITMAP ) LoadImage( g_hInstance, pszName, IMAGE_BITMAP, 0, 0, fuLoad );
      // If fail: find BMP in disk
      if( hBitmap_new == NULL )
         hBitmap_new = ( HBITMAP ) LoadImage( NULL, pszName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | fuLoad );
   }
   // Secondly find BMP (bitmap), ICO (icon), JPEG, GIF, WMF (metafile) file on disk or URL
   if( hBitmap_new == NULL && hb_strnicmp( "http", pszName, 4 ) == 0 )
      hBitmap_new = HMG_OleLoadPicturePath( pszName );
   // If fail: find JPG, GIF, WMF, TIF and PNG images using GDI+
   if( hBitmap_new == NULL )
      hBitmap_new = HMG_LoadImage( pszName, NULL );
   // If fail: return
   if( hBitmap_new == NULL )
      return NULL;

   GetObject( hBitmap_new, sizeof( BITMAP ), &bm );
   bmWidth  = bm.bmWidth;
   bmHeight = bm.bmHeight;

   if( width < 0 )  // load image with original Width
      width = bmWidth;

   if( height < 0 ) // load image with original Height
      height = bmHeight;

   if( width == 0 || height == 0 )
      GetClientRect( hWnd, &rect );
   else
      SetRect( &rect, 0, 0, width, height );

   SetRect( &rect2, 0, 0, rect.right, rect.bottom );

   hDC    = GetDC( hWnd );
   memDC1 = CreateCompatibleDC( hDC );
   memDC2 = CreateCompatibleDC( hDC );

   if( ScaleStretch == 0 )
   {
      if( ( int ) bmWidth * rect.bottom / bmHeight <= rect.right )
         rect.right = ( int ) bmWidth * rect.bottom / bmHeight;
      else
         rect.bottom = ( int ) bmHeight * rect.right / bmWidth;

      if( AdjustImage == 1 )
      {
         width  = ( long ) rect.right;
         height = ( long ) rect.bottom;
      }
      else // Center Image
      {
         rect.left = ( int ) ( width - rect.right ) / 2;
         rect.top  = ( int ) ( height - rect.bottom ) / 2;
      }
   }

   hBitmap_old = ( HBITMAP ) SelectObject( memDC1, hBitmap_new );
   new_hBitmap = CreateCompatibleBitmap( hDC, width, height );
   old_hBitmap = ( HBITMAP ) SelectObject( memDC2, new_hBitmap );

   if( BackgroundColor == -1 )
      FillRect( memDC2, &rect2, ( HBRUSH ) ( COLOR_BTNFACE + 1 ) );
   else
   {
      HBRUSH hBrush = CreateSolidBrush( BackgroundColor );

      FillRect( memDC2, &rect2, hBrush );
      DeleteObject( hBrush );
   }

   if( ScaleStretch == 1 )
      SetStretchBltMode( memDC2, COLORONCOLOR );
   else
   {
      POINT Point;

      GetBrushOrgEx( memDC2, &Point );
      SetStretchBltMode( memDC2, HALFTONE );
      SetBrushOrgEx( memDC2, Point.x, Point.y, NULL );
   }

   if( Transparent == 1 && ScaleStretch == 1 && bAlphaFormat == HB_FALSE )
      TransparentBlt( memDC2, rect.left, rect.top, rect.right, rect.bottom, memDC1, 0, 0, bmWidth, bmHeight, GetPixel( memDC1, 0, 0 ) );
   else if( Transparent == 1 || bAlphaFormat == HB_TRUE )
   {
      // TransparentBlt is supported for source bitmaps of 4 bits per pixel and 8 bits per pixel.
      // Use AlphaBlend to specify 32 bits-per-pixel bitmaps with transparency.
      BLENDFUNCTION ftn;

      if( bAlphaFormat )
         ftn.AlphaFormat = AC_SRC_ALPHA;

      ftn.BlendOp    = AC_SRC_OVER;
      ftn.BlendFlags = 0;
      ftn.SourceConstantAlpha = ( BYTE ) iAlphaConstant;

      AlphaBlend( memDC2, rect.left, rect.top, rect.right, rect.bottom, memDC1, 0, 0, bmWidth, bmHeight, ftn );
   }
   else
      StretchBlt( memDC2, rect.left, rect.top, rect.right, rect.bottom, memDC1, 0, 0, bmWidth, bmHeight, SRCCOPY );

   // clean up
   SelectObject( memDC2, old_hBitmap );
   SelectObject( memDC1, hBitmap_old );
   DeleteDC( memDC1 );
   DeleteDC( memDC2 );
   ReleaseDC( hWnd, hDC );

   DeleteObject( hBitmap_new );

   return new_hBitmap;
}

//*************************************************************************************************
// HMG_OleLoadPicturePath( pszURLorPath ) -> hBitmap
// (stream must be in BMP (bitmap), JPEG, WMF (metafile), ICO (icon), or GIF format)
//*************************************************************************************************
HB_EXPORT HBITMAP HMG_OleLoadPicturePath( const char * pszURLorPath )
{
   IPicture * iPicture = NULL;
   HRESULT    hres     = E_FAIL;
   HBITMAP    hBitmap  = NULL;
   HDC        memDC;
   LONG       hmWidth, hmHeight; // HiMetric

   if( NULL != pszURLorPath )
   {
      LPOLESTR lpURLorPath = ( LPOLESTR ) ( LPCTSTR ) hb_mbtowc( pszURLorPath );

      hres = OleLoadPicturePath( lpURLorPath, NULL, 0, 0, &IID_IPicture, ( LPVOID * ) &iPicture );
      hb_xfree( lpURLorPath );
   }

   if( S_OK != hres )
      return hBitmap;  // NULL

   iPicture->lpVtbl->get_Width( iPicture, &hmWidth  );
   iPicture->lpVtbl->get_Height( iPicture, &hmHeight );

   if( NULL != ( memDC = CreateCompatibleDC( NULL ) ) )
   {
      POINT Point;
      INT   pxWidth, pxHeight; // Pixel

      GetBrushOrgEx( memDC, &Point );
      SetStretchBltMode( memDC, HALFTONE );
      SetBrushOrgEx( memDC, Point.x, Point.y, NULL );

      // Convert HiMetric to Pixel
      pxWidth  = LOGHIMETRIC_TO_PIXEL( hmWidth, GetDeviceCaps( memDC, LOGPIXELSX ) );
      pxHeight = LOGHIMETRIC_TO_PIXEL( hmHeight, GetDeviceCaps( memDC, LOGPIXELSY ) );

      hBitmap = HMG_GdiCreateHBITMAP( memDC, pxWidth, pxHeight, 32 );
      SelectObject( memDC, hBitmap );

      iPicture->lpVtbl->Render( iPicture, memDC, 0, 0, pxWidth, pxHeight, 0, hmHeight, hmWidth, -hmHeight, NULL );
      iPicture->lpVtbl->Release( iPicture );

      DeleteDC( memDC );
   }
   else
      iPicture->lpVtbl->Release( iPicture );

   return hBitmap;
}
