/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2017 Aleksandr Belov, Sergej Kiselev <bilance@bilance.lv>
 */

#include "minigui.ch"

*-----------------------------------------------------------------------------*
FUNCTION _WindowCargo( FormName, xValue )
*-----------------------------------------------------------------------------*
#ifdef _OBJECT_
   LOCAL o := iif( HB_ISOBJECT( FormName ), FormName, _WindowObj( FormName ) )
   LOCAL i := iif( HB_ISOBJECT( o       ), o:Index, GetFormIndex( FormName ) )
#else
   LOCAL i := GetFormIndex( FormName )
#endif
   IF i > 0
      IF PCount() > 1;        _HMG_aFormMiscData2[ i ] := xValue
      ELSE           ; RETURN _HMG_aFormMiscData2[ i ]
      ENDIF
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _ControlCargo( ControlName, FormName, xValue )
*-----------------------------------------------------------------------------*
#ifdef _OBJECT_
   LOCAL o := iif( HB_ISOBJECT( ControlName ), ControlName, _ControlObj( ControlName, FormName ) )
   LOCAL i := iif( HB_ISOBJECT( o ), o:Index, GetControlIndex( ControlName, FormName ) )
#else
   LOCAL i := GetControlIndex( ControlName, FormName )
#endif
   IF i > 0
      IF PCount() > 2;        _HMG_aControlMiscData2[ i ] := xValue
      ELSE           ; RETURN _HMG_aControlMiscData2[ i ]
      ENDIF
   ENDIF

RETURN NIL

#ifdef _OBJECT_

*-----------------------------------------------------------------------------*
FUNCTION _WindowObj( FormName )
*-----------------------------------------------------------------------------*
   LOCAL h := iif( HB_ISNUMERIC( FormName ), FormName, GetFormHandle( FormName ) )

RETURN hmg_GetWindowObject( h )

*-----------------------------------------------------------------------------*
FUNCTION _ControlObj( ControlName, FormName )
*-----------------------------------------------------------------------------*
   LOCAL h := iif( HB_ISNUMERIC( ControlName ), ControlName, ;
      GetControlHandle( ControlName, FormName ) )

   IF ISARRAY( h )
      h := h[ 1 ]
   ENDIF

RETURN hmg_GetWindowObject( h )

*-----------------------------------------------------------------------------*
FUNCTION Do_Obj( nHandle, bBlock, p1, p2, p3 )
*-----------------------------------------------------------------------------*
   LOCAL o

   IF hmg_IsWindowObject( nHandle )
      o := hmg_GetWindowObject( nHandle )
      IF ISBLOCK( bBlock )
         RETURN Eval( bBlock, o, p1, p2, p3 )
      ENDIF
   ENDIF

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION Do_ControlEventProcedure ( bBlock, i, p1, p2, p3, p4 )
*-----------------------------------------------------------------------------*
   LOCAL RetVal

   IF HB_ISBLOCK( bBlock ) .AND. i > 0

      _PushEventInfo()

      _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles, _HMG_aControlParentHandles[ i ] )
      _HMG_ThisType := 'C'
      _HMG_ThisIndex := i
      _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
      _HMG_ThisControlName := _HMG_aControlNames[ _HMG_ThisIndex ]

      RetVal := Eval( bBlock, p1, p2, p3, p4 )

      _PopEventInfo()

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION Do_WindowEventProcedure ( bBlock, i, p1, p2, p3, p4 )
*-----------------------------------------------------------------------------*
   LOCAL RetVal

   IF HB_ISBLOCK( bBlock ) .AND. i > 0

      _PushEventInfo()

      _HMG_ThisFormIndex := i
      _HMG_ThisEventType := ''
      _HMG_ThisType := 'W'
      _HMG_ThisIndex := i
      _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
      _HMG_ThisControlName :=  ""

      RetVal := Eval( bBlock, p1, p2, p3, p4 )

      _PopEventInfo()

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNC Do_OnWndInit( i, cVar )
*-----------------------------------------------------------------------------*
   LOCAL nIndex  := i
   LOCAL cName   := _HMG_aFormNames[ i ]
   LOCAL nHandle := _HMG_aFormHandles[ i ]
   LOCAL nParent := _HMG_aFormParentHandle[ i ]
   LOCAL cType   := _HMG_aFormType[ i ]

