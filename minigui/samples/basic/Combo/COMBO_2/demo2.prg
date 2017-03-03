#Include "minigui.ch"

* When ITEMSOURCE property is set to a fieldname, 'Value' property 
* uses the physical record number, as in browse.
* If you set the VALUESOURCE property to a fieldname, its containt is
* returned instead the physical record number.

Function Main() 		

	DEFINE WINDOW Form_1			;
		AT 0,0				;
		WIDTH 365			;  
		HEIGHT 120			;
		TITLE "Exemplos ComboBox 2"	;		
		MAIN				;      
		NOMAXIMIZE			;
		NOSIZE				;
		ON INIT OpenTables()		;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU
			DEFINE POPUP '&Test'
				MENUITEM 'Get Value' ACTION MsgInfo( Form_1.Combo_1.Value ) 
				MENUITEM 'Set Value' ACTION Form_1.Combo_1.Value := 2
				MENUITEM 'Refresh' ACTION Form_1.Combo_1.Refresh
				MENUITEM 'Item Content' ACTION MsgInfo ( Form_1.Combo_1.DisplayValue )
			END POPUP
		END MENU

		@010,010 COMBOBOX Combo_1		;
			ITEMSOURCE CIDADES->DESCRICAO	; 
			VALUESOURCE CIDADES->CODIGO	;
			VALUE 5				;
			WIDTH 200			;
			FONT "Arial" SIZE 9		;
			TOOLTIP "Combo Cidades" 

	END WINDOW		

	CENTER WINDOW Form_1

	Form_1.Row := (Form_1.Row) + (Form_1.Height)

	ACTIVATE WINDOW Form_1

Return Nil

Procedure Opentables()

	Use Cidades Alias Cidades Shared New
	if File("Cidades1.ntx")
		Set Index To Cidades1
	else
		Index On Field->Descricao To Cidades1
	endif

Return

Procedure CloseTables()

	Use

Return
