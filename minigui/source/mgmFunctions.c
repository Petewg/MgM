#include "hbwin.h"
#include "hbwapi.h"
#include "hbapi.h"
#include "hbapiitm.h"

/* This function has the same result as pressing Ctrl+Alt+Del and clicking Lock Workstation. 
   To unlock the workstation, the user must log in. */
HB_FUNC( LOCKDESKTOP )
{
   int i = LockWorkStation();
    hb_retl( i > 0);
}

#if ( __HARBOUR__ - 0 > 0x030200 ) 
/* below two functions have been deleted in harbour 3.4 (Viktor's fork) */
HB_FUNC( WIN_N2P )  /* NOTE (by Viktor): Unsafe: allows to pass arbitary pointers to functions, potentially causing a crash or worse. */
{
   hb_retptr( HB_ISPOINTER( 1 ) ? hb_parptr( 1 ) : ( void * ) ( HB_PTRDIFF ) hb_parnint( 1 ) );
}

HB_FUNC( WIN_P2N )  /* NOTE (by Viktor): Unsafe: will reveal the numeric value of a pointer */
{
   hb_retnint( HB_ISNUM( 1 ) ? hb_parnint( 1 ) : ( HB_PTRDIFF ) hb_parptr( 1 ) );
}
#endif
/*
   win_ErrorDescription( <nWinErrorCode> ) -> cErrorDescription
      <nWinErrorCode> any decimal or hex value 
      e.g. win_ErrorDescription( 5 ) or win_ErrorDescription( 0x00000010 )
      returns: description of error occured, in locale OS language.
      Similar to previous MGM_GetWinErrorStr( <nCode> ) but more fast and localaized.
      example use: cError := win_ErrorDescription( wapi_GetLastError() )
   - created by: Pete D.
   - version 1.0 - 2016-08-07
*/
HB_FUNC( WIN_ERRORDESCRIPTION )
{
   const DWORD win_error = hb_parnd( 1 );
   LPTSTR lpMsgBuf = NULL;
   DWORD dwRetVal;
   
   dwRetVal = FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM, 
                             NULL, (DWORD)(win_error),
                             MAKELANGID( LANG_NEUTRAL, SUBLANG_NEUTRAL ), 
                             (LPTSTR) &lpMsgBuf, 0, NULL );

   if( dwRetVal )
      lpMsgBuf[ strlen( (const char*) lpMsgBuf ) - 1 ] = '\0';  // discard EOL
   else
      lpMsgBuf = "(uknown/reserved)";
   
   hb_retc( (const char *) lpMsgBuf ) ;
}
 

HB_FUNC( WIN_QPCOUNTER2SEC2 )
{
   static HB_MAXDBL s_dFrequence = 0;

   if( s_dFrequence == 0 )
   {
      LARGE_INTEGER frequency;
      if( ! QueryPerformanceFrequency( &frequency ) )
      {
         hb_retnd( 99 );
         return;
      }
      s_dFrequence = ( HB_MAXDBL ) HBWAPI_GET_LARGEUINT( frequency );
   }
   // hb_retnd( ( double ) ( ( HB_MAXDBL ) hb_parnint( 1 ) / ( HB_MAXDBL ) s_dFrequence ) );
   hb_retnd( ( double )  s_dFrequence / 1000 ) ;
}
