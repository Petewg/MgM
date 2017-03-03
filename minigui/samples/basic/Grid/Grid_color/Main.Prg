#include "hmg.ch"

PROCEDURE Main

   SET AUTOADJUST ON
   
   DEFINE WINDOW MainForm at 0, 0 width 500 height 300 main font 'arial' size 12
   
      DEFINE GRID grid_1
         row 10
         col 10
         width 465
         headers { 'Clr', 'Column1', 'Column2' }
         widths { 0, 200, 200 }
         justify { 0, 0, 0 }
         image { 'WHITE.bmp' , 'GREEN.bmp' , 'RED.bmp'}
         height 245
         items {  { 3, 'Row1, Column1', 'Row1, Column2' }, ;
                  { 3, 'Row2, Column1', 'Row2, Column2' }, ;
                  { 3, 'Row3, Column1', 'Row3, Column2' }, ;
                  { 3, 'Row4, Column1', 'Row4, Column2' }, ;
                  { 3, 'Row5, Column1', 'Row5, Column2' }, ;
                  { 3, 'Row6, Column1', 'Row6, Column2' }, ;
                  { 3, 'Row7, Column1', 'Row7, Column2' }, ;
                  { 3, 'Row8, Column1', 'Row8, Column2' }, ;
                  { 3, 'Row9, Column1', 'Row9, Column2' } ; 
              } 
        tooltip "Double click on this row twice..."
        ondblclick DblClick( This.CellRowIndex /*, This.CellColIndex , This.CellRow , This.CellCol , This.CellWidth , This.CellHeight , This.CellValue*/ )

      END GRID
   
   
   END WINDOW

   MainForm.center
   MainForm.activate

   RETURN


PROCEDURE DblClick( CellRowIndex /*, CellColIndex , CellRow , CellCol , CellWidth , CellHeight , CellValue */ )

   LOCAL aRowItem := MainForm.grid_1.Item( CellRowIndex )

   // msgdebug( aRowItem )
   aRowItem[1] := Iif( ++aRowItem[1] > 3, 1, aRowItem[1] )
   // msgdebug( aRowItem )
   
   MainForm.grid_1.Item( CellRowIndex ) := aRowItem
   //MainForm.grid_1.Show()

   /*
   msgDebug( { "This.CellRowIndex" , CellRowIndex, ;
               "This.CellColIndex" , CellColIndex, ;
               "This.CellRow     " , CellRow     , ;
               "This.CellCol     " , CellCol     , ;
               "This.CellWidth   " , CellWidth   , ; 
               "This.CellHeight  " , CellHeight  , ; 
               "This.CellValue   " , CellValue     } )
   */  

   RETURN

