/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2012 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "winprint.ch"
#include "fileio.ch"

#define PROGRAM 'SysInfo for Win9x/2K/XP'
#define VERSION ' version 1.10'
#define COPYRIGHT ' 2003-2012 Grigory Filatov'

#define NTRIM( n ) hb_ntos( n )

Static aCaption := { "Computer:", ;
			"Processor:", ;
			"Bios:", ;
			"Motherboard:", ;
			"RAM:", ;
			"Hard disks:", ;
			"Removed disks:", ;
			"CD-ROM:", ;
			"Video card:", ;
			"Sound card:", ;
			"Network card:", ;
			"KeyBoard:", ;
			"Mouse:", ;
			"Monitor:", ;
			"Modem:", ;
			"Printers:", ;
			"IP address:", ;
			"OS:", ;
			"Notes:" ;
			}

Static aValue, lWinNT
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
	Local n, cDrv, nDrv, hbprn, aPrinters, aPorts, cPrnString := "", ;
	Brush_1, nCnt, cLbl, cText, aHardDisk := {}, nTotal := 0, nFree := 0, ;
	nTotalMemory := MemoryStatus(1) + 1, aWinVer := WindowsVersion()

	SET DATE GERMAN
	SET CENTURY ON

	aValue := Array( Len(aCaption) )
	lWinNT := IsWinNT()

	Afill(aValue, "")

	aValue[1] := ComputerName() + " (" + RegisteredName() + ")"
	IF lWinNT
		aValue[1] += " - " + IF(IsAdmin(), "Administrator", "Guest")
	ENDIF

	aValue[2] := CPUName() + " " + IF(lWinNT, "[~", "") + NTRIM( GetCPUSpeed() ) + " MHz" + IF(lWinNT, "]", "")
	aValue[3] := BiosName()

	IF !lWinNT
		aValue[4] := SubStr( cBiosSignOn(), 12 )
	ENDIF

	aValue[5] := NTRIM( nTotalMemory ) + " MB (" + NTRIM( nTotalMemory * 1024 ) + " KB" + ")"

	For n := 1 To 26

		cDrv := Chr( 64 + n ) + ":"

		nDrv := GetDriveType( cDrv + "\" + Chr(0) )

		if nDrv = 3
			Aadd( aHardDisk, cDrv )
		elseif nDrv = 2
			aValue[7] += cDrv + " "
		elseif nDrv = 5
			aValue[8] += cDrv + " " + CDROMName( cDrv )
		endif

	Next

	aValue[6] := {}

	DO EVENTS

	Aeval( aHardDisk, {|e| Aadd( aValue[6], e + " " + ;
		NTRIM(HB_DISKSPACE(e, HB_DISK_TOTAL) / (1024 * 1024)) + " MB (free " + ;
		NTRIM(HB_DISKSPACE(e, HB_DISK_FREE) / (1024 * 1024)) + " MB - " + ;
		NTRIM(INT( HB_DISKSPACE(e, HB_DISK_FREE) / HB_DISKSPACE(e, HB_DISK_TOTAL) * 100 )) + "%)" )})

	Aeval( aHardDisk, {|e| nTotal += (HB_DISKSPACE(e, HB_DISK_TOTAL) / (1024 * 1024)), ;
		nFree += (HB_DISKSPACE(e, HB_DISK_FREE) / (1024 * 1024))} )

	Aadd( aValue[6], Repl("-", 100) )
	Aadd( aValue[6], LTRIM(HDDName() + " ") + NTRIM(nTotal) + " MB (free " + NTRIM(nFree) + " MB - " + ;
		NTRIM(INT( nFree / nTotal * 100 )) + "%)" )

	aValue[9]  := VideoName()
	aValue[10] := SoundName()
	aValue[11] := NetworkName()
	aValue[12] := KeybdName()
	aValue[13] := MouseName()
	aValue[14] := MonitorName() + ", " + DisplayCurrentMode()
	aValue[15] := ModemName()

	INIT PRINTSYS
	GET PRINTERS TO aPrinters
	GET PORTS TO aPorts
	RELEASE PRINTSYS

	aValue[16] := {}

	IF LEN(aPrinters) > 0
		For n := 1 To Len(aPrinters)
			Aadd( aValue[16], aPrinters[n] + " (" + ;
				IF( lWinNT, "", IF( LEFT(aPorts[n], 2) == "\\", "remote ", "local " ) ) + aPorts[n] + ")" )
		Next

		Aeval( aPrinters, {|e| cPrnString += e + "   "} )

		Aadd( aValue[16], Repl("-", 100) )
		Aadd( aValue[16], cPrnString )
	ENDIF

	aValue[17] := IPInfo()
	aValue[18] := "Microsoft " + ALLTRIM( aWinVer[1] ) + " " + ALLTRIM( aWinVer[2] ) + " (" + aWinVer[3] + ")"

	SET NAVIGATION EXTENDED

	DEFINE WINDOW Form_1					;
		AT 0,0						;
		WIDTH 453					;
		HEIGHT IF(IsXPThemeActive(), 518, 512 )		; 
		TITLE PROGRAM					;
		MAIN						;
		ICON 'MAIN'					;
		NOMAXIMIZE NOSIZE				;
		ON INIT ( InitDraw(), PaintMessage() )		;
		ON GOTFOCUS ( IF(lWinNT, InitDraw(), ),		;
			PaintMessage() )			;
		BACKCOLOR {216, 216, 216}			;
		FONT 'MS Sans Serif'				;
		SIZE 9

		@ 0,0 ANIMATEBOX Avi_1				;
			WIDTH 106				;
			HEIGHT 40				;
			FILE 'COOL' AUTOPLAY

	       @ 6,86 LABEL Label_1				;
			VALUE PROGRAM + VERSION			;
			BACKCOLOR WHITE				;
			AUTOSIZE

		@ 5, 316 HYPERLINK Label_2				;
			VALUE "gfilatov@inbox.ru"			;
			ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +		;
				"&subject=System%20Info%20Feedback:";
			BACKCOLOR WHITE					;
			WIDTH 100 HEIGHT 14 HANDCURSOR			;
			TOOLTIP "E-mail me if you have any comments or suggestions"

	       @ 22,86 LABEL Label_3					;
			VALUE "Copyright "+ Chr(169) + COPYRIGHT +;
				". All rights reserved"			;
			BACKCOLOR WHITE					;
			WIDTH 300 HEIGHT 14

		For nCnt := 1 To Len(aCaption)

			cLbl := 'Lbl_' + NTRIM(nCnt)
			@ 50 + (nCnt - 1) * 20, 6 LABEL &cLbl		;
				VALUE aCaption[nCnt]			;
				AUTOSIZE TRANSPARENT

			cText := 'Text_' + NTRIM(nCnt)
			IF nCnt == Len(aCaption)
				@ 48 + (nCnt - 1) * 20, 85 EDITBOX &cText		;
					HEIGHT 72					;
					WIDTH 356					;
					VALUE aValue[nCnt]				;
					ON CHANGE OnTextChange()

			ELSEIF nCnt == 6 .OR. nCnt == 16
				@ 48 + (nCnt - 1) * 20, 85 COMBOBOX &cText		;
					HEIGHT 120					;
					WIDTH 356					;
					ITEMS aValue[nCnt]				;
					VALUE Len( aValue[nCnt] )
			ELSE
				@ 48 + (nCnt - 1) * 20, 85 TEXTBOX &cText		;
					HEIGHT 19					;
					WIDTH 356					;
					VALUE aValue[nCnt]				;
					ON CHANGE OnTextChange()
			ENDIF
		Next

		@ 454, 12 BUTTON Button_1			;
			PICTURE 'PRINT'				;
			ACTION RepToPrinter()			;
			WIDTH 24				;
			HEIGHT 24				;
			TOOLTIP "Print... (Ctrl+P)"		;
			FLAT NOTABSTOP

		@ 454, 48 BUTTON Button_2			;
			PICTURE 'SAVE'				;
			ACTION RepToDisk()			;
			WIDTH 24				;
			HEIGHT 24				;
			TOOLTIP "Save... (Ctrl+S)"		;
			FLAT NOTABSTOP

		ON KEY ALT+X ACTION ReleaseAllWindows()
		ON KEY CONTROL+P ACTION RepToPrinter()
		ON KEY CONTROL+S ACTION RepToDisk()

	END WINDOW

	DEFINE BKGBRUSH Brush_1 PATTERN IN Form_1 BITMAP Skin\background.bmp

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

RETURN

*--------------------------------------------------------*
Static proc OnTextChange()
*--------------------------------------------------------*
Local cItem := This.Name
Local nItem := Val( SubStr( cItem, At("_", cItem) + 1 ) )
Local cText := 'Text_' + NTRIM( nItem )

aValue[nItem] := GetProperty( "Form_1", cText, "Value" )

RETURN

*--------------------------------------------------------*
Static proc RepToPrinter()
*--------------------------------------------------------*
Local cTitle := PROGRAM + VERSION, n, i, nRow := 24

	INIT PRINTSYS

	SELECT BY DIALOG 

	IF HBPRNERROR != 0 
		RETURN
	ENDIF

	SET UNITS MM    		// Sets @... units to milimeters
	SET PAPERSIZE DMPAPER_A4	// Sets paper size to A4
	SET ORIENTATION PORTRAIT	// Sets paper orientation to portrait
	SET BIN DMBIN_FIRST		// Use first bin

	DEFINE FONT "Courier" NAME "Courier New" SIZE 10

	START DOC NAME Left(PROGRAM, 7)

		START PAGE

			@ 14, 18 SAY cTitle ;
				FONT "Courier" ;
				TO PRINT

			@ 14, 160 SAY DtoC(Date()) + " " + Left(Time(), 5) ;
				FONT "Courier" ;
				TO PRINT

			@ 20, 16, 200, 196 RECTANGLE

			For n := 1 To Len(aValue)

				IF Valtype(aValue[n]) == "C"

					@ nRow, 18 SAY aCaption[n] ;
						FONT "Courier" ;
						TO PRINT
					@ nRow, 50 SAY aValue[n] ;
						FONT "Courier" ;
						TO PRINT
					nRow += 6

				ELSEIF Valtype(aValue[n]) == "A"

					@ nRow, 18 SAY aCaption[n] ;
						FONT "Courier" ;
						TO PRINT

					IF n == 6
						@ nRow, 50 SAY ATAIL(aValue[n]) ;
							FONT "Courier" ;
							TO PRINT
						nRow += 6
					ENDIF

					For i := 1 To Len(aValue[n]) - 2
						@ nRow, IF( n == 6, 60, 50) SAY aValue[n][i] ;
							FONT "Courier" ;
							TO PRINT
						nRow += 6
					Next
				ENDIF
			Next

		END PAGE

	END DOC

	RELEASE PRINTSYS

RETURN

*--------------------------------------------------------*
Static proc RepToDisk()
*--------------------------------------------------------*
Local cTxt := PROGRAM + VERSION + CRLF, n
Local cFileName := Putfile( { {"Text Files", "*.txt"}, {"All Files", "*.*"} }, "Save to File", ".\", .t. )

	IF !Empty( cFileName )
		cTxt += Repl("-", 70) + CRLF

		For n := 1 To Len(aValue)
			IF Valtype(aValue[n]) == "C"
				cTxt += padr(aCaption[n], 17) + aValue[n] + CRLF
			ELSEIF Valtype(aValue[n]) == "A"
				IF LEN(aValue[n]) > 0
					cTxt += padr(aCaption[n], 17) + ATAIL( aValue[n] ) + CRLF
					Aeval(aValue[n], {|e,i| IF(i < Len(aValue[n]) - 1, cTxt += space(22) + e + CRLF, )})
				ELSE
					cTxt += padr(aCaption[n], 17) + CRLF
				ENDIF
			ENDIF
		Next

		cTxt += Repl("-", 70) + CRLF
		cTxt += CDOW(Date()) + ", " + DtoC(Date()) + " " + Left(Time(), 5) + CRLF

		Memowrit( IF(AT(".", cFileName) > 0, cFileName, cFileName + ".txt") , cTxt )
	ENDIF

RETURN

*--------------------------------------------------------*
Static proc InitDraw()
*--------------------------------------------------------*
	DRAW RECTANGLE IN WINDOW Form_1 AT 0,63 ;
		TO 41,447 ;
		PENCOLOR BLACK ;
		FILLCOLOR WHITE
RETURN

*--------------------------------------------------------*
Static proc PaintMessage()
*--------------------------------------------------------*
	Form_1.Label_1.Value := PROGRAM + VERSION
	Form_1.Label_2.Value := "gfilatov@inbox.ru"
	Form_1.Label_3.Value := "Copyright "+ Chr(169) + COPYRIGHT + ". All rights reserved"
RETURN

*--------------------------------------------------------*
Function ComputerName()
*--------------------------------------------------------*
return GetRegVar( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName", "Computername" )

*--------------------------------------------------------*
Function RegisteredName()
*--------------------------------------------------------*
Local cName := ""

IF lWinNT
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion", "RegisteredOrganization" )
ELSE
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows\CurrentVersion", "RegisteredOrganization" )
ENDIF

return cName

*--------------------------------------------------------*
Function CPUName()
*--------------------------------------------------------*
Local cName := ""

IF lWinNT
	cName := Ltrim( GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString" ) )
ELSE
	cName := GetCPU()
ENDIF

return cName

*--------------------------------------------------------*
Function BiosName()
*--------------------------------------------------------*
Local cName

IF lWinNT
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System", "SystemBiosVersion" ) + " (" + ;
		GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System", "SystemBiosDate" ) + ")"
ELSE
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "Enum\Root\*PNP0C01\0000", "BIOSVersion" ) + " (" + ;
		GetRegVar( HKEY_LOCAL_MACHINE, "Enum\Root\*PNP0C01\0000", "BIOSDate" ) + ")"
ENDIF

return cName

*--------------------------------------------------------*
Function VideoName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", oKey, nId := 0

IF lWinNT
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000", "DriverDesc" )
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Display" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Display\" + cReg )

		cName := oKey:Get( "DriverDesc" )

		oKey:Close()

	ENDDO

	oReg:Close()

	nId := 0

	WHILE EMPTY(cName) .OR. AT( "VGA", cName ) > 0
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Display\" + StrZero(nId++, 4), "DriverDesc" )
		IF nId > 99
			EXIT
		ENDIF
	ENDDO
ENDIF

return cName

*--------------------------------------------------------*
Function SoundName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", cReg1 := "", oKey, oKey1, nId := 0, nId1 := 0, cClass

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96C-E325-11CE-BFC1-08002BE10318}", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
		IF Len(cReg) == 4

			oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96C-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1++, 4), .f. )

			cName := oKey:Get( "DriverDesc" )

			oKey1 := TReg32():New( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96C-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1 - 1, 4) + "\Drivers", .f. )

			IF !Empty( oKey1:Get( "SubClasses" ) )
				oKey1:Close()
				oKey:Close()
				EXIT
			ENDIF

			oKey:Close()
		ENDIF
	ENDDO

	oReg:Close()
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\PCI" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\PCI\" + cReg )

		While RegEnumKey( oKey:nHandle, nId1++, @cReg1 ) == 0

			oKey1 := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\PCI\" + cReg + "\" + cReg1 )

			cClass := oKey1:Get("Class")

			IF cClass == "MEDIA"
				cName := oKey1:Get("DeviceDesc")
				oKey1:Close()
				EXIT
			ENDIF

			oKey1:Close()

			IF nId > 99
				EXIT
			ENDIF
		EndDo

		oKey:Close()

		IF !EMPTY(cName)
			EXIT
		ENDIF

		nId1 := 0
	EndDo

	oReg:Close()
ENDIF

return cName

*--------------------------------------------------------*
Function NetworkName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", oKey, nId := 0, nId1 := 0

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
		IF Len(cReg) == 4

			oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1++, 4), .f. )

			cName := oKey:Get( "DriverDesc" )

			IF !Empty( oKey:Get( "AdapterModel" ) )
				oKey:Close()
				EXIT
			ENDIF

			oKey:Close()

		ENDIF
	ENDDO

	oReg:Close()
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Net" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Net\" + cReg )

		cName := oKey:Get( "DriverDesc" )

		oKey:Close()

	ENDDO

	oReg:Close()

ENDIF

return cName

*--------------------------------------------------------*
Function KeybdName()
*--------------------------------------------------------*
Local cName := "", nId := 0

IF lWinNT
	cName := GetRegVar( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}\0000", "DriverDesc" )
ELSE
	IF GetRegVar( HKEY_LOCAL_MACHINE, "Enum\ACPI\*PNP0303\0", "Class" ) == "Keyboard"
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "Enum\ACPI\*PNP0303\0", "DeviceDesc" )
	ENDIF

	WHILE EMPTY(cName) .AND. GetRegVar( HKEY_LOCAL_MACHINE, "Enum\BIOS\*PNP0303\" + StrZero(nId++, 2), "Class" ) # "Keyboard"
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "Enum\BIOS\*PNP0303\" + StrZero(nId, 2), "DeviceDesc" )
		IF nId > 99
			EXIT
		ENDIF
	ENDDO
ENDIF

return cName

*--------------------------------------------------------*
Function MouseName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", oKey, nId := 0, nId1 := 0

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96F-E325-11CE-BFC1-08002BE10318}", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
		IF Len(cReg) == 4

			oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96F-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1++, 4), .f. )

			cName := oKey:Get( "DriverDesc" )

			oKey:Close()
		ENDIF
	ENDDO

	oReg:Close()
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Mouse" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Mouse\" + cReg )

		cName := oKey:Get( "DriverDesc" )

		oKey:Close()

	ENDDO

	oReg:Close()

	nId := 0

	WHILE EMPTY(cName)
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Mouse\" + StrZero(nId++, 4), "DriverDesc" )
		IF nId > 99
			EXIT
		ENDIF
	ENDDO
