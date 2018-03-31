/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "winprint.ch"

#define PROGRAM 'Tray Calendar'
#define VERSION ' version 1.1'
#define COPYRIGHT ' Grigory Filatov, 2003-2006'

#define IDI_MAIN 1001
#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )

Static nLang, cDate, nOldDay := 0, nNewDay, ;
	nCheck := 60000, lCheck := .t., nShuffle := 20000, lShuffle := .t.

*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
	Local lWinRun := .F.

	nLang := nHex( substr( I2Hex( GetUserLangID() ), 3 ) )

	IF nLang == 25
		SET LANGUAGE TO RUSSIAN
	ELSEIF nLang == 10
		SET LANGUAGE TO SPANISH
	ELSEIF nLang == 9
		SET LANGUAGE TO ENGLISH
	ENDIF

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "TrayCalendar" ))
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0			;
		TITLE PROGRAM 				;
		ICON IDI_MAIN				;
		MAIN NOSHOW 				;
		ON INIT ( UpdateNotify(),  		;
			IF( lWinRun, , Calendar() ) )	;
		ON RELEASE ( dbclosearea(),		;
			Ferase("Notes" + IndexExt()))	;
		NOTIFYICON 'AID_MAIN'			;
		NOTIFYTOOLTIP PROGRAM 			;
		ON NOTIFYCLICK Calendar()

		DEFINE NOTIFY MENU 
			ITEM 'Auto&Run'		ACTION ( lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun( lWinRun ) ) ;
				NAME Auto_Run
			SEPARATOR
			ITEM '&Reshuffle'		ACTION Shuffle() IMAGE "IDB_SHUFFLE"
			ITEM '&Check Date'		ACTION ( lCheck := !lCheck, ;
				Form_1.Auto_Check.Checked := lCheck, ;
				IF(lCheck, _DefineTimer( "Timer_1", "Form_1", nCheck, {|| UpdateNotify()} ), ;
				Form_1.Timer_1.Release) ) ;
				NAME Auto_Check CHECKED
			SEPARATOR
			ITEM '&Mail to author...'	ACTION ShellExecute(0, "open", "rundll32.exe", ;
				"url.dll,FileProtocolHandler " + ;
				"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
				"&subject=Tray%20Calendar%20Feedback:", , 1) IMAGE "IDB_MAIL"
			ITEM 'A&bout...'		ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), IDI_MAIN, 32, 32) ) ;
				IMAGE "IDB_INFO"
			SEPARATOR	
			ITEM 'E&xit'			ACTION Form_1.Release IMAGE "IDB_EXIT"
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

		DEFINE TIMER Timer_1 ;
			INTERVAL nCheck ;
			ACTION UpdateNotify()

		IF lShuffle

			DEFINE TIMER Timer_2 ;
				INTERVAL nShuffle ;
				ACTION ( Shuffle(), Form_1.Timer_2.Release )
		ENDIF

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure Shuffle()
*--------------------------------------------------------*
	Local nWnd := Ascan( _HMG_aFormhandles, GetFormHandle("Form_1") )

	ShowNotifyIcon( _HMG_aFormhandles[nWnd] , .F., NIL, NIL )

	ShowNotifyIcon( _HMG_aFormhandles[nWnd], .T. , LoadTrayIcon( GetInstance(), ;
		_HMG_aFormNotifyIconName[nWnd] ), _HMG_aFormNotifyIconToolTip[nWnd] )

Return

*--------------------------------------------------------*
Static Procedure UpdateNotify()
*--------------------------------------------------------*
	Local dDate   := Date()
	Local nNewDay := Day( dDate )

	IF nNewDay != nOldDay

		nOldDay := nNewDay
		cDate   := IF( nLang == 9, ;
			cMonth( dDate ) + " " + ltrim( str( nNewDay ) ) + "," + Str( Year( dDate ) ), ;
			ltrim( str( nNewDay ) ) + " " + cMonth( dDate ) + Str( Year( dDate ) ) )

		Form_1.NotifyIcon := "IDI_ICON" + ltrim( str( nNewDay ) )

		Form_1.NotifyTooltip := cDoW( dDate ) + ", " + cDate

	ENDIF

Return

DECLARE WINDOW Form_2
*--------------------------------------------------------*
Procedure Calendar()
*--------------------------------------------------------*

	IF IsWindowDefined( Form_2 )
		Form_2.Show
		SetForegroundWindow( GetFormHandle( "Form_2" ) )
		Return
	ENDIF

	DEFINE WINDOW Form_2				;
		AT 0, 0					;
		WIDTH 448 - IF(IsXPThemeActive(), 48, 0);
		HEIGHT 415 + IF(IsXPThemeActive(), 8, 0);
		TITLE PROGRAM				;
		ICON IDI_MAIN				;
		MODAL NOAUTORELEASE NOSIZE		;
		ON INIT ( OpenNotes(), Form_2.Edit_1.SetFocus )

		DEFINE MAIN MENU

			POPUP "&File"

				ITEM 'E&xit' ACTION ReleaseAllWindows() IMAGE "IDB_EXIT"
				SEPARATOR
				ITEM '&Save' + Chr(9) + 'Ctrl+S' ACTION SaveNote( Form_2.m_cal.Value, Form_2.Edit_1.Value )
				ITEM '&Delete Notes Before Today' ACTION DeleteOldNotes()
				ITEM '&Print Current Note' ACTION PrintNote( Form_2.Edit_1.Value )
				ITEM '&Minimize' ACTION Form_2.Hide IMAGE "IDB_DOWN"

			END POPUP

			POPUP "&Help"

				ITEM '&Contents' ACTION ShowHelp() IMAGE "IDB_HELP"
				ITEM 'A&bout' ACTION MsgAbout() IMAGE "IDB_INFO"

			END POPUP

		END MENU

		@ 0, 0 MONTHCALENDAR m_cal VALUE Date() ;
			FONT IF(IsWinNT(), 'Tahoma', 'Times New Roman') ;
			SIZE 12 BOLD ;
			NOTODAYCIRCLE WEEKNUMBERS ;
			ON CHANGE ( BASE->( dbseek(Form_2.m_cal.Value) ), Form_2.Edit_1.Value := BASE->NOTES )

		@ 216, 0 EDITBOX Edit_1 VALUE "" ;
			FONT 'MS Sans Serif' SIZE 8 ;
			MAXLENGTH 32768 ;
			NOHSCROLL ;
			ON CHANGE SaveNote( Form_2.m_cal.Value, Form_2.Edit_1.Value )

		@ Form_2.Height - 70, 2 BUTTON Btn_1 ; 
			CAPTION cDate ; 
			ACTION ( CopyToClipboard( cDate ), Form_2.Edit_1.SetFocus ) ;
			WIDTH 128 ;
			HEIGHT 23 ;
			TOOLTIP "Copy to clipboard"

		@ Form_2.Height - 70, 136 BUTTON Btn_2 ;
			CAPTION "Minimize" ;
			ACTION Form_2.Hide ;
			WIDTH 80 ;
			HEIGHT 23 ;
			TOOLTIP "Minimize to system tray"

		ON KEY ESCAPE ACTION Form_2.Hide
		ON KEY F1 ACTION ShowHelp()
		ON KEY CONTROL+S ACTION SaveNote( Form_2.m_cal.Value, Form_2.Edit_1.Value )

	END WINDOW

	Form_2.m_cal.Width := Form_2.Width - 6
	Form_2.m_cal.Height := Form_2.Height - IF(IsXPThemeActive(), 208, 200)

	Form_2.Edit_1.Width := Form_2.Width - 6
	Form_2.Edit_1.Height := Form_2.Height - IF(IsXPThemeActive(), 298, 290)

	Form_2.Btn_1.Row := Form_2.Height - IF(IsXPThemeActive(), 78, 70)
	Form_2.Btn_1.Col := Form_2.Width - 223

	Form_2.Btn_2.Row := Form_2.Height - IF(IsXPThemeActive(), 78, 70)
	Form_2.Btn_2.Col := Form_2.Width - 89

	Form_2.Center
	Form_2.Activate

RETURN

*--------------------------------------------------------*
Static Procedure OpenNotes()
*--------------------------------------------------------*
	Local cTxt := "Welcome!" + CRLF + CRLF + ;
		"To enter notes for a date, click on the date and type your notes." + CRLF + ;
		"To delete the notes for a date, simply erase them from this box."
	LOCAL aStruct := { {"DATA", "D", 8, 0}, {"NOTES", "M", 10, 0} }, ;
		cFileName := "Notes.dbf"

	If !Used()
		If !File( cFileName )
			DBcreate( cFileName, aStruct )
		EndIF

		USE ( cFileName ) ALIAS BASE NEW
		INDEX ON DTOS(FIELD->DATA) TO Notes

		IF Lastrec() = 0
			BASE->( dbappend() )
			BASE->DATA := Date()
			BASE->NOTES := cTxt
		ELSE
			Seek DTOS(Date())
		ENDIF

		Form_2.Edit_1.Value := BASE->NOTES
	EndIF

