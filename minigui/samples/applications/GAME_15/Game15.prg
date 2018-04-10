/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Game 15'
#define VERSION ' version 2.3'
#define COPYRIGHT ' 2003-2009 Grigory Filatov'

#define IDI_MAIN 1001
//#define DEBUG

Static n := 4, aData := {}, cUserName := "NoName", aBase := { {"NAME","C",30,0}, {"RESULT","N",6,0} }
Static aKeys

FIELD NAME, RESULT

Procedure Main()

   SET MULTIPLE OFF WARNING

   DEFINE WINDOW Form_1 ; 
	AT 0,0 ; 
	WIDTH 317 ; 
	HEIGHT 394 ; 
	TITLE PROGRAM + VERSION ; 
	ICON IDI_MAIN ;
	MAIN ;
	NOMINIMIZE NOMAXIMIZE ;
	NOSIZE NOCAPTION ;
	ON INIT OpenTopTable() ;
	ON RELEASE ( dbCloseAll(), ;
		Ferase( "Game1"+INDEXEXT() ), Ferase( "Game2"+INDEXEXT() ) ) ;
	FONT "Arial" ;
	SIZE 10

	@ 0,0 IMAGE Main_1 ;
		PICTURE "MAIN" ;
		WIDTH Form_1.Width HEIGHT Form_1.Height

	@ 10, 8 LABEL Label_1 VALUE SPACE(6) + PROGRAM + VERSION ;
		WIDTH 266 HEIGHT 16 ;
		ACTION InterActiveMoveHandle( GetFormHandle("Form_1") ) ;
		FONT "Arial" ;
		SIZE 12 ;
		BOLD ;
		FONTCOLOR WHITE ;
		TRANSPARENT ;
		CENTERALIGN

	@ 12, Form_1.Width - 42 BUTTON Minimize ;
		PICTURE "MINBTN" ;
		ACTION Form_1.Minimize ;
		WIDTH 14 HEIGHT 14

	@ 12, Form_1.Width - 26 BUTTON Release ;
		PICTURE "CLOSEBTN" ;
		ACTION Form_1.Release ;
		WIDTH 14 HEIGHT 14

	LoadData()

	@ 36, 14 BUTTON Button_1 PICTURE "Load" ;
		ACTION LoadGame() ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "Load a game" ;
		FLAT ;
		NOXPSTYLE


	@ 36, 110 BUTTON Button_2 PICTURE "Start" ;
		ACTION StartAgain() ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "Start of new game" ;
		FLAT ;
		NOXPSTYLE

	@ 36, 206 BUTTON Button_3 PICTURE "Save" ;
		ACTION SaveGame() ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "Save a game" ;
		FLAT ;
		NOXPSTYLE

	@ Form_1.Height - 32, 14 BUTTON Button_4 ;
		PICTURE "About" ;
		ACTION MsgAbout() ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "About" ;
		FLAT ;
		NOXPSTYLE

	@ Form_1.Height - 32, 110 BUTTON Button_5 ;
		PICTURE "Top" ;
		ACTION LoadTop() ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "Top Table" ;
		FLAT ;
		NOXPSTYLE

	@ Form_1.Height - 32, 206 BUTTON Button_6 ;
		PICTURE "Exit" ;
		ACTION Form_1.Release ;
		WIDTH 96 HEIGHT 24 ;
		TOOLTIP "Exit" ;
		FLAT ;
		NOXPSTYLE

	ON KEY ALT+L ACTION LoadGame()
	ON KEY ALT+T ACTION StartAgain()
	ON KEY ALT+S ACTION SaveGame()
	ON KEY ALT+B ACTION MsgAbout()
	ON KEY ALT+1 ACTION LoadTop()
	ON KEY ALT+X ACTION Form_1.Release

#ifdef DEBUG
	ON KEY ALT+W ACTION LoadWin()
#endif

   END WINDOW

   Form_1.Button_1.Enabled := ( Len( Directory( "*.sav" ) ) > 0 )
   Form_1.Button_2.SetFocus

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure PressButton()
*--------------------------------------------------------*
LOCAL cCapt := This.Picture, nPress, nFree
LOCAL row, col, nr, fl := .F.

nFree := ASCAN( aData, {|x| x[1] == "B16" } )
nPress := ASCAN( aData, {|x| x[1] == cCapt } )

IF ABS(nFree - nPress) == n .OR. ABS(nFree - nPress) == 1
	SwapButtons(nPress, nFree)
	FOR row := 1 TO n
		FOR col := 1 TO n
			nr := (row - 1) * n + col
			IF nr == n * n
				EXIT
			ENDIF
			IF VAL( SUBSTR( aData[nr][1], 2 ) ) # (col - 1) * n + row
				fl := .T.
				PlayBeep()
				EXIT
			ENDIF
		NEXT
		IF fl
			EXIT
		ENDIF
	NEXT
	IF !fl
		SaveResult()
	ENDIF
ENDIF

Return

*--------------------------------------------------------*
Static Procedure SwapButtons(nPress, nFree)
*--------------------------------------------------------*
LOCAL cPress := aData[nPress][2], cFree := aData[nFree][2]
LOCAL swap, nOnRow, nOnCol, nToRow, nToCol

swap := aData[nFree][1]

aData[nFree][1] := aData[nPress][1]
aData[nFree][2] := cPress

aData[nPress][1] := swap
aData[nPress][2] := cFree

nOnRow := GetProperty( "Form_1", cPress, "Row" )
nOnCol := GetProperty( "Form_1", cPress, "Col" )
nToRow := GetProperty( "Form_1", cFree, "Row" )
nToCol := GetProperty( "Form_1", cFree, "Col" )

SetProperty( "Form_1", cPress, "Row", nToRow )
SetProperty( "Form_1", cPress, "Col", nToCol )
SetProperty( "Form_1", cFree, "Row", nOnRow )
SetProperty( "Form_1", cFree, "Col", nOnCol )

Return

*--------------------------------------------------------*
Static Procedure StartAgain()
*--------------------------------------------------------*
LOCAL nr, cButton

FOR nr := 1 TO n * n
	cButton := "Number_" + STRZERO(nr, 2)
	DoMethod( "Form_1", cButton, "Release" )
NEXT

aData := {}
LoadData()

Return

*--------------------------------------------------------*
Static Procedure SaveGame()
*--------------------------------------------------------*
LOCAL cCurDir := CurDrive() + ":\" + CurDir()
LOCAL cSaveFile := PutFile ( {{"Save files (*.sav)", "*.sav"}}, ;
			'Save a Game To File', cCurDir, .T. )

IF !EMPTY(cSaveFile)

	DIRCHANGE( cCurDir )

	cSaveFile := cFileNoExt(cSaveFile) + ".sav"

	BEGIN INI FILE cSaveFile
		SET SECTION "Game" ENTRY "Save" TO aData
	END INI

	Form_1.Button_1.Enabled := .t.

ENDIF

Return

*--------------------------------------------------------*
Static Procedure LoadGame()
*--------------------------------------------------------*
LOCAL cCurDir := CurDrive() + ":\" + CurDir()
LOCAL row, col, nr, cButton, cCaption
LOCAL cSaveFile

IF Form_1.Button_1.Enabled == .T.

   cSaveFile := GetFile ( {{"Save files (*.sav)", "*.sav"}}, ;
			'Load a Game From File', cCurDir, , .T. )

   IF !EMPTY(cSaveFile)

	DIRCHANGE( cCurDir )

	aData := {}
	cSaveFile := cFileNoExt(cSaveFile) + ".sav"

	BEGIN INI FILE cSaveFile
		GET aData SECTION "Game" ENTRY "Save"
	END INI

	FOR nr := 1 TO n * n
		cButton := "Number_" + STRZERO(nr, 2)
		DoMethod( "Form_1", cButton, "Release" )
	NEXT

	FOR row := 1 TO n
		FOR col := 1 TO n
			nr := (row - 1) * n + col
			cCaption := aData[nr][1]
			cButton := aData[nr][2]
			@ (col-1)*72 + 64, (row-1)*72 + 15 BUTTON &cButton ;
				OF Form_1 ;
				PICTURE cCaption ;
				ACTION PressButton() ;
				WIDTH 72 HEIGHT 72
		NEXT
	NEXT

   ENDIF

ENDIF

Return

*--------------------------------------------------------*
Static Procedure LoadData()
*--------------------------------------------------------*
LOCAL row, col, nr, cButton, cCaption, aBtn := LoadArray()

FOR row := 1 TO n
	FOR col := 1 TO n
		nr := (row - 1) * n + col
		cCaption := "B" + LTRIM(STR(aBtn[ nr ], 2))
		cButton := "Number_" + STRZERO(aBtn[ nr ], 2)
		@ (col-1)*72 + 64, (row-1)*72 + 15 BUTTON &cButton ;
			OF Form_1 ;
			PICTURE cCaption ;
			ACTION PressButton() ;
			WIDTH 72 HEIGHT 72
		AADD(aData, {cCaption, cButton})
	NEXT
NEXT

Return

*--------------------------------------------------------*
Static Function LoadArray()
*--------------------------------------------------------*
Local x, i := 1, aArr :={}

DO WHILE i <= n * n
	x := ROUND(Random(32767) / 32767 * n * n, 0)
	IF ASCAN(aArr, x) == 0 .AND. x > 0
		AADD(aArr, x)
		i++
	ENDIF
ENDDO

Return aArr

#ifdef DEBUG
*--------------------------------------------------------*
Static Procedure LoadWin()
*--------------------------------------------------------*
LOCAL row, col, nr, nBtn, cButton, cCaption

	FOR nr := 1 TO n * n
		cButton := "Number_" + STRZERO(nr, 2)
		DoMethod( "Form_1", cButton, "Release" )
	NEXT

	FOR row := 1 TO n
		FOR col := 1 TO n
			nr := (row - 1) * n + col
			nBtn := (col - 1) * n + row
			cButton := "Number_" + STRZERO(nBtn, 2)
			cCaption := "B" + LTRIM(STR(nBtn, 2))
			@ (col-1)*72 + 64, (row-1)*72 + 15 BUTTON &cButton ;
				OF Form_1 ;
				PICTURE cCaption ;
				ACTION PressButton() ;
				WIDTH 72 HEIGHT 72
				aData[nr][1] := cCaption
				aData[nr][2] := cButton
		NEXT
	NEXT

Return
#endif

*--------------------------------------------------------*
Procedure OpenTopTable()
*--------------------------------------------------------*
   LOCAL cDataBase := "Game15.dat", lFirst := .f.

   If !File( cDataBase )
      DBcreate( cDataBase, aBase )
      lFirst := .t.
   EndIF

   USE ( cDataBase ) NEW EXCLUSIVE

   If !NetErr()
      If !File( "Game2" + INDEXEXT() )
         INDEX ON UPPER(FIELD->NAME) TO Game2
      EndIF
      If !File( "Game1" + INDEXEXT() )
         INDEX ON DESCEND(FIELD->RESULT) TO Game1
      EndIF
      SET INDEX TO Game1, Game2
   Else
      MsgStop("Data file is locked", "Please, try again")
      Return
   EndIF

   IF lFirst
	APPEND BLANK
	NAME := "Author"
	RESULT := 100
	APPEND BLANK
	NAME := "NoName"
	RESULT := 1
   EndIF

Return

*--------------------------------------------------------*
Static Procedure SaveResult()
*--------------------------------------------------------*
LOCAL cName := cUserName, n

   PlayOK()
   cName := Ltrim( InputBox( 'Enter your name:', 'Save Result', cName, 15000, cName ) )

   IF EMPTY(cName)
	cName := "NoName"
   ELSE
	cUserName := cName
   ENDIF

   SET ORDER TO 2
   SEEK UPPER(cName)
   IF FOUND()
	n := RESULT
	RESULT := ++n
   ELSE
	APPEND BLANK
	NAME := cName
	RESULT := 1
   ENDIF
   SET ORDER TO 1

   StartAgain()

Return

*--------------------------------------------------------*
Static Procedure LoadTop()
*--------------------------------------------------------*
LOCAL aResult := {}, nr, cButton, cLabel

If !IsControlDefined( Button_7, Form_1 )

   aKeys := SAVEONKEY()

   GO TOP
   DO WHILE RecNo() <= 10 .AND. !EOF()
	Aadd( aResult, PADR( ALLTRIM( NAME ), 50, '.' ) + " " + ;
		Ltrim( Str( RESULT ) ) )
	SKIP
   ENDDO

   FOR nr := 1 TO 6
	cButton := "Button_" + LTRIM(STR(nr, 2))
	DoMethod( "Form_1", cButton, "Hide" )
   NEXT

   FOR nr := 1 TO n * n
	cButton := "Number_" + STRZERO(nr, 2)
	DoMethod( "Form_1", cButton, "Hide" )
   NEXT

   @ Form_1.Height - 32, 62 BUTTON Button_7 ;
	OF Form_1 ;
	PICTURE "OK" ;
	ACTION ClearTop() ;
	WIDTH 96 HEIGHT 24 FLAT ;
	NOXPSTYLE

   @ Form_1.Height - 32, 164 BUTTON Button_8 ;
	OF Form_1 ;
	PICTURE "Clear" ;
	ACTION ClearTop(.T.) ;
	WIDTH 96 HEIGHT 24 ;
	TOOLTIP "Clear Top Table" FLAT ;
	NOXPSTYLE

   FOR nr := 1 TO Len(aResult)

	cLabel := "Label_" + STRZERO(nr, 2)
	@ (nr-1)*32 + 42, 16 LABEL &cLabel ;
		OF Form_1 ;
		VALUE aResult[nr] ;
		WIDTH 280 HEIGHT 16 ;
		FONT "Arial" ;
		SIZE 12 ;
		BOLD ;
		FONTCOLOR WHITE ;
		TRANSPARENT
   NEXT

   Form_1.Button_7.SetFocus

   RedrawWindow( _HMG_MainHandle )

   ON KEY ALT+O OF Form_1 ACTION ClearTop()
   ON KEY ALT+C OF Form_1 ACTION ClearTop( .T. )

EndIf

Return

*--------------------------------------------------------*
Static Procedure ClearTop( lClear )
*--------------------------------------------------------*
LOCAL nr, cButton, cLabel

   DEFAULT lClear := .f.

   IF lClear
	GO 2
	DELETE NEXT (LastRec() - 1)
	PACK
   ENDIF

   RELEASE KEY ALT+O OF Form_1
   RELEASE KEY ALT+C OF Form_1

   Form_1.Button_7.Release
   Form_1.Button_8.Release

   FOR nr := 1 TO 6
	cButton := "Button_" + LTRIM(STR(nr, 2))
	DoMethod( "Form_1", cButton, "Show" )
   NEXT

   FOR nr := 1 TO n * n
	cButton := "Number_" + STRZERO(nr, 2)
	DoMethod( "Form_1", cButton, "Show" )
   NEXT

   FOR nr := 1 TO 10
	cLabel := "Label_" + STRZERO(nr, 2)
	If IsControlDefined( &cLabel, Form_1 )
		DoMethod( "Form_1", cLabel, "Release" )
	Else
		EXIT
	EndIf
   NEXT

   RESTONKEY(aKeys)

   RedrawWindow( _HMG_MainHandle )

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
Return MsgInfo( padc(PROGRAM + VERSION, 38) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	substr(MiniGuiVersion(), 1, 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 42), "About", IDI_MAIN, .F. )

*--------------------------------------------------------*
Static Function SAVEONKEY()
*--------------------------------------------------------*
LOCAL bKeyBlock, abSaveKeys := {}

   STORE KEY ALT+L OF Form_1 TO bKeyBlock
   AADD(abSaveKeys,bKeyBlock)
   RELEASE KEY ALT+L OF Form_1

   STORE KEY ALT+T OF Form_1 TO bKeyBlock
   AADD(abSaveKeys,bKeyBlock)
   RELEASE KEY ALT+T OF Form_1

   STORE KEY ALT+S OF Form_1 TO bKeyBlock
   AADD(abSaveKeys,bKeyBlock)
   RELEASE KEY ALT+S OF Form_1

   STORE KEY ALT+B OF Form_1 TO bKeyBlock
   AADD(abSaveKeys,bKeyBlock)
   RELEASE KEY ALT+B OF Form_1

   AADD(abSaveKeys,Form_1.FocusedControl)

Return abSaveKeys

*--------------------------------------------------------*
Static Procedure RESTONKEY(abSaveKeys)
*--------------------------------------------------------*
LOCAL cBtnFocus

   ON KEY ALT+L OF Form_1 ACTION Eval ( abSaveKeys[1] )
   ON KEY ALT+T OF Form_1 ACTION Eval ( abSaveKeys[2] )
   ON KEY ALT+S OF Form_1 ACTION Eval ( abSaveKeys[3] )
   ON KEY ALT+B OF Form_1 ACTION Eval ( abSaveKeys[4] )

   cBtnFocus := abSaveKeys[5]
   Form_1.&(cBtnFocus).SetFocus

Return

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{

	keybd_event(
		VK_RIGHT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
	keybd_event(
		VK_LEFT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	SendMessage( (HWND) hb_parnl(1) , WM_SYSCOMMAND , SC_MOVE ,10 );

}

#pragma ENDDUMP
