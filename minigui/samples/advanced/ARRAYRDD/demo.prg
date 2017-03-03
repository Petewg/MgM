/*
 * RDD SQL DEMO
 * Based on Harbour Compiler Contrib Sample
 * Adapted for MiniGUI Extended Edition by Grigory Filatov - 2009
*/

#include "hmg.ch"

ANNOUNCE RDDSYS
REQUEST SQLMIX

PROCEDURE main()

   SET MULTIPLE OFF

   rddSetDefault( "SQLMIX" )
   dbCreate( "persons", { { "NAME", "C", 20, 0 }, { "FAMILYNAME", "C", 20, 0 }, { "BIRTH", "D", 8, 0 }, { "MARRIED", "L", 1, 0 }, { "AMOUNT", "N", 9, 2 } }, , .T., "persons" )

   dbAppend(); AEval( { PadR( "Bil", 20 ),  PadR( "Gatwick", 20 ),  hb_SToD( "19650124" ), .t., 123456.78 }, {| X, Y | FieldPut( Y, X ) } )
   dbAppend(); AEval( { PadR( "Tom", 20 ),  PadR( "Heathrow", 20 ), hb_SToD( "19870512" ), .f.,   9086.54 }, {| X, Y | FieldPut( Y, X ) } )
   dbAppend(); AEval( { PadR( "John", 20 ), PadR( "Weber", 20 ),    hb_SToD( "19750306" ), .f.,   2975.45 }, {| X, Y | FieldPut( Y, X ) } )
   dbAppend(); AEval( { PadR( "Sim", 20 ),  PadR( "Simsom", 20 ),   hb_SToD( "19930705" ), .t.,  32975.37 }, {| X, Y | FieldPut( Y, X ) } )
   
   msgdebug( alias(), select() )
   
   INDEX ON FIELD->AMOUNT TO amount
   DBGOTOP()

	DEFINE WINDOW Win_1 ;
		ROW 0 ;
		COL 0 ;
		WIDTH 600 ;
		HEIGHT 400 ;
		TITLE 'RDD SQL Array Test' ;
		WINDOWTYPE MAIN  

		DEFINE BROWSE browse1
			ROW 		10
			COL 		10
			WIDTH		570			
			HEIGHT		330
			HEADERS 	{'Name','Family Name','Birth','Married','Amount'}
			WIDTHS		{125,125,105,60,90}
			WORKAREA	Persons
			FIELDS		{'Persons->NAME','Persons->FAMILYNAME','Persons->Birth','Persons->Married','Persons->Amount'}
			JUSTIFY		{ ,,BROWSE_JTFY_CENTER,, BROWSE_JTFY_RIGHT }
			ALLOWEDIT 	.T.
			INPLACEEDIT 	.T.
		END BROWSE
		                           	
		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Win_1.Center
	Win_1.Activate

RETURN
