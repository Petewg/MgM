/*
 * MiniGUI Demo
 * (c) 2003 Roberto Lopez 
*/

#include "minigui.ch"

Function main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
                TITLE 'ANIMATEBOX Test' ;
		MAIN

		DEFINE ANIMATEBOX Ani_1
			ROW	20
			COL	200
			PARENT	Form_1
			WIDTH	300
			HEIGHT	80
			FILE	'Sample.Avi'
		END ANIMATEBOX

		DEFINE BUTTON Button_D1
			ROW	60
			COL	10
			CAPTION	"Play ANI"
			ACTION	Form_1.Ani_1.Play() 
		END BUTTON
		
		DEFINE BUTTON Button_D2
			ROW	90
			COL	10
			CAPTION	"Seek ANI"
			ACTION	Form_1.Ani_1.Seek(3) 
		END BUTTON

		DEFINE BUTTON Button_D3
			ROW	120
			COL	10
			CAPTION	"Stop ANI"
			ACTION	Form_1.Ani_1.Stop() 
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

