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

#define BROWSE_JTFY_LEFT        	0
#define BROWSE_JTFY_RIGHT       	1
#define BROWSE_JTFY_CENTER      	2
#define BROWSE_JTFY_JUSTIFYMASK 	3

#translate MemVar . <AreaName> . <FieldName> =>  MemVar<AreaName><FieldName>
///////////////////////////////////////////////////////////////////////////////
// STANDARD BROWSE
///////////////////////////////////////////////////////////////////////////////

#command @ <row>,<col> BROWSE <name>			;
		[ ID <nId> ]				;
		[ <dummy1: OF,PARENT,DIALOG> <parent> ] ;
		[ WIDTH <w> ] 				;
		[ HEIGHT <h> ] 				;
		[ HEADERS <headers> ] 			;
		[ WIDTHS <widths> ] 			;
		[ WORKAREA <workarea> ]			;
		[ FIELDS <Fields> ] 			;
		[ VALUE <value> ] 			;
		[ FONT <fontname> ] 			;
		[ SIZE <fontsize> ] 			;
		[ <bold : BOLD> ]			;
		[ <italic : ITALIC> ]			;
		[ <underline : UNDERLINE> ]		;
		[ <strikeout : STRIKEOUT> ]		;
		[ TOOLTIP <tooltip> ]			;
		[ BACKCOLOR <backcolor> ]		;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ]		;
		[ ON GOTFOCUS <gotfocus> ]		;
		[ ON CHANGE <change> ]  		;
		[ ON LOSTFOCUS <lostfocus> ] 		;
		[ ON DBLCLICK <dblclick> ]  		;
		[ <edit : EDIT> ] 			;
		[ <inplace : INPLACE> ]			;
		[ <append : APPEND, ALLOWAPPEND> ]	;
		[ INPUTITEMS <inputitems> ]		;
		[ DISPLAYITEMS <displayitems> ]		;
		[ ON HEADCLICK <aHeadClick> ] 		;
		[ <d2: WHEN, COLUMNWHEN> <aWhenFields> ];
		[ <d3: VALID, COLUMNVALID> <aValidFields> ];
		[ VALIDMESSAGES <aValidMessages> ]	;
		[ READONLY <aReadOnly> ] 		;
		[ <lock: LOCK> ] 			;
		[ <Delete: DELETE, ALLOWDELETE> ]	;
		[ <style: NOLINES> ] 			;
		[ IMAGE <aImage> ] 			;
		[ JUSTIFY <aJust> ] 			;
		[ <novscroll: NOVSCROLL> ] 		;
		[ HELPID <helpid> ] 			;
		[ <break: BREAK> ] 			;
		[ COLUMNSORT <columnsort> ]		;
		[ HEADERIMAGE <aImageHeader> ]		;
		[ <doublebuffer: PAINTDOUBLEBUFFER> ]	;
		[ <notabstop: NOTABSTOP> ]		;
		[ ON INIT <bInit> ] ;
		[ PICTURE <aPict> ] ;         // add  jsz
	=>;
   _DefineBrowse ( <(name)> , 		;
		<(parent)> , 		;
		<col> ,			;
		<row> ,			;
		<w> , 			;
		<h> , 			;
		<headers> , 		;
		<widths> , 		;
		<Fields> , 		;
		<value> ,		;
		<fontname> , 		;
		<fontsize> , 		;
		<tooltip> , 		;
		<{change}> ,		;
		<{dblclick}> ,  	;
		<aHeadClick> ,  	;
		<{gotfocus}> ,		;
		<{lostfocus}>, 		;
		<(workarea)> ,		;
		<.Delete.>,  		;
		<.style.> ,		;
		<aImage> ,		;
		<aJust> ,		;
		<helpid> ,		;
		<.bold.> ,		;
		<.italic.> ,		;
		<.underline.> , 	;
		<.strikeout.> , 	;
		<.break.>  ,		;
		<backcolor> ,		;
		<fontcolor> ,		;
		<.lock.> ,		;
		<.inplace.> ,		;
		<.novscroll.> , 	;
		<.append.> ,		;
		<aReadOnly> ,		;
		<aValidFields> ,	;
		<aValidMessages> ,	;
		<.edit.> ,		;
		<dynamicforecolor> ,	;
		<dynamicbackcolor> ,	;
		<aWhenFields>,		;
		<nId>,			;
		<aImageHeader>, 	;
		<.notabstop.> ,		;
		<inputitems> ,		;
		<displayitems> ,	;
		<.doublebuffer.> ,	;
		<columnsort> ,		;
		<bInit>,		;
		<aPict> )    // add jsz

