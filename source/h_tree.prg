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

STATIC lDialogInMemory := .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineTree ( ControlName, ParentFormName, row, col, width, height, change, tooltip, fontname, fontsize, ;
      gotfocus, lostfocus, dblclick, break, value, HelpId, aImgNode, aImgItem, noBot, bold, italic, underline, strikeout, ;
      itemids, backcolor, fontcolor, linecolor , indent, itemheight, nId )
*-----------------------------------------------------------------------------*
   LOCAL i , ParentFormHandle , Controlhandle , mVar, ImgDefNode, ImgDefItem, aBitmaps := Array( 4 )
   LOCAL FontHandle , k , Style , Mask , blInit

   _HMG_ActiveTreeHandle := 0
   _HMG_NodeIndex := 1
   _HMG_NodeHandle [1] := 0
   _HMG_aTreeMap := {}
   _HMG_aTreeIdMap := {}
   _HMG_ActiveTreeItemIds := itemids

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF _HMG_BeginWindowActive .OR. _HMG_BeginDialogActive
      ParentFormName := iif( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      __defaultNIL( @FontName, _HMG_ActiveFontName )
      __defaultNIL( @FontSize, _HMG_ActiveFontSize )
   ENDIF
   IF _HMG_FrameLevel > 0 .AND. !_HMG_ParentWindowActive
      col := col + _HMG_ActiveFrameCol [_HMG_FrameLevel]
      row := row + _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF
   lDialogInMemory := _HMG_DialogInMemory

   IF .NOT. _IsWindowDefined ( ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError( "Window: " + IFNIL( ParentFormName, "Parent", ParentFormName ) + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentFormName ) .AND. .NOT. lDialogInMemory
      MsgMiniGuiError ( "Control: " + ControlName + " Of " + ParentFormName + " Already defined." )
   ENDIF

   _HMG_ActiveTreeValue := IFNUMERIC( Value, Value, 0 )

   hb_default( @Width, 120 )
   hb_default( @Height, 120 )
   __defaultNIL( @change, "" )
   __defaultNIL( @gotfocus, "" )
   __defaultNIL( @lostfocus, "" )
   __defaultNIL( @dblclick, "" )

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      IF ValType( nobot ) == "L"
         mask := iif( nobot, 0, TVS_LINESATROOT )
      ENDIF
      Style := WS_BORDER + WS_VISIBLE + WS_TABSTOP + WS_CHILD + TVS_HASLINES + TVS_HASBUTTONS + mask + TVS_SHOWSELALWAYS

      IF Len( _HMG_aDialogTemplate ) > 0        //Dialog Template

         //          {{'ID',k/hwnd,class,Style,ExStyle,col,row,width,height,caption,HelpId,tooltip,font,size, bold, italic, underline, strikeout}}  --->_HMG_aDialogItems
         blInit := {|x, y, z| InitDialogTree( x, y, z ) }
         _HMG_aDialogTreeItem := {}
         AAdd( _HMG_aDialogItems, { nId, k, "SysTreeView32", style, 0, col, row, width, height, "", HelpId, tooltip, FontName, FontSize, bold, italic, underline, strikeout, blInit, _HMG_BeginTabActive, .F. , _HMG_ActiveTabPage } )

      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )

         SetWindowStyle ( ControlHandle, Style, .T. )

         col := GetWindowCol ( Controlhandle )
         row := GetWindowRow ( Controlhandle )
         Width := GetWindowWidth  ( Controlhandle )
         Height := GetWindowHeight ( Controlhandle )

         ImgDefNode := iif( ValType( aImgNode ) == "A" , Len( aImgNode ), 0 )  //Tree+
         ImgDefItem := iif( ValType( aImgItem ) == "A" , Len( aImgItem ), 0 )  //Tree+

         IF ImgDefNode > 0

            aBitmaps[1] := aImgNode[1]              // Node default
            aBitmaps[2] := aImgNode[ImgDefNode]

            IF ImgDefItem > 0

               aBitmaps[3] := aImgItem[1]          // Item default
               aBitmaps[4] := aImgItem[ImgDefItem]

            ELSE

               aBitmaps[3] := aImgNode[1]           // Copy Node def if no Item def
               aBitmaps[4] := aImgNode[ImgDefNode]

            ENDIF

            InitTreeViewBitmap( ControlHandle, aBitmaps ) //Init Bitmap List

         ENDIF

         _HMG_ActiveTreeHandle := ControlHandle

      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle ( ParentFormName )

      IF ValType( Row ) == "U" .OR. ValType( Col ) == "U"

         IF _HMG_SplitLastControl == 'TOOLBAR'
            Break := .T.
         ENDIF

         i := GetFormIndex ( ParentFormName )

         IF i > 0

            ControlHandle := InitTree ( _HMG_aFormReBarHandle [i] , col , row , width , height , 0 , '' , 0, iif( noBot,1,0 ) )

            AddSplitBoxItem ( Controlhandle , _HMG_aFormReBarHandle [i] , Width , break , , , , _HMG_ActiveSplitBoxInverted )

            _HMG_SplitLastControl := 'TREE'

         ENDIF

      ELSE

         ControlHandle := InitTree ( ParentFormHandle , col , row , width , height , 0 , '' , 0, iif( noBot,1,0 ) )

      ENDIF

      ImgDefNode := iif( ValType( aImgNode ) == "A" , Len( aImgNode ), 0 )  //Tree+
      ImgDefItem := iif( ValType( aImgItem ) == "A" , Len( aImgItem ), 0 )  //Tree+

      IF ImgDefNode > 0

         aBitmaps[1] := aImgNode[1]          // Node default
         aBitmaps[2] := aImgNode[ImgDefNode]

         IF ImgDefItem > 0

            aBitmaps[3] := aImgItem[1]       // Item default
            aBitmaps[4] := aImgItem[ImgDefItem]

         ELSE

            aBitmaps[3] := aImgNode[1]       // Copy Node def if no Item def
            aBitmaps[4] := aImgNode[ImgDefNode]

         ENDIF

         InitTreeViewBitmap( ControlHandle, aBitmaps )   //Init Bitmap List

      ENDIF

      _HMG_ActiveTreeHandle := ControlHandle

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
         AAdd ( _HMG_ActiveTabCurrentPageMap , ControlHandle )
      ENDIF

      IF ValType( tooltip ) != "U"
         SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle ( ParentFormName ) )
      ENDIF

      IF ValType( backcolor ) == "A"
         TreeView_SetBkColor( ControlHandle, backcolor )
      ENDIF

      IF ValType( fontcolor ) == "A"
         TreeView_SetTextColor( ControlHandle, fontcolor )
      ENDIF

      IF ValType( linecolor ) == "A"
         TreeView_SetLineColor( ControlHandle, linecolor )
      ENDIF

      IF ValType( indent ) == "N"
         TreeView_SetIndent( ControlHandle, indent )
      ENDIF

      IF ValType( itemheight ) == "N"
         TreeView_SetItemHeight( ControlHandle, itemheight )
      ENDIF

   ENDIF

   Public &mVar. := k

   _HMG_ActiveTreeIndex := k

   _HMG_aControlType [k] := "TREE"
   _HMG_aControlNames [k] :=   ControlName
   _HMG_aControlHandles [k] :=   ControlHandle
   _HMG_aControlParentHandles [k] :=   ParentFormHandle
   _HMG_aControlIds [k] :=   nId
   _HMG_aControlProcedures [k] :=   ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  Nil
   _HMG_aControlInputMask  [k] :=  itemids
   _HMG_aControllostFocusProcedure [k] :=   lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  backcolor
   _HMG_aControlFontColor  [k] :=  fontcolor
   _HMG_aControlDblClick   [k] := dblclick
   _HMG_aControlHeadClick   [k] := {}
   _HMG_aControlRow   [k] := Row
   _HMG_aControlCol   [k] := Col
   _HMG_aControlWidth   [k] := Width
   _HMG_aControlHeight   [k] := Height
   _HMG_aControlSpacing   [k] := 0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  {}
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  fontname
   _HMG_aControlFontSize  [k] :=  fontsize
   _HMG_aControlFontAttributes   [k] := { bold, italic, underline, strikeout }
   _HMG_aControlToolTip   [k] :=  tooltip
   _HMG_aControlRangeMin   [k] :=  0
   _HMG_aControlRangeMax   [k] :=  0
   _HMG_aControlCaption   [k] :=  ''
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId   [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  FontHandle
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := { 0, aImgNode, aImgItem }
   _HMG_aControlMiscData2 [k] := ''

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION InitDialogTree( ParentName, ControlHandle, k )
*-----------------------------------------------------------------------------*
   LOCAL ImgDefNode, ImgDefItem, aBitmaps := Array( 4 ), aImgNode, aImgItem
   LOCAL text, ImgDef, Id, aImage, iUnsel, iSel, NodeHandle, n, NodeIndex, Handle

   HB_SYMBOL_UNUSED( ParentName )

   aImgNode := _HMG_aControlMiscData1 [k,2]
   aImgItem := _HMG_aControlMiscData1 [k,3]

   ImgDefNode := iif( ValType( aImgNode ) == "A" , Len( aImgNode ), 0 )  //Tree+
   ImgDefItem := iif( ValType( aImgItem ) == "A" , Len( aImgItem ), 0 )  //Tree+

   IF ImgDefNode > 0
      aBitmaps[1] := aImgNode[1]              // Node default
      aBitmaps[2] := aImgNode[ImgDefNode]
      IF ImgDefItem > 0
         aBitmaps[3] := aImgItem[1]           // Item default
         aBitmaps[4] := aImgItem[ImgDefItem]
      ELSE
         aBitmaps[3] := aImgNode[1]           // Copy Node def if no Item def
         aBitmaps[4] := aImgNode[ImgDefNode]
      ENDIF
      InitTreeViewBitmap( ControlHandle, aBitmaps ) //Init Bitmap List
   ENDIF

   _HMG_ActiveTreeHandle := ControlHandle

   FOR n := 1 TO Len( _HMG_aDialogTreeItem )
      aImage     := _HMG_aDialogTreeItem[n,2]
      text       := _HMG_aDialogTreeItem[n,1]
      id         := _HMG_aDialogTreeItem[n,3]
      NodeIndex  := _HMG_aDialogTreeItem[n,4]
      ImgDef     := iif( ValType( aImage ) == "A" , Len( aImage ), 0 )  //Tree+
      NodeHandle := _HMG_NodeHandle [NodeIndex]

      IF ImgDef == 0
         IF _HMG_aDialogTreeItem[n,5] == 'NODE'
            iUnsel := 0   // Pointer to defalut Node Bitmaps, no Bitmap loaded
            iSel   := 1
         ELSE
            iUnsel := 2   // Pointer to defalut Item Bitmaps, no Bitmap loaded
            iSel   := 3
         ENDIF
      ELSE
         iUnSel := AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[1] ) - 1
         iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[2] ) - 1 )
         // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
      ENDIF
      IF _HMG_aDialogTreeItem[n,5] == 'NODE'
         _HMG_NodeHandle [NodeIndex] := AddTreeItem ( _HMG_ActiveTreeHandle, _HMG_NodeHandle [NodeIndex-1], text, iUnsel, iSel, Id )
         AAdd ( _HMG_aTreeMap , _HMG_NodeHandle [NodeIndex] )
         AAdd ( _HMG_aTreeIdMap , Id )
      ELSE
         handle := AddTreeItem ( _HMG_ActiveTreeHandle, NodeHandle, text, iUnSel, iSel, Id )
         AAdd ( _HMG_aTreeMap , Handle )
         AAdd ( _HMG_aTreeIdMap , Id )
      ENDIF
   NEXT

   _HMG_aControlPageMap [ _HMG_ActiveTreeIndex ] := _HMG_aTreeMap
   _HMG_aControlPicture [ _HMG_ActiveTreeIndex ] := _HMG_aTreeIdMap

   IF _HMG_ActiveTreeValue > 0

      IF _HMG_ActiveTreeItemIds == .F.
         TreeView_SelectItem ( _HMG_ActiveTreeHandle , _HMG_aTreeMap [ _HMG_ActiveTreeValue ] )
      ELSE
         TreeView_SelectItem ( _HMG_ActiveTreeHandle , _HMG_aTreeMap [ AScan ( _HMG_aTreeIdMap , _HMG_ActiveTreeValue ) ] )
      ENDIF
   ENDIF
