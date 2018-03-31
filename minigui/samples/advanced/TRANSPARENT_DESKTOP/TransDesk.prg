/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Transparent Desktop'
#define VERSION ' version 1.0'
#define COPYRIGHT ' Grigory Filatov, 2003'

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON 'ICON_1' ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK IF(GetTransDeskState(), SetSolidIcons(), SetTransparentIcons())

		DEFINE NOTIFY MENU 
			ITEM "&Colored Icon Text Background" ;
				ACTION SetSolidIcons()
			ITEM "&Transparent Icon Text Background" ;
				ACTION SetTransparentIcons()
			SEPARATOR	
			ITEM '&Mail to author...' ;
				ACTION ShellExecute(0, "open", "rundll32.exe", ;
					"url.dll,FileProtocolHandler " + ;
					"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=TransDesk%20Feedback:", , 1)
			ITEM '&About...' ;
				ACTION ShellAbout( "", PROGRAM + CRLF + ;
					Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "ICON_1", 32, 32) )
			SEPARATOR	
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_1

Return


#pragma BEGINDUMP

#include "windows.h"
#include "commctrl.h"
#include "hbapi.h"
#include "hbapiitm.h"

static HWND GetDeskTopListView(void);

HB_FUNC ( GETTRANSDESKSTATE )
{
	HWND hListView = GetDeskTopListView();

	if ( ListView_GetTextBkColor(hListView) != CLR_NONE )
		hb_retl( FALSE );
	else
		hb_retl( TRUE );
} 

HB_FUNC ( SETTRANSPARENTICONS )
{
	HWND hListView = GetDeskTopListView();

	SendMessage( hListView, LVM_SETTEXTBKCOLOR, 0, CLR_NONE );
	InvalidateRect( hListView, 0, TRUE );
	UpdateWindow( hListView );
} 

HB_FUNC ( SETSOLIDICONS )
{
	HWND hListView = GetDeskTopListView();

	SendMessage( hListView, LVM_SETTEXTBKCOLOR, 0, GetSysColor( COLOR_DESKTOP ) );
	InvalidateRect( hListView, 0, TRUE );
	UpdateWindow( hListView );
} 

static HWND GetDeskTopListView()
{
	static HWND hKnownListView=0;
	HWND hDesktop, hListView;

	hDesktop = FindWindowEx( FindWindow("Progman", 0), 0, "SHELLDLL_DefView", 0 );
	hListView = FindWindowEx( hDesktop, 0, "SysListView32", 0 );

	if (hListView)
		hKnownListView = hListView;
	else
		hListView = hKnownListView;

	return hListView;
}

#pragma ENDDUMP
