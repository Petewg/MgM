/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2005-2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM		'JustToTray'
#define COPYRIGHT	' 2005-2015 Grigory Filatov'

#define NTRIM( n )	hb_ntos( n )
#define WM_CLOSE        0x0010

#define GW_HWNDFIRST	0
#define GW_HWNDLAST	1
#define GW_HWNDNEXT	2
#define GW_HWNDPREV	3
#define GW_OWNER	4
#define GW_CHILD	5

#define WM_GETICON      0x007F
#define ICON_SMALL      0
#define ICON_BIG        1
#define GCL_HICON       -14
#define GCL_HICONSM     -34
#define IDI_WINLOGO     32517

#translate cFileName( <cPathMask> ) => cFileNoPath( <cPathMask> )

STATIC nWnd := 1, aList := {}, cINIPath := "", cFilePath := "", cFileTitle := "", cFileParam := ""

*--------------------------------------------------------*
PROCEDURE Main( cCmdLine )
*--------------------------------------------------------*
   LOCAL lNew := .F.

   DEFAULT cCmdLine := ""

   IF !Empty( Val( cCmdLine ) )
      nWnd := Val( cCmdLine )
   ENDIF

   WHILE IsExeRunning( cFileName( hb_argv( 0 ) ) + "_" + NTRIM( nWnd ) )
      nWnd++
   END

   cINIPath := GetStartUpFolder() + "\JustToTray.ini"

   IF File( cINIPath )

      BEGIN INI FILE cINIPath

         GET cFilePath SECTION NTRIM( nWnd ) ENTRY "File" DEFAULT cFilePath
         GET cFileTitle SECTION NTRIM( nWnd ) ENTRY "Title" DEFAULT cFileTitle
         GET cFileParam SECTION NTRIM( nWnd ) ENTRY "Parameter" DEFAULT cFileParam

      END INI

   ENDIF

   IF Empty( cFilePath )

      cFilePath := Getfile( { { "Applications", "*.exe" }, { "All Files", "*.*" } }, ;
         "Select a File", GetWindowsFolder(), .F., .T. )

      IF Empty( cFilePath )
         RETURN
      ENDIF

      lNew := .T.
      BEGIN INI FILE cINIPath

         SET SECTION NTRIM( nWnd ) ENTRY "File" TO cFilePath
         SET SECTION NTRIM( nWnd ) ENTRY "Title" TO cFileTitle
         SET SECTION NTRIM( nWnd ) ENTRY "Parameter" TO cFileParam

      END INI

   ENDIF

   DEFINE WINDOW Form_1 ;
      TITLE PROGRAM ;
      MAIN NOSHOW ;
      ON INIT ( IF( lNew, FindApp( lNew ), FindApp() ), ;
      iif( Empty( aList ), ( StartApp( .T. ), FindApp() ), ), MakeMenu() ) ;
      NOTIFYICON "MAIN" ;
      NOTIFYTOOLTIP PROGRAM ;
      ON NOTIFYCLICK iif( Empty( aList ), StartApp(), IF( Form_1.WinShow.Enabled, RestoreAppWindow(), HideAppWindow() ) )

   END WINDOW

   ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
PROCEDURE MakeMenu()
*--------------------------------------------------------*

   DEFINE NOTIFY MENU OF Form_1

   IF Empty( aList )
      ITEM '&Start ' + cFileTitle ACTION StartApp()
   ELSE
      ITEM '&Show ' + cFileTitle ACTION RestoreAppWindow() NAME WinShow
      ITEM '&Hide ' + cFileTitle ACTION HideAppWindow() NAME WinHide
      ITEM '&Close ' + cFileTitle  ACTION CloseAppWindow()

      Form_1.WinShow.Enabled := .F.
      Form_1.WinHide.Enabled := .T.
   ENDIF
   SEPARATOR
   ITEM '&Mail to author...' ;
      ACTION ShellExecute( 0, "open", "rundll32.exe", ;
      "url.dll,FileProtocolHandler " + ;
      "mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
      "&subject=JustToTray%20Feedback:" + ;
      "&body=How%20are%20you%2C%20Grigory%3F", , 1 )
   ITEM '&About...' ACTION ShellAbout( "", PROGRAM + ' version 1.0.5' + ;
      CRLF + "Copyright " + Chr( 169 ) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
   SEPARATOR
   ITEM 'E&xit'  ACTION iif( lReleaseCheck(), Form_1.Release, )

   END MENU

RETURN

#define IDYES  1
#define IDNO  0
#define IDCANCEL -1
*--------------------------------------------------------*
FUNCTION lReleaseCheck()
*--------------------------------------------------------*
   LOCAL nRet, lRet := .T.

   IF !Empty( aList )

      IF Form_1.WinShow.Enabled

         nRet := MsgYesNoCancel ( 'Do you want to close the session of "' + cFileTitle + '" also?', 'Exit' )

         DO CASE
         CASE nret == IDYES
            PostMessage( aList[ 1 ], WM_CLOSE, 0, 0 )

         CASE nret == IDNO
            RestoreAppWindow()

         OTHERWISE
            lRet := .F.

         ENDCASE

      ENDIF

   ENDIF

RETURN lRet

*--------------------------------------------------------*
PROCEDURE FindApp( ... )
*--------------------------------------------------------*
   LOCAL aTitles := GetTitles( _HMG_MainHandle )
   LOCAL nChoice := AScan( aTitles, {| e| Upper( cFilePath ) == e[ 3 ] .OR. cFileTitle $ e[ 1 ] } )

   IF PCount() > 0

      cFileParam := AllTrim( InputBox( 'Enter parameter:', cFileName( cFilePath ), cFileParam, 60000 ) )

      IF !Empty( cFileParam )

         BEGIN INI FILE cINIPath

            SET SECTION NTRIM( nWnd ) ENTRY "Parameter" TO cFileParam

         END INI

      ENDIF

   ENDIF

   IF Empty( nChoice )
      nChoice := AScan( aTitles, {| e| Token( cFilePath, "\", 3 ) $ e[ 1 ] } )
   ENDIF

   IF Empty( nChoice )
      nChoice := AScan( aTitles, {| e| Token( cFilePath, "\", 4 ) $ e[ 1 ] } )
   ENDIF

   IF Empty( nChoice )
      nChoice := AScan( aTitles, {| e| Token( cFilePath, "\", 5 ) $ e[ 1 ] } )
   ENDIF

   IF !Empty( nChoice ) .AND. Empty( aList )

      IF IsControlDefined( Timer_1, Form_1 )
         Form_1.Timer_1.Release
      ENDIF

      IF Empty( cFileTitle )

         cFileTitle := aTitles[ nChoice ][ 1 ]

         BEGIN INI FILE cINIPath

            SET SECTION NTRIM( nWnd ) ENTRY "Title" TO cFileTitle

         END INI

      ENDIF

      AAdd( aList, aTitles[ nChoice ][ 2 ] )

      ChangeNotifyIcon( _HMG_MainHandle, GetWindowIcon( aList[ 1 ] ), cFileTitle )

      MakeMenu()

      IF !IsControlDefined( Timer_2, Form_1 )

         DEFINE TIMER Timer_2 OF Form_1 ;
            INTERVAL 250 ;
            ACTION iif( IsIconic( aList[ 1 ] ), ( HideAppWindow(), Form_1.Timer_2.Enabled := .F. ), Form_1.Timer_2.Enabled := .T. )

      ENDIF

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE StartApp( lMinimize )
*--------------------------------------------------------*

   DEFAULT lMinimize := .F.

   IF !File( cFilePath )
      cFilePath := GetWindowsFolder() + "\" + cFilePath
   ENDIF
   IF !File( cFilePath )
      cFilePath := GetSystemFolder() + "\" + cFilePath
   ENDIF

   IF File( cFilePath )

      IF Empty( cFileParam )
         IF lMinimize
            EXECUTE OPERATION "open" FILE cFilePath MINIMIZE
         ELSE
            EXECUTE OPERATION "open" FILE cFilePath
         ENDIF
      ELSE
         IF lMinimize
            EXECUTE OPERATION "open" FILE cFilePath PARAMETERS cFileParam MINIMIZE
         ELSE
            EXECUTE OPERATION "open" FILE cFilePath PARAMETERS cFileParam
         ENDIF
      ENDIF
      DO EVENTS

      IF !IsControlDefined( Timer_1, Form_1 )

         DEFINE TIMER Timer_1 OF Form_1 ;
            INTERVAL 250 ;
            ACTION FindApp()

      ENDIF
   ELSE
      MsgStop( "Can't find an application" + CRLF + cFilePath, "Error" )
   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE CloseAppWindow()
*--------------------------------------------------------*

   IF !Empty( aList )

      IF IsControlDefined( Timer_2, Form_1 )
         Form_1.Timer_2.Release
      ENDIF

      IF Empty( GetWindow( aList[ 1 ], GW_OWNER ) )
         PostMessage( aList[ 1 ], WM_CLOSE, 0, 0 )
      ELSE
         PostMessage( GetParent( aList[ 1 ] ), WM_CLOSE, 0, 0 )
      ENDIF

      aList := {}
      MakeMenu()

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE HideAppWindow()
*--------------------------------------------------------*

   IF !Empty( aList )

      HideWindow( aList[ 1 ] )

      Form_1.WinShow.Enabled := .T.
      Form_1.WinHide.Enabled := .F.
      InkeyGUI()

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE RestoreAppWindow()
*--------------------------------------------------------*

   IF !Empty( aList )

      ShowWindow( aList[ 1 ] )

      IF IsControlDefined( Timer_2, Form_1 ) .AND. Form_1.Timer_2.Enabled == .F.
         _Restore( aList[ 1 ] )
         Form_1.Timer_2.Enabled := .T.
      ENDIF

      Form_1.WinShow.Enabled := .F.
      Form_1.WinHide.Enabled := .T.
      InkeyGUI()

   ENDIF

RETURN

*--------------------------------------------------------*
STATIC FUNCTION GetTitles( hOwnWnd )
*--------------------------------------------------------*
   LOCAL aTasks := {}, cTitle, cExeName := "", ;
      hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )      // Get the first window

   WHILE hWnd != 0                               // Loop through all the windows

      cTitle := GetWindowText( hWnd )

      IF IsWindowVisible( hWnd ) .AND. ;     // If it is a visible window OR
         !Empty( cTitle ) .AND. ;            // If the window has a title
         !"About" $ cTitle .AND. ;
         hWnd != hOwnWnd .AND. ;             // If it is not this app
         !( "DOS Session" $ cTitle ) .AND. ; // If it is not DOS session
         !( cTitle == "Program Manager" )    // If it is not the Program Manager

         GetFullFileNameByHandle( hWnd, @cExeName )
         AAdd( aTasks, { cTitle, hWnd, Upper( cExeName ) } )
      ENDIF

      hWnd := GetWindow( hWnd, GW_HWNDNEXT )     // Get the next window

   ENDDO

RETURN aTasks

*--------------------------------------------------------*
STATIC FUNCTION GetWindowIcon( hwnd )
*--------------------------------------------------------*
   LOCAL icon

   IF Empty( icon := SendMessage( hwnd, WM_GETICON, ICON_SMALL, 0 ) )

      IF Empty( icon := SendMessage( hwnd, WM_GETICON, ICON_BIG, 0 ) )

         IF Empty( icon := GetClassLong( hwnd, GCL_HICONSM ) )

            IF Empty( icon := GetClassLong( hwnd, GCL_HICON ) )

               icon := LoadIcon( , IDI_WINLOGO )

            ENDIF

         ENDIF

      ENDIF

   ENDIF

RETURN icon


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

// Routine that gets the module's filename in both Win9x and NT
void GetExeName( HWND hWnd, char *szFileName )
{
 OSVERSIONINFO osver;
 osver.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
 GetVersionEx( &osver );

 // Get the module's filename
 if( osver.dwPlatformId != VER_PLATFORM_WIN32_NT )
 {
  GetWindowModuleFileNameA( hWnd, szFileName, MAX_PATH );
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

  hInstLib = LoadLibraryA( "psapi.dll" );

  if( hInstLib != NULL )
  {
   GetWindowThreadProcessId( hWnd, &dwPID );

   hProc = OpenProcess( PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, 0, dwPID );

   lpfnGetModuleFileNameEx = (DWORD (WINAPI *)(HANDLE, HMODULE,
     LPTSTR, DWORD )) GetProcAddress( hInstLib, "GetModuleFileNameExA" );

   lpfnEnumProcessModules = (BOOL(WINAPI *)(HANDLE, HMODULE *,
     DWORD, LPDWORD)) GetProcAddress( hInstLib, "EnumProcessModules" );

   lpfnEnumProcessModules( hProc, ahMods, sizeof( ahMods ), &dwSize );

   lpfnGetModuleFileNameEx( hProc, ahMods[0], szFileName, _MAX_PATH );
		
   CloseHandle( hProc );

   FreeLibrary( hInstLib );
  }
 }
}

HB_FUNC( GETFULLFILENAMEBYHANDLE )
{
   char szBuffer[ MAX_PATH + 1 ] = {0};

   GetExeName( ( HWND ) hb_parnl( 1 ), ( char * ) szBuffer );

   hb_storc( ( char * ) szBuffer, 2 );
}

HB_FUNC( GETPARENT )
{
   hb_retnl( (LONG) GetParent( (HWND) hb_parnl( 1 ) ) ) ;
}

HB_FUNC( GETCLASSLONG )
{
   hb_retnl( (LONG) GetClassLong( (HWND) hb_parnl( 1 ), hb_parni( 2 ) ) ) ;
}

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

#pragma ENDDUMP
