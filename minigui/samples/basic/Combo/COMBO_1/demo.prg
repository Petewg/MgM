/*
 * MiniGUI ComboBox Demo
 * (c) 2002 Roberto Lopez
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'ComboBox Demo' ;
		MAIN 

		@ 10,10 COMBOBOX Combo_1 ;
			WIDTH 100 ;
			ITEMS { '1 | Uno' , '2 | Dos' , '3 | tres' } ;
			VALUE 1 ;
			ON ENTER MsgInfo ( Str(Form_1.Combo_1.Value) ) ;
			UPPERCASE ;
			FONT 'Segoe UI' SIZE 12 

		DEFINE COMBOBOX Combo_2
			ROW	50
			COL	10
			WIDTH	100
			ITEMS	{ '1 | Uno' , '2 | Dos' , '3 | tres' }
			VALUE	1
			ON ENTER MsgInfo ( Str(Form_1.Combo_2.Value) )
			LOWERCASE .T.
		END COMBOBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
