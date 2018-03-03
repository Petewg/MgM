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
FUNCTION _DefineSlider ( ControlName, ParentFormName, x, y, w, h, lo, hi, value, ;
   tooltip, scroll, change, vertical, noticks, both, top, left, HelpId, invisible, ;
   notabstop, backcolor, nId, enableselrange, nSelMin, nSelMax )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, Controlhandle, blInit, mVar, k, Style
   LOCAL lDialogInMemory

   hb_default( @w, iif( vertical, 35 + iif( both, 5, 0 ), 120 ) )
   hb_default( @h, iif( vertical, 120, 35 + iif( both, 5, 0 ) ) )
   hb_default( @value, Int( ( hi - lo ) / 2 ) )

   hb_default( @enableselrange, .F. ) /* P.Ch. 16.10. */
   hb_default( @nSelMin, 0 )  
   hb_default( @nSelMax, 0 )  

   __defaultNIL( @scroll, "" )
   __defaultNIL( @change, "" )
   hb_default( @invisible, .F. )
   hb_default( @notabstop, .F. )

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
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

      Style := WS_CHILD

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF vertical
         Style += TBS_VERT
      ENDIF

      IF !noticks
         Style += TBS_AUTOTICKS
      ELSE
         Style += TBS_NOTICKS
      ENDIF

      IF both
         Style += TBS_BOTH
      ENDIF
      IF top
         Style += TBS_TOP
      ENDIF
      IF left
         Style += TBS_LEFT
      ENDIF

      IF enableselrange
         Style += TBS_ENABLESELRANGE
      ENDIF

      IF Len( _HMG_aDialogTemplate ) > 0 //Dialog Template
         /* TODO */ /* P.Ch. 16.10. */

         // {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogSlider( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "msctls_trackbar32", style, 0, x, y, w, h, "", HelpId, tooltip, "", 0, , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE
         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol( Controlhandle )
         y := GetWindowRow( Controlhandle )
         w := GetWindowWidth( Controlhandle )
         h := GetWindowHeight( Controlhandle )

         SetWindowStyle( ControlHandle, Style, .T. )
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )
      /* P.Ch. 16.10. */
      ControlHandle := InitSlider( ParentFormHandle, 0, x, y, w, h, lo, hi, vertical, noticks, both, top, left, invisible, notabstop, enableselrange, nSelMin, nSelMax )

   ENDIF

   IF .NOT. lDialogInMemory
      IF _HMG_BeginTabActive
         AAdd( _HMG_ActiveTabCurrentPageMap, ControlHandle )
      ENDIF

      SendMessage( ControlHandle, TBM_SETPOS, 1, value )

      IF ValType( tooltip ) != "U"
         SetToolTip( ControlHandle, tooltip, GetFormToolTipHandle( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "SLIDER"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] := nId
   _HMG_aControlProcedures  [k] :=  scroll
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControlLostFocusProcedure [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure    [k] :=  change
   _HMG_aControlDeleted [k] :=  .F.
   _HMG_aControlBkColor [k] :=  backcolor
   _HMG_aControlFontColor [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  _HMG_ActiveTabButtons
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth   [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip  [k] :=  tooltip
   _HMG_aControlRangeMin [k] :=  Lo
   _HMG_aControlRangeMax [k] :=  Hi
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveTabName , '' )
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameParentFormName [_HMG_FrameLevel] , '' )
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogSlider( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*

   IF ValType( ParentName ) <> 'U'
      SendMessage( ControlHandle , TBM_SETPOS , 1 , _HMG_aControlValue [k] )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil
