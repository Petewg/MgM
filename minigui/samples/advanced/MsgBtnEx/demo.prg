/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'MsgBtnEx Demo'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

#define MB_OK                   0
#define MB_ICONSTOP             16
#define MB_ICONQUESTION         32
#define MB_ICONEXCLAMATION      48
#define MB_ICONINFORMATION      64
*--------------------------------------------------------*
Function Main
*--------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE PROGRAM ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&MsgBtnEx'
				ITEM 'Message Information'	ACTION	MsgBtnEx(MiniguiVersion(), ;
					StrTran(Form_1.Title, "Demo", "Information"), MB_ICONINFORMATION + MB_OK)
				ITEM 'Message Question'		ACTION	MsgBtnEx(MiniguiVersion(), ;
					StrTran(Form_1.Title, "Demo", "Question"), MB_ICONQUESTION + MB_OK)
				ITEM 'Message Stop'		ACTION	MsgBtnEx(MiniguiVersion(), ;
					StrTran(Form_1.Title, "Demo", "Stop"), MB_ICONSTOP + MB_OK)
				ITEM 'Message Error'		ACTION	MsgBtnEx(MiniguiVersion(), ;
					StrTran(Form_1.Title, "Demo", "Error"), MB_ICONEXCLAMATION + MB_OK)
			    	SEPARATOR	
				ITEM '&Exit'	ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&About'	ACTION MsgBtnEx( PROGRAM + VERSION, ;
					'About', MB_ICONINFORMATION + MB_OK )
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HHOOK hMsgBoxHook;

LRESULT CALLBACK CBTProc(int nCode, WPARAM wParam, LPARAM lParam)
{
	HWND hwnd;
	HWND hwndButton;

	if(nCode < 0)
		return CallNextHookEx(hMsgBoxHook, nCode, wParam, lParam);

	switch(nCode)
	{
	case HCBT_ACTIVATE:

		// Get handle to the message box!
		hwnd = (HWND)wParam;

		hwndButton = GetDlgItem(hwnd, IDOK);
		SetWindowText(hwndButton, "Thank you");
		
		return 0;

	}

	return CallNextHookEx(hMsgBoxHook, nCode, wParam, lParam);
}

int MsgBoxHook(HWND hwnd, const char *szText, const char *szCaption, UINT uType)
{
	int retval;

	// Install a window hook, so we can intercept the message-box
	// creation, and customize it
	hMsgBoxHook = SetWindowsHookEx(
		WH_CBT, 
		CBTProc, 
		NULL, 
		GetCurrentThreadId()			// Only install for THIS thread!!!
		);

	// Display a standard message box
	retval = MessageBox(hwnd, szText, szCaption, uType);

	// remove the window hook
	UnhookWindowsHookEx(hMsgBoxHook);

	return retval;
}

HB_FUNC ( MSGBTNEX )
{
	MsgBoxHook(NULL, hb_parc(1), hb_parc(2), hb_parnl(3));
}

#pragma ENDDUMP
