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

#include "i_winuser.ch"
#include "minigui.ch"

STATIC lDialogInMemory := .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineButton ( ControlName, ParentFormName, x, y, Caption, ;
   ProcedureName, w, h, fontname, fontsize, tooltip, gotfocus, lostfocus, flat, NoTabStop, HelpId, ;
   invisible, bold, italic, underline, strikeout, multiline, default, key, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle , FontHandle
   LOCAL mVar
   LOCAL blInit
   LOCAL k
   LOCAL Style

   hb_default( @w, 100 )
   hb_default( @h, 28 )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @invisible, .F. )
   hb_default( @flat, .F. )
   hb_default( @NoTabStop, .F. )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style :=  BS_NOTIFY + WS_CHILD + BS_PUSHBUTTON
      IF flat
         style += BS_FLAT
      ENDIF
      IF !NoTabStop
         style += WS_TABSTOP
      ENDIF
      IF !invisible
         style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //           {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogButtonImage( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, caption, HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         IF FontHandle != 0
            _SetFontHandle( ControlHandle, FontHandle )
         ELSE
            __defaultNIL( @FontName, _HMG_DefaultFontName )
            __defaultNIL( @FontSize, _HMG_DefaultFontSize )
            IF IsWindowHandle( ControlHandle )
               FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
            ENDIF
         ENDIF
         IF ValType( caption ) != "U"
            SetWindowText ( ControlHandle , caption )
         ENDIF

         SetWindowStyle ( ControlHandle, style, .T. )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      ControlHandle := InitButton ( ParentFormHandle, Caption, 0, x, y, w, h, '', 0, flat, NoTabStop, invisible, multiline, default )

   ENDIF

   IF .NOT. lDialogInMemory

      IF FontHandle != 0
         _SetFontHandle( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         IF IsWindowHandle( ControlHandle )
            FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
         ENDIF
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "BUTTON"
   _HMG_aControlNames [k] := ControlName
   _HMG_aControlHandles [k] := ControlHandle
   _HMG_aControlParenthandles [k] := ParentFormHandle
   _HMG_aControlIds [k] := nId
   _HMG_aControlProcedures [k] := ProcedureName
   _HMG_aControlPageMap [k] := {}
   _HMG_aControlValue [k] := Nil
   _HMG_aControlInputMask [k] := iif ( ISCHARACTER( key ), key, "" )
   _HMG_aControllostFocusProcedure [k] := lostfocus
   _HMG_aControlGotFocusProcedure [k] := gotfocus
   _HMG_aControlChangeProcedure [k] := ""
   _HMG_aControlDeleted [k] := FALSE
   _HMG_aControlBkColor [k] := Nil
   _HMG_aControlFontColor [k] := Nil
   _HMG_aControlDblClick [k] := ""
   _HMG_aControlHeadClick [k] := {}
   _HMG_aControlRow [k] := y
   _HMG_aControlCol [k] := x
   _HMG_aControlWidth [k] := w
   _HMG_aControlHeight [k] := h
   _HMG_aControlSpacing [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture [k] := ""
   _HMG_aControlContainerHandle [k] := 0
   _HMG_aControlFontName [k] := fontname
   _HMG_aControlFontSize [k] := fontsize
   _HMG_aControlFontAttributes [k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip [k] := tooltip
   _HMG_aControlRangeMin [k] := 0
   _HMG_aControlRangeMax [k] := 0
   _HMG_aControlCaption [k] := Caption
   _HMG_aControlVisible [k] := iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId [k] := HelpId
   _HMG_aControlFontHandle [k] := FontHandle
   _HMG_aControlBrushHandle [k] := 0
   _HMG_aControlEnabled [k] := .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      _SetHotKeyByName ( ParentFormName , key , ProcedureName )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineImageButton ( ControlName, ParentFormName, x, y, Caption, ;
   ProcedureName, w, h, image, tooltip, gotfocus, lostfocus, flat, notrans, HelpId, ;
   invisible, notabstop, default, icon, extract, nIdx, noxpstyle, key, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle
   LOCAL aRet
   LOCAL mVar
   LOCAL cPicture
   LOCAL blInit
   LOCAL k
   LOCAL Style
   LOCAL nhImage

   hb_default( @flat, .F. )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @noxpstyle, .F. )
   hb_default( @nIdx, 0 )

   IF _HMG_ToolBarActive
      RETURN Nil
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF !Empty( image ) .AND. !Empty( icon )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + ". Either bitmap or icon must be specified." )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   cPicture := IFEMPTY( icon, image, icon )
   IF ValType( cPicture ) == "A"
      image := cPicture [1]
   ENDIF

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := BS_NOTIFY + BS_BITMAP + WS_CHILD + BS_PUSHBUTTON
      IF flat
         style += BS_FLAT
      ENDIF
      IF !NoTabStop
         style += WS_TABSTOP
      ENDIF
      IF !invisible
         style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,ToolTip,FontName,FontSize,bold,italic,,}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogButtonImage( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, caption, HelpId, tooltip, , , , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         SetWindowStyle ( ControlHandle, style, .T. )

         _SetBtnPicture( ControlHandle, image )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      aRet := InitImageButton ( ParentFormHandle, Caption, 0, x, y, w, h, image, flat, notrans, invisible, notabstop, default, icon, extract, nIdx, ( _HMG_IsThemed .AND. !noxpstyle ) )

      ControlHandle := aRet [1]
      nhImage := aRet [2]

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] :=  "BUTTON"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlIds [k] :=  nId
   _HMG_aControlProcedures [k] :=  ProcedureName
   _HMG_aControlPageMap [k] :=  {}
   _HMG_aControlValue [k] :=  Nil
   _HMG_aControlInputMask [k] :=  iif ( ISCHARACTER( key ), key, "" )
   _HMG_aControllostFocusProcedure [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure [k] :=  gotfocus
   _HMG_aControlChangeProcedure [k] :=  ""
   _HMG_aControlDeleted [k] :=  FALSE
   _HMG_aControlBkColor [k] :=  Nil
   _HMG_aControlFontColor [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  noxpstyle
   _HMG_aControlHeadClick [k] :=  {}
   _HMG_aControlRow [k] :=   y
   _HMG_aControlCol [k] :=   x
   _HMG_aControlWidth [k] :=   w
   _HMG_aControlHeight [k] :=   h
   _HMG_aControlSpacing [k] :=   0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture [k] :=   cPicture
   _HMG_aControlContainerHandle [k] :=   0
   _HMG_aControlFontName [k] :=   ''
   _HMG_aControlFontSize [k] :=   0
   _HMG_aControlFontAttributes [k] :=   { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip [k] :=    tooltip
   _HMG_aControlRangeMin [k] :=   0
   _HMG_aControlRangeMax [k] :=   0
   _HMG_aControlCaption [k] :=    Caption
   _HMG_aControlVisible [k] :=    iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId [k] :=    HelpId
   _HMG_aControlFontHandle [k] :=  0
   _HMG_aControlBrushHandle [k] := nhImage
   _HMG_aControlEnabled [k] :=   .T.
   _HMG_aControlMiscData1 [k] := IFEMPTY( icon, 0, 1 )  // 0 - bitmap  1 - icon
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      _SetHotKeyByName ( ParentFormName , key , ProcedureName )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogButtonImage( ParentFormName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL image

   image := _HMG_aControlPicture  [k]
   IF !Empty( image ) .AND. ValType( ParentFormName ) <> 'U'
      _SetBtnPicture( ControlHandle, image )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil
