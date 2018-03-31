#include "minigui.ch"

Function Main
   Local aItems := {}

   aeval( array(15), {|| aadd( aItems, { 0, '', '' } ) } )

   SET CELLNAVIGATIONMODE VERTICAL
//   SET CELLNAVIGATION MODE HORIZONTAL

   define window win_1 at 0, 0 width 528 height 300 ;
      title 'Cell Navigation Downwards Demo' ;
      main nomaximize nosize

      define grid grid_1
         row 10
         col 10
         width 501
         height 250
         widths { 80, 200, 200 }
         headers { 'No.', 'Name', 'Description' }
         items aItems
         columncontrols { { 'TEXTBOX', 'NUMERIC', '999' }, { 'TEXTBOX', 'CHARACTER' }, { 'TEXTBOX', 'CHARACTER' } }
         justify { GRID_JTFY_RIGHT, GRID_JTFY_LEFT, GRID_JTFY_LEFT }
         columnwhen { {|| .t. }, {|| win_1.grid_1.cell( GetProperty("Win_1","Grid_1","Value")[1], 1 ) > 0 }, {|| .t. } }
         allowedit .t.
         cellnavigation .t.
         value {1, 1}
      end grid

      on key escape action thiswindow.release()

   end window

   win_1.center
   win_1.activate

Return Nil
