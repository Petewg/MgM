/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main
Local aRows [5] [3]

	aRows [1]	:= {'Simpson','Homer','555-5555'}
	aRows [2]	:= {'Mulder','Fox','324-6432'} 
	aRows [3]	:= {'Smart','Max','432-5892'} 
	aRows [4]	:= {'Grillo','Pepe','894-2332'} 
	aRows [5]	:= {'Kirk','James','346-9873'} 

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Get Button Caption at Page 1' ACTION MsgInfo ( Form_1.Tab_1(1).Button_1.Caption ) 
				MENUITEM 'Set Button Caption at Page 1' ACTION Form_1.Tab_1(1).Button_1.Caption := 'New'
				SEPARATOR
				MENUITEM 'Hide Button at Page 1' ACTION Form_1.Tab_1(1).Button_1.Hide()
				MENUITEM 'Show Button at Page 1' ACTION Form_1.Tab_1(1).Button_1.Show()
				SEPARATOR
				MENUITEM 'Get Grid Header at Page 4' ACTION MsgInfo ( Form_1.Tab_1(4).Grid_1.Header(1) ) 
				MENUITEM 'Set Grid Header at Page 4' ACTION Form_1.Tab_1(4).Grid_1.Header(1) := 'New Header'
				SEPARATOR
				MENUITEM 'Get Grid Cell at Page 4' ACTION MsgInfo ( Form_1.Tab_1(4).Grid_1.Cell(1,1) )
				MENUITEM 'Set Grid Cell at Page 4' ACTION Form_1.Tab_1(4).Grid_1.Cell(1,1) := 'New Item'
			END POPUP
		END MENU

		DEFINE TAB Tab_1 ;
			AT 10,10 ;
			WIDTH 600 ;
			HEIGHT 400 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control' 

			PAGE 'Page &1' 

			      @ 100,250 BUTTON Button_1 CAPTION "Test" WIDTH 50 HEIGHT 50 ACTION MsgInfo('Test!')

			END PAGE

			PAGE 'Page &2' 

				DEFINE RADIOGROUP R1
					ROW	100
					COL	100
					OPTIONS	{ '1','2','3' }
					VALUE	1
				END RADIOGROUP

			END PAGE

			PAGE 'Page &3' 

				@ 100,250 SPINNER Spinner_1 ;
				RANGE 0,10 ;
				VALUE 5 ;
				WIDTH 100 ;
				TOOLTIP 'Range 0,10' ; 
				ON CHANGE PlayBeep() 

			END PAGE

			PAGE 'Page &4' 

				@ 50,50 GRID Grid_1 ;
					WIDTH 200 ;
					HEIGHT 330 ;
					HEADERS {'Last Name','First Name','Phone'} ;
					WIDTHS {140,140,140};
					ITEMS aRows ;
					VALUE 1 

			END PAGE

		END TAB

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil
