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
#include "i_winuser.ch"

#ifdef _HMG_COMPAT_
   STATIC nCtEfeito := 0, cDescEfeito := ""
#endif

*-----------------------------------------------------------------------------*
FUNCTION _DefineWindow ( FormName, Caption, x, y, w, h, nominimize, nomaximize, ;
      nosize, nosysmenu, nocaption, aMin, aMax, InitProcedure, ReleaseProcedure, ;
      MouseDragProcedure, SizeProcedure, ClickProcedure, MouseMoveProcedure, aRGB, ;
      PaintProcedure, noshow, topmost, main, icon, child, fontname, fontsize, ;
      NotifyIconName, NotifyIconTooltip, NotifyIconLeftClick, GotFocus, LostFocus, ;
      VirtualHeight, VirtualWidth, scrollleft, scrollright, scrollup, scrolldown, ;
      hscrollbox, vscrollbox, helpbutton, MaximizeProcedure, MinimizeProcedure, cursor, ;
      NoAutoRelease, InteractiveCloseProcedure, RestoreProcedure, MoveProcedure, DropProcedure, ;
      mdi, palette, NotifyIconDblClick, cPanelParent, panel, NotifyBalloonClick, clientwidth, clientheight )
*-----------------------------------------------------------------------------*
   LOCAL BrushHandle, FormHandle, ParentHandle
   LOCAL hnotifyicon, htooltip
   LOCAL ClassName
   LOCAL cType
   LOCAL mVar
   LOCAL vscroll, hscroll
   LOCAL k

   hb_default( @panel, .F. )

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
#ifdef _PANEL_
      IF _HMG_LoadWindowRow <> -1

         y := _HMG_LoadWindowRow
         x := _HMG_LoadWindowCol
         w := _HMG_LoadWindowWidth
         h := _HMG_LoadWindowHeight

         _HMG_LoadWindowRow    := -1
         _HMG_LoadWindowCol    := -1
         _HMG_LoadWindowWidth  := -1
         _HMG_LoadWindowHeight := -1
      ENDIF
#endif
   ENDIF

#ifdef _PANEL_
   IF _HMG_FrameLevel > 0
      x := x + _HMG_ActiveFrameCol [ _HMG_FrameLevel ]
      y := y + _HMG_ActiveFrameRow [ _HMG_FrameLevel ]
   ENDIF
#endif
   IF ValType( mdi ) == "U"
      Mdi := .F.
   ENDIF

   FormName := AllTrim( FormName )

   IF Main

      IF AScan ( _HMG_aFormType, 'A' ) > 0
         MsgMiniGuiError( "Main Window is already defined." )
      ENDIF

      IF Child == .T.
         MsgMiniGuiError( "Child and Main clauses cannot be used simultaneously." )
      ENDIF

      IF NoAutoRelease == .T.
         MsgMiniGuiError( "NOAUTORELEASE and MAIN clauses cannot be used simultaneously." )
      ENDIF

   ELSE

#ifdef _HMG_COMPAT_
      IF _HMG_MainWindowFirst == .T.
#endif
         IF AScan ( _HMG_aFormType, 'A' ) == 0
            MsgMiniGuiError( "Main Window is not defined." )
         ENDIF
#ifdef _HMG_COMPAT_
      ENDIF
#endif
      IF _IsWindowDefined ( FormName )
         MsgMiniGuiError( "Window: " + FormName + " is already defined." )
      ENDIF

      IF ! Empty ( NotifyIconName )
         MsgMiniGuiError( "Notification icon allowed only in Main Window." )
      ENDIF

      IF _HMG_BeginWindowMDIActive == .T.
         MsgMiniGuiError( "Only MdiChild windows can be defined inside MdiWindow." )
      ENDIF

   ENDIF
#ifdef _PANEL_
   IF ValType( cPanelParent ) == 'C' .AND. panel == .F.
      MsgMiniGuiError( "Parent can be specified only for Panel windows." )
   ENDIF

   IF !Empty( _HMG_ActiveFormName ) .AND. panel == .F. .AND. _HMG_ProgrammaticChange
      MsgMiniGuiError( "Only Panel windows can be defined inside a DEFINE WINDOW...END WINDOW structure." )
   ENDIF
#else
   HB_SYMBOL_UNUSED( cPanelParent )
#endif
   IF ! ISNUMBER( w ) .AND. ! ISNUMBER( h )

      IF ! ISNUMBER( clientwidth ) .AND. ! ISNUMBER( clientheight )
         w := GetDesktopWidth()
         h := GetDesktopHeight() - GetTaskBarHeight()
         IF child
            w *= .78125
            h *= .78125
         ENDIF
      ELSE
         mVar := ( nocaption .AND. nosize )
         w := ClientWidth + iif( mVar, 0, GetBorderWidth() ) + iif( mVar .OR. _HMG_IsThemed .AND. nosize, 0, GetBorderWidth() ) - iif( mVar .OR. (!_HMG_IsThemed .AND. !nosize) .OR. (_HMG_IsThemed .AND. !nocaption .AND. !nosize), 0, 2 )
         h := ClientHeight + iif( nocaption, 0, GetTitleHeight() ) + iif( mVar .OR. _HMG_IsThemed .AND. nosize, 0, GetBorderWidth() ) + iif( mVar, 0, GetBorderWidth() ) - iif( mVar .OR. (!_HMG_IsThemed .AND. !nosize) .OR. (_HMG_IsThemed .AND. !nocaption .AND. !nosize), 0, 2 )
      ENDIF

   ENDIF

   mVar := '_' + FormName

   ParentHandle := iif( child == .T., _HMG_MainHandle, 0 )

#ifdef _PANEL_
   IF panel == .T.

      IF ValType( cPanelParent ) == 'C'
         IF GetWindowType ( cPanelParent ) == 'X'
            MsgMiniGuiError( "Panel Windows Can't Have SplitChild Parent." )
         ENDIF

         ParentHandle := GetFormHandle( cPanelParent )
         _HMG_ParentWindowActive := .F.

      ELSEIF ! Empty( _HMG_ActiveFormName )
         IF GetWindowType ( _HMG_ActiveFormName ) == 'X'
            MsgMiniGuiError( "Panel Windows Can't Have SplitChild Parent." )
         ENDIF

         ParentHandle := GetFormHandle( _HMG_ActiveFormName )
         _HMG_ParentWindowActive := .T.
         _HMG_ActiveFormNameBak  := _HMG_ActiveFormName

      ELSE
         MsgMiniGuiError( "Panel Windows Must Have a Parent." )
      ENDIF

   ENDIF
#endif
   _HMG_ActiveFontName := hb_defaultValue( FontName, _HMG_DefaultFontName )

   _HMG_ActiveFontSize := hb_defaultValue( FontSize, _HMG_DefaultFontSize )

   hb_default( @Caption, "" )
   __defaultNIL( @InitProcedure, "" )
   __defaultNIL( @ReleaseProcedure, "" )
   __defaultNIL( @MouseDragProcedure, "" )
   __defaultNIL( @SizeProcedure, "" )
   __defaultNIL( @ClickProcedure, "" )
   __defaultNIL( @MouseMoveProcedure, "" )
   __defaultNIL( @PaintProcedure, "" )
   __defaultNIL( @GotFocus, "" )
   __defaultNIL( @LostFocus, "" )
   __defaultNIL( @scrollup, "" )
   __defaultNIL( @scrolldown, "" )
   __defaultNIL( @scrollleft, "" )
   __defaultNIL( @scrollright, "" )
   __defaultNIL( @hscrollbox, "" )
   __defaultNIL( @vscrollbox, "" )

   IF ValType( VirtualHeight ) == "U"
      VirtualHeight := 0
      vscroll := .F.
   ELSE
      IF VirtualHeight <= h
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Height must be greater than Window Height." )
      ENDIF
      vscroll := .T.
   ENDIF

   IF ValType( VirtualWidth ) == "U"
      VirtualWidth := 0
      hscroll := .F.
   ELSE
      IF VirtualWidth <= w
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Width must be greater than Window Width." )
      ENDIF
      hscroll := .T.
   ENDIF

   IF MSC_VER() > 0
      IF nosize .AND. _HMG_IsThemed
         w += 10
         h += 10
      ENDIF
   ENDIF

   IF ValType ( aRGB ) != 'C' .AND. IsArrayRGB ( aRGB ) == .F.
      aRGB := { -1, -1, -1 }
   ENDIF

   IF ValType ( icon ) == 'U' .AND. ValType ( _HMG_DefaultIconName ) != 'U'
      icon := _HMG_DefaultIconName
   ENDIF

   _HMG_ActiveFormName := FormName
   IF mdi
      _HMG_MainClientMDIName := FormName  // JP MDI
   ENDIF

   _HMG_BeginWindowActive := .T.

   ClassName := "HMG_FORM_" + FormName
   UnRegisterWindow ( ClassName )

   IF mdi
      _HMG_BeginWindowMDIActive := .T.  // JP MDI
      BrushHandle := RegisterMDIWindow( icon, FormName, aRGB )
      Formhandle := InitMDIWindow( Caption, x, y, w, h, nominimize, nomaximize, nosize, nosysmenu, nocaption, topmost, FormName, ParentHandle, vscroll, hscroll, helpbutton )
   ELSE
      BrushHandle := RegisterWindow( icon, ClassName, aRGB, cursor )  /* P.Ch. 16.10. */
      Formhandle := InitWindow( Caption, x, y, w, h, nominimize, nomaximize, nosize, nosysmenu, nocaption, topmost, ClassName, ParentHandle, vscroll, hscroll, helpbutton, palette, panel )
   ENDIF

   IF Empty( _HMG_InteractiveClose ) .AND. !Main .AND. !nosysmenu .AND. !nocaption
      xDisableCloseButton( FormHandle, .F. )
   ENDIF

   IF mdi .AND. ValType ( cursor ) != "U"  /* P.Ch. 16.10. */
      SetWindowCursor ( FormHandle, cursor )
   ENDIF

   IF Main
      _HMG_MainHandle := FormHandle
      IF ISBLOCK ( NotifyBalloonClick )
         _HMG_NotifyBalloonClick := NotifyBalloonClick
      ENDIF
   ENDIF

   IF ValType ( NotifyIconName ) == "U"
      NotifyIconName := ""
   ELSE
      hnotifyicon := LoadTrayIcon( GetResources(), NotifyIconName )
      ShowNotifyIcon ( FormHandle, .T., hnotifyicon, NotifyIconTooltip )
   ENDIF

   htooltip := InitToolTip ( FormHandle, SetToolTipBalloon() )

   IF SetToolTipMaxWidth() <> -1
      SendMessage ( htooltip, TTM_SETMAXTIPWIDTH, 0, SetToolTipMaxWidth() )
   ENDIF

   cType := iif( Main == .T., 'A', iif( Child == .T., 'C', iif( Panel == .T., 'P', 'S' ) ) )

   k := AScan ( _HMG_aFormDeleted, .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames [ k ] :=  FormName
      _HMG_aFormHandles [ k ] :=  FormHandle
      _HMG_aFormActive [ k ] :=  .F.
      _HMG_aFormType [ k ] :=  cType
      _HMG_aFormParentHandle [ k ] :=  iif( panel, ParentHandle, 0 )
      _HMG_aFormReleaseProcedure [ k ] :=  ReleaseProcedure
      _HMG_aFormInitProcedure [ k ] :=  InitProcedure
      _HMG_aFormToolTipHandle [ k ] :=  htooltip
      _HMG_aFormContextMenuHandle [ k ] :=  0
      _HMG_aFormMouseDragProcedure [ k ] :=  MouseDragProcedure
      _HMG_aFormSizeProcedure [ k ] :=  SizeProcedure
      _HMG_aFormClickProcedure [ k ] :=  ClickProcedure
      _HMG_aFormMouseMoveProcedure [ k ] :=  MouseMoveProcedure
      _HMG_aFormMoveProcedure [ k ] :=  MoveProcedure
      _HMG_aFormDropProcedure [ k ] :=  DropProcedure
      _HMG_aFormDeleted [ k ] := .F.
      _HMG_aFormBkColor [ k ] := aRGB
      _HMG_aFormPaintProcedure [ k ] :=  PaintProcedure
      _HMG_aFormNoShow [ k ] :=  noshow
      _HMG_aFormNotifyIconName [ k ] :=  NotifyIconName
      _HMG_aFormNotifyIconToolTip [ k ] :=  NotifyIconToolTip
      _HMG_aFormNotifyIconLeftClick [ k ] :=  NotifyIconLeftClick
      _HMG_aFormNotifyIconDblClick [ k ] :=  NotifyIconDblClick
      _HMG_aFormGotFocusProcedure [ k ] :=  GotFocus
      _HMG_aFormLostFocusProcedure [ k ] :=  LostFocus
      _HMG_aFormReBarHandle [ k ] :=  0
      _HMG_aFormNotifyMenuHandle [ k ] := 0
      _HMG_aFormBrowseList [ k ] :=  {}
      _HMG_aFormSplitChildList [ k ] := {}
      _HMG_aFormVirtualHeight [ k ] :=  VirtualHeight
      _HMG_aFormVirtualWidth [ k ] :=  VirtualWidth
      _HMG_aFormFocused [ k ] :=  .F.
      _HMG_aFormScrollUp [ k ] :=  ScrollUp
      _HMG_aFormScrollDown [ k ] :=  ScrollDown
      _HMG_aFormScrollLeft [ k ] :=  ScrollLeft
      _HMG_aFormScrollRight [ k ] :=  ScrollRight
      _HMG_aFormHScrollBox [ k ] := HScrollBox
      _HMG_aFormVScrollBox [ k ] := VScrollBox
      _HMG_aFormBrushHandle [ k ] := BrushHandle
      _HMG_aFormFocusedControl [ k ] := 0
      _HMG_aFormGraphTasks [ k ] := {}
      _HMG_aFormMaximizeProcedure [ k ] :=  MaximizeProcedure
      _HMG_aFormMinimizeProcedure [ k ] :=  MinimizeProcedure
      _HMG_aFormRestoreProcedure [ k ] :=  RestoreProcedure
      _HMG_aFormAutoRelease [ k ] :=  ! NoAutoRelease
      _HMG_aFormInteractiveCloseProcedure [ k ] :=  InteractiveCloseProcedure
      _HMG_aFormMinMaxInfo [ k ] := InitMinMaxInfo ( FormHandle )
      _HMG_aFormActivateId [ k ] := 0
      _HMG_aFormMiscData1  [ k ] := {hnotifyicon, cursor, 0}
      _HMG_aFormMiscData2  [ k ] := ''
#ifdef _HMG_COMPAT_
      _HMG_StopWindowEventProcedure [ k ] := .F.
#endif

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames, FormName )
      AAdd ( _HMG_aFormHandles, FormHandle )
      AAdd ( _HMG_aFormActive, .F. )
      AAdd ( _HMG_aFormType, cType )
      AAdd ( _HMG_aFormParentHandle, iif( panel, ParentHandle, 0 ) )
      AAdd ( _HMG_aFormReleaseProcedure, ReleaseProcedure )
      AAdd ( _HMG_aFormInitProcedure, InitProcedure )
      AAdd ( _HMG_aFormToolTipHandle, htooltip )
      AAdd ( _HMG_aFormContextMenuHandle, 0 )
      AAdd ( _HMG_aFormMouseDragProcedure, MouseDragProcedure )
      AAdd ( _HMG_aFormSizeProcedure, SizeProcedure )
      AAdd ( _HMG_aFormClickProcedure, ClickProcedure )
      AAdd ( _HMG_aFormMouseMoveProcedure, MouseMoveProcedure )
      AAdd ( _HMG_aFormMoveProcedure, MoveProcedure )
      AAdd ( _HMG_aFormDropProcedure, DropProcedure )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, aRGB )
      AAdd ( _HMG_aFormPaintProcedure, PaintProcedure )
      AAdd ( _HMG_aFormNoShow, noshow )
      AAdd ( _HMG_aFormNotifyIconName, NotifyIconName    )
      AAdd ( _HMG_aFormNotifyIconToolTip, NotifyIconToolTip    )
      AAdd ( _HMG_aFormNotifyIconLeftClick, NotifyIconLeftClick    )
      AAdd ( _HMG_aFormNotifyIconDblClick, NotifyIconDblClick    )
      AAdd ( _HMG_aFormGotFocusProcedure, GotFocus )
      AAdd ( _HMG_aFormLostFocusProcedure, LostFocus )
      AAdd ( _HMG_aFormReBarHandle, 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle, 0 )
      AAdd ( _HMG_aFormBrowseList, {} )
      AAdd ( _HMG_aFormSplitChildList, {} )
      AAdd ( _HMG_aFormVirtualHeight, VirtualHeight )
      AAdd ( _HMG_aFormVirtualWidth, VirtualWidth )
      AAdd ( _HMG_aFormFocused, .F. )
      AAdd ( _HMG_aFormScrollUp, ScrollUp )
      AAdd ( _HMG_aFormScrollDown, ScrollDown )
      AAdd ( _HMG_aFormScrollLeft, ScrollLeft )
      AAdd ( _HMG_aFormScrollRight, ScrollRight )
      AAdd ( _HMG_aFormHScrollBox, HScrollBox )
      AAdd ( _HMG_aFormVScrollBox, VScrollBox )
      AAdd ( _HMG_aFormBrushHandle, BrushHandle )
      AAdd ( _HMG_aFormFocusedControl, 0 )
      AAdd ( _HMG_aFormGraphTasks, {} )
      AAdd ( _HMG_aFormMaximizeProcedure, MaximizeProcedure )
      AAdd ( _HMG_aFormMinimizeProcedure, MinimizeProcedure )
      AAdd ( _HMG_aFormRestoreProcedure, RestoreProcedure )
      AAdd ( _HMG_aFormAutoRelease, ! NoAutoRelease )
      AAdd ( _HMG_aFormInteractiveCloseProcedure, InteractiveCloseProcedure )
      AAdd ( _HMG_aFormMinMaxInfo, InitMinMaxInfo ( FormHandle ) )
      AAdd ( _HMG_aFormActivateId, 0 )
      AAdd ( _HMG_aFormMiscData1, {hnotifyicon, cursor, 0} )
      AAdd ( _HMG_aFormMiscData2, '' )
