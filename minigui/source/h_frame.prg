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

*-----------------------------------------------------------------------------*
STATIC FUNCTION _DefineFrame ( ControlName, ParentFormName, x, y, w, h , caption , fontname , fontsize , opaque , bold, italic, underline, strikeout , backcolor , fontcolor , transparent , invisible , nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , k , Style
   LOCAL ControlHandle , FontHandle
   LOCAL lDialogInMemory

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
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

      style := WS_CHILD + BS_GROUPBOX + BS_NOTIFY

      IF !invisible
         style += WS_VISIBLE
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems

         AAdd( _HMG_aDialogItems, { nId, k, "button", style, 0, x, y, w, h, caption, , , FontName, FontSize, bold, italic, underline, strikeout, , _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )
         IF _HMG_aDialogTemplate[3]   // Modal
            _HMG_aControlDeleted [k] := .T.
            RETURN Nil
         ENDIF

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         IF ValType( caption ) != "U"
            SetWindowText ( ControlHandle , caption )
         ENDIF

         SetWindowStyle ( ControlHandle, style, .T. )
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      Controlhandle := InitFrame ( ParentFormHandle, 0, x, y, w, h , caption , '' , 0 , opaque )

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

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "FRAME"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  transparent
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] := _HMG_ActiveTabButtons .OR. opaque
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveTabName , '' )
   _HMG_aControlRangeMax  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameParentFormName [_HMG_FrameLevel] , '' )
   _HMG_aControlCaption  [k] :=   Caption
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId   [k] :=  0
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF invisible
      _HideControl ( ControlName , ParentFormName )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _BeginFrame( name , parent , row , col , w , h , caption , fontname , fontsize , opaque , bold, italic, underline, strikeout , backcolor , fontcolor , transparent , invisible , nId )
*-----------------------------------------------------------------------------*

   IF _HMG_BeginWindowActive
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      col    := col + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      row    := row + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      Parent := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF ValType ( parent ) == 'U'
      IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
         Parent := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      ENDIF
   ENDIF

   hb_default( @caption, "" )
   IF Empty ( caption )
      fontname := "Arial"
      fontsize := 1
   ENDIF

   hb_default( @w, 140 )
   hb_default( @h, 140 )

   _DefineFrame ( name , parent , col , row , w , h , caption , fontname , fontsize , opaque , bold, italic, underline, strikeout , backcolor , fontcolor , transparent , invisible , nId )

RETURN Nil
