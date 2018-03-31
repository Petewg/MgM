/*
 * MiniGUI Grid Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * MiniGUI 1.0 Experimental Build 8b-10b - Grid Demo
*/

#include "minigui.ch"

Function Main

Local aRows [20] [3], bColor1, bColor2, ;
	bfrColor := {|| RGB(0,0,0)}, bbkColor := {|| RGB(255,255,255)}

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

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
		TITLE 'Grid Demo based upon a contribution by Mitja Podgornik <yamamoto@rocketmail.com>' ;
		MAIN 

		DEFINE MAIN MENU 
			POPUP '&Test'
				ITEM 'Get Current Row of Grid 1 Second Column Value'	ACTION MsgInfo( Form_1.Grid_1.Cell(GetProperty("Form_1","Grid_1", 'Value'), 2) )
				ITEM 'Set Current Row of Grid 1 Second Column Value'	ACTION ( Form_1.Grid_1.Cell(GetProperty("Form_1","Grid_1", 'Value'), 2) := "New value" )
				SEPARATOR
				ITEM 'Get Current Row of Grid 2 Third Column Value'	ACTION MsgInfo( Form_1.Grid_2.Cell(GetProperty("Form_1","Grid_2", 'Value'), 3) )
				ITEM 'Set Current Row of Grid 2 Third Column Value'	ACTION Form_1.Grid_2.Cell(GetProperty("Form_1","Grid_2", 'Value'), 3) := "999-9999"
				SEPARATOR
				ITEM 'Exit'		ACTION Form_1.Release
			END POPUP
			POPUP '&Action'
				ITEM 'Add New Row to Grid 1'	ACTION DoMethod ( "Form_1" , "Grid_1" , 'AddItem' , {'??????','????????','???-????'} )
				ITEM 'Add New Row to Grid 2'	ACTION DoMethod ( "Form_1" , "Grid_2" , 'AddItem' , {'??????','????????','???-????'} )
				SEPARATOR
				ITEM 'Delete Current Row from Grid 1'	ACTION DoMethod ( "Form_1" , "Grid_1" , 'DeleteItem' , GetProperty("Form_1", "Grid_1", 'Value') )
				ITEM 'Delete Current Row from Grid 2'	ACTION DoMethod ( "Form_1" , "Grid_2" , 'DeleteItem' , GetProperty("Form_1", "Grid_2", 'Value') )
			END POPUP
			POPUP '&Help'
				ITEM '&About'		ACTION MsgInfo( MiniguiVersion(), "MiniGUI Grid Demo" )
			END POPUP
		END MENU

		bColor1 := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(255,255,255), RGB(128,255,255) )}
		bColor2 := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(0,0,255), RGB(0,0,128) )}

		@ 10,10 GRID Grid_1 ;
			WIDTH 300 ;
			HEIGHT 330 ;
			HEADERS {'Last Name','First Name','Phone'} ;
			WIDTHS {100,100,70};
			ITEMS aRows ;
			VALUE 1 ;
			TOOLTIP 'Editable Grid Control' ;
			EDIT ;
			JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT } ;
			DYNAMICFORECOLOR { bColor1, bColor1, bColor1 } ;
			DYNAMICBACKCOLOR { bColor2, bColor2, bColor2 }

		@ 10,324 GRID Grid_2 ;
			WIDTH 300 ;
			HEIGHT 330 ;
			HEADERS {'Last Name','First Name','Phone'} ;
			WIDTHS {100,100,70};
			ITEMS aRows ;
			VALUE 1 ;
			TOOLTIP 'No Editable Grid Control' ;
			ON HEADCLICK { {||MsgInfo('Click 1')} , {||MsgInfo('Click 2')} , {||MsgInfo('Click 3')} } ;
			JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } ;
			DYNAMICFORECOLOR { bfrColor, bfrColor, {|val| if( "?" $ val[3], RGB(255,255,0), RGB(0,0,0) )} } ;
			DYNAMICBACKCOLOR { bbkColor, bbkColor, {|val| if( "?" $ val[3], RGB(255,0,0), RGB(255,255,255) )} }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
