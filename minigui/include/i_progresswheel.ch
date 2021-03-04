/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Copyright 2020 Grigory Filatov <gfilatov@inbox.ru>
 http://www.hmgextended.com

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

#command @ <row>,<col> PROGRESSWHEEL <name>	;
	[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
	[ RANGE <lo> , <hi> ] 		;
	[ VALUE <v> ]			;
	[ WIDTH <w> ] 			;
	[ HEIGHT <h> ] 			;
	[ <ShowText : SHOWTEXT> ]	;
	[ STARTANGLE <StartAngle> ] 	;
	[ INNERSIZE <InnerSize> ]	;
	[ GRADIENTMODE <GradientMode> ]	;
	[ COLORDONEMIN <ColorDoneMin> ]	;
	[ COLORDONEMAX <ColorDoneMax> ]	;
	[ COLORREMAIN <ColorRemain> ]	;
	[ COLORINNER <ColorInner> ]	;
   =>;
	_DefineProgressWheel ( <(name)>, <(parent)>, <col>, <row>, <w>, <h>, ;
		<v>, <StartAngle>, <InnerSize>, <GradientMode>, <ShowText>, <lo>, <hi>, ;
		<ColorDoneMin>, <ColorDoneMax>, <ColorRemain>, <ColorInner> )


/* for using with GradientMode property */
#define GM_NONE		1
#define GM_POSITION	2
#define GM_ANGLE	3
