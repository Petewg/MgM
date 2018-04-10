/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Phone Base'
#define VERSION ' version 1.1'
#define COPYRIGHT ' 2003-2006 Grigory Filatov'

Static nPageNumber := 1, nItemNumber := 1, nCountryNumber := 1, lChanges := .F.
Memvar cFileName
Memvar cCountry
Memvar aRemarks, cSearch, cFind
Memvar aPhones, aCountries
Memvar aTree
Memvar aResult

*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
Local lWinRun := .F., cExeName := GetExeFileName()

PRIVATE cFileName := cFilePath( cExeName ) + "\" + cFileNoExt( cExeName ) + ".TXT"
PRIVATE cCountry := cFilePath( cExeName ) + "\" + "Country.txt"
PRIVATE aRemarks := {}, cSearch := "", cFind := ""
PRIVATE aPhones := GetPhoneArray(), aCountries := GetCountryArray()

	If LEN(aPhones) = 0
		MsgStop("Phone Base is bad or missing...", "Stop!")
		Return
	EndIf

	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "Phone Base" ))
		lWinRun := .T.
	EndIf

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 				;
		AT 0,0 					;
		WIDTH 0 HEIGHT 0 			;
		TITLE PROGRAM 				;
	        ICON 'PHONE'				;
		MAIN NOSHOW 				;
		ON INIT ( IF(lWinRun, , StartUp()) ) 	;
		NOTIFYICON 'SYSTEM' 			;
		NOTIFYTOOLTIP PROGRAM 			;
		ON NOTIFYCLICK StartUp()

		DEFINE NOTIFY MENU 
			ITEM '&Open' 	ACTION StartUp() DEFAULT
			SEPARATOR	
			ITEM 'Auto&Run'	ACTION {|| lWinRun := !lWinRun, 		;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) } 	;
				NAME Auto_Run
			SEPARATOR	
			ITEM 'A&bout...'	ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "PHONE", 32, 32) )
			ITEM 'E&xit'	ACTION Form_1.Release
		END MENU

		Form_1.Auto_Run.Checked := lWinRun

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure StartUp()
*--------------------------------------------------------*
LOCAL nItem, cItem1, cItem2, cItem3, n := 1, i := 1

