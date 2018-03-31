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
				SEPARATOR
                                ITEM 'Exit'             ACTION Form_1.Release()
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM ''
		END STATUSBAR

                DEFINE BROWSE Browse_1
			COL 10
			ROW 10
                        WIDTH 610
                        HEIGHT 390 - GetBorderHeight()
                        HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } 
                        WIDTHS { 50 , 150 , 150 , 150 , 70 , 150 } 
                        WORKAREA Test 
                        FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } 
                        VALUE 0
                        FONTNAME 'Verdana'
                        FONTSIZE 9
                        TOOLTIP 'Browse Test' 
                        ONCHANGE Form_1.StatusBar.Item(1) := 'Selected Record: ' + hb_ntos( Form_1.Browse_1.Value ) 
                        JUSTIFY { BROWSE_JTFY_RIGHT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER,BROWSE_JTFY_CENTER}
			VSCROLLBAR .F.
                END BROWSE

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()

	Use test

        // Clean table
	Zap

        // Fill table
	Do While LastRec() < 100
		append blank
		Replace code with RecNo()
		Replace First With 'First Name ' + hb_ntos(RecNo())
		Replace Last With 'Last Name ' + hb_ntos(RecNo())
		Replace Married With ( RecNo()/2 == Int(RecNo()/2) )
		replace birth with date()+RecNo()-10000
	EndDo

	Index On Field->Code To Code
	Use

        // Open table for browse
	Use test 

        Form_1.Browse_1.Value := 1

Return

Procedure CloseTables()
	Use
Return
