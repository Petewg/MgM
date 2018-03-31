/*
	MiniGUI ComboBoxEx Image Property Demo
	(c) 2008 Roberto Lopez
*/

/*

- 'Image' Property specify a character array containing image file names or 
resource names.

When using the additem or Item properties you must use a single array 
containing two elements. The first, the image index item and the second, 
the text for the item. 

When 'Image' and 'ItemSource' properties are used simultaneously, 
'ItemSource' must be specified as a list containing two field names.
The first, the image index for the items, the second, the item text.

'Sort' and 'Image' can't be used simultaneously.

*/

#include "minigui.ch"

Function Main
Local aAvailImages := { '00.bmp' ,'01.bmp' , '02.bmp' , '03.bmp' , '04.bmp' , '05.bmp' , '06.bmp' , '07.bmp' , '08.bmp' , '09.bmp' }
Local aItems := {}
Local aImages := {}

	aadd ( aItems , 'Item 01' )
	aadd ( aItems , 'Item 02' )
	aadd ( aItems , 'Item 03' )
	aadd ( aItems , 'Item 04' )
	aadd ( aItems , 'Item 05' )
	aadd ( aItems , 'Item 06' )
	aadd ( aItems , 'Item 07' )
	aadd ( aItems , 'Item 08' )
	aadd ( aItems , 'Item 09' )
	aadd ( aItems , 'Item 10' )

	aadd ( aImages , aAvailImages[5] )
	aadd ( aImages , aAvailImages[3] )
	aadd ( aImages , aAvailImages[6] )
	aadd ( aImages , aAvailImages[2] )
	aadd ( aImages , aAvailImages[4] )
	aadd ( aImages , aAvailImages[8] )
	aadd ( aImages , aAvailImages[7] )
	aadd ( aImages , aAvailImages[9] )
	aadd ( aImages , aAvailImages[10] )
	aadd ( aImages , aAvailImages[1] )


	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'ComboBox Demo 2' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP '&Test'
				MENUITEM 'Get Value' ACTION MsgInfo( Str ( Form_1.Combo_1.Value ) )
				MENUITEM 'Set Value' ACTION Form_1.Combo_1.Value := 2
				MENUITEM 'Add Item' ACTION Form_1.Combo_1.AddItem ( 'New', 10 )
				MENUITEM 'Delete Item' ACTION Form_1.Combo_1.DeleteItem ( 1 )
				MENUITEM 'Set Item' ACTION Form_1.Combo_1.Item ( 2 ) := { 1 , 'Modified' }
				MENUITEM 'Get Item' ACTION MsgInfo ( Form_1.Combo_1.Item ( 1 ) )
				MENUITEM 'Get ItemCount' ACTION MsgInfo (Str(Form_1.Combo_1.ItemCount) )
				MENUITEM 'Get DisplayValue' ACTION MsgInfo ( Form_1.Combo_1.DisplayValue )
				MENUITEM 'Set DisplayValue' ACTION Form_1.Combo_1.DisplayValue := 'New Item'
			END POPUP
		END MENU

		DEFINE COMBOBOXEX Combo_1 
			ROW	10
			COL	10
			WIDTH	100 
			HEIGHT	250 
			ITEMS	aItems 
			VALUE	1 
			IMAGE	aImages
			DISPLAYEDIT	.T.
			ONDISPLAYCHANGE	PlayBeep()
		END COMBOBOXEX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