PRIVATE aTree := {}

   if !IsWindowDefined( Form_2 )
	IF lChanges
		aRemarks := {}
		aPhones := GetPhoneArray()
		lChanges := .F.
	ENDIF

	DEFINE WINDOW Form_2		; 
        AT 0,0				; 
        WIDTH 430			; 
        HEIGHT IF(IsXPThemeActive(), 400, 396 )	; 
        TITLE PROGRAM			; 
        ICON 'PHONE'			;
        NOMAXIMIZE NOSIZE		; 
        FONT 'MS Sans Serif'		; 
        SIZE 9

        DEFINE TAB Tab_1 		;
		AT 7,7 			;
		WIDTH 410 		;
		HEIGHT 326 		;
		VALUE nPageNumber ;
		ON CHANGE IF(Form_2.Tab_1.Value=1, Form_2.TextBox_1.SetFocus, ;
				IF(Form_2.Tab_1.Value=2, Form_2.TextBox_2.SetFocus, ))

		PAGE '&Personal'

			@ 36, 25 LABEL Label_1						;
				VALUE "Search for:"					;
				WIDTH 80        					;
				HEIGHT 18						;
				FONT 'MS Sans Serif'					;
				SIZE 10

			@ 35,100 TEXTBOX TextBox_1 WIDTH 245 HEIGHT 20			;
				VALUE cSearch 						;
				MAXLENGTH 60						;
				ON CHANGE cSearch := Alltrim( Form_2.TextBox_1.Value )	;
				ON ENTER SearchItem( Form_2.Tab_1.Value, cSearch, .T. )	;
				FONT 'MS Sans Serif'					;
				SIZE 10							;
				TOOLTIP "Press Enter for find next"

			@ 33,354 BUTTON SearchButton 					;
				PICTURE "Search" 					;
				ACTION ( SearchItem( Form_2.Tab_1.Value, cSearch ),	;
					Form_2.TextBox_1.SetFocus )			;
				WIDTH 28 						;
				HEIGHT 24 						;
				TOOLTIP "Start of search from begin"

			DEFINE TREE Tree_1 AT 70, 15 					;
				WIDTH 380 HEIGHT 212 					;
				VALUE nItemNumber					;
				TOOLTIP 'Right click for context menu'			;
				ON DBLCLICK EditItem(Form_2.Tab_1.Value, .t.)		;
				NODEIMAGES { "close", "open" } 				;
				ITEMIMAGES { "close", "open" }

				nItem := NumToken( aPhones[1], "#" )

				WHILE n <= Len(aPhones)

					cItem1 := Token( aPhones[n], "#", 1 )

					NODE cItem1
						AADD(aTree, {aPhones[n], cItem1, "", ""})
						WHILE cItem1 = Token( aPhones[n], "#", 1 )

							if nItem > 3

								cItem2 := Token( aPhones[n], "#", 2 )

								NODE cItem2
									AADD(aTree, {aPhones[n], cItem1, cItem2, ""})
									WHILE cItem2 = Token( aPhones[n], "#", 2)

										cItem3 := Trim( Token( aPhones[n], "#", 3 ) ) + " [" + Token( aPhones[n], "#", 4 ) + "]"
										TREEITEM cItem3
										AADD(aTree, {aPhones[n], cItem1, cItem2, cItem3})
										n++
										if n > Len(aPhones)
											exit
										endif
									END
								END NODE

							else

								cItem3 := Trim( Token( aPhones[n], "#", 2 ) ) + " [" + Token( aPhones[n], "#", 3 ) + "]"
								TREEITEM cItem3
								AADD(aTree, {aPhones[n], cItem1, "", cItem3})
								n++

							endif

							if n > Len(aPhones)
								exit
							endif
						END

					END NODE
				END

			END TREE

			@ if(IsXPThemeActive(), 290, 292), 160 BUTTON Button_3 ; 
				CAPTION 'New...' ; 
				ACTION EditItem(Form_2.Tab_1.Value, .f.) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				TOOLTIP "Add a new item"

			@ if(IsXPThemeActive(), 290, 292), 241 BUTTON Button_4 ; 
				CAPTION 'Remove' ; 
				ACTION DeleteItem(Form_2.Tab_1.Value) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				TOOLTIP "Delete current item"

			@ if(IsXPThemeActive(), 290, 292), 322 BUTTON Button_5 ; 
				CAPTION 'Edit' ; 
				ACTION EditItem(Form_2.Tab_1.Value, .t.) ; 
				WIDTH 74 ; 
				HEIGHT 24 ; 
				TOOLTIP "Edit current item"

			SetHandCursor(GetControlHandle("SearchButton", "Form_2"))
			SetHandCursor(GetControlHandle("Tree_1", "Form_2"))

		END PAGE

		PAGE '&Countries'

			@ 36, 25 LABEL Label_12						;
				VALUE "Search for:"					;
				WIDTH 80        						;
				HEIGHT 18							;
				FONT 'MS Sans Serif'					;
				SIZE 10

			@ 35,100 TEXTBOX TextBox_2 WIDTH 245 HEIGHT 20		;
				VALUE cFind	 						;
				MAXLENGTH 60						;
				ON CHANGE cFind := Alltrim( Form_2.TextBox_2.Value ) ;
				ON ENTER SearchItem( Form_2.Tab_1.Value, cFind, .T. );
				FONT 'MS Sans Serif'					;
				SIZE 10							;
				TOOLTIP "Press Enter for find next"

			@ 33,354 BUTTON FindButton 					;
				PICTURE "Search" 						;
				ACTION ( SearchItem( Form_2.Tab_1.Value, cFind ), ;
					Form_2.TextBox_2.SetFocus )			;
				WIDTH 28 							; 
				HEIGHT 24 							;
				TOOLTIP "Start of search from begin"

			DEFINE TREE Tree_2 AT 70,15 					;
				WIDTH 380 HEIGHT 242 					;
				VALUE nCountryNumber					;
				TOOLTIP 'Double click for expand tree'		;
				NODEIMAGES { "close", "open" } 			;
				ITEMIMAGES { "close", "open" }

				WHILE i <= Len(aCountries)

					cItem1 := Token( aCountries[i], "#", 1 )

					NODE cItem1
						WHILE cItem1 = Token( aCountries[i], "#", 1 )

							cItem3 := Trim( Token( aCountries[i], "#", 2 ) ) + " [" + Token( aCountries[i], "#", 3 ) + "]"
							TREEITEM cItem3
							i++

							if i > Len(aCountries)
								exit
							endif
						END

					END NODE
				END

			END TREE

		END PAGE

		PAGE 'A&bout'

			@ 34, 44 LABEL Label_2		;
				VALUE PROGRAM + VERSION	;
				AUTOSIZE		;
				ACTION MsgAbout()	;
				FONT 'Arial' SIZE 22 	;
				BOLD

			@ 72, 120 LABEL Label_3		;
				VALUE "Copyright " + Chr(169) + COPYRIGHT ;
				AUTOSIZE		;
				ACTION MsgAbout()

			@ 96, 15 FRAME TabFrame_6 WIDTH 380 HEIGHT 80 OPAQUE

			@ 106, 30 LABEL Label_4		;
				VALUE "Author:   Grigory Filatov (Ukraine)" ;
				AUTOSIZE

			@ 128, 33 LABEL Label_5	;
				VALUE "E-mail:"		;
				WIDTH 36        		;
				HEIGHT 16

			@ 127, 73 HYPERLINK Link_1	;
				VALUE "gfilatov@inbox.ru" ;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Phone%20Base%20Feedback:" ;
				WIDTH 100        		;
				HEIGHT 16			;
				TOOLTIP "E-mail me if you have any comments or suggestions"

			@ 150, 37 LABEL Label_6		;
				VALUE "Bugs:" 		;
				AUTOSIZE

			@ 149, 73 HYPERLINK Link_2	;
				VALUE "report" 		;
				ADDRESS "gfilatov@inbox.ru?cc=&bcc=" + ;
					"&subject=Phone%20Base%20Bug:" + ;
					"&body=***%20Phone%20Base%20BUGREPORT%20***%0A%0A" + ;
					"OPERATING%20SYSTEM%3A%0A%0AAMOUNT OF RAM (MB)%3A%0A%0A" + ;
					"SWAP-FILE SIZE (MB)%3A%0A%0APROBLEM DESCRIPTION%3A" ;
				WIDTH 36        		;
				HEIGHT 16			;
				TOOLTIP "Send me a bug-report if you experience any problems"

			@ 120, 280 IMAGE Image_1 PICTURE iif(IsXPThemeActive(), "PHONEXP", "PHONE") ;
				WIDTH 32 HEIGHT 32 ACTION MsgAbout()

			@ 190, 15 IMAGE Image_2 PICTURE "HARBOUR" WIDTH 380 HEIGHT 120 ;
				ACTION ShellExecute(0, "open", "https://harbour.github.io/")

			SetHandCursor(GetControlHandle("Image_1", "Form_2"))

		END PAGE

        END TAB

        @ if(IsXPThemeActive(), 338, 340), 262 BUTTON Button_1 ; 
            CAPTION 'OK' ; 
            ACTION ( nPageNumber := Form_2.Tab_1.Value, nItemNumber := Form_2.Tree_1.Value, ;
			SaveBase(), Form_2.Release ) ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            TOOLTIP "Save of changes and close a window"

        @ if(IsXPThemeActive(), 338, 340), 343 BUTTON Button_2 ; 
            CAPTION 'Cancel' ; 
            ACTION ReleaseAllWindows() ; 
            WIDTH 74 ; 
            HEIGHT 24 ; 
            TOOLTIP "Exit from program without saving of changes"

		DEFINE CONTEXT MENU 
			ITEM '&New...'	ACTION EditItem(Form_2.Tab_1.Value, .f.)
			ITEM '&Edit...'	ACTION EditItem(Form_2.Tab_1.Value, .t.)
			ITEM '&Remove' 	ACTION DeleteItem(Form_2.Tab_1.Value)
		END MENU

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

   Else

	nPageNumber := Form_2.Tab_1.Value
	nItemNumber := Form_2.Tree_1.Value
	nCountryNumber := Form_2.Tree_2.Value
	Form_2.Release

   EndIf

