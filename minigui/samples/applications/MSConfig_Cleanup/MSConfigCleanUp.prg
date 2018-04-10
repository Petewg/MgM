/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM		'MSConfig Cleanup'
#define VERSION		' version 1.1'
#define COPYRIGHT	' Grigory Filatov, 2006-2014'

#define VERS		' 1.1'
#define IDI_MAIN	1001

MEMVAR aHKLM
MEMVAR aHKCU

Procedure Main()
LOCAL aImage := { "uncheck", "check" }

	SET MULTIPLE OFF WARNING

	PRIVATE aHKLM := IF(IsWinXPorLater(), GetMSConfigArray( "HKLM" ), GetRunArray( HKEY_LOCAL_MACHINE ) )
	PRIVATE aHKCU := IF(IsWinXPorLater(), GetMSConfigArray(), GetRunArray() )

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 430				;
		HEIGHT IF(IsXPThemeActive(), 402, 396)	; 
		TITLE PROGRAM				;
		ICON IDI_MAIN				;
		MAIN 					;
		NOMAXIMIZE NOSIZE			;
		FONT 'MS Sans Serif'			;
		SIZE 9

        DEFINE TAB Tab_1	 			;
		AT 7,7 					;
		WIDTH 410 				;
		HEIGHT 326 				;
		VALUE 1					;
		ON CHANGE ( Form_1.Button_1.Visible := (Form_1.Tab_1.Value < 3), ;
			Form_1.Button_2.Visible := (Form_1.Tab_1.Value < 3), ;
			Form_1.Button_3.Visible := (Form_1.Tab_1.Value < 3) )

		PAGE 'HK&LM'

			@ 34, 20 LABEL Label_1					;
				VALUE "Cleanup these programs from the HKEY_LOCAL_MACHINE registry key:" ;
				WIDTH 370        				;
				HEIGHT 16 TRANSPARENT

			@ 60, 15 GRID Grid_1 					; 
				WIDTH 380 					; 
				HEIGHT 250 					; 
				HEADERS { '','Application','File Path' } 	; 
				WIDTHS { 0, 122, 220 } 				; 
				ITEMS aHKLM VALUE 1 				;
				TOOLTIP 'Double click for toggle of activate'	;
				NOLINES 					;
				IMAGE aImage 					;
				ON DBLCLICK ToggleRefresh(1)			;
				FONT 'Tahoma'					;
				SIZE 9

		END PAGE

		PAGE 'HK&CU'

			@ 34, 20 LABEL Label_2					;
				VALUE "Cleanup these programs from the HKEY_CURRENT_USER registry key:" ;
				WIDTH 370        				;
				HEIGHT 16 TRANSPARENT

			@ 60, 15 GRID Grid_2 					; 
				WIDTH 380 					; 
				HEIGHT 250 					; 
				HEADERS { '','Application','File Path' } 	; 
				WIDTHS { 0, 122, 220 } 				; 
				ITEMS aHKCU VALUE 1 				;
				TOOLTIP 'Double click for toggle of activate'	;
				NOLINES 					;
				IMAGE aImage 					;
				ON DBLCLICK ToggleRefresh(2)			;
				FONT 'Tahoma'					;
				SIZE 9

		END PAGE

		PAGE 'A&bout'

			@ 32, 15 LABEL Label_5		;
				VALUE PROGRAM + VERS	;
				WIDTH 380        	;
				HEIGHT 34		;
				FONT 'Arial' SIZE 22 	;
				BOLD CENTERALIGN	;
				ACTION MsgAbout()

			@ 72, 115 LABEL Label_6		;
				VALUE "Copyright " + Chr(169) + COPYRIGHT ;
				AUTOSIZE ;
				ACTION MsgAbout()

			@ 96, 15 FRAME TabFrame_6 WIDTH 380 HEIGHT 80

			@ 106, 30 LABEL Label_15	;
				VALUE "Author:   Grigory Filatov (Ukraine)" ;
				ACTION MsgAbout()	;
				AUTOSIZE

			@ 128, 33 LABEL Label_16	;
				VALUE "E-mail:"		;
				WIDTH 36        	;
				HEIGHT 16

			@ 127, 73 HYPERLINK Label_17	;
				VALUE "gfilatov@inbox.ru" ;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=MSConfig%20Cleanup%20Feedback:" ;
				WIDTH 100        	;
				HEIGHT 16		;
				TOOLTIP "E-mail me if you have any comments or suggestions"

			@ 150, 37 LABEL Label_18	;
				VALUE "Bugs:" 		;
				WIDTH 36        	;
				HEIGHT 16

			@ 149, 73 HYPERLINK Label_19	;
				VALUE "report" 		;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=MSConfig%20Cleanup%20Bug:" + ;
					"&body=" + GetReport() ;
				WIDTH 100        	;
				HEIGHT 16		;
				TOOLTIP "Send me a bug-report if you experience any problems"

			@ 120,280 ANIMATEBOX Avi_1	;
				WIDTH 32		;
				HEIGHT 32		;
				FILE 'LOGO' AUTOPLAY

			SetHandCursor(GetControlHandle("Label_5", "Form_1"))

			@ 190, 15 IMAGE Image_1 PICTURE "HARBOUR" WIDTH 380 HEIGHT 120 ;
				ACTION ShellExecute(0, "open", "https://harbour.github.io/")

		END PAGE

        END TAB

        @ 340, 7 BUTTONEX Button_1 ;
            CAPTION 'Select All' ;
            ACTION ToggleRefresh(Form_1.Tab_1.Value, .T.) ;
            WIDTH 74 ;
            HEIGHT 24 ;
            FONT 'Tahoma' ;
            SIZE 9

        @ 340, 92 BUTTONEX Button_2 ;
            CAPTION 'Deselect All' ;
            ACTION ToggleRefresh(Form_1.Tab_1.Value, .F.) ;
            WIDTH 74 ;
            HEIGHT 24 ;
            FONT 'Tahoma' ;
            SIZE 9

        @ 340, 184 BUTTONEX Button_3 ;
            CAPTION 'Clean Up Selected' ;
            ACTION IF( _hmg_IsXp, DeleteKeys(Form_1.Tab_1.Value), DeleteSelectedKeys(Form_1.Tab_1.Value) ) ;
            WIDTH 112 ;
            HEIGHT 24 ;
            FONT 'Tahoma' ;
            SIZE 9

        @ 340, 336 BUTTONEX Button_4 ;
            CAPTION 'Quit' ;
            ACTION ReleaseAllWindows() ;
            WIDTH 80 ;
            HEIGHT 24 ;
            FONT 'Tahoma' ;
            SIZE 9

	Form_1.Button_3.Enabled := .F.
	Form_1.Button_4.SetFocus

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure DeleteSelectedKeys( nPage )
*--------------------------------------------------------*
LOCAL aArray, nItem, hKey, cRunKey := "Software\Microsoft\Windows\CurrentVersion\Run-"

	DO CASE
		CASE nPage = 1
			aArray := ACLONE(aHKLM)
			hKey := HKEY_LOCAL_MACHINE

		CASE nPage = 2
			aArray := ACLONE(aHKCU)
			hKey := HKEY_CURRENT_USER
	ENDCASE

	FOR nItem := LEN(aArray) TO 1 STEP -1

		IF !EMPTY( aArray[nItem][1] ) .AND. DELREGVAR( hKey, cRunKey, aArray[nItem][2] )

			DO CASE
				CASE nPage == 1

					DELETE ITEM nItem FROM Grid_1 OF Form_1

					aDel( aHKLM, nItem )
					aSize( aHKLM, Len(aHKLM) - 1 )

				CASE nPage == 2

					DELETE ITEM nItem FROM Grid_2 OF Form_1

					aDel( aHKCU, nItem )
					aSize( aHKCU, Len(aHKCU) - 1 )

			ENDCASE
		ENDIF
	NEXT

	DO CASE
		CASE nPage = 1
			Form_1.Grid_1.Value := IF( Len(aHKLM) > 0, 1, 0 )

		CASE nPage = 2
			Form_1.Grid_2.Value := IF( Len(aHKCU) > 0, 1, 0 )
	ENDCASE

Return

*--------------------------------------------------------*
Static Procedure DeleteKeys( nPage )
*--------------------------------------------------------*
Local aArray, nItem, oReg, oKey, cReg := "", cName := "", nId, ;
	hKey := HKEY_LOCAL_MACHINE, ;
	cCfgKey := "Software\Microsoft\Shared Tools\MSConfig\startupreg"


	DO CASE
		CASE nPage = 1
			aArray := ACLONE(aHKLM)

		CASE nPage = 2
			aArray := ACLONE(aHKCU)
	ENDCASE

	FOR nItem := LEN(aArray) TO 1 STEP -1

		IF !EMPTY( aArray[nItem][1] )

			oReg := TReg32():New( hKey, cCfgKey )

			nId := 0
			While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

				oKey := TReg32():New( hKey, cCfgKey + "\" + cReg )

				cName := oKey:Get("item")

				IF cName == aArray[nItem][2]
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

			DELREGKEY( hKey, cCfgKey, cReg )

			DO CASE
				CASE nPage == 1

					DELETE ITEM nItem FROM Grid_1 OF Form_1

					aDel( aHKLM, nItem )
					aSize( aHKLM, Len(aHKLM) - 1 )

				CASE nPage == 2

					DELETE ITEM nItem FROM Grid_2 OF Form_1

					aDel( aHKCU, nItem )
					aSize( aHKCU, Len(aHKCU) - 1 )

			ENDCASE

		ENDIF

	NEXT

	DO CASE
		CASE nPage = 1
			Form_1.Grid_1.Value := IF( Len(aHKLM) > 0, 1, 0 )

		CASE nPage = 2
			Form_1.Grid_2.Value := IF( Len(aHKCU) > 0, 1, 0 )
	ENDCASE

Return

*--------------------------------------------------------*
STATIC FUNCTION GetRunArray( hKey )
*--------------------------------------------------------*
LOCAL aRun := {}, oReg, cName := "", cPath, nId := 0

   hKey := IF(hKey == NIL, HKEY_CURRENT_USER, hKey)

   IF EXISTREGKEY(hKey, "Software\Microsoft\Windows\CurrentVersion\Run-")

	oReg := TReg32():New( hKey, "Software\Microsoft\Windows\CurrentVersion\Run-" )

	While RegEnumValueA( oReg:nHandle, nId++, @cName ) == 0

		cPath := oReg:Get(cName)

		aAdd( aRun, { 0, cName, cPath } )

	End

	oReg:Close()

   ENDIF

RETURN ASORT(aRun, , , {|a,b| UPPER(a[2]) < UPPER(b[2])})

*--------------------------------------------------------*
Static Function GetMSConfigArray( cKey )
*--------------------------------------------------------*
Local aRet := {}, oReg, cReg := "", oKey, cName := "", cPath := "", nId := 0

   cKey := IF(cKey == NIL, "HKCU", cKey)

   oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Software\Microsoft\Shared Tools\MSConfig\startupreg" )

   While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

	oKey := TReg32():New( HKEY_LOCAL_MACHINE, "Software\Microsoft\Shared Tools\MSConfig\startupreg\" + cReg )

	cName := oKey:Get("item")
	cPath := oKey:Get("command")

	IF oKey:Get("hkey") == cKey

		aAdd( aRet, { 0, cName, cPath } )

	ENDIF

	oKey:Close()

   End

   oReg:Close()

RETURN ASORT(aRet, , , {|a,b| UPPER(a[2]) < UPPER(b[2])})

*--------------------------------------------------------*
Static Procedure ToggleRefresh( nPage, lAllToggle )
*--------------------------------------------------------*
LOCAL nActItem := GetProperty( "Form_1", "Grid_"+Ltrim(Str(nPage)), "Value" ), i

DO CASE
	CASE nPage = 1

	IF LEN(aHKLM) > 0

		IF ValType(lAllToggle) # "L"

			aHKLM[nActItem][1] := IF(aHKLM[nActItem][1] == 1, 0, 1)
			Form_1.Grid_1.Cell( This.CellRowIndex , 1 ) := aHKLM[nActItem][1]

			FOR i := 1 TO LEN(aHKLM)
				IF EMPTY(aHKLM[i][1])
					Form_1.Button_3.Enabled := .F.
					LOOP
				ELSE
					Form_1.Button_3.Enabled := .T.
					EXIT
				ENDIF
			NEXT

		ELSE
			IF lAllToggle

				FOR i := 1 TO LEN(aHKLM)
					aHKLM[i][1] := 1
					Form_1.Grid_1.Cell( i , 1 ) := aHKLM[i][1]
				NEXT

			ELSE

				FOR i := 1 TO LEN(aHKLM)
					aHKLM[i][1] := 0
					Form_1.Grid_1.Cell( i , 1 ) := aHKLM[i][1]
				NEXT

			ENDIF

			Form_1.Button_3.Enabled := lAllToggle
			Form_1.Grid_1.Value := nActItem
		ENDIF

	ENDIF

	CASE nPage = 2

	IF LEN(aHKCU) > 0

		IF ValType(lAllToggle) # "L"

			aHKCU[nActItem][1] := IF(aHKCU[nActItem][1] == 1, 0, 1)
			Form_1.Grid_2.Cell( This.CellRowIndex , 1 ) := aHKCU[nActItem][1]

			FOR i := 1 TO LEN(aHKCU)
				IF EMPTY(aHKCU[i][1])
					Form_1.Button_3.Enabled := .F.
					LOOP
				ELSE
					Form_1.Button_3.Enabled := .T.
					EXIT
				ENDIF
			NEXT

		ELSE
			IF lAllToggle

				FOR i := 1 TO LEN(aHKCU)
					aHKCU[i][1] := 1
					Form_1.Grid_2.Cell( i , 1 ) := aHKCU[i][1]
				NEXT

			ELSE

				FOR i := 1 TO LEN(aHKCU)
					aHKCU[i][1] := 0
					Form_1.Grid_2.Cell( i , 1 ) := aHKCU[i][1]
				NEXT

			ENDIF

			Form_1.Button_3.Enabled := lAllToggle
			Form_1.Grid_2.Value := nActItem
		ENDIF

	ENDIF

ENDCASE

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About", IDI_MAIN, .F. )

*--------------------------------------------------------*
Static Function GetReport()
*--------------------------------------------------------*
Local cRet := "***%20MSConfig%20Cleanup%20BugReport%20***%0A%0A"

	cRet += "OPERATING%20SYSTEM%3A" + space( 3 ) + OS() + "%0A%0A"
	cRet += "AMOUNT OF RAM (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(1) + 1 ) ) + "%0A%0A"
	cRet += "SWAP-FILE SIZE (MB)%3A" + space( 3 ) + Ltrim( Str( MemoryStatus(3) ) ) + "%0A%0A"
	cRet += "PROBLEM DESCRIPTION%3A"

Return cRet

*--------------------------------------------------------*
STATIC FUNCTION EXISTREGKEY(nKey, cRegKey)
*--------------------------------------------------------*
   LOCAL oReg, lExist

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey, .f.)
   lExist := Empty(oReg:lError)
   oReg:Close()

RETURN lExist

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():New(nKey, cRegKey, .f.)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*--------------------------------------------------------*
STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, lRet

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   oReg:Delete(cSubKey)
   lRet := (oReg:nError # -1)
   oReg:Close()

RETURN lRet

*--------------------------------------------------------*
STATIC FUNCTION DELREGKEY(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:KeyDelete(cSubKey)
   oReg:Close()

RETURN nValue


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"
#include "winreg.h"


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

#pragma ENDDUMP
