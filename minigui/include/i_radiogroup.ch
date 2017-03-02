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

#command @ <row>,<col> RADIOGROUP <name>	;
		[ID <aId>]		;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		OPTIONS <aOptions>	;
		[ VALUE <value> ]	;
		[ WIDTH <width> ] 	;
		[ SPACING <spacing> ] 	;
		[ FONT <fontname> ] 	;
		[ SIZE <fontsize> ]	;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]	;
		[ BACKCOLOR <backcolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ ON CHANGE <change> ]	;
		[ <transparent: TRANSPARENT> ] ;
		[ HELPID <helpid> ] 		;
		[ <invisible : INVISIBLE> ] ;
		[ <notabstop : NOTABSTOP> ] ;
		[ READONLY <aReadOnly> ] ;
		[ <horizontal : HORIZONTAL> ] ;
		[ <leftjustify : LEFTJUSTIFY> ] ;
	=>;
	_DefineradioGroup ( <"name">, <"parent">, <col>, <row>, <aOptions>, <value> , <fontname> , <fontsize> , <tooltip> , <{change}> , <width> , <spacing> , <helpid>, <.invisible.>, <.notabstop.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <backcolor> , <fontcolor> , <.transparent.> , <.horizontal.> , <.leftjustify.> , <aReadOnly> , <aId> )

#command REDEFINE RADIOGROUP <name>	;
		ID <aId>		;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		OPTIONS <aOptions>	;
		[ VALUE <value> ]	;
		[ SPACING <spacing> ] 	;
		[ FONT <fontname> ] 	;
		[ SIZE <fontsize> ]	;
		[ <bold : BOLD> ] ;
		[ <italic : ITALIC> ] ;
		[ <underline : UNDERLINE> ] ;
		[ <strikeout : STRIKEOUT> ] ;
		[ TOOLTIP <tooltip> ]	;
		[ BACKCOLOR <backcolor> ] ;
		[ FONTCOLOR <fontcolor> ] ;
		[ ON CHANGE <change> ]	;
		[ <transparent: TRANSPARENT> ] ;
		[ HELPID <helpid> ] 		;
		[ <invisible : INVISIBLE> ] ;
		[ <notabstop : NOTABSTOP> ] ;
		[ READONLY <aReadOnly> ] ;
		[ <horizontal : HORIZONTAL> ] ;
		[ <leftjustify : LEFTJUSTIFY> ] ;
	=>;
	_DefineradioGroup ( <"name">, <"parent">, 0, 0, <aOptions>, <value> , <fontname> , <fontsize> , <tooltip> , <{change}> , 0 , <spacing> , <helpid>, <.invisible.>, <.notabstop.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <backcolor> , <fontcolor> , <.transparent.> , <.horizontal.> , <.leftjustify.> , <aReadOnly> , <aId> )

