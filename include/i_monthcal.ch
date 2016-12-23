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

#command @ <row>,<col> MONTHCALENDAR <name> ;
		[ ID <nId> ] ;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE <v> ] ;
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
		[ <dummy2: BACKGROUNDCOLOR, BKGNDCOLOR> <background> ] ;
		[ TRAILINGFONTCOLOR <trlfontclr> ] ;
		[ <notoday: NOTODAY> ] ;
		[ <notodaycircle: NOTODAYCIRCLE> ] ;
		[ <weeknumbers: WEEKNUMBERS> ] ;
		[ <invisible: INVISIBLE> ] ;
		[ <notabstop: NOTABSTOP> ] ;
		[ ON GOTFOCUS <gotfocus> ] ;
		[ ON CHANGE <change> ] ;
		[ ON LOSTFOCUS <lostfocus> ] ;
		[ ON SELECT <select> ] ;
		[ HELPID <helpid> ] ;
	=>;
	_DefineMonthCal ( <"name"> , ;
			<"parent"> , ;
			<col> , ;
			<row> , ;
			0 , ;
			0 , ;
			<v> , ;
			<fontname> , ;
			<fontsize> , ;
			<tooltip> , ;
			<.notoday.> , ;
			<.notodaycircle.> , ;
			<.weeknumbers.> , ;
			<{change}>, <helpid>, <.invisible.>, <.notabstop.>, ;
			<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
			[ <backcolor> ], ;
			[ <fontcolor> ], ;
			[ <titlebkclr> ], ;
			[ <titlefrclr> ], ;
			[ <background> ], ;
			[ <trlfontclr> ], ;
			<{select}> , <{gotfocus}> , <{lostfocus}> , <nId> )

#command REDEFINE MONTHCALENDAR <name> ;
		ID <nId> ;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE <v> ] ;
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
		[ BACKGROUNDCOLOR <background> ] ;
		[ TRAILINGFONTCOLOR <trlfontclr> ] ;
		[ <notoday: NOTODAY> ] ;
		[ <notodaycircle: NOTODAYCIRCLE> ] ;
		[ <weeknumbers: WEEKNUMBERS> ] ;
		[ <invisible: INVISIBLE> ] ;
		[ <notabstop: NOTABSTOP> ] ;
		[ ON GOTFOCUS <gotfocus> ] ;
		[ ON CHANGE <change> ] ;
		[ ON LOSTFOCUS <lostfocus> ] ;
		[ ON SELECT <select> ] ;
		[ HELPID <helpid> ] ;
	=>;
	_DefineMonthCal ( <"name"> , ;
			<"parent"> , ;
			0 , ;
			0 , ;
			0 , ;
			0 , ;
			<v> , ;
			<fontname> , ;
			<fontsize> , ;
			<tooltip> , ;
			<.notoday.> , ;
			<.notodaycircle.> , ;
			<.weeknumbers.> , ;
			<{change}> , <helpid>, <.invisible.>, <.notabstop.>, ;
			<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
			[ <backcolor> ], ;
			[ <fontcolor> ], ;
			[ <titlebkclr> ], ;
			[ <titlefrclr> ], ;
			[ <background> ], ;
			[ <trlfontclr> ], ;
			<{select}> , <{gotfocus}> , <{lostfocus}> , <nId> )

// set MonthCal colors
#define MCSC_BACKGROUND   0   // the background color (between months)
#define MCSC_TEXT         1   // the dates
#define MCSC_TITLEBK      2   // background of the title
#define MCSC_TITLETEXT    3
#define MCSC_MONTHBK      4   // background within the month cal
#define MCSC_TRAILINGTEXT 5   // the text color of header & trailing days

#define MCM_FIRST         0x1000

#define MCM_SETCOLOR          (MCM_FIRST + 10)
#define MCM_GETCOLOR          (MCM_FIRST + 11)

#define MCM_SETFIRSTDAYOFWEEK (MCM_FIRST + 15)
#define MCM_GETFIRSTDAYOFWEEK (MCM_FIRST + 16)

#xtranslate SetMonthCalBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_BACKGROUND, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_TEXT, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalTitleBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_TITLEBK, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalTitleFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_TITLETEXT, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalMonthBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_MONTHBK, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalTrlFontColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETCOLOR, MCSC_TRAILINGTEXT, RGB( <r>, <g>, <b> ) )

#xtranslate SetMonthCalFirstDayOfWeek ( <hWnd>, <d> ) ;
=> ;
SendMessage( <hWnd>, MCM_SETFIRSTDAYOFWEEK, 0, <d> )

#xtranslate GetMonthCalFirstDayOfWeek ( <hWnd> ) ;
=> ;
LOWORD( SendMessage( <hWnd>, MCM_GETFIRSTDAYOFWEEK, 0, 0 ) )

#xtranslate GetMonthCalYear ( <h> ) ;
=> ;
GetMonthCalValue( <h>, 1 )

#xtranslate GetMonthCalMonth ( <h> ) ;
=> ;
GetMonthCalValue( <h>, 2 )

#xtranslate GetMonthCalDay ( <h> ) ;
=> ;
GetMonthCalValue( <h>, 3 )
