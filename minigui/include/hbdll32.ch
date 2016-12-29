
#xcommand DECLARE [<static:STATIC>] [<encode:ANSI>] <FuncName>( [ <uParam1> ] [, <uParamN> ] ) IN <DllName> ;
        => ;
        [<static>] FUNCTION <FuncName>( [<uParam1>] [, <uParamN>] ) ; ;
                   LOCAL cFunc := <"FuncName"> [ + Iif( <.encode.>, "A", "" ) ] ; ;
                   RETURN CallDLL32( (cFunc), <"DllName"> [, <uParam1> ] [, <uParamN> ] )
                   
#xcommand DECLARE [<static:STATIC>] [<encode:UNICODE>] <FuncName>( [ <uParam1> ] [, <uParamN> ] ) IN <DllName> ;
        => ;
        [<static>] FUNCTION <FuncName>( [<uParam1>] [, <uParamN>] ) ; ;
                   LOCAL cFunc := <"FuncName"> [ + Iif( <.encode.>, "W", "" ) ] ; ;
                   RETURN CallDLL32( (cFunc), <"DllName"> [, <uParam1> ] [, <uParamN> ] )                   



#xcommand DECLARE [<static:STATIC>] [<encode:ANSI>] <FuncName>( [ <uParam1> ] [, <uParamN> ] ) IN <DllName> ALIAS <alias> ;
        => ;
        [<static>] FUNCTION <alias>( [<uParam1>] [, <uParamN>] ) ; ;
                   LOCAL cFunc := <"FuncName"> [ + Iif( <.encode.>, "A", "" ) ] ; ;
                   RETURN CallDLL32( (cFunc), <"DllName"> [, <uParam1> ] [, <uParamN> ] )
                   
#xcommand DECLARE [<static:STATIC>] [<encode:UNICODE>] <FuncName>( [ <uParam1> ] [, <uParamN> ] ) IN <DllName> ALIAS <alias> ;
        => ;
        [<static>] FUNCTION <alias>( [<uParam1>] [, <uParamN>] ) ; ;
                   LOCAL cFunc := <"FuncName"> [ + Iif( <.encode.>, "W", "" ) ] ; ;
                   RETURN CallDLL32( (cFunc), <"DllName"> [, <uParam1> ] [, <uParamN> ] )                   
                   

/*

FUNCTION __Is_UTF8_Enabled()
   RETURN ( "UTF8" $ SET(_SET_CODEPAGE) )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

// __ISDLLFUNC ( pLibDLL | cLibName, cFuncName ) ---> Boolean
HB_FUNC ( __IS_DLL_FUNC )
{
   HMODULE hModule;
   BOOL bRelease;
   char * cFuncName;

   if ( HB_ISCHAR( 1 ) )
   {  hModule = LoadLibrary( ( char * ) hb_parc( 1 ) );
      bRelease = TRUE;
   }
   else
   {  hModule = hb_libHandle( hb_param( 1, HB_IT_ANY ) );
      bRelease = FALSE;
   }

   cFuncName = ( char * ) hb_parc( 2 );

   hb_retl( GetProcAddress( hModule, cFuncName ) ? TRUE : FALSE );

   if( bRelease && hModule )
      FreeLibrary( hModule );
}

#pragma ENDDUMP

*/