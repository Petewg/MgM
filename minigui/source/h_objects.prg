/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2017-2018 Aleksandr Belov, Sergej Kiselev <bilance@bilance.lv>
 */

#include "minigui.ch"

#ifdef _OBJECT_

#include "i_winuser.ch"
#ifdef __XHARBOUR__
#include "hbcompat.ch"
#endif
#include "hbclass.ch"

#define _METHOD METHOD

///////////////////////////////////////////////////////////////////////////////
CLASS TWndData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR cVar                          INIT ''
   VAR cName                         INIT ''
   VAR cType                         INIT ''
   VAR nIndex                        INIT 0
   VAR nHandle                       INIT 0
   VAR nParent                       INIT 0
   VAR cChr                          INIT ','
   VAR lAction                       INIT .T.

   VAR oStatusBar     AS OBJECT
   VAR oProp          AS OBJECT
   VAR oName          AS OBJECT
   VAR oHand          AS OBJECT

   EXPORTED:
   VAR oCargo         AS OBJECT
   VAR oUserKeys      AS OBJECT
   VAR oEvent         AS OBJECT
   VAR oOnEventBlock  AS OBJECT

   METHOD New() INLINE ( Self )                                CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar )  INLINE ( ;
      ::nIndex := nIndex, ::cName := cName, ::nHandle := nHandle,       ;
      ::nParent:= nParent, ::cType := cType, ::cVar := cVar,            ;
      ::oCargo := oKeyData(), ::oOnEventBlock := oKeyData( Self, .T. ), ;
      ::oEvent := oKeyData( Self ), ::oUserKeys := oKeyData(),          ;
      ::oName  := oKeyData(),       ::oHand     := oKeyData(),          ;
      ::oProp  := oKeyData(),   hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   ACCESS Index                           INLINE ::nIndex
   ACCESS Name                            INLINE ::cName
   ACCESS Handle                          INLINE ::nHandle
   ACCESS Parent                          INLINE ::nParent
   ACCESS Type                            INLINE ::cType
   ACCESS VarName                         INLINE ::cVar
   ACCESS Row                             INLINE  GetWindowRow   ( ::nHandle )
   ACCESS Col                             INLINE  GetWindowCol   ( ::nHandle )
   ACCESS Width                           INLINE  GetWindowWidth ( ::nHandle )
   ACCESS Height                          INLINE  GetWindowHeight( ::nHandle )
   ACCESS ClientWidth                     INLINE _GetClientRect  ( ::nHandle )[ 3 ]
   ACCESS ClientHeight                    INLINE _GetClientRect  ( ::nHandle )[ 4 ]
   ACCESS Title                           INLINE  GetWindowText  ( ::nHandle )

   ACCESS Cargo                           INLINE _WindowCargo( Self       )
   ASSIGN Cargo( xVal )                   INLINE _WindowCargo( Self, xVal )

   ACCESS IsWindow                        INLINE .T.
   ACCESS IsControl                       INLINE .F.
   ACCESS Chr                             INLINE ::cChr
   ASSIGN Chr( cChr )                     INLINE ::cChr := iif( HB_ISCHAR( cChr ), cChr, ::cChr )

   ACCESS Action                          INLINE ::lAction
   ASSIGN Action( lAction )               INLINE ::lAction := !( Empty( lAction ) )

   ACCESS StatusBar                       INLINE ::oStatusBar
   ACCESS HasStatusBar                    INLINE !( Empty( ::oStatusBar ) )
   ACCESS bOnEvent                        INLINE ::oOnEventBlock

   ACCESS WM_nMsgW                        INLINE WM_WND_LAUNCH
   ACCESS WM_nMsgC                        INLINE WM_CTL_LAUNCH

   METHOD SetProp( xKey, xVal )           INLINE ::oProp:Set( xKey, xVal )
   METHOD GetProp( xKey       )           INLINE ::oProp:Get( xKey       )
   METHOD DelProp( xKey       )           INLINE ::oProp:Del( xKey       )

   METHOD UserKeys( Key, Block, p2, p3 )  INLINE iif( HB_ISBLOCK( Block ), ::oUserKeys:Set( Key, Block ), ;
      iif( ::lAction, ::oUserKeys:Do( Key, Block, p2, p3 ), Nil ) )

   METHOD Event   ( Key, Block, p2, p3 )  INLINE iif( HB_ISBLOCK( Block ), ::oEvent:Set( Key, Block ), ;
      iif( ::lAction, ::oEvent:Do( Key, Block, p2, p3 ), Nil ) )

   METHOD PostMsg( nKey, nHandle )        INLINE iif( ::lAction, ;
      PostMessage( ::nHandle, ::WM_nMsgW, nKey, hb_defaultValue( nHandle, 0 ) ), Nil )
   METHOD SendMsg( nKey, nHandle )        INLINE iif( ::lAction, ;
      SendMessage( ::nHandle, ::WM_nMsgW, nKey, hb_defaultValue( nHandle, 0 ) ), Nil )

   METHOD Release()                       INLINE iif( ::IsWindow, ;
      iif( ::lAction, PostMessage( ::nHandle, WM_CLOSE, 0, 0 ), Nil ), Nil )

   METHOD Restore()                       INLINE  ShowWindow( ::nHandle, SW_RESTORE )
   METHOD Show()                          INLINE _ShowWindow( ::cName )
   METHOD Hide()                          INLINE _HideWindow( ::cName )
   METHOD SetSize( y, x, w, h )           INLINE _SetWindowSizePos( ::cName, y, x, w, h )

   _METHOD DoEvent( Key, nHandle )
   _METHOD GetListType()
   _METHOD GetObj4Type( cType, lEque )
   _METHOD GetObj4Name( cName )

   METHOD GetObj( xName )                 INLINE iif( HB_ISCHAR( xName ), ::oName:Get( xName ), ;
                                                                          ::oHand:Get( xName ) )
   // Destructor
   METHOD Destroy()                       INLINE (                                              ;
      ::oCargo        := iif( HB_ISOBJECT( ::oCargo        ), ::oCargo:Destroy()       , Nil ), ;
      ::oEvent        := iif( HB_ISOBJECT( ::oEvent        ), ::oEvent:Destroy()       , Nil ), ;
      ::oOnEventBlock := iif( HB_ISOBJECT( ::oOnEventBlock ), ::oOnEventBlock:Destroy(), Nil ), ;
      ::oStatusBar    := iif( HB_ISOBJECT( ::oStatusBar    ), ::oStatusBar:Destroy()   , Nil ), ;
      ::oName         := iif( HB_ISOBJECT( ::oName         ), ::oName:Destroy()        , Nil ), ;
      ::oHand         := iif( HB_ISOBJECT( ::oHand         ), ::oHand:Destroy()        , Nil ), ;
      ::oProp         := iif( HB_ISOBJECT( ::oProp         ), ::oProp:Destroy()        , Nil ), ;
      ::oUserKeys     := iif( HB_ISOBJECT( ::oUserKeys     ), ::oUserKeys:Destroy()    , Nil ), ;
      ::nIndex := ::nParent   := ::cType   := ::cName  := ::cVar  := ::cChr  := Nil,            ;
      hmg_DelWindowObject( ::nHandle ), ::nHandle := Nil )
#ifndef __XHARBOUR__
      DESTRUCTOR DestroyObject()
#endif

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD GetListType()  CLASS TWndData

   LOCAL oType := oKeyData()
   LOCAL aType

   ::oName:Eval( {| o| oType:Set( o:cType, o:cType ) } )
   aType := oType:Eval( .T. )
   oType:Destroy()
   oType := Nil

RETURN aType

METHOD GetObj4Type( cType, lEque )  CLASS TWndData

   LOCAL aObj := {}

   IF ! Empty( cType )
      lEque := hb_defaultValue( lEque, .T. )
      If ::cChr $ cType; lEque := .F.
      ENDIF
      FOR EACH cType IN hb_ATokens( Upper( cType ), ::cChr )
         ::oName:Eval( {| oc| iif( lEque, iif( cType == oc:cType, AAdd( aObj, oc ), ), ;
            iif( cType $  oc:cType, AAdd( aObj, oc ), ) ) } )
      NEXT
   ENDIF

RETURN aObj

METHOD GetObj4Name( cName )  CLASS TWndData

   LOCAL aObj := {}

   IF ! Empty( cName )
      FOR EACH cName IN hb_ATokens( cName, ::cChr )
         ::oName:Eval( {| oc| iif( cName $ oc:cName, AAdd( aObj, oc ), Nil ) } )
      NEXT
   ENDIF

RETURN aObj

METHOD DoEvent ( Key, nHandle )  CLASS TWndData

   LOCAL o := Self 
   LOCAL i := o:Index 
   LOCAL w := o:IsWindow 

   IF ! Empty( nHandle )
      IF hmg_IsWindowObject( nHandle )                                 // control handle
         o := hmg_GetWindowObject( nHandle )
         i := o:Index
         w := o:IsWindow
      ELSEIF nHandle > 0 .and. nHandle <= Len( _HMG_aControlHandles )  // control index
         IF hmg_IsWindowObject( _HMG_aControlHandles[ nHandle ] )
            o := hmg_GetWindowObject( _HMG_aControlHandles[ nHandle ] )
            i := o:Index
            w := o:IsWindow
         ELSE
            i := nHandle
            w := .F.
         ENDIF
      ENDIF
   ENDIF

   IF w 
      RETURN Do_WindowEventProcedure ( ::oEvent:Get( Key ), i, o, Key ) 
   ENDIF 

RETURN       Do_ControlEventProcedure( ::oEvent:Get( Key ), i, o, Key ) 

#ifndef __XHARBOUR__
METHOD PROCEDURE DestroyObject()  CLASS TWndData

   ::Destroy()

RETURN
#endif
///////////////////////////////////////////////////////////////////////////////
CLASS TCnlData   INHERIT TWndData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oWin           AS OBJECT

   EXPORTED:
   METHOD New( oWnd )      INLINE ( ::Super:New(), ::oWin := oWnd, Self )   CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar )   INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ), ;
      Self )

   ACCESS Title            INLINE ::oWin:cTitle
   ACCESS Caption          INLINE _GetCaption  ( ::cName, ::oWin:cName )
   ACCESS Cargo            INLINE _ControlCargo( Self         )
   ASSIGN Cargo( xVal )    INLINE _ControlCargo( Self, , xVal )

   ACCESS Window           INLINE ::oWin
   ACCESS IsWindow         INLINE .F.
   ACCESS IsControl        INLINE .T.

   METHOD PostMsg( nKey )  INLINE iif( ::oWin:Action, PostMessage( ::oWin:nHandle, ::WM_nMsgC, nKey, ::nHandle ), )
   METHOD SendMsg( nKey )  INLINE iif( ::oWin:Action, SendMessage( ::oWin:nHandle, ::WM_nMsgC, nKey, ::nHandle ), )

   METHOD Set()            INLINE ( iif( HB_ISOBJECT( ::oWin:oName ), ::oWin:oName:Set( ::cName  , Self ), ), ;
                                    iif( HB_ISOBJECT( ::oWin:oHand ), ::oWin:oHand:Set( ::nHandle, Self ), ) )
   METHOD Del()            INLINE ( iif( HB_ISOBJECT( ::oWin:oName ), ::oWin:oName:Del( ::cName   ), ), ;
                                    iif( HB_ISOBJECT( ::oWin:oHand ), ::oWin:oHand:Del( ::nHandle ), ) )

   METHOD Get( xName )     INLINE iif( HB_ISCHAR( xName ), ::oWin:oName:Get( xName ), ;
                                                           ::oWin:oHand:Get( xName ) )

   METHOD GetListType()               INLINE ::oWin:GetListType()
   METHOD GetObj4Type( cType, lEque ) INLINE ::oWin:GetObj4Type( cType, lEque )
   METHOD GetObj4Name( cName )        INLINE ::oWin:GetObj4Name( cName )
   METHOD SetProp( xKey, xVal )       INLINE ::oWin:oProp:Set( xKey, xVal )
   METHOD GetProp( xKey       )       INLINE ::oWin:oProp:Get( xKey       )
   METHOD DelProp( xKey       )       INLINE ::oWin:oProp:Del( xKey       )

   ACCESS Value                       INLINE   _GetValue( , ,       ::nIndex )
   ASSIGN Value( xVal )               INLINE ( _SetValue( , , xVal, ::nIndex ), ;
                                               _GetValue( , ,       ::nIndex ) )

   METHOD SetFocus()                  INLINE _SetFocus      ( ::cName, ::oWin:cName )
   METHOD Refresh()                   INLINE _Refresh       ( ::nIndex )
   METHOD SetSize( y, x, w, h )       INLINE _SetControlSizePos( ::cName, ::oWin:cName, y, x, w, h )

   METHOD Disable( nPos )             INLINE _DisableControl( ::cName, ::oWin:cName, nPos )
   METHOD Enable ( nPos )             INLINE _EnableControl ( ::cName, ::oWin:cName, nPos )
   METHOD Enabled( nPos )             INLINE _IsControlEnabled ( ::cName, ::oWin:cName, nPos )

   METHOD Restore()                   INLINE ::Show()
   METHOD Show()                      INLINE _ShowControl   ( ::cName, ::oWin:cName )
   METHOD Hide()                      INLINE _HideControl   ( ::cName, ::oWin:cName )

   _METHOD DoEvent ( Key, nHandle )
   // Destructor
   METHOD Destroy()                   INLINE ( ::Del(),                                         ;
      ::oCargo        := iif( HB_ISOBJECT( ::oCargo        ), ::oCargo:Destroy()       , Nil ), ;
      ::oEvent        := iif( HB_ISOBJECT( ::oEvent        ), ::oEvent:Destroy()       , Nil ), ;
      ::oOnEventBlock := iif( HB_ISOBJECT( ::oOnEventBlock ), ::oOnEventBlock:Destroy(), Nil ), ;
      ::oUserKeys     := iif( HB_ISOBJECT( ::oUserKeys     ), ::oUserKeys:Destroy()    , Nil ), ;
      ::oName         := iif( HB_ISOBJECT( ::oName         ), ::oName:Destroy()        , Nil ), ;
      ::oHand         := iif( HB_ISOBJECT( ::oHand         ), ::oHand:Destroy()        , Nil ), ;
      ::nParent := ::nIndex := ::cName := ::cType := ::cVar := ::cChr := Nil,                   ;
      hmg_DelWindowObject( ::nHandle ), ::nHandle := Nil )
