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

#define GRID_JTFY_LEFT		0
#define GRID_JTFY_RIGHT		1
#define GRID_JTFY_CENTER	2
#define GRID_JTFY_JUSTIFYMASK	3


#define HDR_IMAGE_NONE		0
#define HDR_IMAGE_ASCENDING	1
#define HDR_IMAGE_DESCENDING	2

///////////////////////////////////////////////////////////////////////////////
// GRID (STANDARD VERSION)
///////////////////////////////////////////////////////////////////////////////
#command @ <row>,<col> GRID <name> 		;
		[ ID <nId> ]			;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ WIDTH <w> ] 			;
		[ AUTOSIZEWIDTH <autosizeW> ]	;
		[ HEIGHT <h> ] 			;
		[ AUTOSIZEHEIGHT <autosizeH> ]	;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ ITEMS <rows> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ] 		;
		[ <italic : ITALIC> ] 		;
		[ <underline : UNDERLINE> ] 	;
		[ <strikeout : STRIKEOUT> ] 	;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ] 	;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ ON RCLICK <rclick> ]  	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ <edit : EDIT> ] 		;
		[ INPLACE <editcontrols> ]	;
		[ <cell : CELL, CELLED, CELLNAVIGATION> ] ;
		[ COLUMNVALID <columnvalid> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ COLUMNWHEN <columnwhen> ]	;
		[ <ownerdata : VIRTUAL> ] 	;
		[ ITEMCOUNT <itemcount> ]	;
		[ ON QUERYDATA <dispinfo> ] 	;
		[ <multiselect : MULTISELECT> ]	;
		[ <style : NOLINES> ] 		;
		[ <noshowheaders: NOHEADERS> ]	;
		[ <nosortheaders: NOSORTHEADERS> ] ;
		[ IMAGE <aImage> ] 		;
		[ JUSTIFY <aJust> ] 		;
		[ HELPID <helpid> ] 		;
		[ <break : BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ COLUMNWIDTHLIMITS <aLimitColumns> ] ;
		[ ON DRAGHEADERITEMS <OnDragItems> ] ;
		[ HEADERIMAGE <aImageHeader> ]  ;
		[ <notabstop: NOTABSTOP> ]	;
		[ <checkboxes: CHECKBOXES> ]	;
		[ ON CHECKBOXCLICKED <OnCheckBoxClicked> ] ;
		[ LOCKCOLUMNS <lockcolumns> ]	;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ ON INIT <bInit> ] ;
	=>;
   _DefineGrid ( <(name)> , 	;
		<(parent)> , 	;
		<col> ,		;
		<row> ,		;
		<w> , 		;
		<h> , 		;
		<headers> , 	;
		<widths> , 	;
		<rows> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,	;
		<{gotfocus}> ,	;
		<{lostfocus}>,  ;
		<.style.>,	;
		<aImage>,	;
		<aJust>  , 	;
		<.break.> , 	;
		<helpid> ,	;
		<.bold.>, 	;
		<.italic.>, 	;
		<.underline.>, 	;
		<.strikeout.> , ;
		<.ownerdata.> , ;
		<{dispinfo}> ,  ;
		<itemcount> , 	;
		<.edit.> ,	;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<.multiselect.> , ;
		<editcontrols> , ;
		<backcolor> ,	;
		<fontcolor> ,	;
		<nId>,		;
		<columnvalid> ,	;
		<columnwhen> ,	;
		<aValidMessages> ,;
		!<.noshowheaders.> ,;
		<aImageHeader> ,;
		<.notabstop.> ,	;
		<.cell.> ,	;
		<.checkboxes.> ,;
		<lockcolumns> , ;
		<{OnCheckBoxClicked}> , ;
		<.doublebuffer.> , ;
		<.nosortheaders.> , ;
                <columnsort> , ;
                <aLimitColumns> , ;
                <{OnDragItems}> , ;
                <bInit> , ;
                <autosizeH> , ;
                <.autosizeW.> , ;
                <{rclick}> )

