/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Property Sheet control source code
 (C)2008 Janusz Pora <januszpora@onet.eu>

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

#xcommand DEFINE PROPSHEET  <name>       ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      AT <row>,<col>  ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      < modal: MODAL >    ;
      [ CAPTION <caption> ];
      [ ICON <icon>];
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ DIALOGPROC <dlgproc> ] ;
      [ ON INIT <initproc> ] ;
      [ ON APPLY <applyproc> ] ;
      [ ON CANCEL <cancelproc> ] ;
      [ ON VALID <validproc> ] ;
=>;
_BeginPropSheet ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> ,;
               <caption> ,<icon>, <fontname> , <fontsize> , <{dlgproc}> , <{initproc}>,;
               <{applyproc}>, <{cancelproc}>, <{validproc}>, <.bold.>, <.italic.>, <.underline.>,;
               <.strikeout.>, <.modal.>, .f., 0, 0, .f. )

#xcommand DEFINE PROPSHEET  <name>       ;
   [ <dummy1: OF, PARENT> <parent> ] ;
      AT <row>,<col>  ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      <wizard: WIZARD>    ;
      [ <lite : LITE> ] ;
      [ CAPTION <caption> ];            //ignored in wizard
      [ ICON <icon>];
      [ WATERMARK <watermark> ];
      [ HEADERBMP <headerbmp> ];
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ DIALOGPROC <dlgproc> ] ;
      [ ON INIT <initproc> ] ;
      [ ON APPLY <applyproc> ] ;
      [ ON CANCEL <cancelproc> ] ;
      [ ON VALID <validproc> ] ;
=>;
_BeginPropSheet ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> , ;
               <caption> ,<icon>, <fontname> , <fontsize> , <{dlgproc}> , <{initproc}>,;
               <{applyproc}>, <{cancelproc}>, <{validproc}>, <.bold.>, <.italic.>, <.underline.>,;
               <.strikeout.>, .t., <.wizard.>, <watermark>, <headerbmp>, <.lite.> )

#xcommand DEFINE PROPSHEET  <name>       ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      AT <row>,<col>  ;
      [ WIDTH <width> ] ;
      [ HEIGHT <height> ] ;
      [ CAPTION <caption> ];
      [ ICON <icon>];
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold : BOLD> ] ;
      [ <italic : ITALIC> ] ;
      [ <underline : UNDERLINE> ] ;
      [ <strikeout : STRIKEOUT> ] ;
      [ DIALOGPROC <dlgproc> ] ;
      [ ON INIT <initproc> ] ;
      [ ON APPLY <applyproc> ] ;
      [ ON CANCEL <cancelproc> ] ;
      [ ON VALID <validproc> ] ;
=>;
_BeginPropSheet ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> ,;
               <caption> ,<icon>, <fontname> , <fontsize> , <{dlgproc}> , <{initproc}>,;
               <{applyproc}>, <{cancelproc}>, <{validproc}>, <.bold.>, <.italic.>, <.underline.>,;
               <.strikeout.>, .f., .f., 0, 0, .f. )



#xcommand SHEETPAGE <Name> RESOURCE <id> ;
      [ TITLE <cTitle> ];
      [ HEADER <chdtitle> ];
      [ SUBHEADER <csubhdtitle> ];
      [ <hideheader : HIDEHEADER > ];
=>;
_DefineSheetPage (  <"Name">, <id>, <cTitle>, <chdtitle>, <csubhdtitle>, <.hideheader.>  )

#xcommand DEFINE SHEETPAGE <Name> [ RESOURCE <id> ] ;
      [ TITLE <cTitle> ];
      [ HEADER <chdtitle> ];
      [ SUBHEADER <csubhdtitle> ];
      [ <hideheader : HIDEHEADER > ];
=>;
_BeginSheetPage (  <"Name">, <id>, <cTitle>, <chdtitle>, <csubhdtitle>, <.hideheader.>   )

#xcommand END SHEETPAGE ;
=>;
_EndSheetPage()

#xcommand END PROPSHEET ;
=>;
_EndPropSheet()


///////////////////////////////////////////////////////////////////////////////
