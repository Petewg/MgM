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

#ifdef _DBFBROWSE_

#include "i_winuser.ch"
#include "dbstruct.ch"
#ifdef HMG_LEGACY_ON
   MEMVAR aresult, l, aWhen, aWhenVarNames
#endif
MEMVAR cMacroVar
*-----------------------------------------------------------------------------*
FUNCTION _DefineBrowse ( ControlName, ParentFormName, x, y, w, h, aHeaders, aWidths, aFields, value, fontname, fontsize, ;
      tooltip , change , dblclick , aHeadClick , gotfocus , lostfocus , WorkArea , Delete , nogrid , ;
      aImage , aJust , HelpId , bold , italic , underline , strikeout , break , backcolor , fontcolor , ;
      lock , inplace , novscroll , appendable , readonly , valid , validmessages , edit , ;
      dynamicforecolor , dynamicbackcolor , aWhenFields , nId , aImageHeader , NoTabStop , inputitems , displayitems , doublebuffer )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , blInit , mVar , DeltaWidth , k , Style
   LOCAL ControlHandle , FontHandle , lDialogInMemory

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF

   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      x := x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      y := y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( _HMG_BRWLangError[1] + IFNIL( ParentFormName, "Parent", ParentFormName ) + _HMG_BRWLangError[2], .F. )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( _HMG_BRWLangError[4] + ControlName + _HMG_BRWLangError[5] + ParentFormName + _HMG_BRWLangError[6], .F. )
   ENDIF

#ifndef HMG_LEGACY_ON
   IF hb_defaultValue( edit, .F. )
      inplace := .T.
   ENDIF
#endif
   hb_default( @value, 0 )
   hb_default( @aFields, {} )
   /* code borrowed from ooHG project */
   IF ! HB_ISARRAY( aJust )
      aJust := AFill( Array( Len( aFields ) ), 0 )
   ELSE
      ASize( aJust, Len( aFields ) )
      AEval( aJust, { |x, i| aJust[ i ] := iif( HB_ISNUMERIC( x ), x, 0 ) } )
   ENDIF
   /* end code borrowed */
   __defaultNIL( @aImage, {} )
   __defaultNIL( @aImageHeader, {} )

   DeltaWidth := iif( novscroll, 0, GETVSCROLLBARWIDTH() )

   __defaultNIL( @change, "" )
   __defaultNIL( @dblclick, "" )
   __defaultNIL( @aHeadClick, {} )

   hb_default( @notabstop, .F. )
   hb_default( @doublebuffer, .F. )

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle
      style := LVS_SINGLESEL + LVS_SHOWSELALWAYS + WS_BORDER + WS_CHILD + WS_VISIBLE + LVS_REPORT

      IF !NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF lDialogInMemory         //Dialog Template

         blInit := {|x, y, z| InitDialogBrowse( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "SysListView32", style, 0, x, y, w - DeltaWidth, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )
         SetWindowStyle ( ControlHandle, style, .T. )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      hb_default( @w, 240 )
      hb_default( @h, 120 )

      IF ValType( x ) == "U" .OR. ValType( y ) == "U"

         // If splitboxed force no vertical scrollbar
         novscroll := .T.

         IF _HMG_SplitLastControl == 'TOOLBAR'
            Break := .T.
         ENDIF

         _HMG_SplitLastControl := 'GRID'

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            ControlHandle := InitBrowse ( ParentFormHandle, 0, x, y, w - DeltaWidth , h , NoTabStop ) // Browse+

            x := GetWindowCol ( Controlhandle )
            y := GetWindowRow ( Controlhandle )

            AddSplitBoxItem ( Controlhandle, _HMG_aFormReBarHandle [i] , w , break , , , , _HMG_ActiveSplitBoxInverted )
         ENDIF

      ELSE

         ControlHandle := InitBrowse ( ParentFormHandle, 0, x, y, w - DeltaWidth , h , NoTabStop ) // Browse+

      ENDIF

   ENDIF

   IF .NOT. lDialogInMemory

      IF ValType ( backcolor ) != 'U'
         ListView_SetBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
         ListView_SetTextBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3]  )
      ENDIF

      IF ValType ( fontcolor ) != 'U'
         ListView_SetTextColor ( ControlHandle , fontcolor[1] , fontcolor[2] , fontcolor[3]  )
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

   _HMG_aControlType [k] := "BROWSE"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  aWidths
   _HMG_aControlPageMap   [k] := aHeaders
   _HMG_aControlValue   [k] := Value
   _HMG_aControlInputMask   [k] := Lock
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted   [k] := .F.
   _HMG_aControlBkColor  [k] :=  aImage // Browse+
   _HMG_aControlFontColor   [k] := inplace
   _HMG_aControlDblClick   [k] := dblclick
   _HMG_aControlHeadClick   [k] := aHeadClick
   _HMG_aControlRow   [k] := y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth   [k] := w
   _HMG_aControlHeight   [k] := h
   _HMG_aControlSpacing   [k] := NoQuote ( WorkArea )
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture   [k] :=  aImageHeader // Browse+
   _HMG_aControlContainerHandle  [k] := 0
   _HMG_aControlFontName   [k] :=  fontname
   _HMG_aControlFontSize   [k] :=  fontsize
   _HMG_aControlFontAttributes   [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip    [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  aFields
   _HMG_aControlRangeMax   [k] :=  {} // Rows array
   _HMG_aControlCaption  [k] :=  aHeaders
   _HMG_aControlVisible  [k] :=  .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { 0 , ;
      appendable , readonly , valid , validmessages , edit , nogrid , novscroll , dynamicforecolor , dynamicbackcolor , aWhenFields , Delete , inputitems , displayitems , 0 , aJust , NIL , NIL , doublebuffer }
   _HMG_aControlMiscData2 [k] := ''

   IF .NOT. lDialogInMemory
      InitDialogBrowse( ParentFormName, ControlHandle, k )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogBrowse( ParentName, ControlHandle, i )
*-----------------------------------------------------------------------------*
   LOCAL x , w , y , h , z , ParentFormHandle , ScrollBarHandle , wBitmap
   LOCAL hsum := 0 , aJust , aImageHeader , ScrollBarButtonHandle , nogrid , doublebuffer

   x := _HMG_aControlCol    [i]
   w := _HMG_aControlWidth  [i]
   y := _HMG_aControlRow    [i]
   h := _HMG_aControlHeight [i]

   ParentFormHandle := _HMG_aControlParenthandles [i]
   nogrid           := _HMG_aControlMiscData1 [i, 7]
   aJust            := _HMG_aControlMiscData1 [i,16]
   doublebuffer     := _HMG_aControlMiscData1 [i,19]
   aImageHeader     := _HMG_aControlPicture [i]

   SendMessage( ControlHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, iif( nogrid, 0, LVS_EX_GRIDLINES ) + ;
      iif( doublebuffer, LVS_EX_DOUBLEBUFFER, 0 ) + LVS_EX_FULLROWSELECT + LVS_EX_INFOTIP + LVS_EX_HEADERDRAGDROP )

   wBitmap := iif( Len( _HMG_aControlBkColor [i] ) > 0, AddListViewBitmap( ControlHandle, _HMG_aControlBkColor [i] ), 0 ) // Add Bitmap Column
   _HMG_aControlProcedures [i,1] := Max ( _HMG_aControlProcedures [i,1], wBitmap + 2 ) // Set Column 1 width to Bitmap width

   IF Len( aImageHeader ) > 0
      _HMG_aControlMiscData1 [i,15] := AddListViewBitmapHeader( ControlHandle, aImageHeader ) // Add Header Bitmaps
   ENDIF

   InitListViewColumns ( ControlHandle, _HMG_aControlCaption [i], _HMG_aControlProcedures [i], aJust )

   // Add to browselist array to update on window activation
   AAdd ( _HMG_aFormBrowseList [ GetFormIndex ( ParentName ) ] , i )

   FOR z := 1 TO Len ( _HMG_aControlProcedures [i] )
      hsum += ListView_GetColumnWidth ( _HMG_aControlHandles [i] , z - 1 )
      _HMG_aControlProcedures [i] [z] := ListView_GetColumnWidth ( _HMG_aControlHandles [i] , z - 1 )
   NEXT z

   // Add Vertical scrollbar
   IF _HMG_aControlMiscData1 [i,8] == .F.

      IF hsum > w - GETVSCROLLBARWIDTH() - 4
         ScrollBarHandle := InitVScrollBar (  ParentFormHandle , x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h - GETHSCROLLBARHEIGHT() )
         ScrollBarButtonHandle := InitVScrollBarButton (  ParentFormHandle , x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() )
      ELSE
         ScrollBarHandle := InitVScrollBar (  ParentFormHandle , x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h )
         ScrollBarButtonHandle := InitVScrollBarButton (  ParentFormHandle , x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , 0 , 0 )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , { ControlHandle , ScrollBarHandle , ScrollBarButtonHandle } )
      ENDIF

   ELSE

      ScrollBarHandle := 0

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

   ENDIF

   _HMG_aControlIds [i] := ScrollBarHandle
   _HMG_aControlMiscData1 [i] [1] := ScrollBarButtonHandle

   _BrowseRefresh( '', '', i )

   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]  // Modal
      _HMG_aControlDeleted [i] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseUpdate( ControlName, ParentName, z )
*-----------------------------------------------------------------------------*
   LOCAL PageLength , aTemp , cTemp , Fields , _BrowseRecMap := {} , i , x , j , First , Image , _Rec
   LOCAL dBc , dFc , processdbc , processdfc , ColorMap , ColorRow , fcolormap , fcolorrow
   LOCAL aDisplayItems, aDisplayItemsLengths, aProcessDisplayItems, lFound, k

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentName ) , z )

   IF Select() == 0
      RETURN
   ENDIF

   Fields := _HMG_aControlRangeMin [i]

   aDisplayItems := _HMG_aControlMiscData1 [ i ] [ 14 ]

   aProcessDisplayItems := Array ( Len ( Fields ) )
   aDisplayItemsLengths := Array ( Len ( Fields ) )

   AFill ( aProcessDisplayItems , .F. )
   AFill ( aDisplayItemsLengths , 0 )

   IF ValType ( aDisplayItems ) == 'A'

      FOR k := 1 TO Len ( aProcessDisplayItems )

         IF ValType ( aDisplayItems [k] ) == 'A'
            aProcessDisplayItems [k] := .T.
            aDisplayItemsLengths [k] := Len ( aDisplayItems [k] )
         ENDIF

      NEXT k

   ENDIF

   dfc := _HMG_aControlMiscData1 [i, 9]
   processdfc := ISARRAY ( dfc )

   dbc := _HMG_aControlMiscData1 [i, 10]
   processdbc := ISARRAY ( dbc )

   _HMG_aControlContainerHandle [i] := 0

   First := iif( Len( _HMG_aControlBkColor [i] ) == 0, 1, 2 ) // Browse+ ( 2= bitmap definido, se cargan campos a partir de 2º )

   ListViewReset ( _HMG_aControlhandles [i] )

   PageLength := ListViewGetCountPerPage ( _HMG_aControlhandles [i] )

   IF processdfc
      fcolormap := {}
      fcolorrow := {}
   ENDIF

   IF processdbc
      colormap := {}
      colorrow := {}
   ENDIF

   FOR EACH x IN Array( PageLength )

      aTemp := {}

      IF First == 2
         cTemp := Fields [1]

         SWITCH Left( Type ( cTemp ), 1 )
         CASE 'N'
            image := &cTemp
            EXIT
         CASE 'L'
            image := iif( &cTemp, 1, 0 )
            EXIT
#ifndef __XHARBOUR__
         OTHERWISE
#else
         DEFAULT
#endif
            image := 0
         END SWITCH
         AAdd ( aTemp , NIL )

         IF processdbc
            IF ValType ( dbc ) == 'A' .AND. Len ( dbc ) == Len ( Fields )
               AAdd ( colorrow , -1 )
            ENDIF
         ENDIF

         IF processdfc
            IF ValType ( dfc ) == 'A' .AND. Len ( dfc ) == Len ( Fields )
               AAdd ( fcolorrow , -1 )
            ENDIF
         ENDIF

      ENDIF

      FOR EACH cTemp IN Fields
#ifndef __XHARBOUR__
         j := cTemp:__enumIndex()
#else
         j := hb_enumindex()
#endif
         IF j >= First

            IF aProcessDisplayItems [ j ] == .T.
               lFound := .F.
               FOR k := 1 TO aDisplayItemsLengths [ j ]
                  IF aDisplayItems [ j ] [ k ] [ 2 ] == &cTemp
                     AAdd ( aTemp , RTrim ( aDisplayItems [ j ] [ k ] [ 1 ] ) )
                     lFound := .T.
                     EXIT
                  ENDIF
               NEXT k

               IF ! lFound
                  AAdd ( aTemp , '' )
               ENDIF
            ELSE
               AAdd ( aTemp , _GetBrowseFieldValue ( cTemp ) )
            ENDIF

            IF processdfc
               IF ValType ( dfc ) == 'A' .AND. Len ( dfc ) == Len ( Fields )
                  AAdd ( fcolorrow , iif( ValType ( dfc [j] ) == 'B', _teval ( dfc [j] ) , -1 ) )
               ENDIF
            ENDIF

            IF processdbc
               IF ValType ( dbc ) == 'A' .AND. Len ( dbc ) == Len ( Fields )
                  AAdd ( colorrow , iif( ValType ( dbc [j] ) == 'B', _teval ( dbc [j] ) , -1 ) )
               ENDIF
            ENDIF

         ENDIF

      NEXT

      AddListViewItems ( _HMG_aControlhandles [i] , aTemp , Image )

      _Rec := RecNo()

      AAdd ( _BrowseRecMap , _Rec )

      IF processdfc
         AAdd ( fcolormap , fcolorrow )
         fcolorrow := {}
      ENDIF

      IF processdbc
         AAdd ( colormap , colorrow )
         colorrow := {}
      ENDIF

      SKIP

      IF EOF()
         _HMG_aControlContainerHandle [i] := 1
         GO BOTTOM
         EXIT
      ENDIF

   NEXT

   IF processdfc
      _HMG_aControlMiscData1 [i] [17] := fcolormap
   ENDIF

   IF processdbc
      _HMG_aControlMiscData1 [i] [18] := colormap
   ENDIF

   _HMG_aControlRangeMax [i] := _BrowseRecMap

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _tEval ( bBlock )
*-----------------------------------------------------------------------------*
   LOCAL tEval := Eval ( bBlock )

   IF ValType ( TEVAL ) == 'A' .AND. Len ( TEVAL ) == 3
      TEVAL := RGB ( TEVAL [1] , TEVAL [2] , TEVAL [3] )
   ENDIF

RETURN IFNUMERIC( tEval, tEval, 0 )

*-----------------------------------------------------------------------------*
FUNCTION _GetBrowseFieldValue ( cTemp )
*-----------------------------------------------------------------------------*
   LOCAL cRet := 'Nil'
   LOCAL cType := _TypeEx ( cTemp )

   SWITCH Left( cType, 1 )

   CASE 'N'
   CASE '+'
   CASE 'F'
   CASE 'I'
   CASE 'B'
   CASE 'Y'
      cRet := LTrim ( Str ( &cTemp ) )
      EXIT
   CASE 'D'
   CASE 'T'
      cRet := DToC ( &cTemp )
      EXIT
   CASE 'C'
      cRet := RTrim ( &cTemp )
      EXIT
   CASE 'L'
      cRet := iif ( &cTemp == .T. , '.T.' , '.F.' )
      EXIT
   CASE 'M'
      cRet := iif ( Empty ( &cTemp ) , '<memo>' , '<Memo>' )
      EXIT
   CASE '@'
      cRet := RTrim( hb_ValToStr ( &cTemp ) )
      EXIT
   CASE 'G'
      cRet := '<General>'
      EXIT
#ifndef __XHARBOUR__
   OTHERWISE
#else
   DEFAULT
#endif
      IF cType == 'UE'
         cRet := '<R-Next>'
      ELSEIF cType == 'UI'
         cRet := _GetBrowseFnValue( cTemp )
      ENDIF
   END SWITCH

RETURN cRet

*-----------------------------------------------------------------------------*
FUNCTION _GetBrowseFnValue ( cTemp )
*-----------------------------------------------------------------------------*
   LOCAL cRet := 'Nil'

   SWITCH ValType ( cTemp )
   CASE 'N'
      cRet := hb_ntos( &cTemp )
      EXIT
   CASE 'D'
      cRet := DToC( &cTemp )
      EXIT
   CASE 'L'
      cRet := iif ( &cTemp == .T. , '.T.' , '.F.' )
      EXIT
   CASE 'C'
      cRet := RTrim ( &cTemp )
      EXIT
   CASE 'M'
      cRet := '<Memo>'
   END SWITCH

RETURN cRet

