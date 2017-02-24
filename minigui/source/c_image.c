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

   ---------------------------------------------------------------------------*/

#ifndef CINTERFACE
  #define CINTERFACE
#endif

#define WINVER  0x0410

#include <mgdefs.h>

#include <commctrl.h>
#include <olectl.h>
#ifdef __XCC__
#include "ocidl.h"
#endif

#include "hbapiitm.h"
#include "hbvm.h"

#ifndef WC_STATIC
#define WC_STATIC  "Static"
#endif

HBITMAP HMG_LoadPicture( char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage );
HBITMAP HMG_LoadImage( char * FileName );
LRESULT APIENTRY  PictSubClassFunc( HWND hwnd, UINT Msg, WPARAM wParam, LPARAM lParam );

static BOOL __bt_Load_GDIplus( void );
static BOOL __bt_Release_GDIplus( void );

static WNDPROC LabelOldWndProc;

extern HINSTANCE g_hInstance;

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
      LabelOldWndProc = ( WNDPROC ) SetWindowLongPtr( hWnd, GWLP_WNDPROC, ( LONG_PTR ) PictSubClassFunc );

   HB_RETNL( ( LONG_PTR ) hWnd );
}

HB_FUNC( C_SETPICTURE )
{
   HBITMAP hBitmap;

   if( hb_parclen( 2 ) == 0 )
      HB_RETNL( ( LONG_PTR ) NULL );

   hBitmap = HMG_LoadPicture( ( char * ) hb_parc( 2 ), hb_parni( 3 ), hb_parni( 4 ), ( HWND ) HB_PARNL( 1 ), hb_parni( 5 ), hb_parni( 6 ), hb_parnl( 7 ), hb_parni( 8 ) );

   if( hBitmap != NULL )
      SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hBitmap );

   HB_RETNL( ( LONG_PTR ) hBitmap );
}

HB_FUNC( C_GETRESPICTURE )
{
   HBITMAP hBitmap;

   hBitmap = HMG_LoadImage( ( char * ) hb_parc( 1 ) );

   HB_RETNL( ( LONG_PTR ) hBitmap );
}

#define _OLD_STYLE  0

LRESULT APIENTRY PictSubClassFunc( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam )
{
   TRACKMOUSEEVENT tme;
   static PHB_SYMB pSymbol        = NULL;
   static BOOL     bMouseTracking = FALSE;
   long r = 0;

#if _OLD_STYLE
   BOOL bCallUDF = FALSE;
#endif
   if( Msg == WM_MOUSEMOVE || Msg == WM_MOUSELEAVE )
   {
      if( Msg == WM_MOUSEMOVE )
      {
         if( bMouseTracking == FALSE )
         {
            tme.cbSize      = sizeof( TRACKMOUSEEVENT );
            tme.dwFlags     = TME_LEAVE;
            tme.hwndTrack   = hWnd;
            tme.dwHoverTime = HOVER_DEFAULT;

            if( _TrackMouseEvent( &tme ) == TRUE )
            {
#if _OLD_STYLE
               bCallUDF = TRUE;
#endif
               bMouseTracking = TRUE;
            }
#if _OLD_STYLE
         }
         else
         {
            bCallUDF = FALSE;
#endif
         }
      }
      else
      {
#if _OLD_STYLE
         bCallUDF = TRUE;
#endif
         bMouseTracking = FALSE;
      }
#if _OLD_STYLE
      if( bCallUDF == TRUE )
      {
#endif
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
#if _OLD_STYLE
   }
#endif
      return ( r != 0 ) ? r : CallWindowProc( LabelOldWndProc, hWnd, 0, 0, 0 );
   }

   bMouseTracking = FALSE;

   return CallWindowProc( LabelOldWndProc, hWnd, Msg, wParam, lParam );
}

#undef _OLD_STYLE

/*-------------------------------------------------------------------------
   The following functions are taken from the graphics library Bos Taurus.
   Bos Taurus, (c) 2012-2013 by Dr. Claudio Soto <srvet@adinet.com.uy>
   ---------------------------------------------------------------------------*/

