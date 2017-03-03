
memvar _hmg_dbg

#include "hmg.ch"

PROCEDURE Test_DBF
Local aData

   IF _IsControlDefined ( "Grid_1", "Form1" )
      RETURN
   ENDIF

   SetProperty ( "Form1", "Button_1", "Enabled", .F. )

	aData := LoadData()

	AEVAL( aData, { |Value, RowIndex| Value[1] := StrZero( Value[1], 5 ), ;
		Value[2] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Upper(Value[2]) , Lower(Value[2]) ) ), ;
		Value[3] := Trim( if ( RowIndex/2 == int(RowIndex/2) , Lower(Value[3]) , Upper(Value[3]) ) ), ;
		Value[4] := DtoC( Value[4] ), ;
		Value[5] := if ( Value[5] == .T. , 'Yes' , 'No' ), ;
		Value[6] := "<memo>" } )

		@ 10,10 GRID Grid_1 OF Form1;
			WIDTH 300 ;
			HEIGHT 340 ;
			HEADERS {'Column 1','Column 2','Column 3','Column 4','Column 5','Column 6'} ;
			WIDTHS {100,140,140,100,100,100};
			VIRTUAL ;
			ITEMCOUNT Len(aData) ;
			ON QUERYDATA QueryTest(aData) ;
			CELLNAVIGATION ;
			VALUE { 1 , 1 } ;
			JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER } ;
			FONT 'Courier New' ;
			SIZE 9 

         select 33
         USE TEST2 // SHARED
         GO 7

RETURN

Procedure QueryTest( aArr )

	This.QueryData := aArr[ This.QueryRowIndex ][ This.QueryColIndex ]

Return

Function LoadData
Local aArr := {}

	USE TEST 
	INDEX ON TEST->CODE TO CODE

	GO TOP
	DO WHILE !EOF()
		AADD(aArr, { TEST->Code ,  TEST->First , TEST->Last ,  TEST->Birth , TEST->Married , TEST->Bio } )
		SKIP
	ENDDO

	GO TOP

Return aArr
