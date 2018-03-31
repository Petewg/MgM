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


/*
 * Success codes
 */
#define S_OK                0
#define S_FALSE             1

/*
 * Object Definitions
 */
#define OBJ_PEN             1
#define OBJ_BRUSH           2
#define OBJ_DC              3
#define OBJ_METADC          4
#define OBJ_PAL             5
#define OBJ_FONT            6
#define OBJ_BITMAP          7
#define OBJ_REGION          8
#define OBJ_METAFILE        9
#define OBJ_MEMDC           10
#define OBJ_EXTPEN          11
#define OBJ_ENHMETADC       12
#define OBJ_ENHMETAFILE     13
#define OBJ_COLORSPACE      14

/*
 * Standard Cursor IDs
 */
#define IDC_ARROW           32512
#define IDC_IBEAM           32513
#define IDC_WAIT            32514
#define IDC_CROSS           32515
#define IDC_UPARROW         32516
#define IDC_SIZENWSE        32642
#define IDC_SIZENESW        32643
#define IDC_SIZEWE          32644
#define IDC_SIZENS          32645
#define IDC_SIZEALL         32646
#define IDC_NO              32648
#define IDC_APPSTARTING     32650
#define IDC_HELP            32651

#xtranslate SetWaitCursor( <hWnd> ) ;
=> ;
SetWindowCursor( <hWnd>, IDC_WAIT )

#xtranslate SetArrowCursor( <hWnd> ) ;
=> ;
SetWindowCursor( <hWnd>, IDC_ARROW )

#xtranslate CursorArrow() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_ARROW ) )

#xtranslate CursorHelp() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_HELP ) )

#xtranslate CursorWait() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_WAIT ) )

#xtranslate CursorCross() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_CROSS ) )

#xtranslate CursorIBeam() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_IBEAM ) )

#xtranslate CursorAppStarting() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_APPSTARTING ) )

#xtranslate CursorNo() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_NO ) )

#xtranslate CursorSizeAll() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_SIZEALL ) )

#xtranslate CursorSizenEsW() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_SIZENESW ) )

#xtranslate CursorSizenWsE() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_SIZENWSE ) )

#xtranslate CursorSizeNS() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_SIZENS ) )

#xtranslate CursorSizeWE() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_SIZEWE ) )

#xtranslate CursorUpArrow() ;
=> ;
SetResCursor( LoadCursor( NIL, IDC_UPARROW ) )

// Alert icons
#define ICON_EXCLAMATION      1  // default value
#define ICON_QUESTION         2
#define ICON_INFORMATION      3
#define ICON_STOP             4

// System metrics
#define SM_CXSCREEN             0
#define SM_CYSCREEN             1
#define SM_CXVSCROLL            2
#define SM_CYHSCROLL            3
#define SM_CYCAPTION            4
#define SM_CYMENU               15

#define SM_CXFRAME              32
#define SM_CYFRAME              33
#define SM_CXSIZEFRAME          SM_CXFRAME
#define SM_CYSIZEFRAME          SM_CYFRAME

#define SM_CXEDGE               45
#define SM_CYEDGE               46

/*
 * ShowWindow() Commands
 */
#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10

#command SETFOCUS <n> OF <w>;
   =>;
   DoMethod ( <"w"> , <"n"> , 'SetFocus' )

#command ADD ITEM <i> TO <n> OF <p> ;
   =>;
   DoMethod ( <"p"> , <"n"> , 'AddItem' , <i> )

#command ADD COLUMN [ INDEX <index> ] [ CAPTION <caption> ] [ WIDTH <width> ] [ JUSTIFY <justify> ] TO <control> OF <parent> ;
   =>;
   DoMethod ( <"parent"> , <"control"> , 'AddColumn' , <index> , <caption> , <width> , <justify> )

#command DELETE COLUMN [ INDEX ] <index> FROM <control> OF <parent> ;
   =>;
   DoMethod ( <"parent"> , <"control"> , 'DeleteColumn' , <index> )