#command REDEFINE GRID <name> 		;
		[ ID <nId> ]		;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ ITEMS <rows> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ] ;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ <edit : EDIT> ] 		;
		[ INPLACE <editcontrols> ]	;
		[ <cell : CELL, CELLED, CELLNAVIGATION> ] ;
		[ COLUMNVALID <columnvalid> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ COLUMNWHEN <columnwhen> ]	;
		[ <ownerdata: VIRTUAL> ] 	;
		[ ITEMCOUNT <itemcount> ]	;
		[ ON QUERYDATA <dispinfo> ] 	;
		[ <multiselect: MULTISELECT> ]	;
		[ <style: NOLINES> ] 		;
		[ <noshowheaders: NOHEADERS> ]	;
		[ <nosortheaders: NOSORTHEADERS> ] ;
		[ IMAGE <aImage> ] 		;
		[ JUSTIFY <aJust> ] 		;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ COLUMNWIDTHLIMITS <aLimitColumns> ] ;
		[ ON DRAGHEADERITEMS <OnDragItems> ] ;
		[ HEADERIMAGE <aImageHeader> ]  ;
		[ <notabstop: NOTABSTOP> ]	;
		[ <checkboxes: CHECKBOXES> ]    ;
		[ ON CHECKBOXCLICKED <OnCheckBoxClicked> ] ;
		[ LOCKCOLUMNS <lockcolumns> ]	;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ AUTOSIZEWIDTH <autosizeW> ]	;
		[ AUTOSIZEHEIGHT <autosizeH> ]	;
		[ ON INIT <bInit> ] ;
	=>;
   _DefineGrid ( <(name)> , 	;
		<(parent)> , 	;
 		0 ,		;
		0 ,		;
		0 , 		;
		0 , 		;
		<headers> , 	;
		<widths> , 	;
		<rows> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,	;
		<{gotfocus}> ,	;
		<{lostfocus}>,  ;
		<.style.>,	;
		<aImage>,	;
		<aJust>  , 	;
		<.break.> , 	;
		<helpid> ,	;
		<.bold.>, 	;
		<.italic.>, 	;
		<.underline.>, 	;
		<.strikeout.> , ;
		<.ownerdata.> , ;
		<{dispinfo}> ,  ;
		<itemcount> , 	;
		<.edit.> ,  ;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<.multiselect.> , ;
		<editcontrols> , ;
		<backcolor>, ;
		<fontcolor>,;
		<nId>,;
		<columnvalid> ,;
		<columnwhen>,;
		<aValidMessages> ,;
		!<.noshowheaders.> ,;
		<aImageHeader> ,;
		<.notabstop.> ,;
		<.cell.> ,;
		<.checkboxes.> ,;
		<lockcolumns> ,;
                <{OnCheckBoxClicked}> ,;
                <.doublebuffer.> ,;
                <.nosortheaders.> ,;
                <columnsort> ,;
                <aLimitColumns> , <{OnDragItems}> , <bInit> , <autosizeH>, <.autosizeW.> )

///////////////////////////////////////////////////////////////////////////////
// GRID (SPLITBOX VERSION)
///////////////////////////////////////////////////////////////////////////////
#command GRID <name> 		;
		[ <dummy1: OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] 			;
		[ AUTOSIZEWIDTH <autosizeW> ]	;
		[ HEIGHT <h> ] 			;
		[ AUTOSIZEHEIGHT <autosizeH> ]	;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ ITEMS <rows> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ] ;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ <edit : EDIT> ] 		;
		[ INPLACE <editcontrols> ]	;
		[ <cell : CELL, CELLED, CELLNAVIGATION> ] ;
		[ COLUMNVALID <columnvalid> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ COLUMNWHEN <columnwhen> ]	;
		[ <ownerdata: VIRTUAL> ] 	;
		[ ITEMCOUNT <itemcount> ]	;
		[ ON QUERYDATA <dispinfo> ] 	;
		[ <multiselect: MULTISELECT> ]	;
		[ <style: NOLINES> ] 		;
		[ <noshowheaders: NOHEADERS> ]	;
		[ <nosortheaders: NOSORTHEADERS> ] ;
		[ IMAGE <aImage> ] 		;
		[ JUSTIFY <aJust> ] 		;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ COLUMNWIDTHLIMITS <aLimitColumns> ] ;
		[ ON DRAGHEADERITEMS <OnDragItems> ] ;
		[ HEADERIMAGE <aImageHeader> ] 	;
		[ <notabstop: NOTABSTOP> ]	;
		[ <checkboxes: CHECKBOXES> ]    ;
		[ ON CHECKBOXCLICKED <OnCheckBoxClicked> ] ;
		[ LOCKCOLUMNS <lockcolumns> ]	;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ ON INIT <bInit> ] ;
	=>;
   _DefineGrid ( <(name)> , 	;
		<(parent)> , 	;
		,		;
		,		;
		<w> , 		;
		<h> , 		;
		<headers> , 	;
		<widths> , 	;
		<rows> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,	;
		<{gotfocus}> ,	;
		<{lostfocus}>,  ;
		<.style.>,	;
		<aImage>,	;
		<aJust>  , 	;
		<.break.> , 	;
		<helpid> ,	;
		<.bold.>, 	;
		<.italic.>, 	;
		<.underline.>, 	;
		<.strikeout.> , ;
		<.ownerdata.> , ;
		<{dispinfo}> ,  ;
		<itemcount> , 	;
		<.edit.> ,  ;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<.multiselect.> , ;
		<editcontrols> , ;
		<backcolor> , ;
		<fontcolor> ,;
		0,;
		<columnvalid> ,;
		<columnwhen> ,;
		<aValidMessages> ,;
		!<.noshowheaders.> ,;
		<aImageHeader> ,;
		<.notabstop.> ,;
		<.cell.> ,;
		<.checkboxes.> ,;
		<lockcolumns> ,;
                <{OnCheckBoxClicked}> ,;
                <.doublebuffer.> ,;
                <.nosortheaders.> ,;
                <columnsort> ,;
                <aLimitColumns> , <{OnDragItems}> , <bInit> , <autosizeH>, <.autosizeW.> )

