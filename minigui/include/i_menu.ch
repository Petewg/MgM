/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 OWNERDRAW MENU definition
 (C) P.Chornyj <myorg63@mail.ru>
 HMG Extended Build 35

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

/* HMG 1.3 Extended Build 35 */

#define MNUCLR_MENUBARBACKGROUND1   1
#define MNUCLR_MENUBARBACKGROUND2   2
#define MNUCLR_MENUBARTEXT          3
#define MNUCLR_MENUBARSELECTEDTEXT  4
#define MNUCLR_MENUBARGRAYEDTEXT    5
#define MNUCLR_MENUBARSELECTEDITEM1 6
#define MNUCLR_MENUBARSELECTEDITEM2 7

#define MNUCLR_MENUITEMTEXT         8
#define MNUCLR_MENUITEMSELECTEDTEXT 9
#define MNUCLR_MENUITEMGRAYEDTEXT   10
#define MNUCLR_MENUITEMBACKGROUND1          11
#define MNUCLR_MENUITEMBACKGROUND2          12
#define MNUCLR_MENUITEMSELECTEDBACKGROUND1  13
#define MNUCLR_MENUITEMSELECTEDBACKGROUND2  14
#define MNUCLR_MENUITEMGRAYEDBACKGROUND1    15
#define MNUCLR_MENUITEMGRAYEDBACKGROUND2    16

#define MNUCLR_IMAGEBACKGROUND1     17
#define MNUCLR_IMAGEBACKGROUND2     18

#define MNUCLR_SEPARATOR1           19
#define MNUCLR_SEPARATOR2           20

#define MNUCLR_SELECTEDITEMBORDER1  21
#define MNUCLR_SELECTEDITEMBORDER2  22
#define MNUCLR_SELECTEDITEMBORDER3  23
#define MNUCLR_SELECTEDITEMBORDER4  24

#define MNUCLR_CHECKMARK            25
#define MNUCLR_CHECKMARKBACKGROUND  26
#define MNUCLR_CHECKMARKSQUARE      27
#define MNUCLR_CHECKMARKGRAYED      28


#define MNUCLR_THEME_DEFAULT      0
#define MNUCLR_THEME_XP           1
#define MNUCLR_THEME_2000         2
#define MNUCLR_THEME_DARK         3
#define MNUCLR_THEME_USER_DEFINED 99

#xcommand SET MENUSTYLE EXTENDED ;
=> ;
_NewMenuStyle ( .T. )

#xcommand SET MENUSTYLE STANDARD ;
=> ;
_NewMenuStyle ( .F. )

#translate IsExtendedMenuStyleActive () ;
=> ;
_NewMenuStyle ()

#xcommand SET MENUCURSOR FULL ;
=> ;
SetMenuCursorType( 0 )

#xcommand SET MENUCURSOR SHORT ;
=> ;
SetMenuCursorType( 1 )

#xcommand SET MENUSEPARATOR SINGLE LEFTALIGN ;
=> ;
SetMenuSeparatorType( 0, 0 )

#xcommand SET MENUSEPARATOR SINGLE CENTERALIGN ;
=> ;
SetMenuSeparatorType( 0, 1 )

#xcommand SET MENUSEPARATOR SINGLE RIGHTALIGN ;
=> ;
SetMenuSeparatorType( 0, 2 )

#xcommand SET MENUSEPARATOR DOUBLE LEFTALIGN ;
=> ;
SetMenuSeparatorType( 1, 0 )

#xcommand SET MENUSEPARATOR DOUBLE CENTERALIGN ;
=> ;
SetMenuSeparatorType( 1, 1 )

#xcommand SET MENUSEPARATOR DOUBLE RIGHTALIGN ;
=> ;
SetMenuSeparatorType( 1, 2 )

#xcommand SET MENUITEM BORDER 3D ;
=> ;
SetMenuSelectedItem3d( .T. )

#xcommand SET MENUITEM BORDER 3DSTYLE ;
=> ;
SetMenuSelectedItem3d( .T. )

#xcommand SET MENUITEM BORDER FLAT ;
=> ;
SetMenuSelectedItem3d( .F. )


#xcommand DEFINE MAIN MENU [ OF <parent> ] ;
=>;
_DefineMainMenu( <(parent)> )

