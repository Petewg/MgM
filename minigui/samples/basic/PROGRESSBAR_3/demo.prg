/*
  MINIGUI - Harbour Win32 GUI library Demo
  (c) 2014 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "dbstruct.ch"

DECLARE WINDOW Form_PrgBar

PROCEDURE Main

   Set Default Icon To GetStartupFolder() + "\Main.ico"

   DEFINE WINDOW Form1 ;
	AT 0 , 0 ;
	WIDTH 600 HEIGHT 400 ;
	TITLE "ProgressBar Demo" ;
	MAIN ;
	ON INIT filltable( 500 )

	DEFINE BUTTON Button_1
		ROW 20
		COL 20
		WIDTH 80
		HEIGHT 28
		CAPTION "Process 1"
		ACTION NtxCreate( FIELD(9), FIELD(9) )
                DEFAULT .T.
	END BUTTON

	DEFINE BUTTON Button_2
		ROW 20
		COL 120
		WIDTH 80
		HEIGHT 28
		CAPTION "Process 2"
		ACTION SkipTest()
	END BUTTON

	ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form1
   ACTIVATE WINDOW Form1

RETURN

///////////////////////////////////////////////////////////////////
FUNCTION NtxCreate( cField, cNtxName )

   CreateProgressBar( "Create index " + cNtxName + "..." )  

   INDEX ON &cField TO (cNtxName) EVAL NtxProgress() EVERY LASTREC()/10

   Form_PrgBar.PrgBar_1.Value := 100
   Form_PrgBar.Label_1.Value := "Completed 100%"
   // final waiting
   INKEYGUI(1000)
   SET INDEX TO

   CloseProgressBar()

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION NtxProgress()

   LOCAL nComplete := INT((RECNO()/LASTREC()) * 100)

   Form_PrgBar.PrgBar_1.Value := nComplete
   Form_PrgBar.Label_1.Value := "Completed "+ +HB_NTOS(nComplete) + "%"
   // refreshing
   INKEYGUI(100)

RETURN .T.

///////////////////////////////////////////////////////////////////
FUNCTION SkipTest()

   LOCAL nComplete

   CreateProgressBar( "Processing..." )  

   GO TOP
   DO WHILE !EOF()
      nComplete := INT((RECNO()/LASTREC()) * 100)
      IF nComplete % 10 == 0
         Form_PrgBar.PrgBar_1.Value := nComplete
         Form_PrgBar.Label_1.Value := "Completed "+ +HB_NTOS(nComplete) + "%"
         // refreshing
         INKEYGUI(20)
      ENDIF
      DBSKIP()
   ENDDO
   // final waiting
   INKEYGUI(1000)

   CloseProgressBar()

RETURN NIL

//////////////////////////////////////////////////////////////////////
FUNCTION CreateProgressBar( cTitle )

DEFINE WINDOW Form_PrgBar ;
      ROW 0 COL 0 ;
      WIDTH 428 HEIGHT 200 ;
      TITLE cTitle ;
      WINDOWTYPE MODAL ;
      NOSIZE ;
      FONT 'Tahoma' SIZE 11

  @ 10,80 ANIMATEBOX Avi_1 ;
      WIDTH 260 HEIGHT 40 ;
      FILE 'filecopy.avi' ;
      AUTOPLAY TRANSPARENT NOBORDER

  @ 75,10 LABEL Label_1   ;
      WIDTH 400 HEIGHT 20 ;
      VALUE ''            ;
      CENTERALIGN VCENTERALIGN

  @ 105,20 PROGRESSBAR PrgBar_1 ;
      RANGE 0,100         ;
      VALUE 0             ;
      WIDTH 380 HEIGHT 34

END WINDOW

Form_PrgBar.Center
Activate Window Form_PrgBar NoWait

RETURN NIL

//////////////////////////////////////////////////////////////////////
FUNCTION CloseProgressBar()

   Form_PrgBar.Release

   DO MESSAGE LOOP

RETURN NIL

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

         replace   first      with   'first'   + str(i)
         replace   last       with   'last'    + str(i)
         replace   street     with   'street'  + str(i)
         replace   city       with   'city'    + str(i)
         replace   state      with   chr( HB_RANDOMINT( 65,90 ) ) + chr( HB_RANDOMINT( 65,90 ) )
         replace   zip        with   alltrim( str( HB_RANDOMINT( 9999 ) ) )
         replace   hiredate   with   date() - 20000 + i
         replace   married    with   ( HB_RANDOMINT() == 1 )
         replace   age        with   HB_RANDOMINT( 18,75 )
         replace   salary     with   HB_RANDOMINT( 10000 )
         replace   notes      with   'notes' + str(i)
      next i
   endif
   GO TOP

RETURN
