/*
 * DrawBoxGradient.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define NONE      0
#define BOX       2
#define PANEL     3

PROCEDURE Main ()

	DEFINE WINDOW x ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 420 ;
		TITLE "Draw Box and Panel Gradient Sample" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

		DRAW GRADIENT IN WINDOW x AT 20,20 TO 200,300 BORDER BOX
		@ 220, 110 LABEL Label_1 VALUE "Gradient Box In" AUTOSIZE TRANSPARENT

		DRAW GRADIENT IN WINDOW x AT 20,320 TO 200,610;
                                          VERTICAL BORDER PANEL
		@ 220, 410 LABEL Label_2 VALUE "Gradient Panel" AUTOSIZE TRANSPARENT

		DRAW GRADIENT IN WINDOW x AT 250,20 TO 278,300;
                                          VERTICAL BORDER BOX ;
                                          BEGINCOLOR {255, 255, 255} ;
                                          ENDCOLOR {220, 220, 220}  

		DRAW GRADIENT IN WINDOW x AT 250,320 TO 278,610;
                                          VERTICAL BORDER PANEL ;
                                          BEGINCOLOR {255, 255, 255} ;
                                          ENDCOLOR {200, 200, 216}  

		DRAW GRADIENT IN WINDOW x AT 300,20 TO 302,316;
                                          BORDER NONE ;
                                          BEGINCOLOR {250, 0, 0} ;
                                          ENDCOLOR {130, 0, 0}  

		DRAW GRADIENT IN WINDOW x AT 300,316 TO 302,610;
                                          BORDER NONE ;
                                          BEGINCOLOR {130, 0, 0} ;
                                          ENDCOLOR {250, 0, 0}  

		@ 330, 240 BUTTON Button_1 ;
			CAPTION "&Close" ;
			ACTION ThisWindow.Release ;
			WIDTH 150 HEIGHT 26 DEFAULT

	END WINDOW

	Center Window x

	Activate Window x
Return
