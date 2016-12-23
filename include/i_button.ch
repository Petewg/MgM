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

#xcommand @ <row>,<col> BUTTON <name> ;
      [ ID <nId> ] ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      CAPTION <caption> ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <font> ] ;
      [ SIZE <size> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <multiline: MULTILINE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   _DefineButton ( <"name">, <"parent"> , <col>, <row>, <caption>, <{action}>, ;
		<w>, <h>, <font>, <size>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
		<.flat.>, <.notabstop.>, <helpid>, <.invisible.> , <.bold.>, <.italic.>, ;
		<.underline.>, <.strikeout.>, <.multiline.>, <.default.>, <"key">, <nId> )

#xcommand REDEFINE BUTTON <name> ;
      ID <nId> ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ CAPTION <caption> ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ FONT <font> ] ;
      [ SIZE <size> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <multiline: MULTILINE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
    _DefineButton ( <"name">, <"parent">, 0, 0, <caption>, <{action}>, ;
		0, 0, <font>, <size>, <tooltip>, <{gotfocus}>, ;
		<{lostfocus}>, <.flat.>, <.notabstop.>, <helpid>, <.invisible.>, ;
		<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.multiline.>, <.default.>, , <nId> )


#xcommand @ <row>,<col> BUTTON <name> ;
      [ ID <nId> ] ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      PICTURE <bitmap> ;
      [ ICON <icon> [ <extract: EXTRACT> <idx> ] ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   _DefineImageButton ( <"name">, <"parent">, <col>, <row>, "", <{action}>, ;
		<w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
		<.flat.>, <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, ;
		<.default.>, <icon>, <.extract.>, <idx>, <.noxpstyle.>, <"key">, <nId> )

#xcommand @ <row>,<col> BUTTON <name> ;
      [ ID <nId> ] ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ PICTURE <bitmap> ] ;
      ICON <icon> [ <extract: EXTRACT> <idx> ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ HOTKEY <key> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   _DefineImageButton ( <"name">, <"parent">, <col>, <row>, "", <{action}>, ;
		<w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
		<.flat.>, <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, ;
		<.default.>, <icon>, <.extract.>, <idx>, <.noxpstyle.>, <"key">, <nId> )

#xcommand REDEFINE BUTTON <name> ;
      ID <nId> ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      PICTURE <bitmap> ;
      [ ICON <icon> [ <extract: EXTRACT> <idx> ] ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT> ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
    =>;
    _DefineImageButton ( <"name">, <"parent">, 0, 0, "",<{action}>, ;
		0, 0, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
		<.flat.>, <.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, ;
		<.default.>, <icon>, <.extract.>, <idx>, <.noxpstyle.>, , <nId> )


#xcommand @ <row>,<col> BUTTONEX <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ CAPTION <caption> ] ;
      [ PICTURE <bitmap> ] ;
      [ IMAGESIZE <imagewidth> , <imageheight> ] ;
      [ ICON <icon> ] ;
      [ <vertical : VERTICAL> ] ;
      [ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <font> ] ;
      [ SIZE <size> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ <lefttext : LEFTTEXT> ] ;
      [ <uptext : UPPERTEXT> ] ;
      [ <adjust : ADJUST> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ <nohotlight : NOHOTLIGHT> ] ;
      [ GRADIENTFILL <aGradInfo> [ <horizontal : HORIZONTAL> ] ] ;
      [ <flat: FLAT> ] ;
      [ <notrans: NOTRANSPARENT > ] ;
      [ <noxpstyle: NOXPSTYLE > ] ;
      [ <dummy3: ON GOTFOCUS,ON MOUSEHOVER> <gotfocus> ] ;
      [ <dummy4: ON LOSTFOCUS,ON MOUSELEAVE> <lostfocus> ] ;
      [ <handcursor: HANDCURSOR> ] ;
      [ <notabstop: NOTABSTOP> ] ;
      [ HELPID <helpid> ] ;
      [ <invisible: INVISIBLE> ] ;
      [ <default: DEFAULT> ] ;
   =>;
   _DefineOwnerButton ( <"name">, <"parent">, <col>, <row>, <caption>, <{action}>, ;
		<w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, <.flat.>, ;
		<.notrans.>, <helpid>, <.invisible.>, <.notabstop.>, <.default.>, <icon>, ;
		<font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
		<.vertical.>, <.lefttext.>, <.uptext.>, [ <backcolor> ], [ <fontcolor> ], ;
		<.nohotlight.>, <.noxpstyle.>, <.adjust.>, <.handcursor.>, <imagewidth>, <imageheight>, <aGradInfo>, <.horizontal.> )
