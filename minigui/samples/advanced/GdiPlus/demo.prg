/*
 * GDI+ demo
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"
#include "hbgdip.ch"

#define c1Tab CHR(9)
#define NTrim( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ) )

#define BM_WIDTH     1
#define BM_HEIGHT    2
#define BM_BITSPIXEL 3

#xtranslate gSave => GPlusSaveHBitmapToFile

memvar cPicture
memvar hPicture
//////////////////////////////////////////////////////////////////////////////
procedure Main()

   if StatusOk != GdiplusInitExt( _GDI_GRAPHICS )
      quit
   endif

   _GdiplusInitLocal()

   public cPicture := 'demo'
   public hPicture := LoadBitmap( cPicture )

   define window Form_Main ;
      at 0,0 ;
      width 320 height 240 ;
      title 'GDI+: Save Bitmap To File Demo' ;
      main ;
      nomaximize nosize

      s_CreateMenu()

      @ 20,20 image Image_1 picture cPicture
   end window

   on key Escape of Form_Main action ThisWindow.Release

   center   window Form_Main
   activate window Form_Main

return

//////////////////////////////////////////////////////////////////////////////
static procedure s_CreateMenu()

   local i
   local aPictInfo := BmpSize( cPicture ) 
   local aMimeType := Array( GPlusGetEncodersNum() )

   for i := 1 to Len( aMimeType )
      aMimeType[i] := GPlusGetEncodersMimeType()[i]
   next

   define main menu
      define popup "&File" 
         for i := 1 TO Len( aMimeType )
            if "bmp" $ aMimeType[i]
               loop
            else

               #xtranslate _PICT_INFO => aPictInfo[BM_WIDTH], aPictInfo[BM_HEIGHT]

               if "jpeg" $ aMimeType[i]
                  menuitem '&Save as '+ aMimeType[i] action;
                     MsgInfo( iif( gSave( hPicture, cPicture+".jpeg", _PICT_INFO, "image/jpeg", 90 ), "Saved", "Failure" ), "Result" )
               endif

               if "gif" $ aMimeType[i]
                  menuitem '&Save as '+ aMimeType[i] action ;
                     MsgInfo( iif( gSave( hPicture, cPicture+".gif", _PICT_INFO, "image/gif", 100 ), "Saved", "Failure" ), "Result" )
               endif

               if "tif" $ aMimeType[i]
                  menuitem '&Save as '+ aMimeType[i] action ;
                     MsgInfo( iif( gSave( hPicture, cPicture+".tif", _PICT_INFO, "image/tiff", 100 ), "Saved", "Failure" ), "Result" )
               endif

               if "png" $ aMimeType[i]
                  menuitem '&Save as '+ aMimeType[i] action ;
                     MsgInfo( iif( gSave( hPicture, cPicture+".png", _PICT_INFO, "image/png", 100 ), "Saved", "Failure" ), "Result" )
               endif
            endif
         next 

         separator

         menuitem "E&xit" action ( DeleteObject( hPicture ), ThisWindow.Release )
      end popup

      define popup "&?" 
         menuitem '&Get number of image coders' action ;
            MsgInfo( "Number of image coders"  + c1Tab + ": " + NTrim( gPlusGetEncodersNum() ), "Info" )

         menuitem '&Get size of image coders array in bytes' action ;
            MsgInfo( "Size of image coders array (in bytes)"  + c1Tab + ": " + NTrim( gPlusGetEncodersSize() ), "Info" )

         MENUITEM "&BMP Info"  ACTION s_GetImageInfo( GetStartupFolder() + "\demo.bmp" )
         MENUITEM "&JPEG Info" ACTION s_GetImageInfo( GetStartupFolder() + "\rainbow.jpg" )
         MENUITEM "&PNG Info"  ACTION s_GetImageInfo( GetStartupFolder() + "\demo.png" )
      end popup
   end menu

return

//////////////////////////////////////////////////////////////////////////////
static procedure s_GetImageInfo( cFile )

   local image 
   local width := 0, height := 0
   local cMsg

   if StatusOk == GdipLoadImageFromFile( cFile, @image )
      GdipGetImageDimension( image, @width, @height )

      cMsg := "Picture name" + c1Tab + ": " + cFileNoPath( cFile ) + CRLF
      cMsg += "Image Width"  + c1Tab + ": " + NTrim( width ) + CRLF
      cMsg += "Image Height" + c1Tab + ": " + NTrim( height )

      MsgInfo( cMsg, "Image Info" )

      GdipDisposeImage( image )
   endif

return

//////////////////////////////////////////////////////////////////////////////
#pragma BEGINDUMP
/*
 * This source file is part of the hbGdiPlus library source
 * Copyright 2007-2017 P.Chornyj <myorg63@mail.ru>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <mgdefs.h>
#include "hbapiitm.h"
#ifndef __XHARBOUR__
# include "hbwinuni.h"
#else
typedef wchar_t HB_WCHAR;
#endif

typedef enum
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
} GpStatus;

typedef struct
{
   CLSID Clsid;
   GUID  FormatID;
   const unsigned short * CodecName;
   const unsigned short * DllName;
   const unsigned short * FormatDescription;
   const unsigned short * FilenameExtension;
   const unsigned short * MimeType;
   ULONG Flags;
   ULONG Version;
   ULONG SigCount;
   ULONG SigSize;
   const unsigned char * SigPattern;
   const unsigned char * SigMask;
} ImageCodecInfo;

typedef struct
{
   GUID   Guid;
   ULONG  NumberOfValues;
   ULONG  Type;
   void * Value;
} ENCODER_PARAMETER;

typedef struct
{
   unsigned int      Count;
   ENCODER_PARAMETER Parameter[ 1 ];
} EncoderParameters;

#define WINGDIPAPI  __stdcall
#define GDIPCONST   const

typedef DWORD ARGB;
typedef void GpBitmap;
typedef void GpImage;
#ifndef IStream
typedef struct IStream IStream;
#endif
typedef GpStatus ( WINGDIPAPI * GetThumbnailImageAbort )( void * );

typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromFile_ptr )( GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateHBITMAPFromBitmap_ptr )( GpBitmap *, HBITMAP *, ARGB );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromResource_ptr )( HINSTANCE, GDIPCONST HB_WCHAR *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromStream_ptr )( IStream *, GpBitmap ** );
typedef GpStatus ( WINGDIPAPI * GdipDisposeImage_ptr )( GpImage * );

#define EXTERN_FUNCPTR( name )          extern name##_ptr fn_##name
#define DECLARE_FUNCPTR( name )         name##_ptr fn_##name = NULL
#define ASSIGN_FUNCPTR( module, name )  fn_##name = ( name##_ptr )GetProcAddress( module, #name )
#define _EMPTY_PTR( module, name )      NULL == ( ASSIGN_FUNCPTR( module, name ) )

EXTERN_FUNCPTR( GdipCreateBitmapFromFile );
EXTERN_FUNCPTR( GdipCreateBitmapFromResource );
EXTERN_FUNCPTR( GdipCreateBitmapFromStream );
EXTERN_FUNCPTR( GdipCreateHBITMAPFromBitmap );
EXTERN_FUNCPTR( GdipDisposeImage );

typedef GpStatus ( WINGDIPAPI * GdipGetImageEncodersSize_ptr )( UINT * numEncoders, UINT * size );
typedef GpStatus ( WINGDIPAPI * GdipGetImageEncoders_ptr )( UINT numEncoders, UINT size, ImageCodecInfo * encoders );
typedef GpStatus ( WINGDIPAPI * GdipGetImageThumbnail_ptr )( GpImage * image, UINT thumbWidth, UINT thumbHeight, GpImage ** thumbImage, GetThumbnailImageAbort callback, VOID * callbackData );
typedef GpStatus ( WINGDIPAPI * GdipCreateBitmapFromHBITMAP_ptr )( HBITMAP hbm, HPALETTE hpal, GpBitmap ** bitmap );
typedef GpStatus ( WINGDIPAPI * GdipSaveImageToFile_ptr )( GpImage * image, GDIPCONST HB_WCHAR * filename, GDIPCONST CLSID * clsidEncoder, GDIPCONST EncoderParameters * encoderParams );

DECLARE_FUNCPTR( GdipGetImageEncodersSize );
DECLARE_FUNCPTR( GdipGetImageEncoders );
DECLARE_FUNCPTR( GdipGetImageThumbnail );
DECLARE_FUNCPTR( GdipCreateBitmapFromHBITMAP );
DECLARE_FUNCPTR( GdipSaveImageToFile );

BOOL SaveHBitmapToFile( void * HBitmap, const char * FileName, unsigned int Width, unsigned int Height, const char * MimeType, ULONG JpgQuality );

extern HMODULE  g_GpModule;
unsigned char * MimeTypeOld;

/*
 * GDI+ Local Init
 */
