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

#ifdef __SCRSAVERDATA__
  MEMVAR _HMG_SCRSAVERDATA
#endif

#xtranslate _ActiveScrSaverName			=> _HMG_SCRSAVERDATA\[1\]
#xtranslate _ScrSaverInstall			=> _HMG_SCRSAVERDATA\[2\]
#xtranslate _ScrSaverFileName			=> _HMG_SCRSAVERDATA\[3\]
#xtranslate _ScrSaverShow			=> _HMG_SCRSAVERDATA\[4\]
#xtranslate _ScrSaverConfig 			=> _HMG_SCRSAVERDATA\[5\]

#xcommand DEFINE SCREENSAVER ;
             WINDOW <Scr> ;
             MAIN ;
             [ <noshow: NOSHOW> ] ;
             [ ON INIT <InitProcedure> ] ;
             [ ON RELEASE <ReleaseProcedure> ] ;
             [ ON PAINT <PaintProcedure> [ INTERVAL <nInterval> ] ] ;
             [ BACKCOLOR <backcolor> ] ;
       => ;
		DECLARE WINDOW <Scr> ;;
		_BeginScrSaver( <"Scr">, <.noshow.>, ;
				<{InitProcedure}>, <{ReleaseProcedure}>, ;
				<{PaintProcedure}>, <nInterval>, [<backcolor>] )

#xcommand INSTALL SCREENSAVER ;
             <file: TO FILE, FILENAME> <cFileName> ;
             [ <lShow: SHOW> ] ;
       => ;
		_ScrSaverInstall := .t. ;;
		_ScrSaverFileName := <"cFileName"> ;;
		_ScrSaverShow := <.lShow.>

#xcommand CONFIGURE SCREENSAVER <ConfigProcedure> ;
       => ;
		_ScrSaverConfig := <{ConfigProcedure}>

#xcommand ACTIVATE SCREENSAVER ;
             WINDOW <name, ...> ;
             PARAMETERS <cParameters> ;
       => ;
		_ActivateScrSaver( \{<"name">\}, <cParameters> )
