/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2011-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

	IF !gPlusInit()
		MsgStop( "Init GDI+ Error", "Error" )
		RETURN
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 440 + GetBorderWidth() ;
		HEIGHT 300 + GetTitleHeight() + GetBorderHeight() ;
		TITLE 'WebCam Preview Demo' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT CaptureImage() ;  // capture initialization
		ON RELEASE ( CloseWebCam(), iif( gPlusDeInit(), , ;
			MsgAlert( "Exit GDI+ Error", "Error" ) ) )

		@ 20,60 WEBCAM WebCam_1 ;
			WIDTH 250 HEIGHT 210 ;
			RATE 20 ;
			START

		DEFINE IMAGE Image_1
			ROW	120
			COL	280
			WIDTH   150
			HEIGHT  110
			STRETCH .T.
		END IMAGE

		DEFINE BUTTON Button_1
			ROW	10
			COL	20
			WIDTH   120
			CAPTION 'Start WebCam'
			ACTION  CreateWebCam()
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	10
			COL	150
			WIDTH   120
			CAPTION 'Stop WebCam'
			ACTION  CloseWebCam()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	80
			COL	315
			WIDTH   80
			CAPTION 'Capture'
			ACTION  CaptureImage()
		END BUTTON

		DEFINE LABEL Label_1
			ROW	59
			COL	19
			WIDTH   252
			HEIGHT  212
			BORDER  .T.
		END LABEL

		DEFINE LABEL Label_2
			ROW	119
			COL	279
			WIDTH   152
			HEIGHT  112
			BORDER  .T.
		END LABEL

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*-----------------------------------------------------------------------------*
Procedure CreateWebCam
*-----------------------------------------------------------------------------*

	If ! IsControlDefined( WebCam_1, Form_1 )

		@ 20,60 WEBCAM WebCam_1 OF Form_1 ;
			WIDTH 250 HEIGHT 210 ;
			RATE 20

		Form_1.WebCam_1.Start()

		Form_1.Button_3.Enabled := .T.

	EndIf

Return

*-----------------------------------------------------------------------------*
Procedure CloseWebCam
*-----------------------------------------------------------------------------*

	If IsControlDefined( WebCam_1, Form_1 )

		Form_1.WebCam_1.Release()

		Form_1.Button_3.Enabled := .F.

	EndIf

Return

*-----------------------------------------------------------------------------*
Procedure CaptureImage
*-----------------------------------------------------------------------------*
  Local hBitmap
  Local nWidth
  Local nHeight

  If cap_EditCopy( GetControlHandle ( 'WebCam_1', 'Form_1' ) )

     nWidth := GetProperty( "Form_1", "Image_1", "Width" )
     nHeight := GetProperty( "Form_1", "Image_1", "Height" )

     hBitmap := LoadFromClpbrd( GetFormHandle( 'Form_1' ), nWidth, nHeight )

     If !Empty( hBitmap )

        SetImageControl ( "Form_1", "Image_1", hBitmap )

        System.Clipboard := ""

        gPlusSaveHBitmapToFile( hBitmap, "webcam.png", nWidth, nHeight, "image/png", 100 )

     EndIf

  Else

     MsgAlert( 'Capture is failure!', 'Error' )

  EndIf

Return

#define CF_BITMAP     2
*-----------------------------------------------------------------------------*
Static Function LoadFromClpbrd( hWnd, w, h )
*-----------------------------------------------------------------------------*
  Local hBmp

  If OpenClipboard( hWnd )

     hBmp := GetClipboardData( CF_BITMAP, w, h )

     CloseClipboard()

  EndIf

Return( hBmp )

*-----------------------------------------------------------------------------*
Static Procedure SetImageControl (cFormName, cControlImageName, hBitmap)
*-----------------------------------------------------------------------------*
Local hWnd, k

k := GetControlIndex (cControlImageName, cFormName)

