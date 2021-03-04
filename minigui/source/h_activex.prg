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
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"

#ifdef _USERINIT_

#include "i_winuser.ch"

ANNOUNCE CLASS_TACTIVEX

*-----------------------------------------------------------------------------*
INIT PROCEDURE _InitActiveX
*-----------------------------------------------------------------------------*

   InstallMethodHandler ( 'Release', 'ReleaseActiveX' )
   InstallPropertyHandler ( 'XObject', 'SetActiveXObject', 'GetActiveXObject' )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineActivex ( cControlName, cParentForm, nRow, nCol, nWidth, nHeight, cProgId, aEvents, clientedge )
*-----------------------------------------------------------------------------*
   LOCAL nControlHandle, nParentFormHandle
   LOCAL mVar
   LOCAL k
   LOCAL oActiveX
   LOCAL oOle
   LOCAL nAtlDllHandle

   // If defined inside DEFINE WINDOW structure, determine cParentForm
   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      cParentForm := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   // If defined inside a Tab structure, adjust position and determine cParentForm
   IF _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol[ _HMG_FrameLevel ]
      nRow += _HMG_ActiveFrameRow[ _HMG_FrameLevel ]
      cParentForm := _HMG_ActiveFrameParentFormName[ _HMG_FrameLevel ]
   ENDIF

   IF .NOT. _IsWindowDefined ( cParentForm )
      MsgMiniGuiError ( "Window: " + cParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cControlName, cParentForm )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " Already defined." )
   ENDIF

   IF ! ISCHARACTER ( cProgId )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PROGID Property Invalid Type." )
   ENDIF

   IF Empty ( cProgId )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PROGID Can't be empty." )
   ENDIF

   // Define public variable associated with control
   mVar := '_' + cParentForm + '_' + cControlName

   // Init ActiveX object

   oActiveX := TActiveX():New( cParentForm, cProgId, nRow, nCol, nWidth, nHeight )

   // Create OLE control

   oOle := oActiveX:Load()

   nControlHandle := oActiveX:hWnd
   nAtlDllHandle := oActiveX:hAtl

   IF !Empty( oActiveX:hSink )
      IF ISARRAY ( aEvents ) .AND. Len ( aEvents ) > 0 .AND. ISARRAY ( aEvents [1] )
         AEval ( aEvents, { | x | oActiveX:EventMap( x [1], x [2] ) } )
      ENDIF
   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, nControlhandle )
   ENDIF

   IF hb_defaultValue( clientedge, .F. )
      ChangeStyle ( nControlHandle, WS_EX_CLIENTEDGE, , .T. )
   ENDIF

   nParentFormHandle := GetFormHandle ( cParentForm )

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_aControlType[ k ] := "ACTIVEX"
   _HMG_aControlNames[ k ] :=  cControlName
   _HMG_aControlHandles[ k ] := nControlHandle
   _HMG_aControlParenthandles[ k ] := nParentFormHandle
   _HMG_aControlIds[ k ] :=  oActiveX
   _HMG_aControlProcedures[ k ] :=  ""
   _HMG_aControlPageMap[ k ] :=  aEvents
   _HMG_aControlValue[ k ] :=  Nil
   _HMG_aControlInputMask[ k ] :=  ""
   _HMG_aControllostFocusProcedure[ k ] :=  ""
   _HMG_aControlGotFocusProcedure[ k ] :=  ""
   _HMG_aControlChangeProcedure[ k ] :=  ""
   _HMG_aControlDeleted[ k ] :=  .F.
   _HMG_aControlBkColor[ k ] :=   Nil
   _HMG_aControlFontColor[ k ] :=  Nil
   _HMG_aControlDblClick[ k ] :=  ""
   _HMG_aControlHeadClick[ k ] :=  {}
   _HMG_aControlRow[ k ] := nRow
   _HMG_aControlCol[ k ] := nCol
   _HMG_aControlWidth[ k ] := nWidth
   _HMG_aControlHeight[ k ] := nHeight
   _HMG_aControlSpacing[ k ] := 0
   _HMG_aControlContainerRow[ k ] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameRow[ _HMG_FrameLevel ], -1 )
   _HMG_aControlContainerCol[ k ] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameCol[ _HMG_FrameLevel ], -1 )
   _HMG_aControlPicture[ k ] :=  ""
   _HMG_aControlContainerHandle[ k ] :=  0
   _HMG_aControlFontName[ k ] :=  Nil
   _HMG_aControlFontSize[ k ] :=  Nil
   _HMG_aControlFontAttributes[ k ] :=  {}
   _HMG_aControlToolTip[ k ] :=  ''
   _HMG_aControlRangeMin[ k ] :=  0
   _HMG_aControlRangeMax[ k ] :=  0
   _HMG_aControlCaption[ k ] :=   ''
   _HMG_aControlVisible[ k ] :=  .T.
   _HMG_aControlHelpId[ k ] :=  nAtlDllHandle
   _HMG_aControlFontHandle[ k ] :=  Nil
   _HMG_aControlBrushHandle[ k ] :=  0
   _HMG_aControlEnabled[ k ] :=  .T.
   _HMG_aControlMiscData1[ k ] := oOle
   _HMG_aControlMiscData2[ k ] := ''

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE ReleaseActiveX ( cWindow, cControl )
*-----------------------------------------------------------------------------*
   LOCAL oActiveX

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      oActiveX := _HMG_aControlIds[ GetControlIndex ( cControl, cWindow ) ]
      IF ValType( oActiveX ) <> "U"
         oActiveX:Release()
      ENDIF

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION SetActiveXObject ( cWindow, cControl )
*-----------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      MsgExclamation ( 'This Property is Read Only!', 'Warning' )

   ENDIF

   _HMG_UserComponentProcess := .F.

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION GetActiveXObject ( cWindow, cControl )
*-----------------------------------------------------------------------------*
   LOCAL RetVal := Nil

   IF GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      _HMG_UserComponentProcess := .T.

      RetVal := _GetControlObject ( cControl, cWindow )

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION _GetControlObject ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar
   LOCAL i

   mVar := '_' + ParentForm + '_' + ControlName
   i := &mVar
   IF i == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aControlMiscData1[ i ] )

