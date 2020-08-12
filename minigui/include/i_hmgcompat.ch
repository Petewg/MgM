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
	Copyright 1999-2020, https://harbour.github.io/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

 ---------------------------------------------------------------------------*/

#ifndef __MINIPRINT__
#include "miniprint.ch"
#endif

#ifndef _RPTGEN_
#include "i_rptgen.ch"
#endif

#ifndef _BT_
#include "BosTaurus.ch"
#include "i_GraphBitmap.ch"
#endif

#ifndef __HMG_COMPAT__
#define __HMG_COMPAT__

#include "i_wincolor.ch"

#xtranslate FocusedWindow . <p:Title,NotifyIcon,NotifyTooltip,FocusedControl,Name,Row,Col,Width,Height> => GetProperty ( GetFormNameByIndex( _HMG_LastActiveFormIndex )  , <"p"> )
#xtranslate FocusedWindow . <p:Title,Cursor,NotifyIcon,NotifyTooltip,Row,Col,Width,Height> := <arg> => SetProperty ( GetFormNameByIndex( _HMG_LastActiveFormIndex ) , <"p"> , <arg> )
#xtranslate FocusedWindow . <p:Activate,Center,Redraw,Release,Maximize,Minimize,Restore,Show,Hide,SetFocus> [ () ] => DoMethod ( GetFormNameByIndex( _HMG_LastActiveFormIndex ) , <"p"> )
#xtranslate FocusedWindow . <p:Handle,Index,IsMinimized,IsMaximized,ClientWidth,ClientHeight> => GetProperty ( GetFormNameByIndex( _HMG_LastActiveFormIndex ) , <"p"> )
#xtranslate FocusedWindow . <p:Closable,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Enabled> => GetProperty ( GetFormNameByIndex( _HMG_LastActiveFormIndex ) , <"p"> )
#xtranslate FocusedWindow . <p:Closable,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Enabled> := <arg> => SetProperty ( GetFormNameByIndex( _HMG_LastActiveFormIndex ) , <"p"> , <arg> )

#xtranslate PICTALIGNMENT TOP => _HMG_ActiveControlUpText := .F. ; _HMG_ActiveControlVertical := .T.
#xtranslate PICTALIGNMENT LEFT => LEFTTEXT .F.
#xtranslate PICTALIGNMENT RIGHT => LEFTTEXT .T.
#xtranslate PICTALIGNMENT BOTTOM => UPPERTEXT .T.

#ifndef _NO_BTN_PICTURE_
#xcommand END BUTTON => END BUTTONEX
#endif

#xcommand END IMAGELIST =>

#xcommand DISABLEDBACKCOLOR <a> =>
#xcommand DISABLEDFONTCOLOR <a> =>
#xcommand TRANSPARENTHEADER <a> => 

#xcommand ROWSOURCE Nil =>
#xcommand COLUMNFIELDS Nil =>
#xcommand BUFFERED <f> =>
#xcommand DYNAMICDISPLAY <f> =>
#xcommand ONSAVE Nil =>
#xcommand ONKEY Nil =>

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <(parent)> , 0 , VK_SPACE , <{action}> )

#xtranslate Restore( <h> ) => _Restore( <h> )

#xtranslate HMG_LEN(<x>)   => LEN (<x>)
#xtranslate HMG_LOWER(<c>) => LOWER (<c>)
#xtranslate HMG_UPPER(<c>) => UPPER (<c>)

#xtranslate HMG_PADC(<x>,<n>,<c>) => PADC(<x>,<n>,<c>)
#xtranslate HMG_PADL(<x>,<n>,<c>) => PADL(<x>,<n>,<c>)
#xtranslate HMG_PADR(<x>,<n>,<c>) => PADR(<x>,<n>,<c>)

#xtranslate HMG_ISALPHA(<c>) => ISALPHA(<c>)
#xtranslate HMG_ISDIGIT(<c>) => ISDIGIT(<c>)
#xtranslate HMG_ISLOWER(<c>) => ISLOWER(<c>)
#xtranslate HMG_ISUPPER(<c>) => ISUPPER(<c>)
#xtranslate HMG_ISALPHANUMERIC(<c>) => ( ISALPHA(<c>) .OR. ISDIGIT(<c>) )

#xtranslate _HMG_PARSEGRIDCONTROLS( <a>, <b> ) => _PARSEGRIDCONTROLS( <a>, <b> )