// JP 62
   IF Len( _HMG_aDialogTemplate ) != 0 .AND. _HMG_aDialogTemplate[3]   // Modal
      _HMG_aControlDeleted [k] := .T.
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineTreeNode ( text, aImage, Id )
*-----------------------------------------------------------------------------*
   LOCAL ImgDef, iUnSel, iSel

   hb_default( @Id, 0 )

   IF lDialogInMemory

      _HMG_NodeIndex++
      AAdd ( _HMG_aDialogTreeItem, { text, aImage, Id, _HMG_NodeIndex, 'NODE' } )

   ELSE

      ImgDef := iif( ValType( aImage ) == "A" , Len( aImage ), 0 )  //Tree+

      IF ImgDef == 0
         iUnsel := 0   // Pointer to defalut Node Bitmaps, no Bitmap loaded
         iSel   := 1
      ELSE
         iUnSel := AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[1] ) - 1
         iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[2] ) - 1 )
         // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
      ENDIF

      _HMG_NodeIndex++
      _HMG_NodeHandle [_HMG_NodeIndex] := AddTreeItem ( _HMG_ActiveTreeHandle, _HMG_NodeHandle [_HMG_NodeIndex-1], text, iUnsel, iSel, Id )
      AAdd ( _HMG_aTreeMap , _HMG_NodeHandle [_HMG_NodeIndex] )
      AAdd ( _HMG_aTreeIdMap , Id )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EndTreeNode()
