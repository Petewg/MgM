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

*-----------------------------------------------------------------------------*
FUNCTION _DefineEditbox ( ControlName, ParentFormName, x, y, w, h, value, ;
      fontname, fontsize, tooltip, maxlength, gotfocus, change, lostfocus, readonly, break, HelpId, ;
      invisible, notabstop, bold, italic, underline, strikeout, field, backcolor, fontcolor, novscroll, nohscroll, nId )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , mVar , ContainerHandle := 0 , k , Style
   LOCAL ControlHandle , FontHandle , WorkArea , blInit
   LOCAL lDialogInMemory

   hb_default( @w, 120 )
   hb_default( @h, 240 )
   hb_default( @value, "" )
   __defaultNIL( @change, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @gotfocus, "" )
   hb_default( @maxlength, 64738 )
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

      Style := ES_MULTILINE + ES_WANTRETURN + WS_CHILD + WS_BORDER

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF !novscroll
         Style += WS_VSCROLL
      ELSE
         Style += ES_AUTOVSCROLL
      ENDIF

      IF !nohscroll
         Style += WS_HSCROLL
      ENDIF

      IF lDialogInMemory         //Dialog Template

         blInit := {|x, y, z| InitDialogEdit( x, y, z ) }

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         AAdd( _HMG_aDialogItems, { nId, k, "edit", style, 0, x, y, w, h, value, HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )


         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         IF ValType ( Value ) == 'C' .OR. ValType ( Value ) == 'M'
            IF .NOT. Empty ( Value )
               SetWindowText ( ControlHandle , value )
            ENDIF
         ENDIF
         SetWindowStyle ( ControlHandle, Style, .T. )

      ENDIF
   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      IF ValType( x ) == "U" .OR. ValType( y ) == "U"

         IF _HMG_SplitLastControl == 'TOOLBAR'
            Break := .T.
         ENDIF

         _HMG_SplitLastControl := 'EDIT'

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            ControlHandle := InitEditBox ( ParentFormHandle , 0, x, y, w, h, '', 0 , maxlength , readonly, invisible, notabstop , novscroll , nohscroll )

            IF FontHandle != 0
               _SetFontHandle( ControlHandle, FontHandle )
            ELSE
               __defaultNIL( @FontName, _HMG_DefaultFontName )
               __defaultNIL( @FontSize, _HMG_DefaultFontSize )
               FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
            ENDIF
            AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , w , break , , , , _HMG_ActiveSplitBoxInverted )
            Containerhandle := _HMG_aFormReBarHandle [i]

            IF ValType ( Value ) == 'C';
                  .OR. ;
                  ValType ( Value ) == 'M'

               IF .NOT. Empty ( Value )
                  SetWindowText ( ControlHandle , value )
               ENDIF

            ENDIF

         ENDIF

      ELSE

         ControlHandle := InitEditBox ( ParentFormHandle, 0, x, y, w, h, '', 0 , maxlength , readonly, invisible, notabstop , novscroll , nohscroll )

         IF ValType ( Value ) == 'C';
               .OR. ;
               ValType ( Value ) == 'M'

            IF .NOT. Empty ( Value )
               SetWindowText ( ControlHandle , value )
            ENDIF

         ENDIF

      ENDIF
   ENDIF

   IF .NOT. lDialogInMemory

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF FontHandle != 0
         _SetFontHandle( ControlHandle, FontHandle )
      ELSE
         __defaultNIL( @FontName, _HMG_DefaultFontName )
         __defaultNIL( @FontSize, _HMG_DefaultFontSize )
         FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF
   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] := "EDIT"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  Field
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure [k] :=   gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  ContainerHandle
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=   0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption  [k] :=   ''
   _HMG_aControlVisible  [k] :=   iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId   [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   FontHandle
   _HMG_aControlBrushHandle  [k] :=   0
   _HMG_aControlEnabled  [k] :=   .T.
   _HMG_aControlMiscData1 [k] := { 0 , maxlength , readonly }
   _HMG_aControlMiscData2 [k] := ''

   IF Len( _HMG_aDialogTemplate ) == 0        //Dialog Template
      InitDialogEdit( ParentFormName, ControlHandle, k )
   ENDIF

   IF ValType ( Field ) != 'U'
      AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentFormName ) ] , k )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _DataEditBoxRefresh ( i )
*-----------------------------------------------------------------------------*
   LOCAL Field := _HMG_aControlPageMap [i], icp

   IF ValType ( Field ) != 'U'
      _SetValue ( ,  , &Field , i )
   ELSE
      // Store Initial CaretPos
      icp := HiWord ( SendMessage( _HMG_aControlhandles [i] , EM_GETSEL , 0 , 0 ) )

      _SetValue ( ,  , _GetValue ( ,  , i ) , i )

      // Restore Initial CaretPos
      SendMessage( _HMG_aControlhandles [i] , EM_SETSEL , icp , icp )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION InitDialogEdit( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL maxlength , readonly
   ParentName := Nil

   maxlength := _HMG_aControlMiscData1 [k,2]
   readonly  := _HMG_aControlMiscData1 [k,3]

   IF ValType ( readonly ) == 'L'
      SendMessage( ControlHandle , EM_SETREADONLY , iif( readonly, 1, 0 ) , 0 )
   ENDIF
   IF ValType ( maxlength ) != 'U'
      SendMessage( ControlHandle , EM_LIMITTEXT , maxlength , 0 )
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate [3]  // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil
