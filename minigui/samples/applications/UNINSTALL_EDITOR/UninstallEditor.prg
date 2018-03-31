/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM		'Uninstall Editor'
#define VERSION		' version 1.4'
#define VERS		' ver. 1.4'
#define COPYRIGHT	' 2003-2006 Grigory Filatov'

#define IDI_MAIN	1001
#define MsgAlert( c )	MsgEXCLAMATION( c, "Attention", , .f. )

Static nPageNumber := 1

DECLARE WINDOW Form_2

MEMVAR aInstall, aResult
*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
Local lWinRun := .F.

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "Uninstall Editor" ))
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	SET FONT TO _GetSysFont() , 10

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0 				;
		TITLE PROGRAM 				;
		MAIN NOSHOW 					;
		ON INIT ( IF(lWinRun, , StartUp(.F.)) ) 	;
		NOTIFYICON IDI_MAIN				;
		NOTIFYTOOLTIP PROGRAM 			;
		ON NOTIFYCLICK StartUp(.T.)

		DEFINE NOTIFY MENU 
			ITEM '&Open' 	ACTION {|| IF(IsWindowDefined( Form_2 ),	;
				(nPageNumber := Form_2.Tab_1.Value, Form_2.Release), ;
				StartUp()) } DEFAULT
			SEPARATOR	
			ITEM 'Auto&Run'	ACTION {|| lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) } ;
				NAME Auto_Run
			SEPARATOR	
			ITEM 'A&bout...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), IDI_MAIN, 32, 32) )
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure StartUp( lSwitch )
*--------------------------------------------------------*
Local aImage := {"no", "ok"}
PRIVATE aInstall := GetInstallArray()

   if !IsWindowDefined( Form_2 )

	DEFINE WINDOW Form_2	; 
        AT 0,0			; 
        WIDTH 430		; 
        HEIGHT IF(IsXPThemeActive(), 400, 396)	;
        TITLE PROGRAM		; 
        ICON IDI_MAIN		;
        NOMAXIMIZE NOSIZE	;
        ON INIT IF( lSwitch, SetForeGroundWindow( GetFormHandle( "Form_2" ) ), )

        DEFINE TAB Tab_1	;
		AT 7,7 		;
		WIDTH 410 	;
		HEIGHT 326	;
		VALUE 1		;
		ON CHANGE IF( Form_2.Tab_1.Value < 2, SetArrowCursor( GetControlHandle("Label_1", "Form_2") ), ;
			SetHandCursor( GetControlHandle("Image_1", "Form_2") ) )

		PAGE 'I&nstalled programs'

			@ 34, 20 LABEL Label_1			;
				VALUE "The following software can be automatically removed by Windows:" ;
				WIDTH 370        		;
				HEIGHT 16 TRANSPARENT		;
				FONT "Arial" SIZE 9

			@ 60, 15 GRID Grid_1 						;
				WIDTH 380 						;
				HEIGHT 220 						;
				HEADERS { '', 'Program Name', 'Uninstall Command' } 	;
				WIDTHS { 20, 240, 480 } 				;
				ITEMS aInstall VALUE 1 					;
				TOOLTIP 'Right click for context menu'		 	;
				NOLINES 						;
				IMAGE aImage 						;
				ON DBLCLICK EditKey( Form_2.Tab_1.Value, .t. )

			@ if(IsWinNT(), 290, 292), 160 BUTTON Button_3 ; 
				CAPTION 'New...' ; 
				ACTION EditKey( Form_2.Tab_1.Value, .f. ) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				FONT "Arial" SIZE 9

			@ if(IsWinNT(), 290, 292), 241 BUTTON Button_4 ; 
				CAPTION 'Remove' ; 
				ACTION DeleteKey( Form_2.Tab_1.Value ) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				FONT "Arial" SIZE 9

			@ if(IsWinNT(), 290, 292), 322 BUTTON Button_5 ; 
				CAPTION 'Edit' ; 
				ACTION EditKey( Form_2.Tab_1.Value, .t. ) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				FONT "Arial" SIZE 9

		END PAGE

		PAGE 'A&bout'

			@ 34, 42 LABEL Label_2		;
				VALUE PROGRAM + VERS	;
				ACTION MsgAbout()	;
				AUTOSIZE		;
				FONT 'Arial' SIZE 22 	;
				BOLD TRANSPARENT

			@ 72, 42 LABEL Label_3		;
				VALUE "Copyright " + Chr(169) + COPYRIGHT ;
				WIDTH 310        	;
				HEIGHT 16		;
				FONT "MS Sans Serif" SIZE 9 ;
				ACTION MsgAbout() CENTERALIGN TRANSPARENT

			@ 96, 15 FRAME TabFrame_6 WIDTH 380 HEIGHT 84

			@ 106, 30 LABEL Label_4		;
				VALUE "Author:   Grigory Filatov (Ukraine)" ;
				ACTION MsgAbout()	;
				AUTOSIZE

			@ 128, 33 LABEL Label_5		;
				VALUE "E-mail:"		;
				WIDTH 42        	;
				HEIGHT 18

			@ 127, 84 HYPERLINK Link_1	;
				VALUE "gfilatov@inbox.ru" ;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Uninstall%20Editor%20Feedback:" ;
				WIDTH 104        	;
				HEIGHT 18		;
				TOOLTIP "E-mail me if you have any comments or suggestions"

			@ 150, 37 LABEL Label_6		;
				VALUE "Bugs:" 		;
				WIDTH 36        	;
				HEIGHT 18

			@ 149, 84 HYPERLINK Link_2	;
				VALUE "report" 		;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Uninstall%20Editor%20Bug:" + ;
					"&body=" + GetReport() ;
				WIDTH 50        	;
				HEIGHT 18		;
				TOOLTIP "Send me a bug-report if you experience any problems"

			@ 120, 280 IMAGE Image_1	;
				PICTURE IF(IsXPThemeActive(), "UNINSTALLXP", ;
					IF(IsWinNT(), "UNINSTALLNT", "UNINSTALL")) ;
				WIDTH 32 HEIGHT 32	;
				ACTION MsgAbout()

			@ 190, 15 IMAGE Image_2 PICTURE "HARBOUR" WIDTH 380 HEIGHT 120 ;
				ACTION ShellExecute(0, "open", "https://harbour.github.io/")

		END PAGE

        END TAB

        Form_2.Tab_1.Value := nPageNumber

        @ if(IsWinNT(), 338, 340), 262 BUTTON Button_1 ; 
            CAPTION 'OK' ; 
            ACTION ( nPageNumber := Form_2.Tab_1.Value, Form_2.Release ) ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            FONT "Arial" SIZE 9

        @ if(IsWinNT(), 338, 340), 343 BUTTON Button_2 ; 
            CAPTION 'Cancel' ; 
            ACTION ReleaseAllWindows() ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            FONT "Arial" SIZE 9

		DEFINE CONTEXT MENU CONTROL Grid_1
			ITEM '&New...'		ACTION EditKey( Form_2.Tab_1.Value, .f. )
			ITEM '&Edit...'		ACTION EditKey( Form_2.Tab_1.Value, .t. )
			ITEM '&Remove' 		ACTION DeleteKey( Form_2.Tab_1.Value )
			SEPARATOR	
			ITEM '&Uninstall'	ACTION UninstallPrg( Form_2.Tab_1.Value )
			SEPARATOR	
			ITEM '&Properties'	ACTION PrgProp( Form_2.Tab_1.Value )
		END MENU

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

   Else

	nPageNumber := Form_2.Tab_1.Value
	Form_2.Release

   EndIf

