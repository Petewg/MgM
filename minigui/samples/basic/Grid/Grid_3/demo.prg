/*
* MiniGUI Grid Demo
* (c) 2005 Roberto Lopez
*/

#include "minigui.ch"

PROCEDURE Main

Local aRows [20] [3]

	aRows [1]	:= {113.12,date(),1,0 , .t. }
	aRows [2]	:= {123.12,date(),2,2 , .f. } 
	aRows [3]	:= {133.12,date(),3,4 , .t. } 
	aRows [4]	:= {143.12,date(),1,6 , .f. } 
	aRows [5]	:= {153.12,date(),2,8 , .t. } 
	aRows [6]	:= {163.12,date(),3,10 , .f. } 
	aRows [7]	:= {173.12,date(),1,12 , .t. } 
	aRows [8]	:= {183.12,date(),2,14 , .f. } 
	aRows [9]	:= {193.12,date(),3,16 , .t. } 
	aRows [10]	:= {113.12,date(),1,18, .f. } 
	aRows [11]	:= {123.12,date(),2,20, .t. } 
	aRows [12]	:= {133.12,date(),3,22, .f. } 
	aRows [13]	:= {143.12,date(),1,24, .t. } 
	aRows [14]	:= {153.12,date(),2,26, .f. } 
	aRows [15]	:= {163.12,date(),3,28, .t. } 
	aRows [16]	:= {173.12,date(),1,30, .f. } 
	aRows [17]	:= {183.12,date(),2,32, .t. } 
	aRows [18]	:= {193.12,date(),3,34, .f. } 
	aRows [19]	:= {113.12,date(),1,36, .t. } 
	aRows [20]	:= {123.12,date(),2,38, .f. } 

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 400 ;
		TITLE 'Mixed Data Type Grid Test' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Set Item'	ACTION SetItem()
				MENUITEM 'Get Item'	ACTION GetItem()
			END POPUP
		END MENU

		@ 10,10 GRID Grid_1 ;
		WIDTH 620 ;
		HEIGHT 330 ;
		HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5'} ;
		WIDTHS {140,140,140,140,140} ;
		ITEMS aRows ;
		EDIT ;
		COLUMNCONTROLS { {'TEXTBOX','NUMERIC','$ 999,999.99'} , {'DATEPICKER','DROPDOWN'} , {'COMBOBOX',{'One','Two','Three'}} , { 'SPINNER' , 0 , 40 , 2 } , { 'CHECKBOX' , 'Yes' , 'No' } } 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

PROCEDURE SETITEM()
local n := GetProperty("Form_1", "Grid_1", 'Value')

	Form_1.Grid_1.Item ( n ) := { 123.45 , date() , min(3, n) , min(40, 2 * n) , .T. }

RETURN

PROCEDURE GETITEM()
local a

	a := Form_1.Grid_1.Item ( GetProperty("Form_1", "Grid_1", 'Value') ) 

	aEval( a, {|x,i| msginfo ( x, hb_ntos ( i ) ) } )

RETURN
