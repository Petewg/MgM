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
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2018, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#xcommand DEFINE STATUSBAR ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ <kbd: KEYBOARD> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
   => ;
   _BeginMessageBar( "StatusBar", <"parent">, <.kbd.>, <fontname>, <fontsize>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.> )

#xcommand  END STATUSBAR ;
   => ;
   _EndMessageBar ()

#xcommand STATUSITEM [ <cMsg> ] ;
          [ WIDTH <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ ICON <cBitmap> ] ;
          [ STYLE ] [ <style:FLAT,RAISED> ] ;
          [ TOOLTIP <cToolTip> ] ;
          [ BACKCOLOR <backcolor> ] ;
          [ FONTCOLOR <fontcolor> [ <c: CENTERALIGN> ] [ <r: RIGHTALIGN> ] ] ;
          [ <default: DEFAULT> ] ;
   => ;
   _DefineItemMessage( "STATUSITEM", , 0, 0, <cMsg>, <{uAction}>, <nSize>, 0, <cBitmap>, <"style">, <cToolTip>, <.default.>, <backcolor>, <fontcolor>, iif( <.r.> == .t., 2, iif( <.c.> == .t., 1, 0 ) ) )

#xcommand DATE ;
          [ <w: WIDTH> <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ TOOLTIP <cToolTip> ] ;
          [ BACKCOLOR <backcolor> ] ;
          [ FONTCOLOR <fontcolor> ] ;
   => ;
   _DefineItemMessage( "STATUSITEM", , 0, 0, Dtoc(Date()), <{uAction}>, iif( <.w.> == .f., iif( lower( left( set( _SET_DATEFORMAT ), 4 ) ) == "yyyy" .or. lower( right( set( _SET_DATEFORMAT ), 4 ) ) == "yyyy", 84, 70 ), <nSize> ), 0, "", , <cToolTip>, , <backcolor>, <fontcolor> )

#xcommand STATUSDATE ;
          [ <w: WIDTH> <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ TOOLTIP <cToolTip> ] ;
          [ BACKCOLOR <backcolor> ] ;
          [ FONTCOLOR <fontcolor> ] ;
   => ;
   _DefineItemMessage( "STATUSITEM", , 0, 0, Dtoc(Date()), <{uAction}>, iif( <.w.> == .f., iif( lower( left( set( _SET_DATEFORMAT ), 4 ) ) == "yyyy" .or. lower( right( set( _SET_DATEFORMAT ), 4 ) ) == "yyyy", 84, 70 ), <nSize> ), 0, "", , <cToolTip>, , <backcolor>, <fontcolor>, 1 )

#xcommand CLOCK ;
          [ WIDTH <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ TOOLTIP <cToolTip> ] ;
          [ <ampm: AMPM> ] ;
          [ BACKCOLOR <backcolor> ] ;
          [ FONTCOLOR <fontcolor> ] ;
   => ;
   _SetStatusClock( _HMG_ActiveMessageBarname , _HMG_ActiveFormName , <nSize> , <cToolTip> , <{uAction}> , <.ampm.> , <backcolor> , <fontcolor> )

#xcommand KEYBOARD ;
          [ WIDTH <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ TOOLTIP <cToolTip> ] ;
   => ;
   _SetStatusKeybrd( _HMG_ActiveMessageBarname , _HMG_ActiveFormName , <nSize> , <cToolTip> , <{uAction}> )

#xcommand PROGRESSITEM ;
          [ WIDTH <nSize> ] ;
          [ ACTION <uAction> ] ;
          [ TOOLTIP <cToolTip> ] ;
          [ RANGE <lo> , <hi> ] ;
          [ VALUE <v> ] ;
   => ;
   _SetStatusProgressMessage ( _HMG_ActiveMessageBarname, _HMG_ActiveFormName, <nSize>, <cToolTip>, <{uAction}>, <v>, <lo>, <hi> )

#xtranslate SET [ STATUSBAR ] PROGRESSITEM ;
          <dummy1: OF, PARENT> <parent> ;
          POSITION TO ;
          [ [ VALUE ] <v> ] ;
   => ;
   _SetStatusProgressPos ( <"parent"> , <v> )

#xtranslate SET [ STATUSBAR ] PROGRESSITEM ;
          <dummy1: OF, PARENT> <parent> ;
          RANGE TO ;
          [ <lo> , <hi> ] ;
   => ;
   _SetStatusProgressRange ( <"parent"> , <lo> , <hi> )

/* for using with _SetStatusItemProperty() */
#define STATUS_ITEM_WIDTH      1
#define STATUS_ITEM_ACTION     2
#define STATUS_ITEM_BACKCOLOR  3
#define STATUS_ITEM_FONTCOLOR  4
#define STATUS_ITEM_ALIGN      5

#xtranslate _SetStatusItemWidth( <item>, <value>, <ParentHandle> ) ;
   => ;
   _SetStatusItemProperty( <item>, <value>, <ParentHandle>, STATUS_ITEM_WIDTH )

#xtranslate _SetStatusItemAction( <item>, <value>, <ParentHandle> ) ;
   => ;
   _SetStatusItemProperty( <item>, <value>, <ParentHandle>, STATUS_ITEM_ACTION )
