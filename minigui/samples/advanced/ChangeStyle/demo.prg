/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Extend Disable/Enable control DEMO
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 * HMG Experimental 1.1 Build 12a
*/

#include "MiniGUI.ch"

Function MAIN()
Local aRows [20] [3], bColor1, bColor2, ;
	bfrColor := {|| RGB(0,0,0)}, bbkColor := {|| RGB(255,255,255)}

	aRows [1]	:= {'Simpson','Homer','555-5555'}
	aRows [2]	:= {'Mulder','Fox','324-6432'} 
	aRows [3]	:= {'Smart','Max','432-5892'} 
	aRows [4]	:= {'Grillo','Pepe','894-2332'} 
	aRows [5]	:= {'Kirk','James','346-9873'} 
	aRows [6]	:= {'Barriga','Carlos','394-9654'} 
	aRows [7]	:= {'Flanders','Ned','435-3211'} 
	aRows [8]	:= {'Smith','John','123-1234'} 
	aRows [9]	:= {'Pedemonti','Flavio','000-0000'} 
	aRows [10]	:= {'Gomez','Juan','583-4832'} 
	aRows [11]	:= {'Fernandez','Raul','321-4332'} 
	aRows [12]	:= {'Borges','Javier','326-9430'} 
	aRows [13]	:= {'Alvarez','Alberto','543-7898'} 
	aRows [14]	:= {'Gonzalez','Ambo','437-8473'} 
	aRows [15]	:= {'Batistuta','Gol','485-2843'} 
	aRows [16]	:= {'Vinazzi','Amigo','394-5983'} 
	aRows [17]	:= {'Pedemonti','Flavio','534-7984'} 
	aRows [18]	:= {'Samarbide','Armando','854-7873'} 
	aRows [19]	:= {'Pradon','Alejandra','???-????'} 
	aRows [20]	:= {'Reyes','Monica','432-5836'} 

	DEFINE WINDOW Form_1 AT 97,62 WIDTH 597 HEIGHT 337 MAIN TITLE "Extend Disable/Enable control DEMO" 
                bColor1 := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(255,255,255), RGB(128,255,255) )}
		bColor2 := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(0,0,255), RGB(0,0,128) )}

	        @ 21,19 TEXTBOX TextBox_1 ;
		        BACKCOLOR {255,255,0};
                        FONTCOLOR {255,0,0} ;
                        VALUE "TextBox_1" ;
                        WIDTH 120 HEIGHT 24

		@ 51,19 LISTBOX ListBox_1 WIDTH 120 HEIGHT 100
		@ 160,21 EDITBOX EditBox_1 ;
		BACKCOLOR {0,0,195} FONTCOLOR {255,255,0} WIDTH 120 HEIGHT 120 VALUE "EditBox_1"
		@ 22,158 GRID Grid_1 WIDTH 240 HEIGHT 256 ;
                         HEADERS {'Last Name','First Name','Phone'} ;
			 WIDTHS {100,100,70};
                         ITEMS aRows ;
			 TOOLTIP 'Editable Grid Control' ;
			 EDIT ;
			 JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT } ;
			 DYNAMICFORECOLOR { bColor1, bColor1, bColor1 } ;
			 DYNAMICBACKCOLOR { bColor2, bColor2, bColor2 }

		@ 22,411 COMBOBOX ComboBox_1 WIDTH 100 ITEMS {"one","two"} Value 1
		@ 54,411 DATEPICKER DatePicker_1 WIDTH 120 HEIGHT 24
		
                DEFINE TREE Tree_1 AT 88, 411 WIDTH 150 HEIGHT 150 tooltip "Tree_1" ITEMIDS 
			NODE 'Item 1' ID 10
				TREEITEM 'Item 1.1' ID 11
				TREEITEM 'Item 1.2' ID 12
				TREEITEM 'Item 1.3' ID 13
			END NODE
			NODE 'Item 2' ID 14
				TREEITEM 'Item 1.1' ID 15
				TREEITEM 'Item 1.2' ID 16
				TREEITEM 'Item 1.3' ID 17
			END NODE
		END TREE

		DEFINE MAIN MENU

			POPUP "DISABLE"
				ITEM "Disable TextBox_1"    ACTION ( _ExtDisableControl ( 'TextBox_1' ,'Form_1' ), Form_1.Setfocus )
				ITEM "Disable EditBox_1"    ACTION ( _ExtDisableControl ( 'EditBox_1' ,'Form_1' ), Form_1.Setfocus )
				ITEM "Disable ComboBox_1"   ACTION ( Form_1.Setfocus, _ExtDisableControl ( 'ComboBox_1' ,'Form_1' ) )
				ITEM "Disable Tree_1"       ACTION ( Form_1.Setfocus, _ExtDisableControl ( 'Tree_1' ,'Form_1' ) )
				ITEM "Disable Grid_1"       ACTION ( _ExtDisableControl ( 'Grid_1' ,'Form_1' ), Form_1.Setfocus )
				ITEM "Disable DatePicker_1" ACTION ( _ExtDisableControl ( 'DatePicker_1' ,'Form_1' ), Form_1.Setfocus )
				ITEM "Disable ListBox_1"    ACTION ( _ExtDisableControl ( 'ListBox_1' ,'Form_1' ), Form_1.Setfocus )
			END POPUP

			POPUP "ENABLE"
				ITEM  "Enable TextBox_1"    ACTION _ExtEnableControl ( 'TextBox_1' ,'Form_1' )
				ITEM  "Enable EditBox_1"    ACTION _ExtEnableControl ( 'EditBox_1' ,'Form_1' )
				ITEM  "Enable ComboBox_1"   ACTION _ExtEnableControl ( 'ComboBox_1' ,'Form_1' )
				ITEM  "Enable Tree_1"       ACTION ( Form_1.Tree_1.Hide , _ExtEnableControl ( 'Tree_1' ,'Form_1' ), Form_1.Tree_1.Show )
				ITEM  "Enable Grid_1"       ACTION _ExtEnableControl ( 'Grid_1' ,'Form_1' )
				ITEM  "Enable DatePicker_1" ACTION _ExtEnableControl ( 'DatePicker_1' ,'Form_1' )
				ITEM  "Enable ListBox_1"    ACTION _ExtEnableControl ( 'ListBox_1' ,'Form_1' )
			END POPUP

			POPUP "TREE"
				ITEM "Set Tree Back color to yellow" ACTION Form_1.Tree_1.Backcolor := YELLOW
				ITEM "Set Tree Text color to red" ACTION Form_1.Tree_1.Fontcolor := RED
			END POPUP

		END MENU

	END WINDOW
	Form_1.Center
	Form_1.Activate
Return Nil
