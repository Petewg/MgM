/*----------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - http://harbour-project.org

    "Harbour Project"
    Copyright 1999-2017, http://harbour-project.org/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts of this code are contributed for MiniGUI Project and
   used here under permission of author :

   Copyright 2005 (C) Andy Wos <andywos@unwired.com.au>
 + SetProp()
 + GetProp()
 + RemoveProp()

   Copyright 2016-2017 (C) Petr Chornyj  <myorg63@mail.ru>
 + EnumProps()
 + EnumPropsEx()
   ---------------------------------------------------------------------------*/

#include <mgdefs.h>

#include "hbapiitm.h"

//------------------------------------------------------------------------------
//                   General, universal GetProp/SetProp functions
//------------------------------------------------------------------------------
// usage: SetProp( hWnd, cPropName, xValue, [lHandle] ) -> lSuccess
// [lHandle] is optional and indicates that no memory management is required
//           if lHandle = .T., xValue must be numerical (integer)

/* Revised by P.Chornyj 16.11 */
HB_FUNC( SETPROP )
{
   HWND    hwnd = ( HWND ) HB_PARNL( 1 );
   HGLOBAL hMem;
   char *  lpMem;
   char    chType;
   int     nLen;
   BOOL    bValue;
   double  dValue;
   INT     iValue;

   hb_retl( HB_FALSE );
   // check params
   if( ! IsWindow( hwnd ) || hb_parclen( 2 ) == 0 )
      return;

   // check data
   if( HB_ISCHAR( 3 ) )
   {
      chType = 'C';     // character
      nLen   = hb_parclen( 3 );
   }
   else if( HB_ISLOG( 3 ) )
   {
      chType = 'L';     // logical
      nLen   = sizeof( BOOL );
   }
   else if( HB_ISDATE( 3 ) )
   {
      chType = 'D';     // date
      nLen   = 9;       // len of "yyyymmdd"
   }
   else if( HB_IS_NUMINT( hb_param( 3, HB_IT_ANY ) ) )
   {
      if( ( BOOL ) hb_parldef( 4, HB_FALSE ) )
         chType = 'X';                 // if 'X' memory HANDLE passed
      else
         chType = 'I';                 // int

      nLen = sizeof( INT );
   }
   else if( HB_ISNUM( 3 ) )
   {
      chType = 'F';     // float
      nLen   = sizeof( double );
   }
   else                 // unsupported type
      return;

   // direct assignment of a long value
   if( chType == 'X' )
   {
      hb_retl( SetProp( hwnd, hb_parc( 2 ), ( HANDLE ) ( LONG_PTR ) HB_PARNL( 3 ) ) ? HB_TRUE : HB_FALSE );
      return;
   }

   // type conversion
   if( ( hMem = GlobalAlloc( GPTR, nLen + sizeof( int ) + 1 ) ) == NULL )
      return;
   else
   {
      lpMem = ( char * ) GlobalLock( hMem );
      if( lpMem == NULL )
      {
         GlobalFree( hMem );
         return;
      }
   }

   lpMem[ 0 ] = chType;
   memcpy( lpMem + 1, ( char * ) &nLen, sizeof( int ) );

   switch( chType )
   {
      case 'C':   memcpy( lpMem + sizeof( int ) + 1, hb_parc( 3 ), nLen ); break;
      case 'L':   bValue = hb_parl( 3 ); memcpy( lpMem + sizeof( int ) + 1, ( char * ) &bValue, sizeof( BOOL ) ); break;
      case 'D':   memcpy( lpMem + sizeof( int ) + 1, hb_pards( 3 ), nLen ); break;
      case 'I':   iValue = ( INT ) hb_parnl( 3 ); memcpy( lpMem + sizeof( int ) + 1, ( char * ) &iValue, sizeof( INT ) ); break;
      case 'F':   dValue = hb_parnd( 3 ); memcpy( lpMem + sizeof( int ) + 1, ( char * ) &dValue, sizeof( double ) ); break;
   }

   GlobalUnlock( hMem );

   hb_retl( SetProp( hwnd, hb_parc( 2 ), hMem ) ? HB_TRUE : HB_FALSE  );
}

// usage: GetProp( hWnd, cPropName, [lHandle] ) -> Value | NIL
// [lHandle] : .T. =  return the value directly
HB_FUNC( GETPROP )
{
   HWND    hwnd = ( HWND ) HB_PARNL( 1 );
   HGLOBAL hMem;
   char *  lpMem;
   int     nLen;

   hb_ret();
   // check params
   if( ! IsWindow( hwnd ) || hb_parclen( 2 ) == 0 )
      return;

   if( hb_parldef( 3, HB_FALSE ) )
   {
      HB_RETNL( ( LONG_PTR ) GetProp( hwnd, hb_parc( 2 ) ) );
      return;
   }

   hMem = ( HGLOBAL ) GetProp( hwnd, hb_parc( 2 ) );

   if( NULL == hMem )
      return;
   else
   {
      lpMem = ( char * ) GlobalLock( hMem );

      if( lpMem == NULL )
         return;
   }

   nLen = ( int ) *( int * ) ( lpMem + 1 );
   switch( lpMem[ 0 ] )
   {
      case 'C':   hb_retclen( lpMem + sizeof( int ) + 1, nLen ); break;
      case 'L':   hb_retl( ( BOOL ) *( BOOL * ) ( lpMem + sizeof( int ) + 1 ) ); break;
      case 'D':   hb_retds( lpMem + sizeof( int ) + 1 ); break;
      case 'I':   hb_retni( ( INT ) *( INT * ) ( lpMem + sizeof( int ) + 1 ) ); break;
      case 'F':   hb_retnd( ( double ) *( double * ) ( lpMem + sizeof( int ) + 1 ) ); break;
   }

   GlobalUnlock( hMem );
}

