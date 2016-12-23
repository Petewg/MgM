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

#define CBS_UPPERCASE         0x2000
#define CBS_LOWERCASE         0x4000

#define EM_SETCUEBANNER       0x1501
#define CB_SETCUEBANNER       0x1703

#define CBEM_GETCOMBOCONTROL  1030
#define CBEM_GETEDITCONTROL   1031

*-----------------------------------------------------------------------------*
FUNCTION _DefineCombo ( ControlName, ParentFormName, x, y, w, rows, value, ;
   fontname, fontsize, tooltip, changeprocedure, h, gotfocus, lostfocus, uEnter, ;
   HelpId, invisible, notabstop, sort, bold, italic, underline, strikeout , ;
   itemsource , valuesource , displaychange , ondisplaychangeprocedure , break , ;
   GripperText , ListWidth , nId, OnListDisplayProcedure, OnListCloseProcedure, ;
   backcolor, fontcolor, lUpper, lLower, cuetext, OnCancel, AutoComplete, lShowDropDown )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , mVar , ControlHandle , FontHandle , WorkArea , cField , ContainerHandle := 0 , k
   LOCAL Style, blInit
   LOCAL lDialogInMemory

   hb_default( @w, 120 )
   hb_default( @h, 150 )
   __defaultNIL( @changeprocedure, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @rows, {} )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @sort, .F. )
   hb_default( @GripperText, "" )
   hb_default( @ListWidth, w )
   hb_default( @AutoComplete, .F. )
   hb_default( @lShowDropDown, .F. )

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

   IF ValType ( ItemSource ) != 'U' .AND. Sort == .T.
      MsgMiniGuiError ( "Sort and ItemSource clauses can't be used simultaneously." )
   ENDIF

   IF ValType ( ValueSource ) != 'U' .AND. Sort == .T.
      MsgMiniGuiError ( "Sort and ValueSource clauses can't be used simultaneously." )
   ENDIF

   IF ValType ( itemsource ) != 'U'
      IF At ( '>' , ItemSource ) == 0
         MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " (ItemSource): You must specify a fully qualified field name." )
      ELSE
         WorkArea := Left ( ItemSource , At ( '>' , ItemSource ) - 2 )
         cField := Right ( ItemSource , Len ( ItemSource ) - At ( '>' , ItemSource ) )
      ENDIF
   ENDIF

   hb_default( @value, 0 )
   __defaultNIL( @uEnter, "" )

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD + WS_VSCROLL

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF SORT
         Style += CBS_SORT
      ENDIF

      IF !displaychange
         Style += CBS_DROPDOWNLIST
      ELSE
         Style += CBS_DROPDOWN
      ENDIF

      IF ValType( _HMG_IsXP ) == "L"
         IF _HMG_IsXP
            Style += CBS_NOINTEGRALHEIGHT
         ENDIF
      ENDIF

      IF lUpper
         Style += CBS_UPPERCASE
      ENDIF

      IF lLower
         Style += CBS_LOWERCASE
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogComboBox( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "COMBOBOX", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

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

         SetWindowStyle ( ControlHandle, Style, .T. )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      IF ValType( x ) == "U" .OR. ValType( y ) == "U"

         _HMG_SplitLastControl := 'COMBOBOX'

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            ControlHandle := InitComboBox ( _HMG_aFormReBarHandle [i], 0, x, y, w, lUpper, lLower, h, invisible, notabstop, sort, displaychange, _HMG_IsXPorLater )

            IF FontHandle != 0
               _SetFontHandle( ControlHandle, FontHandle )
            ELSE
               __defaultNIL( @FontName, _HMG_DefaultFontName )
               __defaultNIL( @FontSize, _HMG_DefaultFontSize )
               FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
            ENDIF

            AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , GripperText , w , , _HMG_ActiveSplitBoxInverted )

            Containerhandle := _HMG_aFormReBarHandle [i]

         ENDIF

      ELSE

         ControlHandle := InitComboBox ( ParentFormHandle, 0, x, y, w, lUpper, lLower, h, invisible, notabstop, sort, displaychange, _HMG_IsXPorLater )

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
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF ValType ( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "COMBO"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
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
   _HMG_aControlBrushHandle  [k] :=   0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] := { 0, DisplayChange, ItemSource, rows, ListWidth, cuetext, AutoComplete, lShowDropDown, 0, OnCancel }
   _HMG_aControlMiscData2 [k] := ''

   IF Len( _HMG_aDialogTemplate ) == 0
      InitDialogComboBox( ParentFormName, ControlHandle, k )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogComboBox( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL WorkArea , BackRec , rcount := 0 , cset := 0 , Value , rows , DisplayChange , ItemSource , cField , ListWidth , cuetext

   WorkArea      := _HMG_aControlSpacing [k]
   cField        := _HMG_aControlPageMap [k]
   Value         := _HMG_aControlValue  [k]
   rows          := _HMG_aControlMiscData1 [k,4]
   DisplayChange := _HMG_aControlMiscData1 [k,2]
   ItemSource    := _HMG_aControlMiscData1 [k,3]
   ListWidth     := _HMG_aControlMiscData1 [k,5]
   cuetext       := _HMG_aControlMiscData1 [k,6]

   IF DisplayChange == .T.

      _HMG_aControlRangeMin [k] := FindWindowEx( ControlHandle, 0, "Edit", Nil )
      // add tooltip for editable combo window if defined //(JK) HMG Exp. Build 8
      IF ValType( _HMG_aControlToolTip [k] ) != "U"
         SetToolTip ( _HMG_aControlRangeMin [k] , _HMG_aControlToolTip [k] , GetFormToolTipHandle( ParentName ) )
      ENDIF

      IF !Empty( cuetext ) .AND. IsVistaOrLater() 
         value := 0
         SendMessageWideString( _HMG_aControlRangeMin [k], EM_SETCUEBANNER, .T., cuetext )
      ENDIF

   ELSEIF !Empty( cuetext ) .AND. IsVistaOrLater() 

      value := 0
      SendMessageWideString( ControlHandle, CB_SETCUEBANNER, .T., cuetext )

   ENDIF

   SetDropDownWidth( ControlHandle , ListWidth )

   IF ValType( WorkArea ) == "C"

      IF Select ( WorkArea ) != 0

         BackRec := ( WorkArea )->( RecNo() )

         ( WorkArea )->( dbGoTop() )

         DO WHILE ! ( WorkArea )->( EOF() )
            rcount++
            IF value == ( WorkArea )->( RecNo() )
               cset := rcount
            ENDIF
            ComboAddString ( ControlHandle, ( WorkArea )->&( cField ) )
            ( WorkArea )->( dbSkip() )
         ENDDO

         ( WorkArea )->( dbGoto( BackRec ) )

         ComboSetCurSel ( ControlHandle, cset )

      ENDIF

   ELSE

      IF Len ( rows ) > 0
         AEval ( rows, { |v| ComboAddString ( ControlHandle, v ) } )
      ENDIF

      IF ISNUMBER( value ) .AND. value <> 0
         ComboSetCurSel ( ControlHandle, Value )
      ENDIF

   ENDIF

   IF ValType ( ItemSource ) != 'U'
      AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentName ) ] , k )
   ENDIF
   // JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