*-----------------------------------------------------------------------------*
STATIC FUNCTION _TypeEx ( cTemp )
*-----------------------------------------------------------------------------*
   LOCAL aStruct
   LOCAL nFieldPos

   aStruct := dbStruct()
   nFieldPos := AScan ( aStruct, {|x| x [DBS_NAME] == Upper( cTemp ) } )

RETURN iif( nFieldPos > 0, aStruct [nFieldPos] [DBS_TYPE], Type ( cTemp ) )

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseNext ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , PageLength , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _BrowseRecMap , _DeltaScroll , s

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   PageLength := LISTVIEWGETCOUNTPERPAGE ( _BrowseHandle )

   s := LISTVIEW_GETFIRSTITEM ( _BrowseHandle )

   IF s == PageLength

      IF _HMG_aControlContainerHandle [i] != 0
         RETURN
      ENDIF

      _Alias := Alias()
      _BrowseArea := _HMG_aControlSpacing [i]
      IF Select ( _BrowseArea ) == 0
         RETURN
      ENDIF
      Select &_BrowseArea
      _RecNo := RecNo()

      GO _BrowseRecMap [PageLength]
      _BrowseUpdate( '', '', i )
      _BrowseVscrollUpdate( i )
      ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
      ListView_SetCursel ( _BrowseHandle , Len( _HMG_aControlRangeMax [i] ) )
      GO _RecNo
      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF

   ELSE

      ListView_SetCursel ( _BrowseHandle , Len( _BrowseRecMap ) )
      _BrowseVscrollFastUpdate ( i , PageLength - s )

   ENDIF

   _BrowseOnChange ( i )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowsePrior ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _BrowseRecMap , _DeltaScroll

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   IF LISTVIEW_GETFIRSTITEM ( _BrowseHandle ) == 1

      _Alias := Alias()
      _BrowseArea := _HMG_aControlSpacing [i]
      IF Select ( _BrowseArea ) == 0
         RETURN
      ENDIF
      Select &_BrowseArea
      _RecNo := RecNo()

      GO _BrowseRecMap [1]
      Skip - LISTVIEWGETCOUNTPERPAGE ( _BrowseHandle ) + 1
      _BrowseVscrollUpdate( i )
      _BrowseUpdate( '', '', i )
      ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
      GO _RecNo
      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF

   ELSE

      _BrowseVscrollFastUpdate ( i , 1 - LISTVIEW_GETFIRSTITEM ( _BrowseHandle ) )

   ENDIF

   ListView_SetCursel ( _BrowseHandle , 1 )

   _BrowseOnChange ( i )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseHome ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _DeltaScroll

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]
   IF Select ( _BrowseArea ) == 0
      RETURN
   ENDIF
   Select &_BrowseArea
   _RecNo := RecNo()
   GO TOP

   _BrowseVscrollUpdate( i )
   _BrowseUpdate( '', '', i )
   ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_SetCursel ( _BrowseHandle , 1 )

   _BrowseOnChange ( i )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseEnd ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _DeltaScroll , _BottomRec

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]
   IF Select ( _BrowseArea ) == 0
      RETURN
   ENDIF
   Select &_BrowseArea
   _RecNo := RecNo()
   GO BOTTOM
   _BottomRec := RecNo()

   _BrowseVscrollUpdate( i )
   Skip - LISTVIEWGETCOUNTPERPAGE ( _BrowseHandle ) + 1
   _BrowseUpdate( '', '', i )
   ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_SetCursel ( _BrowseHandle , AScan ( _HMG_aControlRangeMax [i] , _BottomRec ) )

   _BrowseOnChange ( i )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseUp ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , s , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _BrowseRecMap , _DeltaScroll

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   s := LISTVIEW_GETFIRSTITEM ( _BrowseHandle )

   IF s == 1
      _Alias := Alias()
      _BrowseArea := _HMG_aControlSpacing [i]

      IF Select ( _BrowseArea ) == 0
         RETURN
      ENDIF

      Select &_BrowseArea
      _RecNo := RecNo()

      GO _BrowseRecMap [1]
      Skip - 1

      IF !( _BrowseRecMap [1] == RecNo() )  // BAA 18-Mar-2012
         _BrowseVscrollUpdate( i )
         _BrowseUpdate( '', '', i )
         ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
      ENDIF

      GO _RecNo
      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF

      ListView_SetCursel ( _BrowseHandle , 1 )

   ELSE

      IF _HMG_ActiveDlgProcHandle == 0
         ListView_SetCursel ( _BrowseHandle , s - 1 )
      ENDIF
      _BrowseVscrollFastUpdate ( i , -1 )

   ENDIF

   _BrowseOnChange ( i )

   IF _HMG_ActiveMDIChildIndex > 0  // BAA 15-Apr-2012
      ListView_SetCursel ( _BrowseHandle , s )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseDown ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , PageLength , s , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _BrowseRecMap , _DeltaScroll

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   s := LISTVIEW_GETFIRSTITEM ( _BrowseHandle )

   PageLength := LISTVIEWGETCOUNTPERPAGE ( _BrowseHandle )

   IF s == PageLength
      IF _HMG_aControlContainerHandle [i] != 0
         RETURN
      ENDIF

      _Alias := Alias()
      _BrowseArea := _HMG_aControlSpacing [i]

      IF Select ( _BrowseArea ) == 0
         RETURN
      ENDIF

      Select &_BrowseArea
      _RecNo := RecNo()

      GO _BrowseRecMap [1]
      SKIP

      _BrowseUpdate( '', '', i )
      _BrowseVscrollUpdate( i )

      ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )

      GO _RecNo

      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF

      ListView_SetCursel ( _BrowseHandle , Len( _HMG_aControlRangeMax [i] ) )

   ELSE

      IF _HMG_ActiveDlgProcHandle == 0
         ListView_SetCursel ( _BrowseHandle , s + 1 )
      ENDIF
      _BrowseVscrollFastUpdate ( i , 1 )

   ENDIF

   _BrowseOnChange ( i )

   IF _HMG_ActiveMDIChildIndex > 0  // BAA 15-Apr-2012
      ListView_SetCursel ( _BrowseHandle , s )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseRefresh ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , s , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _DeltaScroll
   LOCAL v
   PRIVATE cMacroVar

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   v := _BrowseGetValue ( '', '', i )

   _BrowseHandle := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   s := LISTVIEW_GETFIRSTITEM ( _BrowseHandle )

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]

   IF Select ( _BrowseArea ) == 0
      ListViewReset ( _BrowseHandle )
      RETURN
   ENDIF

   Select &_BrowseArea
   _RecNo := RecNo()

   IF v <= 0
      v := _RecNo
   ENDIF

   GO v

   IF s == 1 .OR. s == 0

      cMacroVar := dbFilter()
      IF Len ( cMacroVar ) > 0
         IF ValType ( &cMacroVar ) != "L"
            MsgMiniGuiError ( "BROWSE: Argument error in Filter condition of " + _BrowseArea + "." )
         ENDIF
         IF ! &cMacroVar
            SKIP
         ENDIF
      ENDIF

      IF IndexOrd() != 0
         IF ordKeyVal() == Nil
            GO TOP
         ENDIF
      ENDIF

      IF SET ( _SET_DELETED )
         IF Deleted()
            GO TOP
         ENDIF
      ENDIF

   ENDIF

   IF EOF()

      ListViewReset ( _BrowseHandle )

      GO _RecNo

      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF

      RETURN

   ENDIF

   _BrowseVscrollUpdate( i )

   IF s != 0
      Skip - s + 1
   ENDIF

   _BrowseUpdate( '', '', i )

   ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
   ListView_SetCursel ( _BrowseHandle , AScan ( _HMG_aControlRangeMax [i] , v ) )

   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseSetValue ( ControlName , ParentForm , Value , z , mp )
*-----------------------------------------------------------------------------*
   LOCAL i , _Alias , _RecNo , _BrowseHandle , _BrowseArea , _DeltaScroll , m
   PRIVATE cMacroVar

   IF Value <= 0
      RETURN
   ENDIF

   i := iif( ValType ( z ) == 'U' , GetControlIndex ( ControlName , ParentForm ) , z )

   IF _HMG_ThisEventType == 'BROWSE_ONCHANGE'
      IF i == _HMG_THISINDEX
         MsgMiniGuiError ( "BROWSE: Value property can't be changed inside ONCHANGE event." )
      ENDIF
   ENDIF

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]

   IF Select ( _BrowseArea ) == 0
      RETURN
   ENDIF

   _BrowseHandle := _HMG_aControlHandles [i]

   IF Value == ( _BrowseArea )->( RecCount() ) + 1
      _HMG_aControlValue [i] := Value
      ListViewReset ( _BrowseHandle )
      _BrowseOnChange ( i )
      RETURN
   ENDIF

   IF Value > ( _BrowseArea )->( RecCount() ) + 1
      RETURN
   ENDIF

   IF ValType ( mp ) == 'U'
      m := Int ( ListViewGetCountPerPage ( _BrowseHandle ) / 2 )
   ELSE
      m := mp
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _BrowseHandle , 0 , 0 )

   Select &_BrowseArea

   _RecNo := RecNo()

   GO Value

   cMacroVar := dbFilter()

   IF Len ( cMacroVar ) > 0

      IF ValType ( &cMacroVar ) != "L"
         MsgMiniGuiError ( "BROWSE: Argument error in Filter condition of " + _BrowseArea + "." )
      ENDIF

      IF ! &cMacroVar

         GO _RecNo
         IF Select( _Alias ) != 0
            Select &_Alias
         ELSE
            SELECT 0
         ENDIF

         RETURN

      ENDIF

   ENDIF

   IF EOF()
      GO _RecNo
      IF Select( _Alias ) != 0
         Select &_Alias
      ELSE
         SELECT 0
      ENDIF
      RETURN
   ELSE
      IF PCount() < 5
         _BrowseVscrollUpdate( i )
      ENDIF
      Skip - m + 1
   ENDIF

   _HMG_aControlValue [i] := Value
   _BrowseUpdate( '' , '' , i )
   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_Scroll( _BrowseHandle , _DeltaScroll[2] * ( -1 ) , 0 )
   ListView_SetCursel ( _BrowseHandle , AScan ( _HMG_aControlRangeMax [i] , Value ) )

   _HMG_ThisEventType := 'BROWSE_ONCHANGE'
   _BrowseOnChange ( i )
   _HMG_ThisEventType := ''

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _BrowseGetValue ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , RetVal , _BrowseRecMap , _BrowseArea

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _BrowseArea := _HMG_aControlSpacing [i]

   IF Select ( _BrowseArea ) == 0
      RETURN 0
   ENDIF

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   IF LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) != 0
      RetVal := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) ]
   ELSE
      RetVal := 0
   ENDIF

RETURN ( RetVal )

*-----------------------------------------------------------------------------*
FUNCTION  _BrowseDelete (  ControlName , ParentForm , z  )
*-----------------------------------------------------------------------------*
   LOCAL i , _BrowseRecMap , Value , _Alias , _RecNo , _BrowseArea

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   IF LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) == 0
      RETURN Nil
   ENDIF

   _BrowseRecMap := _HMG_aControlRangeMax [i]

   Value := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) ]

   IF Value == 0
      RETURN Nil
   ENDIF

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]
   IF Select ( _BrowseArea ) == 0
      RETURN Nil
   ENDIF
   Select &_BrowseArea
   _RecNo := RecNo()

   GO Value

   IF .NOT. Deleted()
      IF _HMG_aControlInputMask [i] == .T.
         IF NetRlock()
            DELETE
            dbUnlock()
            SKIP
            IF EOF()
               GO BOTTOM
            ELSEIF .NOT. SET ( _SET_DELETED )
               SKIP -1
            ENDIF
         ELSE
            MsgStop( _HMG_BRWLangError [9], _HMG_BRWLangMessage [2] )
         ENDIF
      ELSE
         DELETE
         SKIP
         IF EOF()
            GO BOTTOM
         ELSEIF .NOT. SET ( _SET_DELETED )
            SKIP -1
         ENDIF
      ENDIF
      _BrowseSetValue( '' , '' , RecNo() , i , LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) )
   ENDIF

   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _BrowseEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , inplace , InputItems )
*-----------------------------------------------------------------------------*
#ifdef HMG_LEGACY_ON
   LOCAL actpos := { 0, 0, 0, 0 } , h , GRow , GCol , GWidth , Col , i , ControlName , j , FormName , item
   LOCAL Title , aLabels , aInitValues := {} , aFormats := {} , aResults , z , tvar , BackRec , aStru
   LOCAL svar , q , BackArea , BrowseArea , TmpNames := {} , NewRec := 0 , MixedFields := .F.
   PRIVATE aWhen , aWhenVarNames

#else
   hb_default( @inplace, .T. )
#endif
   IF LISTVIEW_GETFIRSTITEM ( GridHandle ) == 0
      IF ValType ( append ) != 'U'
         IF append == .F.
            RETURN Nil
         ENDIF
      ENDIF
   ENDIF

   IF InPlace .OR. _HMG_MainClientMDIHandle != 0  // GF HMG 64
      _BrowseInPlaceEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , InputItems )
#ifdef HMG_LEGACY_ON
   ELSE

   BackArea := Alias()

   i := AScan ( _HMG_aControlHandles , GridHandle )

   aWhen := _HMG_aControlMiscData1 [i] [ 11 ]

   ControlName := _HMG_aControlNames [i]

   j := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [ i ] )

   FormName := _HMG_aFormNames [ j ]

   item := _GetValue ( ControlName , FormName )

   h := GridHandle

   GetWindowRect( h, actpos )

   GRow   := actpos [2]
   GCol   := actpos [1]
   GWidth := actpos [3] - actpos [1]

   Col := GCol + ( GWidth - 310 ) / 2

   IF ValType ( append ) != 'U'
      Title := _HMG_BRWLangButton [ iif( append == .t., 1, 2 ) ]
   ELSE
      Title := _HMG_BRWLangButton [2]
   ENDIF

   aLabels := _HMG_aControlCaption [i]

   BrowseArea := _HMG_aControlSpacing [i]
   Select &BrowseArea

   BackRec := RecNo()

   IF ValType ( append ) != 'U'
      IF append == .T.
         GO BOTTOM
         SKIP
      ELSE
         GO item
      ENDIF
   ELSE
      GO item
   ENDIF

   FOR EACH tvar IN _HMG_aControlRangeMin [i]

      IF ValType ( &tvar ) == 'C'
         AAdd ( aInitValues , AllTrim( &tvar ) )
      ELSE
         AAdd ( aInitValues , &tvar )
      ENDIF

   NEXT

   FOR z := 1 TO Len ( _HMG_aControlRangeMin [i] )

      tvar := Upper ( _HMG_aControlrangeMin [i] [z] )

      q := At ( '>' , tvar )

      IF q == 0

         Select &BrowseArea
         aStru := dbStruct ()

         AAdd ( TmpNames , 'MemVar' + BrowseArea + tvar )

      ELSE

         svar := Left ( tvar , q - 2 )
         Select &svar
         aStru := dbStruct()

         tvar := Right ( tvar , Len ( tvar ) - q )

         AAdd ( TmpNames , 'MemVar' + svar + tvar )

         IF Upper( svar ) != Upper( BrowseArea )
            MixedFields := .T.
         ENDIF

      ENDIF

      IF ValType ( append ) != 'U'
         IF append == .T.
            IF MixedFields == .T.
               MsgMiniGuiError( _HMG_BRWLangError[8], .F. )
            ENDIF
         ENDIF
      ENDIF

      q := .F.

      FOR EACH item IN aStru

         IF item [DBS_NAME] == tvar
            q := .T.
            SWITCH item [DBS_TYPE]
            CASE 'N'
               IF item [DBS_DEC] == 0
                  AAdd ( aFormats, Replicate( '9', item [DBS_LEN] ) )
               ELSEIF item [DBS_DEC] > 0
                  AAdd ( aFormats, Replicate( '9', ( item [DBS_LEN] - item [DBS_DEC] - 1 ) ) + '.' + Replicate( '9', item [DBS_DEC] ) )
               ENDIF
               EXIT
            CASE 'C'
            CASE 'M'
               AAdd ( aFormats, item [DBS_LEN] )
               EXIT
            CASE 'D'
            CASE 'L'
               AAdd ( aFormats, Nil )
               EXIT
            CASE '+'
               q := .F.
            END SWITCH
         ENDIF

      NEXT

      IF ! q  // field not found, but maybe an expression (readonly hopefully!)
         // force to readonly
         IF ValType ( aReadOnly ) == 'U'
            aReadonly := Array( Len ( _HMG_aControlRangeMin [i] ) )
            AFill( aReadonly, .F. )
            aReadonly [z] := .T.
         ELSEIF aReadOnly [z] == .F.
            aReadonly [z] := .T.
         ENDIF
         // add a length to aFormats
         IF ValType ( aInitValues [z] ) == "C"
            AAdd ( aFormats, Max ( 1, Len( aInitValues [z] ) ) )
         ELSEIF ValType ( aInitValues [z] ) == "N"
            aInitValues [z] := Str( aInitValues [z] ) // type conversion doesn't matter, field should be readonly
            AAdd ( aFormats, Max ( 1, Len( aInitValues [z] ) ) )
         ELSE
            AAdd ( aFormats, Nil )
         ENDIF
      ENDIF

   NEXT z

   aWhenVarNames := tmpnames

   Select &BrowseArea

   IF lock == .T.
      IF ! NetRlock()
         MsgAlert ( _HMG_BRWLangError[9], _HMG_BRWLangError[10] )
         GO BackRec
         IF Select ( BackArea ) != 0
            Select &BackArea
         ELSE
            SELECT 0
         ENDIF
         RETURN Nil
      ENDIF
   ENDIF

   aResults := _EditRecord ( Title , aLabels , aInitValues , aFormats , GRow , Col , aValid , TmpNames , aValidMessages , aReadOnly , actpos [4] - actpos [2] )

   tvar := aResults [1]
   IF ValType ( tvar ) != 'U'

      IF ValType ( append ) != 'U'
         IF append == .T.
            APPEND BLANK
            NewRec := RecNo()
         ENDIF
      ENDIF

      IF lock == .T.
         NetRlock()
      ENDIF

      FOR z := 1 TO Len ( aResults )

         IF ValType ( aReadOnly ) == 'U' .OR. aReadOnly [z] == .F.

            tvar := _HMG_aControlRangeMin [i] [z]
            Replace &tvar WITH aResults [z]

         ENDIF

      NEXT z

      _BrowseRefresh ( '' , '' , i )

   ENDIF

   IF lock == .T.
      UNLOCK
   ENDIF

   GO BackRec

   IF Select ( BackArea ) != 0
      Select &BackArea
   ELSE
      SELECT 0
   ENDIF

   _SetFocus( ControlName , FormName )

   IF ValType ( append ) != 'U'
      IF append == .T.
         IF NewRec != 0
            _SetValue ( ControlName , FormName , NewRec )
         ENDIF
      ENDIF
   ENDIF
#endif

   ENDIF

RETURN Nil

#ifdef HMG_LEGACY_ON
*-----------------------------------------------------------------------------*
FUNCTION _EditRecord ( Title , aLabels , aValues , aFormats , row , col , aValid , TmpNames , aValidMessages , aReadOnly , h )
*-----------------------------------------------------------------------------*
   LOCAL i, ControlRow, e := 0, LN, CN, ControlFocused := 'Control_1', th, lFirstEnabledControl := .T.

   PRIVATE l := Len ( aLabels )
   PRIVATE aResult [l]

   FOR i := 1 TO l

      IF ValType ( aValues[i] ) == 'C'

         IF ValType ( aFormats[i] ) == 'N'

            IF aFormats[i] > 32
               e++
            ENDIF

         ENDIF

      ENDIF

      IF ValType ( aValues[i] ) == 'M'
         e++
      ENDIF

   NEXT i

   th := ( l * 30 ) + ( e * 60 ) + 30

   IF TH < H
      TH := H + 1
   ENDIF

   DEFINE WINDOW _EditRecord;
      AT row, col;
      WIDTH 310;
      HEIGHT h - 19 + GetTitleHeight();
      TITLE Title;
      MODAL NOSIZE;
      ON INIT _SetFocus ( ControlFocused , '_Split_1' )

   ON KEY ALT + O ACTION _EditRecordOk ( aValid, TmpNames, aValidMessages )
   ON KEY ALT + C ACTION _EditRecordCancel()

   DEFINE SPLITBOX

   DEFINE WINDOW _Split_1;
      WIDTH 310;
      HEIGHT H - 90;
      VIRTUAL HEIGHT TH;
      SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK FOCUSED

      ON KEY ALT + O ACTION _EditRecordOk ( aValid, TmpNames, aValidMessages )
      ON KEY ALT + C ACTION _EditRecordCancel()

      ControlRow := 10

      FOR i := 1 TO l

         LN := 'Label_' + hb_ntos( i )
         CN := 'Control_' + hb_ntos( i )

         @ ControlRow , 10 LABEL &LN OF _Split_1 VALUE aLabels [i] WIDTH 90

         SWITCH ValType ( aValues [i] )
         CASE 'L'

            @ ControlRow , 120 CHECKBOX &CN OF _Split_1 CAPTION '' VALUE aValues[i];
               ON LOSTFOCUS _WHENEVAL()
            ControlRow += 30
            EXIT
         CASE 'D'

            @ ControlRow , 120 DATEPICKER &CN  OF _Split_1 VALUE aValues[i] WIDTH 140;
               ON LOSTFOCUS _WHENEVAL();
               SHOWNONE
            ControlRow += 30
            EXIT
         CASE 'N'

            IF ValType ( aFormats [i] ) == 'A'
               @ ControlRow , 120 COMBOBOX &CN  OF _Split_1 ITEMS aFormats[i] VALUE aValues[i] WIDTH 140  FONT 'Arial' SIZE 10;
                  ON GOTFOCUS ( LN := _Split_1.FocusedControl, ;
                  SendMessage ( GetControlHandle( LN , '_Split_1' ) , EM_SETSEL , 0 , -1 ) );
                  ON LOSTFOCUS _WHENEVAL()

            ELSEIF ValType ( aFormats [i] ) == 'C'

               @ ControlRow , 120 GETBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 PICTURE aFormats [i];
                  ON GOTFOCUS ( LN := _Split_1.FocusedControl, ;
                  SendMessage ( GetControlHandle( LN , '_Split_1' ) , EM_SETSEL , 0 , -1 ) );
                  ON LOSTFOCUS _WHENEVAL()
               ELSE
               @ ControlRow , 120 GETBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10;
                  ON GOTFOCUS ( LN := _Split_1.FocusedControl, ;
                  SendMessage ( GetControlHandle( LN , '_Split_1' ) , EM_SETSEL , 0 , -1 ) );
                  ON LOSTFOCUS _WHENEVAL()
               ENDIF
               ControlRow += 30
            EXIT
         CASE 'C'

            IF ValType ( aFormats [i] ) == 'N'
               IF  aFormats [i] <= 32
                  @ ControlRow , 120 GETBOX &CN  OF _Split_1 VALUE aValues[i] WIDTH 140 FONT 'Arial' SIZE 10 PICTURE Replicate( "X", aFormats [i] );
                     ON GOTFOCUS ( LN := _Split_1.FocusedControl, ;
                     SendMessage ( GetControlHandle( LN , '_Split_1' ) , EM_SETSEL , 0 , -1 ) );
                     ON LOSTFOCUS _WHENEVAL()
                  ControlRow += 30
               ELSE
                  _Split_1.&(LN).Height := 90
                  @ ControlRow , 120 EDITBOX &CN  OF _Split_1 WIDTH 140 HEIGHT 90 VALUE aValues[i] FONT 'Arial' SIZE 10 MAXLENGTH aFormats[i];
                     ON LOSTFOCUS _WHENEVAL()
                  ControlRow += 94
               ENDIF
            ENDIF
            EXIT
         CASE 'M'

            @ ControlRow , 120 EDITBOX &CN  OF _Split_1 WIDTH 140 HEIGHT 90 VALUE aValues[i] FONT 'Arial' SIZE 10 ON LOSTFOCUS _WHENEVAL()
            ControlRow += 94

         ENDSWITCH

         IF ValType ( aReadOnly ) != 'U'
            IF aReadOnly [i] == .T.
               _DisableControl ( CN , '_Split_1' )
            ELSEIF lFirstEnabledControl == .T.
               lFirstEnabledControl := .F.
               ControlFocused := CN
            ENDIF
         ENDIF

      NEXT i

      END WINDOW

      DEFINE WINDOW _Split_2;
         WIDTH 300;
         HEIGHT 50;
         SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK

      @ 10, 40 BUTTON BUTTON_1;
         OF _Split_2;
         CAPTION _HMG_BRWLangButton[4];
         ACTION _EditRecordOk ( aValid , TmpNames , aValidMessages )

      @ 10, 150 BUTTON BUTTON_2;
         OF _Split_2;
         CAPTION _HMG_BRWLangButton[3];
         ACTION _EditRecordCancel()

      END WINDOW

   END SPLITBOX

   END WINDOW

   ACTIVATE WINDOW _EditRecord