/*
   Marcelo Torres, Noviembre de 2006.
   TActivex para [x]Harbour Minigui.
   Adaptacion del trabajo de:
   ---------------------------------------------
   Oscar Joel Lira Lira [oSkAr]
   Clase TAxtiveX_FreeWin para Fivewin
   Noviembre 8 del 2006
   email: oscarlira78@hotmail.com
   http://freewin.sytes.net
   CopyRight 2006 Todos los Derechos Reservados
   ---------------------------------------------
*/

#include "hbclass.ch"

CLASS TActiveX
   DATA oOle
   DATA hWnd
   DATA cWindowName
   DATA cProgId
   DATA hSink     INIT NIL
   DATA hAtl      INIT NIL
   DATA nRow
   DATA nCol
   DATA nWidth
   DATA nHeight
   DATA nOldWinWidth
   DATA nOldWinHeight
   DATA bHide INIT .F.
   METHOD New( cWindowName, cProgId, nRow, nCol, nWidth, nHeight )
   METHOD Load()
   METHOD ReSize( nRow, nCol, nWidth, nHeight )
   METHOD Hide()
   METHOD Show()
   METHOD Release()
   METHOD Refresh()
   METHOD Adjust()
   METHOD GetRow()
   METHOD GetCol()
   METHOD GetWidth()
   METHOD GetHeight()

   DATA aAxEv        INIT {}
   DATA aAxExec      INIT {}
   METHOD EventMap( nMsg, xExec, oSelf )

ENDCLASS

METHOD New( cWindowName, cProgId, nRow, nCol, nWidth, nHeight ) CLASS TActiveX

   if( Empty( nRow )    , nRow    := 0 , )
   if( Empty( nCol )    , nCol    := 0 , )
   if( Empty( nWidth )  , nWidth  := GetProperty( cWindowName , "width" ) , )
   if( Empty( nHeight ) , nHeight := GetProperty( cWindowName , "Height" ) , )
   ::nRow := nRow
   ::nCol := nCol
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::cWindowName := cWindowName
   ::cProgId := cProgId
   ::nOldWinWidth := GetProperty( cWindowName, "width" )
   ::nOldWinHeight := GetProperty( cWindowName, "Height" )

RETURN Self

METHOD Load() CLASS TActiveX

   LOCAL oError
   LOCAL xObjeto, hSink
   LOCAL nHandle := GetFormHandle( ::cWindowName )

   AtlAxWinInit()
   ::hWnd := CreateWindowEx( nHandle, ::cProgId )
   MoveWindow( ::hWnd, ::nCol, ::nRow, ::nWidth, ::nHeight, .T. )
   xObjeto := AtlAxGetDisp( ::hWnd )
   ::hAtl := xObjeto
   TRY
      ::oOle := CreateObject( xObjeto )
   CATCH oError
      MsgInfo( oError:description )
   END
   IF SetupConnectionPoint( ::hAtl, @hSink, ::aAxEv, ::aAxExec ) == S_OK
      ::hSink := hSink
   ENDIF

