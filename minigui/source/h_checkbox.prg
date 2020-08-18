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
   Copyright 1999-2020, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION _DefineCheckBox ( ControlName, ParentFormName, x, y, Caption, Value, ;
      fontname, fontsize, tooltip, changeprocedure, w, h, lostfocus, gotfocus, ;
      HelpId, invisible, notabstop, bold, italic, underline, strikeout, field, ;
      backcolor, fontcolor, transparent, leftjustify, threestate, Enter, autosize, multiline, nId, bInit )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle , FontHandle
   LOCAL WorkArea
   LOCAL mVar
   LOCAL k
   LOCAL Style
   LOCAL blInit
   LOCAL lDialogInMemory
   LOCAL oc := NIL, ow := NIL
#ifdef _OBJECT_
   ow := oDlu2Pixel()
#endif

   hb_default( @w, 100 )
   hb_default( @h, 28 )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @changeprocedure, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @transparent, .F. )
   hb_default( @leftjustify, .F. )
   hb_default( @multiline, .F. )
   hb_default( @threestate, .F. )
   IF .NOT. threestate
      hb_default( @value, .F. )
   ENDIF
   hb_default( @autosize, .F. )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF ValType ( Field ) != 'U'
      IF At ( '>', Field ) == 0
         MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " : You must specify a fully qualified field name." )
      ELSE
         WorkArea := Left ( Field , At ( '>', Field ) - 2 )
         IF Select ( WorkArea ) != 0
            Value := &( Field )
         ENDIF
      ENDIF
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x    := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y    := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF transparent .AND. _HMG_FrameLevel == 0 .AND. _HMG_IsThemed // Fixed for transparent problem at themed WinXP and later
      transparent := .F.
      mVar := _HMG_aFormBkColor [ GetFormIndex ( ParentFormName ) ]
      IF backcolor == NIL .AND. mVar [1] < 0 .AND. mVar [2] < 0 .AND. mVar [3] < 0
         k := GetSysColor( COLOR_BTNFACE )
         backcolor := nRGB2Arr( k )
      ELSE
         backcolor := mVar
      ENDIF
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle
      Style := BS_NOTIFY + WS_CHILD  // + BS_LEFT

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF
      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF threestate
         Style += BS_AUTO3STATE
      ELSE
         Style += BS_AUTOCHECKBOX
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //           {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogCheckButton( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, caption, HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         IF ValType( caption ) != "U"
            SetWindowText ( ControlHandle , caption )
         ENDIF

         SetWindowStyle ( ControlHandle, Style, .T. )
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )
      Controlhandle := InitCheckBox ( ParentFormHandle, Caption, 0, x, y, multiline, threestate, w, h, invisible, notabstop, leftjustify, transparent )

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

      IF _HMG_IsThemed .AND. IsArrayRGB ( fontcolor )
         SetWindowTheme ( ControlHandle, "", "" )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "CHECKBOX"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlIds [k] :=  nId
   _HMG_aControlProcedures [k] :=  Enter
   _HMG_aControlPageMap [k] :=  Field
   _HMG_aControlValue [k] :=  Value
   _HMG_aControlInputMask [k] :=  transparent
   _HMG_aControllostFocusProcedure [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure [k] :=  gotfocus
   _HMG_aControlChangeProcedure [k] :=  changeprocedure
   _HMG_aControlDeleted [k] :=  .F.
   _HMG_aControlBkColor [k] :=  backcolor
   _HMG_aControlFontColor [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  _HMG_ActiveTabButtons
   _HMG_aControlHeadClick [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight [k] :=  h
   _HMG_aControlSpacing  [k] :=  threestate
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=  tooltip
   _HMG_aControlRangeMin [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveTabName , '' )
   _HMG_aControlRangeMax [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameParentFormName [_HMG_FrameLevel] , '' )
   _HMG_aControlCaption  [k] :=  Caption
   _HMG_aControlVisible  [k] :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      IF threestate .AND. value == NIL
         SendMessage( Controlhandle , BM_SETCHECK , BST_INDETERMINATE , 0 )
      ELSEIF value == .T.
         SendMessage( Controlhandle , BM_SETCHECK , BST_CHECKED , 0 )
      ENDIF
      IF autosize == .T.
         _SetControlWidth ( ControlName , ParentFormName , GetTextWidth( NIL, Caption, FontHandle ) + ;
            iif( bold == .T. .OR. italic == .T., GetTextWidth( NIL, " ", FontHandle ), 0 ) + 20 )
         _SetControlHeight ( ControlName , ParentFormName , FontSize + iif( FontSize < 14, 12, 16 ) )
         RedrawWindow ( ControlHandle )
      ENDIF
   ENDIF

   IF ValType ( Field ) != 'U'
      AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentFormName ) ] , k )
   ENDIF

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
#ifdef _OBJECT_
      ow := _WindowObj ( ParentFormHandle )
      oc := _ControlObj( ControlHandle )
