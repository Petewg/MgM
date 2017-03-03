/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "hmg.ch"

#define PROGRAM 'System ToolBox'
#define VERSION ' version 1.2'
#define COPYRIGHT ' Grigory Filatov, 2002-2007'

#define EWX_LOGOFF   0
#define EWX_SHUTDOWN 1
#define EWX_REBOOT   2
#define EWX_FORCE    4
#define EWX_POWEROFF 8

#define WM_SYSCOMMAND 274       // &H112
#define SC_SCREENSAVE 61760     // &HF140
#DEFINE SC_TASKLIST   61744     // &HF130
#DEFINE SW_HIDE           0     // &H0
#DEFINE SW_SHOW           5     // &H5
#DEFINE SW_SHOWNA         8     // &H8
#DEFINE SC_MONITORPOWER  61808  // &HF170

DECLARE WINDOW Form_2

Static hMainForm
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON "MAINICON" ;
		MAIN NOSHOW ;
		NOTIFYICON "MAINICON" ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK HideOrShowForm()

		DEFINE NOTIFY MENU
			ITEM '&ShutDown System'		ACTION SysShutDown( EWX_SHUTDOWN, 0 )
			ITEM '&Reboot System'		ACTION SysShutDown( EWX_REBOOT, 0 )
			ITEM 'Fo&rce ShutDown'		ACTION SysShutDown( EWX_SHUTDOWN + EWX_FORCE, 0 )
			SEPARATOR
			ITEM '&Format Floppy...'	ACTION ShellExecute( 0, "open", "rundll32.exe", ;
							"Shell32.dll,SHFormatDrive", GetWindowsDir(), 0 )
			ITEM 'Run &ScreenSaver'		ACTION SendMessage( GetFormHandle("Form_1"), ;
							WM_SYSCOMMAND, SC_SCREENSAVE )
			ITEM '&Change Date/Time...'	ACTION Control( "shell32.dll,Control_RunDLL timedate.cpl" )
			SEPARATOR
			ITEM '&Mail to author...'	ACTION ShellExecute( 0, "open", "rundll32.exe", ;
							"url.dll,FileProtocolHandler " + ;
							"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
							"&subject=System%20ToolBox%20Feedback" + ;
							"&body=How%20are%20you%2C%20Grigory%3F", , 1 )
			ITEM '&About...'		ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + ;
							VERSION + CRLF + Chr(169) + COPYRIGHT, ;
							LoadTrayIcon(GetInstance(), "MAINICON") )
			SEPARATOR	
			ITEM 'E&xit'			ACTION Form_1.Release
		END MENU

	END WINDOW

	SysTools()

	ACTIVATE WINDOW Form_2, Form_1

Return

