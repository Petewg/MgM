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

#xcommand DEFINE TREE <name> ;
    [ID <nId>];
    [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
	AT <row> , <col> ;
	[ WIDTH <width> ] ;
	[ HEIGHT <height> ] ;
	[ VALUE <value> ] ;
	[ FONT <fontname> ] ;
	[ SIZE <fontsize> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
        [ BACKCOLOR <backcolor> ] ;
        [ FONTCOLOR <fontcolor> ] ;
	[ LINECOLOR <linecolor> ];
	[ INDENT    <indent>];
	[ ITEMHEIGHT <itemheight>];
	[ TOOLTIP <tooltip> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON CHANGE <change> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ ON DBLCLICK <dblclick> ] ;
	[ NODEIMAGES <aImgNode> [ ITEMIMAGES <aImgItem> ] [ <noBut: NOROOTBUTTON> ]];
	[ <itemids : ITEMIDS> ] ;
	[ HELPID <helpid> ] 		;
=>;
_DefineTree ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> , <{change}> , <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{dblclick}> , .f. , <value>  , <helpid>, <aImgNode>, <aImgItem>, <.noBut.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemids.>, <backcolor>, <fontcolor>, <linecolor>, <indent>, <itemheight>, <nId> )

#xcommand REDEFINE TREE <name> ;
    ID <nId>;
    [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
	[ VALUE <value> ] ;
	[ FONT <fontname> ] ;
	[ SIZE <fontsize> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
        [ BACKCOLOR <backcolor> ] ;
        [ FONTCOLOR <fontcolor> ] ;
	[ LINECOLOR <linecolor> ];
	[ INDENT    <indent>];
	[ ITEMHEIGHT <itemheight>];
	[ TOOLTIP <tooltip> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON CHANGE <change> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ ON DBLCLICK <dblclick> ] ;
	[ NODEIMAGES <aImgNode> [ ITEMIMAGES <aImgItem> ] [ <noBut: NOROOTBUTTON> ]];
	[ <itemids : ITEMIDS> ] ;
	[ HELPID <helpid> ] 		;
=>;
_DefineTree ( <"name"> , <"parent"> , 0 , 0 , 0 , 0 , <{change}> , <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{dblclick}> , .f. , <value>  , <helpid>, <aImgNode>, <aImgItem>, <.noBut.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemids.>, <backcolor>, <fontcolor>, <linecolor>, <indent>, <itemheight>, <nId> )


#xcommand NODE <text> [ IMAGES <aImage> ] [ ID <id> ];
=>;
_DefineTreeNode (<text>, <aImage> , <id> )

#xcommand DEFINE NODE <text> [ IMAGES <aImage> ] [ ID <id> ] ;
=>;
_DefineTreeNode (<text>, <aImage> , <id> )

#xcommand END NODE ;
=>;
_EndTreeNode()

#xcommand TREEITEM <text> [ IMAGES <aImage> ]  [ ID <id> ] ;
=> ;
_DefineTreeItem (<text>, <aImage> , <id> )

#xcommand END TREE ;
=> ;
_EndTree()

///////////////////////////////////////////////////////////////////////////////
// SPLITBOX VERSION
///////////////////////////////////////////////////////////////////////////////

#xcommand DEFINE TREE <name> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	[ WIDTH <width> ] ;
	[ HEIGHT <height> ] ;
	[ VALUE <value> ] ;
	[ FONT <fontname> ] ;
	[ SIZE <fontsize> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
        [ BACKCOLOR <backcolor> ] ;
        [ FONTCOLOR <fontcolor> ] ;
	[ LINECOLOR <linecolor> ];
	[ INDENT    <indent>];
	[ ITEMHEIGHT <itemheight>];
	[ TOOLTIP <tooltip> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON CHANGE <change> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ ON DBLCLICK <dblclick> ] ;
	[ <itemids : ITEMIDS> ] ;
	[ HELPID <helpid> ] 		;
	[ NODEIMAGES <aImgNode> [ ITEMIMAGES <aImgItem> ] [ <noBut: NOROOTBUTTON> ]];
	[ <break: BREAK> ] ;                             
=>;
_DefineTree ( <"name"> , <"parent"> ,  ,  , <width> , <height> , <{change}> , <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{dblclick}> , <.break.> , <value>  , <helpid>, <aImgNode>, <aImgItem>, <.noBut.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemids.>, <backcolor>, <fontcolor>, <linecolor>, <indent>, <itemheight>, 0 )

#ifndef TV_FIRST
#define TV_FIRST           0x1100
#endif
#define TVM_GETINDENT           (TV_FIRST + 6)
#define TVM_SETINDENT           (TV_FIRST + 7)
#define TVM_SETITEMHEIGHT       (TV_FIRST + 27)
#define TVM_GETITEMHEIGHT       (TV_FIRST + 28)
#define TVM_SETBKCOLOR          (TV_FIRST + 29)
#define TVM_SETTEXTCOLOR        (TV_FIRST + 30)
#define TVM_GETBKCOLOR          (TV_FIRST + 31)
#define TVM_GETTEXTCOLOR        (TV_FIRST + 32)
#define TVM_SETLINECOLOR        (TV_FIRST + 40)
#define TVM_GETLINECOLOR        (TV_FIRST + 41)

#translate TreeView_SetBkColor ( <hWnd>, <aColor> ) ;
=> ;
SendMessage( <hWnd>, TVM_SETBKCOLOR, 0, RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]) )

#translate TreeView_GetBkColor ( <hWnd> ) ;
=> ;
nRGB2Arr( SendMessage( <hWnd>, TVM_GETBKCOLOR, 0, 0 ) )

#translate TreeView_SetTextColor ( <hWnd>, <aColor> ) ;
=> ;
SendMessage( <hWnd>, TVM_SETTEXTCOLOR, 0, RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]) )

#translate TreeView_GetTextColor ( <hWnd> ) ;
=> ;
nRGB2Arr( SendMessage( <hWnd>, TVM_GETTEXTCOLOR, 0, 0 ) )

#translate TreeView_SetLineColor ( <hWnd>, <aColor> ) ;
=> ;
SendMessage( <hWnd>, TVM_SETLINECOLOR, 0, RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]) )

#translate TreeView_GetLineColor ( <hWnd> ) ;
=> ;
nRGB2Arr( SendMessage( <hWnd>, TVM_GETLINECOLOR, 0, 0 ) )

#translate TreeView_SetItemHeight ( <hWnd>, <nHeight> ) ;
=> ;
SendMessage( <hWnd>, TVM_SETITEMHEIGHT, <nHeight>, 0 )

#translate TreeView_GetItemHeight ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, TVM_GETITEMHEIGHT, 0, 0 )

#translate TreeView_SetIndent ( <hWnd>, <nIndent> ) ;
=> ;
SendMessage( <hWnd>, TVM_SETINDENT, <nIndent>, 0 )

#translate TreeView_GetIndent ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, TVM_GETINDENT, 0, 0 )
