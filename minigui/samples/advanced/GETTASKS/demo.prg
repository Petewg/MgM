/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Grigory Filatov <gfilatov@inbox.ru>
 *
 */

#include "hmg.ch"

STATIC aTasks := {}

FUNCTION Main()

   LOCAL cTask

   SET WINDOW MAIN FIRST OFF

   EnumChildWindows( GetDesktopWindow() )  // add the all tasks to static array aTasks

   cTask := Achoice( ,,,, ASort( aTasks,,, {|x, y| x[1] < y[1] } ), "Applications in use" )

   IF ! Empty( cTask )
      MsgBox( cTask )
   ENDIF

RETURN NIL

*****************************************************************************
FUNCTION AddTask( hWnd )

   LOCAL cTaskFullName := "", cTaskTitle := GetWindowText( hWnd )

   GetFullFileNameByHandle( hWnd, @cTaskFullName )

   IF hb_FileExists( cTaskFullName ) .AND. IsWindowVisible( hWnd )

      IF AScan( aTasks, { | aTask | aTask[ 2 ] == cTaskFullName } ) == 0 ;
         .AND. !( "Ribbon" $ cTaskTitle ) .OR. ;
         ! Empty( cTaskTitle ) ;
         .AND. IsAlpha( cTaskTitle ) .AND. !( ":\" $ cTaskTitle ) .AND. !( "Ribbon" $ cTaskTitle )

         AAdd( aTasks, { cTaskTitle, cTaskFullName } )

      ENDIF

   ENDIF

RETURN NIL

*****************************************************************************
STATIC FUNCTION EnumChildWindows( hParentWnd )

RETURN C_EnumChildWindows( hParentWnd, { | hWnd | AddTask( hWnd ), .T. } ) // .T. means continue

*****************************************************************************
FUNCTION AChoice( t, l, b, r, aInput, cTitle, dummy, nValue )

   LOCAL aItems := {}

   HB_SYMBOL_UNUSED( t )
   HB_SYMBOL_UNUSED( l )
   HB_SYMBOL_UNUSED( b )
   HB_SYMBOL_UNUSED( r )
   HB_SYMBOL_UNUSED( dummy )

   DEFAULT cTitle TO "Please, select", nValue TO 1

   AEval( aInput, {|x| AAdd( aItems, iif( Empty( x[ 1 ] ), "Empty Title", x[ 1 ] ) + ", " + x[ 2 ] ) } )

   DEFINE WINDOW Win_2 ;
      AT 0, 0 ;
      WIDTH 640 HEIGHT 480 + IF( IsXPThemeActive(), 7, 0 ) ;
      TITLE cTitle ;
      TOPMOST ;
      NOMAXIMIZE NOSIZE ;
      ON INIT Win_2.Button_1.SetFocus

   @ 415, 230 BUTTON Button_1 ;
      CAPTION 'OK' ;
      ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
      WIDTH 80

   @ 415, 335 BUTTON Button_2 ;
      CAPTION 'Cancel' ;
      ACTION {|| nValue := 0, Win_2.Release } ;
      WIDTH 80

   @ 20, 15 LISTBOX List_1 ;
      WIDTH 600 ;
      HEIGHT 380 ;
      ITEMS aItems ;
      VALUE nValue ;
      FONT GetDefaultFontName() ;
      SIZE 10 ;
      ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

   ON KEY ESCAPE ACTION Win_2.Button_2.OnClick

   END WINDOW

   CENTER WINDOW Win_2
   ACTIVATE WINDOW Win_2

RETURN iif( nValue > 0, aItems[ nValue ], "" )

*****************************************************************************
#pragma BEGINDUMP

#include <mgdefs.h>

// Routine that gets the module's filename in both Win9x and NT
void GetExeName( HWND hWnd, char *szFileName )
{
   OSVERSIONINFO osver;
   osver.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
   GetVersionEx(&osver);

   // Get the module's filename
   if(osver.dwPlatformId != VER_PLATFORM_WIN32_NT)
   {
      GetWindowModuleFileNameA(hWnd,szFileName,MAX_PATH);
   }
   else
   {
      // Get module name in NT
      DWORD (WINAPI *lpfnGetModuleFileNameEx)(HANDLE,HMODULE,LPTSTR,DWORD);
      BOOL (WINAPI *lpfnEnumProcessModules)(HANDLE,HMODULE *,DWORD,LPDWORD);
      DWORD dwPID, dwSize;
      HMODULE ahMods[100];
      HINSTANCE  hInstLib;
      HANDLE hProc;

      szFileName[0] = '\0';

      hInstLib = LoadLibraryA("psapi.dll");

      if(hInstLib != NULL)
      {
         GetWindowThreadProcessId(hWnd,&dwPID);

         hProc = OpenProcess(PROCESS_QUERY_INFORMATION|PROCESS_VM_READ,0,dwPID);

         lpfnGetModuleFileNameEx = (DWORD (WINAPI *)(HANDLE, HMODULE,
           LPTSTR, DWORD )) GetProcAddress( hInstLib,
           "GetModuleFileNameExA" ) ;

         lpfnEnumProcessModules = (BOOL(WINAPI *)(HANDLE, HMODULE *,
           DWORD, LPDWORD)) GetProcAddress( hInstLib,
           "EnumProcessModules" ) ;

         lpfnEnumProcessModules(hProc,ahMods,sizeof(ahMods),&dwSize);

         lpfnGetModuleFileNameEx(hProc,ahMods[0],szFileName,_MAX_PATH);
		
         CloseHandle(hProc);

         FreeLibrary(hInstLib);
      }
   }
}

HB_FUNC( GETFULLFILENAMEBYHANDLE )
{
   char szBuffer[ MAX_PATH + 1 ] = {0};

   GetExeName( (HWND) HB_PARNL( 1 ), (char *) szBuffer );

   hb_storc( (char *) szBuffer, 2 );
}

#pragma ENDDUMP
