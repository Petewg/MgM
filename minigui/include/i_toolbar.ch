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

#xcommand  DEFINE TOOLBAR  <name> ;
      [ OF <parent> ]  [ PARENT <parent> ] ;
      [ CAPTION <caption> ];
      [ BUTTONSIZE <w> , <h> ] ;
      [ FONT <f> ] ;
      [ SIZE <s> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <bottom: BOTTOM> ] ;
      [ <righttext: RIGHTTEXT> ] ;
      [ <wrap : WRAP> ] ;
      [ GRIPPERTEXT <caption> ] ;
      [ <border : BORDER> ] ;
      [ <custom : CUSTOMIZE> ] ;
      [ <break: BREAK> ] ;
   => ;
   _BeginToolBar ( <"name">, <"parent">, , , <w>, <h>, <caption>, , <f>, <s>, <tooltip>, <.flat.>, <.bottom.>, <.righttext.>, <.break.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.border.>, <.wrap.>, <.custom.> )


#xcommand  DEFINE TOOLBAREX  <name> ;
      [ OF <parent> ]  [ PARENT <parent> ] ;
      [ CAPTION <caption> ];
      [ BUTTONSIZE <w> , <h> ] ;
      [ IMAGELIST <imagelst> ] ;
      [ HOTIMAGELIST <hotimagelst> ] ;
      [ FONT <f> ] ;
      [ SIZE <s> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ <flat: FLAT> ] ;
      [ <bottom: BOTTOM> ] ;
      [ <righttext: RIGHTTEXT> ] ;
      [ <wrap : WRAP> ] ;
      [ GRIPPERTEXT <caption> ] ;
      [ ROWS <r> ] ;
      [ TOOLBARSIZE <tbsize> ] ;
      [ <border : BORDER> ] ;
      [ <custom : CUSTOMIZE> ] ;
      [ <mixedbuttons: MIXEDBUTTONS> ] ;
      [ <break: BREAK> ] ;
   => ;
   _BeginToolBarEx ( <"name">, <"parent">, , , <w>, <h>, <caption>, , <f>, <s>, <tooltip>, <.flat.>, <.bottom.>, <.righttext.>, <.break.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.border.>, <.mixedbuttons.>, <r>, <tbsize>, <imagelst>, <hotimagelst>, <.wrap.>, <.custom.> )


#xcommand  END TOOLBAR ;
   => ;
   _EndToolBar ()


#xcommand BUTTON <name> ;
      [ CAPTION <caption> ] ;
      [ PICTURE  <bitmap> ] ;
      [ <adjust: ADJUST> ] ;
      [ TOOLTIP <tooltip> ]   ;
      [ <dummy1: ACTION,ON CLICK,ONCLICK> <action> ];
      [ <separator: SEPARATOR> ] ;
      [ <autosize: AUTOSIZE> ] ;
      [ <dropdown: DROPDOWN> ] ;
      [ <wholedropdown: WHOLEDROPDOWN> ] ;
      [ <check: CHECK> ] ;
      [ <group: GROUP> ] ;
   =>;
   _DefineToolButton ( <"name">, _HMG_ActiveToolBarName, , , <caption> , <{action}> , , , <bitmap> , <tooltip> , , , .f. , <.separator.> , <.autosize.> , <.check.> , <.group.> , <.dropdown.> , <.wholedropdown.> , <.adjust.>, -1 )


#xcommand BUTTON <name> ;
      [ CAPTION <caption> ] ;
      PICTUREINDEX <bitmapinx> ;
      [ <adjust: ADJUST> ] ;
      [ TOOLTIP <tooltip> ]   ;
      [ <dummy1: ACTION,ON CLICK,ONCLICK> <action> ];
      [ <separator: SEPARATOR> ] ;
      [ <autosize: AUTOSIZE> ] ;
      [ <dropdown: DROPDOWN> ] ;
      [ <wholedropdown: WHOLEDROPDOWN> ] ;
      [ <check: CHECK> ] ;
      [ <group: GROUP> ] ;
   =>;
   _DefineToolButton ( <"name">, _HMG_ActiveToolBarName, , , <caption> , <{action}> , , , '' , <tooltip> , , , .f. , <.separator.> , <.autosize.> , <.check.> , <.group.> , <.dropdown.> , <.wholedropdown.> , <.adjust.> , <bitmapinx> )


#define TB_ENABLEBUTTON   (WM_USER + 1)
#define RB_GETBANDCOUNT   (WM_USER + 12)
#define RB_GETBARHEIGHT   (WM_USER + 27)
#define RB_SHOWBAND       (WM_USER + 35)
#define TB_BUTTONCOUNT    (WM_USER + 24)
#define TB_CUSTOMIZE      (WM_USER + 27)


#xtranslate GetBandCount ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, RB_GETBANDCOUNT, 0, 0 )

#xtranslate ReBarHeight ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, RB_GETBARHEIGHT, 0, 0 )

#xtranslate SizeReBar ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, RB_SHOWBAND, 0, 0 ) ;;
SendMessage( <hWnd>, RB_SHOWBAND, 0, 1 )

#xtranslate GetButtonBarCount ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, TB_BUTTONCOUNT, 0, 0 )

#xtranslate CustomizeToolbar ( <hWnd> ) ;
=> ;
SendMessage( <hWnd>, TB_CUSTOMIZE, 0, 0 )

#xtranslate DisableToolButton ( <hWnd>, <id> ) ;
=> ;
SendMessage( <hWnd>, TB_ENABLEBUTTON, <id>, MAKELONG( 0, 0 ) )

#xtranslate EnableToolButton ( <hWnd>, <id> ) ;
=> ;
SendMessage( <hWnd>, TB_ENABLEBUTTON, <id>, MAKELONG( 1, 0 ) )
