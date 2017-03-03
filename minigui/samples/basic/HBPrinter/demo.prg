/*
 * MiniGUI HBPRINTER Simple Demo
*/

#include "minigui.ch"
#include "winprint.ch"

*----------------------*
Function Main
*----------------------*

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'HBPRINTER Simple Demo' ;
                ICON 'zzz_PrintIcon' ;
		MAIN

		DEFINE MAIN MENU
			POPUP 'File'
				MENUITEM 'Test' ACTION HBPRINTERDEMO()
				SEPARATOR
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return Nil

*----------------------*
PROCEDURE HBPRINTERDEMO
*----------------------*
Local aColor [10], i

	aColor [1] := YELLOW	
	aColor [2] := PINK	
	aColor [3] := RED	
	aColor [4] := FUCHSIA	
	aColor [5] := BROWN	
	aColor [6] := ORANGE	
	aColor [7] := GREEN	
	aColor [8] := PURPLE	
	aColor [9] := BLACK	
	aColor [10] := BLUE

	// Initialize print system

	INIT PRINTSYS

	// Select a default printer

	SELECT DEFAULT

	// Let the user to select a printer via dialog

	// SELECT BY DIALOG 

	// If the error code is not zero cancel print

	IF HBPRNERROR != 0 
		MSGSTOP ('Print Cancelled!')
		RETURN
	ENDIF

	// The best way to get the most similiar printout on various printers 
	// is to use SET UNITS MM, remembering to use margins large enough for 
	// all printers.

	SET UNITS MM    		// Sets @... units to milimeters

	SET PAPERSIZE DMPAPER_A4	// Sets paper size to A4

	SET ORIENTATION PORTRAIT	// Sets paper orientation to portrait

	SET BIN DMBIN_FIRST    		// Use first bin

	SET QUALITY DMRES_HIGH		// Sets print quality to high

	SET COLORMODE DMCOLOR_COLOR	// Set print color mode to color

	SET COPIES TO 2    		// Set print quantity of copies

	SET PREVIEW ON			// Enables print preview

	SET PREVIEW RECT MAXIMIZED	// Maximized preview window

	// Create a font for use with @...SAY command
	DEFINE FONT "TitleFont" NAME "Courier New" SIZE 24 BOLD

	START DOC

		FOR i:=1 TO LEN(aColor)

			START PAGE

				@ 20,20,50,190 RECTANGLE

				@ 25,25 PICTURE "hmglogo.gif" SIZE 20,15

				@ 35,60 SAY "HBPRINTER SIMPLE DEMO" ;
					FONT "TitleFont" ;
					COLOR RED ;
					TO PRINT

				@ 140,60 SAY "Page Number :" + Str(i, 2) ;
					FONT "TitleFont" ;
					COLOR aColor [i] ;
					TO PRINT

				@ 270,20,270,190 LINE

			END PAGE

		NEXT

	END DOC

	// Releases print system

	RELEASE PRINTSYS

RETURN
