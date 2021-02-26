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

#define SB_SETTEXT      (WM_USER+1)
#define SBT_OWNERDRAW   0x1000

#define ITEMTYPENAME	"ITEMMESSAGE"
#define ITEMNAME	"StatusItem"
#define PROGRESSNAME	"ProgressMessage"

*-----------------------------------------------------------------------------*
FUNCTION _BeginMessageBar( ControlName, ParentForm, kbd, fontname, fontsize, bold, italic, underline, strikeout )
*-----------------------------------------------------------------------------*
   LOCAL mVar , k , ParentFormHandle , aRect := { 0, 0, 0, 0 }
   LOCAL ControlHandle , FontHandle

   _HMG_ActiveMessageBarName  := ControlName

   IF ValType ( ParentForm ) == 'U'
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   ParentFormHandle := GetFormHandle ( ParentForm )

   ControlHandle := InitMessageBar ( ParentFormHandle, "", 0 )

   _HMG_ActiveStatusHandle := ControlHandle // New Public Value JP MDI

   IF FontHandle != 0
      _SetFontHandle( ControlHandle, FontHandle )
   ELSE
      __defaultNIL( @FontName, _HMG_DefaultFontName )
      __defaultNIL( @FontSize, _HMG_DefaultFontSize )
      FontHandle := _SetFont ( ControlHandle, FontName, FontSize, bold, italic, underline, strikeout )
   ENDIF

   GetClientRect ( ControlHandle, /*@*/aRect )

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] := "MESSAGEBAR"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  0
   _HMG_aControlProcedures  [k] :=  ''
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow   [k] := 0
   _HMG_aControlCol   [k] := 0
   _HMG_aControlWidth   [k] := aRect[3]
   _HMG_aControlHeight  [k] := aRect[4]
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  -1
   _HMG_aControlContainerCol  [k] :=  -1
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] := ''
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  .T.
   _HMG_aControlHelpId  [k] :=  0
   _HMG_aControlFontHandle  [k] :=  FontHandle
   _HMG_aControlBrushHandle [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   _HMG_StatusItemCount := 0

   IF kbd
      _SetStatusBarKbd ( ControlName, ParentForm )
   ENDIF

RETURN Nil
*-----------------------------------------------------------------------------*
FUNCTION _EndMessageBar()
*-----------------------------------------------------------------------------*
   LOCAL i

   // Must have at least one StatusItem to prevent crash when function Events(...) receives WM_SIZE message
   IF _HMG_StatusItemCount == 0  // JD 07/20/2007
      _DefineItemMessage( ITEMNAME, _HMG_ActiveMessageBarName, 0, 0, GetProperty( _HMG_ActiveFormName, "Title" ), , , 0, , , , .F. )
   ENDIF
   IF ( i := GetControlIndex( PROGRESSNAME, _HMG_ActiveFormName ) ) != 0
      RefreshProgressItem( _HMG_aControlMiscData1 [i,1], _HMG_aControlHandles [i], _HMG_aControlMiscData1 [i,2] )
   ENDIF
   _HMG_ActiveMessageBarName := ""
   _HMG_StatusItemCount      := 0

RETURN Nil
*-----------------------------------------------------------------------------*
FUNCTION _DefineItemMessage ( ControlName, ParentControl, x, y, Caption, ProcedureName, w, h, icon, cstyl, tooltip, default, backcolor, fontcolor, align )
*-----------------------------------------------------------------------------*
   LOCAL i , cParentForm, mVar, ParentForm, ParentFormHandle, k
   LOCAL ControlHandle, cCaption

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF
   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF
   IF ValType ( ParentControl ) == 'U'
      ParentControl := _HMG_ActiveMessageBarName
   ENDIF

   cParentForm := ParentForm
   ParentFormHandle := GetFormHandle ( ParentForm )

   mVar := '_' + ParentForm + '_' + ControlName

   ParentForm := GetControlHandle ( ParentControl, ParentForm )

   IF ValType( w ) == "U"
      w := Max( 70, GetTextWidth( NIL, Caption, _HMG_aControlFontHandle[ GetControlIndex( ParentControl, cParentForm ) ] ) + 6 )
   ENDIF

   hb_default( @cStyl, "" )
   hb_default( @default, .F. )
   hb_default( @align, 0 )

   IF ! Empty( ProcedureName )  // P.D. 24/11/2013
      cCaption := Upper ( Caption )

      i := At ( '&', cCaption )

      IF i > 0
         _DefineLetterOrDigitHotKey ( cCaption, i, cParentForm, ProcedureName )
      ENDIF

      Caption := StrTran ( Caption, '&', '' )
   ENDIF

   IF default
      _HMG_DefaultStatusBarMessage := Caption
   ENDIF

   IF ++_HMG_StatusItemCount == 1
      w := h := 0
   ELSE
      h := 1
   ENDIF

   ControlHandle := InitItemBar ( ParentForm, Caption, 0, w, h, Icon, ToolTip, iif( Upper( cStyl ) == "RAISED", 1, iif( Upper( cStyl ) == "FLAT", 2, 0 ) ) )

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] :=  ITEMTYPENAME
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles [k] :=  ParentFormHandle
   _HMG_aControlIds [k] :=  0
   _HMG_aControlProcedures  [k] :=  ProcedureName
   _HMG_aControlPageMap   [k] := {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor [k] :=  backcolor
   _HMG_aControlFontColor [k] :=  fontcolor
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] :=  h
   _HMG_aControlSpacing   [k] :=  align
   _HMG_aControlContainerRow  [k] :=  -1
   _HMG_aControlContainerCol  [k] :=  -1
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  ParentForm
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip  [k] :=   ToolTip
   _HMG_aControlRangeMin  [k] :=   0
   _HMG_aControlRangeMax  [k] :=   0
   _HMG_aControlCaption  [k] :=   Caption
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId   [k] :=  0
   _HMG_aControlFontHandle   [k] :=  0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF IsArrayRGB( backcolor ) .OR. IsArrayRGB( fontcolor )
      SendMessage( ParentForm, SB_SETTEXT, hb_BitOr( _HMG_StatusItemCount - 1, SBT_OWNERDRAW ), 0 )
   ENDIF