//*************************************************************************************************
// __bt_LoadFileFromResources (FileName, TypeResource) ---> Return hGlobalAlloc
//*************************************************************************************************
static HGLOBAL __bt_LoadFileFromResources( char * FileName, char * TypeResource )
{
   HRSRC hResourceData;
   HGLOBAL hGlobalAlloc, hGlobalResource;
   LPVOID lpGlobalAlloc, lpGlobalResource;
   DWORD nSize;

   hResourceData = FindResource( NULL, FileName, TypeResource );
   if( hResourceData == NULL )
      return NULL;

   hGlobalResource = LoadResource( NULL, hResourceData );
   if( hGlobalResource == NULL )
      return NULL;

   lpGlobalResource = LockResource( hGlobalResource );
   if( lpGlobalResource == NULL )
      return NULL;

   nSize = SizeofResource( NULL, hResourceData );

   hGlobalAlloc = GlobalAlloc( GHND, nSize );
   if( hGlobalAlloc == NULL )
   {
      FreeResource( hGlobalResource );
      return NULL;
   }

   lpGlobalAlloc = GlobalLock( hGlobalAlloc );
   CopyMemory( lpGlobalAlloc, lpGlobalResource, ( SIZE_T ) nSize );
   GlobalUnlock( hGlobalAlloc );

   FreeResource( hGlobalResource );

   return hGlobalAlloc;
}

