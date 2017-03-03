/*
  MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Function Main
	Local aHeaders := {'Last Name','First Name','Phone'}
	Local aItems   := LoadItems()
	Local lInit    := .F.

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 550 ;
		HEIGHT 400 ;
		TITLE 'Phone Book' ;
		MAIN

		DEFINE GRID Grid_1
			ROW		10
			COL		10
			WIDTH		500
			HEIGHT		330
			HEADERS		aHeaders
			WIDTHS		{140,140,140}
			ITEMS		aItems
			VALUE		1
			ALLOWSORT	.T.
			ONGOTFOCUS	iif( lInit, NIL, ( HMG_SortColumn( 1 ), lInit := .T. ) )
		END GRID

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return Nil


Function LoadItems()
	Local aRows [20] [3]

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

Return aRows
