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
		TITLE '@...ANIMATEBOX Test' ;
		MAIN ;
		BACKCOLOR TEAL

		@ 08,40 ANIMATEBOX Ani_1 ;
			WIDTH 32 ;
			HEIGHT 32 ;
			FILE 'Process.Avi' ;
			TRANSPARENT BACKCOLOR TEAL ;
			NOBORDER

		@ 60,10 BUTTON Button_D1 ;
			CAPTION "Play    ANI" ;
			ACTION Form_1.Ani_1.Play() 

		@ 90,10 BUTTON Button_D2 ;
			CAPTION "Seek    ANI" ;
			ACTION Form_1.Ani_1.Seek(3)  

		@ 120,10 BUTTON Button_D3 ;
			CAPTION "Stop    ANI" ;
			ACTION Form_1.Ani_1.Stop() 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
