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

#xcommand @ <row>,<col> COMBOBOX <name> ;
      [ID <nId>] ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
      [ ITEMS <aRows> ] ;
      [ ITEMSOURCE <itemsource> ] ;
      [ VALUE <value> ] ;
      [ VALUESOURCE <valuesource> ] ;
      [ <displaychange : DISPLAYEDIT> ] ;
      [ <lstwidth: LISTWIDTH, DROPPEDWIDTH> <nValue> ] ;
      [ FONT <f> ] ;
      [ SIZE <n> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <upper: UPPERCASE> ]    ;
      [ <lower: LOWERCASE> ]    ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <changeprocedure> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ] ;
      [ ON DISPLAYCHANGE <ondisplaychangeprocedure> ] ;
      [ <ondropdown: ON LISTDISPLAY, ON DROPDOWN> <onListdisplayprocedure> ] ;
      [ <oncloseup: ON LISTCLOSE, ON CLOSEUP> <onListcloseprocedure> ] ;
      [ ON CANCEL <OnCancel> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible : INVISIBLE> ] ;
      [ <sort : SORT> ] ;
      [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
      [ <AutoComplete : AUTOCOMPLETE> [ SHOWDROPDOWN <showdd> ] ] ;
   =>;
   _DefineCombo ( <"name">, <"parent">, <col>, <row>, <w>, <aRows> , <value>, ;
                  <f>, <n>, <tooltip>, <{changeprocedure}>, <h>, ;
                  <{gotfocus}>, <{lostfocus}>, <{enter}>, <helpid>, ;
                  <.invisible.>, <.notabstop.>, <.sort.> ,<.bold.>, ;
      <.italic.>, <.underline.>, <.strikeout.> , <"itemsource"> , ;
      <"valuesource"> , <.displaychange.> , ;
      <{ondisplaychangeprocedure}> ,  .f. , "" , <nValue>, <nId>, ;
      <{onListdisplayprocedure}> , <{onListcloseprocedure}> , <backcolor> , <fontcolor> , ;
      <.upper.> , <.lower.> , [<CueText>] , <{OnCancel}> , <.AutoComplete.> , [<.showdd.>] , <nItemHeight> )


#xcommand REDEFINE COMBOBOX <name> ;
      ID <nId> ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
      [ ITEMS <aRows> ] ;
      [ ITEMSOURCE <itemsource> ] ;
      [ VALUE <value> ] ;
      [ VALUESOURCE <valuesource> ] ;
      [ <displaychange : DISPLAYEDIT> ] ;
      [ LISTWIDTH <nValue> ];
      [ FONT <f> ] ;
      [ SIZE <n> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <upper: UPPERCASE> ]    ;
      [ <lower: LOWERCASE> ]    ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <changeprocedure> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ] ;
      [ ON DISPLAYCHANGE <ondisplaychangeprocedure> ] ;
      [ ON LISTDISPLAY <onListdisplayprocedure> ] ;
      [ ON LISTCLOSE <onListcloseprocedure> ] ;
      [ ON CANCEL <OnCancel> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
      [ <sort : SORT> ] ;
      [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
      [ <AutoComplete : AUTOCOMPLETE> [ SHOWDROPDOWN <showdd> ] ] ;
    =>;
   _DefineCombo ( <"name">, <"parent">, 0, 0, 0, <aRows> , <value>, ;
                  <f>, <n>, <tooltip>, <{changeprocedure}>, 0, ;
                  <{gotfocus}>, <{lostfocus}>, <{enter}>, <helpid>, ;
                  <.invisible.>, <.notabstop.>, <.sort.> ,<.bold.>, ;
      <.italic.>, <.underline.>, <.strikeout.> , ;
      <"itemsource"> , <"valuesource"> , <.displaychange.> , ;
      <{ondisplaychangeprocedure}> ,  .f. , "", <nValue>, <nId>, ;
      <{onListdisplayprocedure}> , <{onListcloseprocedure}> , <backcolor> , <fontcolor> , ;
      <.upper.> , <.lower.> , [<CueText>] , <{OnCancel}> , <.AutoComplete.> , [<.showdd.>] , <nItemHeight> )


// SPLITBOX VERSION

#xcommand COMBOBOX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
      [ ITEMS <aRows> ] ;
      [ ITEMSOURCE <itemsource> ] ;
      [ VALUE <value> ] ;
      [ VALUESOURCE <valuesource> ] ;
      [ <displaychange : DISPLAYEDIT> ] ;
      [ <lstwidth: LISTWIDTH, DROPPEDWIDTH> <nValue> ] ;
      [ FONT <f> ] ;
      [ SIZE <n> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <upper: UPPERCASE> ]    ;
      [ <lower: LOWERCASE> ]    ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <changeprocedure> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ] ;
      [ ON DISPLAYCHANGE <ondisplaychangeprocedure> ] ;
      [ <ondropdown: ON LISTDISPLAY, ON DROPDOWN> <onListdisplayprocedure> ] ;
      [ <oncloseup: ON LISTCLOSE, ON CLOSEUP> <onListcloseprocedure> ] ;
      [ ON CANCEL <OnCancel> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ HELPID <helpid> ]       ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ <break: BREAK> ] ;
      [ <invisible : INVISIBLE> ] ;
      [ <sort : SORT> ] ;
      [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
      [ <AutoComplete : AUTOCOMPLETE> [ SHOWDROPDOWN <showdd> ] ] ;
   =>;
   _DefineCombo ( <"name">, <"parent">, , , <w>, <aRows> , <value>, ;
                  <f>, <n>, <tooltip>, <{changeprocedure}>, <h>, ;
                  <{gotfocus}>, <{lostfocus}>, <{enter}>, <helpid>, ;
                  <.invisible.>, <.notabstop.>, <.sort.>, <.bold.>, <.italic.>, <.underline.>, ;
                  <.strikeout.> , <"itemsource"> , <"valuesource"> , <.displaychange.> , ;
                  <{ondisplaychangeprocedure}> , <.break.> , <grippertext> , <nValue>, 0, ;
                  <{onListdisplayprocedure}> , <{onListcloseprocedure}> , <backcolor> , <fontcolor> , ;
                  <.upper.> , <.lower.> , [<CueText>] , <{OnCancel}> , <.AutoComplete.> , [<.showdd.>] , <nItemHeight> )


/*----------------------------------------------------------------------------
ComboBox Extend Style
---------------------------------------------------------------------------*/
#xcommand @ <row>,<col> COMBOBOXEX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
      [ ITEMS <aRows> ] ;
      [ ITEMSOURCE <itemsource> ] ;
      [ VALUE <value> ] ;
      [ VALUESOURCE <valuesource> ] ;
      [ <displaychange : DISPLAYEDIT> ] ;
      [ LISTWIDTH <nValue> ];
      [ FONT <f> ] ;
      [ SIZE <n> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <changeprocedure> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ] ;
      [ ON DISPLAYCHANGE <ondisplaychangeprocedure> ] ;
      [ ON LISTDISPLAY <onListdisplayprocedure> ] ;
      [ ON LISTCLOSE <onListcloseprocedure> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ IMAGE <aImage> ]       ;
      [ IMAGELIST <imagelist> ]       ;
      [ HELPID <helpid> ]       ;
      [ <invisible : INVISIBLE> ] ;
   =>;
   _DefineComboEx ( <"name">, <"parent">, <col>, <row>, <w>, <aRows> , <value>, ;
      <f>, <n>, <tooltip>, <{changeprocedure}>, <h>, ;
      <{gotfocus}>, <{lostfocus}>, <{enter}>, <helpid>, ;
      <.invisible.>, <.notabstop.>, .f. , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , ;
      <"itemsource"> , <"valuesource"> , <.displaychange.> , ;
      <{ondisplaychangeprocedure}> ,  .f. , "", <aImage>, <nValue>, ;
      <{onListdisplayprocedure}> , <{onListcloseprocedure}> , <backcolor> , <fontcolor>, <imagelist>, <nItemHeight> )


// SPLITBOX VERSION

#xcommand COMBOBOXEX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ ITEMHEIGHT <nItemHeight> ] ;
      [ ITEMS <aRows> ] ;
      [ ITEMSOURCE <itemsource> ] ;
      [ VALUE <value> ] ;
      [ VALUESOURCE <valuesource> ] ;
      [ <displaychange : DISPLAYEDIT> ] ;
      [ LISTWIDTH <nValue> ];
      [ FONT <f> ] ;
      [ SIZE <n> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <changeprocedure> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ] ;
      [ ON DISPLAYCHANGE <ondisplaychangeprocedure> ] ;
      [ ON LISTDISPLAY <onListdisplayprocedure> ] ;
      [ ON LISTCLOSE <onListcloseprocedure> ] ;
      [ <notabstop : NOTABSTOP> ] ;
      [ IMAGE <aImage> ]       ;
      [ IMAGELIST <imagelist> ]       ;
      [ HELPID <helpid> ]       ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ <break: BREAK> ] ;
      [ <invisible : INVISIBLE> ] ;
   =>;
   _DefineComboEx ( <"name">, <"parent">, , , <w>, <aRows> , <value>, ;
      <f>, <n>, <tooltip>, <{changeprocedure}>, <h>, ;
      <{gotfocus}>, <{lostfocus}>, <{enter}>, <helpid>, ;
      <.invisible.>, <.notabstop.>, .f. ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.> , ;
      <"itemsource"> , <"valuesource"> , <.displaychange.> , ;
      <{ondisplaychangeprocedure}> , <.break.> , <grippertext> , <aImage> , <nValue>, ;
      <{onListdisplayprocedure}> , <{onListcloseprocedure}> , <backcolor> , <fontcolor>, <imagelist>, <nItemHeight> )