RETURN ( aResult )

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _WHENEVAL ()
*-----------------------------------------------------------------------------*
   LOCAL i, x
   LOCAL Result, mVar
   LOCAL ControlName

   IF ValType ( aWhen ) == 'A'

      IF Len ( aWhen ) >= l

         FOR x := 1 TO l

            IF ValType ( aWhen [x] ) != 'U'
               ControlName := 'Control_' + AllTrim ( Str ( x ) )
               Result := _GetValue ( ControlName , '_Split_1' )
               mVar := aWhenVarNames [x]
               &mVar := Result
            ENDIF

         NEXT x


         FOR i := 1 TO l

            IF ValType ( aWhen [i] ) == 'B'

               ControlName := 'Control_' + AllTrim ( Str ( i ) )

               IF Eval ( aWhen [i] )
                  _EnableControl ( ControlName , '_Split_1' )
               ELSE
                  _DisableControl ( ControlName , '_Split_1' )
               ENDIF

            ENDIF

         NEXT i

      ENDIF

   ENDIF

RETURN
*-----------------------------------------------------------------------------*
STATIC FUNCTION _EditRecordOk ( aValid , TmpNames , aValidMessages )
*-----------------------------------------------------------------------------*
   LOCAL i , ControlName , l , mVar

   l := Len ( aResult )

   FOR i := 1 TO l

      ControlName := 'Control_' + AllTrim ( Str ( i ) )
      aResult [i] := _GetValue ( ControlName , '_Split_1' )

      IF ValType ( aValid ) != 'U'

         mVar := TmpNames [i]
         &mVar := aResult [i]

      ENDIF

   NEXT i

   IF ValType ( aValid ) == 'A'

      FOR i := 1 TO l

         IF ValType ( aValid [i] ) == 'B'

            IF ! Eval ( aValid [i] )

               IF ValType ( aValidMessages ) == 'A'

                  IF ValType ( aValidMessages [i] ) != 'U'

                     MsgAlert ( aValidMessages[i], _HMG_BRWLangError[10] )

                  ELSE

                     MsgAlert ( _HMG_BRWLangError[11], _HMG_BRWLangError[10] )

                  ENDIF

               ELSE

                  MsgAlert ( _HMG_BRWLangError[11], _HMG_BRWLangError[10] )

               ENDIF

               _SetFocus ( 'Control_' + hb_ntos( i ) , '_Split_1' )

               RETURN Nil

            ENDIF

         ENDIF

      NEXT i

   ENDIF

   RELEASE WINDOW _EditRecord

RETURN Nil
*-----------------------------------------------------------------------------*
STATIC FUNCTION _EditRecordCancel ()
*-----------------------------------------------------------------------------*

   AEval( aResult, { |x, i| HB_SYMBOL_UNUSED( x ), aResult [i] := Nil } )

   RELEASE WINDOW _EditRecord

RETURN Nil
#endif