#command DELETE ITEM <i> FROM <n> OF <p>;
   =>;
   DoMethod ( <"p"> , <"n"> , 'DeleteItem' , <i> )

#command DELETE ITEM ALL FROM <n> OF <p>;
   =>;
   DoMethod ( <"p"> , <"n"> , 'DeleteAllItems' )

#command ENABLE CONTROL <control> OF <form>;
   =>;
   SetProperty ( <"form"> , <"control"> , 'Enabled' , .T. )

#command SHOW CONTROL <control> OF <form>;
   =>;
   DoMethod ( <"form"> , <"control"> , 'Show' )

#command HIDE CONTROL <control> OF <form>;
   =>;
   DoMethod ( <"form"> , <"control"> , 'Hide' )

#command DISABLE CONTROL <control> OF <form>;
   =>;
   SetProperty ( <"form"> , <"control"> , 'Enabled' , .F. )

#command RELEASE CONTROL <control> OF <form>;
   =>;
   DoMethod ( <"form"> , <"control"> , 'Release' )

#translate MODIFY [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> <Arg4> ;
=> ;
SetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , <Arg4> )

#xtranslate MODIFY [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> ( <Arg4> ) <Arg5> ;
=> ;
SetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , <Arg4> , <Arg5> )

#xtranslate FETCH [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> TO <Arg4> ;
=> ;
<Arg4> := GetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> )

#xtranslate FETCH [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> (<Arg4>) TO <Arg5> ;
=> ;
<Arg5> := GetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , <Arg4> )

#xtranslate MODIFY [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> .T. ;
=> ;
SetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , .T. )

#xtranslate MODIFY [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> .F. ;
=> ;
SetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , .F. )

#xtranslate MODIFY [ PROPERTY ] [ CONTROL ] <Arg2> OF <Arg1> <Arg3> { <Arg4, ...> } ;
=> ;
SetProperty ( <"Arg1"> , <"Arg2"> , <"Arg3"> , \{<Arg4>\} )

#translate SET MULTIPLE <x:ON,OFF> [ <warning: WARNING> ] ;
=> ;
_HMG_lMultiple := ( Upper(<(x)>) == "ON" ) ; iif ( _HMG_lMultiple == .F. .AND. _HMG_IsMultiple == .T. , ( iif ( <.warning.> , MsgStop( _HMG_MESSAGE\[4\] ) , ) , ExitProcess() ) , )

#translate CRLF => hb_OsNewLine()
#ifndef __XHARBOUR__
  #define hb_OsNewLine()   hb_eol()
#endif

#translate SET OOP [SUPPORT] <x:ON,OFF> => _HMG_lOOPEnabled := ( Upper(<(x)>) == "ON" )
#translate SET OOP [SUPPORT] TO <x>     => _HMG_lOOPEnabled := IFLOGICAL( <x>, <x>, .F. )

#xtranslate SET SCROLLSTEP TO <step> => _HMG_aScrollStep \[1\] := <step>
#xtranslate SET SCROLLPAGE TO <step> => _HMG_aScrollStep \[2\] := <step>

#translate SET AUTOSCROLL <x:ON,OFF> => _HMG_AutoScroll := ( Upper(<(x)>) == "ON" )

#translate SET CONTEXTMENUS <x:ON,OFF> => _HMG_ShowContextMenus := ( Upper(<(x)>) == "ON" )

#translate SET CONTEXTMENU <x:ON,OFF>  => _HMG_ShowContextMenus := ( Upper(<(x)>) == "ON" )

#translate SET CONTEXT MENU <x:ON,OFF> => _HMG_ShowContextMenus := ( Upper(<(x)>) == "ON" )

#translate SET PROGRAMMATICCHANGE <x:ON,OFF> => _HMG_ProgrammaticChange := ( Upper(<(x)>) == "ON" )

#translate SET GLOBALHOTKEYS <x:ON,OFF> => _HMG_GlobalHotkeys := ( Upper(<(x)>) == "ON" )

