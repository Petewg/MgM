/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2009 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Based on tsttable sample included in xHarbour distribution
*/

#include "minigui.ch"
#include 'ttable.ch'

Request Dbfcdx

PROCEDURE main

   LOCAL x := 1
   LOCAL oTable, cAlias
   LOCAL bColor := { || if ( deleted() , RGB( 255, 0, 0 ) , RGB( 255, 255, 255 ) ) }	
   
   RDDSETDEFAULT( 'dbfcdx')

   SET CENTURY ON

   doData()

   /*Open a Table with Table Class */
   DEFINE TABLE oTable FILE test ALIAS Table SHARED NEW
   
   /*Adding an Index to This Table */
   DEFINE ORDER ON KEY "name" TAG _1 IN oTable

   IF !FILE( 'test.cdx' )

      /* Force the index Creating */
      oTable:Reindex()

   ENDIF

   IF oTable:LastRec() == 0

      WHILE x <= 100

         oTable:ReadBlank()

         oTable:name   := Str( x, 20 )
         oTable:street := Str( x + 1, 20 )
         oTable:city   := Str( x + 2, 20 )
         oTable:code   := x
         oTable:today  := Date()
         oTable:pay    := ( x % 2 ) == 0

         oTable:Append()

         oTable:Write()

         x ++

      ENDDO

      oTable:GoTop()

   ENDIF

   cAlias := oTable:Alias

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 640 HEIGHT 480 ;
	TITLE 'MiniGUI Table Class Demo' ;
	MAIN NOMAXIMIZE ;
	ON RELEASE CloseTable()

	DEFINE MAIN MENU 
		POPUP 'File'
			ITEM 'Append record'		ACTION Append_record(oTable)
			ITEM 'Undo the last writing'		ACTION Undo_record(oTable)
			ITEM 'Delete record'		ACTION Delete_record(oTable)
			ITEM 'Roolback the ALL deleting'	ACTION Undo_delete(oTable)
			SEPARATOR
			ITEM 'Exit'			ACTION Form_1.Release
		END POPUP
		POPUP 'Help'
			ITEM 'About'			ACTION MsgInfo ("MiniGUI Table Class Demo") 
		END POPUP

	END MENU

	DEFINE STATUSBAR KEYBOARD FONT 'Tahoma' SIZE 9
	END STATUSBAR

	@ 10,10 BROWSE Browse_1	;
		WIDTH 610	;
		HEIGHT 382	;	
		HEADERS { 'Code' , 'Name' , 'Street' , 'City' , 'Date' , 'Pay' } ;
		WIDTHS { 80 , 100 , 100 , 100 , 100 , 50 } ;
		WORKAREA &cAlias ;
		FIELDS { 'Code' , 'Name' , 'Street' , 'City' , 'Today' , 'Pay' } ;
		JUSTIFY { BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER, BROWSE_JTFY_LEFT, BROWSE_JTFY_CENTER } ;
		DYNAMICBACKCOLOR { bColor, bColor, bColor, bColor, bColor, bColor } ;
		EDIT INPLACE ;
		LOCK ;
		WHEN { {|| Empty(Field->Code) }, , , , , }

	ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   CENTER WINDOW Form_1

   Form_1.Browse_1.SetFocus

   ACTIVATE WINDOW Form_1

RETURN


Procedure Append_record(oTable)
Local i := GetControlIndex ( "Browse_1", "Form_1" ), n

   oTable:GoBottom()

   n := oTable:code

   IF n < 2  // trick for a wrong GO BOTTOM at the first time
	n := oTable:RecNo()
   ENDIF

   oTable:ReadBlank()

   oTable:name   := Str( n + 1, 20 )
   oTable:street := Str( n + 2, 20 )
   oTable:city   := Str( n + 3, 20 )
   oTable:Code   := n + 1
   oTable:today  := Date()
   oTable:pay    := ( n % 2 ) == 0

   oTable:Append()

   BEGIN TRANSACTION IN oTable

	oTable:Write()

   END TRANSACTION IN oTable

   Form_1.Browse_1.Value := oTable:RecNo()

   ProcessInPlaceKbdEdit(i)

   Form_1.Browse_1.SetFocus

Return


Procedure Delete_record(oTable)
Local nValue := Form_1.Browse_1.Value

   oTable:GoTo(nValue)

   BEGIN TRANSACTION IN oTable

	oTable:Delete()

   END TRANSACTION IN oTable

   IF oTable:LastRec() == nValue
	nValue --
   ELSE
	nValue ++
   ENDIF

   Form_1.Browse_1.Value := nValue

   Form_1.Browse_1.Refresh
   Form_1.Browse_1.SetFocus

Return


Procedure Undo_record(oTable)

   ROLLBACK _WRITE_BUFFER STEP 1 IN oTable

   Form_1.Browse_1.Refresh
   Form_1.Browse_1.SetFocus

Return


Procedure Undo_delete(oTable)

   ROLLBACK _DELETE_BUFFER IN oTable

   Form_1.Browse_1.Refresh
   Form_1.Browse_1.SetFocus

Return


Procedure CloseTable

   USE

Return


PROCEDURE dodata()

   LOCAL oTable

   IF !FILE( 'test.dbf' )

      /* Create a Table using Table Class Syntax */

      CREATE DATABASE oTable FILE test.dbf

      FIELD NAME name   TYPE CHARACTER LEN 40 DEC 0 OF oTable
      FIELD NAME street TYPE CHARACTER LEN 40 DEC 0 OF oTable
      FIELD NAME city   TYPE CHARACTER LEN 40 DEC 0 OF oTable
      FIELD NAME code   TYPE NUMERIC   LEN  5 DEC 0 OF oTable
      FIELD NAME today  TYPE DATE      LEN  8 DEC 0 OF oTable
      FIELD NAME pay    TYPE LOGICAL   LEN  1 DEC 0 OF oTable

      BUILD TABLE oTable

   ENDIF

RETURN