static GpStatus _LoadExt( void )
{
   if( NULL == g_GpModule )
      return FALSE;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageEncodersSize ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageEncoders ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateBitmapFromHBITMAP ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipSaveImageToFile ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipGetImageThumbnail ) )
      return NotImplemented;

   return TRUE;
}

HB_FUNC( _GDIPLUSINITLOCAL )
{
   hb_retl( Ok != _LoadExt() ? HB_TRUE : HB_FALSE );
}

/*
 * Get encoders
 */
HB_FUNC( GPLUSGETENCODERSNUM )
{
   UINT num  = 0;  // number of image encoders
   UINT size = 0;  // size of the image encoder array in bytes

   fn_GdipGetImageEncodersSize( &num, &size );

   hb_retni( num );
}

HB_FUNC( GPLUSGETENCODERSSIZE )
{
   UINT num  = 0;
   UINT size = 0;

   fn_GdipGetImageEncodersSize( &num, &size );

   hb_retni( size );
}

HB_FUNC( GPLUSGETENCODERSMIMETYPE )
{
   UINT num  = 0;
   UINT size = 0;
   UINT i;
   ImageCodecInfo * pImageCodecInfo;
   PHB_ITEM         pResult = hb_itemArrayNew( 0 );
   PHB_ITEM         pItem;
   char * RecvMimeType;

   fn_GdipGetImageEncodersSize( &num, &size );

   if( size == 0 )
   {
      hb_itemReturnRelease( pResult );
      return;
   }

   pImageCodecInfo = ( ImageCodecInfo * ) hb_xalloc( size );

   if( pImageCodecInfo == NULL )
   {
      hb_itemReturnRelease( pResult );
      return;
   }

   RecvMimeType = LocalAlloc( LPTR, size );

   if( RecvMimeType == NULL )
   {
      hb_xfree( pImageCodecInfo );
      hb_itemReturnRelease( pResult );
      return;
   }

   fn_GdipGetImageEncoders( num, size, pImageCodecInfo );

   pItem = hb_itemNew( NULL );

   for( i = 0; i < num; ++i )
   {
      WideCharToMultiByte( CP_ACP, 0, pImageCodecInfo[ i ].MimeType, -1, RecvMimeType, size, NULL, NULL );

      pItem = hb_itemPutC( NULL, RecvMimeType );

      hb_arrayAdd( pResult, pItem );
   }

   // free resource
   LocalFree( RecvMimeType );
   hb_xfree( pImageCodecInfo );

   hb_itemRelease( pItem );

   // return a result array
   hb_itemReturnRelease( pResult );
}

