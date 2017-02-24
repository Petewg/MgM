/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

DIALOG form source code
(C)2005-2008 Janusz Pora <januszpora@onet.eu>

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

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_winuser.ch"

#define DS_SETFONT          64   /* User specified font for Dlg controls */

*-----------------------------------------------------------------------------*
FUNCTION _DefineDialog ( FormName, ParentForm, Id_resource , x , y , w , h , caption , fontname , fontsize , DialogProcedure , InitProcedure , ReleaseProcedure, modal , bold, italic )
*-----------------------------------------------------------------------------*
   LOCAL i , htooltip , mVar , k
   LOCAL FormHandle, ParentHandle, style

   DEFAULT x TO 0, y TO 0, w TO 0, h TO 0

   _HMG_aDialogTemplate := {}
   _HMG_DialogInMemory  := .F.

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
   ENDIF

   FormName := AllTrim( FormName )

   i := AScan ( _HMG_aFormType , 'A' )
   IF i <= 0
      MsgMiniGuiError( "Main Window Not Defined." )
   ENDIF

   IF _IsWindowDefined ( FormName )
      MsgMiniGuiError( "Dialog: " + FormName + " already defined." )
   ENDIF

   mVar := '_' + FormName

   ParentHandle := GetFormHandle ( ParentForm )

   _HMG_ModalDialogProcedure := {|| Nil }

   IF Empty( Id_resource )
      style := DS_SETFONT + WS_POPUP + WS_CAPTION + WS_VISIBLE + WS_SYSMENU + WS_THICKFRAME + WS_MAXIMIZEBOX + WS_MINIMIZEBOX
      //     style:= WS_POPUP +WS_CAPTION +WS_VISIBLE +WS_SYSMENU +WS_THICKFRAME +WS_MAXIMIZEBOX +WS_MINIMIZEBOX
      _HMG_DialogInMemory          := .T.
      _HMG_aDialogTemplate := { 0, ParentHandle, modal, style, 0, x, y, w, h, caption, fontname, fontsize, bold, Italic }
      _HMG_aDialogItems    := {}

      IF modal
         _HMG_ActiveDialogHandle     := 0
         _HMG_ActiveDialogName       := FormName
         _HMG_BeginDialogActive      := .T.
         IF ValType( InitProcedure ) == "B"
            _HMG_InitDialogProcedure := InitProcedure
         ENDIF
         IF ValType( DialogProcedure ) == "B"
            _HMG_ModalDialogProcedure := DialogProcedure
         ENDIF
         RETURN Nil
      ELSE
         IF ValType( InitProcedure ) == "B"
            _HMG_InitDialogProcedure := InitProcedure
         ENDIF
         IF ValType( DialogProcedure ) == "B"
            _HMG_DialogProcedure := DialogProcedure
         ENDIF
      ENDIF
   ELSE
      IF modal
         IF ValType( InitProcedure ) == "B"
            _HMG_InitDialogProcedure := InitProcedure
         ENDIF
         IF ValType( DialogProcedure ) == "B"
            _HMG_ModalDialogProcedure := DialogProcedure
         ENDIF
         _HMG_ModalDialogReturn := InitModalDialog ( ParentHandle,  Id_resource )
         _HMG_InitDialogProcedure := ""
         _HMG_ModalDialogProcedure := ""
         RETURN Nil
      ELSE
         IF ValType( InitProcedure ) == "B"
            _HMG_InitDialogProcedure := InitProcedure
         ENDIF
         IF ValType( DialogProcedure ) == "B"
            _HMG_DialogProcedure := DialogProcedure
         ENDIF
         Formhandle := InitDialog ( ParentHandle,  Id_resource )
         IF FormHandle <= 0
            MsgMiniGuiError( "Error by create Dialog from resource." )
         ENDIF

      ENDIF
   ENDIF

   IF ValType( FontName ) == "U"
      _HMG_ActiveFontName := ""
   ELSE
      _HMG_ActiveFontName := FontName
   ENDIF

   IF ValType( FontSize ) == "U"
      _HMG_ActiveFontSize := 0
   ELSE
      _HMG_ActiveFontSize := FontSize
   ENDIF

   _HMG_ActiveDialogHandle  := Formhandle
   _HMG_ActiveDialogName    := FormName
   _HMG_BeginDialogActive   := .T.

   IF ValType( caption ) != "U"
      SetWindowText( FormHandle, caption )
   ENDIF

   htooltip := InitToolTip( FormHandle, SetToolTipBalloon() )

   k := AScan ( _HMG_aFormDeleted , .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames [k] := FormName
      _HMG_aFormHandles  [k] :=  FormHandle
      _HMG_aFormActive  [k] :=  .T.
      _HMG_aFormType  [k] := iif( _HMG_DialogInMemory , 'L', 'D' )     // Windows type Dialog
      _HMG_aFormParentHandle  [k] :=  ParentHandle
      _HMG_aFormReleaseProcedure  [k] :=  ReleaseProcedure
      _HMG_aFormInitProcedure  [k] :=  InitProcedure
      _HMG_aFormToolTipHandle  [k] :=  htooltip
      _HMG_aFormContextMenuHandle  [k] :=  0
      _HMG_aFormMouseDragProcedure  [k] :=  ""
      _HMG_aFormSizeProcedure  [k] :=  ""
      _HMG_aFormClickProcedure  [k] :=  DialogProcedure
      _HMG_aFormMouseMoveProcedure  [k] :=  ""
      _HMG_aFormMoveProcedure  [k] :=  ""
      _HMG_aFormDropProcedure  [k] :=  ""
      _HMG_aFormDeleted  [k] := .F.
      _HMG_aFormBkColor  [k] := { -1 , -1 , -1 }
      _HMG_aFormPaintProcedure [k] :=   ""
      _HMG_aFormNoShow  [k] :=  .F.
      _HMG_aFormNotifyIconName  [k] :=  ""
      _HMG_aFormNotifyIconToolTip [k] := ""
      _HMG_aFormNotifyIconLeftClick   [k] := ""
      _HMG_aFormNotifyIconDblClick    [k] := ""
      _HMG_aFormGotFocusProcedure  [k] := ""
      _HMG_aFormLostFocusProcedure [k] := ""
      _HMG_aFormReBarHandle    [k] :=  0
      _HMG_aFormNotifyMenuHandle  [k] := 0
      _HMG_aFormBrowseList    [k] :=  {}
      _HMG_aFormSplitChildList  [k] := {}
      _HMG_aFormVirtualHeight    [k] :=  0
      _HMG_aFormVirtualWidth    [k] :=  0
      _HMG_aFormFocused    [k] :=  .F.
      _HMG_aFormScrollUp    [k] :=  ""
      _HMG_aFormScrollDown    [k] :=  ""
      _HMG_aFormScrollLeft    [k] :=  ""
      _HMG_aFormScrollRight    [k] :=  ""
      _HMG_aFormHScrollBox     [k] := ""
      _HMG_aFormVScrollBox     [k] := ""
      _HMG_aFormBrushHandle     [k] := 0
      _HMG_aFormFocusedControl  [k] := 0
      _HMG_aFormGraphTasks     [k] := {}
      _HMG_aFormMaximizeProcedure [k] :=  Nil
      _HMG_aFormMinimizeProcedure [k] :=  Nil
      _HMG_aFormRestoreProcedure [k] :=  Nil
      _HMG_aFormAutoRelease [k] :=  .F.
      _HMG_aFormInteractiveCloseProcedure [k] :=  ""
      _HMG_aFormMinMaxInfo [k] := {}
      _HMG_aFormActivateId [k] := 0
#ifdef _HMG_COMPAT_
      _HMG_StopWindowEventProcedure [k] := .F.
#endif

   ELSE

      Public &mVar. := Len( _HMG_aFormNames ) + 1

      AAdd ( _HMG_aFormNames , FormName )
      AAdd ( _HMG_aFormHandles , FormHandle )
      AAdd ( _HMG_aFormActive , .T. )
      AAdd ( _HMG_aFormType , iif( _HMG_DialogInMemory ,'L', 'D' )  )    // Windows type Dialog
      AAdd ( _HMG_aFormParentHandle , ParentHandle )
      AAdd ( _HMG_aFormReleaseProcedure , ReleaseProcedure )
      AAdd ( _HMG_aFormInitProcedure , InitProcedure )
      AAdd ( _HMG_aFormToolTipHandle , htooltip )
      AAdd ( _HMG_aFormContextMenuHandle , 0 )
      AAdd ( _HMG_aFormMouseDragProcedure , "" )
      AAdd ( _HMG_aFormSizeProcedure , "" )
      AAdd ( _HMG_aFormClickProcedure , DialogProcedure )
      AAdd ( _HMG_aFormMouseMoveProcedure , "" )
      AAdd ( _HMG_aFormMoveProcedure , "" )
      AAdd ( _HMG_aFormDropProcedure , "" )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, { -1 , -1 , -1 } )
      AAdd ( _HMG_aFormPaintProcedure , "" )
      AAdd ( _HMG_aFormNoShow , .F. )
      AAdd ( _HMG_aFormNotifyIconName       , ""    )
      AAdd ( _HMG_aFormNotifyIconToolTip      , ""    )
      AAdd ( _HMG_aFormNotifyIconLeftClick   , ""    )
      AAdd ( _HMG_aFormNotifyIconDblClick   , ""    )
      AAdd ( _HMG_aFormGotFocusProcedure      , "" )
      AAdd ( _HMG_aFormLostFocusProcedure      , "" )
      AAdd ( _HMG_aFormReBarHandle      , 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle      , 0 )
      AAdd ( _HMG_aFormBrowseList         , {} )
      AAdd ( _HMG_aFormSplitChildList      , {} )
      AAdd ( _HMG_aFormVirtualHeight      , 0 )
      AAdd ( _HMG_aFormVirtualWidth      , 0 )
      AAdd ( _HMG_aFormFocused         , .F. )
      AAdd ( _HMG_aFormScrollUp         , "" )
      AAdd ( _HMG_aFormScrollDown         , "" )
      AAdd ( _HMG_aFormScrollLeft         , "" )
      AAdd ( _HMG_aFormScrollRight      , "" )
      AAdd ( _HMG_aFormHScrollBox         , "" )
      AAdd ( _HMG_aFormVScrollBox         , "" )
      AAdd ( _HMG_aFormBrushHandle      , 0 )
      AAdd ( _HMG_aFormFocusedControl      , 0 )
      AAdd ( _HMG_aFormGraphTasks         , {} )
      AAdd ( _HMG_aFormMaximizeProcedure      , "" )
      AAdd ( _HMG_aFormMinimizeProcedure      , "" )
      AAdd ( _HMG_aFormRestoreProcedure      , Nil )
      AAdd ( _HMG_aFormAutoRelease      , .F. )
      AAdd ( _HMG_aFormInteractiveCloseProcedure , "" )
      AAdd ( _HMG_aFormMinMaxInfo , {} )
      AAdd ( _HMG_aFormActivateId          , 0 )
