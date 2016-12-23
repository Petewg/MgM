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

*-----------------------------------------------------------------------------*
FUNCTION _BeginPager( ControlName, ParentName, nWidth, nHeight, nScroll, cCaption, tooltip, vertical, autoscroll, backcolor )
*-----------------------------------------------------------------------------*
   LOCAL hRebar
   LOCAL ParentForm, ControlHandle,  mVar, k, Id

   DEFAULT nWidth       TO 0
   DEFAULT nHeight      TO 0
   DEFAULT nScroll      TO 5
   DEFAULT cCaption     TO ""
   DEFAULT Vertical     TO FALSE
   DEFAULT autoscroll   TO FALSE

   IF _HMG_BeginPagerActive
      MsgMiniGuiError( "DEFINE PAGER Structures can't be nested." )
   ENDIF

   IF _HMG_FrameLevel > 0
      MsgMiniGuiError( "PAGERBOX can't be defined inside Tab control." )
   ENDIF

   IF ValType ( ParentName ) == 'U' .AND. _HMG_BeginWindowActive
      ParentName := _HMG_ActiveFormName
   ENDIF
   IF .NOT. _IsWindowDefined ( ParentName )
      MsgMiniGuiError( "Window: " + ParentName + " is not defined." )
   ENDIF

   IF _HMG_SplitChildActive
      MsgMiniGuiError( "PAGERBOX Can't Be Defined inside SplitChild Windows." )
   ENDIF

   hRebar := _DefineSplitBox ( ParentName, .F. , vertical )

   _HMG_ActiveSplitBoxParentFormName := ParentName

   _HMG_BeginPagerActive := .T.

   ParentForm := GetFormHandle ( ParentName )

   ControlHandle := InitPager ( hRebar, nWidth, nHeight, vertical, autoscroll, cCaption )

   _HMG_ActivePagerForm := ControlHandle

   mVar := '_' + ParentName + '_' + ControlName
   Id := _GetId()

   IF ValType( tooltip ) != "U"
      SetToolTip ( ControlHandle, tooltip, GetFormToolTipHandle ( ParentName ) )
   ENDIF

   IF IsArrayRGB ( backcolor )
      SetBkColorPager ( ControlHandle, backcolor[1], backcolor[2], backcolor[3] )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType  [k] := "PAGER"
   _HMG_aControlNames   [k] := ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentForm
   _HMG_aControlIds  [k] :=  id
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask   [k] := ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor   [k] := backcolor
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick   [k] := ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  0
   _HMG_aControlCol  [k] :=  0
   _HMG_aControlWidth   [k] := nWidth
   _HMG_aControlHeight   [k] := nHeight
   _HMG_aControlSpacing   [k] := nScroll
   _HMG_aControlContainerRow  [k] :=  -1
   _HMG_aControlContainerCol  [k] :=  -1
   _HMG_aControlPicture   [k] := ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize   [k] := 0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip  [k] :=  tooltip
   _HMG_aControlRangeMin [k] :=  0
   _HMG_aControlRangeMax [k] :=  0
   _HMG_aControlCaption  [k] :=  cCaption
   _HMG_aControlVisible  [k] :=  .T.
   _HMG_aControlHelpId   [k] :=  0
   _HMG_aControlFontHandle  [k] :=  0
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  vertical
   _HMG_aControlMiscData2 [k] := ''

RETURN ControlHandle

*-----------------------------------------------------------------------------*
FUNCTION _EndPager()
*-----------------------------------------------------------------------------*
   _HMG_BeginPagerActive := .F.
   _HMG_ActiveSplitBoxParentFormName := ""
   _EndSplitBox ()

RETURN Nil

/*-----------------------------------------------------------------------------*
FUNCTION _AddChildToPager (  ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

   AddToPager ( _HMG_ActivePagerForm, c )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _Pager_ForwardMouse( ControlName , ParentForm, lEnable )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

   lEnable := IF( ValType( lEnable ) != 'L', .F. , lEnable )
   PagerForwardMouse( c, lEnable )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _Pager_GetButtonSize( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

RETURN PagerGetButtonSize( c )

*-----------------------------------------------------------------------------*
FUNCTION _Pager_SetButtonSize( ControlName , ParentForm, nSize )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

   PagerSetButtonSize( c, nSize )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _Pager_GetBorder( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

RETURN PagerGetBorder( c )

*-----------------------------------------------------------------------------*
FUNCTION _Pager_SetBorder( ControlName , ParentForm, nSize )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

RETURN PagerSetBorder( c, nSize )

*-----------------------------------------------------------------------------*
FUNCTION _Pager_GetPos( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

RETURN PagerGetPos( c )

*-----------------------------------------------------------------------------*
FUNCTION _Pager_SetPos( ControlName , ParentForm, nPos )
*-----------------------------------------------------------------------------*
   LOCAL c := GetControlHandle ( ControlName, ParentForm )

RETURN PagerSetPos( c, nPos )
*/