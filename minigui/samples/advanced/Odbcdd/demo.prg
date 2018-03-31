/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2009 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Based on RDDSQL ODBC sample included in Harbour distribution
*/

#include "minigui.ch"
#include "dbinfo.ch"
#include "error.ch"

ANNOUNCE RDDSYS
REQUEST SQLMIX, SDDODBC

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
LOCAL nConnection

	RDDSETDEFAULT( "SQLMIX" )

	SET( _SET_DATEFORMAT, "yyyy-mm-dd" )

	nConnection := RDDINFO( RDDI_CONNECT, { "ODBC", "Server=localhost;Driver={MySQL ODBC 3.51 Driver};dsn=;User=root;database=test;" } )
	IF nConnection == 0
		MsgStop("Unable connect to the server!", "Error")
		Return nil
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI ODBC Database Driver Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTable() ;
		ON RELEASE CloseTable()

		DEFINE MAIN MENU

			DEFINE POPUP 'File'
				ITEM "Exit"		ACTION ThisWindow.Release()
			END POPUP

		END MENU

		@ 10,10 BROWSE Browse_1	;
			WIDTH 610	;
			HEIGHT 390	;	
			HEADERS { 'Code' , 'Name' , 'Residents' } ;
			WIDTHS { 50 , 160 , 100 } ;
			WORKAREA country ;
			FIELDS { 'country->Code' , 'country->Name' , 'country->Residents' } ;
			JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT }

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return nil

*--------------------------------------------------------*
Procedure OpenTable
*--------------------------------------------------------*

   If CreateTable()

	DBUSEAREA( .T.,, "SELECT * FROM country", "country" )

	INDEX ON FIELD->RESIDENTS TAG residents TO country

	GO TOP

   Else

	Form_1.Release()

   EndIf

Return

*--------------------------------------------------------*
Procedure CloseTable
*--------------------------------------------------------*

   DBCLOSEALL()

Return

*--------------------------------------------------------*
Function CreateTable
*--------------------------------------------------------*
Local ret := .T.

   RDDINFO(RDDI_EXECUTE, "DROP TABLE country")

   If RDDINFO(RDDI_EXECUTE, "CREATE TABLE country (CODE char(3), NAME char(50), RESIDENTS int(11))")

      If ! RDDINFO(RDDI_EXECUTE, "INSERT INTO country values ('LTU', 'Lithuania', 3369600), ('USA', 'United States of America', 305397000), ('POR', 'Portugal', 10617600), ('POL', 'Poland', 38115967), ('AUS', 'Australia', 21446187), ('FRA', 'France', 64473140), ('RUS', 'Russia', 141900000)")

	MsgStop("Can't fill table Country!", "Error")
	ret := .F.

      EndIf

   Else

	MsgStop("Can't create table Country!", "Error")
	ret := .F.

   EndIf

Return ret