#ifdef _HMG_COMPAT_
      aAdd ( _HMG_StopWindowEventProcedure, .F. )
#endif

   ENDIF
   IF Len( _HMG_aDialogTemplate ) > 0
      _HMG_aDialogTemplate[1] := &mVar.
   ENDIF

RETURN ( FormHandle )

*-----------------------------------------------------------------------------*
FUNCTION _BeginDialog( name, parent, Id_resource, x, y, w, h, caption, fontname, fontsize, dialogproc, initproc, releaseproc, modal, bold, italic, underline, strikeout )
*-----------------------------------------------------------------------------*
   LOCAL FontHandle

   IF _HMG_BeginDialogActive
      MsgMiniGuiError( "DEFINE DIALOG Structures can't be nested." )
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive
      IF .NOT. Empty ( _HMG_ActiveFontName ) .AND. ValType( fontname ) == "U"
         fontname := _HMG_ActiveFontName
      ENDIF
      IF .NOT. Empty ( _HMG_ActiveFontSize ) .AND. ValType( fontsize ) == "U"
         fontsize := _HMG_ActiveFontSize
      ENDIF
   ENDIF

   IF ValType ( parent ) == 'U'
      parent := _HMG_ActiveFormName
   ENDIF
   IF ValType ( Id_resource ) == 'U'
      Id_resource := 0
   ENDIF

   _DefineDialog ( name, parent, Id_resource, x, y, w, h, caption, fontname, fontsize, dialogproc, initproc, releaseproc, modal, bold, italic, underline, strikeout )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EndDialog()
