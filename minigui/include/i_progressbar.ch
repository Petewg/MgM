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

#command @ <row>,<col> PROGRESSBAR <name>	;
        [ID <nId>];
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ RANGE <lo> , <hi> ] 		;
		[ VALUE <v> ]			;
		[ WIDTH <w> ] 			;
		[ HEIGHT <h> ] 			;
		[ TOOLTIP <tooltip> ] 		;
		[ <vertical : VERTICAL> ]	;
		[ <smooth : SMOOTH> ]		;
		[ HELPID <helpid> ] 		;
		[ <invisible : INVISIBLE> ]	;
		[ BACKCOLOR <backcolor> ]	;
		[ FORECOLOR <barcolor> ]	;
		[ STYLE ] [ <style : MARQUEE>	;
		[ VELOCITY <velocity> ] ]	;
		[ ON INIT <bInit> ]		;
	=>;
	_DefineProgressBar ( <(name)>, <(parent)>, <col>, <row>, <w>, <h>, ;
                        <lo>, <hi>, <tooltip>, <.vertical.>, <.smooth.>, ;
                        <helpid>, <.invisible.>, <v>, [ <backcolor> ], [ <barcolor> ], <.style.>, <velocity>, <nId>, <bInit> )


#command REDEFINE PROGRESSBAR <name>	;
        ID <nId>;
		[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
		[ RANGE <lo> , <hi> ] 		;
		[ VALUE <v> ]			;
		[ TOOLTIP <tooltip> ] 		;
		[ <vertical : VERTICAL> ]	;
		[ <smooth : SMOOTH> ]		;
		[ HELPID <helpid> ] 		;
		[ <invisible : INVISIBLE> ]	;
		[ BACKCOLOR <backcolor> ]	;
		[ FORECOLOR <barcolor> ]	;
		[ ON INIT <bInit> ]		;
	=>;
	_DefineProgressBar ( <(name)>, <(parent)>, 0, 0, 0, 0, ;
                        <lo>, <hi>, <tooltip>, <.vertical.>, <.smooth.>, ;
                        <helpid>, <.invisible.>, <v>, [ <backcolor> ], [ <barcolor> ], .F. , , <nId> , <bInit> )


// Common control shared messages
#define CCM_FIRST               0x2000

#define CCM_SETBKCOLOR          (CCM_FIRST + 1)

#define PBM_SETRANGE            (WM_USER+1)
#define PBM_SETBKCOLOR          CCM_SETBKCOLOR
#define PBM_SETBARCOLOR         (WM_USER+9)


#xtranslate SetProgressbarBkColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, PBM_SETBKCOLOR, 0, RGB( <r>, <g>, <b> ) )

#xtranslate SetProgressbarBarColor ( <hWnd>, <r>, <g>, <b> ) ;
=> ;
SendMessage( <hWnd>, PBM_SETBARCOLOR, 0, RGB( <r>, <g>, <b> ) )

#xtranslate SetProgressBarRange ( <hWnd>, <l>, <b> ) ;
=> ;
SendMessage( <hWnd>, PBM_SETRANGE, 0, MAKELONG( <l>, <b> ) )
