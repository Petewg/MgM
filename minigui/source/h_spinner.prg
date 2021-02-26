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

#define EM_SETCUEBANNER       0x1501

*-----------------------------------------------------------------------------*
FUNCTION _DefineSpinner ( ControlName, ParentForm, x, y, w, value , fontname, ;
      fontsize, rl, rh, tooltip, change, lostfocus, gotfocus, h, HelpId, horizontal, invisible, notabstop, bold, ;
      italic, underline, strikeout, wrap, readonly, increment , backcolor , fontcolor , cuetext )
*-----------------------------------------------------------------------------*
   LOCAL cParentForm , RetArray , mVar , k
   LOCAL ControlHandle , FontHandle

   hb_default( @w, 120 )
   hb_default( @h, 24 )
   __defaultNIL( @value, rl )
   __defaultNIL( @change, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @horizontal, .F. )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )
   hb_default( @wrap, .F. )
   hb_default( @readonly, .F. )
   hb_default( @increment, 1 )

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF
   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentForm := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + IFNIL( ParentForm, "Parent", ParentForm ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm := GetFormHandle ( ParentForm )

   RetArray := InitSpinner( ParentForm, 0, x, y, w, '', 0, rl, rh, h, invisible, notabstop, wrap, readonly, horizontal )

   ControlHandle := RetArray [1]

   IF FontHandle != 0
      _SetFontHandle( ControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )
      FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , RetArray )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( cParentForm ) )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] := "SPINNER"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles [k] :=   RetArray
   _HMG_aControlParenthandles [k] :=   ParentForm
   _HMG_aControlIds  [k] :=  0
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  0
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure [k] :=   gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow [k] :=   y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing  [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName [k] :=   fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=   tooltip
   _HMG_aControlRangeMin  [k] :=   Rl
   _HMG_aControlRangeMax  [k] :=   Rh
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { 0, readonly }
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF !Empty ( cuetext ) .AND. IsVistaOrLater() .AND. IsThemed()
      value := ""
      SendMessageWideString ( ControlHandle, EM_SETCUEBANNER, .T., cuetext )
   ENDIF

   IF ValType( value ) == "N"
      SetSpinnerValue ( RetArray [2], Value )
   ENDIF

   IF increment <> 1
      SetSpinnerIncrement( RetArray [2], increment )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION OSPINEVENTS( hWnd, nMsg, wParam, lParam )    // 2006.08.13 JD
*-----------------------------------------------------------------------------*
   LOCAL i, ParentForm

   SWITCH nMsg

   CASE WM_GETDLGCODE

      IF _HMG_ExtendedNavigation
         IF wParam == 0x0D   // Return key pressed
            IF CheckBit( GetKeyState( VK_SHIFT ), 32768 ) // Is Shift key pressed?
               InsertShiftTab()
            ELSE
               InsertTab()
            ENDIF
         ENDIF
      ENDIF
      EXIT

   CASE WM_CONTEXTMENU

      i := AScan( _HMG_aControlHandles, { |x| iif( ValType( x ) == "A", ( AScan( x, hWnd ) > 0 ), x == hWnd ) } )
      ParentForm := _HMG_aControlParentHandles [i]
      i := AScan( _HMG_aControlsContextMenu, { |x| x [1] == hWnd } )
      IF i > 0
         IF _HMG_aControlsContextMenu [i] [4] == .T.
            setfocus( wParam )
            _HMG_xControlsContextMenuID := _HMG_aControlsContextMenu [i] [3]
            TrackPopupMenu ( _HMG_aControlsContextMenu [i] [2], LOWORD( lparam ), HIWORD( lparam ), ParentForm )
            RETURN 1
         ENDIF
      ENDIF

   ENDSWITCH

RETURN 0