IF k > 0
   IF _HMG_aControlBrushHandle [k] <> 0
       DeleteObject (_HMG_aControlBrushHandle [k])
   ENDIF
   _HMG_aControlBrushHandle [k] := hBitmap

   hWnd := GetControlHandle (cControlImageName, cFormName)

   #define STM_SETIMAGE 0x0172
   #define IMAGE_BITMAP 0

   SendMessage (hWnd, STM_SETIMAGE, IMAGE_BITMAP, hBitmap)

   #undef IMAGE_BITMAP
   #undef STM_SETIMAGE
ENDIF

Return


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HBITMAP StretchBitmap( HBITMAP hbmpSrc, int New_Width, int New_Height )
{
   HBITMAP hbmpOldSrc, hbmpOldDest, hbmpNew;
   HDC     hdcSrc, hdcDest;
   BITMAP  bmp;
   POINT   Point;

   hdcSrc = CreateCompatibleDC( NULL );
   hdcDest = CreateCompatibleDC( hdcSrc );

   GetObject( hbmpSrc, sizeof( BITMAP ), &bmp );

   hbmpOldSrc = (HBITMAP) SelectObject( hdcSrc, hbmpSrc );

   hbmpNew = CreateCompatibleBitmap( hdcSrc, New_Width, New_Height );

   hbmpOldDest = (HBITMAP) SelectObject( hdcDest, hbmpNew );

   GetBrushOrgEx( hdcDest, &Point );
   SetStretchBltMode( hdcDest, HALFTONE );
   SetBrushOrgEx( hdcDest, Point.x, Point.y, NULL );

   StretchBlt( hdcDest, 0, 0, New_Width, New_Height, hdcSrc, 0, 0, bmp.bmWidth, bmp.bmHeight, SRCCOPY );

   SelectObject( hdcDest, hbmpOldDest );
   SelectObject( hdcSrc, hbmpOldSrc );

   DeleteDC( hdcDest );
   DeleteDC( hdcSrc );

   return hbmpNew;
}

HB_FUNC( CLOSECLIPBOARD )
{
   hb_retl( CloseClipboard() );
}

HB_FUNC( OPENCLIPBOARD )
{
   hb_retl( OpenClipboard( (HWND) hb_parnl( 1 ) ) ) ;
}

HB_FUNC( GETCLIPBOARDDATA )
{
   WORD wType = hb_parni( 1 );
   HGLOBAL hMem;

   switch( wType )
   {
      case CF_TEXT:
           hMem = GetClipboardData( CF_TEXT );
           if( hMem )
           {
              hb_retc( ( char * ) GlobalLock( hMem ) );
              GlobalUnlock( hMem );
           }
           else
              hb_retc( "" );
           break;

      case CF_BITMAP:
           if( IsClipboardFormatAvailable( CF_BITMAP ) )
              hb_retnl( ( LONG ) StretchBitmap( (HBITMAP) GetClipboardData( CF_BITMAP ), hb_parni( 2 ), hb_parni( 3 ) ) );
           else
              hb_retnl( 0 );
   }
}

#pragma ENDDUMP


#pragma BEGINDUMP