#ifdef _HMG_COMPAT_
      AAdd ( _HMG_StopWindowEventProcedure, .F. )
#endif

   ENDIF

#ifdef _PANEL_
   IF _HMG_BeginTabActive .AND. Panel
      AAdd ( _HMG_ActiveTabCurrentPageMap, FormHandle )
      IF _HMG_ActiveTabPage > 1
         _HMG_aFormParentHandle [ k ] := 0
      ENDIF
   ENDIF
#endif

   _SetThisFormInfo( k )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnFormInit, k, mVar )
   ENDIF

   IF !mdi  // JP MDI
      InitDummy( FormHandle )
   ENDIF

   IF VirtualHeight > 0
      SetScrollRange ( Formhandle, SB_VERT, 0, VirtualHeight - h, .T. )
   ENDIF
   IF VirtualWidth > 0
      SetScrollRange ( Formhandle, SB_HORZ, 0, VirtualWidth - w, .T. )
   ENDIF

   IF ISARRAY ( aMin ) .AND. ISARRAY ( aMax )
      iif( aMin[ 1 ] == NIL, NIL, _HMG_aFormMinMaxInfo [ k ] [ 5 ] := aMin[ 1 ] )
      iif( aMin[ 2 ] == NIL, NIL, _HMG_aFormMinMaxInfo [ k ] [ 6 ] := aMin[ 2 ] )
      iif( aMax[ 1 ] == NIL, NIL, _HMG_aFormMinMaxInfo [ k ] [ 7 ] := aMax[ 1 ] )
      iif( aMax[ 2 ] == NIL, NIL, _HMG_aFormMinMaxInfo [ k ] [ 8 ] := aMax[ 2 ] )
   ENDIF

RETURN ( FormHandle )

*-----------------------------------------------------------------------------*
FUNCTION _DefineModalWindow ( FormName, Caption, x, y, w, h, Parent, nosize, nosysmenu, nocaption, aMin, aMax, ;
      InitProcedure, ReleaseProcedure, MouseDragProcedure, SizeProcedure, ClickProcedure, MouseMoveProcedure, aRGB, ;
      PaintProcedure, icon, FontName, FontSize, GotFocus, LostFocus, VirtualHeight, VirtualWidth, ;
      scrollleft, scrollright, scrollup, scrolldown, hscrollbox, vscrollbox, helpbutton, cursor, noshow, ;
      NoAutoRelease, InteractiveCloseProcedure, MoveProcedure, DropProcedure, clientwidth, clientheight, flashexit )
*-----------------------------------------------------------------------------*
   LOCAL BrushHandle, FormHandle
   LOCAL htooltip
   LOCAL ClassName
   LOCAL mVar
   LOCAL vscroll, hscroll
   LOCAL k

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
   ENDIF
#ifdef _HMG_COMPAT_
   IF _HMG_MainWindowFirst == .T.
#endif
      IF AScan ( _HMG_aFormType, 'A' ) == 0
         MsgMiniGuiError( "Main Window is not defined." )
      ENDIF
#ifdef _HMG_COMPAT_
   ENDIF
