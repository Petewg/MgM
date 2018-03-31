/*
	MiniGUI ComboBox Set/Get Property Demo
	(c) 2008 Roberto Lopez
*/

#Include "minigui.ch"

/*

- 'DroppedWidth' property is used to set the dropdown list's width in a combobox control.

- OnDropDown Event will be executed when the user attempt to open dropdown list

- OnCloseUp Event will be executed when the user closes the dropdown list

*/


Function Main() 		

	DEFINE WINDOW Form_1			;
		AT 0,0				;
		WIDTH 500			;  
		HEIGHT 120			;
		TITLE "ComboBox Demo 4"		;		
		MAIN				;      
		NOMAXIMIZE			;
		NOSIZE				;
		ON INIT OpenTables()		;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU
			DEFINE POPUP '&Test'
				MENUITEM 'Get Combo_1 Value' ACTION MsgInfo( Str ( Form_1.Combo_1.Value ) )
				MENUITEM 'Set Combo_1 Value' ACTION Form_1.Combo_1.Value := 2
				MENUITEM 'Refresh Combo_1' ACTION Form_1.Combo_1.Refresh
			END POPUP
		END MENU


		@ 10, 10 COMBOBOX Combo_1		;
			ITEMSOURCE CIDADES->DESCRICAO	; 
			VALUE 5				;
			WIDTH 200			;
			HEIGHT 220			;
			DROPPEDWIDTH 300		;
			ON DROPDOWN PlayBeep()		;
			ON CLOSEUP PlayAsterisk()		


		DEFINE COMBOBOX Combo_2
			ROW 10
			COL 250
			ITEMSOURCE CIDADES->DESCRICAO
			VALUE 2
			WIDTH 200					
			HEIGHT 220					
			DROPPEDWIDTH 250
			ONDROPDOWN PlayBeep()
			ONCLOSEUP PlayAsterisk()		
		END COMBOBOX

	END WINDOW		

	CENTER WINDOW   Form_1
	Form_1.Row := (Form_1.Row) + (Form_1.Height)
	ACTIVATE WINDOW Form_1

Return Nil

Procedure Opentables()

	Use Cidades Alias Cidades Shared New
	if file("Cidades1.ntx")
		Set Index To Cidades1
	else
		Index On Field->Descricao To Cidades1
	endif

Return

Procedure CloseTables()

	Use
	Delete File Cidades1.ntx

Return
