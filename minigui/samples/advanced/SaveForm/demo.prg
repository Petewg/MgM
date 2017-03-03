/*
 *
 * Copyright 2002 Roberto Lopez <mail.box.hmg@gmail.com>
 * http://www.hmgforum.com//
 * Form Print demo : BP Dave bpd2000@gmail.com
*/


#include "hmg.ch"
//#include "FormPrint.prg"
#include "SaveForm.prg"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Save Window Form!' ;
		MAIN 

    ON KEY ESCAPE ACTION ThisWindow.Release
    
		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Select Image' ACTION Form_1.Image_1.Picture := Getfile ( { {'gif Files','*.gif'} } , {'jpg Files','*.jpg'} , 'Select Image' ) 
			END POPUP
			POPUP 'Save'
				ITEM 'Save Window' ACTION (SaveForm ( "FORM_1" , GetStartUpFolder() + "\test.bmp" , 0 , 0 , 600 , 425 ) , msginfo("Windows Form Saves as test.bmp"))
			END POPUP           
      END MENU
      

		DEFINE IMAGE Image_1
			ROW	0
			COL	0
			HEIGHT	430
		        WIDTH	635
			PICTURE	'HMGLogo.gif'
			STRETCH	.F.
		END IMAGE

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1 

Return