#translate SET GLOBAL HOTKEYS <x:ON,OFF> => _HMG_GlobalHotkeys := ( Upper(<(x)>) == "ON" )

#xcommand SET SHOWDETAILERROR <x:ON,OFF> => _lShowDetailError( Upper(<(x)>) == "ON" )

#command CLEAN MEMORY => iif( _HMG_IsXP, CleanProgramMemory(), iif( IsVistaOrLater(), EmptyWorkingSet(), ) )

#command SET EVENTS FUNCTION TO <fname> [ RESULT TO <lSuccess> ] ;
=> ;
[ <lSuccess> := ] SetGlobalListener( <"fname"> )

#xcommand @ <row>,<col> ANIGIF <ControlName> ;
      [ OBJ <oGif> ] ;
      [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
      PICTURE <filename> ;
      [ WIDTH <nWidth> ] ;
      [ HEIGHT <nHeight> ] ;
      [ DELAY <nDelay> ] ;
      [ BACKGROUNDCOLOR <backgroundcolor> ] ;
=>;
      [ <oGif> := ] _DefineAniGif ( <"ControlName">, <"parent">, <filename>, <row>, <col>, <nWidth>, <nHeight>, <nDelay>, <backgroundcolor> )

#command RELEASE ANIGIF <name> OF <parent> ;
=>;
      _ReleaseAniGif ( <"name">, <"parent"> )

#xcommand DRAW PANEL IN WINDOW <parent> ;
      AT <frow>,<fcol> ;
      TO <trow>,<tcol> ;
=>;
      DrawWindowBoxRaised( <"parent">, <frow>, <fcol>, <trow>, <tcol> )

#xcommand DRAW BOX IN WINDOW <parent> ;
      AT <frow>,<fcol> ;
      TO <trow>,<tcol> ;
=>;
      DrawWindowBoxIn( <"parent">, <frow>, <fcol>, <trow>, <tcol> )

#xcommand DRAW GRADIENT IN WINDOW <parent> ;
      AT <frow>,<fcol> ;
      TO <trow>,<tcol> ;
      [ BEGINCOLOR <aColor1> ] ;
      [ ENDCOLOR <aColor2> ] ;
      [ <vertical: VERTICAL> ] ;
      [ BORDER <border> ] ;
=>;
      DrawGradient( <"parent">, <frow>, <fcol>, <trow>, <tcol>,;
                    <aColor1>, <aColor2>, <.vertical.>, <border> )

/*
 * Virtual keys wrappers
 */
#xtranslate InsertReturn() => InsertVKey( VK_RETURN )
#xtranslate InsertPoint() => InsertVKey( VK_DECIMAL )
#xtranslate InsertTab() => InsertVKey( VK_TAB )
#xtranslate InsertBackspace() => InsertVKey( VK_BACK )
#xtranslate InsertUp() => InsertVKey( VK_UP )
#xtranslate InsertDown() => InsertVKey( VK_DOWN )
#xtranslate InsertPrior() => InsertVKey( VK_PRIOR )
#xtranslate InsertNext() => InsertVKey( VK_NEXT )

// Release Control by given Window Handle

#define WM_SYSCOMMAND	274
#define SC_CLOSE	61536

#xtranslate ReleaseControl ( <hWnd> ) ;
=> ;
iif ( IsWindowHandle( <hWnd> ), SendMessage( <hWnd>, WM_SYSCOMMAND, SC_CLOSE, 0 ), )

// Get Window position and sizes

#xtranslate GetWindowRow ( <hWnd> ) ;
=> ;
GetWindowRect( <hWnd>, 1 )

#xtranslate GetWindowCol ( <hWnd> ) ;
=> ;
GetWindowRect( <hWnd>, 2 )

#xtranslate GetWindowWidth ( <hWnd> ) ;
=> ;
GetWindowRect( <hWnd>, 3 )

#xtranslate GetWindowHeight ( <hWnd> ) ;
=> ;
GetWindowRect( <hWnd>, 4 )
