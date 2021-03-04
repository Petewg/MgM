/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

ANIMATERES Control Source Code
Copyright 2011 Grigory Filatov <gfilatov@inbox.ru>

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
   LOCAL ControlHandle
   LOCAL hAvi
   LOCAL cParentForm
   LOCAL mVar

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
   Public &mVar. := Len ( _HMG_aControlNames ) + 1

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   ControlHandle := InitAnimateRes ( ParentForm, @hAvi, x, y, w, h, cFile, nRes, invisible )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, Controlhandle )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle, tooltip, GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   AAdd ( _HMG_aControlType, "ANIMATERES" )
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
   AAdd ( _HMG_aControlBkColor, Nil )
   AAdd ( _HMG_aControlFontColor, Nil )
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

   IF GetControlType ( cControl, cWindow ) == 'ANIMATERES' .AND. Upper ( cProperty ) == 'FILE'

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

   IF GetControlType ( cControl, cWindow ) == 'ANIMATERES'

      _HMG_UserComponentProcess := .T.

      RetVal := _HMG_aControlValue[ GetControlIndex ( cControl, cWindow ) ]

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*------------------------------------------------------------------------------*
FUNCTION SetAnimateResId ( cWindow, cControl, cProperty, cValue )
*------------------------------------------------------------------------------*

   IF GetControlType ( cControl, cWindow ) == 'ANIMATERES' .AND. Upper ( cProperty ) == 'RESID'

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

   IF GetControlType ( cControl, cWindow ) == 'ANIMATERES'

      _HMG_UserComponentProcess := .T.

      RetVal := _HMG_aControlIds[ GetControlIndex ( cControl, cWindow ) ]

   ELSE

      _HMG_UserComponentProcess := .F.

   ENDIF

RETURN RetVal

*------------------------------------------------------------------------------*
PROCEDURE ReleaseAnimateRes ( cWindow, cControl )
*------------------------------------------------------------------------------*

   IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'ANIMATERES'

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

#ifdef UNICODE
   LPWSTR AnsiToWide( LPCSTR );
#endif

HB_FUNC( INITANIMATERES )
{
   HWND      hwnd;
   HWND      AnimationCtrl;
   HINSTANCE avi;
#ifndef UNICODE
   LPCSTR lpszDllName = hb_parc( 7 );
#else
   LPWSTR lpszDllName = AnsiToWide( ( char * ) hb_parc( 7 ) );
#endif

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

   avi = LoadLibrary( lpszDllName );

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

   Animate_OpenEx( ( HWND ) AnimationCtrl, avi, MAKEINTRESOURCE( hb_parni( 8 ) ) );

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
