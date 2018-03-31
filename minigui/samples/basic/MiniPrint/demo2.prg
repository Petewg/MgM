/*
 MINIPRINT DEMO
 (c) 2010 Roberto Lopez
*/

#include "minigui.ch"
#include "miniprint.ch"

#include "harupdf.ch"
#include "haruprint.ch"

Function Main

	Define Window Win1			;
		Row	10			;
		Col	10			;
		Width	400			;
		Height	400			;
		Title	'Miniprint and PDF Demo';
		MAIN				;
		On Init	Win1.Center()  

		@ 40 , 40 Button Button1	;
			Caption 'Start Print'	;
			On Click Button1Click()	;
			Default

		@ 80 , 40 Button Button2	;
			Caption 'PDF Print'	;
			On Click Button2Click()

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

			@ 120 , 10 PRINT IMAGE 'hmg.png' ;
				WIDTH 80 ;
				HEIGHT 40 ;
				STRETCH

			@ 120 , 110 PRINT IMAGE 'hmg.png' ;
				WIDTH 80 ;
				HEIGHT 40

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


Procedure Button2Click()
Local oPrint
Local oFont, oFont2, oFont3
Local oFontPrint, oFontPrint2
Local aLong, i

	PRINT oPrint TO HARU ;
		FILE "test.pdf" ;
		PREVIEW

		oFont := oPrint:DefineFont( 'Arial', 11 )
		oFont2 := oPrint:DefineFont( 'Arial', 12 )
		oFont3 := oPrint:DefineFont( 'Courier New', 36 )
		oFontPrint := oPrint:DefineFont( 'Arial', 72 )
		oFontPrint2 := oPrint:DefineFont( 'Arial', 20 )

		PRINTPAGE

			WITH OBJECT oPrint

			:CmSay( 2, 10, 'Hello PDF Print!', oFont3, 5.0,,, HPDF_TALIGN_CENTER )

			:CmRect( 5, 1, 5, 20, 1.5, RGB( 0 , 255 , 0 ) )
			:CmRect( 7, 1, 10, 20, 1.5, RGB( 0 , 0 , 255 ) )

			:CmSayBitmap( 12, 1, 'hmg.png', 8, 4 )
			:CmSayBitmap( 12, 11, 'hmg.png', 8, 8 )

			:CmRect( 21, 5, 22, 19, 2, RGB( 255 , 0 , 0 ) )

			aLong := { 'This is a' ;
				, 'long long' ;
				, 'text to test' ;
				, 'multiline' ;
				, 'print..' ;
				}
			FOR i := 1 TO Len( aLong )
				:CmSay( 20.5 + ( i - 1 ) * 0.43, 1.0, aLong[ i ], oFont, 5.0,RGB( 0 , 0 , 255 ) )
			NEXT

			:CmSay( 24, 1, 'Alignment 1', oFont2, 5.0,RGB( 255 , 0 , 0 ),, HPDF_TALIGN_LEFT )
			:CmSay( 25, 10, 'Alignment 2', oFont2, 5.0,RGB( 0 , 255 , 0 ),, HPDF_TALIGN_CENTER )
			:CmSay( 26, 20, 'Alignment 3', oFont2, 5.0,RGB( 0 , 0 , 255 ),, HPDF_TALIGN_RIGHT )

			END OBJECT

		ENDPAGE

		PRINTPAGE

			WITH OBJECT oPrint

			:CmSay( 3, 1.5, 'Another Page!', oFontPrint, 5.0,RGB( 0 , 0 , 255 ),, HPDF_TALIGN_LEFT )
			:CmSay( 12.8, 1.5, 'Another Page!', oFontPrint, 5.0,,, HPDF_TALIGN_LEFT )

			:CmLine( 16, 1, 16, 20, 2 )

			:CmSay( 20, 20, 'Another Page!', oFontPrint2, 5.0,,, HPDF_TALIGN_RIGHT )
			:CmSay( 21, 10, 'Another Page!', oFontPrint2, 5.0,,, HPDF_TALIGN_CENTER )

			END OBJECT

		ENDPAGE
			
	ENDPRINT

Return
