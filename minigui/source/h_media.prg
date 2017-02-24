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
FUNCTION _DefinePlayer ( ControlName, ParentFormName, file, x, y, w, h, noasw, noasm, noed, nom, noo, nop, sha, shm, shn, shp, HelpId )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle , mVar , k

   IF _HMG_BeginWindowActive
      ParentFormName := _HMG_ActiveFormName
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x    := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y    := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentFormName )
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName

   ControlHandle := InitPlayer ( GetFormHandle( ParentFormName ) , ;
      file         , ;
      x            , ;
      y            , ;
      w            , ;
      h            , ;
      noasw        , ;
      noasm        , ;
      noed         , ;
      nom          , ;
      noo          , ;
      nop          , ;
      sha          , ;
      shm          , ;
      shn          , ;
      shp )

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
   ENDIF

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType  [k] := "PLAYER"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  GetFormHandle( ParentFormName )
   _HMG_aControlIds  [k] :=  0
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick   [k] := ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=   0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle  [k] :=   0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

RETURN Nil
*-----------------------------------------------------------------------------*
FUNCTION PlayWave( wave, r, s, ns, l, nd )
*-----------------------------------------------------------------------------*
   IF PCount() == 1
      r := s := ns := l := nd := .F.
   ENDIF

RETURN C_PlayWave( wave, r, s, ns, l, nd )

*-----------------------------------------------------------------------------*
FUNCTION _DefineAnimateBox( ControlName, ParentFormName, x, y, w, h, autoplay, center, transparent, file, HelpId, border, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , blInit , ControlHandle , mVar , k , tooltip := '' , Style
   LOCAL lDialogInMemory

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
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

      style := WS_CHILD + WS_TABSTOP + WS_VISIBLE

      IF border
         Style += WS_BORDER
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout,blInit,.f.}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogAnimateBox( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "SysAnimate32", style, 0, x, y, w, h, "", HelpId, tooltip, "", 0, , , , , blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )
         SetWindowStyle ( ControlHandle, Style, .T. )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )
      ControlHandle := InitAnimate( ParentFormHandle, x, y, w, h, autoplay, center, transparent, border )

   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF
   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] :=  "ANIMATEBOX"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] := nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle   [k] := 0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=   0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption  [k] :=   file
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      IF ValType( file ) <> 'U'
         _OpenAnimateBox ( ControlName , ParentFormName , File )
      ENDIF
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogAnimateBox( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL File
   File := _HMG_aControlCaption [k]
   IF ValType( file ) <> 'U' .AND. ValType( ControlHandle ) <> 'U'
      _OpenAnimateBox ( _HMG_aControlNames [k] , ParentName , File )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate [3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil
