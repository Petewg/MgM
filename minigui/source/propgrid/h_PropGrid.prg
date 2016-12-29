/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Property Grid control source code
 (C)2007-2011 Janusz Pora <januszpora@onet.eu>

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
    Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2012, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_PropGrid.ch"
#include "i_xml.ch"

#define EM_GETSEL   176
#define EM_SETSEL   177
#define WM_CLEAR    771
#define WM_CHAR     258
//#define WM_SETFOCUS   7
#define WM_KILLFOCUS  8
#define WM_NOTIFY     78
#define WM_KEYDOWN    256
#define WM_COMMAND      0x0111
#define WM_LBUTTONDOWN    513    // 0x0201
#define WM_LBUTTONUP      514    // 0x0202
#define WM_LBUTTONDBLCLK  515    // 0x203

#define BN_CLICKED      0
#define EN_CHANGE       768
/*
 * Combo Box Notification Codes
 */
#define CBN_SELCHANGE       1
#define CBN_KILLFOCUS       4
#define CBN_EDITCHANGE      5

#define TVM_EXPAND   4354
#define TVE_COLLAPSE   1
#define TVE_EXPAND   2
#define TVE_TOGGLE   3


#define TVN_SELCHANGED TVN_SELCHANGEDA
#define TVN_SELCHANGEDA   (-402)

#define CLR_NONE                0xFFFFFFFF

#define COLOR_SCROLLBAR         0
#define COLOR_BACKGROUND        1
#define COLOR_ACTIVECAPTION     2
#define COLOR_INACTIVECAPTION   3
#define COLOR_MENU              4
#define COLOR_WINDOW            5
#define COLOR_WINDOWFRAME       6
#define COLOR_MENUTEXT          7
#define COLOR_WINDOWTEXT        8
#define COLOR_CAPTIONTEXT       9
#define COLOR_ACTIVEBORDER      10
#define COLOR_INACTIVEBORDER    11
#define COLOR_APPWORKSPACE      12
#define COLOR_HIGHLIGHT         13
#define COLOR_HIGHLIGHTTEXT     14
#define COLOR_BTNFACE           15
#define COLOR_BTNSHADOW         16
#define COLOR_GRAYTEXT          17
#define COLOR_BTNTEXT           18
#define COLOR_INACTIVECAPTIONTEXT 19
#define COLOR_BTNHIGHLIGHT      20
#define COLOR_3DDKSHADOW        21
#define COLOR_3DLIGHT           22
#define COLOR_INFOTEXT          23
#define COLOR_INFOBK            24

#define APG_TYPE     1
#define APG_NAME     2
#define APG_VALUE    3
#define APG_DATA     4
#define APG_DIS      5
#define APG_CHG      6
#define APG_DISED    7
#define APG_ID       8
#define APG_INFO     9
#define APG_VALNAME  10

//INFO aRowItem  => (Type,PropertyName,Value,Data,Disabled,changed,ItemID, ItemInfo, ValueName
//                     1        2        3     4     5       6       7       8          9
STATIC hIListSys   := 0
STATIC aFontName   := { 'Font Name', 'Font Size', 'Bold', 'Italic', 'Underline', 'Strikeout' }
STATIC aFontType   := { 'enum', 'numeric', 'logic', 'logic', 'logic', 'logic' }
STATIC nItemId     := 0

*------------------------------------------------------------------------------*
FUNCTION _DefinePropGrid ( ControlName, ParentFormName, row, col, width, height, ;
      change, cFile, lXml, tooltip, fontname, fontsize, gotfocus, lostfocus, onclose, ;
      break, aRowItem, HelpId, bold, italic, underline, strikeout, itemexpand, ;
      backcolor, fontcolor, indent, itemheight, datawidth, ImgList, readonly, lInfo, ;
      infoHeight, changevalue, aheadname, singleexpand, ;
      lOkBtn, lApplyBtn, UserOkProc, lCancelBtn, UserCancelProc, UserHelpProc )
*------------------------------------------------------------------------------*

   LOCAL i , ParentFormHandle , aControlhandle , mVar
   LOCAL FontHandle , aFont , k , hColorIL, lHelpBtn := .F.

   DEFAULT lOkBtn       := .F.
   DEFAULT lApplyBtn    := .F.
   DEFAULT lCancelBtn   := .F.
   DEFAULT ImgList      := 0
   DEFAULT Width        := 240
   DEFAULT Height       := 200
   DEFAULT dataWidth    := 120
   DEFAULT indent       := 12
   DEFAULT change       := ""
   DEFAULT changevalue  := ""
   DEFAULT gotfocus     := ""
   DEFAULT lostfocus    := ""
   DEFAULT onclose      := ""
   DEFAULT cFile        := ""
   DEFAULT aRowItem     := {}
   DEFAULT lInfo        := .F.
   DEFAULT infoHeight   := 80
   DEFAULT UserOkProc   := ""
   DEFAULT UserCancelProc  := ""
   DEFAULT UserHelpProc    := ""

   InitPGMessages()

   _HMG_ActivePropGridHandle := 0
   _HMG_ActiveCategoryHandle := 0

   IF dataWidth > 0.8 * width
      dataWidth := 0.8 * width
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      aFont := GetFontParam( FontHandle )
      FontName     := aFont[1]
      FontSize     := aFont[2]
      bold         := aFont[3]
      italic       := aFont[4]
      underline    := aFont[5]
      strikeout    := aFont[6]
   ENDIF

   IF _HMG_BeginWindowActive
      ParentFormName := _HMG_ActiveFormName
      IF .NOT. Empty ( _HMG_ActiveFontName ) .AND. ValType( FontName ) == "U"
         FontName := _HMG_ActiveFontName
      ENDIF
      IF .NOT. Empty ( _HMG_ActiveFontSize ) .AND. ValType( FontSize ) == "U"
         FontSize := _HMG_ActiveFontSize
      ENDIF
   ENDIF
   IF _HMG_FrameLevel > 0
      col    := col + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      row    := row + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentFormName )
      MsgMiniGuiError( "Window: " + ParentFormName + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName )
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   IF aheadname != Nil .AND. ValType( aheadname ) == 'A'
      IF Len( aheadname ) > 0 .AND. ValType( aheadname[1] ) == 'A'
         aheadname := aheadname[1]
      ENDIF
   ENDIF
   IF !lOkBtn
      UserOkProc := ""
   ENDIF
   IF !lCancelBtn
      UserCancelProc := ""
   ENDIF
   IF ValType( UserHelpProc ) == "B"
      lHelpBtn := .T.
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   ParentFormHandle = GetFormHandle ( ParentFormName )

   IF ValType( Row ) == "U" .OR. ValType( Col ) == "U"

      IF _HMG_SplitLastControl == 'TOOLBAR'
         Break := .T.
      ENDIF

      i := GetFormIndex ( ParentFormName )

      IF i > 0

         aControlHandle := InitPropGrid ( _HMG_aFormReBarHandle [i] , col , row , width , height , indent , datawidth, readonly, lInfo, infoHeight, aheadname, singleexpand )

         IF FontHandle != 0
            _SetFontHandle( aControlHandle[1], FontHandle )
         ELSE
            IF ValType( fontname ) == "U"
               FontName := _HMG_DefaultFontName
            ENDIF
            IF ValType( fontsize ) == "U"
               FontSize := _HMG_DefaultFontSize
            ENDIF
            FontHandle := _SetFont ( aControlHandle[1], FontName, FontSize )
         ENDIF

         AddSplitBoxItem ( aControlhandle[1] , _HMG_aFormReBarHandle [i] , Width , break , , , , _HMG_ActiveSplitBoxInverted )

         _HMG_SplitLastControl := 'PROPGRID'

      ENDIF

   ELSE

      aControlHandle := InitPropGrid ( ParentFormHandle , col , row , width , height , indent , datawidth, readonly, lInfo, infoHeight, aheadname, singleexpand, lOkBtn, lApplyBtn, lCancelBtn, lHelpBtn, _HMG_PGLangButton )

   ENDIF

   _HMG_ActivePropGridHandle := aControlHandle[1]

   IF FontHandle != 0
      _SetFontHandle( aControlHandle[1], FontHandle )
      _SetFontHandle( aControlHandle[2], FontHandle )
   ELSE
      IF ValType( fontname ) == "U"
         fontname := _HMG_DefaultFontName
      ENDIF
      IF ValType( fontsize ) == "U"
         fontsize := _HMG_DefaultFontSize
      ENDIF
      _SetFont ( aControlHandle[2], fontname, _HMG_DefaultFontSize, .T. , italic, underline, strikeout )
      _SetFont ( aControlHandle[3], fontname, _HMG_DefaultFontSize, bold, italic, underline, strikeout )
      IF aControlHandle[3] != 0
         _SetFont ( aControlHandle[5], fontname, _HMG_DefaultFontSize, .T. , italic, underline, strikeout )
      ENDIF
      FontHandle := _SetFont ( aControlHandle[1], fontname, _HMG_DefaultFontSize, bold, italic, underline, strikeout )
   ENDIF

   IF _HMG_BeginTabActive
      AAdd ( _HMG_ActiveTabCurrentPageMap, aControlHandle )
   ENDIF

   IF ValType( tooltip ) != "U"
      SetToolTip ( aControlHandle[1], tooltip, GetFormToolTipHandle ( ParentFormName ) )
   ENDIF

   IF ValType( backcolor ) == "A"
      TreeView_SetBkColor( aControlHandle[1], backcolor )
   ENDIF

   IF ValType( fontcolor ) == "A"
      TreeView_SetTextColor( aControlHandle[1], fontcolor )
   ENDIF

   indent := TreeView_GetIndent( aControlHandle[1] )

   IF ValType( itemheight ) == "N"
      TreeView_SetItemHeight( aControlHandle[1], itemheight )
   ELSE
      itemheight := TreeView_GetItemHeight( aControlHandle[1] )
   ENDIF

   hColorIL := InitImageList ( ( itemheight - 4 ) * 1.4, itemheight - 4, .T. )

   InitPropGridImageList( aControlHandle[1], hColorIL )  // Init Color Image List

   _HMG_ActivePropGridIndex := k
   Public &mVar. := k

   _HMG_aControlType [k] := "PROPGRID"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   aControlHandle
   _HMG_aControlParentHandles [k] :=   ParentFormHandle
   _HMG_aControlIds [k] :=   0
   _HMG_aControlProcedures [k] :=  UserOkProc
   _HMG_aControlPageMap  [k] := aRowItem
   _HMG_aControlValue  [k] :=   UserCancelProc
   _HMG_aControlInputMask  [k] :=  itemexpand
   _HMG_aControllostFocusProcedure [k] :=   lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick   [k] := onclose
   _HMG_aControlHeadClick   [k] := changevalue
   _HMG_aControlRow   [k] := Row
   _HMG_aControlCol   [k] := Col
   _HMG_aControlWidth   [k] := Width
   _HMG_aControlHeight   [k] := Height - IF( lInfo, infoHeight, 0 )
   _HMG_aControlSpacing   [k] := hColorIL
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , - 1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , - 1 )
   _HMG_aControlPicture  [k] :=  {}
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes   [k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  itemheight
   _HMG_aControlRangeMax   [k] :=  datawidth
   _HMG_aControlCaption   [k] :=  cFile
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId   [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { indent, ImgList, lInfo, infoHeight, lXml, UserHelpProc, .F. }
   _HMG_aControlMiscData2 [k] := 0

   _InitPgArray( aRowItem, cFile, lXml, k )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgLoadFile( ParentForm, ControlName, cFile, lXml )
*------------------------------------------------------------------------------*
   LOCAL aProp := {}, k
   k := GetControlIndex ( ControlName, ParentForm )
   IF Lower( SubStr( cFile,RAt('.',cFile ) + 1 ) ) == 'xml'
      lXml := .T.
   ENDIF
   IF  !Empty( cFile ) .AND. File( cFile )
      IF !lXml
         aProp := _LoadProperty( cFile, k )
      ENDIF
      _InitPgArray( aProp, cFile, lXml, k )
      _HMG_aControlCaption   [k] :=  cFile
      _HMG_aControlMiscData1 [k,5] := lXml
      _ChangeBtnState(  _HMG_aControlHandles [k], .F. , k )
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _InitPgArray( aRowItem, cFile, lXml, k )
*------------------------------------------------------------------------------*

   IF  !Empty( cFile ) .AND. File( cFile )
      IF lXml
         PgInitItemXml( cFile, k )
         aRowItem := {}
      ELSE
         aRowItem := _LoadProperty( cFile, k )
      ENDIF
   ENDIF
   IF Len( aRowItem ) > 0
      PgInitItem( aRowItem, k )
   ENDIF

RETURN nil

*------------------------------------------------------------------------------*
FUNCTION PgBtnEvents( hwndPG, HwndBtn )
*------------------------------------------------------------------------------*
   LOCAL i, aHandle, nBtn, aRowItem, cFile, lXml
   i := AScan ( _HMG_aControlHandles , {|x| ValType( x ) == 'A' .AND. x[1] == hwndPG } )
   IF i > 0 .AND. HwndBtn > 0
      aRowItem := _HMG_aControlPageMap [i]
      cFile    := _HMG_aControlCaption [i]
      lXml     := _HMG_aControlMiscData1 [i,5]
      aHandle  := _HMG_aControlHandles [i]

      nBtn := AScan (  aHandle, HwndBtn )
      DO CASE
      CASE nBtn == PGB_OK .OR. nBtn == PGB_APPLY
         IF _HMG_aControlMiscData1 [i,7] .OR. nBtn == PGB_APPLY
            IF ValType( _HMG_aControlProcedures [i] ) == "B"
               _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            ELSE
               PgSaveFile( GetParentFormName( i ), _HMG_aControlNames [i], cFile )
            ENDIF
            _ChangeBtnState(  aHandle, .F. , i )
         ENDIF
         IF  nBtn == PGB_OK
            DoMethod( GetParentFormName( i ) , 'Release' )
         ENDIF
      CASE nBtn == PGB_CANCEL
         IF ValType( _HMG_aControlValue [i] ) == "B"
            _DoControlEventProcedure ( _HMG_aControlValue [i] , i )
         ELSE
            _InitPgArray( aRowItem, cFile, lXml, i )
            _ChangeBtnState(  aHandle, .F. , i )
         ENDIF
      CASE nBtn == PGB_HELP
         IF ValType( _HMG_aControlMiscData1 [i,6] ) == "B"
            _DoControlEventProcedure ( _HMG_aControlMiscData1 [i,6] , i )
         ENDIF
      ENDCASE
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _ChangeBtnState(  aHandle, lChg, k )
*------------------------------------------------------------------------------*
   IF aHandle[ PGB_APPLY] > 0
      IF lChg
         EnableWindow( aHandle[ PGB_APPLY] )
         _HMG_aControlMiscData1 [k,7] := .T.
      ELSE
         DisableWindow( aHandle[ PGB_APPLY] )
         _HMG_aControlMiscData1 [k,7] := .F.
      ENDIF
   ENDIF
   IF aHandle[ PGB_CANCEL] > 0
      IF lChg
         EnableWindow( aHandle[ PGB_CANCEL] )
      ELSE
         DisableWindow( aHandle[ PGB_CANCEL] )
      ENDIF
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _DefinePropertyItem ( cType, cName, cValue, aData, disabled, disableedit, id, cInfo, cValName, cValNameDef )
*------------------------------------------------------------------------------*
   LOCAL typePg := PgIdentType( cType )
   DEFAULT cValue := "", aData := "", disabled := .F. , cInfo := "", cValNameDef := "", cValName := cValNameDef
   IF ValType( aData ) == 'N'
      aData := LTrim( Str( adata ) )
   ENDIF
   IF typePG == PG_ERROR
      //      MsgMiniGuiError ("Property Item type: "+cType+" wrong defined." )
      MsgMiniGuiError ( _HMG_PGLangError[1] + cType + _HMG_PGLangError[2] )
   ENDIF
   IF ValType( id ) == 'U'
      IF Len( _HMG_ActivePropGridArray ) == 0
         nItemId := 100
      ENDIF
      Id := nItemId++
   ENDIF
   IF id != 0
      IF AScan( _HMG_ActivePropGridArray, {|x| x[8] == Id } ) > 0
         //         MsgMiniGuiError ("Property Item ID double defined." )
         MsgMiniGuiError ( _HMG_PGLangError[3]  )
      ENDIF
   ENDIF
   PgCheckData( typePG, @cValue, @aData, 0 )
   AAdd( _HMG_ActivePropGridArray, { cType, cName, cValue, aData, disabled, .F. , disableedit, id, cInfo, cValName } )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgCheckData( typePG, cValue, aData, mod )
*------------------------------------------------------------------------------*
   LOCAL n, c, aCol, nValue, cData, aDat, cToken, cErr := "", ret := .T.
   DO CASE
   CASE typePG == PG_STRING
      IF ValType( cValue ) != 'C'
         cErr := _HMG_PGLangError[4] + " STRING " + _HMG_PGLangError[2]
         ret := .F.
      ENDIF
   CASE typePG == PG_INTEGER
      cErr := _HMG_PGLangError[4] + " INTEGER " + _HMG_PGLangError[2]
      IF ValType( cValue ) == 'N'
         cValue := LTrim( Str( Int(cValue ) ) )
      ELSEIF ValType( cValue ) == 'C'
         IF IsDigit( cValue )
            cValue := LTrim( Str( Int(Val(cValue ) ) ) )
         ELSE
            ret := .F.
         ENDIF
      ELSE
         ret := .F.
      ENDIF
   CASE typePG == PG_DOUBLE
      cErr := _HMG_PGLangError[4] + " DOUBLE " + _HMG_PGLangError[2]
      IF ValType( cValue ) == 'N'
         cValue := LTrim( REMRIGHT( Str(cValue,16,8 ),'0' ) )
      ELSEIF ValType( cValue ) == 'C'
         IF IsDigit( cValue ) .OR. Left( cValue, 1 ) == '-'
            cValue := LTrim( REMRIGHT( Str(Val(CharRem(" ", cValue ) ), 16, 8 ), '0' ) )
         ELSE
            ret := .F.
         ENDIF
      ELSE
         ret := .F.
      ENDIF
      IF ! Empty( aData ) .AND. ret
         IF ValType( aData ) == 'N'
            aData := LTrim( REMRIGHT( Str(aData,16,8 ),'0' ) )
         ELSEIF ValType( cValue ) == 'C'
            ret := .T.
         ENDIF
         IF Ret
            FOR n := 1 TO Len ( aData )
               c := SubStr ( aData , n , 1 )
               IF !( c $ '9., ' )
                  cErr := _HMG_PGLangError[5] + " DOUBLE" + _HMG_PGLangError[2]
                  ret := .F.
               ENDIF
            NEXT
         ENDIF
      ENDIF

   CASE typePG == PG_SYSCOLOR
      IF PgIdentColor( 2, cValue ) == 0
         cErr := _HMG_PGLangError[4] + " SYSCOLOR " + _HMG_PGLangError[2]
         ret := .F.
      ENDIF
   CASE typePG == PG_COLOR
      aData := If( ValType( aData ) == "B", ;
         Eval( aData ), aData )
      aCol := PgIdentData( aData, PG_COLOR )
      TOKENINIT ( cValue, ' ,()' )
      n := 0
      DO WHILE !TOKENEND() .AND. n++ <= 3
         nValue := Val( TOKENNEXT ( cValue ) )
         IF nValue != aCol[n]
            aCol[n] := nValue
         ENDIF
      ENDDO
      TOKENEXIT()
      cValue := aCol2Str( aCol )
      aData :=  aVal2Str( aCol )
   CASE typePG == PG_USERFUN
      IF SubStr( AllTrim( aData ), 1, 1 ) != '{'
         aData := "{|x| " + aData + " }"
         IF ValType( &aData ) != 'B'
            cErr := _HMG_PGLangError[6] + " USERFUN " + _HMG_PGLangError[2]
            ret := .F.
         ENDIF
      ENDIF
   CASE typePG == PG_LOGIC
      IF At( cValue, 'true false' ) == 0
         cErr := _HMG_PGLangError[4] + " LOGIC " + _HMG_PGLangError[2]
         ret := .F.
      ENDIF
   CASE typePG == PG_DATE
      IF !Empty( cValue )
         IF Empty( CToD( cValue ) )
            cErr := _HMG_PGLangError[4] + " DATE " + _HMG_PGLangError[2]
            ret := .F.
         ENDIF
      ENDIF
   CASE typePG == PG_FONT
   CASE typePG == PG_ARRAY
   CASE typePG == PG_ENUM
      IF !( At( cValue, aData ) <> 0 .OR. CharOnly( cValue, aData ) == cValue )
         cErr := _HMG_PGLangError[4] + " ENUM " + _HMG_PGLangError[2]
         ret := .F.
      ENDIF
   CASE typePG ==  PG_LIST
      cData := aData // aData is a string but it isn't array here
      IF At( cValue, cData ) == 0
         cData := ( cData + ';' + AllTrim( cValue ) )
      ENDIF
   CASE typePG == PG_FLAG
      cData := CharRem ( "[]", cValue )
      TOKENINIT ( cData, ',' )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         IF At( cToken, aData ) == 0
            cErr := _HMG_PGLangError[4] + " FLAG " + _HMG_PGLangError[2]
            ret := .F.
         ENDIF
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_SYSINFO
      IF ValType( aData ) != "B"
         IF At( "SYSTEM", aData ) == 0
            IF At( "USERHOME", aData ) == 0
               IF At( "USERID", aData ) == 0
                  IF At( "USERNAME", aData ) == 0
                     cErr := _HMG_PGLangError[4] + " SYSINFO " + _HMG_PGLangError[2]
                     ret := .F.
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF

   CASE typePG == PG_IMAGE
   CASE typePG == PG_FILE
   CASE typePG == PG_FOLDER
   CASE typePG == PG_CHECK
      aDat := PgIdentData( aData )
      cErr := _HMG_PGLangError[4] + " CHECK " + _HMG_PGLangError[2]
      IF Len( aDat ) == 1
         IF At( aDat[1], 'true false' ) == 0
            ret := .F.
         ENDIF
      ELSE
         IF AScan( aDat, cValue ) == 0
            ret := .F.
         ENDIF
      ENDIF
   CASE typePG == PG_SIZE
      cData := CharRem ( "()", cValue )
      TOKENINIT ( cData, ',' )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         IF !IsDigit( cToken )
            cErr := _HMG_PGLangError[4] + " SIZE " + _HMG_PGLangError[2]
            ret := .F.
         ENDIF
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_PASSWORD
      IF Empty( aData )
         aData := Chr( 80 ) + Chr( 103 ) + Chr( 75 ) + Chr( 101 ) + Chr( 121 )
      ENDIF
   ENDCASE
   IF !ret
      IF Mod == 0
         MsgMiniGuiError ( cErr )
      ELSE
         MsgExclamation( cErr, _HMG_PGLangMessage[3], , .F. )
      ENDIF
   ENDIF

RETURN ret

*------------------------------------------------------------------------------*
PROCEDURE _EndCategory()
*------------------------------------------------------------------------------*
   AAdd( _HMG_ActivePropGridArray, { 'category', 'end', '', '', .F. , .F. , .F. , 0, '', '' } )

RETURN

*------------------------------------------------------------------------------*
PROCEDURE _EndPropGrid()
*------------------------------------------------------------------------------*
   IF Len( _HMG_ActivePropGridArray ) > 0
      PgInitItem( _HMG_ActivePropGridArray, _HMG_ActivePropGridIndex )
   ENDIF
   _HMG_aControlPageMap [_HMG_ActivePropGridIndex] := _HMG_ActivePropGridArray
   _HMG_ActivePropGridHandle := 0
   _HMG_ActiveCategoryHandle := 0
   _HMG_ActivePropGridIndex  := 0
   _HMG_ActivePropGridArray  := {}

RETURN

*------------------------------------------------------------------------------*
FUNCTION _ShowInfoItem  ( ParentForm, ControlName )
*------------------------------------------------------------------------------*
   LOCAL k, aControlHandle
   k := GetControlIndex ( ControlName, ParentForm )
   IF k > 0
      aControlHandle := _HMG_aControlHandles [k]
      Pg_ToggleInfo( aControlHandle[1] )
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _AddPropertyItem  ( ControlName , ParentForm, cCategory, cType, cName, cValue, aData, disabled, disableedit, id , Info, cValName, cValNameDef, mod )
*------------------------------------------------------------------------------*
   LOCAL aRowItem, hWndPG, nIndex, hItem, aNodeHandle := {}
   LOCAL typePg := PgIdentType( cType )
   DEFAULT cCategory := "", cValue := "", aData := "", disabled := .F. , disableedit := .F. , Id := 0, Info := "", cValNameDef := "", cValName := cValNameDef, Mod := 0

   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   nIndex := GetControlIndex ( ControlName, ParentForm )
   IF Empty( cCategory )
      hItem := TreeView_GetSelection( hWndPG )
   ELSE
      hItem := PG_SearchCategory( hWndPG, cCategory )
   ENDIF

   IF id == 0 .OR. PG_SearchID( hWndPG, Id ) == 0

      IF PgCheckData( typePG, @cValue, @aData, Mod )

         aRowItem := { cType, cName, cValue, aData, disabled, .F. , disableedit, Id, Info, cValName  }
         IF hItem != 0
            IF PG_GETITEM( hWndPG, hItem, PGI_TYPE ) == 1
               AAdd( aNodeHandle, hItem )
               PgAddItem( hWndPG, aRowItem, 1, aNodeHandle, nIndex, .T. )
            ELSEIF Empty( cCategory )
               hItem := TREEVIEW_GETPARENT( hWndPG, hItem )
               AAdd( aNodeHandle, hItem )
               PgAddItem( hWndPG, aRowItem, 1, aNodeHandle, nIndex, .T. )
            ELSE
               MsgInfo( _HMG_PGLangError[7], _HMG_PGLangMessage[3] )
            ENDIF
         ELSE
            MsgInfo( _HMG_PGLangError[8] + cCategory + _HMG_PGLangError[9], _HMG_PGLangMessage[3] )
         ENDIF
      ENDIF
   ELSE
      MsgInfo ( _HMG_PGLangError[10] + AllTrim( Str(Id ) ) + _HMG_PGLangError[11], _HMG_PGLangMessage[3] )
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _AddPropertyCategory  ( ControlName , ParentForm, cCategory, cName, id , Info )
*------------------------------------------------------------------------------*
   LOCAL aRowItem, hWndPG, nIndex, hItem, nLev, aNodeHandle := {}
   DEFAULT cCategory := "", Id := 0, Info := ""

   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   nIndex := GetControlIndex ( ControlName, ParentForm )
   IF Empty( cCategory ) .OR. Upper( cCategory )  == "ROOT"
      hItem := 0
      nLev  := 0
   ELSE
      hItem := PG_SearchCategory( hWndPG, cCategory )
      nLev  := 1
   ENDIF
   IF id == 0 .OR. PG_SearchID( hWndPG, Id ) == 0

      aRowItem := { "category", cName, "", "", .T. , .F. , .F. , Id, Info, "" }
      IF hItem != 0
         IF PG_GETITEM( hWndPG, hItem, PGI_TYPE ) == PG_CATEG
            AAdd( aNodeHandle, hItem )
            PgAddItem( hWndPG, aRowItem, nLev, aNodeHandle, nIndex, .T. )
         ELSEIF Empty( cCategory )
            hItem := TREEVIEW_GETPARENT( hWndPG, hItem )
            AAdd( aNodeHandle, hItem )
            PgAddItem( hWndPG, aRowItem, nLev, aNodeHandle, nIndex, .T. )
         ELSE
            MsgInfo( _HMG_PGLangError[7], _HMG_PGLangMessage[3] )
         ENDIF
      ELSE
         PgAddItem( hWndPG, aRowItem, nLev, aNodeHandle, nIndex, .F. )
      ENDIF
   ELSE
      MsgInfo ( _HMG_PGLangError[10] + AllTrim( Str(Id ) ) + _HMG_PGLangError[11], _HMG_PGLangMessage[3] )
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgInitItem( aRowItem, k )
*------------------------------------------------------------------------------*
   LOCAL nLev := 0, n
   LOCAL ControlHandle :=  _HMG_aControlHandles [k,1], aNodeHandle := { 0 }
//INFO aRowItem  => (Type,PropertyName,Value,Data,Disabled,changed,DisableEdit, ItemID, ItemInfo, ValueName
//                     1        2        3     4     5       6       7           8          9        10
   TreeView_DeleteAllItems ( ControlHandle  )
   FOR n := 1 TO Len( aRowItem )
      nLev := PgAddItem( ControlHandle, aRowItem[n], nLev, aNodeHandle, k )
   NEXT n
   IF _HMG_aControlInputMask [k]
      ExpandPG( ControlHandle, 1 )
   ENDIF
   TreeView_SelectItem ( ControlHandle , PG_GetRoot(  ControlHandle ) )
   SetFocus( ControlHandle )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgInitItemXml( cFile, k )
*------------------------------------------------------------------------------*
   LOCAL nLev, n, i
   LOCAL ControlHandle :=  _HMG_aControlHandles [k,1], aNodeHandle := { 0 }
   LOCAL aRowItem, oXmlDoc, oXmlNode, oXmlSubNode

   oXmlDoc := HXMLDoc():Read( cFile )
   TreeView_DeleteAllItems ( ControlHandle  )
   nLev := 0
//INFO aRowItem  => (Type,PropertyName,Value,Data,Disabled,changed,DisableEdit,ItemID, ItemInfo, ValueName
//                     1        2        3     4     5       6       7           8          9       10
   IF !Empty( oXmlDoc:aItems )
      FOR n := 1 TO Len( oXmlDoc:aItems[1]:aItems )
         oXmlNode := oXmlDoc:aItems[1]:aItems[n]
         IF oXmlNode:Title == "category"  .OR. oXmlNode:Title == "font"
            aRowItem := PgSetItemArray( oXmlNode )
            PgAddItem( ControlHandle, aRowItem, nLev, aNodeHandle, k )
            IF !Empty( oXmlNode:aItems )
               FOR i := 1 TO Len( oXmlNode:aItems )
                  oXmlSubNode := oXmlNode:aItems[i]
                  PgGetNextLevel( oXmlSubNode, ControlHandle, nLev, aNodeHandle, k )
               NEXT
            ENDIF
         ELSE
            aRowItem := PgSetItemArray( oXmlNode )
            PgAddItem( ControlHandle, aRowItem, nLev, aNodeHandle, k )
         ENDIF
      NEXT n
      _HMG_aControlCaption [k] := cFile
   ENDIF
   IF _HMG_aControlInputMask [k]
      ExpandPG( ControlHandle, 1 )
   ENDIF
   TreeView_SelectItem ( ControlHandle , PG_GetRoot(  ControlHandle ) )
   SetFocus( ControlHandle )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgGetNextLevel( oXmlSubNode, ControlHandle, nLev, aNodeHandle, k )
*------------------------------------------------------------------------------*
   LOCAL i, oXmlSubNode1, aRowItem
   nLev++
   IF oXmlSubNode:Title == "category"  .OR. oXmlSubNode:Title == "font"
      aRowItem := PgSetItemArray( oXmlSubNode )
      PgAddItem( ControlHandle, aRowItem, nLev, aNodeHandle, k )
      IF !Empty( oXmlSubNode:aItems )
         FOR i := 1 TO Len( oXmlSubNode:aItems )
            oXmlSubNode1 := oXmlSubNode:aItems[i]
            PgGetNextLevel( oXmlSubNode1, ControlHandle, nLev, aNodeHandle, k )
         NEXT
      ENDIF
   ELSE
      aRowItem := PgSetItemArray( oXmlsubNode )
      PgAddItem( ControlHandle, aRowItem, nLev, aNodeHandle, k )
   ENDIF

RETURN nlev

*------------------------------------------------------------------------------*
FUNCTION PgSetItemArray( oXmlNode )
*------------------------------------------------------------------------------*
   LOCAL aItem := {}
   AAdd ( aItem, oXmlNode:Title )
   AAdd ( aItem, PgGetAttr( oXmlNode,"Name" ) )
   AAdd ( aItem, PgGetAttr( oXmlNode,"Value" ) )
   AAdd ( aItem, PgGetAttr( oXmlNode,"cData" ) )
   AAdd ( aItem, ( PgGetAttr(oXmlNode,"disabled" ) == "true" ) )
   AAdd ( aItem, ( PgGetAttr(oXmlNode,"changed" ) == "true" ) )
   AAdd ( aItem, ( PgGetAttr(oXmlNode,"disableedit" ) == "true" ) )
   AAdd ( aItem, Val( PgGetAttr(oXmlNode,"ItemID" ) ) )
   AAdd ( aItem, PgGetAttr( oXmlNode,"Info" ) )
   AAdd ( aItem, PgGetAttr( oXmlNode,"VarName" ) )

RETURN aItem

*------------------------------------------------------------------------------*
FUNCTION PgGetAttr( oXmlNode, cAttr )
*------------------------------------------------------------------------------*
   LOCAL xAttr := oXmlNode:GetAttribute( cAttr )

RETURN IF( xAttr == Nil, "", xAttr )

*------------------------------------------------------------------------------*
FUNCTION ExpandPG( hWndPG, typ )
*------------------------------------------------------------------------------*
   LOCAL hItem
   SetFocus( hWndPG )
   hItem := PG_GetRoot( hWndPG )
   WHILE hItem != 0
      IF PG_GetItem( hWndPG, hItem, PGI_TYPE ) ==  PG_CATEG
         DO CASE
         CASE typ == 0
            SendMessage ( hWndPG , TVM_EXPAND, TVE_TOGGLE, hItem )
         CASE typ == 1
            SendMessage ( hWndPG , TVM_EXPAND, TVE_EXPAND, hItem )
         CASE typ == 2
            SendMessage ( hWndPG , TVM_EXPAND, TVE_COLLAPSE, hItem )
         ENDCASE
      ENDIF
      hItem := PG_GetNextItem( hWndPG, hItem )
   ENDDO

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION ExpandCategPG( ParentForm, ControlName, cCategory, typ )
*------------------------------------------------------------------------------*
   LOCAL k, hItem, hWndPG
   k := GetControlIndex ( ControlName, ParentForm )
   IF k > 0
      hWndPG := _HMG_aControlHandles  [k,1]
      SetFocus( hWndPG )
      hItem := PG_SearchCategory( hWndPG, cCategory )

      IF hItem != 0
         IF PG_GetItem( hWndPG, hItem, PGI_TYPE ) ==  PG_CATEG
            DO CASE
            CASE typ == 0
               SendMessage ( hWndPG , TVM_EXPAND, TVE_TOGGLE, hItem )
            CASE typ == 1
               SendMessage ( hWndPG , TVM_EXPAND, TVE_EXPAND, hItem )
            CASE typ == 2
               SendMessage ( hWndPG , TVM_EXPAND, TVE_COLLAPSE, hItem )
            ENDCASE
         ENDIF
      ENDIF
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgAddItem( ControlHandle, aRowIt, nLev, aNodeHandle, nIndex, lSelect )
*------------------------------------------------------------------------------*
   LOCAL n, nNodeH := 0 , PropType, nNodePrevH , ImgId, ImgIdSel, cInfo, cValName
   LOCAL aData, nCheck, ItemType, ItemID
   DEFAULT lSelect := .F.
   PropType := Lower( aRowIt[APG_TYPE] )
   ItemType   := PgIdentType( aRowIt[APG_TYPE] )
   ItemId := IF( Len( aRowIt ) < APG_ID, 0, aRowIt[APG_ID] )
   cInfo := IF( Len( aRowIt ) < APG_INFO, "", aRowIt[APG_INFO] )
   cValName := IF( Len( aRowIt ) < APG_VALNAME, "", aRowIt[APG_VALNAME] )
   DO CASE
   CASE PropType == 'category'
      IF Lower( aRowIt[2] ) == 'end'
         nLev--
         RETURN nLev
      ELSE
         nNodePrevH := IF( nLev > 0, aNodeHandle [nLev] , 0 )
         nNodeH := AddPGItem ( ControlHandle , nNodePrevH , "", 0, 0 , 0, aRowIt[2], aRowIt[3], aRowIt[4], aRowIt[5], aRowIt[6], aRowIt[7], ItemType, ItemID, cInfo, cValName )
         nLev++
         IF Len( aNodeHandle ) >= nLev
            aNodeHandle[nLev] := nNodeH
         ELSE
            AAdd( aNodeHandle, nNodeH )
         ENDIF
         TreeView_SetBoldItem( ControlHandle,  nNodeH , .T. )
      ENDIF
   CASE PropType == 'font'
      IF nLev > 0
         nNodeH := AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aRowIt[2], aRowIt[3], aRowIt[4], aRowIt[5], aRowIt[6], aRowIt[7], ItemType, ItemID, cInfo, cValName )
         aData := PgIdentData( aRowIt[4], PG_FONT )
         nLev++
         IF Len( aNodeHandle ) >= nLev
            aNodeHandle[nLev] := nNodeH
         ELSE
            AAdd( aNodeHandle, nNodeH )
         ENDIF
         FOR n := 1 TO Len( aData )
            AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aData[n,2], aData[n,3], "FONT", .F. , .F. , .F. , PgIdentType( aData[n,1] ), 0, "", "" )
         NEXT
         nLev--
      ENDIF
   CASE PropType == 'flag'
      IF nLev > 0
         nNodeH := AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aRowIt[2], aRowIt[3], aRowIt[4], aRowIt[5], aRowIt[6], aRowIt[7], ItemType, ItemID, cInfo, cValName )
         aData := PgIdentData( aRowIt[4], PG_FLAG, aRowIt[3] )
         nLev++
         IF Len( aNodeHandle ) >= nLev
            aNodeHandle[nLev] := nNodeH
         ELSE
            AAdd( aNodeHandle, nNodeH )
         ENDIF
         FOR n := 1 TO Len( aData )
            AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aData[n,2], aData[n,3], "FLAG", .F. , .F. , .F. , PgIdentType( aData[n,1] ), 0, "", "" )
         NEXT
         nLev--
      ENDIF
   CASE PropType == 'size'
      IF nLev > 0
         nNodeH := AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aRowIt[2], aRowIt[3], aRowIt[4], aRowIt[5], aRowIt[6], aRowIt[7], ItemType, ItemID, cInfo, cValName )
         aData := PgIdentData( aRowIt[4], PG_SIZE, aRowIt[3] )
         nLev++
         IF Len( aNodeHandle ) >= nLev
            aNodeHandle[nLev] := nNodeH
         ELSE
            AAdd( aNodeHandle, nNodeH )
         ENDIF
         FOR n := 1 TO Len( aData )
            AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", 0, 0, 0, aData[n,1], aData[n,2], "SIZE", .F. , .F. , .F. , PG_INTEGER, 0, "", "" )
         NEXT
         nLev--
      ENDIF
   OTHERWISE
      ImgId := 0
      ImgIdSel := 0
      nCheck := 0
      IF PropType == 'color'
         ImgId  := PgAddColorIL( aRowIt[3], nIndex ) + 1
         ImgIdSel := ImgId
      ENDIF
      IF PropType == 'syscolor'
         ImgId  := PgAddColorIL( aRowIt[3], nIndex ) + 1
         ImgIdSel := ImgId
      ENDIF
      IF  PropType == 'sysinfo'
         aRowIt[3] := PgGetSysInfo( aRowIt )
      ENDIF
      IF  PropType == 'image'
         ImgId  := PgLoadImag( aRowIt[3], nIndex ) + 1
         ImgIdSel := ImgId
      ENDIF
      IF  PropType == 'check'
         aData := PgIdentData( aRowIt[APG_DATA] )
         IF Len( aData ) == 1
            nCheck := IF( aData[1] == 'true', 2, 1 )
         ELSE
            IF ( nCheck := AScan( aData,aRowIt[APG_VALUE] ) ) == 0
               nCheck := 1
            ENDIF
         ENDIF
      ENDIF
      IF nLev > 0
         nNodeH := AddPGItem ( ControlHandle , aNodeHandle [nLev] , "", ImgId, ImgIdSel, nCheck, aRowIt[2], aRowIt[3], aRowIt[4], aRowIt[5], aRowIt[6], aRowIt[7], ItemType, ItemID, cInfo, cValName  )
         IF nLev == 1
            TreeView_SetBoldItem( ControlHandle,  nNodeH )
         ENDIF
      ENDIF
   ENDCASE
   IF lSelect
      TreeView_SelectItem ( ControlHandle , nNodeH )
   ENDIF

RETURN nLev

*------------------------------------------------------------------------------*
FUNCTION PgGetSysInfo( aRowIt )
*------------------------------------------------------------------------------*
   LOCAL aDan, cDan := aRowIt[APG_VALUE]
   LOCAL typ
   IF  ValType( aRowIt[APG_DATA] ) == "B"
      cDan := Eval( aRowIt[APG_DATA] )
      IF ValType( cDan ) != 'C'
         cDan := aRowIt[APG_VALUE]
      ENDIF
   ELSE
      typ := Lower( aRowIt[APG_DATA] )
      DO CASE
      CASE typ == "system"
         aDan := WindowsVersion()
         cDan := aDan[1] + "(" +  aDan[2] + ',' + aDan[3] + ")"
      CASE typ == "username"
         cDan := GetComputerName ( )
      CASE typ == "userid"
         cDan :=   GetUserName()
      CASE typ == "userhome"
         cDan :=  GetMyDocumentsFolder ( )
      ENDCASE
   ENDIF

RETURN cDan

*------------------------------------------------------------------------------*
FUNCTION PgAddColorIL( cColor, k )
*------------------------------------------------------------------------------*
   LOCAL hImageLst, nColor, hImage, ItHeight, ItWidth
   hImageLst := _HMG_aControlSpacing[k]
   ItHeight := _HMG_aControlRangeMin [k] - 4
   ItWidth := ItHeight * 1.4
   nColor := PgIdentColor( 0, cColor )
   hImage := CREATECOLORBMP( _HMG_aControlParentHandles [k], nColor, ItWidth, ItHeight )

RETURN  IL_AddMaskedIndirect( hImageLst , hImage , , ItWidth , ItHeight , 1 )

*------------------------------------------------------------------------------*
FUNCTION PgLoadImag( cFile, k, hItem )
*------------------------------------------------------------------------------*
   LOCAL hImageLst, hImage, ItHeight, ItWidth
   DEFAULT hItem := 0
   hImageLst :=  _HMG_aControlSpacing[k]
   ItHeight :=  _HMG_aControlRangeMin [k] - 4
   ItWidth := ItHeight * 1.4
   hImage := PG_SetPicture( _HMG_aControlHandles [k,6], cFile, ItWidth, ItHeight )
   IF hItem == 0
      RETURN IL_AddMaskedIndirect( hImageLst , hImage , , ItWidth , ItHeight , 1 )

   ENDIF
   ResetPropGridImageList( _HMG_aControlHandles [k,1], hItem, hImage )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION PgIdentData( cData, typePG, cValue, sep )
*------------------------------------------------------------------------------*
   LOCAL aData := {}, cToken, n := 1, pos, cLogic
   DEFAULT sep := ';', typePG := PG_DEFAULT
   DO CASE
   CASE typePG == PG_DEFAULT
      TOKENINIT ( cData, sep )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         AAdd( aData, cToken )
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_COLOR
      aData := { 0, 0, 0 }
      cData := REMALL ( cData, '()' )
      TOKENINIT ( cData, sep )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         aData[n++] := Val( cToken )
         IF n > 3
            EXIT
         ENDIF
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_FONT
      IF sep == ','
         aData := { "", "", "false", "false", "false", "false" }
      ENDIF
      n := 1
      TOKENINIT ( cData, sep )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         IF sep == ','
            IF n < 3
               aData[n] := cToken
            ELSE
               IF ( pos := AScan( aFontName,cToken ) ) > 0
                  aData[pos] := "true"
               ENDIF
            ENDIF
         ELSE
            AAdd( aData, { aFontType[n], aFontName[n], cToken } )
         ENDIF
         n++
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_FLAG
      cValue := CharRem ( "[]", cValue )
      TOKENINIT ( cData, ';' )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         cLogic := IF( At( cToken,cValue ) != 0, 'true', 'false' )
         AAdd( aData, { 'logic', cToken, cLogic } )
         IF cLogic == 'false'
            aData[1,3] := cLogic
         ENDIF
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_SIZE
      TOKENINIT ( cData, ';' )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         AAdd( aData, { cToken, "" } )
      ENDDO
      TOKENEXIT()
      cValue := CharRem ( "()", cValue )
      TOKENINIT ( cValue, ',' )
      n := 1
      DO WHILE !TOKENEND() .AND. n <= Len( aData )
         cToken := AllTrim( TOKENNEXT ( cValue ) )
         aData[n,2] := cToken
         n++
      ENDDO
      TOKENEXIT()
   CASE typePG == PG_FILE .OR. typePG == PG_IMAGE
      TOKENINIT ( cData, ';' )
      DO WHILE !TOKENEND()
         cToken := AllTrim( TOKENNEXT ( cData ) )
         AAdd( aData, { 'File (' + cToken + ')', cToken } )
      ENDDO
      TOKENEXIT()
   ENDCASE

RETURN aData

*------------------------------------------------------------------------------*
FUNCTION PgIdentType( cType )
*------------------------------------------------------------------------------*
   LOCAL ItemType := PG_DEFAULT
   IF ValType( cType ) == 'C'
      cType := AllTrim( Lower( cType ) )
      DO CASE
      CASE cType == 'category'
         ItemType := PG_CATEG
      CASE cType == 'string'
         ItemType := PG_STRING
      CASE cType == 'numeric' .OR. cType == 'integer'
         ItemType := PG_INTEGER
      CASE cType == 'double'
         ItemType := PG_DOUBLE
      CASE cType == 'logic'
         ItemType := PG_LOGIC
      CASE cType == 'font'
         ItemType := PG_FONT
      CASE cType == 'color'
         ItemType := PG_COLOR
      CASE cType == 'syscolor'
         ItemType := PG_SYSCOLOR
      CASE cType == 'array'
         ItemType := PG_ARRAY
      CASE cType == 'enum'
         ItemType := PG_ENUM
      CASE cType == 'date'
         ItemType := PG_DATE
      CASE cType == 'image'
         ItemType := PG_IMAGE
      CASE cType == 'sysinfo'
         ItemType := PG_SYSINFO
      CASE cType == 'flag'
         ItemType := PG_FLAG
      CASE cType == 'check'
         ItemType := PG_CHECK
      CASE cType == 'size'
         ItemType := PG_SIZE
      CASE cType == 'file'
         ItemType := PG_FILE
      CASE cType == 'folder'
         ItemType := PG_FOLDER
      CASE cType == 'list'
         ItemType := PG_LIST
      CASE cType == 'userfun'
         ItemType := PG_USERFUN
      CASE cType == 'password'
         ItemType := PG_PASSWORD
      OTHERWISE
         ItemType := PG_ERROR
      ENDCASE
   ELSE
      DO CASE
      CASE cType == PG_CATEG
         ItemType := 'category'
      CASE cType == PG_STRING .OR. cType == PG_DEFAULT
         ItemType := 'string'
      CASE cType == PG_INTEGER
         ItemType := 'numeric'
      CASE cType == PG_DOUBLE
         ItemType := 'double'
      CASE cType == PG_LOGIC
         ItemType := 'logic'
      CASE cType == PG_FONT
         ItemType := 'font'
      CASE cType == PG_COLOR
         ItemType := 'color'
      CASE cType == PG_SYSCOLOR
         ItemType := 'syscolor'
      CASE cType == PG_ARRAY
         ItemType := 'array'
      CASE cType == PG_ENUM
         ItemType := 'enum'
      CASE cType == PG_DATE
         ItemType := 'date'
      CASE cType == PG_IMAGE
         ItemType := 'image'
      CASE cType == PG_SYSINFO
         ItemType := 'sysinfo'
      CASE cType == PG_FLAG
         ItemType := 'flag'
      CASE cType == PG_CHECK
         ItemType := 'check'
      CASE cType == PG_SIZE
         ItemType := 'size'
      CASE cType == PG_FILE
         ItemType := 'file'
      CASE cType == PG_FOLDER
         ItemType := 'folder'
      CASE cType == PG_LIST
         ItemType := 'list'
      CASE cType == PG_USERFUN
         ItemType := 'userfun'
      CASE cType == PG_PASSWORD
         ItemType := 'password'
      ENDCASE
   ENDIF

RETURN ItemType

*------------------------------------------------------------------------------*
FUNCTION PgIdentColor( met, cColor )
*------------------------------------------------------------------------------*
   LOCAL nColor := CLR_NONE, pos, aCol, cToken, result
   LOCAL aSysColor := ;
      { { COLOR_3DDKSHADOW,   "ControlDark" }, ;
      { COLOR_BTNFACE,      "ButtonFace" }, ;
      { COLOR_BTNHIGHLIGHT, "ButtonHighlight" }, ;
      { COLOR_3DLIGHT,      "ControlLight" }, ;
      { COLOR_BTNSHADOW,    "ButtonShadow" }, ;
      { COLOR_ACTIVEBORDER, "ActiveBorder" }, ;
      { COLOR_ACTIVECAPTION, "ActiveCaption" }, ;
      { COLOR_APPWORKSPACE, "AppWorkspace" }, ;
      { COLOR_BACKGROUND,   "Desktop" }, ;
      { COLOR_BTNTEXT,      "ButtonText" }, ;
      { COLOR_CAPTIONTEXT,  "CaptionText" }, ;
      { COLOR_GRAYTEXT,     "GrayText" }, ;
      { COLOR_HIGHLIGHT,    "Highlight" }, ;
      { COLOR_HIGHLIGHTTEXT, "HighlightText" }, ;
      { COLOR_INACTIVEBORDER, "InactiveBorder" }, ;
      { COLOR_INACTIVECAPTION, "InactiveCaption" }, ;
      { COLOR_INACTIVECAPTIONTEXT, "InactiveCaptionText" }, ;
      { COLOR_INFOBK,       "Tooltip" }, ;
      { COLOR_INFOTEXT,     "TooltipText" }, ;
      { COLOR_MENU,         "Menu" }, ;
      { COLOR_MENUTEXT,     "MenuText" }, ;
      { COLOR_SCROLLBAR,    "Scroll" }, ;
      { COLOR_WINDOW,       "Window" }, ;
      { COLOR_WINDOWFRAME,  "WindowFrame" }, ;
      { COLOR_WINDOWTEXT,   "WindowText" } }

   LOCAL aColor := { { YELLOW,   "YELLOW" }, ;
      { PINK,     "PINK" }, ;
      { RED,      "RED" }, ;
      { FUCHSIA,  "FUCHSIA" }, ;
      { BROWN,    "BROWN" }, ;
      { ORANGE,   "ORANGE" }, ;
      { GREEN,    "GREEN" }, ;
      { PURPLE,   "PURPLE" }, ;
      { BLACK,    "BLACK" }, ;
      { WHITE,    "WHITE" }, ;
      { GRAY,     "GRAY" }, ;
      { BLUE,     "BLUE" } }
   DEFAULT met := 0
   DO CASE
   CASE met == 0
      cColor := AllTrim( cColor )
      IF ( pos := AScan ( aSysColor , {|x|  Upper(x[2] ) == Upper(cColor ) } ) ) > 0
         nColor := GetSysColor ( aSysColor[pos,1] )
      ELSEIF ( pos := AScan ( aColor , {|x|  Upper(x[2] ) == Upper(cColor ) } ) ) > 0
         nColor := RGB( aColor [pos,1], aColor [ pos,2 ], aColor [ pos,3 ] )
      ELSE
         IF SubStr( cColor, 1, 1 ) == '(' .AND. RAt( ')', cColor ) == Len( cColor )
            aCol := {}
            TOKENINIT ( cColor, ' ,()' )
            DO WHILE !TOKENEND()
               cToken := AllTrim( TOKENNEXT ( cColor ) )
               AAdd( aCol, Val( cToken ) )
            ENDDO
            TOKENEXIT()
            nColor := RGB( aCol [ 1 ], aCol [ 2 ], aCol [ 3 ] )
         ENDIF
      ENDIF
      result := nColor
   CASE met == 1
      result := aSysColor
   CASE met == 2
      result := AScan ( aSysColor , {|x|  Upper( x[2] ) == Upper( AllTrim(cColor ) ) } )
   ENDCASE

RETURN result

*------------------------------------------------------------------------------*
FUNCTION PgSaveFile( ParentForm, ControlName, cFile )
*------------------------------------------------------------------------------*
   LOCAL oXmlDoc, lSave := .T. , cExt
   cExt := Lower( SubStr( cFile,RAt('.',cFile ) + 1 ) )
   IF File( cFile )
      IF !MsgYesNo ( _HMG_PGLangMessage[1] + CRLF + _HMG_PGLangButton [5] + ": " + cFile + " ?" , _HMG_PGLangMessage[4] )
         lSave := .F.
      ENDIF
   ELSEIF Empty( cFile )
      MsgInfo ( "No File to save" , _HMG_BRWLangError[10] )
      lSave := .F.
   ENDIF
   IF lSave
      DO CASE
      CASE cExt == 'xml'
         oXmlDoc := CreatePropXml( ParentForm, ControlName )
         oXmlDoc:Save( cFile )
      CASE cExt == 'txt'
         lSave := CreatePropFile( ParentForm, ControlName, cFile )
      CASE cExt == 'ini'
         lSave := CreateIniFile( ParentForm, ControlName, cFile )
      CASE Empty( cExt )
         lSave := SaveMemVarible( ParentForm, ControlName )
      ENDCASE
   ENDIF

RETURN lSave

*------------------------------------------------------------------------------*
FUNCTION CreatePropXml( ParentForm, ControlName )
*------------------------------------------------------------------------------*
   LOCAL aLev := {}, aNode := {}, aItemRt, hItem, hParentItem
   LOCAL oXmlDoc      := HXMLDoc():new( _HMG_PGEncodingXml )
   LOCAL oXmlSubNode, oXmlNodeAkt
   LOCAL hWndPG := GetPGControlHandle ( ControlName, ParentForm )

   hItem := PG_GetRoot( hWndPG )
   hParentItem := TreeView_GetParent( hWndPG, hItem )      // Parent Item

   oXmlNodeAkt := HXMLNode():New( "ROOT" )
   oXmlNodeAkt:SetAttribute( "Title", "PropertyGrid" )
   oXmlDoc:add( oXmlNodeAkt )
   AAdd( aNode, oXmlNodeAkt )
   AAdd( aLev, hParentItem )
   WHILE hItem != 0
      hParentItem := TreeView_GetParent( hWndPG, hItem )   // Parent Item
      aItemRt := PG_GetItem( hWndPG, hItem, PGI_ALLDATA )
      IF aItemRt[PGI_CHG]
         Pg_ChangeItem( hWndPG, hItem, .F. )
         PG_REDRAWITEM( hWndPG, hItem )
      ELSEIF aItemRt[PGI_TYPE] == PG_PASSWORD
         aItemRt[PGI_VALUE] := ValueTran( aItemRt[PGI_VALUE], aItemRt[PGI_TYPE], aItemRt[PGI_DATA] )
      ENDIF
      DO WHILE ATail( aLev ) != hParentItem
         aLev := ASize( aLev, Len( aLev ) - 1 )
         aNode := ASize( aNode, Len( aLev ) )
      ENDDO
      oXmlNodeAkt := ATail( aNode )

      IF PgIdentType( aItemRt[PGI_TYPE] ) == "category"
         oXmlSubNode := HXMLNode():New( PgIdentType( aItemRt[PGI_TYPE] ), , AttrCreate( aItemRt ) )
         oXmlNodeAkt:add( oXmlSubNode )
         AAdd( aNode, oXmlSubNode )
         AAdd( aLev, hItem )
      ELSE
         oXmlSubNode := HXMLNode():New( PgIdentType( aItemRt[PGI_TYPE] ), HBXML_TYPE_SINGLE, AttrCreate( aItemRt ) )
         oXmlNodeAkt:add( oXmlSubNode )
      ENDIF
      hItem := GetNextItemPG( hWndPG, hItem )
   ENDDO

RETURN oXmlDoc

*------------------------------------------------------------------------------*
FUNCTION GetNextItemPG( hWndPG, hItem )
*------------------------------------------------------------------------------*
   LOCAL TypePG, hItemParent
   TypePG := PG_GetItem( hWndPG, hItem, PGI_TYPE )
   hItemParent := hItem
   hItem := PG_GetNextItem( hWndPG, hItem )
   IF TypePG == PG_FONT .OR. TypePG == PG_FLAG .OR. TypePG == PG_SIZE
      DO WHILE hItemParent == TreeView_GetParent( hWndPG, hItem )
         hItem := PG_GetNextItem( hWndPG, hItem )
      ENDDO
   ENDIF

RETURN hItem

*------------------------------------------------------------------------------*
FUNCTION  AttrCreate( aItProperty )
*------------------------------------------------------------------------------*
//INFO aItProperty  => (Type,PropertyName,Value,Data,Disabled,changed,DisableEdit, ItemID, ItemInfo, ValueName
//                     1        2          3     4     5       6       7           8          9        10
   LOCAL aAttr := {}
   AAdd( aAttr, { "Name", AttrTran( aItProperty[PGI_NAME],'C' ) } )
   AAdd( aAttr, { "Value", AttrTran( aItProperty[PGI_VALUE],'C' ) } )
   AAdd( aAttr, { "cData", AttrTran( aItProperty[PGI_DATA],'C' ) } )
   AAdd( aAttr, { "disabled", AttrTran( aItProperty[PGI_ENAB],'L' ) } )
   AAdd( aAttr, { "changed", AttrTran( aItProperty[PGI_CHG],'L' ) } )
   AAdd( aAttr, { "disableedit", AttrTran( aItProperty[PGI_DIED],'L' ) } )
   AAdd( aAttr, { "ItemID", AttrTran( aItProperty[PGI_ID],'N' ) } )
   AAdd( aAttr, { "Info", AttrTran( aItProperty[PGI_INFO],'C' ) } )
   AAdd( aAttr, { "VarName", AttrTran( aItProperty[PGI_VAR],'C' ) } )

RETURN aAttr

*------------------------------------------------------------------------------*
FUNCTION AttrTran( xData, type )
*------------------------------------------------------------------------------*
   LOCAL n, cData
   DO CASE
   CASE ValType( xData ) == 'U'
      RETURN IF( Type == 'L', "false", "" )
   CASE Type == 'C'
      IF ValType( xData ) == 'C'
         RETURN xData
      ENDIF
   CASE Type == 'N'
      IF ValType( xData ) == 'N'
         RETURN AllTrim( Str( xData ) )
      ENDIF
   CASE Type == 'A'
      IF ValType( xData ) == 'A'
         cData := ""
         FOR n := 1 TO Len( xData )
            IF ValType( xdata[n] ) == 'N'
               cData += AllTrim( Str( xData[n] ) ) + IF( n < Len( xData ), ';', '' )
            ENDIF
            IF ValType( xdata[n] ) == 'C'
               cData += xData[n] + IF( n < Len( xData ), ';', '' )
            ENDIF
            IF ValType( xdata[n] ) == 'L'
               cData += IF( xData[n], "true", "false" ) + IF( n < Len( xData ), ';', '' )
            ENDIF
         NEXT
         RETURN cData
      ENDIF
   CASE Type == 'L'
      IF ValType( xData ) == 'L'
         RETURN IF( xData, "true", "false" )
      ENDIF
   ENDCASE

RETURN ""

*------------------------------------------------------------------------------*
FUNCTION CreatePropFile( ParentForm, ControlName, cFile )
*------------------------------------------------------------------------------*
   LOCAL aLev := {}, aItemRt, hItem, hParentItem
   LOCAL hand, lret := .F.
   LOCAL hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   hand := FCreate( cFile, 0 )
   IF FError() == 0
      lret := .T.
      hItem := PG_GetRoot(  hWndPG )
      hParentItem := TreeView_GetParent( hWndPG, hItem )      // Parent Item
      AAdd( aLev, hParentItem )
      WHILE hItem != 0
         aItemRt := PG_GetItem( hWndPG, hItem, PGI_ALLDATA )
         IF aItemRt[PGI_CHG]
            Pg_ChangeItem( hWndPG, hItem, .F. )
            PG_REDRAWITEM( hWndPG, hItem )
         ENDIF
         IF PgIdentType( aItemRt[PGI_TYPE] ) == "category"
            AAdd( aLev, hItem )
            lret := ItemRt2File( hand, aItemRt )
         ELSE
            lret := ItemRt2File( hand, aItemRt )
         ENDIF
         hItem := GetNextItemPG( hWndPG, hItem )
         hParentItem := TreeView_GetParent( hWndPG, hItem )   // Parent Item
         DO WHILE ATail( aLev ) != hParentItem
            aLev := ASize( aLev, Len( aLev ) - 1 )
            lret := ItemRt2File( hand, { "end", "", "", "", "", "", 1, 0, "", "" } )
         ENDDO
      ENDDO
      FClose( hand )
   ENDIF

RETURN lret

*------------------------------------------------------------------------------*
FUNCTION CreateIniFile( ParentForm, ControlName, cFile )
*------------------------------------------------------------------------------*
   LOCAL cSection := "", aItemRt, hItem
   LOCAL lret := .F.
   LOCAL hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   IF _BeginIni( cFile ) == 0
      lRet := .T.
      hItem := PG_GetRoot(  hWndPG )
      WHILE hItem != 0
         aItemRt := PG_GetItem( hWndPG, hItem, PGI_ALLDATA )
         IF aItemRt[PGI_CHG]
            Pg_ChangeItem( hWndPG, hItem, .F. )
            PG_REDRAWITEM( hWndPG, hItem )
         ELSEIF aItemRt[PGI_TYPE] == PG_PASSWORD
            aItemRt[PGI_VALUE] := ValueTran( aItemRt[PGI_VALUE], aItemRt[PGI_TYPE], aItemRt[PGI_DATA] )
         ENDIF
         IF PgIdentType( aItemRt[PGI_TYPE ] ) == "category"
            cSection := aItemRt[PGI_NAME]
         ELSE
            SET  SECTION cSection ENTRY aItemRt[PGI_NAME]  TO aItemRt[PGI_VALUE]
         ENDIF
         hItem := PG_GetNextItem( hWndPG, hItem )
      ENDDO
      _EndIni()
   ENDIF

RETURN lret

*------------------------------------------------------------------------------*
FUNCTION SaveMemVarible( ParentForm, ControlName )
*------------------------------------------------------------------------------*
   LOCAL aItemRt, hItem, cVar, lRet := .F. , hWndPG
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   hItem := PG_GetRoot( hWndPG )
   WHILE hItem != 0
      aItemRt := PG_GetItem( hWndPG, hItem, PGI_ALLDATA )
      IF aItemRt[PGI_CHG]
         cVar := aItemRt[PGI_VAR]
         IF Type( cVar ) != 'U'
            IF aItemRt[PGI_TYPE] == PG_ARRAY
               &cVar := PgIdentData( aItemRt[PGI_VALUE], , , ',' )
            ELSE
               &cVar := aItemRt[PGI_VALUE]
            ENDIF
            lRet := .T.
         ENDIF
         Pg_ChangeItem( hWndPG, hItem, .F. )
         PG_REDRAWITEM( hWndPG, hItem )
      ENDIF
      hItem := PG_GetNextItem( hWndPG, hItem )
   ENDDO

RETURN lRet

*------------------------------------------------------------------------------*
FUNCTION GetChangedItem( ParentForm, ControlName )
*------------------------------------------------------------------------------*
   LOCAL cSection := "", hItem, hWndPG
   LOCAL aRetItem := {}
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   hItem := PG_GetRoot(  hWndPG )
   WHILE hItem != 0
      IF PG_GetItem( hWndPG, hItem, PGI_CHG )
         AAdd( aRetItem, PG_GetItem( hWndPG, hItem,PGI_ID ) )
      ENDIF
      hItem := PG_GetNextItem( hWndPG, hItem )
   ENDDO

RETURN aRetItem

*------------------------------------------------------------------------------*
FUNCTION ItemRt2File( hand, aItemRt )
*------------------------------------------------------------------------------*
   LOCAL n, aAttr := AttrCreate( aItemRt )
   LOCAL lin := '"' + PgIdentType( aItemRt[7] ) + '" '

   FOR n := 1 TO Len( aAttr )
      IF n == 4
         IF aAttr[n,2] == "true"
            lin += '"' + aAttr[n,1] + '" '
         ELSE
            lin += '"" '
         ENDIF
      ELSEIF  n == 5
         lin += '"" '
      ELSE
         lin += '"' + aAttr[n,2] + '" '
      ENDIF
   NEXT
   lin += CRLF
   FWrite( hand, lin, Len( lin ) )

RETURN ( FError() == 0 )

#define NM_SETFOCUS      -7
#define NM_KILLFOCUS    (-8)
#define LVN_ITEMCHANGED (-101)
#define NM_DBLCLK       (-3)

*------------------------------------------------------------------------------*
FUNCTION OPROPGRIDEVENTS( hWnd, nMsg, wParam, lParam, hItem, hEdit )
*------------------------------------------------------------------------------*
   LOCAL i, ItemType, iCheck, cData, aData, cValue
   DO CASE
   CASE nMsg == WM_CHAR
      IF wParam == 27
         _PGInitData( hWnd, hEdit, hItem, PG_GETITEM( hWnd, hItem, PGI_TYPE ) )
      ENDIF
   CASE nMsg == WM_LBUTTONUP
      RETURN 0
   CASE nMsg == WM_LBUTTONDOWN
      RETURN 0
   CASE nMsg == WM_LBUTTONDBLCLK
      IF hItem != 0
         ItemType := PG_GetItem( hWnd, hItem, PGI_TYPE )
         IF ItemType == PG_CATEG .OR. ItemType == PG_FONT .OR. ItemType == PG_FLAG .OR. ItemType == PG_SIZE
            SendMessage ( hWnd , TVM_EXPAND, TVE_TOGGLE, hItem )
            RETURN 1
         ENDIF
      ENDIF
      RETURN 0
   CASE nMsg == WM_COMMAND
      IF  HIWORD( wParam ) == EN_CHANGE .AND. lParam == hItem
         i := AScan ( _HMG_aControlHandles , {|x| ValType( x ) == 'A' .AND. x[1] == hWnd } )
         IF i > 0
            _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
            _DoControlEventProcedure ( _HMG_aControlHeadClick [i] , i )
         ENDIF
      ENDIF
      IF  HIWORD( wParam ) == BN_CLICKED
         IF PG_GetItem( hWnd, hItem, PGI_TYPE ) == PG_CHECK
            iCheck := LOWORD( wParam )
            cData  := PG_GETITEM( hWnd, hItem, PGI_DATA )
            IF !Empty( cData )
               aData := PgIdentData( cData )
               IF Len( aData ) >= 2
                  cValue := aData[iCheck]
                  PG_SETDATAITEM( hWnd, hItem, cValue, cData, .F. )
               ELSE
                  cValue := PG_GETITEM( hWnd, hItem, PGI_VALUE )
                  cData := IF( iCheck == 2, 'true', 'false' )
                  PG_SETDATAITEM( hWnd, hItem, cValue, cData, .T. )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      IF  HIWORD( wParam ) == CBN_KILLFOCUS
         IF PG_GetItem( hWnd, hItem, PGI_TYPE ) == PG_LIST
            cValue := GetWindowText ( hEdit )
            cData  := PG_GETITEM( hWnd, hItem, PGI_DATA )
            IF !Empty( cData )
               aData := PgIdentData( cData )
               IF AScan( aData, cValue ) == 0
                  cData := cData + ";" + cValue
                  PG_SETDATAITEM( hWnd, hItem, cValue, cData, .T. )
               ENDIF
            ELSE
               PG_SETDATAITEM( hWnd, hItem, cValue, cValue, .T. )
            ENDIF
         ENDIF
      ENDIF
      IF  HIWORD( wParam ) == EN_CHANGE
         IF PG_GetItem( hWnd, hItem, PGI_TYPE ) == PG_DOUBLE .OR. ;
               ( PG_GetItem( hWnd, hItem, PGI_TYPE ) == PG_STRING .AND. !Empty( PG_GETITEM(hWnd,hItem,PGI_DATA ) ) )
            cValue :=  GetWindowText ( hEdit )
            cData := PG_GETITEM( hWnd, hItem, PGI_DATA )
            IF !Empty( cData )
               CharMaskEdit ( hEdit, cValue , cData )
            ELSE
               CharMaskEdit ( hEdit, cValue )
            ENDIF
         ENDIF
      ENDIF
   CASE nMsg == WM_NOTIFY
      i := AScan ( _HMG_aControlHandles , {|x| ValType( x ) == 'A' .AND. x[1] ==  GetHwndFrom ( lParam ) } )
      IF i > 0
         IF GetNotifyCode ( lParam ) = TVN_SELCHANGED   //Tree
            _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
            RETURN 0
         ENDIF

         // PropGrid Double Click .........................

         IF GetNotifyCode ( lParam ) == NM_DBLCLK
            _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            RETURN 0
         ENDIF

         IF GetNotifyCode ( lParam ) = - 181
            ReDrawWindow ( _hmg_acontrolhandles [i,1] )
         ENDIF
      ENDIF
   ENDCASE

RETURN 1

*------------------------------------------------------------------------------*
FUNCTION aCol2Str( aColor )
*------------------------------------------------------------------------------*
   LOCAL n, cColor := "("
   FOR n := 1 TO 3
      cColor += AllTrim( Str( aColor[n] ) + IF( n < 3,',',')' ) )
   NEXT

RETURN cColor

*------------------------------------------------------------------------------*
FUNCTION aFont2Str( aFont )
*------------------------------------------------------------------------------*
   LOCAL n, cValue := "" , sep := ""
   FOR n := 1 TO Len( aFont )
      IF At( aFont[n,3], 'true false' ) != 0
         IF aFont[n,3]  == 'true'
            cValue += ',' + aFontName [n]
         ENDIF
      ELSE
         cValue += sep + aFont[n,3]
      ENDIF
      sep := ','
   NEXT

RETURN cValue

*------------------------------------------------------------------------------*
FUNCTION aVal2Str( aData, sep )
*------------------------------------------------------------------------------*
   LOCAL n, cData := ""
   DEFAULT sep := ';'
   IF ValType( aData ) == 'A'
      FOR n := 1 TO Len( aData )
         IF ValType( adata[n] ) == 'N'
            cData += AllTrim( Str( aData[n] ) ) + IF( n < Len( aData ), sep, '' )
         ENDIF
         IF ValType( adata[n] ) == 'C'
            cData += aData[n] + IF( n < Len( aData ), sep, '' )
         ENDIF
         IF ValType( adata[n] ) == 'L'
            cData += IF( aData[n], "true", "false" ) + IF( n < Len( aData ), sep, '' )
         ENDIF
      NEXT
   ENDIF

RETURN cData

*------------------------------------------------------------------------------*
FUNCTION SetPropGridValue ( ParentForm, ControlName, nID, cValue, cData )
*------------------------------------------------------------------------------*
   LOCAL hItem, RetVal := "", ItemType, i, lData := .T.
   LOCAL hWndPG , hEdit := 0
   DEFAULT nID := 0
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   i := AScan ( _HMG_aControlHandles , {|x| ValType( x ) == 'A' .AND. x[1] == hwndPG } )
   IF i > 0
      hEdit := _HMG_aControlMiscData2 [i]
   ENDIF
   IF ValType( cData ) == 'U'
      lData := .F.
   ENDIF
   IF hWndPG > 0
      IF nId == 0
         hItem := TreeView_GetSelection( hWndPG )
      ELSE
         hItem := PG_SearchID( hWndPG, nID )
      ENDIF
      IF hItem != 0  .AND. !PG_GETITEM( hWndPG, hItem, PGI_ENAB )
         ItemType := PG_GETITEM( hWndPG, hItem, PGI_TYPE )
         IF !lData
            cData := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         ENDIF
         IF PgCheckData( ItemType, @cValue, @cData, 1 )
            IF hEdit > 0
               SetWindowText ( hEdit, cValue )
            ENDIF
            PG_SETDATAITEM( hWndPG, hItem, cValue, cData, lData )
            PG_REDRAWITEM( hWndPG, hItem )
            PostMessage( hWndPG, WM_KEYDOWN, VK_ESCAPE, 0 )
         ENDIF
      ENDIF
   ENDIF

RETURN retVal

