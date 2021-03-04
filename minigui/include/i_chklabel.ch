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

#command @ <row>,<col> CHECKLABEL <name> ;
   [ID <nId>] ;
   [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
   [ VALUE <value> ] ;
   [ <dummy2: ACTION, ON CLICK, ONCLICK> <action> ] ;
   [ <dummy3: ON MOUSEHOVER, ONMOUSEHOVER> <overproc> ] ;
   [ <dummy4: ON MOUSELEAVE, ONMOUSELEAVE> <leaveproc> ] ;
   [ WIDTH <width> ] ;
   [ HEIGHT <height> ] ;
   [ <autosize : AUTOSIZE> ] ;
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ <dummy5: IMAGE,PICTURE> <acbitmap> ] ;
   [ <border: BORDER> ] ;
   [ <clientedge: CLIENTEDGE> ] ;
   [ <hscroll: HSCROLL> ] ;
   [ <vscroll: VSCROLL> ] ;
   [ <transparent: TRANSPARENT> ]   ;
   [ <rightalign: RIGHTALIGN> ]   ;
   [ <centeralign: CENTERALIGN> ]   ;
   [ <vcenteralign: VCENTERALIGN> ] ;
   [ <leftcheck: LEFTCHECK> ]   ;
   [ <lchecked: CHECKED> ]   ;
   [ FIELD <field> ] ;
   [ <blink: BLINK> ]  ;
   [ HELPID <helpid> ] ;
   [ <invisible: INVISIBLE> ] ;
   [ ON INIT <bInit> ] ;
=> ;
   _DefineChkLabel ( ;
   <(name)>,         ;
   <(parent)>,       ;
   <col>,            ;
   <row>,            ;
   <value>,          ;
   <width>,          ;
   <height>,         ;
   <fontname> ,      ;
   <fontsize> ,      ;
   <.bold.>,         ;
   <.border.> ,      ;
   <.clientedge.> ,  ;
   <.hscroll.> ,     ;
   <.vscroll.> ,     ;
   <.transparent.> , ;
   [ <backcolor> ],  ;
   [ <fontcolor> ],  ;
   <{action}>,       ;
   <tooltip>,        ;
   <helpid>,         ;
   <.invisible.>,    ;
   <.italic.>,       ;
   <.underline.>,    ;
   <.strikeout.> ,   ;
   <(field)> ,       ;
   <.autosize.> ,    ;
   <.rightalign.> ,  ;
   <.centeralign.> , ;
   <.blink.> ,       ;
   <{overproc}> ,    ;
   <{leaveproc}> ,   ;
   <acbitmap> ,      ;
   <.leftcheck.> ,   ;
   <.lchecked.> ,    ;
   <.vcenteralign.>, ;
   <nId> , <bInit> )

#command REDEFINE CHECKLABEL <name>  ;
   ID <nId> ;
   [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
   [ VALUE <value> ]   ;
   [ <dummy2: ACTION, ON CLICK, ONCLICK> <action> ] ;
   [ <autosize : AUTOSIZE> ] ;
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ <dummy3: IMAGE,PICTURE> <acbitmap> ] ;
   [ <border: BORDER> ]  ;
   [ <clientedge: CLIENTEDGE> ] ;
   [ <hscroll: HSCROLL> ] ;
   [ <vscroll: VSCROLL> ] ;
   [ <transparent: TRANSPARENT> ]   ;
   [ <rightalign: RIGHTALIGN> ]   ;
   [ <centeralign: CENTERALIGN> ]   ;
   [ <vcenteralign: VCENTERALIGN> ] ;
   [ <leftcheck: LEFTCHECK> ]   ;
   [ <lcheck: CHECKED> ]   ;
   [ FIELD <field> ] ;
   [ <blink: BLINK> ]  ;
   [ HELPID <helpid> ] ;
   [ <invisible: INVISIBLE> ] ;
   [ ON INIT <bInit> ] ;
=> ;
   _DefineChkLabel ( <(name)>, <(parent)>, 0, 0, <value>, ;
      0, 0, <fontname>, <fontsize>, <.bold.>, ;
      <.border.> , <.clientedge.> , <.hscroll.> , <.vscroll.> , ;
      <.transparent.> , [ <backcolor> ], [ <fontcolor> ], ;
      <{action}>, <tooltip>, <helpid>, <.invisible.>, <.italic.>, ;
      <.underline.> , <.strikeout.> , <(field)> , <.autosize.> , <.rightalign.> , ;
      <.centeralign.> , <.blink.> , , , <acbitmap>, <.leftcheck.>, <.lcheck.>, <.vcenteralign.>, ;
      <nId> , <bInit> )

/*-------------------------------------------------------------------------
Switcher pseudo-control
---------------------------------------------------------------------------*/

#command @ <row>,<col> SWITCHER <name> ;
   [ID <nId>] ;
   [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
   [ VALUE <value> ] ;
   [ <dummy2: ACTION, ON CLICK, ONCLICK> <action> ] ;
   [ <dummy3: ON MOUSEHOVER, ONMOUSEHOVER> <overproc> ] ;
   [ <dummy4: ON MOUSELEAVE, ONMOUSELEAVE> <leaveproc> ] ;
   [ WIDTH <width> ] ;
   [ HEIGHT <height> ] ;
   [ <autosize : AUTOSIZE> ] ;
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ <dummy5: IMAGE,PICTURE> <acbitmap> ] ;
   [ <border: BORDER> ] ;
   [ <clientedge: CLIENTEDGE> ] ;
   [ <hscroll: HSCROLL> ] ;
   [ <vscroll: VSCROLL> ] ;
   [ <transparent: TRANSPARENT> ]   ;
   [ <rightalign: RIGHTALIGN> ]   ;
   [ <centeralign: CENTERALIGN> ]   ;
   [ <vcenteralign: VCENTERALIGN> ] ;
   [ <leftcheck: LEFTCHECK> ]   ;
   [ <lchecked: CHECKED> ]   ;
   [ FIELD <field> ] ;
   [ <blink: BLINK> ]  ;
   [ HELPID <helpid> ] ;
   [ <invisible: INVISIBLE> ] ;
   [ ON INIT <bInit> ] ;
=> ;
   _DefineChkLabel ( ;
   <(name)>,         ;
   <(parent)>,       ;
   <col>,            ;
   <row>,            ;
   <value>,          ;
   <width>,          ;
   <height>,         ;
   <fontname> ,      ;
   <fontsize> ,      ;
   <.bold.>,         ;
   <.border.> ,      ;
   <.clientedge.> ,  ;
   <.hscroll.> ,     ;
   <.vscroll.> ,     ;
   <.transparent.> , ;
   [ <backcolor> ],  ;
   [ <fontcolor> ],  ;
   <{action}>,       ;
   <tooltip>,        ;
   <helpid>,         ;
   <.invisible.>,    ;
   <.italic.>,       ;
   <.underline.>,    ;
   <.strikeout.> ,   ;
   <(field)> ,       ;
   .T. ,             ;
   <.rightalign.> ,  ;
   <.centeralign.> , ;
   <.blink.> ,       ;
   <{overproc}> ,    ;
   <{leaveproc}> ,   ;
   <acbitmap> ,      ;
   <.leftcheck.> ,   ;
   <.lchecked.> ,    ;
   .T. ,             ;
   <nId> , <bInit> )