#xcommand DEFINE MAINMENU [ <dummy1: OF, PARENT> <parent> ] ;
=>;
_DefineMainMenu( <(parent)> )

#xcommand DEFINE CONTEXT MENU [ OF <parent> ] ;
=>;
_DefineContextMenu( <(parent)> )

#xcommand DEFINE CONTEXTMENU [ <dummy1: OF, PARENT> <parent> ] ;
=>;
_DefineContextMenu( <(parent)> )

#xcommand SHOW CONTEXT MENU <dummy1: OF, PARENT> <parent> [ AT <nRow>, <nCol> ] ;
=> ;
_ShowContextMenu( <(parent)>, <nRow>, <nCol> )

#xcommand SHOW CONTEXTMENU <dummy1: OF, PARENT> <parent> [ AT <nRow>, <nCol> ] ;
=> ;
_ShowContextMenu( <(parent)>, <nRow>, <nCol> )

#xcommand DEFINE CONTEXT MENU CONTROL <control> [ OF <parent> ] ;
=> ;
_DefineControlContextMenu( <(control)> , <(parent)> )

#xcommand DEFINE CONTEXTMENU CONTROL <control> [ <dummy1: OF, PARENT> <parent> ] ;
=> ;
_DefineControlContextMenu( <(control)> , <(parent)> )

#xcommand DEFINE CONTEXT MENU CONTROLS <control1> [,<controln>] [ OF <parent> ] ;
=> ;
_DefineControlContextMenu( { <(control1)> [, <(controln)>] }, <(parent)> )

#xcommand DEFINE CONTEXTMENU CONTROLS <control1> [,<controln>] [<dummy1: OF, PARENT> <parent> ] ;
=> ;
_DefineControlContextMenu( { <(control1)> [, <(controln)>] }, <(parent)> )

#xcommand SET CONTEXT MENU CONTROL <control> OF <parent> ON ;
=> ;
_ShowControlContextMenu( <(control)> , <(parent)> , .T. )

#xcommand SET CONTEXTMENU CONTROL <control> OF <parent> ON ;
=> ;
_ShowControlContextMenu( <(control)> , <(parent)> , .T. )

#xcommand SET CONTEXT MENU CONTROL <control> OF <parent> OFF ;
=> ;
_ShowControlContextMenu( <(control)> , <(parent)> , .F. )

#xcommand SET CONTEXTMENU CONTROL <control> OF <parent> OFF ;
=> ;
_ShowControlContextMenu( <(control)> , <(parent)> , .F. )

#xcommand DEFINE NOTIFY MENU [ OF <parent> ] ;
=>;
_DefineNotifyMenu( <(parent)> )

#xcommand DEFINE NOTIFYMENU [ <dummy1: OF, PARENT> <parent> ] ;
=>;
_DefineNotifyMenu( <(parent)> )

#xcommand POPUP <caption> [ NAME <name> ] [ IMAGE <image> ] [ FONT <font> ] ;
=> ;
_DefineMenuPopup( <caption> , <(name)> , <image> , <font> )

#xcommand DEFINE POPUP <caption> [ NAME <name> ] [ IMAGE <image> ] [ FONT <font> ] ;
=> ;
_DefineMenuPopup( <caption> , <(name)> , <image> , <font> )

#xcommand DEFINE MENU POPUP <caption> [ NAME <name> ] [ IMAGE <image> ] [ FONT <font> ] ;
=> ;
_DefineMenuPopup( <caption> , <(name)> , <image> , <font> )

#xcommand ITEM <caption> [ ACTION <action> ] [ NAME <name> ] [ IMAGE <image> ] [ CHECKMARK <image1> ] [ FONT <font> ] ;
   [ <checked : CHECKED> ] [ MESSAGE <message> ] [ <disabled : DISABLED> ] [ <breakmenu : BREAKMENU> [ <separator : SEPARATOR> ] ] ;
   [ <default : DEFAULT> ] ;
=> ;
_DefineMenuItem ( <caption> , <{action}> , <(name)> , <image> , <.checked.> , <.disabled.> , <message>, <font>, <image1>, <.breakmenu.>, <.separator.>, , <.default.> )

