/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

MDI window source code
(C)2005 Janusz Pora <januszpora@onet.eu>

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

#define WM_MDICREATE           0x0220
#define WM_MDIDESTROY          0x0221
#define WM_MDIACTIVATE         0x0222
#define WM_MDIRESTORE          0x0223
#define WM_MDINEXT             0x0224
#define WM_MDIMAXIMIZE         0x0225
#define WM_MDITILE             0x0226
#define WM_MDICASCADE          0x0227
#define WM_MDIICONARRANGE      0x0228
#define WM_MDIGETACTIVE        0x0229

#define MDITILE_VERTICAL       0x0000
#define MDITILE_HORIZONTAL     0x0001
#define MDITILE_SKIPDISABLED   0x0002

#define CW_USEDEFAULT          0x80000000
#define DLGC_WANTALLKEYS       4

#include "minigui.ch"
#include "i_winuser.ch"
#include "error.ch"

MEMVAR mVar
#ifdef _TSBROWSE_
MEMVAR _TSB_aControlhWnd, _TSB_aControlObjects, _TSB_aClientMDIhWnd
#endif

*-----------------------------------------------------------------------------*
FUNCTION MdiEvents ( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL i, x, ControlCount
#ifdef _TSBROWSE_
   LOCAL oGet
#endif

   DO CASE

#ifdef _TSBROWSE_
   //**********************************************************************
   CASE nMsg == WM_KEYDOWN .OR. nMsg == WM_KEYUP
   //**********************************************************************

      IF Type( '_TSB_aControlhWnd' ) == 'A' .AND. Len( _TSB_aControlhWnd ) > 0
         oGet := GetObjectByClientMDI( hWnd )
         IF ValType( oGet ) == 'O'
            oGet:HandleEvent ( nMsg, wParam, lParam )
         ENDIF
      ENDIF
  
   //**********************************************************************
   CASE nMsg == WM_MOUSEWHEEL 
   //**********************************************************************
      IF Type( '_TSB_aControlhWnd' ) == 'A' .AND. Len( _TSB_aControlhWnd ) > 0
         oGet := GetObjectByClientMDI( hWnd )
         IF ValType( oGet ) == 'O'
            x := oGet:HandleEvent ( nMsg, wParam, lParam )
            IF ValType( x ) == 'N'
               IF x != 0
                  RETURN x
               ENDIF
            ENDIF
         ENDIF
      ENDIF
#endif
   //**********************************************************************
   CASE nMsg == WM_MDIACTIVATE
   //**********************************************************************

      IF _HMG_MdiChildActive == .F.

         i := AScan ( _HMG_aFormHandles , hWnd )
         IF i > 0
            _DoWindowEventProcedure ( _HMG_aFormClickProcedure [i] , i )
         ENDIF

      ENDIF

   //**********************************************************************
   CASE nMsg == WM_GETDLGCODE
   //**********************************************************************

      RETURN DLGC_WANTALLKEYS

   //**********************************************************************
   CASE nMsg == WM_WINDOWPOSCHANGED .OR. nMsg ==  WM_WINDOWPOSCHANGING
   //**********************************************************************

      RETURN 0

   //**********************************************************************
   CASE nMsg == WM_MOVE
   //**********************************************************************

      IF _HMG_MdiChildActive == .F.

         i := AScan ( _HMG_aFormhandles , hWnd )

         IF i > 0
            _DoWindowEventProcedure ( _HMG_aFormMoveProcedure  [i] , i )
         ENDIF

      ENDIF

   //**********************************************************************
   CASE nMsg == WM_SIZE
   //**********************************************************************

      IF _HMG_MdiChildActive == .F.

         i := AScan ( _HMG_aFormHandles , hWnd )
         IF i > 0

            IF wParam == SIZE_MAXIMIZED

               _DoWindowEventProcedure ( _HMG_aFormMaximizeProcedure [i] , i )

            ELSEIF wParam == SIZE_MINIMIZED

               _DoWindowEventProcedure ( _HMG_aFormMinimizeProcedure [i] , i )

            ELSEIF wParam == SIZE_RESTORED .AND. !IsWindowSized( hWnd )

               _DoWindowEventProcedure ( _HMG_aFormRestoreProcedure [i] , i )

            ELSE

               _DoWindowEventProcedure ( _HMG_aFormSizeProcedure [i] , i )

            ENDIF

         ENDIF

      ENDIF

   //**********************************************************************
   CASE nMsg == WM_CLOSE
   //**********************************************************************

      IF GetEscapeState() < 0
         RETURN ( 1 )
      ENDIF

      RETURN _MdiChildClose( hWnd )

   //**********************************************************************
   CASE nMsg == WM_DESTROY
   //**********************************************************************

      ControlCount := Len ( _HMG_aControlHandles )

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         // Remove Child Window Properties

         EnumPropsEx( hWnd, {|hWnd, cPropName, hHandle| HB_SYMBOL_UNUSED( hHandle ), ;
            iif( hb_LeftEqI( cPropName, "HMG_" ), RemoveProp( hWnd, cPropName ), Nil ), .T. } )

         _RemoveProperty( hWnd, "PROP_CFILE" )
         _RemoveProperty( hWnd, "PROP_FORMNAME" )
         _RemoveProperty( hWnd, "PROP_MODIFIED" )

         // Remove Child Controls

         FOR x := 1 TO ControlCount
            IF _HMG_aControlParentHandles [x] == hWnd
               _EraseControl( x, i )
            ENDIF
         NEXT x

         // Delete ToolTip

         ReleaseControl ( _HMG_aFormToolTipHandle [i] )

         // Update Form Index Variable

         mVar := '_' + _HMG_aFormNames [i]
         IF __mvExist ( mVar )
            __mvPut ( mVar , 0 )
         ENDIF

         _HMG_aFormDeleted       [i]   := .T.
         _HMG_aFormhandles       [i]   := 0
         _HMG_aFormNames         [i]   := ""
         _HMG_aFormActive        [i]   := .F.
         _HMG_aFormType          [i]   := ""
         _HMG_aFormParenthandle      [i]   := 0
         _HMG_aFormInitProcedure      [i]   := ""
         _HMG_aFormReleaseProcedure   [i]   := ""
         _HMG_aFormToolTipHandle      [i]   := 0
         _HMG_aFormContextMenuHandle    [i]   := 0
         _HMG_aFormMouseDragProcedure   [i]   := ""
         _HMG_aFormSizeProcedure    [i]   := ""
         _HMG_aFormClickProcedure     [i]   := ""
         _HMG_aFormMouseMoveProcedure   [i]   := ""
         _HMG_aFormMoveProcedure   [i]   := ""
         _HMG_aFormDropProcedure   [i]   := ""
         _HMG_aFormBkColor      [i]   := Nil
         _HMG_aFormPaintProcedure   [i]   := ""
         _HMG_aFormNoShow      [i]   := .F.
         _HMG_aFormNotifyIconName   [i] := ''
         _HMG_aFormNotifyIconToolTip   [i] := ''
         _HMG_aFormNotifyIconLeftClick   [i] := ''
         _HMG_aFormNotifyIconDblClick   [i] := ''
         _HMG_aFormReBarHandle      [i] := 0
         _HMG_aFormNotifyMenuHandle   [i] := 0
         _HMG_aFormBrowseList      [i] := {}
         _HMG_aFormSplitChildList   [i] := {}
         _HMG_aFormVirtualHeight      [i] := 0
         _HMG_aFormGotFocusProcedure   [i] := ""
         _HMG_aFormLostFocusProcedure   [i] := ""
         _HMG_aFormVirtualWidth      [i] := 0
         _HMG_aFormFocused      [i] := .F.
         _HMG_aFormScrollUp      [i] := ""
         _HMG_aFormScrollDown      [i] := ""
         _HMG_aFormScrollLeft      [i] := ""
         _HMG_aFormScrollRight     [i] := ""
         _HMG_aFormHScrollBox      [i] := ""
         _HMG_aFormVScrollBox      [i] := ""
         _HMG_aFormBrushHandle      [i] := 0
         _HMG_aFormFocusedControl   [i] := 0
         _HMG_aFormGraphTasks      [i] := {}
         _HMG_aFormMaximizeProcedure   [i] := Nil
         _HMG_aFormMinimizeProcedure   [i] := Nil
         _HMG_aFormRestoreProcedure   [i] := Nil
         _HMG_aFormAutoRelease      [i] := .F.
         _HMG_aFormInteractiveCloseProcedure [i] := ""
         _HMG_aFormMinMaxInfo [i] := {}
         _HMG_aFormActivateId [i] := 0
         _HMG_aFormMiscData1  [i] := {}
         _HMG_aFormMiscData2  [i] := ''

         _HMG_InteractiveCloseStarted := .F.

      ENDIF

   OTHERWISE

      IF nMsg != WM_CREATE .AND. nMsg != WM_CLOSE .AND. nMsg != WM_DESTROY
         Events ( hWnd, nMsg, wParam, lParam )
      ENDIF

   ENDCASE

RETURN ( 0 )

*-----------------------------------------------------------------------------*
FUNCTION _DefineChildMDIWindow ( FormName, x, y, w, h, nominimize, nomaximize, ;
      nocaption, novscroll, nohscroll, title, FontName, FontSize, ;
      initprocedure, ReleaseProcedure, ClickProcedure, GotFocus, LostFocus, SizeProcedure, ;
      maximizeprocedure, minimizeprocedure, focused, cursor, InteractiveCloseProcedure, MouseMoveProcedure )
*-----------------------------------------------------------------------------*
   LOCAL i , htooltip , mVar , ParentForm , k , aRGB := { -1 , -1 , -1 }
   LOCAL FormHandle , ChildIndex

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
   ENDIF

   ChildIndex := _HMG_ActiveMDIChildIndex + 1

   IF _HMG_ProgrammaticChange
      FormName += '_' + hb_ntos( ChildIndex )
   ELSE
      IF AScan( _HMG_aFormNames, FormName ) > 0 // child window FormName already exist
         FormName += '_' + hb_ntos( ChildIndex )
      ENDIF
   ENDIF

   i := AScan ( _HMG_aFormType , 'A' )

   IF i <= 0
      MsgMiniGuiError( "Main Window Is Not Defined." )
   ENDIF

   IF _IsWindowDefined ( FormName )
      MsgMiniGuiError( "Window: " + FormName + " already defined." )
   ENDIF

   IF _HMG_BeginWindowMDIActive == .F.
      MsgMiniGuiError( "MdiChild Windows can be defined only inside MDI Window." )
   ENDIF

   __defaultNIL( @x, CW_USEDEFAULT )
   __defaultNIL( @y, CW_USEDEFAULT )
   __defaultNIL( @w, CW_USEDEFAULT )
   __defaultNIL( @h, CW_USEDEFAULT )

   _HMG_ActiveFontName := hb_defaultValue( FontName, _HMG_DefaultFontName )

   _HMG_ActiveFontSize := hb_defaultValue( FontSize, _HMG_DefaultFontSize )

   _HMG_MdiChildActive := .T.

   ParentForm := _HMG_MainClientMDIName

   mVar := '_' + FormName

   _HMG_ActiveFormName := FormName
   _HMG_BeginWindowActive := .T.

   i := GetFormIndex ( ParentForm )
   IF i > 0

      Formhandle := InitMdiChildWindow ( _HMG_MainClientMDIHandle, Title, x, y, w , h, nominimize, nomaximize, nocaption, novscroll, nohscroll )

      _SetWindowProperty( Formhandle, "PROP_CFILE", iif( Empty( Title ), "No Title", Title ) )
      _SetWindowProperty( Formhandle, "PROP_FORMNAME", FormName )
      _SetWindowProperty( Formhandle, "PROP_MODIFIED", .F. )

      // JP MDI Background
      aRGB := _HMG_aFormBkColor [i]
      // End
      IF ValType ( cursor ) != "U"
         SetWindowCursor( Formhandle , cursor )
      ENDIF

   ENDIF

   htooltip := InitToolTip( FormHandle , SetToolTipBalloon() )  //JP MDI ToolTip
//JP MDI Background
   IF aRGB[1] != -1
      SetWindowBackground( Formhandle, PaintBkGnd( Formhandle, aRGB ) )
   ENDIF
//JP End
   _HMG_ActiveMDIChildIndex := ChildIndex

   k := AScan ( _HMG_aFormDeleted , .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames  [k] :=  FormName
      _HMG_aFormHandles  [k] :=  FormHandle
      _HMG_aFormActive  [k] :=  .F.
      _HMG_aFormType  [k] :=  'Y'
      _HMG_aFormParentHandle  [k] :=  GetFormHandle( ParentForm )
      _HMG_aFormReleaseProcedure  [k] :=  ReleaseProcedure
      _HMG_aFormInitProcedure  [k] :=  initprocedure
      _HMG_aFormToolTipHandle  [k] :=  hToolTip
      _HMG_aFormContextMenuHandle  [k] :=  0
      _HMG_aFormMouseDragProcedure  [k] :=  ""
      _HMG_aFormSizeProcedure  [k] :=  SizeProcedure
      _HMG_aFormClickProcedure  [k] :=  ClickProcedure
      _HMG_aFormMouseMoveProcedure  [k] :=  MouseMoveProcedure
      _HMG_aFormMoveProcedure  [k] :=  ""
      _HMG_aFormDropProcedure  [k] :=  ""
      _HMG_aFormDeleted  [k] := .F.
      _HMG_aFormBkColor  [k] := aRGB  //JP MDI Background
      _HMG_aFormPaintProcedure  [k] :=  ""
      _HMG_aFormNoShow   [k] := .F.
      _HMG_aFormNotifyIconName  [k] :=  ""
      _HMG_aFormNotifyIconToolTip    [k] :=  ""
      _HMG_aFormNotifyIconLeftClick  [k] :=  ""
      _HMG_aFormNotifyIconDblClick  [k] :=  ""
      _HMG_aFormGotFocusProcedure  [k] := gotfocus
      _HMG_aFormLostFocusProcedure [k] := lostfocus
      _HMG_aFormReBarHandle    [k] :=  0
      _HMG_aFormNotifyMenuHandle [k] :=     0
      _HMG_aFormBrowseList    [k] :=     {}
      _HMG_aFormSplitChildList [k] :=     {}
      _HMG_aFormVirtualHeight    [k] := 0
      _HMG_aFormVirtualWidth    [k] := 0
      _HMG_aFormFocused    [k] :=  Focused
      _HMG_aFormScrollUp    [k] := ""
      _HMG_aFormScrollDown    [k] := ""
      _HMG_aFormScrollLeft    [k] := ""
      _HMG_aFormScrollRight   [k] := ""
      _HMG_aFormHScrollBox    [k] := ""
      _HMG_aFormVScrollBox    [k] := ""
      _HMG_aFormBrushHandle    [k] := 0
      _HMG_aFormFocusedControl [k] := 0
      _HMG_aFormGraphTasks    [k] :=  {}
      _HMG_aFormMaximizeProcedure [k] := maximizeprocedure
      _HMG_aFormMinimizeProcedure [k] := minimizeprocedure
      _HMG_aFormRestoreProcedure   [k] := ""
      _HMG_aFormAutoRelease [k] :=  .T.
      _HMG_aFormInteractiveCloseProcedure [k] :=  InteractiveCloseProcedure
      _HMG_aFormMinMaxInfo [k] := {}
      _HMG_aFormActivateId [k] := 0
      _HMG_aFormMiscData1  [k] := {}
      _HMG_aFormMiscData2  [k] := ''
#ifdef _HMG_COMPAT_
      _HMG_StopWindowEventProcedure [k] := .F.
#endif

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames , FormName )
      AAdd ( _HMG_aFormHandles , FormHandle )
      AAdd ( _HMG_aFormActive , .F. )
      AAdd ( _HMG_aFormType , 'Y' )
      AAdd ( _HMG_aFormParentHandle , GetFormHandle( ParentForm ) )
      AAdd ( _HMG_aFormReleaseProcedure , ReleaseProcedure  )
      AAdd ( _HMG_aFormInitProcedure , initprocedure  )
      AAdd ( _HMG_aFormToolTipHandle , hToolTip )
      AAdd ( _HMG_aFormContextMenuHandle , 0 )
      AAdd ( _HMG_aFormMouseDragProcedure , "" )
      AAdd ( _HMG_aFormSizeProcedure , SizeProcedure )
      AAdd ( _HMG_aFormClickProcedure , ClickProcedure )
      AAdd ( _HMG_aFormMouseMoveProcedure , MouseMoveProcedure )
      AAdd ( _HMG_aFormMoveProcedure , "" )
      AAdd ( _HMG_aFormDropProcedure , "" )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, Nil )
      AAdd ( _HMG_aFormPaintProcedure , "" )
      AAdd ( _HMG_aFormNoShow , .F. )
      AAdd ( _HMG_aFormNotifyIconName , "" )
      AAdd ( _HMG_aFormNotifyIconToolTip , "" )
      AAdd ( _HMG_aFormNotifyIconLeftClick , "" )
      AAdd ( _HMG_aFormNotifyIconDblClick  , "" )
      AAdd ( _HMG_aFormGotFocusProcedure   , gotfocus )
      AAdd ( _HMG_aFormLostFocusProcedure  , lostfocus )
      AAdd ( _HMG_aFormReBarHandle       , 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle  , 0 )
      AAdd ( _HMG_aFormBrowseList        , {} )
      AAdd ( _HMG_aFormSplitChildList    , {} )
      AAdd ( _HMG_aFormVirtualHeight     , 0 )
      AAdd ( _HMG_aFormVirtualWidth      , 0 )
      AAdd ( _HMG_aFormFocused           , Focused )
      AAdd ( _HMG_aFormScrollUp          , "" )
      AAdd ( _HMG_aFormScrollDown        , "" )
      AAdd ( _HMG_aFormScrollLeft        , "" )
      AAdd ( _HMG_aFormScrollRight       , "" )
      AAdd ( _HMG_aFormHScrollBox        , "" )
      AAdd ( _HMG_aFormVScrollBox        , "" )
      AAdd ( _HMG_aFormBrushHandle       , 0 )
      AAdd ( _HMG_aFormFocusedControl    , 0 )
      AAdd ( _HMG_aFormGraphTasks        , {} )
      AAdd ( _HMG_aFormMaximizeProcedure , maximizeprocedure )
      AAdd ( _HMG_aFormMinimizeProcedure , minimizeprocedure )
      AAdd ( _HMG_aFormRestoreProcedure  ,  "" )
      AAdd ( _HMG_aFormAutoRelease       , .T. )
      AAdd ( _HMG_aFormInteractiveCloseProcedure , InteractiveCloseProcedure )
      AAdd ( _HMG_aFormMinMaxInfo , {} )
      AAdd ( _HMG_aFormActivateId , 0 )
      AAdd ( _HMG_aFormMiscData1  , {} )
      AAdd ( _HMG_aFormMiscData2  , '' )