ENDIF

return cName

*--------------------------------------------------------*
Function MonitorName()
*--------------------------------------------------------*
Local cName := "", oReg, cReg := "", oKey, nId := 0, nId1 := 0

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96E-E325-11CE-BFC1-08002BE10318}", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
		IF Len(cReg) == 4

			oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96E-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1++, 4), .f. )

			cName := oKey:Get( "DriverDesc" )

			oKey:Close()
		ENDIF
		IF !EMPTY(cName)
			EXIT
		ENDIF
	ENDDO

	oReg:Close()
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Monitor" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Monitor\" + cReg )

		cName := oKey:Get( "DriverDesc" )

		oKey:Close()
/*
		IF !EMPTY(cName)
			EXIT
		ENDIF
*/
	ENDDO

	oReg:Close()

	nId := 0

	WHILE EMPTY(cName) .OR. AT( "Plug", cName ) > 0
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Monitor\" + StrZero(nId++, 4), "DriverDesc" )
		IF nId > 99
			EXIT
		ENDIF
	ENDDO

ENDIF

return cName

*--------------------------------------------------------*
Function ModemName()
*--------------------------------------------------------*
Local oReg, cReg := "", oKey, nId := 0, nId1 := 0, cName := "", cClass

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96D-E325-11CE-BFC1-08002BE10318}", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
		IF Len(cReg) == 4

			oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Control\Class\{4D36E96D-E325-11CE-BFC1-08002BE10318}\" + StrZero(nId1++, 4), .f. )

			cName := oKey:Get( "DriverDesc" )

			oKey:Close()
		ENDIF
		IF !EMPTY(cName)
			EXIT
		ENDIF
	ENDDO

	oReg:Close()
