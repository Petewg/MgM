/**********************************************************
* Harbour-MiniGUI source code
* File         : WinProcess.prg,  Created: 02/18/2014, 19:35
* Creator      : Pete D.
***********************************************************/
/* FUNCTIONS

hb_GetProcess( <cExeFile>, [(by ref) nProcessID] ) -> Bool
      Returns: .T. if cExeFile is running
            Process Id (PID) can be obtained if the optional param nProcessID
            passed by reference and cExeFile is running.

hb_GetPID( <cExeFile> ) -> integer
      Returned value will be: >0 (the process ID (PID) of cExeFile)
                               0 (if cExeFile is NOT running)

hb_KillProcess( <cExeFile> ) -> Bool
      Attempts to Kill cExeFile (if it's running)
      Returns: .T. on success, .F. otherwise

hb_IsProcess( <cExeFile> ) -> Bool
      Returns: .T. if cExeFile is running
      * Compatibility Function using hb_GetProcess()


win_GetProcessList( <aProcess>, [cExeFile] ) -> integer (0 on success >0 on fail).
      Params: aProcess, an empty initialized array in which process list wil be stored
              cExeFile (optional) the executable for which needed to obtain process's Info.

      If func succeed (and cExeFile not passed),
      the aProcess will contain subarrays for all processes that are running.
      Each subarray has the following structure:
      { cProcessName, nProcessID, nParentID, cUserName, cDomain (computername) }

      If optional param cExeFile is passed and cExeFile is running
      the aProcess will contain subarrays for all cExeFile appearances (or at least one)

      If func fail or cExeFile is passed and cExeFile is NOT running
      aProcess will be empty.

win_KillProcess( nProcessID )  -> .T. on success, .F. otherwise
      Attempts to Kill the process with PID = nProcessID
      Returns: .T. on success, .F. otherwise
*/

#include "error.ch"

FUNCTION hb_GetProcess( cExeFile, /*@*/ nProcessID )
********************************************************************************
   STATIC lFirstRun := .T.
   LOCAL lRet := .F.
   LOCAL aProcess, nResult, p, c
   LOCAL nSecs := Seconds()

   IF PCount() < 1                      ; UDFArgError( 1 )
   ELSEIF ! hb_IsString( hb_PValue(1) ) ; UDFArgError( 2 )
   ENDIF

   /*
   hb_Default( @cExeFile, "" )
   IF Empty( cExeFile )
      RETURN .F.
   ENDIF
   */

   IF lFirstRun // first call. wait 1 sec for process to initialize
      lFirstRun := .F.
      DO WHILE Seconds() - nSecs < 1 // wait for 1 secs
      ENDDO
   ENDIF

   // manipulate cExeFile param.
   nResult := RAt( ".", cExeFile )
   IF nResult == 0
      cExeFile := cExeFile + ".exe"
   ELSEIF nResult == Len( cExeFile ) // dot at the end of cExeFile!
      cExeFile := cExeFile + "exe"
   ELSE
      IF ! Lower( SubStr( cExeFile, nResult + 1 ) ) == "exe"
         cExeFile := cExeFile + ".exe"
      ENDIF
   ENDIF

   aProcess := { }

   nResult :=  win_GetProcessList( aProcess, cExeFile )

   IF nResult == 0  // win_GetProcessList succeed!
      FOR p := 1 TO Len( aProcess )
         nProcessID := aProcess[ p, 2 ]
         IF ! Empty( nProcessID )
            c := aProcess[ p, 1 ]
            IF Lower( cExeFile ) == Lower( c )
               lRet := .T.
            ENDIF
         ENDIF
      NEXT
   ELSE
      //todo: error handling
   ENDIF

   RETURN lRet


FUNCTION hb_GetPID( cExeFile )
********************************************************************************
   LOCAL nProcessID

   IF PCount() < 1                      ; UDFArgError( 1 )
   ELSEIF ! hb_IsString( hb_PValue(1) ) ; UDFArgError( 2 )
   ENDIF
   IF hb_GetProcess( cExeFile, @nProcessID )
      RETURN nProcessID
   ENDIF

RETURN 0


FUNCTION hb_KillProcess( cExeFile )
********************************************************************************
   LOCAL nProcessID // := hb_GetPID( cExeFile )

   IF PCount() < 1                      ; UDFArgError( 1 )
   ELSEIF ! hb_IsString( hb_PValue(1) ) ; UDFArgError( 2 )
   ENDIF

   IF (nProcessID := hb_GetPID( cExeFile )) > 0
      RETURN win_KillProcess( nProcessID )
   ENDIF

RETURN .F.


FUNCTION hb_IsProcess( cExeFile )
********************************************************************************
   IF PCount() < 1                      
      UDFArgError( 1 )
   ELSEIF ! hb_IsString( hb_PValue(1) )
      UDFArgError( 2 )
   ENDIF

RETURN hb_GetProcess( cExeFile )


