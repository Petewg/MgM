/*
 * MiniGUI Grid Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * MiniGUI 1.0 Experimental Build 8b-9d - Grid Demo
*/

#include "minigui.ch"

Function Main

Local aRows [20] [3], aRows2 [18] [4], bColor, bColor1, bColor2

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

	aRows2 [1]	:= {1, 'Simpson','Homer','555-5555'}
	aRows2 [2]	:= {0, 'Mulder','Fox','324-6432'} 
	aRows2 [3]	:= {1, 'Smart','Max','432-5892'} 
	aRows2 [4]	:= {0, 'Grillo','Pepe','894-2332'} 
	aRows2 [5]	:= {1, 'Kirk','James','346-9873'} 
	aRows2 [6]	:= {0, 'Barriga','Carlos','394-9654'} 
	aRows2 [7]	:= {1, 'Flanders','Ned','435-3211'} 
	aRows2 [8]	:= {0, 'Smith','John','123-1234'} 
	aRows2 [9]	:= {1, 'Pedemonti','Flavio','000-0000'} 
	aRows2 [10]	:= {0, 'Gomez','Juan','583-4832'} 
	aRows2 [11]	:= {1, 'Fernandez','Raul','321-4332'} 
	aRows2 [12]	:= {0, 'Borges','Javier','326-9430'} 
	aRows2 [13]	:= {1, 'Alvarez','Alberto','543-7898'} 
	aRows2 [14]	:= {0, 'Gonzalez','Ambo','437-8473'} 
	aRows2 [15]	:= {1, 'Batistuta','Gol','485-2843'} 
	aRows2 [16]	:= {0, 'Vinazzi','Amigo','394-5983'} 
	aRows2 [17]	:= {1, 'Pedemonti','Flavio','534-7984'} 
	aRows2 [18]	:= {0, 'Samarbide','Armando','854-7873'} 

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
		TITLE 'Grid Demo based upon a contribution by Mitja Podgornik <yamamoto@rocketmail.com>' ;
		MAIN 

		DEFINE MAIN MENU 
			POPUP '&Test'
				ITEM 'Get Current Row of Grid 1 Second Column Value'	ACTION MsgInfo( GetColValue( "Grid_1", "Form_1", 2 ) )
				ITEM 'Set Current Row of Grid 1 Second Column Value'	ACTION SetColValue( "Grid_1", "Form_1", 2, "New value" )
				SEPARATOR
				ITEM 'Get Current Row of Grid 2 Third Column Value'	ACTION MsgInfo( GetColValue( "Grid_2", "Form_1", 4 ) )
				ITEM 'Set Current Row of Grid 2 Third Column Value'	ACTION SetColValue( "Grid_2", "Form_1", 4, "999-9999" )
				SEPARATOR
				ITEM 'Exit'		ACTION Form_1.Release
			END POPUP
			POPUP '&Action'
				ITEM 'Add New Row to Grid 1'	ACTION DoMethod ( "Form_1" , "Grid_1" , 'AddItem' , {'??????','????????','???-????'} )
				ITEM 'Add New Row to Grid 2'	ACTION DoMethod ( "Form_1" , "Grid_2" , 'AddItem' , {1,'??????','????????','???-????'} )
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

		bColor := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(240,240,240), RGB(255,255,255) )}

		@ 10,324 GRID Grid_2 ;
			WIDTH 300 ;
			HEIGHT 330 ;
			HEADERS {'','Last Name','First Name','Phone'} ;
			WIDTHS {0,100,100,70};
			ITEMS aRows2 ;
			VALUE 1 ;
			TOOLTIP 'No Editable Grid Control' ;
			ON HEADCLICK { , {||MsgInfo('Click 1')} , {||MsgInfo('Click 2')} , {||MsgInfo('Click 3')} } ;
			JUSTIFY { , BROWSE_JTFY_LEFT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } ;
			DYNAMICBACKCOLOR { , bColor, bColor, bColor } ;
			NOLINES ;
			IMAGE {"br_no.bmp","br_ok.bmp"} 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*--------------------------------------------------------------*
Function GetColValue( xObj, xForm, nCol )
*--------------------------------------------------------------*
  Local nPos:= GetProperty(xForm, xObj, 'Value')
  Local aRet:= GetProperty(xForm, xObj, 'Item', nPos)
Return aRet[nCol] 

*--------------------------------------------------------------*
Function SetColValue( xObj, xForm, nCol, xValue )
*--------------------------------------------------------------*
  Local nPos:= GetProperty(xForm, xObj, 'Value')
  Local aRet:= GetProperty(xForm, xObj, 'Item', nPos)
      aRet[nCol] := xValue
      SetProperty(xForm, xObj, 'Item', nPos, aRet)
Return NIL
