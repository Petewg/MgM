/*
* MiniGUI Virtual Column Grid Demo
* (c) 2006 Grigory Filatov
*/

#include "minigui.ch"

PROCEDURE Main

Local aRows [20] [6]

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
		TITLE 'Virtual Column Grid Test' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Set Item'	ACTION SetItem()
				MENUITEM 'Get Item'	ACTION GetItem()
				SEPARATOR
				MENUITEM 'Exit'	ACTION ThisWindow.Release
			END POPUP
		END MENU

		aRows [1]	:= {'01','Simpson','Homer',5,10,5*10}
		aRows [2]	:= {'02','Mulder','Fox',24,32,24*32} 
		aRows [3]	:= {'03','Smart','Max',43,58,43*58} 
		aRows [4]	:= {'04','Grillo','Pepe',89,23,89*23} 
		aRows [5]	:= {'05','Kirk','James',34,73,34*73} 
		aRows [6]	:= {'06','Barriga','Carlos',39,54,39*54} 
		aRows [7]	:= {'07','Flanders','Ned',43,11,43*11} 
		aRows [8]	:= {'08','Smith','John',12,34,12*34} 
		aRows [9]	:= {'09','Pedemonti','Flavio',10,100,10*100} 
		aRows [10]	:= {'10','Gomez','Juan',58,32,58*32} 
		aRows [11]	:= {'11','Fernandez','Raul',32,43,32*43} 
		aRows [12]	:= {'12','Borges','Javier',26,30,26*30} 
		aRows [13]	:= {'13','Alvarez','Alberto',54,98,54*98} 
		aRows [14]	:= {'14','Gonzalez','Ambo',43,73,43*73} 
		aRows [15]	:= {'15','Batistuta','Gol',48,28,48*28} 
		aRows [16]	:= {'16','Vinazzi','Amigo',39,83,39*83} 
		aRows [17]	:= {'17','Pedemonti','Flavio',53,84,53*84} 
		aRows [18]	:= {'18','Samarbide','Armando',54,73,54*73} 
		aRows [19]	:= {'19','Pradon','Alejandra',12,45,12*45} 
		aRows [20]	:= {'20','Reyes','Monica',32,36,32*36} 

		@ 10,10 GRID Grid_1 ;
			WIDTH 612 ;
			HEIGHT 330 ;
			HEADERS { 'Code', 'Last Name', 'First Name', 'Quantity', 'Price', 'Cost' } ;
			WIDTHS {60,100,100,80,80,100} ;
			ITEMS aRows ;
			EDIT INPLACE { ;
					{'TEXTBOX','CHARACTER', '999' } , ;
					{'TEXTBOX','CHARACTER', } , ;
					{'TEXTBOX','CHARACTER', } , ;
					{'TEXTBOX','NUMERIC', '9,999' } , ;
					{'TEXTBOX','NUMERIC', '999.99' } , ;
					{'TEXTBOX','NUMERIC', '9,999,999.99' } ;
					};
			COLUMNWHEN { ;
					{ || Empty ( This.CellValue ) } , ;
					{ || This.CellValue >= 'M' } , ;
					{ || This.CellValue >= 'C' } , ;
					{ || ! Empty ( This.CellValue ) }, ;
					{ || ! Empty ( This.CellValue ) }, ;
					{ || Empty ( This.CellValue ) } ;
					} ;
			COLUMNVALID { , , , ;
					{ || SETVIRTUALITEM() } , ;
					{ || SETVIRTUALITEM() } , ;
					} ;
			JUSTIFY { GRID_JTFY_LEFT,;
				GRID_JTFY_RIGHT,;
				GRID_JTFY_RIGHT,;
				GRID_JTFY_RIGHT,;
				GRID_JTFY_RIGHT,;
				GRID_JTFY_RIGHT }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

Function SETVIRTUALITEM()
local nVal := This.CellValue
local nCol := This.CellColIndex
local nRow := This.CellRowIndex

if nCol == 4
	Form_1.Grid_1.Cell( nRow , 6 ) := nVal * Form_1.Grid_1.Cell( nRow , 5 )
elseif nCol == 5
	Form_1.Grid_1.Cell( nRow , 6 ) := Form_1.Grid_1.Cell( nRow , 4 ) * nVal
endif

RETURN .T.

PROCEDURE SETITEM()

	Form_1.Grid_1.Item (2) := { '02', 'Gomez', 'Juan' , Form_1.Grid_1.Cell( 1 , 4 ), Form_1.Grid_1.Cell( 1 , 5 ), Form_1.Grid_1.Cell( 1 , 4 ) * Form_1.Grid_1.Cell( 1 , 5 ) }

RETURN

PROCEDURE GETITEM()
local a

	a := Form_1.Grid_1.Item (2)

	aEval( a, {|x,i| msginfo ( if(valtype(x)=="C", x, str(x)), ltrim( str ( i ) ) )} )

RETURN
