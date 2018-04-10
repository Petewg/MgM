/*
 * SQLite3 Demo
 *
 * Copyright 2007 Grigory Filatov <gfilatov@inbox.ru>
 * 2011 Printer support by Pierpaolo Martinello pier.martinello[at]alice.it
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include "minigui.ch"
#include "hbsqlit3.ch"

Memvar aRtv
Memvar aRtvl, cTitle

//////////////////////////////
PROCEDURE main()
//////////////////////////////

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'SQLite Demo' ;
		ICON 'sqlite.ico' ;
		MAIN ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT OnInit() ;
		ON RELEASE _dummy()

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

RETURN

//////////////////////////////
PROCEDURE OnInit()
//////////////////////////////
  LOCAL aTest := {}, nPos

  AADD( aTest, "See SQLite Version" )
  AADD( aTest, "See ALL tables" )
  AADD( aTest, "See ALL Columns (Fields)" )
  AADD( aTest, "See Table struct (Fields)" )
  AADD( aTest, "Show data" )
  AADD( aTest, "Append From DBF" )
  AADD( aTest, "Browse and print data" )
  AADD( aTest, "Drop Table" )
  AADD( aTest, "EXIT" )

  @ 10, 10 LABEL Label_1 ;
	OF Win_1 ;
	VALUE "Harbour Interface for SQLite - Select test and press Enter" ;
	AUTOSIZE

  DO WHILE .T.
    IF !EMPTY( nPos := ACHOICE( 3,0,20,33,aTest,,,nPos,.f. ) )
      Test( nPos )
    ELSE
      EXIT
    ENDIF
  ENDDO

  Win_1.Release

RETURN

#ifdef __XHARBOUR__
   #xcommand OTHERWISE => DEFAULT
#endif
//////////////////////////////
PROCEDURE Test( n )
//////////////////////////////

  SWITCH n
      CASE 1
         ShowVersion()
         EXIT

      CASE 2
         ShowTables(.F.)
         EXIT

      CASE 3
         ShowFields( ShowTables(.T.) )
         EXIT

      CASE 4
         ShowCOLInfo( ShowTables(.T.) )
         EXIT

      CASE 5
         ShowData( ShowTables(.T.) )
         EXIT

      CASE 6
         CreatefromDBF( "Names.Dbf" )
         EXIT

      CASE 7
         BrowseData()
         EXIT

      CASE 8
         IF SQLITE_DROPTABLE()
		MsgInfo( "Table was dropped successfully", "Result" )
         ENDIF
         EXIT

      OTHERWISE
         Win_1.Release
  END

RETURN

#translate Alert( <c>, <t> ) => MsgExclamation( <c>, <t> )

*----------------------
 FUNCTION ShowVersion()
*---------------------------------------------------------------------------
* Shows SQLite version
*---------------------------------------------------------------------------
  ALERT( "Version library = " + sqlite3_libversion() + CRLF + ;
         "number version library = " + LTRIM(STR( sqlite3_libversion_number() )), ;
         "SQLITE INFO" )
RETURN 0

*-------------------------------
 FUNCTION ShowTables( lMsgShow )
*---------------------------------------------------------------------------
* Shows all tables inside the database
*---------------------------------------------------------------------------
 LOCAL aResult, nChoices, cTitle

  * Show all tables inside database
  aResult := SQLITE_TABLES()

  IF VALTYPE(lMsgShow) == "L" .AND. lMsgShow == .T.
     cTitle := "Pick a Table"
  ELSE
     cTitle := "List Of Tables"
  ENDIF

  nChoices := ACHOICE( 10,11,20,31, aResult, cTitle )


RETURN( IIF( nChoices > 0, aResult[ nChoices ], "") )

*-----------------------------
 FUNCTION ShowFields( cTable )
*---------------------------------------------------------------------------
* Shows fields on a box from given table
*---------------------------------------------------------------------------
  LOCAL aResult, nChoices

  * Show all tables inside database
  IF VALTYPE( cTable ) != "C" .OR. EMPTY( cTable ) .OR. cTable == NIL
     RETURN("")
  ELSE
     aResult := SQLITE_FIELDS( cTable )
  ENDIF

  AEVAL( aResult, {| aVal, nIndex | ;
               aResult[ nIndex ] := STR( nIndex, 3) + ". " + aVal } )

  nChoices := ACHOICE( 10,11,20,31, aResult, "Fields" )

RETURN( IIF( nChoices > 0, aResult[ nChoices ], "") )

*------------------------------
 FUNCTION ShowCOLInfo( cTable )
*---------------------------------------------------------------------------
* Shows Information about fields...
*---------------------------------------------------------------------------
  LOCAL aResult, nChoices

  IF VALTYPE( cTable ) != "C" .OR. EMPTY( cTable ) .OR. cTable == NIL
    RETURN 0
   ELSE
     aResult := SQLITE_COLUMNS( cTable )
  ENDIF

  AEVAL( aResult, {| aVal, nIndex | ;
		aResult[ nIndex ] := STR( nIndex, 3) + ". " + aVal[1] + "  " + aVal[2] } )

  nChoices := ACHOICE( 9,4,20,75, aResult, "Fields with Types" )

RETURN nChoices

*---------------------------
 FUNCTION ShowData( cDBase )
*---------------------------------------------------------------------------
* Shows data
*---------------------------------------------------------------------------
  LOCAL lCreateIfNotExist := .f.
  LOCAL db
  LOCAL aResult
  LOCAL cQuery

  IF cDBase == NIL .OR. EMPTY(cDBase)
    RETURN 0
  ENDIF

  db := sqlite3_open( "test.db", lCreateIfNotExist )
  cQuery := PADR("select * from " + cDBase, 40)

  DO WHILE ! EMPTY( cQuery )

    cQuery := InputBox ( 'Enter Query' , 'Select' , cQuery )

    IF EMPTY(cQuery)
       LOOP
    ENDIF

    aResult := SQLITE_QUERY( db, RTRIM( cQuery ) + ";")

    IF EMPTY(LEN(aResult))
       IF !MsgRetryCancel("No record match your query. Retry ?", "Empty")
          RETURN 0
       ENDIF
       LOOP
    ENDIF

    ACHOICE( 10,11,20,31, aResult, "Query Result" )

    IF !MsgRetryCancel("New Query ?", "Question")
       EXIT
    ENDIF

  ENDDO

RETURN 0

*------------------------------
 FUNCTION CreatefromDBF( cDBase )
*---------------------------------------------------------------------------
  LOCAL cHeader, cQuery := "", NrReg:= 0, cTable := cFileNoExt(cDBase)
  LOCAL lCreateIfNotExist := .f.
  LOCAL db

  IF FILE( cDBase )

    IF !SQLITE_TABLEEXISTS( cTable )
	db := sqlite3_open( "test.db", lCreateIfNotExist )
	sqlite3_exec( db, "PRAGMA auto_vacuum=0" )

	* Create table
	cHeader := "create table " + cTable + "( Code INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, eMail TEXT );"
	IF sqlite3_exec( db, cHeader ) == SQLITE_OK

		Use Names Alias Names New
		go top
		Do While !Eof()
			cQuery += "INSERT INTO "+ cTable + "( Name, eMail ) VALUES ( '"+ AllTrim(Names->Name)+"' , '"+Names->Email+"' );"
			NrReg++
			skip
		EndDo
		use

		IF sqlite3_exec( db, ;
			"BEGIN TRANSACTION;" + ;
			cQuery + ;
			"COMMIT;" ) == SQLITE_OK

			MsgInfo( AllTrim(Str(NrReg))+" records added to table "+cTable, "Result" )

		ENDIF
	ENDIF

    ELSE

      MsgStop( "Table "+cTable+" already exists!" )

    ENDIF

  ELSE

    MsgStop( "File "+cDBase+" doesn't exist!" )

  ENDIF

RETURN 0

*---------------------
 FUNCTION BrowseData()
*---------------------------------------------------------------------------
* Browse data
*---------------------------------------------------------------------------
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( "test.db", lCreateIfNotExist )

IF SQLITE_TABLEEXISTS( "Names" )

  DEFINE WINDOW Grid_Names ;
    AT 5,5 ;
    WIDTH 440 HEIGHT 460 ;
    TITLE "Names" ;
    NOSYSMENU ;
    FONT "Arial" SIZE 09

  @ 10,10 GRID Grid_1 ;
    WIDTH  415 ;
    HEIGHT 329 ;
    HEADERS {"Code", "Name"};
    WIDTHS  {60, 335} ;
    VALUE 1 ;
    PAINTDOUBLEBUFFER ;
    ON DBLCLICK Get_Fields(db, 2)

  @ 357,11 LABEL  Label_Search_Generic ;
    VALUE "Search " ;
    WIDTH 70 ;
    HEIGHT 20

  @ 353,85 TEXTBOX cSearch ;
    WIDTH 326 ;
    MAXLENGTH 40 ;
    UPPERCASE ;
    ON ENTER iif( !Empty(Grid_Names.cSearch.Value), Grid_fill(db), Grid_Names.cSearch.SetFocus )

  @ 397-IF(IsThemed(),7,0),11 BUTTON Bt_New ;
    CAPTION '&New' ;
    ACTION Get_Fields(db, 1);
    width 80

  @ 397-IF(IsThemed(),7,0),91 BUTTON Bt_Edit ;
    CAPTION '&Edit' ;
    ACTION Get_Fields(db, 2);
    width 80

  @ 397-IF(IsThemed(),7,0),171 BUTTON Bt_Delete ;
    CAPTION '&Delete' ;
    ACTION Delete_Record(db);
    width 80

  @ 397-IF(IsThemed(),7,0),251 BUTTON Bt_Print ;
    CAPTION '&Print' ;
    ACTION ReportData(db) ;
    width 80

  @ 397-IF(IsThemed(),7,0),331 BUTTON Bt_exit ;
    CAPTION '&Exit' ;
    ACTION ThisWindow.Release;
    width 80

  END WINDOW 

  Grid_Names.cSearch.Value:= "A" 

  Grid_fill(db)
             
  CENTER WINDOW Grid_Names
  ACTIVATE WINDOW Grid_Names

ELSE

  MsgStop( "Table Names doesn't exist!" )

ENDIF

RETURN 0

*--------------------------------------------------------------*
Function Grid_fill( db )
*--------------------------------------------------------------*
Local cSearch:= " '"+AllTrim( Grid_Names.cSearch.Value )+"%' "           
Local aResult:= {}
Local i, cCode, cName

DELETE ITEM ALL FROM Grid_1 Of Grid_Names

aResult := SQLITE_QUERY( db, "SELECT CODE, NAME FROM Names WHERE NAME LIKE "+cSearch+" ORDER BY NAME")

if LEN(aResult) > 0
  Grid_Names.Grid_1.DisableUpdate 
  For i := 1 To LEN(aResult) Step 2
    cCode := aResult[i]
    cName := aResult[i+1]
    ADD ITEM { Padr(cCode, 4), cName } TO Grid_1 Of Grid_Names
  Next
  Grid_Names.Grid_1.EnableUpdate 
endif

Grid_Names.cSearch.SetFocus  

Return Nil

*--------------------------------------------------------------*
Function ReportData ( db )
*--------------------------------------------------------------*
Local cSearch:= " '"+AllTrim( Grid_Names.cSearch.Value )+"%' "
Local aResult, i
Private aRtv := {}

aResult := SQLITE_QUERY( db, "SELECT CODE, NAME FROM Names WHERE NAME LIKE "+cSearch+" ORDER BY NAME" )

if LEN(aResult) > 0
   For i := 1 To LEN(aResult) Step 2
       aadd(aRtv,{val(aResult[i]),space(3)+aResult[i+1]})
   next
   Winrepint("Report.Rpt", aRtv)
endif
release aRtv

Grid_Names.cSearch.SetFocus

Return Nil

*--------------------------------------------------------------*
Function Get_Fields( db, status )
*--------------------------------------------------------------*
Local pCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))            
Local cCode:= ""
Local cName:= ""
Local cEMail:= ""
Local aResult:= {}
            
If status == 2
  If EMPTY(Grid_Names.Grid_1.Value)
    Return Nil
  EndIf         
  aResult := SQLITE_QUERY( db, "SELECT * FROM Names WHERE CODE = " + AllTrim(pCode))
  cCode	:= aResult[1]
  cName	:= aResult[2]
  cEMail:= aResult[3]
EndIf         
              
DEFINE WINDOW Form_4 ;
  AT 0,0 ;
  WIDTH 485 HEIGHT 240 ;
  TITLE iif( status==1 , "Add new record" , "Edit record" )  ;			
  NOMAXIMIZE ;
  FONT "Arial" SIZE 09

  @ 20,30 LABEL Label_Code ;
    VALUE "Code" ;
    WIDTH 150 ;
    HEIGHT 35 ;
    BOLD

  @ 55, 30 LABEL Label_Name ;
    VALUE "Name" ;
    WIDTH 120 ;
    HEIGHT 35 ;
    BOLD

  @ 90,30 LABEL Label_eMail ;
    VALUE "e-Mail" ;
    WIDTH 120 ;
    HEIGHT 35 ;
    BOLD

  @ 24,100 TEXTBOX p_Code ;
    VALUE cCode ;
    WIDTH 50 ;			
    HEIGHT 25 ;
    ON ENTER iif( !Empty(Form_4.p_Code.Value), Form_4.p_Name.SetFocus, Form_4.p_Code.SetFocus ) ;
    RIGHTALIGN

  @ 59,100 TEXTBOX p_Name ;
    HEIGHT 25 ;
    VALUE cName ;
    WIDTH 350 ;
    ON ENTER iif( !Empty(Form_4.p_Name.Value), Form_4.p_eMail.SetFocus, Form_4.p_Name.SetFocus )
									
  @ 94,100 TEXTBOX p_eMail ;
    HEIGHT 25 ;
    VALUE cEMail ;
    WIDTH 350 ;
    ON ENTER Form_4.Bt_Confirm.SetFocus

  @ 165,100 BUTTON Bt_Confirm ;
    CAPTION '&Confirm' ;
    ACTION Set_Record( db, status )

  @ 165,300 BUTTON Bt_Cancel ;
    CAPTION '&Cancel' ;
    ACTION Form_4.Release

END WINDOW

Form_4.p_Code.Enabled:= .F.

CENTER WINDOW Form_4
ACTIVATE WINDOW Form_4

Return Nil

*--------------------------------------------------------------*
Function GetColValue( xObj, xForm, nCol)
*--------------------------------------------------------------*
  Local nPos:= GetProperty(xForm, xObj, 'Value')
  Local aRet:= GetProperty(xForm, xObj, 'Item', nPos)
Return aRet[nCol] 

*--------------------------------------------------------------*
Function Set_Record( db, status )
*--------------------------------------------------------------*
Local gCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))
Local cCode:= AllTrim(Form_4.p_Code.Value)
Local cName:= AllTrim(Form_4.p_Name.Value)
Local cEMail:= AllTrim(Form_4.p_EMail.Value)
Local cQuery

If status == 1
  cQuery := "INSERT INTO Names  VALUES ( NULL, '"+AllTrim(UPPER(cName))+"' , '"+cEmail+ "' ) "
Else
  cQuery := "UPDATE Names SET  NAME = '"+cName+"' , eMail = '"+cEMail+"'  WHERE CODE = " + AllTrim(gCode)
Endif

If sqlite3_exec( db, cQuery ) == SQLITE_OK
					 																			
  MsgInfo( iif(status== 1, "Record is added", "Record is updated"), "Result" )

Endif

Form_4.Release

Grid_Names.cSearch.Value:=Left(cName, 1)

Grid_fill(db)

Return Nil

*--------------------------------------------------------------*
Function Delete_Record( db )
*--------------------------------------------------------------*
Local gCode:= AllTrim(GetColValue("Grid_1", "Grid_Names", 1 ))
Local gName:= AllTrim(GetColValue("Grid_1", "Grid_Names", 2 ))
Local cQuery      
Local oQuery      
                        
If !Empty( gName ) 
  If MsgYesNo( "Delete record: "+ gName+ " ?", "Confirm" )
    cQuery:= "DELETE FROM Names  WHERE CODE = " + AllTrim(gCode)
    If sqlite3_exec( db, cQuery ) == SQLITE_OK
      MsgInfo( "Record is deleted!", "Result" )
    EndIf
    Grid_fill(db)
  EndIf
EndIf

Return Nil

*-------------------------------------
 FUNCTION SQLITE_TABLEEXISTS( cTable )
*---------------------------------------------------------------------------
* Uses a (special) master table where the names of all tables are stored
*---------------------------------------------------------------------------
  LOCAL cStatement, lRet := .f.
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( "test.db", lCreateIfNotExist )

  cStatement := "SELECT name FROM sqlite_master "    +;
                "WHERE type ='table' AND tbl_name='" +;
                cTable + "'"

  IF DB_IS_OPEN( db )
    lRet := ( LEN( SQLITE_QUERY( db, cStatement ) ) > 0 )
  ENDIF

RETURN( lRet )

*---------------------------
 FUNCTION SQLITE_DROPTABLE()
*---------------------------------------------------------------------------
* Deletes a table from current database
* WARNING !!   It deletes forever...
*---------------------------------------------------------------------------
  LOCAL db, lRet := .F.
  LOCAL cTable := ShowTables()

  IF !EMPTY(cTable)
	IF MsgYesNo("The selected table will be erased" + CRLF + ;
		"without any choice to recover." + CRLF + CRLF + ;
		"       Continue ?", "Warning!" )

		db := sqlite3_open_v2( "test.db", SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )
		IF DB_IS_OPEN( db )
			IF sqlite3_exec( db, "drop table " + cTable ) == SQLITE_OK
				IF sqlite3_exec( db, "vacuum" ) == SQLITE_OK
					lRet := .T.
				ENDIF
			ENDIF
		ENDIF
	ENDIF
  ENDIF

RETURN lRet

*---------------------------------
 FUNCTION SQLITE_FIELDS( cTable )
*---------------------------------------------------------------------------
* Returns an unidimensional array with field names only
*---------------------------------------------------------------------------
  LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( "test.db", lCreateIfNotExist )
  LOCAL stmt, nCCount, nI

  stmt := sqlite3_prepare( db, cStatement )

  sqlite3_step( stmt )
  nCCount := sqlite3_column_count( stmt )  

  IF nCCount > 0
	FOR nI := 1 TO nCCount
	        AADD( aFields, sqlite3_column_name( stmt, nI ) )
	NEXT nI
  ENDIF

  sqlite3_finalize( stmt )

RETURN( aFields )

*--------------------------------
 FUNCTION SQLITE_COLUMNS( cTable )
*---------------------------------------------------------------------------
* Returns an 2-dimensional array with field names and types
*---------------------------------------------------------------------------
  LOCAL aCType :=  { "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_TEXT", "SQLITE_BLOB", "SQLITE_NULL" }
  LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( "test.db", lCreateIfNotExist )
  LOCAL stmt, nCCount, nI, nCType

  stmt := sqlite3_prepare( db, cStatement )

  sqlite3_step( stmt )
  nCCount := sqlite3_column_count( stmt )  

  IF nCCount > 0
	FOR nI := 1 TO nCCount
		nCType := sqlite3_column_type( stmt, nI )
	        AADD( aFields, { sqlite3_column_name( stmt, nI ), aCType[ nCType ] } )
	NEXT nI
  ENDIF

  sqlite3_finalize( stmt )

RETURN( aFields )

*------------------------
 FUNCTION SQLITE_TABLES()
*---------------------------------------------------------------------------
* Uses a (special) master table where the names of all tables are stored
* Returns an array with names of tables inside of the database
*---------------------------------------------------------------------------
  LOCAL aTables, cStatement
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( "test.db", lCreateIfNotExist )

  cStatement := "SELECT name FROM sqlite_master "      +;
                "WHERE type IN ('table','view') "      +;
                "AND name NOT LIKE 'sqlite_%' "        +;
                "UNION ALL "                           +;
                "SELECT name FROM sqlite_temp_master " +;
                "WHERE type IN ('table','view') "      +;
                "ORDER BY 1;"

  IF DB_IS_OPEN( db )
    aTables := SQLITE_QUERY( db, cStatement )
  ENDIF

RETURN( aTables )

*--------------------------------------
 FUNCTION SQLITE_QUERY( db, cStatement )
*---------------------------------------------------------------------------
  LOCAL stmt, nCCount, nI, nCType
  LOCAL aRet := {}

  stmt := sqlite3_prepare( db, cStatement )
                
  IF STMT_IS_PREPARED( stmt )
    DO WHILE sqlite3_step( stmt ) == SQLITE_ROW
	nCCount := sqlite3_column_count( stmt )  

	IF nCCount > 0
		FOR nI := 1 TO nCCount
			nCType := sqlite3_column_type( stmt, nI )

			SWITCH nCType
				CASE SQLITE_NULL
				        AADD( aRet, "NULL")
					EXIT
		
				CASE SQLITE_FLOAT
				CASE SQLITE_INTEGER
				        AADD( aRet, LTRIM(STR( sqlite3_column_int( stmt, nI ) )) )
					EXIT

				CASE SQLITE_TEXT
			        	AADD( aRet, sqlite3_column_text( stmt, nI ) )
					EXIT
			END SWITCH
		NEXT nI
	ENDIF
    ENDDO
    sqlite3_finalize( stmt )
  ENDIF
  
RETURN( aRet )

//////////////////////////////
FUNCTION Achoice( t, l, b, r, aItems, cTitle, dummy, nValue, btp )
//////////////////////////////

	DEFAULT cTitle TO "Please, select", nValue TO 1, btp to .T.

	DEFINE WINDOW Win_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 + IF(IsXPThemeActive(), 7, 0) ;
		TITLE cTitle ;
		ICON 'sqlite.ico' ;
		TOPMOST ;
		NOMAXIMIZE NOSIZE ;
		ON INIT Win_2.Button_1.SetFocus

		If btp
		   @ 235,15 BUTTON Bt_Print ;
		   CAPTION '&Print' ;
		   ACTION ListData(aItems, cTitle) ;
		   WIDTH 80
		Endif

		@ 235,190 BUTTON Button_1 ;
		CAPTION 'OK' ;
		ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
		WIDTH 80

		@ 235,295 BUTTON Button_2 ;
		CAPTION 'Cancel' ;
		ACTION {|| nValue := 0, Win_2.Release } ;
		WIDTH 80

		@ 20,15 LISTBOX List_1 ;
		WIDTH 360 ;
		HEIGHT 200 ;
		ITEMS aItems ;
		VALUE nValue ;
		FONT "Ms Sans Serif" ;
		SIZE 12 ;
		ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

		ON KEY ESCAPE ACTION Win_2.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Win_2
	ACTIVATE WINDOW Win_2

RETURN nValue

*--------------------------------------------------------------*
Function Listdata( db, Title )
*--------------------------------------------------------------*
   Private aRtvl := db, cTitle := Title
   Win_2.Topmost := .f.
   Winrepint("List.Rpt", aRtvl)
   Win_2.Topmost := .t.

Return nil
