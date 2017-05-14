/*
 * MgM C-functions
 * Copyright 2016-2017 Pete D.
 *
 * EnumWindows() -> aArray filled with handles of all top-level windows
 * EnumChildWindows( hWnd ) -> aArray filled with handles of all child windows
 *
 * GetWindowThreadProcessId( hWnd, @nProcessID ) -> nThreadID
 * GetProcessFullName ( [ nProcessID ] ) --> return cProcessFullName
 *
 * win_ErrorDescription( <nWinErrorCode> ) -> cErrorDescription
 
 * Interesting notes & links
 * Windows Data Types -> https://msdn.microsoft.com/en-us/library/aa383751(VS.85).aspx
*/

#include <mgdefs.h>

#include "hbwin.h"
#include "hbwapi.h"
#include "hbapiitm.h"

 
/*
 * mgm_ErrorDescription( <nWinErrorCode> ) -> cErrorDescription
 *     <nWinErrorCode> any decimal or hex value 
 *     e.g. win_ErrorDescription( 5 ) or win_ErrorDescription( 0x00000010 )
 *     returns: description of error occured, in locale OS language.
 *     Similar to previous MGM_GetWinErrorStr( <nCode> ) (h_mgmFunctions.prg) 
 *     but more fast and auto-localized.
 *     example use: cError := mgm_ErrorDescription( wapi_GetLastError() )
 *  - Copyright 2016 Pete D. <pete_westg / at / yahoo.gr>
 *  - version 1.0 - 2016-08-07
*/

HB_FUNC_TRANSLATE( MGM_GETWINERRORSTR, MGM_ERRORDESCRIPTION )

HB_FUNC( MGM_ERRORDESCRIPTION )
{
   const DWORD win_error = HB_ISNUM( 1 ) ? (DWORD) hb_parnd( 1 ) : hbwapi_GetLastError();
   LPTSTR pDescription = NULL;
   DWORD dwRetVal;

   dwRetVal = FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_MAX_WIDTH_MASK,
                             NULL, (DWORD)(win_error),
                             MAKELANGID( LANG_NEUTRAL, SUBLANG_NEUTRAL ),
                             (LPTSTR) &pDescription, 0, NULL );

   if( !dwRetVal )
   {
      FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_MAX_WIDTH_MASK,
                             NULL, 0x80000008, // "Unspecified error"
                             MAKELANGID( LANG_NEUTRAL, SUBLANG_NEUTRAL ),
                             (LPTSTR) &pDescription, 0, NULL );
   }

   hb_retc( pDescription );

   // FORMAT_MESSAGE_ALLOCATE_BUFFER entails the use of LocalAlloc() 
   // to allocate memory for pDescription, so we have to free it up.
   // https://msdn.microsoft.com/en-us/library/windows/desktop/ms679351(v=vs.85).aspx
   LocalFree( pDescription ); 
}


#if ( __HARBOUR__ - 0 > 0x030200 )
/* below two functions have been deleted in harbour 3.4 (Viktor's fork) so we add them here. */

/* NOTE (by Viktor): Unsafe: allows to pass arbitary pointers to functions, potentially causing a crash or worse. */
HB_FUNC( WIN_N2P )  
{
   hb_retptr( HB_ISPOINTER( 1 ) ? hb_parptr( 1 ) : ( void * ) ( HB_PTRDIFF ) hb_parnint( 1 ) );
}

/* NOTE (by Viktor): Unsafe: will reveal the numeric value of a pointer */
HB_FUNC( WIN_P2N )
{
   hb_retnint( HB_ISNUM( 1 ) ? hb_parnint( 1 ) : ( HB_PTRDIFF ) hb_parptr( 1 ) );
}
#endif
