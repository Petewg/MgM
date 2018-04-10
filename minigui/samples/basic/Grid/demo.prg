/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/

 * MiniGUI 1.0 Experimantal Build 6 - Grid Demo
 * (c) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 *
 * New property - ColumnWidth(nColumn) for BROWSE & GRID controls
 * New methods for BROWSE & GRID controls
   - ColumnAutoFit(nColumn)  - set column width to best fit regarding to column contents
   - ColumnAutoFitH(nColumn) - set column width to best fit regarding to column header & column contents
   - ColumnsAutoFit  - set widths of all columns in control to best fit regarding to column contents
   - ColumnsAutoFitH - set widths of all columns in control to best fit regarding to column header & column contents
*/

#include "minigui.ch"

Function Main()

Local aRows [20] [3]

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 400 ;
		TITLE 'MiniGUI 1.0 Experimantal Build 6 - Grid Demo' ;
		MAIN 

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

		@ 10,10 GRID Grid_1 ;
			WIDTH 200 ;
			HEIGHT 330 ;
			HEADERS {'Last Name','First Name','Phone'} ;
			WIDTHS {140,140,140};
			ITEMS aRows ;
			VALUE 1 ;
			TOOLTIP 'Editable Grid Control' ;
			EDIT ;
			JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT }

		@ 10,240 GRID Grid_2 ;
			WIDTH 200 ;
			HEIGHT 330 ;
			HEADERS {'Last Name','First Name','Phone'} ;
			WIDTHS {140,140,140};
			ITEMS aRows ;
			VALUE 1 ;
			TOOLTIP 'Editable Grid Control' ;
			EDIT ;
			ON HEADCLICK { {||MsgInfo('Click 1')} , {||MsgInfo('Click 2')} , {||MsgInfo('Click 3')} } ;
			JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } 

		DEFINE MAIN MENU
			POPUP 'New Functions Tests'

				ITEM 'GetColumnWidth Column 1 Grid 1'          ACTION MsgBox( str(Form_1.Grid_1.ColumnWidth(1)) ) 
				ITEM 'GetColumnWidth Column 2 Grid 1'          ACTION MsgBox( str(Form_1.Grid_1.ColumnWidth(2)) )
				ITEM 'GetColumnWidth Column 3 Grid 1'          ACTION MsgBox( str(Form_1.Grid_1.ColumnWidth(3)) )
				SEPARATOR
				ITEM 'SetColumnWidth Column 1 Grid 1 To 100 '  ACTION {|| (Form_1.Grid_1.ColumnWidth(1) := 100)}
				ITEM 'SetColumnWidth Column 2 Grid 1 To 100 '  ACTION {|| (Form_1.Grid_1.ColumnWidth(2) := 100)}
				ITEM 'SetColumnWidth Column 3 Grid 1 To 100 '  ACTION {|| (Form_1.Grid_1.ColumnWidth(3) := 100)}
				SEPARATOR
				ITEM 'SetColumnWidth Column 1 Grid 1 To Auto'  ACTION Form_1.Grid_1.ColumnAutoFit(1)
				ITEM 'SetColumnWidth Column 2 Grid 1 To Auto'  ACTION Form_1.Grid_1.ColumnAutoFit(2)
				ITEM 'SetColumnWidth Column 1 Grid 1 To AutoH' ACTION Form_1.Grid_1.ColumnAutoFitH(1)
				ITEM 'SetColumnWidth Column 2 Grid 1 To AutoH' ACTION Form_1.Grid_1.ColumnAutoFitH(2)
				SEPARATOR
				ITEM 'Set Auto Width for Grid_1'               ACTION Form_1.Grid_1.ColumnsAutoFit
				ITEM 'Set Auto Width for Grid_2'               ACTION Form_1.Grid_2.ColumnsAutoFit
				SEPARATOR
				ITEM 'Set AutoFit Widths for Grid_1 (header)'  ACTION Form_1.Grid_1.ColumnsAutoFitH
				ITEM 'Set AutoFit Widths for Grid_2(header)'   ACTION Form_1.Grid_2.ColumnsAutoFitH

			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
