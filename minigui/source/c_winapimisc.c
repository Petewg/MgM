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
#define __WIN98__

#include <mgdefs.h>

#include <commctrl.h>
#include <lmcons.h>
#include <shellapi.h>
#include <shlobj.h>
#include <shlwapi.h>

#include "hbapierr.h"
#include "hbapiitm.h"
#include "hbapifs.h"
#include "inkey.ch"

#ifdef __XCC__
char * itoa( int __value, char * __string, int __radix );
#endif

#if defined( _MSC_VER ) && ! defined( __POCC__ )
# define itoa( __value, __string, __radix )  _itoa( __value, __string, __radix )
#endif

#if defined( __XHARBOUR__ )
# define HB_LONGLONG  LONGLONG
extern HB_EXPORT void   hb_evalBlock0( PHB_ITEM pCodeBlock );
#endif
extern HB_EXPORT BOOL Array2Rect( PHB_ITEM aRect, RECT * rc );
extern HB_EXPORT PHB_ITEM Rect2Array( RECT * rc );
extern void hmg_ErrorExit( LPCTSTR lpMessage, DWORD dwError, BOOL bExit );

typedef HMODULE ( __stdcall * SHGETFOLDERPATH )( HWND, int, HANDLE, DWORD, LPTSTR );

BOOL  SysRefresh( void );

/*
   WaitRun function For minigui With Pipe redirection
   Author Luiz Rafael Culik Guimaraes: culikr@uol.com.br
   Parameters WaitRunPipe(cCommand,nShowWindow,cFile)
 */
HB_FUNC( WAITRUNPIPE )
{
   STARTUPINFO StartupInfo;
   PROCESS_INFORMATION ProcessInfo;
   HANDLE ReadPipeHandle;
   HANDLE WritePipeHandle;                // not used here
   char * Data;
   const char *        szFile = ( const char * ) hb_parc( 3 );
   HB_FHANDLE          nHandle;
   SECURITY_ATTRIBUTES sa;

   ZeroMemory( &sa, sizeof( SECURITY_ATTRIBUTES ) );
   sa.nLength              = sizeof( SECURITY_ATTRIBUTES );
   sa.bInheritHandle       = 1;
   sa.lpSecurityDescriptor = NULL;

   memset( &StartupInfo, 0, sizeof( StartupInfo ) );
   memset( &ProcessInfo, 0, sizeof( ProcessInfo ) );

   if( ! hb_fsFile( szFile ) )
      nHandle = hb_fsCreate( szFile, 0 );
   else
   {
      nHandle = hb_fsOpen( szFile, 2 );
      hb_fsSeek( nHandle, 0, 2 );
   }

   if( ! CreatePipe( &ReadPipeHandle, &WritePipeHandle, &sa, 0 ) )
      hb_retnl( -1 );

   ProcessInfo.hProcess    = INVALID_HANDLE_VALUE;
   ProcessInfo.hThread     = INVALID_HANDLE_VALUE;
   StartupInfo.dwFlags     = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
   StartupInfo.wShowWindow = ( WORD ) hb_parni( 2 );
   StartupInfo.hStdOutput  = WritePipeHandle;
   StartupInfo.hStdError   = WritePipeHandle;

   if( ! CreateProcess( 0, ( char * ) hb_parc( 1 ), 0, 0, FALSE, CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS, 0, 0, &StartupInfo, &ProcessInfo ) )
      hb_retnl( -1 );

   Data = ( char * ) hb_xgrab( 1024 );
   for(;; )
   {
      DWORD BytesRead;
      DWORD TotalBytes;
      DWORD BytesLeft;

      //Check for the presence of data in the pipe
      if( ! PeekNamedPipe( ReadPipeHandle, Data, sizeof( Data ), &BytesRead, &TotalBytes, &BytesLeft ) )
         hb_retnl( -1 );

      //If there is bytes, read them
      if( BytesRead )
      {
         if( ! ReadFile( ReadPipeHandle, Data, sizeof( Data ) - 1, &BytesRead, NULL ) )
            hb_retnl( -1 );

         Data[ BytesRead ] = '\0';
         hb_fsWriteLarge( nHandle, Data, BytesRead );
      }
      else
      //Is the console app terminated?
      if( WaitForSingleObject( ProcessInfo.hProcess, 0 ) == WAIT_OBJECT_0 )
         break;

   }

   CloseHandle( ProcessInfo.hThread );
   CloseHandle( ProcessInfo.hProcess );
   CloseHandle( ReadPipeHandle );
   CloseHandle( WritePipeHandle );
   hb_fsClose( nHandle );
   hb_xfree( Data );
}

HB_FUNC( COPYRTFTOCLIPBOARD ) // CopyRtfToClipboard(cRtfText) store cRTFText in Windows clipboard
{
   HGLOBAL      hglbCopy;
   char *       lptstrCopy;
   UINT         cf;
   const char * cStr = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : "";
   int          nLen = strlen( cStr );

   if( ( nLen == 0 ) || ! OpenClipboard( GetActiveWindow() ) )
      return;

   // Get Clipboard format id for RTF.
   cf = RegisterClipboardFormat( "Rich Text Format" );

   EmptyClipboard();

   hglbCopy = GlobalAlloc( GMEM_MOVEABLE | GMEM_DDESHARE, ( nLen + 4 ) * sizeof( TCHAR ) );
   if( hglbCopy == NULL )
   {
      CloseClipboard();
      return;
   }

   lptstrCopy = ( char * ) GlobalLock( hglbCopy );
   memcpy( lptstrCopy, cStr, nLen * sizeof( TCHAR ) );
   lptstrCopy[ nLen ] = ( TCHAR ) 0;  // null character
   GlobalUnlock( hglbCopy );

   SetClipboardData( cf, hglbCopy );
   CloseClipboard();
}

