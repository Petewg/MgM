/*
 * TransparentBltDemo.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Function Main()
Local cImage1 := 'animals1.bmp'
Local cImage2 := 'animals2.bmp'
Local aSize1, aSize2 

	aSize1 := BmpSize(cImage1); aSize2 := BmpSize(cImage2)

	DEFINE WINDOW Form_1 AT 0,0 ;
		WIDTH 430 ;
		HEIGHT 440 ;
		TITLE 'TransparentBlt Demo' ;
                NOMAXIMIZE NOSIZE ;
		MAIN

		DRAW PANEL IN WINDOW Form_1 ;
		AT 38,38 TO 38+aSize1[2]+2,38+aSize1[1]+2

		DEFINE IMAGE Image_1
			ROW	40
			COL	40
			WIDTH	aSize1[1]
			HEIGHT	aSize1[2]
			PICTURE	cImage1
			STRETCH	.F.
		END IMAGE

		DRAW PANEL IN WINDOW Form_1 ;
		AT 38,238 TO 38+aSize2[2]+2,238+aSize2[1]+2

		DEFINE IMAGE Image_2
			ROW	40
			COL	240
			WIDTH	aSize2[1]
			HEIGHT	aSize2[2]
			PICTURE	cImage2
			STRETCH	.F.
		END IMAGE

		@ 260, 60 BUTTON Button_1 CAPTION "TransBlt" ;
			ACTION ( TBlt( GetControlHandle( "Image_2", "Form_1" ), ;
                                     aSize1[1], aSize1[2],;
                                     GetControlHandle( "Image_1", "Form_1" ), ;
                                     aSize2[1], aSize2[2], RGB(255, 255, 255) ) ) ;
			WIDTH 110 HEIGHT 26

		@ 300, 60 BUTTON Button_3 CAPTION "&Reset" ;
			ACTION ( Form_1.Image_1.Picture := cImage1, ;
                               Form_1.Image_2.Picture := cImage2 ) ;
			WIDTH 110 HEIGHT 26 

		@ 300, 260 BUTTON Button_4 CAPTION "&Close" ;
			ACTION ( ThisWindow.Release ) ; 
			WIDTH 110 HEIGHT 26 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1 
        
Return Nil

/*
*/
Function TBlt( hWnd1, w1, h1, hWnd2, w2, h2, color )
Local hdc1 := GetDC( hWnd1 ), hdc2 := GetDC( hWnd2 )

        TransparentBlt( hdc1, 0, 0, w1, h1, hdc2, 0, 0, w2, h2, color )

	ReleaseDC( hWnd1, hdc1 )
	ReleaseDC( hWnd2, hdc2 )

Return Nil

