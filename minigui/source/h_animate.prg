
#include "minigui.ch"

#ifdef _USERINIT_
*------------------------------------------------------------------------------*
INIT PROCEDURE _InitAnimateRes
*------------------------------------------------------------------------------*

   InstallMethodHandler ( 'Release', 'ReleaseAnimateRes' )
   InstallPropertyHandler ( 'File', 'SetAnimateResFile', 'GetAnimateResFile' )
   InstallPropertyHandler ( 'ResId', 'SetAnimateResId', 'GetAnimateResId' )

RETURN

*------------------------------------------------------------------------------*
FUNCTION _DefineAnimateRes ( ControlName, ParentForm, x, y, w, h, cFile, nRes, ;
      tooltip, HelpId, invisible )
*------------------------------------------------------------------------------*
   LOCAL cParentForm, mVar, ControlHandle, hAvi

   hb_default( @w, 200 )
   hb_default( @h, 50 )
   hb_default( @invisible, .F. )

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF _HMG_FrameLevel > 0
      x  := x + _HMG_ActiveFrameCol[_HMG_FrameLevel ]
      y  := y + _HMG_ActiveFrameRow[_HMG_FrameLevel ]
      ParentForm := _HMG_ActiveFrameParentFormName[_HMG_FrameLevel ]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName
   Public &mVar. := Len( _HMG_aControlNames ) + 1

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   ControlHandle := InitAnimateRes ( ParentForm, @hAvi, x, y, w, h, cFile, nRes, invisible )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, Controlhandle )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle, tooltip, GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   AAdd ( _HMG_aControlType, "ANIMATE" )
   AAdd ( _HMG_aControlNames, ControlName )
   AAdd ( _HMG_aControlHandles, ControlHandle )
   AAdd ( _HMG_aControlParentHandles, ParentForm )
   AAdd ( _HMG_aControlIds, nRes )
   AAdd ( _HMG_aControlProcedures, "" )
   AAdd ( _HMG_aControlPageMap, {} )
   AAdd ( _HMG_aControlValue, cFile )
   AAdd ( _HMG_aControlInputMask, "" )
   AAdd ( _HMG_aControllostFocusProcedure, "" )
   AAdd ( _HMG_aControlGotFocusProcedure, "" )
   AAdd ( _HMG_aControlChangeProcedure, "" )
   AAdd ( _HMG_aControlDeleted, .F. )
   AAdd ( _HMG_aControlBkColor, {} )
   AAdd ( _HMG_aControlFontColor, {} )
   AAdd ( _HMG_aControlDblClick, "" )
   AAdd ( _HMG_aControlHeadClick, {} )
   AAdd ( _HMG_aControlRow, y )
   AAdd ( _HMG_aControlCol, x )
   AAdd ( _HMG_aControlWidth, w )
   AAdd ( _HMG_aControlHeight, h )
   AAdd ( _HMG_aControlSpacing, 0 )
   AAdd ( _HMG_aControlContainerRow, iif ( _HMG_FrameLevel > 0,_HMG_ActiveFrameRow[_HMG_FrameLevel ], -1 ) )
   AAdd ( _HMG_aControlContainerCol, iif ( _HMG_FrameLevel > 0,_HMG_ActiveFrameCol[_HMG_FrameLevel ], -1 ) )
   AAdd ( _HMG_aControlPicture, "" )
   AAdd ( _HMG_aControlContainerHandle, 0 )
   AAdd ( _HMG_aControlFontName, '' )
   AAdd ( _HMG_aControlFontSize, 0 )
   AAdd ( _HMG_aControlFontAttributes, { FALSE, FALSE, FALSE, FALSE } )
   AAdd ( _HMG_aControlToolTip, tooltip  )
   AAdd ( _HMG_aControlRangeMin, 0  )
   AAdd ( _HMG_aControlRangeMax, 0  )
   AAdd ( _HMG_aControlCaption, ''  )
   AAdd ( _HMG_aControlVisible, iif( invisible, FALSE, TRUE ) )
   AAdd ( _HMG_aControlHelpId, HelpId )
   AAdd ( _HMG_aControlFontHandle, 0 )
   AAdd ( _HMG_aControlBrushHandle, 0 )
   AAdd ( _HMG_aControlEnabled, .T. )
   AAdd ( _HMG_aControlMiscData1, hAvi )
   AAdd ( _HMG_aControlMiscData2, '' )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, Len( _HMG_aControlNames ), mVar )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION SetAnimateResFile ( cWindow, cControl, cProperty, cValue )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'ANIMATE' .AND. Upper ( cProperty ) == 'FILE'

      _HMG_UserComponentProcess := .T.

      _HMG_aControlValue[ GetControlIndex ( cControl, cWindow ) ] :=  cValue

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION GetAnimateResFile ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL RetVal := Nil

   IF GetControlType ( cControl, cWindow ) == 'ANIMATE'

      _HMG_UserComponentProcess := .T.

      RetVal := _HMG_aControlValue[ GetControlIndex ( cControl, cWindow ) ]

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*------------------------------------------------------------------------------*
FUNCTION SetAnimateResId ( cWindow, cControl, cProperty, cValue )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'ANIMATE' .AND. Upper ( cProperty ) == 'RESID'

      _HMG_UserComponentProcess := .T.

      _HMG_aControlIds[ GetControlIndex ( cControl, cWindow ) ] :=  cValue

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION GetAnimateResId ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL RetVal := Nil

   IF GetControlType ( cControl, cWindow ) == 'ANIMATE'

      _HMG_UserComponentProcess := .T.

      RetVal := _HMG_aControlIds[ GetControlIndex ( cControl, cWindow ) ]

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*------------------------------------------------------------------------------*
PROCEDURE ReleaseAnimateRes ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'ANIMATE'

      UnloadAnimateLib( _GetControlObject ( cControl, cWindow ) )

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <mgdefs.h>
#include <mmsystem.h>
#include <commctrl.h>