*-----------------------------------------------------------------------------*
STATIC FUNCTION _BrowseInPlaceEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , aInputItems )
*-----------------------------------------------------------------------------*
   LOCAL GridCol , GridRow , i , nrec , _GridWorkArea , BackArea , BackRec
   LOCAL _GridFields , FieldName , CellData := '' , CellColIndex
   LOCAL aStruct , Width , Decimals , sFieldname , ControlType
   LOCAL Ldelta := 0 , aTemp , E , r , p , lInputItems := .F. , aItems := {}, aValues := {}
   LOCAL aEnabledTypes := { "N", "C", "D", "L", "M" }
   LOCAL abKeyBlocks := {}
   LOCAL bOnDisplay := { || AAdd( abKeyBlocks, _GetHotKeyBlock ( '_InPlaceEdit', 0, 27 ) ), ;
      _ReleaseHotKey ( '_InPlaceEdit', 0, 27 ), ;
      AAdd( abKeyBlocks, _GetHotKeyBlock ( '_InPlaceEdit', 0, 13 ) ), ;
      _ReleaseHotKey ( '_InPlaceEdit', 0, 13 ) }
   LOCAL bOnCloseUp := { || _DefineHotKey( '_InPlaceEdit', 0, 27, abKeyBlocks[1] ), ;
      _DefineHotKey( '_InPlaceEdit', 0, 13, abKeyBlocks[2] ), ;
      abKeyBlocks := {} }

   IF _HMG_ThisEventType == 'BROWSE_WHEN'
      MsgMiniGuiError( "BROWSE: Editing within WHEN event procedure is not allowed." )
   ELSEIF _HMG_ThisEventType == 'BROWSE_VALID'
      MsgMiniGuiError( "BROWSE: Editing within VALID event procedure is not allowed." )
   ENDIF

   IF append
      i := AScan ( _HMG_aControlhandles , GridHandle )
      _BrowseInPlaceAppend ( '' , '' , i )
      RETURN Nil
   ENDIF

   IF This.CellRowIndex != LISTVIEW_GETFIRSTITEM ( GridHandle )
      RETURN Nil
   ENDIF

   i := AScan ( _HMG_aControlhandles , GridHandle )

   _GridWorkArea := _HMG_aControlSpacing [i]

   _GridFields := _HMG_aControlRangeMin [i]

   CellColIndex := This.CellColIndex

   IF CellColIndex < 1 .OR. CellColIndex > Len ( _GridFields )
      RETURN Nil
   ENDIF

   IF Len ( _HMG_aControlBkColor [i] ) > 0 .AND. CellColIndex == 1
      PlayHand()
      RETURN Nil
   ENDIF

   IF ValType ( aInputItems ) == 'A'
      IF Len ( aInputItems ) >= CellColIndex
         IF ValType ( aInputItems [ CellColIndex ] ) == 'A'
            lInputItems := .T.
         ENDIF
      ENDIF
   ENDIF

   IF ValType ( aReadOnly ) == 'A'
      IF Len ( aReadOnly ) >= CellColIndex
         IF aReadOnly [ CellColIndex ] != Nil
            IF aReadOnly [ CellColIndex ] == .T.
               _HMG_IPE_CANCELLED := .F.
               RETURN Nil
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   FieldName := _GridFields [ CellColIndex ]

   IF AScan( aEnabledTypes, ( _GridWorkArea )->( _TypeEx ( FieldName ) ) ) < 1
      MsgAlert ( "Edit of this field is not supported.", _HMG_BRWLangError[10] )
      RETURN Nil
   ENDIF

   r := At ( '>', FieldName )

   IF r != 0
      sFieldName := Right ( FieldName, Len( Fieldname ) - r )
      p := Left ( FieldName, r - 2 )
      IF !( Upper( p ) == "FIELD" ) .AND. !( Upper( p ) == "_FIELD" )
         _GridWorkArea := p
      ENDIF
   ELSE
      sFieldName := FieldName
   ENDIF

   // If the specified area does not exists, when return
   IF Select ( _GridWorkArea ) == 0
      RETURN Nil
   ENDIF

   // Save Original WorkArea
   BackArea := Alias()
   // Selects Grid's WorkArea
   Select &_GridWorkArea
   // Save Original Record Pointer
   BackRec := RecNo()

   IF _GridWorkArea == _HMG_aControlSpacing [i]
      nRec := _GetValue ( '', '' , i )
      GO nRec
   ENDIF

   // If LOCK clause is present, try to lock.
   IF lock == .T.
      IF ( _GridWorkArea )->( NetRlock() ) == .F.
         MsgAlert( _HMG_BRWLangError[9], _HMG_BRWLangError[10] )
         // Restore Original Record Pointer
         GO BackRec
         // Restore Original WorkArea
         IF Select ( BackArea ) != 0
            Select &BackArea
         ELSE
            SELECT 0
         ENDIF
         RETURN Nil
      ENDIF
   ENDIF

   aTemp := _HMG_aControlMiscData1 [i] [ 11 ]

   IF ValType ( aTemp ) == 'A'
      IF Len ( aTemp ) >= Len ( _GridFields )
         IF ValType ( aTemp [CellColIndex] ) == 'B'
            _HMG_ThisEventType := 'BROWSE_WHEN'
            E := Eval ( aTemp [CellColIndex] )
            _HMG_ThisEventType := ''
            IF ISLOGICAL( E ) .AND. E == .F.
               PlayHand()
               // Restore Original Record Pointer
               GO BackRec
               // Restore Original WorkArea
               IF Select ( BackArea ) != 0
                  Select &BackArea
               ELSE
                  SELECT 0
               ENDIF
               _HMG_IPE_CANCELLED := .F.
               RETURN Nil
            ENDIF
            IF Alias() <> _GridWorkArea
               Select &_GridWorkArea
            ENDIF
            IF ISNUMBER ( nRec ) .AND. RecNo() <> nRec
               GO nRec
            ENDIF
            IF GetControlHandle ( _GetFocusedControl ( ( r := GetParentFormName( i ) ) ), r ) <> GridHandle
               SetFocus ( GridHandle )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   CellData := &FieldName

   aStruct := dbStruct()

   r := FieldPos ( sFieldName )

   IF r > 0
      Width    := aStruct [r] [DBS_LEN]
      Decimals := aStruct [r] [DBS_DEC]
   ENDIF

   GridRow := GetWindowRow ( GridHandle )
   GridCol := GetWindowCol ( GridHandle )

   IF lInputItems == .T.
      ControlType := 'X'
      Ldelta := 1
   ELSE
      p := Type ( FieldName )
      SWITCH p
      CASE 'C'
      CASE 'D'
      CASE 'M'
         ControlType := p
         EXIT
      CASE 'L'
         ControlType := p
         Ldelta := 1
         EXIT
      CASE 'N'
         ControlType := IFEMPTY( Decimals, 'I', 'F' )
      END SWITCH
   ENDIF

   _HMG_InplaceParentHandle := iif( _HMG_BeginWindowMDIActive, GetActiveMdiHandle(), GetActiveWindow() )

   IF ControlType == 'M'

      r := InputBox ( '' , _HMG_aControlCaption [i][CellColIndex] , StrTran( CellData, Chr(141 ), ' ' ) , , , .T. )

      IF _HMG_DialogCancelled == .F.
         Replace &FieldName WITH r
         _HMG_IPE_CANCELLED := .F.
      ELSE
         _HMG_IPE_CANCELLED := .T.
      ENDIF

      IF lock == .T.
         ( _GridWorkArea )->( dbUnlock() )
      ENDIF

   ELSE

      DEFINE WINDOW _InPlaceEdit ;
         AT This.CellRow + GridRow - _HMG_aControlRow [i] - 1 , This.CellCol + GridCol - _HMG_aControlCol [i] + 2 ;
         WIDTH This.CellWidth ;
         HEIGHT This.CellHeight + 6 + Ldelta ;
         MODAL ;
         NOCAPTION ;
         NOSIZE

      ON KEY CONTROL + U ACTION iif( _IsWindowActive( '_InPlaceEdit' ), ;
         _InPlaceEdit.Control_1.Value := iif( ControlType == 'L', iif ( CellData , 1 , 2 ), CellData ), NIL )
      ON KEY RETURN ACTION iif( _IsWindowActive( '_InPlaceEdit' ), ;
         _InPlaceEditOk ( i , _InPlaceEdit.Control_1.Value , aValid , CellColIndex , ;
         sFieldName , _GridWorkArea , aValidMessages , lock , ControlType , aInputItems ), NIL )
      ON KEY ESCAPE ACTION ( _HMG_IPE_CANCELLED := .T. , iif( lock == .T. , dbUnlock(), NIL ) , ;
         iif( _IsWindowActive( '_InPlaceEdit' ), _InPlaceEdit.Release, NIL ) )

      IF lInputItems == .T.

         // Fill Items Array
         AEval( aInputItems [ CellColIndex ] , { |p| AAdd ( aItems , p [1] ) } )
         // Fill Values Array
         AEval( aInputItems [ CellColIndex ] , { |p| AAdd ( aValues , p [2] ) } )

         r := AScan ( aValues , CellData )

         DEFINE COMBOBOX Control_1
           ROW 0
           COL 0
           ITEMS aItems
           WIDTH This.CellWidth
           VALUE iif ( Empty( r ) , 1 , r )
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
           ON LISTDISPLAY Eval( bOnDisplay )
           ON LISTCLOSE Eval( bOnCloseUp )
         END COMBOBOX

      ELSEIF ControlType == 'C'
         CellData := RTrim ( CellData )

         DEFINE TEXTBOX Control_1
           ROW 0
           COL 0
           WIDTH This.CellWidth
           HEIGHT This.CellHeight + 6
           VALUE CellData
           MAXLENGTH Width
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
         END TEXTBOX

      ELSEIF ControlType == 'D'

         DEFINE DATEPICKER Control_1
           ROW 0
           COL 0
           HEIGHT This.CellHeight + 6
           WIDTH This.CellWidth
           VALUE CellData
           UPDOWN .T.
           SHOWNONE .T.
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
         END DATEPICKER

      ELSEIF ControlType == 'L'

         DEFINE COMBOBOX Control_1
           ROW 0
           COL 0
           ITEMS { '.T.', '.F.' }
           WIDTH This.CellWidth
           VALUE iif ( CellData , 1 , 2 )
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
           ON LISTDISPLAY Eval( bOnDisplay )
           ON LISTCLOSE Eval( bOnCloseUp )
         END COMBOBOX

      ELSEIF ControlType == 'I'

         DEFINE TEXTBOX Control_1
           ROW 0
           COL 0
           NUMERIC   .T.
           WIDTH This.CellWidth
           HEIGHT This.CellHeight + 6
           VALUE CellData
           MAXLENGTH Width
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
         END TEXTBOX

      ELSEIF ControlType == 'F'

         DEFINE TEXTBOX Control_1
           ROW 0
           COL 0
           NUMERIC   .T.
           INPUTMASK Replicate ( '9', Width - Decimals - 1 ) + '.' + Replicate ( '9', Decimals )
           WIDTH This.CellWidth
           HEIGHT This.CellHeight + 6
           VALUE CellData
           FONTNAME _hmg_aControlFontName [i]
           FONTSIZE _hmg_aControlFontSize [i]
         END TEXTBOX

      ENDIF

      END WINDOW

      _SetFocus ( 'Control_1' , '_InPlaceEdit' )

      ACTIVATE WINDOW _InPlaceEdit

   ENDIF

   _MdiWindowsActivate ( _HMG_InplaceParentHandle )  // GF HMG 47

   _HMG_InplaceParentHandle := 0

   SetFocus ( GridHandle )

   // Restore Original Record Pointer
   GO BackRec
   // Restore Original WorkArea
   IF Select ( BackArea ) != 0
      Select &BackArea
   ELSE
      SELECT 0
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _InPlaceEditOk ( i , r , aValid , CellColIndex , sFieldName , AreaName , aValidMessages , lock , ControlType , aInputItems )
*-----------------------------------------------------------------------------*
   LOCAL b , Result , mVar , TmpName

   IF ValType ( aValid ) == 'A'

      IF Len ( aValid ) >= CellColIndex

         IF aValid [ CellColIndex ] != Nil

            Result := _GetValue ( 'Control_1' , '_InPlaceEdit' )

            IF ControlType == 'L'
               Result := ( Result == 1 )
            ELSEIF ControlType == 'X'
               Result := aInputItems [ CellColIndex ] [ r ] [ 2 ]
            ENDIF

            TmpName := 'MemVar' + AreaName + sFieldname
            mVar    := TmpName
            &mVar   := Result

            _HMG_ThisEventType := 'BROWSE_VALID'

            b := Eval ( aValid [ CellColIndex ] )

            _HMG_ThisEventType := ''

            IF ISLOGICAL( b ) .AND. b == .F.

               IF ValType ( aValidMessages ) == 'A'

                  IF Len ( aValidMessages ) >= CellColIndex

                     IF aValidMessages [CellColIndex] != Nil

                        IF ValType ( aValidMessages [CellColIndex] ) == 'C'

                           MsgAlert ( aValidMessages [CellColIndex], _HMG_BRWLangError[10] )

                        ELSEIF ValType ( aValidMessages [CellColIndex] ) == 'B'

                           Eval ( aValidMessages [ CellColIndex ], Result )

                        ENDIF

                     ELSE

                        MsgAlert ( _HMG_BRWLangError[11], _HMG_BRWLangError[10] )

                     ENDIF

                  ELSE

                     MsgAlert ( _HMG_BRWLangError[11], _HMG_BRWLangError[10] )

                  ENDIF

               ELSE

                  MsgAlert ( _HMG_BRWLangError[11], _HMG_BRWLangError[10] )

               ENDIF

            ELSE

               _InPlaceEditSave ( i , sFieldname , AreaName , r , lock , ControlType , aInputItems , CellColIndex )

            ENDIF

         ELSE

            _InPlaceEditSave ( i , sFieldname , AreaName , r , lock , ControlType , aInputItems , CellColIndex )

         ENDIF

      ENDIF

   ELSE

      _InPlaceEditSave ( i , sFieldname , AreaName , r , lock , ControlType , aInputItems , CellColIndex )

   ENDIF

   _HMG_IPE_CANCELLED := .F.

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _InPlaceEditSave ( i , FieldName , Alias , r , lock , ControlType , aInputItems , CellColIndex )
*-----------------------------------------------------------------------------*

   IF lock == .T.
      IF ! ( Alias )->( NetRlock() )
         MsgAlert ( _HMG_BRWLangError[9], _HMG_BRWLangError[10] )
         RETURN
      ENDIF
   ENDIF

   IF ISNUMERIC( r )
      IF ControlType == 'L'
         r := ( r == 1 )
      ELSEIF ControlType == 'X'
         r := aInputItems [ CellColIndex ] [ r ] [ 2 ]
      ENDIF
   ENDIF

   FieldName := Alias + "->" + FieldName
   Replace &FieldName WITH r

   IF lock == .T.
      ( Alias )->( dbUnlock() )
   ENDIF

   _BrowseRefresh ( '' , '' , i )

   _InPlaceEdit.Release

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION NetRlock()
*-----------------------------------------------------------------------------*
   LOCAL lSuccess := .T. , n := 1

   IF AScan ( RecNo(), dbRLockList() ) == 0

      REPEAT

         IF ( lSuccess := RLock() )
            EXIT
         ENDIF

         Inkey( .2 )
         n -= .2

      UNTIL ( n > 0 )

   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
