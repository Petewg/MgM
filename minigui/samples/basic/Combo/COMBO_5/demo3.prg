/*
	MiniGUI ComboBoxEx Image Property Demo
	(c) 2008 Roberto Lopez
*/

#Include "minigui.ch"

/*

- 'Image' Property specify a character array containing image file names or 
resource names.

- 'ListWidth' property is used to set the dropdown list in a combobox control.

- OnListDisplay Event will be executed when the user attempt to open dropdown list

- OnListClose Event will be executed when the user closes the dropdown list

*/


Function Main() 		
Local aImages := { { '00.bmp' , '02.bmp' } }

	DEFINE WINDOW Form_1			;
		AT 0,0				;
		WIDTH 500			;  
		HEIGHT 120			;
		TITLE "ComboBox Demo 3"		;		
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


		@ 10, 10 COMBOBOXEX Combo_1		;
			ITEMSOURCE CIDADES->DESCRICAO	; 
			VALUE 5				;
			WIDTH 200			;
			HEIGHT 220			;
			IMAGE aImages 			;
			LISTWIDTH 400			;
			ON LISTDISPLAY PlayBeep()	;
			ON LISTCLOSE PlayAsterisk()		


		DEFINE COMBOBOXEX Combo_2
			ROW 10
			COL 250
			ITEMSOURCE CIDADES->DESCRICAO
			VALUE 2
			WIDTH 200					
			HEIGHT 220					
			IMAGE aImages
			LISTWIDTH 350
			ONLISTDISPLAY PlayBeep()
			ON LISTCLOSE PlayAsterisk()		
		END COMBOBOXEX

	END WINDOW		

	CENTER WINDOW   Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure Opentables()

	Use Cidades Alias Cidades Shared New
	Index On Field->Descricao To Cidades1

Return

Procedure CloseTables()

	Use
	Delete File Cidades1.ntx

Return
