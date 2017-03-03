/*
 MINIPRINT DEMO
 (c) 2010 Roberto Lopez
*/

#include "minigui.ch"
#include "miniprint.ch"

Function Main

	Define Window Win1			;
		Row	10			;
		Col	10			;
		Width	400			;
		Height	400			;
		Title	'Miniprint Demo'	;
		MAIN				;
		On Init	Win1.Center()  

		@ 40 , 40 Button Button1	;
			Caption 'Start Print'	;
			On Click Button1Click()	;
			Default

	End Window

	Activate Window Win1

Return Nil


Procedure Button1Click()
Local cPrinter
Local nLastCol

	cPrinter := GetPrinter()

	if Empty( cPrinter )
		Return
	endif

	SELECT PRINTER cPrinter PREVIEW

	nLastCol := GetPrintableAreaWidth() - iif(IsWinNT(), 2, 10)

	START PRINTDOC

		START PRINTPAGE
			@ 20 , 10 PRINT 'Hello HMG MiniPrint!' ;
				TO 40 , nLastCol ;
				FONT 'Courier New' ;
				SIZE 36 ;
				CENTER

			@ 50 , 10 PRINT LINE ;
				TO 50 , nLastCol ;
				COLOR { 0 , 255 , 0 } 

			@ 70 , 10 PRINT RECTANGLE ;
				TO 100 , nLastCol ;
				COLOR { 0 , 0 , 255 }

			@ 120 , 10 PRINT IMAGE 'hmg.bmp' ;
				WIDTH 80 ;
				HEIGHT 40 ;
				STRETCH

			@ 120 , 110 PRINT IMAGE 'hmg.bmp' ;
				WIDTH 80 ;
				HEIGHT 40 ;

			@ 210 , 50 PRINT RECTANGLE ;
				TO 220 , 190 ;
				COLOR { 255 , 0 , 0 } ;
				PENWIDTH 2

			@ 205 , 10 PRINT 'This is a long long text to test multiline print..' ;
				TO 235 , 30 ;
				FONT 'Arial' ;
				SIZE 11 ;
				COLOR { 0 , 0 , 255 }

			@ 240 , 10 PRINT 'Alignment 1' ;
				TO 250 , nLastCol ;
				FONT 'Arial' ;
				SIZE 12 ;
				COLOR { 255 , 0 , 0 } 

			@ 250 , 10 PRINT 'Alignment 2' ;
				TO 260 , nLastCol ;
				FONT 'Arial' ;
				SIZE 12 ;
				COLOR { 0 , 255 , 0 } ;
				CENTER

			@ 260 , 10 PRINT 'Alignment 3' ;
				TO 270 , nLastCol ;
				FONT 'Arial' ;
				SIZE 12 ;
				COLOR { 0 , 0 , 255 } ;
				RIGHT

		END PRINTPAGE

		START PRINTPAGE

			@ 30 , 15 PRINT 'Another Page!' ;
				FONT 'Arial' ;
				SIZE 72 ;
				COLOR { 0 , 0 , 255 } 

			@ 130 , 15 PRINT 'Another Page!' ;
				FONT 'Arial' ;
				SIZE 72 ;

			@ 160 , 10 PRINT LINE ;
				TO 160 , nLastCol ;

			@ 200 , nLastCol PRINT 'Another Page!' ;
				FONT 'Arial' ;
				SIZE 20 ;
				RIGHT			

			@ 210 , 100 PRINT 'Another Page!' ;
				FONT 'Arial' ;
				SIZE 20 ;
				CENTER

		END PRINTPAGE

	END PRINTDOC

Return