#endif
   ENDIF

   Do_ControlEventProcedure ( bInit, k, ow, oc )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineCheckButton ( ControlName, ParentFormName, x, y, Caption, Value, ;
      fontname, fontsize, tooltip, changeprocedure, ;
      w, h, lostfocus, gotfocus, HelpId, invisible, ;
      notabstop , bold, italic, underline, strikeout, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle , FontHandle
   LOCAL mVar
   LOCAL k
   LOCAL Style
   LOCAL blInit
   LOCAL lDialogInMemory

   hb_default( @value, .F. )
   hb_default( @w, 100 )
   hb_default( @h, 28 )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @changeprocedure, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF
   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x    := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y    := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
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

      Style := BS_NOTIFY + WS_CHILD + BS_AUTOCHECKBOX + BS_PUSHLIKE

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{ID,k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogCheckButton( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         SetWindowStyle ( ControlHandle, Style, .T. )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      Controlhandle := InitCheckButton ( ParentFormHandle, Caption, 0, x, y, '', 0, w, h, invisible, notabstop )

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

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "CHECKBOX"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlIds [k] :=   nId
   _HMG_aControlProcedures [k] :=   ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask   [k] := ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  changeprocedure
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor   [k] := Nil
   _HMG_aControlFontColor   [k] := Nil
   _HMG_aControlDblClick   [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := .F.
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName   [k] := fontname
   _HMG_aControlFontSize   [k] := fontsize
   _HMG_aControlFontAttributes   [k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=   tooltip
   _HMG_aControlRangeMin   [k] :=  0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption   [k] :=  Caption
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle   [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 2
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF value == .T. .AND. .NOT. lDialogInMemory
      SendMessage( Controlhandle , BM_SETCHECK , BST_CHECKED , 0 )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogCheckButton ( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL Value , BitMap , threestate

   BitMap := _HMG_aControlPicture [k]
   Value := _HMG_aControlValue [k]
   threestate := _HMG_aControlSpacing [k]
   IF !Empty( BitMap ) .AND. ValType( ParentName ) <> 'U'
      _SetBtnPicture( ControlHandle, BitMap )
   ENDIF
   IF value == .T.
      SendMessage( Controlhandle , BM_SETCHECK , BST_CHECKED , 0 )
   ELSEIF threestate .AND. value == NIL
      SendMessage( Controlhandle , BM_SETCHECK , BST_INDETERMINATE , 0 )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineImageCheckButton ( ControlName, ParentFormName, x, y, BitMap, ;
      Value, fontname, fontsize, tooltip, ;
      changeprocedure, w, h, lostfocus, gotfocus, ;
      HelpId, invisible, notabstop, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , ControlHandle
   LOCAL aRet
   LOCAL nhImage
   LOCAL mVar
   LOCAL k
   LOCAL Style
   LOCAL blInit
   LOCAL lDialogInMemory

   hb_default( @value, .F. )
   hb_default( @w, 100 )
   hb_default( @h, 28 )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @changeprocedure, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF
   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x    := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y    := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
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

      Style := BS_NOTIFY + BS_BITMAP + WS_CHILD + BS_AUTOCHECKBOX + BS_PUSHLIKE
      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF
      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template
         //          {{ID,k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogCheckButton( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )
      ELSE
         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         SetWindowStyle ( ControlHandle, Style, .T. )

         _SetBtnPicture( ControlHandle, bitmap )
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      aRet := InitImageCheckButton ( ParentFormHandle, "", 0, x, y, '', 1, bitmap, w, h, invisible, notabstop, _HMG_IsThemed )

      ControlHandle := aRet[1]
      nhImage := aRet[2]

   ENDIF

   IF .NOT. lDialogInMemory
      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "CHECKBOX"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlIds [k] :=   nId
   _HMG_aControlProcedures [k] :=   ""
   _HMG_aControlPageMap [k] :=   {}
   _HMG_aControlValue [k] :=   Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  changeprocedure
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow   [k] :=  y
   _HMG_aControlCol   [k] :=  x
   _HMG_aControlWidth   [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing [k] :=  .F.
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  BitMap
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip  [k] :=   tooltip
   _HMG_aControlRangeMin   [k] :=  0
   _HMG_aControlRangeMax   [k] :=  0
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   0
   _HMG_aControlBrushHandle  [k] :=  nhImage
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 1
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF value == .T. .AND. .NOT. lDialogInMemory
      SendMessage( Controlhandle , BM_SETCHECK , BST_CHECKED , 0 )
   ENDIF

RETURN Nil