/*
 * This source file is part of the hbGdiPlus library source 
 * Copyright 2007 P.Chornyj <myorg63@mail.ru>
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

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "hbapierr.h"
#include "hbapifs.h"

typedef void(__stdcall* DEBUGEVENTPROC) ( void*, char* );
typedef int(__stdcall* GET_THUMBNAIL_IMAGE_ABORT) ( void* );

typedef struct
{
  UINT GdiPlusVersion;
  DEBUGEVENTPROC DebugEventCallback;
  int SuppressBackgroundThread;
  int SuppressExternalCodecs;
} GDIPLUS_STARTUP_INPUT;

typedef struct
{
  CLSID Clsid;
  GUID FormatID;
  const unsigned short *CodecName;
  const unsigned short *DllName;
  const unsigned short *FormatDescription;
  const unsigned short *FilenameExtension;
  const unsigned short *MimeType;
  ULONG Flags;
  ULONG Version;
  ULONG SigCount;
  ULONG SigSize;
  const unsigned char *SigPattern;
  const unsigned char *SigMask;
} IMAGE_CODEC_INFO;

typedef struct
{
  GUID Guid;
  ULONG NumberOfValues;
  ULONG Type;
  void *Value;
} ENCODER_PARAMETER;

typedef struct
{
  unsigned int Count;
  ENCODER_PARAMETER Parameter[1];
} ENCODER_PARAMETERS;

typedef void* gPlusImage;
typedef gPlusImage * gPlusImagePtr;

typedef LONG(__stdcall* GDIPLUSSTARTUP) ( ULONG*, const GDIPLUS_STARTUP_INPUT*, void* );
typedef void(__stdcall* GDIPPLUSSHUTDOWN) ( ULONG );

typedef LONG(__stdcall* GDIPCREATEBITMAPFROMHBITMAP) ( void*, void*, void** );
typedef LONG(__stdcall* GDIPGETIMAGEENCODERSSIZE) ( unsigned int*, unsigned int* );
typedef LONG(__stdcall* GDIPGETIMAGEENCODERS) ( UINT, UINT, IMAGE_CODEC_INFO* );
typedef LONG(__stdcall* GDIPSAVEIMAGETOFILE) ( void*, const unsigned short*, const CLSID*, const ENCODER_PARAMETERS* );
typedef LONG(__stdcall* GDIPLODIMAGEFROMSTREAM) ( IStream*, void** );
typedef LONG(__stdcall* GDIPCREATEHBITMAPFROMBITMAP) ( void*, void*, ULONG );
typedef LONG(__stdcall* GDIPDISPOSEIMAGE) ( void* );
typedef LONG(__stdcall* GDIPGETIMANGETHUMBNAIL) ( void*, UINT, UINT, void**, GET_THUMBNAIL_IMAGE_ABORT, void* );

typedef LONG(__stdcall* GDIPLOADIMAGEFROMFILE) ( const unsigned short*, void** );
typedef LONG(__stdcall* GDIPGETIMAGEWIDTH) ( void*, UINT* );
typedef LONG(__stdcall* GDIPGETIMAGEHEIGHT) ( void*, UINT* );

BOOL InitDeinitGdiPlus( BOOL );
BOOL LoadGdiPlusDll( void );
BOOL SaveHBitmapToFile( void *, const char *, UINT, UINT, const char *, ULONG );
BOOL GetEnCodecClsid( const char *, CLSID * );
LONG LoadImageFromFile( const char *, void** );

void *GdiPlusHandle;
ULONG GdiPlusToken;
unsigned char *MimeTypeOld;

GDIPLUS_STARTUP_INPUT GdiPlusStartupInput;
GDIPLUSSTARTUP GdiPlusStartup;
GDIPPLUSSHUTDOWN GdiPlusShutdown;
GDIPCREATEBITMAPFROMHBITMAP GdipCreateBitmapFromHBITMAP;
GDIPGETIMAGEENCODERSSIZE GdipGetImageEncodersSize;
GDIPGETIMAGEENCODERS GdipGetImageEncoders;
GDIPSAVEIMAGETOFILE GdipSaveImageToFile;
GDIPLODIMAGEFROMSTREAM GdipLoadImageFromStream;
GDIPCREATEHBITMAPFROMBITMAP GdipCreateHBITMAPFromBitmap;
GDIPDISPOSEIMAGE GdipDisposeImage;
GDIPGETIMANGETHUMBNAIL GdipGetImageThumbnail;
GDIPLOADIMAGEFROMFILE GdipLoadImageFromFile;
GDIPGETIMAGEWIDTH GdipGetImageWidth;
GDIPGETIMAGEHEIGHT GdipGetImageHeight;

/*
   GC
*/
static gPlusImagePtr hb_pargPlusImage( int );
static void hb_retgPlusImage( gPlusImagePtr );