#if ( defined( __WIN98__ ) || defined( __XHARBOUR__ ) )
HB_FUNC( COPYTOCLIPBOARD ) // CopyToClipboard(cText) store cText in Windows clipboard
{
   HGLOBAL hglbCopy;
   char *  lptstrCopy;

   const char * cStr = HB_ISCHAR( 1 ) ? hb_parc( 1 ) : "";
   int          nLen = strlen( cStr );

   if( ( nLen == 0 ) || ! OpenClipboard( GetActiveWindow() ) )
      return;

   EmptyClipboard();

   hglbCopy = GlobalAlloc( GMEM_DDESHARE, ( nLen + 1 ) * sizeof( TCHAR ) );
   if( hglbCopy == NULL )
   {
      CloseClipboard();
      return;
   }

   lptstrCopy = ( char * ) GlobalLock( hglbCopy );
   memcpy( lptstrCopy, cStr, nLen * sizeof( TCHAR ) );
   lptstrCopy[ nLen ] = ( TCHAR ) 0;  // null character
   GlobalUnlock( hglbCopy );

   SetClipboardData( HB_ISNUM( 2 ) ? ( UINT ) hb_parni( 2 ) : CF_TEXT, hglbCopy );
   CloseClipboard();
}

HB_FUNC( RETRIEVETEXTFROMCLIPBOARD )
{
   HGLOBAL hClipMem;
   LPSTR   lpClip;

   if( IsClipboardFormatAvailable( CF_TEXT ) && OpenClipboard( GetActiveWindow() ) )
   {
      hClipMem = GetClipboardData( CF_TEXT );
      if( hClipMem )
      {
         lpClip = ( LPSTR ) GlobalLock( hClipMem );
         if( lpClip )
         {
            hb_retc( lpClip );
            GlobalUnlock( hClipMem );
         }
         else
            hb_retc( "" );
      }
      else
         hb_retc( NULL );
      CloseClipboard();
   }
   else
      hb_retc( NULL );
}
#endif /* defined( __WIN98__ ) || defined( __XHARBOUR__ ) */

HB_FUNC( CLEARCLIPBOARD )
{
   if( OpenClipboard( ( HWND ) HB_PARNL( 1 ) ) )
   {
      EmptyClipboard();
      CloseClipboard();
      hb_retl( TRUE );
   }
   else
      hb_retl( FALSE );
}

HB_FUNC( GETBLUE )
{
   hb_retnl( GetBValue( hb_parnl( 1 ) ) );
}

HB_FUNC( GETRED )
{
   hb_retnl( GetRValue( hb_parnl( 1 ) ) );
}

HB_FUNC( GETGREEN )
{
   hb_retnl( GetGValue( hb_parnl( 1 ) ) );
}

HB_FUNC( GETKEYSTATE )
{
   hb_retni( GetKeyState( hb_parni( 1 ) ) );
}

#ifndef USER_TIMER_MINIMUM
# define USER_TIMER_MINIMUM  0x0000000A
#endif
#ifndef USER_TIMER_MAXIMUM
# define USER_TIMER_MAXIMUM  0x7FFFFFFF
#endif

HB_FUNC( INKEYGUI )
{
   UINT     uElapse = hb_parnidef( 1, USER_TIMER_MINIMUM );
   UINT_PTR uTimer;
   MSG      Msg;
   BOOL     bRet, bBreak = FALSE;
   UINT     uRet = 0;

   if( uElapse == 0 )
      uElapse = USER_TIMER_MAXIMUM;

   uTimer = SetTimer( NULL, 0, uElapse, NULL );

   while( ( bRet = GetMessage( &Msg, NULL, 0, 0 ) ) != 0 )
   {
      if( bRet == -1 )
      {
         // handle the error and possibly exit
         hmg_ErrorExit( TEXT( "INKEYGUI" ), 0, TRUE );
      }
      else
      {
         switch( Msg.message )
         {
            case WM_KEYDOWN:
            case WM_SYSKEYDOWN:
               bBreak = TRUE;
               uRet   = Msg.wParam;
               break;
            case WM_TIMER:
               bBreak = ( Msg.wParam == uTimer );
               break;
            case WM_LBUTTONDOWN:
            case WM_RBUTTONDOWN:
               bBreak = TRUE;
               uRet   = ( Msg.message == WM_LBUTTONDOWN ) ? K_LBUTTONDOWN : K_RBUTTONDOWN;
               PostMessage( Msg.hwnd, Msg.message, Msg.wParam, Msg.lParam );
               break;
         }
      }

      if( bBreak )
      {
         KillTimer( NULL, uTimer );
         break;
      }
      else
      {
         TranslateMessage( &Msg );  // Translates virtual key codes
         DispatchMessage( &Msg );   // Dispatches message to window
      }
   }

   hb_retns( uRet );
}

