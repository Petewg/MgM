/*
* HMG Demo
*/

/*-----------------------------------------------------------------*/
// comments
/*-----------------------------------------------------------------*/

// Adaptation of source code from:
// http://msdn.microsoft.com/en-us/library/windows/desktop/aa376861%28v=vs.85%29.aspx
//
// Carlos Britos

// Warning: before test it, save your data. Just in case cancel button don't works.
//
// Use it at your own risk.


#include "hmg.ch"

/*-----------------------------------------------------------------*/

PROCEDURE Main

IF _HMG_IsXPorLater

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 250 ;
		TITLE 'My System Shutdown' ;
		MAIN ;
		ON INIT MsgLbl( 4 )

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				Item "MySystemShutdown()"      Action {||MsgLbl( MySystemShutdown() ) }
				Item "Shutdown with message"   Action {||MsgLbl( MySystemShutdown( 'System shutdown in 30" or cancel with PreventSystemShutdown()' ) )}
				Item "Restart"                 Action {||MsgLbl( MySystemShutdown( 'System will restart after shutdown', 0, 1, 30 ) ) }
				Item "Shutdown in 50 seconds"  Action {||MsgLbl( MySystemShutdown( 'ShutDown Message', 0, 0, 50 ) ) }
				Item "Ask user to close apps"  Action {||MsgLbl( MySystemShutdown( 'ShutDown Message', 1 ) ) }
				Item "Cancel System Shutdown"  Action {||PreventSystemShutdown(), MsgLbl( 4 ) }
			END POPUP
		END MENU

      @ 20,20 LABEL Label_2 ;
         WIDTH 400 ;
         BOLD ;
         SIZE 12 ;
         VALUE ''

      @ 60,20 BUTTON Button_1 ;
         CAPTION 'PreventSystemShutdown' ;
         WIDTH 400 ;
         HEIGHT 30 ;
         ACTION {||PreventSystemShutdown(), MsgLbl( 4 ) }

	END WINDOW

	ACTIVATE WINDOW Win_1
ELSE
	MsgStop( 'This Program Runs In WinXP Or Later Only!', 'Stop' )
ENDIF

RETURN

/*-----------------------------------------------------------------*/

PROCEDURE MsgLbl( n )

   LOCAL a := { ;
               'MySystemShutdown() -> 0. ShutDown in progress', ;
               'MySystemShutdown() -> 1. Cannot Open Process Token', ;
               'MySystemShutdown() -> 2. Cannot test the return value of AdjustTokenPrivileges', ;
               'MySystemShutdown() -> 3. Cannot Display the shutdown dialog box', ;
               'Warning: Save all data before ShutDown test'  ;
              }

      IF n == 0
         SetProperty( 'Win_1','Label_2','FontColor', {255,0,0} )
      ELSE
         IF ! ( n == 4 )
            SetProperty( 'Win_1','Label_2','FontColor', {255,184,0} )
         ELSE
            SetProperty( 'Win_1','Label_2','FontColor', {0,0,0} )
         ENDIF
      ENDIF
      SetProperty( 'Win_1','Label_2','value', a[ n + 1 ] )

RETURN

/*-----------------------------------------------------------------*/

#pragma BEGINDUMP


#include <windows.h>
#include "hbapi.h"


HB_FUNC_STATIC( MYSYSTEMSHUTDOWN )
{
   HANDLE hToken;              // handle to process token
   TOKEN_PRIVILEGES tkp;       // pointer to token structure
   int nAsk = ( HB_ISNUM(2) ) ? hb_parni(2) : 0 ;
   int nRestart = ( HB_ISNUM(3) ) ? hb_parni(3) : 0 ;
   int nTime = ( HB_ISNUM(4) ) ? hb_parni(4) : 30 ;
   int nRet = 0 ;

   // Get the current process token handle so we can get shutdown privilege.
   if ( ! OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken) )
      nRet = 1;
   else
   {
      // Get the LUID for shutdown privilege.
      LookupPrivilegeValue( NULL, SE_SHUTDOWN_NAME, &tkp.Privileges[0].Luid );

      tkp.PrivilegeCount = 1;  // one privilege to set
      tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

      // Get shutdown privilege for this process.
      AdjustTokenPrivileges( hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES) NULL, 0 );

      // Cannot test the return value of AdjustTokenPrivileges.
      if ( GetLastError() != ERROR_SUCCESS )
         nRet = 2;
      else
      {
         // Display the shutdown dialog box and start the countdown.
         if ( InitiateSystemShutdown(
                    NULL,                  // shut down local computer
                    (LPSTR) hb_parc(1),    // message for user
                    nTime,                 // time-out period, in seconds
                    nAsk,                  // ask user to close apps
                    nRestart ) )           // reboot after shutdown
            {
               // Disable shutdown privilege.
               tkp.Privileges[0].Attributes = 0;
               AdjustTokenPrivileges( hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES) NULL, 0 );
            }
            else
               nRet = 3;
      }
   }

   hb_retni( nRet );
}

HB_FUNC_STATIC( PREVENTSYSTEMSHUTDOWN )
{
   HANDLE hToken;              // handle to process token
   TOKEN_PRIVILEGES tkp;       // pointer to token structure
   int nRet = TRUE ;

   // Get the current process token handle so we can get shutdown privilege.
   if ( ! OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken ))
      nRet = FALSE;
   else
   {
      // Get the LUID for shutdown privilege.
      LookupPrivilegeValue( NULL, SE_SHUTDOWN_NAME, &tkp.Privileges[0].Luid );

      tkp.PrivilegeCount = 1;  // one privilege to set
      tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

      // Get shutdown privilege for this process.
      AdjustTokenPrivileges( hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES)NULL, 0);

      if (GetLastError() != ERROR_SUCCESS)
         nRet = FALSE;
      else
      {
         // Prevent the system from shutting down.
         if ( ! AbortSystemShutdown( NULL ) )
            nRet = FALSE;
         else
         {
            // Disable shutdown privilege.
            tkp.Privileges[0].Attributes = 0;
            AdjustTokenPrivileges( hToken, FALSE, &tkp, 0, (PTOKEN_PRIVILEGES) NULL, 0 );
         }
      }
   }

   hb_retl( nRet );
}

#pragma ENDDUMP
