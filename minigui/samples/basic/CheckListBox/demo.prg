#include "MiniGUI.ch"

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , 0 , VK_SPACE , <{action}> )


Function Main()
   Local aItems := {"Item 1","Item 2","Item 3","Item 4","Item 5"}

   DEFINE WINDOW Form_1 AT 97,62 WIDTH 402 HEIGHT 449 ;
      TITLE "Checked ListBox - By Janusz Pora" ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      @ 10,10 CHECKLISTBOX ListBox_1 ;
         WIDTH 150 HEIGHT 160 ;
         ITEMS aItems ;
         VALUE 2 ;
         CHECKBOXITEM {3,5} ;
         ON DBLCLICK clb_Check() ;
         ITEMHEIGHT 19 ;
         FONT 'Arial' SIZE 9

      @ 10,200 CHECKLISTBOX ListBox_2 ;
         WIDTH 150 HEIGHT 160 ;
         ITEMS aItems ;
         VALUE {2} ;
         CHECKBOXITEM {4,5};
         ON DBLCLICK cmlb_Check() ;
         MULTISELECT ;
         ITEMHEIGHT 19 ;
         FONT 'Arial' SIZE 9

      @ 200,10 button bt1 caption 'Add'     action clb_add()
      @ 230,10 button bt2 caption 'Del'     action clb_del()
      @ 260,10 button bt3 caption 'Del All' action clb_delete_all()
      @ 290,10 button bt4 caption 'Modify'  action clb_modify()
      @ 320,10 button bt5 caption 'Check'   action clb_Check()
      @ 350,10 button bt6 caption 'Check #4'   action clb_Check(4)

      @ 200,200 button btm1 caption 'Add'     action cmlb_add()
      @ 230,200 button btm2 caption 'Del'     action cmlb_del()
      @ 260,200 button btm3 caption 'Del All' action cmlb_delete_all()
      @ 290,200 button btm4 caption 'Modify'  action cmlb_modify()
      @ 320,200 button btm5 caption 'Check'   action cmlb_Check()
      @ 350,200 button btm6 caption 'Check #4'   action cmlb_Check(4)

      on key space action OnPressSpacebar()

   END WINDOW

   Form_1.Center ; Form_1.Activate
Return Nil

*.....................................................*

proc clb_add
   local nn := form_1.ListBox_1.ItemCount + 1
   form_1.ListBox_1.AddItem( 'ITEM_' + alltrim(str( nn )) )
   form_1.ListBox_1.value := nn
return

*.....................................................*

proc clb_del
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

proc clb_delete_all
   form_1.ListBox_1.DeleteAllItems
   form_1.ListBox_1.value := 1
return

*.....................................................*

proc clb_modify
   local nn := form_1.ListBox_1.value
   if nn > 0
      form_1.ListBox_1.item( nn ) := 'New ' + alltrim( str(nn) )
   endif
   form_1.ListBox_1.Setfocus
return

*.....................................................*

Function clb_Check(nn)
   Local lCheck
   Default nn := form_1.ListBox_1.value
   if nn > 0
      lCheck :=  clb_getCheck(nn)
      setproperty('form_1','ListBox_1',"CHECKBOXITEM",nn,!lCheck)
   endif
   form_1.ListBox_1.Setfocus

return nil

*.....................................................*

function clb_getCheck(nn)
   local lCheck
   lCheck := GetProperty('form_1','ListBox_1',"CHECKBOXITEM",nn)
return lCheck

*.....................................................*

proc OnPressSpacebar()
   if GetProperty('form_1',"FOCUSEDCONTROL") == "ListBox_1"
      clb_Check()
   else
      cmlb_Check()
   endif
return

*.....................................................*

proc cmlb_add
   local nn := form_1.ListBox_2.ItemCount + 1
   form_1.ListBox_2.AddItem( 'ITEM_' + alltrim(str( nn )) )
   form_1.ListBox_2.value := {nn}
return

*.....................................................*

proc cmlb_del
   local n1, i
   local nn := form_1.ListBox_2.value
   if len (nn) > 0
      for i:= len(nn) to 1 step -1
         form_1.ListBox_2.DeleteItem( nn[i] )
      next
      n1 := form_1.ListBox_2.ItemCount
      if nn[1] <= n1
         form_1.ListBox_2.value := {nn[1]}
      else
         form_1.ListBox_2.value := {n1}
      endif
   endif
return

*.....................................................*

proc cmlb_delete_all
   form_1.ListBox_2.DeleteAllItems
   form_1.ListBox_2.value := 1
return

*.....................................................*

proc cmlb_modify
   local i, nn := form_1.ListBox_2.value
   for i := 1 to len(nn)
      form_1.ListBox_2.item( nn[i] ) := 'New ' + alltrim( str(nn[i]) )
   next
   form_1.ListBox_2.Setfocus
return

*.....................................................*

function cmlb_Check(n)
   Local lCheck, i
   Local nn := form_1.ListBox_2.value
   Default n := 0
   if n == 0
      for i :=1 to len(nn)
         lCheck :=  cmlb_getCheck(nn[i])
         setproperty('form_1','ListBox_2',"CHECKBOXITEM",nn[i],!lCheck)
      next
   else
      lCheck :=  cmlb_getCheck(n)
      setproperty('form_1','ListBox_2',"CHECKBOXITEM",n,!lCheck)
   endif
   form_1.ListBox_2.Setfocus
return nil

*.....................................................*

function cmlb_getCheck(nn)
   local lCheck
   lCheck := GetProperty('form_1','ListBox_2',"CHECKBOXITEM",nn)
return lCheck