#xtranslate HMG_IsWindowStyle( <hWnd>, <nStyle> [, <lExStyle> ] ) ;
   => ;
   iif( <.lExStyle.>, IsWindowHasExStyle ( <hWnd>, <nStyle> ), IsWindowHasStyle ( <hWnd>, <nStyle> ) )

#xtranslate HMG_ChangeWindowStyle( <hWnd>, [ <nAddStyle> ], [ <nRemoveStyle> ], [ <lExStyle> ] [, <lRedrawWindow> ] ) ;
   => ;
   ChangeStyle( <hWnd>, [ <nAddStyle> ], [ <nRemoveStyle> ], [ <lExStyle> ] );;
   iif( <.lRedrawWindow.>, RedrawWindow ( <hWnd> ), )

#ifndef WS_EX_WINDOWEDGE
#define WS_EX_WINDOWEDGE         256
#define WS_EX_CLIENTEDGE         512
#define WS_EX_STATICEDGE         0x20000
#endif

#xtranslate SET CONTROL <ControlName> OF <FormName> CLIENTEDGE => HMG_ChangeWindowStyle (GetControlHandle (<"ControlName">, <"FormName">), WS_EX_CLIENTEDGE, NIL, .T.)
#xtranslate SET CONTROL <ControlName> OF <FormName> STATICEDGE => HMG_ChangeWindowStyle (GetControlHandle (<"ControlName">, <"FormName">), WS_EX_STATICEDGE, NIL, .T.)
#xtranslate SET CONTROL <ControlName> OF <FormName> WINDOWEDGE => HMG_ChangeWindowStyle (GetControlHandle (<"ControlName">, <"FormName">), WS_EX_WINDOWEDGE, NIL, .T.)
#xtranslate SET CONTROL <ControlName> OF <FormName> NOTEDGE    => HMG_ChangeWindowStyle (GetControlHandle (<"ControlName">, <"FormName">), NIL, hb_bitOr (WS_EX_CLIENTEDGE, WS_EX_STATICEDGE, WS_EX_WINDOWEDGE), .T.)

#xtranslate SET DIALOGBOX [ POSITION ] [ ROW <nRow> ] [ COL <nCol> ] [ [<lCenter:CENTER> OF <Form> ] ] ;
   => ;
   _HMG_DialogBoxProperty ( <nRow>, <nCol>, <.lCenter.>, <Form>, .T. )

#xtranslate SET DIALOGBOX [ POSITION ] <lCenter:CENTER> OF PARENT ;
   => ;
   _HMG_DialogBoxProperty ( NIL, NIL, <.lCenter.>, NIL, .T. )

#xtranslate SET DIALOGBOX [ POSITION ] <lCenter:CENTER> OF DESKTOP ;
   => ;
   _HMG_DialogBoxProperty ( NIL, NIL, <.lCenter.>, GetDesktopWindow(), .T. )

#xtranslate SET DIALOGBOX [ POSITION ] DISABLE ;
   => ;
   _HMG_DialogBoxProperty ( NIL, NIL, NIL, NIL, .T. )


#define WM_GETFONT               0x0031

#xtranslate GetWindowFont ( <hWnd> ) ;
   => ;
   SendMessage( <hWnd>, WM_GETFONT, 0, 0 )

#xtranslate SetWindowFont ( <hWnd>, <hFont> [, <lRedraw> ] ) ;
   => ;
   _SetFontHandle( <hWnd>, <hFont> )

#xtranslate SetCursorSystem ( <nCursor> ) ;
   => ;
   SetResCursor( LoadCursor( NIL, <nCursor> ) )

#xtranslate HMGVersion () => MiniGUIVersion ()

#translate GetProperty ( <FormName> , "CLIENTAREAWIDTH" ) ;
   => ;
   _GetClientRect ( GetFormHandle ( <FormName> ) ) \[3]

#translate GetProperty ( <FormName> , "CLIENTAREAHEIGHT" ) ;
   => ;
   _GetClientRect ( GetFormHandle ( <FormName> ) ) \[4]

#translate GetProperty ( <FormName> , <ControlName> , "CellEx" , <row> , <col> ) ;
   => ;
   _GetGridCellValue ( <ControlName> , <FormName> , <row> , <col> )

