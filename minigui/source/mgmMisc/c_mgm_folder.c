#include <windows.h>
#include <shlobj.h>

#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#include "hbwapi.h"
// callback procedure of BrowseForFolder()
static int CALLBACK BrowseCallbackProc(HWND hwnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
   (void)(lParam); // pacify gcc 'unused' warning
   
   switch (uMsg)
   {
      case BFFM_INITIALIZED:
      {
         if( lpData ) //if (NULL != lpData)
         {
            SendMessage(hwnd, BFFM_SETSELECTION, TRUE, lpData);
            // we have to add the folowing two lines to force the folder list scroll down to the initial path
            // see: https://connect.microsoft.com/VisualStudio/feedback/details/518103/bffm-setselection-does-not-work-with-shbrowseforfolder-on-windows-7
            Sleep(100);
            PostMessage(hwnd, BFFM_SETSELECTION, TRUE, lpData);
         }
      }
      // case BFFM_SELCHANGED:
        // Sleep(20);
   }
   return 0; // The function should always return 0.
}

// <hwnd> is the parent window.
// <szCurrent> is an optional initial folder. Can be NULL.
// <szPath> receives the selected path on success. Must be MAX_PATH characters in length.
// <lpszTitle> is the optional message showing at top of directory list in browsing dialog
BOOL BrowseForFolder(HWND hwnd, LPCTSTR szCurrent, LPTSTR szPath, LPCTSTR lpszTitle, UINT ulFlags)
{
   BROWSEINFO   bif = { 0 };
   LPITEMIDLIST pidl;
   TCHAR        szDisplay[MAX_PATH];
   BOOL         retval;
   
   bif.hwndOwner      = hwnd;
   bif.pszDisplayName = szDisplay;
   bif.lpszTitle      = lpszTitle;
   bif.ulFlags        = ulFlags;
   bif.lpfn           = BrowseCallbackProc;
   bif.lParam         = (LPARAM) szCurrent;

   CoInitialize( NULL ); // we have to do this before use SHBrowseForFolder()
   
   pidl = SHBrowseForFolder( &bif );

   if (NULL != pidl)
   {
      retval = SHGetPathFromIDList(pidl, szPath);
      CoTaskMemFree(pidl);
   }
   else
   {
      retval = FALSE;
   }

   if (!retval)
   {
      szPath[0] = TEXT('\0');
   }

   CoUninitialize();
   
   return retval;
}

/*
   mgm_BrowseForFolder( [<hWnd>], [<cInitFolder>], [<cTitle>], ;
                        [<lAllowCreateFolder>], [<nFlags>] ) --> cSelectedFolder | NULL string
*/
HB_FUNC( MGM_BROWSEFORFOLDER )
{
   HWND hwnd = HB_ISNIL( 1 ) ? GetActiveWindow() : (HWND) hb_parnl( 1 );
   const char * szCurrent = hb_parc( 2 );
   const char * szTitle = HB_ISCHAR( 3 ) ? hb_parc( 3 ) : "Please choose a folder from the list below...";
   char * szPath = (char*) hb_xgrab( MAX_PATH + 1 );
   UINT ulFlags = hb_parldef( 4, FALSE ) ? 
                  BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE :
                  BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE | BIF_NONEWFOLDERBUTTON; 

   if( HB_ISNUM( 5 ) )
      ulFlags |= hb_parni( 5 );

   if( BrowseForFolder( hwnd, szCurrent, szPath, szTitle, ulFlags ) )
      // add a trailing backslash to selected path, for consistency with 
      // other harbour funcs that return a path.
      hb_strncat( szPath, "\\", (strlen( szPath ) + 1) * sizeof( TCHAR ) );

   hb_retc( szPath );

   hb_xfree( szPath);
}

/* mgm_DirParent( <cDir>, [<nUpLevel> def: 1] ) --> cParentDir | NULL string if no cDir passed
 *    mgm_DirParent( hb_cwd(), 0 ) --> hb_cwd()
 *    mgm_DirParent( hb_cwd(), 1 ) --> one level up of hb_cwd()
 */
HB_FUNC( MGM_DIRPARENT )
{
   if( HB_ISCHAR( 1 ) )
   {
      char * ret_path = hb_strdup( hb_parc( 1 ) );
      int level = hb_parnidef(2, 1);

      do
      {
         char * last_backslash = strrchr(ret_path, '\\');
         if (last_backslash)
            * last_backslash = '\0';
      }
      while( level-- );

      hb_retc( hb_strncat( ret_path, "\\", (strlen( ret_path ) + 1) * sizeof(char) ) );

      hb_xfree( ret_path );
   }
   else
   {
      hb_retc( "" );
   }
}

HB_FUNC( MGM_GETSPECIALFOLDER )
{
   PIDLIST_ABSOLUTE pidlBrowse;
   DWORD dwReserved = 0;
   char * lpBuffer = (char *) hb_xgrab( MAX_PATH + 1 );
   
   SHGetFolderLocation( GetActiveWindow(), hb_parni( 1 ) , NULL , dwReserved , &pidlBrowse );
   SHGetPathFromIDList( pidlBrowse, lpBuffer );

   hb_retc( lpBuffer );
   CoTaskMemFree( pidlBrowse );  
   hb_xfree( lpBuffer );
}