HB_FUNC( INITANIMATERES )
{
   HWND      hwnd;
   HWND      AnimationCtrl;
   HINSTANCE avi;

   int Style = WS_CHILD | WS_VISIBLE | ACS_TRANSPARENT | ACS_CENTER | ACS_AUTOPLAY;

   INITCOMMONCONTROLSEX i;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC  = ICC_ANIMATE_CLASS;
   InitCommonControlsEx( &i );

   hwnd = ( HWND ) HB_PARNL( 1 );

   if( ! hb_parl( 9 ) )
   {
      Style = Style | WS_VISIBLE;
   }

   avi = LoadLibrary( hb_parc( 7 ) );

   AnimationCtrl = CreateWindowEx( 0,                       // Style
                                   ANIMATE_CLASS,           // Class Name
                                   NULL,                    // Window name
                                   Style,                   // Window Style
                                   hb_parni( 3 ),           // Left
                                   hb_parni( 4 ),           // Top
                                   hb_parni( 5 ),           // Right
                                   hb_parni( 6 ),           // Bottom
                                   hwnd,                    // Handle of parent
                                   ( HMENU ) HB_PARNL( 2 ), // Menu
                                   avi,                     // hInstance
                                   NULL );                  // User defined style

   Animate_OpenEx( ( HWND ) AnimationCtrl, avi, hb_parni( 8 ) );

   HB_STORNL( ( LONG_PTR ) avi, 2 );
   HB_RETNL( ( LONG_PTR ) AnimationCtrl );
}

HB_FUNC( UNLOADANIMATELIB )
{
   HINSTANCE hLib = ( HINSTANCE ) HB_PARNL( 1 );

   if( hLib )
   {
      FreeLibrary( hLib );
   }
}

#pragma ENDDUMP

#endif
