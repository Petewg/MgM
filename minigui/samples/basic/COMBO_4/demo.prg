/*
 * MiniGUI ComboBox Demo
 * (c) 2002 Roberto Lopez
*/

#include "minigui.ch"

Function Main

	SET NAVIGATION EXTENDED

	DEFINE WINDOW Form_1 ;
		MAIN ;
		CLIENTAREA 300, 150 ;
		TITLE 'ComboBox Demo'

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Get Value' ACTION MsgInfo(Str(Form_1.Combo_1.Value))
				MENUITEM 'Set Value' ACTION Form_1.Combo_1.Value := 1
				MENUITEM 'Get DisplayValue' ACTION MsgInfo( Form_1.Combo_1.DisplayValue )
				MENUITEM 'Set DisplayValue' ACTION Form_1.Combo_1.DisplayValue := 'New Text' 
			END POPUP
		END MENU


		@ 10,10 COMBOBOX Combo_1 ;
			ITEMS { 'A' , 'B' , 'C' } ;
			VALUE 1 ;
			DISPLAYEDIT ;
			FONTCOLOR RED ;
			LOWERCASE ;
			ON DISPLAYCHANGE PlayBeep() 

		@ 50,10 COMBOBOX Combo_2 ;
			ITEMS { 'a' , 'b' , 'c' } ;
			VALUE 1 ;
			DISPLAYEDIT ;
			FONTCOLOR BLUE ;
			UPPERCASE ;
			ON DISPLAYCHANGE PlayBeep() 

		DEFINE TEXTBOX txb_1
			ROW 90
			COL 10
			WIDTH 120
		END TEXTBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