#xcommand MENUITEM <caption> [ <dummy1: ACTION, ONCLICK> <action> ] [ NAME <name> ] [ IMAGE <image> ] [ CHECKMARK <image1> ] [ FONT <font> ] ;
   [ <checked : CHECKED> ] [ MESSAGE <message> ] [ <disabled : DISABLED> ] [ <breakmenu : BREAKMENU> [ <separator : SEPARATOR> ] ] ;
   [ <default : DEFAULT> ] ;
=> ;
_DefineMenuItem ( <caption> , <{action}> , <(name)> , <image> , <.checked.> , <.disabled.> , <message>, <font>, <image1>, <.breakmenu.>, <.separator.>, , <.default.> )

#xcommand ITEM <caption> [ ACTION <action> ] [ NAME <name> ] [ ICON <image> ] [ CHECKMARK <image1> ] [ FONT <font> ] ;
   [ <checked : CHECKED> ] [ MESSAGE <message> ] [ <disabled : DISABLED> ] [ <breakmenu : BREAKMENU> [ <separator : SEPARATOR> ] ] ;
   [ <default : DEFAULT> ] ;
=> ;
_DefineMenuItem ( <caption> , <{action}> , <(name)> , , <.checked.> , <.disabled.> , <message>, <font>, <image1>, <.breakmenu.>, <.separator.> , <image>, <.default.> )

#xcommand MENUITEM <caption> [ <dummy1: ACTION, ONCLICK> <action> ] [ NAME <name> ] [ ICON <image> ] [ CHECKMARK <image1> ] [ FONT <font> ] ;
   [ <checked : CHECKED> ] [ MESSAGE <message> ] [ <disabled : DISABLED> ] [ <breakmenu : BREAKMENU> [ <separator : SEPARATOR> ] ] ;
   [ <default : DEFAULT> ] ;
=> ;
_DefineMenuItem ( <caption> , <{action}> , <(name)> , , <.checked.> , <.disabled.> , <message>, <font>, <image1>, <.breakmenu.>, <.separator.> , <image>, <.default.> )

#xcommand SEPARATOR ;
=> ;
_DefineSeparator ()

#xcommand END POPUP ;
=> ;
_EndMenuPopup()

#xcommand END MENU ;
=> ;
_EndMenu()

#xcommand DEFINE DROPDOWN MENU BUTTON <button> [ OF <parent> ] ;
=>;
_DefineDropDownMenu( <(button)> , <(parent)> )

#xcommand DEFINE DROPDOWNMENU OWNERBUTTON <button> [ PARENT <parent> ] ;
=> ;
_DefineDropDownMenu( <(button)> , <(parent)> )

#command ENABLE MENUITEM <control> OF <form>;
=> ;
_EnableMenuItem ( <(control)> , <(form)> )

#command DISABLE MENUITEM <control> OF <form>;
=> ;
_DisableMenuItem ( <(control)> , <(form)> )

#command CHECK MENUITEM <control> OF <form>;
=> ;
_CheckMenuItem ( <(control)> , <(form)> )

#command UNCHECK MENUITEM <control> OF <form>;
=> ;
_UnCheckMenuItem ( <(control)> , <(form)> )

#command SET DEFAULT MENUITEM <control> OF <form>;
=> ;
_DefaultMenuItem ( <(control)> , <(form)> )

#xcommand MRU [ <caption> ] ;
	[ <Ini: INI, FILENAME, FILE, DISK> <cIniFile> ] ;
	[ SECTION <cSection> ] ;
	[ <size: SIZE, ITEMS> <nItems> ] ;
	[ ACTION <Action> ] ;
	[ NAME <name> ] ;
=> ;
_DefineMruItem ( <caption>, <cIniFile>, <cSection>, <nItems>, <"Action">, <(name)> )

#xcommand MRUITEM [ <caption> ] ;
	[ <Ini: INI, FILENAME, FILE, DISK> <cIniFile> ] ;
	[ SECTION <cSection> ] ;
	[ <size: SIZE, ITEMS> <nItems> ] ;
	[ ACTION <Action> ] ;
	[ NAME <name> ] ;
=> ;
_DefineMruItem ( <caption>, <cIniFile>, <cSection>, <nItems>, <"Action">, <(name)> )
