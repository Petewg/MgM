/*
* HMG Embedded Child Window Demo
* (c) 2002-2010 Roberto Lopez
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Win_0 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Panel Window Demo 3' ;
		WINDOWTYPE MAIN  

		DEFINE BUTTON BUTTON_1
			ROW		160
			COL		90
			WIDTH		200
			CAPTION		'Click Me!'
			ACTION		Test()
			DEFAULT		.T.
		END BUTTON

	END WINDOW

	Center Window Win_0

	Activate Window Win_0

Return Nil

Procedure Test

	DEFINE WINDOW Win_1 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 500 ;
		HEIGHT 300 ;
		TITLE 'Panel in Modal Window' ;
		WINDOWTYPE MODAL

		ON KEY ESCAPE ACTION ThisWindow.Release

		DEFINE WINDOW Win_2 ;
			ROW 30 ;
			COL 30 ;
			WIDTH 300 ;
			HEIGHT 200 ;
			VIRTUAL WIDTH 400 ;
			VIRTUAL HEIGHT 400 ;
			WINDOWTYPE PANEL

			DEFINE LABEL LABEL_1
				ROW		10
				COL		10
				VALUE		'Panel window...'
				WIDTH		300
			END LABEL

			DEFINE BUTTON BUTTON_1
				ROW		40
				COL		10
				CAPTION		'Click Me!'
				ACTION		MsgInfo('Clicked!')
				DEFAULT		.T.
			END BUTTON

			DEFINE LABEL LABEL_2
				ROW		90
				COL		10
				VALUE		"Can do this!"
				WIDTH		300
			END LABEL

			DEFINE TEXTBOX TEXT_1
				ROW		120
				COL		10
				VALUE		'Test'
			END TEXTBOX

			DEFINE TEXTBOX TEXT_2
				ROW		150
				COL		10
				VALUE		'Test'
			END TEXTBOX

			DEFINE TEXTBOX TEXT_3
				ROW		180
				COL		10
				VALUE		'Test'
			END TEXTBOX

			DEFINE TEXTBOX TEXT_4
				ROW		210
				COL		10
				VALUE		'Test'
			END TEXTBOX

			DEFINE TEXTBOX TEXT_5
				ROW		240
				COL		10
				VALUE		'Test'
			END TEXTBOX

		END WINDOW

		DEFINE TEXTBOX TEXT_1
			ROW		300
			COL		10
			VALUE		'Test'
		END TEXTBOX

	END WINDOW

	Center Window Win_1

	// Panel windows are automatically activated through its parent
	// so, only Win_1 must be activated.

	Activate Window Win_1

Return
