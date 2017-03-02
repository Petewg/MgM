/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 02.10.2005 TIMEPICKER definition
 (C) Jacek Kubica <kubica@wssk.wroc.pl>
 HMG Experimental Build 10d

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

#command @ <row>,<col> TIMEPICKER <name> ;
      [ID <nId>];
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ VALUE <v> ] ;
      [ FIELD <field> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ TIMEFORMAT <cTimeFormat> ] ;
      [ < shownone: SHOWNONE > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ]      ;
      [ HELPID <helpid> ]       ;
      [ <invisible: INVISIBLE> ] ;
      [ <notabstop: NOTABSTOP> ] ;
   => ;
   _DefineTimePick ( <"name"> , ;
                     <"parent"> , ;
                     <col> , ;
                     <row> , ;
                     <w> , ;
                     <h> , ;
                     <v> , ;
                     <fontname> , ;
                     <fontsize> , ;
                     <tooltip> , ;
                     <{change}> , ;
                     <{lostfocus}> , ;
                     <{gotfocus}> , ;
                     <.shownone.> , ;
                     <helpid> , <.invisible.>, <.notabstop.>, ;
                     <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , ;
                     <"field"> , <{enter}>, <cTimeFormat>, ;
                     <nId> )


#command @ <row>,<col> DATEPICKER <name> ;
      [ID <nId>];
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ VALUE <v> ] ;
      [ FIELD <field> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ TITLEBACKCOLOR <titlebkclr> ] ;
      [ TITLEFONTCOLOR <titlefrclr> ] ;
      [ TRAILINGFONTCOLOR <trlfontclr> ] ;
      [ DATEFORMAT <cDateFormat> ] ;
      [ RANGE <lo> , <hi> ] ;
      [ < shownone: SHOWNONE > ] ;
      [ < updown: UPDOWN > ] ;
      [ < rightalign: RIGHTALIGN > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ]      ;
      [ HELPID <helpid> ]       ;
      [ <invisible: INVISIBLE> ] ;
      [ <notabstop: NOTABSTOP> ] ;
   => ;
   _DefineDatePick ( <"name"> , ;
                     <"parent"> , ;
                     <col> , ;
                     <row> , ;
                     <w> , ;
                     <h> , ;
                     <v> , ;
                     <fontname> , ;
                     <fontsize> , ;
                     <tooltip> , ;
                     <{change}> , ;
                     <{lostfocus}> , ;
                     <{gotfocus}> , ;
                     <.shownone.> , ;
                     <.updown.> , ;
                     <.rightalign.>  , <helpid> , <.invisible.>, <.notabstop.>, ;
                     <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , ;
                     <"field"> , <{enter}>, ;
                     [ <backcolor> ], ;
                     [ <fontcolor> ], ;
                     [ <titlebkclr> ], ;
                     [ <titlefrclr> ], ;
                     [ <trlfontclr> ], ;
                     <cDateFormat>, ;
                     <lo> , <hi> , ;
                     <nId> )


#command REDEFINE DATEPICKER <name> ;
      ID <nId> ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      [ VALUE <v> ] ;
      [ FIELD <field> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ TITLEBACKCOLOR <titlebkclr> ] ;
      [ TITLEFONTCOLOR <titlefrclr> ] ;
      [ TRAILINGFONTCOLOR <trlfontclr> ] ;
      [ DATEFORMAT <cDateFormat> ] ;
      [ RANGE <lo> , <hi> ] ;
      [ < shownone: SHOWNONE > ] ;
      [ < updown: UPDOWN > ] ;
      [ < rightalign: RIGHTALIGN > ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON ENTER <enter> ]      ;
      [ HELPID <helpid> ]       ;
      [ <invisible: INVISIBLE> ] ;
      [ <notabstop: NOTABSTOP> ] ;
   => ;
   _DefineDatePick ( <"name"> , ;
                     <"parent"> , ;
                     0 , ;
                     0 , ;
                     0 , ;
                     0 , ;
                     <v> , ;
                     <fontname> , ;
                     <fontsize> , ;
                     <tooltip> , ;
                     <{change}> , ;
                     <{lostfocus}> , ;
                     <{gotfocus}> , ;
                     <.shownone.> , ;
                     <.updown.> , ;
                     <.rightalign.>  , <helpid> , <.invisible.>, <.notabstop.>, ;
                     <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , ;
                     <"field"> , <{enter}>, ;
                     [ <backcolor> ], ;
                     [ <fontcolor> ], ;
                     [ <titlebkclr> ], ;
                     [ <titlefrclr> ], ;
                     [ <trlfontclr> ], ;
                     <cDateFormat>, ;
                     <lo> , <hi> , ;
                     <nId> )


#ifndef DTM_FIRST
#define DTM_FIRST        0x1000
#endif

#define DTM_SETMCCOLOR    (DTM_FIRST + 6)


#xtranslate SetDatePickFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, DTM_SETMCCOLOR, MCSC_TEXT, RGB( <r>, <g>, <b> ) )

#xtranslate SetDatePickBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, DTM_SETMCCOLOR, MCSC_MONTHBK, RGB( <r>, <g>, <b> ) )

#xtranslate SetDatePickTitleBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, DTM_SETMCCOLOR, MCSC_TITLEBK, RGB( <r>, <g>, <b> ) )

#xtranslate SetDatePickTitleFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, DTM_SETMCCOLOR, MCSC_TITLETEXT, RGB( <r>, <g>, <b> ) )

#xtranslate SetDatePickTrlFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, DTM_SETMCCOLOR, MCSC_TRAILINGTEXT, RGB( <r>, <g>, <b> ) )

