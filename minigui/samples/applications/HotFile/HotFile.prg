/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-03 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Hot File'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2003-2006 Grigory Filatov'

Static aPublicVars := { "HotFile.ini", "My Hot File.txt", "", "Hot File" }

#xtranslate cCfgFile     => aPublicVars\[1\]
#xtranslate cFileName    => aPublicVars\[2\]
#xtranslate cFileFolder  => aPublicVars\[3\]
#xtranslate cFileComment => aPublicVars\[4\]

Procedure Main( lStartUp )
	Local lWinRun := .F., lOptions := .F.

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "HotFile" ))
		lWinRun := .T.
	EndIf

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "OPTIONS"
		lOptions := .T.
	EndIf

	SET MULTIPLE OFF

	SET HELPFILE TO 'HOTFILE.CHM'

	cFileFolder := GetMyDocumentsFolder()

	IF !File( cCfgFile )
		BEGIN INI FILE cCfgFile
			SET SECTION "Options" ENTRY "FileName" TO cFileName
			SET SECTION "Options" ENTRY "FileFolder" TO cFileFolder
			SET SECTION "Options" ENTRY "FileComment" TO cFileComment
		END INI
	ELSE
		BEGIN INI FILE cCfgFile
			GET cFileName SECTION "Options" ENTRY "FileName"
			GET cFileFolder SECTION "Options" ENTRY "FileFolder"
			GET cFileComment SECTION "Options" ENTRY "FileComment"
		END INI
	ENDIF

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0 				;
		TITLE PROGRAM 				;
		MAIN NOSHOW					;
		ON INIT IF(lWinRun, , IF(lOptions,		;
			SetOptions(), RunHotFile()))	;
		NOTIFYICON 'MAIN' 				;
		NOTIFYTOOLTIP cFileComment 			;
		ON NOTIFYCLICK RunHotFile()

		DEFINE NOTIFY MENU 
			ITEM 'Auto&Run'		ACTION ( lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) ) ;
				NAME Auto_Run
			SEPARATOR	
			ITEM 'Open &Notes'	ACTION RunHotFile() DEFAULT
			ITEM '&Options'		ACTION SetOptions()
			ITEM '&Help'		ACTION _Execute( _HMG_MainHandle, "open", 'HotFile.CHM' )
			ITEM 'A&bout...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) )
			SEPARATOR	
			ITEM 'E&xit'		ACTION Form_1.Release
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure RunHotFile()
*--------------------------------------------------------*

  If ! lCheckTasks( _HMG_MainHandle )

	If ! File( cFileFolder + "\" + cFileName )
		FClose( FCreate( cFileFolder + "\" + cFileName ) )
	EndIf

	EXECUTE FILE cFileFolder + "\" + cFileName DEFAULT cFileFolder

  EndIf

Return

*--------------------------------------------------------*
Static Procedure SetOptions()
*--------------------------------------------------------*
  Local cFile, hIcon

  DEFINE WINDOW Form_2 ; 
    AT 0,0 ; 
    WIDTH 430 ; 
    HEIGHT 164 + IF(IsXPThemeActive(), 6, 0) ; 
    TITLE PROGRAM + ' Options' ; 
    ICON 'MAIN' ; 
    NOMINIMIZE NOMAXIMIZE NOSIZE ;
    ON INIT DoMethod( "Form_2", "Control_9", "SetFocus" ) ;
    ON PAINT ( hIcon := LoadTrayIcon( GetInstance(), "MAIN", 32, 32 ), ;
       DrawIcon( GetFormHandle("Form_2"), 16, 100, hIcon ), DestroyIcon( hIcon ) ) ;
    FONT 'MS Sans Serif' ;
    SIZE 9

    @ 12,8 LABEL CONTROL_1 ; 
        VALUE 'File Name:' ; 
        WIDTH 80 ; 
        HEIGHT 16 ; 

    @ 42,8 LABEL CONTROL_2 ; 
        VALUE 'File Comment:' ; 
        WIDTH 80 ; 
        HEIGHT 16 ; 

    @ 75,8 LABEL CONTROL_3 ; 
        VALUE 'File Folder:' ; 
        WIDTH 80 ; 
        HEIGHT 16 ; 

    @ 9,85 TEXTBOX CONTROL_4 ; 
        VALUE cFileName ;
        HEIGHT 21 ; 
        WIDTH 256 ; 

    @ 39,85 TEXTBOX CONTROL_5 ; 
        VALUE cFileComment ; 
        HEIGHT 21 ; 
        WIDTH 256 ;
        ON CHANGE ( cFileComment := Form_2.Control_5.Value )

    @ 72,85 TEXTBOX CONTROL_6 ; 
        VALUE cFileFolder ;
        HEIGHT 21 ; 
        WIDTH 330 ;
        READONLY

    @ 9,352 BUTTON CONTROL_7 ; 
        CAPTION '&Browse' ; 
        ACTION ( cFile := Getfile( { {"Text files (*.txt)", "*.txt"}, ;
                                   {"MS Office documents (*.doc, *.xls, *.mdb)", "*.doc;*.xls;*.mdb"}, ;
                                   {"All files (*.*)", "*.*"}  }, /*"Select a file"*/, cFileFolder ), ;
		IF(!EMPTY(cFile), ( cFileName := cFileNoPath(cFile), cFileFolder := cFilePath(cFile), ;
			Form_2.Control_4.Value := cFileName, Form_2.Control_6.Value := cFileFolder ), ) ) ;
        WIDTH 62 ; 
        HEIGHT 21 ; 

    @ 107,166 BUTTON CONTROL_8 ; 
        CAPTION '&OK' ; 
        ACTION { || SaveCfg(), Form_2.Release } ; 
        WIDTH 80 ; 
        HEIGHT 23 ; 

    @ 107,250 BUTTON CONTROL_9 ; 
        CAPTION '&Cancel' ; 
        ACTION Form_2.Release ; 
        WIDTH 80 ; 
        HEIGHT 23 ; 

    @ 107,334 BUTTON CONTROL_10 ; 
        CAPTION '&Help' ; 
        ACTION { || _Execute( _HMG_MainHandle, "open", 'HotFile.CHM' ) } ;
        WIDTH 80 ; 
        HEIGHT 23 ; 

    ON KEY ESCAPE ACTION Form_2.Release

  END WINDOW

  CENTER WINDOW Form_2

  ACTIVATE WINDOW Form_2

Return

*--------------------------------------------------------*
Static Procedure SaveCfg()
*--------------------------------------------------------*
  Local cCurDir := CurDrive() + ":\" + CurDir()

	Form_1.NotifyTooltip := cFileComment

	SetCurrentFolder( cFilePath( GetExeFileName() ) )

	BEGIN INI FILE cCfgFile
		SET SECTION "Options" ENTRY "FileName" TO cFileName
		SET SECTION "Options" ENTRY "FileFolder" TO cFileFolder
		SET SECTION "Options" ENTRY "FileComment" TO cFileComment
	END INI

	SetCurrentFolder( cCurDir )

Return

#define GW_HWNDFIRST 0
#define GW_HWNDNEXT  2
#define GW_OWNER     4
*--------------------------------------------------------*
Function lCheckTasks( hOwnWnd )
*--------------------------------------------------------*
  local hWnd := GetWindow( hOwnWnd, GW_HWNDFIRST )
  local cTitle, lExist := .F., nItem := 1

  WHILE hWnd != 0 .AND. nItem < 99

	IF hWnd != hOwnWnd
		cTitle := AllTrim( GetWindowText( hWnd ) )
		IF ! Empty(cTitle) .AND. GetWindow( hWnd, GW_OWNER ) = 0 .AND. cFileName $ cTitle
			lExist := .T.
			EXIT
		ENDIF
	ENDIF

	hWnd := GetWindow( hWnd, GW_HWNDNEXT )
	nItem++

  ENDDO

Return lExist

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "HotFile" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "HotFile", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "HotFile" )
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

#include <windows.h>
#include "hbapi.h"

HB_FUNC( DRAWICON )
{
    HWND hwnd;
    HDC hdc;

    hwnd  = (HWND) hb_parnl( 1 ) ;
    hdc   = GetDC( hwnd ) ;
 
    hb_retl( DrawIcon( (HDC) hdc , hb_parni( 2 ) , hb_parni( 3 ) , (HICON) hb_parnl( 4 ) ) ) ;
    ReleaseDC( hwnd, hdc ) ;
}

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

#pragma ENDDUMP
