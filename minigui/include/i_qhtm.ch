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

#command @ <row>,<col> QHTM <name> ;
		[ID <nId>] ;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE  <value> ]     ;
		[ FILE <fname> ]       ;
		[ RESOURCE <resname> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
		[ FONT <fontname> ]   ;
		[ SIZE <fontsize> ]   ;
		[ ON CHANGE <change> ] ;
		[ <border: BORDER> ] ;
	=>;
	_DefineQhtm ( <"name">, ;
                   <"parent">, ;
                   <row>, ;
                   <col>, ;
                   <w>, ;
                   <h> , ;
                   <value>, ;
                   <fname>, ;
                   <resname>, ;
                   <fontname>, ;
                   <fontsize>, ;
                   <{change}> , ;
                   <.border.>, ;
                   <nId> )


#command REDEFINE QHTM <name> ;
		ID <nId>;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE  <value> ]     ;
		[ FILE <fname> ]       ;
		[ RESOURCE <resname> ] ;
                [ FONT <fontname> ]   ;
                [ SIZE <fontsize> ]   ;
		[ ON CHANGE <change> ] ;
		[ <border: BORDER> ] ;
	=>;
	_DefineQhtm ( <"name">, ;
                   <"parent">, ;
                   0, 0, 0, 0, ;
                   <value>, ;
                   <fname>, ;
                   <resname>, ;
                   <fontname>,    ;
                   <fontsize>,    ;
                   <{change}> , ;
                   <.border.>, ;
                   <nId> )

/*----------------------------------------------------------------------------
QHTM
---------------------------------------------------------------------------*/

#xcommand DEFINE QHTM <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">	;;
   _HMG_ActiveControlOf      := Nil		;;
   _HMG_ActiveControlId		:= Nil		;;
   _HMG_ActiveControlCol               := Nil   ;;
   _HMG_ActiveControlRow               := Nil   ;;
   _HMG_ActiveControlWidth      := Nil		;;
   _HMG_ActiveControlHeight      := Nil		;;
   _HMG_ActiveControlValue             := ""    ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlOnChange          := ""	;;
   _HMG_ActiveControlBorder            := .f.


#xcommand END QHTM ;
   =>;
   _DefineQHTM (  ;
      _HMG_ActiveControlName, ;
      _HMG_ActiveControlOf, ;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlValue, ;
      _HMG_ActiveControlFile,;
      Nil, ;
      _HMG_ActiveControlFont, ;
      _HMG_ActiveControlSize, ;
      _HMG_ActiveControlOnChange, ;
      _HMG_ActiveControlBorder, ;
      _HMG_ActiveControlId )


// Get/Set position of scrolling

#define QHTM_GET_SCROLL_POS	( WM_USER + 6 )
#define QHTM_SET_SCROLL_POS	( WM_USER + 7 )

#translate QHTM_GetScrollPos( <nHandle> ) ;
        => SendMessage( <nHandle>, QHTM_GET_SCROLL_POS, 0, 0 ) 
#translate QHTM_SetScrollPos( <nHandle>, <nPos> ) ; 
        => SendMessage( <nHandle>, QHTM_SET_SCROLL_POS, <nPos>, 0 )