HB_FUNC( GETDC )
{
   HB_RETNL( ( LONG_PTR ) GetDC( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( RELEASEDC )
{
   hb_retl( ReleaseDC( ( HWND ) HB_PARNL( 1 ), ( HDC ) HB_PARNL( 2 ) ) );
}

HB_FUNC( HIWORD )
{
   hb_retni( ( int ) HIWORD( ( DWORD ) hb_parnl( 1 ) ) );
}

HB_FUNC( LOWORD )
{
   hb_retni( ( int ) LOWORD( ( DWORD ) hb_parnl( 1 ) ) );
}

HB_FUNC( C_GETSPECIALFOLDER ) // Contributed By Ryszard Ryüko
{
   char *       lpBuffer = ( char * ) hb_xgrab( MAX_PATH + 1 );
   LPITEMIDLIST pidlBrowse;   // PIDL selected by user

   SHGetSpecialFolderLocation( GetActiveWindow(), hb_parni( 1 ), &pidlBrowse );
   SHGetPathFromIDList( pidlBrowse, lpBuffer );

   hb_retc( lpBuffer );
   hb_xfree( lpBuffer );
}

#ifdef __WIN98__
/*
   Based Upon Code Contributed By Jacek Kubica <kubica@wssl.wroc.pl>
   Updated by Vailton Renato <vailtom@gmail.com>
 */
HB_FUNC( C_GETDLLSPECIALFOLDER )
{
   TCHAR   szPath[ MAX_PATH ];
   HMODULE hModule = LoadLibrary( TEXT( "SHFolder.dll" ) );

   if( hModule )
   {
      SHGETFOLDERPATH fnShGetFolderPath = ( SHGETFOLDERPATH ) GetProcAddress( hModule, "SHGetFolderPathA" );

      if( fnShGetFolderPath )
      {
         if( fnShGetFolderPath( NULL, hb_parni( 1 ), NULL, 0, szPath ) == ( HMODULE ) S_OK )
            hb_retc( szPath );
         else
            hb_retc( "" );
      }
      FreeLibrary( hModule );
   }
}
#endif /* __WIN98__ */

// Memory Management Functions
typedef BOOL ( WINAPI * GetPhysicallyInstalledSystemMemory_ptr )( ULONGLONG * );

HB_FUNC( GETPHYSICALLYINSTALLEDSYSTEMMEMORY )
{
   HMODULE hDll = GetModuleHandle( TEXT( "kernel32.dll" ) );

   hb_retnll( 0 );

   if( NULL != hDll )
   {
      GetPhysicallyInstalledSystemMemory_ptr fn_GetPhysicallyInstalledSystemMemory =
         ( GetPhysicallyInstalledSystemMemory_ptr ) GetProcAddress( hDll, "GetPhysicallyInstalledSystemMemory" );

      if( NULL != fn_GetPhysicallyInstalledSystemMemory )
      {
         ULONGLONG ullTotalMemoryInKilobytes;

         if( fn_GetPhysicallyInstalledSystemMemory( &ullTotalMemoryInKilobytes ) )
            hb_retnll( ( HB_LONGLONG ) ullTotalMemoryInKilobytes );
      }
   }
}

typedef BOOL ( WINAPI * GlobalMemoryStatusEx_ptr )( MEMORYSTATUSEX * );
#define DIV  ( 1024 * 1024 )

HB_FUNC( MEMORYSTATUS )
{
   HMODULE hDll = GetModuleHandle( TEXT( "kernel32.dll" ) );

   HB_RETNL( 0 );

   if( NULL != hDll )
   {
      GlobalMemoryStatusEx_ptr fn_GlobalMemoryStatusEx =
         ( GlobalMemoryStatusEx_ptr ) GetProcAddress( hDll, "GlobalMemoryStatusEx" );

      if( NULL != fn_GlobalMemoryStatusEx )
      {
         MEMORYSTATUSEX mstex;

         mstex.dwLength = sizeof( mstex );

         if( fn_GlobalMemoryStatusEx( &mstex ) )
         {
            switch( hb_parni( 1 ) )
            {
               case 1:  hb_retnll( mstex.ullTotalPhys / DIV ); break;
               case 2:  hb_retnll( mstex.ullAvailPhys / DIV ); break;
               case 3:  hb_retnll( mstex.ullTotalPageFile / DIV ); break;
               case 4:  hb_retnll( mstex.ullAvailPageFile / DIV ); break;
               case 5:  hb_retnll( mstex.ullTotalVirtual / DIV ); break;
               case 6:  hb_retnll( mstex.ullAvailVirtual / DIV ); break;
            }
         }
      }
      else
      {
         MEMORYSTATUS mst;

         mst.dwLength = sizeof( MEMORYSTATUS );
         GlobalMemoryStatus( &mst );

         switch( hb_parni( 1 ) )
         {
            case 1:  HB_RETNL( mst.dwTotalPhys / DIV ); break;
            case 2:  HB_RETNL( mst.dwAvailPhys / DIV ); break;
            case 3:  HB_RETNL( mst.dwTotalPageFile / DIV ); break;
            case 4:  HB_RETNL( mst.dwAvailPageFile / DIV ); break;
            case 5:  HB_RETNL( mst.dwTotalVirtual / DIV ); break;
            case 6:  HB_RETNL( mst.dwAvailVirtual / DIV ); break;
         }
      }
   }
}

HB_FUNC( SHELLABOUT )
{
   ShellAbout( 0, hb_parc( 1 ), hb_parc( 2 ), ( HICON ) HB_PARNL( 3 ) );
}

HB_FUNC( PAINTBKGND )
{
   HWND   hwnd;
   HBRUSH brush;
   RECT   recClie;
   HDC    hdc;

   hwnd = ( HWND ) HB_PARNL( 1 );
   hdc  = GetDC( hwnd );

   GetClientRect( hwnd, &recClie );

   if( hb_pcount() > 1 && ! HB_ISNIL( 2 ) )
   {
      brush = CreateSolidBrush( RGB( HB_PARNI( 2, 1 ), HB_PARNI( 2, 2 ), HB_PARNI( 2, 3 ) ) );
      FillRect( hdc, &recClie, brush );
   }
   else
   {
      brush = ( HBRUSH ) ( COLOR_BTNFACE + 1 );
      FillRect( hdc, &recClie, brush );
   }

   ReleaseDC( hwnd, hdc );

   HB_RETNL( ( LONG_PTR ) brush );
}

/* Functions Contributed  By Luiz Rafael Culik Guimaraes( culikr@uol.com.br) */
HB_FUNC( GETWINDOWSDIR )
{
   char szBuffer[ MAX_PATH + 1 ] = { 0 };

   GetWindowsDirectory( szBuffer, MAX_PATH );
   hb_retc( szBuffer );
}

HB_FUNC( GETSYSTEMDIR )
{
   char szBuffer[ MAX_PATH + 1 ] = { 0 };

   GetSystemDirectory( szBuffer, MAX_PATH );
   hb_retc( szBuffer );
}

HB_FUNC( GETTEMPDIR )
{
   char szBuffer[ MAX_PATH + 1 ] = { 0 };

   GetTempPath( MAX_PATH, szBuffer );
   hb_retc( szBuffer );
}

HB_FUNC( POSTMESSAGE )
{
   hb_retnl( ( LONG ) PostMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) hb_parni( 2 ), ( WPARAM ) hb_parnl( 3 ), ( LPARAM ) hb_parnl( 4 ) ) );
}

HB_FUNC( DEFWINDOWPROC )
{
   HB_RETNL( ( LONG_PTR ) DefWindowProc( ( HWND ) HB_PARNL( 1 ), ( UINT ) hb_parni( 2 ), ( WPARAM ) hb_parnl( 3 ), ( LPARAM ) hb_parnl( 4 ) ) );
}

HB_FUNC( GETSTOCKOBJECT )
{
   HB_RETNL( ( LONG_PTR ) GetStockObject( hb_parni( 1 ) ) );
}

HB_FUNC( GETNEXTDLGTABITEM )
{
   HB_RETNL( ( LONG_PTR ) GetNextDlgTabItem( ( HWND ) HB_PARNL( 1 ), ( HWND ) HB_PARNL( 2 ), hb_parl( 3 ) ) );
}

HB_FUNC( SHELLEXECUTE )
{
   HB_RETNL
   (
      ( LONG_PTR ) ShellExecute
      (
         ( HWND ) HB_PARNL( 1 ),
         HB_ISNIL( 2 ) ? NULL : ( LPCTSTR ) hb_parc( 2 ),
         ( LPCSTR ) hb_parc( 3 ),
         HB_ISNIL( 4 ) ? NULL : ( LPCTSTR ) hb_parc( 4 ),
         HB_ISNIL( 5 ) ? NULL : ( LPCTSTR ) hb_parc( 5 ),
         hb_parni( 6 )
      )
   );
}

HB_FUNC( WAITRUN )
{
   DWORD dwExitCode;

   STARTUPINFO stInfo;
   PROCESS_INFORMATION prInfo;
   BOOL bResult;

   ZeroMemory( &stInfo, sizeof( stInfo ) );

   stInfo.cb = sizeof( stInfo );

   stInfo.dwFlags = STARTF_USESHOWWINDOW;

   stInfo.wShowWindow = ( WORD ) hb_parni( 2 );

   bResult = CreateProcess( NULL, ( char * ) hb_parc( 1 ), NULL, NULL, TRUE, CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS, NULL, NULL, &stInfo, &prInfo );

   if( ! bResult )
      hb_retl( -1 );

   WaitForSingleObject( prInfo.hProcess, INFINITE );

   GetExitCodeProcess( prInfo.hProcess, &dwExitCode );

   CloseHandle( prInfo.hThread );
   CloseHandle( prInfo.hProcess );

   hb_retnl( dwExitCode );
}

/* WaitRunTerm contributed by Kevin Carmody (i@kevincarmody.com) 2007.11.16 */
HB_FUNC( WAITRUNTERM )
{
   PHB_ITEM    pWaitProc  = hb_param( 4, HB_IT_BLOCK );
   ULONG       ulWaitMsec = ( HB_ISNIL( 5 ) ? 2000 : hb_parnl( 5 ) );
   BOOL        bTerm      = FALSE;
   BOOL        bWait;
   ULONG       ulNoSignal;
   DWORD       dwExitCode;
   STARTUPINFO stInfo;
   PROCESS_INFORMATION prInfo;
   BOOL bResult;

   ZeroMemory( &stInfo, sizeof( stInfo ) );
   stInfo.cb          = sizeof( stInfo );
   stInfo.dwFlags     = STARTF_USESHOWWINDOW;
   stInfo.wShowWindow = ( WORD ) ( HB_ISNIL( 3 ) ? 5 : hb_parni( 3 ) );

   bResult = CreateProcess
             (
      NULL,
      ( char * ) hb_parc( 1 ),
      NULL,
      NULL,
      TRUE,
      CREATE_NEW_CONSOLE | NORMAL_PRIORITY_CLASS,
      NULL,
      HB_ISNIL( 2 ) ? NULL : hb_parc( 2 ),
      &stInfo,
      &prInfo
             );

   if( ! bResult )
      hb_retnl( -2 );

   if( pWaitProc )
   {
      do
      {
         ulNoSignal = WaitForSingleObject( prInfo.hProcess, ulWaitMsec );
         if( ulNoSignal )
         {
            hb_evalBlock0( pWaitProc );
            bWait = hb_parl( -1 );
            if( ! bWait )
            {
               if( TerminateProcess( prInfo.hProcess, 0 ) != 0 )
                  bTerm = TRUE;
               else
                  bWait = TRUE;
            }
         }
         else
            bWait = FALSE;
      }
      while( bWait );
   }
   else
      WaitForSingleObject( prInfo.hProcess, INFINITE );

   if( bTerm )
      dwExitCode = ( DWORD ) -1;
   else
      GetExitCodeProcess( prInfo.hProcess, &dwExitCode );

   CloseHandle( prInfo.hThread );
   CloseHandle( prInfo.hProcess );
   hb_retnl( dwExitCode );
}

HB_FUNC( ISEXERUNNING ) // ( cExeNameCaseSensitive ) --> lResult
{
   HANDLE hMutex = CreateMutex( NULL, FALSE, ( LPTSTR ) hb_parc( 1 ) );

   hb_retl( GetLastError() == ERROR_ALREADY_EXISTS );

   if( hMutex != NULL )
      ReleaseMutex( hMutex );
}

HB_FUNC( SETSCROLLPOS )
{
   hb_retni( SetScrollPos( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), hb_parl( 4 ) ) );
}

