/*
* MiniGUI InputMask Demo
* (c) 2003 Roberto lopez
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 40,40 ;
		WIDTH 450 ;
		HEIGHT 250 ;
		TITLE 'InputMask Demo' ;
		MAIN

		@ 10,10 LABEL label_1 ;
			VALUE 'Simple Code:' ;
			WIDTH 100 VCENTERALIGN

		@ 10,120 TEXTBOX text_1 ;
			VALUE 'ZFA-17529/Z' ;
			INPUTMASK 'AAA-99999/A'

		@ 10,290 LABEL label_1b ;
			VALUE 'AAA-99999/A' 
			WIDTH 100

		@ 40,10 LABEL label_2 ;
			VALUE 'Brazil ID:' ;
			WIDTH 100 VCENTERALIGN

		@ 40,120 TEXTBOX text_2 ;
			VALUE '123.456.789-12' ;
			INPUTMASK '999.999.999-99' 

		@ 40,290 LABEL label_2b ;
			VALUE '999.999.999-99' 

		@ 70,10 LABEL label_3 ;
			VALUE 'Argentina ID:' ;
			WIDTH 100 VCENTERALIGN

		@ 70,120 TEXTBOX text_3 ;
			VALUE '12.123.123' ;
			INPUTMASK '99.999.999' 

		@ 70,290 LABEL label_3b ;
			VALUE '99.999.999' 


		@ 100,10 LABEL label_4 ;
			VALUE 'Credit Card:' ;
			WIDTH 100 VCENTERALIGN

		@ 100,120 TEXTBOX text_4 ;
			WIDTH 150 ;
			VALUE '1234-1234-1234-1234' ;
			INPUTMASK '9999-9999-9999-9999' 

		@ 100,290 LABEL label_4b ;
			VALUE '9999-9999-9999-9999' ;
			WIDTH 160

		@ 130,10 LABEL label_5 ;
			VALUE 'Complex Code:' ;
			WIDTH 100 VCENTERALIGN

		@ 130,120 TEXTBOX text_5 ;
			WIDTH 130 ;
			VALUE 'JZ-123/4(X-DKS)' ;
			INPUTMASK 'AA-999/9(A-AAA)'  

		@ 130,290 LABEL label_5b ;
			VALUE 'AA-999/9(A-AAA)' 

		@ 160,10 LABEL label_6 ;
			VALUE 'Phone Number:' ;
			WIDTH 100 VCENTERALIGN

		@ 160,120 TEXTBOX text_6 ;
			WIDTH 130 ;
			VALUE '(651) 384 - 8372' ;
			INPUTMASK '(999) 999 - 9999'  

		@ 160,290 LABEL label_6b ;
			VALUE '(999) 999 - 9999'  

	END WINDOW

	ACTIVATE WINDOW Form_1

Return Nil
