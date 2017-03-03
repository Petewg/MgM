/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 300 ;
		HEIGHT 300 ;
		TITLE 'REGIONS Demo (based upon a Contribution of Richard Rylko <rrylko@poczta.onet.pl>)' ;
		MAIN 

		@ 040,95 BUTTON Button_1 ;
		CAPTION "RoundRect" ;
	    	ACTION SET REGION OF Form_1 ROUNDRECT 20,20,300,300 

		@ 070,95 BUTTON Button_2 ;
		CAPTION "Rectangular" ;
	    	ACTION SET REGION OF Form_1 RECTANGULAR 0,50,250,280 

		@ 100,95 BUTTON Button_3 ;
		CAPTION "Elliptic" ;
		ACTION SET REGION OF Form_1 ELLIPTIC 0,0,300,300

		@ 130,95 BUTTON Button_4 ;
		CAPTION "Polygonal" ;
		ACTION SET REGION OF Form_1 POLYGONAL {{150,0},{300,300},{0,100},{300,100},{0,300}}

		@ 160,95 BUTTON Button_5 ;
		CAPTION "Reset" ;
		ACTION SET REGION OF Form_1 RESET

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

RETURN Nil

