/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "fileio.ch"

#define PROGRAM			'MSDOS.SYS SetUp Utility'
#define VERSION			' version 1.1'
#define COPYRIGHT		' Grigory Filatov, 2003-06'

#define NTRIM( n )		LTrim( Str( n ) )
#define IDI_MAIN		1001

#define _FA_NORMAL		32
#define _FA_HIDDEN		39

#define SYS_EVENT_GUI          1
#define SYS_EVENT_FKEYS        2
#define SYS_EVENT_BOOTDELAY    3
#define SYS_EVENT_MENU         4
#define SYS_EVENT_MENUDELAY    5
#define SYS_EVENT_MULTI        6
#define SYS_EVENT_LOGO         7
#define SYS_EVENT_SCAN         8
#define SYS_EVENT_DRV          9
#define SYS_EVENT_DBL         10
#define SYS_EVENT_BUFFER      11
#define SYS_EVENT_WARN        12

STATIC cLineBuffer, nHandle, nBytesRead, lFullBuff, nTotBytes, lIsOpen

MEMVAR cFileName, aMsg, aRem
MEMVAR nGUI, nKeys, nBootDelay, ;
	nMenu, nMenuDelay, ;
	nMulti, nLogo, nScan, ;
	nDrv, nDbl, nBuffer, nWarn

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
LOCAL cLine, cMsg := ""
PRIVATE cFileName := 'C:\MSDOS.SYS', aMsg := {}, aRem := {}
PRIVATE nGUI := 1, nKeys := 1, nBootDelay := 2, ;
	nMenu := 0, nMenuDelay := 30, ;
	nMulti := 1, nLogo := 1, nScan := 2, ;
	nDrv := 1, nDbl := 1, nBuffer := 0, nWarn := 1

IF IsWinNT()
	MsgStop( 'This program for Win9x/ME Only!', PROGRAM )
	Return
ENDIF

IF IsFileExist( cFileName )
	IF bOpen( cFileName )
		DO WHILE !bEof()
			cLine := bReadLine()
			IF SUBSTR(cLine, 1, 1) # ";"
				AADD(aMsg, cLine)
			ELSE
				AADD(aRem, cLine)
			ENDIF
		ENDDO
		bClose()
	ELSE
		MsgStop( 'Cannot open a file ' + cFileName, PROGRAM )
		Return
	ENDIF
ELSE
	MsgStop( 'Cannot found a file ' + cFileName, PROGRAM )
	Return
ENDIF

AEVAL(GetExtractOpt( aMsg ), {|e| cMsg += e + CRLF})