///////////////////////////////////////////////////////////////////////////////
// GRID (STANDARD VERSION)
///////////////////////////////////////////////////////////////////////////////
#command @ <row>,<col> GRID <name> 		;
		[ <dummy1: OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] 			;
		[ AUTOSIZEWIDTH <autosizeW> ]	;
		[ HEIGHT <h> ] 			;
		[ AUTOSIZEHEIGHT <autosizeH> ]	;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ ITEMS <rows> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ ON RCLICK <rclick> ]  	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ <edit : EDIT> ]		;
		[ <cell : CELL, CELLED, CELLNAVIGATION> ] ;
		[ COLUMNCONTROLS <editcontrols> ] ;
		[ COLUMNVALID <columnvalid> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ COLUMNWHEN <columnwhen> ]	;
		[ <ownerdata: VIRTUAL> ] 	;
		[ ITEMCOUNT <itemcount> ]	;
		[ ON QUERYDATA <dispinfo> ] 	;
		[ <multiselect: MULTISELECT> ]	;
		[ <style: NOLINES> ] 		;
		[ <noshowheaders: NOHEADERS> ]	;
		[ <nosortheaders: NOSORTHEADERS> ] ;
		[ IMAGE <aImage> ] 		;
		[ JUSTIFY <aJust> ] 		;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ COLUMNWIDTHLIMITS <aLimitColumns> ] ;
		[ ON DRAGHEADERITEMS <OnDragItems> ] ;
		[ HEADERIMAGE <aImageHeader> ]	;
		[ <notabstop: NOTABSTOP> ]	;
		[ <checkboxes: CHECKBOXES> ]    ;
		[ ON CHECKBOXCLICKED <OnCheckBoxClicked> ] ;
		[ LOCKCOLUMNS <lockcolumns> ]	;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ ON INIT <bInit> ] ;
	=>;
   _DefineGrid ( <(name)> , 	;
		<(parent)> , 	;
		<col> ,		;
		<row> ,		;
		<w> , 		;
		<h> , 		;
		<headers> , 	;
		<widths> , 	;
		<rows> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,	;
		<{gotfocus}> ,	;
		<{lostfocus}>,  ;
		<.style.>,	;
		<aImage>,	;
		<aJust>  , 	;
		<.break.> , 	;
		<helpid> ,	;
		<.bold.>, 	;
		<.italic.>, 	;
		<.underline.>, 	;
		<.strikeout.> , ;
		<.ownerdata.> , ;
		<{dispinfo}> ,  ;
		<itemcount> , 	;
		<.edit.> ,  ;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<.multiselect.> , ;
		<editcontrols> , ;
		<backcolor> , ;
		<fontcolor> ,;
		0,;
		<columnvalid> ,;
		<columnwhen> ,;
		<aValidMessages> ,;
		!<.noshowheaders.> ,;
		<aImageHeader> ,;
		<.notabstop.> ,;
		<.cell.> ,;
		<.checkboxes.> ,;
		<lockcolumns> ,;
                <{OnCheckBoxClicked}> ,;
                <.doublebuffer.> ,;
                <.nosortheaders.> ,;
                <columnsort> ,;
                <aLimitColumns> , ;
                <{OnDragItems}> , ;
                <bInit> , ;
                <autosizeH> , ;
                <.autosizeW.> , ;
                <{rclick}> )

