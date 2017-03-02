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

///////////////////////////////////////////////////////////////////////////////
// ANIMATEBOX COMMANDS
///////////////////////////////////////////////////////////////////////////////
#command @ <row>,<col>  ANIMATEBOX <name> ;
            [ID <nId>];
			[ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
			WIDTH <w> ;
			HEIGHT <h> ;
			[ FILE <file> ] ;
			[ <autoplay: AUTOPLAY> ] ;
			[ <center : CENTER> ] ;
			[ <transparent: TRANSPARENT> ] ;
			[ <noborder: NOBORDER> ] ;
			[ HELPID <helpid> ] 		;
	=>;
    _DefineAnimateBox( <"name">, <"parent">, <col>, <row>, <w>, <h>, <.autoplay.>, <.center.>, <.transparent.>, <file>, <helpid>, !<.noborder.>, <nId> )

#command REDEFINE ANIMATEBOX <name> ;
    ID <nId>;
    [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
    [ FILE <file> ] ;
    [ <autoplay: AUTOPLAY> ] ;
    [ <center : CENTER> ] ;
    [ <transparent: TRANSPARENT> ] ;
    [ <noborder: NOBORDER> ] ;
    [ HELPID <helpid> ]         ;
    =>;
    _DefineAnimateBox( <"name">, <"parent">, 0, 0, 0, 0, <.autoplay.>, <.center.>, <.transparent.>, <file>, <helpid>, !<.noborder.>, <nId> )


#command OPEN ANIMATEBOX <ControlName> OF <ParentForm> FILE <FileName> ;
=> ;
_OpenAnimateBox ( <"ControlName"> , <"ParentForm"> , <FileName> )

#command PLAY ANIMATEBOX <ControlName> OF <ParentForm> ;
=> ;
_PlayAnimateBox ( <"ControlName"> , <"ParentForm"> )

#command SEEK ANIMATEBOX <ControlName> OF <ParentForm> POSITION <frame> ;
=> ;
_SeekAnimateBox ( <"ControlName"> , <"ParentForm"> , <frame> )

#command STOP ANIMATEBOX <ControlName> OF <ParentForm> ;
=> ;
_StopAnimateBox ( <"ControlName"> , <"ParentForm"> )

#command CLOSE ANIMATEBOX <ControlName> OF <ParentForm> ;
=> ;
_CloseAnimateBox ( <"ControlName"> , <"ParentForm"> )

#command DESTROY ANIMATEBOX <ControlName> OF <ParentForm> ;
=> ;
_DestroyAnimateBox ( <"ControlName"> , <"ParentForm"> )

#xtranslate OpenAnimateBox ( <ControlName> , <ParentForm> , <FileName> );
=> ;
_OpenAnimateBox ( <"ControlName"> , <"ParentForm"> , <FileName> )

#xtranslate PlayAnimateBox ( <ControlName> , <ParentForm> );
=> ;
_PlayAnimateBox ( <"ControlName"> , <"ParentForm"> )

#xtranslate SeekAnimateBox ( <ControlName> , <ParentForm> , <frame> );
=> ;
_SeekAnimateBox ( <"ControlName"> , <"ParentForm"> , <frame> )

#xtranslate StopAnimateBox ( <ControlName> , <ParentForm> );
=> ;
_StopAnimateBox ( <"ControlName"> , <"ParentForm"> )

#xtranslate CloseAnimateBox ( <ControlName> , <ParentForm> ) ;
=> ;
_CloseAnimateBox ( <"ControlName"> , <"ParentForm"> )

#xtranslate DestroyAnimateBox ( <ControlName> , <ParentForm> );
=> ;
_DestroyAnimateBox ( <"ControlName"> , <"ParentForm"> )
 
//////////////////////////////////////////////////////////////////////////////
// PLAYER COMMANDS
/////////////////////////////////////////////////////////////////////////////
#command @ <row>,<col>  PLAYER <name> ;
			[ <dummy1: OF, PARENT> <parent> ] ;
			WIDTH <w> ;
			HEIGHT <h> ;
                        FILE <file> ;
			[ <noautosizewindow: NOAUTOSIZEWINDOW> ] ;
			[ <noautosizemovie : NOAUTOSIZEMOVIE> ] ;
			[ <noerrordlg: NOERRORDLG> ] ;
			[ <nomenu: NOMENU> ] ;
			[ <noopen: NOOPEN> ] ;                             
			[ <noplaybar: NOPLAYBAR> ] ;                             
			[ <showall: SHOWALL> ] ;                             
			[ <showmode: SHOWMODE> ] ;                             
			[ <showname: SHOWNAME> ] ;                             
			[ <showposition: SHOWPOSITION> ] ;                             
			[ HELPID <helpid> ] 		;
	=>;
    _DefinePlayer( <"name">,<"parent">,<file>,<col>, <row>, <w>, <h>, <.noautosizewindow.>, <.noautosizemovie.>, <.noerrordlg.>,<.nomenu.>,<.noopen.>,<.noplaybar.>,<.showall.>,<.showmode.>,<.showname.>,<.showposition.>, <helpid> )

#command PLAY PLAYER <name> OF <parent> ;
	=> ;
	_PlayPlayer ( <"name"> , <"parent"> )

#xcommand PLAY PLAYER <name> OF <parent> REVERSE ;
	=> ;
	_PlayPlayerReverse ( <"name"> , <"parent"> )	

#command STOP PLAYER <name> OF <parent> ;
	=> ;
	_StopPlayer ( <"name"> , <"parent"> )	

#command PAUSE PLAYER <name> OF <parent> ;
	=> ;
	_PausePlayer ( <"name"> , <"parent"> )	

#command CLOSE PLAYER <name> OF <parent> ;
	=> ;
	_ClosePlayer ( <"name"> , <"parent"> )	

#command DESTROY PLAYER <name> OF <parent> ;
	=> ;
	_DestroyPlayer ( <"name"> , <"parent"> )	

#command EJECT PLAYER <name> OF <parent> ;
	=> ;
	_EjectPlayer ( <"name"> , <"parent"> )	

#command OPEN PLAYER <name> OF <parent> FILE <file> ;
	=> ;
	_OpenPlayer ( <"name"> , <"parent"> , <file> )	

#command OPEN PLAYER <name> OF <parent> DIALOG ;
	=> ;
	_OpenPlayerDialog ( <"name"> , <"parent"> )	

#command RESUME PLAYER <name> OF <parent> ;
	=> ;
	_ResumePlayer ( <"name"> , <"parent"> )	

#command SET PLAYER <name> OF <parent> POSITION HOME ;
	=> ;
	_SetPlayerPositionHome ( <"name"> , <"parent"> )	

#command SET PLAYER <name> OF <parent> POSITION END ;
	=> ;
	_SetPlayerPositionEnd ( <"name"> , <"parent"> )	

#command SET PLAYER <name> OF <parent> REPEAT ON ;
	=> ;
	_SetPlayerRepeatOn ( <"name"> , <"parent"> )	

#command SET PLAYER <name> OF <parent> REPEAT OFF ;
	=> ;
	_SetPlayerRepeatOff ( <"name"> , <"parent"> )	

#command SET PLAYER <name> OF <parent> SPEED <speed> ;
	=> ;
	_SetPlayerSpeed ( <"name"> , <"parent"> , <speed> )	

#command SET PLAYER <name> OF <parent> VOLUME <volume> ;
	=> ;
	_SetPlayerVolume ( <"name"> , <"parent"> , <volume> )	

#command SET PLAYER <name> OF <parent> ZOOM <zoom> ;
	=> ;
	_SetPlayerZoom ( <"name"> , <"parent"> , <zoom> )	

///////////////////////////////////////////////////////////////////////////////
// WAVE COMMANDS
//////////////////////////////////////////////////////////////////////////////
#command PLAY WAVE  <wave>  [<r:  FROM RESOURCE>] ;
                            [<s:  SYNC>];
                            [<ns: NOSTOP>] ;
                            [<l:  LOOP>] ;
                            [<nd: NODEFAULT>] ;
	=> playwave(<wave>,<.r.>,<.s.>,<.ns.>,<.l.>,<.nd.>)

#command STOP WAVE [ NODEFAULT ] => stopwave()