FUNCTION UDFArgError( nError )
********************************************************************************
LOCAL aErrors := { "Required Argument Missing", "Argument Type Mismatch" }
LOCAL nStack := 1  // Skip the GetCallStack() function in the result
LOCAL cStack :=""

LOCAL oError := ErrorNew()

   oError:severity   := ES_ERROR
   oError:genCode    := EG_ARG
   oError:subSystem  := "BASE"
   oError:canDefault := .T.
   oError:operation  := ""
   oError:subCode    := 9997 + nError // 3011

   DO WHILE .NOT. Empty( ProcName(nStack) )
      cStack += ProcName(nStack) + " (line:"+hb_ntos(ProcLine(nStack))+");"
         // AAdd( aStack, { ProcFile(nStack), ProcName(nStack), ProcLine(nStack) }
      nStack ++
   ENDDO
   /*
   oError:Description:= "Required Argument Missing;"+;
                          "Called from: "+ProcName(1)+" Line: "+ hb_ntos(ProcLine(1))
   */
   oError:Description:= "Function " + ProcName(1) + "(); Error description: " + aErrors[nError]+";"+;
                          "Called from: " + cStack
   RETURN Eval( ErrorBlock(), oError )

   
   
/*
 * Routines to Kill a process, List all processes WITH user & domain names. 
 * by Vailton Renato <vailtom@gmail.com> to Public Domain. 
 *
 * UPDATED: 16/12/2009 - 12:15 
 * Test program revised by Pete D. 19/02/2014 
 */
 
/*
PROCEDURE Main()
   LOCAL cApp
   LOCAL n, i
   LOCAL iL := 0

   While .T.
      CLS
      ACCEPT 'Type process name to find (like CALC.EXE - q=quit): ' TO cApp

      If cApp $"Qq"
         exit
      Endif

      aProcs := {}

      If !empty( cApp ) .and. !( '.' $ cApp )
        cApp += '.exe'
      Endif

      n := WIN_GETPROCESSLIST( aProcs, cApp )

      ?
      ? 'WIN_GETPROCESSLIST( {}, "' + cApp + '" ) ->', n

      DO CASE
         CASE n == 0 ; ?? ' - Success'
         CASE n == 1 ; ?? ' - Argument error!'
         CASE n == 2 ; ?? ' - Unable to obtain current process list!'
         CASE n == 3 ; ?? ' - Error retrieving information about processes!'
      ENDCASE

      aSort( aProcs ,,, {|x,y| x[1] < y[1] })

      aEval( aProcs , { |x| iL := Max( iL, Len( x[1] ) ) } )

      ?
      ? Padr('Process Name', iL) + ' Process ID ParentID UserName  Domain'
      ? repl('=' , iL)           + ' ========== ======== ========= =========='
       * 123456789*123456789*       123456789* 12345678 123456789* 123456789*

      For i := 1 TO Len( aProcs )

        ? Padr( aProcs[i,1], iL ) + " " + ;
          Padl( aProcs[i,2], 10 ) + " " + ;
          Padl( aProcs[i,3],  8 ) + " "

        If ! Empty( aProcs[i,4] )
          ?? Padr(aProcs[i,4], 10)
        Endif
        If ! Empty(aProcs[i,5])
          ?? '\\' + aProcs[i,5]
        Endif

      Next

      ? Len(aProcs), ' process found!'
      ?
      If ! Empty(cApp)  .AND. ! Empty( aProcs )
         ? 'K = Kill ' + cApp + ' !'
         If CHR(Inkey(0)) == "K"
            p := Atail(aProcs)[ 2 ]
            ? 'Type Y to kill the process number ' + hb_NtoS(p) + ' ('+cApp+')'
            If CHR(Inkey(0)) == "Y"
               ?
               ? 'Kill ' + cApp +', PID:', p, " --> "
               ?? WIN_KILLPROCESS( p )
               ?
            Endif
         Endif
      Endif

      WAIT

   End

   Return
*/

********************************************************************************

// #pragma BEGINDUMP