#endif
   IF _IsWindowDefined ( FormName )
      MsgMiniGuiError( "Window: " + FormName + " is already defined." )
   ENDIF

   IF ! ISNUMBER( w ) .AND. ! ISNUMBER( h )

      IF ! ISNUMBER( clientwidth ) .AND. ! ISNUMBER( clientheight )
         w := GetDesktopWidth() * 0.614
         h := ( GetDesktopHeight() - GetTaskBarHeight() ) * 0.614
      ELSE
         mVar := ( nocaption .AND. nosize )
         w := ClientWidth + iif( mVar, 0, GetBorderWidth() ) + iif( mVar .OR. _HMG_IsThemed .AND. nosize, 0, GetBorderWidth() ) - iif( mVar .OR. (!_HMG_IsThemed .AND. !nosize) .OR. (_HMG_IsThemed .AND. !nocaption .AND. !nosize), 0, 2 )
         h := ClientHeight + iif( nocaption, 0, GetTitleHeight() ) + iif( mVar .OR. _HMG_IsThemed .AND. nosize, 0, GetBorderWidth() ) + iif( mVar, 0, GetBorderWidth() ) - iif( mVar .OR. (!_HMG_IsThemed .AND. !nosize) .OR. (_HMG_IsThemed .AND. !nocaption .AND. !nosize), 0, 2 )
      ENDIF

   ENDIF

   mVar := '_' + FormName

   _HMG_ActiveFontName := hb_defaultValue( FontName, _HMG_DefaultFontName )

   _HMG_ActiveFontSize := hb_defaultValue( FontSize, _HMG_DefaultFontSize )

   hb_default( @Caption, "" )
   hb_default( @flashexit, .F. )
   __defaultNIL( @InitProcedure, "" )
   __defaultNIL( @ReleaseProcedure, "" )
   __defaultNIL( @MouseDragProcedure, "" )
   __defaultNIL( @SizeProcedure, "" )
   __defaultNIL( @ClickProcedure, "" )
   __defaultNIL( @MouseMoveProcedure, "" )
   __defaultNIL( @PaintProcedure, "" )
   __defaultNIL( @GotFocus, "" )
   __defaultNIL( @LostFocus, "" )
   __defaultNIL( @scrollup, "" )
   __defaultNIL( @scrolldown, "" )
   __defaultNIL( @scrollleft, "" )
   __defaultNIL( @scrollright, "" )
   __defaultNIL( @hscrollbox, "" )
   __defaultNIL( @vscrollbox, "" )

   IF ValType( VirtualHeight ) == "U"
      VirtualHeight := 0
      vscroll := .F.
   ELSE
      IF VirtualHeight <= h
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Height must be greater than Window Height." )
      ENDIF
      vscroll := .T.
   ENDIF

   IF ValType( VirtualWidth ) == "U"
      VirtualWidth := 0
      hscroll := .F.
   ELSE
      IF VirtualWidth <= w
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Width must be greater than Window Width." )
      ENDIF
      hscroll := .T.
   ENDIF

   IF MSC_VER() > 0
      IF nosize .AND. !nocaption .AND. _HMG_IsThemed
         w += 10
         h += 10
      ENDIF
   ENDIF

   IF ValType ( aRGB ) != 'C' .AND. IsArrayRGB ( aRGB ) == .F.
      aRGB := { -1, -1, -1 }
   ENDIF

   IF ValType ( icon ) == 'U' .AND. ValType ( _HMG_DefaultIconName ) != 'U'
      icon := _HMG_DefaultIconName
   ENDIF

   IF _HMG_InplaceParentHandle <> 0
      Parent := _hmg_InplaceParentHandle
   ELSEIF ! _HMG_BeginWindowMDIActive
      Parent := _hmg_MainHandle
   ENDIF

   _HMG_ActiveFormName := FormName
   _HMG_BeginWindowActive := .T.

   ClassName := "HMG_FORM_" + FormName
   UnRegisterWindow ( ClassName )

   BrushHandle := RegisterWindow( icon, ClassName, aRGB )
   Formhandle := InitModalWindow ( Caption, x, y, w, h, Parent, nosize, nosysmenu, nocaption, ClassName, vscroll, hscroll, helpbutton )

   IF Empty ( _HMG_InteractiveClose ) .AND. !nosysmenu .AND. !nocaption
      xDisableCloseButton( FormHandle, .F. )
   ENDIF

   IF ValType ( cursor ) != "U"
      SetWindowCursor( FormHandle, cursor )
   ENDIF

   htooltip := InitToolTip( , SetToolTipBalloon() )

   IF SetToolTipMaxWidth() <> -1
      SendMessage( htooltip, TTM_SETMAXTIPWIDTH, 0, SetToolTipMaxWidth() )
   ENDIF

   k := AScan ( _HMG_aFormDeleted, .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames [ k ] :=  FormName
      _HMG_aFormHandles [ k ] :=  FormHandle
      _HMG_aFormActive [ k ] :=  .F.
      _HMG_aFormType [ k ] :=  "M"
      _HMG_aFormParentHandle [ k ] :=  Parent
      _HMG_aFormReleaseProcedure [ k ] :=  ReleaseProcedure
      _HMG_aFormInitProcedure [ k ] :=  InitProcedure
      _HMG_aFormToolTipHandle [ k ] :=  htooltip
      _HMG_aFormContextMenuHandle [ k ] := 0
      _HMG_aFormMouseDragProcedure [ k ] :=  MouseDragProcedure
      _HMG_aFormSizeProcedure [ k ] :=  SizeProcedure
      _HMG_aFormClickProcedure [ k ] :=  ClickProcedure
      _HMG_aFormMouseMoveProcedure [ k ] :=  MouseMoveProcedure
      _HMG_aFormMoveProcedure [ k ] :=  MoveProcedure
      _HMG_aFormDropProcedure [ k ] :=  DropProcedure
      _HMG_aFormDeleted [ k ] :=  .F.
      _HMG_aFormBkColor [ k ] :=  aRGB
      _HMG_aFormPaintProcedure [ k ] :=  PaintProcedure
      _HMG_aFormNoShow [ k ] :=  noshow
      _HMG_aFormNotifyIconName [ k ] :=  ''
      _HMG_aFormNotifyIconToolTip [ k ] :=  ''
      _HMG_aFormNotifyIconLeftClick [ k ] :=  ''
      _HMG_aFormNotifyIconDblClick [ k ] :=  ''
      _HMG_aFormGotFocusProcedure [ k ] :=  GotFocus
      _HMG_aFormLostFocusProcedure [ k ] :=  LostFocus
      _HMG_aFormReBarHandle [ k ] :=  0
      _HMG_aFormNotifyMenuHandle [ k ] :=  0
      _HMG_aFormBrowseList [ k ] :=  {}
      _HMG_aFormSplitChildList [ k ] :=  {}
      _HMG_aFormVirtualHeight [ k ] :=  VirtualHeight
      _HMG_aFormVirtualWidth [ k ] :=  VirtualWidth
      _HMG_aFormFocused [ k ] :=  flashexit
      _HMG_aFormScrollUp [ k ] :=  ScrollUp
      _HMG_aFormScrollDown [ k ] :=  ScrollDown
      _HMG_aFormScrollLeft [ k ] :=  ScrollLeft
      _HMG_aFormScrollRight [ k ] :=  ScrollRight
      _HMG_aFormHScrollBox [ k ] :=  HScrollBox
      _HMG_aFormVScrollBox [ k ] :=  VScrollBox
      _HMG_aFormBrushHandle [ k ] :=  BrushHandle
      _HMG_aFormFocusedControl [ k ] := 0
      _HMG_aFormGraphTasks [ k ] :=  {}
      _HMG_aFormMaximizeProcedure [ k ] :=  Nil
      _HMG_aFormMinimizeProcedure [ k ] :=  Nil
      _HMG_aFormRestoreProcedure [ k ] :=  Nil
      _HMG_aFormAutoRelease [ k ] :=  ! NoAutoRelease
      _HMG_aFormInteractiveCloseProcedure [ k ] :=  InteractiveCloseProcedure
      _HMG_aFormMinMaxInfo [ k ] := InitMinMaxInfo ( FormHandle )
      _HMG_aFormActivateId [ k ] := 0
      _HMG_aFormMiscData1  [ k ] := {NIL, cursor, 0}
      _HMG_aFormMiscData2  [ k ] := ''
#ifdef _HMG_COMPAT_
      _HMG_StopWindowEventProcedure [ k ] := .F.
#endif

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames, FormName )
      AAdd ( _HMG_aFormHandles, FormHandle )
      AAdd ( _HMG_aFormActive, .F. )
      AAdd ( _HMG_aFormType, "M" )
      AAdd ( _HMG_aFormParentHandle, Parent )
      AAdd ( _HMG_aFormReleaseProcedure, ReleaseProcedure )
      AAdd ( _HMG_aFormInitProcedure, InitProcedure )
      AAdd ( _HMG_aFormToolTipHandle, htooltip )
      AAdd ( _HMG_aFormContextMenuHandle, 0 )
      AAdd ( _HMG_aFormMouseDragProcedure, MouseDragProcedure )
      AAdd ( _HMG_aFormSizeProcedure, SizeProcedure )
      AAdd ( _HMG_aFormClickProcedure, ClickProcedure )
      AAdd ( _HMG_aFormMouseMoveProcedure, MouseMoveProcedure )
      AAdd ( _HMG_aFormMoveProcedure, MoveProcedure )
      AAdd ( _HMG_aFormDropProcedure, DropProcedure )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, aRGB )
      AAdd ( _HMG_aFormPaintProcedure, PaintProcedure )
      AAdd ( _HMG_aFormNoShow, noshow )
      AAdd ( _HMG_aFormNotifyIconName, '' )
      AAdd ( _HMG_aFormNotifyIconToolTip, '' )
      AAdd ( _HMG_aFormNotifyIconLeftClick, '' )
      AAdd ( _HMG_aFormNotifyIconDblClick, '' )
      AAdd ( _HMG_aFormGotFocusProcedure, GotFocus )
      AAdd ( _HMG_aFormLostFocusProcedure, LostFocus )
      AAdd ( _HMG_aFormReBarHandle, 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle, 0 )
      AAdd ( _HMG_aFormBrowseList, {} )
      AAdd ( _HMG_aFormSplitChildList, {} )
      AAdd ( _HMG_aFormVirtualHeight, VirtualHeight )
      AAdd ( _HMG_aFormVirtualWidth, VirtualWidth )
      AAdd ( _HMG_aFormFocused, flashexit )
      AAdd ( _HMG_aFormScrollUp, ScrollUp )
      AAdd ( _HMG_aFormScrollDown, ScrollDown )
      AAdd ( _HMG_aFormScrollLeft, ScrollLeft )
      AAdd ( _HMG_aFormScrollRight, ScrollRight )
      AAdd ( _HMG_aFormHScrollBox, HScrollBox )
      AAdd ( _HMG_aFormVScrollBox, VScrollBox )
      AAdd ( _HMG_aFormBrushHandle, BrushHandle )
      AAdd ( _HMG_aFormFocusedControl, 0 )
      AAdd ( _HMG_aFormGraphTasks, {} )
      AAdd ( _HMG_aFormMaximizeProcedure, Nil )
      AAdd ( _HMG_aFormMinimizeProcedure, Nil )
      AAdd ( _HMG_aFormRestoreProcedure, Nil )
      AAdd ( _HMG_aFormAutoRelease, ! NoAutoRelease )
      AAdd ( _HMG_aFormInteractiveCloseProcedure, InteractiveCloseProcedure )
      AAdd ( _HMG_aFormMinMaxInfo, InitMinMaxInfo ( FormHandle ) )
      AAdd ( _HMG_aFormActivateId, 0 )
      AAdd ( _HMG_aFormMiscData1, {NIL, cursor, 0} )
      AAdd ( _HMG_aFormMiscData2, '' )
#ifdef _HMG_COMPAT_
      AAdd ( _HMG_StopWindowEventProcedure, .F. )
#endif

   ENDIF

   _SetThisFormInfo( k )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnFormInit, k, mVar )
   ENDIF

   InitDummy( FormHandle )

   IF VirtualHeight > 0
      SetScrollRange ( Formhandle, SB_VERT, 0, VirtualHeight - h, .T. )
   ENDIF
   IF VirtualWidth > 0
      SetScrollRange ( Formhandle, SB_HORZ, 0, VirtualWidth - w, .T. )
   ENDIF

   IF ISARRAY ( aMin ) .AND. ISARRAY ( aMax )
      iif( aMin[ 1 ] == NIL, NIL, _HMG_aFormMinMaxInfo[ k ] [ 5 ] := aMin[ 1 ] )
      iif( aMin[ 2 ] == NIL, NIL, _HMG_aFormMinMaxInfo[ k ] [ 6 ] := aMin[ 2 ] )
      iif( aMax[ 1 ] == NIL, NIL, _HMG_aFormMinMaxInfo[ k ] [ 7 ] := aMax[ 1 ] )
      iif( aMax[ 2 ] == NIL, NIL, _HMG_aFormMinMaxInfo[ k ] [ 8 ] := aMax[ 2 ] )
   ENDIF

RETURN ( FormHandle )

*-----------------------------------------------------------------------------*
FUNCTION _DefineSplitChildWindow ( FormName, w, h, break, grippertext, nocaption, title, fontname, fontsize, gotfocus, lostfocus, ;
      virtualheight, VirtualWidth, Focused, scrollleft, scrollright, scrollup, scrolldown, hscrollbox, vscrollbox, cursor )
*-----------------------------------------------------------------------------*
   LOCAL aRGB := { -1, -1, -1 }
   LOCAL BrushHandle, FormHandle
   LOCAL htooltip
   LOCAL ParentForm
   LOCAL mVar
   LOCAL hscroll, vscroll
   LOCAL k
   LOCAL i

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
   ENDIF
#ifdef _HMG_COMPAT_
   IF _HMG_MainWindowFirst == .T.
#endif
      IF AScan ( _HMG_aFormType, 'A' ) == 0
         MsgMiniGuiError( "Main Window is not defined." )
      ENDIF
#ifdef _HMG_COMPAT_
   ENDIF