#ifndef __XHARBOUR__
      DESTRUCTOR DestroyObject()
#endif

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD DoEvent ( Key, nHandle )  CLASS TCnlData

   LOCAL o := iif( hmg_IsWindowObject( nHandle ), hmg_GetWindowObject( nHandle ), Self )

RETURN Do_ControlEventProcedure( ::oEvent:Get( Key ), o:Index, o, Key )

#ifndef __XHARBOUR__
METHOD PROCEDURE DestroyObject()  CLASS TCnlData

   ::Destroy()

RETURN
#endif
///////////////////////////////////////////////////////////////////////////////
CLASS TGetData   INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oGetBox        AS OBJECT

   EXPORTED:
   METHOD New( oWnd, oGet ) INLINE ( ::Super:New( oWnd ), ::oGetBox := oGet, Self )  CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar )   INLINE ( ;
            ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
            ::Set(), hmg_SetWindowObject( ::nHandle, Self ),             ;
              Self )

   ACCESS Caption           INLINE ::oWin:cName + "." + ::cName
   ACCESS Get               INLINE ::oGetBox
  
   ACCESS VarGet            INLINE   _GetValue( , ,       ::nIndex )
   ASSIGN VarPut( xVal )    INLINE ( _SetValue( , , xVal, ::nIndex ), ;
                                     _GetValue( , ,       ::nIndex ) )
   METHOD Destroy()         INLINE ::oGetBox := ::Super:Destroy()

ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TStbData   INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   EXPORTED:
   METHOD New( oWnd ) INLINE ( ::Super:New( oWnd ), ::oWin:oStatusBar := iif( Empty( ::oWin:oStatusBar ), ;
                                              Self, ::oWin:oStatusBar ), Self )      CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar )   INLINE (  ;
             ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
             ::Set(), hmg_SetWindowObject( ::nHandle, Self ),             ;
              Self )

   METHOD Say   ( cText, nItem )  INLINE _SetItem( ::cName, ::oWin:cName, hb_defaultValue( nItem, 1 ), ;
                                                                          hb_defaultValue( cText, '' ) )
  
   METHOD Icon  ( cIcon, nItem )  INLINE SetStatusItemIcon( ::nHandle, hb_defaultValue( nItem, 1 ), cIcon )

   METHOD Width ( nItem, nWidth ) INLINE iif( HB_ISNUMERIC( nWidth ) .AND. nWidth > 0,              ;
                             _SetStatusWidth ( ::oWin:cName, hb_defaultValue( nItem, 1 ), nWidth ), ;
                             _GetStatusItemWidth( ::oWin:nHandle, hb_defaultValue( nItem, 1 ) ) )

   METHOD Action( nItem, bBlock ) INLINE _SetStatusItemAction( hb_defaultValue( nItem, 1 ), bBlock, ;
                                                               ::oWin:nHandle )
ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TTsbData   INHERIT TCnlData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oTBrowse       AS OBJECT

   EXPORTED:
   METHOD New( oWnd, oTsb ) INLINE ( ::Super:New( oWnd ), ::oTBrowse := oTsb, Self ) CONSTRUCTOR

   METHOD Def( nIndex, cName, nHandle, nParent, cType, cVar )   INLINE ( ;
      ::Super:Def( nIndex, cName, nHandle, nParent, cType, cVar ), ;
      ::Set(), hmg_SetWindowObject( ::nHandle, Self ),           ;
      Self )

   ACCESS Caption                         INLINE ::oWin:cName + "." + ::cName
   ACCESS Tsb                             INLINE ::oTBrowse

   METHOD Enable ()                       INLINE ::oTBrowse:lEnabled := .T.
   METHOD Disable()                       INLINE ::oTBrowse:lEnabled := .F.
   METHOD Enabled ( lEnab )               INLINE ::oTBrowse:Enabled( lEnab )
   METHOD Refresh( lPaint )               INLINE ::oTBrowse:Refresh( lPaint )
   METHOD Restore()                       INLINE ::oTBrowse:Show()
   METHOD Show()                          INLINE ::oTBrowse:Show()
   METHOD Hide()                          INLINE ::oTBrowse:Hide()
   METHOD SetFocus()                      INLINE ::oTBrowse:SetFocus()

   METHOD OnEvent( nMsg, wParam, lParam ) INLINE ::Tsb:HandleEvent( nMsg, wParam, lParam )
   METHOD Destroy()                       INLINE ::oTBrowse := ::Super:Destroy()

