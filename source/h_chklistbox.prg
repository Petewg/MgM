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
   Copyright 1999-2016, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION _DefineChkListbox ( ControlName, ParentFormName, x, y, w, h, arows, value, ;
      fontname, fontsize, tooltip, changeprocedure, dblclick, gotfocus, lostfocus, break, HelpId, ;
      invisible, notabstop, sort, bold, italic, underline, strikeout, backcolor, fontcolor, ;
      multiselect, aCheck, nItemHeight, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , blInit , mVar , ControlHandle , Style
   LOCAL FontHandle , rows := {} , i , k ,  aChkItem := {} , nPos
   LOCAL lDialogInMemory

   DEFAULT w               TO 120
   DEFAULT h               TO 120
   DEFAULT gotfocus        TO ""
   DEFAULT lostfocus       TO ""
   DEFAULT value           TO 0
   DEFAULT changeprocedure TO ""
   DEFAULT dblclick        TO ""
   DEFAULT invisible       TO FALSE
   DEFAULT notabstop       TO FALSE
   DEFAULT sort            TO FALSE
   DEFAULT aCheck          TO {}
   DEFAULT nItemHeight     TO 16

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF ! ISARRAY( arows )
      arows := {}
   ENDIF
   IF Len( arows ) > 0
      IF ! ISARRAY( arows[1] )
         rows := AClone( arows )
         AEval( arows, { |x, y| HB_SYMBOL_UNUSED( x ), nPos := y, AAdd( aChkItem, iif( AScan( aCheck, { |z| z == nPos } ) > 0, 2, 1) ) } )
      ELSE
         AEval( arows, { |x| AAdd( rows, x[1] ) } )
         AEval( arows, { |x, y| nPos := y, AAdd( aChkItem, iif( ValType( x[2] ) == 'L' .AND. x[2] .OR. AScan( aCheck, { |z| z == nPos } ) > 0, 2, 1) ) } )
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

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_BORDER + WS_CHILD + WS_VSCROLL + LBS_DISABLENOSCROLL + LBS_NOTIFY + LBS_NOINTEGRALHEIGHT

      IF multiselect
         Style += LBS_MULTIPLESEL
      ENDIF

      IF !notabstop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF sort
         Style += LBS_SORT
      ENDIF


      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogChkListBox( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "LISTBOX", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

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

      IF ValType( x ) == "U" .OR. ValType( y ) == "U"

         IF _HMG_SplitLastControl == "TOOLBAR"
            Break := .T.
         ENDIF

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            IF multiselect
               ControlHandle := InitMultiChkListBox ( _HMG_aFormReBarHandle [i], 0, x, y, w, h, fontname, fontsize, invisible, notabstop, sort, nItemHeight )
            ELSE
               ControlHandle := InitChkListBox ( _HMG_aFormReBarHandle [i] , 0 , 0 , 0 , w , h , '' , 0 , invisible , notabstop, sort, nItemHeight )
            ENDIF

            AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , , , , _HMG_ActiveSplitBoxInverted )

            _HMG_SplitLastControl := "LISTBOX"

         ENDIF

      ELSE

         IF multiselect
            ControlHandle := InitMultiChkListBox ( ParentFormHandle, 0, x, y, w, h, fontname, fontsize, invisible, notabstop, sort, nItemHeight )
         ELSE
            ControlHandle := InitChkListBox ( ParentFormHandle , 0 , x , y , w , h , '' , 0 , invisible, notabstop, sort, nItemHeight )
         ENDIF

      ENDIF

   ENDIF

   IF .NOT. lDialogInMemory

      IF FontHandle != 0
         _SetFontHandle( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := iif ( multiselect , "MULTICHKLIST" , "CHKLIST" )
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  ChangeProcedure
   _HMG_aControlDeleted  [k] :=  FALSE
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  dblclick
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] :=  nItemHeight
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture   [k] := ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  rows
   _HMG_aControlRangeMax  [k] :=   aCheck
   _HMG_aControlCaption   [k] :=  ""
   _HMG_aControlVisible  [k] :=   iif ( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := ''
   _HMG_aControlMiscData2 [k] := ''

   IF Len ( _HMG_aDialogTemplate ) == 0     //Dialog Template
      IF Len ( aRows ) > 0
         AEval ( Rows, { | r,n | ChkListboxAddItem ( ControlHandle, r, aChkItem[n], nItemHeight ) } )
      ENDIF

      IF FontSize != _HMG_DefaultFontSize .AND. Len ( Rows ) > 0
         SetChkLBItemHeight ( ControlHandle , FontHandle )
      ENDIF

      IF multiselect
         IF ISARRAY ( value )
            LISTBOXSETMULTISEL ( ControlHandle , Value )
         ENDIF
      ELSE
         IF ISNUMBER ( value ) .AND. value <> 0
            ListboxSetCurSel ( ControlHandle , Value )
         ENDIF
      ENDIF
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogChkListBox( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL Rows, Value, FontSize, FontHandle

   HB_SYMBOL_UNUSED( ParentName )

   Rows        := _HMG_aControlRangeMin [k]
   Value       := _HMG_aControlValue [k]
   FontSize    := _HMG_aControlFontSize  [k]
   FontHandle  := _HMG_aControlFontHandle  [k]

   IF Len ( Rows ) > 0
      AEval ( Rows , { | r | ListboxAddString ( ControlHandle , r ) } )
   ENDIF

   IF FontSize != _HMG_DefaultFontSize .AND. Len( Rows ) > 0
      SetChkLBItemHeight ( ControlHandle , FontHandle )
   ENDIF

   IF _HMG_aControlType [k] == "MULTICHKLIST"
      IF ISARRAY ( value )
         LISTBOXSETMULTISEL ( ControlHandle , Value )
      ENDIF
   ELSE
      IF ISNUMBER ( value ) .AND. value <> 0
         ListboxSetCurSel ( ControlHandle , Value )
      ENDIF
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate [3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetGetChkListItemState ( ControlName, ParentForm, Item, lState )
*-----------------------------------------------------------------------------*
   LOCAL RetVal As Logical
   LOCAL i, t, uSel

   i := GetControlIndex ( ControlName , ParentForm )
   IF i > 0
      T := _HMG_aControlType [i]
      IF "CHKLIST" $ T
         IF item > 0 .AND. item <= ListBoxGetItemCount ( _HMG_aControlHandles [i] )
            IF ISLOGICAL ( lState )
               IF T == "MULTICHKLIST"
                  uSel := ListBoxGetMultiSel ( _HMG_aControlHandles [i] )
               ELSE
                  uSel := ListBoxGetCursel ( _HMG_aControlHandles [i] )
               ENDIF
               ChkList_SetCheckBox ( _HMG_aControlHandles [i], Item, iif( lState, 2, 1 ) )
               IF T == "MULTICHKLIST"
                  ListBoxSetMultiSel ( _HMG_aControlHandles [i], uSel )
               ELSE
                  ListBoxSetCursel ( _HMG_aControlHandles [i], uSel )
               ENDIF
            ELSE
               RetVal := ChkList_GetCheckBox ( _HMG_aControlHandles [i], Item )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN RetVal
