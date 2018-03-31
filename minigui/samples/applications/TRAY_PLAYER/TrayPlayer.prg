/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2003-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#ifndef __XHARBOUR__
   #xcommand DEFAULT => OTHERWISE
#endif

#define PROGRAM 'Tray Player'
#define VERSION ' version 1.5.2'
#define COPYRIGHT ' 2003-2011 Grigory Filatov'

#define NTRIM( n )	hb_ntos( n )

MEMVAR nDevice, aFiles, aDuration, nCurItem, cCommand, lWinNT, cIniFile, lShuffle
*--------------------------------------------------------*
Procedure Main( ... )
*--------------------------------------------------------*
Local cPrgPath := cFilePath(_GetErrorlogFile()), aParams := HB_aParams(), ;
	aArray1 := {}, aArray2 := {}, cFolder := GetMyDocumentsFolder()

	PUBLIC nDevice := 0, aFiles := {}, aDuration := {}, ;
		nCurItem := 1, cCommand := "STOP", lWinNT := IsWinNT(), ;
		cIniFile := cPrgPath + "\mru.ini", lShuffle := .F.

	SET MULTIPLE OFF

	Set ShowDetailError Off

	IF PCOUNT() == 0

		IF FILE(cIniFile)

			BEGIN INI FILE cIniFile

				GET aArray1 SECTION "MRU" ENTRY "Files"
				GET aArray2 SECTION "MRU" ENTRY "Duration"
				GET cFolder SECTION "MRU" ENTRY "Folder"
				GET nCurItem SECTION "MRU" ENTRY "Item"

				GET lShuffle SECTION "Options" ENTRY "Shuffle" DEFAULT lShuffle
			END INI

			AEVAL( aArray1, {|e,i| IF(FILE(e), ( AADD(aFiles, e), AADD(aDuration, aArray2[i]) ), )} )
			nCurItem := IF( nCurItem > LEN(aFiles), 1, nCurItem )

		ENDIF

	ENDIF

	SET EVENTS FUNCTION TO MYEVENTS

	DEFINE WINDOW Form_1 					;
		AT 0,0 						;
		WIDTH 0 HEIGHT 0 				;
		TITLE PROGRAM 					;
		MAIN NOSHOW 					;
		ON INIT OnInit( aParams, cPrgPath, cFolder )	;
		ON RELEASE SaveMRU()				;
		NOTIFYICON 'STOP' 				;
		NOTIFYTOOLTIP 'Stop (nothing to play)' 		;
		ON NOTIFYCLICK PlayFiles()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure OnInit( aParams, cPrgPath, cFolder )
*--------------------------------------------------------*
Local i, cFile, nLen := LEN(aParams)

	IF nLen > 0

		For i = 1 To nLen

			cFile := aParams[i]

			IF AT("\", cFile) == 0

				cFile := cPrgPath + "\" + cFile

			ENDIF

			IF FILE( _GetShortPathName(cFile) )

				cFolder := cFilePath(cFile)
				AADD( aFiles, cFile )
				AADD( aDuration, GetMP3Duration(cFile) )

			ENDIF

		Next

	ENDIF

	BuildMenu()

	SetCurrentFolder( cFolder )

	IF LEN(aFiles) > 0
		PlayAudioFile()
	ENDIF

Return

*--------------------------------------------------------*
Static Procedure BuildMenu()
*--------------------------------------------------------*
Local i, cItem

	DEFINE NOTIFY MENU OF Form_1

		ITEM 'E&xit'		ACTION ( IF(EMPTY(nDevice), , C_MCICLOSE(nDevice)), Form_1.Release ) IMAGE "EXIT"
		SEPARATOR	
		ITEM 'A&bout...'	ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAIN", 32, 32 ) ) IMAGE "INFO"
		ITEM '&Mail to author...' ACTION ShellExecute(0, "open", "rundll32.exe", ;
				"url.dll,FileProtocolHandler " + ;
				"mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
				"&subject=Tray%20Player%20Feedback:" + ;
				"&body=Dear%20Author%2C%0A%0A", , 1) IMAGE "MAIL"
		SEPARATOR	

		IF LEN(aFiles) > 0

			ITEM '&Shuffle'	ACTION ( lShuffle := !lShuffle, Form_1.Shuffle.Checked := lShuffle ) NAME Shuffle
			Form_1.Shuffle.Checked := lShuffle

			POPUP "Playlist"
				For i = 1 To LEN(aFiles)
					cItem := "Item_" + NTRIM(i)
					ITEM StrTran( SubStr( cFileNoExt( aFiles[i] ), 1, 56 ), "_", " " ) + " (" + aDuration[i] + ")" ;
						ACTION PlayThisFile() NAME &cItem
				Next
			END POPUP

			cItem := "Item_" + NTRIM(nCurItem)
			Form_1.&(cItem).Checked := .T.

			SEPARATOR	
			ITEM '&Previous'	ACTION PlayControl(-1)	IMAGE "BACK"
			ITEM '&Next'		ACTION PlayControl(1)	IMAGE "NEXT"
			SEPARATOR	

		ENDIF

		ITEM '&Open...'		ACTION IF( OpenFiles(), PlayFiles(), ) IMAGE "OPEN"

	END MENU

Return

*--------------------------------------------------------*
Static Procedure PlayThisFile()
*--------------------------------------------------------*
Local cItem := This.Name

	nCurItem := Val( SubStr(cItem, At("_", cItem) + 1) )

	IF !EMPTY(nDevice)
		C_MCICLOSE( nDevice )
		nDevice := 0
	ENDIF

	BuildMenu()
	PlayAudioFile()

	cCommand := "PREVNEXT"

Return

*--------------------------------------------------------*
Static Procedure PlayFiles()
*--------------------------------------------------------*

	IF cCommand == "PAUSE"

		C_MCIRESUME( nDevice )

		cCommand := "PLAY"
		Form_1.NotifyIcon := 'MAIN'

	ELSEIF cCommand == "PLAY"

		C_MCIPAUSE( nDevice )

		cCommand := "PAUSE"
		Form_1.NotifyIcon := 'PAUSE'

	ELSEIF cCommand == "STOP"

		IF LEN(aFiles) == 0

			OpenFiles()

		ENDIF

		IF LEN(aFiles) <> 0

			IF !lWinNT
				DO EVENTS
			ENDIF

			PlayAudioFile()

		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Static Procedure PlayAudioFile()
*--------------------------------------------------------*

	IF lWinNT .AND. ( cCommand == "STOP" .OR. cCommand == "PREVNEXT" )
		DO EVENTS
	ENDIF

	IF C_MCIOPEN( "WaveAudio", aFiles[nCurItem], @nDevice ) == 0

		IF C_MCIPLAY( nDevice, Application.Handle ) == 0

			cCommand := "PLAY"

			Form_1.NotifyIcon := 'MAIN'
			Form_1.NotifyTooltip := StrTran( SubStr( cFileNoExt( aFiles[nCurItem] ), 1, 56 ), "_", " " ) + ;
				" (" + aDuration[nCurItem] + ")"

		ELSE

			IF LEN(aFiles) > 1

				PlayControl(1)

			ENDIF

		ENDIF

	ELSE
		IF LEN(aFiles) > 1

			PlayControl(1)

		ENDIF

	ENDIF

Return

*--------------------------------------------------------*
Static Procedure PlayControl( nMode )
*--------------------------------------------------------*
Local nOldItem

	IF LEN(aFiles) > 0 .AND. cCommand <> "STOP"

		IF lShuffle

			nOldItem := nCurItem
			nCurItem := MAX( 1, Random( LEN(aFiles) ) )

			IF nOldItem == nCurItem
				nCurItem := MAX( 1, Random( LEN(aFiles) ) )
			ENDIF

		ELSE

			IF nMode > 0

				IF nCurItem < LEN(aFiles)

					nCurItem++

				ELSE

					nCurItem := 1

				ENDIF

			ELSE

				IF nCurItem > 1

					nCurItem--

				ELSE

					nCurItem := LEN(aFiles)

				ENDIF

			ENDIF

		ENDIF

		IF !EMPTY(nDevice)
			C_MCICLOSE( nDevice )
			nDevice := 0
		ENDIF

		BuildMenu()
		PlayAudioFile()

		cCommand := "PREVNEXT"

	ENDIF

Return

*--------------------------------------------------------*
Static Function GetMP3Duration( cFile )
*--------------------------------------------------------*
Local nLength

	@0,0 PLAYER Play_1		;
		OF Form_1		;
		WIDTH 0 HEIGHT 0	;
		FILE cFile

	nLength := Form_1.Play_1.Length / 60000

	Form_1.Play_1.Release

Return NTRIM( Int(nLength) ) + "'" + StrZero( Int( ( nLength - Int(nLength) ) * 60 ), 2 )

*--------------------------------------------------------*
Static Function OpenFiles()
*--------------------------------------------------------*
Local lRet := .F., cCurPath := CurDrive() + ":\" + CurDir()
Local aGetFiles := GetFile( { {"Audio Files", "*.mp3;*.wma;*.wav;*.mid"} }, "Select a File(s)", StrTran(cCurPath, "\\", "\"), .T., .F. )

	IF LEN(aGetFiles) > 0

		lRet := .T.

		aFiles := {}
		AEVAL( aGetFiles, {|e| AADD(aFiles, e)} )
		ASORT( aFiles )

		aDuration := {}
		AEVAL( aFiles, {|e| AADD(aDuration, GetMP3Duration(e))} )

		IF !EMPTY(nDevice)
			C_MCICLOSE( nDevice )
			nDevice := 0
		ENDIF

		nCurItem := 1
		BuildMenu()

		cCommand := "STOP"
		Form_1.NotifyIcon := 'STOP'
		Form_1.NotifyTooltip := 'Stop'

	ENDIF

Return lRet

*--------------------------------------------------------*
Static Procedure SaveMRU()
*--------------------------------------------------------*

	IF LEN(aFiles) > 0

		BEGIN INI FILE cIniFile

			SET SECTION "MRU" ENTRY "Files" TO aFiles
			SET SECTION "MRU" ENTRY "Duration" TO aDuration
			SET SECTION "MRU" ENTRY "Folder" TO cFilePath(aFiles[1])
			SET SECTION "MRU" ENTRY "Item" TO nCurItem

			SET SECTION "Options" ENTRY "Shuffle" TO lShuffle
		END INI

	ENDIF

Return

*--------------------------------------------------------*
Function cFileNoExt( cPathMask )
*--------------------------------------------------------*
LOCAL cName := AllTrim( cFileNoPath( cPathMask ) )
LOCAL n     := rAt( ".", cName )

Return AllTrim( If( n > 0, Left( cName, n - 1 ), cName ) )

#define MM_MCINOTIFY    953     // 0x3B9
#define WM_MENUSELECT   287
*--------------------------------------------------------*
Function MyEvents( hWnd, nMsg, wParam, lParam )
*--------------------------------------------------------*
Local nOldItem

    SWITCH nMsg

	CASE MM_MCINOTIFY

		IF cCommand == "STOP"

		ELSEIF cCommand == "PREVNEXT"

			cCommand := "PLAY"

		ELSE

			IF lShuffle

				nOldItem := nCurItem
				nCurItem := MAX( 1, Random( LEN(aFiles) ) )

				IF nOldItem == nCurItem
					nCurItem := MAX( 1, Random( LEN(aFiles) ) )
				ENDIF

				IF !EMPTY(nDevice)
					C_MCICLOSE( nDevice )
					nDevice := 0
				ENDIF

				IF lWinNT
					cCommand := "PREVNEXT"
				ENDIF

				BuildMenu()
				PlayAudioFile()

			ELSE

				IF nCurItem < LEN(aFiles)

					nCurItem++

					IF !EMPTY(nDevice)
						C_MCICLOSE( nDevice )
						nDevice := 0
					ENDIF

					IF lWinNT
						cCommand := "PREVNEXT"
					ENDIF

					BuildMenu()
					PlayAudioFile()

				ELSE

					IF !EMPTY(nDevice)
						C_MCICLOSE( nDevice )
						nDevice := 0
					ENDIF

					cCommand := "STOP"
					Form_1.NotifyIcon := 'STOP'
					Form_1.NotifyTooltip := 'Stop'

				ENDIF

			ENDIF

		ENDIF

		EXIT

	CASE WM_MENUSELECT

		EXIT

	DEFAULT

		Return Events ( hWnd, nMsg, wParam, lParam )

    END

Return (0)


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

#ifndef __XHARBOUR__
   #define ISCHAR( n )           HB_ISCHAR( n )
#endif

HB_FUNC ( C_MCIOPEN )
{
   MCI_OPEN_PARMS mciOpenParms;

   mciOpenParms.lpstrDeviceType = hb_parc( 1 );

   if( ISCHAR( 2 ) )
   {
      mciOpenParms.lpstrElementName = hb_parc( 2 );
   }

   hb_retnl( mciSendCommand( 0, MCI_OPEN, MCI_OPEN_ELEMENT,
                           ( DWORD ) &mciOpenParms ) );

   hb_storni( mciOpenParms.wDeviceID, 3 );
}

HB_FUNC ( C_MCIPLAY )
{
   MCI_PLAY_PARMS mciPlayParms;

   mciPlayParms.dwCallback = ( DWORD ) ( LPVOID ) hb_parnl( 2 );

   hb_retnl( mciSendCommand( hb_parni( 1 ),         // Device ID
		MCI_PLAY, MCI_NOTIFY,
		( DWORD ) &mciPlayParms ) );
}

HB_FUNC ( C_MCIRESUME )
{
   hb_retnl( mciSendCommand( hb_parni( 1 ),         // Device ID
		MCI_RESUME, 0,
		NULL ) );
}

HB_FUNC ( C_MCIPAUSE )
{
   hb_retnl( mciSendCommand( hb_parni( 1 ),         // Device ID
		MCI_PAUSE, 0,
		NULL ) );
}

HB_FUNC ( C_MCICLOSE )
{
   hb_retnl( mciSendCommand( hb_parni( 1 ),         // Device ID
		MCI_CLOSE, 0,
		NULL ) );
}

#pragma ENDDUMP
