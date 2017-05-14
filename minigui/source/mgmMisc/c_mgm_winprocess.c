#include <mgdefs.h>

#include <tlhelp32.h>
#include <hbapiitm.h>
#include "hbapierr.h"
#include "hbinit.h"

// used by WIN_GETPROCESSLIST()
static BOOL GetUserAndDomainFromPID( DWORD ProcessId, PHB_ITEM pUser, PHB_ITEM pDomain )
{
   HANDLE hToken;
   HANDLE ProcessHandle;
   DWORD cbBuf;
   SID_NAME_USE snu;
   char *User = NULL;
   char *Domain = NULL;
   DWORD UserSize = 0L;
   DWORD DomainSize = 0L;
   BOOL bResult = FALSE;
   ProcessHandle = OpenProcess( PROCESS_QUERY_INFORMATION, FALSE, ProcessId );
   if (ProcessHandle)
   {
      if (OpenProcessToken(ProcessHandle, TOKEN_QUERY, &hToken))
      {
         BOOL bSuccess = FALSE;
         PTOKEN_USER ptiUser = NULL;
         if (!GetTokenInformation(hToken, TokenUser, NULL, 0, &cbBuf ))
         {
            ptiUser = (TOKEN_USER *) hb_xgrab( cbBuf );
            bSuccess = GetTokenInformation( hToken, TokenUser, (LPVOID) ptiUser, cbBuf, &cbBuf);
         }
         CloseHandle(hToken);
         if (bSuccess)
         {
            LookupAccountSid( NULL, ptiUser->User.Sid, NULL, &UserSize, NULL, &DomainSize, &snu);
            if (UserSize != 0 && DomainSize != 0)
            {
               User = (char *) hb_xgrab( UserSize );
               Domain = (char *) hb_xgrab( DomainSize );
               if (LookupAccountSid( NULL, ptiUser->User.Sid, User, &UserSize, Domain, &DomainSize, &snu ))
               {  /* Result OK */
                  bResult = TRUE;
               }
            }
         }
         if (ptiUser)
            hb_xfree( ptiUser );
      }
      CloseHandle(ProcessHandle);
   }
   if (!User)
      hb_itemPutC( pUser, "" );
   else
      hb_itemPutCLPtr( pUser, User, UserSize );

   if (!Domain)
      hb_itemPutC( pDomain, "" );
   else
      hb_itemPutCLPtr( pDomain, Domain, DomainSize );

   return bResult;
}


/*
* WIN_GETPROCESSLIST( aArray [, <cProcessToFind> ] ) -> nResult
* Get current process list on Windows OS. by Vailton Renato <vailtom@gmail.com>
* Returns:
*  0 - Success
*  1 - Argument error
*  2 - Unable to obtain current process list.
*  3 - Error retrieving information about processes.
*
* 15/12/2009 - 18:58:58
*/
HB_FUNC(WIN_GETPROCESSLIST)
{
   HANDLE hProcessSnap;
   PROCESSENTRY32 pe32;
   PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   const char * szAppName = hb_parcx(2);
   BOOL bCanAdd = TRUE;

   if( !pArray )
   {
      hb_errRT_BASE_SubstR( EG_ARG, 3012, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );

      hb_retni( 1 );
      return;
   }

   // Take a snapshot of all processes in the system.
   hProcessSnap = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );

   if( hProcessSnap == INVALID_HANDLE_VALUE )
   {
      // CreateToolhelp32Snapshot (of processes)
      hb_retni( 2 );
      return;
   }

   // Set the size of the structure before using it.
   pe32.dwSize = sizeof( PROCESSENTRY32 );

   // Retrieve information about the first process,
   // and exit if unsuccessful
   if( !Process32First( hProcessSnap, &pe32 ) )
   {
      hb_retni( 3 );
      CloseHandle( hProcessSnap );     // clean the snapshot object
      return;
   }

   // Ignores a empty string on seconds argument
   if ( hb_parclen(2) < 1 )
      szAppName = NULL;

   // Now walk the snapshot of processes, and
   // display information about each process in turn
   do
   {
      PHB_ITEM pSubarray;

      if (szAppName)
         bCanAdd = ( hb_stricmp( szAppName, pe32.szExeFile ) == 0 );

      if (bCanAdd)
      {
         pSubarray = hb_itemNew( NULL );

         hb_arrayNew ( pSubarray, 5 );
         hb_arraySetC ( pSubarray, 1, pe32.szExeFile );               // Process Name
         hb_arraySetNInt ( pSubarray, 2, pe32.th32ProcessID );        // Process ID
         hb_arraySetNInt ( pSubarray, 3, pe32.th32ParentProcessID );  // Parent process ID

         GetUserAndDomainFromPID( pe32.th32ProcessID,
                                  hb_arrayGetItemPtr( pSubarray, 4 ),    // User
                                  hb_arrayGetItemPtr( pSubarray, 5 ) );  // Domain

         hb_arrayAddForward( pArray, pSubarray );
      }
   } while( Process32Next( hProcessSnap, &pe32 ) );

   CloseHandle( hProcessSnap );
   hb_retni( 0 );
   return;
}


/*
 * WIN_KILLPROCESS( <nProessIDtoKill> ) -> lKilled
 * Kill a process using Win32 API. by Vailton Renato <vailtom@gmail.com>
 * 16/12/2009 - 00:08:48
 */
/*
HB_FUNC(WIN_KILLPROCESS)
{
   DWORD ProcID;
   BOOL Result = FALSE;

   if (HB_ISNUM(1))
   {
      ProcID = (DWORD) hb_parnl(1);
      Result = TerminateProcess(OpenProcess( PROCESS_TERMINATE, FALSE, ProcID ),0);
   }

   hb_retl( Result );
}
*/
// win_KillProcess( <nProessIDtoKill> [, nExitCode] )
HB_FUNC ( WIN_KILLPROCESS )
{
   BOOL Result = FALSE;

   if( HB_ISNUM(1) )
   {
      DWORD ProcessID = (DWORD) hb_parnl( 1 );
      HANDLE hProcess = OpenProcess( PROCESS_TERMINATE, FALSE, ProcessID );
      
      if( hProcess != NULL )
      {
         Result = TerminateProcess( hProcess, (UINT) hb_parnl( 2 ) );
         
         if( Result == FALSE )
            CloseHandle (hProcess);
      }
   }

   hb_retl( Result );
}

