/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2010 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Based on RDDSQL sample included in Harbour distribution
*/

#include "minigui.ch"
#include "dbinfo.ch"

ANNOUNCE RDDSYS
REQUEST SDDSQLITE3, SQLMIX

Memvar MemvarT1Name
Memvar MemvarT1Age

Static nLastId
*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*

	RDDSETDEFAULT( "SQLMIX" )

	IF RDDINFO( RDDI_CONNECT, {"SQLITE3", hb_dirBase() + "test.sq3"} ) == 0
		MsgStop("Unable connect to the server!", "Error")
		Return nil
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'SQLITE3 Database Driver Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTable() ;
		ON RELEASE CloseTable()

		DEFINE MAIN MENU

			DEFINE POPUP 'File'
				ITEM "Exit"	ACTION ThisWindow.Release()
			END POPUP
			DEFINE POPUP 'Test'
				MENUITEM 'Add record'	ACTION AddRecord( 'New', random(68) )
			END POPUP

		END MENU

		@ 10,10 BROWSE Browse_1	;
			WIDTH 610	;
			HEIGHT 390	;	
			HEADERS { 'Code' , 'Name' , 'Age' } ;
			WIDTHS { 50 , 160 , 100 } ;
			WORKAREA t1 ;
			FIELDS { 't1->id' , 't1->name' , 't1->age' } ;
			JUSTIFY { 1 , 0 , 0 } ;
			EDIT INPLACE ;
			VALID { , { || sqlupdate(2) } , { || sqlupdate(3) } } ;
			READONLY { .T. , .F. , .F. }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return nil

*--------------------------------------------------------*
Procedure OpenTable
*--------------------------------------------------------*

   DBUSEAREA( .T.,, "select * from t1", "t1" )

   GO BOTTOM
   nLastId := t1->id

   INDEX ON FIELD->AGE TO age

   GO TOP

Return

*--------------------------------------------------------*
Procedure CloseTable
*--------------------------------------------------------*

   DBCLOSEALL()

Return

*--------------------------------------------------------*
Procedure AddRecord( cName, nAge )
*--------------------------------------------------------*
Local cNewValue

   cNewValue := cName + hb_ntos( ++nLastId )

   If RDDINFO(RDDI_EXECUTE, "INSERT INTO t1( name, age ) values ('" + cNewValue + "', " + hb_ntos( nAge ) + ")")

      // MsgInfo( RDDINFO(RDDI_AFFECTEDROWS), "Count of Affected Rows" )

      APPEND BLANK

      REPLACE ID WITH nLastId, ;
              NAME WITH cNewValue, ;
              AGE WITH nAge

      Form_1.Browse_1.Value := t1->(RecNo())
      Form_1.Browse_1.Refresh

   Else

	MsgStop("Can't append record to table!", "Error")

   EndIf

Return

*--------------------------------------------------------*
Function sqlupdate(nColumn)
*--------------------------------------------------------*
Local nValue := Form_1.Browse_1.Value
Local cId, cField, cNewValue

   If nColumn == 2

	cField := "Name"
	cNewValue := "'" + Memvar.T1.Name + "'"

   ElseIf nColumn == 3

	cField := "Age"
	cNewValue := hb_ntos( Memvar.T1.Age )

   EndIf

   GO nValue
   cId := "'" + ltrim(str(t1->id)) + "'"

   If ! RDDINFO(RDDI_EXECUTE, "UPDATE t1 SET " + cField + " = " + cNewValue + " WHERE id = " + cId)

	MsgStop("Can't update record in the table!", "Error")
	Return .F.

   EndIf

Return .T.
