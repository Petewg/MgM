#include <hmg.ch>

memvar _cAnywhereSearchStr

Function Main
   local aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ),   CRLF )
   local aCities := HB_ATOKENS( MEMOREAD( "LargCits.lst" ),   CRLF )
   local aNationalities := HB_ATOKENS( MEMOREAD( "Nationality.lst" ),   CRLF )
   local i
   local aGrid := {}
   local cActiveControl := 'tree1'
   public _cAnywhereSearchStr := ''
   
   set navigation extended
   
   asort( aCountries )
   asort( aCities )
   asort( aNationalities )
   
   for i := 1 to 150
      aadd( aGrid, { aCountries[ i ], aCities[ i ], aNationalities[ i ] } )
   next i
   define window main at 0, 0 width 800 height 600 main
      define label textboxlabel
         row 10
         col 10
         value 'Enter a search string'         
         autosize .t.
         vcenteralign .t.
      end label
      define textbox textbox
         row 10
         col 160
         onchange ( _cAnywhereSearchStr := getproperty( ThisWindow.Name, 'textbox', 'VALUE' ), ;
                    setproperty( ThisWindow.Name, '_anywherelabel', 'VALUE', _cAnywhereSearchStr ), ;
                    iif( empty(_HMGAnywhereSearch( cActiveControl, ThisWindow.Name, .t. )),;
                    ( setproperty( ThisWindow.Name, 'textbox', 'VALUE', _cAnywhereSearchStr ), ;
                    main.textbox.caretpos := len(_cAnywhereSearchStr) ), ) ;
                  )
         on lostfocus _HMGAnywhereSearchClear()
      end textbox
      DEFINE RADIOGROUP Radio
         ROW    10
         COL    300
         WIDTH  60
         HEIGHT 20
         OPTIONS { 'tree1','list1','combo1','grid1','grid2'}
         VALUE 1
         ONCHANGE cActiveControl := main.Radio.Caption(this.value)
         TABSTOP .T.
         VISIBLE .T.
         TRANSPARENT .F.
         SPACING 10
         HORIZONTAL .T.
      END RADIOGROUP

      define tree tree1 at 40, 10 width 200 height 200 ;
         on gotfocus ( cActiveControl := this.name, main.Radio.Value := 1 )
         node 'Parent 1'
            treeitem 'Child 1'
            treeitem 'Child 2'
            treeitem 'Child 3'
            node 'Sub-Parent 1'
               treeitem 'Child 4'
            end node   
         end node
      end tree 
      define listbox list1
         row 40
         col 210
         width 200
         height 200
         multiselect .t.
         fontname 'Arial'
         fontsize 14
         items aCountries
         value { 1 }
         on gotfocus ( cActiveControl := this.name, main.Radio.Value := 2 )
      end listbox
      define combobox combo1
         row 250
         col 10
         width 200
         items aNationalities
         fontname 'FixedSys'
         fontsize 12
         value 1
         on gotfocus ( cActiveControl := this.name, main.Radio.Value := 3 )
      end combobox
      define grid grid1
         row 280
         col 10
         width 350
         height 200
         items aGrid
         headers { 'Head1', 'Head2', 'Head3' }
         widths { 100, 100, 120 }
         value { 1 }
         multiselect .t.
         on gotfocus ( cActiveControl := this.name, main.Radio.Value := 4 )
      end grid
      define grid grid2
         row 280
         col 370
         width 330
         height 200
         virtual .t.
         itemcount 1000
         headers { 'Column1', 'Column2' }
         widths { 150, 150 }
         value 1 
         onquerydata testquery()
         on gotfocus ( cActiveControl := this.name, main.Radio.Value := 5 )
      end grid
      define label _anywherelabel
         row GetProperty( ThisWindow.Name, 'HEIGHT' ) - 85
         col 10
         width 200
         transparent .t.
         fontcolor { 255, 0, 0 }
         fontname 'Arial'
         fontsize 14
         fontbold .t.
         autosize .t.
      end label
      
      define statusbar 
         statusitem 'Status 1'
         statusitem 'Status 2'
         statusitem 'Status 3'
      end statusbar   
   end window
   main.textbox.setfocus
   main.center
   main.activate   
Return nil

function testquery
   This.QueryData := 'Row' + alltrim( Str ( This.QueryRowIndex ) ) + ', ' + 'Col' + alltrim( Str ( This.QueryColIndex ) )
return nil