// #include <windows.h>
// // #include <windef.h>
// #include <tlhelp32.h>
// #include <hbapiitm.h>
// #include "hbapierr.h"
// #include "hbinit.h"
// static BOOL GetUserAndDomainFromPID( DWORD ProcessId, PHB_ITEM pUser, PHB_ITEM pDomain )
// {
   // HANDLE hToken;
   // HANDLE ProcessHandle;
   // DWORD cbBuf;
   // SID_NAME_USE snu;
   // char *User = NULL;
   // char *Domain = NULL;
   // DWORD UserSize = 0L;
   // DWORD DomainSize = 0L;
   // BOOL bResult = FALSE;
   // ProcessHandle = OpenProcess( PROCESS_QUERY_INFORMATION, FALSE, ProcessId );
   // if (ProcessHandle)
   // {
      // if (OpenProcessToken(ProcessHandle, TOKEN_QUERY, &hToken))
      // {
         // BOOL bSuccess = FALSE;
         // PTOKEN_USER ptiUser = NULL;
         // if (!GetTokenInformation(hToken, TokenUser, NULL, 0, &cbBuf ))
         // {
            // ptiUser = (TOKEN_USER *) hb_xgrab( cbBuf );
            // bSuccess = GetTokenInformation( hToken, TokenUser, (LPVOID) ptiUser, cbBuf, &cbBuf);
         // }
         // CloseHandle(hToken);
         // if (bSuccess)
         // {
            // LookupAccountSid( NULL, ptiUser->User.Sid, NULL, &UserSize, NULL, &DomainSize, &snu);
            // if (UserSize != 0 && DomainSize != 0)
            // {
               // User = (char *) hb_xgrab( UserSize );
               // Domain = (char *) hb_xgrab( DomainSize );
               // if (LookupAccountSid( NULL, ptiUser->User.Sid, User, &UserSize, Domain, &DomainSize, &snu ))
               // {  /* Result OK */
                  // bResult = TRUE;
               // }
            // }
         // }
         // if (ptiUser)
            // hb_xfree( ptiUser );
      // }
      // CloseHandle(ProcessHandle);
   // }
   // if (!User)
      // hb_itemPutC( pUser, "" );
   // else
      // hb_itemPutCLPtr( pUser, User, UserSize );

   // if (!Domain)
      // hb_itemPutC( pDomain, "" );
   // else
      // hb_itemPutCLPtr( pDomain, Domain, DomainSize );

   // return bResult;
// }


// /*
// * WIN_KILLPROCESS( <nProessIDtoKill> ) -> lKilled
// * Kill a process using Win32 API. by Vailton Renato <vailtom@gmail.com>
// * 16/12/2009 - 00:08:48
// */
// HB_FUNC(WIN_KILLPROCESS)
// {
   // DWORD ProcID;
   // BOOL Result = FALSE;

   // if (HB_ISNUM(1))
   // {
      // ProcID = (DWORD) hb_parnl(1);
      // Result = TerminateProcess(OpenProcess( PROCESS_TERMINATE, FALSE, ProcID ),0);
   // }

   // hb_retl( Result );
// }


// /*
// * WIN_GETPROCESSLIST( aArray [, <cProcessToFind> ] ) -> nResult
// * Get current process list on Windows OS. by Vailton Renato <vailtom@gmail.com>
// *
// * Returns:
// *  0 - Success
// *  1 - Argument error
// *  2 - Unable to obtain current process list.
// *  3 - Error retrieving information about processes.
// *
// * 15/12/2009 - 18:58:58
// */
// HB_FUNC(WIN_GETPROCESSLIST)
// {
   // HANDLE hProcessSnap;
   // PROCESSENTRY32 pe32;
   // PHB_ITEM pArray = hb_param( 1, HB_IT_ARRAY );
   // const char * szAppName = hb_parcx(2);
   // BOOL bCanAdd = TRUE;

   // if( !pArray )
   // {
      // hb_errRT_BASE_SubstR( EG_ARG, 3012, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS );

      // hb_retni( 1 );
      // return;
   // }

   // // Take a snapshot of all processes in the system.
   // hProcessSnap = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );

   // if( hProcessSnap == INVALID_HANDLE_VALUE )
   // {
      // // CreateToolhelp32Snapshot (of processes)
      // hb_retni( 2 );
      // return;
   // }

   // // Set the size of the structure before using it.
   // pe32.dwSize = sizeof( PROCESSENTRY32 );

   // // Retrieve information about the first process,
   // // and exit if unsuccessful
   // if( !Process32First( hProcessSnap, &pe32 ) )
   // {
      // hb_retni( 3 );
      // CloseHandle( hProcessSnap );     // clean the snapshot object
      // return;
   // }

   // // Ignores a empty string on seconds argument
   // if ( hb_parclen(2) < 1 )
      // szAppName = NULL;

   // // Now walk the snapshot of processes, and
   // // display information about each process in turn
   // do
   // {
      // PHB_ITEM pSubarray;

      // if (szAppName)
      // bCanAdd = ( hb_stricmp( szAppName, pe32.szExeFile ) == 0 );

      // if (bCanAdd)
      // {
         // pSubarray = hb_itemNew( NULL );

         // hb_arrayNew( pSubarray, 5 );
         // hb_arraySetC  ( pSubarray, 1, pe32.szExeFile );          // Process Name
         // hb_arraySetNInt ( pSubarray, 2, pe32.th32ProcessID );        // Process ID
         // hb_arraySetNInt ( pSubarray, 3, pe32.th32ParentProcessID );     // Parent process ID

         // GetUserAndDomainFromPID( pe32.th32ProcessID,
                      // hb_arrayGetItemPtr( pSubarray, 4 ),    // User
                      // hb_arrayGetItemPtr( pSubarray, 5 ) );   // Domain
         // hb_arrayAddForward( pArray, pSubarray );
      // }
   // } while( Process32Next( hProcessSnap, &pe32 ) );

   // CloseHandle( hProcessSnap );
   // hb_retni( 0 );
   // return;
// }

// #pragma ENDDUMP