#endif
   IF _IsWindowDefined ( FormName )
      MsgMiniGuiError( "Window: " + FormName + " is already defined." )
   ENDIF

   IF _HMG_ActiveSplitBox == .F.
      MsgMiniGuiError( "SplitChild Windows can be defined only inside SplitBox." )
   ENDIF

   _HMG_ActiveFontName := hb_defaultValue( FontName, _HMG_DefaultFontName )

   _HMG_ActiveFontSize := hb_defaultValue( FontSize, _HMG_DefaultFontSize )

   IF ValType( VirtualHeight ) == "U"
      VirtualHeight := 0
      vscroll := .F.
   ELSE
      IF VirtualHeight <= h
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Height must be greater than Window Height." )
      ENDIF
      vscroll := .T.
   ENDIF

   IF ValType( VirtualWidth ) == "U"
      VirtualWidth := 0
      hscroll := .F.
   ELSE
      IF VirtualWidth <= w
         MsgMiniGuiError( "DEFINE WINDOW: Virtual Width must be greater than Window Width." )
      ENDIF
      hscroll := .T.
   ENDIF

   _HMG_SplitChildActive := .T.

   ParentForm := _HMG_ActiveFormName

   mVar := '_' + FormName

   _HMG_ActiveFormNameBak := _HMG_ActiveFormName

   _HMG_ActiveFormName := FormName
   _HMG_BeginWindowActive := .T.

   UnRegisterWindow ( FormName )
   BrushHandle := RegisterSplitChildWindow( "", FormName, aRGB )

   i := GetFormIndex ( ParentForm )

   IF i > 0

      Formhandle := InitSplitChildWindow ( w, h, FormName, nocaption, title, 0, vscroll, hscroll )

      IF ValType ( cursor ) != "U"
         SetWindowCursor( FormHandle, cursor )
      ENDIF

      IF _HMG_SplitLastControl == 'TOOLBAR' .AND. _HMG_ActiveSplitBoxInverted == .F.
         Break := .T.
      ENDIF

      AddSplitBoxItem ( FormHandle, _HMG_aFormReBarHandle [ i ], w, break, grippertext,  ,  , _HMG_ActiveSplitBoxInverted )

      _HMG_SplitLastControl := 'SPLITCHILD'

   ENDIF

   __defaultNIL( @scrollup, "" )
   __defaultNIL( @scrolldown, "" )
   __defaultNIL( @scrollleft, "" )
   __defaultNIL( @scrollright, "" )
   __defaultNIL( @hscrollbox, "" )
   __defaultNIL( @vscrollbox, "" )

   htooltip := InitToolTip( FormHandle, SetToolTipBalloon() )

   IF SetToolTipMaxWidth() <> -1
      SendMessage( htooltip, TTM_SETMAXTIPWIDTH, 0, SetToolTipMaxWidth() )
   ENDIF

   k := AScan ( _HMG_aFormDeleted, .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames [ k ] := FormName
      _HMG_aFormHandles [ k ] :=  FormHandle
      _HMG_aFormActive [ k ] :=  .F.
      _HMG_aFormType [ k ] :=  'X'
      _HMG_aFormParentHandle [ k ] :=  GetFormHandle( ParentForm )
      _HMG_aFormReleaseProcedure [ k ] :=  ""
      _HMG_aFormInitProcedure [ k ] :=  ""
      _HMG_aFormToolTipHandle [ k ] :=  hToolTip
      _HMG_aFormContextMenuHandle [ k ] :=  0
      _HMG_aFormMouseDragProcedure [ k ] :=  ""
      _HMG_aFormSizeProcedure [ k ] :=  ""
      _HMG_aFormClickProcedure [ k ] :=  ""
      _HMG_aFormMouseMoveProcedure [ k ] :=  ""
      _HMG_aFormMoveProcedure [ k ] :=  ""
      _HMG_aFormDropProcedure [ k ] :=  ""
      _HMG_aFormDeleted [ k ] := .F.
      _HMG_aFormBkColor [ k ] := aRGB
      _HMG_aFormPaintProcedure [ k ] :=  ""
      _HMG_aFormNoShow [ k ] := .F.
      _HMG_aFormNotifyIconName [ k ] :=  ""
      _HMG_aFormNotifyIconToolTip [ k ] :=  ""
      _HMG_aFormNotifyIconLeftClick [ k ] :=  ""
      _HMG_aFormNotifyIconDblClick [ k ] :=  ""
      _HMG_aFormGotFocusProcedure [ k ] := gotfocus
      _HMG_aFormLostFocusProcedure [ k ] := lostfocus
      _HMG_aFormReBarHandle [ k ] :=  0
      _HMG_aFormNotifyMenuHandle [ k ] :=  0
      _HMG_aFormBrowseList [ k ] :=  {}
      _HMG_aFormSplitChildList [ k ] :=  {}
      _HMG_aFormVirtualHeight [ k ] :=  VirtualHeight
      _HMG_aFormVirtualWidth [ k ] :=  VirtualWidth
      _HMG_aFormFocused [ k ] :=  Focused
      _HMG_aFormScrollUp [ k ] :=  ScrollUp
      _HMG_aFormScrollDown [ k ] :=  ScrollDown
      _HMG_aFormScrollLeft [ k ] :=  ScrollLeft
      _HMG_aFormScrollRight [ k ] :=  ScrollRight
      _HMG_aFormHScrollBox [ k ] :=  HScrollBox
      _HMG_aFormVScrollBox [ k ] :=  VScrollBox
      _HMG_aFormBrushHandle [ k ] :=  BrushHandle
      _HMG_aFormFocusedControl [ k ] :=  0
      _HMG_aFormGraphTasks [ k ] :=  {}
      _HMG_aFormMaximizeProcedure [ k ] :=  Nil
      _HMG_aFormMinimizeProcedure [ k ] :=  Nil
      _HMG_aFormRestoreProcedure [ k ] :=  Nil
      _HMG_aFormAutoRelease [ k ] :=  .T.
      _HMG_aFormInteractiveCloseProcedure [ k ] :=  iif( nocaption, {|| .F.}, "" )
      _HMG_aFormMinMaxInfo [ k ] := InitMinMaxInfo ( FormHandle )
      _HMG_aFormActivateId [ k ] := 0
      _HMG_aFormMiscData1  [ k ] := {NIL, cursor, 0}
      _HMG_aFormMiscData2  [ k ] := ''
#ifdef _HMG_COMPAT_
      _HMG_StopWindowEventProcedure [ k ] := .F.
#endif

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames, FormName )
      AAdd ( _HMG_aFormHandles, FormHandle )
      AAdd ( _HMG_aFormActive, .F. )
      AAdd ( _HMG_aFormType, 'X' )
      AAdd ( _HMG_aFormParentHandle, GetFormHandle( ParentForm ) )
      AAdd ( _HMG_aFormReleaseProcedure, "" )
      AAdd ( _HMG_aFormInitProcedure, "" )
      AAdd ( _HMG_aFormToolTipHandle, hToolTip )
      AAdd ( _HMG_aFormContextMenuHandle, 0 )
      AAdd ( _HMG_aFormMouseDragProcedure, "" )
      AAdd ( _HMG_aFormSizeProcedure, "" )
      AAdd ( _HMG_aFormClickProcedure, "" )
      AAdd ( _HMG_aFormMouseMoveProcedure, "" )
      AAdd ( _HMG_aFormMoveProcedure, "" )
      AAdd ( _HMG_aFormDropProcedure, "" )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, aRGB )
      AAdd ( _HMG_aFormPaintProcedure, "" )
      AAdd ( _HMG_aFormNoShow, .F. )
      AAdd ( _HMG_aFormNotifyIconName, "" )
      AAdd ( _HMG_aFormNotifyIconToolTip, "" )
      AAdd ( _HMG_aFormNotifyIconLeftClick, "" )
      AAdd ( _HMG_aFormNotifyIconDblClick, "" )
      AAdd ( _HMG_aFormGotFocusProcedure, gotfocus )
      AAdd ( _HMG_aFormLostFocusProcedure, lostfocus )
      AAdd ( _HMG_aFormReBarHandle, 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle, 0 )
      AAdd ( _HMG_aFormBrowseList, {} )
      AAdd ( _HMG_aFormSplitChildList, {} )
      AAdd ( _HMG_aFormVirtualHeight, VirtualHeight )
      AAdd ( _HMG_aFormVirtualWidth, VirtualWidth )
      AAdd ( _HMG_aFormFocused, Focused )
      AAdd ( _HMG_aFormScrollUp, ScrollUp )
      AAdd ( _HMG_aFormScrollDown, ScrollDown )
      AAdd ( _HMG_aFormScrollLeft, ScrollLeft )
      AAdd ( _HMG_aFormScrollRight, ScrollRight )
      AAdd ( _HMG_aFormHScrollBox, HScrollBox )
      AAdd ( _HMG_aFormVScrollBox, VScrollBox )
      AAdd ( _HMG_aFormBrushHandle, BrushHandle )
      AAdd ( _HMG_aFormFocusedControl, 0 )
      AAdd ( _HMG_aFormGraphTasks, {} )
      AAdd ( _HMG_aFormMaximizeProcedure, Nil )
      AAdd ( _HMG_aFormMinimizeProcedure, Nil )
      AAdd ( _HMG_aFormRestoreProcedure, Nil )
      AAdd ( _HMG_aFormAutoRelease, .T. )
      AAdd ( _HMG_aFormInteractiveCloseProcedure, iif( nocaption, {|| .F.}, "" ) )
      AAdd ( _HMG_aFormMinMaxInfo, {} )
      AAdd ( _HMG_aFormActivateId, 0 )
      AAdd ( _HMG_aFormMiscData1, {NIL, cursor, 0} )
      AAdd ( _HMG_aFormMiscData2, '' )
#ifdef _HMG_COMPAT_
      AAdd ( _HMG_StopWindowEventProcedure, .F. )
#endif

   ENDIF

   _HMG_ActiveSplitChildIndex := k
   _SetThisFormInfo( k )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnFormInit, k, mVar )
   ENDIF

   InitDummy( FormHandle )

   AAdd ( _HMG_aFormSplitChildList[ i ], _HMG_ActiveSplitChildIndex )

   IF VirtualHeight > 0
      SetScrollRange ( Formhandle, SB_VERT, 0, VirtualHeight - h, .T. )
   ENDIF
   IF VirtualWidth > 0
      SetScrollRange ( Formhandle, SB_HORZ, 0, VirtualWidth - w, .T. )
   ENDIF

RETURN ( FormHandle )

*-----------------------------------------------------------------------------*
FUNCTION _SetThisFormInfo ( i )
*-----------------------------------------------------------------------------*
   LOCAL lDefine := .T.      // BK 18.05.2015 
  
   IF PCount() == 0

      _PopEventInfo()

   ELSE

      IF HB_ISCHAR( i )
         i := GetFormIndex( i )
         lDefine := .F.
#ifdef _OBJECT_
      ELSEIF HB_ISOBJECT( i )
         i := iif( i:ClassName == 'TSBROWSE', GetFormIndex( i:cParentWnd ), i:Index )
         lDefine := .F. 
#endif
      ENDIF 
#ifdef _HMG_COMPAT_
      _HMG_LastActiveFormIndex := i
#endif
      _PushEventInfo()

      _HMG_ThisFormIndex   := i
      _HMG_ThisEventType   := iif( lDefine, 'DEFINE_WINDOW', '' )
      _HMG_ThisType        := iif( lDefine, 'W', _HMG_aFormType [ i ] )
      _HMG_ThisIndex       := i
      _HMG_ThisFormName    := _HMG_aFormNames [ _HMG_ThisFormIndex ]
      _HMG_ThisControlName :=  ""

   ENDIF 

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _SetWindowSizePos ( FormName, row, col, width, height )
*-----------------------------------------------------------------------------*
   LOCAL actpos := { 0, 0, 0, 0 }
   LOCAL hWnd := iif( ISNUMERIC( FormName ), FormName, GetFormHandle ( FormName ) )
#ifdef _PANEL_
   LOCAL lspang := ( ISNUMBER( row ) .AND. ISNUMBER( col ) .AND. ISNUMBER( width ) .AND. ISNUMBER( height ) )
#endif
   GetWindowRect( hWnd, /*@*/actpos )

   col := IFNIL( col, actpos [ 1 ], col )
   row := IFNIL( row, actpos [ 2 ], row )
   width := IFNIL( width, actpos [ 3 ] - actpos [ 1 ], width )
   height := IFNIL( height, actpos [ 4 ] - actpos [ 2 ], height )

#ifdef _PANEL_
   IF ISCHARACTER( FormName ) .AND. GetWindowType ( FormName ) == 'P'
      IF lspang
         col += GetBorderWidth()
         row += GetTitleHeight() + GetBorderHeight()
      ENDIF
      actpos := ScreenToClient ( _HMG_aFormParentHandle [ GetFormIndex ( FormName ) ], col, row )
      col := actpos [ 1 ]
      row := actpos [ 2 ]
   ENDIF
#endif

   MoveWindow ( hWnd, col, row, width, height, .T. )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION GetFormIndex ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + FormName

RETURN __mvGetDef ( mVar , 0 )

*-----------------------------------------------------------------------------*
FUNCTION _SetNotifyIconName ( FormName, IconName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetFormIndex ( FormName ) ) > 0 .AND. _HMG_aFormType [ i ] == 'A'

      IF _HMG_aFormMiscData1 [ i ] [ 1 ] != NIL
         DestroyIcon ( _HMG_aFormMiscData1 [ i ] [ 1 ] )
      ENDIF

      _HMG_aFormMiscData1 [ i ] [ 1 ] := LoadTrayIcon ( GetResources(), IconName )

      ChangeNotifyIcon ( _HMG_aFormHandles [ i ], _HMG_aFormMiscData1 [ i ] [ 1 ], _HMG_aFormNotifyIconTooltip [ i ] )

      _HMG_aFormNotifyIconName [ i ] := IconName

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _SetNotifyIconTooltip ( FormName, TooltipText )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetFormIndex ( FormName ) ) > 0 .AND. _HMG_aFormType [ i ] == 'A'

      IF _HMG_aFormMiscData1 [ i ] [ 1 ] == NIL .AND. ! Empty ( _HMG_aFormNotifyIconName [ i ] )
         _HMG_aFormMiscData1 [ i ] [ 1 ] := LoadTrayIcon ( GetResources(), _HMG_aFormNotifyIconName [ i ] )
      ENDIF

      ChangeNotifyIcon ( _HMG_aFormHandles [ i ], _HMG_aFormMiscData1 [ i ] [ 1 ], TooltipText )

      _HMG_aFormNotifyIconTooltip [ i ] := TooltipText

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _DefineSplitBox ( ParentForm, bottom, inverted )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle
   LOCAL i

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF _HMG_FrameLevel > 0
      MsgMiniGuiError( "SPLITBOX cannot be defined inside Tab control." )
   ENDIF

   IF ! _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _HMG_SplitChildActive == .T.
      MsgMiniGuiError( "SplitBox cannot be defined inside SplitChild Windows." )
   ENDIF

   IF _HMG_ActiveSplitBox == .T.
      MsgMiniGuiError( "SplitBox controls cannot be nested." )
   ENDIF

   _HMG_ActiveSplitBoxInverted := Inverted
   _HMG_ActiveSplitBox := .T.
   _HMG_ActiveSplitBoxParentFormName := ParentForm

   ControlHandle := InitSplitBox ( GetFormHandle ( ParentForm ), bottom, inverted )

   IF ( i := GetFormIndex ( ParentForm ) ) > 0
      _HMG_aFormReBarHandle [ i ] := ControlHandle
   ENDIF

RETURN ControlHandle

*-----------------------------------------------------------------------------*
FUNCTION _EndSplitBox ()
*-----------------------------------------------------------------------------*

   _HMG_SplitLastControl := 'TOOLBAR'
   _HMG_ActiveSplitBox := .F.

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _EndSplitChildWindow ()
*-----------------------------------------------------------------------------*

   _HMG_ActiveFormName := _HMG_ActiveFormNameBak
   _HMG_SplitChildActive := .F.
   _HMG_aFormActive[ _HMG_ActiveSplitChildIndex ] := .T.

RETURN NIL

#ifdef _PANEL_
*-----------------------------------------------------------------------------*
FUNCTION _EndPanelWindow ()
*-----------------------------------------------------------------------------*

   _HMG_ActiveFormName := _HMG_ActiveFormNameBak
   _HMG_ParentWindowActive := .F.

RETURN NIL

#endif
*-----------------------------------------------------------------------------*
FUNCTION _EndWindow ()
*-----------------------------------------------------------------------------*

   DO CASE
   CASE _HMG_SplitChildActive == .T.
      _EndSplitChildWindow ()
#ifdef _PANEL_
   CASE _HMG_ParentWindowActive == .T.
      _EndPanelWindow ()
