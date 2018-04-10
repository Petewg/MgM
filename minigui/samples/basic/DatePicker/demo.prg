/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main
	Local ctrl

	SET CENTURY ON
	SET DATE GERMAN

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 400 ;
		TITLE "MiniGUI DatePicker Demo" ;
		MAIN ;
		FONT "Arial" SIZE 10
/*
		@ 10,10 DATEPICKER Date_1 ;
		VALUE CTOD("01/01/2001") ;
		TOOLTIP "DatePicker Control" ;
		TITLEBACKCOLOR BLACK ;
		TITLEFONTCOLOR YELLOW ;
		TRAILINGFONTCOLOR PURPLE
*/
		DEFINE DATEPICKER Date_1
			ROW	10
			COL	10
			VALUE Date()
			TOOLTIP 'DatePicker Control' 
			SHOWNONE .F.
		IF ! ISVISTAORLATER()
			TITLEBACKCOLOR BLACK
			TITLEFONTCOLOR YELLOW
			TRAILINGFONTCOLOR PURPLE
		ENDIF
		END DATEPICKER

		@ 10,310 DATEPICKER Date_2 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control ShowNone RightAlign" ;
		SHOWNONE ;
		RIGHTALIGN

		@ 230,10 DATEPICKER Date_3 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control UpDown" ;
		UPDOWN

		@ 230,310 DATEPICKER Date_4 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control ShowNone UpDown" ;
		SHOWNONE ;
		UPDOWN

		ON KEY F2 ACTION ( ctrl := ThisWindow.FocusedControl, MsgInfo( Form_1.&ctrl..Value ) ) 

	END WINDOW

	IF ! ISVISTAORLATER()
		Form_1.Date_1.FontColor := RED
		Form_1.Date_1.BackColor := YELLOW
	ENDIF

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