HB_FUNC( CREATEFOLDER )
{
   hb_retl( CreateDirectory( ( LPCTSTR ) hb_parc( 1 ), NULL ) );
}

HB_FUNC( SETCURRENTFOLDER )
{
   hb_retl( SetCurrentDirectory( ( LPCTSTR ) hb_parc( 1 ) ) );
}

HB_FUNC( REMOVEFOLDER )
{
   hb_retl( RemoveDirectory( ( LPCSTR ) hb_parc( 1 ) ) );
}

HB_FUNC( GETCURRENTFOLDER )
{
   char Path[ MAX_PATH + 1 ] = { 0 };

   GetCurrentDirectory( MAX_PATH, ( LPSTR ) Path );
   hb_retc( Path );
}

HB_FUNC( CREATESOLIDBRUSH )
{
   HB_RETNL( ( LONG_PTR ) CreateSolidBrush( ( COLORREF ) RGB( hb_parni( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) ) );
}

HB_FUNC( SETTEXTCOLOR )
{
   hb_retnl( ( ULONG ) SetTextColor( ( HDC ) HB_PARNL( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) ) );
}

HB_FUNC( SETBKCOLOR )
{
   hb_retnl( ( ULONG ) SetBkColor( ( HDC ) HB_PARNL( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) ) );
}

HB_FUNC( GETSYSCOLOR )
{
   hb_retnl( GetSysColor( hb_parni( 1 ) ) );
}

/**************************************************************************************/
/*                                                                                    */
/*  This function returns the Windows Version on which the app calling the function   */
/*  is running.                                                                       */
/*                                                                                    */
/*  The return value is an 4-th dimensinal array containing the OS in the first,      */
/*  the servicepack or the system release number in the second, the build number      */
/*  in the third and extended OS information in the fourth array element.             */
/*                                                                                    */
/**************************************************************************************/
HB_FUNC( WINVERSION )
{
   #if defined( __BORLANDC__ )
   #define VER_SUITE_PERSONAL  0x00000200
   #define VER_SUITE_BLADE     0x00000400
   #endif

   OSVERSIONINFOEX osvi;
   BOOL   bOsVersionInfoEx;
   CHAR * szVersion     = NULL;
   CHAR * szServicePack = NULL;
   CHAR * szBuild       = NULL;
   CHAR   buffer[ 5 ];

   CHAR * szVersionEx = NULL;

   ZeroMemory( &osvi, sizeof( OSVERSIONINFOEX ) );
   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFOEX );

   bOsVersionInfoEx = GetVersionEx( ( OSVERSIONINFO * ) &osvi );
   if( ! bOsVersionInfoEx )
   {
      osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
      if( ! GetVersionEx( ( OSVERSIONINFO * ) &osvi ) )
         szVersion = "Unknown Operating System";
   }

   if( szVersion == NULL )
   {
      switch( osvi.dwPlatformId )
      {
         case VER_PLATFORM_WIN32_NT:
            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 )
               szVersion = "Windows Server 2003 family ";

            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 )
               szVersion = "Windows XP ";

            if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
               szVersion = "Windows 2000 ";

            if( osvi.dwMajorVersion <= 4 )
               szVersion = "Windows NT ";

            if( bOsVersionInfoEx )
            {
               if( osvi.wProductType == VER_NT_WORKSTATION )
               {
                  if( osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0 )
                     szVersion = "Windows 10 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 3 )
                     szVersion = "Windows 8.1 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 2 )
                     szVersion = "Windows 8 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 1 )
                     szVersion = "Windows 7 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 0 )
                     szVersion = "Windows Vista ";
                  else if( osvi.dwMajorVersion == 4 )
                     szVersionEx = "Workstation 4.0 ";
                  else if( osvi.wSuiteMask & VER_SUITE_PERSONAL )
                     szVersionEx = "Home Edition ";
                  else
                     szVersionEx = "Professional ";
               }
               else if( osvi.wProductType == VER_NT_SERVER )
               {
                  if( osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0 )
                     szVersion = "Windows Server 2016 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 3 )
                     szVersion = "Windows Server 2012 R2 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 2 )
                     szVersion = "Windows Server 2012 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 1 )
                     szVersion = "Windows Server 2008 R2 ";
                  else if( osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 0 )
                     szVersion = "Windows Server 2008 ";
                  else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 )
                  {
                     if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                        szVersionEx = "Datacenter Edition ";
                     else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                        szVersionEx = "Enterprise Edition ";
                     else if( osvi.wSuiteMask & VER_SUITE_BLADE )
                        szVersionEx = "Web Edition ";
                     else
                        szVersionEx = "Standard Edition ";
                  }
                  else if( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 )
                  {
                     if( osvi.wSuiteMask & VER_SUITE_DATACENTER )
                        szVersionEx = "Datacenter Server ";
                     else if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                        szVersionEx = "Advanced Server ";
                     else
                        szVersionEx = "Server ";
                  }
                  else
                  {
                     if( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
                        szVersionEx = "Server 4.0, Enterprise Edition ";
                     else
                        szVersionEx = "Server 4.0 ";
                  }
               }
            }
            else
            {
               HKEY  hKey;
               char  szProductType[ 80 ];
               DWORD dwBufLen = 80;
               LONG  lRetVal;

               lRetVal = RegOpenKeyEx( HKEY_LOCAL_MACHINE, "SYSTEM\\CurrentControlSet\\Control\\ProductOptions", 0, KEY_QUERY_VALUE, &hKey );

               if( lRetVal != ERROR_SUCCESS )
                  szVersion = "Unknown Operating System";
               else
               {
                  lRetVal = RegQueryValueEx( hKey, "ProductType", NULL, NULL, ( LPBYTE ) szProductType, &dwBufLen );
                  if( ( lRetVal != ERROR_SUCCESS ) || ( dwBufLen > 80 ) )
                     szVersion = "Unknown Operating System";
               }

               RegCloseKey( hKey );

               if( szVersion != ( CHAR * ) "Unknown Operating System" )
               {
                  if( lstrcmpi( "WINNT", szProductType ) == 0 )
                     szVersionEx = "Workstation ";

                  if( lstrcmpi( "LANMANNT", szProductType ) == 0 )
                     szVersionEx = "Server ";

                  if( lstrcmpi( "SERVERNT", szProductType ) == 0 )
                     szVersionEx = "Advanced Server ";

                  szVersion = strcat( szVersion, itoa( osvi.dwMajorVersion, buffer, 10 ) );
                  szVersion = strcat( szVersion, "." );
                  szVersion = strcat( szVersion, itoa( osvi.dwMinorVersion, buffer, 10 ) );
               }
            }

            if( osvi.dwMajorVersion == 4 && lstrcmpi( osvi.szCSDVersion, "Service Pack 6" ) == 0 )
            {
               HKEY hKey;
               LONG lRetVal;

               lRetVal = RegOpenKeyEx
                         (
                  HKEY_LOCAL_MACHINE,
                  "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Hotfix\\Q246009",
                  0,
                  KEY_QUERY_VALUE,
                  &hKey
                         );
               if( lRetVal == ERROR_SUCCESS )
               {
                  szServicePack = "Service Pack 6a";
                  szBuild       = itoa( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
               }
               else
               {
                  szServicePack = osvi.szCSDVersion;
                  szBuild       = itoa( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
               }

               RegCloseKey( hKey );
            }
            else
            {
               szServicePack = osvi.szCSDVersion;
               szBuild       = itoa( osvi.dwBuildNumber & 0xFFFF, buffer, 10 );
            }
            break;

         case VER_PLATFORM_WIN32_WINDOWS:
            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 0 ) )
            {
               if( osvi.szCSDVersion[ 1 ] == 'B' )
               {
                  szVersion     = "Windows 95 B";
                  szServicePack = "OSR2";
               }
               else
               {
                  if( osvi.szCSDVersion[ 1 ] == 'C' )
                  {
                     szVersion     = "Windows 95 C";
                     szServicePack = "OSR2";
                  }
                  else
                  {
                     szVersion     = "Windows 95";
                     szServicePack = "OSR1";
                  }
               }

               szBuild = itoa( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }

            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 10 ) )
            {
               if( osvi.szCSDVersion[ 1 ] == 'A' )
               {
                  szVersion     = "Windows 98 A";
                  szServicePack = "Second Edition";
               }
               else
               {
                  szVersion     = "Windows 98";
                  szServicePack = "First Edition";
               }

               szBuild = itoa( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }

            if( ( osvi.dwMajorVersion == 4 ) && ( osvi.dwMinorVersion == 90 ) )
            {
               szVersion = "Windows ME";
               szBuild   = itoa( osvi.dwBuildNumber & 0x0000FFFF, buffer, 10 );
            }
            break;
      }
   }

   hb_reta( 4 );
   HB_STORC( szVersion, -1, 1 );
   HB_STORC( szServicePack, -1, 2 );
   HB_STORC( szBuild, -1, 3 );
   HB_STORC( szVersionEx, -1, 4 );
}

HB_FUNC( ISWINXPORLATER )
{
   OSVERSIONINFO osvi;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( ( OSVERSIONINFO * ) &osvi );

   hb_retl( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT && ( ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion > 0 ) || ( osvi.dwMajorVersion > 5 ) ) );
}

HB_FUNC( ISVISTAORLATER )
{
   OSVERSIONINFO osvi;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( ( OSVERSIONINFO * ) &osvi );

   hb_retl( osvi.dwMajorVersion >= 6 );
}

HB_FUNC( ISEXE64 ) // Check if our app is 64 bits
{
   hb_retl( ( sizeof( void * ) == 8 ) );
}

HB_FUNC( GETDLLVERSION )
{
   HMODULE hModule;
   DWORD   dwMajorVersion = 0;
   DWORD   dwMinorVersion = 0;
   DWORD   dwBuildNumber  = 0;

   hModule = LoadLibrary( hb_parcx( 1 ) );
   if( hModule )
   {
      DLLGETVERSIONPROC fnDllGetVersion;

      fnDllGetVersion = ( DLLGETVERSIONPROC ) GetProcAddress( hModule, "DllGetVersion" );

      if( fnDllGetVersion )
      {
         DLLVERSIONINFO dvi = { 0 };

         dvi.cbSize = sizeof( dvi );

         if( fnDllGetVersion( &dvi ) == S_OK )
         {
            dwMajorVersion = dvi.dwMajorVersion;
            dwMinorVersion = dvi.dwMinorVersion;
            dwBuildNumber  = dvi.dwBuildNumber;
         }
      }
      else
         MessageBox( NULL, "Cannot get DllGetVersion function.", "DllGetVersion", MB_OK | MB_ICONERROR );

      FreeLibrary( hModule );
   }

   hb_reta( 3 );
   HB_STORVNL( dwMajorVersion, -1, 1 );
   HB_STORVNL( dwMinorVersion, -1, 2 );
   HB_STORVNL( dwBuildNumber, -1, 3 );
}

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.0 Experimental Build 9a
HB_FUNC( SELECTOBJECT )
{
   HB_RETNL( ( LONG_PTR ) SelectObject( ( HDC ) HB_PARNL( 1 ),    // handle of device context
                                        ( HGDIOBJ ) HB_PARNL( 2 ) // handle of object
                                        ) );
}

HB_FUNC( FILLRECT )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC  hDC;
   BOOL bDC = FALSE;

   if( IsWindow( hWnd ) )
   {
      hDC = GetDC( hWnd );
      bDC = TRUE;
   }
   else
      hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   if( GetObjectType( ( HGDIOBJ ) hDC ) == OBJ_DC )
   {
      RECT rc;
      int  iParam = 6;

      if( Array2Rect( hb_param( 2, HB_IT_ANY ), &rc ) )
         iParam = 3;
      else
      {
         rc.left   = hb_parni( 2 );
         rc.top    = hb_parni( 3 );
         rc.right  = hb_parni( 4 );
         rc.bottom = hb_parni( 5 );
      }

      hb_retni( FillRect( hDC, &rc, ( HBRUSH ) HB_PARNL( iParam ) ) );

      if( bDC )
         ReleaseDC( hWnd, hDC );
   }
   else
      hb_retni( 0 );
}

#if defined( __MINGW32__ )
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif  /* __MINGW32__ */

BOOL IsAppHung( IN HWND hWnd, OUT PBOOL pbHung )
{
   OSVERSIONINFO osvi;
   HINSTANCE     hUser;

   if( ! IsWindow( hWnd ) )
      return SetLastError( ERROR_INVALID_PARAMETER ), FALSE;

   osvi.dwOSVersionInfoSize = sizeof( osvi );

   // detect OS version
   GetVersionEx( &osvi );

   // get handle of USER32.DLL
   hUser = GetModuleHandle( TEXT( "user32.dll" ) );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {
      BOOL ( WINAPI * _IsHungAppWindow )( HWND );

      // found the function IsHungAppWindow
      *( FARPROC * )&_IsHungAppWindow =
         GetProcAddress( hUser, "IsHungAppWindow" );
      if( _IsHungAppWindow == NULL )
         return SetLastError( ERROR_PROC_NOT_FOUND ), FALSE;

      // call the function IsHungAppWindow
      *pbHung = _IsHungAppWindow( hWnd );
   }
   else
   {
      DWORD dwThreadId = GetWindowThreadProcessId( hWnd, NULL );

      BOOL ( WINAPI * _IsHungThread )( DWORD );

      // found the function IsHungThread
      *( FARPROC * )&_IsHungThread =
         GetProcAddress( hUser, "IsHungThread" );
      if( _IsHungThread == NULL )
         return SetLastError( ERROR_PROC_NOT_FOUND ), FALSE;

      // call the function IsHungThread
      *pbHung = _IsHungThread( dwThreadId );
   }

   return TRUE;
}

