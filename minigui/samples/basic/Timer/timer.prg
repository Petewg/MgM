/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "resource.h"

#define PROGRAM 'Timer'
#define VERSION ' version 1.1'
#define COPYRIGHT ' Grigory Filatov, 2005-2008'

#define IDOK                1
#define IDCANCEL            2

Static lBlock := .F., IsTimerLeave := .F.
Static SoundFileName := ""
Static Description := ""

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF WARNING

	SoundFileName += GetWindowsFolder() + "\Media\Ding.wav"
	Description += "Warning !"

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN /*NOSHOW*/ ;
		NOTIFYICON IDI_ICON ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK Settings()
		
		DEFINE NOTIFY MENU
			ITEM '&About...'	ACTION ShellAbout( "", ;
					PROGRAM + VERSION + CRLF + ;
					IF(IsXPThemeActive(), "", "Copyright ") + Chr(169) + COPYRIGHT, ;
					LoadMainIcon(GetInstance(), IDI_ICON) )
			SEPARATOR
			ITEM 'E&xit'		ACTION Form_1.Release
		END MENU

	END WINDOW

	ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
Procedure Settings()
*--------------------------------------------------------*
	IF lBlock == .T.
		RETURN
	ENDIF

	DEFINE DIALOG Form_2 OF Form_1 ;
		RESOURCE IDD_DIALOG1 ;
		ON INIT { |hDlg| lBlock := .T., SetForegroundWindow(hDlg) } ;
		ON RELEASE lBlock := .F.

		REDEFINE BUTTON Btn_1 ID IDOK ;
			ACTION OnOK()

		REDEFINE BUTTON Btn_2 ID IDCANCEL ;
			ACTION _ReleaseWindow ( 'Form_2' )

		REDEFINE BUTTON Btn_3 ID IDC_QUIT ;
			ACTION _ReleaseWindow ( 'Form_1' )

		REDEFINE TEXTBOX TextBox_1 ID IDC_TIME ;
			VALUE 5 NUMERIC

		REDEFINE TEXTBOX TextBox_2 ID IDC_DESCRIPTION ;
			VALUE Description

		REDEFINE TEXTBOX TextBox_3 ID IDC_FILE ;
			VALUE SoundFileName

		REDEFINE BUTTON Btn_4 ID IDC_BROWSE ;
			ACTION OnBrowseForFile()

		REDEFINE BUTTON Btn_5 ID IDC_TEST ;
			ACTION OnTest()

        END DIALOG 

RETURN

*--------------------------------------------------------*
PROCEDURE OnOK()
*--------------------------------------------------------*
local time := Form_2.TextBox_1.Value

	if IsTimerLeave
		Form_1.Timer_1.Value := time * 60000
	else
		DEFINE TIMER Timer_1 OF Form_1 INTERVAL time * 60000 ACTION TimerAction()
		IsTimerLeave = .T.
	endif

	Description := Form_2.TextBox_2.Value

	_ReleaseWindow ( 'Form_2' )

RETURN

*--------------------------------------------------------*
PROCEDURE OnBrowseForFile()
*--------------------------------------------------------*
local file := GetFile( { {"Audio files (*.wav)", "*.wav"}, {"All files (*.*)", "*.*"} }, ;
		"Select a sound", cFilePath(SoundFileName), , .T. )

	if file(file)
		SoundFileName := file
		Form_2.TextBox_3.Value := SoundFileName
	endif

RETURN

*--------------------------------------------------------*
PROCEDURE OnTest()
*--------------------------------------------------------*
	if Empty(SoundFileName)
		PlayAsterisk()
	else
		PLAY WAVE SoundFileName
	endif

RETURN

*--------------------------------------------------------*
PROCEDURE TimerAction()
*--------------------------------------------------------*
	if IsTimerLeave
		Form_1.Timer_1.Release
		IsTimerLeave = .F.
	endif

	if Empty(SoundFileName)
		PlayAsterisk()
	else
		PLAY WAVE SoundFileName
	endif

	MsgAlert( Description, "Timer" )

RETURN


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( LOADMAINICON )
{
	HICON himage;
	HINSTANCE hInstance  = (HINSTANCE) hb_parnl(1);  // handle to application instance
	WORD      wIconName  = (WORD)      hb_parni(2);  // resource identifier

	himage = (HICON) LoadImage (hInstance, MAKEINTRESOURCE (wIconName), IMAGE_ICON,
				0, 0, LR_DEFAULTCOLOR);

	hb_retnl( (LONG) himage );
}
/*
HB_FUNC( LOADTRAYICON )
{
	HICON himage;
	HINSTANCE hInstance  = (HINSTANCE) hb_parnl(1);  // handle to application instance
	WORD      wIconName  = (WORD)      hb_parni(2);  // resource identifier

	himage = (HICON) LoadImage (hInstance, MAKEINTRESOURCE (wIconName), IMAGE_ICON,
				16, 16, LR_DEFAULTCOLOR);

	hb_retnl( (LONG) himage );
}

HB_FUNC( INITIMAGE )
{
	HWND  h;
	HBITMAP hBitmap;
	HWND hwnd;
	int Style;

	hwnd = (HWND) hb_parnl(1);

	Style = WS_CHILD | SS_BITMAP | SS_NOTIFY ;

	if ( ! hb_parl (8) )
	{
		Style = Style | WS_VISIBLE ;
	}

	h = CreateWindowEx( 0, "static", NULL, Style,
		hb_parni(3), hb_parni(4), 0, 0,
		hwnd, (HMENU) hb_parni(2), GetModuleHandle(NULL), NULL ) ;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_CREATEDIBSECTION);
	}

	SendMessage( h, (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

	hb_retnl( (LONG) h );
}

HB_FUNC( C_SETPICTURE )
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP) LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
	if (hBitmap==NULL)
	{
		hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
	}

	SendMessage( (HWND) hb_parnl (1), (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

	hb_retnl( (LONG) hBitmap );
}
*/
#pragma ENDDUMP