*-----------------------------------------------------------------------------*

   _HMG_NodeIndex--

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DefineTreeItem ( text, aImage, Id )
*-----------------------------------------------------------------------------*
   LOCAL handle, ImgDef, iUnSel, iSel

   hb_default( @Id, 0 )

   IF lDialogInMemory

      AAdd ( _HMG_aDialogTreeItem, { text, aImage, Id, _HMG_NodeIndex, 'ITEM' } )

   ELSE

      ImgDef := iif( ValType( aImage ) == "A" , Len( aImage ), 0 )  //Tree+

      IF ImgDef == 0
         iUnsel := 2   // Pointer to defalut Item Bitmaps, no Bitmap loaded
         iSel   := 3
      ELSE
         iUnSel := AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[1] ) - 1
         iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( _HMG_ActiveTreeHandle, aImage[2] ) - 1 )
         // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
      ENDIF

      handle := AddTreeItem ( _HMG_ActiveTreeHandle, _HMG_NodeHandle [_HMG_NodeIndex], text, iUnSel, iSel, Id )
      AAdd ( _HMG_aTreeMap , Handle )
      AAdd ( _HMG_aTreeIdMap , Id )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EndTree()
*-----------------------------------------------------------------------------*

   IF .NOT. lDialogInMemory

      _HMG_aControlPageMap [ _HMG_ActiveTreeIndex ] := _HMG_aTreeMap
      _HMG_aControlPicture [ _HMG_ActiveTreeIndex ] := _HMG_aTreeIdMap

      IF _HMG_ActiveTreeValue > 0

         IF _HMG_ActiveTreeItemIds == .F.
            TreeView_SelectItem ( _HMG_ActiveTreeHandle , _HMG_aTreeMap [ _HMG_ActiveTreeValue ] )
         ELSE
            TreeView_SelectItem ( _HMG_ActiveTreeHandle , _HMG_aTreeMap [ AScan ( _HMG_aTreeIdMap , _HMG_ActiveTreeValue ) ] )
         ENDIF

      ENDIF

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _Collapse ( ControlName , ParentForm , Item )
*-----------------------------------------------------------------------------*
   LOCAL ItemHandle

   ItemHandle := TreeItemGetHandle ( ControlName , ParentForm , Item )

   IF ItemHandle > 0
      SendMessage ( GetControlHandle( ControlName , ParentForm ), TVM_EXPAND, TVE_COLLAPSE, ItemHandle )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _Expand ( ControlName , ParentForm , Item )
