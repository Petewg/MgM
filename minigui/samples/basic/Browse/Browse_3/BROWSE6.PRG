/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main
	LOCAL lDoubleBuffer := .T.

	SET NAVIGATION EXTENDED

	SET BROWSESYNC ON	

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
                                ITEM 'Set Browse Value'		ACTION Form_1.Browse_1.Value := 10
                                ITEM 'Get Browse Value'		ACTION MsgInfo ( Form_1.Browse_1.Value )
                                ITEM 'Refresh Browse'		ACTION Form_1.Browse_1.Refresh()
				SEPARATOR
                                ITEM 'Paint Double Buffer'	ACTION { lDoubleBuffer := ! lDoubleBuffer, PaintDoubleBuffer (lDoubleBuffer) } NAME menu_db CHECKED
				SEPARATOR
                                ITEM 'Exit'			ACTION Form_1.Release()
			END POPUP
			POPUP 'Help'
				ITEM 'About'			ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready'
			STATUSITEM '<Enter> / Double Click To Edit' WIDTH 200
			STATUSITEM 'Alt+A: Append' WIDTH 120
		END STATUSBAR

                DEFINE BROWSE Browse_1
                        ROW 10
                        COL 10
                        WIDTH 610
                        HEIGHT 390 - GetBorderHeight()
                        HEADERS { 'Field 1' , 'Field 2' , 'Field 3', 'Field 4', 'Field 5' , 'Field 6' , 'Field 7', 'Field 8' , 'Field 9' , 'Field 10'  , 'Field 11' , 'Field 12' , 'Field 13' , 'Field 14' , 'Field 15' , 'Field 16' , 'Field 17' , 'Field 18' , 'Field 19' , 'Field 20' , 'Field 21' , 'Field 22' , 'Field 23' , 'Field 24' , 'Field 25' , 'Field 26' , 'Field 27' , 'Field 28' , 'Field 29' , 'Field 30' , 'Field 31' , 'Field 32' }
                        WIDTHS  { 100       ,100        ,100       ,100       ,100        ,100        ,100        ,100       ,100        ,100          ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         ,100         }
                        WORKAREA MuchFields
                        FIELDS { 'c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12','c13','c14','c15','c16','c17','c18','c19','c20','c21','c22','c23','c24','c25','c26','c27','c28','c29','c30','c31','c32' } 
                        VALUE 1
                        ALLOWEDIT .T.
                        LOCK .T.
                        ALLOWAPPEND .T.
			PAINTDOUBLEBUFFER lDoubleBuffer
                END BROWSE

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure OpenTables()
	Use MuchFields Shared
Return


Procedure CloseTables()
	Use
Return


#define LVS_EX_DOUBLEBUFFER 0x10000

Procedure PaintDoubleBuffer( lSwitch )

	Form_1.menu_db.Checked := lSwitch
	IF lSwitch
		ListView_ChangeExtendedStyle ( GetControlHandle('Browse_1','Form_1'), LVS_EX_DOUBLEBUFFER, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( GetControlHandle('Browse_1','Form_1'), NIL, LVS_EX_DOUBLEBUFFER )
	ENDIF

Return


#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>

#include "hbapi.h"

//       ListView_ChangeExtendedStyle ( hWnd, [ nAddStyle ], [ nRemoveStyle ] )
HB_FUNC( LISTVIEW_CHANGEEXTENDEDSTYLE )
{
   HWND  hWnd = (HWND) hb_parnl( 1 );
   DWORD Add = (DWORD) hb_parnl( 2 );
   DWORD Remove = (DWORD) hb_parnl( 3 );
   DWORD OldStyle, NewStyle, Style;

   OldStyle = ListView_GetExtendedListViewStyle( hWnd );
   NewStyle = ( OldStyle | Add) & ( ~Remove );
   Style = ListView_SetExtendedListViewStyle( hWnd, NewStyle );

   hb_retnl ((LONG) Style);
}

#pragma ENDDUMP
