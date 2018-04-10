/*
 * MiniGUI ComboBox Demo
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'ComboBox Demo' ;
		MAIN 

		@ 15,20 COMBOBOX Combo_1 ;
			ITEMS { 'RED' , 'BLUE' , 'GREEN' , 'YELLOW' } ;
			VALUE 0 ;
			DISPLAYEDIT ;
			LOWERCASE ;
			FONTCOLOR NAVY ;
			BACKCOLOR WHITE

		@ 50,30 CHECKBOX CheckBox_1 CAPTION " Enabled" VALUE .T. ON CHANGE Form_1.Combo_1.Enabled := (this.Value)

		@ 80,30 CHECKBOX CheckBox_2 CAPTION " Visible" VALUE .T. ON CHANGE Form_1.Combo_1.Visible := Form_1.CheckBox_2.Value

		@110,30 CHECKBOX CheckBox_3 CAPTION " Read only" VALUE .F. ON CHANGE Form_1.Combo_1.Readonly := (this.Value)


		@ 50,200 RADIOGROUP Radio_1 ;
			OPTIONS { 'DropDown' , 'DropDown List' } ;
			VALUE 1 ;
			WIDTH 120 ;
			SPACING 30 ;
			ON CHANGE SetComboState( this.value )

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function SetComboState( nState )
	Local nValue := Form_1.Combo_1.Value

	Form_1.Combo_1.Release

	IF nState == 2

		@ 15,20 COMBOBOX Combo_1 OF Form_1 ;
			ITEMS { 'RED' , 'BLUE' , 'GREEN' , 'YELLOW' } ;
			VALUE nValue ;
			LOWERCASE

		Form_1.CheckBox_3.Enabled := .F.

	ELSE
		@ 15,20 COMBOBOX Combo_1 OF Form_1 ;
			ITEMS { 'RED' , 'BLUE' , 'GREEN' , 'YELLOW' } ;
			VALUE nValue ;
			DISPLAYEDIT ;
			LOWERCASE ;
			FONTCOLOR NAVY ;
			BACKCOLOR WHITE

		Form_1.CheckBox_3.Enabled := .T.

		Form_1.Combo_1.Readonly := Form_1.CheckBox_3.Value

	ENDIF

	Form_1.Combo_1.Visible := Form_1.CheckBox_2.Value

	Form_1.Combo_1.Enabled := Form_1.CheckBox_1.Value

Return Nil
