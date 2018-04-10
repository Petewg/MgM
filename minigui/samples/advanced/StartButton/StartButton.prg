/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

#define PROGRAM 'Start Button Image Control'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2007-2011 Grigory Filatov'

#define REGKEY 'Software\Microsoft\Windows\CurrentVersion\Run'
#define REGNAME 'Start Button'

#define MESSAGE1 'Press Ctrl+F6 to swap images of Start Button' + CRLF + 'Click Tray Icon to close program'
#define MESSAGE2 'Press Ctrl+F6 to swap images, Click Me to close program'

Static nOldMode := 0, nNewMode := 0, lSound := .t., cBitmap1 := "", cBitmap2 := ""

Memvar cPath

Procedure Main( lStartUp )
LOCAL lWinRun := .F.
PRIVATE cPath := GetStartUpFolder() + "\"

	SET MULTIPLE OFF

	SET GLOBAL HOTKEYS ON

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, REGKEY, REGNAME ))
		lWinRun := .T.
	EndIf

	cBitmap1 := cPath + IF( IsWinXPorLater(), "img_xp\1.bmp", "img_98\1.bmp" )
	cBitmap2 := cPath + IF( IsWinXPorLater(), "img_xp\2.bmp", "img_98\2.bmp" )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 ;
		HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		ON INIT ( UpdateImage(), ;
			IF( IsWinXPorLater(), ( MsgBalloon( MESSAGE1 ), Inkey(6) ), ), ;
			ActivateNotifyMenu( lWinRun ) ) ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP MESSAGE2 ;
		ON NOTIFYCLICK ThisWindow.Release

		ON KEY CONTROL+F6 ACTION SwapImages()

		DEFINE TIMER Timer_1 ;
			INTERVAL 50 ;
			ACTION UpdateImage()

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure UpdateImage()
*--------------------------------------------------------*
Local nNewMode := GetKeyboardMode()

	IF nNewMode != nOldMode

		nOldMode := nNewMode

		IF nNewMode == 1033  // English

			SetStartButtonImage( cBitmap1 )

		ELSE

			SetStartButtonImage( cBitmap2 )

		ENDIF

		IF lSound
			Tone( 1000, 1 )
		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Static Procedure SwapImages()
*--------------------------------------------------------*

	IF lSound
		Tone( 5000, 1 )
	ENDIF

	IF Val( cFileNoExt( cBitmap1 ) ) == 2

		cBitmap1 := cPath + IF( IsWinXPorLater(), "img_xp\1.bmp", "img_98\1.bmp" )
		cBitmap2 := cPath + IF( IsWinXPorLater(), "img_xp\2.bmp", "img_98\2.bmp" )

	ELSE

		cBitmap1 := cPath + IF( IsWinXPorLater(), "img_xp\2.bmp", "img_98\2.bmp" )
		cBitmap2 := cPath + IF( IsWinXPorLater(), "img_xp\1.bmp", "img_98\1.bmp" )

	ENDIF

Return

*--------------------------------------------------------*
Static Procedure MsgBalloon( cMessage, cTitle )
*--------------------------------------------------------*
	Local i := Ascan( _HMG_aFormhandles, GetFormHandle("Form_1") )

	Default cMessage := "Prompt", cTitle := PROGRAM

	ShowNotifyIcon( _HMG_aFormhandles[i], .F. , NIL, NIL )

	ShowNotifyInfo( _HMG_aFormhandles[i], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i], cMessage, cTitle )

Return

