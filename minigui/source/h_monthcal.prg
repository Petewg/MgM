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

#define MCS_WEEKNUMBERS     0x0004
#define MCS_NOTODAYCIRCLE   0x0008
#define MCS_NOTODAY         0x0010

*-----------------------------------------------------------------------------*
FUNCTION _DefineMonthCal ( ControlName, ParentFormName, x, y, w, h, value, ;
      fontname, fontsize, tooltip, notoday, notodaycircle, weeknumbers, change, ;
      HelpId, invisible, notabstop, bold, italic, underline, strikeout, ;
      backcolor, fontcolor, titlebkclr, titlefrclr, background, trlfontclr, ;
      select, gotfocus, lostfocus, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, mVar, k, Style, blInit
   LOCAL aControlHandle := { 0, 0 }
   LOCAL lDialogInMemory

   __defaultNIL( @value, Date() )
   __defaultNIL( @change, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @bold, .F. )
   hb_default( @italic, .F. )
   hb_default( @underline, .F. )
   hb_default( @strikeout, .F. )

   IF ( aControlHandle[2] := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( aControlHandle[2], @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
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

      Style := WS_BORDER + WS_CHILD

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF notoday
         Style += MCS_NOTODAY
      ENDIF

      IF notodaycircle
         Style += MCS_NOTODAYCIRCLE
      ENDIF

      IF weeknumbers
         Style += MCS_WEEKNUMBERS
      ENDIF

      IF lDialogInMemory         //Dialog Template
         InitExCommonControls( 1 )

         //           {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogMonthCalendar( x, y, z ) }

         AAdd( _HMG_aDialogItems, { nId, k, "SysMonthCal32", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         aControlHandle[1] := GetDialogItemHandle( ParentFormHandle, nId )

         SetWindowStyle ( aControlHandle[1], style, .T. )

         IF aControlHandle[2] != 0
            _SetFontHandle( aControlHandle[1], aControlHandle[2] )
         ELSE
            __defaultNIL( @FontName, _HMG_DefaultFontName )
            __defaultNIL( @FontSize, _HMG_DefaultFontSize )
            aControlHandle[2] := _SetFont ( aControlHandle[1], FontName, FontSize, bold, italic, underline, strikeout )
         ENDIF

         x := GetWindowCol ( aControlHandle[1] )
         y := GetWindowRow ( aControlHandle[1] )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )

      aControlHandle := InitMonthCal ( ParentFormHandle, 0, x, y, w, h , fontname , fontsize , notoday , notodaycircle , weeknumbers, invisible, notabstop, bold, italic, underline, strikeout )

   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , aControlhandle[1] )
      ENDIF

      SetMonthCalValue( aControlHandle[1], Year( value ), Month( value ), Day( value ) )

      IF ValType( tooltip ) != "U"
         SetToolTip ( aControlHandle[1] , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      w := GetWindowWidth ( aControlHandle[1] )
      h := GetWindowHeight ( aControlHandle[1] )
   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] :=  "MONTHCAL"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  aControlHandle[1]
   _HMG_aControlParentHandles [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  BackColor
   _HMG_aControlFontColor  [k] :=  FontColor
   _HMG_aControlDblClick  [k] :=  iif ( IsVistaOrLater(), select, "" )
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] :=  w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=   0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption   [k] :=  ''
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   aControlHandle[2]
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF IsArrayRGB( BackColor )
      SetMonthCalMonthBkColor( aControlHandle[1], BackColor[1], BackColor[2], BackColor[3] )
   ENDIF

   IF IsArrayRGB( FontColor )
      SetMonthCalFontColor( aControlHandle[1], FontColor[1], FontColor[2], FontColor[3] )
   ENDIF

   IF IsArrayRGB( TitleBkClr )
      SetMonthCalTitleBkColor( aControlHandle[1], TitleBkClr[1], TitleBkClr[2], TitleBkClr[3] )
   ENDIF

   IF IsArrayRGB( TitleFrClr )
      SetMonthCalTitleFontColor( aControlHandle[1], TitleFrClr[1], TitleFrClr[2], TitleFrClr[3] )
   ENDIF

   IF IsArrayRGB( BackGround )
      SetMonthCalBkColor( aControlHandle[1], BackGround[1], BackGround[2], BackGround[3] )
   ENDIF

   IF IsArrayRGB( TrlFontClr )
      SetMonthCalTrlFontColor( aControlHandle[1], TrlFontClr[1], TrlFontClr[2], TrlFontClr[3] )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogMonthCalendar( ParentFormName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   ParentFormName := Nil

   SetPosMonthCal ( ControlHandle , _HMG_aControlCol [k] , _HMG_aControlRow [k] )
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION OMONTHCALEVENTS( hWnd, nMsg, wParam, lParam )    // GF 2016.04.02
*-----------------------------------------------------------------------------*
   LOCAL i := AScan ( _HMG_aControlHandles , hWnd )

   HB_SYMBOL_UNUSED( wParam )
   HB_SYMBOL_UNUSED( lParam )

   SWITCH nMsg

   CASE WM_MOUSEACTIVATE

      SetFocus( hWnd )

      RETURN 1

   CASE WM_SETFOCUS

      VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
      _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )

      EXIT

   CASE WM_KILLFOCUS

      _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )

   ENDSWITCH

RETURN 0
