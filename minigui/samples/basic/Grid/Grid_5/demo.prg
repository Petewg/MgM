/*
 * MiniGUI HeaderImage Property Test
 * (c) 2008 Roberto Lopez
*/

#include "minigui.ch"

Function Main
Local aImages := { '00.bmp' , '01.bmp' , '02.bmp' , '03.bmp' , '04.bmp' , '05.bmp' }

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 550 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON INIT OnInit()

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Change Column 1 Header Image'	ACTION Form_1.Grid_1.HeaderImage(1) := 4
				MENUITEM 'Change Column 2 Header Image'	ACTION Form_1.Grid_1.HeaderImage(2) := 5
				MENUITEM 'Change Column 3 Header Image'	ACTION Form_1.Grid_1.HeaderImage(3) := 6
				SEPARATOR
				MENUITEM 'Erase All Columns Header Images'	ACTION EraseAllImages()
				MENUITEM 'Restore All Columns Header Images'	ACTION SetHeaderImages()
			END POPUP
		END MENU

		DEFINE GRID Grid_1
			ROW		10
			COL		10
			WIDTH		500
			HEIGHT		330
			HEADERS		{'Last Name','First Name','Phone'}
			WIDTHS		{140,140,140}
			ITEMS		{}
			HEADERIMAGES	aImages
		END GRID

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil


Procedure OnInit

	Form_1.Grid_1.SetArray( LoadItems() )
	Form_1.Grid_1.Value := 1

	SetHeaderImages()

Return


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


Procedure EraseAllImages()
Local i

	For i := 1 To 3
		SetProperty( 'Form_1', 'Grid_1', 'HeaderImage', i, 0 )
	Next

Return


Procedure SetHeaderImages()
Local i

	For i := 1 To 3
		SetProperty( 'Form_1', 'Grid_1', 'HeaderImage', i, i )
	Next

Return
