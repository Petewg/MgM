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

#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION _DefineRadioGroup ( ControlName, ParentFormName, x, y, aOptions, Value, ;
      fontname, fontsize, tooltip, change, width, ;
      spacing, HelpId, invisible, notabstop, bold, italic, underline, strikeout, ;
      backcolor , fontcolor , transparent , horizontal , leftjustify , aReadOnly , aId )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , blInit , mVar , BackCol , BackRow , k , Style
   LOCAL aHandles[ 0 ], ControlHandle, FontHandle, n, lDialogInMemory

   hb_default( @Width, 120 )
   __defaultNIL( @change, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @horizontal, .F. )
   hb_default( @Spacing, iif( horizontal, 0, 25 ) )
   hb_default( @leftjustify, .F. )

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

   IF .NOT. _IsWindowDefined ( ParentFormName )  .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName )  .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF ValType ( aReadOnly ) != 'A'
      aReadOnly := Array ( Len( aOptions ) )
      AFill ( aReadOnly, .F. )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := BS_NOTIFY + WS_CHILD + BS_AUTORADIOBUTTON + WS_GROUP
      IF !notabstop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template
         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         style := BS_NOTIFY + WS_CHILD + BS_AUTORADIOBUTTON
         IF !invisible
            Style += WS_VISIBLE
         ENDIF
         aHandles := { 0 }

         BackCol := x
         BackRow := y

         FOR n := 1 TO Len( aId )

            blInit := iif( n == Len( aId ), {|x, y, z| InitDialogRadioGroup( x,y,z ) }, {|| Nil } )
            AAdd( _HMG_aDialogItems, { aId[n], k, "button", style, 0, x, y, width, spacing, aOptions[n], HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )
            IF horizontal
               x += Width + Spacing
            ELSE
               y += Spacing
            ENDIF
         NEXT

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, aId[1] )

         SetWindowStyle ( ControlHandle, Style, .T. )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         width := GetWindowWidth  ( Controlhandle )
         spacing := GetWindowHeight ( Controlhandle )

         FOR i := 1 TO Len ( aId )

            ControlHandle := GetDialogItemHandle( ParentFormHandle, aId[i] )
            SetWindowStyle ( ControlHandle, BS_NOTIFY + WS_CHILD + BS_AUTORADIOBUTTON, .T. )

            IF !invisible
               SetWindowStyle ( ControlHandle, WS_VISIBLE, .T. )
            ENDIF

            IF ValType( aOptions ) == "A"
               IF i <= Len( aOptions )
                  SetWindowText ( ControlHandle , aOptions[i] )
               ENDIF
            ENDIF

            IF FontHandle != 0
               _SetFontHandle( ControlHandle, FontHandle )
            ELSE
               __defaultNIL( @FontName, _HMG_DefaultFontName )
               __defaultNIL( @FontSize, _HMG_DefaultFontSize )
               FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
            ENDIF

            AAdd ( aHandles , ControlHandle )

         NEXT i

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      BackCol := x
      BackRow := y

      ControlHandle := InitRadioGroup ( ParentFormHandle, aOptions[1], 0, x, y , '' , 0 , width, invisible, notabstop , leftjustify )

      IF FontHandle != 0
         _SetFontHandle( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
      ENDIF

      AAdd ( aHandles , ControlHandle )

      FOR i := 2 TO Len ( aOptions )
         IF horizontal
            x += Width + Spacing
         ELSE
            y += Spacing
         ENDIF

         ControlHandle := InitRadioButton ( ParentFormHandle, aOptions[i], 0, x, y , '' , 0 , width, invisible , leftjustify )

         IF FontHandle != 0
            _SetFontHandle( ControlHandle, FontHandle )
         ELSE
            FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
         ENDIF

         AAdd ( aHandles , ControlHandle )

         IF ValType( tooltip ) != "U"
            SetToolTip ( aHandles [i] , tooltip , GetFormToolTipHandle ( ParentFormName ) )
         ENDIF

      NEXT i

   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , aHandles )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( aHandles [1] , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF
   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "RADIOGROUP"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  aHandles
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlIds  [k] :=  aId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] := aReadOnly
   _HMG_aControlValue  [k] :=  iif( ValType ( Value ) == 'N', Value, 0 )
   _HMG_aControlInputMask  [k] :=  transparent
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor [k] :=   backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  _HMG_ActiveTabButtons
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  BackRow
   _HMG_aControlCol  [k] :=  BackCol
   _HMG_aControlWidth  [k] :=  Width
   _HMG_aControlHeight  [k] :=  iif( horizontal, 28, Spacing * Len ( aOptions ) + GetBorderHeight() )
   _HMG_aControlSpacing  [k] :=  Spacing
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  .NOT. NoTabStop
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=   tooltip
   _HMG_aControlRangeMin  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveTabName , '' )
   _HMG_aControlRangeMax  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameParentFormName [_HMG_FrameLevel] , '' )
   _HMG_aControlCaption  [k] :=   aOptions
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := horizontal
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF .NOT. lDialogInMemory
      IF ValType ( Value ) == 'N' .AND. Value > 0  // EF 93
         _SetValue ( , , Value , k )
      ENDIF
      _SetRadioGroupReadOnly ( ControlName , ParentFormName , aReadOnly )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogRadioGroup( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL aHandles , Value

   HB_SYMBOL_UNUSED( ControlHandle )

   aHandles := _HMG_aControlHandles [k]
   Value    := _HMG_aControlValue [k]
// EF 93
   IF ValType ( Value ) == 'N' .AND. Value > 0
      _SetValue ( , , Value , k )
   ENDIF
//JP V40
   IF Len( _HMG_aControlIds [k] ) == Len( aHandles ) .AND. ValType( ParentName ) <> 'U'
      _SetRadioGroupReadOnly ( _HMG_aControlNames [k] , ParentName , _HMG_aControlPageMap [k] )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _SetRadioGroupReadOnly ( ControlName , ParentForm , aReadOnly )
*-----------------------------------------------------------------------------*
   LOCAL z , aHandles , aOptions , lError := .F.
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   aHandles := _HMG_aControlHandles [i]
   aOptions := _HMG_aControlCaption [i]

   IF ValType ( aReadOnly ) == 'A'
      IF Len ( aReadOnly ) == Len ( aOptions )
         FOR z := 1 TO Len ( aReadOnly )
            IF ValType ( aReadOnly [z] ) == 'L'
               IF aReadOnly [z]
                  DisableWindow ( aHandles [z] )
               ELSE
                  EnableWindow ( aHandles [z] )
               ENDIF
            ELSE
               lError := .T.
               EXIT
            ENDIF
         NEXT z
      ELSE
         lError := .T.
      ENDIF
   ELSE
      lError := .T.
   ENDIF

   IF .NOT. lError
      _HMG_aControlPageMap [i] := aReadOnly
   ENDIF

RETURN