RETURN

*--------------------------------------------------------*
Static Procedure SaveNote( dDate, cText )
*--------------------------------------------------------*
	Local lText := !Empty( cText )

	If Used()
		Seek DTOS( dDate )
		If !Found() .AND. lText
			BASE->( dbappend() )
			BASE->DATA := dDate
		EndIF

		If lText
			BASE->NOTES := cText
		EndIF

		If Found() .AND. !lText
			BASE->( dbdelete() )
			pack
		EndIF
	EndIF

RETURN

*--------------------------------------------------------*
Static Procedure DeleteOldNotes()
*--------------------------------------------------------*
	Local nDeleted := 0

	IF MsgYesNo("Are you sure?", "Delete All Before Today", , , .f.)
		DELETE ALL FOR FIELD->DATA < Date()
		DBEVAL( { || nDeleted++ }, { || Deleted() } )
		if !Empty(nDeleted)
			pack
		endif
		MsgInfo("Deleted (" + Ltrim(Str(nDeleted))+ ") days", "Information")
	ENDIF

RETURN

*--------------------------------------------------------*
Static Procedure PrintNote( cText )
*--------------------------------------------------------*
   Local nLine, cLine, n := 0
   Private hbprn

   IF !Empty( cText )

	INIT PRINTSYS

	SELECT BY DIALOG 

	IF HBPRNERROR != 0 
		RETURN
	ENDIF

	DEFINE FONT "Font_1" NAME "MS Sans Serif" SIZE 12

	SET PAPERSIZE DMPAPER_A4	// Sets paper size to A4

	SET ORIENTATION PORTRAIT	// Sets paper orientation to portrait

	SET BIN DMBIN_FIRST 		// Use first bin
	SET QUALITY DMRES_HIGH		// Sets print quality to high

	SET PRINT MARGINS TOP 2 LEFT 5
	SET PREVIEW ON			// Enables print preview
	SET PREVIEW RECT 60, 100, GetDesktopHeight() - 60, GetDesktopWidth() - 40
	SET PREVIEW SCALE 2

	START DOC NAME Right(PROGRAM, 8)

		START PAGE

			For nLine := 1 To MlCount( cText )

				cLine := MemoLine( cText, , nLine )

				@n, 0 SAY cLine FONT "Font_1" TO PRINT

				n++

				IF n > HBPRNMAXROW - 3
					END PAGE

					n := 0

					START PAGE
				ENDIF
			Next

		END PAGE

	END DOC

	RELEASE PRINTSYS

   ENDIF

Return

*--------------------------------------------------------*
Function ShowHelp()
*--------------------------------------------------------*
	Local cHelp := MemoRead( "help.txt" )
return IF( Empty(cHelp), MsgStop( "Help is not available!", "Error" ), ;
	MsgInfo( cHelp, "Usage" ) )

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 44), "About", IDI_MAIN, .F. )

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetExeFileName() ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "TrayCalendar" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "TrayCalendar", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "TrayCalendar" )
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

*--------------------------------------------------------*
Static Function nHex( cHex )
*--------------------------------------------------------*
local n, nChar, nResult := 0
local nLen := Len( cHex )

	For n = 1 To nLen
		nChar = Asc( Upper( SubStr( cHex, n, 1 ) ) )
		nResult += ( ( nChar - If( nChar <= 57, 48, 55 ) ) * ( 16 ^ ( nLen - n ) ) )
	Next

return nResult


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( GETUSERLANGID )
{
   hb_retni( GetUserDefaultLangID() );
}

static char * u2Hex( WORD wWord )
{
    static far char szHex[ 5 ];

    WORD i= 3;

    do
    {
        szHex[ i ] = 48 + ( wWord & 0x000F );

        if( szHex[ i ] > 57 )
            szHex[ i ] += 7;

        wWord >>= 4;

    }
    while( i-- > 0 );

    szHex[ 4 ] = 0;

    return szHex;
}

HB_FUNC ( I2HEX )
{
   hb_retc( u2Hex( hb_parni( 1 ) ) );
}

HB_FUNC ( ENABLEPERMISSIONS )

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

#pragma ENDDUMP
