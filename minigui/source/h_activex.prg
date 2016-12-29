
#include "minigui.ch"

#ifdef _USERINIT_
*------------------------------------------------------------------------------*
INIT PROCEDURE _InitActiveX
*------------------------------------------------------------------------------*

   InstallMethodHandler ( 'Release', 'ReleaseActiveX' )
   InstallPropertyHandler ( 'Object', 'SetActiveXObject', 'GetActiveXObject' )

RETURN

*------------------------------------------------------------------------------*
PROCEDURE _DefineActivex ( cControlName, cParentForm, nRow, nCol, nWidth, nHeight, cProgId )
*------------------------------------------------------------------------------*
   LOCAL mVar, nControlHandle, aControlHandles, k, nParentFormHandle, oOle
   LOCAL nAtlDllHandle, nInterfacePointer

   // If defined inside DEFINE WINDOW structure, determine cParentForm

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      cParentForm := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   // If defined inside a Tab structure, adjust position and determine cParentForm

   IF _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol[_HMG_FrameLevel ]
      nRow += _HMG_ActiveFrameRow[_HMG_FrameLevel ]
      cParentForm := _HMG_ActiveFrameParentFormName[_HMG_FrameLevel ]
   ENDIF

   IF .NOT. _IsWindowDefined ( cParentForm )
      MsgMiniGuiError ( "Window: " + cParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cControlName, cParentForm )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " Already defined." )
   ENDIF

   IF ValType ( cProgId ) <> 'C'
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PROGID Property Invalid Type." )
   ENDIF

   IF Empty ( cProgId )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " PROGID Can't be empty." )
   ENDIF

   // Define public variable associated with control

   mVar := '_' + cParentForm + '_' + cControlName

   nParentFormHandle := GetFormHandle ( cParentForm )

   // Init Activex

   aControlHandles := InitActivex( nParentFormHandle, cProgId, nCol, nRow, nWidth, nHeight )

   nControlHandle := aControlHandles[ 1 ]
   nInterfacePointer := aControlHandles[ 2 ]
   nAtlDllHandle := aControlHandles[ 3 ]

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, nControlhandle )
   ENDIF

   // Create OLE control

   oOle := CreateObject( nInterfacePointer )

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType[ k ] := "ACTIVEX"
   _HMG_aControlNames[ k ] :=  cControlName
   _HMG_aControlHandles[ k ] := nControlHandle
   _HMG_aControlParenthandles[ k ] := nParentFormHandle
   _HMG_aControlIds[ k ] :=  0
   _HMG_aControlProcedures[ k ] := ""
   _HMG_aControlPageMap[ k ] :=  {}
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
   _HMG_aControlContainerRow[ k ] :=  iif ( _HMG_FrameLevel > 0,_HMG_ActiveFrameRow[_HMG_FrameLevel ], -1 )
   _HMG_aControlContainerCol[ k ] :=  iif ( _HMG_FrameLevel > 0,_HMG_ActiveFrameCol[_HMG_FrameLevel ], -1 )
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

*------------------------------------------------------------------------------*
PROCEDURE ReleaseActiveX ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      ExitActivex( GetControlHandle ( cControl, cWindow ), _HMG_aControlHelpId[ GetControlIndex ( cControl, cWindow ) ] )

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*------------------------------------------------------------------------------*
FUNCTION SetActiveXObject ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      MsgExclamation ( 'This Property is Read Only!', 'Warning' )

   ENDIF

   _HMG_UserComponentProcess := .F.

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION GetActiveXObject ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL RetVal := Nil

   IF GetControlType ( cControl, cWindow ) == 'ACTIVEX'

      _HMG_UserComponentProcess := .T.
      RetVal := _GetControlObject ( cControl, cWindow )

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*------------------------------------------------------------------------------*
FUNCTION _GetControlObject ( ControlName, ParentForm )
*------------------------------------------------------------------------------*
   LOCAL mVar, i

   mVar := '_' + ParentForm + '_' + ControlName
   i := &mVar
   IF i == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aControlMiscData1[ i ] )

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>
#include <olectl.h>

typedef HRESULT ( WINAPI * LPAtlAxGetControl )( HWND hwnd, IUnknown ** unk );
typedef HRESULT ( WINAPI * LPAtlAxWinInit )( void );

/*

   InitActivex() function.
   2008.07.15 - Roberto López <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com

   Inspired by the works of Oscar Joel Lira Lira <oskar78@users.sourceforge.net>
   for Freewin project
   http://www.sourceforge.net/projects/freewin

 */

HB_FUNC( INITACTIVEX )
{
   HMODULE           hlibrary;
   HWND              hchild;
   IUnknown *        pUnk;
   IDispatch *       pDisp;
   LPAtlAxWinInit    AtlAxWinInit;
   LPAtlAxGetControl AtlAxGetControl;

   hlibrary        = LoadLibrary( "Atl.Dll" );
   AtlAxWinInit    = ( LPAtlAxWinInit ) GetProcAddress( hlibrary, "AtlAxWinInit" );
   AtlAxGetControl = ( LPAtlAxGetControl ) GetProcAddress( hlibrary, "AtlAxGetControl" );
   AtlAxWinInit();

   hchild = CreateWindowEx( 0L, "AtlAxWin", hb_parc( 2 ), WS_CHILD | WS_VISIBLE, hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ), hb_parni( 6 ), ( HWND ) HB_PARNL( 1 ), 0, 0, 0 );

   AtlAxGetControl( ( HWND ) hchild, &pUnk );
#if defined( __cplusplus )
   pUnk->QueryInterface( IID_IDispatch, ( void ** ) &pDisp );
#else
   pUnk->lpVtbl->QueryInterface( pUnk, &IID_IDispatch, ( void ** ) &pDisp );
#endif
   hb_reta( 3 );
   HB_STORVNL( ( LONG_PTR ) hchild, -1, 1 );
   HB_STORVNL( ( LONG_PTR ) pDisp, -1, 2 );
   HB_STORVNL( ( LONG_PTR ) hlibrary, -1, 3 );
}

HB_FUNC( EXITACTIVEX )
{
   DestroyWindow( ( HWND ) HB_PARNL( 1 ) );
   FreeLibrary( ( HMODULE ) HB_PARNL( 2 ) );
}

#pragma ENDDUMP

#endif
