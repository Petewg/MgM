/*
 * MiniGUI Grid Demo
 * (c) 2005 Roberto Lopez
*/

#include "minigui.ch"

Function Main


	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN

		DEFINE GRID Grid_1 
			ROW		10
			COL		10
			WIDTH		560 
			HEIGHT		330 
			HEADERS		{'Column 1','Column 2','Column 3','Column 4','Column 5'}
			WIDTHS		{110,110,110,110,90}
			ITEMS		LoadItems() 
			CELLNAVIGATION	.T.
			ALLOWEDIT	.T.
			ALLOWSORT	.T.
			JUSTIFY		{1,1,0,1,0}
			VALUE		1
			COLUMNCONTROLS { {'TEXTBOX','NUMERIC','$ 999,999.99'} , {'DATEPICKER','DROPDOWN'} , {'COMBOBOX',{'One','Two','Three'}} , { 'SPINNER' , 0 , 40 , 2 } , { 'CHECKBOX' , 'Yes' , 'No' } } 
		END GRID

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil

Function LoadItems()

Local aRows [20] [5]

	aRows [1]	:= {113.12,date()+1,1,1 , .t. }
	aRows [2]	:= {123.12,date()+2,2,2 , .f. } 
	aRows [3]	:= {133.12,date()+3,3,3, .t. } 
	aRows [4]	:= {143.12,date()+4,1,4, .f. } 
	aRows [5]	:= {153.12,date()+5,2,5, .t. } 
	aRows [6]	:= {163.12,date()+6,3,6, .f. } 
	aRows [7]	:= {173.12,date()+7,1,7, .t. } 
	aRows [8]	:= {183.12,date()+8,2,8, .f. } 
	aRows [9]	:= {193.12,date()+9,3,9, .t. } 
	aRows [10]	:= {113.12,date()+10,1,10, .f. } 
	aRows [11]	:= {123.12,date()+11,2,11, .t. } 
	aRows [12]	:= {133.12,date()+12,3,12, .f. } 
	aRows [13]	:= {143.12,date()+13,1,13, .t. } 
	aRows [14]	:= {153.12,date()+14,2,14, .f. } 
	aRows [15]	:= {163.12,date()+15,3,15, .t. } 
	aRows [16]	:= {173.12,date()+16,1,16, .f. } 
	aRows [17]	:= {183.12,date()+17,2,17, .t. } 
	aRows [18]	:= {193.12,date()+18,3,18, .f. } 
	aRows [19]	:= {113.12,date()+19,1,19, .t. } 
	aRows [20]	:= {123.12,date(),2,20, .f. } 

Return aRows