RETURN ::oOle

METHOD ReSize( nRow, nCol, nWidth, nHeight ) CLASS TActiveX

   IF !::bHide
      MoveWindow( ::hWnd, nCol, nRow, nWidth, nHeight, .T. )
   ENDIF
   ::nRow := nRow
   ::nCol := nCol
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::nOldWinWidth := GetProperty( ::cWindowName, "width" )
   ::nOldWinHeight := GetProperty( ::cWindowName, "Height" )

RETURN .T.

METHOD Adjust() CLASS TActiveX

   LOCAL nAuxRight, nAuxBottom

   nAuxRight := ( ::nOldWinWidth - ( ::nWidth + ::nCol ) )
   nAuxBottom := ( ::nOldWinHeight - ( ::nHeight + ::nRow ) )
   MoveWindow( ::hWnd, ::nCol, ::nRow, GetProperty( ::cWindowName, "width" ) - ::nCol - nAuxRight, GetProperty( ::cWindowName, "height" ) - ::nRow - nAuxBottom, .T. )
   ::nWidth := GetProperty( ::cWindowName, "width" ) - ::nCol - nAuxRight
   ::nHeight := GetProperty( ::cWindowName, "height" ) - ::nRow - nAuxBottom
   ::nOldWinWidth := GetProperty( ::cWindowName, "width" )
   ::nOldWinHeight := GetProperty( ::cWindowName, "Height" )

RETURN .T.

METHOD GetRow() CLASS TActiveX
RETURN ::nRow

METHOD GetCol() CLASS TActiveX
RETURN ::nCol

METHOD GetWidth() CLASS TActiveX
RETURN ::nWidth

METHOD GetHeight() CLASS TActiveX
RETURN ::nHeight

METHOD Hide() CLASS TActiveX
   MoveWindow( ::hWnd, 0, 0, 0, 0, .T. )
   ::bHide := .T.

RETURN .T.

METHOD Show() CLASS TActiveX

   MoveWindow( ::hWnd, ::nCol, ::nRow, ::nWidth, ::nHeight, .T. )
   ::bHide := .F.

RETURN .T.

METHOD Release() CLASS TActiveX

   IF ValType( ::hWnd ) <> "U"
      DestroyWindow( ::hWnd )
   ENDIF
   IF !Empty( ::hSink )
      ShutdownConnectionPoint( ::hSink )
   ENDIF
   ReleaseDispatch( ::hAtl )
   AtlAxWinEnd()

RETURN .T.

METHOD Refresh() CLASS TActiveX

   ::Hide()
   ::Show()

RETURN .T.

METHOD EventMap( nMsg, xExec, oSelf )

   LOCAL nAt

   nAt := AScan( ::aAxEv, nMsg )
   IF nAt == 0
      AAdd( ::aAxEv, nMsg )
      AAdd( ::aAxExec, { NIL, NIL } )
      nAt := Len( ::aAxEv )
   ENDIF
   ::aAxExec[ nAt ] := { xExec, oSelf }

RETURN NIL

#pragma BEGINDUMP

#ifndef CINTERFACE
   #define CINTERFACE  1
#endif

#ifndef NONAMELESSUNION
   #define NONAMELESSUNION
#endif

#include <mgdefs.h>
#include <commctrl.h>
#include <ocidl.h>

#include <hbvm.h>
#include <hbstack.h>
#include <hbapiitm.h>

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif

extern HB_PTRUINT wapi_GetProcAddress( HMODULE hModule, const char * lpProcName );

typedef HRESULT ( WINAPI * LPAtlAxWinInit )( void );
typedef HRESULT ( WINAPI * LPAtlAxGetControl )( HWND, IUnknown ** );

static HMODULE    hAtl = NULL;
LPAtlAxWinInit    AtlAxWinInit;
LPAtlAxGetControl AtlAxGetControl;

static void _Ax_Init( void )
{
   if( ! hAtl )
   {
      hAtl            = LoadLibrary( TEXT( "Atl.Dll" ) );
      AtlAxWinInit    = ( LPAtlAxWinInit ) wapi_GetProcAddress( hAtl, "AtlAxWinInit" );
      AtlAxGetControl = ( LPAtlAxGetControl ) wapi_GetProcAddress( hAtl, "AtlAxGetControl" );
      ( AtlAxWinInit ) ( );
   }
}

