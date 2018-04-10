/*
  MINIGUI - Harbour Win32 GUI library Demo

  (c) 2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "dbstruct.ch"

PROCEDURE Main

   LOCAL aHead, aWidth, aFld, aSort, i
   LOCAL lInit := .F.

   Set Default Icon To GetStartupFolder() + "\Main.ico"

   filltable( 10000 )

   DEFINE WINDOW Form1 ;
	WIDTH 640 HEIGHT 480 ;
	TITLE "Browse Columns Sort Demo" ;
	MAIN

	aHead := { 'First' , 'Last', 'Street', 'City', 'State', 'Zip', 'Hire Date', /*'Married',*/ 'Age', 'Salary', 'Notes' }

	aWidth:= { 110, 150, 150, 150, 80, 60, 100, /*80,*/ 60, 80, 200 }

	aFld  := {}

        For i:=1 To FCount()
                if FieldName(i) == 'MARRIED'
                   loop
                endif
		AAdd(aFld, FieldName(i))
	Next

	aSort := Array( Len(aFld) )

	AFill( aSort, .T. )
	aSort[ 3 ] := .F.
	aSort[ 4 ] := .F.
	aSort[ Len(aSort) ] := .F.
/*
	@ 10,10 BROWSE Brw_1;
		WIDTH 600 ;
		HEIGHT 420;
		WORKAREA TEST ;
		HEADERS aHead ;
		WIDTHS aWidth ;
		FIELDS aFld ;
		VALUE 1 ;
		ON GOTFOCUS iif(lInit, , (HMG_SetOrder( 1, .F. ), lInit := .T.)) ;
		COLUMNSORT aSort
*/
	DEFINE BROWSE Brw_1
		ROW         10
		COL         10
		WIDTH       600
		HEIGHT      420
		WORKAREA    TEST
		HEADERS     aHead
		WIDTHS      aWidth
		FIELDS      aFld
		VALUE       1
		ON GOTFOCUS iif(lInit, , (HMG_SetOrder( 1, .F. ), lInit := .T.))
		COLUMNSORT  aSort
	END BROWSE

	ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form1
   ACTIVATE WINDOW Form1

RETURN


#translate dbcreate(<file>, <struct>) => hb_dbcreatetemp(<file>, <struct>)
//////////////////////////////////////////////////////////////////////
PROCEDURE filltable ( nCount )

   LOCAL aDbf[11][4], i

   if !file('test.dbf')
        aDbf[1][ DBS_NAME ] := "First"
        aDbf[1][ DBS_TYPE ] := "Character"
        aDbf[1][ DBS_LEN ]  := 20
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "Last"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 20
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Street"
        aDbf[3][ DBS_TYPE ] := "Character"
        aDbf[3][ DBS_LEN ]  := 30
        aDbf[3][ DBS_DEC ]  := 0
        //
        aDbf[4][ DBS_NAME ] := "City"
        aDbf[4][ DBS_TYPE ] := "Character"
        aDbf[4][ DBS_LEN ]  := 30
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "State"
        aDbf[5][ DBS_TYPE ] := "Character"
        aDbf[5][ DBS_LEN ]  := 2
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Zip"
        aDbf[6][ DBS_TYPE ] := "Character"
        aDbf[6][ DBS_LEN ]  := 10
        aDbf[6][ DBS_DEC ]  := 0
        //
        aDbf[7][ DBS_NAME ] := "Hiredate"
        aDbf[7][ DBS_TYPE ] := "Date"
        aDbf[7][ DBS_LEN ]  := 8
        aDbf[7][ DBS_DEC ]  := 0
        //
        aDbf[8][ DBS_NAME ] := "Married"
        aDbf[8][ DBS_TYPE ] := "Logical"
        aDbf[8][ DBS_LEN ]  := 1
        aDbf[8][ DBS_DEC ]  := 0
        //
        aDbf[9][ DBS_NAME ] := "Age"
        aDbf[9][ DBS_TYPE ] := "Numeric"
        aDbf[9][ DBS_LEN ]  := 2
        aDbf[9][ DBS_DEC ]  := 0
        //
        aDbf[10][ DBS_NAME ] := "Salary"
        aDbf[10][ DBS_TYPE ] := "Numeric"
        aDbf[10][ DBS_LEN ]  := 6
        aDbf[10][ DBS_DEC ]  := 0
        //
        aDbf[11][ DBS_NAME ] := "Notes"
        aDbf[11][ DBS_TYPE ] := "Character"
        aDbf[11][ DBS_LEN ]  := 70
        aDbf[11][ DBS_DEC ]  := 0

        DBCREATE("test", aDbf)
   endif

   if select('test') == 0
      dbusearea(.t.,,'test')
   endif

   if lastrec() == 0
      for i := 1 to nCount
         append blank

         replace   first      with   'First'   + str(i)
         replace   last       with   'Last'    + str(i)
         replace   street     with   'Street'  + str(i)
         replace   city       with   'City'    + str(i)
         replace   state      with   chr( HB_RANDOMINT( 65,90 ) ) + chr( HB_RANDOMINT( 65,90 ) )
         replace   zip        with   strzero( HB_RANDOMINT( 9999 ), 4 )
         replace   hiredate   with   date() - 20000 + i
         replace   married    with   ( HB_RANDOMINT() == 1 )
         replace   age        with   HB_RANDOMINT( 18,75 )
         replace   salary     with   HB_RANDOMINT( 10000 )
         replace   notes      with   'Notes' + str(i)
      next i
   endif

   dbGoTop()

RETURN