*------------------------------------------------------------------------------*
FUNCTION EnablePropGridItem ( ParentForm, ControlName, nID, lEnabled )
*------------------------------------------------------------------------------*
   LOCAL hItem, RetVal := ""
   LOCAL hWndPG , hItemSel
   DEFAULT nID := 0
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hItemSel := TreeView_GetSelection( hWndPG )
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   IF hWndPG > 0
      IF nId == 0
         hItem := TreeView_GetSelection( hWndPG )
      ELSE
         hItem := PG_SearchID( hWndPG, nID )
      ENDIF
      IF hItem != 0
         IF ( !PG_GETITEM( hWndPG,hItem,PGI_ENAB ) .AND. !lEnabled ) .OR. ;
               ( PG_GETITEM( hWndPG,hItem,PGI_ENAB ) .AND. lEnabled )
            PG_ENABLEITEM( hWndPG, hItem, lEnabled )
            IF hItemSel == hItem
               PG_REDRAWITEM( hWndPG, hItem )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN retVal

*------------------------------------------------------------------------------*
FUNCTION RedrawPropGridItem ( ParentForm, ControlName, nID )
*------------------------------------------------------------------------------*
   LOCAL hItem, hWndPG
   DEFAULT nID := 0
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   IF hWndPG > 0
      IF nId == 0
         hItem := TreeView_GetSelection( hWndPG )
      ELSE
         hItem := PG_SearchID( hWndPG, nID )
      ENDIF
      IF hItem != 0
         PG_REDRAWITEM( hWndPG, hItem )
      ENDIF
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION GetPropGridValue ( ParentForm, ControlName, nID, lAllData, nSubItem )
*------------------------------------------------------------------------------*
   LOCAL hItem, RetVal, ItemType, aData
   LOCAL hWndPG
   DEFAULT nID := 0
   IF ValType( ParentForm ) == 'U'
      IF _HMG_BeginWindowActive
         ParentForm := _HMG_ActiveFormName
      ELSE
         MsgMiniGuiError( "Parent Window is not defined." )
      ENDIF
   ENDIF
   hWndPG := GetPGControlHandle ( ControlName, ParentForm )
   IF nId == 0
      hItem := TreeView_GetSelection( hWndPG )
   ELSE
      hItem := PG_SearchID( hWndPG, nID )
   ENDIF
   IF hItem != 0
      IF lAllData
         RetVal   := PG_GETITEM( hWndPG, hItem, PGI_ALLDATA )
         IF RetVal[PGI_TYPE] == PG_PASSWORD
            RetVal[PGI_VALUE] := ValueTran( RetVal[PGI_VALUE], RetVal[PGI_TYPE], RetVal[PGI_DATA], nSubItem )
         ENDIF
      ELSE
         ItemType := PG_GETITEM( hWndPG, hItem, PGI_TYPE )
         RetVal   := PG_GETITEM( hWndPG, hItem, PGI_VALUE )
         aData    := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         RetVal   := ValueTran( RetVal, ItemType, aData, nSubItem )
      ENDIF
   ENDIF

RETURN retVal

*------------------------------------------------------------------------------*
FUNCTION GetPGControlHandle ( ControlName, ParentForm )
*------------------------------------------------------------------------------*
   LOCAL aHwnd := GetControlHandle ( ControlName, ParentForm )

RETURN  aHwnd[1]

*------------------------------------------------------------------------------*
FUNCTION ValueTran( cValue, ItType, cData, nSubIt )
*------------------------------------------------------------------------------*
   LOCAL xData, aData
   DEFAULT nSubIt := 0
   IF ValType( cValue ) == 'C'
      DO CASE
      CASE ItType == PG_DEFAULT .OR. ItType == PG_CATEG .OR. ItType == PG_STRING .OR. ItType == PG_SYSINFO ;
            .OR. ItType == PG_IMAGE .OR. ItType == PG_FLAG .OR. ItType == PG_ENUM ;
            .OR. ItType == PG_FILE .OR. ItType == PG_FOLDER .OR. ItType == PG_LIST .OR. ItType == PG_USERFUN
         xData := cValue
      CASE ItType == PG_INTEGER
         xData := Int( Val( cValue ) )
      CASE ItType == PG_DOUBLE
         xData := Val( CharRem( " ", cValue ) )
      CASE ItType == PG_SYSCOLOR .OR. ItType == PG_COLOR
         xData := PgIdentColor( 0, cValue )
         xData := { GetRed ( xData ), GetGreen ( xData ), GetBlue ( xData ) }
      CASE ItType ==  PG_LOGIC
         xData := IF( RTrim( cValue ) == "true", .T. , .F. )
      CASE ItType ==  PG_DATE
         xData := CToD( cValue )
      CASE ItType == PG_FONT
         xData := PgIdentData( cValue, PG_FONT, , ',' )
         IF nSubIt > 0 .AND. nSubIt <= Len( xData )
            xdata := Val( xData[nSubIt] )
         ELSE
            AEval( xData, {|x| x := IF( x == 'true', .T. , .F. ) }, 3 )
            ASize( xData, 8 )
            xData := AIns( xData, 5 )
            xData[5] := { 0, 0, 0 }
            xData[8] := 0
         ENDIF
      CASE ItType == PG_ARRAY
         xData := PgIdentData( cValue, , , ',' )
      CASE ItType == PG_CHECK
         aData := PgIdentData( cData )
         IF Len( aData ) == 1
            xData := IF( aData[1] == 'true', .T. , .F. )
         ELSE
            IF AScan( aData, cValue ) == 1
               xData := .F.
            ELSE
               xData := .T.
            ENDIF
         ENDIF
      CASE ItType == PG_SIZE
         aData := PgIdentData( cData, PG_SIZE, cValue )
         IF nSubIt > 0 .AND. nSubIt <= Len( aData )
            xdata := Val( aData[nSubIt,2] )
         ENDIF
      CASE ItType == PG_PASSWORD
         xdata := CHARXOR( cValue, cData )
      ENDCASE
   ENDIF

RETURN xData

*------------------------------------------------------------------------------*
FUNCTION _LoadProperty( cFile, k )
*------------------------------------------------------------------------------*
   LOCAL oFile, cLine, aLine, cExt
   LOCAL aProperty := {}
   nItemId := 100
   cExt := Lower( SubStr( cFile, RAt('.', cFile ) + 1 ) )
   oFile := TFileRead():New( cFile )
   oFile:Open()
   IF !oFile:Error()
      WHILE oFile:MoreToRead()
         cLine := oFile:ReadLine()
         IF ! Empty( cLine )
            IF cExt == 'txt'
               aLine := FormatPropertyLine( cLine )
            ELSE
               aLine := FormatIniLine( cLine )
               IF Len( aProperty ) > 0
                  IF aLine[1] == 'category'
                     AAdd( aProperty, { 'category', 'end', '', '', .F. , .F. , , .F. , , 0, '', '' } )
                  ENDIF
               ENDIF
            ENDIF
            AAdd( aProperty, aLine )
         ENDIF
      END WHILE
      oFile:Close()
      _HMG_aControlCaption [k] := cFile
   ENDIF
   _HMG_aControlPageMap [k] := aProperty

RETURN aProperty

*------------------------------------------------------------------------------*
FUNCTION FormatPropertyLine( cString )
*------------------------------------------------------------------------------*
   LOCAL cToken, lToken, cStr := '', n
   LOCAL aLine := {}
   LOCAL aRowDef := { 'string', '', '', '', .F. , .F. , .F. , 0, '', '' }

   TOKENINIT ( cString, ' ' + Chr( 9 ) + Chr( 13 ) )
   DO WHILE ( !TOKENEND() )
      cToken := TOKENNEXT( cString )
      IF RAt( '"', cToken ) < Len( cToken )
         lToken := .F.
         cStr += cToken + " "
      ELSE
         lToken := .T.
         cStr += cToken
      ENDIF
      IF lToken
         cStr := REMALL ( cStr, '"' )
         AAdd( aLine, cStr )
         cStr := ""
      ENDIF
   ENDDO
   TOKENEXIT()
   IF Len( aLine ) < 10
      aLine := ASize( aLine, 10 )
   ENDIF
   FOR n := 1 TO 10
      IF aLine[n] == Nil
         IF n == 8
            aLine[n] :=  nItemId++
         ELSE
            aLine[n] := aRowDef[n]
         ENDIF
      ELSE
         DO CASE
         CASE n == 5 .AND. Lower( aLine[5] ) == "disabled"
            aLine[5] := .T.
         CASE n == 7 .AND. Lower( aLine[7] ) == "disableedit"
            aLine[7] := .T.
         CASE n == 8 .AND. ValType( aLine[8] ) == 'C'
            aLine[8] := Val( aLine[8] )
         ENDCASE
      ENDIF
   NEXT

RETURN aLine

*------------------------------------------------------------------------------*
FUNCTION FormatIniLine( cString )
*------------------------------------------------------------------------------*
   LOCAL cToken, n
   LOCAL aLine
   LOCAL aRowDef := { 'string', '', '', '', .F. , .F. , .F. , 0, '', '' }
   cString := LTrim( cString )
   TOKENINIT ( cString, '=' + Chr( 9 ) + Chr( 13 ) )
   IF At( '[', cString ) == 1
      aLine := { 'category' }
   ELSE
      aLine := { 'string' }
   ENDIF
   cString := CharRem ( "[]", cString )
   DO WHILE ( !TOKENEND() )
      cToken := TOKENNEXT( cString )
      AAdd( aLine, cToken )
   ENDDO
   TOKENEXIT()
   IF Len( aLine ) < 10
      aLine := ASize( aLine, 10 )
   ENDIF
   FOR n := 1 TO 10
      IF aLine[n] == Nil
         IF n == 8
            aLine[n] := nItemId++
         ELSE
            aLine[n] := aRowDef[n]
            IF n == 5 .AND. aLine[1] == "category"
               aLine[n] := .T.
            ENDIF
         ENDIF
      ENDIF
   NEXT

RETURN aLine

*------------------------------------------------------------------------------*
FUNCTION OPGEDITEVENTS( hWnd, nMsg, wParam, lParam, hWndPG, hItem )
*------------------------------------------------------------------------------*
   LOCAL icp, icpe, i, n, x, ItemType, nColor, Pos
   LOCAL hImage, ItHeight, hParentItem, hChildItem, ParentItemType, cParentName
   LOCAL aData, aDataNew, cData, cDataNew, cValue, cVal, cFltr, lAll, cFold, bData, lChg
   lParam := Nil //unused parameter

   IF ( i := AScan ( _HMG_aControlHandles ,{|x| ValType(x ) == 'A' .AND. x[1] == hwndPG } ) ) == 0
      RETURN 0
   ENDIF
   IF ( x := AScan ( _HMG_aFormHandles ,_HMG_aControlParentHandles[i] ) ) > 0
      cParentName :=  _HMG_aFormNames [ x ]
   ENDIF
   ItHeight := _HMG_aControlRangeMin [i] - 4
   _HMG_aControlMiscData2 [i] := hWnd
   DO CASE
   CASE nMsg == WM_CHAR
      icp :=  HiWord ( SendMessage( hWnd , EM_GETSEL , 0 , 0 ) )
      icpe := LoWord ( SendMessage( hWnd , EM_GETSEL , 0 , 0 ) )
      cValue := GetWindowText ( hWnd )
      IF wParam == 27
         _PGInitData( hWndPG, hWnd, hItem, PG_GETITEM( hWndPG, hItem, PGI_TYPE ) )
         SetFocus( hWndPG )
      ELSEIF wParam >= 32
         _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
      ENDIF
      // simulate overwrite mode
      IF ! IsInsertActive() .AND. wParam <> 13 .AND. wParam <> 8 .AND. SubStr( cValue, icp + 1, 1 ) <> Chr( 13 )

         IF IsAlpha( Chr( wParam ) ) .OR. IsDigit( Chr( wParam ) )
            IF icp <> icpe
               SendMessage( hWnd , WM_CLEAR , 0 , 0 )
               SendMessage( hWnd , EM_SETSEL , icpe , icpe )
            ELSE
               SendMessage( hWnd , EM_SETSEL , icp , icp + 1 )
               SendMessage( hWnd , WM_CLEAR , 0 , 0 )
               SendMessage( hWnd , EM_SETSEL , icp , icp )
            ENDIF

         ELSE

            IF wParam == 1
               SendMessage( hWnd , EM_SETSEL , 0 , - 1 )
            ENDIF

         ENDIF

      ELSE
         IF wParam == 1
            SendMessage( hWnd , EM_SETSEL , 0 , - 1 )
         ENDIF
      ENDIF

   CASE nMsg == WM_COMMAND
      hParentItem := TreeView_GetParent( hWndPG, hItem )      // Parent Item
      hChildItem  := TreeView_GetChild( hWndPG, hParentItem ) // First Child Item
      cValue := GetWindowText ( hWnd )

      DO CASE
      CASE  HIWORD( wParam ) == BN_CLICKED
         lChg := .F.
         DO CASE
         CASE LOWORD( wParam ) == PG_COLOR
            cData := PG_GETITEM( hWndPG, hItem, PGI_DATA )
            aData := PgIdentData( cData, PG_COLOR )
            aDataNew := GetColor ( aData )
            IF aDataNew[1] != NIL
               cData := AttrTran( aDataNew, 'A' )
               cValue  := aCol2Str( aDataNew )
               SetWindowText ( hWnd, cValue )
               nColor := PgIdentColor( 0, cValue )
               hImage := CREATECOLORBMP( hWndPG, nColor, ItHeight * 1.4 , ItHeight )
               ResetPropGridImageList( hWndPG, hItem, hImage )
               lChg := .T.
            ENDIF
         CASE LOWORD( wParam ) == PG_USERFUN
            cValue := GetWindowText ( hWnd )
            cData := PG_GETITEM( hWndPG, hItem, PGI_DATA )
            bData := &( cData )
            cValue := Eval( bData, cValue )
            IF cValue != NIL .AND. ValType( cValue ) == 'C'
               SetWindowText ( hWnd, cValue )
               lChg := .T.
            ENDIF
         CASE LOWORD( wParam ) == PG_FONT
            cData := PG_GETITEM( hWndPG, hItem, PGI_DATA )
            aData := PgIdentData( cData, PG_FONT )
            aDataNew := GetFont ( aData[1,3], Val( aData[2,3] ) , ;
               if(len(aData)>=3,aData[3,3] == "true",.f.) ,;
               if(len(aData)>=4,aData[4,3] == "true",.f.) , ,;
               if(len(aData)>=5,aData[5,3] == "true",.f.) , ;
               if(len(aData)>=6,aData[6,3] == "true",.f.) )
            IF !Empty( aDataNew[1] )
               ADel( aDataNew, 5 )
               ASize( aDataNew, 6 )
               cData := AttrTran( aDataNew, 'A' )
               aData := PgIdentData( cData, PG_FONT )
               cValue  := aFont2Str( aData )
               SetWindowText ( hWnd, cValue )
               lChg := .T.
            ENDIF

         CASE LOWORD( wParam ) == PG_IMAGE
            cData := GetWindowText ( hWnd )
            cFltr := PgIdentData( PG_GETITEM( hWndPG,hItem,PGI_DATA ), PG_IMAGE )
            cDataNew := GetFile ( cFltr , "Image File", cData , .F. , .T. )
            IF !Empty( cDataNew )
               cValue := cDataNew
               SetWindowText ( hWnd, cValue )
               PgLoadImag( cValue, i, hItem )
               lChg := .T.
            ENDIF
         CASE LOWORD( wParam ) == PG_FILE
            cData := GetWindowText ( hWnd )
            cFltr := PgIdentData( PG_GETITEM( hWndPG,hItem,PGI_DATA ), PG_FILE )
            cDataNew := GetFile ( cFltr , "File", cData , .F. , .T. )
            IF !Empty( cDataNew )
               cValue := cDataNew
               SetWindowText ( hWnd, cValue )
               lChg := .T.
            ENDIF
         CASE LOWORD( wParam ) == PG_FOLDER
            cData := GetWindowText ( hWnd )
            cFold := PG_GETITEM( hWndPG, hItem, PGI_DATA )
            cDataNew := GetFolder ( cFold, cData )
            IF !Empty( cDataNew )
               cValue := cDataNew
               SetWindowText ( hWnd, cValue )
               lChg := .T.
            ENDIF
         CASE LOWORD( wParam ) == PG_ARRAY
            cValue :=  GetWindowText ( hWnd )
            cDataNew := ArrayDlg( cValue, cParentName )
            IF !Empty( cDataNew )
               SetWindowText ( hWnd, cDataNew )
               lChg := .T.
            ENDIF

         ENDCASE
         IF lChg
            _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
         ENDIF

      CASE  HIWORD( wParam ) == CBN_SELCHANGE
         IF PG_GETITEM( hWndPG, hItem, PGI_VALUE ) != ComboGetString( hWnd, ComboGetCursel ( hWnd ) )
            _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
            cValue := ComboGetString( hWnd, ComboGetCursel ( hWnd ) )
            cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
            aData := PgIdentData( cData )
            IF AScan( aData, cValue ) == 0
               cData := cData + ";" + cValue
            ENDIF
            SetWindowText ( hWnd, cValue )
            PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .T. )
         ENDIF

      ENDCASE

   CASE  nMsg == WM_KILLFOCUS
      ItemType   := PG_GETITEM( hWndPG, hItem, PGI_TYPE )
      hParentItem := TreeView_GetParent( hWndPG, hItem )      // Parent Item
      hChildItem  := TreeView_GetChild( hWndPG, hParentItem ) // First Child Item
      //    _HMG_aControlMiscData2 [i] := 0
      DO CASE
      CASE ItemType == PG_DEFAULT .OR. ItemType == PG_CATEG .OR. ItemType == PG_LOGIC .OR. ItemType == PG_ARRAY .OR. ItemType == PG_LIST .OR. ;
            ItemType == PG_STRING .OR. ItemType == PG_INTEGER .OR. ItemType == PG_DOUBLE .OR. ItemType == PG_DATE .OR. ItemType == PG_ENUM
         cValue := GetWindowText ( hWnd )
         IF ItemType == PG_DOUBLE
            cValue := CharRem( " ", cValue )
            IF ( Pos := RAt( '.',cValue ) ) > 0
               cValue := CharRem( '.', Left( cValue,Pos ) ) + SubStr( cValue, Pos )
            ENDIF
         ENDIF
         ParentItemType := PG_GETITEM( hWndPG, hParentItem, PGI_TYPE )
         PG_SETDATAITEM( hWndPG, hItem, cValue, "", .F. )
         IF PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
            _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
         ENDIF
         DO CASE
         CASE ParentItemType == PG_FONT
            cValue := ''
            cValue := PG_GETITEM( hWndPG, hChildItem, PGI_VALUE )
            cData  := cValue
            lChg   := .F.
            n := 1
            DO WHILE ( hChildItem := TreeView_GetNextSibling( hWndPG, hChildItem ) ) > 0
               IF TreeView_GetParent( hWndPG, hChildItem ) == hParentItem
                  n++
                  lChg := lChg .OR. PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
                  cVal := PG_GETITEM( hWndPG, hChildItem, PGI_VALUE )
                  cData += ';' + cVal
                  IF At( cVal, 'true false' ) != 0
                     IF cVal  == 'true'
                        cValue += ',' + aFontName [n]
                     ENDIF
                  ELSE
                     cValue += ',' + cVal
                  ENDIF
               ENDIF
            ENDDO
            IF !Empty( cValue ) .AND. lChg
               PG_SETDATAITEM( hWndPG, hParentItem, cValue, cData, .T. )
               PG_REDRAWITEM( hWndPG, hParentItem )
               IF PG_GETITEM( hWndPG, hParentItem,  PGI_CHG )
                  _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
               ENDIF
               TreeView_SelectItem( hWndPG, hItem )
               lChg   := .F.
            ENDIF

         CASE ParentItemType == PG_FLAG
            cData := PG_GETITEM( hWndPG, hParentItem, PGI_DATA )
            lAll := .F.
            lChg   := .F.
            IF hItem == hChildItem
               lAll := PG_GETITEM( hWndPG, hItem, PGI_VALUE ) == 'true'
               cValue := "[" + PG_GETITEM( hWndPG, hItem, PGI_NAME )
            ELSE
               PG_SETDATAITEM( hWndPG, hChildItem, 'false', "", .F. )
               cValue := "["
            ENDIF
            DO WHILE ( hChildItem := TreeView_GetNextSibling( hWndPG,hChildItem ) ) > 0
               IF TreeView_GetParent( hWndPG, hChildItem ) == hParentItem
                  IF lAll
                     PG_SETDATAITEM( hWndPG, hChildItem, 'false', "", .F. )
                  ENDIF
                  lChg := lChg .OR. PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
                  cVal := PG_GETITEM( hWndPG, hChildItem, PGI_VALUE )
                  IF cVal  == 'true'
                     cValue += IF( Len( cValue ) > 1, ',' , '' ) + PG_GETITEM( hWndPG, hChildItem, PGI_NAME )
                  ENDIF
               ENDIF
            ENDDO
            IF lChg
               cValue += "]"
               PG_SETDATAITEM( hWndPG, hParentItem, cValue, cData, .T. )
               ReDrawWindow( hWndPG, hParentItem )
               IF PG_GETITEM( hWndPG, hParentItem,  PGI_CHG )
                  _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
               ENDIF
               TreeView_SelectItem( hWndPG, hItem )
               lChg   := .F.
            ENDIF
         CASE ParentItemType == PG_SIZE
            lChg   := .F.
            hParentItem := TreeView_GetParent( hWndPG, hItem )
            hChildItem  := TreeView_GetChild( hWndPG, hParentItem )
            cData  := PG_GETITEM( hWndPG, hParentItem, PGI_DATA )
            cValue := '(' + PG_GETITEM( hWndPG, hChildItem, PGI_VALUE )
            lChg := lChg .OR. PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
            DO WHILE ( hChildItem := TreeView_GetNextSibling( hWndPG,hChildItem ) ) > 0
               IF TreeView_GetParent( hWndPG, hChildItem ) == hParentItem
                  lChg := lChg .OR. PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
                  cValue += ',' + PG_GETITEM( hWndPG, hChildItem, PGI_VALUE )
               ENDIF
            ENDDO
            cValue += ')'
            IF lChg
               PG_SETDATAITEM( hWndPG, hParentItem, cValue, cData, .T. )
               PG_REDRAWITEM( hWndPG, hParentItem )
               IF PG_GETITEM( hWndPG, hParentItem,  PGI_CHG )
                  _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
               ENDIF
               PG_REDRAWITEM( hWndPG, hItem )
               lChg := .F.
            ENDIF
         ENDCASE
      CASE ItemType == PG_FONT
         cValue := GetWindowText( hWnd )
         aData := PgIdentData( cValue, PG_FONT, , ',' )
         cData := AttrTran( aData, 'A' )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .T. )
         IF PG_GETITEM( hWndPG, hItem, PGI_CHG )
            aData := PgIdentData( cData, PG_FONT, , ';' )
            hChildItem  := TreeView_GetChild( hWndPG, hItem )
            PG_SETDATAITEM( hWndPG, hChildItem, aData[1,3], "FONT", .T. )
            PG_REDRAWITEM( hWndPG, hChildItem )
            IF PG_GETITEM( hWndPG, hChildItem,  PGI_CHG )
               _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
            ENDIF
            DO WHILE ( hChildItem := TreeView_GetNextSibling( hWndPG,hChildItem ) ) > 0
               IF TreeView_GetParent( hWndPG, hChildItem ) == hItem
                  IF  ( pos := AScan( aData,{|fIt| fIt[2] == PG_GETITEM(hWndPG,hChildItem,PGI_NAME ) } ) ) > 0
                     PG_SETDATAITEM( hWndPG, hChildItem, aData[pos,3], "FONT", .T. )
                     PG_REDRAWITEM( hWndPG, hChildItem )
                     TreeView_SelectItem( hWndPG, hItem )
                  ENDIF
               ENDIF
            ENDDO
         ENDIF

      CASE ItemType == PG_LOGIC
         cValue := ComboGetString( hWnd, ComboGetCursel ( hWnd ) )
         PG_SETDATAITEM( hWndPG, hItem, cValue, "", .F. )
      CASE ItemType == PG_IMAGE
         cValue := GetWindowText ( hWnd )
         cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .T. )
         PgLoadImag( cValue, i, hItem )

      CASE ItemType == PG_FILE .OR. ItemType == PG_ENUM .OR. ItemType == PG_FOLDER
         cValue := GetWindowText ( hWnd )
         cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .T. )

      CASE ItemType == PG_USERFUN
         cValue := GetWindowText ( hWnd )
         cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .F. )
      CASE ItemType == PG_PASSWORD
         cValue := GetWindowText ( hWnd )
         cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         cValue := CHARXOR( cValue, cData )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .F. )

      CASE ItemType == PG_LIST
         cValue := GetWindowText ( hWnd )
         cData  := PG_GETITEM( hWndPG, hItem, PGI_DATA )
         aData := PgIdentData( cData )
         IF AScan( aData, cValue ) == 0
            cData := cData + ";" + cValue
            PG_SETDATAITEM( hWnd, hItem, cValue, cData, .T. )
         ENDIF

      CASE ItemType == PG_SYSCOLOR
         cValue := ComboGetString( hWnd, ComboGetCursel ( hWnd ) )
         nColor := PgIdentColor( 0, cValue )
         hImage := CREATECOLORBMP( hWndPG, nColor, ItHeight * 1.4, ItHeight )
         ResetPropGridImageList( hWndPG, hItem, hImage )
         PG_SETDATAITEM( hWndPG, hItem, cValue, "", .F. )

      CASE ItemType == PG_COLOR
         cValue := GetWindowText ( hWnd )
         aData  := PgIdentData( cValue, PG_COLOR, , ',' )
         cValue := aCol2Str( aData )
         cData  := aVal2Str( aData )
         nColor := PgIdentColor( 0, cValue )
         hImage := CREATECOLORBMP( hWndPG, nColor, ItHeight * 1.4, ItHeight )
         ResetPropGridImageList( hWndPG, hItem, hImage )
         PG_SETDATAITEM( hWndPG, hItem, cValue, cData, .T. )
      ENDCASE
      IF PG_GETITEM( hWndPG, hItem,  PGI_CHG )
         _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
      ENDIF
   ENDCASE

RETURN 0

*------------------------------------------------------------------------------*
FUNCTION _PGInitData( hWnd, hEdit, hWndItem, ItemType )
*------------------------------------------------------------------------------*
   LOCAL i, n, aSysColor, nColor, hImage, ItHeight, aData, hParentItem
   i := AScan ( _HMG_aControlHandles , {|x| ValType( x ) == 'A' .AND. x[1] == hWnd } )
   IF i > 0
      ItHeight := _HMG_aControlRangeMin [i] - 4
      IF PG_GETITEM( hWnd, hWndItem, PGI_CHG )
         _ChangeBtnState(  _HMG_aControlHandles [i], .T. , i )
      ENDIF
      _HMG_aControlMiscData2 [i] := hEdit
      DO CASE
      CASE ItemType == PG_DEFAULT .OR. ItemType == PG_CATEG .OR. ItemType == PG_ARRAY .OR. ;
            ItemType == PG_INTEGER .OR. ItemType == PG_SYSINFO .OR. ItemType == PG_USERFUN
         SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
      CASE ItemType == PG_STRING
         aData := PG_GETITEM( hWnd, hWndItem, PGI_DATA )
         IF !Empty( aData )
            SetWindowText ( hEdit, Transform( PG_GETITEM(hWnd,hWndItem,PGI_VALUE ),aData ) )
         ELSE
            SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
         ENDIF
      CASE ItemType == PG_DOUBLE
         aData := PG_GETITEM( hWnd, hWndItem, PGI_DATA )
         IF !Empty( aData )
            SetWindowText ( hEdit, FormatDouble( PG_GETITEM(hWnd,hWndItem,PGI_VALUE ),aData ) )
         ELSE
            SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
         ENDIF
      CASE ItemType == PG_PASSWORD
         aData := PG_GETITEM( hWnd, hWndItem, PGI_DATA )
         SetWindowText ( hEdit, CHARXOR( PG_GETITEM(hWnd,hWndItem,PGI_VALUE ),aData ) )
      CASE ItemType == PG_LOGIC
         ComboBoxReset( hEdit )
         ComboAddString ( hEdit, "true" )
         ComboAddString ( hEdit, "false" )
         ComboSetCurSel ( hEdit, IF( Lower(PG_GETITEM(hWnd,hWndItem,PGI_VALUE ) ) == "true",1,2 ) )
      CASE ItemType == PG_ENUM .OR. ItemType == PG_LIST
         hParentItem := TreeView_GetParent( hWnd, hWndItem )      // Parent Item
         SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
         ComboBoxReset( hEdit )
         IF PG_GETITEM( hWnd, hParentItem, PGI_TYPE ) == PG_FONT
            PG_GetFonts( hEdit )
            n := ComboFindString( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
            ComboSetCurSel ( hEdit, n )
         ELSE
            aData := PgIdentData( PG_GETITEM( hWnd,hWndItem,PGI_DATA ) )
            FOR n := 1 TO Len( aData )
               PGCOMBOADDSTRING( hEdit, aData[n], 0 )
            NEXT
            ComboSetCurSel ( hEdit, AScan( aData,PG_GETITEM(hWnd,hWndItem,PGI_VALUE ) ) )
         ENDIF
         TreeView_SelectItem( hWnd, hWndItem )

      CASE ItemType == PG_FONT .OR. ItemType == PG_FLAG .OR. ItemType == PG_SIZE
         SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
      CASE ItemType == PG_COLOR  .OR. ItemType == PG_IMAGE .OR. ItemType == PG_FILE .OR. ItemType == PG_FOLDER
         SetWindowText ( hEdit, PG_GETITEM( hWnd,hWndItem,PGI_VALUE ) )
      CASE ItemType == PG_SYSCOLOR
         aSysColor := PgIdentColor( 1 )
         ComboBoxReset( hEdit )
         IF hIListSys == 0
            hIListSys := InitImageList ( ItHeight * 1.4 , ItHeight, .F. , 0 )
            FOR n := 1 TO Len( aSysColor )
               nColor := GetSysColor ( aSysColor[n,1] )
               hImage := CREATECOLORBMP( hWnd, nColor, ItHeight * 1.4 , ItHeight )
               IL_AddMaskedIndirect(  hIListSys , hImage , , ItHeight * 1.4 , ItHeight , 1 )
            NEXT
         ENDIF
         FOR n := 1 TO Len( aSysColor )
            PGCOMBOADDSTRING( hEdit, aSysColor[n,2 ], hIListSys )
         NEXT
         ComboSetCurSel ( hEdit, AScan( aSysColor, {|colIt| colIt[2] == PG_GETITEM(hWnd, hWndItem, PGI_VALUE ) } ) )
      ENDCASE
   ENDIF

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION ArrayDlg( cArr, FormName )
*------------------------------------------------------------------------------*
   LOCAL aItem,  aItemOld, aPos, nRow, nCol, ;
      cData := "", ;
      cNewArr := "", ;
      lOk     := .F.
   IF _IsWIndowDefined ( FormName )
      aPos := GetCursorPos()
      nRow := DialogUnitsY( aPos[1] )
      nCol := DialogUnitsX( aPos[2] )

      nRow := IF( nRow + 300 >  getdesktopheight(), nRow - 300, nRow )
      nCol := IF( nCol + 270 > getdesktopwidth(), nCol - 270, nCol )

      aItem := PgIdentData( cArr, , , ',' )
      aItemOld := AClone( aItem )
      DEFINE FONT Font_7 FONTNAME "Arial" SIZE 9

      DEFINE DIALOG Dlg_1 OF &FormName  AT nRow, nCol WIDTH 270 HEIGHT 300 FONT "Font_7" ;
         CAPTION "Array Property" MODAL;
         DIALOGPROC  DialogFun( @lOk, @aItem, aItemOld ) ;
         ON INIT SetInitItem( aItem, 0 )

         @ 10, 10 TEXTBOX tbox_1 VALUE cData HEIGHT 24 WIDTH 150   ID 101
         @ 10, 170 BUTTON BtnAdd ID 110 CAPTION _HMG_aABMLangButton[14]  WIDTH 90 HEIGHT 24

         @ 40, 10 FRAME Frm   ID 100  WIDTH 250  HEIGHT 0

         @ 50 , 10  LISTBOX Lst_1 ID 102 WIDTH 150 HEIGHT 170  ITEMS aItem

         @ 50, 170 BUTTON BtnRem ID 111 CAPTION _HMG_aABMLangButton[15] WIDTH 90 HEIGHT 24
         @ 80, 170 BUTTON BtnUp  ID 112 CAPTION "&Up"     WIDTH 90 HEIGHT 24
         @ 110, 170 BUTTON BtnDwn ID 113 CAPTION "&Down"   WIDTH 90 HEIGHT 24

         @ 230,  10 BUTTON Btn1 ID 105 CAPTION "&Accept" WIDTH 70 HEIGHT 24 DEFAULT
         @ 230,  90 BUTTON Btn2 ID 106 CAPTION _HMG_aABMLangButton[13] WIDTH 70 HEIGHT 24
         @ 230, 170 BUTTON Btn3 ID 107 CAPTION _HMG_aABMLangButton[1]   WIDTH 70 HEIGHT 24

      END DIALOG

      RELEASE FONT Font_7
      IF lOk
         cNewArr := aVal2Str( aItem, ',' )
      ENDIF
   ENDIF

RETURN cNewArr

*------------------------------------------------------------------------------*
STATIC FUNCTION DialogFun( lOk, aItem, aItemOld )
*------------------------------------------------------------------------------*
   LOCAL ret := 0, cValue, pos, hListBox
   IF DLG_ID != Nil
      hListBox := Getdialogitemhandle( DLG_HWND, 102 )
      DO CASE
      CASE DLG_ID == 101 .AND. DLG_NOT == 1024
         cValue := GetEditText ( DLG_HWND, 101 )
         IF !Empty( cValue )
            EnableDialogItem ( DLG_HWND, 110 )
         ELSE
            DisableDialogItem ( DLG_HWND, 110 )
         ENDIF
      CASE DLG_ID == 110 .AND. DLG_NOT == 0
         cValue := GetEditText ( DLG_HWND, 101 )
         EnableDialogItem ( DLG_HWND, 105 )
         SetDialogItemText( DLG_HWND, 101, "" )
         AAdd( aItem, cValue )
         ListboxAddString ( hListBox, cValue )
         DisableDialogItem ( DLG_HWND, 110 )

      CASE DLG_ID == 111 .AND. DLG_NOT == 0
         pos := ListBoxGetCurSel( hListBox )
         IF Pos > 0 .AND. pos <= Len( aItem )
            ADel( aItem, pos )
            ASize( aItem, Len( aItem ) - 1 )
            ListBoxReset( hListBox )
            SetInitItem( aItem, 1 )
            EnableDialogItem ( DLG_HWND, 105 )
         ENDIF
      CASE DLG_ID == 112 .AND. DLG_NOT == 0
         pos := ListBoxGetCurSel( hListBox )
         IF Pos > 1 .AND. pos <= Len( aItem )
            cValue := aItem[pos]
            ADel( aItem, pos )
            AIns( aItem, pos - 1 )
            aItem[pos-1] := cValue
            ListBoxReset( hListBox )
            SetInitItem( aItem, 1 )
            ListBoxSetCurSel( hListBox, pos - 1 )
            EnableDialogItem ( DLG_HWND, 105 )
         ENDIF
      CASE DLG_ID == 113 .AND. DLG_NOT == 0
         pos := ListBoxGetCurSel( hListBox )
         IF Pos > 0 .AND. pos <= Len( aItem ) - 1
            cValue := aItem[pos]
            ADel( aItem, pos )
            AIns( aItem, pos + 1 )
            aItem[pos+1] := cValue
            ListBoxReset( hListBox )
            SetInitItem( aItem, 1 )
            ListBoxSetCurSel( hListBox, pos + 1 )
            EnableDialogItem ( DLG_HWND, 105 )
         ENDIF
      CASE DLG_ID == 105 .AND. DLG_NOT == 0
         ret := GetEditText ( DLG_HWND, 101 )
         lOk := .T.
         _ReleaseDialog ( )
      CASE DLG_ID == 106 .AND. DLG_NOT == 0
         ListBoxReset( hListBox )
         aItem := AClone( aItemOld )
         SetInitItem( aItem, 1 )
         SetDialogItemText( DLG_HWND, 101, "" )
      CASE DLG_ID == 107 .AND. DLG_NOT == 0
         _ReleaseDialog ( )
      ENDCASE
   ENDIF

RETURN ret

*------------------------------------------------------------------------------*
STATIC FUNCTION SetInitItem( aItem, met )
*------------------------------------------------------------------------------*
   LOCAL hListBox, i
   IF met == 0
      DisableDialogItem ( DLG_HWND, 110 )
   ENDIF
   hListBox := Getdialogitemhandle( DLG_HWND, 102 )
   FOR i = 1 TO Len ( aItem )
      ListboxAddString( hListBox, aItem[i] )
   NEXT i

RETURN Nil

*------------------------------------------------------------------------------*
STATIC FUNCTION FormatDouble( Text , InputMask )
*------------------------------------------------------------------------------*
   LOCAL s As String
   LOCAL x , c
   DEFAULT InputMask := ''
   FOR x := 1 TO Len ( Text )
      c := SubStr ( Text, x, 1 )
      IF c $ '0123456789,-. '
         IF c == ','
            c := '.'
         ENDIF
         s += c
      ENDIF
   NEXT x
   IF ! Empty( InputMask )
      s := Transform ( Val( CharRem(" ", s ) ) , InputMask )
   ENDIF

RETURN s

*------------------------------------------------------------------------------*
STATIC PROCEDURE CharMaskEdit ( hWnd, cValue , Mask )
*------------------------------------------------------------------------------*
   LOCAL  icp , x , CB , CM , cValueLeft , cValueRight ,  OldChar , BackcValue
   LOCAL BadEntry As Logical , pFlag As Logical , NegativeZero As Logical , OutBuffer As String
   LOCAL pc As Numeric , fnb As Numeric , dc As Numeric , ol As Numeric
   LOCAL ncp
   LOCAL Output
   DEFAULT Mask := ''
   icp := HiWord ( SendMessage( hWnd , EM_GETSEL , 0 , 0 ) )
   IF Empty( mask )
      SetWindowText ( hWnd , FormatDouble( cValue ) )
      SendMessage( hWnd , EM_SETSEL , icp , icp )
      RETURN
   ENDIF
   IF Left ( AllTrim( cValue ) , 1 ) == '-' .AND. Val( cValue ) == 0
      NegativeZero := .T.
   ENDIF

   FOR x := 1 TO Len ( cValue )
      CB := SubStr ( cValue , x , 1 )
      IF CB == '.' .OR. CB == ','
         pc++
      ENDIF
   NEXT x

   IF Left ( cValue, 1 ) == '.' .OR. Left ( cValue, 1 ) == ','
      pFlag := .T.
   ENDIF

   FOR x := 1 TO Len ( cValue )
      CB := SubStr ( cValue , x , 1 )
      IF CB != ' '
         fnb := x
         EXIT
      ENDIF
   NEXT x

   BackcValue := cValue

   OldChar := SubStr ( cValue , icp + 1 , 1 )
   IF Len ( cValue ) < Len ( Mask )

      cValueLeft := Left ( cValue , icp )
      cValueRight := Right ( cValue , Len ( cValue ) - icp )
      IF CharMaskTekstOK( cValueLeft + ' ' + cValueRight, Mask ) .AND. !CharMaskTekstOK( cValueLeft + cValueRight, Mask )
         cValue := cValueLeft + ' ' + cValueRight
      ELSE
         cValue := cValueLeft + cValueRight
      ENDIF
   ENDIF

   IF Len ( cValue ) > Len ( Mask )

      cValueLeft := Left ( cValue , icp )
      cValueRight := Right ( cValue , Len ( cValue ) - icp - 1 )
      cValue := cValueLeft + cValueRight

   ENDIF
   FOR x := 1 TO Len ( Mask )

      CB := SubStr ( cValue , x , 1 )
      CM := SubStr ( Mask , x , 1 )

      DO CASE
      CASE CM == 'A' .OR. CM == 'N' .OR. CM == '!'
         IF IsAlpha ( CB ) .OR. CB == ' ' .OR. ( ( CM == 'N' .OR. CM == '!'  ) .AND. IsDigit ( CB ) )
            IF CM == "!" .AND. !IsDigit ( CB )
               OutBuffer += Upper ( CB )
            ELSE
               OutBuffer += CB
            ENDIF
         ELSE
            IF x == icp
               BadEntry := .T.
               OutBuffer += OldChar
            ELSE
               OutBuffer += ' '
            ENDIF
         ENDIF
      CASE CM == '9'
         IF IsDigit ( CB ) .OR. CB == ' ' .OR. ( CB == '-' .AND. x == fnb .AND. PCount() > 1 )
            OutBuffer += CB
         ELSE
            IF x == icp
               BadEntry := .T.
               OutBuffer += OldChar
            ELSE
               OutBuffer += ' '
            ENDIF
         ENDIF
      CASE CM == ' '
         IF CB == ' '
            OutBuffer += CB
         ELSE
            IF x == icp
               BadEntry := .T.
               OutBuffer += OldChar
            ELSE
               OutBuffer += ' '
            ENDIF
         ENDIF
      OTHERWISE
         OutBuffer += CM
      ENDCASE
   NEXT x
   IF ! ( BackcValue == OutBuffer )
      SetWindowText ( hWnd , OutBuffer )
   ENDIF
   IF pc > 1
      pc := At ( '.', OutBuffer )
      IF NegativeZero == .T.
         Output := FormatDouble( GetWindowText ( hWnd ) , Mask )
         Output := Right ( Output , ol - 1 )
         Output := '-' + Output
         SetWindowText ( hWnd , Output )
         SendMessage( hWnd , EM_SETSEL , pc + dc , pc + dc )
      ELSE
         SetWindowText ( hWnd , FormatDouble( GetWindowText ( hWnd ) ,Mask ) )
         SendMessage( hWnd , EM_SETSEL , pc + dc , pc + dc )
      ENDIF
   ELSE
      IF pFlag == .T.
         ncp := At ( '.' , GetWindowText ( hWnd ) )
         SendMessage( hWnd , EM_SETSEL , ncp , ncp )
      ELSE
         IF BadEntry
            icp--
         ENDIF
         SendMessage( hWnd , EM_SETSEL , icp , icp )
         FOR x := 1 TO Len ( OutBuffer )
            CB := SubStr ( OutBuffer , icp + x , 1 )
            CM := SubStr ( Mask , icp + x , 1 )
            IF !IsDigit( CB ) .AND. !IsAlpha( CB ) .AND. ( !( CB == ' ' ) .OR. ( CB == ' ' .AND. CM == ' ' ) )
               SendMessage( hWnd , EM_SETSEL , icp + x , icp + x )
            ELSE
               EXIT
            ENDIF
         NEXT x
      ENDIF
   ENDIF

RETURN

*------------------------------------------------------------------------------*
STATIC FUNCTION CharMaskTekstOK( cString, cMask )
*------------------------------------------------------------------------------*
   LOCAL lPassed := .F. , CB, CM, x
   LOCAL nCount := Min( Len( cString ), Len( cMask ) )
   IF   Len( cString ) == Len( cMask )
      FOR x := 1 TO nCount
         CB := SubStr( cString , x , 1 )
         CM := SubStr( cMask , x , 1 )
         DO CASE
         CASE CM == '9'
            lPassed := ( IsDigit ( CB ) .OR. CB == ' ' )
         CASE CM == ' '
            lPassed := ( CB == ' ' )
         OTHERWISE
            lPassed := .T.
         ENDCASE
         IF lPassed == .F.
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN lPassed
