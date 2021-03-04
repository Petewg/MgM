/*
 * MINIGUI - Harbour Win32 GUI library source code
 *
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 */

#include "minigui.ch"

#ifdef _USERINIT_
*------------------------------------------------------------------------------*
INIT PROCEDURE _InitSPButton
*------------------------------------------------------------------------------*

   InstallEventHandler  ( 'SPButtonEventHandler' )
   InstallMethodHandler ( 'SetFocus', 'SPButtonSetFocus' )
   InstallMethodHandler ( 'Enable', 'SPButtonEnable' )
   InstallMethodHandler ( 'Disable', 'SPButtonDisable' )

RETURN

*------------------------------------------------------------------------------*
PROCEDURE _DefineSplitButton ( cName, nRow, nCol, cCaption, bAction, cParent, ;
   lDefault, w, h, tooltip, fontname, fontsize, bold, italic, underline, strikeout )
*------------------------------------------------------------------------------*
   LOCAL hControlHandle, hParentFormHandle
   LOCAL FontHandle
   LOCAL mVar
   LOCAL nId
   LOCAL k

   IF _HMG_BeginWindowActive
      cParent := _HMG_ActiveFormName
   ENDIF

   // If defined inside a Tab structure, adjust position and determine cParent

   IF _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol[ _HMG_FrameLevel ]
      nRow += _HMG_ActiveFrameRow[ _HMG_FrameLevel ]
      cParent := _HMG_ActiveFrameParentFormName[ _HMG_FrameLevel ]
   ENDIF

   IF .NOT. _IsWindowDefined ( cParent )
      MsgMiniGuiError( "Window: " + cParent + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cName, cParent )
      MsgMiniGuiError ( "Control: " + cName + " Of " + cParent + " Already defined." )
   ENDIF

   hb_default( @w, 148 )
   hb_default( @h, 38 )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   mVar := '_' + cParent + '_' + cName

   k := _GetControlFree()
   nId := _GetId()

   hParentFormHandle := GetFormHandle ( cParent )

   hControlHandle := InitSplitButton ( ;
      hParentFormHandle, ;
      nRow, ;
      nCol, ;
      cCaption, ;
      lDefault, ;
      w, h, ;
      nId ;
      )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, hControlHandle )
   ENDIF

   IF FontHandle != 0
      _SetFontHandle( hControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )
      FontHandle := _SetFont ( hControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := 'SPBUTTON'
   _HMG_aControlNames [k] := cName
   _HMG_aControlHandles [k] := hControlHandle
   _HMG_aControlParenthandles [k] := hParentFormHandle
   _HMG_aControlIds [k] :=  nId
   _HMG_aControlProcedures [k] := bAction
   _HMG_aControlPageMap [k] :=  {}
   _HMG_aControlValue [k] :=  Nil
   _HMG_aControlInputMask [k] :=  ""
   _HMG_aControllostFocusProcedure [k] :=  ""
   _HMG_aControlGotFocusProcedure [k] :=  ""
   _HMG_aControlChangeProcedure [k] :=  ""
   _HMG_aControlDeleted [k] :=  .F.
   _HMG_aControlBkColor [k] :=   Nil
   _HMG_aControlFontColor [k] :=  Nil
   _HMG_aControlDblClick [k] :=  ""
   _HMG_aControlHeadClick [k] :=  {}
   _HMG_aControlRow [k] := nRow
   _HMG_aControlCol [k] := nCol
   _HMG_aControlWidth [k] := w
   _HMG_aControlHeight [k] := h
   _HMG_aControlSpacing [k] := 0
   _HMG_aControlContainerRow [k] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameRow[ _HMG_FrameLevel ], -1 )
   _HMG_aControlContainerCol [k] :=  iif ( _HMG_FrameLevel > 0, _HMG_ActiveFrameCol[ _HMG_FrameLevel ], -1 )
   _HMG_aControlPicture [k] :=  Nil
   _HMG_aControlContainerHandle [k] :=  0
   _HMG_aControlFontName [k] :=  fontname
   _HMG_aControlFontSize [k] :=  fontsize
   _HMG_aControlFontAttributes [k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip [k] :=  tooltip
   _HMG_aControlRangeMin [k] :=  0
   _HMG_aControlRangeMax [k] :=  0
   _HMG_aControlCaption [k] :=  cCaption
   _HMG_aControlVisible [k] :=  .T.
   _HMG_aControlHelpId [k] :=  0
   _HMG_aControlFontHandle [k] :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( hControlHandle , tooltip , GetFormToolTipHandle ( cParent ) )
   ENDIF

RETURN

#define WM_COMMAND   0x0111
#define BN_CLICKED   0
#define WM_NOTIFY    0x004E
#define BCN_FIRST    -1250
#define BCN_DROPDOWN (BCN_FIRST + 0x0002)
*------------------------------------------------------------------------------*
FUNCTION SPButtonEventHandler ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
   LOCAL xRetVal := Nil
   LOCAL i

   HB_SYMBOL_UNUSED( hWnd )

   IF nMsg == WM_NOTIFY

      IF GetNotifyCode ( lParam ) == BCN_DROPDOWN  // Notify for dropdown button
         xRetVal := 0
         LaunchDropdownMenu( GetHwndFrom ( lParam ) )
      ENDIF

   ELSEIF nMsg == WM_COMMAND

      i := AScan ( _HMG_aControlHandles, lParam )

      IF i > 0 .AND. _HMG_aControlType[ i ] == 'SPBUTTON'

         IF HiWord ( wParam ) == BN_CLICKED
            xRetVal := 0
            _DoControlEventProcedure ( _HMG_aControlProcedures[ i ], i )
         ENDIF

      ENDIF

   ENDIF

RETURN xRetVal

#define BM_SETSTYLE        244
#define BS_SPLITBUTTON     0x0000000C
#define BS_DEFSPLITBUTTON  0x0000000D
*------------------------------------------------------------------------------*
PROCEDURE SPButtonSetFocus ( cWindow, cControl )
*------------------------------------------------------------------------------*
   LOCAL hWnd
   LOCAL ParentFormHandle
   LOCAL ControlCount
   LOCAL x

   IF GetControlType ( cControl, cWindow ) == 'SPBUTTON'

      _HMG_UserComponentProcess := .T.

      hWnd := GetControlHandle ( cControl, cWindow )

      ControlCount := Len ( _HMG_aControlNames )
      ParentFormHandle := _HMG_aControlParentHandles [ GetControlIndex ( cControl, cWindow ) ]
      FOR x := 1 TO ControlCount
         IF _HMG_aControlType [x] == 'SPBUTTON'
            IF _HMG_aControlParentHandles [x] == ParentFormHandle
               SendMessage ( _HMG_aControlHandles [x], BM_SETSTYLE, BS_SPLITBUTTON, LOWORD( 1 ) )
            ENDIF
         ENDIF
      NEXT

      SetFocus( hWnd )
      SendMessage ( hWnd, BM_SETSTYLE, BS_DEFSPLITBUTTON, LOWORD( 1 ) )

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE SPButtonEnable ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'SPBUTTON'

      EnableWindow ( GetControlHandle ( cControl, cWindow ) )

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE SPButtonDisable ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'SPBUTTON'

      DisableWindow ( GetControlHandle ( cControl, cWindow ) )

      _HMG_UserComponentProcess := .T.

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN

*------------------------------------------------------------------------------*
STATIC FUNCTION LaunchDropdownMenu( nHwnd )
*------------------------------------------------------------------------------*
   LOCAL aPos := {0, 0, 0, 0}
   LOCAL nIdx

   nIdx := AScan ( _HMG_aControlHandles, nHwnd )

   IF nIdx > 0

      GetWindowRect( nHwnd, aPos )

      TrackPopupMenu( _HMG_aControlRangeMax[ nIdx ], aPos[ 1 ] + 1, ;
      	aPos[ 2 ] + _HMG_aControlHeight[ nIdx ], _HMG_aControlParentHandles[ nIdx ] )

   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#define BS_SPLITBUTTON     0x0000000C
#define BS_DEFSPLITBUTTON  0x0000000D

#include <mgdefs.h>

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif

HB_FUNC( INITSPLITBUTTON )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );
   HWND hbutton;
   int  Style;
#ifndef UNICODE
   LPCSTR lpWindowName = hb_parc( 4 );
#else
   LPWSTR lpWindowName = AnsiToWide( ( char * ) hb_parc( 4 ) );
#endif

   Style = BS_SPLITBUTTON;

   if( hb_parl( 5 ) )
      Style = BS_DEFSPLITBUTTON;

   hbutton = CreateWindow( TEXT( "button" ),
                           lpWindowName,
                           Style | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | BS_PUSHBUTTON | WS_VISIBLE | WS_TABSTOP,
                           hb_parni( 3 ),
                           hb_parni( 2 ),
                           hb_parni( 6 ),
                           hb_parni( 7 ),
                           hwnd,
                           ( HMENU ) HB_PARNL( 8 ),
                           GetModuleHandle( NULL ),
                           NULL );

   HB_RETNL( ( LONG_PTR ) hbutton );
}

#pragma ENDDUMP

#endif
