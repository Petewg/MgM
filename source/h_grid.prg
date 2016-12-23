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

#include 'minigui.ch'
#include "i_winuser.ch"

STATIC _lTabKeyPressed := .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineGrid ( ControlName, ParentFormName, x, y, w, h, aHeaders, aWidths, aRows, value, ;
      fontname, fontsize, tooltip, change, dblclick, aHeadClick, gotfocus, lostfocus, nogrid, ;
      aImage, aJust, break, HelpId , bold, italic, underline, strikeout, ownerdata, ondispinfo, ;
      itemcount, editable, dynamicforecolor, dynamicbackcolor, multiselect, editcontrols, ;
      backcolor, fontcolor, nId, columnvalid, columnwhen, validmessages, showheaders, aImageHeader, ;
      NoTabStop, celled, lCheckboxes, lockcolumns, OnCheckBoxClicked, doublebuffer, nosortheaders, columnsort )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , blInit , mVar, wBitmap , k , Style , inplace , lsort
   LOCAL ControlHandle , FontHandle , nHeaderImageListHandle := 0
   LOCAL lDialogInMemory

   hb_default( @w, 240 )
   hb_default( @h, 120 )
   hb_default( @showheaders, .T. )
   hb_default( @nosortheaders, .F. )
   __defaultNIL( @aImage, {} )
   __defaultNIL( @aImageHeader, {} )
   __defaultNIL( @aHeadClick, {} )
   __defaultNIL( @change, "" )
   __defaultNIL( @dblclick, "" )
   hb_default( @notabstop, .F. )
   hb_default( @lockcolumns, 0 )
   hb_default( @doublebuffer, .F. )
   hb_default( @lcheckboxes, .F. )

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
   /* Dr. Claudio Soto, April 2016 */
   #define DEFAULT_COLUMNHEADER  "Column "
   #define DEFAULT_COLUMNWIDTH   150
   IF ValType( aRows ) == "A" .AND. Len( aRows ) > 0
      IF ValType( aHeaders ) == "U" .AND. ValType( aWidths ) == "U"
         aHeaders := Array( Len( aRows[ 1 ] ) )
         aWidths  := Array( Len( aRows[ 1 ] ) )
         AEval( aHeaders, { | xValue, nIndex | xValue := NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_ntos( nIndex ) } )
         AFill( aWidths,  DEFAULT_COLUMNWIDTH )
      ELSEIF ValType( aHeaders ) == "A" .AND. ValType( aWidths ) == "U"
         aWidths  := Array( Len( aHeaders ) )
         AFill( aWidths,  DEFAULT_COLUMNWIDTH )
         IF Len( aImage ) > 0
            aWidths[ 1 ] := 0
         ENDIF
      ELSEIF ValType( aHeaders ) == "U" .AND. ValType( aWidths ) == "A"
         aHeaders := Array( Len( aWidths ) )
         AEval( aHeaders, { | xValue, nIndex | xValue := NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_ntos( nIndex ) } )
      ENDIF
   ELSE
      IF ValType( aHeaders ) == "U" .AND. ValType( aWidths ) == "U"
         aHeaders := { '' }
         aWidths  := { 0 }
      ELSEIF ValType( aHeaders ) == "A" .AND. ValType( aWidths ) == "U"
         aWidths  := Array( Len( aHeaders ) )
         AFill( aWidths,  DEFAULT_COLUMNWIDTH )
         IF Len( aImage ) > 0
            aWidths[ 1 ] := 0
         ENDIF
      ELSEIF ValType( aHeaders ) == "U" .AND. ValType( aWidths ) == "A"
         aHeaders := Array( Len( aWidths ) )
         AEval( aHeaders, { | xValue, nIndex | xValue := NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_ntos( nIndex ) } )
      ENDIF
   ENDIF
   /* end code borrowed */
   IF showheaders == .F.
      aHeaders := Array ( Len ( aWidths ) )
      AFill ( aHeaders , '' )
   ENDIF

   IF ValType( value ) == "U" .AND. ! MultiSelect
      value := 0
   ENDIF

   __defaultNIL( @aRows, {} )
   /* code borrowed from ooHG project */
   IF !HB_ISARRAY( aJust )
      aJust := AFill( Array( Len( aHeaders ) ), 0 )
   ELSE
      ASize( aJust, Len( aHeaders ) )
      AEval( aJust, { |x, i| aJust[ i ] := iif( HB_ISNUMERIC( x ), x, 0 ) } )
   ENDIF
   /* end code borrowed */
   inplace := ISARRAY( editcontrols )
   lsort := ( ISARRAY( columnsort ) .AND. nosortheaders == .F. .AND. ownerdata == .F. )

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle
      Style := WS_BORDER + LVS_SHOWSELALWAYS + WS_CHILD + WS_VISIBLE + LVS_REPORT

      IF ! NoTabStop
         Style += WS_TABSTOP
      ENDIF

      IF ! multiselect
         Style += LVS_SINGLESEL
      ENDIF

      IF ownerdata
         Style += LVS_OWNERDATA
      ENDIF

      IF ! showheaders
         Style += LVS_NOCOLUMNHEADER
      ELSEIF nosortheaders
         Style += LVS_NOSORTHEADER
      ENDIF

      IF Len( _HMG_aDialogTemplate ) > 0     //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,x,y,w,h,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogGrid( x, y, z ) }
         AAdd( _HMG_aDialogItems, { nId, k, "SysListView32", style, 0, x, y, w, h, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, , _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         SetWindowStyle ( ControlHandle, Style, .T. )

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )
         w := GetWindowWidth  ( Controlhandle )
         h := GetWindowHeight ( Controlhandle )

         IF ownerdata
            LISTVIEW_SETITEMCOUNT (  ControlHandle , itemcount )
         ENDIF

         SendMessage( ControlHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, iif( nogrid, 0, 1 ) + LVS_EX_FULLROWSELECT + LVS_EX_INFOTIP + LVS_EX_HEADERDRAGDROP + iif( lCheckboxes, LVS_EX_CHECKBOXES, 0 ) )

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      IF ValType( x ) == "U" .OR. ValType( y ) == "U"

         IF _HMG_SplitLastControl == 'TOOLBAR'
            Break := .T.
         ENDIF

         _HMG_SplitLastControl := 'GRID'

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            x := y := 0
            ControlHandle := InitListView ( _HMG_aFormReBarHandle [i], 0, x, y, w, h , ownerdata, itemcount, multiselect, showheaders, nosortheaders, NoTabStop )

            AddSplitBoxItem ( Controlhandle, _HMG_aFormReBarHandle [i] , w , break , , , , _HMG_ActiveSplitBoxInverted )

         ENDIF

      ELSE

         ControlHandle := InitListView ( ParentFormHandle, 0, x, y, w, h , ownerdata, itemcount, multiselect, showheaders, nosortheaders, NoTabStop )

      ENDIF

   ENDIF

   IF .NOT. lDialogInMemory

      IF ValType ( backcolor ) != 'U'
         ListView_SetBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
         ListView_SetTextBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
      ENDIF

      IF ValType ( fontcolor ) != 'U'
         ListView_SetTextColor ( ControlHandle , fontcolor[1] , fontcolor[2] , fontcolor[3] )
      ENDIF

      wBitmap := iif( Len( aImage ) > 0, AddListViewBitmap( ControlHandle, aImage ), 0 )
      aWidths[ 1 ] := Max ( aWidths[ 1 ], wBitmap + 2 ) // Set Column 1 width to Bitmap width

      IF lsort
         aImageHeader := { 'MINIGUI_GRID_ASC', 'MINIGUI_GRID_DSC' }
         aHeadClick := Array( Len( aHeaders ) )
         AEval( aHeadClick, { | x, i | aHeadClick[ i ] := { | n | HMG_SortColumn( n ) }, HB_SYMBOL_UNUSED( x ) } )
      ENDIF

      IF Len( aImageHeader ) > 0
         nHeaderImageListHandle := AddListViewBitmapHeader( ControlHandle, aImageHeader )
      ENDIF

      IF _HMG_BeginTabActive
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
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

   _HMG_aControlType [k] := iif ( multiselect , "MULTIGRID" , "GRID" )
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParenthandles [k] :=   ParentFormHandle
   _HMG_aControlIds [k] :=   nId
   _HMG_aControlProcedures [k] :=   ondispinfo
   _HMG_aControlPageMap  [k] :=  aHeaders
   _HMG_aControlValue  [k] :=  Value
   _HMG_aControlInputMask  [k] :=  Nil
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  aImage
   _HMG_aControlFontColor [k] :=  celled
   _HMG_aControlDblClick  [k] :=  dblclick
   _HMG_aControlHeadClick  [k] :=  aHeadClick
   _HMG_aControlRow   [k] := y
   _HMG_aControlCol   [k] := x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing  [k] :=  Editable
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  aImageHeader
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes  [k] :=  { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin  [k] :=  nHeaderImageListHandle
   _HMG_aControlRangeMax  [k] :=  iif( lsort, Array( Len( aHeaders ) ), 0 )
   _HMG_aControlCaption  [k] :=   aHeaders
   _HMG_aControlVisible   [k] :=  .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle   [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { 0, aWidths, aJust, aRows, ownerdata, itemcount, nogrid, ;
      backcolor, fontcolor, multiselect, dynamicforecolor, dynamicbackcolor, editcontrols, ;
      columnvalid, columnwhen, validmessages, 1, lcheckboxes, lockcolumns, inplace, NIL, NIL, ;
      OnCheckBoxClicked, doublebuffer }
   _HMG_aControlMiscData2 [k] := ''

   IF Len( _HMG_aDialogTemplate ) == 0    //Dialog Template
      IF lsort
         AFill( _HMG_aControlRangeMax [k], 1 )
         IF Len( columnsort ) > 0
            FOR i := 1 TO Min( Len( columnsort ), Len( _HMG_aControlRangeMax [k] ) )
               IF ValType( columnsort [i] ) == 'N'
                  _HMG_aControlRangeMax [k][i] := columnsort [i]
               ENDIF
            NEXT i
         ENDIF
      ENDIF
      InitDialogGrid ( ParentFormName, ControlHandle, k )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogGrid( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL ControlName, Value , row , wBitmap
   LOCAL ownerdata, itemcount, fontcolor, backcolor, aRows, multiselect
   LOCAL aWidths, aJust, nogrid, lcheckboxes, lockcolumns, doublebuffer

   ControlName  := _HMG_aControlNames [k]
   Value        := _HMG_aControlValue [k]

   aWidths      := _HMG_aControlMiscData1 [k,2]
   aJust        := _HMG_aControlMiscData1 [k,3]
   aRows        := _HMG_aControlMiscData1 [k,4]
   ownerdata    := _HMG_aControlMiscData1 [k,5]
   itemcount    := _HMG_aControlMiscData1 [k,6]
   nogrid       := _HMG_aControlMiscData1 [k,7]
   backcolor    := _HMG_aControlMiscData1 [k,8]
   fontcolor    := _HMG_aControlMiscData1 [k,9]
   multiselect  := _HMG_aControlMiscData1 [k,10]
   lcheckboxes  := _HMG_aControlMiscData1 [k,18]
   lockcolumns  := _HMG_aControlMiscData1 [k,19]
   doublebuffer := _HMG_aControlMiscData1 [k,24]

   IF ownerdata
      LISTVIEW_SETITEMCOUNT ( ControlHandle , itemcount )
   ENDIF

   SendMessage( ControlHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, iif( nogrid, 0, LVS_EX_GRIDLINES ) + iif( doublebuffer, LVS_EX_DOUBLEBUFFER, 0 ) + ;
      LVS_EX_FULLROWSELECT + LVS_EX_INFOTIP + iif( lockcolumns > 0, 0, LVS_EX_HEADERDRAGDROP ) + iif( lcheckboxes, LVS_EX_CHECKBOXES, 0 ) )

   IF ValType ( backcolor ) != 'U'
      ListView_SetBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
      ListView_SetTextBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
   ENDIF

   IF ValType ( fontcolor ) != 'U'
      ListView_SetTextColor ( ControlHandle , fontcolor[1] , fontcolor[2] , fontcolor[3] )
   ENDIF

   wBitmap := iif ( Len( _HMG_aControlBkColor [k] ) > 0, AddListViewBitmap( ControlHandle, _HMG_aControlBkColor [k] ), 0 ) // Add Bitmap Column
   aWidths[ 1 ] := Max ( aWidths[ 1 ], wBitmap + 2 ) // Set Column 1 width to Bitmap width

   InitListViewColumns ( ControlHandle , _HMG_aControlCaption [k] , aWidths , aJust )

   AEval ( aRows , { | r | _AddGridRow ( ControlName , ParentName , r ) } )

   IF multiselect

      IF ISARRAY ( Value )
         ListViewSetMultiSel ( ControlHandle, Value )
      ENDIF

   ELSE

      row := iif ( ISARRAY ( value ), value [1], value )
      IF row <> 0
         _SetValue ( , , Value , k )
      ENDIF

   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

   _UpdateGridColors ( k )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddGridRow ( ControlName, ParentForm, aRow )
*-----------------------------------------------------------------------------*
   LOCAL i, h, iIm := 0, aGridRow := AClone ( aRow )

   i := GetControlIndex ( ControlName , ParentForm )

   IF Len ( _HMG_aControlPageMap [i] ) != Len ( aRow )
      MsgMiniGuiError ( "Grid.AddItem: Item size mismatch." )
   ENDIF

   IF Len( _HMG_aControlBkColor [i] ) > 0
      iIm := aGridRow [1]
      aGridRow [1] := NIL
   ENDIF

   h := GetControlHandle ( ControlName , ParentForm )

   AddListViewItems ( h , aGridRow , iIm )

   IF ValType ( _HMG_aControlMiscData1 [i] [13] ) == 'A'
      _SetItem ( ControlName , ParentForm , ListViewGetItemCount ( h ) , aGridRow )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE HMG_SortColumn( nColumnNo )
*-----------------------------------------------------------------------------*
   LOCAL cFormName := ThisWindow.Name
   LOCAL cControlName := This.Name
   LOCAL ix := GetControlIndex( cControlName, cFormName )
   LOCAL i, nOrder, lAscend, nCount, aImages, aItems := {}

   nOrder := _HMG_aControlRangeMax [ix] [nColumnNo]

   IF nOrder > 0
      _EnableListViewUpdate( cControlName , cFormName , .F. )

      aImages := Array( Len( _HMG_aControlRangeMax [ix] ) )
      nCount := GetProperty( cFormName , cControlName , 'ItemCount' )

      FOR i := 1 TO nCount
         AAdd( aItems , GetProperty( cFormName , cControlName , 'Item' , i ) )
      NEXT i

      lAscend := ( nOrder < 2 )
      IF lAscend
         ASort( aItems, , , { | x, y | x[ nColumnNo ] < y[ nColumnNo ] })
      ELSE
         ASort( aItems, , , { | x, y | x[ nColumnNo ] > y[ nColumnNo ] })
      ENDIF

      DoMethod( cFormName , cControlName , 'DeleteAllItems' )

      AEval( aItems, { | x | DoMethod( cFormName , cControlName , 'AddItem' , x ) } )

      AEval( aImages, { | x, i | aImages[ i ] := HDR_IMAGE_NONE, HB_SYMBOL_UNUSED( x ) } )

      aImages[ nColumnNo ] := iif( lAscend, HDR_IMAGE_ASCENDING, HDR_IMAGE_DESCENDING )

      AEval( aImages, { | n, i | _SetMultiImage( cControlName, cFormName, i, n, ( _HMG_aControlMiscData1 [ix][3][i] == 1 ) ) } )

      _HMG_aControlRangeMax [ix] [nColumnNo] := iif( lAscend, nOrder + 1, 1 )

      _EnableListViewUpdate( cControlName , cFormName , .T. )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _EditItem ( GridHandle )
*-----------------------------------------------------------------------------*
   LOCAL a, l, g, IRow, actpos := { 0, 0, 0, 0 }, h := GridHandle
   LOCAL GRow, GCol, GWidth, Col, LN, TN, i, ControlName, j, FormName, item

   _HMG_ActiveFormNameBak := _HMG_ActiveFormName

   i := AScan ( _HMG_aControlHandles , GridHandle )

   a := _HMG_aControlPageMap [i]
   ControlName := _HMG_aControlNames [i]

   j := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [ i ] )

   FormName := _HMG_aFormNames [ j ]

   item := _GetValue ( ControlName , FormName )

   l := Len( a )

   g := _GetItem ( ControlName , FormName , Item )

   IRow := ListViewGetItemRow ( h, Item )

   GetWindowRect ( h, actpos )

   GRow   := actpos [2] + IRow / 2
   GCol   := actpos [1]
   GWidth := actpos [3] - actpos [1]

   Col := GCol + ( ( GWidth - 260 ) / 2 )

   DEFINE WINDOW _EditItem;
      AT GRow, Col;
      WIDTH 260;
      HEIGHT ( l * 30 ) + 70 + GetTitleHeight();
      TITLE _HMG_MESSAGE [5];
      MODAL;
      NOSIZE

      FOR i := 1 TO l
         LN := 'Label_' + hb_ntos( i )
         TN := 'Text_' + hb_ntos( i )
         @ ( i * 30 ) - 17 , 10 LABEL &LN OF _EditItem VALUE AllTrim( a[i] ) + ":"
         @ ( i * 30 ) - 20 , 120 TEXTBOX &TN OF _EditItem VALUE g[i]
      NEXT i

      @ ( l * 30 ) + 20 , 20 BUTTON BUTTON_1;
         OF _EDITITEM;
         CAPTION _HMG_MESSAGE [6];
         ACTION { || _EditItemOk ( ControlName , FormName , Item , l ) }

      @ ( l * 30 ) + 20 , 130 BUTTON BUTTON_2;
         OF _EDITITEM;
         CAPTION _HMG_MESSAGE [7];
         ACTION _EditItem.Release

   END WINDOW

   _SetFocus ( 'Text_1', '_EditItem' )

   ACTIVATE WINDOW _EditItem

   _HMG_ActiveFormName := _HMG_ActiveFormNameBak

   _SetFocus( ControlName , FormName )

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _EditItemOk ( ControlName , FormName , Item , l )
*-----------------------------------------------------------------------------*
   LOCAL a := Array( l )

   AEval( a , { | x, i | HB_SYMBOL_UNUSED( x ) , a [i] := GetProperty ( '_EditItem' , 'Text_' + hb_ntos( i ) , 'Value' ) } )

   _SetItem( ControlName , FormName , Item , a )

   _EditItem.Release

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _AddGridColumn ( cControlName , cParentForm , nColIndex , cCaption , nWidth , nJustify )
*-----------------------------------------------------------------------------*
   LOCAL atemp As Array, atemp2 As Array
   LOCAL i , x

   // Get Control Index
   i := GetControlIndex ( cControlName , cParentForm )

   // Set Default Values
   hb_default( @nColIndex, Len ( _HMG_aControlPageMap [i] ) + 1 )
   __defaultNIL( @cCaption, "" )
   hb_default( @nWidth, 120 )
   hb_default( @nJustify, 0 )

   // Update Grid Object
   FOR x := 1 TO nColIndex - 1
      AAdd ( atemp , _HMG_aControlPageMap [i] [x] )
      AAdd ( atemp2, _HMG_aControlMiscData1 [i] [3] [x] )
   NEXT x

   AAdd ( atemp , cCaption )
   AAdd ( atemp2, nJustify )

   FOR x := nColIndex + 1 TO Len ( _HMG_aControlPageMap [i] ) + 1
      AAdd ( atemp , _HMG_aControlPageMap [i] [x-1] )
      AAdd ( atemp2, _HMG_aControlMiscData1 [i] [3] [x-1] )
   NEXT x

   _HMG_aControlPageMap [i] := atemp
   _HMG_aControlCaption [i] := atemp
   _HMG_aControlMiscData1 [i] [3] := atemp2

   // Call C-Level Routine
   ListView_AddColumn( _HMG_aControlHandles [i] , nColIndex , nWidth , cCaption , nJustify )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DeleteGridColumn ( cControlName , cParentForm , nColIndex )
*-----------------------------------------------------------------------------*
   LOCAL atemp As Array, atemp2 As Array
   LOCAL i , x

   // Get Control Index
   i := GetControlIndex ( cControlName , cParentForm )

   // Update Grid Object
   FOR x := 1 TO nColIndex - 1
      AAdd ( atemp , _HMG_aControlPageMap [i] [x] )
      AAdd ( atemp2, _HMG_aControlMiscData1 [i] [3] [x] )
   NEXT x

   FOR x := nColIndex + 1 TO Len ( _HMG_aControlPageMap [i] )
      AAdd ( atemp , _HMG_aControlPageMap [i] [x] )
      AAdd ( atemp2, _HMG_aControlMiscData1 [i] [3] [x] )
   NEXT x

   _HMG_aControlPageMap [i] := atemp
   _HMG_aControlCaption [i] := atemp
   _HMG_aControlMiscData1 [i] [3] := atemp2

   // Call C-Level Routine
   ListView_DeleteColumn ( _HMG_aControlHandles [i] , nColIndex )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _UpdateGridColors ( i )
*-----------------------------------------------------------------------------*
   LOCAL dBc := _HMG_aControlMiscData1 [i, 12]
   LOCAL dFc := _HMG_aControlMiscData1 [i, 11]
   LOCAL processdbc := ISARRAY ( dbc ) , processdfc := ISARRAY ( dfc )
   LOCAL Cols , Rows

   IF processdbc .OR. processdfc

      Rows := ListViewGetItemCount ( _HMG_aControlHandles [i] )
      Cols := ListView_GetColumnCount ( _HMG_aControlHandles [i] )

      IF processdbc
         ProcessDynamicArray ( i , Rows , Cols , dBc , 22 )
      ENDIF

      IF processdfc
         ProcessDynamicArray ( i , Rows , Cols , dFc , 21 )
      ENDIF

   ENDIF

   ReDrawWindow ( _HMG_aControlHandles [i] )

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE ProcessDynamicArray ( i , Rows , Cols , Arr , item )
*-----------------------------------------------------------------------------*
   LOCAL r , c
   LOCAL aValues , aTemp

   aTemp := Array ( Rows , Cols )

   FOR r := 1 TO Rows

      IF _HMG_aControlMiscData1 [ i ] [ 5 ] == .T.

         aValues := _GetIVirtualItem ( r , i , Cols )

      ELSE

         aValues := _GetItem ( , , r , i )

      ENDIF

      FOR c := 1 TO Cols

         _HMG_ThisItemRowIndex := r
         _HMG_ThisItemColIndex := c

         _HMG_ThisItemCellValue := aValues [c]

         aTemp [r] [c] := iif( ValType ( Arr [c] ) == 'B', _tEval ( Arr [c] , aValues , r ) , -1 )

      NEXT c

   NEXT r

   _HMG_aControlMiscData1 [i, item] := aTemp

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _tEval ( bBlock , Par1 , Par2 )
*-----------------------------------------------------------------------------*
   LOCAL tEval := Eval ( bBlock , Par1 , Par2 )

   IF ValType ( TEVAL ) == 'A' .AND. Len ( TEVAL ) == 3
      TEVAL := RGB ( TEVAL [1] , TEVAL [2] , TEVAL [3] )
   ENDIF

RETURN IFNUMERIC( tEval, tEval, 0 )

*-----------------------------------------------------------------------------*
FUNCTION _GridInplaceEdit( idx )
*-----------------------------------------------------------------------------*
   LOCAL r , c , v, h , aTemp , ri , ci , DH := 0 , DR := 0
   LOCAL FormName := '_hmg_grid_inplaceedit'
   LOCAL AEDITCONTROLS
   LOCAL AEC := 'TEXTBOX'
   LOCAL AITEMS
   LOCAL ARANGE
   LOCAL DTYPE
   LOCAL ALABELS := { '.T.' , '.F.' }
   LOCAL CTYPE
   LOCAL CINPUTMASK
   LOCAL CFORMAT
   LOCAL XRES
   LOCAL CWH, WHEN, abKeyBlocks := {}

   IF _HMG_ThisEventType == 'GRID_WHEN'
      MsgMiniGuiError( "GRID: Editing within WHEN event procedure is not allowed." )
   ELSEIF _HMG_ThisEventType == 'GRID_VALID'
      MsgMiniGuiError( "GRID: Editing within VALID event procedure is not allowed." )
   ENDIF

   IF _HMG_aControlFontColor [ idx ] == .T.
      IF This.CellRowIndex != _HMG_aControlMiscData1 [ idx ] [ 1 ]
         RETURN .F.
      ENDIF
   ELSE
      IF This.CellRowIndex != LISTVIEW_GETFIRSTITEM ( _hmg_acontrolhandles [ idx ] )
         RETURN .F.
      ENDIF
   ENDIF

   ri := This.CellRowIndex
   ci := This.CellColIndex

   IF ri == 0 .OR. ci == 0
      RETURN .F.
   ENDIF

   IF _HMG_aControlMiscData1 [ idx ] [ 5 ] == .F.

      aTemp := This.Item( ri )

      v := aTemp [ci]

   ELSE

      _HMG_ThisQueryRowIndex  := ri
      _HMG_ThisQueryColIndex  := ci

      Eval( _HMG_aControlProcedures [idx] )

      v := _HMG_ThisQueryData

   ENDIF

   CWH := _HMG_aControlMiscData1 [idx] [15]

   IF ValType ( CWH ) == 'A' .AND. Len ( CWH ) >= ci

      IF ValType ( CWH [ci] ) == 'B'

         _HMG_ThisItemCellValue := v

         _HMG_ThisEventType := 'GRID_WHEN'
         WHEN := Eval ( CWH [ci] )
         _HMG_ThisEventType := ''

         IF WHEN == .F.
            _HMG_IPE_CANCELLED := .F.
            RETURN .F.
         ENDIF

      ENDIF

   ENDIF

   h := _HMG_aControlHandles [idx]

   r := This.CellRow + GetWindowRow ( h ) - This.Row - 1

   IF _HMG_aControlContainerRow  [idx] <> -1
      r -= _HMG_aControlContainerRow [idx]
   ENDIF

   c := This.CellCol + GetWindowCol ( h ) - This.Col + 2

   IF _HMG_aControlContainerCol [idx] <> -1
      c -= _HMG_aControlContainerCol [idx]
   ENDIF

   aEditControls := _HMG_aControlMiscData1 [idx] [13]

   XRES := _ParseGridControls ( aEditControls , ci , ri )

   AEC        := XRES [1]
   CTYPE      := XRES [2]
   CINPUTMASK := XRES [3]
   CFORMAT    := XRES [4]
   AITEMS     := XRES [5]
   ARANGE     := XRES [6]
   DTYPE      := XRES [7]
   ALABELS    := XRES [8]

   IF AEC == 'COMBOBOX'
      DH := 1
   ELSEIF AEC == 'CHECKBOX'
      DR := 3
      DH := -7
   ENDIF

   _HMG_InplaceParentHandle := GetActiveWindow()

   DEFINE WINDOW _hmg_grid_inplaceedit AT r + DR , c ;
      WIDTH This.CellWidth ;
      HEIGHT This.CellHeight + 6 + DH ;
      TITLE '' MODAL ;
      NOSIZE ;
      NOCAPTION

   ON KEY ESCAPE ACTION ( _HMG_IPE_CANCELLED := .T. , ThisWindow.Release )
   ON KEY RETURN ACTION iif ( _IsWindowActive ( FormName ) , ( _HMG_IPE_CANCELLED := .F. , _GridInplaceEditOK ( IDX , CI , RI , AEC ) ) , NIL )
   ON KEY TAB    ACTION ( _lTabKeyPressed := .T. , InsertReturn() )

   IF AEC == 'TEXTBOX'

      DEFINE TEXTBOX T
        ROW      0
        COL      0
        WIDTH    This.CellWidth
        HEIGHT   This.CellHeight + 6

        IF CTYPE == 'NUMERIC'
           NUMERIC .T.
        ELSEIF CTYPE == 'DATE'
           DATE .T.
        ENDIF

        VALUE    v
        FONTNAME _hmg_aControlFontName [idx]
        FONTSIZE _hmg_aControlFontSize [idx]

        IF ! Empty ( CINPUTMASK )
           INPUTMASK CINPUTMASK
        ENDIF

        IF ! Empty ( CFORMAT )
           FORMAT CFORMAT
        ENDIF

      END TEXTBOX

      IF Empty ( CINPUTMASK ) .AND. Empty ( CFORMAT )
         _SetFocus ( 't' , '_hmg_grid_inplaceedit' )
      ENDIF

   ELSEIF AEC == 'DATEPICKER'

      DEFINE DATEPICKER D
        ROW      0
        COL      0
        WIDTH    This.CellWidth
        HEIGHT   This.CellHeight + 6
        VALUE    v
        SHOWNONE .T.

        FONTNAME _hmg_aControlFontName [idx]
        FONTSIZE _hmg_aControlFontSize [idx]

        IF DTYPE == 'DROPDOWN'
           UPDOWN .F.
        ELSEIF DTYPE == 'UPDOWN'
           UPDOWN .T.
        ENDIF

      END DATEPICKER

   ELSEIF AEC == 'COMBOBOX'

      DEFINE COMBOBOX C
        ROW      0
        COL      0
        WIDTH    This.CellWidth
        ITEMS    AITEMS
        VALUE    v
        FONTNAME _hmg_aControlFontName [idx]
        FONTSIZE _hmg_aControlFontSize [idx]
        ON LISTDISPLAY ( AAdd( abKeyBlocks, _GetHotKeyBlock ( FormName, 0, 27 ) ), ;
           _ReleaseHotKey ( FormName, 0, 27 ), ;
           AAdd( abKeyBlocks, _GetHotKeyBlock ( FormName, 0, 13 ) ), ;
           _ReleaseHotKey ( FormName, 0, 13 ) )
        ON LISTCLOSE ( _DefineHotKey( FormName, 0, 27, abKeyBlocks[1] ), ;
           _DefineHotKey( FormName, 0, 13, abKeyBlocks[2] ), abKeyBlocks := {} )
      END COMBOBOX

   ELSEIF AEC == 'SPINNER'

      DEFINE SPINNER S
        ROW       0
        COL       0
        WIDTH     This.CellWidth
        HEIGHT    This.CellHeight + 6
        VALUE     v
        RANGEMIN  ARANGE [1]
        RANGEMAX  ARANGE [2]
        INCREMENT ARANGE [3]
        FONTNAME _hmg_aControlFontName [idx]
        FONTSIZE _hmg_aControlFontSize [idx]
      END SPINNER

   ELSEIF AEC == 'CHECKBOX'

      DEFINE CHECKBOX C
        ROW       0
        COL       0
        WIDTH     This.CellWidth
        HEIGHT    This.CellHeight + 6 + DH
        VALUE     v
        FONTNAME _hmg_aControlFontName [idx]
        FONTSIZE _hmg_aControlFontSize [idx]
        CAPTION   ALABELS [ iif ( V == .T., 1, 2 ) ]
        BACKCOLOR WHITE
        ON CHANGE This.Caption := ALABELS [ iif ( This.Value == .T., 1, 2 ) ]
      END CHECKBOX

   ENDIF

   END WINDOW

   ACTIVATE WINDOW _hmg_grid_inplaceedit

   _HMG_InplaceParentHandle := 0

   SetFocus( _HMG_aControlHandles [idx] )

RETURN .T.

*-----------------------------------------------------------------------------*
FUNCTION _ParseGridControls ( aEditControls , ci , ri )
*-----------------------------------------------------------------------------*
   LOCAL AEC := 'TEXTBOX'
   LOCAL AITEMS := {}
   LOCAL ARANGE := {}
   LOCAL DTYPE := 'D'
   LOCAL ALABELS := { '.T.' , '.F.' }
   LOCAL CTYPE := 'CHARACTER'
   LOCAL CINPUTMASK := ''
   LOCAL CFORMAT := ''
   LOCAL aEdit

   IF ValType( aEditControls ) == 'A'

      IF Len( aEditControls ) >= ci

         IF ValType( aEditControls [ci] ) == 'A'

            IF Len( aEditControls [ci] ) >= 1

               AEC := Upper( aEditControls [ci] [1] )

               // check for a new type control defined as { 'DYNAMIC', {|r,c| CodeBlock_Return_Control_Array} }
               IF Len( aEditControls [ci] ) == 2 .AND. AEC == 'DYNAMIC'
                  aEdit := Eval( aEditControls [ci] [2] , ri , ci )
                  IF ValType( aEdit ) == "A" .AND. Len( aEdit ) >= 1
                     AEC := aEdit [1]    // get normal type for this cell
                  ELSE
                     AEC := 'TEXTBOX'    // default
                     aEdit := {}         // set as array
                  ENDIF
               ELSE
                  aEdit := aEditControls [ci]
               ENDIF

               IF Len( aEdit ) >= 2 .AND. AEC == 'TEXTBOX'

                  IF ValType( AEDIT [2] ) == 'C'
                     CTYPE := Upper( AEDIT [2] )
                  ENDIF

                  IF Len( AEDIT ) >= 3
                     IF ValType( AEDIT [3] ) == 'C'
                        CINPUTMASK := AEDIT [3]
                     ENDIF
                  ENDIF

                  IF Len( AEDIT ) >= 4
                     IF ValType( AEDIT [4] ) == 'C'
                        CFORMAT := AEDIT [4]
                     ENDIF
                  ENDIF

               ENDIF

               IF Len( aEdit ) >= 2 .AND. AEC == 'COMBOBOX'
                  IF ValType( AEDIT [2] ) == 'A'
                     AITEMS := AEDIT [2]
                  ENDIF
               ENDIF

               IF Len( aEdit ) >= 3 .AND. AEC == 'SPINNER'
                  IF Len( aEdit ) == 3 .AND. ;
                     ValType( AEDIT [2] ) == 'N' .AND. ;
                     ValType( AEDIT [3] ) == 'N'
                     ARANGE := { AEDIT [2] , AEDIT [3] , 1 }
                  ELSEIF ValType( AEDIT [2] ) == 'N' .AND. ;
                     ValType( AEDIT [3] ) == 'N' .AND. ;
                     ValType( AEDIT [4] ) == 'N'
                     ARANGE := { AEDIT [2] , AEDIT [3] , AEDIT [4] }
                  ENDIF
               ENDIF

               IF Len( aEdit ) >= 2 .AND. AEC == 'DATEPICKER'
                  IF ValType( AEDIT [2] ) == 'C'
                     DTYPE := Upper( AEDIT [2] )
                  ENDIF
               ENDIF

               IF Len( aEdit ) == 3 .AND. AEC == 'CHECKBOX'
                  IF ValType( AEDIT [2] ) == 'C' .AND. ;
                     ValType( AEDIT [3] ) == 'C'
                     ALABELS := { AEDIT [2] , AEDIT [3] }
                  ENDIF
               ENDIF

            ENDIF

         ENDIF

      ENDIF

   ENDIF

RETURN { AEC , CTYPE , CINPUTMASK , CFORMAT , AITEMS , ARANGE , DTYPE , ALABELS }

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _GridInplaceEditOK ( idx , ci , ri , aec )
*-----------------------------------------------------------------------------*
   LOCAL CVA , VALID , aValidMessages , aTemp , Cols , z

   CVA := _HMG_aControlMiscData1 [idx] [14]

   IF ValType ( CVA ) == 'A' .AND. Len ( CVA ) >= ci

      IF ValType ( CVA [ci] ) == 'B'

         _HMG_ThisItemCellValue := GetProperty ( "_hmg_grid_inplaceedit", Left ( AEC, 1 ), "value" )

         _HMG_ThisFormName := _HMG_aFormNames [ Ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles [idx] ) ]
         _HMG_ThisEventType := 'GRID_VALID'

         VALID := Eval ( CVA [ci] )

         _HMG_ThisEventType := ''
         _HMG_ThisFormName := _HMG_aFormNames [ _HMG_ThisFormIndex ]

         IF ISLOGICAL( VALID ) .AND. VALID == .F.

            aValidMessages := _HMG_aControlMiscData1 [idx] [16]

            IF ValType ( aValidMessages ) == 'A'

               IF ValType ( aValidMessages [ci] ) == 'C'

                  MsgAlert ( aValidMessages [ci] , _HMG_BRWLangError [10] )

               ELSEIF ValType ( aValidMessages [ci] ) == 'B'

                  Eval ( aValidMessages [ci], _HMG_ThisItemCellValue )

               ELSE

                  MsgAlert ( _HMG_BRWLangError [11] , _HMG_BRWLangError [10] )

               ENDIF

            ELSE

               MsgAlert ( _HMG_BRWLangError [11] , _HMG_BRWLangError [10] )

            ENDIF

            RETURN

         ENDIF

         ReDrawWindow ( _HMG_aControlHandles [idx] )

      ENDIF

   ENDIF

   IF _HMG_aControlMiscData1 [idx] [5] == .F.

      aTemp := _GetItem ( , , ri , idx )

   ELSE

      Cols := ListView_GetColumnCount ( _HMG_aControlHandles [idx] )

      aTemp := AFill ( Array ( Cols ) , '' )

      FOR z := 1 TO Cols
         _HMG_ThisQueryRowIndex  := ri
         _HMG_ThisQueryColIndex  := z

         Eval( _HMG_aControlProcedures [idx] )

         aTemp [z] := _HMG_ThisQueryData
      NEXT

   ENDIF

   aTemp [ci] := GetProperty ( "_hmg_grid_inplaceedit", Left ( AEC, 1 ), "value" )

   IF _HMG_aControlMiscData1 [ idx ] [ 5 ] == .F.
      _SetItem ( , , ri , aTemp , idx )
   ENDIF

   _hmg_grid_inplaceedit.Release

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetGridCellEditValue ( arg )
*-----------------------------------------------------------------------------*
   LOCAL FormName := "_hmg_grid_inplaceedit"
   LOCAL ControlName

   SWITCH ValType ( arg )

   CASE 'C'
      ControlName := iif( _IsControlDefined ( "t" , FormName ) .AND. ;
         !( ValType ( _GetValue ( "t" , FormName ) ) == "N" ) , "t" , Nil )
      EXIT

   CASE 'D'
      ControlName := iif( _IsControlDefined ( "d" , FormName ), "d" , ;
         iif( _IsControlDefined ( "t" , FormName ) , "t" , Nil ) )
      EXIT

   CASE 'N'
      ControlName := iif( _IsControlDefined ( "c" , FormName ), "c" , ;
         iif( _IsControlDefined ( "s" , FormName ) , "s" , ;
         iif( _IsControlDefined ( "t" , FormName ) , "t" , Nil ) ) )
      EXIT

   CASE 'L'
      ControlName := iif( _IsControlDefined ( "c" , FormName ) , "c" , Nil )

   END SWITCH

   IF ISCHARACTER( ControlName )
      SetProperty ( FormName , ControlName , "value" , arg )
   ELSE
      MsgMiniGuiError ( "CellValue replace: type mismatch." )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridInplaceKbdEdit( i )
*-----------------------------------------------------------------------------*
   LOCAL H := _HMG_aControlHandles [i]
   LOCAL IPE_MAXCOL := ListView_GetColumnCount ( h )
   LOCAL TmpRow
   LOCAL XS
   LOCAL XD
   LOCAL R

   DO WHILE .T.

      TmpRow := LISTVIEW_GETFIRSTITEM ( h )

      IF TmpRow != _HMG_IPE_ROW

         _HMG_IPE_ROW := TmpRow
         _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

      ENDIF

      _HMG_ThisItemRowIndex := _HMG_IPE_ROW
      _HMG_ThisItemColIndex := _HMG_IPE_COL

      IF _HMG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( h , _HMG_IPE_ROW - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( h , _HMG_IPE_ROW - 1 , _HMG_IPE_COL - 1 )
      ENDIF

      xs := ( _HMG_aControlCol [i] + r [2] + r [3] ) - ( _HMG_aControlCol [i] + _HMG_aControlWidth [i] )

      xd := 20

      IF xs > - xd
         ListView_Scroll( h , xs + xd , 0 )
      ELSE
         IF r [2] < 0
            ListView_Scroll( h , r[2] , 0 )
         ENDIF
      ENDIF

      IF _HMG_IPE_COL == 1
         r := LISTVIEW_GETITEMRECT ( h , _HMG_IPE_ROW - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( h , _HMG_IPE_ROW - 1 , _HMG_IPE_COL - 1 )
      ENDIF

      _HMG_ThisItemCellRow := IFNUMERIC( _HMG_aControlRow [i] , _HMG_aControlRow [i] , 0 ) + r [1]
      _HMG_ThisItemCellCol := IFNUMERIC( _HMG_aControlCol [i] , _HMG_aControlCol [i] , 0 ) + r [2]
      _HMG_ThisItemCellWidth := r[3]
      _HMG_ThisItemCellHeight := r[4]

      _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [i] )
      _HMG_ThisType := 'C'
      _HMG_ThisIndex := i

      _HMG_ThisFormName := _HMG_aFormNames [ _HMG_ThisFormIndex ]
      _HMG_ThisControlName := _HMG_aControlNames [ _HMG_ThisIndex ]

      _GridInplaceEdit( i )

      _HMG_ThisIndex := 0
      _HMG_ThisType := ''

      _HMG_ThisItemRowIndex := 0
      _HMG_ThisItemColIndex := 0
      _HMG_ThisItemCellRow := 0
      _HMG_ThisItemCellCol := 0
      _HMG_ThisItemCellWidth := 0
      _HMG_ThisItemCellHeight := 0

      _HMG_ThisFormIndex := 0
      _HMG_ThisEventType := ''
      _HMG_ThisFormName :=  ''
      _HMG_ThisControlName := ''

      IF _HMG_IPE_CANCELLED == .T.

         IF _HMG_IPE_COL == IPE_MAXCOL

            _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

            ListView_Scroll( h , -10000 , 0 )

         ENDIF

         EXIT

      ELSE

         _HMG_IPE_COL++

         IF _HMG_IPE_COL > IPE_MAXCOL

            _HMG_IPE_COL := iif( Len ( _HMG_aControlBkColor [i] ) > 0, 2, 1 )

            ListView_Scroll( h , -10000 , 0 )

            EXIT

         ENDIF

      ENDIF

   ENDDO

RETURN

*-----------------------------------------------------------------------------*
FUNCTION GetNumFromCellText ( Text )
*-----------------------------------------------------------------------------*
   LOCAL s As String
   LOCAL x , c

   FOR x := 1 TO Len ( Text )

      c := SubStr ( Text, x, 1 )

      IF c = '0' .OR. c = '1' .OR. c = '2' .OR. c = '3' .OR. c = '4' .OR. c = '5' .OR. c = '6' .OR. c = '7' .OR. c = '8' .OR. c = '9' .OR. c = '.' .OR. c = '-'
         s += c
      ENDIF

   NEXT x

   IF Left ( AllTrim( Text ) , 1 ) == '(' .OR.  Right ( AllTrim( Text ) , 2 ) == 'DB'
      s := '-' + s
   ENDIF

RETURN Val( s )

*-----------------------------------------------------------------------------*
FUNCTION GETNumFromCellTextSP ( Text )
*-----------------------------------------------------------------------------*
   LOCAL s As String
   LOCAL x , c

   FOR x := 1 TO Len ( Text )

      c := SubStr ( Text, x, 1 )

      IF c = '0' .OR. c = '1' .OR. c = '2' .OR. c = '3' .OR. c = '4' .OR. c = '5' .OR. c = '6' .OR. c = '7' .OR. c = '8' .OR. c = '9' .OR. c = ',' .OR. c = '-' .OR. c = '.'

         IF c == '.'
            c := ''
         ENDIF

         IF c == ','
            c := '.'
         ENDIF

         s += c

      ENDIF

   NEXT x

   IF Left ( AllTrim( Text ) , 1 ) == '(' .OR.  Right ( AllTrim( Text ) , 2 ) == 'DB'
      s := '-' + s
   ENDIF

RETURN Val( s )

*-----------------------------------------------------------------------------*
FUNCTION _GetGridCellValue ( ControlName , ParentForm , Row , Col )
*-----------------------------------------------------------------------------*
   LOCAL A := _GetItem ( ControlName , ParentForm , Row )

RETURN iif( Col > 0 .AND. Col <= Len( A ), A [ COL ], NIL )

*-----------------------------------------------------------------------------*
PROCEDURE _SetGridCellValue ( ControlName , ParentForm , Row , Col , CellValue )
*-----------------------------------------------------------------------------*
   LOCAL A := _GetItem ( ControlName , ParentForm , Row )

   IF Col > 0 .AND. Col <= Len( A )

      A [ Col ] := CellValue

      _SetItem ( ControlName , ParentForm , Row , A )

   ENDIF

RETURN

// (JK) HMG 1.0 Experimental Build 6
/*
   _GetColumnWidth( ControlName , ParentForm, nColumnNo )->nColumnWidth

   _SetColumnWidth( ControlName , ParentForm, nColumnNo ,nWidth )->lSuccess

   _SetColumnWidthAuto( ControlName , ParentForm, nColumnNo )->lSuccess
   - Autofit column width to largest grid item width in column nColumnNo

   _SetColumnWidthAutoH( ControlName , ParentForm, nColumnNo )->lSuccess
   - Autofit column width to largest grid header width in column nColumnNo

   _SetColumnsWidthAuto( ControlName , ParentForm )
   - Autofit all columns width to largest grid item width in column

   _SetColumnsWidthAutoH( ControlName , ParentForm )
   - Autofit all columns width to largest grid header width in column
*/
*-----------------------------------------------------------------------------*
FUNCTION _GetColumnWidth( ControlName , ParentForm, nColumnNo )
*-----------------------------------------------------------------------------*
   LOCAL z As Numeric
   LOCAL nWidth := -1, i

   i := GetControlIndex( ControlName , ParentForm )

   Assign z := nColumnNo

   IF z > 0 .AND. z <= ListView_GetColumnCount ( _HMG_aControlHandles [i] )
      nWidth := ListView_GetColumnWidth( _HMG_aControlHandles [i] , z - 1 )
   ENDIF

RETURN nWidth

*-----------------------------------------------------------------------------*
FUNCTION _SetColumnWidth( ControlName , ParentForm , nColumnNo , nWidth )
*-----------------------------------------------------------------------------*
   LOCAL z As Numeric
   LOCAL i, lSuccess := .F.

   i := GetControlIndex( ControlName , ParentForm )

   Assign z := nColumnNo

   IF z > 0 .AND. z <= ListView_GetColumnCount ( _HMG_aControlHandles [i] )
      lSuccess := ListView_SetColumnWidth( _HMG_aControlHandles [i] , z - 1 , nWidth )
   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
FUNCTION _SetColumnWidthAuto( ControlName , ParentForm , nColumnNo )
*-----------------------------------------------------------------------------*
   LOCAL z As Numeric
   LOCAL i, lSuccess := .F.

   i := GetControlIndex( ControlName , ParentForm )

   Assign z := nColumnNo

   IF z > 0 .AND. z <= ListView_GetColumnCount ( _HMG_aControlHandles [i] )
      lSuccess := ListView_SetColumnWidthAuto( _HMG_aControlHandles [i] , z - 1 )
   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
FUNCTION _SetColumnWidthAutoH( ControlName , ParentForm , nColumnNo )
*-----------------------------------------------------------------------------*
   LOCAL z As Numeric
   LOCAL i, lSuccess := .F.

   i := GetControlIndex( ControlName , ParentForm )

   Assign z := nColumnNo

   IF z > 0 .AND. z <= ListView_GetColumnCount ( _HMG_aControlHandles [i] )
      lSuccess := ListView_SetColumnWidthAutoH( _HMG_aControlHandles [i] , z - 1 )
   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
FUNCTION _SetColumnsWidthAuto( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL z, i, ColumnCount, lSuccess := .F.

   i := GetControlIndex( ControlName , ParentForm )
   ColumnCount := ListView_GetColumnCount( _HMG_aControlHandles [i] )

   IF ColumnCount > 0
      FOR z := 1 TO ColumnCount
         lSuccess := ListView_SetColumnWidthAuto( _HMG_aControlHandles [i] , z - 1 )
      NEXT z
   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
FUNCTION _SetColumnsWidthAutoH( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL z, i, ColumnCount, lSuccess := .F.

   i := GetControlIndex ( ControlName , ParentForm )
   ColumnCount := ListView_GetColumnCount( _HMG_aControlHandles [i] )

   IF ColumnCount > 0
      FOR z := 1 TO ColumnCount
         lSuccess := ListView_SetColumnWidthAutoH( _HMG_aControlHandles [i] , z - 1 )
      NEXT z
   ENDIF

RETURN lSuccess

//(JP) HMG 1.4 Extended Build 40
*-----------------------------------------------------------------------------*
PROCEDURE _GridPgDn ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , PageLength , _DeltaScroll , s , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )
   PageLength   := LISTVIEWGETCOUNTPERPAGE ( GridHandle )
   IF s + PageLength <=  LISTVIEWGETITEMCOUNT( GridHandle )
      ListView_SetCursel ( GridHandle , s + PageLength )
      ListView_Scroll( GridHandle , 0 , _DeltaScroll[4] * PageLength )
   ELSE
      ListView_SetCursel ( GridHandle , LISTVIEWGETITEMCOUNT( GridHandle ) )
      ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * ( LISTVIEWGETITEMCOUNT( GridHandle ) - s ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridPgUp ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , PageLength , s , _DeltaScroll , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )
   PageLength   := LISTVIEWGETCOUNTPERPAGE ( GridHandle )

   IF s - PageLength >= 1
      ListView_SetCursel ( GridHandle , s - PageLength )
      ListView_Scroll( GridHandle , 0 , _DeltaScroll[4] * PageLength * ( -1 ) )
   ELSE
      ListView_SetCursel ( GridHandle , 1 )
      ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * s * ( -1 ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridHome ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , s , _DeltaScroll , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )

   ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * ( -1 ) * s )

   ListView_SetCursel ( GridHandle, 1 )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridEnd ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , s , _DeltaScroll , _BottomPos , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   _BottomPos   := LISTVIEWGETITEMCOUNT( GridHandle )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )

   ListView_Scroll( GridHandle , 0 , _DeltaScroll[4] * ( _BottomPos - s ) )

   ListView_SetCursel ( GridHandle, _BottomPos )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridPrior ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , s , TopInx , _DeltaScroll , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   TopInx       := LISTVIEW_GETTOPINDEX ( GridHandle )

   s := LISTVIEW_GETFIRSTITEM ( GridHandle )
   ListView_SetCursel ( GridHandle , s - 1 )

   IF s <= TopInx + 1
      ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * ( -1 ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridNext ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i , PageLength , s , TopInx , _DeltaScroll , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )
   TopInx       := LISTVIEW_GETTOPINDEX ( GridHandle )
   PageLength   := LISTVIEWGETCOUNTPERPAGE ( GridHandle )
   ListView_SetCursel ( GridHandle , s + 1 )

   IF s - TopInx == PageLength
      ListView_Scroll( GridHandle, 0, _DeltaScroll[4] )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GridScrollToPos ( ControlName , ParentForm , z )
*-----------------------------------------------------------------------------*
   LOCAL i, s, TopInx, PageLength, _DeltaScroll , GridHandle

   i := iif( PCount() == 2, GetControlIndex ( ControlName , ParentForm ), z )

   GridHandle   := _HMG_aControlHandles [i]
   _DeltaScroll := ListView_GetSubItemRect ( GridHandle , 0 , 0 )
   s            := LISTVIEW_GETFIRSTITEM ( GridHandle )
   TopInx       := LISTVIEW_GETTOPINDEX ( GridHandle )
   PageLength   := LISTVIEWGETCOUNTPERPAGE ( GridHandle )
   IF topInx < s
      IF s - TopInx > PageLength
         ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * ( s - TopInx - PageLength ) )
      ENDIF
   ELSE
      ListView_Scroll( GridHandle, 0, _DeltaScroll[4] * ( -1 ) * ( s - TopInx ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _GetIVirtualItem ( nRow , i , nCols )
*-----------------------------------------------------------------------------*
   LOCAL aTemp := Array ( nCols )
   LOCAL j

   FOR j := 1 TO nCols

      _HMG_ThisQueryRowIndex := nRow

      _HMG_ThisQueryColIndex := j

      IF ValType ( _HMG_aControlProcedures [ i ] ) == 'B'

         Eval( _HMG_aControlProcedures [ i ] )   // OnQueryData Event

      ENDIF

      aTemp [j] := _HMG_ThisQueryData

   NEXT j

RETURN aTemp

*-----------------------------------------------------------------------------*
FUNCTION _DoGridCustomDraw ( i , a , lParam )
*-----------------------------------------------------------------------------*
   LOCAL aTemp
   LOCAL aTemp2

   IF a[1] >= 1 .AND. a[1] <= ListViewGetItemCount( _HMG_aControlHandles [i] ) .AND. ; // MaxGridRows
      a[2] >= 1 .AND. a[2] <= ListView_GetColumnCount ( _HMG_aControlHandles [i] )     // MaxGridCols
      aTemp  := _HMG_aControlMiscData1 [i, 22]
      aTemp2 := _HMG_aControlMiscData1 [i, 21]
      IF ValType ( aTemp ) == 'A' .AND. ValType ( aTemp2 ) <> 'A'
         IF Len ( aTemp ) >= a[1]
            IF aTemp [a[1]] [a[2]] <> -1
               RETURN SetBcFc ( lParam , aTemp [a[1]] [a[2]] , RGB( 0, 0, 0 ) )
            ELSE
               RETURN SETBRCCD( lParam )
            ENDIF
         ENDIF
      ELSEIF ValType ( aTemp ) <> 'A' .AND. ValType ( aTemp2 ) == 'A'
         IF Len ( aTemp2 ) >= a[1]
            IF aTemp2 [a[1]] [a[2]] <> -1
               RETURN SetBcFc ( lParam , RGB( 255, 255, 255 ) , aTemp2 [a[1]] [a[2]] )
            ELSE
               RETURN SETBRCCD( lParam )
            ENDIF
         ENDIF
      ELSEIF ValType ( aTemp ) == 'A' .AND. ValType ( aTemp2 ) == 'A'
         IF Len ( aTemp ) >= a[1] .AND. Len ( aTemp2 ) >= a[1]
            IF aTemp [a[1]] [a[2]] <> -1
               RETURN SetBcFc ( lParam , aTemp [a[1]] [a[2]] , aTemp2 [a[1]] [a[2]] )
            ELSE
               RETURN SETBRCCD( lParam )
            ENDIF
         ENDIF
      ENDIF
   ELSE
      RETURN SETBRCCD( lParam )
   ENDIF

RETURN 0

*-----------------------------------------------------------------------------*
PROCEDURE _GRIDINPLACEKBDEDIT_2( i )
*-----------------------------------------------------------------------------*
   LOCAL IPE_MAXCOL := ListView_GetColumnCount ( _HMG_aControlHandles [i] )
   LOCAL IPE_MAXROW := ListViewGetItemCount( _HMG_aControlHandles [i] )
   LOCAL ownerdata := _HMG_aControlMiscData1 [i] [5]
   LOCAL aColumnWhen := _HMG_aControlMiscData1 [i] [15]
   LOCAL r, nStart, nEnd, j, lResult, aTemp

   _GRID_KBDSCROLL( i )

   IF _HMG_ThisItemColIndex == 1
      r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i] , _HMG_ThisItemRowIndex - 1 )
   ELSE
      r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , _HMG_ThisItemRowIndex - 1 , _HMG_ThisItemColIndex - 1 )
   ENDIF

   _HMG_ThisItemCellRow := IFNUMERIC( _HMG_aControlRow [i] , _HMG_aControlRow [i] , 0 ) + r [1]
   _HMG_ThisItemCellCol := IFNUMERIC( _HMG_aControlCol [i] , _HMG_aControlCol [i] , 0 ) + r [2]
   _HMG_ThisItemCellWidth := r[3]
   _HMG_ThisItemCellHeight := r[4]

   _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [i] )
   _HMG_ThisType := 'C'
   _HMG_ThisIndex := i

   _HMG_ThisFormName := _HMG_aFormNames [ _HMG_ThisFormIndex ]
   _HMG_ThisControlName := _HMG_aControlNames [ _HMG_ThisIndex ]

   r := _GridInplaceEdit( i )

   IF _HMG_IPE_CANCELLED == .F.

      IF r == .T. .AND. _HMG_aControlMiscData1 [i] [19] == 0
         IF _HMG_aControlMiscData1 [i] [ 17 ] < IPE_MAXCOL
            IF !_lTabKeyPressed
               IF _HMG_GridNavigationMode
                  IF This.CellRowIndex < IPE_MAXROW
                     InsertDown()
                     InsertReturn()
                  ENDIF
               ELSE
                  _HMG_aControlMiscData1 [i] [ 17 ]++
               ENDIF
            ELSE
               _HMG_aControlMiscData1 [i] [ 17 ]++
               _lTabKeyPressed := .F.
               InsertReturn()
            ENDIF

            IF ValType ( aColumnWhen ) == 'A'
               IF ownerdata == .F.
                  aTemp := This.Item( This.CellRowIndex )
               ELSE
                  _HMG_ThisQueryRowIndex := This.CellRowIndex
               ENDIF
               nStart := _HMG_aControlMiscData1 [i] [ 17 ]
               nEnd := Len ( aColumnWhen )
               FOR j := nStart TO nEnd
                  IF ValType ( aColumnWhen [j] ) == 'B'
                     r := Min ( IPE_MAXCOL, j )
                     IF ownerdata == .F.
                        _HMG_ThisItemCellValue := aTemp [r]
                     ELSE
                        _HMG_ThisQueryColIndex  := r
                        Eval ( _HMG_aControlProcedures [i] )
                        _HMG_ThisItemCellValue := _HMG_ThisQueryData
                     ENDIF
                     _HMG_ThisEventType := 'GRID_WHEN'
                     lResult := Eval ( aColumnWhen [j] )
                     _HMG_ThisEventType := ''
                     IF lResult == .F.
                        _HMG_aControlMiscData1 [i] [ 17 ]++
                     ELSE
                        EXIT
                     ENDIF
                  ELSE
                     EXIT
                  ENDIF
               NEXT j
               IF !_HMG_GridNavigationMode
                  IF _HMG_aControlMiscData1 [i] [ 17 ] > nEnd
                     _HMG_aControlMiscData1 [i] [ 17 ] := nStart - 1
                  ENDIF
               ENDIF
            ENDIF
         ELSEIF _HMG_aControlMiscData1 [i] [ 17 ] == IPE_MAXCOL
            IF !_lTabKeyPressed
               IF !_HMG_GridNavigationMode
                  _HMG_aControlMiscData1 [i] [ 17 ] := 1
               ELSE
                  IF This.CellRowIndex < IPE_MAXROW
                     InsertDown()
                     InsertReturn()
                  ENDIF
               ENDIF
            ELSE
               _HMG_aControlMiscData1 [i] [ 17 ] := 1
               _lTabKeyPressed := .F.
            ENDIF
         ENDIF
      ENDIF

      LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )

   ENDIF

   _HMG_ThisIndex := 0
   _HMG_ThisType := ''

   _HMG_ThisItemRowIndex := 0
   _HMG_ThisItemColIndex := 0
   _HMG_ThisItemCellRow := 0
   _HMG_ThisItemCellCol := 0
   _HMG_ThisItemCellWidth := 0
   _HMG_ThisItemCellHeight := 0

   _HMG_ThisFormIndex := 0
   _HMG_ThisEventType := ''
   _HMG_ThisFormName := ''
   _HMG_ThisControlName := ''

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _GRID_KBDSCROLL( i )
*-----------------------------------------------------------------------------*
   LOCAL r , xs , xd

   _HMG_ThisItemRowIndex := _HMG_aControlMiscData1 [i] [ 1 ]
   _HMG_ThisItemColIndex := _HMG_aControlMiscData1 [i] [ 17 ]

   IF _HMG_ThisItemColIndex == 1
      r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i] , _HMG_ThisItemRowIndex - 1 )
   ELSE
      r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , _HMG_ThisItemRowIndex - 1 , _HMG_ThisItemColIndex - 1 )
   ENDIF

   xs := ( _HMG_aControlCol [i] + r[2] + r[3] ) - ( _HMG_aControlCol [i] + _HMG_aControlWidth [i] )

   xd := 20

   IF xs > - xd
      ListView_Scroll( _HMG_aControlHandles [i] , xs + xd , 0 )
   ELSE
      IF r [2] < 0
         ListView_Scroll( _HMG_aControlHandles [i] , r[2] , 0 )
      ENDIF
   ENDIF

RETURN
