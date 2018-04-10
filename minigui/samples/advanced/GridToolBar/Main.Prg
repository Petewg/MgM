/*
  MINIGUI - Harbour Win32 GUI library Demo

  Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  Author: S.Rathinagiri <srgiri@dataone.in>

  Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include <hmg.ch>

Function Main
   Local aData

   SET CENTURY ON
   SET DATE GERMAN
   aData := LoadData()

   define window main at 0, 0 width 800 height 600 main title "Grid ToolBar Demo"
      define grid grid_1
         row 80
         col 120
         width 500
         height 400
         headers {'Column 1','Column 2','Column 3','Column 4','Column 5','Column 6'}
         widths { 100, 160, 160, 100, 100, 100 }
         justify { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER }
      end grid
   end window
   fillupdata( aData )
   
   _addGridToolBar( 'grid_1', 'main' )
   main.center()
   main.activate()

Return nil


function fillupdata( aData )

	AEVAL( aData, { |Value, RowIndex| main.grid_1.additem( { StrZero( Value[1], 10 ), ;
		Value[2] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Upper(Value[2]) , Lower(Value[2]) ) ), ;
		Value[3] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Lower(Value[3]) , Upper(Value[3]) ) ), ;
		Value[4] := DtoC( Value[4] ), ;
		Value[5] := if ( Value[5] == .T. , 'Yes' , 'No' ), ;
		Value[6] := "<memo>" } ) } )
return nil


Function LoadData
   Local aArr := {}

	USE TEST 
	INDEX ON TEST->CODE TO CODE

	GO TOP
	DO WHILE !EOF()
		AADD(aArr, { TEST->Code ,  TEST->First , TEST->Last ,  TEST->Birth , TEST->Married , TEST->Bio } )
		SKIP
	ENDDO

	USE
	FERASE('CODE.NTX')

Return aArr