IF LoadDefaults()

   DEFINE WINDOW  Form_1 ;
        AT 0,0 ;
        WIDTH 580 ;
        HEIGHT 380 ;
        TITLE PROGRAM ;
        ICON IDI_MAIN ;
        MAIN ;
        NOMAXIMIZE ;
        NOSIZE ;
        ON INIT _ExtDisableControl( 'CONTROL_4' ,'Form_1' ) ;
        ON PAINT DoMethod( 'Form_1', 'CONTROL_6', 'SetFocus' ) ;
        FONT 'MS Sans Serif' ;
        SIZE 10

        @ 10,10 FRAME CONTROL_1 ;
            CAPTION 'Boot Settings' ;
            WIDTH 270 ;
            HEIGHT 200 ;
            OPAQUE

        @ 216,10 FRAME CONTROL_2 ;
            CAPTION 'Special Settings' ;
            WIDTH 270 ;
            HEIGHT 100 ;
            OPAQUE

        @ 10,292 FRAME CONTROL_3 ;
            CAPTION 'MSDOS.SYS File' ;
            WIDTH 270 ;
            HEIGHT 306 ;
            OPAQUE

        @ 32,305 EDITBOX CONTROL_4 ;
            WIDTH 242 ;
            HEIGHT 270 ;
            VALUE cMsg ;
            BACKCOLOR WHITE ;
            NOTABSTOP ;
            NOVSCROLL ;
            NOHSCROLL

        @ 323,390 BUTTON CONTROL_6 ;
            CAPTION 'Cancel' ;
            ACTION Form_1.Release ;
            WIDTH 74 ;
            HEIGHT 26

        @ 323,310 BUTTON CONTROL_5 ;
            CAPTION 'OK' ;
            ACTION ( IF(Form_1.CONTROL_7.Enabled, ApplyChanges(), ), Form_1.Release ) ;
            WIDTH 74 ;
            HEIGHT 26

        @ 323,470 BUTTON CONTROL_7 ;
            CAPTION 'Apply' ;
            ACTION ( ApplyChanges(), Form_1.CONTROL_7.Enabled := FALSE ) ;
            WIDTH 74 ;
            HEIGHT 26

        @ 320,10 IMAGE CONTROL_8 ;
            PICTURE 'TIPS' ;
            ACTION MsgAbout() ;
            WIDTH 32 ;
            HEIGHT 32

        @ 327,60 LABEL CONTROL_9 ;
            VALUE 'Copyright ' + Chr(169) + ' 2003-06 Grigory Filatov' ;
            WIDTH 210 ;
            HEIGHT 18 ; 
            TRANSPARENT

        @ 30,20 LABEL CONTROL_10 ;
            VALUE 'Start directly to :' ;
            WIDTH 100 ;
            HEIGHT 23

        @ 26,120 COMBOBOX CONTROL_11 ;
            ITEMS { "Windows", "MS-DOS" } ;
            VALUE nGUI ;
            WIDTH 100 ;
            HEIGHT 100 ;
            ON CHANGE ( nGUI := Form_1.CONTROL_11.Value, nGUI := IF(nGUI == 2, 0, nGUI), ;
			MsgUpdate(SYS_EVENT_GUI), Form_1.CONTROL_7.Enabled := TRUE )

        @ 54,20 CHECKBOX CONTROL_12 ;
            CAPTION 'Function Keys are available for' ;
            WIDTH 205 ;
            HEIGHT 23 ; 
            VALUE ( nKeys == 1 ) ;
            ON CHANGE ( nKeys := IF(Form_1.CONTROL_12.Value, 1, 0), MsgUpdate(SYS_EVENT_FKEYS), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 54,230 SPINNER CONTROL_13 ;
            RANGE 0 , 30 ;
            VALUE nBootDelay ;
            WIDTH 40 ;
            HEIGHT 23 ;
            ON CHANGE ( nBootDelay := Form_1.CONTROL_13.Value, MsgUpdate(SYS_EVENT_BOOTDELAY), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 76,20 CHECKBOX CONTROL_14 ;
            CAPTION 'Always show Boot Menu' ;
            WIDTH 180 ;
            HEIGHT 23 ;
            VALUE ( nMenu == 1 ) ;
            ON CHANGE ( nMenu := IF(Form_1.CONTROL_14.Value, 1, 0), MsgUpdate(SYS_EVENT_MENU), ;
			Form_1.CONTROL_7.Enabled := TRUE, ;
			IF(EMPTY(nMenu), ( Form_1.CONTROL_15.Enabled := FALSE, Form_1.CONTROL_17.Enabled := FALSE ), ;
			( Form_1.CONTROL_15.Enabled := TRUE, Form_1.CONTROL_17.Enabled := TRUE ) ) )

        @ 102,40 LABEL CONTROL_15 ;
            VALUE 'Continue booting after' ;
            WIDTH 140 ;
            HEIGHT 23

        @ 100,180 SPINNER CONTROL_17 ;
            RANGE 0 , 60 ;
            VALUE nMenuDelay ;
            WIDTH 40 ;
            HEIGHT 23 ;
            ON CHANGE ( nMenuDelay := Form_1.CONTROL_17.Value, MsgUpdate(SYS_EVENT_MENUDELAY), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 128,20 CHECKBOX CONTROL_18 ;
            CAPTION 'Allow F4 to boot to previous OS' ;
            WIDTH 220 ;
            HEIGHT 23 ;
            VALUE ( nMulti == 1 ) ;
            ON CHANGE ( nMulti := IF(Form_1.CONTROL_18.Value, 1, 0), MsgUpdate(SYS_EVENT_MULTI), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 150,20 CHECKBOX CONTROL_19 ;
            CAPTION 'Always show Splash Screen at startup' ;
            WIDTH 245 ;
            HEIGHT 23 ;
            VALUE ( nLogo == 1 ) ;
            ON CHANGE ( nLogo := IF(Form_1.CONTROL_19.Value, 1, 0), MsgUpdate(SYS_EVENT_LOGO), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 180,20 LABEL CONTROL_20 ;
            VALUE 'Run ScanDisk:' ;
            WIDTH 100 ;
            HEIGHT 23

        @ 176,120 COMBOBOX CONTROL_21 ;
            ITEMS { "Never Scan", "After prompting", "Automatically" } ;
            VALUE nScan + 1 ;
            WIDTH 120 ;
            HEIGHT 120 ;
            ON CHANGE ( nScan := Form_1.CONTROL_21.Value - 1, MsgUpdate(SYS_EVENT_SCAN), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 234,20 CHECKBOX CONTROL_22 ;
            CAPTION 'Autoload DrvSpace Driver' ;
            WIDTH 200 ;
            HEIGHT 18 ;
            VALUE ( nDrv == 1 ) ;
            ON CHANGE ( nDrv := IF(Form_1.CONTROL_22.Value, 1, 0), MsgUpdate(SYS_EVENT_DRV), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 252,20 CHECKBOX CONTROL_23 ;
            CAPTION 'Autoload DblSpace Driver' ;
            WIDTH 200 ;
            HEIGHT 18 ;
            VALUE ( nDbl == 1 ) ;
            ON CHANGE ( nDbl := IF(Form_1.CONTROL_23.Value, 1, 0), MsgUpdate(SYS_EVENT_DBL), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 270,20 CHECKBOX CONTROL_24 ;
            CAPTION 'Use Double Buffering' ;
            WIDTH 200 ;
            HEIGHT 18 ;
            VALUE ( nBuffer == 1 ) ;
            ON CHANGE ( nBuffer := IF(Form_1.CONTROL_24.Value, 1, 0), MsgUpdate(SYS_EVENT_BUFFER), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        @ 288,20 CHECKBOX CONTROL_25 ;
            CAPTION 'Show Safe Mode Warning' ;
            WIDTH 200 ;
            HEIGHT 18 ;
            VALUE ( nWarn == 1 ) ;
            ON CHANGE ( nWarn := IF(Form_1.CONTROL_25.Value, 1, 0), MsgUpdate(SYS_EVENT_WARN), ;
			Form_1.CONTROL_7.Enabled := TRUE )

        Form_1.CONTROL_7.Enabled := FALSE

        IF EMPTY(nMenu)
		Form_1.CONTROL_15.Enabled := FALSE
		Form_1.CONTROL_17.Enabled := FALSE
        ENDIF

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

ELSE
   MsgStop( 'File ' + cFileName + ' is empty!', PROGRAM )
ENDIF

RETURN

*--------------------------------------------------------*
Function MsgUpdate( nEvent )
*--------------------------------------------------------*
LOCAL i, cMsg := ""

	DO CASE
		CASE nEvent == SYS_EVENT_GUI
			i := ASCAN( aMsg, {|e| "BootGUI" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootGUI=" + NTRIM(nGUI) )
			ELSE
				aMsg[i] := "BootGUI=" + NTRIM(nGUI)
			ENDIF

		CASE nEvent == SYS_EVENT_FKEYS
			i := ASCAN( aMsg, {|e| "BootKeys" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootKeys=" + NTRIM(nKeys) )
			ELSE
				aMsg[i] := "BootKeys=" + NTRIM(nKeys)
			ENDIF

		CASE nEvent == SYS_EVENT_BOOTDELAY
			i := ASCAN( aMsg, {|e| "BootDelay" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootDelay=" + NTRIM(nBootDelay) )
			ELSE
				aMsg[i] := "BootDelay=" + NTRIM(nBootDelay)
			ENDIF

		CASE nEvent == SYS_EVENT_MENU
			i := ASCAN( aMsg, {|e| "BootMenu" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootMenu=" + NTRIM(nMenu) )
			ELSE
				aMsg[i] := "BootMenu=" + NTRIM(nMenu)
			ENDIF

		CASE nEvent == SYS_EVENT_MENUDELAY
			i := ASCAN( aMsg, {|e| "BootMenuDelay" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootMenuDelay=" + NTRIM(nMenuDelay) )
			ELSE
				aMsg[i] := "BootMenuDelay=" + NTRIM(nMenuDelay)
			ENDIF

		CASE nEvent == SYS_EVENT_MULTI
			i := ASCAN( aMsg, {|e| "BootMulti" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootMulti=" + NTRIM(nMulti) )
			ELSE
				aMsg[i] := "BootMulti=" + NTRIM(nMulti)
			ENDIF

		CASE nEvent == SYS_EVENT_LOGO
			i := ASCAN( aMsg, {|e| "Logo" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "Logo=" + NTRIM(nLogo) )
			ELSE
				aMsg[i] := "Logo=" + NTRIM(nLogo)
			ENDIF

		CASE nEvent == SYS_EVENT_SCAN
			i := ASCAN( aMsg, {|e| "AutoScan" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "AutoScan=" + NTRIM(nScan) )
			ELSE
				aMsg[i] := "AutoScan=" + NTRIM(nScan)
			ENDIF

		CASE nEvent == SYS_EVENT_DRV
			i := ASCAN( aMsg, {|e| "DrvSpace" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "DrvSpace=" + NTRIM(nDrv) )
			ELSE
				aMsg[i] := "DrvSpace=" + NTRIM(nDrv)
			ENDIF

		CASE nEvent == SYS_EVENT_DBL
			i := ASCAN( aMsg, {|e| "DblSpace" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "DblSpace=" + NTRIM(nDbl) )
			ELSE
				aMsg[i] := "DblSpace=" + NTRIM(nDbl)
			ENDIF

		CASE nEvent == SYS_EVENT_BUFFER
			i := ASCAN( aMsg, {|e| "DoubleBuffer" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "DoubleBuffer=" + NTRIM(nBuffer) )
			ELSE
				aMsg[i] := "DoubleBuffer=" + NTRIM(nBuffer)
			ENDIF

		CASE nEvent == SYS_EVENT_WARN
			i := ASCAN( aMsg, {|e| "BootWarn" $ e} )
			IF EMPTY(i)
				AADD( aMsg, "BootWarn=" + NTRIM(nWarn) )
			ELSE
				aMsg[i] := "BootWarn=" + NTRIM(nWarn)
			ENDIF
	ENDCASE

	AEVAL(GetExtractOpt( aMsg ), {|e| cMsg += e + CRLF})
	Form_1.CONTROL_4.Value := cMsg

Return nil

*--------------------------------------------------------*
Function GetExtractOpt( aInput )
*--------------------------------------------------------*
LOCAL nEvent, aOpt := {}

For nEvent := 1 To 12

	DO CASE
		CASE nEvent == SYS_EVENT_GUI
			IF !EMPTY( ASCAN( aInput, {|e| "BootGUI" $ e} ) )
				AADD( aOpt, "BootGUI=" + NTRIM(nGUI) )
			ENDIF

		CASE nEvent == SYS_EVENT_FKEYS
			IF !EMPTY( ASCAN( aInput, {|e| "BootKeys" $ e} ) )
				AADD( aOpt, "BootKeys=" + NTRIM(nKeys) )
			ENDIF

		CASE nEvent == SYS_EVENT_BOOTDELAY
			IF !EMPTY( ASCAN( aInput, {|e| "BootDelay" $ e} ) )
				AADD( aOpt, "BootDelay=" + NTRIM(nBootDelay) )
			ENDIF

		CASE nEvent == SYS_EVENT_MENU
			IF !EMPTY( ASCAN( aInput, {|e| "BootMenu" $ e} ) )
				AADD( aOpt, "BootMenu=" + NTRIM(nMenu) )
			ENDIF

		CASE nEvent == SYS_EVENT_MENUDELAY
			IF !EMPTY( ASCAN( aInput, {|e| "BootMenuDelay" $ e} ) )
				AADD( aOpt, "BootMenuDelay=" + NTRIM(nMenuDelay) )
			ENDIF

		CASE nEvent == SYS_EVENT_MULTI
			IF !EMPTY( ASCAN( aInput, {|e| "BootMulti" $ e} ) )
				AADD( aOpt, "BootMulti=" + NTRIM(nMulti) )
			ENDIF

		CASE nEvent == SYS_EVENT_LOGO
			IF !EMPTY( ASCAN( aInput, {|e| "Logo" $ e} ) )
				AADD( aOpt, "Logo=" + NTRIM(nLogo) )
			ENDIF

		CASE nEvent == SYS_EVENT_SCAN
			IF !EMPTY( ASCAN( aInput, {|e| "AutoScan" $ e} ) )
				AADD( aOpt, "AutoScan=" + NTRIM(nScan) )
			ENDIF

		CASE nEvent == SYS_EVENT_DRV
			IF !EMPTY( ASCAN( aInput, {|e| "DrvSpace" $ e} ) )
				AADD( aOpt, "DrvSpace=" + NTRIM(nDrv) )
			ENDIF

		CASE nEvent == SYS_EVENT_DBL
			IF !EMPTY( ASCAN( aInput, {|e| "DblSpace" $ e} ) )
				AADD( aOpt, "DblSpace=" + NTRIM(nDbl) )
			ENDIF

		CASE nEvent == SYS_EVENT_BUFFER
			IF !EMPTY( ASCAN( aInput, {|e| "DoubleBuffer" $ e} ) )
				AADD( aOpt, "DoubleBuffer=" + NTRIM(nBuffer) )
			ENDIF

		CASE nEvent == SYS_EVENT_WARN
			IF !EMPTY( ASCAN( aInput, {|e| "BootWarn" $ e} ) )
				AADD( aOpt, "BootWarn=" + NTRIM(nWarn) )
			ENDIF
	ENDCASE

Next

Return aOpt

*--------------------------------------------------------*
Function ApplyChanges()
*--------------------------------------------------------*
   IF GetFileAttributes(cFileName) # _FA_NORMAL
	SetFileAttributes(cFileName, _FA_NORMAL)
   ENDIF

   Ferase(cFileName)

   MakeSysFile( cFileName, aMsg )
   MakeSysFile( cFileName, aRem )

   IF GetFileAttributes(cFileName) == _FA_NORMAL
	SetFileAttributes(cFileName, _FA_HIDDEN)
   ENDIF

Return nil

*--------------------------------------------------------*
Function LoadDefaults()
*--------------------------------------------------------*
LOCAL cIniFile := "System.log"

   IF Len(aMsg) > 0
	MakeSysFile( cIniFile, aMsg )

	BEGIN INI FILE cIniFile

		GET nGUI SECTION "Options" ENTRY "BootGUI" DEFAULT nGUI

		GET nKeys SECTION "Options" ENTRY "BootKeys" DEFAULT nKeys

		GET nBootDelay SECTION "Options" ENTRY "BootDelay" DEFAULT nBootDelay

		GET nMenu SECTION "Options" ENTRY "BootMenu" DEFAULT nMenu

		GET nMenuDelay SECTION "Options" ENTRY "BootMenuDelay" DEFAULT nMenuDelay

		GET nMulti SECTION "Options" ENTRY "BootMulti" DEFAULT nMulti

		GET nLogo SECTION "Options" ENTRY "Logo" DEFAULT nLogo

		GET nScan SECTION "Options" ENTRY "AutoScan" DEFAULT nScan

		GET nDrv SECTION "Options" ENTRY "DrvSpace" DEFAULT nDrv

		GET nDbl SECTION "Options" ENTRY "DblSpace" DEFAULT nDbl

		GET nBuffer SECTION "Options" ENTRY "DoubleBuffer" DEFAULT nBuffer

		GET nWarn SECTION "Options" ENTRY "BootWarn" DEFAULT nWarn

	END INI

	Ferase(cIniFile)
   ENDIF

Return ( Len(aMsg) > 0 )

*--------------------------------------------------------*
Function IsFileExist( cFileName )
*--------------------------------------------------------*
LOCAL hFile := FOpen( cFileName, FO_READ )

      FClose( hFile )

Return ( hFile != -1 )

*--------------------------------------------------------*
Function MakeSysFile( cFileName, aInfo )
*--------------------------------------------------------*
LOCAL hFile, cLine := "", n

   for n = 1 to Len( aInfo )
      cLine += aInfo[ n ] + CRLF
   next

   if ! File( cFileName )
      FClose( FCreate( cFileName ) )
   endif

   if( ( hFile := FOpen( cFileName, FO_WRITE ) ) != -1 )
      FSeek( hFile, 0, FS_END )
      FWrite( hFile, cLine, Len( cLine ) )
      FClose( hFile )
   endif

Return nil

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
Return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This Program is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 30), "About", IDI_MAIN, .F. )


#include "buffread.prg"

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( SETFILEATTRIBUTES )
{
   hb_retl( SetFileAttributes( (LPCSTR) hb_parc( 1 ), (DWORD) hb_parnl( 2 ) ) ) ;
}

HB_FUNC( GETFILEATTRIBUTES )
{
   hb_retnl( (LONG) GetFileAttributes( (LPCSTR) hb_parc( 1 ) ) ) ;
}

#pragma ENDDUMP
