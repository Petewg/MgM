/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Language Indicator'
#define VERSION ' version 1.02'
#define COPYRIGHT ' 2003-2006 Grigory Filatov'

Static nOldMode := 0, nNewMode := 0, lSound := .F.

Procedure Main( lStartUp )
	Local lWinRun := .F., lAbout := .F.

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "Indicator" ))
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 		;
		AT 0,0 			;
		WIDTH 0 HEIGHT 0 		;
		TITLE PROGRAM 		;
		MAIN NOSHOW 		;
		ON INIT UpdateNotify() 	;
		NOTIFYICON 'EN' 		;
		NOTIFYTOOLTIP PROGRAM 	;
		ON NOTIFYCLICK ( lAbout := !lAbout, IF(lAbout, MsgAbout(), lAbout := .F.) )

		DEFINE NOTIFY MENU 

			ITEM 'Auto&Run'		ACTION ( lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
				NAME Auto_Run

			SEPARATOR	

			ITEM 'Disable &Sound'	ACTION ( lSound := !lSound, ;
				Form_1.Sound.Checked := !lSound ) ;
				NAME Sound CHECKED

			ITEM 'A&bout...'		ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "AMAIN", 32, 32 ) )

			SEPARATOR	

			ITEM 'E&xit'		ACTION Form_1.Release

		END MENU

		Form_1.Auto_Run.Checked := lWinRun

		DEFINE TIMER Timer_1 ;
			INTERVAL 100 ;
			ACTION UpdateNotify()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure UpdateNotify()
*--------------------------------------------------------*
  Local cFlag, cTip, nNewMode := GetKeyboardMode()

	if nNewMode != nOldMode

		nOldMode := nNewMode

		DO CASE
			CASE nNewMode == 1049  // Russian
				cFlag := "RU"
				cTip := "Russian"
				if lSound ;	SoundBeep(4000) ;	endif

			CASE nNewMode == 1033  // English
				cFlag := "EN"
				cTip := "English (USA)"
				if lSound ;	SoundBeep(4500) ;	endif

			CASE nNewMode == 1058  // Ukrainian
				cFlag := "UA"
				cTip := "Ukrainian"
				if lSound ;	SoundBeep(5000) ;	endif

			CASE nNewMode == 1031  // German
				cFlag := "DE"
				cTip := "German (St)"
				if lSound ;	SoundBeep(5500) ;	endif

			CASE nNewMode == 1034  // Spanish
				cFlag := "ES"
				cTip := "Spanish (Tr)"
				if lSound ;	SoundBeep(6000) ;	endif

			CASE nNewMode == 1036  // French
				cFlag := "FR"
				cTip := "French (St)"
				if lSound ;	SoundBeep(6500) ;	endif

			CASE nNewMode == 1040  // Italian
				cFlag := "IT"
				cTip := "Italian (St)"
				if lSound ;	SoundBeep(6500) ;	endif

			CASE nNewMode == 1045  // Polish
				cFlag := "PL"
				cTip := "Polski "
				if lSound ;	SoundBeep(6500) ;	endif
				
			CASE nNewMode == 1026  // Bulgarian
				cFlag := "BG"
				cTip := "Bulgarian "
				if lSound ;	SoundBeep(6500) ;	endif	

			OTHERWISE
				cFlag := "AMAIN"
				cTip := "Not determined"
				if lSound ;	SoundBeep(1000) ;	endif
		ENDCASE

		Form_1.NotifyIcon := cFlag
		Form_1.NotifyTooltip := cTip

	endif

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

Return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 44), "About..." )

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "Indicator" )

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "Indicator", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "Indicator" )
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

#include <mgdefs.h>

HB_FUNC( SOUNDBEEP )
{
	Beep( hb_parni( 1 ), 50 );
}

HB_FUNC( GETKEYBOARDMODE )
{
	HKL   kbl;
	HWND  CurApp;
	DWORD idthd;
	int   newmode;

	CurApp  = GetForegroundWindow();
	idthd   = GetWindowThreadProcessId( CurApp, NULL );

	kbl     = GetKeyboardLayout( idthd );
	newmode = ( int ) LOWORD( kbl );

	hb_retnl( newmode );
}

#pragma ENDDUMP