#ifdef _HMG_COMPAT_
      AAdd ( _HMG_StopWindowEventProcedure, .F. )
#endif

   ENDIF

   _SetThisFormInfo( k )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnFormInit, k, mVar )
   ENDIF

RETURN ( FormHandle )

*-----------------------------------------------------------------------------*
FUNCTION _EndMdiChildWindow ()
*-----------------------------------------------------------------------------*
   _ActivateMdiWindow ( _HMG_ActiveFormName )
   _HMG_ActiveFormName := _HMG_ActiveFormNameBak
   _HMG_MdiChildActive := .F.

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ActivateMdiWindow ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF .NOT. _IsWindowDefined ( Formname )
      MsgMiniGUIError( "Window " + FormName + " is not defined." )
   ENDIF

   IF _IsWindowActive ( FormName )
      MsgMiniGUIError( "Window " + FormName + " already active." )
   ENDIF

   i := GetFormIndex ( FormName )

   IF _HMG_aFormType [i] == "M"

      _ShowWindow ( _HMG_aFormNames [i] )

      _SetActivationFlag( i )
      _ProcessInitProcedure( i )
      _RefreshDataControls( i )

   ELSE

      IF _HMG_IsModalActive
         MsgMiniGUIError( Formname + ": Non Modal Windows can't be activated when a modal window is active." )
      ENDIF

      IF _HMG_aFormNoShow [i] == .F.
         ShowWindow( GetFormHandle( FormName ) )
         IF _HMG_ProgrammaticChange
            SetFocus( _HMG_MainClientMDIHandle )  // BK 26-Apr-2012
            SetFocus( GetFormHandle( FormName ) ) // BK 26-Apr-2012
         ENDIF
      ENDIF

      _SetActivationFlag( i )
      _ProcessInitProcedure( i )
      _RefreshDataControls( i )

      IF _SetFocusedSplitChild( i ) == .F.
         _SetActivationFocus( i )
      ENDIF

      _DefineHotKey ( FormName , 0 , VK_TAB , {|| _SetNextFocus() } )
      _DefineHotKey ( FormName , MOD_SHIFT , VK_TAB , {|| _SetNextFocus( .T. ) } )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiChildClose ( hWnd )
*-----------------------------------------------------------------------------*
   LOCAL i, xRetVal

   i := AScan ( _HMG_aFormHandles , hWnd )

   IF i > 0

      // Process Interactive Close Event / Setting

      IF ISBLOCK ( _HMG_aFormInteractiveCloseProcedure [i] )
         xRetVal := _DoWindowEventProcedure ( _HMG_aFormInteractiveCloseProcedure [i] , i , 'WINDOW_ONINTERACTIVECLOSE' )
         IF ValType ( xRetVal ) == 'L'
            IF !xRetVal
               RETURN 1
            ENDIF
         ENDIF
      ENDIF

      SWITCH _HMG_InteractiveClose

      CASE 0
         MsgStop ( _HMG_MESSAGE [3] )
         RETURN 1
      CASE 2
         IF ! MsgYesNo ( _HMG_MESSAGE [1] , _HMG_MESSAGE [2] )
            RETURN 1
         ENDIF
         EXIT
      CASE 3
         IF _HMG_aFormType [i] == 'A'
            IF ! MsgYesNo ( _HMG_MESSAGE [1] , _HMG_MESSAGE [2] )
               RETURN 1
            ENDIF
         ENDIF

      ENDSWITCH

      IF ISBLOCK ( _HMG_aFormReleaseProcedure [i] )
         _HMG_InteractiveCloseStarted := .T.
         _DoWindowEventProcedure ( _HMG_aFormReleaseProcedure [i] , i , 'WINDOW_RELEASE' )
      ENDIF

   ENDIF

RETURN 0

*-----------------------------------------------------------------------------*
FUNCTION ActivateMdiChildWindow ( ChildName )
*-----------------------------------------------------------------------------*
   LOCAL n

   FOR n := 1 TO Len( _HMG_aFormHandles )
      IF _HMG_aFormType [n] == 'Y'
         IF ChildName == _GetWindowProperty( _HMG_aFormHandles [n], "PROP_FORMNAME" )
            _MdiWindowsActivate( _HMG_aFormHandles [n] )
         ENDIF
      ENDIF
   NEXT

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _CloseActiveMdi()
*-----------------------------------------------------------------------------*
   LOCAL ChildHandle := GetActiveMdiHandle()

   IF _MdiChildClose( ChildHandle ) == 0
      DestroyActiveMdi( ChildHandle )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiChildCloseAll()
*-----------------------------------------------------------------------------*
   LOCAL ChildHandle, n

   FOR n := 1 TO Len( _HMG_aFormHandles )
      IF _HMG_aFormType [n] == 'Y'
         ChildHandle := _HMG_aFormHandles [n]
         IF _MdiChildClose( ChildHandle ) == 0
            DestroyActiveMdi( ChildHandle )
         ENDIF
      ENDIF
   NEXT

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiChildRestoreAll()
*-----------------------------------------------------------------------------*
   LOCAL n

   FOR n := 1 TO Len( _HMG_aFormHandles )
      IF _HMG_aFormType [n] == 'Y'
         _MdiWindowsRestore( _HMG_aFormHandles [n] )
      ENDIF
   NEXT

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION GetActiveMdiHandle()
*-----------------------------------------------------------------------------*

RETURN iif( _HMG_MainClientMDIHandle > 0, SendMessage( _HMG_MainClientMDIHandle, WM_MDIGETACTIVE, 0, 0 ), 0 )

*-----------------------------------------------------------------------------*
FUNCTION DestroyActiveMdi( hwndCln )
*-----------------------------------------------------------------------------*
   SendMessage( _HMG_MainClientMDIHandle, WM_MDIDESTROY, hwndCln, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiWindowsTile( lVert )
*-----------------------------------------------------------------------------*
   LOCAL Style := iif( lVert, MDITILE_VERTICAL, MDITILE_HORIZONTAL )
   SendMessage( _HMG_MainClientMDIHandle, WM_MDITILE, Style, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiWindowsCascade()
*-----------------------------------------------------------------------------*
   SendMessage( _HMG_MainClientMDIHandle, WM_MDICASCADE, 0, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiWindowsIcons()
*-----------------------------------------------------------------------------*
   SendMessage( _HMG_MainClientMDIHandle, WM_MDIICONARRANGE, 0, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiWindowsRestore( childhwnd )
*-----------------------------------------------------------------------------*
   SendMessage( _HMG_MainClientMDIHandle, WM_MDIRESTORE, childhwnd, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _MdiWindowsActivate( childhwnd )
*-----------------------------------------------------------------------------*
   IF _HMG_MainClientMDIHandle > 0
      SendMessage( _HMG_MainClientMDIHandle, WM_MDIACTIVATE, childhwnd, 0 )
   ENDIF

RETURN Nil

#ifdef _TSBROWSE_
*-----------------------------------------------------------------------------*
FUNCTION GetObjectByClientMDI( hWnd )
*-----------------------------------------------------------------------------*
   LOCAL oWnd := NIL, nPos

   IF ( nPos := AScan( _TSB_aClientMDIhWnd, hWnd ) ) > 0
      oWnd := _TSB_aControlObjects[ nPos ]
   ENDIF

RETURN oWnd

#endif
