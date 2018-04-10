/*
 * Program: Memory Statistics
 *
 * Copyright © 2007-2010 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Memory Statistics'
#define VERSION ' version 1.1'
#define COPYRIGHT ' Grigory Filatov, 2010'

DECLARE WINDOW Form_1
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_0 			;
		AT 0,0 				;
		WIDTH 0 HEIGHT 0 		;
		TITLE PROGRAM 			;
		ICON 'MAIN' 			;
		MAIN NOSHOW 			;
		ON INIT OnInit()		;
		NOTIFYICON 'MAIN' 		;
		NOTIFYTOOLTIP PROGRAM 		;
		ON NOTIFYCLICK ShowStat()

		DEFINE NOTIFY MENU 
			ITEM 'Show/Hide'	ACTION ShowStat()
			ITEM 'About...'	ACTION ShellAbout( "About " + PROGRAM + "#", ;
				PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
				LoadIconByName("MAIN") )
			SEPARATOR	
			ITEM 'Exit'		ACTION Form_0.Release
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_0

Return

*--------------------------------------------------------*
Static Procedure ShowStat()
*--------------------------------------------------------*

If IsWindowDefined( Form_1 )

	If IsWindowVisible( GetFormHandle('Form_1') )
		Form_1.Hide
	Else
		Form_1.Show
		RefreshPaint()
		RefreshStat()
	EndIf

Else

	DEFINE WINDOW Form_1			;
		AT 0,0				;
		WIDTH 241 HEIGHT 395		;
		TITLE PROGRAM			;
		CHILD NOCAPTION			;
		NOMINIMIZE NOMAXIMIZE		;
		NOSIZE				;
		TOPMOST				;
		ON INIT ( RefreshStat(), Form_1.Btn_OK.Setfocus ) ;
		ON MOUSECLICK MoveActiveWindow();
		FONT 'MS Sans Serif' SIZE 9

		DRAW PANEL IN WINDOW Form_1 ;
			AT 1, 1 ;
			TO Form_1.Height-1, Form_1.Width-1

		DRAW PANEL IN WINDOW Form_1 ;
			AT 2, 2 ;
			TO Form_1.Height-2, Form_1.Width-2

		DRAW PANEL IN WINDOW Form_1 ;
			AT 8, 8 ;
			TO 56, Form_1.Width-9

		DRAW PANEL IN WINDOW Form_1 ;
			AT 64, 8 ;
			TO 386, Form_1.Width-9

		@356,66 BUTTONEX Btn_Refresh ;
			PICTURE "REFRESH" ;
			CAPTION "&Refresh" ;
			ACTION RefreshStat() ;
			WIDTH 72 HEIGHT 23

		@356,154 BUTTONEX Btn_OK ;
			PICTURE "OK" ;
			CAPTION "OK" ;
			ACTION Form_1.Hide ;
			WIDTH 70 HEIGHT 23 DEFAULT

		// First Panel

		DRAW ICON IN WINDOW Form_1 AT 16, 16 ;
			PICTURE "TYPE"

		@ 12,58 LABEL Label_1 VALUE "MemStat" + Right(VERSION, 4) ;
			WIDTH 120 HEIGHT 14 FONT "MS Sans Serif" SIZE 9 BOLD ;
			ACTION MoveActiveWindow()

		@ 26,58 LABEL Label_2 VALUE "Copyright " + Chr(169) + COPYRIGHT + ;
			CRLF + "Freeware Version" WIDTH 160 HEIGHT 28 FONTCOLOR GRAY ;
			ACTION MoveActiveWindow()

		// Second Panel

		@ 68,16 LABEL Label_3 VALUE PROGRAM ;
			WIDTH 160 HEIGHT 24 FONT "Arial Narrow" SIZE 15 BOLD ;
			ACTION MoveActiveWindow()

		// First Frame

		@ 96,16 FRAME Frame_1 CAPTION 'Physical Memory' ;
			WIDTH Form_1.Width-32 HEIGHT 64

		@ 112,32 LABEL Label_11 VALUE "Total" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 127,32 LABEL Label_12 VALUE "Used" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 142,32 LABEL Label_13 VALUE "Available" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 112,Form_1.Width-120 LABEL Label_14 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 127,Form_1.Width-120 LABEL Label_15 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 142,Form_1.Width-120 LABEL Label_16 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 127,83 LABEL Label_17 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 142,83 LABEL Label_18 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		// Second Frame

		@ 166,16 FRAME Frame_2 CAPTION 'Paging File' ;
			WIDTH Form_1.Width-32 HEIGHT 64

		@ 182,32 LABEL Label_21 VALUE "Total" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 197,32 LABEL Label_22 VALUE "Used" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 212,32 LABEL Label_23 VALUE "Available" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 182,Form_1.Width-120 LABEL Label_24 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 197,Form_1.Width-120 LABEL Label_25 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 212,Form_1.Width-120 LABEL Label_26 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 197,83 LABEL Label_27 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 212,83 LABEL Label_28 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		// Third Frame

		@ 236,16 FRAME Frame_3 CAPTION 'Virtual Memory' ;
			WIDTH Form_1.Width-32 HEIGHT 64

		@ 252,32 LABEL Label_31 VALUE "Total" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 267,32 LABEL Label_32 VALUE "Used" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 282,32 LABEL Label_33 VALUE "Available" WIDTH 50 HEIGHT 14 ;
			ACTION MoveActiveWindow()

		@ 252,Form_1.Width-120 LABEL Label_34 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 267,Form_1.Width-120 LABEL Label_35 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 282,Form_1.Width-120 LABEL Label_36 VALUE "" WIDTH 90 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 267,83 LABEL Label_37 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		@ 282,83 LABEL Label_38 VALUE "" WIDTH 32 HEIGHT 14 RIGHTALIGN ;
			ACTION MoveActiveWindow()

		// Fourth Frame

		@ 306,16 FRAME Frame_4 CAPTION 'Show as' ;
			WIDTH Form_1.Width-32 HEIGHT 42

		@ 318,26 RADIOGROUP Radio_1 ;
			OPTIONS { '&GBytes', '&MBytes', '&KBytes' } ;
			VALUE 2 ;
			WIDTH 60 ;
			SPACING 4 ;
			ON CHANGE RefreshStat() ;
			HORIZONTAL

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

EndIf

Return

*--------------------------------------------------------*
Procedure OnInit
*--------------------------------------------------------*

	CLEAN MEMORY

Return

#define WM_PAINT	15
*--------------------------------------------------------*
Static Procedure RefreshPaint()
*--------------------------------------------------------*

	SendMessage( GetFormHandle('Form_1'), WM_PAINT, 0, 0 )
	DO EVENTS

Return

*--------------------------------------------------------*
Static Procedure RefreshStat()
*--------------------------------------------------------*
Local nShow := Form_1.Radio_1.Value, nSwap
Local cMeasure := " " + IF(nShow==1, "G", IF(nShow==2, "M", "K")) + "B"
Local aMemStat := { MemoryStatus(1) + IF(IsWinNT(), 0, 1024), MemoryStatus(2), ;
	Abs( MemoryStatus(3) ), Abs( MemoryStatus(4) ), ;
	MemoryStatus(5), MemoryStatus(6) }
Local n14 := aMemStat[ 1 ], n15 := aMemStat[ 1 ] - aMemStat[ 2 ], n16 := aMemStat[ 2 ]
Local n24 := aMemStat[ 3 ], n25 := aMemStat[ 3 ] - aMemStat[ 4 ], n26 := aMemStat[ 4 ]
Local n34 := aMemStat[ 5 ], n35 := aMemStat[ 5 ] - aMemStat[ 6 ], n36 := aMemStat[ 6 ]

	IF IsWinNT()
		nSwap := n24
		n24 := Max( n24, n26 )
		n25 := Abs( n25 )
		n26 := Min( nSwap, n26 )
	ENDIF

	IF nShow==1
		n14 := n14 / ( 1024 * 1024 )
		n15 := n15 / ( 1024 * 1024 )
		n16 := n16 / ( 1024 * 1024 )
		n24 := n24 / ( 1024 * 1024 )
		n25 := n25 / ( 1024 * 1024 )
		n26 := n26 / ( 1024 * 1024 )
		n34 := n34 / ( 1024 * 1024 )
		n35 := n35 / ( 1024 * 1024 )
		n36 := n36 / ( 1024 * 1024 )
	ELSEIF nShow==2
		n14 := n14 / 1024
		n15 := n15 / 1024
		n16 := n16 / 1024
		n24 := n24 / 1024
		n25 := n25 / 1024
		n26 := n26 / 1024
		n34 := n34 / 1024
		n35 := n35 / 1024
		n36 := n36 / 1024
	ENDIF

	Form_1.Label_14.Value := Ltrim(Transform(n14,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_15.Value := Ltrim(Transform(n15,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_16.Value := Ltrim(Transform(n16,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_17.Value := Ltrim(Transform(round(n15/n14*100,0),"999")) + "%"
	Form_1.Label_18.Value := Ltrim(Transform(round(n16/n14*100,0),"999")) + "%"

	Form_1.Label_24.Value := Ltrim(Transform(n24,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_25.Value := Ltrim(Transform(n25,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_26.Value := Ltrim(Transform(n26,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_27.Value := Ltrim(Transform(round(n25/n24*100,0),"999")) + "%"
	Form_1.Label_28.Value := Ltrim(Transform(round(n26/n24*100,0),"999")) + "%"

	Form_1.Label_34.Value := Ltrim(Transform(n34,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_35.Value := Ltrim(Transform(n35,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_36.Value := Ltrim(Transform(n36,IF(nShow==1, "999.99", "999,999,999"))) + cMeasure
	Form_1.Label_37.Value := Ltrim(Transform(round(n35/n34*100,0),"999")) + "%"
	Form_1.Label_38.Value := Ltrim(Transform(round(n36/n34*100,0),"999")) + "%"

Return

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161
*--------------------------------------------------------*
Procedure MoveActiveWindow( hWnd )
*--------------------------------------------------------*
	DEFAULT hWnd := GetActiveWindow()

	PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)

Return


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( MEMORYSTATUS )
{
      MEMORYSTATUS mst;
      LONG n = hb_parnl(1);

      mst.dwLength = sizeof( MEMORYSTATUS );
      GlobalMemoryStatus( &mst );

      switch( n )
      {
         case 1:  hb_retnl( mst.dwTotalPhys / 1024 ) ; break;
         case 2:  hb_retnl( mst.dwAvailPhys / 1024 ) ; break;
         case 3:  hb_retnl( mst.dwTotalPageFile / 1024 ) ; break;
         case 4:  hb_retnl( mst.dwAvailPageFile / 1024 ) ; break;
         case 5:  hb_retnl( mst.dwTotalVirtual / 1024 ) ; break;
         case 6:  hb_retnl( mst.dwAvailVirtual / 1024 ) ; break;
         default: hb_retnl( 0 ) ;
      }
}

HB_FUNC (LOADTRAYICON)
{
	HICON himage;
	HINSTANCE hInstance  = (HINSTANCE) hb_parnl(1);  // handle to application instance
	LPCTSTR   lpIconName = (LPCTSTR)   hb_parc(2);   // name string or resource identifier

	himage = (HICON) LoadImage( hInstance , lpIconName , IMAGE_ICON, 16, 16, LR_SHARED ) ;

	if (himage==NULL)
	{
		himage = (HICON) LoadImage( hInstance , lpIconName , IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE ) ;
	}

	hb_retnl ( (LONG) himage );
}

#pragma ENDDUMP
