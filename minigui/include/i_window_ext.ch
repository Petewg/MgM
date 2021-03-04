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

#xcommand DEFINE WINDOW <w> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	[ AT <row>,<col> ] ;
	[ ROW <row> ] ;
	[ COL <col> ] ;
	[ WIDTH <wi> ] ;
	[ HEIGHT <h> ] ;
	[ MINWIDTH <minWidth> ] ;
	[ MINHEIGHT <minHeight> ] ;
	[ MAXWIDTH <maxWidth> ] ;
	[ MAXHEIGHT <maxHeight> ] ;
	[ VIRTUALWIDTH <vWidth> ] ;                             
	[ VIRTUALHEIGHT <vHeight> ] ;                             
	[ CLIENTAREA <clientwidth>,<clientheight> ] ;
	[ TITLE <title> ] ;
	[ ICON <icon> ] ;
	WINDOWTYPE ;
	[ <main:  MAIN> ] ;
	[ <mdi:   MDI> ] ;
	[ <child: CHILD> ] ;
	[ <panel: PANEL> ] ;
	[ STANDARD ] ;
	[ <noshow: NOSHOW> ] ;
	[ <topmost: TOPMOST> ] ;
	[ <palette: PALETTE> ] ;
	[ <noautorelease: NOAUTORELEASE> ] ;
	[ <nominimize: NOMINIMIZE> ] ;
	[ <nomaximize: NOMAXIMIZE> ] ;
	[ <nosize: NOSIZE> ] ;
	[ <nosysmenu: NOSYSMENU> ] ;                             
	[ <nocaption: NOCAPTION> ] ;                             
	[ CURSOR <cursor> ] ;
	[ ONINIT <InitProcedure> ] ;
	[ ONRELEASE <ReleaseProcedure> ] ;
	[ ONINTERACTIVECLOSE <interactivecloseprocedure> ] ;
	[ ONMOUSECLICK <ClickProcedure> ] ;
	[ ONMOUSEDRAG <MouseDragProcedure> ] ;
	[ ONMOUSEMOVE <MouseMoveProcedure> ] ;
	[ ONMOVE <MoveProcedure> ] ;
	[ ONSIZE <SizeProcedure> ] ;
	[ ONMAXIMIZE <MaximizeProcedure> ] ;
	[ ONMINIMIZE <MinimizeProcedure> ] ;
	[ ONPAINT <PaintProcedure> ] ;
	[ ONRESTORE <RestoreProcedure> ] ;
	[ ONDROPFILES <DropProcedure> ] ;
	[ BACKCOLOR <backcolor> ] ;
	[ FONT <FontName> SIZE <FontSize> ] ;
	[ NOTIFYICON <NotifyIcon> ] ;
	[ NOTIFYTOOLTIP <NotifyIconTooltip> ] ;
	[ ONNOTIFYCLICK <NotifyLeftClick> ] ;
	[ ONNOTIFYDBLCLICK <NotifyDblClick> ] ;
        [ ON NOTIFYBALLOONCLICK <NotifyBalloonClick> ] ;
	[ ONGOTFOCUS <GotFocusProcedure> ] ;
	[ ONLOSTFOCUS <LostFocusProcedure> ] ;
	[ ONSCROLLUP <scrollup> ] ;
	[ ONSCROLLDOWN <scrolldown> ] ;
	[ ONSCROLLLEFT <scrollleft> ] ;
	[ ONSCROLLRIGHT <scrollright> ] ;
	[ ONHSCROLLBOX <hScrollBox> ] ;
	[ ONVSCROLLBOX <vScrollBox> ] ;
	[ <helpbutton:  HELPBUTTON> ] ;
	[ FONTNAME <FontName> FONTSIZE <FontSize> ] ;
   =>;
   DECLARE WINDOW <w>  ;;
   DECLARE CUSTOM COMPONENTS <w> ;;
   _DefineWindow ( <(w)>, <title>, <col>, <row>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>,<minHeight>}, {<maxWidth>,<maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}>, <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>] , <{PaintProcedure}> , <.noshow.> , <.topmost.> , <.main.> , <icon> , <.child.> , <FontName> , <FontSize>, <NotifyIcon> , <NotifyIconTooltip> , <{NotifyLeftClick}>  , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight> , <vWidth> , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <{MaximizeProcedure}> , <{MinimizeProcedure}> , <cursor> , <.noautorelease.> , <{interactivecloseprocedure}> , <{RestoreProcedure}> , <{MoveProcedure}> , <{DropProcedure}> , <.mdi.> , <.palette.> , <{NotifyDblClick}> , <(parent)> , <.panel.> , <{NotifyBalloonClick}> , <clientwidth> , <clientheight> )