static HB_GARBAGE_FUNC( hb_gPlusImage_Destructor )
{
   /* Retrieve image pointer holder */
   gPlusImagePtr * imPtr = ( gPlusImagePtr * ) Cargo;

   /* Check if pointer is not NULL to avoid multiple freeing */
   if( * imPtr )
   {
      GdipDisposeImage( * imPtr );
      * imPtr = NULL;
   }
}

static const HB_GC_FUNCS s_gcPlusImageFuncs =
{
   hb_gPlusImage_Destructor,
   hb_gcDummyMark
};

static gPlusImagePtr hb_pargPlusImage( int iParam )
{
   gPlusImagePtr * imPtr =
               ( gPlusImagePtr * ) hb_parptrGC( &s_gcPlusImageFuncs, iParam );

   if( imPtr )
      return * imPtr;
   else
      return NULL;
}

static void hb_retgPlusImage( gPlusImagePtr image )
{
   gPlusImagePtr * imPtr;

   imPtr = ( gPlusImagePtr * ) hb_gcAllocate( sizeof( gPlusImagePtr ),
                                        &s_gcPlusImageFuncs );
   * imPtr = image;
   hb_retptrGC( ( void * ) imPtr );
}

/*
   Init/Deinit 
*/
HB_FUNC( GPLUSINIT )
{
  hb_retl( InitDeinitGdiPlus( TRUE ) );
}

HB_FUNC( GPLUSDEINIT )
{
  hb_retl( InitDeinitGdiPlus( FALSE ) );
}

// Init/Deinit tools func
BOOL InitDeinitGdiPlus( BOOL OnOff )
{
  static BOOL InitOK;

  if( !OnOff )
  {
    if( GdiPlusShutdown != NULL )
      GdiPlusShutdown( GdiPlusToken );

    if( GdiPlusHandle != NULL )
      FreeLibrary( GdiPlusHandle );

    InitOK = FALSE;
    GdiPlusToken = 0;

    return TRUE;
  }
  if( InitOK )
    return TRUE;

  if( !LoadGdiPlusDll() )
    return FALSE;

  GdiPlusStartupInput.GdiPlusVersion           = 1;
  GdiPlusStartupInput.DebugEventCallback       = NULL;
  GdiPlusStartupInput.SuppressBackgroundThread = FALSE;
  GdiPlusStartupInput.SuppressExternalCodecs   = FALSE;

  if( GdiPlusStartup( &GdiPlusToken, &GdiPlusStartupInput, NULL ) )
  {
    FreeLibrary( GdiPlusHandle );

    return FALSE;
  }

  InitOK = TRUE;

  return TRUE;
}

BOOL LoadGdiPlusDll( void )
{
  if( GdiPlusHandle != NULL )
    FreeLibrary( GdiPlusHandle );

  if( ( GdiPlusHandle = LoadLibrary( "GdiPlus.dll") ) == NULL )
    return FALSE;

  if( ( GdiPlusStartup = (GDIPLUSSTARTUP) GetProcAddress( GdiPlusHandle, "GdiplusStartup" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdiPlusShutdown = (GDIPPLUSSHUTDOWN) GetProcAddress( GdiPlusHandle, "GdiplusShutdown" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipLoadImageFromStream = (GDIPLODIMAGEFROMSTREAM) GetProcAddress( GdiPlusHandle, "GdipLoadImageFromStream" ) ) == NULL )
  {
    FreeLibrary( GdiPlusHandle );

    return FALSE;
  }

  if( ( GdipCreateHBITMAPFromBitmap = (GDIPCREATEHBITMAPFROMBITMAP) GetProcAddress( GdiPlusHandle, "GdipCreateHBITMAPFromBitmap" ) ) == NULL )
  {
    FreeLibrary( GdiPlusHandle );

    return FALSE;
  }

  if( ( GdipCreateBitmapFromHBITMAP = (GDIPCREATEBITMAPFROMHBITMAP) GetProcAddress( GdiPlusHandle, "GdipCreateBitmapFromHBITMAP" ) ) == NULL )
  {
    FreeLibrary( GdiPlusHandle );

    return FALSE;
  }

  if( ( GdipGetImageEncodersSize = (GDIPGETIMAGEENCODERSSIZE) GetProcAddress( GdiPlusHandle, "GdipGetImageEncodersSize" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipGetImageEncoders = (GDIPGETIMAGEENCODERS) GetProcAddress( GdiPlusHandle, "GdipGetImageEncoders" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipSaveImageToFile = (GDIPSAVEIMAGETOFILE) GetProcAddress( GdiPlusHandle, "GdipSaveImageToFile" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipDisposeImage = (GDIPDISPOSEIMAGE) GetProcAddress( GdiPlusHandle, "GdipDisposeImage" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipGetImageThumbnail = (GDIPGETIMANGETHUMBNAIL) GetProcAddress( GdiPlusHandle, "GdipGetImageThumbnail" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipLoadImageFromFile = (GDIPLOADIMAGEFROMFILE) GetProcAddress( GdiPlusHandle, "GdipLoadImageFromFile" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipGetImageWidth = (GDIPGETIMAGEWIDTH) GetProcAddress( GdiPlusHandle, "GdipGetImageWidth" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  if( ( GdipGetImageHeight = (GDIPGETIMAGEHEIGHT) GetProcAddress( GdiPlusHandle, "GdipGetImageHeight" ) ) == NULL )
  {
    FreeLibrary(GdiPlusHandle);

    return FALSE;
  }

  return TRUE;
}

/*
*/
HB_FUNC( GPLUSGETENCODERSNUM )
{
  UINT  num  = 0;         // number of image encoders
  UINT  size = 0;         // size of the image encoder array in bytes

  GdipGetImageEncodersSize( &num, &size );

  hb_retni( num );
}

HB_FUNC( GPLUSGETENCODERSSIZE )
{
  UINT  num  = 0;     
  UINT  size = 0;     

  GdipGetImageEncodersSize( &num, &size );

  hb_retni( size );
}

HB_FUNC( GPLUSGETENCODERS )
{
  UINT  num  = 0;          
  UINT  size = 0;   
  UINT  i;
  IMAGE_CODEC_INFO *pImageCodecInfo;
  PHB_ITEM pResult = hb_itemArrayNew( 0 );
  PHB_ITEM pItem;
  char *RecvMimeType;

  GdipGetImageEncodersSize( &num, &size );
  if( size == 0 )
  {
#ifdef __XHARBOUR__	
    hb_itemRelease( hb_itemReturn( pResult ) );
#else
    hb_itemReturnRelease( pResult );
#endif
  }

  pImageCodecInfo = (IMAGE_CODEC_INFO *) hb_xalloc( size );
  if( pImageCodecInfo == NULL )
  {
  // return a empty array
#ifdef __XHARBOUR__	
    hb_itemRelease( hb_itemReturn( pResult ) );
#else
    hb_itemReturnRelease( pResult );
#endif
  }

  RecvMimeType = LocalAlloc( LPTR, size );
  if( RecvMimeType == NULL)
  {
    hb_xfree( pImageCodecInfo );
#ifdef __XHARBOUR__	
    hb_itemRelease( hb_itemReturn( pResult ) );
#else
    hb_itemReturnRelease( pResult );
#endif
  }

  GdipGetImageEncoders( num, size, pImageCodecInfo );

  pItem = hb_itemNew( NULL );
  for( i = 0; i < num; ++i )
  {
     WideCharToMultiByte( CP_ACP, 0, pImageCodecInfo[i].MimeType, -1, RecvMimeType, size, NULL, NULL );

     pItem = hb_itemPutC( NULL, RecvMimeType );
     hb_arrayAdd( pResult, pItem );
  } 
  // free resource
  LocalFree( RecvMimeType );
  hb_xfree( pImageCodecInfo );
  hb_itemRelease( pItem );

  // return a result array
#ifdef __XHARBOUR__	
  hb_itemRelease( hb_itemReturn( pResult ) );
#else
  hb_itemReturnRelease( pResult );
#endif
}

/*
*/
HB_FUNC( GPLUSSAVEHBITMAPTOFILE )
{
  HBITMAP hbmp = (HBITMAP) hb_parnl( 1 );

  hb_retl( SaveHBitmapToFile( (void*) hbmp, hb_parc( 2 ), (UINT) hb_parnl( 3 ), (UINT) hb_parnl( 4 ), hb_parc( 5 ), (ULONG) hb_parnl( 6 ) ) );
}

BOOL SaveHBitmapToFile( void *HBitmap, const char *FileName, unsigned int Width,unsigned int Height, const char *MimeType, ULONG JpgQuality )
{
  void *GBitmap;
  void *GBitmapThumbnail;
  LPWSTR WFileName;
  static CLSID Clsid;
  ENCODER_PARAMETERS EncoderParameters;

  if( ( HBitmap == NULL ) || ( FileName == NULL ) || ( MimeType == NULL ) || ( GdiPlusHandle == NULL ) ) 
  {
    MessageBox( NULL, "Wrong Param", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

    return FALSE;
  }

  if ( MimeTypeOld == NULL ) 
  {
    if( !GetEnCodecClsid( MimeType, &Clsid ) )
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

      if( !GetEnCodecClsid( MimeType, &Clsid ) )
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
  EncoderParameters.Count=1;
  EncoderParameters.Parameter[0].Guid.Data1 = 0x1d5be4b5;
  EncoderParameters.Parameter[0].Guid.Data2 = 0xfa4a;
  EncoderParameters.Parameter[0].Guid.Data3 = 0x452d;
  EncoderParameters.Parameter[0].Guid.Data4[0] = 0x9c;
  EncoderParameters.Parameter[0].Guid.Data4[1] = 0xdd;
  EncoderParameters.Parameter[0].Guid.Data4[2] = 0x5d;
  EncoderParameters.Parameter[0].Guid.Data4[3] = 0xb3;
  EncoderParameters.Parameter[0].Guid.Data4[4] = 0x51;
  EncoderParameters.Parameter[0].Guid.Data4[5] = 0x05;
  EncoderParameters.Parameter[0].Guid.Data4[6] = 0xe7;
  EncoderParameters.Parameter[0].Guid.Data4[7] = 0xeb;
  EncoderParameters.Parameter[0].NumberOfValues = 1;
  EncoderParameters.Parameter[0].Type = 4;
  EncoderParameters.Parameter[0].Value = (void*)&JpgQuality;

  GBitmap = 0;

  if( GdipCreateBitmapFromHBITMAP( HBitmap, NULL, &GBitmap ) )
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

  MultiByteToWideChar( CP_ACP, 0, FileName, -1, WFileName, ( strlen( FileName )*sizeof( WCHAR ) ) - 1 ); 

  if( ( Width > 0 ) && ( Height > 0 ) )
  {
    GBitmapThumbnail = NULL;

    if( GdipGetImageThumbnail( GBitmap, Width, Height, &GBitmapThumbnail, NULL, NULL ) )
    {
      GdipDisposeImage(GBitmap);
      LocalFree( WFileName );
      MessageBox( NULL, "Thumbnail Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

      return FALSE;
    }

    GdipDisposeImage( GBitmap );
    GBitmap = GBitmapThumbnail;
  }

  if( GdipSaveImageToFile( GBitmap, WFileName, &Clsid, &EncoderParameters ) != 0 )
  {
    GdipDisposeImage( GBitmap );
    LocalFree( WFileName );
    MessageBox( NULL, "Save Operation Error", "GPlus error", MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL );

    return FALSE;
  }

  GdipDisposeImage( GBitmap );
  LocalFree( WFileName );

  return TRUE;
}

BOOL GetEnCodecClsid( const char *MimeType, CLSID *Clsid )
{
  UINT num  = 0;
  UINT size = 0;
  IMAGE_CODEC_INFO *ImageCodecInfo;
  UINT CodecIndex;
  char *RecvMimeType;
  BOOL OkSearchCodec = FALSE;

  hb_xmemset( Clsid, 0, sizeof( CLSID ) );

  if( ( MimeType == NULL ) || ( Clsid == NULL ) || ( GdiPlusHandle == NULL ) )
    return FALSE;

  if( GdipGetImageEncodersSize( &num, &size ) )
    return FALSE;

  if( ( ImageCodecInfo = hb_xalloc( size ) ) == NULL )
    return FALSE;

  hb_xmemset( ImageCodecInfo, 0, sizeof( IMAGE_CODEC_INFO ) );

  if( GdipGetImageEncoders( num, size, ImageCodecInfo ) || ( ImageCodecInfo == NULL ) )
  {
    hb_xfree( ImageCodecInfo );

    return FALSE;
  }

  if( ( RecvMimeType = LocalAlloc( LPTR, size ) ) == NULL )
  {
    hb_xfree( ImageCodecInfo );

    return FALSE;
  }

  for( CodecIndex = 0; CodecIndex < num; ++CodecIndex )
  {
     WideCharToMultiByte( CP_ACP, 0, ImageCodecInfo[CodecIndex].MimeType, -1, RecvMimeType, size, NULL, NULL );

    if( strcmp( MimeType, RecvMimeType ) == 0 )
    {
      OkSearchCodec = TRUE;
      break;
    }
  }

  if( OkSearchCodec )
    CopyMemory( Clsid, &ImageCodecInfo[CodecIndex].Clsid, sizeof( CLSID ) );

  hb_xfree( ImageCodecInfo );
  LocalFree( RecvMimeType );

  return ( OkSearchCodec ? TRUE : FALSE );
}

/*
   Load Image from disk
*/
HB_FUNC( GPLUSLOADIMAGEFROMFILE )
{
  gPlusImage image;

  if( LoadImageFromFile( hb_parc( 1 ), &image ) == 0 )
    hb_retgPlusImage( image );
  else
    hb_ret( );
}

LONG LoadImageFromFile( const char *FileName, gPlusImagePtr image )
{
  LPWSTR WFileName;
  LONG result;

  WFileName = LocalAlloc( LPTR, ( strlen( FileName ) * sizeof( WCHAR ) ) + 1 );
  if( WFileName == NULL ) 
    return -1L;

  MultiByteToWideChar( CP_ACP, 0, FileName, -1, WFileName, ( strlen( FileName )*sizeof( WCHAR ) ) - 1 ); 

  result = GdipLoadImageFromFile( WFileName, image );

  LocalFree( WFileName );

  return result;
}

/*
   Image Width/Height
*/
HB_FUNC( GPLUSGETIMAGEWIDTH )
{
  gPlusImage image;
  UINT width = 0;

  image = hb_pargPlusImage( 1 );
  if ( image == NULL )
  {
    hb_retni( -1 );
    return;
  }
  GdipGetImageWidth( image, &width );

  hb_retni( width );
}

HB_FUNC( GPLUSGETIMAGEHEIGHT )
{
  gPlusImage image;
  UINT height = 0;

  image = hb_pargPlusImage( 1 );
  if ( image == NULL )
  {
    hb_retni( -1 );
    return;
  }
  GdipGetImageHeight( image, &height );

  hb_retni( height );
}

#pragma ENDUMP
