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

#include "i_winuser.ch"
#include "minigui.ch"

#define BP_PUSHBUTTON 1

#define PBS_NORMAL 1
#define PBS_HOT 2
#define PBS_PRESSED 3
#define PBS_DISABLED 4
#define PBS_DEFAULTED 5

#define DT_TOP 0
#define DT_LEFT 0
#define DT_CENTER 1
#define DT_RIGHT 2
#define DT_VCENTER 4
#define DT_BOTTOM 8
#define DT_SINGLELINE 32

/* Aspects for owner buttons */
#define OBT_HORIZONTAL    0
#define OBT_VERTICAL      1
#define OBT_LEFTTEXT      2
#define OBT_UPTEXT        4
#define OBT_HOTLIGHT      8
#define OBT_FLAT          16
#define OBT_NOTRANSPARENT 32
#define OBT_NOXPSTYLE     64
#define OBT_ADJUST       128

STATIC lXPThemeActive  := .F.
STATIC lDialogInMemory := .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineButton ( ControlName, ParentFormName, x, y, Caption, ;
   ProcedureName, w, h, fontname, fontsize, tooltip, gotfocus, lostfocus, flat, NoTabStop, HelpId, ;
   invisible, bold, italic, underline, strikeout, multiline, default, key, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , ControlHandle , blInit , FontHandle , k , Style

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
            FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
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
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
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
   LOCAL ParentFormHandle , mVar , ControlHandle , blInit , k , Style
   LOCAL nhImage , cPicture , aRet

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

*-----------------------------------------------------------------------------*
FUNCTION _DefineOwnerButton ( ControlName, ParentForm, x, y, Caption, ;
   ProcedureName, w, h, image, tooltip, gotfocus, lostfocus, flat, notrans, HelpId, ;
   invisible, notabstop, default, icon, fontname, fontsize, bold, italic, underline, ;
   strikeout, lvertical, lefttext, uptext, aRGB_bk, aRGB_font, lnohotlight, lnoxpstyle, ;
   ladjust, handcursor, imagewidth, imageheight, aGradInfo, lhorizontal )
*-----------------------------------------------------------------------------*
   LOCAL cParentForm , mVar , ControlHandle , k
   LOCAL cPicture , FontHandle , aRet

   hb_default( @w, 100 )
   hb_default( @h, 28 )
   hb_default( @Caption, "" )
   hb_default( @flat, .F. )
   hb_default( @notrans, .F. )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @lvertical, .F. )
   hb_default( @lefttext, .F. )
   hb_default( @uptext, .F. )
   hb_default( @lnohotlight, .F. )
   hb_default( @lnoxpstyle, .F. )
   hb_default( @ladjust, .F. )
   hb_default( @imagewidth, -1 )
   hb_default( @imageheight, -1 )

   IF ladjust  // ignore CAPTION clause when ADJUST is defined
      Caption := ""
   ENDIF

   IF _HMG_ToolBarActive
      RETURN Nil
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentForm := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentForm := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError ( "Window: " + IFNIL( ParentForm, "Parent", ParentForm ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   IF !Empty( image ) .AND. !Empty( icon )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + ". Either bitmap or icon must be specified." )
   ENDIF

   cPicture := IFEMPTY( icon, image, icon )
   IF ValType( cPicture ) == "A"
      image := cPicture [1]
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   aRet := InitOwnerButton ( ParentForm, Caption, 0, x, y, w, h, image, flat, notrans, invisible, notabstop, default, icon, imagewidth, imageheight )

   ControlHandle := aRet [1]

   IF !Empty( image ) .AND. Empty( aRet [2] )
      aRet [2] := iif( _HMG_IsThemed .AND. At ( ".", image ) == 0 .AND. imagewidth < 0 .AND. imageheight < 0, ;
         C_GetResPicture ( image ), _SetBtnPicture ( ControlHandle, image, imagewidth, imageheight ) )
   ENDIF

   IF FontHandle != 0
      _SetFontHandle( ControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )
      FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] :=  "OBUTTON"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentForm
   _HMG_aControlIds [k] :=   0
   _HMG_aControlProcedures [k] :=   ProcedureName
   _HMG_aControlPageMap [k] :=   {}
   _HMG_aControlValue [k] :=   aGradInfo
   _HMG_aControlInputMask [k] :=   hb_defaultValue( handcursor, .F. )
   _HMG_aControllostFocusProcedure [k] :=   lostfocus
   _HMG_aControlGotFocusProcedure [k] :=   gotfocus
   _HMG_aControlChangeProcedure [k] :=   ""
   _HMG_aControlDeleted [k]   :=   FALSE
   _HMG_aControlBkColor  [k] :=  aRGB_bk
   _HMG_aControlFontColor  [k] :=  aRGB_font
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick [k] :=  { imagewidth, imageheight }
   _HMG_aControlRow [k]       :=  y
   _HMG_aControlCol [k]       :=  x
   _HMG_aControlWidth [k]     :=  w
   _HMG_aControlHeight [k]    :=  h
   _HMG_aControlSpacing [k]   :=  iif( lvertical, 1, 0 ) + iif( lefttext, OBT_LEFTTEXT, 0 ) + iif( uptext, OBT_UPTEXT, 0 ) + iif( !lnohotlight, OBT_HOTLIGHT, 0 ) + iif( flat, OBT_FLAT, 0 ) + iif( notrans, OBT_NOTRANSPARENT, 0 ) + iif( lnoxpstyle, OBT_NOXPSTYLE, 0 ) + iif( ladjust, OBT_ADJUST, 0 )
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture [k]      :=   cPicture
   _HMG_aControlContainerHandle [k] :=   0
   _HMG_aControlFontName [k]    := fontname
   _HMG_aControlFontSize [k]    := fontsize
   _HMG_aControlFontAttributes[k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip [k]     :=  tooltip
   _HMG_aControlRangeMin [k]    :=  hb_defaultValue( lhorizontal, .F. )
   _HMG_aControlRangeMax [k]    :=  iif( lnohotlight, 2, 0 )   // used for mouse hot tracking !!
   _HMG_aControlCaption [k]     :=  Caption
   _HMG_aControlVisible [k]     :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId [k]      :=  HelpId
   _HMG_aControlFontHandle [k]  :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  aRet [2]  // handle to an Image (Icon or Bitmap)
   _HMG_aControlEnabled [k]     :=  .T.
   _HMG_aControlMiscData1 [k]   :=  IFEMPTY( icon, 0, 1 )  // 0 - bitmap  1 - icon
   _HMG_aControlMiscData2 [k]   :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

RETURN Nil

// HMG 1.0 Experimental Build 9a (JK)
*-----------------------------------------------------------------------------*
FUNCTION OBTNEVENTS( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL i := AScan ( _HMG_aControlHandles, hWnd )

   HB_SYMBOL_UNUSED( wParam )
   HB_SYMBOL_UNUSED( lParam )

   IF i > 0 .AND. _HMG_aControlType [i] == "OBUTTON"

      SWITCH nMsg

      CASE WM_MOUSEMOVE

         IF _HMG_aControlInputMask [i]
            RC_CURSOR( "MINIGUI_FINGER" )
         ENDIF

         IF AND( _HMG_aControlSpacing [i], OBT_HOTLIGHT ) == OBT_HOTLIGHT .OR. _HMG_IsThemed

            _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )

            IF _HMG_aControlRangeMax [i] == 0
               InvalidateRect( hWnd, 0 )
               _HMG_aControlRangeMax [i] := 1
            ENDIF

         ENDIF
         EXIT

      CASE WM_MOUSELEAVE

         _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )

         IF AND( _HMG_aControlSpacing [i], OBT_HOTLIGHT ) == OBT_HOTLIGHT .OR. lXPThemeActive

            IF _HMG_aControlRangeMax [i] == 1
               _HMG_aControlRangeMax [i] := 0
               InvalidateRect( hWnd, 0 )
            ENDIF

         ENDIF

      ENDSWITCH

   ENDIF

RETURN 0

// HMG 1.0 Experimental Build 9a (JK)
// (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
*-----------------------------------------------------------------------------*
FUNCTION OwnButtonPaint( pdis )
*-----------------------------------------------------------------------------*
   LOCAL hDC, itemState, itemAction, i, rgbTrans, hWnd, lFlat, lNotrans
   LOCAL oldBkMode, oldTextColor, hOldFont, hBrush, nFreeSpace
   LOCAL x1, y1, x2, y2, xp1, yp1, xp2, yp2
   LOCAL aBmp := {}, aMetr, aBtnRc, aBtnClipRc, aDarkColor
   LOCAL lDisabled, lSelected, lFocus, lDrawEntire, loFocus, loSelect
   LOCAL hTheme, nStyle, lnoxpstyle, lXPThemeActive := .F.
   LOCAL pozYpic, pozYtext := 0, xPoz, nCRLF
   LOCAL lGradient, aGradient, lvertical

   hDC := GETOWNBTNDC( pdis )

   IF Empty( hDC ) .OR. GETOWNBTNCTLTYPE( pdis ) <> ODT_BUTTON
      RETURN ( 1 )
   ENDIF

   itemAction := GETOWNBTNITEMACTION ( pdis )
   lDrawEntire := ( AND( itemAction, ODA_DRAWENTIRE ) == ODA_DRAWENTIRE )
   loFocus := ( AND( itemAction, ODA_FOCUS ) == ODA_FOCUS )
   loSelect := ( AND( itemAction, ODA_SELECT ) == ODA_SELECT )

   IF ! lDrawEntire .AND. ! loFocus .AND. ! loSelect
      RETURN ( 1 )
   ENDIF

   hWnd := GETOWNBTNHANDLE( pdis )
   aBtnRc := GETOWNBTNRECT( pdis )
   itemState := GETOWNBTNSTATE( pdis )

   i := AScan ( _HMG_aControlHandles , hWnd )

   IF ( i <= 0 .OR. _HMG_aControlType[ i ] <> "OBUTTON" )
      RETURN ( 1 )
   ENDIF

   nCRLF := CountIt( _HMG_aControlCaption[ i ] ) + 1
   lDisabled := AND( itemState, ODS_DISABLED ) == ODS_DISABLED
   lSelected := AND( itemState, ODS_SELECTED ) == ODS_SELECTED
   lFocus := AND( itemState, ODS_FOCUS ) == ODS_FOCUS
   lFlat := AND( _HMG_aControlSpacing [ i ], OBT_FLAT ) == OBT_FLAT
   lNotrans := AND( _HMG_aControlSpacing [ i ], OBT_NOTRANSPARENT ) == OBT_NOTRANSPARENT
   lnoxpstyle := AND( _HMG_aControlSpacing [ i ], OBT_NOXPSTYLE ) == OBT_NOXPSTYLE

   IF ! lNotrans
      rgbTrans := NIL
   ELSE

      IF IsArrayRGB( _HMG_aControlBkColor [ i ] ) .AND. ! lXPThemeActive
         rgbTrans := RGB( _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] )
      ELSE
         rgbTrans := GetSysColor ( COLOR_BTNFACE )
      ENDIF

   ENDIF

   aGradient := _HMG_aControlValue [i]
   lGradient := ( ISARRAY( aGradient ) .AND. ! Empty( _HMG_aControlBkColor [i] ) )
   lvertical := ( _HMG_aControlRangeMin [i] == .F. )

   IF ! lnoxpstyle .AND. _HMG_IsThemed .AND. ! lGradient

      lXPThemeActive := .T.

      nStyle := PBS_NORMAL

      IF AND( itemState, ODS_HOTLIGHT ) == ODS_HOTLIGHT .OR. _HMG_aControlRangeMax [ i ] == 1
         nStyle := PBS_HOT
      ELSEIF lFocus
         nStyle := PBS_DEFAULTED
      ENDIF

      IF lDisabled
         nStyle := PBS_DISABLED
      ENDIF

      IF lSelected
         nStyle := PBS_PRESSED
      ENDIF

      aBtnClipRc := AClone( aBtnRc )
      aBtnClipRc[ 3 ] += 1
      aBtnClipRc[ 4 ] += 1

      hTheme := OpenThemeData( hWnd, ToUnicode( "BUTTON" ) )
      DrawThemeBackground( hTheme, hDC, BP_PUSHBUTTON, nStyle, aBtnRc, aBtnClipRc )
      CloseThemeData( hTheme )

   ELSE

      DrawButton( hDC, iif( lFocus .OR. _HMG_aControlRangeMax [ i ] == 1, 1, 0 ), ;
         DFCS_BUTTONPUSH + iif( lSelected, DFCS_PUSHED, 0 ) + iif( lDisabled, DFCS_INACTIVE, 0 ) + iif( lflat, DFCS_FLAT, 0 ), ;
         pdis, iif( AND( _HMG_aControlSpacing [ i ], OBT_HOTLIGHT ) == OBT_HOTLIGHT, _HMG_aControlRangeMax [ i ], 2 ), iif( lflat, 1, 0 ) )

   ENDIF

   hOldFont := SelectObject( hDC, _HMG_aControlFontHandle [ i ] )
   aMetr := GetTextMetric( hDC )
   oldBkMode := SetBkMode( hDC, TRANSPARENT )
   oldTextColor := SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ), GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ), GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )

   IF ! lDisabled

      IF Empty( _HMG_aControlFontColor [ i ] )
         SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ), GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ), GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      ELSE
         SetTextColor( hDC, _HMG_aControlFontColor [ i, 1 ], _HMG_aControlFontColor [ i, 2 ], _HMG_aControlFontColor [ i, 3 ] )
      ENDIF

      IF ! Empty( _HMG_aControlBkColor [ i ] ) .AND. ! lXPThemeActive

         xp1 := aBtnRc[ 1 ]
         xp2 := aBtnRc[ 2 ]
         yp1 := aBtnRc[ 3 ]
         yp2 := aBtnRc[ 4 ]

         // paint button background

         IF lGradient

            IF Len( aGradient [ 1 ] ) == 2
               ReplaceGradInfo( aGradient, 1, 1 )
               ReplaceGradInfo( aGradient, 1, 2 )
            ENDIF

            IF lSelected 
               IF Len( aGradient [ 1 ] ) == 3
                  IF IsArrayRGB( _HMG_aControlBkColor [ i ] ) .AND. ValType( _HMG_aControlBkColor [ i, 1 ] ) == "N"
                     _HMG_aControlBkColor [ i ] := { { 1, _HMG_aControlBkColor [ i ], Darker( _HMG_aControlBkColor [ i ], 82 ) } }
                  ENDIF
                  _GradientFill( hDC, xp2 + 2, xp1 + 2, yp2 - 2, yp1 - 2, _HMG_aControlBkColor [ i ], lvertical )
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 2, yp2 - 2, aGradient [ 1 ][ 2 ], aGradient [ 1 ][ 1 ] )
                  FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 2, yp2 - 2, hBrush )
                  DeleteObject( hBrush )
               ENDIF
            ELSEIF ! ( _HMG_aControlRangeMax [ i ] == 1 )
               IF Len( aGradient [ 1 ] ) == 3
                  _GradientFill( hDC, xp2 + 1, xp1 + 1, yp2 - 1, yp1 - 1, aGradient, lvertical )
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 1, yp2 - 1, aGradient [ 1 ][ 1 ], aGradient [ 1 ][ 2 ] )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
                  DeleteObject( hBrush )
               ENDIF
            ELSE
               IF Len( aGradient [ 1 ] ) == 3
                  _GradientFill( hDC, xp2 + 1, xp1 + 1, yp2 - 1, yp1 - 1, iif( Len( aGradient ) == 1, ;
                     InvertGradInfo( aGradient ), ModifGradInfo( aGradient ) ), lvertical )
               ELSE
                  hBrush := CreateButtonBrush( hDC, yp1 - 1, yp2 - 1, aGradient [ 1 ][ 2 ], aGradient [ 1 ][ 1 ] )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
                  DeleteObject( hBrush )
               ENDIF
            ENDIF

         ELSE

            IF lSelected
               aDarkColor := Darker( { _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] }, 97 )
            ELSE
               aDarkColor := { _HMG_aControlBkColor [ i, 1 ], _HMG_aControlBkColor [ i, 2 ], _HMG_aControlBkColor [ i, 3 ] }
            ENDIF

            hBrush := CreateSolidBrush( aDarkColor [1], aDarkColor [2], aDarkColor [3] )
            IF lflat
               IF ! lfocus .AND. ! lSelected .AND. ! ( _HMG_aControlRangeMax [ i ] == 1 )
                  FillRect( hDC, xp1 + 1, xp2 + 1, yp1 - 1, yp2 - 1, hBrush )
               ELSE
                  FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 2, yp2 - 2, hBrush )
               ENDIF
            ELSE
               FillRect( hDC, xp1 + 2, xp2 + 2, yp1 - 3, yp2 - 3, hBrush )
            ENDIF
            DeleteObject( hBrush )

         ENDIF

      ENDIF

   ENDIF

   IF ! Empty( _HMG_aControlBrushHandle [ i ] )
      SWITCH _HMG_aControlMiscData1 [ i ]
      CASE 0
         aBmp := GetBitmapSize( _HMG_aControlBrushHandle [ i ] )
         EXIT
      CASE 1
         aBmp := GetIconSize( _HMG_aControlBrushHandle [ i ] )
      ENDSWITCH
   ENDIF

   IF AND( _HMG_aControlSpacing [ i ], OBT_VERTICAL ) == OBT_VERTICAL  // vertical text/picture aspect

      y2 := aMetr[ 1 ] * nCRLF
      x2 := aBtnRc[ 3 ] - 2

      xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
      yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
      xp1 := Round( ( aBtnRc[ 3 ] / 2 ) - ( xp2 / 2 ), 0 )

      IF At( CRLF, _HMG_aControlCaption[ i ] ) <= 0
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( aMetr[ 4 ] + yp2 ) ) / 3, 0 )
         nCRLF := 1
      ELSE
         nFreeSpace := Round( ( aBtnRc[ 4 ] - 4 - ( y2 + yp2 ) ) / 3, 0 )
      ENDIF

      IF ! Empty( _HMG_aControlCaption[ i ] )  // button has caption

         IF ! Empty( _HMG_aControlBrushHandle [ i ] )
            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_UPTEXT ) == OBT_UPTEXT )  // upper text aspect not set
               pozYpic := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               pozYtext := aBtnRc[ 2 ] + iif( ! Empty( aBmp ), nFreeSpace, 0 ) + yp2 + iif( ! Empty( aBmp ), nFreeSpace, 0 )
            ELSE
               pozYtext := Max( aBtnRc[ 2 ] + nFreeSpace, 5 )
               aBtnRc[ 4 ] := nFreeSpace + ( ( aMetr[ 1 ] ) * nCRLF ) + nFreeSpace
               pozYpic := aBtnRc[ 4 ]
            ENDIF
         ELSE
            pozYpic := 0
            pozYtext := Round( ( aBtnRc[ 4 ] - y2 ) / 2, 0 )
         ENDIF

      ELSE  // button without caption

         IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
            pozYpic := Round( ( ( aBtnRc[ 4 ] / 2 ) - ( yp2 / 2 ) ), 0 )
            pozYtext := 0
         ELSE  // strech image
            pozYpic := 1
         ENDIF

      ENDIF

      IF ! lDisabled

         IF lSelected  // vertical selected

            IF ! lXPThemeActive
               xp1 ++
               xPoz := 2
               pozYtext ++
               pozYpic ++
            ELSE
               xPoz := 0
            ENDIF

            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic , xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], xPoz , pozYtext - 1 , x2, aBtnRc[ 4 ], DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ELSE  // vertical non selected

            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ],  0 , pozYtext - 1 , x2, aBtnRc[ 4 ], DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ENDIF

      ELSE  // vertical disabled

         IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
            DrawGlyph( hDC, xp1, pozYpic, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .T. , .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 2, pozYtext + 1 , x2, aBtnRc[ 4 ] + 1, DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], 0, pozYtext, x2, aBtnRc[ 4 ], DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .T. , .T. )
         ENDIF

      ENDIF

   ELSE

      y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
      y2 := y1 + aMetr[ 1 ]
      x2 := aBtnRc[ 3 ] - 2

      IF ! Empty( _HMG_aControlBrushHandle [ i ] ) // horizontal

         xp2 := iif( ! Empty( aBmp ), aBmp[ 1 ], 0 ) // picture width
         yp2 := iif( ! Empty( aBmp ), aBmp[ 2 ], 0 ) // picture height
         yp1 := Round( aBtnRc[ 4 ] / 2 - yp2 / 2, 0 )

         IF ! Empty( _HMG_aControlCaption[ i ] )

            lDrawEntire := ( aBtnRc[ 3 ] > 109 ) .AND. ( aBtnRc[ 4 ] - yp2 > 16 )
            nStyle := xp2 / 2 - iif( xp2 > 24, 8, 0 )

            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_LEFTTEXT ) == OBT_LEFTTEXT )

               xp1 := 5 + iif( lDrawEntire, nStyle, 0 )
               x1 := aBtnRc[ 1 ] + xp1 + xp2

            ELSE

               xp1 := aBtnRc[ 3 ] - xp2 - 5 - iif( lDrawEntire, nStyle, 0 )
               x1 := 3
               x2 := aBtnRc[ 3 ] - xp2 - iif( lDrawEntire, xp2 / 2 + 5, 0 )

            ENDIF

         ELSE

            xp1 := Round( aBtnRc[ 3 ] / 2 - xp2 / 2, 0 )
            x1 := aBtnRc[ 1 ]

         ENDIF

      ELSE

         xp1 := 2
         xp2 := 0
         yp1 := 0
         yp2 := 0

         x1 := aBtnRc[ 1 ] + xp1

      ENDIF

      IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
         y1 := Max( ( ( aBtnRc[ 4 ] / 2 ) - ( nCRLF * aMetr[ 1 ] ) / 2 ) - 1, 1 )
         y2 := ( aMetr[ 1 ] + aMetr[ 5 ] ) * nCRLF
      ENDIF

      IF ! lDisabled

         IF lSelected

            IF ! lXPThemeActive
               x1 += 2
               xp1 ++
               yp1 ++
            ENDIF

            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans, .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1 + 1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 4, aBtnRc[ 2 ] + 4 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF

         ELSE
            IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
               DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .F. )
               DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
            ELSE
               DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , rgbTrans , .F. , .T. )
            ENDIF
         ENDIF

      ELSE
         // disabled horizontal
         IF ! ( AND( _HMG_aControlSpacing [ i ], OBT_ADJUST ) == OBT_ADJUST )
            DrawGlyph( hDC, xp1, yp1, xp2, yp2 , _HMG_aControlBrushHandle [ i ] , , .T. , .F. )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetGreen ( GetSysColor ( COLOR_3DHILIGHT ) ) , GetBlue ( GetSysColor ( COLOR_3DHILIGHT ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1 + 1, y1 + 1, x2 + 1, y1 + y2 + 1, DT_CENTER )
            SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_3DSHADOW ) ) , GetGreen ( GetSysColor ( COLOR_3DSHADOW ) ) , GetBlue ( GetSysColor ( COLOR_3DSHADOW ) ) )
            DrawText( hDC, _HMG_aControlCaption[ i ], x1, y1, x2, y1 + y2, DT_CENTER )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + 3, aBtnRc[ 2 ] + 3 , aBtnRc[ 3 ] - 6, aBtnRc[ 4 ] - 6 , _HMG_aControlBrushHandle [ i ] , , .T. , .T. )
         ENDIF
      ENDIF
   ENDIF

   IF ( lSelected .OR. lFocus ) .AND. ! lDisabled .AND. ! lXPThemeActive
      SetTextColor( hDC, GetRed ( GetSysColor ( COLOR_BTNTEXT ) ) , GetGreen ( GetSysColor ( COLOR_BTNTEXT ) ) , GetBlue ( GetSysColor ( COLOR_BTNTEXT ) ) )
      DrawFocusRect( pdis )
   ENDIF

   SelectObject( hDC, hOldFont )
   SetBkMode( hDC, oldBkMode )
   SetTextColor( hDC, oldTextColor )

RETURN ( 1 )

*-----------------------------------------------------------------------------*
STATIC FUNCTION ToUnicode( cString )
*-----------------------------------------------------------------------------*
   LOCAL i, cTemp := ""

   FOR i := 1 TO Len( cString )
      cTemp += SubStr( cString, i, 1 ) + Chr( 0 )
   NEXT
   cTemp += Chr( 0 )

RETURN cTemp

*-----------------------------------------------------------------------------*
FUNCTION _SetBtnPictureMask( hWnd, ControlIndex )
*-----------------------------------------------------------------------------*
   LOCAL hDC := GetDC( hWnd ), aBMP
   LOCAL aBtnRc := Array( 4 )
   LOCAL i := ControlIndex
   LOCAL x, y

   IF Empty( hDC ) .OR. Empty( _HMG_aControlBrushHandle [i] )
      RETURN NIL
   ENDIF

   aBtnRc [1] := _HMG_aControlRow    [i]
   aBtnRc [2] := _HMG_aControlCol    [i]
   aBtnRc [3] := _HMG_aControlWidth  [i]
   aBtnRc [4] := _HMG_aControlHeight [i]

   aBmp := GetBitmapSize( _HMG_aControlBrushHandle [i] )
   x := aBtnRc [3] / 2 - aBmp [1] / 2
   y := aBtnRc [4] / 2 - aBmp [2] / 2

   DrawGlyphMask( hDC, x, y, aBmp [1], aBmp [2], _HMG_aControlBrushHandle [i], , .T. , .F. , hWnd )

   ReleaseDC( hWnd, hDC )

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _DestroyBtnPictureMask( hWnd, ControlIndex )
*-----------------------------------------------------------------------------*
   LOCAL MaskHwnd := _GetBtnPictureHandle( hWnd )

   IF ! Empty( MaskHwnd ) .AND. MaskHwnd <> _HMG_aControlBrushHandle [ ControlIndex ]
      DeleteObject( MaskHwnd )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _DestroyBtnPicture( hWnd, ControlIndex )
*-----------------------------------------------------------------------------*
   LOCAL BtnPicHwnd := _GetBtnPictureHandle( hWnd )

   IF ! Empty( BtnPicHwnd ) .AND. BtnPicHwnd == _HMG_aControlBrushHandle [ ControlIndex ]
      DeleteObject( BtnPicHwnd )
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION Darker( aColor, Percent )
*-----------------------------------------------------------------------------*
   LOCAL aDark := Array( 3 )

   Percent := Percent / 100

   aDark [1] := Round( aColor [1] * Percent, 0 )
   aDark [2] := Round( aColor [2] * Percent, 0 )
   aDark [3] := Round( aColor [3] * Percent, 0 )

RETURN aDark

*-----------------------------------------------------------------------------*
FUNCTION Lighter( aColor, Percent )
*-----------------------------------------------------------------------------*
   LOCAL Light, aLight := Array( 3 )

   Percent := Percent / 100
   Light := Round( 255 - Percent * 255, 0 )

   aLight [1] := Round( aColor [1] * Percent, 0 ) + Light
   aLight [2] := Round( aColor [2] * Percent, 0 ) + Light
   aLight [3] := Round( aColor [3] * Percent, 0 ) + Light

RETURN aLight

*-----------------------------------------------------------------------------*
STATIC FUNCTION CountIt( cText )
*-----------------------------------------------------------------------------*
   LOCAL nPoz, nCount := 0

   IF At( CRLF, cText ) > 0
      DO WHILE ( nPoz := At( CRLF, cText ) ) > 0
         nCount++
         cText := SubStr( cText, nPoz + 2 )
      ENDDO
   ENDIF

RETURN nCount

*-----------------------------------------------------------------------------*
STATIC FUNCTION InvertGradInfo( aGradInfo )
*-----------------------------------------------------------------------------*
   LOCAL aGradInvert := {}

   IF ! Empty( aGradInfo ) .AND. ValType( aGradInfo ) == "A"

      AEval( aGradInfo, { | x | AAdd( aGradInvert, { x[ 1 ], x[ 3 ], x[ 2 ] } ) } )

   ENDIF

RETURN aGradInvert

*-----------------------------------------------------------------------------*
STATIC FUNCTION ModifGradInfo( aGradInfo )
*-----------------------------------------------------------------------------*
   LOCAL nClr, aReturn := {}

   IF ! Empty( aGradInfo ) .AND. ValType( aGradInfo ) == "A"

      FOR nClr := 1 TO Len( aGradInfo )
         ReplaceGradInfo( aGradInfo, nClr, 2 )
         ReplaceGradInfo( aGradInfo, nClr, 3 )
      NEXT

      AEval( aGradInfo, { | x | AAdd( aReturn, { x[ 1 ], x[ 2 ] - 10, x[ 3 ] - 30 } ) } )

   ENDIF

RETURN aReturn

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ReplaceGradInfo( aGradInfo, nClr, nItem )
*-----------------------------------------------------------------------------*
   LOCAL aColor

   aColor := aGradInfo[ nClr ][ nItem ]
   IF IsArrayRGB( aColor )
      aGradInfo[ nClr ][ nItem ] := RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GradientFill( hDC, nTop, nLeft, nBottom, nRight, aGradInfo, lVertical )
