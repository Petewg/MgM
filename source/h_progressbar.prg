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

#define PBS_SMOOTH              0x01
#define PBS_VERTICAL            0x04
#define PBS_MARQUEE             0x08
#define PBM_SETMARQUEE          (WM_USER+10)

*-----------------------------------------------------------------------------*
FUNCTION _DefineProgressBar ( ControlName, ParentFormName, x, y, w, h, lo, hi, ;
      tooltip, vertical, smooth, HelpId, invisible, value, BackColor, BarColor, marquee, velocity, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle, blInit, mVar, ControlHandle, k, Style
   LOCAL lDialogInMemory

   hb_default( @vertical, .F. )
   hb_default( @h, iif( vertical, 120, 25 ) )
   hb_default( @w, iif( vertical, 25, 120 ) )
   hb_default( @lo, 0 )
   hb_default( @hi, 100 )
   hb_default( @value, 0 )
   hb_default( @velocity, 40 )
   hb_default( @invisible, .F. )

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
      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF vertical
         Style += PBS_VERTICAL
      ENDIF

      IF smooth
         Style += PBS_SMOOTH
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogProgressBar( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "msctls_progress32", style, 0, x, y, w, h, "", HelpId, tooltip, "", 0, , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

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

      ControlHandle := InitProgressBar ( ParentFormHandle, 0, x, y, w, h , lo , hi, vertical, smooth, invisible, value )

   ENDIF

   IF .NOT. lDialogInMemory

      SendMessage( ControlHandle , PBM_SETPOS , value , 0 )

      IF marquee
         IF _HMG_IsXPorLater .AND. IsThemed()
            ChangeStyle( ControlHandle , PBS_MARQUEE )
            SendMessage( ControlHandle , PBM_SETMARQUEE , iif( velocity > 0, 1, 0 ) , velocity )
         ENDIF
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "PROGRESSBAR"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParentHandles [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  FALSE
   _HMG_aControlBkColor  [k] :=  BackColor
   _HMG_aControlFontColor  [k] :=  BarColor
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName [k] :=   ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { FALSE, FALSE, FALSE, FALSE }
   _HMG_aControlToolTip  [k] :=   tooltip
   _HMG_aControlRangeMin  [k] :=   Lo
   _HMG_aControlRangeMax  [k] :=   Hi
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   0
   _HMG_aControlBrushHandle  [k] :=   0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      IF IsArrayRGB( BackColor )
         SetProgressBarBkColor( ControlHandle, BackColor[1], BackColor[2], BackColor[3] )
      ENDIF

      IF IsArrayRGB( BarColor )
         SetProgressBarBarColor( ControlHandle, BarColor[1], BarColor[2], BarColor[3] )
      ENDIF
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogProgressBar( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL BackColor, BarColor

   BackColor := _HMG_aControlBkColor [k]
   BarColor  := _HMG_aControlFontColor [k]

   IF ValType( ParentName ) <> 'U'
      SendMessage( ControlHandle , PBM_SETPOS , _HMG_aControlValue [k] , 0 )
   ENDIF

   IF IsArrayRGB( BackColor )
      SetProgressBarBkColor( ControlHandle, BackColor[1], BackColor[2], BackColor[3] )
   ENDIF

   IF IsArrayRGB( BarColor )
      SetProgressBarBarColor( ControlHandle, BarColor[1], BarColor[2], BarColor[3] )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil
