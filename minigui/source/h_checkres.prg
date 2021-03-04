/* Resources Control Functions */

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"

STATIC aResources := {}

*-----------------------------------------------------------------------------*
FUNCTION MGAddResource( nHResource, cType )
*-----------------------------------------------------------------------------*
   LOCAL n := 3, cInfo := ""

   WHILE ! Empty( ProcName( n ) )
      cInfo += ProcName( n ) + "(" + hb_ntos( ProcLine( n ) ) + ")->"
      n++
   END

   IF ! Empty( cInfo )
      cInfo := SubStr( cInfo, 1, Len( cInfo ) - 2 )
   ENDIF

   AAdd( aResources, { cType, nHResource, cInfo } )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION MGDelResource( nHResource )
*-----------------------------------------------------------------------------*
   LOCAL nAt

   IF ( nAt := AScan( aResources, {| aRes | aRes[ 2 ] == nHResource } ) ) != 0
      hb_ADel( aResources, nAt, .T. )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION CheckRes()
*-----------------------------------------------------------------------------*
   LOCAL cInfo := "", p

   _SetGetLogFile( GetStartUpFolder() + "\checkres.txt" )
   FErase( _SetGetLogFile() )

   FOR EACH p IN aResources
      IF p[ 2 ] != 0
         cInfo += GetExeFileName() + " -- " + p[ 1 ] + "," + hb_ntos( p[ 2 ] ) + "," + p[ 3 ] + CRLF
         _LogFile( .T., cInfo )
      ENDIF
   NEXT

   IF ! Empty( cInfo )
     _LogFile( .T., GetExeFileName() + " -- " + Replicate( "=", 99 ) )
   ENDIF

RETURN NIL

/*
 * C-level
 */

#pragma BEGINDUMP

#include <windows.h>
#include <hbapiitm.h>
#include <hbvm.h>

void RegisterResource( HANDLE hRes, LPSTR szType )
{
   PHB_ITEM pRet = hb_itemNew( hb_param( -1, HB_IT_ANY ) );

   hb_vmPushSymbol( hb_dynsymGetSymbol( "MGADDRESOURCE" ) );
   hb_vmPushNil();
   hb_vmPushNumInt( ( LONG_PTR ) hRes );
   hb_vmPushString( szType, strlen( szType ) );
   hb_vmFunction( 2 );

   hb_itemReturnRelease( pRet );
}

void pascal DelResource( HANDLE hResource )
{
   PHB_ITEM pRet = hb_itemNew( hb_param( -1, HB_IT_ANY ) );

   hb_vmPushSymbol( hb_dynsymGetSymbol( "MGDELRESOURCE" ) );
   hb_vmPushNil();
   hb_vmPushNumInt( ( LONG_PTR ) hResource );
   hb_vmFunction( 1 );

   hb_itemReturnRelease( pRet );
}

#pragma ENDDUMP