// Usage: RemoveProp( hWnd, cPropName, [lNoFree] ) -> hMem | NIL
HB_FUNC( REMOVEPROP )
{
   HWND    hwnd = ( HWND ) HB_PARNL( 1 );
   HGLOBAL hMem;

   hb_ret();

   if( ! IsWindow( hwnd ) || ( hb_parclen( 2 ) == 0 ) )
      return;

   hMem = RemovePropA( hwnd, hb_parc( 2 ) );
   if( ( NULL != hMem ) && ( ! hb_parldef( 3, HB_FALSE ) ) )
   {
      GlobalFree( hMem );
      hMem = NULL;
   }
   // !!!
   if( NULL != hMem )
      HB_RETNL( ( LONG_PTR ) hMem );      // ( ( ULONG_PTR ) hMem )
}


static BOOL CALLBACK PropsEnumProc( HWND hWnd, LPCTSTR pszPropName, HANDLE handle, ULONG_PTR lParam );

/* Usage: aProps := EnumProps( nHandle ) */
HB_FUNC( ENUMPROPS )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      PHB_ITEM pArray = hb_itemArrayNew( 0 );

      EnumPropsEx( hWnd, ( PROPENUMPROCEX ) PropsEnumProc, ( LPARAM ) pArray );

      hb_itemReturnRelease( pArray );
   }
}

static BOOL CALLBACK PropsEnumProc( HWND hWnd, LPCTSTR pszPropName, HANDLE handle, ULONG_PTR lParam )
{
   int iLen = lstrlen( pszPropName );

   if( iLen )
   {
      PHB_ITEM item    = hb_itemArrayNew( 3 );
      LPTSTR   pszName = ( LPTSTR ) hb_xgrabz( ( iLen + 1 ) * sizeof( TCHAR ) );

      lstrcpy( pszName, pszPropName );

      hb_arraySetNInt( item, 1, ( LONG_PTR ) hWnd );
#if ! ( defined( __XHARBOUR__ ) )
      hb_arraySetCLPtr( item, 2, pszName, iLen );
#else
      hb_arraySetCPtr( item, 2, pszName, iLen );
#endif
      hb_arraySetNInt( item, 3, ( LONG_PTR ) handle );

      hb_arrayAddForward( ( PHB_ITEM ) lParam, item );
      hb_itemRelease( item );
   }

   return TRUE;
}

/*
   aProps := {}
        bCodeBlock := {|hWnd,cPropName,hHandle| HB_SYMBOL_UNUSED( hWnd ), ;
                                           AAdd( aProps, cPropName ),;
                                           HB_SYMBOL_UNUSED( hHandle ),;
                                           .T. }

        nRetVal := EnumPropsEx( nHandle, bCodeBlock )
        IF nRetVal == -2
                ? "Wrong/Missing parameters."
        ELSEIF nRetVal == -1
                ? "Not find a property."
        ELSE
                ? "Last value returned by CB is", If( nRetVal == 0, .F., .T. )
                AEVal( aProps, {|c| QOut(c) } )
        ENDIF
        ..

        CB return TRUE to continue the property list enumeration
        or return FALSE to stop the property list enumeration.

        bCodeBlock := {|hWnd,cPropName,hHandle| HB_SYMBOL_UNUSED( hWnd ), ;
                                           HB_SYMBOL_UNUSED( hHandle ),;
                                           ( ! ( cPropName == "MY_PROP" ) ) }

        nRetVal := EnumPropsEx( nHandle, bCodeBlock )
        IF nRetVal == 0
                ? "MY_PROP found"
        ..
 */
BOOL CALLBACK PropsEnumProcEx( HWND hWnd, LPCTSTR pszPropName, HANDLE handle, ULONG_PTR lParam );

HB_FUNC( ENUMPROPSEX )
{
   HWND     hWnd       = ( HWND ) HB_PARNL( 1 );
   PHB_ITEM pCodeBlock = hb_param( 2, HB_IT_BLOCK );

   if( IsWindow( hWnd ) && pCodeBlock )
      hb_retni( EnumPropsEx( hWnd, ( PROPENUMPROCEX ) PropsEnumProcEx, ( LPARAM ) pCodeBlock ) );
   else
      hb_retni( -2 );
}

BOOL CALLBACK PropsEnumProcEx( HWND hWnd, LPCTSTR pszPropName, HANDLE handle, ULONG_PTR lParam )
{
   PHB_ITEM pCodeBlock = ( PHB_ITEM ) lParam;
   int      iLen       = lstrlen( pszPropName );

   if( iLen )
   {
      PHB_ITEM pHWnd = hb_itemPutNInt( NULL, ( LONG_PTR ) hWnd );
      PHB_ITEM pPropName;
      PHB_ITEM pHandle = hb_itemPutNInt( NULL, ( LONG_PTR ) handle );
      LPTSTR   pszName = ( LPTSTR ) hb_xgrabz( ( iLen + 1 ) * sizeof( TCHAR ) );

      lstrcpy( pszName, pszPropName );
#if ! ( defined( __XHARBOUR__ ) )
      pPropName = hb_itemPutCPtr( NULL, pszName );
#else
      pPropName = hb_itemPutCPtr( NULL, pszName, iLen );
#endif
      hb_evalBlock( pCodeBlock, pHWnd, pPropName, pHandle, NULL );

      hb_itemRelease( pHWnd );
      hb_itemRelease( pPropName );
      hb_itemRelease( pHandle );

      return ( BOOL ) hb_parl( -1 );
   }

   return TRUE;
}
