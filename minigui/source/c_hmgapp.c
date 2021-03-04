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
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2021, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

   Parts  of  this  code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
 */

#define WINVER  0x0410

#include <mgdefs.h>

#include "shlwapi.h"

#include "hbinit.h"
#include "hbvm.h"

#define _HMG_STUB_
#include "hbgdiplus.h"
#undef _HMG_STUB_

#define PACKVERSION( major, minor )  MAKELONG( minor, major )

extern void hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );
extern GpStatus GdiplusInit( void );

HINSTANCE GetInstance( void );
HMODULE   hmg_LoadLibrarySystem( LPCTSTR pFileName );

// auxiliary functions
TCHAR * hmg_tstrdup( const TCHAR * pszText );
TCHAR * hmg_tstrncat( TCHAR * pDest, const TCHAR * pSource, HB_SIZE nLen );
HB_SIZE hmg_tstrlen( const TCHAR * pText );

static DWORD DllGetVersion( LPCTSTR lpszDllName );
static TCHAR * hmg_FileNameAtSystemDir( const TCHAR * pFileName );

typedef HRESULT ( CALLBACK * _DLLGETVERSIONPROC )( DLLVERSIONINFO2 * );

static HINSTANCE g_hInstance     = NULL;
static DWORD     g_dwComCtl32Ver = 0;

#ifdef __XHARBOUR__
static void hmg_init( void )
#else
static void hmg_init( void * cargo )
#endif
{
   LPCTSTR lpszDllName = TEXT( "ComCtl32.dll" );

#ifndef __XHARBOUR__
   HB_SYMBOL_UNUSED( cargo );
#endif

   if( S_FALSE == CoInitializeEx( NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE | COINIT_SPEED_OVER_MEMORY ) )
      hmg_ErrorExit( TEXT( "hmg_init( void )" ), S_FALSE, TRUE );

   g_dwComCtl32Ver = DllGetVersion( lpszDllName );

   GetInstance();

   if( Ok != GdiplusInit() )
      hmg_ErrorExit( TEXT( "GdiplusInit( void )" ), 0, TRUE );
}

#ifdef __XHARBOUR__
HB_CALL_ON_STARTUP_BEGIN( _hmg_init_ )
hmg_init();
HB_CALL_ON_STARTUP_END( _hmg_init_ )
#else
HB_CALL_ON_STARTUP_BEGIN( _hmg_init_ )
hb_vmAtInit( hmg_init, NULL );
HB_CALL_ON_STARTUP_END( _hmg_init_ )
#endif

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup _hmg_init_
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY  HB_DATASEG_FUNC( _hmg_init_ )
   #include "hbiniseg.h"
#endif

HINSTANCE GetInstance( void )
{
   if( ! g_hInstance )
      g_hInstance = GetModuleHandle( 0 );

   return g_hInstance;
}

static DWORD DllGetVersion( LPCTSTR lpszDllName )
{
   HINSTANCE hinstDll;
   DWORD     dwVersion = 0;

   hinstDll = hmg_LoadLibrarySystem( lpszDllName );

   if( hinstDll )
   {
      _DLLGETVERSIONPROC pDllGetVersion;
      pDllGetVersion = ( _DLLGETVERSIONPROC ) wapi_GetProcAddress( hinstDll, "DllGetVersion" );

      if( pDllGetVersion )
      {
         DLLVERSIONINFO2 dvi;
         HRESULT         hr;

         ZeroMemory( &dvi, sizeof( DLLVERSIONINFO2 ) );

         dvi.info1.cbSize = sizeof( dvi );

         hr = ( *pDllGetVersion )( &dvi );
         if( S_OK == hr )
            dwVersion = PACKVERSION( dvi.info1.dwMajorVersion, dvi.info1.dwMinorVersion );
      }
      FreeLibrary( hinstDll );
   }

   return dwVersion;
}

HB_FUNC( GETINSTANCE )
{
   HB_RETNL( ( LONG_PTR ) g_hInstance );
}

HB_FUNC( GETCOMCTL32DLLVER )
{
   hb_retnint( g_dwComCtl32Ver );
}

HB_FUNC( OLEDATARELEASE )
{
   CoUninitialize();
}

// borrowed from hbwapi.lib [vszakats]
#ifndef LOAD_LIBRARY_SEARCH_SYSTEM32
# define LOAD_LIBRARY_SEARCH_SYSTEM32  0x00000800
#endif

static HB_BOOL win_has_search_system32( void )
{
   HMODULE hKernel32 = GetModuleHandle( TEXT( "kernel32.dll" ) );

   if( hKernel32 )
      return GetProcAddress( hKernel32, "AddDllDirectory" ) != NULL;  /* Detect KB2533623 */

   return HB_FALSE;
}

HMODULE hmg_LoadLibrarySystem( LPCTSTR pFileName )
{
   TCHAR * pLibPath = hmg_FileNameAtSystemDir( pFileName );

   HMODULE h = LoadLibraryEx( pLibPath, NULL, win_has_search_system32() ? LOAD_LIBRARY_SEARCH_SYSTEM32 : LOAD_WITH_ALTERED_SEARCH_PATH );

   hb_xfree( pLibPath );

   return h;
}

static TCHAR * hmg_FileNameAtSystemDir( const TCHAR * pFileName )
{
   UINT nLen = GetSystemDirectory( NULL, 0 );

   if( nLen )
   {
      LPTSTR buffer;

      if( pFileName )
         nLen += ( UINT ) hmg_tstrlen( pFileName ) + 1;

      buffer = ( LPTSTR ) hb_xgrab( nLen * sizeof( TCHAR ) );

      GetSystemDirectory( buffer, nLen );

      if( pFileName )
      {
         hmg_tstrncat( buffer, TEXT( "\\" ), nLen - 1 );
         hmg_tstrncat( buffer, pFileName, nLen - 1 );
      }

      return buffer;
   }
   else
      return hmg_tstrdup( pFileName );
}

TCHAR * hmg_tstrdup( const TCHAR * pszText )
{
   TCHAR * pszDup;
   HB_SIZE nLen;

   nLen = ( hmg_tstrlen( pszText ) + 1 ) * sizeof( TCHAR );

   pszDup = ( TCHAR * ) hb_xgrab( nLen );
   memcpy( pszDup, pszText, nLen );

   return pszDup;
}

TCHAR * hmg_tstrncat( TCHAR * pDest, const TCHAR * pSource, HB_SIZE nLen )
{
   TCHAR * pBuf = pDest;

   pDest[ nLen ] = TEXT( '\0' );

   while( nLen && *pDest )
   {
      pDest++;
      nLen--;
   }

   while( nLen && ( *pDest++ = *pSource++ ) != TEXT( '\0' ) )
      nLen--;

   return pBuf;
}

HB_SIZE hmg_tstrlen( const TCHAR * pText )
{
   HB_SIZE nLen = 0;

   while( pText[ nLen ] != TEXT( '\0' ) )
      ++nLen;

   return nLen;
}
