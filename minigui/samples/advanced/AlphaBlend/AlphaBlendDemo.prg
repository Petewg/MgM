/*
 * AlphaBlendDemo.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Memvar cImage1
Memvar cImage2

Function Main()
Local aSize1, aSize2 
Local bLoop := .F.

Public cImage1 := 'animals1.bmp'
Public cImage2 := 'animals2.bmp'

	aSize1 := BmpSize(cImage1); aSize2 := BmpSize(cImage2)

	DEFINE WINDOW Form_1 AT 0,0 ;
		WIDTH 430 ;
		HEIGHT 440 ;
		TITLE 'AlphaBlend Demo #1' ;
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

		@ 220,38 FRAME Frame_1 ;
			CAPTION "Simple AlphaBlend" ;
			WIDTH 350 HEIGHT 120 ;
			OPAQUE

		@ 260, 60 BUTTON Button_1 CAPTION "hdcDest IMG2" ;
			ACTION ( Form_1.Button_2.Enabled := FALSE, ;
                               ABlend( GetControlHandle( "Image_2", "Form_1" ), ;
                                       aSize1[1], aSize1[2],;
                                       GetControlHandle( "Image_1", "Form_1" ), ;
                                       aSize2[1], aSize2[2], 125) ) ;
			WIDTH 110 HEIGHT 26

		@ 260, 260 BUTTON Button_2 CAPTION "hdcDest IMG1" ;
			ACTION ( Form_1.Button_1.Enabled := FALSE, ;
			       ABlend( GetControlHandle( "Image_1", "Form_1" ), ;
                                       aSize1[1], aSize1[2], ;
                                       GetControlHandle( "Image_2", "Form_1" ), ;
                                       aSize2[1], aSize2[2], 125) );
			WIDTH 110 HEIGHT 26

		@ 300, 60 BUTTON Button_3 CAPTION "&Reset" ;
			ACTION ( Form_1.Image_1.Picture := cImage1, ;
                               Form_1.Image_2.Picture := cImage2, ;
                               Form_1.Button_1.Enabled := TRUE, ;
                               Form_1.Button_2.Enabled := TRUE, ;
                               Form_1.Button_4.Enabled := TRUE, ;
			       iif( bLoop, Form_1.Timer_1.Enabled := FALSE, Nil), ;
                               bLoop := FALSE ) ;
			WIDTH 110 HEIGHT 26 

		@ 300, 260 BUTTON Button_4 CAPTION "&Loop" ;
			ACTION ( Form_1.Image_1.Picture := cImage1, ;
                               Form_1.Image_2.Picture := cImage2,;
                               Form_1.Button_1.Enabled := FALSE, ;
                               Form_1.Button_2.Enabled := FALSE, ;
                               Form_1.Button_4.Enabled := FALSE,;
                               bLoop := TRUE, ;
                               Form_1.Timer_1.Enabled := TRUE );
			WIDTH 110 HEIGHT 26 

		@ 360, 150 BUTTON Button_5 CAPTION "&Close" ;
			ACTION ( Form_1.Timer_1.Release, ThisWindow.Release ) ;
			WIDTH 140 HEIGHT 26 DEFAULT

		DEFINE TIMER Timer_1 OF Form_1 INTERVAL 75;
		ACTION ( LoopBlend( GetControlHandle( "Image_1", "Form_1" ), ;
                                aSize1[1], aSize1[2], ;
                                GetControlHandle( "Image_2", "Form_1" ), ;
                                aSize2[1], aSize2[2]), cImage1, cImage2 ) ;

	END WINDOW

	Form_1.Timer_1.Enabled := .F.

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1 
        
Return Nil

/*
*/
Function ABlend( hWnd1, w1, h1, hWnd2, w2, h2, Alpha )
Local hdc1 := GetDC( hWnd1 ), hdc2 := GetDC( hWnd2 )

        AlphaBlend( hdc1, 0, 0, w1, h1, hdc2, 0, 0, w2, h2, Alpha )

	ReleaseDC( hWnd1, hdc1 )
	ReleaseDC( hWnd2, hdc2 )

Return Nil

/*
*/
Function LoopBlend( hWnd1, w1, h1, hWnd2, w2, h2 )
Local hdc1 := GetDC( hWnd1 ), hdc2 := GetDC( hWnd2 ), alpha := 10
Static i 

	DEFAULT i TO 10

	DO EVENTS
	IF i <> 750	
	        i := i + 10
		AlphaBlend( hdc1, 0, 0, w1, h1, hdc2, 0, 0, w2, h2, alpha )
	ELSE	
		Form_1.Image_1.Picture := cImage1
	        i := 10
	END

	ReleaseDC( hWnd1, hdc1 )
	ReleaseDC( hWnd2, hdc2 )

Return Nil