PROCEDURE ProcessInPlaceKbdEdit( i )
*-----------------------------------------------------------------------------*
   LOCAL r, IPE_MAXCOL, TmpRow, xs, xd

   IF _HMG_aControlFontColor [i] == .F.
      RETURN
   ENDIF

   IF LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) == 0
      RETURN
   ENDIF

   IPE_MAXCOL := Len ( _HMG_aControlRangeMin [i] )

   DO WHILE .T.

      TmpRow := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] )

      IF TmpRow != _HMG_IPE_ROW

         _HMG_IPE_ROW := TmpRow
         _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

      ENDIF

      _HMG_ThisItemRowIndex := _HMG_IPE_ROW
      _HMG_ThisItemColIndex := _HMG_IPE_COL

      IF _HMG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i] , _HMG_IPE_ROW - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , _HMG_IPE_ROW - 1 , _HMG_IPE_COL - 1 )
      ENDIF

      xs := ( _HMG_aControlCol [i] + r [2] + r [3] ) - ( _HMG_aControlCol [i] + _HMG_aControlWidth [i] )

      xd := 20

      IF xs > - xd
         ListView_Scroll( _HMG_aControlHandles [i] , xs + xd , 0 )
      ELSE

         IF r [2] < 0
            ListView_Scroll( _HMG_aControlHandles [i] , r[2] , 0 )
         ENDIF

      ENDIF

      IF _HMG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i] , _HMG_IPE_ROW - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , _HMG_IPE_ROW - 1 , _HMG_IPE_COL - 1 )
      ENDIF

      _HMG_ThisItemCellRow := _HMG_aControlRow [i] + r [1]
      _HMG_ThisItemCellCol := _HMG_aControlCol [i] + r [2]
      _HMG_ThisItemCellWidth := r[3]
      _HMG_ThisItemCellHeight := r[4]

      _BrowseEdit ( _hmg_acontrolhandles[i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .F. , _HMG_aControlFontColor [i] , _HMG_acontrolmiscdata1 [i] [13] )

      _HMG_ThisIndex := 0
      _HMG_ThisType := ''

      _HMG_ThisItemRowIndex := 0
      _HMG_ThisItemColIndex := 0
      _HMG_ThisItemCellRow := 0
      _HMG_ThisItemCellCol := 0
      _HMG_ThisItemCellWidth := 0
      _HMG_ThisItemCellHeight := 0

      IF _HMG_IPE_CANCELLED == .T.

         IF _HMG_IPE_COL == IPE_MAXCOL

            _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

            ListView_Scroll( _HMG_aControlHandles [i] , -10000 , 0 )

         ENDIF

         EXIT

      ELSE

         _HMG_IPE_COL++

         IF _HMG_IPE_COL > IPE_MAXCOL

            _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

            ListView_Scroll( _HMG_aControlHandles [i] , -10000 , 0 )

            EXIT

         ENDIF

      ENDIF

   ENDDO

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _BrowseSync ( i )
*-----------------------------------------------------------------------------*
   LOCAL _Alias , _BrowseArea , _RecNo , _CurrentValue

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]
   IF Select ( _BrowseArea ) == 0
      RETURN
   ENDIF
   Select &_BrowseArea
   _RecNo := RecNo()

   _CurrentValue := _BrowseGetValue ( '' , '' , i )

   IF _RecNo != _CurrentValue
      GO _CurrentValue
   ENDIF

   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

RETURN
*-----------------------------------------------------------------------------*
PROCEDURE _BrowseOnChange ( i )
*-----------------------------------------------------------------------------*

   IF _HMG_BrowseSyncStatus == .T.
      _BrowseSync ( i )
   ENDIF

   _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _BrowseInPlaceAppend ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , _Alias , _RecNo , _BrowseArea , _NewRec , aTemp

   i := iif( PCount() == 2 , GetControlIndex ( ControlName , ParentForm ) , z )

   _Alias := Alias()
   _BrowseArea := _HMG_aControlSpacing [i]
   IF Select ( _BrowseArea ) == 0
      RETURN
   ENDIF
   Select &_BrowseArea
   _RecNo := RecNo()
   GO BOTTOM

   _NewRec := RecCount() + 1

   IF LISTVIEWGETITEMCOUNT( _HMG_aControlhandles[i] ) != 0
      _BrowseVscrollUpdate( i )
      Skip - LISTVIEWGETCOUNTPERPAGE ( _HMG_aControlhandles[i] ) + 2
      _BrowseUpdate( '' , '' , i )
   ENDIF

   APPEND BLANK

   GO _RecNo
   IF Select( _Alias ) != 0
      Select &_Alias
   ELSE
      SELECT 0
   ENDIF

   aTemp := Array ( Len ( _HMG_aControlRangeMin [i] ) )
   AFill ( aTemp , '' )
   AAdd ( _HMG_aControlRangeMax [i] , _NewRec )

   AddListViewItems ( _HMG_aControlhandles[i] , aTemp , 0 )

   ListView_SetCursel ( _HMG_aControlHandles [i] , Len ( _HMG_aControlRangeMax [i] ) )

   _BrowseOnChange ( i )

   _HMG_IPE_ROW := 1
   _HMG_IPE_COL := 1

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _BrowseVscrollUpdate ( i )
*-----------------------------------------------------------------------------*
   LOCAL ActualRecord , RecordCount , KeyCount

   // If vertical scrollbar is used it must be updated
   IF _HMG_aControlIds [i] != 0

      KeyCount := ordKeyCount()
      IF KeyCount > 0
         ActualRecord := ordKeyNo()
         RecordCount := KeyCount
      ELSE
         ActualRecord := RecNo()
         RecordCount := RecCount()
      ENDIF

      _HMG_aControlBrushHandle [i] := RecordCount

      IF RecordCount < 100
         SetScrollRange ( _HMG_aControlIds [i] , SB_CTL , 1 , RecordCount , .T. )
         SetScrollPos ( _HMG_aControlIds [i] , SB_CTL , ActualRecord , .T. )
      ELSE
         SetScrollRange ( _HMG_aControlIds [i] , SB_CTL , 1 , 100 , .T. )
         SetScrollPos ( _HMG_aControlIds [i] , SB_CTL , Int ( ActualRecord * 100 / RecordCount ) , .T. )
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _BrowseVscrollFastUpdate ( i , d )
*-----------------------------------------------------------------------------*
   LOCAL ActualRecord , RecordCount

   // If vertical scrollbar is used it must be updated
   IF _HMG_aControlIds [i] != 0

      RecordCount := _HMG_aControlBrushHandle [i]

      IF .NOT. ISNUMBER( RecordCount ) .OR. RecordCount == 0
         RETURN
      ENDIF

      IF RecordCount < 100
         ActualRecord := GetScrollPos( _HMG_aControlIds [i], 2 )
         ActualRecord := ActualRecord + d
         SetScrollRange ( _HMG_aControlIds [i] , SB_CTL , 1 , RecordCount , .T. )
         SetScrollPos ( _HMG_aControlIds [i] , SB_CTL , ActualRecord , .T. )
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _SetGetBrowseProperty ( ControlName, ParentForm, nId, Value )
*-----------------------------------------------------------------------------*
   LOCAL RetVal := .T. , i := GetControlIndex ( ControlName, ParentForm )

   IF _HMG_aControlType [i] == 'BROWSE'
      IF PCount() > 3
         _HMG_aControlMiscData1 [ i ] [ nId ] := Value
      ELSE
         RetVal := _HMG_aControlMiscData1 [ i ] [ nId ]
      ENDIF
   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
STATIC FUNCTION NoQuote ( cStr )
*-----------------------------------------------------------------------------*

RETURN CharRem ( Chr(34) + Chr(39), cStr )

#endif