#xcommand DEFINE WINDOW <w> ;
	[ AT <row>,<col> ] ;
	[ ROW <row> ] ;
	[ COL <col> ] ;
	[ WIDTH <wi> ] ;
	[ HEIGHT <h> ] ;
	[ MINWIDTH <minWidth> ] ;
	[ MINHEIGHT <minHeight> ] ;
	[ MAXWIDTH <maxWidth> ] ;
	[ MAXHEIGHT <maxHeight> ] ;
	[ VIRTUALWIDTH <vWidth> ] ;                             
	[ VIRTUALHEIGHT <vHeight> ] ;                             
	[ CLIENTAREA <clientwidth>,<clientheight> ] ;
	[ TITLE <title> ] ;
	[ ICON <icon> ] ;
	WINDOWTYPE MODAL ;
	[ <noshow: NOSHOW> ] ;
	[ <noautorelease: NOAUTORELEASE> ] ;
	[ <nosize: NOSIZE> ] ;
	[ <nosysmenu: NOSYSMENU> ] ;                             
	[ <nocaption: NOCAPTION> ] ;                             
	[ CURSOR <cursor> ] ;
	[ ONINIT <InitProcedure> ] ;
	[ ONRELEASE <ReleaseProcedure> ] ;
	[ ONINTERACTIVECLOSE <interactivecloseprocedure> ] ;
	[ ONMOUSECLICK <ClickProcedure> ] ;
	[ ONMOUSEDRAG <MouseDragProcedure> ] ;
	[ ONMOUSEMOVE <MouseMoveProcedure> ] ;
	[ ONMOVE <MoveProcedure> ] ;
	[ ONSIZE <SizeProcedure> ] ;
	[ ONPAINT <PaintProcedure> ] ;
	[ ONDROPFILES <DropProcedure> ] ;
	[ BACKCOLOR <backcolor> ] ;
	[ FONT <FontName> SIZE <FontSize> ] ;
	[ ONGOTFOCUS <GotFocusProcedure> ] ;
	[ ONLOSTFOCUS <LostFocusProcedure> ] ;
	[ ONSCROLLUP <scrollup> ] ;
	[ ONSCROLLDOWN <scrolldown> ] ;
	[ ONSCROLLLEFT <scrollleft> ] ;
	[ ONSCROLLRIGHT <scrollright> ] ;
	[ ONHSCROLLBOX <hScrollBox> ] ;
	[ ONVSCROLLBOX <vScrollBox> ] ;
	[ HELPBUTTON <helpbutton> ] ;
        [ FLASHEXIT <flashexit> ] ;
	[ FONTNAME <FontName> FONTSIZE <FontSize> ] ;
   =>;
   DECLARE WINDOW <w>  ;;
   _DefineModalWindow ( <(w)>, <title>, <col>, <row>, <wi>, <h>, "" , <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>,<minHeight>}, {<maxWidth>,<maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}> , <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>]  , <{PaintProcedure}> , <icon> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <cursor> , <.noshow.> , <.noautorelease.> , <{interactivecloseprocedure}> , <{MoveProcedure}> , <{DropProcedure}> , <clientwidth> , <clientheight> , <.flashexit.> )


#xcommand  DEFINE WINDOW <w> ;
      HEIGHT <h> ;
      WIDTH <wi> ;
      [ VIRTUAL WIDTH <vWidth> ] ;
      [ VIRTUAL HEIGHT <vHeight> ] ;
      [ TITLE <title> ] ;
      SPLITCHILD ;
      [ <nocaption: NOCAPTION> ] ;
      [ CURSOR <cursor> ] ;
      [ FONT <FontName> SIZE <FontSize> ] ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ <break: BREAK> ] ;
      [ <focused: FOCUSED> ] ;
      [ ON GOTFOCUS <GotFocusProcedure> ] ;
      [ ON LOSTFOCUS <LostFocusProcedure> ] ;
      [ ON SCROLLUP <scrollup> ] ;
      [ ON SCROLLDOWN <scrolldown> ] ;
      [ ON SCROLLLEFT <scrollleft> ] ;
      [ ON SCROLLRIGHT <scrollright> ] ;
      [ ON HSCROLLBOX <hScrollBox> ] ;
      [ ON VSCROLLBOX <vScrollBox> ] ;
   => ;
   DECLARE WINDOW <w>  ;;
   _DefineSplitChildWindow ( <(w)>, <wi>, <h> , <.break.> , <grippertext> , <.nocaption.> , <title> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth> , <.focused.>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <cursor> )

#xcommand  DEFINE WINDOW <w> ;
		WIDTH <wi> ;
		HEIGHT <h> ;
		[ VIRTUALWIDTH <vWidth> ] ;                             
		[ VIRTUALHEIGHT <vHeight> ] ;                             
		[ TITLE <title> ] ;
		WINDOWTYPE SPLITCHILD ;
		[ <nocaption: NOCAPTION> ] ;
		[ CURSOR <cursor> ] ;
		[ FONT <FontName> SIZE <FontSize> ] ;
		[ GRIPPERTEXT <grippertext> ] ;
		[ <break: BREAK> ] ;
		[ <focused: FOCUSED> ] ;
		[ ONGOTFOCUS <GotFocusProcedure> ] ;
		[ ONLOSTFOCUS <LostFocusProcedure> ] ;
		[ ONSCROLLUP <scrollup> ] ;
		[ ONSCROLLDOWN <scrolldown> ] ;
		[ ONSCROLLLEFT <scrollleft> ] ;
		[ ONSCROLLRIGHT <scrollright> ] ;
		[ ONHSCROLLBOX <hScrollBox> ] ;
		[ ONVSCROLLBOX <vScrollBox> ] ;
		[ FONTNAME <FontName> FONTSIZE <FontSize> ] ;
   => ;
   DECLARE WINDOW <w>  ;;
   _DefineSplitChildWindow ( <(w)>, <wi>, <h> , <.break.> , <grippertext> , <.nocaption.> , <title> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth> , <.focused.>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <cursor> )


