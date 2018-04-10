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
FUNCTION _DefineChkLabel ( ControlName, ParentFormName, x, y, Caption, w, h, ;
      fontname, fontsize, bold, BORDER, CLIENTEDGE, HSCROLL, VSCROLL, ;
      TRANSPARENT, aRGB_bk, aRGB_font, ProcedureName, tooltip, HelpId, invisible, ;
      italic, underline, strikeout, autosize, rightalign, centeralign, ;
      blink, mouseover, mouseleave, abitmap, leftcheck, lChecked, nId )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , k := 0, Style, blInit
   LOCAL ControlHandle , FontHandle, cBmp
   LOCAL lDialogInMemory

   DEFAULT w             TO 120
   DEFAULT h             TO 24
   DEFAULT ProcedureName TO {|| _SetValue( ControlName, ParentFormName, NIL ) }
   DEFAULT invisible     TO FALSE
   DEFAULT bold          TO FALSE
   DEFAULT italic        TO FALSE
   DEFAULT underline     TO FALSE
   DEFAULT strikeout     TO FALSE
   DEFAULT leftcheck     TO FALSE

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
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
      IF _HMG_IsThemed .AND. aRGB_bk == NIL
         Transparent := .T.
      ENDIF
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF ValType ( aBitmap ) != 'A'
      cBmp := aBitmap
      aBitmap := Array( 2 )
      aBitmap[ 1 ] := iif( Empty( cBmp ), GetCheckBmp(), cBmp )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      Style := WS_CHILD + SS_NOTIFY

      IF border
         Style += WS_BORDER
      ENDIF

      IF !invisible
         Style += WS_VISIBLE
      ENDIF

      IF HSCROLL
         Style += WS_HSCROLL
      ENDIF

      IF VSCROLL
         Style += WS_VSCROLL
      ENDIF

      IF rightalign
         Style += ES_RIGHT
      ENDIF

      IF centeralign
         Style += ES_CENTER
      ENDIF

      IF lDialogInMemory         //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogLabel( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "static", style, 0, x, y, w, h, caption, HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )


         IF ValType( caption ) != "U"
            SetWindowText ( ControlHandle , caption )
         ENDIF

         SetWindowStyle ( ControlHandle, Style, .T. )

