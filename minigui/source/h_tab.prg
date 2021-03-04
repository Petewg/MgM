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

STATIC lDialogInMemory := .F., bOnInit, _HMG_ActiveTabImage_NoTransparent

*-----------------------------------------------------------------------------*
FUNCTION _BeginTab( ControlName , ParentFormName , row , col , w , h , value , f , s , tooltip , change , buttons , flat , hottrack , vertical , bottom , notabstop , bold, italic, underline, strikeout, multiline , backcolor, nId, bInit, NoTrans )
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
   hb_default( @NoTrans, .F. )

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
   bOnInit := bInit
   _HMG_ActiveTabImage_NoTransparent := NoTrans

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
STATIC FUNCTION _DefineTab ( ControlName, ParentFormName, x, y, w, h, aCaptions, aPageMap, value, fontname, fontsize, tooltip, change, Buttons, Flat, HotTrack, Vertical, Bottom, notabstop, aMnemonic, bold, italic, underline, strikeout, Images, multiline, backcolor, nId, bInit, NoTrans )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, ControlHandle, FontHandle
   LOCAL hBrush := 0
   LOCAL mVar
   LOCAL k
   LOCAL Style
   LOCAL blInit
   LOCAL ImageFlag := .F.
   LOCAL oc := NIL, ow := NIL
#ifdef _OBJECT_
   ow := oDlu2Pixel()
#endif

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
         IF IsWindowHandle( ControlHandle )
            FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
         ENDIF
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] :=  "TAB"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlHandles [k] :=  Controlhandle
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
   _HMG_aControlRangeMin   [k] :=  Buttons
   _HMG_aControlRangeMax   [k] :=  0
   _HMG_aControlCaption   [k] :=  aCaptions
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   0
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  hBrush
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  { 0, ImageFlag, aMnemonic, Bottom, HotTrack, backcolor [2], backcolor [3], NoTrans }
   _HMG_aControlMiscData2 [k] :=  ''

   IF Len( _HMG_aDialogTemplate ) == 0   //Dialog Template
      InitDialogTab( ParentFormName, ControlHandle, k )
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
FUNCTION InitDialogTab( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL aCaptions, aMnemonic
   LOCAL Caption
   LOCAL tabpage
   LOCAL c, z, i

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
      _HMG_aControlInputMask [k] := AddTabBitMap ( ControlHandle, _HMG_aControlPicture [k], _HMG_aControlMiscData1 [k,8] )
   ENDIF

   FOR EACH c IN aCaptions

      Caption := Upper ( c )

      IF ( i := At ( '&' , Caption ) ) > 0
         _DefineLetterOrDigitHotKey ( Caption, i, ParentName, aMnemonic [ hb_enumindex( c ) ] )
      ENDIF

   NEXT

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
   LOCAL tabpage
   LOCAL w, s, z

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

#ifdef _PANEL_
*-----------------------------------------------------------------------------*
STATIC FUNCTION _IsWindowVisibleFromHandle ( Handle )
*-----------------------------------------------------------------------------*
   LOCAL lVisible As Logical
   LOCAL hForm

   FOR EACH hForm IN _HMG_aFormHandles

      IF hForm == Handle
         lVisible := .NOT. _HMG_aFormNoShow [ hb_enumindex( hForm ) ]
         EXIT
      ENDIF

   NEXT

RETURN lVisible
#endif

*-----------------------------------------------------------------------------*
STATIC FUNCTION _IsControlVisibleFromHandle ( Handle )
*-----------------------------------------------------------------------------*
   LOCAL lVisible As Logical
   LOCAL hControl

   FOR EACH hControl IN _HMG_aControlHandles

      IF ValType ( hControl ) == 'N'

         IF hControl == Handle
            lVisible := _HMG_aControlVisible [ hb_enumindex( hControl ) ]
            EXIT
         ENDIF

      ELSEIF ValType ( hControl ) == 'A'

         IF hControl [1] == Handle
            lVisible := _HMG_aControlVisible [ hb_enumindex( hControl ) ]
            EXIT
         ENDIF

      ENDIF

   NEXT

RETURN lVisible

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
      _HMG_aDialogItems [ Len( _HMG_aDialogItems ), 21 ] := .T.
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
      _HMG_ActiveTabImages, _HMG_ActiveTabMultiline, _HMG_ActiveTabColor, _HMG_ActiveTabnId, bOnInit, _HMG_ActiveTabImage_NoTransparent )

   _HMG_BeginTabActive := .F.
   _HMG_FrameLevel--

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddTabPage ( ControlName , ParentForm , Position , Caption , Image , tooltip )
*-----------------------------------------------------------------------------*
   LOCAL aMnemonic
   LOCAL ImageFlag := .F.  // JD 11/05/2006
   LOCAL i , x , c

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
      // GF 03/10/2018
      aMnemonic := _HMG_aControlMiscData1 [i,3]
      ASize ( aMnemonic , Len ( _HMG_aControlCaption [i] ) )

      aEval( aMnemonic, { |x, i| HB_SYMBOL_UNUSED( x ), aMnemonic[i] := &( '{|| _SetValue("' + ControlName + '","' + ParentForm + '",' + hb_ntos(i) + ') }' ) } )

      FOR EACH c IN _HMG_aControlCaption [i]
         Caption := Upper ( c )
         IF ( x := At ( '&' , Caption ) ) > 0
            _DefineLetterOrDigitHotKey ( Caption, x, ParentForm, aMnemonic [ hb_enumindex( c ) ] )
         ENDIF
      NEXT
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
         _HMG_aControlInputMask [i] := AddTabBitMap ( _HMG_aControlHandles [i], _HMG_aControlPicture [i], _HMG_aControlMiscData1 [i, 8] )
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