Return

*--------------------------------------------------------*
Static Function GetReport()
*--------------------------------------------------------*
Local cRet := "***%20Uninstall%20Editor%20BugReport%20***%0A%0A"

	cRet += "OPERATING%20SYSTEM%3A" + space( 3 ) + OS() + "%0A%0A"
	cRet += "AMOUNT OF RAM (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(1) + 1 ) ) + "%0A%0A"
	cRet += "SWAP-FILE SIZE (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(3) ) ) + "%0A%0A"
	cRet += "PROBLEM DESCRIPTION%3A"

Return cRet

*--------------------------------------------------------*
Static Procedure EditKey(nPage, lExist)
*--------------------------------------------------------*
Local nActItem, nItem, cPath, cFile, nVerify, ;
	aLabels, aInitValues := { "", "" }, aFormats, aResults
Local oReg, cReg := "", oKey, nId:= 0, cName, hKey := HKEY_LOCAL_MACHINE, ;
	cRunKey := "Software\Microsoft\Windows\CurrentVersion\Uninstall"

   IF nPage < 2

	nActItem := GetProperty( "Form_2", "Grid_" + Ltrim( Str( nPage ) ), "Value" )

	IF lExist .AND. !EMPTY(nActItem)

		aInitValues[1]	:= aInstall[nActItem][2]
		aInitValues[2]	:= aInstall[nActItem][3]

	ELSE

		lExist := .F.

	ENDIF

	aLabels		:= { "Description:", "Uninstaller:" }

	aFormats	:= { 60, 150 }

	aResults	:= MyInputWindow( "Program Properties", aLabels, aInitValues, aFormats )

	IF aResults[1] # Nil

		IF !Empty( aResults[2] )

			IF lExist

				oReg := TReg32():New( hKey, cRunKey )

				While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
					oKey := TReg32():New( hKey, cRunKey + "\" + cReg )

					cName := oKey:Get("DisplayName")

					IF cName == aInstall[nActItem][2]
						oKey:Set("DisplayName", aResults[1])
						oKey:Set("UninstallString", aResults[2])
						oKey:Close()
						EXIT
					ENDIF

					oKey:Close()

				EndDo

				oReg:Close()

				aInstall[nActItem][2] := aResults[1]
				aInstall[nActItem][3] := aResults[2]

			ELSE

				SETREGVAR( hKey, cRunKey + "\" + aResults[1], "DisplayName", aResults[1] )
				SETREGVAR( hKey, cRunKey + "\" + aResults[1], "UninstallString", aResults[2] )

				AADD(aInstall, { 1, aResults[1], aResults[2] })
				nActItem := LEN(aInstall)

			ENDIF

			DELETE ITEM ALL FROM Grid_1 OF Form_2

			FOR nItem := 1 TO LEN(aInstall)

				cPath := aInstall[nItem][3]

				nVerify := IF(FILE(GetWindowsFolder() + '\' + cFileNoExt(cPath) + '.exe'), 1, 0)
				nVerify := IF(!EMPTY(nVerify) .OR. FILE(GetSystemFolder() + '\' + cFileNoExt(cPath) + '.exe'), 1, 0)

				IF EMPTY(nVerify)
					DO CASE
						CASE FILE(StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')) == .T.
							nVerify := 1
						CASE FILE(StrTran(SubStr(cPath, 1, AT(".", cPath) + 3), '"', '')) == .T.
							nVerify := 1
						CASE FILE((cFile := StrTran(SubStr(cPath, 1, AT(" ", cPath) - 1), '"', ''))) == .T.
							nVerify := 1
						CASE FILE(GetWindowsFolder() + '\' + cFileNoExt(cFile) + '.exe') == .T.
							nVerify := 1
						CASE FILE(GetSystemFolder() + '\' + cFileNoExt(cFile) + '.exe') == .T.
							nVerify := 1
					END CASE

				ELSE
					IF AT(".exe", Lower(cPath)) > 0
						nVerify := IF(FILE(StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')), 1, 0)
					ENDIF

				ENDIF

				ADD ITEM { nVerify, aInstall[nItem][2], aInstall[nItem][3] } TO Grid_1 OF Form_2

			NEXT

			Form_2.Grid_1.Value := nActItem

	      ELSE

			MsgAlert( "Please enter the path to the uninstall program!" )

	      ENDIF

	ENDIF

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure DeleteKey(nPage)
*--------------------------------------------------------*
Local nActItem, oReg, oKey, cReg := "", cName := "", nId := 0, ;
	hKey := HKEY_LOCAL_MACHINE, ;
	cRunKey := "Software\Microsoft\Windows\CurrentVersion\Uninstall"

IF nPage < 2

   nActItem := GetProperty( "Form_2", "Grid_" + Ltrim( Str( nPage ) ), "Value" )

   IF !EMPTY(nActItem)

		IF MsgYesNo( "Are you sure you want to remove the selected item?", "Confirm", , , .f. )

			if IsWinNT()
			      EnablePermissions()
			endif

			oReg := TReg32():New( hKey, cRunKey )

			While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
				oKey := TReg32():New( hKey, cRunKey + "\" + cReg )

				cName := oKey:Get("DisplayName")

				IF cName == aInstall[nActItem][2]
					oKey:Delete( "DisplayName" )
					oKey:Delete( "UninstallString" )
					nId := 0
					While RegEnumValue( oKey:nHandle, nId++, @cName ) == 0
						oKey:Delete( cName )
					EndDo
					oKey:Close()
					EXIT
				ENDIF

				oKey:Close()

			EndDo

			oReg:Close()

			DELREGKEY( hKey, cRunKey, aInstall[nActItem][2] )

			DELETE ITEM nActItem FROM Grid_1 OF Form_2

			aDel( aInstall, nActItem )
			aSize( aInstall, Len(aInstall) - 1 )

			Form_2.Grid_1.Value := IF(nActItem > 1, nActItem - 1, nActItem)

		ENDIF

	ENDIF

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure UninstallPrg(nPage)
*--------------------------------------------------------*
Local nActItem, cPath, cPrg, cData

IF nPage < 2

   nActItem := GetProperty( "Form_2", "Grid_"+Ltrim(Str(nPage)), "Value" )

   IF !EMPTY(nActItem)

		IF MsgYesNo( "Are you sure you want to uninstall the selected program?", "Confirm", , , .f. )

			Form_2.Release

			cPath := aInstall[nActItem][3]

			cPrg := StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')

			cData := Ltrim(StrTran(StrTran(cPath, cPrg, ""), '"', ''))

			ShellExecute(0, "open", cPrg, cData, , 1)

		ENDIF

	ENDIF

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure PrgProp(nPage)
*--------------------------------------------------------*
Local nActItem, aFile, cPath, cFile, cDesc := "", cVers := "", cLC := "", hIcon
Local aInfo := { "FileDescription", "FileVersion", "LegalCopyright" }

IF nPage < 2

   nActItem := GetProperty( "Form_2", "Grid_" + Ltrim( Str( nPage ) ), "Value" )

   IF !EMPTY(nActItem)
	cPath := aInstall[nActItem][3]
	cFile := StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')
	cFile := IF(FILE(cFile), cFile, StrTran(SubStr(cPath, 1, AT(".", cPath) + 3), '"', ''))
	cFile := IF(FILE(cFile), cFile, StrTran(SubStr(cPath, 1, AT(" ", cPath) - 1), '"', ''))
	cFile := IF(FILE(cFile), cFile, GetWindowsFolder() + '\' + cFileNoExt(cFile) + '.exe')
	cFile := IF(FILE(cFile), cFile, GetSystemFolder() + '\' + cFileNoExt(cFile) + '.exe')

	aFile := FileVersInfo(aInfo, GetInstance(), cFile)

	IF LEN(aFile) > 0
		IF valtype(aFile[1]) == "C"
			cDesc := aFile[1]
		ENDIF
		IF valtype(aFile[2]) == "C"
			cVers := aFile[2]
		ENDIF
		IF valtype(aFile[3]) == "C"
			cLC := aFile[3]
		ENDIF
	ENDIF

	hIcon := ExtractIcon(cFile, 0)

	ShellAbout( aInstall[nActItem][2], cDesc + ", " + cVers + CRLF + cLC, hIcon ) 

	DestroyIcon(hIcon)
   ENDIF

ENDIF

Return

*--------------------------------------------------------*
Static Function GetInstallArray(hKey)
*--------------------------------------------------------*
Local aInst := {}, oReg, cReg := "", oKey, cFile, ;
	cName, cPath, nId := 0, nVerify

   hKey := IF(hKey == NIL, HKEY_LOCAL_MACHINE, hKey)

   oReg := TReg32():New( hKey, "Software\Microsoft\Windows\CurrentVersion\Uninstall" )

   While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
	oKey := TReg32():New( hKey, "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + cReg )

	cName := oKey:Get("DisplayName")
	cPath := oKey:Get("UninstallString")
	oKey:Close()

	IF !EMPTY(cName) .AND. !EMPTY(cPath)

		nVerify := IF(FILE(GetWindowsFolder() + '\' + cFileNoExt(cPath) + '.exe'), 1, 0)
		nVerify := IF(!EMPTY(nVerify) .OR. FILE(GetSystemFolder() + '\' + cFileNoExt(cPath) + '.exe'), 1, 0)

		IF EMPTY(nVerify)

			DO CASE
				CASE FILE(StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')) == .T.
					nVerify := 1
				CASE FILE(StrTran(SubStr(cPath, 1, AT(".", cPath) + 3), '"', '')) == .T.
					nVerify := 1
				CASE FILE((cFile := StrTran(SubStr(cPath, 1, AT(" ", cPath) - 1), '"', ''))) == .T.
					nVerify := 1
				CASE FILE(GetWindowsFolder() + '\' + cFileNoExt(cFile) + '.exe') == .T.
					nVerify := 1
				CASE FILE(GetSystemFolder() + '\' + cFileNoExt(cFile) + '.exe') == .T.
					nVerify := 1
			END CASE

		ELSE

			IF AT(".exe", Lower(cPath)) > 0
				nVerify := IF(FILE(StrTran(SubStr(cPath, 1, AT(".exe", Lower(cPath)) + 4), '"', '')), 1, 0)
			ENDIF

		ENDIF

		nVerify := IF(!EMPTY(nVerify) .OR. FILE(GetSystemFolder() + '\' + SubStr(cPath, 1, AT(" ", cPath) - 1) + '.exe'), 1, 0)

		aAdd( aInst, { nVerify, cName, cPath } )

	ENDIF

   EndDo

   oReg:Close()

RETURN ASORT(aInst, , , {|a,b| UPPER(a[2]) < UPPER(b[2])})

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 42), "About", IDI_MAIN, .f. )

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "Uninstall Editor" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "Uninstall Editor", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "Uninstall Editor" )
   ENDIF

return

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
   LOCAL oReg

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   oReg:Delete(cSubKey)
   oReg:Close()

RETURN NIL

*--------------------------------------------------------*
STATIC FUNCTION DELREGKEY(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:KeyDelete(cSubKey)
   oReg:Close()

RETURN nValue

*--------------------------------------------------------*
Function MyInputWindow( Title, aLabels, aValues, aFormats )
*--------------------------------------------------------*
Local i , l , ControlRow , LN , CN , PB , cFile

	l := Len( aLabels )

	Private aResult[l]

	DEFINE WINDOW _MyInputWindow ;
		AT 0,0 ;
		WIDTH 430 ;
		HEIGHT (l*30) + 80 ;
		TITLE Title ;
		ICON IDI_MAIN ;
		MODAL ;
		NOSIZE

		ControlRow :=  10

		For i := 1 to l

			LN := 'Label_' + Ltrim(Str(i))
			CN := 'Control_' + Ltrim(Str(i))
			PB := 'PicButton_' + Ltrim(Str(i))

			@ ControlRow + 3, 10 LABEL &LN VALUE aLabels[i] ;
				FONT "MS Sans Serif" SIZE 11

			do case

			case ValType ( aValues [i] ) == 'D'

				@ ControlRow , 140 DATEPICKER &CN VALUE aValues[i] WIDTH 140
				ControlRow := ControlRow + 30

			case ValType( aValues[i] ) == 'N'

				If  ValType( aFormats[i] ) == 'C'

					If AT ( '.' , aFormats [i] ) > 0
						@ ControlRow , 140 TEXTBOX &CN VALUE aValues[i] ;
							WIDTH 140 NUMERIC INPUTMASK aFormats[i] 
					Else
						@ ControlRow , 140 TEXTBOX &CN VALUE aValues[i] ;
							WIDTH 140 MAXLENGTH Len(aFormats[i]) NUMERIC
					EndIf

					ControlRow := ControlRow + 30
				Endif

			case ValType( aValues[i] ) == 'C'

				If ValType ( aFormats [i] ) == 'N'
					@ ControlRow, 91 TEXTBOX &CN VALUE aValues[i] ;
						WIDTH 295 MAXLENGTH aFormats[i] ;
						ON ENTER _MyInputWindow.BUTTON_1.SetFocus

					@ ControlRow, 394 BUTTON &PB PICTURE "OPEN" ;
						ACTION {|| cFile := ;
						GetFile( {{"Programs", "*.exe"}, {"All files", "*.*"}}, ;
						"Select the program's executable" ), ;
						IF(EMPTY(_MyInputWindow.Control_1.Value), ;
						_MyInputWindow.Control_1.Value := cFileNoExt(cFile), ), ;
						_MyInputWindow.Control_2.Value := cFile, ;
						_MyInputWindow.BUTTON_1.SetFocus } ;
						WIDTH 24 HEIGHT 24 TOOLTIP "Browse for file"

					ControlRow := ControlRow + 30
				EndIf

			endcase

		Next i

		@ ControlRow + 8, 230 BUTTON BUTTON_1 ;
			CAPTION '&OK' ;
			ACTION _MyInputWindowOk() ;
			WIDTH 74 ;
			HEIGHT 24 ;
			FONT "Arial" SIZE 9

		@ ControlRow + 8, 312 BUTTON BUTTON_2 ;
			CAPTION '&Cancel' ;
			ACTION _MyInputWindowCancel() ;
			WIDTH 74 ;
			HEIGHT 24 ;
			FONT "Arial" SIZE 9

		ON KEY ESCAPE ACTION _MyInputWindow.BUTTON_2.OnClick

		_MyInputWindow.Control_1.SetFocus

	END WINDOW

	CENTER WINDOW _MyInputWindow

	ACTIVATE WINDOW _MyInputWindow

Return ( aResult )

*--------------------------------------------------------*
Function _MyInputWindowOk 
*--------------------------------------------------------*
Local i , ControlName , l 

	l := len (aResult)

	For i := 1 to l

		ControlName := 'Control_' + Alltrim ( Str ( i ) )
		aResult [i] := GetProperty( '_MyInputWindow', ControlName, 'Value' )

	Next i

	RELEASE WINDOW _MyInputWindow

Return Nil

*--------------------------------------------------------*
Function _MyInputWindowCancel
*--------------------------------------------------------*
Local i , l

	l := len (aResult)

	For i := 1 to l

		aResult [i] := Nil

	Next i

	RELEASE WINDOW _MyInputWindow

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include <winver.h>

#include "hbapi.h"
#include "hbapiitm.h"

#include "winreg.h"
#include "tchar.h"

#ifdef __XHARBOUR__
#define HB_PARC( n, x ) hb_parc( n, x )
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_PARC( n, x ) hb_parvc( n, x )
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

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

HB_FUNC ( REGENUMKEY )
{
   char buffer[ 128 ];

   hb_retnl( RegEnumKey( ( HKEY ) hb_parnl( 1 ), hb_parnl( 2 ), buffer, 128 ) );
   hb_storc( buffer, 3 );
}

HB_FUNC ( REGENUMVALUE )
{
   DWORD lpType = 1;
   TCHAR Buffer[255];
   DWORD dwBuffSize = 255;
   DWORD dwClass = 255;
   long  lError;

   lError = RegEnumValue( (HKEY) hb_parnl(1), hb_parnl(2), Buffer, &dwBuffSize, NULL, &lpType, NULL, &dwClass );
   if ( lError != ERROR_SUCCESS )
   {
      hb_retnl( -1 );
   }
   else
   {
      hb_storc( Buffer, 3 );
      hb_retnl( 0 );
   }
}

HB_FUNC( FILEVERSINFO )
{
    int   iLen  = hb_itemSize( hb_param(1, -1) );
    char  szFullPath[256];
    DWORD dwVerHnd;
    DWORD dwVerInfoSize;
    HANDLE hHndl = (HANDLE) hb_parni(2);

    if ( hb_pcount() > 2 )
    {
      // Get version information from an application path + filename
      lstrcpy( szFullPath, hb_parc(3) );
    } else {
      // Get version information from the application
      GetModuleFileName( hHndl, szFullPath, sizeof(szFullPath) );
    }

    dwVerInfoSize = GetFileVersionInfoSize(szFullPath, &dwVerHnd);
    if (dwVerInfoSize)
    {
        // If we were able to get the information, process it:
        HANDLE  hMem;
        LPVOID  lpvMem;
        DWORD   * pdwLangChar;
        UINT    uSize;
        char    szGetName[256];
        int     cchRoot;
        int     i;

        hMem   = GlobalAlloc(GMEM_MOVEABLE, dwVerInfoSize);
        lpvMem = GlobalLock(hMem);
        GetFileVersionInfo(szFullPath, dwVerHnd, dwVerInfoSize, lpvMem);
        if (VerQueryValue(lpvMem, "\\VarFileInfo\\Translation", (void**)(&pdwLangChar), &uSize))
        {
           wsprintf(szGetName, "\\StringFileInfo\\%04X%04X\\", LOWORD(*pdwLangChar), HIWORD(*pdwLangChar));
        }
        else
        {
           lstrcpy(szGetName, "\\StringFileInfo\\040904E4\\");
        }

        cchRoot = lstrlen(szGetName);

        hb_reta( iLen );

        // Walk through the requested items:
        for (i = 1; i <= iLen; i++)
        {

#if defined( __BORLANDC__ )
           #pragma warn -sus
#endif
           BOOL  fRet;
           UINT  cchVer = 0;
           LPSTR lszVer = NULL;
           char  szResult[256];

           lstrcpy( &szGetName[cchRoot], HB_PARC( 1, i ) );

           fRet = VerQueryValue(lpvMem, szGetName, (void**)(&lszVer), &cchVer);

           if (fRet && cchVer && lszVer)
           {
              lstrcpy(szResult, lszVer);
              HB_STORC( szResult, -1, i );
           }

        }

        GlobalUnlock(hMem);
        GlobalFree(hMem);
     }
     else
     {
        hb_reta( 0 );
     }
}

#pragma ENDDUMP
