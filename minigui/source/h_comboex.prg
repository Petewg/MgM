/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

COMBOBOXEX Control Source Code
Copyright 2005 Jacek Kubica <kubica@wssk.wroc.pl>

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

#define CBEM_GETCOMBOCONTROL  1030
#define CBEM_GETEDITCONTROL   1031

// (JK) Extend combobox control - COMBOBOXEX
// HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
FUNCTION _DefineComboEx ( ControlName, ParentForm, x, y, w, rows, value, ;
      fontname, fontsize, tooltip, changeprocedure, h, gotfocus, lostfocus, ;
      uEnter, HelpId, invisible, notabstop, ;
      sort , ;  // not used with extend COMBO
      bold, italic, underline, strikeout , itemsource , valuesource , ;
      displaychange , ondisplaychangeprocedure , break , GripperText, ;
      aImage, ListWidth, OnListDisplayProcedure, OnListCloseProcedure, ;
      backcolor, fontcolor, ImageList, nItemHeight, bInit, notrans )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle , FontHandle
   LOCAL cParentForm , mVar
   LOCAL i , k
   LOCAL rcount := 0
   LOCAL cset := 0
   LOCAL ContainerHandle := 0
   LOCAL BackRec , WorkArea , cField
   LOCAL aImages := {}
   LOCAL im
   LOCAL oc := NIL, ow := NIL
#ifdef _OBJECT_
   ow := oDlu2Pixel()
