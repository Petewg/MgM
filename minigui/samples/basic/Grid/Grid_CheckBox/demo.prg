/*
 * Checkbox Grid item sample.
 * Author: Eduardo Fernandes <modalsist@yahoo.com.br>
 * 2009/JUN/17
*/

#include "minigui.ch"

Function Main

Local a_Items[20][2], a_head[2], a_width[2]


a_Items [01] := { STRZERO(1,3), 'Item 1'     }
a_Items [02] := { STRZERO(2,3), 'Item 2'     }
a_Items [03] := { STRZERO(3,3), 'Item 3'     }
a_Items [04] := { STRZERO(4,3), 'Item 4'     }
a_Items [05] := { STRZERO(5,3), 'Item 5'     }
a_Items [06] := { STRZERO(6,3), 'Item 6'     }
a_Items [07] := { STRZERO(7,3), 'Item 7'     }
a_Items [08] := { STRZERO(8,3), 'Item 8'     }
a_Items [09] := { STRZERO(9,3), 'Item 9'     }
a_Items [10] := { STRZERO(10,3), 'Item 10'   }
a_Items [11] := { STRZERO(11,3), 'Item 11'   }
a_Items [12] := { STRZERO(12,3), 'Item 12'   }
a_Items [13] := { STRZERO(13,3), 'Item 13'   }
a_Items [14] := { STRZERO(14,3), 'Item 14'   }
a_Items [15] := { STRZERO(15,3), 'Item 15'   }
a_Items [16] := { STRZERO(16,3), 'Item 16'   }
a_Items [17] := { STRZERO(17,3), 'Item 17'   }
a_Items [18] := { STRZERO(18,3), 'Item 18'   }
a_Items [19] := { STRZERO(19,3), 'Item 19'   }
a_Items [20] := { STRZERO(20,3), 'Item 20'   }


a_head[1] := "Code"
a_head[2] := "Name"

a_width[1] := 80
a_width[2] := 400

DEFINE WINDOW Form_1 ;
   AT 0,0 WIDTH 620 HEIGHT 480 ;
   TITLE "Grid with Checkbox Items" ;
   MAIN ;
   NOMAXIMIZE NOSIZE ;
   ON INIT initcheckboxes()

   @ 20, 50 LABEL Label_1;
     VALUE "Checkbox items allows us to select an aleatory items. More flexible!" ;
     WIDTH  120 ;
     HEIGHT 25 ;
     AUTOSIZE ;
     FONT "Arial" SIZE 12

   @ 50,50 GRID Grid_1 ;
     WIDTH  504 ;
     HEIGHT 328 ;
     HEADERS a_head ;
     WIDTHS a_width ;
     ITEMS a_Items ;
     VALUE {1,4,6} ;
     TOOLTIP "Grid with Checkboxes" ;
     MULTISELECT ;
     CHECKBOXES

   @ 400, 60 BUTTON Button_1;
     CAPTION "Checked Items" ;
     ON CLICK Getcheckeditems();
     WIDTH  120 ;
     HEIGHT 25

   @ 400, 200 BUTTON Button_2;
     CAPTION "Selected Items" ;
     ON CLICK GetSelecteditems();
     WIDTH  120 ;
     HEIGHT 25

   ON KEY ESCAPE ACTION ThisWindow.Release

END WINDOW

Form_1.center
Form_1.activate

Return Nil

*--------------------------------------------------------*
Procedure GetCheckeditems()
local a := {}
Local c := "", i

for i := 1 to Form_1.Grid_1.ItemCount

  if Form_1.Grid_1.CheckboxItem (i)
     c += "Item "+Ltrim(Str(i))+" checked"+ CRLF
     aadd( a, GetProperty ( "Form_1", "Grid_1", "Item" , i ) )
  endif

next

if ! empty( c )
   msginfo( c )
   msgdebug( a )   
else
   msginfo("No items checked.")
endif

Return

*--------------------------------------------------------*
Procedure GetSelecteditems()

Local c := "", i, v

v := Form_1.Grid_1.Value

for i := 1 to Len(v)
  c += "Item "+Ltrim(Str(v[i]))+" selected"+ CRLF
next

if ! empty( c )
   msginfo( c )
else
   msginfo("No items selected.")
endif

Return

*--------------------------------------------------------*
Procedure initcheckboxes()

  Form_1.Grid_1.CheckboxItem (1) := .t.
  Form_1.Grid_1.CheckboxItem (3) := .t.
  Form_1.Grid_1.CheckboxItem (5) := .t.
  Form_1.Grid_1.CheckboxItem (8) := .t.
  Form_1.Grid_1.CheckboxItem (9) := .t.

Return