#if defined( __MINGW32__ )
# pragma GCC diagnostic pop
#endif  /* __MINGW32__ */

HB_FUNC( ISAPPHUNG )
{
   BOOL bIsHung;

   if( IsAppHung( ( HWND ) HB_PARNL( 1 ), &bIsHung ) )
      hb_retl( bIsHung );
   else
   {
      if( GetLastError() != ERROR_INVALID_PARAMETER )
      {
         MessageBox( NULL, "Process not found", "Warning", MB_OK | MB_ICONWARNING );
      }
      hb_retl( HB_FALSE );
   }
}

#ifndef PROCESS_QUERY_LIMITED_INFORMATION
  #define PROCESS_QUERY_LIMITED_INFORMATION  ( 0x1000 )
#endif

// EmptyWorkingSet( [ ProcessID ] ) ---> lBoolean
HB_FUNC( EMPTYWORKINGSET )
{
   // It removes as many pages as possible from the process working set (clean the working set memory).
   // This operation is useful primarily for testing and tuning.
   DWORD  ProcessID;
   HANDLE hProcess;

   typedef BOOL ( WINAPI * Func_EmptyWorkingSet )( HANDLE );
   static Func_EmptyWorkingSet pEmptyWorkingSet = NULL;

   if( pEmptyWorkingSet == NULL )
   {
      HMODULE hLib = LoadLibrary( "Kernel32.dll" );
      pEmptyWorkingSet = ( Func_EmptyWorkingSet ) GetProcAddress( hLib, "K32EmptyWorkingSet" );
   }

   if( pEmptyWorkingSet == NULL )
   {
      HMODULE hLib = LoadLibrary( "Psapi.dll" );
      pEmptyWorkingSet = ( Func_EmptyWorkingSet ) GetProcAddress( hLib, "K32EmptyWorkingSet" );
   }

   if( pEmptyWorkingSet != NULL )
   {
      ProcessID = HB_ISNUM( 1 ) ? ( DWORD ) hb_parnl( 1 ) : GetCurrentProcessId();

      hProcess = OpenProcess( PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA, FALSE, ProcessID );
      if( hProcess != NULL )
      {
         hb_retl( ( BOOL ) pEmptyWorkingSet( hProcess ) );

         CloseHandle( hProcess );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );
}

// Grigory Filatov <gfilatov@inbox.ru> HMG 1.1 Experimental Build 10d
HB_FUNC( CLEANPROGRAMMEMORY )
{
   hb_retl( SetProcessWorkingSetSize( GetCurrentProcess(), ( SIZE_T ) -1, ( SIZE_T ) -1 ) );
}

// Grigory Filatov <gfilatov@inbox.ru> HMG 1.1 Experimental Build 11a
typedef INT ( WINAPI * _GETCOMPACTPATH )( LPTSTR pszOut, LPTSTR pszSrc, INT cchMax, DWORD dwFlags );

HB_FUNC( GETCOMPACTPATH )
{
   HINSTANCE handle = LoadLibrary( "shlwapi.dll" );

   if( handle )
   {
      _GETCOMPACTPATH pFunc;
      pFunc = ( _GETCOMPACTPATH ) GetProcAddress( handle, "PathCompactPathExA" );
      hb_retni( pFunc( ( LPTSTR ) hb_parc( 1 ), ( LPTSTR ) hb_parc( 2 ), ( INT ) hb_parni( 3 ), ( DWORD ) hb_parnl( 4 ) ) );
      FreeLibrary( handle );
   }
}

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 11a
HB_FUNC( GETSHORTPATHNAME )
{
   char  buffer[ MAX_PATH + 1 ] = { 0 };
   DWORD iRet;

   iRet = GetShortPathName( hb_parc( 1 ), buffer, MAX_PATH );
   if( iRet < MAX_PATH )
      hb_storclen( buffer, iRet, 2 );
   else
      hb_storc( "", 2 );

   hb_retnl( iRet );
}

HB_FUNC( DRAWTEXT )
{
   char * cText = ( char * ) hb_parc( 2 );
   RECT   rc;

   rc.left   = hb_parni( 3 );
   rc.top    = hb_parni( 4 );
   rc.right  = hb_parni( 5 );
   rc.bottom = hb_parni( 6 );

   DrawText
   (
      ( HDC ) HB_PARNL( 1 ),  // device context
      ( LPCTSTR ) cText,      // pointer to string
      strlen( cText ),        // length of  string
      &rc,                    // rectangle
      hb_parni( 7 )           // draw style
   );
}

HB_FUNC( GETTEXTMETRIC )
{
   TEXTMETRIC tm;
   PHB_ITEM   aMetr = hb_itemArrayNew( 6 );

   GetTextMetrics( ( HDC ) HB_PARNL( 1 ), // handle of device context
                   &tm                    // address of text metrics structure
                   );

   //tmHeight
   //Specifies the height (ascent + descent) of characters.
   HB_arraySetNL( aMetr, 1, tm.tmHeight );

   //tmAveCharWidth Specifies the average width of characters in the font
   //(generally defined as the width of the letter x).
   //This value does not include the overhang required for bold or italic characters.
   HB_arraySetNL( aMetr, 2, tm.tmAveCharWidth );

   //tmMaxCharWidth
   //Specifies the width of the widest character in the font.
   HB_arraySetNL( aMetr, 3, tm.tmMaxCharWidth );

   //tmAscent
   //Specifies the ascent (units above the base line) of characters.
   HB_arraySetNL( aMetr, 4, tm.tmAscent );

   //tmDescent
   //Specifies the descent (units below the base line) of characters.
   HB_arraySetNL( aMetr, 5, tm.tmDescent );

   //tmInternalLeading
   //Specifies the amount of leading (space) inside the bounds set by the tmHeight member.
   //Accent marks and other diacritical characters may occur in this area.
   //The designer may set this member to zero.
   HB_arraySetNL( aMetr, 6, tm.tmInternalLeading );

   hb_itemReturnRelease( aMetr );
}

HB_FUNC( _GETCLIENTRECT )
{
   RECT rc;
   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      GetClientRect( hWnd, &rc );

      hb_itemReturnRelease( Rect2Array( &rc ) );
   }
   else
   {
      hb_errRT_BASE_SubstR( EG_ARG, 0, "MiniGUI Err.", HB_ERR_FUNCNAME, 1, hb_paramError( 1 ) );
   }
}

