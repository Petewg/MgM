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

#command @ <row>,<col> LISTBOX <name> ;
      [ ID <nId> ];
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ <dragitems : DRAGITEMS> ] ;
      [ <multicolumn : MULTICOLUMN> ] ;
      [ <multitabs : MULTITAB> ] ;
      [ TABSWIDTH <aWidth> ] ;
   => ;
   _DefineListBox ( <"name">, <"parent">, <col>, <row>, <w>, <h>, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, <{gotfocus}>, <{lostfocus}>, .f., ;
      <helpid>, <.invisible.>, <.notabstop.>, <.sort.> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> ,;
      <backcolor> , <fontcolor> , <.multiselect.> , <.dragitems.>, <.multicolumn.>, <.multitabs.>, <aWidth>, <nId> )


#command REDEFINE LISTBOX <name> ;
        ID <nId>;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ <dragitems : DRAGITEMS> ] ;
      [ <multicolumn : MULTICOLUMN> ] ;
      [ <multitabs : MULTITAB> ] ;
      [ TABSWIDTH <aWidth> ] ;
   => ;
   _DefineListBox ( <"name">, <"parent">, 0, 0, 0, 0, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, <{gotfocus}>, <{lostfocus}>, .f., ;
      <helpid>, <.invisible.>, <.notabstop.>, <.sort.> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> ,;
      <backcolor> , <fontcolor> , <.multiselect.> , <.dragitems.>, <.multicolumn.>, <.multitabs.>, <aWidth>, <nId> )


// SPLITBOX VERSION

#xcommand LISTBOX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <break: BREAK> ] ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ <dragitems : DRAGITEMS> ] ;
      [ <multicolumn : MULTICOLUMN> ] ;
      [ <multitabs : MULTITAB> ] ;
      [ TABSWIDTH <aWidth> ] ;
   => ;
   _DefineListBox ( <"name">, <"parent">, , , <w>, <h>, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, ;
      <{gotfocus}>, <{lostfocus}>, <.break.>, <helpid>, ;
      <.invisible.>, <.notabstop.>, <.sort.> ,<.bold.>, ;
      <.italic.>, <.underline.>, <.strikeout.> , <backcolor> , ;
      <fontcolor> , <.multiselect.> , <.dragitems.>, <.multicolumn.>, <.multitabs.>, <aWidth>, 0 )


// CHECKED LISTBOX

#command @ <row>,<col> CHECKLISTBOX <name> ;
      [ ID <nId> ];
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ CHECKBOXITEM <aCheck> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
   => ;
   _DefineChkListBox ( <"name">, <"parent">, <col>, <row>, <w>, <h>, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, <{gotfocus}>, <{lostfocus}>, .f., ;
      <helpid>, <.invisible.>, <.notabstop.>, <.sort.> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
      <backcolor> , <fontcolor> , <.multiselect.> , <aCheck>, <nItemHeight>, <nId> )

#command REDEFINE CHECKLISTBOX <name> ;
        ID <nId>;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ CHECKBOXITEM <aCheck> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
   => ;
   _DefineChkListBox ( <"name">, <"parent">, 0, 0, 0, 0, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, <{gotfocus}>, <{lostfocus}>, .f., ;
      <helpid>, <.invisible.>, <.notabstop.>, <.sort.> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> ,;
      <backcolor> , <fontcolor> , <.multiselect.> , <aCheck>, <nItemHeight>, <nId> )


// SPLITBOX VERSION

#xcommand CHECKLISTBOX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMS <aRows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ <multiselect : MULTISELECT> ] ;
      [ HELPID <helpid> ]       ;
      [ <break: BREAK> ] ;
      [ <invisible : INVISIBLE> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ <sort : SORT> ] ;
      [ CHECKBOXITEM <aCheck> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
   => ;
   _DefineChkListBox ( <"name">, <"parent">, , , <w>, <h>, <aRows>, <value>, ;
      <fontname>, <fontsize>, <tooltip>, <{change}>, <{dblclick}>, ;
      <{gotfocus}>, <{lostfocus}>, <.break.>, <helpid>, ;
      <.invisible.>, <.notabstop.>, <.sort.> ,<.bold.>, ;
      <.italic.>, <.underline.>, <.strikeout.> , <backcolor> , ;
      <fontcolor> , <.multiselect.> , <aCheck>, <nItemHeight>, 0 )


/*
 * Listbox messages
 */
#define LB_ADDSTRING            0x0180
#define LB_INSERTSTRING         0x0181
#define LB_DELETESTRING         0x0182
#define LB_SELITEMRANGEEX       0x0183
#define LB_RESETCONTENT         0x0184
#define LB_SETSEL               0x0185
#define LB_SETCURSEL            0x0186
#define LB_GETSEL               0x0187
#define LB_GETCURSEL            0x0188
#define LB_GETCOUNT             0x018B
#define LB_SETTABSTOPS          0x0192

#xtranslate ListboxAddString ( <hWnd>, <s> ) ;
=> ;
SendMessageString( <hWnd>, LB_ADDSTRING, 0, <s> )

#xtranslate ListboxInsertString ( <hWnd>, <s>, <p> ) ;
=> ;
SendMessageString( <hWnd>, LB_INSERTSTRING, <p> - 1, <s> )

#xtranslate ListboxSetCurSel ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, LB_SETCURSEL, <s> - 1, 0 )

#xtranslate ListboxGetCurSel ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, LB_GETCURSEL, 0, 0 ) + 1

#xtranslate ListboxDeleteString ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, LB_DELETESTRING, <s> - 1, 0 )

#xtranslate ListboxReset ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, LB_RESETCONTENT, 0, 0 )

#xtranslate ListboxGetItemCount ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, LB_GETCOUNT, 0, 0 )
