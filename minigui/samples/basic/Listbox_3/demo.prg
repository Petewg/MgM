/*
 HMG ListBox Demo
 (c) 2010 Roberto Lopez
*/

#include "minigui.ch"

Function Main

Define window Win1;
    at 10,10;
    Width 400;
    Height 400;
    Title "HMG ListBox Demo";
    WindowType MAIN ;
    On Init loadlist(3, .f., .f.)

    Define Label Label1
       Row 10
       Col 10
       Value 'This is for status!'
       AutoSize .t.
    End Label    

    Define Button Button1
       Row 240
       Col 10   
       Caption "Add Item"
       OnClick {|| Win1.List1.Additem("Added Item "+hb_ntos(Win1.List1.Itemcount + 1)), ;
                   Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {Win1.List1.Itemcount}, Win1.List1.Itemcount)}
    End Button

    Define Button Button2
       Row 240
       Col 110   
       Caption "Delete Item"
       OnClick {|| Win1.List1.Deleteitem(1)}
    End Button
    
    Define Button Button3
       Row 240
       Col 210   
       Caption "Set Value"
       Width 120   
       OnClick Win1.List1.Value := iif(islistmultiselect('List1','Win1'), {1,3,5}, 2)
    End Button
    
    Define Button Button4
       Row 270
       Col 10   
       Caption "Get Value"
       OnClick ShowValues()
    End Button
    
    Define Button Button5
       Row 270
       Col 110   
       Caption "Get ItemCount"
       OnClick {|| MsgInfo(str(Win1.List1.ItemCount))}
    End Button
    
    Define Button Button6
       Row 270
       Col 210   
       Width 120   
       Caption "Delete All Items"
       OnClick {|| Win1.List1.DeleteAllItems()}
    End Button
    
    Define Button Button7
       Row 300
       Col 10   
       Caption "Set Items"
       OnClick {|| SetItems({"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"})}
    End Button
    
    Define Button Button8
       Row 300
       Col 110   
       Caption "Sort Items"
       OnClick {|| loadlist( win1.list1.value, islistmultiselect('List1','Win1'), .t.)}
    End Button

    Define Button Button9
       Row 300
       Col 210   
       Width 120   
       Caption "Toggle Multiselect"
       OnClick {|| loadlist( if(isarray(win1.list1.value),1,{1}), !islistmultiselect('List1','Win1'), .f.)}
    End Button

End Window

Win1.Center()  
Win1.Activate()

Return Nil 


function loadlist(value,lmultiselect,lsort)
local aItems := {"Item 1","Item 2","Item 3","Item 4","Item 5"}
local i

if iscontroldefined(List1,Win1)
   if Win1.List1.ItemCount >= 0
      aItems := {}
      for i := 1 to Win1.List1.ItemCount
         aAdd(aItems, Win1.List1.Item(i))
      next i
   endif
   win1.list1.release
   do events
endif

Define ListBox List1
       Row 40
       Col 10
       Parent Win1
       Items {}
       onChange {|| Win1.Label1.Value := iif(isarray(win1.list1.value),"MultiSelect List","Current Value is "+hb_ntos(win1.list1.value))}
       onDblClick {|| MsgInfo("Double Click Action!")}
       multiselect lmultiselect
       sort lsort
End ListBox

win1.list1.SetArray(aItems)
win1.list1.value := Value

return nil


function setitems(aNewItems)

win1.list1.SetArray(aNewItems)

return nil


function islistmultiselect(control,form)
return ( "MULTI" $ getcontroltype(control,form) )


function showvalues
local aValue, i
local cStr := ''

if islistmultiselect('List1','Win1')
   aValue := win1.list1.value
   cStr := 'Selected Lines are :'
   for i := 1 to len(aValue)
      cStr += str(aValue[i])
      if i < len(aValue)
         cStr += ','
      endif   
   next i
   msginfo(cStr,"MultiSelect List")   
else
   msginfo("Selected Line is : "+hb_ntos(win1.list1.value))
endif

return nil