#ifdef _USERINIT_
      IF t == "SPBUTTON" .AND. _HMG_aControlVisible [x]
         BringWindowToTop ( _HMG_aControlHandles [x] )
      ENDIF
#endif
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DeleteTabPage ( ControlName , ParentForm , Position )
*-----------------------------------------------------------------------------*
   LOCAL NewValue
   LOCAL NewMap := {}
   LOCAL aMnemonic
   LOCAL ImageFlag := .F.
   LOCAL i , j , c

   i := GetControlIndex ( ControlName , ParentForm )

   IF i > 0

      // Hide all ñontrols on a focused deleted page
      IF _GetValue ( ControlName , ParentForm ) == Position   // GF 07/17/2019

         FOR EACH NewValue IN _HMG_aControlPageMap [i]

            IF hb_enumindex( NewValue ) == position

               FOR EACH c IN NewValue

                  IF ValType ( c ) <> "A"
                     HideWindow ( c )
                  ELSE
                     FOR EACH j IN c
                        HideWindow ( j )
                     NEXT
                  ENDIF

               NEXT
               EXIT

            ENDIF

         NEXT

      ENDIF

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

      // Hotkeys cleaning
      FOR EACH NewMap IN _HMG_aControlCaption [i]
         NewValue := Upper ( NewMap )
         IF ( j := At ( '&' , NewValue ) ) > 0
            c := Asc ( SubStr ( NewValue , j + 1 , 1 ) )
            IF c >= 48 .AND. c <= 90
               _ReleaseHotKey ( ParentForm , MOD_ALT , c )
            ENDIF
         ENDIF
      NEXT

      // Captions
      NewMap := {}

      FOR j := 1 TO Len ( _HMG_aControlCaption [i] )

         IF j <> position
            AAdd ( NewMap, _HMG_aControlCaption [i] [j] )
         ENDIF

      NEXT j

      _HMG_aControlCaption [i] := NewMap

      // Hotkeys assignment
      aMnemonic := _HMG_aControlMiscData1 [i,3]

      FOR EACH c IN _HMG_aControlCaption [i]

         NewValue := Upper ( c )
         IF ( j := At ( '&' , NewValue ) ) > 0
            _DefineLetterOrDigitHotKey ( NewValue, j, ParentForm, aMnemonic [ hb_enumindex( c ) ] )
         ENDIF

      NEXT

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

         _HMG_aControlInputMask [i] := AddTabBitMap ( _HMG_aControlHandles [i], _HMG_aControlPicture [i], _HMG_aControlMiscData1 [i, 8] )

      ENDIF

      NewValue := iif( Position-- > Len ( NewMap ), Max( 1, Len ( NewMap ) ), Position )

      TABCTRL_SETCURSEL ( _HMG_aControlhandles [i], NewValue )

      UpdateTab ( i )

   ENDIF

RETURN Nil