*-----------------------------------------------------------------------------*
   LOCAL nClr, nClrs, nSize, nSlice

   IF ! Empty( aGradInfo ) .AND. ValType( aGradInfo ) == "A"

      nClrs := Len( aGradInfo )

      IF lVertical

         nSize := nBottom - nTop + 1

         FOR nClr := 1 TO nClrs

            nSlice = iif( nClr == nClrs, nBottom, ;
               Min( nBottom, nTop + nSize * aGradInfo[ nClr ][ 1 ] - 1 ) )

            ReplaceGradInfo( aGradInfo, nClr, 2 )
            ReplaceGradInfo( aGradInfo, nClr, 3 )

            FillGradient( hDC, nTop, nLeft, nSlice, nRight, .T., aGradInfo[ nClr ][ 2 ], aGradInfo[ nClr ][ 3 ] )

            nTop := nSlice - 1

            IF nTop > nBottom
               EXIT
            ENDIF

         NEXT

      ELSE

         nSize := nRight - nLeft + 1

         FOR nClr := 1 TO nClrs

            nSlice := iif( nClr == nClrs, nRight, ;
               Min( nRight, nLeft + nSize * aGradInfo[ nClr ][ 1 ] - 1 ) )

            ReplaceGradInfo( aGradInfo, nClr, 2 )
            ReplaceGradInfo( aGradInfo, nClr, 3 )

            FillGradient( hDC, nTop, nLeft, nBottom, nSlice, .F., aGradInfo[ nClr ][ 2 ], aGradInfo[ nClr ][ 3 ] )

            nLeft := nSlice - 1

            IF nLeft > nRight
               EXIT
            ENDIF

         NEXT

      ENDIF

   ENDIF

RETURN NIL