#endif

   hb_default( @w, 120 )
   hb_default( @h, 150 )
   __defaultNIL( @changeprocedure, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @lostfocus, "" )
   hb_default( @rows, {} )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @notrans, .F. )
   hb_default( @sort, .F. )
   hb_default( @GripperText, "" )
   hb_default( @aImage, {} )
   __defaultNIL( @value, 0 )
   __defaultNIL( @ImageList, 0 )
   __defaultNIL( @uEnter, "" )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x    := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y    := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentForm := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + IFNIL( ParentForm, "Parent", ParentForm ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   IF ValType ( itemsource ) != 'U'
      IF  At ( '>', ItemSource ) == 0
         MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " (ItemSource): You must specify a fully qualified field name." )
      ELSE
         WorkArea := Left ( ItemSource , At ( '>', ItemSource ) - 2 )
         cField   := Right ( ItemSource , Len ( ItemSource ) - At ( '>', ItemSource ) )
      ENDIF
   ENDIF

   IF ( ValType( ImageList ) == "C" .OR. ImageList > 0 ) .AND. Len( aImage ) > 0
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " : Image and ImageList clauses can't be used simultaneously." )
   ENDIF

   IF ValType( ImageList ) == "C"
      IF Len( ImageList ) > 0
         ImageList := GetControlHandle ( ImageList, ParentForm )
      ENDIF
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   IF !Empty( aImage )
      aImages := {}
      FOR im := 1 TO Len( aImage )
         IF ValType( aImage[im] ) == "C"
            AAdd( aImages, aImage[im] )
            AAdd( aImages, aImage[im] )
            AAdd( aImages, aImage[im] )

         ELSEIF ValType( aImage[im] ) == "A"
            IF Len( aImage[im] ) <> 2
               MsgMiniGuiError ( "Control: " + ControlName + " Of " + cParentForm + " : You must specify 2 elements characters array as image param." )
            ELSE
               AAdd( aImages, aImage[im,1] )
               AAdd( aImages, aImage[im,2] )
               AAdd( aImages, aImage[im,1] )
            ENDIF
         ENDIF
      NEXT im
   ENDIF

   IF ValType( x ) == "U" .OR. ValType( y ) == "U"

      _HMG_SplitLastControl := 'COMBOBOX'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitComboBoxEx ( _HMG_aFormReBarHandle [i], 0, x, y, w, '', notrans , h, invisible, notabstop, .F. , displaychange, _HMG_IsXPorLater, aImages, ImageList )

         IF FontHandle != 0
            _SetFontHandle( ControlHandle, FontHandle )
         ELSE
            __defaultNIL( @FontName, _HMG_DefaultFontName )
            __defaultNIL( @FontSize, _HMG_DefaultFontSize )
            IF IsWindowHandle( ControlHandle )
               FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
            ENDIF
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , GripperText , w , , _HMG_ActiveSplitBoxInverted )

         Containerhandle := _HMG_aFormReBarHandle [i]

      ENDIF

   ELSE

      ControlHandle := InitComboBoxEx ( ParentForm, 0, x, y, w, '', notrans , h, invisible, notabstop, .F. , displaychange, _HMG_IsXPorLater, aImages, ImageList )

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

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
   ENDIF

   IF ValType( nItemHeight ) != "U"
      ComboSetItemHeight ( ControlHandle , nItemHeight )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   IF Len( aImages ) > 0
      AddListViewBitmap( ControlHandle, aImages )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] := "COMBO"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentForm
   _HMG_aControlIds  [k] :=  0
   _HMG_aControlProcedures  [k] :=  ondisplaychangeprocedure
   _HMG_aControlPageMap  [k] :=  cField
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask   [k] := OnListDisplayProcedure
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  changeprocedure
   _HMG_aControlDeleted   [k] := FALSE
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  uEnter
   _HMG_aControlHeadClick  [k] := {}
   _HMG_aControlRow   [k] := y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := WorkArea
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  OnListCloseProcedure
   _HMG_aControlContainerHandle  [k] :=  ContainerHandle
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption   [k] :=  valuesource
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { 1, displaychange }  // value used for recognition between extend and standard COMBO
   _HMG_aControlMiscData2 [k] := ''

   IF DisplayChange == .T.
      // handle for ComboBoxEx edit window
      _hmg_acontrolrangemin [k] := SendMessage ( Controlhandle, CBEM_GETEDITCONTROL, 0, 0 )
      IF ValType( tooltip ) != "U"
         SetToolTip ( _hmg_acontrolrangemin [k] , tooltip , GetFormToolTipHandle ( cParentForm ) )
      ENDIF
   ENDIF
   // handle for ComboBoxEx child window
   _hmg_acontrolrangemax [k] := SendMessage ( Controlhandle, CBEM_GETCOMBOCONTROL, 0, 0 )
   IF ValType( tooltip ) != "U"
      SetToolTip ( _hmg_acontrolrangemax [k] , tooltip , GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   SetDropDownWidth( _hmg_acontrolrangemax [k] , hb_defaultValue( ListWidth, w ) )

   IF ValType( WorkArea ) == "C"

      IF Select( WorkArea ) != 0

         BackRec := ( WorkArea )->( RecNo() )

         ( WorkArea )->( dbGoTop() )

         DO WHILE ! ( WorkArea )->( EOF() )
            rcount++
            IF value == ( WorkArea )->( RecNo() )
               cset := rcount
            ENDIF
            ComboAddStringEx ( ControlHandle, cValToChar ( ( WorkArea )->&( cField ), 1 ) )
            ( WorkArea )->( dbSkip() )
         ENDDO

         ( WorkArea )->( dbGoto( BackRec ) )

         ComboSetCurSel ( ControlHandle, cset )

      ENDIF

   ELSE

      IF Len ( rows ) > 0
         AEval ( rows, { |v, i| ComboAddStringEx ( ControlHandle, v, i ) } )
      ENDIF

      IF ISNUMBER( value ) .AND. value <> 0
         ComboSetCurSel ( ControlHandle, Value )
      ENDIF

   ENDIF

   IF ValType ( ItemSource ) != 'U'
      AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( cParentForm ) ] , k )
   ENDIF

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
#ifdef _OBJECT_
      ow := _WindowObj ( ParentForm )
      oc := _ControlObj( ControlHandle )
#endif
   ENDIF

   Do_ControlEventProcedure ( bInit, k, ow, oc )

RETURN Nil