ELSE
	WHILE EMPTY(cName)
		cName := GetRegVar( HKEY_LOCAL_MACHINE, "System\CurrentControlSet\Services\Class\Modem\" + StrZero(nId++, 4), "DriverDesc" )
		IF nId > 99
			EXIT
		ENDIF
	ENDDO

	IF EMPTY(cName)

		nId := 0

		oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\Root\MDMGEN" )

		While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

			oKey := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\Root\MDMGEN\" + cReg )

			cClass := oKey:Get("Class")

			IF cClass == "Modem"
				cName := oKey:Get("DeviceDesc")
			ENDIF

			oKey:Close()

			IF !EMPTY(cName)
				EXIT
			ENDIF

		EndDo

		oReg:Close()

	ENDIF
ENDIF

return cName

*--------------------------------------------------------*
Function IPInfo()
*--------------------------------------------------------*
Local cIP := "0.0.0.0"

If WSAStartUp() == 0
	cIP := GetHostByName( GetHostName() )
	WSACleanUp()
Endif

return cIP

*--------------------------------------------------------*
Function CDROMName(cDrive)
*--------------------------------------------------------*
Local oReg, cReg := "", cReg1 := "", oKey, oKey1, nId := 0, nId1 := 0, cName := "", cClass, cNameDrive

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE\" + cReg, .f. )

		While RegEnumKey( oKey:nHandle, nId1++, @cReg1 ) == 0

			oKey1 := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE\" + cReg + "\" + cReg1, .f. )

			cClass := oKey1:Get("Class")

			IF cClass == "CDROM"
				cName := oKey1:Get("FriendlyName")
				oKey1:Close()
				EXIT
			ENDIF

			oKey1:Close()
		EndDo

		oKey:Close()

		IF !EMPTY(cName)
			EXIT
		ENDIF

		nId1 := 0
	EndDo

	oReg:Close()
ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI\" + cReg )

		While RegEnumKey( oKey:nHandle, nId1++, @cReg1 ) == 0

			oKey1 := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI\" + cReg + "\" + cReg1 )

			cClass := oKey1:Get("Class")
			cNameDrive := oKey1:Get("CurrentDriveLetterAssignment")

			IF cClass == "CDROM" .AND. cNameDrive $ cDrive
				cName := oKey1:Get("DeviceDesc")
				oKey1:Close()
				EXIT
			ENDIF

			oKey1:Close()

		EndDo

		oKey:Close()

		IF !EMPTY(cName)
			EXIT
		ENDIF

		nId1 := 0
	EndDo

	oReg:Close()
ENDIF

return cName

*--------------------------------------------------------*
Function HDDName()
*--------------------------------------------------------*
Local oReg, cReg := "", cReg1 := "", oKey, oKey1, nId := 0, nId1 := 0, cName := "", cClass, cNameDrive := ""

IF lWinNT
	oReg := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE", .f. )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE\" + cReg, .f. )

		While RegEnumKey( oKey:nHandle, nId1++, @cReg1 ) == 0

			oKey1 := TReg32():Create( HKEY_LOCAL_MACHINE, "SYSTEM\CurrentControlSet\Enum\IDE\" + cReg + "\" + cReg1, .f. )

			cClass := oKey1:Get("Class")

			IF cClass == "DiskDrive"
				cName := oKey1:Get("FriendlyName")
				oKey1:Close()
				EXIT
			ENDIF

			oKey1:Close()

		EndDo

		oKey:Close()
/*
		IF !EMPTY(cName)
			EXIT
		ENDIF
*/
		nId1 := 0
	EndDo

	oReg:Close()

ELSE
	oReg := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI" )

	While RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0

		oKey := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI\" + cReg )

		While RegEnumKey( oKey:nHandle, nId1++, @cReg1 ) == 0

			oKey1 := TReg32():New( HKEY_LOCAL_MACHINE, "Enum\SCSI\" + cReg + "\" + cReg1 )

			cClass := oKey1:Get("Class")
			cNameDrive := oKey1:Get("CurrentDriveLetterAssignment")

			IF cClass == "DiskDrive" .AND. "C" $ cNameDrive
				cName := oKey1:Get("DeviceDesc")
				oKey1:Close()
				EXIT
			ENDIF

			oKey1:Close()

		EndDo

		oKey:Close()

		IF !EMPTY(cName)
			EXIT
		ENDIF

		nId1 := 0
	EndDo

	oReg:Close()
ENDIF

return ALLTRIM(cName)

*--------------------------------------------------------*
static FUNCTION cBios_( nFunction, nBytes )
*--------------------------------------------------------*
   local n, nPeek, cBiosInfo := ""

   For n := 0 To nBytes - 1

      If ( nPeek := PeekByte( nFunction, n ) ) < 32
           Exit
      End

      cBiosInfo += Chr( nPeek )

   Next

RETURN cBiosInfo

#define BIOS_TYPE       1040481
#define BIOS_OEM_SIGNON 1040577
#define BIOS_SIGNON     1043569
#define BIOS_ID         1043592
#define BIOS_DATE       1048565

*--------------------------------------------------------*
FUNCTION cBiosSignOn()
*--------------------------------------------------------*
RETURN cBios_( BIOS_SIGNON, 37 )

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue := ""

   DEFAULT nKey := HKEY_CURRENT_USER
   DEFAULT uValue := ""

   oReg := TReg32():Create(nKey, cRegKey, .f.)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue

*-----------------------------------------------------------------------------*
function drawrect(window,row,col,row1,col1,penrgb,penwidth,fillrgb)
*-----------------------------------------------------------------------------*
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i] , fill

if formhandle > 0

   if valtype(penrgb) == "U"
      penrgb = {0,0,0}
   endif

   if valtype(penwidth) == "U"
      penwidth = 1
   endif

   if valtype(fillrgb) == "U"
      fillrgb := {255,255,255}
      fill := .f.
   else
      fill := .t.   
   endif

   rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill)

   aadd ( _HMG_aFormGraphTasks [i] , { || rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill) } )

