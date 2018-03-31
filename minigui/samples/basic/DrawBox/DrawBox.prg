/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW w ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE "Draw Box And Panel Sample By Grigory Filatov" ;
		MAIN NOMAXIMIZE NOSIZE ;
		BACKCOLOR iif(ISVISTAORLATER(), {220, 220, 220}, Nil)

		DRAW BOX			;
			IN WINDOW w		;
			AT 20,20		;
			TO 200,300

		@ 110, 140 LABEL Label_1 VALUE "Box In" AUTOSIZE TRANSPARENT

		DRAW PANEL			;
			IN WINDOW w		;
			AT 20,320		;
			TO 200,610

		@ 110, 440 LABEL Label_2 VALUE "Panel" AUTOSIZE TRANSPARENT

		@ 220,20 FRAME Frame_1 ;
			CAPTION "Frame Title" ;
			WIDTH 280 ;
			HEIGHT 180 TRANSPARENT

		@ 220,320 FRAME Frame_2 ;
			WIDTH 290 ;
			HEIGHT 180

		@ 310, 410 LABEL Label_3 VALUE "Frame without title" AUTOSIZE TRANSPARENT

		@ 414, 530 BUTTON Button_1 ;
			CAPTION "&Close" ;
			ACTION ThisWindow.Release ;
			WIDTH 78 HEIGHT 26 DEFAULT

	END WINDOW

	Center Window w

	Activate Window w

Return
