/*
* File:         Display all available characters
* Author:       Dr Joe Fanucchi <drjoe@meditrax.com>
*/

#include "minigui.ch"

DECLARE WINDOW ShowChars
DECLARE WINDOW ShowWings

Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "Show All Characters Demo" ;
		MAIN NOMAXIMIZE NOSIZE

	@ 10,10 BUTTON Button_1 CAPTION "Show Chars" ACTION ShowChars()
	@ 50,10 BUTTON Button_2 CAPTION "Show Wings" ACTION ShowWings()
	@ 90,10 BUTTON Button_3 CAPTION "Exit" ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


*----------------------------
FUNCTION ShowChars
*----------------------------
LOCAL cText := ""
LOCAL cs4sp := SPACE( 4 )
LOCAL i

IF IsWindowDefined( ShowChars )
	ShowChars.Release
ENDIF

FOR i := 32 TO 249 STEP 7 // show all chars from 32 to 255
	cText += "CHR " + LTRIM(STR(i)) + " is " + CHR(i) + cs4sp ;
	+ "CHR " + LTRIM(STR(1+i)) + " is " + CHR(1+i) + cs4sp ;
	+ "CHR " + LTRIM(STR(2+i)) + " is " + CHR(2+i) + cs4sp ;
	+ "CHR " + LTRIM(STR(3+i)) + " is " + CHR(3+i) + cs4sp ;
	+ "CHR " + LTRIM(STR(4+i)) + " is " + CHR(4+i) + cs4sp ;
	+ "CHR " + LTRIM(STR(5+i)) + " is " + CHR(5+i) + cs4sp ;
	+ "CHR " + LTRIM(STR(6+i)) + " is " + CHR(6+i) + cs4sp + CRLF
NEXT

DEFINE WINDOW ShowChars ;
	AT 0, 0 ;
	WIDTH 800 HEIGHT 544 ;
	TITLE 'ASCII Characters' ;
	FONT "MS Sans Serif" SIZE 9

	@ 10,10 LABEL Box_Chars ;
            WIDTH 700 ;
            HEIGHT 500 ;
            VALUE cText

END WINDOW

CENTER WINDOW ShowChars
ACTIVATE WINDOW ShowChars

RETURN NIL

*----------------------
FUNCTION ShowWings
*----------------------
LOCAL i
LOCAL nRow
LOCAL cLblName
LOCAL cChrName

IF IsWindowDefined( ShowWings )
	ShowWings.Release
ENDIF

DEFINE WINDOW ShowWings ;
	AT 0, 0 ;
	WIDTH 800 HEIGHT 544 ;
	TITLE 'WingDings Characters' ;
	FONT "Arial" SIZE 8

	FOR nRow := 1 TO 32
		FOR i := 1 TO 7
			cLblName := "Lbl_" + STRZERO(((nRow - 1)*7)+i+31,3)
			@(20+(nRow*14)),(i*100)-60 LABEL &cLblName ;
				VALUE "CHR " + LTRIM(STR(((nRow-1)*7)+i+31))+":" ;
				HEIGHT 18 WIDTH 60 ;
				RIGHTALIGN

			cChrName := "Chr_" + STRZERO(((nRow-1)*7)+i+31,3)
			@(20+(nRow*14)),(i*100)+1 LABEL &cChrName ;
				VALUE CHR(((nRow-1)*7 )+i+31 ) ;
				HEIGHT 18 WIDTH 16 ;
				FONT "WingDings" SIZE 9
		NEXT i
	NEXT nRow

END WINDOW

CENTER WINDOW ShowWings
ACTIVATE WINDOW ShowWings

RETURN NIL
