/*
   test.prg --->>>
   local aVer := GetDllVersion( 'mydemo.dll' )
   local hDll, hIcon

   if aVer[1] >= 2
      hDll := LoadLibraryEx( 'mydemo.dll', 0, LOAD_LIBRARY_AS_DATAFILE )

      if ! Empty( hDll )
         hIcon := LoadIconByName( '1MAIN_ICO', 128, 128, hDll )
         ...
         FreeLibrary( hDll )
      endif
   endif
   <<<---
 */

#include <windows.h>
#define NO_SHLWAPI_STRFCNS
#define NO_SHLWAPI_PATH
#define NO_SHLWAPI_REG
#define NO_SHLWAPI_STREAM
#define NO_SHLWAPI_GDI
#include <shlwapi.h>

__declspec( dllexport ) HRESULT WINAPI DllGetVersion( DLLVERSIONINFO * pdvi )
{
   DLLVERSIONINFO2 * pdvi2 = ( DLLVERSIONINFO2 * ) pdvi;

   if( ! pdvi )
      return E_INVALIDARG;

   switch( pdvi2->info1.cbSize )
   {
      case sizeof( DLLVERSIONINFO2 ):
         pdvi2->dwFlags    = 0;
         pdvi2->ullVersion = MAKEDLLVERULL( 2, 0, 0, 0 );

      case sizeof( DLLVERSIONINFO ):
         pdvi2->info1.dwMajorVersion = 2;
         pdvi2->info1.dwMinorVersion = 0;
         pdvi2->info1.dwBuildNumber  = 0;
         pdvi2->info1.dwPlatformID   = DLLVER_PLATFORM_WINDOWS;
         return S_OK;
   }

   return E_INVALIDARG;
}