ENDCLASS

///////////////////////////////////////////////////////////////////////////////
CLASS TWmEData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj           AS OBJECT
   VAR aMsg                           INIT hb_Hash()
   VAR lMsg                           INIT .F.

   EXPORTED:
   METHOD New( o )                    INLINE ( ::oObj := o, Self )            CONSTRUCTOR

   ACCESS IsEvent                     INLINE ::lMsg
   METHOD Set( nMsg, Block )          INLINE ( hb_HSet   ( ::aMsg, nMsg, Block ), ::lMsg := Len( ::aMsg ) > 0 )
   METHOD Get( nMsg, Def )            INLINE   hb_HGetDef( ::aMsg, nMsg, Def   )
   METHOD Del( nMsg )                 INLINE ( hb_HDel   ( ::aMsg, nMsg        ), ::lMsg := Len( ::aMsg ) > 0 )

   _METHOD Do( nMsg, wParam, lParam )
   _METHOD Destroy()

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD Do( nMsg, wParam, lParam )  CLASS TWmEData

   LOCAL o, r, b := ::Get( nMsg )

   IF HB_ISBLOCK( b )
      o := ::oObj
      IF o:IsWindow
         r := Do_WindowEventProcedure ( b, o:Index, o, nMsg, wParam, lParam ) // {|ow,nm,wp,lp| ... }
      ELSE
         r := Do_ControlEventProcedure( b, o:Index, o, nMsg, wParam, lParam ) // {|oc,nm,wp,lp| ... }
      ENDIF
   ENDIF