Return

*--------------------------------------------------------*
Static Procedure SaveBase()
*--------------------------------------------------------*
LOCAL cStrings := "", nCnt

	IF lChanges
		For nCnt := 1 To Len(aRemarks)
			cStrings += aRemarks[nCnt] + CRLF
		Next

		For nCnt := 1 To Len(aTree)
			IF !EMPTY(aTree[nCnt][4])
				cStrings += aTree[nCnt][1] + CRLF
			ENDIF
		Next

		MemoWrit(cFileName, cStrings)
	ENDIF

Return

*--------------------------------------------------------*
Static Procedure SearchItem(nPage, cNameItem, lCont)
*--------------------------------------------------------*
LOCAL nItems, i, cItem, nret := 0

	DEFAULT lCont TO .F.

	nItems := GetProperty( "Form_2", "Tree_"+Ltrim(Str(nPage)), "ItemCount" )
	for i := IF(lCont, GetProperty( "Form_2", "Tree_"+Ltrim(Str(nPage)), "Value" ) + 1, 1) to nItems 
		cItem := _GetItem( "Tree_"+Ltrim(Str(nPage)), "Form_2", i )
		if UPPER(cNameItem) $ UPPER(cItem)
			nret := i
			EXIT
		endif
	next i

	if empty(nret)
		PlayBeep()
	else
		SetProperty( "Form_2", "Tree_"+Ltrim(Str(nPage)), "Value", nret )
	endif

Return

*--------------------------------------------------------*
Static Procedure EditItem(nPage, lExist)
*--------------------------------------------------------*
LOCAL nActItem, cItem, aLabels, aInitValues := { "", "" }, aFormats, aResults

   IF nPage < 2

	nActItem := GetProperty( "Form_2", "Tree_"+Ltrim(Str(nPage)), "Value" )

	IF !EMPTY(nActItem) .AND. AT("[", ( cItem := Form_2.Tree_1.Item( nActItem ) )) > 0

		IF lExist

			aInitValues[1]	:= Trim( Token( cItem, "[", 1 ) )
			aInitValues[2]	:= Substr( Token( cItem, "[", 2 ), 1, Len( Token( cItem, "[", 2 ) ) - 1 )

		ENDIF

		aLabels 	:= { "Description:", "Phone:" }

		aFormats 	:= { 60, 60 }

		aResults 	:= MyInputWindow( "Phone Properties", aLabels, aInitValues, aFormats )

		IF !_HMG_DialogCancelled

			lChanges := .T.

			IF lExist
				IF NumToken( aTree[nActItem][1], "#" ) > 3
					aTree[nActItem][1] := Token( aTree[nActItem][1], "#", 1 ) + "#" + Token( aTree[nActItem][1], "#", 2 ) + "#"  + aResults[1] + " #"  + aResults[2]
				ELSE
					aTree[nActItem][1] := Token( aTree[nActItem][1], "#", 1 ) + "#" + aResults[1] + "#"  + aResults[2]
				ENDIF
				aTree[nActItem][4] := aResults[1] + " [" + aResults[2] + "]"
				Form_2.Tree_1.Item( nActItem ) := aTree[nActItem][4]

			ELSE

				IF NumToken( aTree[nActItem][1], "#" ) > 3
					AADD(aTree, { Token( aTree[nActItem][1], "#", 1 ) + "#" + Token( aTree[nActItem][1], "#", 2 ) + "#"  + aResults[1] + " #"  + aResults[2], ;
						Token( aTree[nActItem][1], "#", 1 ), Token( aTree[nActItem][1], "#", 2 ), aResults[1] + " [" + aResults[2] + "]" })
				ELSE
					AADD(aTree, { Token( aTree[nActItem][1], "#", 1 ) + "#"  + aResults[1] + "#"  + aResults[2], ;
						Token( aTree[nActItem][1], "#", 1 ), "", aResults[1] + " [" + aResults[2] + "]" })
				ENDIF
				cItem := ATAIL(aTree)
				AINS(aTree, nActItem + 1)
				aTree[nActItem + 1] := cItem
				Form_2.Tree_1.AddItem( aResults[1] + " [" + aResults[2] + "]", nActItem - 1 )

			ENDIF

		ENDIF

	ENDIF

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure DeleteItem(nPage)
*--------------------------------------------------------*
LOCAL nActItem

IF nPage < 2

   nActItem := Form_2.Tree_1.Value

   IF !EMPTY(nActItem) .AND. AT("[", Form_2.Tree_1.Item( nActItem )) > 0

		IF MsgYesNo( "Are you sure you want to remove the selected item?", "Confirm" )

			lChanges := .T.

			Form_2.Tree_1.DeleteItem( Form_2.Tree_1.Value )
			Form_2.Tree_1.Value := IF(nActItem > 1, nActItem - 1, nActItem)
			ADEL(aTree, nActItem)
			ASIZE(aTree, LEN(aTree)-1)

		ENDIF

	ENDIF

   ENDIF

Return

*--------------------------------------------------------*
STATIC FUNCTION GetPhoneArray()
*--------------------------------------------------------*
LOCAL aPhone := {}, cLine, oFile

	IF FILE( cFileName )

		oFile := TFileRead():New( cFileName )

		oFile:Open()

		IF oFile:Error()

			MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
		ELSE
			WHILE oFile:MoreToRead()
				cLine := oFile:ReadLine()
				IF SUBSTR(cLine, 1, 1) # "$" .AND. !EMPTY(SUBSTR(cLine, 1, 1)) .AND. AT(CHR(26), cLine) = 0
					AADD(aPhone, cLine)
				ELSEIF AT(CHR(26), cLine) = 0
					AADD(aRemarks, cLine)
				ENDIF
			END WHILE

			oFile:Close()
		ENDIF 
	ENDIF

RETURN ASORT(aPhone, , , {|a,b| UPPER(a) < UPPER(b)})

*--------------------------------------------------------*
STATIC FUNCTION GetCountryArray()
*--------------------------------------------------------*
LOCAL aCountry := {}, cLine, oFile

	IF FILE( cCountry )

		oFile := TFileRead():New( cCountry )

		oFile:Open()

		IF oFile:Error()

			MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
		ELSE
			WHILE oFile:MoreToRead()
				cLine := oFile:ReadLine()
				IF SUBSTR(cLine, 1, 1) # "$" .AND. !EMPTY(SUBSTR(cLine, 1, 1)) .AND. AT(CHR(26), cLine) = 0
					AADD(aCountry, cLine)
				ENDIF
			END WHILE

			oFile:Close()
		ENDIF 
	ENDIF

RETURN ASORT(aCountry, , , {|a,b| UPPER(a) < UPPER(b)})

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 40) + CRLF + ;
	padc("Copying is allowed!", 42), "About", , .F. )

*--------------------------------------------------------*
Static Procedure WinRun( lMode )
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "Phone Base" )

   if IsWinNT()
      EnablePermissions()
   endif

   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "Phone Base", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "Phone Base" )
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
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

RETURN nValue

*--------------------------------------------------------*
STATIC FUNCTION NumToken( cString, cDelimiter )
*--------------------------------------------------------*
   LOCAL x
   LOCAL nStrLen    := len( cString )
   LOCAL nHowMany   := 0
   LOCAL lFoundWord := .F.

   FOR x := 1 TO nStrLen
      IF SUBSTR( cString, x, 1 ) $ cDelimiter
         IF lFoundWord
            nHowMany++
         ENDIF
         DO WHILE x < nStrLen .and. SUBSTR( cString, x + 1, 1 ) $ cDelimiter
            x++
         ENDDO
      ELSE
         lFoundWord := .T.
      ENDIF
   NEXT

   if nStrLen > 0
      nHowMany := IF( RIGHT( cString, 1 ) $ cDelimiter, nHowMany, nHowMany + 1 )
   endif