#command DEFINE WINDOW TEMPLATE ;
         [ <dummy1: OF, PARENT> <parent> ] ;
         AT <row>,<col> ;
         HEIGHT <h> ;
         WIDTH <wi> ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         [ <main:  MAIN> ] ;
         [ <mdi: MDI> ] ;
         [ <child: CHILD> ] ;
         [ <panel: PANEL> ] ;
         [ <noshow: NOSHOW> ] ;
         [ <topmost: TOPMOST> ] ;
         [ <palette: PALETTE> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nominimize: NOMINIMIZE> ] ;
         [ <nomaximize: NOMAXIMIZE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON MAXIMIZE <MaximizeProcedure> ] ;
         [ ON MINIMIZE <MinimizeProcedure> ] ;
         [ ON RESTORE <RestoreProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ BACKCOLOR <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ NOTIFYICON <NotifyIcon> ] ;
         [ NOTIFYTOOLTIP <NotifyIconTooltip> ] ;
         [ ON NOTIFYCLICK <NotifyLeftClick> ] ;
         [ ON NOTIFYDBLCLICK <NotifyDblClick> ] ;
         [ ON NOTIFYBALLOONCLICK <NotifyBalloonClick> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton:  HELPBUTTON> ] ;
   =>;
   _DefineWindow ( , <title>, <col>, <row>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>,<minHeight>}, {<maxWidth>,<maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}>, <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>] , <{PaintProcedure}> , <.noshow.> , <.topmost.> , <.main.> , <icon> , <.child.> , <FontName> , <FontSize>, <NotifyIcon> , <NotifyIconTooltip> , <{NotifyLeftClick}> , <{GotFocusProcedure}> , <{LostFocusProcedure}> , <vHeight> , <vWidth> , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <{MaximizeProcedure}> , <{MinimizeProcedure}> , <cursor> , <.noautorelease.> , <{interactivecloseprocedure}> , <{RestoreProcedure}> , <{MoveProcedure}> , <{DropProcedure}> , <.mdi.> , <.palette.> , <{NotifyDblClick}> , <(parent)> , <.panel.> , <{NotifyBalloonClick}> , <clientwidth> , <clientheight> )


#command DEFINE WINDOW TEMPLATE ;
         AT <row>,<col> ;
         HEIGHT <h> ;
         WIDTH <wi> ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         MODAL ;
         [ <noshow: NOSHOW> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ BACKCOLOR <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton:  HELPBUTTON> ] ;
         [ <flashexit: FLASHEXIT> ] ;
   =>;
   _DefineModalWindow ( , <title>, <col>, <row>, <wi>, <h>, "" , <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>,<minHeight>}, {<maxWidth>,<maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}> , <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>]  , <{PaintProcedure}> , <icon> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <cursor> , <.noshow.> , <.noautorelease.> , <{interactivecloseprocedure}> , <{MoveProcedure}> , <{DropProcedure}> , <clientwidth> , <clientheight> , <.flashexit.> )


#xcommand  DEFINE WINDOW TEMPLATE ;
      HEIGHT <h> ;
      WIDTH <wi> ;
      [ VIRTUAL WIDTH <vWidth> ] ;
      [ VIRTUAL HEIGHT <vHeight> ] ;
      [ TITLE <title> ] ;
      SPLITCHILD ;
      [ <nocaption: NOCAPTION> ] ;
      [ CURSOR <cursor> ] ;
      [ FONT <FontName> SIZE <FontSize> ] ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ <break: BREAK> ] ;
      [ <focused: FOCUSED> ] ;
      [ ON GOTFOCUS <GotFocusProcedure> ] ;
      [ ON LOSTFOCUS <LostFocusProcedure> ] ;
      [ ON SCROLLUP <scrollup> ] ;
      [ ON SCROLLDOWN <scrolldown> ] ;
      [ ON SCROLLLEFT <scrollleft> ] ;
      [ ON SCROLLRIGHT <scrollright> ] ;
      [ ON HSCROLLBOX <hScrollBox> ] ;
      [ ON VSCROLLBOX <vScrollBox> ] ;
   => ;
   _DefineSplitChildWindow ( , <wi>, <h> , <.break.> , <grippertext> , <.nocaption.> , <title> , <FontName> , <FontSize>, <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth> , <.focused.>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <cursor> ) ;;
