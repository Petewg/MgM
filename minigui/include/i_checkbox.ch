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
	Copyright 1999-2020, https://harbour.github.io/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#command @ <row>,<col> CHECKBOX <name> ;
        [ID <nId> ];
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		CAPTION <caption> ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		[ FIELD <field> ] ;
		[ VALUE <value> ] ;
		[ <autosize : AUTOSIZE> ] ;
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
		[ ON CHANGE <change> ] ;
		[ ON LOSTFOCUS <lostfocus> ] ;
		[ ON ENTER <enter> ] ;
		[ <transparent: TRANSPARENT> ] ;
		[ <multiline: MULTILINE> ] ;
		[ HELPID <helpid> ] ;
		[ <invisible: INVISIBLE> ] ;
		[ <notabstop: NOTABSTOP> ] ;
		[ <leftjustify: LEFTJUSTIFY> ] ;
		[ <threestate : THREESTATE> ] ;
		[ ON INIT <bInit> ] ;
	=>;
	_DefineCheckBox ( <(name)>, <(parent)>, <col>, <row>, <caption>, <value> , <f> , <n> , <tooltip> , <{change}> , [<w>] , [<h>] , <{lostfocus}>, <{gotfocus}>  , <helpid>, <.invisible.>, <.notabstop.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <(field)> , <backcolor> , <fontcolor> , <.transparent.> , <.leftjustify.> , <.threestate.> , <{enter}> , <.autosize.> , <.multiline.> , <nId> , <bInit> )


#command REDEFINE CHECKBOX <name> ;
	ID <nId>;
	[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
	[ CAPTION <caption> ] ;
	[ FIELD <field> ] ;
	[ VALUE <value> ] ;
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
	[ ON CHANGE <change> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ ON ENTER <enter> ] ;
	[ <transparent: TRANSPARENT> ] ;
	[ HELPID <helpid> ] ;
	[ <invisible: INVISIBLE> ] ;
	[ <notabstop: NOTABSTOP> ] ;
	[ <leftjustify: LEFTJUSTIFY> ] ;
	[ <threestate : THREESTATE> ] ;
	[ ON INIT <bInit> ] ;
    =>;
	_DefineCheckBox ( <(name)>, <(parent)>, 0, 0, <caption>, <value> , <f> , <n> , <tooltip> , <{change}> , 0 , 0 , <{lostfocus}>, <{gotfocus}> , <helpid>, <.invisible.>, <.notabstop.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <(field)> , <backcolor> , <fontcolor> , <.transparent.> , <.leftjustify.> , <.threestate.> , <{enter}> , .f. , .f. , <nId> , <bInit> )


#command @ <row>,<col> CHECKBUTTON <name> ;
        [ID <nId>] ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		CAPTION <caption>  ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		[ VALUE <value> ] ;
		[ FONT <f> ] ;
		[ SIZE <n> ] ;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ] ;
		[ ON GOTFOCUS <gotfocus> ] ;
		[ ON CHANGE <change> ] ;
		[ ON LOSTFOCUS <lostfocus> ] ;
		[ HELPID <helpid> ] 		;
		[ <invisible: INVISIBLE> ] ;
		[ <notabstop: NOTABSTOP> ] ;
	=>;
	_DefineCheckButton ( <(name)>, <(parent)>, <col>, <row>, <caption>, <value> ,<f> ,<n> , <tooltip> , <{change}> , [<w>] , [<h>] , <{lostfocus}>, <{gotfocus}>  , <helpid>, <.invisible.>, <.notabstop.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <nId> )


#command REDEFINE CHECKBUTTON <name> ;
    ID <nId>;
    [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
    CAPTION <caption>  ;
    [ VALUE <value> ] ;
    [ FONT <f> ] ;
    [ SIZE <n> ] ;
    [ <bold : BOLD> ] ;
    [ <italic : ITALIC> ] ;
    [ <underline : UNDERLINE> ] ;
    [ <strikeout : STRIKEOUT> ] ;
    [ TOOLTIP <tooltip> ] ;
    [ ON GOTFOCUS <gotfocus> ] ;
    [ ON CHANGE <change> ] ;
    [ ON LOSTFOCUS <lostfocus> ] ;
    [ HELPID <helpid> ]         ;
    [ <invisible: INVISIBLE> ] ;
    [ <notabstop: NOTABSTOP> ] ;
    =>;
	_DefineCheckButton ( <(name)>, <(parent)>, 0, 0, <caption>, <value> ,<f> ,<n> , <tooltip> , <{change}> , 0 , 0 , <{lostfocus}>, <{gotfocus}>  , <helpid>, <.invisible.>, <.notabstop.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <nId>)



#command @ <row>,<col> CHECKBUTTON <name> ;
        [ID <nId>] ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		PICTURE <bitmap> ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		[ VALUE <value> ] ;
		[ TOOLTIP <tooltip> ] ;
		[ ON GOTFOCUS <gotfocus> ] ;
		[ ON CHANGE <change> ] ;
		[ ON LOSTFOCUS <lostfocus> ] ;
		[ HELPID <helpid> ] 		;
		[ <invisible: INVISIBLE> ] ;
		[ <notabstop: NOTABSTOP> ] ;
	=>;
	_DefineImageCheckButton ( <(name)>, <(parent)>, <col>, <row>, <bitmap>, <value> ,"" ,0 , <tooltip> , <{change}> , [<w>] , [<h>] , <{lostfocus}>, <{gotfocus}> , <helpid>, <.invisible.>, <.notabstop.>, <nId> )


#command REDEFINE CHECKBUTTON <name> ;
    ID <nId>;
    [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
    PICTURE <bitmap> ;
    [ VALUE <value> ] ;
    [ TOOLTIP <tooltip> ] ;
    [ ON GOTFOCUS <gotfocus> ] ;
    [ ON CHANGE <change> ] ;
    [ ON LOSTFOCUS <lostfocus> ] ;
    [ HELPID <helpid> ]         ;
    [ <invisible: INVISIBLE> ] ;
    [ <notabstop: NOTABSTOP> ] ;
    =>;
	_DefineImageCheckButton ( <(name)>, <(parent)>, 0, 0, <bitmap>, <value> ,"" ,0 , <tooltip> , <{change}> , 0 , 0 , <{lostfocus}>, <{gotfocus}> , <helpid>, <.invisible.>, <.notabstop.>, <nId> )