HB_FUNC( ATLAXWININIT )
{
   _Ax_Init();
}

HB_FUNC( ATLAXWINEND )
{
   if( hAtl )
      FreeLibrary( hAtl );
}

HB_FUNC( ATLAXGETDISP ) // hWnd -> pDisp
{
   IUnknown *  pUnk;
   IDispatch * pDisp;

   _Ax_Init();
   AtlAxGetControl( ( HWND ) HB_PARNL( 1 ), &pUnk );
#if defined( __cplusplus )
   pUnk->QueryInterface( IID_IDispatch, ( void ** ) &pDisp );
#else
   pUnk->lpVtbl->QueryInterface( pUnk, &IID_IDispatch, ( void ** ) &pDisp );
#endif
   pUnk->lpVtbl->Release( pUnk );
   HB_RETNL( ( LONG_PTR ) pDisp );
}

HB_FUNC_STATIC( CREATEWINDOWEX ) // ( hWnd, cProgId ) -> hActiveXWnd
{
   HWND hControl;

   hControl = CreateWindowEx( 0, TEXT( "AtlAxWin" ), 
#ifndef UNICODE
                          hb_parc( 2 ),
#else
                          AnsiToWide( ( char * ) hb_parc( 2 ) ),
#endif
                          WS_VISIBLE | WS_CHILD, 0, 0, 0, 0, ( HWND ) HB_PARNL( 1 ), 0, 0, NULL );
   HB_RETNL( ( LONG_PTR ) hControl );
}

#ifdef __USEHASHEVENTS
   #include <hashapi.h>
#endif

//------------------------------------------------------------------------------
HRESULT hb_oleVariantToItem( PHB_ITEM pItem, VARIANT * pVariant );

//------------------------------------------------------------------------------
static void HB_EXPORT hb_itemPushList( ULONG ulRefMask, ULONG ulPCount, PHB_ITEM ** pItems )
{
   PHB_ITEM itmRef;
   ULONG    ulParam;

   if( ulPCount )
   {
      itmRef = hb_itemNew( NULL );

      // initialize the reference item
      //itmRef->type = HB_IT_BYREF;
      //itmRef->item.asRefer.offset = -1;
      //itmRef->item.asRefer.BasePtr.itemsbasePtr = pItems;
      for( ulParam = 0; ulParam < ulPCount; ulParam++ )
      {
         if( ulRefMask & ( 1L << ulParam ) )
         {
            // when item is passed by reference then we have to put
            // the reference on the stack instead of the item itself
            //itmRef->item.asRefer.value = ulParam+1;
            hb_vmPush( itmRef );
         }
         else
         {
            hb_vmPush( ( *pItems )[ ulParam ] );
         }
      }

      hb_itemRelease( itmRef );
   }
}

//------------------------------------------------------------------------------
//self is a macro which defines our IEventHandler struct as so:
//
// typedef struct {
//    IEventHandlerVtbl  *lpVtbl;
// } IEventHandler;

#undef  INTERFACE
#define INTERFACE  IEventHandler

DECLARE_INTERFACE_( INTERFACE, IDispatch )
{
   // IUnknown functions
   STDMETHOD( QueryInterface          ) ( THIS_ REFIID, void **                                                          ) PURE;
   STDMETHOD_( ULONG, AddRef           ) ( THIS                                                                           ) PURE;
   STDMETHOD_( ULONG, Release          ) ( THIS                                                                           ) PURE;
   // IDispatch functions
   STDMETHOD_( ULONG, GetTypeInfoCount ) ( THIS_ UINT *                                                                   ) PURE;
   STDMETHOD_( ULONG, GetTypeInfo      ) ( THIS_ UINT, LCID, ITypeInfo * *                                                 ) PURE;
   STDMETHOD_( ULONG, GetIDsOfNames    ) ( THIS_ REFIID, LPOLESTR *, UINT, LCID, DISPID *                                 ) PURE;
   STDMETHOD_( ULONG, Invoke           ) ( THIS_ DISPID, REFIID, LCID, WORD, DISPPARAMS *, VARIANT *, EXCEPINFO *, UINT * ) PURE;
};