#endif
   CASE _HMG_MdiChildActive == .T.  // JP MDI
      _EndMdiChildWindow ()
   OTHERWISE
      _HMG_BeginWindowActive := .F.
      _HMG_ActiveFormName := ""
   ENDCASE

   _PopEventInfo()

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION InputBox ( cInputPrompt, cDialogCaption, cDefaultValue, nTimeout, cTimeoutValue, lMultiLine, /*@*/lCanceled )
*-----------------------------------------------------------------------------*
   LOCAL lIsVistaOrLater := IsVistaOrLater()
   LOCAL nBordW  := iif( lIsVistaOrLater, GetBorderWidth() / 2 + 2, 0 )
   LOCAL nTitleH := GetTitleHeight() + iif( lIsVistaOrLater, GetBorderHeight() / 2 + 2, 0 )
   LOCAL nMLines := iif( ValType ( lMultiLine ) == 'L' .AND. lMultiLine, 150, 0 )
   LOCAL bCancel := {|| _HMG_DialogCancelled := lCanceled := .T., DoMethod( '_InputBox', 'Release' ) }
   LOCAL RetVal  := '', lOk := .F.

   hb_default( @cInputPrompt, '' )
   hb_default( @cDialogCaption, '' )
   hb_default( @cDefaultValue, '' )

   DEFINE WINDOW _InputBox;
      AT 0, 0;
      WIDTH 350 + nBordW;
      HEIGHT 115 + nMLines + nTitleH;
      TITLE cDialogCaption;
      MODAL;
      ON SIZE _InputBoxAdjust( nTitleH, nBordW ) ;
      ON INTERACTIVECLOSE iif( lOk, NIL, _HMG_DialogCancelled := lCanceled := .T. )

      ON KEY ESCAPE ACTION Eval( bCancel )

      @ 07, 10 LABEL _Label VALUE cInputPrompt AUTOSIZE
      // JK
      IF nMLines > 0
         @ 30, 10 EDITBOX _TextBox VALUE cDefaultValue HEIGHT 26 + nMLines WIDTH 320
      ELSE
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            ON ENTER IFEMPTY( _InputBox._TextBox.Value, Nil, _InputBox._Ok.OnClick )

         _InputBox.MaxHeight := ( _InputBox.Height )
      ENDIF
      //
      @ 67 + nMLines, 120 BUTTON _Ok;
         CAPTION _HMG_MESSAGE [ 6 ];
         ACTION ( lOk := .T., _HMG_DialogCancelled := lCanceled := .F., ;
            RetVal := _InputBox._TextBox.Value, _InputBox.Release )

      @ 67 + nMLines, 230 BUTTON _Cancel;
        CAPTION _HMG_MESSAGE [ 7 ];
        ACTION Eval( bCancel )

      IF ISNUMERIC ( nTimeout )
         DEFINE TIMER _InputBox INTERVAL nTimeout ;
            ACTION ( IFCHAR ( cTimeoutValue, RetVal := cTimeoutValue, Nil ), _InputBox.Release )
      ENDIF

   END WINDOW

   IF _InputBox._Label.Width > 280
      _InputBox.Width := _InputBox._Label.Width + 34 + nBordW
   ENDIF

   _InputBox.MinWidth  := ( _InputBox.Width )
   _InputBox.MinHeight := ( _InputBox.Height )

   CENTER WINDOW _InputBox
   ACTIVATE WINDOW _InputBox

RETURN ( RetVal )

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _InputBoxAdjust ( nTitleH, nBordW )
*-----------------------------------------------------------------------------*
   LOCAL nWidth  := _InputBox.Width
   LOCAL nHeight := _InputBox.Height

   _InputBox._TextBox.Width  := nWidth  - 30 - nBordW
   _InputBox._TextBox.Height := nHeight - 89 - nTitleH

   _InputBox._Ok.Row         := nHeight - 48 - nTitleH
   _InputBox._Ok.Col         := nWidth  - 230 - nBordW

   _InputBox._Cancel.Row     := nHeight - 48 - nTitleH
   _InputBox._Cancel.Col     := nWidth  - 120 - nBordW

   InvalidateRect( GetFormHandle( '_InputBox' ), 0 )  // GF 11/05/2009

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _SetWindowRgn ( name, col, row, w, h, lx )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( name )

   _HMG_aFormMiscData1 [ i ] [ 3 ] := c_SetWindowRgn( GetFormHandle( name ), col, row, w, h, lx )

RETURN _HMG_aFormMiscData1 [ i ] [ 3 ]

*-----------------------------------------------------------------------------*
FUNCTION _SetPolyWindowRgn ( name, apoints, lx )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( name )
   LOCAL apx := {}, apy := {}

   AEval( apoints, {| x | AAdd( apx, x [ 1 ] ), AAdd( apy, x [ 2 ] ) } )

   _HMG_aFormMiscData1 [ i ] [ 3 ] := c_SetPolyWindowRgn( GetFormHandle( name ), apx, apy, lx )

RETURN _HMG_aFormMiscData1 [ i ] [ 3 ]

*-----------------------------------------------------------------------------*
FUNCTION _ActivateWindow ( aForm, lNoWait, lDebugger, bInit )
*-----------------------------------------------------------------------------*
   LOCAL MainFound := .F.
   LOCAL nForm := Len( aForm )
   LOCAL VisibleModalCount := 0
   LOCAL VisibleModalName := ''
   LOCAL FormName
   LOCAL TmpId
   LOCAL i
#ifdef _PANEL_
   LOCAL x, FormCount := Len ( _HMG_aFormNames )
#endif

   IF _HMG_ThisEventType == 'WINDOW_RELEASE'
      IF !( "_ALERT" $ ProcName( 1 ) .OR. ProcName( 2 ) == "_ALERT" )
         MsgMiniGuiError( "ACTIVATE WINDOW: activate windows within an ON RELEASE window procedure is not allowed." )
      ENDIF
   ENDIF

   IF _HMG_BeginWindowActive
      MsgMiniGUIError( "ACTIVATE WINDOW: DEFINE WINDOW Structure is not closed." )
   ENDIF

   IF _HMG_ThisEventType == 'WINDOW_GOTFOCUS'
      MsgMiniGUIError( "ACTIVATE WINDOW / Activate(): Not allowed in window's GOTFOCUS event procedure." )
   ENDIF

   IF _HMG_ThisEventType == 'WINDOW_LOSTFOCUS'
      MsgMiniGUIError( "ACTIVATE WINDOW / Activate(): Not allowed in window's LOSTFOCUS event procedure." )
   ENDIF

   * Look For Main Window
   FOR EACH FormName IN aForm

      i := GetFormIndex ( FormName )

      Do_WindowEventProcedure( bInit, i, 'WINDOW_ACTIVATE' )

      IF _HMG_aFormType [ i ] == 'A'
         MainFound := .T.
         EXIT
      ENDIF

   NEXT

   * Main Check
#ifdef _HMG_COMPAT_
   IF _HMG_MainWindowFirst == .T.
#endif
   IF _HMG_MainActive == .F.
      IF MainFound == .F.
         MsgMiniGUIError( "ACTIVATE WINDOW: Main Window must be activated in the first ACTIVATE WINDOW command." )
      ENDIF
   ELSE
      IF MainFound == .T.
         MsgMiniGUIError( "ACTIVATE WINDOW: Main Window already active." )
      ENDIF
   ENDIF
#ifdef _HMG_COMPAT_
   ENDIF
#endif
   hb_default( @lNoWait, .F. )

   * Set Main Active Public Flag
   IF MainFound == .T.
      _HMG_MainActive := .T.
   ENDIF

   IF nForm > 1

      IF _HMG_IsModalActive .AND. bInit == NIL
         MsgMiniGUIError( "Multiple Activation can not be used when a Modal window is active." )
      ENDIF

      TmpId := _GenActivateId( nForm )

      FOR EACH FormName IN aForm

         IF ! _IsWindowDefined ( Formname )
            MsgMiniGUIError( "Window: " + FormName + " is not defined." )
         ENDIF

         IF _IsWindowActive ( FormName )
            MsgMiniGUIError( "Window: " + FormName + " already active." )
         ENDIF

#ifdef _PANEL_
         IF GetWindowType ( FormName ) == 'P'
            MsgMiniGUIError( "Panel Windows can't be explicity activated (They are activated via its parent)." )
         ENDIF
#endif
         i := GetFormIndex ( FormName )

#ifdef _PANEL_
         FOR x := 1 TO FormCount

            IF _HMG_aFormType [ x ] == 'P' .AND. _HMG_aFormParentHandle [ x ] == _HMG_aFormHandles [ i ]

               _ShowWindow ( _HMG_aFormNames [ x ] )

               _SetActivationFlag( x )
               _ProcessInitProcedure( x )
               _RefreshDataControls( x )

               IF _SetFocusedSplitChild( x ) == .F.
                  _SetActivationFocus( x )
               ENDIF

            ENDIF

         NEXT x
#endif
         * Only One Visible Modal is Allowed
         IF _HMG_aFormType [ i ] == "M" .AND. _HMG_aFormNoShow [ i ] == .F.
            VisibleModalName := _HMG_aFormNames [ i ]
            IF ++VisibleModalCount > 1
               MsgMiniGUIError( "ACTIVATE WINDOW: Only one initially visible modal window is allowed." )
            ENDIF
         ENDIF

         * Set Activate Id
         _HMG_aFormActivateId [ i ] := TmpId

         * If NOSHOW Clause Is Not Specified, Show The Window
         IF _HMG_aFormNoShow [ i ] == .F.
            ShowWindow( _HMG_aFormHandles [ i ] )
         ENDIF

         _SetActivationFlag( i )
         _ProcessInitProcedure( i )
         _RefreshDataControls( i )

      NEXT

      * If Specified, Execute Show Method For Visible Modal
      * If Not, Process Focus For Last Window In The List

      IF VisibleModalCount == 1
         _ShowWindow ( VisibleModalName )
      ELSE
         IF _SetFocusedSplitChild( i ) == .F.
            _SetActivationFocus( i )
         ENDIF
      ENDIF

   ELSE

      FormName := aForm [ 1 ]

      IF ! _IsWindowDefined ( Formname )
         MsgMiniGUIError( "Window " + FormName + " is not defined." )
      ENDIF

      IF _IsWindowActive ( FormName )
         MsgMiniGUIError( "Window " + FormName + " already active." )
      ENDIF

#ifdef _PANEL_
      IF GetWindowType ( FormName ) == 'P'
         MsgMiniGUIError( "Panel Windows can't be explicity activated (They are activated via its parent)." )
      ENDIF
#endif
      i := GetFormIndex ( FormName )

#ifdef _PANEL_
      FOR x := 1 TO FormCount

         IF _HMG_aFormType [ x ] == 'P' .AND. _HMG_aFormParentHandle [ x ] == _HMG_aFormHandles [ i ]

            _ShowWindow ( _HMG_aFormNames [ x ] )

            _SetActivationFlag( x )
            _ProcessInitProcedure( x )
            _RefreshDataControls( x )

            IF _SetFocusedSplitChild( x ) == .F.
               _SetActivationFocus( x )
            ENDIF

         ENDIF

      NEXT x
#endif
      // JP MDI Background
      IF _HMG_BeginWindowMDIActive
         IF _HMG_aFormBkColor [ i ] [ 1 ] != -1
            SetWindowBackground( _HMG_MainClientMDIHandle, PaintBkGnd( _HMG_MainClientMDIHandle, _HMG_aFormBkColor [ i ] ) )
         ENDIF
      ENDIF
      // JP end

      IF _HMG_aFormType [ i ] == "M"
         _ShowWindow ( _HMG_aFormNames [ i ], .F. )

         _SetActivationFlag( i )
         _ProcessInitProcedure( i )
         _RefreshDataControls( i )
      ELSE
         * Non Modal Check
         IF _HMG_IsModalActive .AND. lNoWait == .F.
            MsgMiniGUIError( "Non Modal Window " + Formname + " can't be activated when a Modal window is active." )
         ENDIF

         IF _HMG_aFormNoShow [ i ] == .F.
            ShowWindow( GetFormHandle( FormName ) )
         ENDIF

         _SetActivationFlag( i )
         _ProcessInitProcedure( i )
         _RefreshDataControls( i )

         IF _SetFocusedSplitChild( i ) == .F.
            _SetActivationFocus( i )
         ENDIF
      ENDIF

   ENDIF

   IF lNoWait == .F.
      * Start The Message Loop
      DO MESSAGE LOOP
   ENDIF

   IF nForm == 1 .AND. hb_defaultValue( lDebugger, .F. )

      i := GetFormIndex( FormName )

      _HMG_aFormActivateId [ i ] := _GenActivateId( nForm + 1 )

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _ActivateAllWindows ( bInit )
*-----------------------------------------------------------------------------*
   LOCAL aForm := {}
   LOCAL MainName := ''
   LOCAL FormName
   LOCAL i

   * If Already Exists Activated Windows When Abort Command
   IF AScan ( _HMG_aFormActive, .T. ) > 0
      MsgMiniGuiError( "ACTIVATE WINDOW ALL: this command should be used at application startup only." )
   ENDIF

   * Force NoShow And NoAutoRelease Styles FOR Non Main Windows Excepting SplitChild and Panel
   * ( Force AutoRelease And Visible For Main )

   FOR EACH FormName IN _HMG_aFormNames

      i := hb_enumindex( FormName )

      IF _HMG_aFormDeleted [ i ] == .F.

         IF ! _HMG_aFormType [ i ] $ 'XP'

            IF _HMG_aFormType [ i ] == 'A'
               _HMG_aFormNoShow [ i ] := .F.
               _HMG_aFormAutoRelease [ i ] := .T.
               MainName := FormName
            ELSE
               _HMG_aFormNoShow [ i ] := .T.
               _HMG_aFormAutoRelease [ i ] := .F.
               AAdd ( aForm, FormName )
            ENDIF

         ENDIF

      ENDIF

   NEXT

   * Check For Error And Call Activate Window Command
   IF Empty ( MainName )
      MsgMiniGuiError( "ACTIVATE WINDOW ALL: Main Window is not defined." )
   ELSEIF Len ( aForm ) == 0
      MsgMiniGuiError( "ACTIVATE WINDOW ALL: Child windows are not defined." )
   ENDIF

   AAdd ( aForm, MainName )

   _ActivateWindow ( aForm, , , bInit )

RETURN NIL