/*
 * Combo Box messages
 */
#define CB_ADDSTRING                0x0143
#define CB_DELETESTRING             0x0144
#define CB_GETCOUNT                 0x0146
#define CB_GETCURSEL                0x0147
#define CB_INSERTSTRING             0x014A
#define CB_RESETCONTENT             0x014B
#define CB_SETCURSEL                0x014E

#define CBEM_DELETEITEM         CB_DELETESTRING

#define CB_GETDROPPEDWIDTH          0x015f
#define CB_SETDROPPEDWIDTH          0x0160


#xtranslate ComboAddString ( <hWnd>, <s> ) ;
=> ;
SendMessageString( <hWnd>, CB_ADDSTRING, 0, <s> )

#xtranslate ComboInsertString ( <hWnd>, <s>, <p> ) ;
=> ;
SendMessageString( <hWnd>, CB_INSERTSTRING, <p> - 1, <s> )

#xtranslate ComboSetCurSel ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, CB_SETCURSEL, <s> - 1, 0 )

#xtranslate ComboGetCurSel ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, CB_GETCURSEL, 0, 0 ) + 1

#xtranslate ComboboxDeleteString ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, CB_DELETESTRING, <s> - 1, 0 )

#xtranslate ComboboxReset ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, CB_RESETCONTENT, 0, 0 )

#xtranslate ComboboxGetItemCount ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, CB_GETCOUNT, 0, 0 )

#xtranslate ComboboxDeleteItemEx ( <hWnd>, <s> ) ;
=> ;
SendMessage( <hWnd>, CBEM_DELETEITEM, <s> - 1, 0 )

#xtranslate SetDropDownWidth ( <hWnd>, <w> ) ;
=> ;
SendMessage( <hWnd>, CB_SETDROPPEDWIDTH, <w>, 0 )

#xtranslate GetDropDownWidth ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, CB_GETDROPPEDWIDTH, 0, 0 )
