/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM "MsgBalloon Demo"
#define VERSION " version 1.1"
#define COPYRIGHT " Grigory Filatov, 2007-2013"

#define		IDI_MAIN	1001

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 			;
		AT 0,0 				;
		WIDTH 0 HEIGHT 0 		;
		TITLE PROGRAM 			;
		ICON IDI_MAIN			;
		MAIN NOSHOW 			;
		ON INIT Start()	  		;
		NOTIFYICON IDI_MAIN		;
		NOTIFYTOOLTIP PROGRAM

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure Start()
*--------------------------------------------------------*

	IF IsWinNT()

		MsgBalloon( "Initializing" )
		Inkey(3)

		MsgBalloon( "A long time operation..", "Processing", 2 )
		Inkey(3)

		MsgBalloon( "Quitting.." )
		Inkey(3)

		ActivateNotifyMenu()

	ELSE

		MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
		Form_1.Release

	ENDIF

Return

// Notify Icon Infotip flags
#define NIIF_NONE       0x00000000
// icon flags are mutualy exclusive
// and take only the lowest 2 bits
#define NIIF_INFO       0x00000001
#define NIIF_WARNING    0x00000002
#define NIIF_ERROR      0x00000003
*--------------------------------------------------------*
Static Procedure MsgBalloon( cMessage, cTitle, nIconIndex )
*--------------------------------------------------------*
	Local i := GetFormIndex( "Form_1" )

	Default cMessage := "Prompt", cTitle := PROGRAM, nIconIndex := NIIF_INFO

	ShowNotifyInfo( _HMG_aFormhandles[i], .F. , NIL, NIL, NIL, NIL, 0 )

	ShowNotifyInfo( _HMG_aFormhandles[i], .T. , ;
		LoadTrayIcon( GetInstance(), _HMG_aFormNotifyIconName[i] ), ;
		_HMG_aFormNotifyIconToolTip[i], cMessage, cTitle, nIconIndex )

Return

*--------------------------------------------------------*
Static Procedure ActivateNotifyMenu()
*--------------------------------------------------------*
	Local i := GetFormIndex( "Form_1" )

	ShowNotifyInfo( _HMG_aFormhandles[i], .F. , NIL, NIL, NIL, NIL, 0 )

	ShowNotifyIcon( _HMG_aFormhandles[i], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i] )

	DEFINE NOTIFY MENU OF Form_1
		ITEM 'A&bout...'	ACTION ShellAbout( "About " + PROGRAM + "#", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
			LoadTrayIcon(GetInstance(), IDI_MAIN, 32, 32) )
		SEPARATOR	
		ITEM 'E&xit'		ACTION Form_1.Release
	END MENU

Return

/*
 * C-level
*/
#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle, DWORD nIconIndex);

HB_FUNC ( SHOWNOTIFYINFO )
{
	ShowNotifyInfo( (HWND) hb_parnl(1), (BOOL) hb_parl(2), (HICON) hb_parnl(3), (LPSTR) hb_parc(4), 
			(LPSTR) hb_parc(5), (LPSTR) hb_parc(6), (DWORD) hb_parnl(7) );
}

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle, DWORD nIconIndex)
{
	NOTIFYICONDATA nid;

	ZeroMemory( &nid, sizeof(nid) );

	nid.cbSize		= sizeof(NOTIFYICONDATA);
	nid.hIcon		= hIcon;
	nid.hWnd		= hWnd;
	nid.uID			= 0;
	nid.uFlags		= NIF_INFO | NIF_TIP | NIF_ICON;
	nid.dwInfoFlags		= nIconIndex;

	lstrcpy( nid.szTip, TEXT(szText) );
	lstrcpy( nid.szInfo, TEXT(szInfo) );
	lstrcpy( nid.szInfoTitle, TEXT(szInfoTitle) );

	if(bAdd)
		Shell_NotifyIcon( NIM_ADD, &nid );
	else
		Shell_NotifyIcon( NIM_DELETE, &nid );

	if(hIcon)
		DestroyIcon( hIcon );
}

#pragma ENDDUMP