*--------------------------------------------------------*
Procedure SysTools()
*--------------------------------------------------------*
		hMainForm := GetFormHandle("Form_1")

		DEFINE WINDOW Form_2 AT 0,0 ;
			WIDTH 220 + 2 * GetBorderWidth() - 1 ;
			HEIGHT 504 + IF(IsXPThemeActive(), 6, 0) ;
			TITLE "System Tools" ;
			CHILD ;
			NOSIZE ;
			NOSYSMENU ;
			ON INTERACTIVECLOSE ReleaseAllWindows() ;
			FONT "MS Sans Serif" SIZE 8

			@ 0,0 BUTTON btn_1 ;
				CAPTION 'Disable Start Button' ;
				ACTION EnableSysWindow( FindWindowEx(FindWindow('Shell_TrayWnd', nil), 0, 'Button', nil), .F. ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Disable Start Button' ; 
				FLAT

			@ 0,110 BUTTON btn_2 ;
				CAPTION 'Enable Start Button' ;
				ACTION EnableSysWindow( FindWindowEx(FindWindow('Shell_TrayWnd', nil), 0, 'Button', nil), .T. ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Enable Start Button' ; 
				FLAT

			@ 24,0 BUTTON btn_3 ;
				CAPTION 'Hide Taskbar' ;
				ACTION ShowSysWindow( FindWindow('Shell_TrayWnd', nil), SW_HIDE ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Hide Taskbar' ; 
				FLAT

			@ 24,110 BUTTON btn_4 ;
				CAPTION 'Show Taskbar' ;
				ACTION ShowSysWindow( FindWindow('Shell_TrayWnd', nil), SW_SHOWNA ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Show Taskbar' ; 
				FLAT

			@ 48,0 BUTTON btn_5 ;
				CAPTION 'Hide Desktop Icons' ;
				ACTION ShowSysWindow( FindWindow(nil, 'Program Manager'), SW_HIDE ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Hide Desktop Icons' ; 
				FLAT

			@ 48,110 BUTTON btn_6 ;
				CAPTION 'Show Desktop Icons' ;
				ACTION ShowSysWindow( FindWindow(nil, 'Program Manager'), SW_SHOW ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Show Desktop Icons' ; 
				FLAT

			@ 72,0 BUTTON btn_7 ;
				CAPTION 'Press Start Button' ;
				ACTION SendMessage( hMainForm, WM_SYSCOMMAND, SC_TASKLIST, 0 ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Press Start Button' ; 
				FLAT

			@ 72,110 BUTTON btn_8 ;
				CAPTION 'Run ScreenSaver' ;
				ACTION SendMessage( hMainForm, WM_SYSCOMMAND, SC_SCREENSAVE, 0 ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Run ScreenSaver' ; 
				FLAT

			@ 96,0 BUTTON btn_9 ;
				CAPTION 'Control Panel' ;
				ACTION Control( "shell32.dll,Control_RunDLL" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Control Panel' ; 
				FLAT

			@ 96,110 BUTTON btn_10 ;
				CAPTION 'Install/Uninstall' ;
				ACTION Control( "shell32.dll,Control_RunDLL appwiz.cpl,,"+IF(_HMG_IsXP, "0", "1") ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Install and Uninstall of programs' ; 
				FLAT

			@ 120,0 BUTTON btn_11 ;
				CAPTION 'Components Install' ;
				ACTION Control( "shell32.dll,Control_RunDLL appwiz.cpl,,2" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Components Install' ; 
				FLAT

			@ 120,110 BUTTON btn_12 ;
				CAPTION IF(_HMG_IsXP, 'Default Programs', 'Bootable Disk') ;
				ACTION Control( "shell32.dll,Control_RunDLL appwiz.cpl,,3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP IF(_HMG_IsXP, 'Default Programs', 'Bootable Disk') ; 
				FLAT

			@ 144,0 BUTTON btn_13 ;
				CAPTION 'Display Background' ;
				ACTION Control( "shell32.dll,Control_RunDLL desk.cpl,,0" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Display Background' ; 
				FLAT

			@ 144,110 BUTTON btn_15 ;
				CAPTION 'Display Saver' ;
				ACTION Control( "shell32.dll,Control_RunDLL desk.cpl,,1" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Display Saver' ; 
				FLAT

			@ 168,0 BUTTON btn_16 ;
				CAPTION IF(_HMG_IsXP, 'Display Themes', 'Display Appearance') ;
				ACTION Control( "shell32.dll,Control_RunDLL desk.cpl,,"+IF(_HMG_IsXP, "5", "2") ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP IF(_HMG_IsXP, 'Display Themes', 'Display Appearance') ; 
				FLAT

			@ 168,110 BUTTON btn_14 ;
				CAPTION 'Display Settings' ;
				ACTION Control( "shell32.dll,Control_RunDLL desk.cpl,,3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Display Settings' ; 
				FLAT

			@ 192,0 BUTTON btn_17 ;
				CAPTION 'Internet General' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,0" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet General' ; 
				FLAT

			@ 192,110 BUTTON btn_18 ;
				CAPTION 'Internet Security' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,1" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Security' ; 
				FLAT

			@ 216,0 BUTTON btn_19 ;
				CAPTION 'Internet Privacy' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,2" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Privacy' ; 
				FLAT

			@ 216,110 BUTTON btn_20 ;
				CAPTION 'Internet Content' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Content' ; 
				FLAT

			@ 240,0 BUTTON btn_21 ;
				CAPTION 'Internet Connections' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,4" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Connections' ; 
				FLAT

			@ 240,110 BUTTON btn_22 ;
				CAPTION 'Internet Programs' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,5" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Programs' ; 
				FLAT

			@ 264,0 BUTTON btn_23 ;
				CAPTION 'Internet Advanced' ;
				ACTION Control( "shell32.dll,Control_RunDLL inetcpl.cpl,,6" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Internet Advanced' ; 
				FLAT

			@ 264,110 BUTTON btn_24 ;
				CAPTION 'Regional Config' ;
				ACTION Control( "shell32.dll,Control_RunDLL intl.cpl,,0" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Regional Configuration' ; 
				FLAT

			@ 288,0 BUTTON btn_25 ;
				CAPTION IF(_HMG_IsXP, 'System Language', 'Regional Numbers') ;
				ACTION Control( "shell32.dll,Control_RunDLL intl.cpl,,1" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP IF(_HMG_IsXP, 'System Language', 'Regional Numbers Format') ; 
				FLAT

			@ 288,110 BUTTON btn_26 ;
				CAPTION 'Regional Currency' ;
				ACTION Control( "shell32.dll,Control_RunDLL intl.cpl,,2" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Regional Currency Format' ; 
				FLAT

			@ 312,0 BUTTON btn_27 ;
				CAPTION 'Regional Times' ;
				ACTION Control( "shell32.dll,Control_RunDLL intl.cpl,,3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Regional Times Format' ; 
				FLAT

			@ 312,110 BUTTON btn_28 ;
				CAPTION 'Regional Dates' ;
				ACTION Control( "shell32.dll,Control_RunDLL intl.cpl,,4" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Regional Dates Format' ; 
				FLAT

			@ 336,0 BUTTON btn_29 ;
				CAPTION 'Mouse' ;
				ACTION Control( "shell32.dll,Control_RunDLL main.cpl @0" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Mouse Config' ; 
				FLAT

			@ 336,110 BUTTON btn_30 ;
				CAPTION 'Keyboard' ;
				ACTION Control( "shell32.dll,Control_RunDLL main.cpl @1" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Keyboard Config' ; 
				FLAT

			@ 360,0 BUTTON btn_31 ;
				CAPTION 'Printers' ;
				ACTION Control( "shell32.dll,Control_RunDLL main.cpl @2" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Printers Folder' ; 
				FLAT

			@ 360,110 BUTTON btn_32 ;
				CAPTION 'Fonts' ;
				ACTION Control( "shell32.dll,Control_RunDLL main.cpl @3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Fonts Folder' ; 
				FLAT

			@ 384,0 BUTTON btn_33 ;
				CAPTION 'System General' ;
				ACTION Control( "shell32.dll,Control_RunDLL sysdm.cpl,,0" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'System General' ; 
				FLAT

			@ 384,110 BUTTON btn_34 ;
				CAPTION 'Device Manager' ;
				ACTION IF( _HMG_IsXP, ;
					ShellExecute( hMainForm, nil, GetSystemFolder()+'\mmc.exe', ;
					GetSystemFolder()+'\devmgmt.msc /s ', nil, SW_SHOW ), ;
					Control( "shell32.dll,Control_RunDLL sysdm.cpl,,1" ) ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Device Manager' ; 
				FLAT

			@ 406,0 BUTTON btn_35 ;
				CAPTION 'Hardware Profiles' ;
				ACTION Control( "shell32.dll,Control_RunDLL sysdm.cpl,,2" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Hardware Profiles' ; 
				FLAT

			@ 406,110 BUTTON btn_36 ;
				CAPTION 'System Performance' ;
				ACTION Control( "shell32.dll,Control_RunDLL sysdm.cpl,,3" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'System Performance' ; 
				FLAT

			@ 430,0 BUTTON btn_37 ;
				CAPTION 'Hardware Assistant' ;
				ACTION Control( "shell32.dll,Control_RunDLL sysdm.cpl @1" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Hardware Assistant' ; 
				FLAT

			@ 430,110 BUTTON btn_38 ;
				CAPTION 'Printers Assistant' ;
				ACTION Control( "shell32.dll,SHHelpShortcuts_RunDLL AddPrinter" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Printers Assistant' ; 
				FLAT

			@ 454,0 BUTTON btn_39 ;
				CAPTION 'Date/Time Settings' ;
				ACTION Control( "shell32.dll,Control_RunDLL timedate.cpl" ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Time/Date Settings' ; 
				FLAT

			@ 454,110 BUTTON btn_40 ;
				CAPTION 'Sleep/Show Monitor' ;
				ACTION ( SendMessage(hMainForm, WM_SYSCOMMAND, SC_MONITORPOWER, 2 ), SysWait(10), ;
					SendMessage(hMainForm, WM_SYSCOMMAND, SC_MONITORPOWER, -1 ) ) ;
				WIDTH 110 HEIGHT 24 ;
				TOOLTIP 'Sleep/Enable Monitor for 10 seconds' ; 
				FLAT

		END WINDOW

		CENTER WINDOW Form_2

Return

*--------------------------------------------------------*
Static Function Control( cString )
*--------------------------------------------------------*

Return ShellExecute( hMainForm, nil,'rundll32.exe', cString, nil, SW_SHOW )

*--------------------------------------------------------*
Static Procedure HideOrShowForm()
*--------------------------------------------------------*
Local FormHandle := GetFormHandle( 'Form_2' )

	IF IsWindowVisible( FormHandle )
		Form_2.Hide
	ELSE
		Form_2.Show
		SetForegroundWindow( FormHandle )
	ENDIF

Return

*--------------------------------------------------------*
Procedure SysWait( nWait )
*--------------------------------------------------------*
Local iTime := Seconds()

DEFAULT nWait TO 2

Do While Seconds() - iTime < nWait
	INKEY(1)
	DoEvents()
EndDo

Return

*--------------------------------------------------------*
#include "hbdll32.ch"
DECLARE ANSI FindWindow (  lpClassName,  lpWindowName ) IN USER32.DLL

DECLARE ANSI FindWindowEx (  hWnd1,  hWnd2,  lpsz1,  lpsz2 ) IN USER32.DLL

DECLARE ANSI ShowWindow (  hwnd,  nCmdShow ) IN USER32.DLL ALIAS ShowSysWindow

DECLARE ANSI ExitWindowsEx (  uFlags,  dwReserved ) IN USER32.DLL ALIAS SysShutDown
*--------------------------------------------------------*


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( ENABLESYSWINDOW )
{
   HWND hWnd = ( HWND ) hb_parnl( 1 );

   if( IsWindow( hWnd ) )
      hb_retl( EnableWindow( hWnd, hb_parl( 2 ) ) );
   else
      hb_retl( FALSE );
}

#pragma ENDDUMP