// Grigory Filatov <gfilatov@inbox.ru> HMG 1.1 Experimental Build 17d
HB_FUNC( ISOEMTEXT )
{
   LPBYTE pString = ( LPBYTE ) hb_parc( 1 );
   WORD   w       = 0, wLen = ( WORD ) hb_parclen( 1 );
   BOOL   bOem    = FALSE;

   while( w < wLen && ! bOem )
   {
      bOem = pString[ w ] >= 128 && pString[ w ] <= 168;
      w++;
   }

   hb_retl( bOem );
}

/*
   Harbour MiniGUI 1.3 Extended (Build 33)
   added by P.Chornyj

   Function GetObjectType()
   ------------------------
   The GetObjectType identifies the type of the specified object.

   Syntax
     GetObjectType( nObject ) --> nType

   Arguments
     nObject is identifies the object

   Returns
     If the function succeeds, the return value identifies the object.
   This value can be one of the following:
     OBJ_PEN         1
     OBJ_BRUSH       2
     OBJ_DC          3
     OBJ_METADC      4
     OBJ_PAL         5
     OBJ_FONT        6
     OBJ_BITMAP      7
     OBJ_REGION      8
     OBJ_METAFILE    9
     OBJ_MEMDC       10
     OBJ_EXTPEN      11
     OBJ_ENHMETADC   12
     OBJ_ENHMETAFILE 13
     OBJ_COLORSPACE  14
 */
HB_FUNC( GETOBJECTTYPE )
{
   HB_RETNL( ( LONG_PTR ) GetObjectType( ( HGDIOBJ ) HB_PARNL( 1 ) ) );
}

/*
   Harbour MiniGUI 1.4 Extended (Build 47)
   added by Grigory Filatov
 */
HB_FUNC( DRAGACCEPTFILES )
{
   DragAcceptFiles( ( HWND ) HB_PARNL( 1 ), hb_parl( 2 ) );
}

HB_FUNC( DRAGQUERYFILES )
{
   HDROP hDrop  = ( HDROP ) HB_PARNL( 1 );
   int   iFiles = DragQueryFile( hDrop, ( UINT ) -1, 0, 0 );
   int   i;
   char  bBuffer[ 250 ];

   hb_reta( iFiles );

   for( i = 0; i < iFiles; i++ )
   {
      DragQueryFile( hDrop, i, ( char * ) bBuffer, 249 );
      HB_STORC( ( char * ) bBuffer, -1, i + 1 );
   }
}

HB_FUNC( DRAGFINISH )
{
   DragFinish( ( HDROP ) HB_PARNL( 1 ) );
}

#ifdef __XCC__

char * itoa( int n, char s[], int base )
{
   int d = n % base;
   int r = n / base;

   if( n < 0 )
   {
      *s++ = '-';
      d    = -d;
      r    = -r;
   }

   if( r )
      s = itoa( r, s, base );

   *s++ = "0123456789abcdefghijklmnopqrstuvwxyz"[ d ];
   *s   = 0;

   return s;
}

#endif /* __XCC__ */