// In other words, it defines our IEventHandler to have nothing
// but a pointer to its VTable. And of course, every COM object must
// start with a pointer to its VTable.
//
// But we actually want to add some more members to our IEventHandler.
// We just don't want any app to be able to know about, and directly
// access, those members. So here we'll define a MyRealIEventHandler that
// contains those extra members. The app doesn't know that we're
// really allocating and giving it a MyRealIEventHAndler object. We'll
// lie and tell it we're giving a plain old IEventHandler. That's ok
// because a MyRealIEventHandler starts with the same VTable pointer.
//
// We add a DWORD reference count so that self IEventHandler
// can be allocated (which we do in our IClassFactory object's
// CreateInstance()) and later freed. And, we have an extra
// BSTR (pointer) string, which is used by some of the functions we'll
// add to IEventHandler

typedef struct
{

   IEventHandler * lpVtbl;
   DWORD count;
   IConnectionPoint * pIConnectionPoint;          // Ref counted of course.
   DWORD    dwEventCookie;
   IID      device_event_interface_iid;
   PHB_ITEM pEvents;

#ifndef __USEHASHEVENTS
   PHB_ITEM pEventsExec;
#endif

} MyRealIEventHandler;

//------------------------------------------------------------------------------
// Here are IEventHandler's functions.
//------------------------------------------------------------------------------
// Every COM object's interface must have the 3 functions QueryInterface(),
// AddRef(), and Release().

// IEventHandler's QueryInterface()
static HRESULT STDMETHODCALLTYPE QueryInterface( IEventHandler * self, REFIID vTableGuid, void ** ppv )
{
   // Check if the GUID matches IEvenetHandler VTable's GUID. We gave the C variable name
   // IID_IEventHandler to our VTable GUID. We can use an OLE function called
   // IsEqualIID to do the comparison for us. Also, if the caller passed a
   // IUnknown GUID, then we'll likewise return the IEventHandler, since it can
   // masquerade as an IUnknown object too. Finally, if the called passed a
   // IDispatch GUID, then we'll return the IExample3, since it can masquerade
   // as an IDispatch too

   if( IsEqualIID( vTableGuid, &IID_IUnknown ) )
   {
      *ppv = ( IUnknown * ) self;
      // Increment the count of callers who have an outstanding pointer to self object
      self->lpVtbl->AddRef( self );
      return S_OK;
   }

   if( IsEqualIID( vTableGuid, &IID_IDispatch ) )
   {
      *ppv = ( IDispatch * ) self;
      self->lpVtbl->AddRef( self );
      return S_OK;
   }

   if( IsEqualIID( vTableGuid, &( ( ( MyRealIEventHandler * ) self )->device_event_interface_iid ) ) )
   {
      *ppv = ( IDispatch * ) self;
      self->lpVtbl->AddRef( self );
      return S_OK;
   }

   // We don't recognize the GUID passed to us. Let the caller know self,
   // by clearing his handle, and returning E_NOINTERFACE.
   *ppv = 0;
   return E_NOINTERFACE;
}

//------------------------------------------------------------------------------
// IEventHandler's AddRef()
static ULONG STDMETHODCALLTYPE AddRef( IEventHandler * self )
{
   // Increment IEventHandler's reference count, and return the updated value.
   // NOTE: We have to typecast to gain access to any data members. These
   // members are not defined  (so that an app can't directly access them).
   // Rather they are defined only above in our MyRealIEventHandler
   // struct. So typecast to that in order to access those data members
   return ++( ( MyRealIEventHandler * ) self )->count;
}

//------------------------------------------------------------------------------
// IEventHandler's Release()
static ULONG STDMETHODCALLTYPE Release( IEventHandler * self )
{
   if( --( ( MyRealIEventHandler * ) self )->count == 0 )
   {
      GlobalFree( self );
      return 0;
   }
   return ( ( MyRealIEventHandler * ) self )->count;
}

//------------------------------------------------------------------------------
// IEventHandler's GetTypeInfoCount()
static ULONG STDMETHODCALLTYPE GetTypeInfoCount( IEventHandler * self, UINT * pCount )
{
   HB_SYMBOL_UNUSED( self );
   HB_SYMBOL_UNUSED( pCount );
   return ( ULONG ) E_NOTIMPL;
}

//------------------------------------------------------------------------------
// IEventHandler's GetTypeInfo()
static ULONG STDMETHODCALLTYPE GetTypeInfo( IEventHandler * self, UINT itinfo, LCID lcid, ITypeInfo ** pTypeInfo )
{
   HB_SYMBOL_UNUSED( self );
   HB_SYMBOL_UNUSED( itinfo );
   HB_SYMBOL_UNUSED( lcid );
   HB_SYMBOL_UNUSED( pTypeInfo );
   return ( ULONG ) E_NOTIMPL;
}

