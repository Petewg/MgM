#include "MiniGUI.ch"

Function main()

DEFINE WINDOW Form_1 AT 97,62 WIDTH 402 HEIGHT 449 ;
	TITLE "ListBox - By CAS - webcas@bol.com.br" ;
	MAIN ;
	NOMAXIMIZE NOSIZE

	@ 0,1 LISTBOX ListBox_1 WIDTH 392 HEIGHT 160 ;
	ITEMS { '01 UM' , '02 DOIS' , '03 TRES' } ;
	value 2

	@ 200,10 button bt1 caption 'Add'     action cas_add()
	@ 230,10 button bt2 caption 'Del'     action cas_del()
	@ 260,10 button bt3 caption 'Del All' action cas_delete_all()
	@ 290,10 button bt4 caption 'Modify'  action cas_modify()
END WINDOW
Form_1.Center ; Form_1.Activate
Return Nil

*.....................................................*

proc cas_add
local nn := form_1.ListBox_1.ItemCount + 1
form_1.ListBox_1.AddItem( 'ITEM_' + alltrim(str( nn )) )
form_1.ListBox_1.value := nn
return

*.....................................................*

proc cas_del
local n1
local nn := form_1.ListBox_1.value
form_1.ListBox_1.DeleteItem( nn )
n1 := form_1.ListBox_1.ItemCount
if nn <= n1
	form_1.ListBox_1.value := nn
else
	form_1.ListBox_1.value := n1
endif
return

*.....................................................*

proc cas_delete_all
form_1.ListBox_1.DeleteAllItems
form_1.ListBox_1.value := 1
return

*.....................................................*

proc cas_modify
local nn := form_1.ListBox_1.value
form_1.ListBox_1.item( nn ) := 'Nº ' + alltrim( str(nn) )
form_1.ListBox_1.Setfocus
return