RETURN ControlHandle

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusClock ( BarName , FormName , Width , ToolTip , Action , lAMPM , backcolor , fontcolor )
*-----------------------------------------------------------------------------*
   LOCAL nrItem

   hb_default( @lAMPM, .F. )
   __defaultNIL( @Width, iif( lAMPM, 92, 70 ) )
   __defaultNIL( @ToolTip, "" )
   __defaultNIL( @Action, "" )

   nrItem := _DefineItemMessage ( "TimerBar", BarName, 0, 0, iif( lAMPM, AMPM( Time() ), Time() ), Action, Width, 0, , "", ToolTip, , backcolor, fontcolor, 1 )

   _DefineTimer ( 'StatusTimer' , FormName , 1000 , {|| _SetItem ( BarName , FormName , nrItem , iif( lAMPM, AMPM( Time() ), Time() ) ) } )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusKeybrd ( BarName , FormName , Width , ToolTip , action )
*-----------------------------------------------------------------------------*
   LOCAL nrItem1 , nrItem2 , nrItem3

   __defaultNIL( @Width, 75 )
   __defaultNIL( @ToolTip, "" )
   __defaultNIL( @Action, "" )

   nrItem1 := _DefineItemMessage( "TimerNum", BarName, 0, 0, "NumLock", ;
      iif( Empty( Action ), {|| iif( _HMG_IsXPorLater, KeyToggleNT( VK_NUMLOCK ), KeyToggle( VK_NUMLOCK ) ) }, Action ), Width + 20, 0, ;
      iif( IsNumLockActive(), "zzz_led_on", "zzz_led_off" ), "", ToolTip )

   nrItem2 := _DefineItemMessage( "TimerCaps", BarName, 0, 0, "CapsLock", ;
      iif( Empty( Action ), {|| iif( _HMG_IsXPorLater, KeyToggleNT( VK_CAPITAL ), KeyToggle( VK_CAPITAL ) ) }, Action ), Width + 25, 0, ;
      iif( IsCapsLockActive(), "zzz_led_on", "zzz_led_off" ), "", ToolTip )

   nrItem3 := _DefineItemMessage( "TimerInsert", BarName, 0, 0, "Insert", ;
      iif( Empty( Action ), {|| iif( _HMG_IsXPorLater, KeyToggleNT( VK_INSERT ), KeyToggle( VK_INSERT ) ) }, Action ), Width, 0, ;
      iif( IsInsertActive(), "zzz_led_on", "zzz_led_off" ), "", ToolTip )

   _DefineTimer ( 'StatusKeyBrd' , FormName , 250 , ;
      {|| _SetStatusIcon ( BarName , FormName , nrItem1 , iif ( IsNumLockActive() , "zzz_led_on" , "zzz_led_off" ) ), ;
      _SetStatusIcon ( BarName , FormName , nrItem2 , iif ( IsCapsLockActive() , "zzz_led_on" , "zzz_led_off" ) ), ;
      _SetStatusIcon ( BarName , FormName , nrItem3 , iif ( IsInsertActive() , "zzz_led_on" , "zzz_led_off" ) ) } )

RETURN Nil

#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
*-----------------------------------------------------------------------------*
FUNCTION _IsOwnerDrawStatusBarItem( ParentHandle , ItemID , Value , lSet )
*-----------------------------------------------------------------------------*
   LOCAL h, i, nLocID := 0, lOwnerDraw := .F.

   hb_default( @lSet, .F. )
   IF Empty( ItemID ) .OR. ItemID == NIL
      ItemID := 1
   ENDIF

   FOR EACH h IN _HMG_aControlContainerHandle
      i := hb_enumindex( h )
      IF _HMG_aControlType [i] == ITEMTYPENAME .AND. h == ParentHandle
         IF ++nLocID == ItemID
            lOwnerDraw := ( _HMG_aControlBkColor [i] != Nil .OR. _HMG_aControlFontColor [i] != Nil )
            IF lOwnerDraw
               IF lSet
                  _HMG_aControlCaption [i] := Value
               ELSE
                  Value := i
               ENDIF
            ENDIF
            EXIT
         ENDIF
      ENDIF
   NEXT

RETURN lOwnerDraw

// (GF) HMG 1.2 Extended Build 25
*-----------------------------------------------------------------------------*
STATIC FUNCTION AMPM( cTime )
*-----------------------------------------------------------------------------*
   LOCAL nHour := Val( cTime )

   DO CASE
   CASE nHour == 0 .OR. nHour == 24
      cTime := "12" + SubStr( cTime, 3 ) + " am"
   CASE nHour < 12
      cTime += " am"
   CASE nHour == 12
      cTime += " pm"
   OTHERWISE
      cTime := StrZero( nHour - 12, 2 ) + SubStr( cTime, 3 ) + " pm"
   ENDCASE

RETURN cTime

// (GF) HMG 1.2 Extended Build 30
*-----------------------------------------------------------------------------*
FUNCTION _SetStatusBarKbd ( BarName, FormName )
*-----------------------------------------------------------------------------*

   _DefineItemMessage ( ITEMNAME, BarName, 0, 0, GetProperty ( FormName, "Title" ), , , 0, , "RAISED" )

   _DefineItemMessage ( ITEMNAME, BarName, 0, 0, iif( IsCapsLockActive(), "CAP", "" ), , iif( _HMG_IsThemed, 38, 36 ), 0 )

   _DefineItemMessage ( ITEMNAME, BarName, 0, 0, iif( IsNumLockActive(), "NUM", "" ), , 42, 0 )

   _DefineItemMessage ( ITEMNAME, BarName, 0, 0, iif( IsScrollLockActive(), "SCRL", "" ), , 44, 0 )

   _DefineTimer ( "StatusBarKbd" , FormName , 250 , ;
      {|| _SetItem ( BarName, FormName, 2, iif( IsCapsLockActive()  , "CAP",  "" ) ), ;
      _SetItem ( BarName, FormName, 3, iif( IsNumLockActive()   , "NUM",  "" ) ), ;
      _SetItem ( BarName, FormName, 4, iif( IsScrollLockActive(), "SCRL", "" ) ) } )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetStatusItemWidth( hWnd, nItem )