*-----------------------------------------------------------------------------*
PROCEDURE _RefreshDataControls ( i )
*-----------------------------------------------------------------------------*
   LOCAL ControlIndex
   LOCAL SplitIndex
   LOCAL v

   IF ( Len ( _HMG_aFormGraphTasks [ i ] ) > 0 .OR. ;
      ISBLOCK( _HMG_aFormPaintProcedure [ i ] ) ) .AND. _HMG_ProgrammaticChange
      InvalidateRect( _HMG_aFormHandles [ i ], 0 )  // GF 07/11/2012
   ENDIF

   FOR EACH ControlIndex IN _HMG_aFormBrowseList [ i ]

      v := _HMG_aControlValue [ ControlIndex ]
      _Refresh ( ControlIndex )

      IF _HMG_aControlType [ControlIndex ] $ 'COMBO,BROWSE'
         _SetValue ( , , v, ControlIndex )
      ENDIF

   NEXT

   IF Len ( _HMG_aFormSplitChildList [ i ] ) > 0

      FOR EACH SplitIndex IN _HMG_aFormSplitChildList [ i ]

         FOR EACH ControlIndex IN _HMG_aFormBrowseList [ SplitIndex ]

            v := _HMG_aControlValue [ ControlIndex ]
            _Refresh ( ControlIndex )

            IF _HMG_aControlType [ ControlIndex ] $ 'COMBO,BROWSE'
               _SetValue ( , , v, ControlIndex )
            ENDIF

         NEXT

      NEXT

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetActivationFlag ( i )
*-----------------------------------------------------------------------------*
   LOCAL FormName
   LOCAL NoAutoReleaseFound := .F.

   _HMG_aFormActive [i] := .T.

   IF Len ( _HMG_aFormSplitChildList [i] ) > 0
      AEval ( _HMG_aFormSplitChildList [i], {|x| _HMG_aFormActive [x] := .T. } )
   ENDIF

   IF ISBLOCK ( _HMG_aFormDropProcedure [i] )
      DragAcceptFiles ( _HMG_aFormHandles [i], .T. )
   ENDIF

   IF _HMG_aFormType [i] == 'A' .AND. ! _HMG_aFormNoShow [i] .AND. ! IsInsertActive ()

      FOR EACH FormName IN _HMG_aFormNames

         i := hb_enumindex( FormName )

         IF _HMG_aFormDeleted [i] == .F.

            IF ! _HMG_aFormType [i] $ 'AXP'

               IF _HMG_aFormAutoRelease [i] == .F.
                  NoAutoReleaseFound := .T.
                  EXIT
               ENDIF

            ENDIF

         ENDIF

      NEXT

      IF NoAutoReleaseFound == .F. .AND. _HMG_AutoScroll
         iif( _HMG_IsXPorLater, KeyToggleNT( VK_INSERT ), KeyToggle( VK_INSERT ) )  
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _ProcessInitProcedure ( i )
*-----------------------------------------------------------------------------*

   IF ISBLOCK ( _HMG_aFormInitProcedure [ i ] )

      SuppressKeyAndMouseEvents()

      _PushEventInfo()

      _HMG_ThisEventType := 'WINDOW_INIT'
      _HMG_ThisFormIndex := i
      _HMG_ThisType := 'W'
      _HMG_ThisIndex := i
      _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
      _HMG_ThisControlName := ""

      IF ISBLOCK ( _HMG_aFormInitProcedure [ i ] )
         Eval ( _HMG_aFormInitProcedure [ i ] )
      ENDIF

      _PopEventInfo()

   ENDIF

   IF _HMG_AutoAdjust .AND. _HMG_MainClientMDIHandle == 0

      IF _HMG_aFormActive [ i ] .AND. IsWindowSized( _HMG_aFormHandles [ i ] )
         _Autoadjust( _HMG_aFormHandles [ i ] )
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _SetFocusedSplitChild ( i )
*-----------------------------------------------------------------------------*
   LOCAL SplitFocusFlag := .F.
   LOCAL nIndex

   IF Len ( _HMG_aFormSplitChildList [ i ] ) > 0

      FOR EACH nIndex IN _HMG_aFormSplitChildList [ i ]

         IF _HMG_aFormFocused [ nIndex ] == .T.
            SetFocus ( _HMG_aFormHandles [ nIndex ] )
            SplitFocusFlag := .T.
         ENDIF

      NEXT

   ENDIF

RETURN SplitFocusFlag

*-----------------------------------------------------------------------------*
PROCEDURE _SetActivationFocus ( i )
*-----------------------------------------------------------------------------*
   LOCAL FocusDefined := .F.
   LOCAL Sp := GetFocus()
   LOCAL hControl
   LOCAL hParent
   LOCAL x

   hParent := _HMG_aFormHandles [i]

   FOR EACH hControl IN _HMG_aControlHandles

      x := hb_enumindex( hControl )

      IF _HMG_aControlParentHandles [x] == hParent .AND. _HMG_aControlType [x] != "HOTKEY"

         IF _HMG_aControlType [x] == "OBUTTON" .AND. ISLOGICAL ( _HMG_aControlDblClick [x] ) .AND. _HMG_aControlDblClick [x] == .T.
            SetFocus ( hControl )
            FocusDefined := .T.
            EXIT
         ENDIF

      ENDIF

   NEXT

   IF FocusDefined == .F.

      FOR EACH hControl IN _HMG_aControlHandles

         x := hb_enumindex( hControl )

         IF _HMG_aControlParentHandles [x] == hParent .AND. _HMG_aControlType [x] != "HOTKEY" // BK 25-Apr-2012

            IF ISNUMBER ( hControl )
               IF hControl == Sp ;
                  .OR. ;
                  _HMG_aControlType [x] == 'BUTTON' .AND. IsWindowHasStyle ( hControl, BS_DEFPUSHBUTTON )
                  _SetFocus ( , , x )
                  FocusDefined := .T.
                  EXIT
               ENDIF

            ELSEIF ISARRAY ( hControl )
               IF hControl [1] == Sp
                  FocusDefined := .T.
                  EXIT
               ENDIF

            ENDIF

         ENDIF

      NEXT

   ENDIF

   IF FocusDefined == .F.

      IF ( x := AScan ( _HMG_aControlHandles, GetNextDlgTabItem ( hParent, 0, .F. ) ) ) > 0
         _SetFocus ( , , x )
      ENDIF

      IF _HMG_BeginWindowMDIActive  // BK 25-Apr-2012
         _HMG_aFormFocusedControl [i] := GetFocus()
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GenActivateId ( nForm )
*-----------------------------------------------------------------------------*
   LOCAL TmpStr
   LOCAL TmpId

   REPEAT

      TmpId := Int ( Seconds() * 100 )
      TmpStr := '_HMG_ACTIVATE_' + hb_ntos ( TmpId )

   UNTIL __mvExist ( TmpStr )

   __mvPublic ( TmpStr )
   __mvPut ( TmpStr, nForm )

RETURN( TmpId )

*-----------------------------------------------------------------------------*
PROCEDURE _hmg_OnHideFocusManagement ( i )
*-----------------------------------------------------------------------------*
   LOCAL bEnableWindow := {|y, z| iif( _HMG_aFormDeleted [ z ] == .F., ;
      EnableWindow ( _HMG_aFormhandles [ z ] ), ), HB_SYMBOL_UNUSED( y ) }
   LOCAL x

   IF _HMG_aFormParentHandle [ i ] == 0

      * Non Modal

      IF _HMG_IsModalActive == .F.

         AEval( _HMG_aFormHandles, bEnableWindow )

      ENDIF

   ELSE

      * Modal

      IF ( x := AScan ( _HMG_aFormHandles, _HMG_aFormParenthandle [ i ] ) ) > 0

         IF _HMG_aFormType [ x ] == "M"

            * Modal Parent

            _HMG_IsModalActive := .T.
            _HMG_ActiveModalHandle := _HMG_aFormParenthandle [ i ]

            EnableWindow ( _HMG_aFormParenthandle [ i ] )

            SetFocus ( _HMG_aFormParenthandle [ i ] )

         ELSE

            * Non Modal Parent

            _HMG_IsModalActive := .F.
            _HMG_ActiveModalHandle := 0

            AEval ( _HMG_aFormHandles, bEnableWindow )

            SetFocus ( _HMG_aFormParenthandle [ i ] )

         ENDIF

      ELSE

         * Missing Parent

         _HMG_IsModalActive := .F.
         _hmg_ActiveModalHandle := 0

         AEval ( _HMG_aFormHandles, bEnableWindow )

         SetFocus ( _HMG_MainHandle )

      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _DoControlEventProcedure ( bBlock, i, cEventType, nParam )
*-----------------------------------------------------------------------------*
   LOCAL lRetVal

#ifdef _HMG_COMPAT_
   IF _HMG_aControlType [ i ] != "HOTKEY"  // Claudio Soto, November 2016
      _HMG_LastActiveControlIndex := i
   ENDIF
   IF Len( _HMG_StopControlEventProcedure ) >= i .AND. _HMG_StopControlEventProcedure [ i ] == .T.  // Claudio Soto, April 2013
      RETURN .F.
   ENDIF
#endif
   IF ISBLOCK ( bBlock )
      _PushEventInfo()
      _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles, _HMG_aControlParentHandles [ i ] )
      _HMG_ThisType := 'C'
      _HMG_ThisIndex := i
      _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
      _HMG_ThisControlName := _HMG_aControlNames[ _HMG_ThisIndex ]

      IF _HMG_BeginWindowActive == .F. .OR. !( hb_defaultValue( cEventType, '' ) == 'CONTROL_ONCHANGE' ) .OR. _HMG_MainClientMDIHandle != 0
         lRetVal := Eval ( bBlock, hb_defaultValue( nParam, 0 ) )
      ENDIF

      _PopEventInfo()
      lRetVal := IFLOGICAL ( lRetVal, lRetVal, .T. )
   ELSE
      lRetVal := .F.
   ENDIF

RETURN lRetVal

*-----------------------------------------------------------------------------*
FUNCTION _DoWindowEventProcedure ( bBlock, i, cEventType )
*-----------------------------------------------------------------------------*
   LOCAL lRetVal := .F.

#ifdef _HMG_COMPAT_
   IF cEventType != "TASKBAR"  // Claudio Soto, November 2016
      _HMG_LastActiveFormIndex := i
   ENDIF
   IF Len( _HMG_StopWindowEventProcedure ) >= i .AND. _HMG_StopWindowEventProcedure [ i ] == .T.  // Claudio Soto, April 2013
      RETURN .F.
   ENDIF
#endif
   IF ISBLOCK( bBlock )
      _PushEventInfo()
      _HMG_ThisFormIndex := i
      _HMG_ThisEventType := hb_defaultValue( cEventType, '' )
      _HMG_ThisType := 'W'
      _HMG_ThisIndex := i
      _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
      _HMG_ThisControlName :=  ""

      lRetVal := Eval ( bBlock )

      _PopEventInfo()
   ENDIF

RETURN lRetVal

*-----------------------------------------------------------------------------*
FUNCTION IsThemed ()
*-----------------------------------------------------------------------------*
   LOCAL aRetVal := GetDllVersion( "comctl32.dll" )

   IF IsXPThemeActive () .AND. ;
      ( IsAppXPThemed () .AND. aRetVal[ 1 ] >= 6 .OR. aRetVal[ 1 ] == 6 .AND. aRetVal[ 2 ] >= 10 )
      RETURN .T.
   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNCTION IsAppXPThemed ()
*-----------------------------------------------------------------------------*
   LOCAL uResult := .F.

   IF _HMG_IsXPorLater
      InitUxTheme()
      uResult := IsAppThemed()
      EndUxTheme()
   ENDIF

RETURN uResult

*-----------------------------------------------------------------------------*
FUNCTION IsXPThemeActive ()
*-----------------------------------------------------------------------------*
   LOCAL uResult := .F.

   IF _HMG_IsXPorLater
      InitUxTheme()
      uResult := IsThemeActive()
      EndUxTheme()
   ENDIF

RETURN uResult

