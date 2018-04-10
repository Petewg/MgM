/*
* MiniGUI Grid Demo
* (c) 2005 Roberto Lopez
*/

#include "hmg.ch"

Function Main

	Local aRows [20] [3], aRows1 [20] [5]

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 ;
		HEIGHT 550 ;
		TITLE 'Grid2HTML!' ;
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
      
		aRows1 [1]	:= {113.12,date(),1,1 , .t. }
		aRows1 [2]	:= {123.12,date(),2,2 , .f. } 
		aRows1 [3]	:= {133.12,date(),3,3, .t. } 
		aRows1 [4]	:= {143.12,date(),1,4, .f. } 
		aRows1 [5]	:= {153.12,date(),2,5, .t. } 
		aRows1 [6]	:= {163.12,date(),3,6, .f. } 
		aRows1 [7]	:= {173.12,date(),1,7, .t. } 
		aRows1 [8]	:= {183.12,date(),2,8, .f. } 
		aRows1 [9]	:= {193.12,date(),3,9, .t. } 
		aRows1 [10]	:= {113.12,date(),1,10, .f. } 
		aRows1 [11]	:= {123.12,date(),2,11, .t. } 
		aRows1 [12]	:= {133.12,date(),3,12, .f. } 
		aRows1 [13]	:= {143.12,date(),1,13, .t. } 
		aRows1 [14]	:= {153.12,date(),2,14, .f. } 
		aRows1 [15]	:= {163.12,date(),3,15, .t. } 
		aRows1 [16]	:= {173.12,date(),1,16, .f. } 
		aRows1 [17]	:= {183.12,date(),2,17, .t. } 
		aRows1 [18]	:= {193.12,date(),3,18, .f. } 
		aRows1 [19]	:= {113.12,date(),1,19, .t. } 
		aRows1 [20]	:= {123.12,date(),2,20, .f. } 
      
      
		define grid grid_1
			row 10
			col 10
			WIDTH 760 
			HEIGHT 200
			HEADERS {'Last Name','First Name','Phone'} 
			WIDTHS {140,140,140}
			ITEMS aRows
			VALUE 1
			JUSTIFY { GRID_JTFY_CENTER,GRID_JTFY_LEFT, GRID_JTFY_RIGHT } 
		end grid
      
		define GRID Grid_2 
			row 220
			col 10
			WIDTH 760 
			HEIGHT 200 
			HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5'} 
			JUSTIFY { GRID_JTFY_RIGHT, GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT, GRID_JTFY_LEFT }
			WIDTHS {140,140,140,140,140} 
			ITEMS aRows1 
			ALLOWEDIT .t.
			COLUMNCONTROLS { ;
					{'TEXTBOX','NUMERIC','$ 999,999.99'} , ;
					{'DATEPICKER','DROPDOWN'} , ;
					{'COMBOBOX',{'One','Two','Three'}} , ;
					{ 'SPINNER' , 1 , 20 } , ;
					{ 'CHECKBOX' , 'Yes' , 'No' } ;
					} 
			COLUMNVALID	{ ;
					{ || This.CellValue > 100 } , ;
					{ || This.CellValue = Date() } , ;
					Nil , ;
					Nil , ;
					Nil ;
					}
		end grid

		define button b1
			row 430
			col 10
			width 80
			caption 'HTML1'         
			action grid2html1()
		end button

		define button b2
			row 430
			col 110
			width 80
			caption 'HTML2'         
			action grid2html2()
		end button

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return nil

function grid2html1
   local cFile := _grid2html( 'grid_1', 'form_1' )
   if file( cFile )
      _Execute ( GetActiveWindow() , , cFile ,  , , 5 )
   endif   
return nil

function grid2html2
   _grid2html( 'grid_2', 'form_1', 'report.html', { 'Report Main Header', 'Report SubHeader 1', 'Report SubHeader 2' } )
   if file( 'report.html' )
      _Execute ( GetActiveWindow() , , 'report.html' ,  , , 5 )
   endif   
return nil
