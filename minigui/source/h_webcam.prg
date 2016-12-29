
#include "minigui.ch"

#ifdef _USERINIT_
#include "i_winuser.ch"

*------------------------------------------------------------------------------*
INIT PROCEDURE _InitWebCam
*------------------------------------------------------------------------------*

   InstallMethodHandler ( 'Start', '_StartWebCam' )
   InstallMethodHandler ( 'Release', '_ReleaseWebCam' )

RETURN

*------------------------------------------------------------------------------*
FUNCTION _DefineWebCam ( ControlName, ParentForm, x, y, w, h, lStart, nRate, tooltip, HelpId )
*------------------------------------------------------------------------------*
   LOCAL cParentForm, mVar, ControlHandle

   DEFAULT w     TO 320
   DEFAULT h     TO 240
   DEFAULT nRate TO 30

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF _HMG_FrameLevel > 0
      x := x + _HMG_ActiveFrameCol[_HMG_FrameLevel ]
      y := y + _HMG_ActiveFrameRow[_HMG_FrameLevel ]
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

   ControlHandle := _CreateWebCam ( ParentForm, x, y, w, h )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, Controlhandle )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle, tooltip, GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   AAdd ( _HMG_aControlType, "WEBCAM" )
   AAdd ( _HMG_aControlNames, ControlName )
   AAdd ( _HMG_aControlHandles, ControlHandle )
   AAdd ( _HMG_aControlParentHandles, ParentForm )
   AAdd ( _HMG_aControlIds, 0 )
   AAdd ( _HMG_aControlProcedures, "" )
   AAdd ( _HMG_aControlPageMap, {} )
   AAdd ( _HMG_aControlValue, nRate )
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
   AAdd ( _HMG_aControlVisible, .F. )
   AAdd ( _HMG_aControlHelpId, HelpId )
   AAdd ( _HMG_aControlFontHandle, 0 )
   AAdd ( _HMG_aControlBrushHandle, 0 )
   AAdd ( _HMG_aControlEnabled, .T. )
   AAdd ( _HMG_aControlMiscData1, 0 )
   AAdd ( _HMG_aControlMiscData2, '' )

   IF lStart
      IF ! _StartWebCam ( cParentForm, ControlName )
         MsgAlert( "Webcam service is unavailable!", "Alert" )
      ENDIF
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _CreateWebCam ( ParentForm, x, y, w, h )
*------------------------------------------------------------------------------*

RETURN cap_CreateCaptureWindow( "WebCam", hb_bitOr( WS_CHILD, WS_VISIBLE ), y, x, w, h, ParentForm, 0 )

*------------------------------------------------------------------------------*
FUNCTION _StartWebCam ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL hWnd
   LOCAL lSuccess

   hWnd := GetControlHandle ( cControl, cWindow )

   IF cap_DriverConnect( hWnd, 0 )

      lSuccess := cap_PreviewScale( hWnd, .T. )

      lSuccess := lSuccess .AND. cap_PreviewRate( hWnd, GetControlValue ( cControl, cWindow ) )

      lSuccess := lSuccess .AND. cap_Preview( hWnd, .T. )

   ELSE
      // error connecting to video source
      DestroyWindow( hWnd )

      lSuccess := .F.

   ENDIF

   _HMG_aControlVisible [ GetControlIndex ( cControl, cWindow ) ] := lSuccess

RETURN lSuccess

*------------------------------------------------------------------------------*
PROCEDURE _ReleaseWebCam ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL hWnd

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'WEBCAM'

      hWnd := GetControlHandle ( cControl, cWindow )

      IF !Empty( hWnd )

         cap_DriverDisconnect( hWnd )

         DestroyWindow( hWnd )

         _EraseControl ( GetControlIndex ( cControl, cWindow ), GetFormIndex ( cWindow ) )

      ENDIF

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN


#pragma BEGINDUMP

#include <mgdefs.h>
#include <vfw.h>

#if defined( __BORLANDC__ )
#pragma warn -use /* unused var */
#endif

HB_FUNC( CAP_CREATECAPTUREWINDOW )
{
   HB_RETNL( ( LONG_PTR ) capCreateCaptureWindow( ( LPCSTR ) hb_parc( 1 ),
                    ( DWORD ) hb_parnl( 2 ),
                    hb_parni( 3 ), hb_parni( 4 ),
                    hb_parni( 5 ), hb_parni( 6 ),
                    ( HWND ) HB_PARNL( 7 ),
                    hb_parni( 8 ) ) );
}

HB_FUNC( CAP_DRIVERCONNECT )
{
   hb_retl( capDriverConnect( ( HWND ) HB_PARNL( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( CAP_DRIVERDISCONNECT )
{
   hb_retl( capDriverDisconnect( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( CAP_PREVIEWRATE )
{
   hb_retl( capPreviewRate( ( HWND ) HB_PARNL( 1 ), ( WORD ) hb_parnl( 2 ) ) );
}

HB_FUNC( CAP_PREVIEWSCALE )
{
   hb_retl( capPreviewScale( ( HWND ) HB_PARNL( 1 ), hb_parl( 2 ) ) );
}

HB_FUNC( CAP_PREVIEW )
{
   hb_retl( capPreview( ( HWND ) HB_PARNL( 1 ), hb_parl( 2 ) ) );
}

HB_FUNC( CAP_EDITCOPY )
{
   hb_retl( capEditCopy( ( HWND ) HB_PARNL( 1 ) ) );
}

#pragma ENDDUMP

#endif