// (JK) Extend combobox control -  COMBOBOXEX
// HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
FUNCTION _DefineComboEx ( ;
      ControlName, ; // 1
      ParentForm, ;  // 2
      x, ;           // 3
      y, ;           // 4
      w, ;           // 5
      rows, ;        // 6
      value, ;       // 7
      fontname, ;    // 8
      fontsize, ;    // 9
      tooltip, ;         // 10
      changeprocedure, ; // 11
      h, ;               // 12
      gotfocus, ;        // 13
      lostfocus, ;       // 14
      uEnter, ;          // 15
      HelpId, ;          // 16
      invisible, ;       // 17
      notabstop, ;       // 18
      sort , ;           // 19   // not used with extend COMBO
      bold, ;            // 20
      italic, ;          // 21
      underline, ;         // 22
      strikeout , ;        // 23
      itemsource , ;       // 24
      valuesource , ;      // 25
      displaychange , ;    // 26
      ondisplaychangeprocedure , ; // 27
      break , ;            // 28
      GripperText, ;       // 29
      aImage , ;           // 30
      ListWidth, ;         // 31
      OnListDisplayProcedure, ; // 32
      OnListCloseProcedure, ;   // 33
      backcolor, fontcolor, ImageList )
*-----------------------------------------------------------------------------*
   LOCAL i , cParentForm , mVar , ControlHandle , FontHandle , rcount := 0
   LOCAL BackRec , cset := 0 , WorkArea , cField , ContainerHandle := 0 , k
   LOCAL im , aImages := {}

   hb_default( @w, 120 )
   hb_default( @h, 150 )
   __defaultNIL( @changeprocedure, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @lostfocus, "" )
   hb_default( @rows, {} )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
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

         ControlHandle := InitComboBoxEx ( _HMG_aFormReBarHandle [i], 0, x, y, w, '', 0 , h, invisible, notabstop, .F. , displaychange, _HMG_IsXPorLater, aImages, ImageList )

         IF FontHandle != 0
            _SetFontHandle( ControlHandle, FontHandle )
         ELSE
            __defaultNIL( @FontName, _HMG_DefaultFontName )
            __defaultNIL( @FontSize, _HMG_DefaultFontSize )
            FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , GripperText , w , , _HMG_ActiveSplitBoxInverted )

         Containerhandle := _HMG_aFormReBarHandle [i]

      ENDIF

   ELSE

      ControlHandle := InitComboBoxEx ( ParentForm, 0, x, y, w, '', 0 , h, invisible, notabstop, .F. , displaychange, _HMG_IsXPorLater, aImages, ImageList )

      IF FontHandle != 0
         _SetFontHandle( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
      ENDIF

   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
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
            ComboAddStringEx ( ControlHandle, ( WorkArea )->&( cField ), 1 )
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

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _DataComboRefresh ( i )  // (JK) Modified for extend COMBO HMG 1.0 Build 8
*-----------------------------------------------------------------------------*
   LOCAL BackValue , BackRec , WorkArea , cField , ControlHandle

   IF Empty ( _HMG_aControlCaption [i] )
      BackValue := _GetValue ( , , i )
   ELSE
      cField := _HMG_aControlCaption [i]
      _HMG_aControlCaption [i] := ""
      BackValue := _GetValue ( , , i )
      _HMG_aControlCaption [i] := cField
   ENDIF

   cField := _HMG_aControlPageMap [i]

   ControlHandle := _HMG_aControlHandles [i]

   WorkArea := _HMG_aControlSpacing [i]

   BackRec := ( WorkArea )->( RecNo() )

   ( WorkArea )->( dbGoTop() )

   ComboboxReset ( ControlHandle )

   DO WHILE ! ( WorkArea )->( EOF() )  // (JK) HMG 1.0 Experimental Build 8
      IF  _HMG_aControlMiscData1 [i] [1] <> 1  // standard Combo
         ComboAddString ( ControlHandle , ( WorkArea )->&( cField ) )
      ELSE  // extend Combo
         ComboAddDataStringEx ( ControlHandle , ( WorkArea )->&( cField ) )
      ENDIF
      ( WorkArea )->( dbSkip() )
   ENDDO

   ( WorkArea )->( dbGoto( BackRec ) )

   IF BackValue > 0 .AND. BackValue <= ( WorkArea )->( LastRec() )
      _SetValue ( , , BackValue , i )
   ENDIF

RETURN
// (JK) HMG 1.0 Experimental Build 8e
*-----------------------------------------------------------------------------*
FUNCTION _SetGetDropDownWidth ( ControlName, ParentForm, nWidth )
*-----------------------------------------------------------------------------*
   LOCAL h

   IF _IsComboExtend( ControlName, ParentForm )
      h := _hmg_acontrolrangemax [ GetControlIndex ( ControlName, ParentForm ) ]
   ELSE
      h := GetControlHandle ( ControlName, ParentForm )
   ENDIF

   IF ISNUMERIC ( nWidth )
      IF nWidth == 0
         nWidth := GetWindowWidth ( GetControlHandle ( ControlName, ParentForm ) )
      ENDIF
      SetDropDownWidth ( h, nWidth )
   ELSE
      nWidth := GetDropDownWidth ( h )
   ENDIF

RETURN nWidth