*-----------------------------------------------------------------------------*
PROCEDURE VirtualChildControlFocusProcess ( nControlHandle, nWindowHandle )
*-----------------------------------------------------------------------------*
   LOCAL nWindowVirtualWidth
   LOCAL nWindowVirtualHeight
   LOCAL nWindowHeight  := 0
   LOCAL nWindowWidth   := 0
   LOCAL nControlHeight := 0
   LOCAL nControlWidth  := 0
   LOCAL nControlRow    := 0
   LOCAL nControlCol    := 0
   LOCAL nHorizontalScrollBoxPos
   LOCAL nVerticalScrollBoxPos
   LOCAL nHorizontalScrollBarRangeMax
   LOCAL nVerticalScrollBarRangeMax
   LOCAL nVisibleAreaFromRow
   LOCAL nVisibleAreaFromCol
   LOCAL nVisibleAreaToRow
   LOCAL nVisibleAreaToCol
   LOCAL nNewScrollBarPos
   LOCAL x

   IF _HMG_AutoScroll == .F. .OR. _HMG_AutoAdjust == .T.
      RETURN
   ENDIF

   * Get Window Width / Height / Virtual Width / Virtual Height

   FOR x := 1 TO Len ( _HMG_aFormHandles )

      IF _HMG_aFormHandles [ x ] == nWindowHandle

         nWindowVirtualHeight := _HMG_aFormVirtualHeight [ x ]
         nWindowVirtualWidth := _HMG_aFormVirtualWidth [ x ]

         IF  nWindowVirtualHeight == 0 .AND. nWindowVirtualWidth == 0
            RETURN
         ELSE
            nWindowHeight := GetWindowHeight ( nWindowHandle )
            nWindowWidth := GetWindowWidth ( nWindowHandle )
            EXIT
         ENDIF

      ENDIF

   NEXT x

   * Get Control Row / Col / Width / Height

   FOR x := 1 TO Len ( _HMG_aControlHandles )

      IF ISNUMBER ( nControlHandle )

         IF ISNUMBER ( _HMG_aControlHandles [ x ] )

            IF _HMG_aControlHandles [ x ] == nControlHandle

               nControlHeight := _HMG_aControlHeight[ x ]
               nControlWidth := _HMG_aControlWidth[ x ]
               nControlRow := _HMG_aControlRow[ x ]
               nControlCol := _HMG_aControlCol[ x ]
               EXIT

            ENDIF

         ELSEIF ISARRAY ( _HMG_aControlHandles [ x ] )

            IF AScan ( _HMG_aControlHandles [ x ], nControlHandle ) > 0

               nControlHeight := _HMG_aControlHeight[ x ]
               nControlWidth := _HMG_aControlWidth[ x ]
               nControlRow := _HMG_aControlRow[ x ]
               nControlCol := _HMG_aControlCol[ x ]
               EXIT

            ENDIF

         ENDIF

      ENDIF

   NEXT x

   * Get hScrollBox Position / vScrollBox Position

   nHorizontalScrollBoxPos := GetScrollPos ( nWindowHandle, SB_HORZ )
   nVerticalScrollBoxPos := GetScrollPos ( nWindowHandle, SB_VERT )

   * Get hScrollBar Maximun Range / vScrollBar Maximun Range

   nHorizontalScrollBarRangeMax := GetScrollRangeMax( nWindowHandle, SB_HORZ )
   nVerticalScrollBarRangeMax := GetScrollRangeMax( nWindowHandle, SB_VERT )

   * Calculate Current Visible Area

   nVisibleAreaFromRow := nVerticalScrollBoxPos
   nVisibleAreaFromCol := nHorizontalScrollBoxPos

   nVisibleAreaToRow := nVisibleAreaFromRow + nWindowHeight - 50
   nVisibleAreaToCol := nVisibleAreaFromCol + nWindowWidth - 10

   * Determine If Control Getting the Focus is out of Visible
   * Area. If So, scroll The Window.

   * Control is too Low To be Visible

   IF nControlRow + nControlHeight > nVisibleAreaToRow

      nNewScrollBarPos := nControlRow + nControlHeight - nWindowHeight + 100

      IF nNewScrollBarPos > nVerticalScrollBarRangeMax
         nNewScrollBarPos := nVerticalScrollBarRangeMax
      ENDIF

      _HMG_SETVSCROLLVALUE( nWindowHandle, nNewScrollBarPos )

   ELSE

      * Control is too High To be Visible

      IF nControlRow + nControlHeight < nVisibleAreaFromRow

         nNewScrollBarPos := nControlRow - nWindowHeight - 100

         IF nNewScrollBarPos < 0
            nNewScrollBarPos := 0
         ENDIF

         _HMG_SETVSCROLLVALUE( nWindowHandle, nNewScrollBarPos )

      ENDIF

   ENDIF

   * Control Is Too Right To Be Visible

   IF nControlCol + nControlWidth > nVisibleAreaToCol

      nNewScrollBarPos := nControlCol + nControlWidth - nWindowWidth + 100

      IF nNewScrollBarPos > nHorizontalScrollBarRangeMax
         nNewScrollBarPos := nHorizontalScrollBarRangeMax
      ENDIF

      _HMG_SETHSCROLLVALUE( nWindowHandle, nNewScrollBarPos )

   ELSE

      * Control Is Too Left To Be Visible

      IF nControlCol + nControlWidth < nVisibleAreaFromCol

         nNewScrollBarPos := nControlCol - nWindowWidth - 100

         IF nNewScrollBarPos < 0
            nNewScrollBarPos := 0
         ENDIF

         _HMG_SETHSCROLLVALUE( nWindowHandle, nNewScrollBarPos )

      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION NoQuote ( cStr )
*-----------------------------------------------------------------------------*

RETURN CharRem ( Chr( 34 ) + Chr( 39 ), cStr )

