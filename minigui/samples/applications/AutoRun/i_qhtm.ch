/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://harbour-project.org

	"Harbour Project"
	Copyright 1999-2003, http://harbour-project.org/
---------------------------------------------------------------------------*/

#command @ <row>,<col> QHTM <name> ;
		[ID <nId>] ;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE  <value> ]     ;
		[ FILE <fname> ]       ;
		[ RESOURCE <resname> ] ;
		[ WIDTH <w> ] ;
		[ HEIGHT <h> ] ;
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
                   <{change}> , ;
                   <.border.>, ;
                   <nId> )


#command REDEFINE QHTM <name> ;
		ID <nId>;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ VALUE  <value> ]     ;
		[ FILE <fname> ]       ;
		[ RESOURCE <resname> ] ;
		[ ON CHANGE <change> ] ;
		[ <border: BORDER> ] ;
	=>;
	_DefineQhtm ( <"name">, ;
                   <"parent">, ;
                   0, 0, 0, 0, ;
                   <value>, ;
                   <fname>, ;
                   <resname>, ;
                   <{change}> , ;
                   <.border.>, ;
                   <nId> )

/*----------------------------------------------------------------------------
QHTM
---------------------------------------------------------------------------*/

#xcommand DEFINE QHTM <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId		:= Nil		;;
   _HMG_ActiveControlCol               := Nil          ;;
   _HMG_ActiveControlRow               := Nil          ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlValue             := ""          ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlOnChange          := ""           ;;
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
      _HMG_ActiveControlOnChange, ;
      _HMG_ActiveControlBorder, ;
      _HMG_ActiveControlId )