RETURN iif( Empty( r ), 0, 1 )

METHOD Destroy() CLASS TWmEData

   LOCAL i, k

   IF HB_ISHASH( ::aMsg )
      FOR i := 1 TO Len( ::aMsg )
         k := hb_HKeyAt( ::aMsg, i )
         hb_HSet( ::aMsg, k, Nil )
         hb_HDel( ::aMsg, k )
      NEXT
   ENDIF

   ::oObj := ::aMsg := Nil

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
CLASS TKeyData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj           AS OBJECT
   VAR aKey                      INIT hb_Hash()
   VAR lKey                      INIT .F.

   EXPORTED:
   VAR Cargo

   METHOD New()                  INLINE ( Self )              CONSTRUCTOR

   METHOD Def( o )               INLINE ( ::Obj := o, Self )

   METHOD Set( Key, Block )      INLINE ( hb_HSet   ( ::aKey, Key, Block ), ::lKey := .T. )
   METHOD Get( Key, Def )        INLINE   hb_HGetDef( ::aKey, Key, Def   )
   METHOD Del( Key )             INLINE ( iif( ::Len > 0, hb_HDel ( ::aKey, Key ), ), ::lKey := Len( ::aKey ) > 0 )

   METHOD Do ( Key, p1, p2, p3 ) BLOCK  {| Self, Key, p1, p2, p3, b| b := ::Get( Key ), ;
      iif( HB_ISBLOCK( b ), Eval( b, ::oObj, Key, p1, p2, p3 ), Nil ) }

   ACCESS Obj                    INLINE ::oObj
   ASSIGN Obj( o )               INLINE ::oObj := iif( HB_ISOBJECT( o ), o, Self )
   ACCESS Len                    INLINE Len( ::aKey )
   ACCESS IsEvent                INLINE ::lKey
   METHOD ISBLOCK( Key )         INLINE HB_ISBLOCK( ::Get( Key ) )

   _METHOD Eval( Block )
   _METHOD Sum( Key, xSum )
   _METHOD Destroy()

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD Eval( Block ) CLASS TKeyData

   LOCAL i, b := HB_ISBLOCK( Block )
   LOCAL l := HB_ISLOGICAL( Block ) .AND. Block
   LOCAL a := iif( b, Nil, Array( 0 ) )

   FOR i := 1 To ::Len
      IF     b; Eval( Block, hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i   )
      ELSEIF l; AAdd( a,     hb_HValueAt( ::aKey, i )                              )
      ELSE    ; AAdd( a,   { hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i } )
      ENDIF
   NEXT

RETURN a

METHOD Sum( Key, xSum ) CLASS TKeyData

   LOCAL sum := ::Get( Key, 0 )

   IF HB_ISNUMERIC( xSum )
      IF HB_ISNUMERIC( sum ); sum += xSum
      ELSE                  ; sum := xSum
      ENDIF
      ::Set( Key, sum )
   ELSEIF HB_ISARRAY( xSum )
      IF HB_ISARRAY( sum ) .AND. Len( sum ) == Len( xSum )
         AEval( xSum, {| s, i| sum[ i ] := iif( HB_ISNUMERIC( s ), sum[ i ] + s, s ) } )
      ELSE
         sum := xSum
      ENDIF
      ::Set( Key, sum )
   ENDIF

RETURN NIL

METHOD Destroy() CLASS TKeyData

   LOCAL i, k, o

   IF HB_ISHASH( ::aKey )
      FOR i := 1 TO Len( ::aKey )
         k := hb_HKeyAt( ::aKey, i )
         hb_HSet( ::aKey, k, Nil )
         hb_HDel( ::aKey, k )
      NEXT
   ENDIF

   IF HB_ISOBJECT( ::Cargo ) .AND. ::Cargo:ClassName == ::ClassName
      o := ::Cargo
      IF HB_ISHASH( o:aKey )
         FOR i := 1 TO Len( o:aKey )
            k := hb_HKeyAt( o:aKey, i )
            hb_HSet( o:aKey, k, Nil )
            hb_HDel( o:aKey, k )
         NEXT
      ENDIF
   ENDIF

   ::oObj := ::aKey := ::Cargo := Nil