*-----------------------------------------------------------------------------*
FUNCTION _IsWindowActive ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL mVar
   LOCAL i

   IF ISCHARACTER( FormName )
      mVar := '_' + NoQuote( FormName )

      IF __mvExist ( mVar )
         i := __mvGet ( mVar )
         IF i == 0
            RETURN .F.
         ENDIF
         RETURN ( _HMG_aFormActive [ i ] )
      ENDIF

   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNCTION _IsWindowDefined ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL mVar
   LOCAL i

   IF ISCHARACTER( FormName )
      mVar := '_' + NoQuote( FormName )

      IF __mvExist ( mVar )
         i := __mvGet ( mVar )
         IF i == 0
            RETURN .F.
         ENDIF
         RETURN ( .NOT. ( _HMG_aFormDeleted [ i ] ) )
      ENDIF

   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNCTION GetWindowType ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetFormIndex ( FormName ) ) == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aFormType [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetFormName ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF _HMG_BeginWindowMDIActive

      IF GetActiveMdiHandle() == 0
         RETURN _HMG_MainClientMDIName
      ELSE
         RETURN _GetWindowProperty ( GetActiveMdiHandle(), "PROP_FORMNAME" )
      ENDIF

   ENDIF

   IF ( i := GetFormIndex ( FormName ) ) == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aFormNames [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetFormToolTipHandle ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF _HMG_BeginWindowMDIActive
      FormName := GetFormName ( FormName )
   ENDIF

   IF ( i := GetFormIndex ( FormName ) ) == 0
      MsgMiniGuiError( "Form " + FormName + " is not defined." )
   ENDIF

RETURN ( _HMG_aFormToolTipHandle [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetFormHandle ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetFormIndex ( FormName ) ) == 0
      MsgMiniGuiError( "Form " + FormName + " is not defined." )
   ENDIF

RETURN ( _HMG_aFormHandles [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION ReleaseAllWindows ()
*-----------------------------------------------------------------------------*
   LOCAL FormHandle, hMenu
   //LOCAL oGif
   LOCAL ControlType
   LOCAL i

   IF _HMG_ThisEventType == 'WINDOW_RELEASE'
      MsgMiniGuiError ( "Release a window in its own ON RELEASE procedure or release the Main Window in any ON RELEASE procedure is not allowed." )
   ENDIF

   FOR EACH FormHandle IN _HMG_aFormHandles

      i := hb_enumindex ( FormHandle )

      IF _HMG_aFormActive [ i ] == .T.

         IF ErrorLevel() == 0

            _DoWindowEventProcedure ( _HMG_aFormReleaseProcedure [ i ], i, 'WINDOW_RELEASE' )

            IF _HMG_lOOPEnabled
               Eval ( _HMG_bOnFormDestroy, i )
            ENDIF

         ENDIF

         IF ! Empty ( _HMG_aFormNotifyIconName [ i ] )

            _HMG_aFormNotifyIconName [ i ] := ''
            ShowNotifyIcon ( FormHandle, .F., NIL, NIL )

         ENDIF

         IF GetObjectType ( _HMG_aFormBrushHandle [ i ] ) == OBJ_BRUSH
            DeleteObject ( _HMG_aFormBrushHandle [ i ] )
         ENDIF

         IF Len ( _HMG_aFormMiscData1[ i ] ) > 0 .AND. _HMG_aFormMiscData1 [ i ] [ 1 ] != NIL
            DestroyIcon ( _HMG_aFormMiscData1 [ i ] [ 1 ] )
         ENDIF

         IF Len ( _HMG_aFormMiscData1[ i ] ) > 2 .AND. ! Empty ( _HMG_aFormMiscData1 [ i ] [ 3 ] )
            DeleteObject ( _HMG_aFormMiscData1 [ i ] [ 3 ] )
         ENDIF

      ENDIF

   NEXT

   IF IsExtendedMenuStyleActive() .AND. IsMenu ( hMenu := GetMenu ( _HMG_MainHandle ) )
      _OnDestroyMenu ( hMenu )  // Release OwnerDraw Main Menu
   ENDIF

   FOR EACH ControlType IN _HMG_aControlType

      i := hb_enumindex ( ControlType )

      IF _HMG_aControlDeleted [ i ] == .F.

         DO CASE
         CASE ControlType == 'HOTKEY'

            ReleaseHotKey ( _HMG_aControlParentHandles [ i ] , _HMG_aControlIds [ i ] )

         CASE ControlType == 'FONT'

            _EraseFontDef ( i )

         CASE ControlType == 'ANIGIF'

            _ReleaseAniGif ( _HMG_aControlNames [ i ], GetParentFormName( i ) )

         OTHERWISE

            IF ISCHARACTER ( _HMG_aControlNames [ i ] )
               _EraseControl ( i , AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [ i ] ) )
            ENDIF

         ENDCASE

      ENDIF

   NEXT

   OleDataRelease()

   UnloadRichEditLib()
   UnloadRichEditExLib()

   GdiplusShutdown()

   FreeResources()

   TRY
      dbCloseAll()
   CATCH
   END

   IF Set( _SET_DEBUG )
      CheckRes()
   ENDIF

#ifndef __XHARBOUR__
   IF ErrorLevel() == 0 .AND. ! hb_mtvm()
#else
   IF ErrorLevel() == 0 .AND. ! Hb_MultiThread()
#endif
      __Quit()
   ELSE
      ExitProcess()
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _ReleaseWindow ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL FormHandle
   LOCAL b
   LOCAL i

   b := _HMG_InteractiveClose
   _HMG_InteractiveClose := 1  // Interactive Close event is disabled

   IF ! _IsWindowDefined ( Formname )
      MsgMiniGuiError( "Window: " + FormName + " is not defined." )
   ENDIF

   IF ! _IsWindowActive ( Formname )
      MsgMiniGuiError( "Window: " + FormName + " is not active." )
   ENDIF

   IF _HMG_ThisEventType == 'WINDOW_RELEASE'
      IF GetFormIndex ( FormName ) == _HMG_ThisIndex
         MsgMiniGuiError( "Release a window in its own ON RELEASE procedure or release the Main Window in any ON RELEASE procedure is not allowed." )
      ENDIF
   ENDIF

   * If the window to release is the main application window, RELEASE ALL WINDOWS command will be executed

   IF GetWindowType ( FormName ) == 'A'

      IF _HMG_ThisEventType == 'WINDOW_RELEASE'
         MsgMiniGuiError( "Release a window in its own ON RELEASE procedure or release the Main Window in any ON RELEASE procedure is not allowed." )
      ELSE
         ReleaseAllWindows()
      ENDIF

   ENDIF

#ifdef _PANEL_
   IF GetWindowType ( FormName ) == 'P'
      MsgMiniGuiError( "Release a PANEL window is not allowed (It wiil be released via its parent)." )
   ENDIF
#endif

   i := GetFormIndex ( Formname )

   FormHandle := _HMG_aFormHandles [ i ]

   * Release Window

   IF _HMG_aFormType [ i ] == 'M' .AND. _HMG_ActiveModalHandle <> FormHandle

      EnableWindow ( FormHandle )
      PostMessage ( FormHandle, WM_CLOSE, 0, 1 )

   ELSE

      AEval( _HMG_aFormHandles, {|x, i| iif( _HMG_aFormParentHandle [ i ] == FormHandle, _HMG_aFormParentHandle [ i ] := _HMG_MainHandle, ), ;
         HB_SYMBOL_UNUSED( x ) } )

      EnableWindow ( FormHandle )
      PostMessage ( FormHandle, WM_CLOSE, 0, 1 )

   ENDIF

   _HMG_InteractiveClose := b

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _ShowWindow ( FormName, lProcessMessages )
*-----------------------------------------------------------------------------*
   LOCAL ActiveWindowHandle
   LOCAL i

   i := GetFormIndex ( FormName )

   IF _HMG_aFormType [ i ] == "M"

      * Find Parent

      IF _HMG_IsModalActive

         _HMG_aFormParentHandle [ i ] := _HMG_ActiveModalHandle

      ELSE

         ActiveWindowHandle := _HMG_UserWindowHandle

         IF AScan ( _HMG_aFormHandles, ActiveWindowHandle ) == 0
            ActiveWindowHandle := _HMG_MainHandle
         ENDIF

         _HMG_aFormParentHandle [ i ] := ActiveWindowHandle

      ENDIF

      AEval ( _HMG_aFormHandles, { |y, x| iif( x <> i .AND. ! _HMG_aFormType [ x ] $ 'XP' .AND. ;
         _HMG_aFormParentHandle [ x ] != _HMG_aFormHandles [ i ], DisableWindow ( _HMG_aFormHandles [ x ] ), ), HB_SYMBOL_UNUSED( y ) } )

      IF Len ( _HMG_aFormSplitChildList [ i ] ) > 0
         AEval ( _HMG_aFormSplitChildList [ i ], { | x | EnableWindow ( _HMG_aFormHandles[ x ] ) } )
      ENDIF

#ifdef _HMG_COMPAT_
   IF _HMG_MainWindowFirst == .T.
#endif
      _HMG_IsModalActive := .T.
#ifdef _HMG_COMPAT_
   ENDIF
#endif
      _HMG_ActiveModalHandle := _HMG_aFormHandles [ i ]

      EnableWindow ( _HMG_aFormHandles [ i ] )

      IF _SetFocusedSplitChild ( i ) == .F.
         _SetActivationFocus ( i )
      ENDIF

   ENDIF

   ShowWindow ( _HMG_aFormHandles [ i ] )

   IF hb_defaultValue( lProcessMessages, .T. )

      * Do Process Messages
      DO EVENTS

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _HideWindow ( FormName )
*-----------------------------------------------------------------------------*
   LOCAL FormHandle
   LOCAL i

   IF ( i := GetFormIndex ( FormName ) ) > 0

      FormHandle := _HMG_aFormHandles [ i ]

      IF IsWindowVisible ( FormHandle )

         IF _HMG_aFormType [ i ] == 'M'

            IF _HMG_ActiveModalHandle <> FormHandle
               MsgMiniGuiError ( "Non top modal windows can't be hide." )
            ENDIF

         ENDIF

         HideWindow ( FormHandle )
         _hmg_OnHideFocusManagement ( i )

      ENDIF

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _CenterWindow ( FormName, lParent )
*-----------------------------------------------------------------------------*
   LOCAL FormHandle := GetFormHandle( FormName )

   C_Center( FormHandle, iif( FormHandle == _HMG_MainHandle, .F., hb_defaultValue( lParent, .F. ) ) )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _SetCenterWindowStyle ( lNewStyle )
*-----------------------------------------------------------------------------*
   STATIC lCenterStyle := .F.

   LOCAL lOldStyle := lCenterStyle

   IF ISLOGICAL( lNewStyle )
      lCenterStyle := lNewStyle
   ENDIF

RETURN lOldStyle

*-----------------------------------------------------------------------------*
FUNCTION SuppressKeyAndMouseEvents ( nWait )
*-----------------------------------------------------------------------------*

      REPEAT

         HMG_KeyboardClearBuffer()
         HMG_MouseClearBuffer()
         DO EVENTS

      UNTIL ( InkeyGUI( hb_defaultValue( nWait, 20 ) ) <> 0 )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION GetParentFormName ( nControlIndex )
*-----------------------------------------------------------------------------*
   LOCAL i := AScan( _HMG_aFormHandles, _HMG_aControlParentHandles [ nControlIndex ] )

RETURN iif( i > 0, _HMG_aFormNames [ i ], "" )

#ifdef __XHARBOUR__
   #xtranslate hb_ValToExp( [<x,...>] ) => ValToPrgExp( <x> )
#endif
*-----------------------------------------------------------------------------*
FUNCTION MsgDebug ( ... )
*-----------------------------------------------------------------------------*
   LOCAL nCnt := PCount()
   LOCAL cMsg
   LOCAL i

   cMsg := "Called from: " + ProcName( 1 ) + "(" + hb_ntos( ProcLine( 1 ) ) + ") --> " + ProcFile( 1 ) + CRLF + CRLF

   FOR i = 1 TO nCnt
      cMsg += hb_ValToExp( PValue( i ) ) + iif( i < nCnt, ", ", "" )
   NEXT

   MsgInfo( cMsg, "DEBUG INFO" )

RETURN cMsg

*-----------------------------------------------------------------------------*
PROCEDURE _InitSplashWindow ()
*-----------------------------------------------------------------------------*

   DEFINE WINDOW _HMG_SPLASHWINDOW ;
      CHILD NOSHOW NOAUTORELEASE NOSIZE NOSYSMENU NOCAPTION

      @ 0, 0 IMAGE Image PICTURE ""

   END WINDOW

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _ShowSplashWindow ( cImage, nDelay, bOnInit, bOnRelease )
*-----------------------------------------------------------------------------*
   LOCAL aBmpSize := BmpSize( cImage )
   LOCAL width    := aBmpSize [1]
   LOCAL height   := aBmpSize [2]

   IF _IsWindowDefined( "_HMG_SPLASHWINDOW" ) .AND. width > 0 .AND. height > 0

      DEFAULT nDelay := 2, bOnInit := {|| HideWindow( App.Handle ) }, ;
         bOnRelease := {|| DoEvents(), ShowWindow( App.Handle ) }

      _HMG_SPLASHWINDOW.Image.Picture := cImage

      _HMG_SPLASHWINDOW.Width  := width
      _HMG_SPLASHWINDOW.Height := height

      CENTER WINDOW _HMG_SPLASHWINDOW

      DRAW LINE IN WINDOW _HMG_SPLASHWINDOW ;
         AT 0, 0 TO 0, Width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW _HMG_SPLASHWINDOW ;
         AT Height, 0 TO Height, Width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW _HMG_SPLASHWINDOW ;
         AT 0, 0 TO Height, 0 ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      DRAW LINE IN WINDOW _HMG_SPLASHWINDOW ;
         AT 0, Width TO Height, Width ;
         PENCOLOR BLACK ;
         PENWIDTH 2

      _HMG_SPLASHWINDOW.Topmost := .T.
      _HMG_SPLASHWINDOW.Show()

      Eval( bOnInit )

      SendMessage( _HMG_SPLASHWINDOW.Handle, WM_PAINT, 0, 0 )

      HMG_SysWait( nDelay )

      _HMG_SPLASHWINDOW.Topmost := .F.
      _HMG_SPLASHWINDOW.Hide()

      Eval( bOnRelease )

   ELSE

      DoMethod ( App.FormName, 'Show' )

   ENDIF

RETURN

#ifdef _HMG_COMPAT_  // Dr. Claudio Soto, April 2013
*-----------------------------------------------------------------------------*
FUNCTION StopWindowEventProcedure ( cFormName, lStop )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetFormIndex ( cFormName ) ) > 0
      _HMG_StopWindowEventProcedure [i] := iif( ValType( lStop ) == "L", lStop, .F. )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION StopControlEventProcedure ( cControlName, cFormName, lStop )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( cControlName, cFormName ) ) > 0
      _HMG_StopControlEventProcedure [i] := iif( ValType( lStop ) == "L", lStop, .F. )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION GetLastActiveFormIndex ()
*-----------------------------------------------------------------------------*
   IF _HMG_LastActiveFormIndex > 0 .AND. _HMG_aFormDeleted[ _HMG_LastActiveFormIndex ] == .T.
      _HMG_LastActiveFormIndex := 0
   ENDIF

RETURN _HMG_LastActiveFormIndex

*-----------------------------------------------------------------------------*
FUNCTION GetLastActiveControlIndex ()
*-----------------------------------------------------------------------------*
   IF _HMG_LastActiveControlIndex > 0 .AND. _HMG_aControlDeleted[ _HMG_LastActiveControlIndex ] == .T.
      _HMG_LastActiveControlIndex := 0
   ENDIF

RETURN _HMG_LastActiveControlIndex

*-----------------------------------------------------------------------------*
PROCEDURE WaitWindow ( cMessage, lNoWait )
*-----------------------------------------------------------------------------*
   LOCAL cFormName := "_HMG_CHILDWAITWINDOW"
   LOCAL lDefined := _IsWindowDefined( cFormName )
   LOCAL lIsModal
   LOCAL nWidth

   IF PCount() == 0

      IF lDefined
         nCtEfeito := 0
         cDescEfeito := ""
         DoMethod( cFormName, "Release" )
      ENDIF

   ELSE

      hb_default( @lNoWait, .F. )

      IF lDefined

         IF lNoWait
            SetProperty( cFormName, "Message", "Value", cMessage )
         ENDIF

      ELSE

         lIsModal := _HMG_IsModalActive
         nWidth := GetTextWidth( , cMessage )

         IF lNoWait
            _HMG_IsModalActive := .F.
            DEFINE WINDOW _HMG_CHILDWAITWINDOW CHILD
         ELSE
            DEFINE WINDOW _HMG_CHILDWAITWINDOW MODAL
         ENDIF

         SetProperty( cFormName, "Width", Min( 2 * nWidth, Min( GetDesktopWidth(), 800 ) ) )
         SetProperty( cFormName, "Height", 36 + GetBorderHeight() / 2 )

         SetProperty( cFormName, "Title", "" )
         SetProperty( cFormName, "TitleBar", .F. )
         SetProperty( cFormName, "SysMenu", .F. )

         IF hb_osisWin10()
            SetProperty( cFormName, "Height", GetProperty( cFormName, "Height" ) + 7 )
            SetProperty( cFormName, "BackColor", nRGB2Arr( GetSysColor( COLOR_WINDOW ) ) )
         ENDIF

         @ iif( IsVistaOrLater(), 4, 7 ), 12 LABEL Message ;
            WIDTH GetProperty( cFormName, "Width" ) - 24 - GetBorderWidth() ;
            HEIGHT 18 VALUE cMessage SIZE 10 CENTERALIGN TRANSPARENT

         END WINDOW

         IF GetProperty( cFormName, "Width" ) < 2 * nWidth
            SetProperty( cFormName, "Message", "Value", "" )
            _DefineTimer( "Timer", cFormName, 100, {|| EfeitoLabel( cMessage ) } )
         ENDIF

         DoMethod( cFormName, "Center" )
         _ActivateWindow( { cFormName }, .T. )
         _HMG_IsModalActive := lIsModal

         IF ! lNoWait
            InkeyGUI( 0 )
            IF _IsControlDefined( "Timer", cFormName )
               nCtEfeito := 0
               cDescEfeito := ""
            ENDIF
            DoMethod( cFormName, "Release" )
         ENDIF

      ENDIF

   ENDIF

   DO EVENTS

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE EfeitoLabel ( cTxt )
*-----------------------------------------------------------------------------*
   LOCAL cFormName := ThisWindow.Name
   LOCAL nDescLen := GetTextWidth( , cDescEfeito, _HMG_aControlFontHandle[ GetControlIndex( "Message", cFormName ) ] )
   LOCAL nLblLen := GetProperty( cFormName, "Message", "Width" )

   IF ++nCtEfeito > Len( cTxt )

      IF nDescLen > nLblLen
         nCtEfeito := 0
         cDescEfeito := ""
      ENDIF

      cDescEfeito += " "

   ELSE

      cDescEfeito += SubStr( cTxt, nCtEfeito, 1 )

      IF nDescLen >= nLblLen
         cDescEfeito := SubStr( cDescEfeito, 2 )
      ENDIF

   ENDIF

   SetProperty( cFormName, "Message", "Value", cDescEfeito )

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _HMG_DialogBoxProperty ( nRow, nCol, lCenter, Form, lSet )
*-----------------------------------------------------------------------------*
   STATIC _HMG_DialogBoxPosSizeInfo

   hb_default( @_HMG_DialogBoxPosSizeInfo, Array( 4 ) )
   hb_default( @lSet, .T. )

   IF lSet

      _HMG_DialogBoxPosSizeInfo [1] := nCol
      _HMG_DialogBoxPosSizeInfo [2] := nRow
      _HMG_DialogBoxPosSizeInfo [3] := lCenter
      _HMG_DialogBoxPosSizeInfo [4] := iif( HB_ISSTRING( Form ), GetFormHandle( Form ), Form )

   ELSE

      nCol    := _HMG_DialogBoxPosSizeInfo [1]
      nRow    := _HMG_DialogBoxPosSizeInfo [2]
      lCenter := _HMG_DialogBoxPosSizeInfo [3]
      Form    := _HMG_DialogBoxPosSizeInfo [4]

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _HMG_DialogBoxProcedure()
*-----------------------------------------------------------------------------*
   LOCAL hWnd := GetActiveWindow()
   LOCAL hWndParent
   LOCAL nRow, nCol
   LOCAL lCenter

   IF IsWindowHandle( hWnd ) .AND. GetClassName( hWnd ) == "#32770" // The class name for a dialog box

      _HMG_DialogBoxProperty( @nRow, @nCol, @lCenter, @hWndParent, .F. )

      IF nRow <> NIL .OR. nCol <> NIL .OR. lCenter <> NIL .OR. hWndParent <> NIL

         hb_default( @nCol, GetWindowCol( hWnd ) )
         hb_default( @nRow, GetWindowRow( hWnd ) )
      
         IF ( lCenter := hb_defaultValue( lCenter, .F. ) )

            hb_default( @hWndParent, GetParent( hWnd ) )

            nCol := GetWindowCol( hWndParent ) + Int( ( GetWindowWidth ( hWndParent ) - GetWindowWidth ( hWnd ) ) / 2 )
            nRow := GetWindowRow( hWndParent ) + Int( ( GetWindowHeight( hWndParent ) - GetWindowHeight( hWnd ) ) / 2 )

         ENDIF
   
         SetWindowPos( hWnd, 0, nCol, nRow, 0, 0, SWP_NOOWNERZORDER + SWP_NOSIZE )

      ENDIF

   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION EnumChildWindows( hWnd, bExt )
*-----------------------------------------------------------------------------*
   LOCAL aChilds := {}
   LOCAL bAction

   IF hb_defaultValue( bExt, .F. )
      bAction := {|hChild| AAdd( aChilds, { hChild, GetClassName( hChild ), GetWindowText( hChild ) } ), .T. }
   ELSE
      bAction := {|hChild| AAdd( aChilds, hChild ), .T. }
   ENDIF

   C_EnumChildWindows( hWnd, bAction )

RETURN aChilds

#endif
