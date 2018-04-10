/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'ComboBox Demo' ;
		MAIN 

		@ 20,20 COMBOBOX Combo_1 ;
			WIDTH 100 ;
			ITEMS { '1 | Uno' , '2 | Dos' , '3 | tres' } ;
			VALUE 1 ;
			ON ENTER MsgInfo ( Form_1.Combo_1.ITEMHEIGHT ) ;
			UPPERCASE ;
			ITEMHEIGHT 21 ;
			FONT 'Courier' SIZE 12 

		DEFINE COMBOBOX Combo_2
			ROW	20
			COL	140
			WIDTH	100
			ITEMS	{ '1 | Uno' , '2 | Dos' , '3 | tres' }
			VALUE	1
			ON ENTER MsgInfo ( Form_1.Combo_2.ITEMHEIGHT )
			LOWERCASE .T.
			ITEMHEIGHT 17
		END COMBOBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
