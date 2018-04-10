/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

/*

	'DisplayItems' property allows to control data display in browse control.
	This property is an array (one element for each browse column).
	each element (if specified) must be a two dimensional array. 
	the first column in the array must contain the text to be shown to the 
	user. The second column	must contain the ID for each array row.
	The array will be searched for a corresponding ID in the table to show
	the right text in each cell. If no correspondence is found, the cell 
	will be blank.

*/

#include "minigui.ch"

Function Main

Local aBooks := {}
Local aPupils := {}

	* Load Arrays
	* 
	* The First Column is the text shown to the user
	* The second column is the correspondig data stored in the table.

	* Books 

	aadd ( aBooks , { 'La Venganza Será Terrible'		, 123 } )
	aadd ( aBooks , { 'Aquí Radio Bangkok'			, 314 } )
	aadd ( aBooks , { 'Buenos Aires, Una Divina Comedia'	, 555 } )

	* Pupils

	aadd ( aPupils , { 'Douglas Vinci'		, 653 } )
	aadd ( aPupils , { 'Washington Tacuarembó'	, 276 } )
	aadd ( aPupils , { 'Milagros López'		, 888 } )

	SET CENTURY ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE STATUSBAR
			STATUSITEM ''
		END STATUSBAR

                DEFINE BROWSE Browse_1
			COL 		10
			ROW 		10
                        WIDTH 		610                                                                               
                        HEIGHT 		390                                                                               
                        HEADERS		{ 'Date' , 'Book Code' , 'Pupil Code' } 
                        WIDTHS		{ 110 , 220 , 220 } 
                        WORKAREA 	Library
                        FIELDS		{ 'Library->Date' , 'Library->Book_Code' , 'Library->Pupil_Code' } 
                        VALUE		1 
			ALLOWEDIT	.T.
			INPLACEEDIT	.T.
			ALLOWAPPEND	.T.
			DISPLAYITEMS	{ Nil , aBooks , aPupils }
                END BROWSE

	END WINDOW

	CENTER WINDOW Form_1

        Form_1.Browse_1.SetFocus()

	ACTIVATE WINDOW Form_1

Return Nil

Procedure OpenTables()

	Use library

Return

Procedure CloseTables()
	Use
Return