*--------------------------------------------------------*
Static Procedure ActivateNotifyMenu( lWinRun )
*--------------------------------------------------------*
	Local i := Ascan( _HMG_aFormhandles, GetFormHandle("Form_1") )

	ShowNotifyInfo( _HMG_aFormhandles[i], .F. , NIL, NIL, NIL, NIL )

	ShowNotifyIcon( _HMG_aFormhandles[i], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i] )

	DEFINE NOTIFY MENU OF Form_1
		ITEM 'Auto&Run'		ACTION ( lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
				NAME Auto_Run
		SEPARATOR	
		ITEM 'Disable &Sound'	ACTION ( lSound := !lSound, ;
				Form_1.Sound.Checked := !lSound ) ;
				NAME Sound
		ITEM 'A&bout...'	ACTION ShellAbout( "About#", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
		SEPARATOR	
		ITEM 'E&xit'		ACTION Form_1.Release
	END MENU

	Form_1.Auto_Run.Checked := lWinRun
	Form_1.Sound.Checked := !lSound

Return

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := REGKEY, ;
         cRegKey  := GETREGVAR( NIL, cRunKey, REGNAME )

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, REGNAME, cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, REGNAME )
   ENDIF

Return

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

RETURN nValue


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400
#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED

#include <shlobj.h>
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"

static HWND GetStartButton(void);

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle);

HB_FUNC ( SHOWNOTIFYINFO )
{
	ShowNotifyInfo( (HWND) hb_parnl(1), (BOOL) hb_parl(2), (HICON) hb_parnl(3), (LPSTR) hb_parc(4), 
			(LPSTR) hb_parc(5), (LPSTR) hb_parc(6) );
}

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle)
{
	NOTIFYICONDATA nid;

	ZeroMemory( &nid, sizeof(nid) );

	nid.cbSize		= sizeof(NOTIFYICONDATA);
	nid.hIcon		= hIcon;
	nid.hWnd		= hWnd;
	nid.uID			= 0;
	nid.uFlags		= NIF_INFO | NIF_TIP | NIF_ICON;
	nid.dwInfoFlags		= NIIF_INFO;

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

HB_FUNC ( SETSTARTBUTTONIMAGE )
{
	HWND hButton = GetStartButton();
	HDC  hDCButton = GetDC(hButton);
	HDC  hDcCompatibleButton;
	RECT rc;
	int  nWidth, nHeight;

	HBITMAP hBitmap, hBitmapOld;
	BITMAP bitmap;

	GetWindowRect(hButton, &rc);
	nWidth = rc.right - rc.left;
	nHeight = rc.bottom - rc.top;

	hDcCompatibleButton = CreateCompatibleDC(hDCButton);

	hBitmap = (HBITMAP)LoadImage (NULL, hb_parc(1), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);

	hBitmapOld = (HBITMAP)SelectObject(hDcCompatibleButton, hBitmap);
	GetObject(hBitmap, sizeof(BITMAP), &bitmap);

	if (nWidth > bitmap.bmWidth - 3 && nWidth < bitmap.bmWidth + 3 && nHeight > bitmap.bmHeight - 3 && nHeight < bitmap.bmHeight + 3)
		BitBlt(hDCButton, 0, 0, nWidth, nHeight, hDcCompatibleButton, 0, 0, SRCCOPY);
	else
		StretchBlt(hDCButton, 0, 0, nWidth, nHeight, hDcCompatibleButton, 0, 0, bitmap.bmWidth, bitmap.bmHeight, SRCCOPY);

	SelectObject(hDcCompatibleButton, hBitmapOld);

	DeleteDC(hDcCompatibleButton);
	DeleteDC(hDCButton);
	DeleteObject(hBitmap);
} 

static HWND GetStartButton()
{
	static HWND hKnownButton=0;
	HWND hTaskBar, hButton;

	hTaskBar = FindWindow( "Shell_TrayWnd", NULL );
	hButton = GetWindow( hTaskBar, GW_CHILD );

	if (hButton)
		hKnownButton = hButton;
	else
		hButton = hKnownButton;

	return hButton;
}

HB_FUNC( GETKEYBOARDMODE )
{
	HKL kbl;
	HWND CurApp;
	DWORD idthd;
	int newmode;

	CurApp=GetForegroundWindow();
	idthd=GetWindowThreadProcessId(CurApp,NULL);
	kbl=GetKeyboardLayout(idthd);
	newmode=(int)LOWORD(kbl);
	hb_retnl(newmode);
}

#pragma ENDDUMP
