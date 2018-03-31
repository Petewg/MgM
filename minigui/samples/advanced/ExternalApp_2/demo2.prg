/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

#define WM_CLOSE 16

#xtranslate ExternalApp.FILENAME         => "NOTEPAD.EXE"
#xtranslate ExternalApp.FULLFILENAME     => GetWindowsDir()+"\"+ExternalApp.FILENAME
#xtranslate ExternalApp.HANDLE           => _HMG_ExternalAppGetHandle()
#xtranslate ExternalApp.OPEN [ SHOW ]    => EXECUTE FILE ExternalApp.FULLFILENAME
#xtranslate ExternalApp.OPEN   HIDE      => EXECUTE FILE ExternalApp.FULLFILENAME HIDE
#xtranslate ExternalApp.RELEASE          => PostMessage (ExternalApp.HANDLE, WM_CLOSE, 0, 0)
#xtranslate ExternalApp.TITLE            => GetWindowText (ExternalApp.HANDLE)
#xtranslate ExternalApp.TITLE := <arg>   => SetWindowText (ExternalApp.HANDLE, <arg>)
#xtranslate ExternalApp.SHOW             => ShowWindow (ExternalApp.HANDLE)
#xtranslate ExternalApp.HIDE             => HideWindow (ExternalApp.HANDLE)
#xtranslate ExternalApp.IsVisible        => IsWindowVisible (ExternalApp.HANDLE)
#xtranslate ExternalApp.IsOpen           => IsValidWindowHandle (ExternalApp.HANDLE)
#xtranslate ExternalApp.IsRelease        => .NOT. ExternalApp.IsOpen
#xtranslate ExternalApp.IsMinimize       => IsMinimized (ExternalApp.HANDLE)
#xtranslate ExternalApp.IsMaximize       => IsMaximized (ExternalApp.HANDLE)

#xtranslate ExternalApp.ROW    => GetWindowRow    ( ExternalApp.HANDLE )
#xtranslate ExternalApp.COL    => GetWindowCol    ( ExternalApp.HANDLE )
#xtranslate ExternalApp.WIDTH  => GetWindowWidth  ( ExternalApp.HANDLE )
#xtranslate ExternalApp.HEIGHT => GetWindowHeight ( ExternalApp.HANDLE )

#xtranslate ExternalApp.ROW    := <arg> => _SetWindowSizePos ( ExternalApp.HANDLE, <arg>,      ,      ,       )
#xtranslate ExternalApp.COL    := <arg> => _SetWindowSizePos ( ExternalApp.HANDLE,      , <arg>,      ,       )
#xtranslate ExternalApp.WIDTH  := <arg> => _SetWindowSizePos ( ExternalApp.HANDLE,      ,      , <arg>,       )
#xtranslate ExternalApp.HEIGHT := <arg> => _SetWindowSizePos ( ExternalApp.HANDLE,      ,      ,      , <arg> )


FUNCTION Main()

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 200 ;
		TITLE "External Application Control" ;
		MAIN ;
		ON INIT StartIt() ;
		ON RELEASE CloseIt()

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	180
			CAPTION 'Minimize/Maximize Notepad' 
			ACTION MinimizeIt()
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	180
			CAPTION 'Hide/Show Notepad' 
			ACTION OnOff_ExternalApp()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	70
			COL	10
			WIDTH	180
			CAPTION 'Set New Width of Notepad' 
			ACTION iif (ExternalApp.IsOpen == .T., ExternalApp.WIDTH := 400, NIL)
		END BUTTON

		DEFINE BUTTON Button_4
			ROW	100
			COL	10
			WIDTH	180
			CAPTION 'Set New Height of Notepad' 
			ACTION iif (ExternalApp.IsOpen == .T., ExternalApp.HEIGHT := 400, NIL)
		END BUTTON

		DEFINE BUTTON Button_5
			ROW	130
			COL	10
			WIDTH	180
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

RETURN Nil


FUNCTION StartIt()

   IF ExternalApp.IsOpen == .F.

      IF .NOT. FILE (ExternalApp.FULLFILENAME)
         RETURN Nil
      ENDIF

      ExternalApp.OPEN   HIDE

      Inkey (1)   // Wait until the application is loaded

      ExternalApp.TITLE := "Notepad - Untitled"
      ExternalApp.SHOW

   ENDIF

RETURN Nil


FUNCTION CloseIt()

    IF ExternalApp.IsOpen == .T.
	ExternalApp.RELEASE
    ENDIF

RETURN Nil


FUNCTION MinimizeIt()

   IF ExternalApp.IsOpen == .T.

	IF ExternalApp.IsMinimize == .T.

		_Maximize( ExternalApp.HANDLE )

	ELSE

		_Minimize( ExternalApp.HANDLE )

	ENDIF

   ENDIF

RETURN Nil


#define GW_OWNER		4

FUNCTION _HMG_ExternalAppGetHandle
STATIC hWnd := 0
LOCAL aWin, i, cFullFileName := ""

   IF IsValidWindowHandle (hWnd) == .F.

      hWnd := 0

      aWin := EnumWindows ()

      FOR i = 1 TO LEN (aWin)

         GetFullFileNameByHandle (aWin [i], @cFullFileName)
         IF GetWindow( aWin [i], GW_OWNER ) = 0 .AND.;  // If it is an owner window
            aWin [i] != Application.Handle .AND.;       // If it is not this app
            UPPER (ExternalApp.FULLFILENAME) $ UPPER (cFullFileName)
            hWnd := aWin [i]
            EXIT
         ENDIF

      NEXT

   ENDIF

RETURN hWnd


PROCEDURE OnOff_ExternalApp

   StartIt()

   IF ExternalApp.IsVisible == .F.
      ExternalApp.SHOW
   ELSE
      ExternalApp.HIDE
   ENDIF

RETURN


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"
#include "hbapiitm.h"

// Routine that gets the module's filename in both Win9x and NT
void GetExeName(HWND hWnd, char *szFileName)
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

HB_FUNC ( GETFULLFILENAMEBYHANDLE )
{
 char szBuffer[ MAX_PATH + 1 ] = {0};

 GetExeName( (HWND) hb_parnl( 1 ), (char *) szBuffer );

 hb_storc( (char *) szBuffer, 2 );
}

static PHB_ITEM pArray;

#if defined( __BORLANDC__ )
   #pragma argsused
#endif

BOOL CALLBACK EnumWindowsProc( HWND hWnd, LPARAM lParam )
{
  PHB_ITEM pHWnd = hb_itemPutNL( NULL, ( LONG ) hWnd ); 
#if defined( __MINGW32__ )
   UNREFERENCED_PARAMETER( lParam );
#endif
   hb_arrayAddForward( pArray, pHWnd );
   hb_itemRelease( pHWnd );

   return TRUE;
}

HB_FUNC ( ENUMWINDOWS )
{
   pArray = hb_itemArrayNew( 0 );

   EnumWindows( ( WNDENUMPROC ) EnumWindowsProc, ( LPARAM ) 0 );

   hb_itemReturnRelease( pArray );
   pArray = NULL;
}

HB_FUNC ( ISMAXIMIZED )
{
   HWND hWnd = (HWND) hb_parnl (1);
   hb_retl ( (BOOL) IsZoomed ( hWnd ) );
}

#pragma ENDDUMP
