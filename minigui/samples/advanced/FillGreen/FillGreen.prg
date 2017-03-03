/*
 * FillGreen.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Function Main()
Local aColor1 := {0,200,0}, aColor2 := {0,0,0}
Local nColor1 := RGB ( aColor1[1], aColor1[2], aColor1[3] )
Local nColor2 := RGB ( aColor2[1], aColor2[2], aColor2[3] )

	DEFINE WINDOW Form_1 ;
		AT 0,0;
		WIDTH GetDesktopWidth() HEIGHT GetDesktopHeight() ;
		TITLE 'Demo for Gradient Background';
		ICON 'setup.ico' ;
		MAIN ; 
		ON RELEASE ExitGradientFunc() ;
		NOMAXIMIZE NOSIZE ;
		ON PAINT ( FillGreen(_HMG_MainHandle, nColor1, nColor2 ),;
                           TextPaint() )

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

/*
*/
function TextPaint()

      DRAW TEXT IN WINDOW Form_1 AT 10, 14 ;
		VALUE "Program Setup" ;
		FONT "Verdana" SIZE 24 BOLD ITALIC ;
		FONTCOLOR WHITE TRANSPARENT

      DRAW TEXT IN WINDOW Form_1 AT Form_1.Height - 54, Form_1.Width - 250 ;
		VALUE "Copyright (c) 2007 by P.Chornyj" ;
		FONT "Tahoma" SIZE 10 ITALIC ;
		FONTCOLOR WHITE TRANSPARENT

Return Nil

/*
*/
Function Fillgreen( hWnd, clr1, clr2 )
LOCAL hDC, pps

	hDC := BeginPaint( hWnd, @pps )

	FillGradient( hDC,;
                      0, 0,;
                      Form_1.Height, Form_1.Width, .T.,;
                      clr1, clr2 )

	EndPaint( hWnd, pps )
	ReleaseDC( hWnd, hDC )

Return Nil