*-----------------------------------------------------------------------------*
   LOCAL ItemHandle

   ItemHandle := TreeItemGetHandle ( ControlName , ParentForm , Item )

   IF ItemHandle > 0
      SendMessage ( GetControlHandle( ControlName , ParentForm ), TVM_EXPAND, TVE_EXPAND, ItemHandle )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION TreeItemGetHandle ( ControlName , ParentForm , Item )
*-----------------------------------------------------------------------------*
   LOCAL i , ItemHandle := 0 , Pos

   i := GetControlIndex( ControlName , ParentForm )

   IF i > 0

      IF _HMG_aControlInputmask [i] == .F.
         IF Item <= Len ( _HMG_aControlPageMap [i] )
            ItemHandle := _HMG_aControlPageMap [i] [Item]
         ENDIF
      ELSE
         Pos := AScan ( _HMG_aControlPicture [i] , Item )
         IF Pos > 0
            ItemHandle := _HMG_aControlPageMap [i] [Pos]
         ENDIF
      ENDIF

   ENDIF

RETURN ItemHandle

*-----------------------------------------------------------------------------*
PROCEDURE TreeItemChangeImage ( ControlName , ParentForm , nItem , aImage )
*-----------------------------------------------------------------------------*
   LOCAL TreeHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle := TreeItemGetHandle ( ControlName , ParentForm , nItem )
   LOCAL ImgDef, iUnSel, iSel

   IF ItemHandle > 0 .AND. ISARRAY( aImage ) .AND. ( ImgDef := LEN( aImage ) ) > 0
      iUnSel := AddTreeViewBitmap( TreeHandle, aImage[1] ) - 1
      iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( TreeHandle, aImage[2] ) - 1 )

      TREEITEM_SETIMAGEINDEX ( TreeHandle , ItemHandle , iUnSel , iSel )
   ENDIF

RETURN