static BOOL GetEnCodecClsid( const char * MimeType, CLSID * Clsid )
{
   UINT num  = 0;
   UINT size = 0;
   ImageCodecInfo * pImageCodecInfo;
   UINT   CodecIndex;
   char * RecvMimeType;
   BOOL   bFounded = FALSE;

   hb_xmemset( Clsid, 0, sizeof( CLSID ) );

   if( ( MimeType == NULL ) || ( Clsid == NULL ) || ( g_GpModule == NULL ) )
      return FALSE;

   if( fn_GdipGetImageEncodersSize( &num, &size ) )
      return FALSE;

   if( ( pImageCodecInfo = hb_xalloc( size ) ) == NULL )
      return FALSE;

   hb_xmemset( pImageCodecInfo, 0, sizeof( ImageCodecInfo ) );

   if( fn_GdipGetImageEncoders( num, size, pImageCodecInfo ) || ( pImageCodecInfo == NULL ) )
   {
      hb_xfree( pImageCodecInfo );

      return FALSE;
   }

   if( ( RecvMimeType = LocalAlloc( LPTR, size ) ) == NULL )
   {
      hb_xfree( pImageCodecInfo );

      return FALSE;
   }

   for( CodecIndex = 0; CodecIndex < num; ++CodecIndex )
   {
      WideCharToMultiByte( CP_ACP, 0, pImageCodecInfo[ CodecIndex ].MimeType, -1, RecvMimeType, size, NULL, NULL );

      if( strcmp( MimeType, RecvMimeType ) == 0 )
      {
         bFounded = TRUE;
         break;
      }
   }

   if( bFounded )
      CopyMemory( Clsid, &pImageCodecInfo[ CodecIndex ].Clsid, sizeof( CLSID ) );

   hb_xfree( pImageCodecInfo );
   LocalFree( RecvMimeType );

   return bFounded ? TRUE : FALSE;
}

/*
 * Save bitmap to file
 */
