/*
 * MiniGUI Process Information Demo
 *
 * Copyright 2014-2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include <hmg.ch>

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

PROCEDURE Main()
   LOCAL fColor  := { |val| iif( val[1] == '<!>', RED, BLACK ) }

   SET FONT TO _GetSysFont(), 10

   DEFINE WINDOW frmProcInfo ;
      WIDTH 650 + iif( IsWinNT(), GetBorderWidth() / 2, 0 ) ;
      HEIGHT 450 + iif( IsWinNT(), GetBorderHeight(), 0 ) ;
      TITLE 'Process Information' ;
      MAIN

      ON KEY ESCAPE ACTION ThisWindow.Release()
      ON KEY DELETE ACTION PROC_Terminate_Process()

      @ 10, 10 GRID grdProcInfo ;
         WIDTH 620 ;
         HEIGHT 400 ;
         HEADERS { 'Hung', 'Prc.ID', 'Name', 'Full Name' } ;
         WIDTHS { 30, 50, 118, 400 };
         ITEMS {} ;
         JUSTIFY { 0, 1, 0, 0 } ;
         ON DBLCLICK PROC_Terminate_Process() ;
         DYNAMICFORECOLOR { fColor , fColor, fColor, fColor } ;
         PAINTDOUBLEBUFFER

      DEFINE TIMER Timer_1 INTERVAL 2000 ACTION FillGrid()

   END WINDOW // frmProcInfo

   FillGrid( 32 )

   CENTER Window frmProcInfo

   ACTIVATE Window frmProcInfo

RETURN // ProcInfo.Main()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

PROCEDURE FillGrid( nMin )
   LOCAL aProcess := iif( IsWinNT(), GetProcessesNT(), GetProcessesW9x() ), ;
      nProcID, nCurItem := 1
   LOCAL i, cFullFileName, hWnd

   DEFAULT nMin := 64

   frmProcInfo.grdProcInfo.DisableUpdate()

   IF frmProcInfo.grdProcInfo.ItemCount > 0

      nCurItem := GetProperty( 'frmProcInfo', 'grdProcInfo', 'Value' )

      frmProcInfo.grdProcInfo.DeleteAllItems()

   ENDIF

   FOR i := 1 TO Len( aProcess ) STEP 2

      nProcID := aProcess[ i ]
      cFullFileName := aProcess[ i + 1 ]

      IF ! Empty( nProcID ) .AND. ! IsExistInList( cFullFileName )

         hWnd := GetAppHandleByFileName( cFullFileName )
         frmProcInfo.grdProcInfo.AddItem( { iif( IsAppHung( hWnd ), '<!>', '' ), ;
            NTOC( nProcID ), ;
            cFileNoPath( cFullFileName ), ;
            cFullFileName } )

      ENDIF

   NEXT

   frmProcInfo.grdProcInfo.EnableUpdate()

   frmProcInfo.grdProcInfo.SetFocus()

   AdjustGrid( nMin, iif( nCurItem < frmProcInfo.grdProcInfo.ItemCount, nCurItem, frmProcInfo.grdProcInfo.ItemCount ) )

RETURN // FillGrid()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

PROCEDURE AdjustGrid( nMin, nItem )
   LOCAL nRows, nHeight, hBrw, nBrwOldH, nBrwNewH

   nRows    := Min( nMin, frmProcInfo.grdProcInfo.ItemCount )
   nHeight  := GetWindowHeight( GetFormHandle( 'frmProcInfo' ) )
   hBrw     := GetControlHandle( 'grdProcInfo', 'frmProcInfo' )
   nBrwOldH := GetWindowHeight( hBrw )
   nBrwNewH := GetWH_ListView( hBrw, nRows )[ 2 ] + iif( IsSeven(), 0, GetBorderHeight() / 2 )

   SetProperty( 'frmProcInfo', 'Height', nHeight - nBrwOldH + nBrwNewH )
   SetProperty( 'frmProcInfo', 'grdProcInfo', 'Height', nBrwNewH )
   SetProperty( 'frmProcInfo', 'grdProcInfo', 'Value', nItem )

RETURN // AdjustGrid()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

FUNCTION IsExistInList( cFullFileName )
   LOCAL i, aItem, lExist := .F.

   FOR i := 1 TO frmProcInfo.grdProcInfo.ItemCount

      aItem := frmProcInfo.grdProcInfo.Item( i )

      IF aItem[ 4 ] == cFullFileName
         lExist := .T.
      ENDIF

   NEXT

RETURN lExist // IsExistInList()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

PROCEDURE PROC_Terminate_Process
   LOCAL nID := Val( frmProcInfo.grdProcInfo.Item( frmProcInfo.grdProcInfo.Value )[ 2 ] )

   IF ! Empty( frmProcInfo.grdProcInfo.Item( frmProcInfo.grdProcInfo.Value )[ 1 ] ) // app is hunging

      IF MsgYesNo( hb_ntos( nID ) + " : " + frmProcInfo.grdProcInfo.Item( frmProcInfo.grdProcInfo.Value )[ 3 ], "Terminate Process" )
         KillProcess( nID )
         FillGrid()
      ENDIF

   ENDIF

RETURN // PROC_Terminate_Process()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.
#define GW_OWNER	4

FUNCTION GetAppHandleByFileName( cFileName )
LOCAL hWnd := 0, hWin, cFullFileName := ""

   FOR EACH hWin IN EnumWindows()

      GetFullFileNameByHandle( hWin, @cFullFileName )

      IF GetWindow( hWin, GW_OWNER ) == 0 .AND. ;  // If it is an owner window
         Upper( cFileName ) $ Upper( cFullFileName )

         hWnd := hWin
         EXIT
      ENDIF

   NEXT

RETURN hWnd // GetAppHandleByFileName()

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

FUNCTION GetWH_ListView( hBrw, nRows )
   LOCAL a

   a    := ListViewApproximateViewRect( hBrw, nRows )
   a[1] += GetBorderWidth () / 2  // Width
   a[2] += GetBorderHeight() / 2  // Height

RETURN a  // { Width, Height }

*- ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._. - ._.

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>
#include "hbapiitm.h"

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

HB_FUNC ( GETFULLFILENAMEBYHANDLE )
{
   char szBuffer[ MAX_PATH + 1 ] = {0};

   GetExeName( ( HWND ) hb_parnl( 1 ), ( char * ) szBuffer );

   hb_storc( ( char * ) szBuffer, 2 );
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

HB_FUNC( LISTVIEWAPPROXIMATEVIEWRECT )
{
   int iCount = hb_parni( 2 ) - 1;
   DWORD Rc;

   Rc = ListView_ApproximateViewRect( ( HWND ) hb_parnl( 1 ), -1, -1, iCount );

   hb_reta( 2 );
   HB_STORNI( LOWORD( Rc ), -1, 1 );
   HB_STORNI( HIWORD( Rc ), -1, 2 );
}

#pragma ENDDUMP
