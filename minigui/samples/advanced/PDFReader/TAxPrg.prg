#include "hbclass.ch"

#ifndef __XHARBOUR__
   #xcommand TRY                => bError := errorBlock( {|oError| break( oError ) } ) ;;
                                   BEGIN SEQUENCE
   #xcommand CATCH [<!oError!>] => errorBlock( bError ) ;;
                                   RECOVER [USING <oError>] <-oError-> ;;
                                   errorBlock( bError )
#endif

CLASS TActiveX
   DATA oOle
   DATA hWnd
   DATA cWindowName
   DATA cProgId
   DATA nRow
   DATA nCol
   DATA nWidth
   DATA nHeight
   DATA nOldWinWidth
   DATA nOldWinHeight
   DATA bHide INIT .F.
   METHOD New( cWindowName, cProgId , nRow , nCol , nWidth , nHeight )
   METHOD Load()
   METHOD ReSize( nRow , nCol , nWidth , nHeight )
   METHOD Hide()
   METHOD Show()
   METHOD Release()
   METHOD Refresh()
   METHOD Adjust()
   METHOD GetRow()
   METHOD GetCol()
   METHOD GetWidth()
   METHOD GetHeight()
ENDCLASS

METHOD New( cWindowName , cProgId , nRow , nCol , nWidth , nHeight ) CLASS TActiveX
   if( empty( nRow )    , nRow    := 0 , )
   if( empty( nCol )    , nCol    := 0 , )
   if( empty( nWidth )  , nWidth  := GetProperty( cWindowName , "width" ) , )
   if( empty( nHeight ) , nHeight := GetProperty( cWindowName , "Height" ) , )
   ::nRow := nRow
   ::nCol := nCol
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::cWindowName := cWindowName
   ::cProgId := cProgId
   ::nOldWinWidth := GetProperty( cWindowName , "width" )
   ::nOldWinHeight := GetProperty( cWindowName , "Height" )
Return Self

METHOD Load() CLASS TActiveX
   local oError, bError
   local nHandle := GetFormHandle(::cWindowName)
   local xObjeto
   local OCX_Error := 0
   AtlAxWinInit()
   ::hWnd := CreateWindowEx( nHandle, ::cProgId )
   MoveWindow( ::hWnd , ::nCol , ::nRow , ::nWidth , ::nHeight , .t. )
   xObjeto := AtlAxGetDisp( ::hWnd )
   TRY
      ::oOle := CreateObject( xObjeto )
   CATCH
      MsgInfo( oError:description )
   END
RETURN ::oOle

METHOD ReSize( nRow , nCol , nWidth , nHeight ) CLASS TActiveX
   if !::bHide
      MoveWindow( ::hWnd , nCol , nRow , nWidth , nHeight , .t. )
   endif
   ::nRow := nRow
   ::nCol := nCol
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::nOldWinWidth := GetProperty( ::cWindowName , "width" )
   ::nOldWinHeight := GetProperty( ::cWindowName , "Height" )
RETURN .T.

METHOD Adjust() CLASS TActiveX
   Local nAuxRight , nAuxBottom
   nAuxRight := ( ::nOldWinWidth - ( ::nWidth + ::nCol ) )
   nAuxBottom := ( ::nOldWinHeight - ( ::nHeight + ::nRow ) )
   MoveWindow( ::hWnd , ::nCol , ::nRow , GetProperty( ::cWindowName , "width" ) - ::nCol - nAuxRight , GetProperty( ::cWindowName , "height" ) - ::nRow - nAuxBottom , .t. )
   ::nWidth := GetProperty( ::cWindowName , "width" ) - ::nCol - nAuxRight
   ::nHeight := GetProperty( ::cWindowName , "height" ) - ::nRow - nAuxBottom
   ::nOldWinWidth := GetProperty( ::cWindowName , "width" )
   ::nOldWinHeight := GetProperty( ::cWindowName , "Height" )
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
   MoveWindow( ::hWnd , 0 , 0 , 0 , 0 , .t. )
   ::bHide := .T.
RETURN .T.

METHOD Show() CLASS TActiveX
   MoveWindow( ::hWnd , ::nCol , ::nRow , ::nWidth , ::nHeight , .t. )
   ::bHide := .F.
RETURN .T.

METHOD Release() CLASS TActiveX
   IF VALTYPE( ::hWnd ) <> "U"
      DestroyWindow( ::hWnd )
   ENDIF
   AtlAxWinEnd()
RETURN .T.

METHOD Refresh() CLASS TActiveX
   ::Hide()
   ::Show()
RETURN .T.


#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include <hbapi.h>

typedef HRESULT ( WINAPI *LPAtlAxWinInit )    ( void );
typedef HRESULT ( WINAPI *LPAtlAxGetControl ) ( HWND hwnd, IUnknown** unk );

HMODULE hAtl = NULL;
LPAtlAxWinInit    AtlAxWinInit;
LPAtlAxGetControl AtlAxGetControl;

static void _Ax_Init( void )
{
   if( ! hAtl )
   {
      hAtl = LoadLibrary( "Atl.Dll" );
      AtlAxWinInit    = ( LPAtlAxWinInit )    GetProcAddress( hAtl, "AtlAxWinInit" );
      AtlAxGetControl = ( LPAtlAxGetControl ) GetProcAddress( hAtl, "AtlAxGetControl" );
      ( AtlAxWinInit )();
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
   IUnknown *pUnk;
   IDispatch *pDisp;
   _Ax_Init();
   AtlAxGetControl( (HWND)hb_parnl( 1 ), &pUnk );
   pUnk->lpVtbl->QueryInterface( pUnk, &IID_IDispatch, ( void ** ) &pDisp );
   hb_retnl( (LONG)pDisp );
}

HB_FUNC_STATIC( CREATEWINDOWEX ) // hWnd, cProgId -> hActiveXWnd
{
   HWND hControl;
   hControl = CreateWindowEx( 0, "AtlAxWin", hb_parc( 2 ),
              WS_VISIBLE|WS_CHILD, 0, 0, 0, 0, (HWND)hb_parnl( 1 ), 0, 0, NULL );
   hb_retnl( (LONG) hControl );
}

#pragma ENDDUMP
