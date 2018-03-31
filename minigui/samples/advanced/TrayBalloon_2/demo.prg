/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2010 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#define PROGRAM		"SysTray Timed Balloon Tip Demo"
#define VERSION		" version 1.1"
#define COPYRIGHT	" Grigory Filatov, 2010-2012"

#define	IDI_MAIN	1001

Static lTimerRunning := .F.
Static hMainWin
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	SET TOOLTIPBALLOON ON

	SET FONT TO "Tahoma", 9

	DEFINE WINDOW Form_1 							;
		AT 0,0 								;
		WIDTH 400 HEIGHT 290 						;
		TITLE PROGRAM 							;
		ICON IDI_MAIN							;
		MAIN 								;
		NOMAXIMIZE NOSIZE						;
		ON NOTIFYBALLOONCLICK MsgInfo( "Action for tooltip click!" )	;
		ON INIT OnInit() 						;
		ON RELEASE OnExit()

		@20,20 EDITBOX Text1 ;
		WIDTH 350 ;
		HEIGHT 80 ;
		MAXLENGTH 500 ;
		NOHSCROLL

		@ 110,20 RADIOGROUP Option1 ; 
		OPTIONS { "&no icon", "information icon", "warning icon", "error icon" } ; 
		WIDTH 110 ;
		SPACING 23 ;
		VALUE 2

		@ 220,20 BUTTON Command1 ;
		CAPTION 'Add Systray Icon' ;
		ACTION Command1_Click() ;
		WIDTH 110 ;
		HEIGHT 23

		@ 220,170 BUTTON Command2 ;
		CAPTION 'Show Balloon Tip' ;
		ACTION Command2_Click() ;
		WIDTH 110 ;
		HEIGHT 23

	END WINDOW

	Form_1.Text1.Value := "The balloon tip shown in this demo " + ;
                "will automatically disappear when " + ;
                "the assigned time has elapsed. For " + ;
                "this demo the balloon will close in " + ;
                "7000 milliseconds (AKA seven seconds)." + ;
                CRLF + CRLF + ;
                "Clicking the balloon tip will cause it to close immediately."

	Form_1.Command2.Enabled := .F.

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure OnInit()
*--------------------------------------------------------*

	IF !IsWinNT()

		MsgStop( 'This Program Runs In Win2000/XP or later Only!', 'Stop' )
		QUIT

	ENDIF

	hMainWin := WIN_N2P( Application.Handle )

	DEFINE NOTIFY MENU OF Form_1
		ITEM 'A&bout...'	ACTION ShellAbout( "About " + PROGRAM + "#", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
			LoadTrayIcon( GetInstance(), IDI_MAIN, 32, 32 ) )
		SEPARATOR	
		ITEM 'E&xit'		ACTION Form_1.Release
	END MENU

Return

*--------------------------------------------------------*
Static Procedure OnExit()
*--------------------------------------------------------*

   ShellTrayIconRemove( hMainWin )

Return

*--------------------------------------------------------*
Static Procedure Command1_Click()
*--------------------------------------------------------*
   Local cToolTip
   Local hIcon

   cToolTip := "This is the Balloon Tip Demo"
   hIcon := WIN_N2P( LoadTrayIcon( GetInstance(), IDI_MAIN ) )

   Form_1.Command2.Enabled := ShellTrayIconAdd( hMainWin, hIcon, cToolTip )
   
Return

*--------------------------------------------------------*
Static Procedure Command2_Click()
*--------------------------------------------------------*
   Local nIconIndex
   Local cTitle
   Local cMessage
   
   nIconIndex := Form_1.Option1.Value - 1
   cTitle := "Balloon Tip Demo"
   cMessage := Form_1.Text1.Value

   If ShellTrayBalloonTipShow( hMainWin, nIconIndex, cTitle, cMessage )
      If lTimerRunning == .F.
         lTimerRunning := .T.
         DEFINE TIMER Timer1 OF Form_1 INTERVAL 7000 ACTION OnTimer()
      EndIf
   EndIf

Return

*--------------------------------------------------------*
Static Procedure OnTimer()
*--------------------------------------------------------*

   Form_1.Timer1.Release()
   lTimerRunning := .F.

   ShellTrayBalloonTipClose( hMainWin )

Return

/* WIN_ShellNotifyIcon( [<hWnd>], [<nUID>], [<nMessage>], [<hIcon>],
                        [<cTooltip>], [<lAddDel>],
                        [<cInfo>], [<nInfoTimeOut>], [<cInfoTitle>], [<nInfoFlags>] ) -> <lOK> */

*--------------------------------------------------------*
Function ShellTrayIconAdd( hWnd, hIcon, cToolTip )
*--------------------------------------------------------*

Return WIN_ShellNotifyIcon( hWnd, ID_TASKBAR, WM_TASKBAR, hIcon, cTooltip, .T. )

*--------------------------------------------------------*
Function ShellTrayIconRemove( hWnd )
*--------------------------------------------------------*

Return WIN_ShellNotifyIcon( hWnd, , , , , .F. )

*--------------------------------------------------------*
Procedure ShellTrayBalloonTipClose( hWnd )
*--------------------------------------------------------*

	WIN_ShellNotifyIcon( hWnd, , , , , , Chr(0) )

Return

*--------------------------------------------------------*
Function ShellTrayBalloonTipShow( hWnd, nIconIndex, cTitle, cMessage )
*--------------------------------------------------------*

Return WIN_ShellNotifyIcon( hWnd, , , , , , cMessage, 20000, cTitle, nIconIndex )
