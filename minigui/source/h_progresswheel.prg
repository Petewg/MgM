/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

PROGRESSWHEEL Control Source Code
Copyright 2020 Grigory Filatov <gfilatov@inbox.ru>

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
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
#define __MINIPRINT__
#endif

#include "hmg.ch"

#ifndef HMG_LEGACY_OFF
#undef _BT_
#endif

#ifdef _BT_
#include "i_winuser.ch"

#define Left       aRect[1]
#define Right      aRect[2]
#define Top        aRect[3]
#define Bottom     aRect[4]

STATIC BufScale := 3
STATIC hGradient
STATIC aRect := { 0, 0, 0, 0 }

*------------------------------------------------------------------------------*
FUNCTION _DefineProgressWheel ( cControlName, cParentForm, nCol, nRow, nWidth, ;
      nHeight, nPosition, nStartAngle, nInnerSize, nGradientMode, lShowText, ;
      nMin, nMax, nColorDoneMin, nColorDoneMax, nColorRemain, nColorInner )
*------------------------------------------------------------------------------*
   LOCAL nParentFormHandle
   LOCAL nControlHandle
   LOCAL nId
   LOCAL cImageName
   LOCAL mVar
   LOCAL k

   // If defined inside DEFINE WINDOW structure, determine cParentForm
   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      cParentForm := iif ( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
   ENDIF

   IF .NOT. _IsWindowDefined ( cParentForm )
      MsgMiniGuiError ( "Window: " + cParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( cControlName, cParentForm )
      MsgMiniGuiError ( "Control: " + cControlName + " Of " + cParentForm + " Already defined." )
   ENDIF

   hb_default( @nPosition, 0 )
   hb_default( @nStartAngle, 0 )
   hb_default( @nInnerSize, 75 )
   hb_default( @nGradientMode, 1 )
   hb_default( @lShowText, .T. )
   hb_default( @nMin, 0 )
   hb_default( @nMax, 100 )
   __defaultNIL( @nColorDoneMin, MAROON )
   __defaultNIL( @nColorDoneMax, RED )
   __defaultNIL( @nColorRemain, SILVER )
   __defaultNIL( @nColorInner, WHITE )

   nColorDoneMin := HMG_RGB2n( nColorDoneMin )
   nColorDoneMax := HMG_RGB2n( nColorDoneMax )
   nColorRemain := HMG_RGB2n( nColorRemain )
   nColorInner := HMG_RGB2n( nColorInner )

   nId := _GetId()

   cImageName := cControlName + hb_ntos( nId )

   @ nROW, nCol IMAGE ( cImageName ) PARENT ( cParentForm ) PICTURE NIL ;
      WIDTH nWidth HEIGHT nHeight

   nControlHandle := GetControlHandle ( cImageName, cParentForm )

   // Define public variable associated with control
   mVar := '_' + cParentForm + '_' + cControlName

   nParentFormHandle := GetFormHandle ( cParentForm )

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_aControlType[ k ] := "PROGRESSWHEEL"
   _HMG_aControlNames[ k ] := cControlName
   _HMG_aControlHandles[ k ] := nControlHandle
   _HMG_aControlParentHandles[ k ] := nParentFormHandle
   _HMG_aControlIds[ k ] := nId
   _HMG_aControlProcedures[ k ] := cImageName
   _HMG_aControlPageMap[ k ] := {}
   _HMG_aControlValue[ k ] := nPosition
   _HMG_aControlInputMask[ k ] := nStartAngle
   _HMG_aControllostFocusProcedure[ k ] := ""
   _HMG_aControlGotFocusProcedure[ k ] := ""
   _HMG_aControlChangeProcedure[ k ] := ""
   _HMG_aControlDeleted[ k ] := .F.
   _HMG_aControlBkColor[ k ] := { nColorRemain, nColorInner }
   _HMG_aControlFontColor[ k ] := { nColorDoneMin, nColorDoneMax }
   _HMG_aControlDblClick[ k ] := lShowText
   _HMG_aControlHeadClick[ k ] := {}
   _HMG_aControlRow[ k ] := nRow
   _HMG_aControlCol[ k ] := nCol
   _HMG_aControlWidth[ k ] := nWidth
   _HMG_aControlHeight[ k ] := nHeight
   _HMG_aControlSpacing[ k ] := nInnerSize
   _HMG_aControlContainerRow[ k ] := -1
   _HMG_aControlContainerCol[ k ] := -1
   _HMG_aControlPicture[ k ] := nGradientMode
   _HMG_aControlContainerHandle[ k ] := 0
   _HMG_aControlFontName[ k ] := NIL
   _HMG_aControlFontSize[ k ] := NIL
   _HMG_aControlFontAttributes[ k ] := {}
   _HMG_aControlToolTip[ k ] := ''
   _HMG_aControlRangeMin[ k ] := nMin
   _HMG_aControlRangeMax[ k ] := nMax
   _HMG_aControlCaption[ k ] := ""
   _HMG_aControlVisible[ k ] := .T.
   _HMG_aControlHelpId[ k ] := 0
   _HMG_aControlFontHandle[ k ] := NIL
   _HMG_aControlBrushHandle[ k ] := 0
   _HMG_aControlEnabled[ k ] := .T.
   _HMG_aControlMiscData2[ k ] := ''

   ProgressWheelPaint( cParentForm, cImageName, nWidth, nHeight, nPosition, ;
      nStartAngle, nInnerSize, nGradientMode, _HMG_aControlCaption[ k ], lShowText, nMin, nMax, ;
      nColorDoneMin, nColorDoneMax, nColorRemain, nColorInner )

   UpdateAngleGradientBrush( nGradientMode, nWidth, nHeight, nStartAngle, nColorDoneMin, nColorDoneMax )

   nId := GetFormIndex ( cParentForm )

   AAdd ( _HMG_aFormGraphTasks[ nId ], ;
      {|| ProgressWheelPaint( cParentForm, cImageName, nWidth, nHeight, nPosition, ;
      nStartAngle, nInnerSize, nGradientMode, _HMG_aControlCaption[ k ], lShowText, nMin, nMax, ;
      nColorDoneMin, nColorDoneMax, nColorRemain, nColorInner ) } )

   _HMG_aControlMiscData1[ k ] := Len( _HMG_aFormGraphTasks[ nId ] )

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION PW_GetColorDoneMin( cControlName, cParentForm )
*------------------------------------------------------------------------------*

   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL ColorDoneMin

   IF i > 0
      ColorDoneMin := COLORREF_TO_ArrayRGB( _HMG_aControlFontColor[ i ][ 1 ] )
   ENDIF

RETURN ColorDoneMin

*------------------------------------------------------------------------------*
FUNCTION PW_GetColorDoneMax( cControlName, cParentForm )
*------------------------------------------------------------------------------*

   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL ColorDoneMax

   IF i > 0
      ColorDoneMax := COLORREF_TO_ArrayRGB( _HMG_aControlFontColor[ i ][ 2 ] )
   ENDIF

RETURN ColorDoneMax

*------------------------------------------------------------------------------*
FUNCTION PW_GetColorRemain( cControlName, cParentForm )
*------------------------------------------------------------------------------*

   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL ColorRemain

   IF i > 0
      ColorRemain := COLORREF_TO_ArrayRGB( _HMG_aControlBkColor[ i ][ 1 ] )
   ENDIF

RETURN ColorRemain

*------------------------------------------------------------------------------*
FUNCTION PW_GetColorInner( cControlName, cParentForm )
*------------------------------------------------------------------------------*

   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL ColorInner

   IF i > 0
      ColorInner := COLORREF_TO_ArrayRGB( _HMG_aControlBkColor[ i ][ 2 ] )
   ENDIF

RETURN ColorInner

*------------------------------------------------------------------------------*
PROCEDURE PW_SetShowText( cControlName, cParentForm, Value )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )

   IF ISBLOCK( Value )
      _HMG_aControlCaption[ i ] := Value
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], ;
         _HMG_aControlWidth[ i ], _HMG_aControlHeight[ i ], .F. )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetColorDoneMin( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]

   IF IsArrayRGB ( Value )
      Value := HMG_RGB2n( Value )
   ENDIF
   IF ColorDoneMin <> Value
      _HMG_aControlFontColor[ i ][ 1 ] := Value
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         Value, ColorDoneMax, ColorRemain, ColorInner ) }
      IF PCount() == 3 .OR. ISLOGICAL( lErase ) .AND. lErase
         BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
      ENDIF
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetColorDoneMax( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]

   IF IsArrayRGB ( Value )
      Value := HMG_RGB2n( Value )
   ENDIF
   IF ColorDoneMax <> Value
      _HMG_aControlFontColor[ i ][ 2 ] := Value
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, Value, ColorRemain, ColorInner ) }
      IF PCount() == 3 .OR. ISLOGICAL( lErase ) .AND. lErase
         BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
      ENDIF
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetColorRemain( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]

   IF IsArrayRGB ( Value )
      Value := HMG_RGB2n( Value )
   ENDIF
   IF ColorRemain <> Value
      _HMG_aControlBkColor[ i ][ 1 ] := Value
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, Value, ColorInner ) }
      IF PCount() == 3 .OR. ISLOGICAL( lErase ) .AND. lErase
         BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
      ENDIF
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetColorInner( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]

   IF IsArrayRGB ( Value )
      Value := HMG_RGB2n( Value )
   ENDIF
   IF ColorInner <> Value
      _HMG_aControlBkColor[ i ][ 2 ] := Value
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, Value ) }
      IF PCount() == 3 .OR. ISLOGICAL( lErase ) .AND. lErase
         BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
      ENDIF
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetStartAngle( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL V := Value

   IF V < 0
      V := 0
   ELSEIF V > 359
       V := 359
   ENDIF
   IF StartAngle <> V
      _HMG_aControlInputMask[ i ] := V
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         V, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetMin( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL V := Value

   IF V >= Max
      V := Max - 1
   ENDIF
   IF Min <> V
      Min := V
      _HMG_aControlRangeMin[ i ] := Min
      IF Position < Min
         _HMG_aControlValue[ i ] := Position := Min
      ENDIF
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetMax( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL V := Value

   IF V <= Min
      V := Min + 1
   ENDIF
   IF Max <> V
      Max := V
      _HMG_aControlRangeMax[ i ] := Max
      IF Position > Max
         _HMG_aControlValue[ i ] := Position := Max
      ENDIF
      UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetPosition( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL V := Value

   IF V < Min
      V := Min
   ELSEIF V > Max
      V := Max
   ENDIF
   IF Position <> V
      _HMG_aControlValue[ i ] := V
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, V, ;
         StartAngle, InnerSize, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetInnerSize( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL V := Value

   IF V < 0
      V := 0
   ELSEIF V > 99
      V := 99
   ENDIF
   IF InnerSize <> V
      _HMG_aControlSpacing[ i ] := V
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, V, GradientMode, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE PW_SetGradientMode( cControlName, cParentForm, Value, lErase )
*------------------------------------------------------------------------------*

   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i := GetControlIndex ( cControlName, cParentForm )
   LOCAL n := _HMG_aControlMiscData1[ i ]
   LOCAL cImageName := _HMG_aControlProcedures[ i ]
   LOCAL Width := _HMG_aControlWidth[ i ]
   LOCAL Height := _HMG_aControlHeight[ i ]
   LOCAL StartAngle := _HMG_aControlInputMask[ i ]
   LOCAL InnerSize := _HMG_aControlSpacing[ i ]
   LOCAL cText := _HMG_aControlCaption[ i ]
   LOCAL ShowText := _HMG_aControlDblClick[ i ]
   LOCAL ColorDoneMin := _HMG_aControlFontColor[ i ][ 1 ]
   LOCAL ColorDoneMax := _HMG_aControlFontColor[ i ][ 2 ]
   LOCAL ColorRemain := _HMG_aControlBkColor[ i ][ 1 ]
   LOCAL ColorInner := _HMG_aControlBkColor[ i ][ 2 ]
   LOCAL Min := _HMG_aControlRangeMin[ i ]
   LOCAL Max := _HMG_aControlRangeMax[ i ]
   LOCAL Position := _HMG_aControlValue[ i ]
   LOCAL GradientMode := _HMG_aControlPicture[ i ]

   IF GradientMode <> Value
      _HMG_aControlPicture[ i ] := Value
      UpdateAngleGradientBrush( Value, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
      _HMG_aFormGraphTasks[ GetFormIndex ( cParentForm ) ][ n ] := ;
         {|| ProgressWheelPaint( cParentForm, cImageName, Width, Height, Position, ;
         StartAngle, InnerSize, Value, cText, ShowText, Min, Max, ;
         ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner ) }
      BT_ClientAreaInvalidateRect( nParentFormHandle, _HMG_aControlRow[ i ], _HMG_aControlCol[ i ], Width, Height, hb_defaultValue( lErase, .F. ) )
   ENDIF

RETURN

#define HALFTONE        4
*------------------------------------------------------------------------------*
PROCEDURE ProgressWheelPaint( cParentForm, cImgName, Width, Height, ;
      Position, StartAngle, InnerSize, GradientMode, cText, ShowText, ;
      Min, Max, ColorDoneMin, ColorDoneMax, ColorRemain, ColorInner )
*------------------------------------------------------------------------------*
   LOCAL hBitmap
   LOCAL hDC
   LOCAL BTStruct
   LOCAL R, RR
   LOCAL BrushColor
   LOCAL hBrushBitmap
   LOCAL row, col
   LOCAL P1
   LOCAL P2

   hBitmap := BT_BitmapCreateNew ( Width, Height, nRGB2Arr( GetSysColor( COLOR_BTNFACE ) ) )
   hDC := BT_CreateDC( hBitmap, BT_HDC_BITMAP, @BTStruct )

   IF Width > Height
      R := { 0, 0, Height, Height }
   ELSE
      R := { 0, 0, Width, Width }
   ENDIF

   Left := R[ 1 ] * BufScale
   Right := R[ 3 ] * BufScale
   Top := R[ 2 ] * BufScale
   Bottom := R[ 4 ] * BufScale

   BrushColor := COLORREF_TO_ArrayRGB( ColorRemain )

   P1 := AnglePosition( StartAngle, R, Min, Max, Min )
   P2 := AnglePosition( StartAngle, R, Min, Max, Max )

   DrawPieInBitmap( hDC, R[ 2 ], R[ 1 ], R[ 3 ], R[ 4 ], P2[ 1 ], P2[ 2 ], P1[ 1 ], P1[ 2 ], BrushColor, , BrushColor )

   IF Position > Min
      P1 := AnglePosition( StartAngle, R, Min, Max, 0 )
      P2 := AnglePosition( StartAngle, R, Min, Max, Position )

      SWITCH GradientMode
      CASE 1 /*None*/
         BrushColor := COLORREF_TO_ArrayRGB( ColorDoneMax )
         EXIT
      CASE 2 /*Position*/
         BrushColor := COLORREF_TO_ArrayRGB( GradientColor( ColorDoneMin, ColorDoneMax, Min, Max, Position ) )
         EXIT
      CASE 3 /*Angle*/
         hBrushBitmap := CreatePatternHBrush( hGradient )
         SetBrushOrg( hDC, ( Width * BufScale - BufScale ) / 2, ( Height * BufScale - BufScale ) / 2 )
         EXIT
      ENDSWITCH

      DrawPieInBitmap( hDC, R[ 2 ], R[ 1 ], R[ 3 ], R[ 4 ], P2[ 1 ], P2[ 2 ], P1[ 1 ], P1[ 2 ], BrushColor, , BrushColor, hBrushBitmap )
   ENDIF

   IF InnerSize > 0
      RR := { ;
         Left + ( 100 - InnerSize ) * ( Right - Left ) / 200, ;
         Top + ( 100 - InnerSize ) * ( Bottom - Top ) / 200, ;
         Right - ( 100 - InnerSize ) * ( Right - Left ) / 200, ;
         Bottom - ( 100 - InnerSize ) * ( Bottom - Top ) / 200 }

      Left := RR[ 1 ]
      Right := RR[ 3 ]
      Top := RR[ 2 ]
      Bottom := RR[ 4 ]

      Row := RR[ 2 ] + 1
      Col := RR[ 1 ] + 1
      Width := Right - Left
      Height := Bottom - Top

      BrushColor := COLORREF_TO_ArrayRGB( ColorInner )

      DrawEllipseInBitmap( hDC, row, col, Width, Height, BrushColor, , BrushColor )
   ENDIF

   SetStretchBltMode( hDC, HALFTONE )
   SetBrushOrg( hDC, 0, 0 )

   IF ShowText
      IF ISBLOCK( cText )
         cText := Eval( cText, Position, Max )
      ELSE
         cText := hb_ntos( Int( 100 * ( Position - Min ) / ( Max - Min ) ) ) + '%'
      ENDIF

      Row := R[ 4 ] / 2 - InnerSize * Width / 6000 - 6
      Col := R[ 3 ] / 2 - InnerSize * Height / 6000 + 2

      DrawTextInBitmap( hDC, row, col, cText, _HMG_DefaultFontName, _HMG_DefaultFontSize, iif( Empty( ColorInner ), WHITE, BLACK ), 2 )
   ENDIF

   BT_DeleteDC( BTstruct )

   SetProperty( cParentForm, cImgName, "HBITMAP", hBitmap ) // Assign hBitmap to the IMAGE control

RETURN

*------------------------------------------------------------------------------*
FUNCTION UpdateAngleGradientBrush( GradientMode, Width, Height, StartAngle, ColorDoneMin, ColorDoneMax )
*------------------------------------------------------------------------------*
   LOCAL hBitmap
   LOCAL hDC
   LOCAL BTStruct
   LOCAL i
   LOCAL R
   LOCAL BrushColor
   LOCAL P1
   LOCAL P2

   IF GradientMode <> 3
      IF hGradient != NIL
         DeleteObject( hGradient )
         hGradient := NIL
      ENDIF
   ELSE
      Width *= BufScale
      Height *= BufScale

      hBitmap := BT_BitmapCreateNew ( Width, Height, nRGB2Arr( GetSysColor( COLOR_BTNFACE ) ) )
      hDC := BT_CreateDC( hBitmap, BT_HDC_BITMAP, @BTStruct )

      R := { 0, 0, Width, Height }

      FOR i := 0 TO 99

         P1 := AnglePosition( StartAngle, R, 0, 100, i )
         P2 := AnglePosition( StartAngle, R, 0, 100, i + 1 )

         BrushColor := COLORREF_TO_ArrayRGB( GradientColor( ColorDoneMin, ColorDoneMax, 0, 100, i ) )

         DrawPieInBitmap( hDC, R[ 2 ], R[ 1 ], R[ 3 ], R[ 4 ], P2[ 1 ], P2[ 2 ], P1[ 1 ], P1[ 2 ], BrushColor, , BrushColor )

      NEXT

      BT_DeleteDC( BTstruct )

#ifdef __DEBUG__
      BT_BitmapSaveFile( hBitmap, "grad.bmp", BT_FILEFORMAT_BMP )

#endif
      hGradient := hBitmap
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
STATIC FUNCTION GradientColor( ColorBegin, ColorEnd, AMin, AMax, APosition )
*------------------------------------------------------------------------------*
   LOCAL B
   LOCAL B1, B2, B3
   LOCAL E
   LOCAL E1, E2, E3
   LOCAL P

   B := COLORREF_TO_ArrayRGB( ColorBegin )

   B1 := B[ 1 ]
   B2 := B[ 2 ]
   B3 := B[ 3 ]

   E := COLORREF_TO_ArrayRGB( ColorEnd )

   E1 := E[ 1 ]
   E2 := E[ 2 ]
   E3 := E[ 3 ]

   IF AMax - AMin <> 0
      P := ( APosition - AMin ) / ( AMax - AMin )
   ELSE
      P := 0
   ENDIF

RETURN B1 + Round( ( E1 - B1 ) * P, 0 ) + hb_bitShift( B2 + Round( ( E2 - B2 ) * P, 0 ), 8 ) + hb_bitShift( B3 + Round( ( E3 - B3 ) * P, 0 ), 16 )

*------------------------------------------------------------------------------*
STATIC FUNCTION AnglePosition( StartAngle, Rect, AMin, AMax, APosition )
*------------------------------------------------------------------------------*
   LOCAL a
   LOCAL X, Y

   a := ( StartAngle - 90 ) + 360 * ( APosition / ( AMax - AMin ) - AMin )
   a := a * PI() / 180

   Left := Rect[ 1 ]
   Top := Rect[ 2 ]
   Right := Rect[ 3 ]
   Bottom := Rect[ 4 ]

   X := Round( Cos( a ) * ( Right - Left ) / 2 + ( Left + Right ) / 2, 0 )
   Y := Round( Sin( a ) * ( Bottom - Top ) / 2 + ( Bottom + Top ) / 2, 0 )

RETURN { Y, X }

*=============================================================================*
*                          Auxiliary Functions
*=============================================================================*

*------------------------------------------------------------------------------*
STATIC FUNCTION BT_DrawPieEx ( hDC, Row1, Col1, Row2, Col2, RowStartArc, ColStartArc, RowEndArc, ColEndArc, aColorRGBLine, nWidthLine, aColorRGBFill, hBrushBitmap )
*------------------------------------------------------------------------------*

   nWidthLine := IF ( ValType ( nWidthLine ) == "U", 1, nWidthLine )
   BT_DRAW_HDC_ARCX_EX ( hDC, Col1, Row1, Col2, Row2, ColStartArc, RowStartArc, ColEndArc, RowEndArc, ArrayRGB_TO_COLORREF( aColorRGBLine ), nWidthLine, ArrayRGB_TO_COLORREF( aColorRGBFill ), BT_DRAW_PIE, hBrushBitmap )

RETURN NIL

*------------------------------------------------------------------------------*
STATIC PROCEDURE DrawPieInBitmap( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb, hBrush )
*------------------------------------------------------------------------------*

   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF

   BT_DrawPieEx ( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb, hBrush )

RETURN

*------------------------------------------------------------------------------*
STATIC PROCEDURE DrawEllipseInBitmap( hDC, row, col, Width, Height, penrgb, penwidth, fillrgb )
*------------------------------------------------------------------------------*

   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF

   BT_DrawFillEllipse ( hDC, row, col, Width, Height, fillrgb, penrgb, penwidth )

RETURN

*------------------------------------------------------------------------------*
STATIC PROCEDURE DrawTextInBitmap( hDC, row, col, cText, cFontName, nFontSize, aColor, nAlign )
*------------------------------------------------------------------------------*

   DEFAULT nAlign := 0

   SWITCH nAlign
   CASE 0
      BT_DrawText ( hDC, row, col, cText, cFontName, nFontSize, aColor, , BT_TEXT_TRANSPARENT )
      EXIT
   CASE 1
      BT_DrawText ( hDC, row, col, cText, cFontName, nFontSize, aColor, , , BT_TEXT_RIGHT + BT_TEXT_TOP )
      EXIT
   CASE 2
      BT_DrawText ( hDC, row, col, cText, cFontName, nFontSize, aColor, , BT_TEXT_TRANSPARENT, BT_TEXT_CENTER + BT_TEXT_TOP )
      EXIT
   ENDSWITCH

RETURN


#pragma BEGINDUMP

#define WINVER 0x0501  // minimum requirements: Windows XP
#include <mgdefs.h>

#include <commctrl.h>

// Minigui Resources control system
void RegisterResource( HANDLE hResource, LPSTR szType );

HB_FUNC ( SETBRUSHORG )
{
    HDC hDC  = ( HDC ) HB_PARNL( 1 );

    SetBrushOrgEx( hDC, hb_parni( 2 ), hb_parni( 3 ), NULL );
}

HB_FUNC( SETSTRETCHBLTMODE )
{
    hb_retni( SetStretchBltMode( ( HDC ) HB_PARNL( 1 ),  hb_parni( 2 ) ) );
}

//**********************************************************************************************************************************************
//* BT_DRAW_HDC_ARCX_EX (hDC, x1, y1, x2, y2, XStartArc, YStartArc, XEndArc, YEndArc, ColorLine, nWidthLine, ColorFill, nArcType, hBrushBitmap )
//**********************************************************************************************************************************************

// nArcType
#define BT_DRAW_ARC    0
#define BT_DRAW_CHORD  1
#define BT_DRAW_PIE    2

HB_FUNC( BT_DRAW_HDC_ARCX_EX )
{
   HDC      hDC;
   HPEN     hPen;
   HBRUSH   hBrush;
   HPEN     OldPen;
   HBRUSH   OldBrush;
   COLORREF ColorLine, ColorFill;
   INT      x1, y1, x2, y2, nWidthLine;
   INT      XStartArc, YStartArc, XEndArc, YEndArc;
   INT      nArcType;

   hDC = ( HDC ) HB_PARNL( 1 );
   x1  = ( INT ) hb_parni( 2 );
   y1  = ( INT ) hb_parni( 3 );
   x2  = ( INT ) hb_parni( 4 );
   y2  = ( INT ) hb_parni( 5 );

   XStartArc = ( INT ) hb_parni( 6 );
   YStartArc = ( INT ) hb_parni( 7 );
   XEndArc   = ( INT ) hb_parni( 8 );
   YEndArc   = ( INT ) hb_parni( 9 );

   ColorLine  = ( COLORREF ) hb_parnl( 10 );
   nWidthLine = ( INT ) hb_parni( 11 );
   ColorFill  = ( COLORREF ) hb_parnl( 12 );

   nArcType = ( INT ) hb_parni( 13 );

   hPen     = CreatePen( PS_SOLID, nWidthLine, ColorLine );
   OldPen   = ( HPEN ) SelectObject( hDC, hPen );

   if( hb_parnl( 14 ) )
      hBrush   = ( HBRUSH ) HB_PARNL( 14 );
   else
      hBrush   = CreateSolidBrush( ColorFill );

   OldBrush = ( HBRUSH ) SelectObject( hDC, hBrush );

   switch( nArcType )
   {
      case BT_DRAW_ARC:
         Arc( hDC, x1, y1, x2, y2, XStartArc, YStartArc, XEndArc, YEndArc );
         break;
      case BT_DRAW_CHORD:
         Chord( hDC, x1, y1, x2, y2, XStartArc, YStartArc, XEndArc, YEndArc );
         break;
      case BT_DRAW_PIE:
         Pie( hDC, x1, y1, x2, y2, XStartArc, YStartArc, XEndArc, YEndArc );
         break;
   }

   SelectObject( hDC, OldBrush );
   DeleteObject( hBrush );
   SelectObject( hDC, OldPen );
   DeleteObject( hPen );
}

HB_FUNC( CREATEPATTERNHBRUSH ) // ( hBitmap ) --> hBrush
{
   HBRUSH hBrush = CreatePatternBrush( ( HBITMAP ) HB_PARNL( 1 ) );

   RegisterResource( hBrush, "BRUSH" );

   HB_RETNL( ( LONG_PTR ) hBrush );
}

#pragma ENDDUMP

#endif
