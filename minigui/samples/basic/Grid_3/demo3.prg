/*
* MiniGUI Grid Demo
* (c) 2005 Roberto Lopez
*/

#include "minigui.ch"

PROCEDURE Main

Local aRows [20] [3]

	aRows [1]	:= {113.12,date(),1,1 , .t. }
	aRows [2]	:= {123.12,date(),2,2 , .f. } 
	aRows [3]	:= {133.12,date(),3,3 , .t. } 
	aRows [4]	:= {143.12,date(),1,4 , .f. } 
	aRows [5]	:= {153.12,date(),2,5 , .t. } 
	aRows [6]	:= {163.12,date(),3,6 , .f. } 
	aRows [7]	:= {173.12,date(),1,7 , .t. } 
	aRows [8]	:= {183.12,date(),2,8 , .f. } 
	aRows [9]	:= {193.12,date(),3,9 , .t. } 
	aRows [10]	:= {113.12,date(),1,10, .f. } 
	aRows [11]	:= {123.12,date(),2,11, .t. } 
	aRows [12]	:= {133.12,date(),3,12, .f. } 
	aRows [13]	:= {143.12,date(),1,13, .t. } 
	aRows [14]	:= {153.12,date(),2,14, .f. } 
	aRows [15]	:= {163.12,date(),3,15, .t. } 
	aRows [16]	:= {173.12,date(),1,16, .f. } 
	aRows [17]	:= {183.12,date(),2,17, .t. } 
	aRows [18]	:= {193.12,date(),3,18, .f. } 
	aRows [19]	:= {113.12,date(),1,19, .t. } 
	aRows [20]	:= {123.12,date(),2,20, .f. } 

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

		DEFINE GRID Grid_1 
			ROW 	10
			COL	10
			WIDTH	620 
			HEIGHT	330 
			HEADERS	{ 'Column 1','Column 2','Column 3','Column 4','Column 5' } 
			WIDTHS	{ 140,140,140,140,140 }
			ITEMS	aRows
			VALUE	1
			ALLOWEDIT .T.
			COLUMNCONTROLS	{ ;
					{'TEXTBOX','NUMERIC','$ 999,999.99'} , ;
					{'DATEPICKER','DROPDOWN'} , ;
					{'COMBOBOX',{'One','Two','Three'}} , ;
					{ 'SPINNER' , 1 , 20 } , ;
					{ 'CHECKBOX' , 'Yes' , 'No' } ;
					}
			COLUMNVALID 	{ ;
					{ || This.CellValue > 100 } , ;
					{ || This.CellValue = Date() } , ;
					Nil , ;
					Nil , ;
					Nil ;
					} 
		END GRID

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

PROCEDURE SETITEM()

	Form_1.Grid_1.Item (2) := { 123.45 , date() , 2 , 10 , .T. }

RETURN

PROCEDURE GETITEM()
Local a

	a := Form_1.Grid_1.Item (2) 

	aEval( a, {|x,i| msginfo ( x, ltrim( str ( i ) ) ) } )

RETURN
