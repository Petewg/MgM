/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

BTNTEXTBOX control source code
(C)2006 Janusz Pora <januszpora@onet.eu>

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

#define EM_SETCUEBANNER       0x1501

#define TBB1   2
#define TBB2   3

*-----------------------------------------------------------------------------*
FUNCTION _DefineBtnTextBox ( ControlName, ParentFormName, x, y, w, h, ;
      cValue, ProcedureName, ProcedureName2, abitmap, BtnWidth, FontName, FontSize, ;
      aToolTip, nMaxLength, lUpper, lLower, lNumeric, lPassword, ;
      uLostFocus, uGotFocus, uChange, uEnter, right, HelpId, ;
      bold, italic, underline, strikeout, field, backcolor, fontcolor , ;
      invisible, notabstop, nId, disableedit, lDefault, cuetext, keepfocus )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, aControlHandle := 0
   LOCAL mVar, k, Style
   LOCAL FontHandle, cBmp, cTTip, lBtn2 := ISBLOCK( ProcedureName2 )
   LOCAL WorkArea, blInit
   LOCAL lDialogInMemory

   // Assign STANDARD values to optional params.
   hb_default( @w, 120 )
   hb_default( @h, 24 )
   __defaultNIL( @cValue, "" )
   __defaultNIL( @uChange, "" )
   __defaultNIL( @uGotFocus, "" )
   __defaultNIL( @uLostFocus, "" )
   __defaultNIL( @uEnter, "" )
   __defaultNIL( @nMaxLength, 255 )
   hb_default( @lUpper, .F. )
   hb_default( @lLower, .F. )
   hb_default( @lNumeric, .F. )
   hb_default( @lPassword, .F. )
   hb_default( @lDefault, .F. )
   hb_default( @keepfocus, .T. )

   IF ValType ( aBitmap ) != 'A'
      cBmp := aBitmap
      aBitmap := Array( 2 )
      aBitmap[1] := cBmp
   ENDIF
   IF ValType ( Field ) != 'U'
      IF  At ( '>', Field ) == 0
         MsgMiniGuiError ( "Control " + ControlName + " Of " + ParentFormName + " : You must specify a fully qualified field name." )
      ELSE
         WorkArea := Left ( Field , At ( '>', Field ) - 2 )
         IF Select ( WorkArea ) != 0
            cValue := &( Field )
         ENDIF
      ENDIF
   ENDIF
   IF ValType ( aToolTip ) != 'A'
      cTTip := aToolTip
      aToolTip := Array( 3 )
      aToolTip[1] := cTTip
   ELSE
      IF Len( aToolTip ) < 3
         aToolTip := ASize( aToolTip, 3 )
      ENDIF
   ENDIF

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

// Check if the window/form is defined.
   IF .NOT. _IsWindowDefined( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

// Check if the control is already defined.
   IF _IsControlDefined( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Control " + ControlName + " of " + ParentFormName + " already defined." )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive
      ParentFormHandle  := _HMG_ActiveDialogHandle

      Style := WS_CHILD + ES_AUTOHSCROLL + WS_CLIPCHILDREN

      IF lNumeric
         Style += ES_NUMBER
      ELSE
         IF lUpper
            Style += ES_UPPERCASE
         ENDIF
         IF lLower
            Style += ES_LOWERCASE
         ENDIF
      ENDIF

      IF lPassword
         Style += ES_PASSWORD
      ENDIF

      IF right
         Style += ES_RIGHT
      ENDIF

      IF disableedit
         Style += ES_READONLY
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF  !notabstop
         Style += WS_TABSTOP
      ENDIF

      IF Len( _HMG_aDialogTemplate ) > 0        //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,aToolTip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogTextBox( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "EDIT", style, 0, x, y, w, h, cValue, HelpId, aToolTip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         aControlHandle := GetDialogItemHandle( ParentFormHandle, nId )
         SetWindowStyle( aControlHandle, Style, .T. )

         x := GetWindowCol ( aControlHandle )
         y := GetWindowRow ( aControlHandle )
         w := GetWindowWidth  ( aControlHandle )
         h := GetWindowHeight ( aControlHandle )

         aControlHandle := ReDefBtnTextBox( aControlHandle, abitmap[1], BtnWidth, abitmap[2], lBtn2, w, h )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle( ParentFormName )
      // Creates the control window
      aControlHandle := InitBtnTextBox( ParentFormHandle, 0, x, y, w, h, '', 0, nMaxLength, ;
         lUpper, lLower, .F. , lPassword, right, invisible, notabstop, ;
         abitmap[1], BtnWidth, abitmap[2], lBtn2, disableedit, lDefault )

   ENDIF

   IF .NOT. lDialogInMemory

      IF FontHandle != 0
         _SetFontHandle( aControlHandle[1], FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( aControlHandle[1], FontName, FontSize, bold, italic, underline, strikeout )
         SetTbBtnMargin ( aControlHandle[1], BtnWidth, .T., lBtn2 )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , aControlHandle )
      ENDIF

      // Add a ToolTip if param has value
      IF ValType( aToolTip[1] ) != "U"
         SetToolTip( aControlHandle[1], aToolTip[1], GetFormToolTipHandle( ParentFormName ) )
      ENDIF
      IF ValType( aToolTip[2] ) != "U"
         SetToolTip( aControlHandle[2], aToolTip[2], GetFormToolTipHandle( ParentFormName ) )
      ENDIF
      IF ValType( aToolTip[3] ) != "U"
         SetToolTip( aControlHandle[3], aToolTip[3], GetFormToolTipHandle( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := iif( lNumeric, "BTNNUMTEXT", "BTNTEXT" )
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  aControlHandle[1]
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ProcedureName
   _HMG_aControlPageMap  [k] :=  Field
   _HMG_aControlValue  [k] :=  cValue
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControlLostFocusProcedure [k] :=   uLostFocus
   _HMG_aControlGotFocusProcedure  [k] := uGotFocus
   _HMG_aControlChangeProcedure  [k] :=  uChange
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor [k] :=   fontcolor
   _HMG_aControlDblClick  [k] :=  uEnter
   _HMG_aControlHeadClick  [k] :=  ProcedureName2
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing  [k] :=  aControlHandle
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  abitmap
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  FontName
   _HMG_aControlFontSize  [k] :=  FontSize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=   aToolTip
   _HMG_aControlRangeMin  [k] :=   BtnWidth
   _HMG_aControlRangeMax  [k] :=   nMaxLength
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=  .NOT.  invisible
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=   0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] := { 0, lBtn2, disableedit, lDefault, keepfocus }
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      // With NUMERIC clause, transform numeric value into a string.
      IF lNumeric
         IF ValType( cValue ) != 'C'
            cValue := hb_ntos( cValue )
         ENDIF
      ENDIF

      // Fill the TEXTBOX with the text given.
      IF Len( cValue ) > 0
         SetWindowText( aControlHandle[1], cValue )
      ENDIF

      IF !Empty( cuetext ) .AND. IsVistaOrLater() 
         SendMessageWideString( aControlHandle[1], EM_SETCUEBANNER, .T. /*show on focus*/, cuetext )
      ENDIF

      IF ValType( Field ) != 'U'
         AAdd( _HMG_aFormBrowseList [ GetFormIndex ( ParentFormName ) ] , k )
      ENDIF
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogBtnTextBox( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL nMaxLength, Field, cValue, lNumeric, abitmap, BtnWidth, lBtn2, aControlHandle

   Field          := _HMG_aControlPageMap  [k]
   nMaxLength     := _HMG_aControlRangeMax  [k]
   cValue         := _HMG_aControlValue  [k]
   lNumeric       := ( _HMG_aControlType [k] == "BTNNUMTEXT" )
   abitmap        := _HMG_aControlPicture  [k]
   BtnWidth       := _HMG_aControlRangeMin  [k]
   lBtn2          := _HMG_aControlMiscData1  [k,2]
   aControlHandle := _HMG_aControlSpacing [k]

   IF ValType ( nMaxLength ) != 'U'
      SendMessage( aControlHandle [1] , EM_LIMITTEXT , nMaxLength , 0 )
   ENDIF

// With NUMERIC clause, transform numeric value into a string.
   IF lNumeric
      IF ValType( cValue ) != 'C'
         cValue := hb_ntos( cValue )
      ENDIF
   ENDIF

// Fill the TEXTBOX with the text given.
   IF Len( cValue ) > 0
      SetWindowText ( aControlHandle [1] , cValue )
   ENDIF

   IF ValType( Field ) != 'U'
      AAdd( _HMG_aFormBrowseList [ GetFormIndex ( ParentName ) ] , k )
   ENDIF

   ReDefBtnTextBox( ControlHandle, abitmap [1], BtnWidth, abitmap [2], lBtn2 )
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION TBBtnEvents( hwndEdit, HwndBtn )
*------------------------------------------------------------------------------*
   LOCAL i, aHandle

   i := AScan ( _HMG_aControlSpacing, { |x| ValType( x ) == 'A' .AND. Len( x ) > 0 .AND. ValType( x [1] ) == 'N' .AND. x [1] == hwndEdit } )

   IF i > 0 .AND. HwndBtn > 0

      aHandle := _HMG_aControlSpacing [i]

      SWITCH AScan ( aHandle, HwndBtn )
      CASE TBB1
         IF _DoControlEventProcedure ( _HMG_aControlProcedures [i], i )
            IF ValType( _HMG_aControlMiscData1 [i] ) == 'A' .AND. Len( _HMG_aControlMiscData1 [i] ) >= 4 .AND. ! _HMG_aControlMiscData1 [i] [4]
               SendMessage ( HwndBtn, BM_SETSTYLE, LOWORD ( BS_PUSHBUTTON ), 1 )
            ENDIF
         ENDIF
         EXIT
      CASE TBB2
         IF _DoControlEventProcedure ( _HMG_aControlHeadClick [i], i )
            IF ValType( _HMG_aControlMiscData1 [i] ) == 'A' .AND. Len( _HMG_aControlMiscData1 [i] ) >= 4 .AND. ! _HMG_aControlMiscData1 [i] [4]
               SendMessage ( HwndBtn, BM_SETSTYLE, LOWORD ( BS_PUSHBUTTON ), 1 )
            ENDIF
         ENDIF
      END SWITCH

      IF ValType( _HMG_aControlMiscData1 [i] ) == 'A' .AND. Len( _HMG_aControlMiscData1 [i] ) > 4 .AND. _HMG_aControlMiscData1 [i] [5]
         SetFocus( aHandle [1] )
      ENDIF

   ENDIF

RETURN 0
