/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
 * http://www.geocities.com/harbour_minigui/
*/

* Value property selects a record by its number (RecNo())
* Value property returns selected record number (recNo())
* Browse control does not change the active work area
* Browse control does not change the record pointer in any area
* (nor change selection when it changes)
* You can programatically refresh it using refresh method.
* Variables called <MemVar>.<WorkAreaName>.<FieldName> are created for 
* validation in browse editing window. You can use it in VALID array.
* Using APPEND clause you can add records to table associated with WORKAREA
* clause. The hotkey to add records is Alt+A.
* Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea
* Using DELETE clause allows to mark selected record for deletion pressing <Del> key

* Enjoy !

#include "minigui.ch"

Function Main

	SET CENTURY ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
                                ITEM 'Set Browse Value' ACTION Form_1.Browse_1.Value := 10
                                ITEM 'Get Browse Value' ACTION MsgInfo ( Form_1.Browse_1.Value )
                                ITEM 'Refresh Browse'   ACTION Form_1.Browse_1.Refresh()

                                ITEM 'Show Browse'      ACTION Form_1.Browse_1.Show()
                                ITEM 'Hide Browse'      ACTION Form_1.Browse_1.Hide()
                                ITEM 'Enable Browse'    ACTION Form_1.Browse_1.Enabled := .t.
                                ITEM 'Disable Browse'   ACTION Form_1.Browse_1.Enabled := .f.

				SEPARATOR
                                ITEM 'Exit'             ACTION Form_1.Release()
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready!'
		END STATUSBAR

		DEFINE TAB Tab_1 ;
			AT 10,10 ;
			WIDTH 600 ;
			HEIGHT 400 - Form_1.Statusbar.Height ;
			VALUE 1 ;
                        FONT 'Arial' SIZE 10

			PAGE '&Browse '

                                DEFINE BROWSE Browse_1
                                        COL 25
                                        ROW 40
                                        WIDTH 555
                                        HEIGHT 350 - Form_1.Statusbar.Height
                                        HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'BioGraphy' }  
                                        WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 }                                            
                                        WORKAREA Test 
                                        FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' }  
                                        VALUE 1 
                                        ONDBLCLICK MsgInfo('DoubleClick!!') 
                                        ONHEADCLICK { {|| MsgInfo('Header 1 Clicked !')} , { || MsgInfo('Header 2 Clicked !')} , { || MsgInfo('Header 3 Clicked !')}, { || MsgInfo('Header 4 Clicked !')}, { || MsgInfo('Header 5 Clicked !')}, { || MsgInfo('Header 6 Clicked !')}}
                               END BROWSE

			END PAGE

			PAGE '&More'

				@ 55,90 LABEL Label_1 ;
				VALUE 'Label !!!' ;
				WIDTH 100 HEIGHT 27 

				@ 80,90 CHECKBOX Check_1 ;
				CAPTION 'Check 1' ;
				VALUE .T. ;
				TOOLTIP 'CheckBox' 

				@ 115,85 SLIDER Slider_1 ;
				RANGE 1,10 ;
				VALUE 5 ;
				TOOLTIP 'Slider' 

				@ 45,240 FRAME TabFrame_2 WIDTH 125 HEIGHT 110 OPAQUE

				@ 50,260 RADIOGROUP Radio_1 ;
				OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
				VALUE 1 ;
				WIDTH 100 ;
				TOOLTIP 'RadioGroup' 

			END PAGE

		END TAB

	END WINDOW

	CENTER WINDOW Form_1

        Form_1.Browse_1.SetFocus()

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()
	Use Test 
Return

Procedure CloseTables()
	Use
Return