//------------------------------------------------------------------------------
// IEventHandler's GetIDsOfNames()
static ULONG STDMETHODCALLTYPE GetIDsOfNames( IEventHandler * self, REFIID riid, LPOLESTR * rgszNames, UINT cNames, LCID lcid, DISPID * rgdispid )
{
   HB_SYMBOL_UNUSED( self );
   HB_SYMBOL_UNUSED( riid );
   HB_SYMBOL_UNUSED( rgszNames );
   HB_SYMBOL_UNUSED( cNames );
   HB_SYMBOL_UNUSED( lcid );
   HB_SYMBOL_UNUSED( rgdispid );
   return ( ULONG ) E_NOTIMPL;
}

//------------------------------------------------------------------------------
// IEventHandler's Invoke()
// self is where the action happens
// self function receives events (by their ID number) and distributes the processing
// or them or ignores them
static ULONG STDMETHODCALLTYPE Invoke( IEventHandler * self, DISPID dispid, REFIID riid,
                                       LCID lcid, WORD wFlags, DISPPARAMS * params, VARIANT * result, EXCEPINFO * pexcepinfo,
                                       UINT * puArgErr )
{
   PHB_ITEM   pItem;
   int        iArg, i;
   PHB_ITEM   pItemArray[ 32 ]; // max 32 parameters?
   PHB_ITEM * pItems;
   ULONG      ulRefMask = 0;
   HB_SIZE    ulPos;
   PHB_ITEM   Key;

   Key = hb_itemNew( NULL );

   // We implement only a "default" interface
   if( ! IsEqualIID( riid, &IID_NULL ) )
      return ( ULONG ) DISP_E_UNKNOWNINTERFACE;

   HB_SYMBOL_UNUSED( lcid );
   HB_SYMBOL_UNUSED( wFlags );
   HB_SYMBOL_UNUSED( result );
   HB_SYMBOL_UNUSED( pexcepinfo );
   HB_SYMBOL_UNUSED( puArgErr );

   // delegate work to somewhere else in PRG
   //***************************************

#ifdef __USEHASHEVENTS

   if( hb_hashScan( ( ( MyRealIEventHandler * ) self )->pEvents, hb_itemPutNL( Key, dispid ),
                    &ulPos ) )
   {
      PHB_ITEM pArray = hb_hashGetValueAt( ( ( MyRealIEventHandler * ) self )->pEvents, ulPos );

#else

   #if defined( __XHARBOUR__ )
   ulPos = hb_arrayScan( ( ( MyRealIEventHandler * ) self )->pEvents, hb_itemPutNL( Key, dispid ),
                         NULL, NULL, 0, 0 );
   #else
   ulPos = hb_arrayScan( ( ( MyRealIEventHandler * ) self )->pEvents, hb_itemPutNL( Key, dispid ),
                         NULL, NULL, 0 );
   #endif

   if( ulPos )
   {
      PHB_ITEM pArray = hb_arrayGetItemPtr( ( ( MyRealIEventHandler * ) self )->pEventsExec, ulPos );

#endif
      PHB_ITEM pExec = hb_arrayGetItemPtr( pArray, 1 );

      if( pExec )
      {

         if( hb_vmRequestReenter() )
         {

         switch( hb_itemType( pExec ) )
         {

            case HB_IT_BLOCK:
            {
#ifdef __XHARBOUR__
               hb_vmPushSymbol( &hb_symEval );
#else
               hb_vmPushEvalSym();
#endif
               hb_vmPush( pExec );
               break;
            }

            case HB_IT_STRING:
            {
               PHB_ITEM pObject = hb_arrayGetItemPtr( pArray, 2 );
               hb_vmPushSymbol( hb_dynsymSymbol( hb_dynsymFindName( hb_itemGetCPtr( pExec ) ) ) );

               if( HB_IS_OBJECT( pObject ) )
                  hb_vmPush( pObject );
               else
                  hb_vmPushNil();
               break;

            }

            case HB_IT_POINTER:
            {
               hb_vmPushSymbol( hb_dynsymSymbol( ( ( PHB_SYMB ) pExec )->pDynSym ) );
               hb_vmPushNil();
               break;
            }

         }

         iArg = params->cArgs;
         for( i = 1; i <= iArg; i++ )
         {
            pItem = hb_itemNew( NULL );
            hb_oleVariantToItem( pItem, &( params->rgvarg[ iArg - i ] ) );
            pItemArray[ i - 1 ] = pItem;
            // set bit i
            ulRefMask |= ( 1L << ( i - 1 ) );
         }

         if( iArg )
         {
            pItems = pItemArray;
            hb_itemPushList( ulRefMask, iArg, &pItems );
         }

         // execute
         hb_vmDo( ( USHORT ) iArg );

         // En caso de que los parametros sean pasados por referencia
         for( i = iArg; i > 0; i-- )
         {
            if( ( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.vt & VT_BYREF ) == VT_BYREF )
            {

               switch( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.vt )
               {

                  //case VT_UI1|VT_BYREF:
                  //   *((&(params->rgvarg[iArg-i]))->n1.n2.n3.pbVal) = va_arg(argList,unsigned char*);  //pItemArray[i-1]
                  //   break;
                  case VT_I2 | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.piVal ) = ( short ) hb_itemGetNI( pItemArray[ i - 1 ] );
                     break;
                  case VT_I4 | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.plVal ) = ( long ) hb_itemGetNL( pItemArray[ i - 1 ] );
                     break;
                  case VT_R4 | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.pfltVal ) = ( float ) hb_itemGetND( pItemArray[ i - 1 ] );
                     break;
                  case VT_R8 | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.pdblVal ) = ( double ) hb_itemGetND( pItemArray[ i - 1 ] );
                     break;
                  case VT_BOOL | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.pboolVal ) = ( VARIANT_BOOL ) ( hb_itemGetL( pItemArray[ i - 1 ] ) ? 0xFFFF : 0 );
                     break;
                  //case VT_ERROR|VT_BYREF:
                  //   *((&(params->rgvarg[iArg-i]))->n1.n2.n3.pscode) = va_arg(argList, SCODE*);
                  //   break;
                  case VT_DATE | VT_BYREF:
                     *( ( &( params->rgvarg[ iArg - i ] ) )->n1.n2.n3.pdate ) = ( DATE ) ( double ) ( hb_itemGetDL( pItemArray[ i - 1 ] ) - 2415019 );
                     break;
                  //case VT_CY|VT_BYREF:
                  //   *((&(params->rgvarg[iArg-i]))->n1.n2.n3.pcyVal) = va_arg(argList, CY*);
                  //   break;
                  //case VT_BSTR|VT_BYREF:
                  //   *((&(params->rgvarg[iArg-i]))->n1.n2.n3.pbstrVal = va_arg(argList, BSTR*);
                  //   break;
                  //case VT_UNKNOWN|VT_BYREF:
                  //   pArg->ppunkVal = va_arg(argList, LPUNKNOWN*);
                  //   break;
                  //case VT_DISPATCH|VT_BYREF:
                  //   pArg->ppdispVal = va_arg(argList, LPDISPATCH*);
                  //   break;

               }

            }

         }

         hb_vmRequestRestore();
         }

      }

   }

   hb_itemRelease( Key );

   return S_OK;

}