HB_FUNC( GPLUSSAVEHBITMAPTOFILE )
{
   HBITMAP hbmp = ( HBITMAP ) hb_parnl( 1 );

   hb_retl( SaveHBitmapToFile( ( void * ) hbmp, hb_parc( 2 ), ( UINT ) hb_parnl( 3 ), ( UINT ) hb_parnl( 4 ), hb_parc( 5 ), ( ULONG ) hb_parnl( 6 ) ) );
}

BOOL SaveHBitmapToFile( void * HBitmap, const char * FileName, unsigned int Width, unsigned int Height, const char * MimeType, ULONG JpgQuality )
{
   void *            GBitmap;
   void *            GBitmapThumbnail;
   LPWSTR            WFileName;
   static CLSID      Clsid;
   EncoderParameters EncoderParameters;

   if( ( HBitmap == NULL ) || ( FileName == NULL ) || ( MimeType == NULL ) || ( g_GpModule == NULL ) )
   {
      MessageBox( NULL, "Wrong Param", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   if( MimeTypeOld == NULL )
   {
      if( ! GetEnCodecClsid( MimeType, &Clsid ) )
      {
         MessageBox( NULL, "Wrong MimeType", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      MimeTypeOld = LocalAlloc( LPTR, strlen( MimeType ) + 1 );

      if( MimeTypeOld == NULL )
      {
         MessageBox( NULL, "LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      strcpy( MimeTypeOld, MimeType );
   }
   else
   {
      if( strcmp( MimeTypeOld, MimeType ) != 0 )
      {
         LocalFree( MimeTypeOld );

         if( ! GetEnCodecClsid( MimeType, &Clsid ) )
         {
            MessageBox( NULL, "Wrong MimeType", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

            return FALSE;
         }

         MimeTypeOld = LocalAlloc( LPTR, strlen( MimeType ) + 1 );

         if( MimeTypeOld == NULL )
         {
            MessageBox( NULL, "LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

            return FALSE;
         }
         strcpy( MimeTypeOld, MimeType );
      }
   }

   ZeroMemory( &EncoderParameters, sizeof( EncoderParameters ) );
   EncoderParameters.Count = 1;
   EncoderParameters.Parameter[ 0 ].Guid.Data1      = 0x1d5be4b5;
   EncoderParameters.Parameter[ 0 ].Guid.Data2      = 0xfa4a;
   EncoderParameters.Parameter[ 0 ].Guid.Data3      = 0x452d;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 0 ] = 0x9c;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 1 ] = 0xdd;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 2 ] = 0x5d;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 3 ] = 0xb3;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 4 ] = 0x51;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 5 ] = 0x05;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 6 ] = 0xe7;
   EncoderParameters.Parameter[ 0 ].Guid.Data4[ 7 ] = 0xeb;
   EncoderParameters.Parameter[ 0 ].NumberOfValues  = 1;
   EncoderParameters.Parameter[ 0 ].Type  = 4;
   EncoderParameters.Parameter[ 0 ].Value = ( void * ) &JpgQuality;

   GBitmap = 0;

   if( fn_GdipCreateBitmapFromHBITMAP( HBitmap, NULL, &GBitmap ) )
   {
      MessageBox( NULL, "CreateBitmap Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   WFileName = LocalAlloc( LPTR, ( strlen( FileName ) * sizeof( WCHAR ) ) + 1 );

   if( WFileName == NULL )
   {
      MessageBox( NULL, "WFile LocalAlloc Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   MultiByteToWideChar( CP_ACP, 0, FileName, -1, WFileName, ( strlen( FileName ) * sizeof( WCHAR ) ) - 1 );

   if( ( Width > 0 ) && ( Height > 0 ) )
   {
      GBitmapThumbnail = NULL;

      if( Ok != fn_GdipGetImageThumbnail( GBitmap, Width, Height, &GBitmapThumbnail, NULL, NULL ) )
      {
         fn_GdipDisposeImage( GBitmap );
         LocalFree( WFileName );
         MessageBox( NULL, "Thumbnail Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

         return FALSE;
      }

      fn_GdipDisposeImage( GBitmap );
      GBitmap = GBitmapThumbnail;
   }

   if( Ok != fn_GdipSaveImageToFile( GBitmap, WFileName, &Clsid, &EncoderParameters ) )
   {
      fn_GdipDisposeImage( GBitmap );
      LocalFree( WFileName );
      MessageBox( NULL, "Save Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
   }

   fn_GdipDisposeImage( GBitmap );
   LocalFree( WFileName );

   return TRUE;
}

#pragma ENDDUMP