*-----------------------------------------------------------------------------*
   LOCAL FormHandle, ParentForm, nId, n, k, k_old, ControlHandle, blInit, FontHandle

   IF  _HMG_DialogInMemory .AND. Len( _HMG_aDialogTemplate ) > 0
      IF _HMG_aDialogTemplate[3]  // Modal
         _HMG_ModalDialogReturn := CreateDlgTemplate ( _HMG_aDialogTemplate[2], _HMG_aDialogTemplate, _HMG_aDialogItems )
         _HMG_InitDialogProcedure := ""
         _HMG_ModalDialogProcedure := ""
         _HMG_aDialogTemplate := {}
         _HMG_aDialogItems    := {}
      ELSE
         //                                              10             12
         //   {'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size,bold,italic,underline,strikeout}  --->_HMG_aDialogItems

         Formhandle := CreateDlgTemplate ( _HMG_aDialogTemplate[2], _HMG_aDialogTemplate,  _HMG_aDialogItems )
         IF _HMG_aDialogTemplate[1] > 0
            _HMG_aFormHandles  [_HMG_aDialogTemplate[1]] :=  FormHandle
         ENDIF
         ParentForm := FormHandle
         k_old := 0
         FOR n := 1 TO Len( _HMG_aDialogItems )
            nId     := _HMG_aDialogItems[n,1]
            k       := _HMG_aDialogItems[n,2]
            blInit  := _HMG_aDialogItems[n,19]

            ControlHandle := GetDialogItemHandle( ParentForm, nId )
            FontHandle    := GetFontHandle( _HMG_aDialogItems[n,13] )

            IF FontHandle != 0
               _SetFontHandle ( ControlHandle, FontHandle )
            ELSE
               IF ValType( _HMG_aDialogItems[n,13] ) != "U" .AND. ValType( _HMG_aDialogItems[n,14] ) != "U"
                  FontHandle := _SetFont ( ControlHandle, _HMG_aDialogItems[n,13], _HMG_aDialogItems[n,14], _HMG_aDialogItems[n,15], _HMG_aDialogItems[n,16], _HMG_aDialogItems[n,17], _HMG_aDialogItems[n,18] )
               ELSE
                  FontHandle := _SetFont ( ControlHandle, _HMG_DefaultFontName, _HMG_DefaultFontSize, _HMG_aDialogItems[n,15], _HMG_aDialogItems[n,16], _HMG_aDialogItems[n,17], _HMG_aDialogItems[n,18] )
               ENDIF
            ENDIF
            IF ValType( _HMG_aDialogItems[n,20] ) == "L" .AND. _HMG_aDialogItems[n,20] == TRUE  //_HMG_BeginTabActive
               AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
               IF _HMG_aDialogItems[n,21]
                  WHILE Len( _HMG_ActiveTabFullPageMap ) + 1 < _HMG_aDialogItems[n,22]
                     AAdd ( _HMG_ActiveTabFullPageMap , {} )
                  ENDDO
                  AAdd ( _HMG_ActiveTabFullPageMap , _HMG_ActiveTabCurrentPageMap )
                  _HMG_ActiveTabCurrentPageMap := {}
               ENDIF
            ENDIF

            IF ValType( _HMG_aDialogItems[n,12] ) != "U"
               SetToolTip ( ControlHandle , _HMG_aDialogItems[n,12] , GetFormToolTipHandle ( _HMG_ActiveDialogName ) )
            ENDIF
            IF k > 0
               IF k_old != k
                  IF ValType( _HMG_aControlHandles  [ k ] ) != "A"
                     _HMG_aControlHandles  [ k ] :=  ControlHandle
                  ELSE
                     _HMG_aControlHandles  [ k ] :=  {}
                  ENDIF
               ELSE
                  AAdd ( _HMG_aControlHandles  [ k ] , ControlHandle )
               ENDIF
               _HMG_aControlParentHandles  [ k ] :=  FormHandle
               _HMG_aControlFontHandle  [k] :=  FontHandle
               k_old := k
            ENDIF
            IF ValType( blInit ) == "B"
               Eval( blInit, _HMG_ActiveDialogName, ControlHandle, k )
            ENDIF
         NEXT
      ENDIF
      _HMG_DialogInMemory   := .F.
   ENDIF
   _HMG_ActiveDialogName    := ""
   _HMG_BeginDialogActive   := .F.
   _HMG_InitDialogProcedure := ""
   _HMG_aDialogTemplate     := {}

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION DialogProc( hwndDlg, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL ret := FALSE, i, ControlHandle
   _HMG_ActiveDlgProcHandle    := hwndDlg
   _HMG_ActiveDlgProcMsg       := nMsg
   _HMG_ActiveDlgProcId        := wParam
   _HMG_ActiveDlgProcNotify    := lParam
   _HMG_ActiveDlgProcModal     := .F.

   DO CASE
   CASE nMsg == WM_INITDIALOG
      IF ValType( _HMG_InitDialogProcedure ) == 'B'
         Eval( _HMG_InitDialogProcedure, hwndDlg )
         ret := TRUE
      ENDIF
   CASE nMsg == WM_DESTROY
      EraseDialog( hwndDlg )
      ret := TRUE
   CASE nMsg == WM_CLOSE
      i := AScan ( _HMG_aFormhandles, hwndDlg )
      IF i > 0
         IF ValType( _HMG_aFormReleaseProcedure [i] ) == 'B'
            Eval( _HMG_aFormReleaseProcedure [i] )
         ENDIF
      ENDIF
      EraseDialog( hwndDlg )
      ret := TRUE
   CASE nMsg == WM_COMMAND
      i := AScan ( _HMG_aFormhandles, hwndDlg )  // find DialogProcedure
      IF i > 0
         IF ValType( _HMG_aFormClickProcedure [i] ) == 'B' .AND. _HMG_aFormType [i] == 'D'
            ret := Eval( _HMG_aFormClickProcedure [i], nMsg, LOWORD( wParam ), HIWORD( wParam ) )
            IF ValType( ret ) == "N"
               ret := iif( ret = 0, FALSE, TRUE )
            ELSE
               ret := FALSE
            ENDIF
         ELSE
            IF  ( ControlHandle := GetDialogITemHandle( hwndDlg,LOWORD(wParam ) ) ) == 0    //JP 66
               ControlHandle := lParam
            ENDIF
            Events( hwndDlg, nMsg, wParam, ControlHandle )
            ret := TRUE
         ENDIF
      ENDIF
      IF ret == FALSE
         IF  ( ControlHandle := GetDialogITemHandle( hwndDlg,LOWORD(wParam ) ) ) == 0    //JP 66
            ControlHandle := lParam
         ENDIF
         Events( hwndDlg, nMsg, wParam, ControlHandle )
         ret := TRUE
      ENDIF
   OTHERWISE
      Events( hwndDlg, nMsg, wParam, lParam )
      ret := FALSE
   ENDCASE
   _HMG_ActiveDlgProcHandle    := 0
   _HMG_ActiveDlgProcMsg       := 0
   _HMG_ActiveDlgProcId        := 0
   _HMG_ActiveDlgProcNotify    := 0

RETURN ret

*-----------------------------------------------------------------------------*
FUNCTION ModalDialogProc( hwndDlg, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL ret

   HB_SYMBOL_UNUSED( lParam )

   _HMG_ActiveDlgProcHandle    := hwndDlg
   _HMG_ActiveDlgProcMsg       := nMsg
   _HMG_ActiveDlgProcId        := LOWORD( wParam )
   _HMG_ActiveDlgProcNotify    := HIWORD( wParam )
   _HMG_ActiveDlgProcModal     := .T.
   DO CASE
   CASE nMsg == WM_INITDIALOG
      IF ValType( _HMG_InitDialogProcedure ) == 'B'
         Eval( _HMG_InitDialogProcedure )
      ENDIF
      ret := TRUE
   CASE nMsg == WM_CLOSE
      EndDialog( hwndDlg, 0 )
      ret := TRUE
   CASE nMsg == WM_COMMAND
      DO CASE
      CASE LOWORD( wParam ) == IDOK .AND. HIWORD( wParam ) == BN_CLICKED
         EndDialog( hwndDlg, IDOK )
         ret := TRUE
      CASE LOWORD( wParam ) == IDCANCEL .AND. HIWORD( wParam ) == BN_CLICKED
         EndDialog( hwndDlg, IDCANCEL )
         ret := TRUE
      CASE LOWORD( wParam ) == IDIGNORE .AND. HIWORD( wParam ) == BN_CLICKED
         ret := TRUE
      OTHERWISE
         IF ValType( _HMG_ModalDialogProcedure ) == 'B'
            Eval( _HMG_ModalDialogProcedure, hwndDlg, nMsg, LOWORD( wParam ), HIWORD( wParam ) )
         ENDIF
         ret := TRUE
      ENDCASE
   OTHERWISE
      ret := FALSE
   ENDCASE
   _HMG_ActiveDlgProcHandle    := 0
   _HMG_ActiveDlgProcMsg       := 0
   _HMG_ActiveDlgProcId        := 0
   _HMG_ActiveDlgProcNotify    := 0

RETURN ret

*-----------------------------------------------------------------------------*
FUNCTION DisableDialogItem ( hDlg, Id )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle := GetDialogITemHandle( hDlg, Id )
   IF ControlHandle > 0
      DisableWindow( ControlHandle )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION EnableDialogItem ( hDlg, Id )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle := GetDialogITemHandle( hDlg, Id )
   IF ControlHandle > 0
      EnableWindow( ControlHandle )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION EraseDialog( hwndDlg )
*-----------------------------------------------------------------------------*
   LOCAL i, x, ControlCount, mVar

   i := AScan ( _HMG_aFormhandles, hwndDlg )
   IF i > 0
      ControlCount := Len ( _HMG_aControlHandles )
      FOR x := 1 TO ControlCount
         IF _HMG_aControlParentHandles [x] == hwndDlg
            mVar := '_' + _HMG_aFormNames [i] + '_' + _HMG_aControlNames [x]
            IF __mvExist ( mVar )
               __mvPut ( mVar , 0 )
            ENDIF
            _EraseControl( x, i )
         ENDIF
      NEXT x
      mVar := '_' + _HMG_aFormNames [i]
      IF __mvExist ( mVar )
         __mvPut ( mVar , 0 )
      ENDIF
      _HMG_aFormDeleted      [i]   := .T.
      _HMG_aFormhandles      [i]   := 0
      _HMG_aFormNames         [i]   := ""
      _HMG_aFormActive      [i]   := .F.
      _HMG_aFormType         [i]   := ""
      _HMG_aFormParenthandle      [i]   := 0
      _HMG_aFormInitProcedure      [i]   := ""
      _HMG_aFormReleaseProcedure   [i]   := ""
      _HMG_aFormToolTipHandle      [i]   := 0
      _HMG_aFormContextMenuHandle   [i]   := 0
      _HMG_aFormMouseDragProcedure   [i]   := ""
      _HMG_aFormSizeProcedure    [i]   := ""
      _HMG_aFormClickProcedure     [i]   := ""
      _HMG_aFormMouseMoveProcedure   [i]   := ""
      _HMG_aFormMoveProcedure      [i]   := ""
      _HMG_aFormDropProcedure      [i]   := ""
      _HMG_aFormBkColor      [i]   := Nil
      _HMG_aFormPaintProcedure   [i]   := ""
      _HMG_aFormNoShow      [i]   := .F.
      _HMG_aFormNotifyIconName   [i]   := ''
      _HMG_aFormNotifyIconToolTip   [i]   := ''
      _HMG_aFormNotifyIconLeftClick   [i]   := ''
      _HMG_aFormNotifyIconDblClick   [i]   := ''
      _HMG_aFormReBarHandle      [i]   := 0
      _HMG_aFormNotifyMenuHandle   [i]   := 0
      _HMG_aFormBrowseList      [i]   := {}
      _HMG_aFormSplitChildList   [i]   := {}
      _HMG_aFormVirtualHeight      [i]   := 0
      _HMG_aFormGotFocusProcedure   [i]   := ""
      _HMG_aFormLostFocusProcedure   [i]   := ""
      _HMG_aFormVirtualWidth      [i]   := 0
      _HMG_aFormFocused      [i]   := .F.
      _HMG_aFormScrollUp      [i]   := ""
      _HMG_aFormScrollDown      [i]   := ""
      _HMG_aFormScrollLeft      [i]   := ""
      _HMG_aFormScrollRight      [i]   := ""
      _HMG_aFormHScrollBox      [i]   := ""
      _HMG_aFormVScrollBox      [i]   := ""
      _HMG_aFormBrushHandle      [i]   := 0
      _HMG_aFormFocusedControl   [i]   := 0
      _HMG_aFormGraphTasks      [i]   := {}
      _HMG_aFormMaximizeProcedure   [i]   := Nil
      _HMG_aFormMinimizeProcedure   [i]   := Nil
      _HMG_aFormRestoreProcedure   [i]   := Nil
      _HMG_aFormAutoRelease      [i]   := .F.
      _HMG_aFormInteractiveCloseProcedure [i] := ""
      _HMG_aFormMinMaxInfo      [i]   := {}
      _HMG_aFormActivateId      [i]   := 0

      DestroyWindow( hwndDlg )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ReleaseDialog( hwndDlg )
*-----------------------------------------------------------------------------*
   DEFAULT  hwndDlg TO _HMG_ActiveDlgProcHandle
   IF hwndDlg != 0
      IF _HMG_ActiveDlgProcModal
         EndDialog( hwndDlg, 0 )
      ELSE
         EraseDialog( hwndDlg )
      ENDIF
   ENDIF

RETURN Nil
