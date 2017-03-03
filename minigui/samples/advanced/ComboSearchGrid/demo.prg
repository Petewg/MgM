#include <hmg.ch>
#include "combosearchgrid.ch"

Function Main

   local aItems := randomdatafill()

   define window csg at 0, 0 width 600 height 500 main title 'ComboSearchGrid - Sample'
      define label namelabel
         row 10
         col 10
         width 60
         value 'Name'
         vcenteralign .t.
      end label
      define combosearchgrid name
         row 10
         col 80
         width 480
         items aItems
         headers { 'First Name', 'Last Name', 'Code' }
         widths { 200, 150, 100 }
         justify { 0, 0, 1 }
         anywheresearch .t.
         showheaders .t.
      end combosearchgrid
      define label label2
         row 40
         col 10
         width 60
         value 'Label 2'
         vcenteralign .t.
      end label
      define textbox textbox2
         row 40
         col 80
         width 200
      end textbox
      define button selected
         row 40
         col 300
         caption 'Click after selecting an item'
         width 200
         action findselecteditem()
      end button
   end window
   csg.center
   csg.activate

Return Nil

function findselecteditem
   local aData := {}
   local i
   local cMsg

   aData := _HMG_CSG_ItemSelected( 'csg', 'name' )
   if len( aData ) > 0
      cMsg := '{'
      for i := 1 to len( aData )
         cMsg := cMsg + aData[ i ] 
         if i < len( aData )
            cMsg := cMsg + ', ' 
         endif
      next i
      cMsg := cMsg + '}'
      msginfo( 'You have selected the item - ' + cMsg )
   endif
   return nil

function randomdatafill
   local aItems := {}
   local i, j
   local c := ''
   local d := ''

   for i := 1 to 10000
      c := ''
      for j := 1 to 10
         c := c + chr( int( random( 26 ) ) + 65 )
      next j
      d := ''
      for j := 1 to 5
         d := d + chr( int( random( 26 ) ) + 65 )
      next j
      aadd( aItems, { c, d, alltrim( str( i ) ) } )
   next i
   return aItems