///////////////////////////////////////////////////////////////////////////////
// GRID (SPLITBOX VERSION)
///////////////////////////////////////////////////////////////////////////////
#command GRID <name> 		;
		[ <dummy1: OF, PARENT> <parent> ] ;
		[ WIDTH <w> ] 			;
		[ AUTOSIZEWIDTH <autosizeW> ]	;
		[ HEIGHT <h> ] 			;
		[ AUTOSIZEHEIGHT <autosizeH> ]	;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ ITEMS <rows> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ <edit : EDIT> ]		;
		[ <cell : CELL, CELLED, CELLNAVIGATION> ] ;
		[ COLUMNCONTROLS <editcontrols> ] ;
		[ COLUMNVALID <columnvalid> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ COLUMNWHEN <columnwhen> ]	;
		[ <ownerdata: VIRTUAL> ] 	;
		[ ITEMCOUNT <itemcount> ]	;
		[ ON QUERYDATA <dispinfo> ] 	;
		[ <multiselect: MULTISELECT> ]	;
		[ <style: NOLINES> ] 		;
		[ <noshowheaders: NOHEADERS> ]	;
		[ <nosortheaders: NOSORTHEADERS> ] ;
		[ IMAGE <aImage> ] 		;
		[ JUSTIFY <aJust> ] 		;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ COLUMNWIDTHLIMITS <aLimitColumns> ] ;
		[ ON DRAGHEADERITEMS <OnDragItems> ] ;
		[ HEADERIMAGE <aImageHeader> ]	;
		[ <notabstop: NOTABSTOP> ]	;
		[ <checkboxes: CHECKBOXES> ]    ;
		[ ON CHECKBOXCLICKED <OnCheckBoxClicked> ] ;
		[ LOCKCOLUMNS <lockcolumns> ]	;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ ON INIT <bInit> ] ;
	=>;
   _DefineGrid ( <(name)> , 	;
	        <(parent)> , 	;
		,		;
		,		;
		<w> , 		;
		<h> , 		;
		<headers> , 	;
		<widths> , 	;
		<rows> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,	;
		<{gotfocus}> ,	;
		<{lostfocus}>,  ;
		<.style.>,	;
		<aImage>,	;
		<aJust>  , 	;
		<.break.> , 	;
		<helpid> ,	;
		<.bold.>, 	;
		<.italic.>, 	;
		<.underline.>, 	;
		<.strikeout.> , ;
		<.ownerdata.> , ;
		<{dispinfo}> ,  ;
		<itemcount> , 	;
		<.edit.> ,  ;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<.multiselect.> , ;
		<editcontrols> , ;
		<backcolor> , ;
		<fontcolor> , ;
		0,;
		<columnvalid> ,;
		<columnwhen> ,;
		<aValidMessages> ,;
		!<.noshowheaders.> ,;
		<aImageHeader> ,;
		<.notabstop.> ,;
		<.cell.> ,;
		<.checkboxes.> ,;
		<lockcolumns> ,;
                <{OnCheckBoxClicked}> ,;
                <.doublebuffer.> ,;
                <.nosortheaders.> ,;
                <columnsort> ,;
                <aLimitColumns> , <{OnDragItems}> , <bInit> , <autosizeH>, <.autosizeW.> )

#xcommand SET [GRID] CELLNAVIGATIONMODE <x:VERTICAL,HORIZONTAL> => _HMG_GridNavigationMode := ( Upper(<(x)>) == "VERTICAL" )
#xcommand SET [GRID] CELLNAVIGATION MODE <x:VERTICAL,HORIZONTAL> => _HMG_GridNavigationMode := ( Upper(<(x)>) == "VERTICAL" )


#ifndef LVM_FIRST
#define LVM_FIRST               0x1000      // ListView messages
#endif

#define LVM_DELETEITEM          (LVM_FIRST + 8)
#define LVM_DELETEALLITEMS      (LVM_FIRST + 9)

#define LVM_SETEXTENDEDLISTVIEWSTYLE (LVM_FIRST + 54)

#xtranslate ListviewDeleteString ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, LVM_DELETEITEM, <s> - 1, 0 )

#xtranslate ListviewReset ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, LVM_DELETEALLITEMS, 0, 0 )

#define LVSCW_AUTOSIZE              -1
#define LVSCW_AUTOSIZE_USEHEADER    -2

#xtranslate ListView_SetColumnWidthAuto ( <h>, <nColumn> ) ;
=> ;
ListView_SetColumnWidth ( <h>, <nColumn>, LVSCW_AUTOSIZE )

#xtranslate ListView_SetColumnWidthAutoH ( <h>, <nColumn> ) ;
=> ;
ListView_SetColumnWidth ( <h>, <nColumn>, LVSCW_AUTOSIZE_USEHEADER )


#define _GRID_COLUMN_JUSTIFY_            3
#define _GRID_COLUMN_DYNAMICFORECOLOR_   11
#define _GRID_COLUMN_DYNAMICBACKCOLOR_   12
#define _GRID_COLUMN_CONTROL_            13
#define _GRID_COLUMN_VALID_              14
#define _GRID_COLUMN_WHEN_               15
#define _GRID_COLUMN_VALIDMESSAGE_       16
