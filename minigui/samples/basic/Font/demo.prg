/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Procedure Main

	DEFINE FONT font_0 FONTNAME 'Times New Roman' SIZE 14 DEFAULT
	DEFINE FONT font_1 FONTNAME 'Arial' SIZE 24 ITALIC
	DEFINE FONT font_2 FONTNAME 'Verdana' SIZE 14 BOLD ANGLE -10 
	DEFINE FONT font_3 FONTNAME 'Courier' SIZE 12 BOLD

	DEFINE FONT dlg_font_0 FONTNAME 'Times New Roman' SIZE 14
	DEFINE FONT dlg_font_1 FONTNAME 'Arial' SIZE 24 ITALIC
	DEFINE FONT dlg_font_2 FONTNAME 'Verdana' SIZE 14 BOLD ANGLE -10 
	DEFINE FONT dlg_font_3 FONTNAME 'Courier' SIZE 12 BOLD

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 440 HEIGHT 380 ;
		TITLE 'New definitions of Fonts - by Janusz Pora' ;
		MAIN

		@ 10,10 LABEL Label_1 ;
		WIDTH 150 HEIGHT 30 ;
		VALUE 'Standard definiton font' ;
		FONT "Arial" SIZE 10 ;

		@ 50,10 LABEL Label_2 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Font 0 - New definition (default)' ;
		FONT "font_0" CENTERALIGN

		@ 90,10 LABEL Label_3 ;
		WIDTH 450 HEIGHT 50 ;
		VALUE 'Font 1 - New definition'  ;
	        FONT "font_1"

		@ 150,10 LABEL Label_4 ;
		WIDTH 250 HEIGHT 60 ;
		VALUE 'Font 2 - New definition'  ;
        	FONT "font_2"

		@ 220,10 LABEL Label_5 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Font 3 - New definition'  ;
	        FONT "font_3"

		@ 260,10 LABEL Label_6 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Default Font' 

		@ 300,300 BUTTON Btn1 ;
		CAPTION 'Font in Dialog' ;
        	ON CLICK DlgFont() ;
	        WIDTH 120 HEIGHT 30 DEFAULT

		@ 300,30 BUTTON Btn2 ;
		CAPTION 'Exit' ;
        	ON CLICK thiswindow.release

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main
    
Return 


Function DlgFont()

	DEFINE DIALOG DLG1 ;
        	OF Form_Main ;
		AT 100,100 ;
		WIDTH 400 HEIGHT 300 ;
		CAPTION 'Fonts in Dialog' 

		@ 10,10 LABEL Label_1 ;
	        ID 100 ;
		WIDTH 150 HEIGHT 30 ;
		VALUE 'Standard definiton font' ;
		FONT "Arial" SIZE 10 ;

		@ 50,10 LABEL Label_2 ;
        	ID 110 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Font 0 - New definition (default)' ;
		FONT "dlg_font_0" CENTERALIGN

		@ 90,10 LABEL Label_3 ;
	        ID 120 ;
		WIDTH 450 HEIGHT 50 ;
		VALUE 'Font 1 - New definition'  ;
        	FONT "dlg_font_1"

		@ 150,10 LABEL Label_4 ;
	        ID 130 ;
		WIDTH 250 HEIGHT 60 ;
		VALUE 'Font 2 - New definition'  ;
        	FONT "dlg_font_2"

		@ 220,10 LABEL Label_5 ;
	        ID 140 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Font 3 - New definition'  ;
        	FONT "dlg_font_3"

		@ 260,10 LABEL Label_6 ;
	        ID 150 ;
		WIDTH 250 HEIGHT 30 ;
		VALUE 'Default Font' 

    END DIALOG

Return Nil
