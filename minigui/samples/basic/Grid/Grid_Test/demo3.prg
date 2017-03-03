#include "minigui.ch"

Procedure Main
local nId

define window m at 0,0 width 600 height 400 title 'Grid Demo' main

   define grid g
      row 10
      col 10
      width 472
      height 200
      headers {"Name","City","Amount"}
      widths {200,150,100}
      allowedit .t.
      COLUMNCONTROLS { { 'TEXTBOX','CHARACTER' } , { 'COMBOBOX',{ 'CHENNAI','DELHI','KOLKATTA' } } , { 'TEXTBOX','NUMERIC',"999999.99" } }
      items { {"Person 1", 1, 1000} , {"Person 2", 3, 2000} }
      justify {0,0,1}
   end grid

   define button b1
      row 230
      col 10
      width 240
      caption "Add a new item in inplaced combobox"
      action AddGridEditComboItem( "g", "m", 2, Upper( InputBox("Enter a new city", "Add city", "MUMBAI") ) )
   end button

   define button b2
      row 260
      col 10
      width 240
      caption "Add a new item in grid"
      action ( nId := m.g.ItemCount, m.g.AddItem( {"Person "+hb_ntos(++nId), Random(3), nId*1000} ) )
   end button

   on key escape action thiswindow.release()

end window
m.center
m.activate

Return


function AddGridEditComboItem ( cGridName, cWindowName, nColIndex, cNewItem )
local i := GetControlIndex ( cGridName, cWindowName )
local aEditcontrols := _HMG_aControlMiscData1 [i] [13]

   if ascan(aEditControls [nColIndex] [2], cNewItem) == 0
      aAdd ( aEditControls [nColIndex] [2], cNewItem )
   endif
   _HMG_aControlMiscData1 [i] [13] := aEditControls

return nil
