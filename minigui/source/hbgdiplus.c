/*
   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2007-2017 (C) P.Chornyj <myorg63@mail.ru>
 */

#include <mgdefs.h>

#ifndef __XHARBOUR__
# include "hbwinuni.h"
#else
typedef wchar_t HB_WCHAR;
#endif

#define _HMG_STUB_
# include "hbgdiplus.h"
#undef _HMG_STUB_

DECLARE_FUNCPTR( GdiplusStartup );
DECLARE_FUNCPTR( GdiplusShutdown );

DECLARE_FUNCPTR( GdipCreateBitmapFromFile );
DECLARE_FUNCPTR( GdipCreateBitmapFromResource );
DECLARE_FUNCPTR( GdipCreateBitmapFromStream );
DECLARE_FUNCPTR( GdipCreateHBITMAPFromBitmap );
DECLARE_FUNCPTR( GdipDisposeImage );

HMODULE g_GpModule         = NULL;
static ULONG_PTR g_GpToken = 0;

/**
 */
GpStatus GdiplusInit( void )
{
   LPCTSTR lpFileName = TEXT( "Gdiplus.dll" );
   GDIPLUS_STARTUP_INPUT GdiplusStartupInput = { 1, NULL, FALSE, FALSE };

   if( NULL == g_GpModule )
      g_GpModule = LoadLibrary( lpFileName );

   if( NULL == g_GpModule )
      return GdiplusNotInitialized;

   if( _EMPTY_PTR( g_GpModule, GdiplusStartup ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdiplusShutdown ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateBitmapFromFile ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateBitmapFromResource ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateBitmapFromStream ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateHBITMAPFromBitmap ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDisposeImage ) )
      return NotImplemented;

   return g_GdiplusStartup( &g_GpToken, &GdiplusStartupInput, NULL );
}

HB_FUNC( GDIPLUSSHUTDOWN )
{
   if( NULL != g_GdiplusShutdown )
      g_GdiplusShutdown( g_GpToken );

   if( HB_TRUE == hb_parldef( 1, HB_TRUE ) && ( NULL != g_GpModule ) )
      FreeLibrary( g_GpModule );
}

#if 0
HB_FUNC( GDIPLUSSTARTUP )
{
   hb_retni( ( int ) GdiplusInit() );
}
#endif