endif

return nil


#pragma BEGINDUMP

#include <windows.h>

#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#endif

/* Returns one of these:
#define DRIVE_UNKNOWN     0
#define DRIVE_NO_ROOT_DIR 1
#define DRIVE_REMOVABLE   2
#define DRIVE_FIXED       3
#define DRIVE_REMOTE      4
#define DRIVE_CDROM       5
#define DRIVE_RAMDISK     6
*/

HB_FUNC( GETDRIVETYPE )
{
   hb_retni( GetDriveType( (LPCSTR) hb_parc( 1 ) ) ) ;
}

HB_FUNC( DISPLAYCURRENTMODE )
{
	BYTE buffer[ 20 ];
	DEVMODE  lpDevMode;

	strcpy( ( char * ) buffer, "0x0x0" );

	if ( EnumDisplaySettings( NULL, ENUM_CURRENT_SETTINGS, &lpDevMode ) )
	{
		wsprintf( ( char * ) buffer, "%dx%dx%d bits",
			lpDevMode.dmPelsWidth, lpDevMode.dmPelsHeight,
			lpDevMode.dmBitsPerPel );
	}

	hb_retc( ( char * ) buffer );
}

HB_FUNC ( REGENUMKEY )
{
   char buffer[ 128 ];

   hb_retnl( RegEnumKey( ( HKEY ) hb_parnl( 1 ), hb_parnl( 2 ), buffer, 128 ) );
   hb_storc( buffer, 3 );
}

