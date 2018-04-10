/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#Include "Fileio.ch"

#define PROGRAM 'Screen Saver'
#define VERSION ' version 2.2'
#define COPYRIGHT ' Grigory Filatov, 2002-2006'
#define NTRIM( n ) LTrim( Str( n ) )

#define WM_SYSCOMMAND 274     // &H112
#define SC_SCREENSAVE 61760   // &HF140

Static aScrSavers, cFileIni, cActScr := "", nActCheck := 0, lSSActive

*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
	Local lWinRun := .F., nItem, cItem, cActItem, cActCheck

	SET MULTIPLE OFF

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "SScontrol" ))
		lWinRun := .T.
	EndIf

	Set InteractiveClose Off

	DEFAULT cFileIni TO GetWindowsFolder() + "\" + "SYSTEM.INI"

	aScrSavers := GetArrayScrSavers()

	IF Len(aScrSavers) > 0
		IF IsWinNT()
			cActScr := Upper(_GetShortPathName( GETREGVAR( NIL, "Control Panel\Desktop", "SCRNSAVE.EXE" ) ))
		ELSE
			cActScr := GetIni( "boot", "SCRNSAVE.EXE" )
		ENDIF
		nActCheck := aScan( aScrSavers, { |x| Upper(_GetShortPathName( x )) = cActScr } )
		nActCheck := Max( 1, nActCheck )
	ENDIF

	lSSActive := IF( Empty(cActScr), .F., .T. )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON IF( lSSActive, 'ON', 'OFF' ) ;
		NOTIFYTOOLTIP PROGRAM + ' is ' + IF( lSSActive, 'ON', 'OFF' ) ;
		ON NOTIFYCLICK ( lSSActive := !lSSActive, SSTurn(lSSActive) )

		DEFINE NOTIFY MENU
			DEFINE POPUP "ScreenSavers List"
				For nItem := 1 To Len(aScrSavers)
					cActItem := "StartSaver(" + NTRIM(nItem) + ")"
					cItem := NTRIM(nItem)
					ITEM cFileNoExt( aScrSavers[nItem] ) ACTION &cActItem ;
						NAME &cItem
				Next
			END POPUP
			SEPARATOR	
			ITEM 'Turn O&n ScreenSaver'	 ACTION SSTurn( .T. )
			ITEM 'Turn O&ff ScreenSaver'	 ACTION SSTurn( .F. )
			ITEM 'Run &ScreenSaver'	 ACTION IF( lSSActive, ;
					SendMessage( GetFormHandle("Form_1"), ;
					WM_SYSCOMMAND, SC_SCREENSAVE ), )
			SEPARATOR	
			ITEM 'Auto&Run'		ACTION {|| lWinRun := !lWinRun, ;
					Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) } ;
					NAME Auto_Run
			ITEM '&About...'	ACTION ShellAbout( "", PROGRAM + " Controller" + ;
					VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, ;
					LoadTrayIcon(GetInstance(), "MAINICON", 32, 32) )
			SEPARATOR	
			ITEM 'E&xit'		ACTION Form_1.Release
		END MENU

		IF Len(aScrSavers) > 0
			cActCheck := NTRIM(nActCheck)
			SetProperty("Form_1", cActCheck, "Checked", .T.)
		ENDIF

		Form_1.Auto_Run.Checked := lWinRun

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure SSTurn( lMode )
*--------------------------------------------------------*
	lSSActive := lMode

	IF lMode
		IF !Empty(cActScr)
			IF IsWinNT()
				SETREGVAR( NIL, "Control Panel\Desktop", "SCRNSAVE.EXE", cActScr )
			ELSE
				WriteIni( "boot", "SCRNSAVE.EXE", ;
				IF( Len( cFileNoExt(cActScr) ) > 8, Upper(_GetShortPathName( cActScr )), cActScr ) )
			ENDIF
		ENDIF
	ELSE
		IF IsWinNT()
			SETREGVAR( NIL, "Control Panel\Desktop", "SCRNSAVE.EXE", "" )
		ELSE
			cActScr := GetIni( "boot", "SCRNSAVE.EXE" )
			WriteIni( "boot", "SCRNSAVE.EXE", "" )
		ENDIF
	ENDIF

	IF !Empty(cActScr)
		Form_1.NotifyIcon := IF( lMode, 'ON', 'OFF' )
		Form_1.NotifyTooltip := PROGRAM + ' is ' + IF( lMode, 'ON', 'OFF' )
	ENDIF

Return

*--------------------------------------------------------*
Procedure StartSaver( nItem )
*--------------------------------------------------------*
	Local cActCheck

	IF lSSActive
		cActCheck := NTRIM(nActCheck)
		SetProperty("Form_1", cActCheck, "Checked", .F.)

		nActCheck := nItem
		cActCheck := NTRIM(nItem)
		SetProperty("Form_1", cActCheck, "Checked", .T.)

		IF IsWinNT()
			EXECUTE FILE "Rundll32.exe" ;
				PARAMETERS "desk.cpl,InstallScreenSaver " + aScrSavers[nActCheck]
		ELSE
			WriteIni( "boot", "SCRNSAVE.EXE", ;
			IF( Len( cFileNoExt(aScrSavers[nActCheck]) ) > 8, Upper(_GetShortPathName( aScrSavers[nActCheck] )), ;
				aScrSavers[nActCheck] ) )

			SendMessage( GetFormHandle("Form_1"), WM_SYSCOMMAND, SC_SCREENSAVE )
		ENDIF
	ENDIF

Return

*--------------------------------------------------------*
Function GetArrayScrSavers()
*--------------------------------------------------------*
	LOCAL aArr1 := Directory( GetWindowsFolder() + "\*.SCR" ), ;
		aArr2 := Directory( GetSystemFolder() + "\*.SCR" ), aArray := {}

	If Len(aArr1) > 0
            aEval( aArr1, { |uFile| AAdd( aArray, GetWindowsFolder()+"\"+uFile[1] ) } )
	EndIf

	If Len(aArr2) > 0
            aEval( aArr2, { |uFile| AAdd( aArray, GetSystemFolder()+"\"+uFile[1] ) } )
	EndIf

Return( aArray )

*--------------------------------------------------------*
Function GetIni( cSection, cEntry, cDefault )
*--------------------------------------------------------*
   Default cDefault To ""
RETURN GetPrivateProfileString( cSection, cEntry, cDefault, cFileIni )

*--------------------------------------------------------*
Function WriteIni( cSection, cEntry, cValue )
*--------------------------------------------------------*
RETURN WritePrivateProfileString( cSection, cEntry, cValue, cFileIni )

*--------------------------------------------------------*
Static Function WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "SScontrol" )

   IF IsWinNT()
      EnablePermissions()
   ENDIF

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "SScontrol", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "SScontrol" )
   ENDIF

return NIL

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

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
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

#pragma ENDDUMP
