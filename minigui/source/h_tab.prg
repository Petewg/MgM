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

STATIC lDialogInMemory := .F.

*-----------------------------------------------------------------------------*
FUNCTION _BeginTab( ControlName , ParentFormName , row , col , w , h , value , f , s , tooltip , change , buttons , flat , hottrack , vertical , bottom , notabstop , bold, italic, underline, strikeout, multiline , backcolor, nId )
*-----------------------------------------------------------------------------*
   LOCAL aMnemonic := Array( 16 )

   __defaultNIL( @change, "" )
   hb_default( @buttons, .F. )
   hb_default( @Flat, .F. )
   hb_default( @HotTrack, .F. )
   hb_default( @Vertical, .F. )
   hb_default( @bottom, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @multiline, .F. )

   IF _HMG_BeginTabActive
      MsgMiniGuiError( "DEFINE TAB Structures can't be nested." )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @f, _HMG_ActiveFontName )
      __defaultNIL( @s, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0
      col  := col + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      row  := row + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF ValType ( ParentFormName ) == 'U'
      ParentFormName := _HMG_ActiveFormName
   ENDIF

   IF ValType ( value ) == 'U' .OR. value < 1
      value := 1
   ENDIF

   _HMG_FrameLevel++

   _HMG_ActiveFrameParentFormName [_HMG_FrameLevel] := ParentFormName
   _HMG_ActiveFrameRow [_HMG_FrameLevel] := row
   _HMG_ActiveFrameCol [_HMG_FrameLevel] := col
   _HMG_BeginTabActive           := .T.
   _HMG_ActiveTabPage            := 0
   _HMG_ActiveTabFullPageMap     := {}
   _HMG_ActiveTabCaptions        := {}
   _HMG_ActiveTabImages          := {}
   _HMG_ActiveTabCurrentPageMap  := {}
   _HMG_ActiveTabName            := ControlName
   _HMG_ActiveTabParentFormName  := ParentFormName
   _HMG_ActiveTabRow             := row
   _HMG_ActiveTabCol             := col
   _HMG_ActiveTabWidth           := w
   _HMG_ActiveTabHeight          := h
   _HMG_ActiveTabValue           := value
   _HMG_ActiveTabFontName        := f
   _HMG_ActiveTabFontSize        := s
   _HMG_ActiveTabToolTip         := tooltip
   _HMG_ActiveTabChangeProcedure := change
   _HMG_ActiveTabColor           := backcolor
   _HMG_ActiveTabnId             := nId

   _HMG_ActiveTabButtons         := Buttons
   _HMG_ActiveTabFlat            := Flat
   _HMG_ActiveTabHotTrack        := HotTrack
   _HMG_ActiveTabVertical        := Vertical
   _HMG_ActiveTabBottom          := Bottom
   _HMG_ActiveTabNoTabStop       := NotabStop
   _HMG_ActiveTabMultiline       := Multiline

   _HMG_ActiveTabBold            := Bold
   _HMG_ActiveTabItalic          := Italic
   _HMG_ActiveTabUnderline       := Underline
   _HMG_ActiveTabStrikeout       := Strikeout

   aEval( aMnemonic, { |x, i| HB_SYMBOL_UNUSED( x ), aMnemonic[i] := &( '{|| _SetValue("' + ControlName + '","' + ParentFormName + '",' + hb_ntos(i) + ') }' ) } )

   _HMG_ActiveTabMnemonic := aMnemonic

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _DefineTab ( ControlName, ParentFormName, x, y, w, h, aCaptions, aPageMap, value, fontname, fontsize, tooltip, change, Buttons, Flat, HotTrack, Vertical, Bottom, notabstop, aMnemonic, bold, italic, underline, strikeout, Images, multiline, backcolor, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, mVar, ImageFlag := .F., k, Style
   LOCAL ControlHandle, FontHandle, blInit, hBrush := 0

   __defaultNIL( @change, "" )
   hb_default( @Buttons, .F. )
   hb_default( @Flat, .F. )
   hb_default( @HotTrack, .F. )
   hb_default( @Vertical, .F. )
   hb_default( @bottom, .F. )
   hb_default( @notabstop, .F. )

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   FOR EACH mVar IN Images
      IF ISCHARACTER( mVar ) .AND. !Empty( mVar )  // JD 11/05/2006
         ImageFlag := .T.
         EXIT
      ENDIF
   NEXT

   IF _HMG_IsThemed .AND. buttons == .F.
      vertical := .F.
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD + WS_VISIBLE

      IF Buttons
         Style += TCS_BUTTONS
      ENDIF
      IF Flat
         Style += TCS_FLATBUTTONS
      ENDIF
      IF HotTrack
         Style += TCS_HOTTRACK
      ENDIF
      IF Vertical
         Style += TCS_VERTICAL
      ENDIF
      IF Multiline
         Style += TCS_MULTILINE
      ENDIF
      IF !notabstop
         Style += WS_TABSTOP
      ENDIF

      nId := _HMG_ActiveTabnId

      IF Len( _HMG_aDialogTemplate ) > 0        //Dialog Template
         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogTab( x, y, z ) }
         AAdd( _HMG_aDialogItems, { _HMG_ActiveTabnId, k, "SysTabControl32", style, 0, ;
            _HMG_ActiveTabCol, _HMG_ActiveTabRow, _HMG_ActiveTabWidth, _HMG_ActiveTabHeight, "", ;
            0, _HMG_ActiveTabToolTip, _HMG_ActiveTabFontName, _HMG_ActiveTabFontSize, ;
            _HMG_ActiveTabBold, _HMG_ActiveTabItalic, _HMG_ActiveTabUnderline, _HMG_ActiveTabStrikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         SetWindowStyle ( ControlHandle, Style, .T. )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      ControlHandle := InitTabControl ( ParentFormHandle, 0, x, y, w, h, aCaptions, value, '', 0, Buttons, Flat, HotTrack, Vertical, Bottom, Multiline, ISARRAY( backcolor[1] ), notabstop )
      IF ISARRAY( backcolor[1] )
         hBrush := CreateSolidBrush( backcolor[1][1], backcolor[1][2], backcolor[1][3] )
         SetWindowBrush( ControlHandle, hBrush )
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

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "TAB"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlHandles [k] :=   Controlhandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlPageMap  [k] :=  aPageMap
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  0
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor [1]
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing  [k] :=  0
   _HMG_aControlContainerRow  [k] :=  -1
   _HMG_aControlContainerCol  [k] :=  -1
   _HMG_aControlPicture  [k] :=  Images
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  0
   _HMG_aControlRangeMax   [k] :=  0
   _HMG_aControlCaption   [k] :=  aCaptions
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   0
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  hBrush
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  { 0, ImageFlag, aMnemonic, Bottom, HotTrack, backcolor [2], backcolor [3] }
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF Len( _HMG_aDialogTemplate ) == 0   //Dialog Template
      InitDialogTab( ParentFormName, ControlHandle, k )
   ENDIF

RETURN Nil

#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
*-----------------------------------------------------------------------------*
FUNCTION InitDialogTab( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL aCaptions, Caption, tabpage, c, z, i, aMnemonic

   aMnemonic := _HMG_aControlMiscData1 [k,3]
   aCaptions := _HMG_aControlCaption [k]

   IF _HMG_BeginDialogActive

      IF Len( _HMG_ActiveTabFullPageMap ) < Len( aCaptions )
         AAdd ( _HMG_ActiveTabFullPageMap , {} )
      ENDIF

      _HMG_aControlPageMap [k] := _HMG_ActiveTabFullPageMap

      AddDialogPages( ControlHandle, aCaptions, _HMG_aControlValue [k] )

   ENDIF

   IF _HMG_aControlMiscData1 [k,2]  // ImageFlag
      _HMG_aControlInputMask [k] := AddTabBitMap ( ControlHandle, _HMG_aControlPicture [k] )
   ENDIF

   FOR z := 1 TO Len ( aCaptions )

      Caption := Upper ( aCaptions [z] )

      i := At ( '&' , Caption )

      IF i > 0
         _DefineLetterOrDigitHotKey ( Caption, i, ParentName, aMnemonic [z] )
      ENDIF

   NEXT z

   // Hide all except page to show
   FOR EACH tabpage IN _HMG_ActiveTabFullPageMap

      IF hb_enumindex( tabpage ) != _HMG_aControlValue [k]

         FOR EACH c IN tabpage
            IF ValType ( c ) <> "A"
               HideWindow ( c )
            ELSE
               FOR EACH z IN c
                  HideWindow ( z )
               NEXT
            ENDIF
         NEXT

      ENDIF

   NEXT

   // JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION UpdateTab ( y )  // Internal Function
*-----------------------------------------------------------------------------*
   LOCAL tabpage, w, s, z

   // Hide All Pages
   FOR EACH tabpage IN _HMG_aControlPageMap [y]

      FOR EACH w IN tabpage
         IF ValType ( w ) <> "A"
            HideWindow ( w )
         ELSE
            FOR EACH z IN w
               HideWindow ( z )
            NEXT
         ENDIF
      NEXT

   NEXT

   // Show New Active Page
   s := TabCtrl_GetCurSel ( _HMG_aControlHandles [y] )

   IF s > 0

      FOR EACH w IN _HMG_aControlPageMap [y] [s]

         IF ValType ( w ) <> "A"

            IF _IsControlVisibleFromHandle ( w )

               CShowControl ( w )
#ifdef _PANEL_
            ELSEIF _IsWindowVisibleFromHandle ( w )
		
               CShowControl ( w )
#endif
            ENDIF

         ELSE

            IF _IsControlVisibleFromHandle ( w [1] )

               FOR EACH z IN w
                  CShowControl ( z )
               NEXT

            ENDIF

         ENDIF

      NEXT

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _BeginTabPage ( caption , image , tooltip )
*-----------------------------------------------------------------------------*
   // JD 11/05/2006
   hb_default( @Caption, "" )
   hb_default( @Image, "" )

   _HMG_ActiveTabPage++
   AAdd ( _HMG_ActiveTabCaptions , caption )
   AAdd ( _HMG_ActiveTabImages , image )
   // JR
   IF ValType( tooltip ) == 'C'
      IF ValType( _HMG_ActiveTabTooltip ) <> 'A'
         _HMG_ActiveTabTooltip := Array( _HMG_ActiveTabPage )
         AFill( _HMG_ActiveTabTooltip, '' )
         _HMG_ActiveTabTooltip[ _HMG_ActiveTabPage ] := tooltip  // JP
      ELSE
         AAdd( _HMG_ActiveTabTooltip, tooltip )
      ENDIF
   ELSEIF ValType( _HMG_ActiveTabTooltip ) == 'A'
      AAdd( _HMG_ActiveTabTooltip, '' )
   ELSE  // GF 11/04/2009
      _HMG_ActiveTabTooltip := Array( _HMG_ActiveTabPage )
      AFill( _HMG_ActiveTabTooltip, '' )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EndTabPage()
*-----------------------------------------------------------------------------*

   IF lDialogInMemory
      _HMG_aDialogItems[len(_HMG_aDialogItems),21] := .T.
   ELSE
      AAdd ( _HMG_ActiveTabFullPageMap , _HMG_ActiveTabCurrentPageMap )
      _HMG_ActiveTabCurrentPageMap := {}
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EndTab()
*-----------------------------------------------------------------------------*

   _DefineTab ( _HMG_ActiveTabName, _HMG_ActiveTabParentFormName, _HMG_ActiveTabCol, ;
      _HMG_ActiveTabRow, _HMG_ActiveTabWidth, _HMG_ActiveTabHeight, ;
      _HMG_ActiveTabCaptions, _HMG_ActiveTabFullPageMap, _HMG_ActiveTabValue, ;
      _HMG_ActiveTabFontName, _HMG_ActiveTabFontSize, _HMG_ActiveTabToolTip, ;
      _HMG_ActiveTabChangeProcedure, _HMG_ActiveTabButtons, _HMG_ActiveTabFlat, ;
      _HMG_ActiveTabHotTrack, _HMG_ActiveTabVertical, _HMG_ActiveTabBottom, ;
      _HMG_ActiveTabNoTabStop, _HMG_ActiveTabMnemonic, _HMG_ActiveTabBold, ;
      _HMG_ActiveTabItalic, _HMG_ActiveTabUnderline, _HMG_ActiveTabStrikeout, ;
      _HMG_ActiveTabImages, _HMG_ActiveTabMultiline, _HMG_ActiveTabColor, _HMG_ActiveTabnId )
   _HMG_BeginTabActive := .F.
   _HMG_FrameLevel--

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddTabPage ( ControlName , ParentForm , Position , Caption , Image , tooltip )
*-----------------------------------------------------------------------------*
   LOCAL i, ImageFlag := .F.  // JD 11/05/2006

   hb_default( @Caption, "" )
   hb_default( @Image, "" )
   __defaultNIL( @tooltip, "" )  // JR

   i := GetControlIndex ( Controlname , ParentForm )
   // JD 11/05/2006
   IF i > 0
      TABCTRL_INSERTITEM ( _HMG_aControlHandles [i] , Position - 1 , Caption )

      AIns ( _HMG_aControlPageMap [i] , Position , {} , .T. )
      AIns ( _HMG_aControlCaption [i] , Position , Caption , .T. )
      AIns ( _HMG_aControlPicture [i] , Position , Image , .T. )
      // JD 11/05/2006
      FOR EACH Image IN _HMG_aControlPicture [i]
         IF ValType ( Image ) == "C" .AND. !Empty ( Image )
            ImageFlag := .T.
            EXIT
         ENDIF
      NEXT

      _HMG_aControlMiscData1 [i] [2] := ImageFlag  // JD 11/05/2006
      // JD 11/05/2006
      IF ImageFlag == .T.
         IF !Empty( _HMG_aControlInputMask [i] )
            IMAGELIST_DESTROY ( _HMG_aControlInputMask [i] )
         ENDIF
         _HMG_aControlInputMask [i] := AddTabBitMap ( _HMG_aControlHandles [i], _HMG_aControlPicture [i] )
      ENDIF
      // JR
      IF ValType ( _HMG_aControlTooltip [i] ) <> "A"
         _HMG_aControlTooltip [i] := Array ( Len ( _HMG_aControlPageMap [i] ) )
         AFill ( _HMG_aControlTooltip [i], "" )
         _HMG_aControlTooltip [i] [Position] := tooltip
      ELSE
         AIns ( _HMG_aControlTooltip [i], Position, tooltip, .T. )
      ENDIF

      UpdateTab ( i )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddTabControl ( TabName , ControlName , ParentForm , PageNumber , Row , Col )
*-----------------------------------------------------------------------------*
   LOCAL i , x , t

   i := GetControlIndex ( TabName , ParentForm )

   x := GetControlIndex ( ControlName , ParentForm )

   IF i * x > 0

      t := _HMG_aControlType [x]

      // JD 07/20/2007
      IF t == "BROWSE" .AND. _HMG_aControlMiscData1 [x,8] == .F.
         AAdd ( _HMG_aControlPageMap [i] [PageNumber] , { _HMG_aControlHandles [x] , _HMG_aControlIds [x], _HMG_aControlMiscData1 [x] [1] } )
      ELSE
         AAdd ( _HMG_aControlPageMap [i] [PageNumber] , _HMG_aControlHandles [x] )
      ENDIF

      IF t == "SLIDER"

         _HMG_aControlFontHandle [x] :=  TabName
         _HMG_aControlMiscData1  [x] :=  ParentForm

      ELSEIF t $ "FRAME,CHECKBOX,RADIOGROUP,LABEL"  // JD 07/20/2007

         _HMG_aControlRangeMin  [x] :=  TabName
         _HMG_aControlRangeMax  [x] :=  ParentForm

      ENDIF

      _HMG_aControlContainerRow [x] := _HMG_aControlRow [i]
      _HMG_aControlContainerCol [x] := _HMG_aControlCol [i]

      _SetControlRow ( ControlName , ParentForm , Row )
      _SetControlCol ( ControlName , ParentForm , Col )

      UpdateTab ( i )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DeleteTabPage ( ControlName , ParentForm , Position )
*-----------------------------------------------------------------------------*
   LOCAL i , j , NewValue , NewMap := {} , ImageFlag := .F.

   i := GetControlIndex ( Controlname , ParentForm )

   IF i > 0

      // Control Map
      FOR j := 1 TO Len ( _HMG_aControlPageMap [i] )

         IF j <> position
            AAdd ( NewMap , _HMG_aControlPageMap [i] [j] )
         ENDIF

      NEXT j

      _HMG_aControlPageMap [i] := NewMap

      // Images
      NewMap := {}

      FOR j := 1 TO Len ( _HMG_aControlPicture [i] )

         IF j <> position
            AAdd ( NewMap , _HMG_aControlPicture [i] [j] )
         ENDIF

      NEXT j

      _HMG_aControlPicture [i] := NewMap

      // Captions
      NewMap := {}

      FOR j := 1 TO Len ( _HMG_aControlCaption [i] )

         IF j <> position
            AAdd ( NewMap, _HMG_aControlCaption [i] [j] )
         ENDIF

      NEXT j

      _HMG_aControlCaption [i] := NewMap

      // ToolTips
      NewMap := {}

      FOR j := 1 TO Len ( _HMG_aControlTooltip [i] )

         IF j <> position
            AAdd ( NewMap, _HMG_aControlTooltip [i] [j] )
         ENDIF

      NEXT j

      _HMG_aControlTooltip [i] := NewMap

      TabCtrl_DeleteItem( _HMG_aControlhandles [i], Position - 1 )

      // JD 11/05/2006
      FOR EACH NewValue IN _HMG_aControlPicture [i]

         IF ValType ( NewValue ) == "C" .AND. !Empty ( NewValue )
            ImageFlag := .T.
            EXIT
         ENDIF

      NEXT

      _HMG_aControlMiscData1 [i,2] := ImageFlag   // JD 11/05/2006

      // JD 11/05/2006
      IF ImageFlag == .T.

         IF !Empty( _HMG_aControlInputMask [i] )
            IMAGELIST_DESTROY ( _HMG_aControlInputMask [i] )
         ENDIF

         _HMG_aControlInputMask [i] := AddTabBitMap ( _HMG_aControlHandles [i], _HMG_aControlPicture [i] )

      ENDIF

      NewValue := Position - 1

      IF NewValue == 0
         NewValue := 1
      ENDIF

      TABCTRL_SETCURSEL ( _HMG_aControlhandles [i], NewValue )

      UpdateTab ( i )

   ENDIF

RETURN Nil

#define DT_CENTER     1
*------------------------------------------------------------------------------*
FUNCTION OwnTabPaint ( lParam )
*------------------------------------------------------------------------------*
   LOCAL i, hDC, nItemId, aBtnRc, hBrush, oldBkMode, bkColor
   LOCAL hOldFont, aMetr, oldTextColor, nTextColor, hImage
   LOCAL aBkColor, aForeColor, aInactiveColor, aBmp
   LOCAL x1, y1, x2, y2, xp1, yp1, xp2, yp2
   LOCAL lSelected, lBigFsize, lBigFsize2

   hDC := GETOWNBTNDC( lParam )

   i := AScan( _HMG_aControlHandles, GETOWNBTNHANDLE( lParam ) )

   IF Empty( hDC ) .OR. i == 0
      RETURN( 1 )
   ENDIF

   nItemId    := GETOWNBTNITEMID( lParam ) + 1
   aBtnRc     := GETOWNBTNRECT( lParam )
   lSelected  := AND( GETOWNBTNSTATE( lParam ), ODS_SELECTED ) == ODS_SELECTED
   lBigFsize  := ( _HMG_aControlFontSize [i] > 12 )
   lBigFsize2 := ( _HMG_aControlFontSize [i] > 18 )
   _HMG_aControlMiscData1 [i] [1] := aBtnRc[ 4 ] - aBtnRc[ 2 ]  // store a bookmark height

   hOldFont := SelectObject( hDC, _HMG_aControlFontHandle [i] )
   aMetr := GetTextMetric( hDC )
   oldBkMode := SetBkMode( hDC, TRANSPARENT )
   nTextColor := GetSysColor( COLOR_BTNTEXT )
   oldTextColor := SetTextColor( hDC, GetRed( nTextColor ), GetGreen( nTextColor ), GetBlue( nTextColor ) )

   IF ISARRAY( _HMG_aControlMiscData2 [i] ) .AND. nItemId <= Len( _HMG_aControlMiscData2 [i] ) .AND. ;
      IsArrayRGB( _HMG_aControlMiscData2 [i] [nItemId] )
      aBkColor := _HMG_aControlMiscData2 [i] [nItemId]
   ELSE
      aBkColor := _HMG_aControlBkColor [i]
   ENDIF
   hBrush := CreateSolidBrush( aBkColor [1], aBkColor [2], aBkColor [3] )
   FillRect( hDC, aBtnRc[ 1 ], aBtnRc[ 2 ], aBtnRc[ 3 ], aBtnRc[ 4 ], hBrush )
   DeleteObject( hBrush )

   bkColor := RGB( aBkColor [1], aBkColor [2], aBkColor [3] )
   SetBkColor( hDC, bkColor )

   x1 := aBtnRc[ 1 ]
   y1 := Round( aBtnRc[ 4 ] / 2, 0 ) - ( aMetr[ 1 ] - 10 )
   x2 := aBtnRc[ 3 ] - 2
   y2 := y1 + aMetr[ 1 ]

   IF _HMG_aControlMiscData1 [i] [2]  // ImageFlag
      nItemId := Min( nItemId, Len( _HMG_aControlPicture [i] ) )
      hImage := LoadBitmap( _HMG_aControlPicture [i] [nItemId] )
      aBmp := GetBitmapSize( hImage )

      xp1 := 4
      xp2 := aBmp[ 1 ]
      yp2 := aBmp[ 2 ]
      yp1 := Round( aBtnRc[ 4 ] / 2 - yp2 / 2, 0 )
      x1 += 2 * xp1 + xp2

      IF _HMG_aControlMiscData1 [i] [4]  // Bottom Tab
         IF lSelected
            DrawGlyph( hDC, aBtnRc[ 1 ] + 2 * xp1, 2 * yp1 - iif( lBigFsize, 8, 5 ), xp2, 2 * yp2 - iif( lBigFsize, 8, 5 ), hImage, bkColor, .F., .F. )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + xp1, 2 * yp1 - iif( lBigFsize, 8, 5 ), xp2, 2 * yp2 - iif( lBigFsize, 8, 5 ), hImage, bkColor, .F., .F. )
         ENDIF
      ELSE
         IF lSelected
            DrawGlyph( hDC, aBtnRc[ 1 ] + 2 * xp1, yp1 - 2, xp2, yp2, hImage, bkColor, .F., .F. )
         ELSE
            DrawGlyph( hDC, aBtnRc[ 1 ] + xp1, yp1 + 2, xp2, yp2, hImage, bkColor, .F., .F. )
         ENDIF
      ENDIF

      DeleteObject( hImage )
   ENDIF

   IF lSelected
      IF _HMG_aControlMiscData1 [i] [5]  // HotTrack
         aForeColor := _HMG_aControlMiscData1 [i] [6]
         IF IsArrayRGB ( aForeColor )
            SetTextColor( hDC, aForeColor [1], aForeColor [2], aForeColor [3] )
         ELSEIF bkColor == GetSysColor( COLOR_BTNFACE )
            SetTextColor( hDC, 0, 0, 128 )
         ELSE
            SetTextColor( hDC, 255, 255, 255 )
         ENDIF
      ENDIF
   ELSE
      aInactiveColor := _HMG_aControlMiscData1 [i] [7]
      IF IsArrayRGB ( aInactiveColor )
         SetTextColor( hDC, aInactiveColor [1], aInactiveColor [2], aInactiveColor [3] )
      ENDIF
   ENDIF

   IF _HMG_aControlMiscData1 [i] [4]  // Bottom Tab
      IF lSelected
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, 2 * y1 - iif( lBigFsize2, -3, iif( lBigFsize, 6, 12 ) ), x2, 2 * y2 - iif( lBigFsize2, -3, iif( lBigFsize, 6, 12 ) ), DT_CENTER )
      ELSE
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, 2 * y1 - iif( lBigFsize2, -6, iif(lBigFsize, 2, 8 ) ), x2, 2 * y2 - iif( lBigFsize2, -6, iif( lBigFsize, 2, 8 ) ), DT_CENTER )
      ENDIF
   ELSE
      IF lSelected
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, y1 - iif( lBigFsize2, -5, iif( lBigFsize, 0, 4 ) ), x2, y2 - iif( lBigFsize2, -5, iif( lBigFsize, 0, 4 ) ), DT_CENTER )
      ELSE
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, y1 + iif( lBigFsize2, 8, iif( lBigFsize, 4, 0 ) ), x2, y2 + iif( lBigFsize2, 8, iif( lBigFsize, 4, 0 ) ), DT_CENTER )
      ENDIF
   ENDIF

   SelectObject( hDC, hOldFont )
   SetBkMode( hDC, oldBkMode )
   SetTextColor( hDC, oldTextColor )

RETURN( 0 )