#translate GetProperty ( <FormName> , <ControlName> , "CellRowFocused" ) ;
   => ;
   _GetValue (  <ControlName> , <FormName> ) \[1]

#translate GetProperty ( <FormName> , <ControlName>, 'CellColFocused' ) ;
   => ;
   _GetValue (  <ControlName> , <FormName> ) \[2]

#xtranslate CellNavigationColor (_SELECTEDCELL_FORECOLOR, <aColor>) => ( _HMG_GridSelectedCellForeColor := <aColor> )
#xtranslate CellNavigationColor (_SELECTEDCELL_BACKCOLOR, <aColor>) => ( _HMG_GridSelectedCellBackColor := <aColor> )
#xtranslate CellNavigationColor (_SELECTEDROW_FORECOLOR, <aColor>)  => ( _HMG_GridSelectedRowForeColor := <aColor> )
#xtranslate CellNavigationColor (_SELECTEDROW_BACKCOLOR, <aColor>)  => ( _HMG_GridSelectedRowBackColor := <aColor> )
#xtranslate CellNavigationColor (_SELECTEDCELL_DISPLAYCOLOR, <l>) => //
#xtranslate CellNavigationColor (_SELECTEDROW_DISPLAYCOLOR, <l>) => //


#xcommand  SET TOOLTIPBACKCOLOR <aColor> => ;
   SendMessage( GetFormToolTipHandle(Application.FormName), TTM_SETTIPBKCOLOR, RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]), 0 )

#xcommand  SET TOOLTIPFORECOLOR <aColor> => ;
   SendMessage( GetFormToolTipHandle(Application.FormName), TTM_SETTIPTEXTCOLOR, RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]), 0 )


#define LWA_COLORKEY 0x01
#define LWA_ALPHA    0x02

#xtranslate SET WINDOW <FormName> TRANSPARENT TO <nAlphaBlend> => ;  // nAlphaBlend = 0 to 255 (completely transparent = 0, opaque = 255)
   SetLayeredWindowAttributes( GetFormHandle( <"FormName"> ), 0, <nAlphaBlend>, LWA_ALPHA )

#xtranslate SET WINDOW <FormName> [ TRANSPARENT ] TO OPAQUE => ;
   SetLayeredWindowAttributes( GetFormHandle( <"FormName"> ), 0, 255, LWA_ALPHA )

#xtranslate SET WINDOW <FormName> TRANSPARENT TO COLOR <aColor> => ;
   SetLayeredWindowAttributes( GetFormHandle( <"FormName"> ), RGB(<aColor>\[1\], <aColor>\[2\], <aColor>\[3\]), 0, LWA_COLORKEY )


#define FLASHW_CAPTION 1
#define FLASHW_TRAY    2
#define FLASHW_ALL    (FLASHW_CAPTION + FLASHW_TRAY)

#xtranslate FLASH WINDOW <FormName> CAPTION COUNT <nTimes> INTERVAL <nMilliseconds> =>;
   FlashWindowEx( GetFormHandle( <"FormName"> ), FLASHW_CAPTION, <nTimes>, <nMilliseconds> )

#xtranslate FLASH WINDOW <FormName> TASKBAR COUNT <nTimes> INTERVAL <nMilliseconds> =>;
   FlashWindowEx( GetFormHandle( <"FormName"> ), FLASHW_TRAY, <nTimes>, <nMilliseconds> )

#xtranslate FLASH WINDOW <FormName> [ ALL ] COUNT <nTimes> INTERVAL <nMilliseconds> =>;
   FlashWindowEx( GetFormHandle( <"FormName"> ), FLASHW_ALL, <nTimes>, <nMilliseconds> )


// ANIMATE WINDOW MODE <nFlags>
#define AW_HOR_POSITIVE 0x00000001
#define AW_HOR_NEGATIVE 0x00000002
#define AW_VER_POSITIVE 0x00000004
#define AW_VER_NEGATIVE 0x00000008
#define AW_CENTER       0x00000010
#define AW_HIDE         0x00010000
#define AW_ACTIVATE     0x00020000
#define AW_SLIDE        0x00040000
#define AW_BLEND        0x00080000

#xtranslate ANIMATE WINDOW <FormName> INTERVAL <nMilliseconds> MODE <nFlags> => ;
   AnimateWindow( GetFormHandle( <"FormName"> ), <nMilliseconds>, <nFlags> )

