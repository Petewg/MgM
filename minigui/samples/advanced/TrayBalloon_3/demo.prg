/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2015 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#define PROGRAM		"SysTray Sample"
#define VERSION		" version 1.0"
#define COPYRIGHT	" Grigory Filatov, 2015"

#define	IDI_BOB		1001
#define	IDI_TOOTH	1002
#define	IDI_STIMPY	1003


Static pMainWin, ahTrayIcons := {}

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
	Local anResIcons := { IDI_BOB, IDI_TOOTH, IDI_STIMPY }

	SET MULTIPLE OFF

	SET TOOLTIPBALLOON ON

	SET FONT TO _GetSysFont(), 9

	AEval( anResIcons, { |nIcon| aAdd( ahTrayIcons, LoadTrayIcon( GetInstance(), nIcon ) ) } )

	DEFINE WINDOW Form_1 					;
		AT 0,0 						;
		WIDTH 300 HEIGHT 290 				;
		TITLE PROGRAM + " Application"			;
		ICON IDI_BOB					;
		MAIN 						;
		NOMAXIMIZE NOSIZE				;
		ON NOTIFYDBLCLICK ProcessNotifyDblClick()	;
		ON INIT OnInit() 				;
		ON PAINT OnPaint() 				;
		ON RELEASE OnExit()

		@10,20 ANIMATEBOX Ani_Minigui ;
			WIDTH 135 ;
			HEIGHT 36 ;
			FILE 'Minigui' AUTOPLAY

		@ 64,20 CHECKBOX Check1 CAPTION "S&how in Systray" WIDTH 110 ;
			VALUE .T. ;
			ON CHANGE Command1_Click()

		@ 100,60 RADIOGROUP Option1 ; 
			OPTIONS { "&Bob", "&Tooth Beaver", "&Stimpy" } ; 
			WIDTH 110 ;
			SPACING 38 ;
			VALUE 1 ;
			ON CHANGE Option_Click()

		@ 220,20 BUTTON Command_ShowTip ;
			CAPTION 'Show In&foTip' ;
			ACTION Command2_Click() ;
			WIDTH 110 ;
			HEIGHT 28

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure ProcessNotifyDblClick()
*--------------------------------------------------------*

	IF IsWindowVisible( Application.Handle )
		Form_1.Hide
	ELSE
		Form_1.Restore
		refresh_it( Application.Handle )
	ENDIF

Return

#define WM_PAINT	15

Static Function refresh_it( hWnd )

	SendMessage( hWnd, WM_PAINT, 0, 0 )

Return NIL

*--------------------------------------------------------*
Static Procedure OnInit()
*--------------------------------------------------------*

	pMainWin := win_N2P( Application.Handle )

	Form_1.Command_ShowTip.Enabled := ShellTrayIconAdd( pMainWin, win_N2P( ahTrayIcons[ 1 ] ), PROGRAM )

	DEFINE NOTIFY MENU OF Form_1
		ITEM 'A&bout...'	ACTION ShellAbout( "About " + PROGRAM + "#", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
			LoadTrayIcon( GetInstance(), IDI_BOB ) )
		SEPARATOR	
		ITEM 'E&xit'		ACTION Form_1.Release
	END MENU

Return

*--------------------------------------------------------*
Static Procedure OnExit()
*--------------------------------------------------------*

   ShellTrayIconRemove( pMainWin )
   AEval( ahTrayIcons, { |hIcon| DestroyIcon( hIcon ) } )

Return

*--------------------------------------------------------*
Static Procedure OnPaint()
*--------------------------------------------------------*
   Local hMainWin := Application.Handle
   Local nIconIndex, nRow := 96

   FOR nIconIndex := 1 TO 3
      DrawIcon( hMainWin, 20, nRow, ahTrayIcons[ nIconIndex ] )
      nRow += 38
   NEXT

Return

*--------------------------------------------------------*
Static Procedure Command1_Click()
*--------------------------------------------------------*
   Local nIconIndex := Form_1.Option1.Value

   IF Form_1.Check1.Value
      Form_1.Command_ShowTip.Enabled := ShellTrayIconAdd( pMainWin, win_N2P( ahTrayIcons[ nIconIndex ] ), PROGRAM )
      Form_1.Option1.Enabled := ( Form_1.Command_ShowTip.Enabled )
   ELSE
      ShellTrayIconRemove( pMainWin )
      Form_1.Option1.Enabled := .F.
      Form_1.Command_ShowTip.Enabled := .F.
   ENDIF

Return

*--------------------------------------------------------*
Static Procedure Command2_Click()
*--------------------------------------------------------*

   ShellTrayBalloonTipShow( pMainWin, 1, PROGRAM, ;
      "This SysTray form allows to show a long text in the balloon tips." )

Return

*--------------------------------------------------------*
Static Procedure Option_Click()
*--------------------------------------------------------*
   Local nIconIndex := Form_1.Option1.Value

   Form_1.Command_ShowTip.Enabled := ShellTrayIconChange( pMainWin, win_N2P( ahTrayIcons[ nIconIndex ] ) )
   Form_1.Option1.Enabled := ( Form_1.Command_ShowTip.Enabled )

Return

/* win_ShellNotifyIcon( [<hWnd>], [<nUID>], [<nMessage>], [<hIcon>],
                        [<cTooltip>], [<lAddDel>],
                        [<cInfo>], [<nInfoTimeOut>], [<cInfoTitle>], [<nInfoFlags>] ) -> <lOK> */

*--------------------------------------------------------*
Function ShellTrayIconAdd( pWnd, pIcon, cToolTip )
*--------------------------------------------------------*

Return win_ShellNotifyIcon( pWnd, ID_TASKBAR, WM_TASKBAR, pIcon, cTooltip, .T. )

*--------------------------------------------------------*
Function ShellTrayIconChange( pWnd, pIcon )
*--------------------------------------------------------*

Return win_ShellNotifyIcon( pWnd, , , pIcon )

*--------------------------------------------------------*
Function ShellTrayIconRemove( pWnd )
*--------------------------------------------------------*

Return win_ShellNotifyIcon( pWnd, , , , , .F. )

*--------------------------------------------------------*
Function ShellTrayBalloonTipShow( pWnd, nIconIndex, cTitle, cMessage )
*--------------------------------------------------------*

Return win_ShellNotifyIcon( pWnd, , , , , , cMessage, 10000, cTitle, nIconIndex )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( DRAWICON )
{
    HWND hwnd;
    HDC hdc;

    hwnd  = ( HWND ) hb_parnl( 1 ) ;
    hdc   = GetDC( hwnd ) ;
 
    hb_retl( DrawIcon( ( HDC ) hdc , hb_parni( 2 ) , hb_parni( 3 ) , ( HICON ) hb_parnl( 4 ) ) ) ;
    ReleaseDC( hwnd, hdc ) ;
}

HB_FUNC( DESTROYICON )
{
   DestroyIcon( ( HICON ) hb_parnl( 1 ) );
}

#pragma ENDDUMP
