/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 *
 */

#define _HMG_OUTLOG

#include "minigui.ch"
#include "hbthread.ch"

#define INFINITE        0xFFFFFFFF

// WaitForSingleObject() returns value
#define WAIT_TIMEOUT    0x00000102
#define WAIT_ABANDONED  0x00000080
#define WAIT_OBJECT_0   0x00000000
#define WAIT_OBJECT_1   ( WAIT_OBJECT_0 + 1 )

// for wapi_Find*ChangeNotification
#define FILE_NOTIFY_CHANGE_FILE_NAME  0x00000001
#define FILE_NOTIFY_CHANGE_DIR_NAME   0x00000002
#define FILE_NOTIFY_CHANGE_ATTRIBUTES 0x00000004
#define FILE_NOTIFY_CHANGE_SIZE       0x00000008
#define FILE_NOTIFY_CHANGE_LAST_WRITE 0x00000010
#define FILE_NOTIFY_CHANGE_SECURITY   0x00000100


#define PROGRAM 'Directory Watcher'
#define COPYRIGHT ' Petr Chornyj, 2016'

STATIC lStartWatch := .F.

/*
*/
FUNCTION Main( cDir )

   SET MULTIPLE OFF

   SET LOGFILE TO "dirwatcher.log"

   SET DEFAULT ICON TO "MAIN"

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 0 HEIGHT 0 ;
      TITLE PROGRAM ;
      MAIN NOSHOW ;
      NOTIFYICON "MAIN" ;
      NOTIFYTOOLTIP PROGRAM + ": Right Click for Menu"

   DEFINE NOTIFY MENU
      ITEM '&Start Watch' ACTION StartWatch( cDir )
      SEPARATOR
      ITEM '&Mail to author...' ;
         ACTION ShellExecute( 0, "open", "rundll32.exe", ;
         "url.dll,FileProtocolHandler " + ;
         "mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
         "&subject=Directory%20Watcher%20Feedback:" + ;
         "&body=How%20are%20you%2C%20Grigory%3F", , 1 )
      ITEM '&About...' ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + ' version 1.0' + ;
         CRLF + "Copyright " + Chr( 169 ) + COPYRIGHT, Application.Icon.Handle )
      SEPARATOR
      ITEM 'E&xit'  ACTION Form_1.Release
   END MENU

   END WINDOW

   ACTIVATE WINDOW Form_1

   RETURN NIL
/*
*/
PROCEDURE StartWatch( cDir )

   LOCAL cDirectory

   IF hb_DirExists( cDir )
      cDirectory := cDir
   ELSE
      hb_FNameSplit( hb_DirBase(), @cDirectory )
   ENDIF

   IF !lStartWatch

      lStartWatch := .T.

      IF hb_DirExists( cDirectory )
         IF hb_FileExists( cDirectory + "quit" )
            hb_FileDelete( cDirectory + "quit" )
         ENDIF

         hb_threadDetach( hb_threadStart( HB_THREAD_INHERIT_MEMVARS, @WatchDirectory(), cDirectory ) )
      ENDIF

   ENDIF

   RETURN
/*
*/
FUNCTION WatchDirectory( cDir )

   LOCAL pChangeHandle
   LOCAL nWaitStatus
   LOCAL lRunAnyway := .T.

   // watch file name changes ( file was CREATED, RENAMED or DELETED)
   pChangeHandle := wapi_FindFirstChangeNotification( cDir, .F., FILE_NOTIFY_CHANGE_FILE_NAME )

   IF INVALID_HANDLE_VALUE( pChangeHandle )
      ? "ERROR: FindFirstChangeNotification function failed."
      RETURN wapi_GetLastError()
   ENDIF

   // Change notification is set. Now we can wait on notification handle.
   DO WHILE lRunAnyway
      ? "Waiting for notification..."
      // If the function succeeds, the return value indicates
      // the event that caused the function to return.
      nWaitStatus = wapi_WaitForSingleObject( pChangeHandle, INFINITE )

      SWITCH nWaitStatus

      CASE WAIT_OBJECT_0
         // A file was CREATED, RENAMED or DELETED in the directory.
         // _Refresh_ this directory and _restart_ the notification.
         RefreshDirectory( cDir, @lRunAnyway )

         IF lRunAnyway
            IF ! wapi_FindNextChangeNotification( pChangeHandle )
               ? "ERROR: FindNextChangeNotification function failed."
               RETURN wapi_GetLastError()
            ENDIF
         ELSE
            wapi_FindCloseChangeNotification( pChangeHandle )
         ENDIF

         EXIT

      CASE WAIT_TIMEOUT
         // A timeout occurred, this would happen if some value other
         // than INFINITE is used in the Wait call and no changes occur.
         // In a single-threaded environment you might not want an
         // INFINITE wait.
         ? "No changes in the timeout period."
         EXIT

      OTHERWISE
         ? "ERROR: Unhandled nWaitStatus."
         RETURN wapi_GetLastError()

      ENDSWITCH

   END WHILE
   ? "EXIT: Quit signal was received."

   RETURN 0
/*
*/
PROCEDURE RefreshDirectory( cDir, lRunAnyway )

   // This is where you might place code to refresh your
   // directory listing, but not the subtree because it
   // would not be necessary.
   ? hb_StrFormat( "Directory %1$s was changed.", cDir )

   IF hb_FileExists( cDir + "quit" )
      lRunAnyway := .F.
   ENDIF

   RETURN
/*
*/
#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

#include "hbwapi.h"

/*
 HANDLE WINAPI
    FindFirstChangeNotification( LPCTSTR lpPathName, BOOL bWatchSubtree, DWORD dwNotifyFilter );
*/
HB_FUNC( WAPI_FINDFIRSTCHANGENOTIFICATION )
{
   if( HB_ISCHAR( 1 ) )
   {
      HANDLE handle;
      void   *hText;

      handle = FindFirstChangeNotification( HB_PARSTRDEF( 1, &hText, NULL ),
                                            hbwapi_par_BOOL( 2 ), hbwapi_par_DWORD( 3 ) );
      hb_strfree( hText );

      if ( INVALID_HANDLE_VALUE == handle )
      {
         hbwapi_SetLastError( GetLastError() );

         hb_retptr( NULL );
      }
      else
      {
         hbwapi_ret_raw_HANDLE( handle );
      }
   }
   else
   {
      hb_retptr( NULL );
   }
}

//BOOL FindNextChangeNotification(HANDLE hChangeHandle);
HB_FUNC( WAPI_FINDNEXTCHANGENOTIFICATION )
{
   HANDLE handle = hbwapi_par_raw_HANDLE( 1 );

   if( handle )
   {
      hbwapi_ret_L( FindNextChangeNotification( handle ) );
   }
   else
   {
      hb_retl( HB_FALSE );
   }
}

//BOOL WINAPI FindCloseChangeNotification( HANDLE hChangeHandle );
HB_FUNC( WAPI_FINDCLOSECHANGENOTIFICATION )
{
   HANDLE handle = hbwapi_par_raw_HANDLE( 1 );

   if( handle )
   {
      hbwapi_ret_L( FindCloseChangeNotification( handle ) );
   }
   else
   {
      hb_retl( HB_FALSE );
   }
}

HB_FUNC( INVALID_HANDLE_VALUE )
{
   HANDLE handle = hbwapi_par_raw_HANDLE( 1 );

   if ( NULL != handle )
   {
      hbwapi_ret_L( ( INVALID_HANDLE_VALUE == handle )  );
   }
}

#pragma ENDDUMP
