/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Uptime'
#define VERSION ' version 1.2'
#define COPYRIGHT ' Grigory Filatov, 2003-2008'

#define NTRIM( n ) LTrim( Str( n ) )

#define HALF_SIZE		44
#define FULL_SIZE		71

Static lSec := .F.

*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
	Local lWinRun := .F.

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "Uptime" ))
		lWinRun := .T.
	EndIf

	SET CENTURY ON

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0 			;
		TITLE PROGRAM 				;
		ICON 'MAIN'				;
		MAIN NOSHOW 				;
		NOTIFYICON 'MAIN'			;
		NOTIFYTOOLTIP PROGRAM 			;
		ON NOTIFYCLICK ShowForm()

		DEFINE NOTIFY MENU 
			ITEM 'Auto&Run'		ACTION ( lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
				NAME Auto_Run
			SEPARATOR
			ITEM 'A&bout...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				iif(IsWinNT(), "", "Copyright ") + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
			SEPARATOR
			ITEM 'E&xit'		ACTION Form_1.Release
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION UpdateTime()

	END WINDOW

	DEFINE WINDOW Form_2				;
		AT 0, 0					;
		WIDTH 81				;
		HEIGHT FULL_SIZE			;
		TITLE PROGRAM				;
		CHILD					;
		TOPMOST					;
		PALETTE					;
		NOMAXIMIZE				;
		NOSYSMENU				;
		NOSIZE					;
		ON GOTFOCUS Form_2.Height := FULL_SIZE	;
		ON LOSTFOCUS Form_2.Height := HALF_SIZE	;
		ON PAINT DrawWindowBoxIn( "Form_2", 2, 2, 17, Form_2.Width - 9 )

		@ 22,2 CHECKBUTTON Button_1 ;
			PICTURE "TOP" ;
			VALUE .T. ;
			ON CHANGE ChangeTopStatus() ;
			WIDTH 22 HEIGHT 22 NOTABSTOP

		@ 22,26 CHECKBUTTON Button_2 ;
			PICTURE "SEC" ;
			VALUE .F. ;
			ON CHANGE ( lSec := Form_2.Button_2.Value, ;
				Form_1.Timer_1.Release, UpdateTime(), ;
				_DefineTimer( "Timer_1", "Form_1", IF(lSec, 10, 1000), ;
				{|| UpdateTime()} ) ) ;
			WIDTH 22 HEIGHT 22 NOTABSTOP

		@ 22,50 BUTTON Button_3 ;
			PICTURE "CORNER" ;
			ACTION ( Form_2.Row := 0, Form_2.Col := GetDesktopWidth() - 82, ;
				Form_2.TopMost := .T., IF( Form_2.Button_1.Value, NIL, ;
				( Form_2.Button_1.Value := .T., SetChkBtnPicture(.T.) ) ) ) ;
			WIDTH 22 HEIGHT 22 NOTABSTOP

		@ 3, 3 LABEL Text_1 VALUE GetTime() ;
			HEIGHT 14 WIDTH Form_2.Width - 12 ;
			FONT 'MS Sans Serif' ;
			SIZE 9 CENTERALIGN

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2, Form_1

Return

*--------------------------------------------------------*
Static Procedure ShowForm()
*--------------------------------------------------------*

	IF IsWindowVisible( GetFormHandle( "Form_2" ) )
		Form_2.Hide
	ELSE
		Form_2.Restore ; Form_2.Show ; Form_1.SetFocus
	ENDIF

Return

*--------------------------------------------------------*
Static Procedure UpdateTime()
*--------------------------------------------------------*
	Local cUptime := GetTime()

	Form_1.NotifyTooltip := cUptime + " since last reboot"

	IF IsWindowVisible( GetFormHandle( "Form_2" ) )
		Form_2.Text_1.Value := cUptime
	ENDIF

Return

*--------------------------------------------------------*
Function GetTime()
*--------------------------------------------------------*
   local t := Int( GetTickCount() / IF(lSec, 10, 1000) )
   local nDAYS, nHRS, nMINS, nSECS, nMSECS

   nDAYS := Int( t / ( 3600 * IF(lSec, 100, 1) * 24 ) )
   nHRS  := int( ( t - nDAYS * 3600 * IF(lSec, 100, 1) * 24 ) / ( 3600 * IF(lSec, 100, 1) ) )
   nMINS := int( ( t - nDAYS * 3600 * IF(lSec, 100, 1) * 24 - nHRS * 3600 * IF(lSec, 100, 1)) / ( 60 * IF(lSec, 100, 1)) )
   nSECS := IF(lSec, int( ( t - nDAYS * 360000 * 24 - nHRS * 360000 - nMINS * 6000 ) / 100 ), ;
		t - nDAYS * 3600 * 24 - nHRS * 3600 - nMINS * 60 )
   nMSECS := IF(lSec, t - nDAYS * 360000 * 24 - nHRS * 360000 - nMINS * 6000 - nSECS * 100, 0 )

Return IF(Empty(nDAYS), "", strzero( nDAYS, 2 ) + "d ") + strzero( nHRS, 2 ) + ":" + ;
	strzero( nMINS, 2 ) + ":" + strzero( nSECS, 2 ) + IF(lSec, "." + strzero( nMSECS, 2 ), "")

*-----------------------------------------------------------------------------*
Procedure ChangeTopStatus()
*-----------------------------------------------------------------------------*
   local lTop := Form_2.Button_1.Value

   Form_2.TopMost := lTop

   SetChkBtnPicture(lTop)

Return

*-----------------------------------------------------------------------------*
Static Procedure SetChkBtnPicture( lTop )
*-----------------------------------------------------------------------------*

	Form_2.Button_1.Release

	IF lTop

		@ 22,2 CHECKBUTTON Button_1 ;
			OF Form_2 ;
			PICTURE "TOP" ;
			VALUE .T. ;
			ON CHANGE ChangeTopStatus() ;
			WIDTH 22 HEIGHT 22 NOTABSTOP

	ELSE

		@ 22,2 CHECKBUTTON Button_1 ;
			OF Form_2 ;
			PICTURE "NORM" ; 
			VALUE .F. ;
			ON CHANGE ChangeTopStatus() ;
			WIDTH 22 HEIGHT 22 NOTABSTOP

	ENDIF

Return

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "Uptime" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "Uptime", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "Uptime" )
   ENDIF

Return

*--------------------------------------------------------*
Static Function GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
Static Function SETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
Static Function DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

RETURN nValue


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( GETTICKCOUNT )
{
   hb_retnl( (LONG) GetTickCount() ) ;
}

#pragma ENDDUMP
