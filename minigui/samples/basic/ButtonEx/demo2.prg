/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI SplitBox Demo' ;
		MAIN NOMAXIMIZE ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready - Click / Drag Grippers And Enjoy !' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&Help'
				ITEM 'About'	ACTION MsgInfo ("MiniGUI SplitBox Demo","A COOL Feature ;)") 
			END POPUP
		END MENU

		DEFINE SPLITBOX 

			DEFINE WINDOW SplitChild_1 ;
				WIDTH 0 ;
				HEIGHT 350 ;
				TITLE 'SplitChild 1' ;
				SPLITCHILD ;
				GRIPPERTEXT 'Split 1' 
				
				DEFINE GRID Grid_1
					ROW	30
					COL	10
					WIDTH 410 
					HEIGHT 140 
					HEADERS {'Last Name','First Name'} 
					WIDTHS {220,220}
					ITEMS { {'Simpson','Homer'} , {'Mulder','Fox'} } 
					VALUE 1 
					TOOLTIP 'Grid Control' 
				END GRID

				DEFINE BUTTONEX ButtonEx_1
					ROW 180
					COL 50
					WIDTH 100
					HEIGHT 25
					CAPTION "Cool Button"
					PICTURE "res\button14.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR {0,128,0}
					BACKCOLOR {240,255,240}
					LEFTTEXT .t.
				END BUTTONEX

				DEFINE BUTTONEX ButtonEx_2
					ROW 180
					COL 160
					WIDTH 100
					HEIGHT 25
					CAPTION "URL"
					PICTURE "res\mse.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR BLUE
					FONTUNDERLINE .t.
					BACKCOLOR {230,230,255}
				END BUTTONEX

				DEFINE BUTTONEX ButtonEx_3
					ROW 180
					COL 270
					WIDTH 110
					HEIGHT 25
					CAPTION "Folder select"
					PICTURE "res\button6.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR YELLOW
					BACKCOLOR {128,0,0}
					FLAT .t.
					NOHOTLIGHT .t.
				END BUTTONEX

			END WINDOW 

			DEFINE WINDOW SplitChild_2 ;
				WIDTH 0 ;
				HEIGHT 350 ;
				TITLE 'SplitChild 2' ;
				SPLITCHILD ;
				GRIPPERTEXT 'Split 2' 

				DEFINE FRAME Tab_Frame_1
					ROW	45
					COL	80
					WIDTH 130 
					HEIGHT 110 
					OPAQUE .T.
				END FRAME

				DEFINE LABEL Label_1
					ROW	55
					COL	90
					VALUE 'Label !!!' 
					WIDTH 100 
					HEIGHT 27 	
				END LABEL

				DEFINE CHECKBOX Check_1
					ROW	80
					COL	90
					CAPTION 'Check 1' 
					VALUE .T. 
					TOOLTIP 'CheckBox' 
				END CHECKBOX

				DEFINE SLIDER Slider_1
					ROW	115
					COL	85
					RANGEMIN	1
					RANGEMAX	10
					VALUE 5 
					TOOLTIP 'Slider' 
				END SLIDER

				DEFINE FRAME TabFrame_2
					ROW	45
					COL	240
					WIDTH 125 
					HEIGHT 110 
					OPAQUE .T.
				END FRAME

				DEFINE RADIOGROUP Radio_1
					ROW	50
					COL	260
					OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
					VALUE 1 
					WIDTH 100 
					SPACING 25
					TOOLTIP 'RadioGroup'
				END RADIOGROUP

				DEFINE BUTTONEX ButtonEx_1a
					ROW 180
					COL 50
					WIDTH 100
					HEIGHT 25
					CAPTION "Cool Button"
					PICTURE "res\button14.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR {0,128,0}
					BACKCOLOR {240,255,240}
					LEFTTEXT .f.
				END BUTTONEX

				DEFINE BUTTONEX ButtonEx_2a
					ROW 180
					COL 160
					WIDTH 100
					HEIGHT 25
					CAPTION "URL"
					PICTURE "res\mse.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR BLUE
					FONTUNDERLINE .t.
					BACKCOLOR {230,230,255}
				END BUTTONEX

				DEFINE BUTTONEX ButtonEx_3a
					ROW 180
					COL 270
					WIDTH 110
					HEIGHT 25
					CAPTION "Folder select"
					PICTURE "res\button6.bmp"
					FONTNAME "MS Sans serif"
					FONTSIZE 9
					FONTBOLD .t.
					FONTCOLOR YELLOW
					BACKCOLOR {128,0,0}
					FLAT .t.
					NOHOTLIGHT .t.
				END BUTTONEX

			END WINDOW 

			DEFINE WINDOW SplitChild_3 ;
				WIDTH 0 ;
				HEIGHT 350 ;
				TITLE 'SplitChild 3' ;
				SPLITCHILD ;
				GRIPPERTEXT 'Split 3' 

				DEFINE EDITBOX	Edit_1
					ROW	30
					COL	10
					WIDTH 410 
					HEIGHT 140 
					VALUE 'EditBox!!' 
					TOOLTIP 'EditBox' 
				END EDITBOX

			END WINDOW 

		END SPLITBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