RETURN nHowMany

*--------------------------------------------------------*
STATIC FUNCTION Token( cStr, cDelim, nToken )
*--------------------------------------------------------*
   LOCAL nPos
   LOCAL cToken
   LOCAL nCounter := 1

   DEFAULT nToken TO 1

   WHILE .T.

      IF ( nPos := At( cDelim, cStr ) ) == 0

         IF nCounter == nToken
            cToken := cStr
         ENDIF

         EXIT

      ENDIF

      IF ++ nCounter > nToken
         cToken := LEFT( cStr, nPos - 1 )
         EXIT
      ENDIF

      cStr := Substr( cStr, nPos + 1 )

   ENDDO

RETURN cToken

*--------------------------------------------------------*
Function MyInputWindow( Title, aLabels, aValues, aFormats )
*--------------------------------------------------------*
Local i , l , ControlRow , LN , CN

	l := Len( aLabels )

	Private aResult[l]

	DEFINE WINDOW _MyInputWindow;
		AT 0,0 ;
		WIDTH 410 ;
		HEIGHT (l*30) + 80 ;
		TITLE Title ;
		ICON "SYSTEM" ;
		MODAL ;
		NOSIZE ;
		FONT "MS Sans Serif" SIZE 10

		ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T. , _MyInputWindowCancel() )

		ControlRow :=  10

		For i := 1 to l

			LN := 'Label_' + Ltrim(Str(i))
			CN := 'Control_' + Ltrim(Str(i))

			@ ControlRow + 3, 10 LABEL &LN VALUE aLabels[i] ;
				AUTOSIZE ;
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
						ON ENTER _MyEnterMove()

					ControlRow := ControlRow + 30
				EndIf

			endcase

		Next i

		@ ControlRow + 8, 230 BUTTON BUTTON_1 ;
			CAPTION '&OK' ;
			ACTION ( _HMG_DialogCancelled := .F. , _MyInputWindowOk() ) ;
			WIDTH 74 ;
			HEIGHT 24 ;
			FONT "MS Sans Serif" SIZE 9

		@ ControlRow + 8, 312 BUTTON BUTTON_2 ;
			CAPTION '&Cancel' ;
			ACTION ( _HMG_DialogCancelled := .T. , _MyInputWindowCancel() ) ;
			WIDTH 74 ;
			HEIGHT 24 ;
			FONT "MS Sans Serif" SIZE 9

		_MyInputWindow.Control_1.SetFocus

	END WINDOW

	CENTER WINDOW _MyInputWindow

	ACTIVATE WINDOW _MyInputWindow

Return ( aResult )

*--------------------------------------------------------*
Function _MyInputWindowOk()
*--------------------------------------------------------*
Local i , ControlName , l 

	l := len (aResult)

	For i := 1 to l

		ControlName := 'Control_' + Alltrim ( Str ( i ) )
		aResult [i] := _MyInputWindow.&ControlName..Value

	Next i

	RELEASE WINDOW _MyInputWindow

Return Nil

*--------------------------------------------------------*
Function _MyInputWindowCancel()
*--------------------------------------------------------*
Local i , l

	l := len (aResult)

	For i := 1 to l

		aResult [i] := Nil

	Next i

	RELEASE WINDOW _MyInputWindow

Return Nil

*--------------------------------------------------------*
Function _MyEnterMove()
*--------------------------------------------------------*
Local ControlName := This.Name
Local nControl := Val( SubStr( ControlName, At("_", ControlName) + 1 ) )

	if nControl = 1
		_MyInputWindow.Control_2.SetFocus
	else
		_MyInputWindow.BUTTON_1.SetFocus
	endif

Return Nil


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

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

#ifdef __XHARBOUR__
  #include <fileread.prg>
#endif