*-----------------------------------------------------------------------------*
   LOCAL i, h, aItemWidth := {}

   FOR EACH h IN _HMG_aControlParentHandles
      i := hb_enumindex( h )
      IF _HMG_aControlType [i] == ITEMTYPENAME .AND. h == hWnd
         AAdd( aItemWidth, _HMG_aControlWidth [i] )
      ENDIF
   NEXT

RETURN iif( PCount() > 1, aItemWidth [nItem], aItemWidth )

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusItemProperty( nItem, Value, hWnd, nType )
*-----------------------------------------------------------------------------*
   LOCAL i, h, nIndex := 0

   FOR EACH h IN _HMG_aControlParentHandles
      i := hb_enumindex( h )
      IF _HMG_aControlType [i] == ITEMTYPENAME .AND. h == hWnd
         IF ++nIndex == nItem
            SWITCH nType
            CASE STATUS_ITEM_WIDTH
               _HMG_aControlWidth [i] := Value
               EXIT
            CASE STATUS_ITEM_ACTION
               _HMG_aControlProcedures [i] := Value
               EXIT
            CASE STATUS_ITEM_BACKCOLOR
               _HMG_aControlBkColor [i] := Value
               EXIT
            CASE STATUS_ITEM_FONTCOLOR
               _HMG_aControlFontColor [i] := Value
               EXIT
            CASE STATUS_ITEM_ALIGN
               _HMG_aControlSpacing [i] := Value
            ENDSWITCH
            IF nType > STATUS_ITEM_ACTION
               InvalidateRect( hWnd, 0 )
            ENDIF
            EXIT
         ENDIF
      ENDIF
   NEXT

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusProgressMessage ( BarName , FormName , Width , ToolTip , Action , nValue , nMin , nMax )
*-----------------------------------------------------------------------------*
   LOCAL i, NrItem, HwndStatus, hwndProgress

   hb_default( @nValue, 0 )
   hb_default( @nMin, 0 )
   hb_default( @nMax, 100 )
   __defaultNIL( @Width, 70 )
   __defaultNIL( @ToolTip, "" )
   __defaultNIL( @Action, "" )

   hwndStatus := GetControlHandle ( BarName, FormName )
   nrItem := _DefineItemMessage ( PROGRESSNAME, BarName, 0, 0, '', Action, Width, 0, , "", ToolTip )

   hwndProgress := CreateProgressBarItem ( hwndStatus, nrItem, nValue, nMin, nMax )
   i := GetControlIndex ( PROGRESSNAME, FormName )

   _HMG_aControlMiscData1 [i] := { hwndStatus, hwndProgress }
   _HMG_aControlRangeMin  [i] := nMin
   _HMG_aControlRangeMax  [i] := nMax
   _HMG_aControlValue     [i] := nValue

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusProgressPos ( FormName, nValue )
*-----------------------------------------------------------------------------*
   LOCAL i

   hb_default( @nValue, 0 )

   IF ( i := GetControlIndex ( PROGRESSNAME, FormName ) ) > 0
      SetPosProgressBarItem ( _HMG_aControlMiscData1 [i,2], nValue )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetStatusProgressRange ( FormName, nMin, nMax )
*-----------------------------------------------------------------------------*
   LOCAL i

   hb_default( @nMin, 0 )
   hb_default( @nMax, 100 )

   IF ( i := GetControlIndex ( PROGRESSNAME, FormName ) ) > 0
      SetProgressBarRange ( _HMG_aControlMiscData1 [i,2], nMin, nMax )
   ENDIF

RETURN Nil
