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

#define DTS_UPDOWN          0x0001 // use UPDOWN instead of MONTHCAL
#define DTS_SHOWNONE        0x0002 // allow a NONE selection
#define DTS_RIGHTALIGN      0x0020 // right-align popup instead of left-align it

*-----------------------------------------------------------------------------*
FUNCTION _DefineDatePick ( ControlName, ParentFormName, x, y, w, h, value, ;
      fontname, fontsize, tooltip, change, lostfocus, ;
      gotfocus, shownone, updown, rightalign, HelpId, ;
      invisible, notabstop , bold, italic, underline, strikeout , ;
      Field, Enter, backcolor, fontcolor, titlebkclr, titlefrclr, trlfontclr, cDateFormat, dRangeMin, dRangeMax, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , k , Style , blInit
   LOCAL ControlHandle , FontHandle , WorkArea
   LOCAL lDialogInMemory

   hb_default( @w, 120 )
   hb_default( @h, 24 )
   __defaultNIL( @value, CToD ( '  /  /  ' ) )
   __defaultNIL( @change, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF ValType ( Field ) != 'U'
      IF  At ( '>', Field ) == 0
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

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD

      IF shownone
         Style += DTS_SHOWNONE
      ENDIF

      IF updown
         Style += DTS_UPDOWN
      ENDIF

      IF rightalign
         Style += DTS_RIGHTALIGN
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF lDialogInMemory         //Dialog Template
         InitExCommonControls( 1 )

         //           {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogDatePicker( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "SysDateTimePick32", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

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

      ControlHandle := InitDatePick ( ParentFormHandle, 0, x, y, w, h , '' , 0 , shownone , updown , rightalign, invisible, notabstop )

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

      IF Empty ( Value )
         SetDatePickNull ( ControlHandle )
      ELSE
         SetDatePick( ControlHandle, Year( value ), Month( value ), Day( value ) )
      ENDIF

      IF ValType ( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      IF ValType ( Field ) != 'U'
         AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentFormName ) ] , k )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "DATEPICK"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  Enter
   _HMG_aControlPageMap  [k] :=  Field
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  BackColor
   _HMG_aControlFontColor  [k] :=  FontColor
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing  [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=  tooltip
   _HMG_aControlRangeMin [k] :=  0
   _HMG_aControlRangeMax [k] :=  0
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF IsArrayRGB( BackColor )
      SetDatePickBkColor( ControlHandle, BackColor[1], BackColor[2], BackColor[3] )
   ENDIF

   IF IsArrayRGB( FontColor )
      SetDatePickFontColor( ControlHandle, FontColor[1], FontColor[2], FontColor[3] )
   ENDIF

   IF IsArrayRGB( TitleBkClr )
      SetDatePickTitleBkColor( ControlHandle, TitleBkClr[1], TitleBkClr[2], TitleBkClr[3] )
   ENDIF

   IF IsArrayRGB( TitleFrClr )
      SetDatePickTitleFontColor( ControlHandle, TitleFrClr[1], TitleFrClr[2], TitleFrClr[3] )
   ENDIF

   IF IsArrayRGB( TrlFontClr )
      SetDatePickTrlFontColor( ControlHandle, TrlFontClr[1], TrlFontClr[2], TrlFontClr[3] )
   ENDIF

   IF ISCHARACTER( cDateFormat )

      IF SetDatePickerDateFormat( ControlHandle , cDateFormat )
         _HMG_aControlSpacing [k] := cDateFormat
      ELSE
         MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + ": Wrong format string." )
      ENDIF

   ELSE
      _HMG_aControlSpacing [k] := ""
   ENDIF

   IF ISDATE( dRangeMin ) .OR. ISDATE( dRangeMax )
      IF !_SetDatePickerRange( ControlHandle, dRangeMin, dRangeMax, k )
         MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + ": Wrong date range." )
      ENDIF
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineTimePick ( ControlName, ParentFormName, x, y, w, h, value, ;
      fontname, fontsize, tooltip, change, lostfocus, ;
      gotfocus, shownone, HelpId, ;
      invisible, notabstop , bold, italic, underline, strikeout , ;
      Field, Enter, cTimeFormat, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , k , Style , blInit
   LOCAL ControlHandle , FontHandle , WorkArea
   LOCAL lDialogInMemory

   hb_default( @w, 120 )
   hb_default( @h, 24 )
   __defaultNIL( @value, iif( shownone, "", Time() ) )
   __defaultNIL( @change, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @cTimeFormat, "HH:mm:ss" )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF ValType ( Field ) != 'U'
      IF  At ( '>', Field ) == 0
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

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD

      IF shownone
         Style += DTS_SHOWNONE
      ENDIF

      Style += DTS_UPDOWN

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF lDialogInMemory         //Dialog Template
         InitExCommonControls( 1 )

         //           {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogDatePicker( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "SysDateTimePick32", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

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

      ControlHandle := InitTimePick ( ParentFormHandle, 0, x, y, w, h , '' , 0 , shownone , invisible, notabstop )

   ENDIF

   IF .NOT. lDialogInMemory

      IF FontHandle != 0
         _SetFontHandle ( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF Empty ( Value )
         IF shownone
            SetDatePickNull ( ControlHandle )
         ELSE
            SetTimePick ( ControlHandle, Val( Left( Time(),2 ) ), Val( SubStr( Time(),4,2 ) ), Val( SubStr( Time(),7,2 ) ) )
         ENDIF
      ELSE
         SetTimePick ( ControlHandle, Val( Left( Value,2 ) ), Val( SubStr( Value,4,2 ) ), Val( SubStr( Value,7,2 ) ) )
      ENDIF

      IF ValType ( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      IF ValType ( Field ) != 'U'
         AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentFormName ) ] , k )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "TIMEPICK"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  Enter
   _HMG_aControlPageMap  [k] :=  Field
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  ""
   _HMG_aControlFontColor [k] :=  ""
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick [k] :=  {}
   _HMG_aControlRow   [k] :=  y
   _HMG_aControlCol   [k] :=  x
   _HMG_aControlWidth   [k] :=  w
   _HMG_aControlHeight   [k] :=  h
   _HMG_aControlSpacing   [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption   [k] :=  ''
   _HMG_aControlVisible  [k] :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF SetDatePickerDateFormat( ControlHandle , cTimeFormat )
      _HMG_aControlSpacing [k] := cTimeFormat
      IF AScan( _HMG_aControlFontAttributes [k], .T. ) > 0 .OR. ;
         FontName != _HMG_DefaultFontName .OR. FontSize != _HMG_DefaultFontSize
         _SetFontName ( ControlName, ParentFormName , fontname )
      ENDIF
   ELSE
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + ": Wrong format string." )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogDatePicker( ParentFormName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   ParentFormName := Nil
   ControlHandle  := Nil

   _SetValue ( ,  , _HMG_aControlValue [k] , k )
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate [3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetGetDatePickerDateFormat( ControlName, ParentForm, cFormat )
*-----------------------------------------------------------------------------*
   LOCAL ix

   IF ( ix := GetControlIndex ( ControlName, ParentForm ) ) > 0

      IF "PICK" $ _HMG_aControlType [ix]

         IF ISCHARACTER( cFormat )

            IF SetDatePickerDateFormat( _HMG_aControlHandles [ix], cFormat )
               _HMG_aControlSpacing [ix] := cFormat
            ENDIF

         ELSE

            cFormat := _HMG_aControlSpacing [ix]

         ENDIF

      ENDIF

   ENDIF

RETURN cFormat

*-----------------------------------------------------------------------------*
FUNCTION _SetDatePickerRange( ControlHandle, dRangeMin, dRangeMax, Index )
*-----------------------------------------------------------------------------*
   LOCAL lOK

   hb_default( @dRangeMin, CToD( '' ) )
   hb_default( @dRangeMax, CToD( '' ) )

   IF ( lOK := SetDatePickRange( ControlHandle, dRangeMin, dRangeMax ) )
      _HMG_aControlRangeMin [Index] := dRangeMin
      _HMG_aControlRangeMax [Index] := dRangeMax
   ENDIF

RETURN lOK