//------------------------------------------------------------------------------
// Here's IEventHandler's VTable. It never changes so we can declare it static
static const IEventHandlerVtbl IEventHandler_Vtbl = {
   QueryInterface,
   AddRef,
   Release,
   GetTypeInfoCount,
   GetTypeInfo,
   GetIDsOfNames,
   Invoke
};

//------------------------------------------------------------------------------
// constructor
// params:
// device_interface        - refers to the interface type of the COM object (whose event we are trying to receive).
// device_event_interface  - indicates the interface type of the outgoing interface supported by the COM object.
//                           This will be the interface that must be implemented by the Sink object.
//                           is essentially derived from IDispatch, our Sink object (self IEventHandler)
//                           is also derived from IDispatch.

typedef IEventHandler device_interface;

// Hash  // SetupConnectionPoint( oOle:hObj, @hSink, hEvents )             -> nError
// Array // SetupConnectionPoint( oOle:hObj, @hSink, aEvents, aExecEvent ) -> nError

HB_FUNC( SETUPCONNECTIONPOINT )
{
   IConnectionPointContainer * pIConnectionPointContainerTemp = NULL;
   IUnknown *                  pIUnknown = NULL;
   IConnectionPoint *          m_pIConnectionPoint = NULL;
   IEnumConnectionPoints *     m_pIEnumConnectionPoints;
   HRESULT hr;
   IID     rriid = {0};
   register IEventHandler * selfobj;
   DWORD dwCookie = 0;

   device_interface * pdevice_interface = ( device_interface * ) HB_PARNL( 1 );
   MyRealIEventHandler * pThis;

   // Allocate our IEventHandler object (actually a MyRealIEventHandler)
   // intentional misrepresentation of size

   selfobj = ( IEventHandler * ) GlobalAlloc( GMEM_FIXED, sizeof( MyRealIEventHandler ) );

   if( ! selfobj )
   {
      hr = E_OUTOFMEMORY;
   }
   else
   {
      // Store IEventHandler's VTable in the object
      selfobj->lpVtbl = ( IEventHandlerVtbl * ) &IEventHandler_Vtbl;

      // Increment the reference count so we can call Release() below and
      // it will deallocate only if there is an error with QueryInterface()
      ( ( MyRealIEventHandler * ) selfobj )->count = 0;

      //((MyRealIEventHandler *) selfobj)->device_event_interface_iid = &riid;
      ( ( MyRealIEventHandler * ) selfobj )->device_event_interface_iid = IID_IDispatch;

      // Query self object itself for its IUnknown pointer which will be used
      // later to connect to the Connection Point of the device_interface object.
      hr = selfobj->lpVtbl->QueryInterface( selfobj, &IID_IUnknown, ( void ** ) ( void * ) &pIUnknown );
      if( hr == S_OK && pIUnknown )
      {

         // Query the pdevice_interface for its connection point.
         hr = pdevice_interface->lpVtbl->QueryInterface( pdevice_interface,
                                                         &IID_IConnectionPointContainer, ( void ** ) ( void * ) &pIConnectionPointContainerTemp );

         if( hr == S_OK && pIConnectionPointContainerTemp )
         {
            hr = pIConnectionPointContainerTemp->lpVtbl->EnumConnectionPoints( pIConnectionPointContainerTemp, &m_pIEnumConnectionPoints );

            if( hr == S_OK && m_pIEnumConnectionPoints )
            {
               do
               {
                  hr = m_pIEnumConnectionPoints->lpVtbl->Next( m_pIEnumConnectionPoints, 1, &m_pIConnectionPoint, NULL );
                  if( hr == S_OK )
                  {
                     if( m_pIConnectionPoint->lpVtbl->GetConnectionInterface( m_pIConnectionPoint, &rriid ) == S_OK )
                     {
                        break;
                     }
                  }

               }
               while( hr == S_OK );
               m_pIEnumConnectionPoints->lpVtbl->Release( m_pIEnumConnectionPoints );
            }

            pIConnectionPointContainerTemp->lpVtbl->Release( pIConnectionPointContainerTemp );
            pIConnectionPointContainerTemp = NULL;
         }

         if( hr == S_OK && m_pIConnectionPoint )
         {

            if( hr == S_OK )
            {
               ( ( MyRealIEventHandler * ) selfobj )->device_event_interface_iid = rriid;
            }

            hr = m_pIConnectionPoint->lpVtbl->Advise( m_pIConnectionPoint, pIUnknown, &dwCookie );
            ( ( MyRealIEventHandler * ) selfobj )->pIConnectionPoint = m_pIConnectionPoint;
            ( ( MyRealIEventHandler * ) selfobj )->dwEventCookie     = dwCookie;

         }

         pIUnknown->lpVtbl->Release( pIUnknown );
         pIUnknown = NULL;

      }
   }

   if( selfobj )
   {
      pThis = ( MyRealIEventHandler * ) selfobj;

#ifndef __USEHASHEVENTS
      pThis->pEventsExec = hb_itemNew( hb_param( 4, HB_IT_ANY ) );
#endif

      pThis->pEvents = hb_itemNew( hb_param( 3, HB_IT_ANY ) );
      HB_STORNL( ( LONG_PTR ) pThis, 2 );

   }

   hb_retnl( hr );

}

HB_FUNC( SHUTDOWNCONNECTIONPOINT )
{
   MyRealIEventHandler * self = ( MyRealIEventHandler * ) HB_PARNL( 1 );

   if( self->pIConnectionPoint )
   {
      self->pIConnectionPoint->lpVtbl->Unadvise( self->pIConnectionPoint, self->dwEventCookie );
      self->dwEventCookie = 0;
      self->pIConnectionPoint->lpVtbl->Release( self->pIConnectionPoint );
      self->pIConnectionPoint = NULL;
   }
}

HB_FUNC( RELEASEDISPATCH )
{
   IDispatch * pObj;

   pObj = ( IDispatch * ) HB_PARNL( 1 );
   pObj->lpVtbl->Release( pObj );
}

#pragma ENDDUMP

#endif