/*          TODO

         if ( hb_parl (12) )
            {
            ExStyle = ExStyle | WS_EX_CLIENTEDGE;
               }

            if ( hb_parl (15) )
               {
               ExStyle = ExStyle | WS_EX_TRANSPARENT;
                  }
*/
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      Controlhandle := InitChkLabel ( ParentFormHandle, Caption, 0, x, y, w, h, '', 0, ;
         ( ValType( mouseover ) == "B" .OR. ValType( mouseleave ) == "B" ) , border , clientedge , ;
         HSCROLL , VSCROLL , TRANSPARENT , invisible , rightalign , centeralign, ;
         abitmap[ 1 ], abitmap[ 2 ], leftcheck, lChecked )

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

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_aControlType [k] :=  "CHECKLABEL"
   _HMG_aControlNames  [k] :=  ControlName
   _HMG_aControlHandles  [k] :=  ControlHandle
   _HMG_aControlParenthandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  ProcedureName
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue [k] :=   Nil
   _HMG_aControlInputMask  [k] :=  transparent
   _HMG_aControllostFocusProcedure  [k] :=  mouseleave
   _HMG_aControlGotFocusProcedure [k] :=  mouseover
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  aRGB_bk
   _HMG_aControlFontColor  [k] :=  aRGB_font
   _HMG_aControlDblClick   [k] := ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight   [k] :=  h
   _HMG_aControlSpacing  [k] :=  iif ( autosize == .T. , 1 , 0 )
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  abitmap
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip  [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption  [k] :=  Caption
   _HMG_aControlVisible  [k] :=  iif( invisible, FALSE, TRUE )
   _HMG_aControlHelpId  [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=  FontHandle
   _HMG_aControlBrushHandle   [k] :=  0
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  { 0, blink, .T. }
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   IF blink == .T. .AND. .NOT. lDialogInMemory
      _DefineTimer ( 'BlinkTimer' + hb_ntos( k ) , ParentFormName , 500 , {|| _HMG_aControlMiscData1 [k] [3] := ! _HMG_aControlMiscData1 [k] [3], ;
         iif( _HMG_aControlMiscData1 [k] [3] == .T. , _ShowControl ( ControlName , ParentFormName ), _HideControl ( ControlName , ParentFormName ) ) } )
   ENDIF

   IF autosize == .T. .AND. .NOT. lDialogInMemory
      _SetControlWidth ( ControlName , ParentFormName , GetTextWidth( NIL, Caption, FontHandle ) + ;
         iif( bold == .T. .AND. _HMG_IsThemed, GetTextWidth( NIL, " ", FontHandle ), 0 ) ) // Fixed for problem with display bold label at themed WinXP
      _SetControlHeight ( ControlName , ParentFormName , FontSize + iif( FontSize < 12, 12, 16 ) )
      RedrawWindow ( ControlHandle )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION GetCheckBmp()
*-----------------------------------------------------------------------------*
   LOCAL uAnsi, cBmp, nHandle, nWrite, cBmpFile

   LOCAL cStock := ; // check bmp
      "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ;
      "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
      "00 00 80 00 00 00 C4 0E 00 00 C4 0E 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 FF FF FF FF FF FF FF FF FF FF" + ;
      "FF 7F FF FF FF FF FF FF F8 07 FF FF FF FF FF FF" + ;
      "80 00 7F FF FF FF FF FF 80 00 78 FF FF FF FF F8" + ;
      "00 70 08 FF FF FF FF 80 07 80 07 8F FF FF F8 00" + ;
      "7F F7 00 8F FF FF F8 07 8F F8 00 78 FF FF F8 8F" + ;
      "FF FF 70 07 8F FF FF FF FF FF 87 00 7F FF FF FF" + ;
      "FF FF F8 70 07 FF FF FF FF FF FF 87 00 8F FF FF" + ;
      "FF FF FF F8 70 8F FF FF FF FF FF FF 88 8F FF FF" + ;
      "FF FF FF FF FF FF"

   uAnsi := StrTran( cStock, " " )
   cBmp := cAnsi2Bmp( uAnsi )
   cBmpFile := TempFile( GetTempFolder(), "BMP" )

   IF File( cBmpFile )
      FErase( cBmpFile )
   ENDIF

   IF ( nHandle := FCreate( cBmpFile ) ) < 0
      RETURN ''
   ENDIF

   nWrite := Len( cBmp )

   IF FWrite( nHandle, cBmp, nWrite ) < nWrite
      cBmpFile := ''
   ENDIF

   FClose( nHandle )

RETURN cBmpFile

// ============================================================================
// FUNCTION cAnsi2Bmp() Version 9.0 Nov/30/2009
// ============================================================================
STATIC FUNCTION cAnsi2Bmp( cAnsi )

   LOCAL cLong, ;
      cBmp := ""

   WHILE Len( cAnsi ) >= 8
      cLong := Left( cAnsi, 8 )
      cBmp += cHex2Bin( cAnsi2Hex( cLong ) )
      cAnsi := Stuff( cAnsi, 1, 8, "" )
   ENDDO

   IF ! Empty( cAnsi )
      cBmp += cHex2Bin( cAnsi2Hex( PadR( cAnsi, 4, "0" ) ) )
   ENDIF

RETURN cBmp

// ============================================================================
// FUNCTION cAnsi2Hex() Version 9.0 Nov/30/2009
// ============================================================================
STATIC FUNCTION cAnsi2Hex( cAnsi )

   LOCAL cDig, ;
      cHex := ""

   cAnsi := AllTrim( cAnsi )

   WHILE Len( cAnsi ) >= 2
      cDig := Left( cAnsi, 2 )
      cHex := cDig + cHex
      cAnsi := Stuff( cAnsi, 1, 2, "" )
   ENDDO

RETURN cHex

// ============================================================================
// FUNCTION cHex2Bin() Version 9.0 Nov/30/2009
// ============================================================================
STATIC FUNCTION cHex2Bin( cHex )

   LOCAL nPos, nEle, ;
      nExp := 0, ;
      nDec := 0, ;
      aHex := { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }

   cHex := AllTrim( cHex )

   FOR nPos := Len( cHex ) TO 1 Step - 1
      nEle := Max( 0, AScan( aHex, SubStr( cHex, nPos, 1 ) ) - 1 )
      nDec += ( nEle * ( 16 ** nExp ) )
      nExp ++
   NEXT

RETURN iif( Len( cHex ) > 4, L2Bin( Int( nDec ) ), iif( Len( cHex ) > 2, I2Bin( Int( nDec ) ), Chr( Int( nDec ) ) ) )