//*************************************************************************************************
// __bt_LoadFileFromDisk (FileName) ---> Return hGlobalAlloc
//*************************************************************************************************
static HGLOBAL __bt_LoadFileFromDisk( char * FileName )
{
   HGLOBAL hGlobalAlloc;
   LPVOID lpGlobalAlloc;
   HANDLE hFile;
   DWORD nFileSize, nReadByte;

   hFile = CreateFile( FileName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
      return NULL;

   nFileSize = GetFileSize( hFile, NULL );
   if( nFileSize == INVALID_FILE_SIZE )
   {
      CloseHandle( hFile );
      return NULL;
   }

   hGlobalAlloc = GlobalAlloc( GHND, nFileSize );
   if( hGlobalAlloc == NULL )
   {
      CloseHandle( hFile );
      return NULL;
   }
   lpGlobalAlloc = GlobalLock( hGlobalAlloc );
   ReadFile( hFile, lpGlobalAlloc, nFileSize, &nReadByte, NULL );
   GlobalUnlock( hGlobalAlloc );

   CloseHandle( hFile );

   return hGlobalAlloc;
}

//*************************************************************************************************
// __bt_bmp_create_24bpp (HDC hDC_mem, int Width, int Height) ---> Return hBITMAP
//*************************************************************************************************
static HBITMAP __bt_bmp_create_24bpp( HDC hDC_mem, int Width, int Height )
{
   LPBYTE Bitmap_mem_pBits;
   HBITMAP hBitmap_mem;
   BITMAPINFO Bitmap_Info;

   Bitmap_Info.bmiHeader.biSize          = sizeof( BITMAPINFOHEADER );
   Bitmap_Info.bmiHeader.biWidth         = Width;
   Bitmap_Info.bmiHeader.biHeight        = Height;
   Bitmap_Info.bmiHeader.biPlanes        = 1;
   Bitmap_Info.bmiHeader.biBitCount      = 24;
   Bitmap_Info.bmiHeader.biCompression   = BI_RGB;
   Bitmap_Info.bmiHeader.biSizeImage     = 0;
   Bitmap_Info.bmiHeader.biXPelsPerMeter = 0;
   Bitmap_Info.bmiHeader.biYPelsPerMeter = 0;
   Bitmap_Info.bmiHeader.biClrUsed       = 0;
   Bitmap_Info.bmiHeader.biClrImportant  = 0;

   hBitmap_mem = CreateDIBSection( hDC_mem, ( BITMAPINFO * ) &Bitmap_Info, DIB_RGB_COLORS, ( VOID ** ) &Bitmap_mem_pBits, NULL, 0 );

   return hBitmap_mem;
}

BOOL __bt_OleInitialize_Flag_ = FALSE;

//*************************************************************************************************
// __bt_LoadOLEPicture (FileName, TypePicture) ---> Return hBitmap  (Load JPG, GIF and TIF images)
//*************************************************************************************************
HBITMAP __bt_LoadOLEPicture( TCHAR * FileName, TCHAR * TypePictureResource )
{
   IStream    * iStream;
   IPicture   * iPicture = NULL;
   HBITMAP hBitmap;
   HDC memDC;
   HGLOBAL hGlobalAlloc;
   LONG hmWidth, hmHeight;
   INT pxWidth, pxHeight;
   POINT Point;

   if( TypePictureResource != NULL )
      hGlobalAlloc = __bt_LoadFileFromResources( FileName, TypePictureResource );
   else
      hGlobalAlloc = __bt_LoadFileFromDisk( FileName );

   if( hGlobalAlloc == NULL )
      return NULL;

   if( __bt_OleInitialize_Flag_ == FALSE )
   {
      __bt_OleInitialize_Flag_ = TRUE;
      OleInitialize( NULL );
   }

   CreateStreamOnHGlobal( hGlobalAlloc, FALSE, &iStream );
#if defined( __cplusplus )
   OleLoadPicture( iStream, 0, TRUE, IID_IPicture, ( LPVOID * ) &iPicture );
#else
   OleLoadPicture( iStream, 0, TRUE, &IID_IPicture, ( LPVOID * ) &iPicture );
   iStream->lpVtbl->Release( iStream );
#endif
   if( iPicture == NULL )
   {
      GlobalFree( hGlobalAlloc );
      return NULL;
   }

   iPicture->lpVtbl->get_Width( iPicture, &hmWidth );
   iPicture->lpVtbl->get_Height( iPicture, &hmHeight );

   memDC = CreateCompatibleDC( NULL );

   GetBrushOrgEx( memDC, &Point );
   SetStretchBltMode( memDC, HALFTONE );
   SetBrushOrgEx( memDC, Point.x, Point.y, NULL );

   // Convert HiMetric to Pixel
   #define HIMETRIC_PER_INCH  2540                                                              // Number of HIMETRIC units per INCH
   #define __bt_LOGHIMETRIC_TO_PIXEL( hm, ppli )  MulDiv( ( hm ), ( ppli ), HIMETRIC_PER_INCH ) // ppli = Point per Logic Inch
   #define __bt_PIXEL_TO_LOGHIMETRIC( px, ppli )  MulDiv( ( px ), HIMETRIC_PER_INCH, ( ppli ) ) // ppli = Point per Logic Inch

   pxWidth  = __bt_LOGHIMETRIC_TO_PIXEL( hmWidth, GetDeviceCaps( memDC, LOGPIXELSX ) );
   pxHeight = __bt_LOGHIMETRIC_TO_PIXEL( hmHeight, GetDeviceCaps( memDC, LOGPIXELSY ) );

   hBitmap = __bt_bmp_create_24bpp( memDC, pxWidth, pxHeight );
   SelectObject( memDC, hBitmap );

   iPicture->lpVtbl->Render( iPicture, memDC, 0, 0, pxWidth, pxHeight, 0, hmHeight, hmWidth, -hmHeight, NULL );
   iPicture->lpVtbl->Release( iPicture );

   DeleteDC( memDC );
   GlobalFree( hGlobalAlloc );

   return hBitmap;
}

HB_FUNC( OLEDATARELEASE )
{
   if( __bt_OleInitialize_Flag_ )
   {
      OleUninitialize();
   }
}

//*************************************************************************************************
//  GDI Plus: Functions and Definitions
//*************************************************************************************************

// Begin GDIPLUS Definitions

typedef enum GpStatus
{
   Ok                        = 0,
   GenericError              = 1,
   InvalidParameter          = 2,
   OutOfMemory               = 3,
   ObjectBusy                = 4,
   InsufficientBuffer        = 5,
   NotImplemented            = 6,
   Win32Error                = 7,
   WrongState                = 8,
   Aborted                   = 9,
   FileNotFound              = 10,
   ValueOverflow             = 11,
   AccessDenied              = 12,
   UnknownImageFormat        = 13,
   FontFamilyNotFound        = 14,
   FontStyleNotFound         = 15,
   NotTrueTypeFont           = 16,
   UnsupportedGdiplusVersion = 17,
   GdiplusNotInitialized     = 18,
   PropertyNotFound          = 19,
   PropertyNotSupported      = 20,
   ProfileNotFound           = 21
} GpStatus;

#define WINGDIPAPI  __stdcall
#define GDIPCONST   const

typedef void GpBitmap;
typedef void * DebugEventProc;

typedef struct GdiplusStartupInput
{
   UINT32 GdiplusVersion;
   DebugEventProc DebugEventCallback;
   BOOL SuppressBackgroundThread;
   BOOL SuppressExternalCodecs;
} GdiplusStartupInput;

typedef GpStatus WINGDIPAPI ( *NotificationHookProc )( ULONG_PTR * token );
typedef VOID WINGDIPAPI ( *NotificationUnhookProc )( ULONG_PTR token );

typedef struct GdiplusStartupOutput
{
   NotificationHookProc NotificationHook;
   NotificationUnhookProc NotificationUnhook;
} GdiplusStartupOutput;

typedef ULONG ARGB;
typedef GpStatus ( WINGDIPAPI * Func_GdiPlusStartup )( ULONG_PTR *, GDIPCONST GdiplusStartupInput *, GdiplusStartupOutput * );
typedef VOID ( WINGDIPAPI * Func_GdiPlusShutdown )( ULONG_PTR );
typedef GpStatus ( WINGDIPAPI * Func_GdipCreateBitmapFromStream )( IStream *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * Func_GdipCreateHBITMAPFromBitmap )( GpBitmap *, HBITMAP *, ARGB );
typedef GpStatus ( WINGDIPAPI * Func_GdipDisposeImage )( GpBitmap * );

// End GDIPLUS Definitions

// GDI Plus Functions
Func_GdiPlusStartup _GdiPlusStartup;
Func_GdiPlusShutdown _GdiPlusShutdown;
Func_GdipCreateBitmapFromStream _GdipCreateBitmapFromStream;
Func_GdipCreateHBITMAPFromBitmap _GdipCreateHBITMAPFromBitmap;
Func_GdipDisposeImage _GdipDisposeImage;

// Global Variables
VOID         * _GdiPlusHandle_ = NULL;
ULONG_PTR _GdiPlusToken_;
GdiplusStartupInput _GDIPlusStartupInput_;

//  Load Library GDI Plus
static BOOL __bt_Load_GDIplus( void )
{
   _GdiPlusHandle_ = LoadLibrary( "GdiPlus.dll" );
   if( _GdiPlusHandle_ == NULL )
      return FALSE;

   _GdiPlusStartup  = ( Func_GdiPlusStartup ) GetProcAddress( ( HMODULE ) _GdiPlusHandle_, "GdiplusStartup" );
   _GdiPlusShutdown = ( Func_GdiPlusShutdown ) GetProcAddress( ( HMODULE ) _GdiPlusHandle_, "GdiplusShutdown" );
   _GdipCreateBitmapFromStream  = ( Func_GdipCreateBitmapFromStream ) GetProcAddress( ( HMODULE ) _GdiPlusHandle_, "GdipCreateBitmapFromStream" );
   _GdipCreateHBITMAPFromBitmap = ( Func_GdipCreateHBITMAPFromBitmap ) GetProcAddress( ( HMODULE ) _GdiPlusHandle_, "GdipCreateHBITMAPFromBitmap" );
   _GdipDisposeImage = ( Func_GdipDisposeImage ) GetProcAddress( ( HMODULE ) _GdiPlusHandle_, "GdipDisposeImage" );

   if( _GdiPlusStartup == NULL ||
       _GdiPlusShutdown == NULL ||
       _GdipCreateBitmapFromStream == NULL ||
       _GdipCreateHBITMAPFromBitmap == NULL ||
       _GdipDisposeImage == NULL )
   {
      FreeLibrary( ( HMODULE ) _GdiPlusHandle_ );
      _GdiPlusHandle_ = NULL;
      return FALSE;
   }

   _GDIPlusStartupInput_.GdiplusVersion           = 1;
   _GDIPlusStartupInput_.DebugEventCallback       = NULL;
   _GDIPlusStartupInput_.SuppressBackgroundThread = FALSE;
   _GDIPlusStartupInput_.SuppressExternalCodecs   = FALSE;

   if( _GdiPlusStartup( &_GdiPlusToken_, &_GDIPlusStartupInput_, NULL ) )
   {
      FreeLibrary( ( HMODULE ) _GdiPlusHandle_ );
      _GdiPlusHandle_ = NULL;
      return FALSE;
   }
   return TRUE;
}

//  Release Library GDI Plus
static BOOL __bt_Release_GDIplus( void )
{
   if( _GdiPlusHandle_ == NULL )
      return FALSE;
   else
   {
      _GdiPlusShutdown( _GdiPlusToken_ );
      FreeLibrary( ( HMODULE ) _GdiPlusHandle_ );
      _GdiPlusHandle_ = NULL;
      return TRUE;
   }
}

//****************************************************************************************************************
// __bt_LoadGDIPlusPicture (FileName, TypePicture) ---> Return hBitmap (Load PNG image)
//****************************************************************************************************************
static HBITMAP __bt_LoadGDIPlusPicture( char * FileName, char * TypePictureResource )
{
   IStream   * iStream;
   HBITMAP hBitmap;
   HGLOBAL hGlobalAlloc;
   GpBitmap  * pGpBitmap;
   ARGB BkColor;

   if( ! __bt_Load_GDIplus() )
      return NULL;

   if( TypePictureResource != NULL )
      hGlobalAlloc = __bt_LoadFileFromResources( FileName, TypePictureResource );
   else
      hGlobalAlloc = __bt_LoadFileFromDisk( FileName );

   if( hGlobalAlloc == NULL )
      return NULL;

   if( CreateStreamOnHGlobal( hGlobalAlloc, FALSE, &iStream ) == S_OK )
   {
      BkColor = 0xFF000000UL;
      _GdipCreateBitmapFromStream( iStream, &pGpBitmap );
      _GdipCreateHBITMAPFromBitmap( pGpBitmap, &hBitmap, BkColor );
      _GdipDisposeImage( pGpBitmap );
      iStream->lpVtbl->Release( iStream );
   }

   GlobalFree( hGlobalAlloc );
   __bt_Release_GDIplus();

   return hBitmap;
}

//****************************************************************************************************************
// HMG_LoadImage (char *FileName) ---> Return hBitmap (Load: JPG, GIF, WMF, TIF, PNG)
//****************************************************************************************************************
HBITMAP HMG_LoadImage( char * FileName )
{
   HBITMAP hBitmap;

   // Find JPG Image in resourses
   hBitmap = __bt_LoadOLEPicture( FileName, "JPG" );
   // If fail: find GIF Image in resourses
   if( hBitmap == NULL )
      hBitmap = __bt_LoadOLEPicture( FileName, "GIF" );
   // If fail: find WMF Image in resourses
   if( hBitmap == NULL )
      hBitmap = __bt_LoadOLEPicture( FileName, "WMF" );
   // If fail: find PNG Image in resourses
   if( hBitmap == NULL )
      hBitmap = __bt_LoadGDIPlusPicture( FileName, "PNG" );
   // If fail: find JPG, GIF, WMF and TIF Image in disk
   if( hBitmap == NULL )
      hBitmap = __bt_LoadOLEPicture( FileName, NULL );
   // If fail: find PNG Image in disk
   if( hBitmap == NULL )
      hBitmap = __bt_LoadGDIPlusPicture( FileName, NULL );

   return hBitmap;
}

//****************************************************************************************************************
// HMG_LoadPicture (FileName, New_Width, New_Height, ...) ---> Return hBitmap (Load: BMP, GIF, JPG, TIF, WMF, PNG)
//****************************************************************************************************************
HBITMAP HMG_LoadPicture( char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage )
{
   UINT fuLoad = ( Transparent == 0 ) ? LR_CREATEDIBSECTION : LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT;
   HBITMAP hBitmap_Old, hBitmap_New, hOldBitmap, hBitmap;
   RECT rect, rect2;
   BITMAP bm;
   LONG Image_Width, Image_Height;
   HDC hDC, memDC1, memDC2;
   HBRUSH hBrush;
   BOOL bBmpImage = TRUE;

   // First find BMP image in resourses (.EXE file)
   hBitmap = ( HBITMAP ) LoadImage( g_hInstance, FileName, IMAGE_BITMAP, 0, 0, fuLoad );
   // If fail: find BMP in disk
   if( hBitmap == NULL )
      hBitmap = ( HBITMAP ) LoadImage( NULL, FileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | fuLoad );

   // If fail: find JPG, GIF, WMF, PNG and TIF images
   if( hBitmap == NULL )
   {
      bBmpImage = FALSE;
      hBitmap   = HMG_LoadImage( FileName );
   }
   // If fail: return
   if( hBitmap == NULL )
      return NULL;

   GetObject( hBitmap, sizeof( BITMAP ), &bm );
   Image_Width  = bm.bmWidth;
   Image_Height = bm.bmHeight;

   if( New_Width < 0 )  // load image with original Width
      New_Width = Image_Width;

   if( New_Height < 0 ) // load image with original Height
      New_Height = Image_Height;

   if( New_Width == 0 || New_Height == 0 )
      GetClientRect( hWnd, &rect );
   else
      SetRect( &rect, 0, 0, New_Width, New_Height );

   SetRect( &rect2, 0, 0, rect.right, rect.bottom );

   hDC    = GetDC( hWnd );
   memDC2 = CreateCompatibleDC( hDC );
   memDC1 = CreateCompatibleDC( hDC );

   if( ScaleStretch == 0 )
   {
      if( ( int ) Image_Width * rect.bottom / Image_Height <= rect.right )
         rect.right = ( int ) Image_Width * rect.bottom / Image_Height;
      else
         rect.bottom = ( int ) Image_Height * rect.right / Image_Width;

      if( AdjustImage == 1 )
      {
         New_Width  = ( long ) rect.right;
         New_Height = ( long ) rect.bottom;
      }
      else // Center Image
      {
         rect.left = ( int ) ( New_Width - rect.right ) / 2;
         rect.top  = ( int ) ( New_Height - rect.bottom ) / 2;
      }
   }

   hBitmap_New = CreateCompatibleBitmap( hDC, New_Width, New_Height );

   hOldBitmap  = ( HBITMAP ) SelectObject( memDC1, hBitmap );
   hBitmap_Old = ( HBITMAP ) SelectObject( memDC2, hBitmap_New );

   if( BackgroundColor == -1 )
      FillRect( memDC2, &rect2, ( HBRUSH ) GetSysColorBrush( COLOR_BTNFACE ) );
   else
   {
      hBrush = CreateSolidBrush( BackgroundColor );
      FillRect( memDC2, &rect2, hBrush );
      DeleteObject( hBrush );
   }

   if( ! bBmpImage )
   {
      if( ScaleStretch == 1 )
         SetStretchBltMode( memDC2, COLORONCOLOR );
      else
      {
         POINT Point;
         GetBrushOrgEx( memDC2, &Point );
         SetStretchBltMode( memDC2, HALFTONE );
         SetBrushOrgEx( memDC2, Point.x, Point.y, NULL );
      }
   }

   if( Transparent == 1 && ! bBmpImage )
      TransparentBlt( memDC2, rect.left, rect.top, rect.right, rect.bottom, memDC1, 0, 0, Image_Width, Image_Height, GetPixel( memDC1, 0, 0 ) );
   else
      StretchBlt( memDC2, rect.left, rect.top, rect.right, rect.bottom, memDC1, 0, 0, Image_Width, Image_Height, SRCCOPY );

   // clean up
   SelectObject( memDC2, hBitmap_Old );
   SelectObject( memDC1, hOldBitmap );
   DeleteDC( memDC1 );
   DeleteDC( memDC2 );
   ReleaseDC( hWnd, hDC );

   DeleteObject( hBitmap );

   return hBitmap_New;
}