HB_FUNC ( WSASTARTUP )
{
   WSADATA wsa;

   hb_retni( WSAStartup( 0x101, &wsa ) );
}

HB_FUNC ( WSACLEANUP )
{
   hb_retni( WSACleanup() );
}

HB_FUNC ( GETHOSTNAME )
{
   BYTE Name[ 255 ];

   gethostname( ( char * ) Name, 255 );

   hb_retc( ( char * ) Name );
}

HB_FUNC (GETHOSTBYNAME)
{

   struct hostent * pHost;

   BYTE addr[ 20 ];

   strcpy( ( char * ) addr, "0.0.0.0" );

   pHost = gethostbyname( ( char * ) hb_parc( 1 ) ) ;

   if( pHost )
   {
      wsprintf( ( char * ) addr, "%i.%i.%i.%i",
               ( BYTE ) pHost->h_addr[ 0 ], ( BYTE ) pHost->h_addr[ 1 ],
               ( BYTE ) pHost->h_addr[ 2 ], ( BYTE ) pHost->h_addr[ 3 ] );
   }

   hb_retc( ( char * ) addr );
}

HB_FUNC( PEEKBYTE )  // ( nSegment, nOffset ) --> nByte
{
      hb_retni( * ( LPBYTE ) ( hb_parnl( 1 ) + hb_parnl( 2 ) ) );
}