#xtranslate ANIMATE WINDOW <FormName> MODE <nFlags> => ;
   AnimateWindow( GetFormHandle( <"FormName"> ), 200, <nFlags> )

#xtranslate SET CODEPAGE TO UNICODE => Set (_SET_CODEPAGE, "UTF8")

#xtranslate RELEASE MEMORY => iif( IsVistaOrLater(), ( hb_gcAll(), EmptyWorkingSet() ), )


#xtranslate SET WINDOW MAIN [ FIRST ] OFF => _HMG_MainWindowFirst := .F.
#xtranslate SET WINDOW MAIN [ FIRST ] ON  => _HMG_MainWindowFirst := .T.

#xcommand ACTIVATE WINDOW DEBUGGER <name, ...> => ;
   _ActivateWindow ( \{<(name)>\}, .T., .T. )


#xtranslate IsMainMenuDefined ( <FormName> ) => ( Empty( GetMenu( GetFormHandle( <FormName> ) ) ) == .F. )

#xtranslate IsNotifyMenuDefined ( <FormName> ) => IsMenu( _HMG_aFormNotifyMenuHandle \[ GetFormIndex( <FormName> ) ] )

#xtranslate IsContextMenuDefined ( <FormName> ) => IsMenu( _HMG_aFormContextMenuHandle \[ GetFormIndex( <FormName> ) ] )


#xcommand RELEASE MAIN MENU OF <form> => DestroyMenu( GetMenu( GetFormHandle( <(form)> ) ) ) ; SetMenu( GetFormHandle( <(form)> ), 0 )

#xcommand RELEASE CONTEXT MENU OF <form> => DEFINE CONTEXT MENU OF <form> ; END MENU ; DestroyMenu( _HMG_aFormContextMenuHandle \[ GetFormIndex( <(form)> ) ] )

#xcommand RELEASE NOTIFY MENU OF <form>  => DEFINE NOTIFY MENU OF <form> ; END MENU ; DestroyMenu( _HMG_aFormNotifyMenuHandle \[ GetFormIndex( <(form)> ) ] )

#xcommand RELEASE DROPDOWN MENU BUTTON <button> OF <form>     => DEFINE DROPDOWN MENU BUTTON <button> OF <form> ; END MENU
#xcommand RELEASE DROPDOWNMENU OWNERBUTTON <button> OF <form> => DEFINE DROPDOWN MENU BUTTON <button> OF <form> ; END MENU

#xcommand DEFINE CONTROL CONTEXT MENU <cControlName> [ OF <cParentName> ]     => _DefineControlContextMenu ( <"cControlName"> , <"cParentName"> )
#xcommand DEFINE CONTROL CONTEXT MENU <cControlName> [ PARENT <cParentName> ] => _DefineControlContextMenu ( <"cControlName"> , <"cParentName"> )
#xcommand DEFINE CONTROL CONTEXTMENU  <cControlName> [ OF <cParentName> ]     => _DefineControlContextMenu ( <"cControlName"> , <"cParentName"> )
#xcommand DEFINE CONTROL CONTEXTMENU  <cControlName> [ PARENT <cParentName> ] => _DefineControlContextMenu ( <"cControlName"> , <"cParentName"> )


#translate DISABLE [ WINDOW ]  EVENT OF <form> => StopWindowEventProcedure (<(form)>, .T.)
#translate ENABLE  [ WINDOW ]  EVENT OF <form> => StopWindowEventProcedure (<(form)>, .F.)

#translate DISABLE [ CONTROL ] EVENT <control> OF <form> => StopControlEventProcedure (<(control)>, <(form)>, .T.)
#translate ENABLE  [ CONTROL ] EVENT <control> OF <form> => StopControlEventProcedure (<(control)>, <(form)>, .F.)

#xtranslate CREATE EVENT PROCNAME <cProcName>[()] [HWND <hWnd>] [MSG <nMsg>] [STOREINDEX <nIndex>] =>;
   InstallEventHandler ( <"cProcName"> )

#xtranslate EventCount () => Len (_HMG_aCustomEventProcedure)
#xtranslate EventRemoveAll () => iif ( EventCount() > 0, _HMG_aCustomEventProcedure := {}, NIL )
#xtranslate EventRemove ([<x>]) => iif ( EventCount() > 0, hb_ADel (_HMG_aCustomEventProcedure, EventCount(), .T.), NIL )

#xtranslate MsgHMGError ( <Message> ) => MsgMiniGuiError( <Message>, .F. )

#xtranslate GetFormNameByIndex ( <nFormIndex> ) => _HMG_aFormNames \[ <nFormIndex> ]
#xtranslate GetFormHandleByIndex ( <nFormIndex> ) => _HMG_aFormHandles \[ <nFormIndex> ]
#xtranslate GetControlNameByIndex ( <nControlIndex> ) => _HMG_aControlNames \[ <nControlIndex> ]
#xtranslate GetControlHandleByIndex ( <nControlIndex> ) => _HMG_aControlHandles \[ <nControlIndex> ]
#xtranslate GetControlParentHandleByIndex ( <nControlIndex> ) => _HMG_aControlParentHandles \[ <nControlIndex> ]

#xtranslate GetFocusedControlType () => _GetFocusedControlType ( GetActiveWindow() )

#xtranslate IsValidWindowHandle ( <hWnd> ) => IsWindowHandle ( <hWnd> )
#xtranslate IsMinimized ( <hWnd> ) => IsIconic ( <hWnd> )
#xtranslate IsMaximized ( <hWnd> ) => IsZoomed ( <hWnd> )

#xtranslate System.EmptyClipboard => ClearClipboard()

#define TREESORTNODE_FIRST  0
#define TREESORTNODE_LAST   1
#define TREESORTNODE_MIX    2

#xtranslate TREESORT <control> OF <parent>; 
   [ ITEM <nItem> ] [ RECURSIVE <lRecursive> ];
   [ CASESENSITIVE <lCaseSensitive> ] [ ASCENDINGORDER <lAscendingOrder> ] [ NODEPOSITION <nNodePosition> ];
   =>;
   TreeItemSort (<(control)>, <(parent)>, <nItem>, <lRecursive>, <lCaseSensitive>, <lAscendingOrder>, <nNodePosition>)

#translate GetProperty ( <FormName> , <ControlName> , "RootValue" ) ;
   => ;
   TreeItemGetRootValue ( <ControlName> , <FormName> )

#translate GetProperty ( <FormName> , <ControlName> , "FirstItemValue" ) ;
   => ;
   TreeItemGetFirstItemValue ( <ControlName> , <FormName> )

#translate GetProperty ( <FormName> , <ControlName> , "IsTrueNode" , <item> ) ;
   => ;
   TreeItemIsTrueNode ( <ControlName> , <FormName> , <item> )

#translate GetProperty ( <FormName> , <ControlName> , "NodeFlag" , <item> ) ;
   => ;
   TreeItemGetNodeFlag ( <ControlName> , <FormName> , <item> )

#translate GetProperty ( <FormName> , <ControlName> , "IsExpand" , <item> ) ;
   => ;
   TreeItemIsExpand ( <ControlName> , <FormName> , <item> )

#define GRID_GROUP_LEFT      0x01
#define GRID_GROUP_CENTER    0x02
#define GRID_GROUP_RIGHT     0x04

#define GRID_GROUP_NORMAL    0x01
#define GRID_GROUP_COLLAPSED 0x02

#define CYAN      { 153, 217, 234 }
#define IDC_HAND  (32649)

#translate _TIMELONG24H  => "HH:mm:ss"
#translate _TIMESHORT24H => "HH:mm"
#translate _TIMELONG12H  => "hh:mm:ss tt"
#translate _TIMESHORT12H => "hh:mm tt"

// by Dr. Claudio Soto (June 2013)

#define PBS_MARQUEE             0x08
#define PBM_SETMARQUEE          (WM_USER+10)

// Use this command when you do not know the amount of progress toward completion
// but wish to indicate that progress is being made.

#xcommand SET PROGRESSBAR <name> OF <parent> ENABLE MARQUEE [ UPDATED <milliseconds> ] ;
   => ;
   ChangeStyle( GetControlHandle(<(name)>,<(parent)>) , PBS_MARQUEE );;
   SendMessage( GetControlHandle(<(name)>,<(parent)>) , PBM_SETMARQUEE , 1 , <milliseconds> )

#xcommand SET PROGRESSBAR <name> OF <parent> DISABLE MARQUEE ;
   => ;
   SendMessage( GetControlHandle(<(name)>,<(parent)>) , PBM_SETMARQUEE , 0 , 0 )

// by Dr. Claudio Soto, April 2016

#xtranslate CHECK TYPE [ <lSoft: SOFT> ] <var> AS <type> [, <varN> AS <typeN> ] => ;
   HMG_CheckType( <.lSoft.>, { <"type"> , ValType( <var> ), <"var"> } [, { <"typeN"> , ValType( <varN> ), <"varN"> } ] )

* Alternate Syntax

#xcommand DEFINE TAB <name> ;
	[ PARENT> <parent> ] ;
	ROW <row> ;
	COL <col> ;
	WIDTH <w> ;
	HEIGHT <h> ;
	[ VALUE <value> ] ;
	[ FONTNAME <f> ] ;
	[ FONTSIZE <s> ] ;
	[ FONTBOLD <bold> ] ;
	[ FONTITALIC <italic> ] ;
	[ FONTUNDERLINE <underline> ] ;
	[ FONTSTRIKEOUT <strikeout> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ BUTTONS <buttons> ] ;
	[ FLAT <flat> ]       ;
	[ HOTTRACK <hottrack> ] ;
	[ VERTICAL <vertical> ] ;
	[ ON CHANGE <change> ] ;
	[ TABSTOP <tabstop> ] ;
	[ MULTILINE <multiline> ] ;
	[ TRANSPARENT <Trans> ] ;
	[ ON INIT <bInit> ] ;
=>;
	_BeginTab( <(name)> , <(parent)> , <row> , <col> , <w> , <h> , <value> , <f> , <s> , <tooltip> , <{change}> , <.buttons.> , <.flat.> , <.hottrack.> , <.vertical.>, .f., !<.tabstop.> ,<.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <.multiline.> , {,,}, , <bInit> )


#xcommand  DEFINE TOOLBAR  <name> ;
      [ OF <parent> ] ;
      BUTTONSIZE <buttonwidth> , <buttonheight> ;
      IMAGESIZE <imagewidth> , <imageheight> ;
      [ BUTTONWIDTH <buttonwidth> ] [ BUTTONHEIGHT <buttonheight> ] ;
      [ IMAGEWIDTH <imagewidth> ] [ IMAGEHEIGHT <imageheight> ] ;
      [ <strictwidth : STRICTWIDTH> ] ;		
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
      [ <dummy1: GRIPPERTEXT, CAPTION> <grippertext> ] ;
      [ <border : BORDER> ] ;
      [ <custom : CUSTOMIZE> ] ;
      [ <break: BREAK> ] ;
   => ;
   _BeginToolBar ( <(name)>, <(parent)>,,, <buttonwidth>-iif(<.strictwidth.>,16,iif(<imagewidth> > 26,<imagewidth>/2+1,-16)), ;
                   <buttonheight>-iif(<.strictwidth.>,16,iif(<imageheight> > 26,-(<imageheight>/8+1),10)), <grippertext>,, <f>, <s>, ;
                   <tooltip>, <.flat.>, <.bottom.>, <.righttext.>, <.break.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                   <.border.>, <.wrap.>, <.custom.> )

#xcommand  DEFINE TOOLBAR  <name> ;
      [ PARENT <parent> ] ;
      [ BUTTONWIDTH <buttonwidth> ] [ BUTTONHEIGHT <buttonheight> ] ;
      IMAGEWIDTH <imagewidth> IMAGEHEIGHT <imageheight> ;
      [ STRICTWIDTH <strictwidth> ] ;
      [ FONTNAME <f> ] ;
      [ FONTSIZE <s> ] ;
      [ FONTBOLD <bold> ] ;
      [ FONTITALIC <italic> ] ;
      [ FONTUNDERLINE <underline> ] ;
      [ FONTSTRIKEOUT <strikeout> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ FLAT <flat> ] ;
      [ BOTTOM <bottom> ] ;
      [ RIGHTTEXT <righttext> ] ;
      [ WRAP <wrap> ] ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ BORDER <border> ] ;
      [ CUSTOMIZE <custom> ] ;
      [ BREAK <break> ] ;
   => ;
   _BeginToolBar ( <(name)>, <(parent)>,,, iif(<.strictwidth.>,<imagewidth>,<imagewidth>+8), ;
                   iif(<.strictwidth.>,<imageheight>,<imageheight>+2), <grippertext>,, <f>, <s>, ;
                   <tooltip>, <.flat.>, <.bottom.>, <.righttext.>, <.break.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                   <.border.>, <.wrap.>, <.custom.> )


#xcommand @ <row>, <col> BUTTON <name> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	CAPTION <caption> ;
	PICTURE <bitmap> ;
	[ <alignment: LEFT> ] ;
	[ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ];
	[ WIDTH <w> ] ;
	[ HEIGHT <h> ] ;
	[ FONT <font> ] ;
	[ SIZE <size> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ <flat: FLAT> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ <notabstop: NOTABSTOP> ] ;
	[ HELPID <helpid> ] 		;
	[ <invisible: INVISIBLE> ] ;
	[ <multiline: MULTILINE> ] ;
   =>;
   _DefineOwnerButton ( <(name)>, <(parent)>, <col>, <row>, <caption>, <{action}>, ;
                        <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
                        <.flat.>, .f., <helpid>, <.invisible.>, <.notabstop.>, ;
                        .f., NIL, <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                        .f., .f., .f., NIL, NIL, .f., .f., .f. )

#xcommand @ <row>, <col> BUTTON <name> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	CAPTION <caption> ;
	PICTURE <bitmap> ;
	[ <alignment: RIGHT> ] ;
	[ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ];
	[ WIDTH <w> ] ;
	[ HEIGHT <h> ] ;
	[ FONT <font> ] ;
	[ SIZE <size> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ <flat: FLAT> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ <notabstop: NOTABSTOP> ] ;
	[ HELPID <helpid> ] 		;
	[ <invisible: INVISIBLE> ] ;
	[ <multiline: MULTILINE> ] ;
   =>;
   _DefineOwnerButton ( <(name)>, <(parent)>, <col>, <row>, <caption>, <{action}>, ;
                        <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
                        <.flat.>, .f., <helpid>, <.invisible.>, <.notabstop.>, ;
                        .f., NIL, <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                        .f., <.alignment.>, .f., NIL, NIL, .f., .f., .f. )

#xcommand @ <row>, <col> BUTTON <name> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	CAPTION <caption> ;
	PICTURE <bitmap> ;
	[ <alignment: BOTTOM> ] ;
	[ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ];
	[ WIDTH <w> ] ;
	[ HEIGHT <h> ] ;
	[ FONT <font> ] ;
	[ SIZE <size> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ <flat: FLAT> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ <notabstop: NOTABSTOP> ] ;
	[ HELPID <helpid> ] 		;
	[ <invisible: INVISIBLE> ] ;
	[ <multiline: MULTILINE> ] ;
   =>;
   _DefineOwnerButton ( <(name)>, <(parent)>, <col>, <row>, <caption>, <{action}>, ;
                        <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
                        <.flat.>, .f., <helpid>, <.invisible.>, <.notabstop.>, ;
                        .f., NIL, <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                        <.alignment.>, .f., <.alignment.>, NIL, NIL, .f., .f., .f. )

#xcommand @ <row>, <col> BUTTON <name> ;
	[ <dummy1: OF, PARENT> <parent> ] ;
	CAPTION <caption> ;
	PICTURE <bitmap> ;
	[ <alignment: TOP> ] ;
	[ <dummy2: ACTION,ON CLICK,ONCLICK> <action> ];
	[ WIDTH <w> ] ;
	[ HEIGHT <h> ] ;
	[ FONT <font> ] ;
	[ SIZE <size> ] ;
	[ <bold : BOLD> ] ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ TOOLTIP <tooltip> ] ;
	[ <flat: FLAT> ] ;
	[ ON GOTFOCUS <gotfocus> ] ;
	[ ON LOSTFOCUS <lostfocus> ] ;
	[ <notabstop: NOTABSTOP> ] ;
	[ HELPID <helpid> ] 		;
	[ <invisible: INVISIBLE> ] ;
	[ <multiline: MULTILINE> ] ;
   =>;
   _DefineOwnerButton ( <(name)>, <(parent)>, <col>, <row>, <caption>, <{action}>, ;
                        <w>, <h>, <bitmap>, <tooltip>, <{gotfocus}>, <{lostfocus}>, ;
                        <.flat.>, .f., <helpid>, <.invisible.>, <.notabstop.>, ;
                        .f., NIL, <font>, <size>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, ;
                        .t., .f., .f., NIL, NIL, .f., .f., .f. )

#xcommand @ <row>, <col> GRID <name> ;
      [ <dummy1: OF, PARENT> <parent> ] ;
      [ WIDTH <w> ] ;
      [ HEIGHT <h> ] ;
      [ HEADERS <headers> ] ;
      [ WIDTHS <widths> ] ;
      [ ITEMS <rows> ] ;
      [ VALUE <value> ] ;
      [ FONT <fontname> ] ;
      [ SIZE <fontsize> ] ;
      [ <bold: BOLD> ] ;
      [ <italic: ITALIC> ] ;
      [ <underline: UNDERLINE> ] ;
      [ <strikeout: STRIKEOUT> ] ;
      [ TOOLTIP <tooltip> ] ;
      [ BACKCOLOR <backcolor> ] ;
      [ FONTCOLOR <fontcolor> ] ;
      [ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
      [ DYNAMICFORECOLOR <dynamicforecolor> ] ;
      [ ON GOTFOCUS <gotfocus> ] ;
      [ ON CHANGE <change> ] ;
      [ ON LOSTFOCUS <lostfocus> ] ;
      [ ON DBLCLICK <dblclick> ] ;
      [ ON HEADCLICK <aHeadClick> ] ;
      ROWSOURCE <recordsource> ;
      COLUMNFIELDS <columnfields> ;
      [ <edit: EDIT> ] ;
      [ COLUMNCONTROLS <editcontrols> ] ;
      [ COLUMNVALID <columnvalid> ] ;
      [ COLUMNWHEN <columnwhen> ] ;
      [ <ownerdata: VIRTUAL> ] ;
      [ ITEMCOUNT <itemcount> ] ;
      [ ON QUERYDATA <dispinfo> ] ;
      [ <multiselect: MULTISELECT> ] ;
      [ <style: NOLINES> ] ;
      [ <noshowheaders: NOHEADERS> ] ;
      [ IMAGE <aImage> ] ;
      [ JUSTIFY <aJust> ] ;
      [ HELPID <helpid> ] ;
      [ <break: BREAK> ] ;
      [ HEADERIMAGES <aHeaderImages> ] ;
      [ <bycell: NAVIGATEBYCELL> ] ;
      [ <append: ALLOWAPPEND> ] ;
      [ <delete: ALLOWDELETE> ] ;
      [ DYNAMICDISPLAY <dynamicdisplay> ] ;
      [ ON SAVE <onsave> ] ;
      [ <fixedcols: FIXEDCOLS> ] ;
   => ;
      _HMG_BrowseSyncStatus := .T. ;;
      @ <row>, <col> BROWSE <name> ;
            [ PARENT <parent> ] ;
            [ WIDTH <w> ] ;
            [ HEIGHT <h> ] ;
            [ HEADERS <headers> ] ;
            [ WIDTHS <widths> ] ;
            WORKAREA <recordsource> ;
            FIELDS <columnfields> ;
            [ VALUE <value> ] ;
            [ FONT <fontname> ] ;
            [ SIZE <fontsize> ] ;
            [ <bold> ] ;
            [ <italic> ] ;
            [ <underline> ] ;
            [ <strikeout> ] ;
            [ TOOLTIP <tooltip> ] ;
            [ BACKCOLOR <backcolor> ] ;
            [ FONTCOLOR <fontcolor> ] ;
            [ DYNAMICBACKCOLOR <dynamicbackcolor> ] ;
            [ DYNAMICFORECOLOR <dynamicforecolor> ] ;
            [ ON GOTFOCUS <gotfocus> ] ;
            [ ON CHANGE <change> ] ;
            [ ON LOSTFOCUS <lostfocus> ] ;
            [ ON DBLCLICK <dblclick> ] ;
            [ ON HEADCLICK <aHeadClick> ] ;
            [ <edit> INPLACE ] LOCK ;
            [ COLUMNVALID <columnvalid> ] ;
            [ COLUMNWHEN <columnwhen> ] ;
            [ <style> ] ;
            [ <noshowheaders> ] ;
            [ IMAGE <aImage> ] ;
            [ JUSTIFY <aJust> ] ;
            [ HELPID <helpid> ] ;
            [ <break> ] ;
            [ HEADERIMAGE <aHeaderImages> ] ;
            [ <append> ] ;
            [ <delete> ] PAINTDOUBLEBUFFER

#endif