RETURN NIL

///////////////////////////////////////////////////////////////////////////////
CLASS TThrData
///////////////////////////////////////////////////////////////////////////////

   PROTECTED:
   VAR oObj           AS OBJECT
   VAR aKey                      INIT hb_Hash()
   VAR lMT                       INIT .F.

   SYNC METHOD SGD( n, k, v )

   EXPORTED:
   VAR Cargo

   METHOD New()                  INLINE ( Self )              CONSTRUCTOR

   METHOD Def( o, lVmMt )        INLINE ( ::Obj := o, ::MT := lVmMt, Self )

   METHOD Set( Key, Block )      INLINE iif( ::lMT, ::SGD( 1, Key, Block ), hb_HSet   ( ::aKey, Key, Block ) )
   METHOD Get( Key, Def )        INLINE iif( ::lMT, ::SGD( 2, Key, Def   ), hb_HGetDef( ::aKey, Key, Def   ) )
   METHOD Del( Key )             INLINE iif( ::lMT, ::SGD( 3, Key        ), ;
      iif( hb_HHasKey( ::aKey, Key ), hb_HDel   ( ::aKey, Key ), Nil ) )

   METHOD Do ( Key, p1, p2, p3 ) BLOCK  {| Self, Key, p1, p2, p3, b| b := ::Get( Key ), ;
      iif( HB_ISBLOCK( b ), Eval( b, ::oObj, Key, p1, p2, p3 ), Nil ) }
   ACCESS MT                     INLINE ::lMT
   ASSIGN MT( lVmMt )            INLINE ::lMT  := iif( HB_ISLOGICAL( lVmMt ), lVmMt, .F. )
   ACCESS Obj                    INLINE ::oObj
   ASSIGN Obj( o )               INLINE ::oObj := iif( HB_ISOBJECT( o ), o, Self )
   ACCESS Len                    INLINE Len( ::aKey )
   METHOD ISBLOCK( Key )         INLINE HB_ISBLOCK( ::Get( Key ) )
   _METHOD Eval( Block )
   _METHOD Sum( Key, xSum )
   _METHOD Destroy()

