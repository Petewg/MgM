#include <mgdefs.h>

#include <windows.h>

#include <shlobj.h>

#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#include "hbwapi.h"

//   FUNCTION: WinCenterWindow(HWND, HWND)
//   PURPOSE : Centers one window over another.
//   COMMENTS:
//    This function will center one window over another ensuring that
//    the placement of the window is within the 'working area', meaning
//    that it is both within the display limits of the screen, and not
//    obscured by the tray or other framing elements of the desktop.
BOOL WinCenterWindow( HWND hwndChild, HWND hwndParent )
{
   RECT  rChild, rParent, rWorkArea;
   int   wChild, hChild, wParent, hParent;
   int   xNew, yNew;
   BOOL  bResult;

   // Get the Height and Width of the child window
   GetWindowRect( hwndChild, &rChild );
   wChild = rChild.right - rChild.left;
   hChild = rChild.bottom - rChild.top;
   
   // Get the Height and Width of the parent window
   GetWindowRect( hwndParent, &rParent );
   wParent = rParent.right - rParent.left;
   hParent = rParent.bottom - rParent.top;
   
   // Get the limits of the 'workarea'
   bResult = SystemParametersInfo( SPI_GETWORKAREA,  // system parameter to query or set
                                   sizeof(RECT),
                                   &rWorkArea,
                                   0 );
   if( ! bResult ) 
   {
      rWorkArea.left = rWorkArea.top = 0;
      rWorkArea.right = GetSystemMetrics(SM_CXSCREEN);
      rWorkArea.bottom = GetSystemMetrics(SM_CYSCREEN);
   }
   // Calculate new X position, then adjust for workarea
   xNew = rParent.left + ( (wParent - wChild) / 2 );
   if( xNew < rWorkArea.left ) 
   {
      xNew = rWorkArea.left;
   } 
   else if( (xNew+wChild) > rWorkArea.right ) 
   {
      xNew = rWorkArea.right - wChild;
   }
   // Calculate new Y position, then adjust for workarea
   yNew = rParent.top + ( (hParent - hChild) / 2 );
   if( yNew < rWorkArea.top ) 
   {
      yNew = rWorkArea.top;
   } 
   else if( (yNew+hChild) > rWorkArea.bottom ) 
   {
      yNew = rWorkArea.bottom - hChild;
   }
   // Set it, and return
   return SetWindowPos( hwndChild, NULL, xNew, yNew, 0, 0, SWP_NOSIZE | SWP_NOZORDER );
}

HB_FUNC( MGM_CENTERWIN2WIN )
{
   // HWND hwndChild  = (HWND) hb_parnl( 1 );
   // HWND hwndParent = (HWND) hb_parnl( 2 );
   
   // hb_retl( WinCenterWindow( hwndChild, hwndParent) );
   
   hb_retl( WinCenterWindow( (HWND) hb_parnl( 1 ), (HWND) hb_parnl( 2 ) ) );
}


/* ************************ Windows Enumeration and Process functions ************ */

BOOL CALLBACK EnumWindowsProc( HWND hWnd, LPARAM pArray )
{
   PHB_ITEM pItem = hb_itemPutNLL( NULL, (LONG_PTR) hWnd );
   hb_arrayAddForward ( (PHB_ITEM) pArray, pItem );
   hb_itemRelease ( pItem );
   return TRUE;
}

/* EnumWindows() -> aArray filled with handles of all top-level windows */
HB_FUNC ( ENUMWINDOWS )
{
   PHB_ITEM pArray = hb_itemArrayNew ( 0 );
   EnumWindows( (WNDENUMPROC) EnumWindowsProc, (LPARAM) pArray);
   hb_itemReturnRelease ( pArray );
   pArray = NULL;
}

/* EnumChildWindows( hWnd ) -> aArray filled with handles of all child windows */
HB_FUNC( ENUMCHILDWINDOWS )
{
   HWND hWnd = (HWND) hb_parnl (1); 
   PHB_ITEM pArray = hb_itemArrayNew ( 0 );
   if( hWnd )
      EnumChildWindows( hWnd, (WNDENUMPROC) EnumWindowsProc, (LPARAM) pArray);
   
   hb_itemReturnRelease ( pArray );
   pArray = NULL;
}
/* GetWindowThreadProcessId( hWnd, @nProcessID ) -> nThreadID */
HB_FUNC ( GETWINDOWTHREADPROCESSID )
{
   DWORD lpdwThreadId;
   DWORD lpdwProcessId;
   HWND hWnd = (HWND) hb_parnl (1);
   
   lpdwThreadId = GetWindowThreadProcessId( hWnd, &lpdwProcessId );

   if ( HB_ISBYREF(2) )
        hb_storni (lpdwProcessId, 2);
     
   hb_retni( lpdwThreadId );
}
/* GetProcessFullName ( [ nProcessID ] ) -> cProcessFullName or NIL on error */
HB_FUNC ( GETPROCESSFULLNAME )
{
   typedef BOOL (WINAPI * Func_EnumProcessModules) (HANDLE, HMODULE*, DWORD, LPDWORD);
   static Func_EnumProcessModules pEnumProcessModules = NULL;
   
   if ( pEnumProcessModules == NULL )
   {  
      HMODULE hLib = LoadLibrary ( TEXT( "Psapi.dll" ) );
      pEnumProcessModules = (Func_EnumProcessModules) GetProcAddress(hLib, "EnumProcessModules");
   }
   
   if (pEnumProcessModules == NULL)
       return;

   typedef DWORD (WINAPI * Func_GetModuleFileNameEx) (HANDLE, HMODULE, LPTSTR, DWORD);
   static Func_GetModuleFileNameEx pGetModuleFileNameEx = NULL;
   
   if (pGetModuleFileNameEx == NULL)
   {   
      HMODULE hLib = LoadLibrary( TEXT( "Psapi.dll" ) );
      pGetModuleFileNameEx = (Func_GetModuleFileNameEx) GetProcAddress(hLib, "GetModuleFileNameExA");
   }
   if (pGetModuleFileNameEx == NULL)
      return;

   DWORD ProcessID = HB_ISNUM( 1 ) ? /*(DWORD)*/ hb_parnd( 1 ) : GetCurrentProcessId();
   TCHAR cProcessFullName [ MAX_PATH ] = TEXT("");
   HANDLE hProcess = OpenProcess ( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, ProcessID );
   
   if ( hProcess != NULL )
   {   HMODULE hMod;
       DWORD cbNeeded;
       if ( pEnumProcessModules(hProcess, &hMod, sizeof(hMod), &cbNeeded) )
            pGetModuleFileNameEx(hProcess, hMod, cProcessFullName, sizeof(cProcessFullName)/sizeof(TCHAR));

       CloseHandle (hProcess);
       hb_retc( cProcessFullName );
   }

   return;
}

/* 
   IsWindowUnicode( <hWnd> ) --> .T. | .F. 
     - Determines whether the specified <hWnd> window is a native Unicode window.
*/
HB_FUNC( ISWINDOWUNICODE )
{
   hb_retl( IsWindowUnicode( (HWND) hb_parnl( 1 ) ) );
}