RETURN oWndData( nIndex, cName, nHandle, nParent, cType, cVar )

*-----------------------------------------------------------------------------*
FUNC Do_OnWndRelease( i )
*-----------------------------------------------------------------------------*
   LOCAL o
   LOCAL hWnd := _HMG_aFormHandles[ i ]

   IF hmg_IsWindowObject( hWnd )
      o := hmg_GetWindowObject( hWnd )
      IF __objHasMethod( o, 'Del'     ); o:Del()
      ENDIF
      IF __objHasMethod( o, 'Destroy' ); o:Destroy()
      ENDIF
      RETURN .T.
   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNC Do_OnCtlInit( i, cVar )
*-----------------------------------------------------------------------------*
   LOCAL nCtlIndex := i
   LOCAL cCtlName  := _HMG_aControlNames[ i ]
   LOCAL nHandle   := iif( ISARRAY( _HMG_aControlHandles[ i ] ), ;
      _HMG_aControlHandles[ i ][ 1 ], _HMG_aControlHandles[ i ] )
   LOCAL nParent   := _HMG_aControlParentHandles[ i ]
   LOCAL cFormName := GetParentFormName( i )
   LOCAL cCtlType  := iif( Empty( cFormName ), _HMG_aControlType[ i ], ;
      GetProperty( cFormName, cCtlName, "Type" ) )

RETURN oCnlData( nCtlIndex, cCtlName, nHandle, nParent, cCtlType, cVar )

*-----------------------------------------------------------------------------*
FUNC Do_OnCtlRelease( i )
*-----------------------------------------------------------------------------*
   LOCAL o
   LOCAL hWnd := _HMG_aControlHandles[ i ]

   IF hmg_IsWindowObject( hWnd )
      o := hmg_GetWindowObject( hWnd )
      IF __objHasMethod( o, 'Del'     ); o:Del()
      ENDIF
      IF __objHasMethod( o, 'Destroy' ); o:Destroy()
      ENDIF
      RETURN .T.
   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNC Do_OnWndLaunch( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   IF hmg_IsWindowObject ( hWnd )
      hmg_GetWindowObject( hWnd ):DoEvent( wParam, lParam )
   ENDIF

   HB_SYMBOL_UNUSED( nMsg )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNC Do_OnCtlLaunch( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   IF ! Empty( lParam ); hWnd := lParam
   ENDIF

   IF hmg_IsWindowObject ( hWnd )
      hmg_GetWindowObject( hWnd ):DoEvent( wParam, lParam )
   ENDIF

   HB_SYMBOL_UNUSED( nMsg )

RETURN NIL


#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"
#include <commctrl.h>

HB_FUNC( HMG_SETWINDOWOBJECT )
{
   PHB_ITEM pObject;
   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      pObject = ( PHB_ITEM ) hb_param( 2, HB_IT_OBJECT );

      if( pObject && HB_IS_OBJECT( pObject ) )
      {
         pObject = hb_itemNew( pObject );

         hb_gcLock( pObject );    // Ref++

         SetWindowLongPtr( hWnd, GWLP_USERDATA, ( LPARAM ) pObject );

         hb_retl( TRUE );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );
}

HB_FUNC( HMG_DELWINDOWOBJECT )
{
   PHB_ITEM pObject;
   HWND     hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      pObject = ( PHB_ITEM ) GetWindowLongPtr( hWnd, GWLP_USERDATA );

      SetWindowLongPtr( hWnd, GWLP_USERDATA, 0 );

      if( pObject && HB_IS_OBJECT( pObject ) )
      {
         hb_gcUnlock( pObject );     // Ref --
         hb_itemRelease( pObject );
      }
   }
}

HB_FUNC( HMG_GETWINDOWOBJECT )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
      hb_itemReturn( ( PHB_ITEM ) GetWindowLongPtr( hWnd, GWLP_USERDATA ) );
   else
      hb_ret();
}

HB_FUNC( HMG_ISWINDOWOBJECT )
{
   PHB_ITEM pObject;

   HWND hWnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hWnd ) )
   {
      pObject = ( PHB_ITEM ) GetWindowLongPtr( hWnd, GWLP_USERDATA );

      hb_retl( pObject && HB_IS_OBJECT( pObject ) );
   }
   else
      hb_retl( FALSE );
}

#pragma ENDDUMP

#endif