ENDCLASS
///////////////////////////////////////////////////////////////////////////////

METHOD SGD( n, k, v ) CLASS TThrData

   SWITCH n

   CASE 1
      hb_HSet( ::aKey, k, v )
      EXIT
   CASE 2
      RETURN hb_HGetDef( ::aKey, k, v )
   CASE 3
      IF hb_HHasKey( ::aKey, k )
         hb_HDel   ( ::aKey, k )
      ENDIF
      EXIT
   CASE 4
      RETURN { hb_HKeyAt( ::aKey, k ), hb_HValueAt( ::aKey, k ) }

   END SWITCH

RETURN NIL

METHOD Eval( Block ) CLASS TThrData

   LOCAL m, i, b := HB_ISBLOCK( Block )
   LOCAL l := HB_ISLOGICAL( Block ) .AND. Block
   LOCAL a := iif( b, Nil, Array( 0 ) )

   FOR i := 1 To ::Len
      If ::lMT
         m := ::SGD( 4, i )
         IF     b; Eval( Block, m[ 2 ], m[ 1 ], i   )
         ELSEIF l; AAdd( a,     m[ 2 ]              )
         ELSE    ; AAdd( a,   { m[ 2 ], m[ 1 ], i } )
         ENDIF
      ELSE
         IF     b; Eval( Block, hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i   )
         ELSEIF l; AAdd( a,     hb_HValueAt( ::aKey, i )                              )
         ELSE    ; AAdd( a,   { hb_HValueAt( ::aKey, i ), hb_HKeyAt( ::aKey, i ), i } )
         ENDIF
      ENDIF
   NEXT

RETURN a

METHOD Sum( Key, xSum ) CLASS TThrData

   LOCAL sum := ::Get( Key, 0 )

   IF HB_ISNUMERIC( xSum )
      IF HB_ISNUMERIC( sum ); sum += xSum
      ELSE                  ; sum := xSum
      ENDIF
      ::Set( Key, sum )
   ELSEIF HB_ISARRAY( xSum )
      IF HB_ISARRAY( sum ) .AND. Len( sum ) == Len( xSum )
         AEval( xSum, {| s, i| sum[ i ] := iif( HB_ISNUMERIC( s ), sum[ i ] + s, s ) } )
      ELSE
         sum := xSum
      ENDIF
      ::Set( Key, sum )
   ENDIF

RETURN NIL

METHOD Destroy() CLASS TThrData

   LOCAL i, k, o

   IF HB_ISHASH( ::aKey )
      FOR i := 1 TO Len( ::aKey )
         k := hb_HKeyAt( ::aKey, i )
         hb_HSet( ::aKey, k, Nil )
         hb_HDel( ::aKey, k )
      NEXT
   ENDIF

   IF HB_ISOBJECT( ::Cargo ) .AND. ::Cargo:ClassName == ::ClassName
      o := ::Cargo
      IF HB_ISHASH( o:aKey )
         FOR i := 1 TO Len( o:aKey )
            k := hb_HKeyAt( o:aKey, i )
            hb_HSet( o:aKey, k, Nil )
            hb_HDel( o:aKey, k )
         NEXT
      ENDIF
   ENDIF

   ::oObj := ::aKey := ::Cargo := ::lMT := Nil

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION oWndData( nIndex, cName, nHandle, nParent, cType, cVar )
*-----------------------------------------------------------------------------*
   LOCAL o

   DEFAULT nIndex  := 0, ;
           cName   := '',;
           nHandle := 0, ;
           nParent := 0, ;
           cType   := '',;
           cVar    := ''

   IF Empty( nIndex ) .OR. Empty( nHandle ) .OR. Empty( cName )
      RETURN o
   ENDIF

   o := TWndData():New():Def( nIndex, cName, nHandle, nParent, cType, cVar )

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION oCnlData( nIndex, cName, nHandle, nParent, cType, cVar, oWin )
*-----------------------------------------------------------------------------*
   LOCAL o, ob

   DEFAULT nIndex  := 0, ;
           cName   := '',;
           nHandle := 0, ;
           nParent := 0, ;
           cType   := '',;
           cVar    := ''

   IF Empty( nIndex ) .OR. Empty( nHandle ) .OR. Empty( nParent ) .OR. Empty( cName ); RETURN o
   ENDIF

   DEFAULT oWin := hmg_GetWindowObject( nParent )

   IF HB_ISOBJECT( oWin )

      IF cType == 'TBROWSE'
         ob := _HMG_aControlIds[ nIndex ]
         o  := TTsbData():New( oWin, ob ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSEIF cType == 'GETBOX'
         ob := _HMG_aControlHeadClick[ nIndex ]
         o  := TGetData():New( oWin, ob ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSEIF cType == 'STATUSBAR'
         o  := TStbData():New( oWin     ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ELSE
         o  := TCnlData():New( oWin     ):Def( nIndex, cName, nHandle, nParent, cType, cVar )
      ENDIF

   ENDIF

RETURN o

*-----------------------------------------------------------------------------*
FUNCTION oKeyData( Obj, Event )
*-----------------------------------------------------------------------------*
   LOCAL o

   IF     HB_ISNIL    ( Event )            ; o := TKeyData():New():Def( Obj )
   ELSEIF HB_ISLOGICAL( Event ) .AND. Event; o := TWmEData():New( Obj )
   ELSE                                    ; o := TThrData():New():Def( Obj, hb_mtvm() )
   ENDIF

RETURN o

#ifdef __XHARBOUR__
*-----------------------------------------------------------------------------*
STATIC FUNCTION hb_HGetDef( hHash, xKey, xDef ) 
*-----------------------------------------------------------------------------*
   LOCAL nPos := HGetPos( hHash, xKey ) 

RETURN iif( nPos > 0, HGetValueAt( hHash, nPos ), xDef ) 

#endif

#endif