#command REDEFINE BROWSE <name> 		;
        ID <nId> ;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ WORKAREA <workarea> ]		;
		[ FIELDS <Fields> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ]		;
		[ <italic : ITALIC> ]		;
		[ <underline : UNDERLINE> ]	;
		[ <strikeout : STRIKEOUT> ]	;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ]	;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ]	;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ <edit : EDIT> ] 		;
		[ <inplace : INPLACE> ]		;
		[ <append : APPEND> ] 		;
		[ INPUTITEMS <inputitems> ]	;
		[ DISPLAYITEMS <displayitems> ]	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ WHEN <aWhenFields> ]		;
		[ VALID <aValidFields> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ READONLY <aReadOnly> ] 	;
		[ <lock: LOCK> ] 		;
		[ <Delete: DELETE> ]		;
		[ <style: NOLINES> ] 		;// Browse+
		[ IMAGE <aImage> ] 		;// Browse+
		[ JUSTIFY <aJust> ] 		;// Browse+
		[ <novscroll: NOVSCROLL> ] 	;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ HEADERIMAGE <aImageHeader> ]	;// Browse+
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ <notabstop: NOTABSTOP> ]	;
		[ ON INIT <bInit> ] ;
		[ PICTURE <aPict> ] ;   // add jsz
	=>;
   _DefineBrowse ( <(name)> , 	;
		<(parent)> , 	;
		0 ,		;
		0 ,		;
		0 , 		;
		0 , 		;
		<headers> , 	;
		<widths> , 	;
		<Fields> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,  ;
		<{gotfocus}> ,	;
		<{lostfocus}>, 	;
		<(workarea)> ,	;
		<.Delete.>,  	;
		<.style.> ,	;
		<aImage> ,	;
		<aJust> ,	;
		<helpid> ,	;
		<.bold.> ,	;
		<.italic.> ,	;
		<.underline.> , ;
		<.strikeout.> , ;
		<.break.> ,	;
		<backcolor> ,	;
		<fontcolor> ,	;
		<.lock.> ,	;
		<.inplace.> ,	;
		<.novscroll.> , ;
		<.append.> ,	;
		<aReadOnly> ,	;
		<aValidFields> , ;
		<aValidMessages> , ;
		<.edit.> ,	;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<aWhenFields>, <nId>, ;
		<aImageHeader>, ;
		<.notabstop.> , ; 
		<inputitems> , ;
		<displayitems> , ;
		<.doublebuffer.> , ; 
		<columnsort> , ;
		<bInit> , ;
		<aPict> )     // add jsz

