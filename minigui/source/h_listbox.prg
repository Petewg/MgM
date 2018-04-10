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
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2018, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION _DefineListbox ( ControlName, ParentFormName, x, y, w, h, arows, value, ;
      fontname, fontsize, tooltip, changeprocedure, dblclick, gotfocus, lostfocus, break, HelpId, ;
      invisible, notabstop, sort, bold, italic, underline, strikeout, backcolor, fontcolor, ;
      multiselect, dragitems, multicolumn, multitabs, aWidth, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , blInit , mVar , ControlHandle , Style
   LOCAL FontHandle , rows , i , k
   LOCAL lDialogInMemory

   hb_default( @w, 120 )
   hb_default( @h, 120 )
   hb_default( @value, 0 )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @changeprocedure, "" )
   __defaultNIL( @dblclick, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @sort, .F. )
   hb_default( @multicolumn, .F. )
   hb_default( @multitabs, .F. )
   hb_default( @aWidth, {} )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   rows := iif( ISARRAY( arows ), AClone( arows ), {} )

   IF multitabs
      IF Len( rows ) > 0
         IF Len( aWidth ) == 0
            IF Valtype( rows[1] ) == 'A'
               FOR i:=1 TO Len( rows[1] )
                  AAdd( aWidth, Int( w / Len( rows[1] ) ) )
               NEXT
            ENDIF
         ENDIF
         FOR i:=1 TO Len( rows )
            IF Valtype( rows[i] ) == 'A'
               rows[i] := LB_Array2String( rows[i] )
            ENDIF
         NEXT
      ENDIF
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

      IF multicolumn
         Style += LBS_MULTICOLUMN
      ENDIF

      IF multitabs
         Style += LBS_USETABSTOPS
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogListBox( x, y, z ) }
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
               ControlHandle := InitMultiListBox ( _HMG_aFormReBarHandle [i], 0, x, y, w, h, fontname, fontsize, invisible, notabstop, sort, dragitems, multitabs, multicolumn )
            ELSE
               ControlHandle := InitListBox ( _HMG_aFormReBarHandle [i] , 0 , 0 , 0 , w , h , '' , 0 , invisible , notabstop, sort, dragitems, multitabs, multicolumn )
            ENDIF

            AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , , , , _HMG_ActiveSplitBoxInverted )

            _HMG_SplitLastControl := "LISTBOX"

         ENDIF

      ELSE

         IF multiselect
            ControlHandle := InitMultiListBox ( ParentFormHandle, 0, x, y, w, h, fontname, fontsize, invisible, notabstop, sort, dragitems, multitabs, multicolumn )
         ELSE
            ControlHandle := InitListBox ( ParentFormHandle , 0 , x , y , w , h , '' , 0 , invisible, notabstop, sort, dragitems, multitabs, multicolumn )
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

   _HMG_aControlType [k] := iif ( multiselect , "MULTILIST" , "LIST" )
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
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture   [k] := ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  rows
   _HMG_aControlRangeMax  [k] :=   aWidth
   _HMG_aControlCaption   [k] :=  ""
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { multicolumn, multitabs }
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF Len( _HMG_aDialogTemplate ) == 0        //Dialog Template

      AEval ( Rows , { | r | ListboxAddString ( ControlHandle , r ) } )
      IF multiselect
         IF ISARRAY ( value )
            LISTBOXSETMULTISEL ( ControlHandle , Value )
         ENDIF
      ELSE
         IF ISNUMBER ( value ) .AND. value <> 0
            ListboxSetCurSel ( ControlHandle , Value )
         ENDIF
      ENDIF
      IF multitabs
         LISTBOXSETMULTITAB ( ControlHandle , aWidth )
      ENDIF
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogListBox( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL Rows, Value, multitabs, aWidth

   HB_SYMBOL_UNUSED( ParentName )

   Rows   := _HMG_aControlRangeMin [k]
   Value  := _HMG_aControlValue [k]
   aWidth := _HMG_aControlRangeMax [k]
   multitabs := _HMG_aControlMiscData1 [k] [2]

   AEval ( Rows , { | r | ListboxAddString ( ControlHandle , r ) } )

   IF _HMG_aControlType [k] == "MULTILIST"
      IF ISARRAY ( value )
         LISTBOXSETMULTISEL ( ControlHandle , Value )
      ENDIF
   ELSE
      IF ISNUMBER ( value ) .AND. value <> 0
         ListboxSetCurSel ( ControlHandle , Value )
      ENDIF
   ENDIF
   IF multitabs
      LISTBOXSETMULTITAB ( ControlHandle , aWidth )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

   RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION LB_Array2String( aData, Sep )
*-----------------------------------------------------------------------------*
   LOCAL n, cData := ""

   DEFAULT Sep := Chr(9)

   FOR n := 1 TO Len( aData )
      cData += iif(n == 1, "", Sep) + aData [n]
   NEXT

RETURN cData
