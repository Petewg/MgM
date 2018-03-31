/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Graph and Process Bar Demo'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2006 Grigory Filatov'

Static RxValue := 0, TxValue := 0

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT CreateChildForm(0, 0) ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP PROGRAM

		DEFINE NOTIFY MENU OF Form_Main
		ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
		SEPARATOR	
		ITEM '&Exit'		ACTION Form_Main.Release
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_Main

Return

*--------------------------------------------------------*
Static Procedure CreateChildForm( nTop, nLeft )
*--------------------------------------------------------*

	DEFINE FONT DefaultFont FONTNAME 'Arial' SIZE 12 DEFAULT

	DEFINE WINDOW Form_1 ;
		AT nTop, nLeft ;
		WIDTH 640 HEIGHT 480 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		CHILD ;
		TOPMOST ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT RefreshWin( GetFormHandle('Form_1') ) ;
		ON PAINT ( MyGraph( GetFormHandle('SplitChild_1'), RxValue, TxValue, 0 ), ;
			MyBarGraph( GetFormHandle('SplitChild_2'), TxValue ) ) ;
		ON INTERACTIVECLOSE ReleaseAllWindows()

		DEFINE BUTTON Button_1
			ROW    410
			COL    300
			WIDTH  80
			HEIGHT 26
			CAPTION "OK"
			ACTION ThisWindow.Release
			DEFAULT .T.
		END BUTTON

		DEFINE SPLITBOX

		DEFINE WINDOW SplitChild_1 ;
			WIDTH 370 ;
			HEIGHT 300 ;
			SPLITCHILD ;
			NOCAPTION

		END WINDOW 

		DEFINE WINDOW SplitChild_2 ;
			WIDTH 250 ;
			HEIGHT 300 ;
			SPLITCHILD ;
			NOCAPTION

		END WINDOW 

		END SPLITBOX

		DEFINE LABEL Label_1
			ROW	352
			COL	10
			WIDTH	180
			HEIGHT  23
			VALUE	'Green Packet Data'
		END LABEL

		DEFINE TEXTBOX Text_1
			ROW	350
			COL	200
			WIDTH	40
			HEIGHT  23
			VALUE	RxValue
			NUMERIC .T.
			RIGHTALIGN .T.
			READONLY .T.
		END TEXTBOX

		DEFINE LABEL Label_2
			ROW	382
			COL	10
			WIDTH	180
			HEIGHT  23
			VALUE	'Red Packet Data'
		END LABEL

		DEFINE TEXTBOX Text_2
			ROW	380
			COL	200
			WIDTH	40
			HEIGHT  23
			VALUE	TxValue
			NUMERIC .T.
			RIGHTALIGN .T.
			READONLY .T.
		END TEXTBOX

		DEFINE TIMER Timer_1 INTERVAL 1000 ACTION OnTimer()

	END WINDOW

	IF EMPTY(nTop) .AND. EMPTY(nLeft)
		CENTER WINDOW Form_1
	ENDIF

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure OnTimer()
*--------------------------------------------------------*

  // Random values selectable for demo 
  if RxValue > 150
	RxValue -= 27
  else
 	RxValue += 12
  endif

  if TxValue > 80
	TxValue -= 17
  else
	TxValue += 12
  endif

  Form_1.Text_1.Value := RxValue
  Form_1.Text_2.Value := TxValue

  RefreshWin( GetFormHandle('Form_1') )

Return

#define WM_PAINT	15
*--------------------------------------------------------*
Static Procedure RefreshWin( hWnd )
*--------------------------------------------------------*

	SendMessage( hWnd, WM_PAINT, 0, 0 )
	Do Events

Return


#pragma BEGINDUMP

#include <shlobj.h>
#include <windows.h>
#include "hbapi.h"

#include "Graph.h"
#include "Graph.c"

HB_FUNC( MYGRAPH )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   HDC  hDC  = GetDC( hWnd );
   RECT rect;

   GetClientRect(hWnd, &rect);

   DrawGraph(hDC, rect);
   UpdateGraph(hDC, rect, hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ));

   ReleaseDC( hWnd, hDC );
}

HB_FUNC( MYBARGRAPH )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   HDC  hDC  = GetDC( hWnd );
   RECT rect;

   GetClientRect(hWnd, &rect);

   DrawBar(hDC, rect, hb_parni( 2 ));

   ReleaseDC( hWnd, hDC );
}

#pragma ENDDUMP