HB_FUNC ( RECTDRAW )
{
   HWND hWnd1;
   HDC hdc1;
   HGDIOBJ hgdiobj1,hgdiobj2;
   HPEN hpen;
   HBRUSH hbrush;
   hWnd1 = (HWND) hb_parnl (1);
   hdc1 = GetDC((HWND) hWnd1);
   hpen = CreatePen( (int) PS_SOLID, (int) hb_parni(7), (COLORREF) RGB( (int) HB_PARNI(6,1), (int) HB_PARNI(6,2), (int) HB_PARNI(6,3) ) );

   hgdiobj1 = SelectObject((HDC) hdc1, hpen);
   if (hb_parl(9))
   {
      hbrush = CreateSolidBrush((COLORREF) RGB((int) HB_PARNI(8,1),(int) HB_PARNI(8,2),(int) HB_PARNI(8,3)));    
      hgdiobj2 = SelectObject((HDC) hdc1, hbrush);
   }   
   else
   {
      hbrush = GetSysColorBrush((int) COLOR_WINDOW);    
      hgdiobj2 = SelectObject((HDC) hdc1, hbrush);
   }      
   Rectangle((HDC) hdc1,(int) hb_parni(3),(int) hb_parni(2),(int) hb_parni(5),(int) hb_parni(4));
   SelectObject((HDC) hdc1,(HGDIOBJ) hgdiobj1);
   SelectObject((HDC) hdc1,(HGDIOBJ) hgdiobj2);
   DeleteObject( hpen );
   DeleteObject( hbrush );
   ReleaseDC( hWnd1, hdc1 );
}

HB_FUNC( ISADMIN )
{
  HANDLE hToken;
  PTOKEN_GROUPS pGroupInfo;
  DWORD dwSize = 0, dwResult;
  DWORD nError, i;
  BOOL lError, lAdMin = FALSE;
  LPSTR cFunc = "";
  PSID  psidAdmin;
  CHAR cMess[100];
  SID_IDENTIFIER_AUTHORITY SystemSidAuthority = {SECURITY_NT_AUTHORITY};

  lError = (! OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,&hToken) );
  if ( lError )
    {
     cFunc = "OpenProcessToken";
     nError = GetLastError();
     if (nError == ERROR_CALL_NOT_IMPLEMENTED)
       {
        hb_retl( TRUE );
        return;
       }
    }

  if ( ! lError && ! (GetTokenInformation(hToken, TokenGroups, NULL, dwSize, &dwSize)) )
    {
      dwResult = GetLastError();
      lError = ( dwResult != ERROR_INSUFFICIENT_BUFFER );
      if( lError )
       {
        cFunc = "GetTokenInformation";
       }
    }

  if ( ! lError )
   {
    pGroupInfo = (PTOKEN_GROUPS) GlobalAlloc( GPTR, dwSize );
    lError = (! GetTokenInformation(hToken, TokenGroups, pGroupInfo, dwSize, &dwSize ) );
    if( lError )
      {
        cFunc = "GetTokenInformation";
      }
   }

  if ( ! lError )
    lError = (! AllocateAndInitializeSid(&SystemSidAuthority, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, &psidAdmin) );
    if ( lError )
     {
      cFunc = "AllocateAndInitializeSid";
     }

  if ( ! lError )
    {
      for( i=0; i<pGroupInfo->GroupCount; i++)
       {
          if ( EqualSid(psidAdmin, pGroupInfo->Groups[i].Sid) )
           {
        	    lAdMin = TRUE;
        	    break;
           }
       }
    }
  else
    {
      cMess[0]=0;
      lstrcat(cMess,"Error calling ");
      lstrcat(cMess,cFunc);
      MessageBox(GetActiveWindow(), cMess, "Attention", MB_OK);
    }

  if (psidAdmin)
      FreeSid(psidAdmin);

  if ( pGroupInfo )
      GlobalFree( pGroupInfo );

  CloseHandle( hToken );
  hb_retl( lAdMin );
}

#pragma ENDDUMP
