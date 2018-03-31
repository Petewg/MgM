/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 366 + GetBorderWidth() ;
		HEIGHT 160 + GetTitleHeight() + 2 * GetBorderHeight() ;
		TITLE "MiniGUI ProgressBar Style Marquee Demo" ;
		MAIN ;
		FONT "Arial" SIZE 10 

		@ 020,031 PROGRESSBAR Progress_0 	;
			RANGE 0 , 100 			;
			WIDTH 300 			;
			HEIGHT 26 			;
			TOOLTIP "ProgressBar Marquee"	;
			STYLE MARQUEE

		DEFINE PROGRESSBAR Progress_1
			ROW 60
			COL 31
			WIDTH 300
			HEIGHT 26
			RANGEMIN 0
			RANGEMAX 100
			VALUE 0
			MARQUEE .T.
			VELOCITY 0
		END PROGRESSBAR

		@ 110,30 BUTTONEX BUTTON_1 ;
			CAPTION "Start" ;
			ACTION Form_1.Progress_1.Velocity := 20 ;
			WIDTH 80 ;
			HEIGHT 28

		@ 110,120 BUTTONEX BUTTON_2 ;
			CAPTION "Stop" ;
			ACTION Form_1.Progress_1.Velocity := 0 ;
			WIDTH 80 ;
			HEIGHT 28

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