///////////////////////////////////////////////////////////////////////////////
// SPLITBOX BROWSE
///////////////////////////////////////////////////////////////////////////////
#command BROWSE <name>				;
		[ OF <parent> ] 		;
		[ WIDTH <w> ] 			;
		[ HEIGHT <h> ] 			;
		[ HEADERS <headers> ] 		;
		[ WIDTHS <widths> ] 		;
		[ WORKAREA <WorkArea> ]		;
		[ FIELDS <Fields> ] 		;
		[ VALUE <value> ] 		;
		[ FONT <fontname> ] 		;
		[ SIZE <fontsize> ] 		;
		[ <bold : BOLD> ]		;
		[ <italic : ITALIC> ]		;
		[ <underline : UNDERLINE> ]	;
		[ <strikeout : STRIKEOUT> ]	;
		[ TOOLTIP <tooltip> ]  		;
		[ BACKCOLOR <backcolor> ]	;
		[ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
		[ DYNAMICFORECOLOR <dynamicforecolor> ] ;
		[ FONTCOLOR <fontcolor> ]	;
		[ ON GOTFOCUS <gotfocus> ] 	;
		[ ON CHANGE <change> ]  	;
		[ ON LOSTFOCUS <lostfocus> ] 	;
		[ ON DBLCLICK <dblclick> ]  	;
		[ <edit : EDIT> ] 		;
		[ <inplace : INPLACE> ]		;
		[ <append : APPEND> ] 		;
		[ INPUTITEMS <inputitems> ]	;
		[ DISPLAYITEMS <displayitems> ]	;
		[ ON HEADCLICK <aHeadClick> ] 	;
		[ WHEN <aWhenFields> ]		;
		[ VALID <aValidFields> ]	;
		[ VALIDMESSAGES <aValidMessages> ] ;
		[ READONLY <aReadOnly> ] 	;
		[ <lock: LOCK> ] 		;
		[ <Delete: DELETE> ]		;
		[ <style: NOLINES> ] 		;// Browse+
		[ IMAGE <aImage> ] 		;// Browse+
		[ JUSTIFY <aJust> ] 		;// Browse+
		[ <novscroll: NOVSCROLL> ] 	;
		[ HELPID <helpid> ] 		;
		[ <break: BREAK> ] 		;
		[ COLUMNSORT <columnsort> ]	;
		[ HEADERIMAGE <aImageHeader> ]	;// Browse+
		[ <doublebuffer: PAINTDOUBLEBUFFER> ] ;
		[ <notabstop: NOTABSTOP> ]	;
		[ ON INIT <bInit> ] ;
		[ PICTURE <aPict> ] ;    // add jsz
	=>;
   _DefineBrowse ( <(name)> , 	;
		<(parent)> , 	;
		 ,		;
		 ,		;
		<w> , 		;
		<h> , 		;
		<headers> , 	;
		<widths> , 	;
		<Fields> , 	;
		<value> ,	;
		<fontname> , 	;
		<fontsize> , 	;
		<tooltip> , 	;
		<{change}> ,	;
		<{dblclick}> ,  ;
		<aHeadClick> ,  ;
		<{gotfocus}> ,	;
		<{lostfocus}>, 	;
		<(WorkArea)> ,	;
		<.Delete.>,  	;
		<.style.> ,	;
		<aImage> ,	;
		<aJust> ,	;
		<helpid> ,	;
		<.bold.> ,	;
		<.italic.> ,	;
		<.underline.> , ;
		<.strikeout.> , ;
		<.break.> ,	;
		<backcolor> ,	;
		<fontcolor> ,	;
		<.lock.> ,	;
		<.inplace.> ,	;
		<.novscroll.> , ;
		<.append.> ,	;
		<aReadOnly> ,	;
		<aValidFields> , ;
		<aValidMessages> , ;
		<.edit.> ,	;
		<dynamicforecolor> , ;
		<dynamicbackcolor> , ;
		<aWhenFields>, 0, ;
		<aImageHeader>, ;
		<.notabstop.> , ;
		<inputitems> , ;
		<displayitems> , ;
		<.doublebuffer.> , ; 
		<columnsort> , ;
		<bInit> , ;
		<aPict> )   // add jsz

#xcommand SET BROWSESYNC <x:ON,OFF> => _HMG_BrowseSyncStatus := ( Upper(<(x)>) == "ON" )

#xcommand SET BROWSEUPDATEONCLICK <x:ON,OFF> => _HMG_BrowseUpdateStatus := ( Upper(<(x)>) == "ON" )
