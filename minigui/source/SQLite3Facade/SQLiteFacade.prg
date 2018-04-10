/*
 * SQLiteFacade.prg
 *
 * This file is part of "SQLite3Facade for Harbour".
 *
 * This work is licensed under the Creative Commons Attribution 3.0
 * Unported License. To view a copy of this license, visit
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to
 * Creative Commons, 444 Castro Street, Suite 900, Mountain View,
 * California, 94041, USA.
 *
 * Copyright (c) 2010, Daniel Goncalves <daniel-at-base4-com-br>
 * Updated June 2013, Added some extra functions, R.Visscher
 */

#include "hbclass.ch"
#include "error.ch"
#include "hbsqlit3.ch"
#include "common.ch"

/**
 *  A <code>SQLiteFacade</code> object is designed to represent one SQLite
 *  database and provides a convenient interface that make easy the most
 *  common operations. For example, to create a database and a table:
 *
 *  <pre>
 *  db := SQLiteFacade():new( "/home/daniel/my.db" )
 *  IF ( db:open() ) // open for read+write and create if not exists
 *     stmt := db:prepare( "CREATE TABLE people (name TEXT, age INTEGER);" )
 *     stmt:executeUpdate()
 *     stmt:close()
 *  ENDIF
 *  db:close()
 *  </pre>
 *
 *  <p>If you need to do something more sofisticated or something that this
 *  facade does not implement, you can get the pointer to the opened database
 *  via <code>getPointer()</code> method and use the Harbour SQLite3 contrib
 *  functions to access your SQLite database directly.</p>
 *
 *  @see SQLiteFacadeStatement.prg#SQLiteFacadeStatement
 *  @see .#getPointer
 *
 *  @author Daniel Goncalves
 *  @since 0.1 (feb/2010)
 *  @update ( june/2013 )
 */
CREATE CLASS SQLiteFacade
   PROTECTED:

      /**
       *  Holds the database filename used to create <code>SQLiteFacade</code>
       *  object instance.
       *
       *  @protected
       */
      VAR filename TYPE CHARACTER

      /**
       *  Holds the flags used when the database was opened.
       *  @see .#open
       *  @protected
       */
      VAR mode TYPE NUMERIC

      /**
       *  Holds a pointer to the SQLite version 3 object.
       *  @protected
       */
      VAR db // POINTER

   EXPORT:
      METHOD init CONSTRUCTOR
      METHOD open          // returns LOGICAL
      METHOD openReadOnly  // returns LOGICAL
      METHOD prepare       // returns SQLiteFacadeStatement() object
      METHOD pack          // returns LOGICAL
      METHOD close         // returns LOGICAL
      // ---- information methods ----
      METHOD getFilename   // returns CHARACTER
      METHOD getMode       // returns NUMERIC
      METHOD getPointer    // returns POINTER
      METHOD isMemory      // returns LOGICAL

      // Add methods June 4, 2013
      METHOD CreateTable( cTableName, aStruct, cPrimaryKey )
      METHOD GetTables( cTableName )
      METHOD ExistsTable( cTableName )
      METHOD CreateIndex( cIndex, cTableName, acFieldName, lUnique )
      METHOD DeleteTable( cTableName )
      METHOD DeleteIndex( cIndex, cTableName )
      METHOD Execute( cSql )
      METHOD BeginTransaction()
      METHOD CommitTransaction()
      METHOD RollBackTransaction()

   END CLASS

// ///////////////////////////////////////////////////////////////////////////
//
//    exported instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Constructs a new <code>SQLiteFacade</code> object.
 *
 *  @param cFilename CHARACTER The full path name to the database file. This
 *     parameter should follow the SQLite <code>sqlite3_open_v2</code> API
 *     function. For example, to create in memory database, set this parameter
 *     value to <code>":memory:"</code>.
 *
 *  @constructor
 *  @exported
 */
METHOD init( cFilename )
   IF ( !HB_IsString( cFilename ) )
      Throw( SQLiteFacadeTypeError( "String required", cFilename ) )
   ENDIF
   ::filename := cFilename
   ::mode := 0 // will be resolved in open() methods
   ::db := NIL // will be resolved in open() methods
   RETURN ( self )

/**
 *  Open database.
 *
 *  @param nFlags NIL|INTEGER These flags should be a combination of the
 *     constants <code>SQLITE_OPEN_xxx</code> wich can be found in the
 *     Harbour sources distribuction at
 *     <code>/harbour/contrib/hbsqlit3/hbsqlit3.ch</code>. If not specified,
 *     the default is <code>SQLITE_OPEN_READWRITE + SQLITE_OPEN_CREATE</code>.
 *
 *  @return LOGICAL Returns true if the database could be opened or false,
 *     otherwise.
 *
 *  @see .#openReadOnly
 *  @exported
 */
METHOD open( nFlags )
   IF ( nFlags == NIL )
      nFlags := SQLITE_OPEN_READWRITE + SQLITE_OPEN_CREATE
   ELSE
      IF ( !HB_IsNumeric( nFlags ) )
         Throw( SQLiteFacadeTypeError( "Number required", nFlags ) )
      ENDIF
   ENDIF
   ::mode := nFlags
   ::db := sqlite3_open_v2( ::filename, ::mode )
   RETURN ( !EMPTY( ::db ) )

/**
 *  Open database for read only.
 *
 *  @return LOGICAL Return true if the database could be opened or false,
 *     otherwise.
 *
 *  @see .#open
 *  @exported
 */
METHOD openReadOnly()
   RETURN ( ::open( SQLITE_OPEN_READONLY + SQLITE_OPEN_CREATE ) )

/**
 *  Creates a <code>SQLiteFacadeStatement</code> for the given SQL instruction.
 *  See an example of an SQL instruction, with host parameters and value
 *  bindings:
 *
 *  <pre>
 *  db := SQLiteFacade():new( "/home/daniel/my.db" )
 *  IF ( db:open() ) // open for read+write and create if not exists
 *     // create the database
 *     stmt := db:prepare( "CREATE TABLE people (name TEXT, age INTEGER);" )
 *     stmt:executeUpdate()
 *     stmt:close()
 *
 *     // insert a record into table "people"
 *     stmt := db:prepare( "INSERT INTO people (name,age) VALUES (:name,:age);" )
 *     stmt:setString( "name", "John Connor" ) // bind value to param "name"
 *     stmt:setInteger( "age", 32 ) // bind value to param "age"
 *     n := stmt:executeUpdate() // returns number of affected rows (records)
 *
 *     // reuse the same SQL statement, clearing previous bindings
 *     stmt:reuse():clear()
 *     stmt:setString( "name", "Hiro Nakamura" )
 *     stmt:setInteger( "age", 27 )
 *     n := stmt:executeUpdate()
 *  ENDIF
 *  </pre>
 *
 *  @param cSQL CHARACTER The SQL instruction to be pre-compiled (also known as
 *     "prepared statement"). For more details about prepared SQL statements
 *     visit the <a href="http://www.sqlite.org/lang_expr.html#varparam">SQLite
 *     SQLite documentation</a>.
 *
 *  @return SQLiteFacadeStatement
 *
 *  @see SQLiteFacadeStatement.prg#SQLiteFacadeStatement
 *  @exported
 */
METHOD prepare( cSQL )
   LOCAL oStatement := SQLiteFacadeStatement():new( self, cSQL )
   RETURN ( oStatement )

/**
 *  Issue <code>VACUUM</code> SQL instruction to the opened database, wich is
 *  analogue to the <code>PACK</code> xBase command. You should take a look at
 *  the official SQLite documentation for <a href="http://www.sqlite.org/lang_vacuum.html">VACUUM</a>.
 *
 *  @return LOGICAL Returns true if the <code>VACUUM</code> was executed
 *     without any error.
 *
 *  @exported
 */
METHOD pack()
   LOCAL iResult
   IF ( EMPTY( ::db ) )
      Throw( SQLiteFacadeError( "Database wasn't opened." ) )
   ENDIF
   iResult := sqlite3_exec( ::db, "VACUUM;" )
   RETURN ( iResult == SQLITE_OK )

/**
 *  Closes the database.
 *  @return LOGICAL Returns true if the database could be closed.
 *  @exported
 */
METHOD close()
   ::db := NIL
   RETURN ( .T. )

/**
 *  Get the database filename used to create this <code>SQLiteFacade</code>
 *  object.
 *
 *  @return CHARACTER The database filename used to create this
 *     <code>SQLiteFacade</code> object.
 *
 *  @exported
 */
METHOD getFilename()
   RETURN ( ::filename )

/**
 *  Get the mode flags used when the database was opened.
 *
 *  @return NUMERIC The mode, or flags value used when the database was opened.
 *     This value is a numeric value wich is a combination of the constants
 *     <code>SQLITE_OPEN_xxx</code> wich can be found in the Harbour sources
 *     distribuction at <code>/harbour/contrib/hbsqlit3/hbsqlit3.ch</code>.
 *
 *  @see .#open
 *  @exported
 */
METHOD getMode()
   RETURN ( ::mode )

/**
 *  Get the pointer to the SQLite version 3 database object.
 *
 *  @return POINTER|NIL Return <code>NIL</code> if the database isn't opened
 *     yet or was closed. Otherwise, return a pointer to the SQLite version 3
 *     object. This pointer is returned by the function
 *     <code>sqlite3_open_v2()</code> from the Harbour SQLite3 library.
 *
 *  @see .#open
 *  @see .#close
 *
 *  @exported
 */
METHOD getPointer()
   RETURN ( ::db )

/**
 *  Indicates if the current database object is an "in-memory" database.
 *  @return LOGICAL Returns true if this database object is an "in-memory"
 *     database. In-memory databases can be created when the filename
 *     parameter to <code>SQLiteFacade</code> object is <code>":memory:"</code>
 *     like this: <code>SQLiteFacade():new( ":memory:" )</code>. For more
 *     details visit the SQLite official documentation at http://www.sqlite.org/.
 *  @exported
 */
METHOD isMemory()
   RETURN ( ":memory:" $ LOWER( ALLTRIM( ::filename ) ) )


// Added methods

METHOD GetTables( cTableName )
   LOCAL aTables := {}
   LOCAL cSql := "SELECT name FROM sqlite_master WHERE type='table'"
   LOCAL stmt,rs

   IF !Empty( cTableName )
      cSql += " AND name LIKE '" + AllTrim( cTableName ) + "'"
   ENDIF

   stmt := ::Prepare( cSql + ";" )
   rs := stmt:executeQuery()

   WHILE rs:Next()
      AAdd( aTables, rs:GetString("name"))
   ENDDO

   stmt:Close()

RETURN ( aTables )


METHOD ExistsTable( cTableName )

   IF Empty( cTableName )
      RETURN .F.
   ENDIF

RETURN Len( ::GetTables( cTableName ) ) > 0


METHOD DeleteIndex( cIndex, cTableName )
   LOCAL cSql := "DROP INDEX " + AllTrim( cIndex ) + " FROM " + AllTrim( Lower( cTableName ))
   LOCAL nResult := sqlite3_exec( ::db, cSql )
RETURN ( nResult == SQLITE_OK )


METHOD CreateIndex( cIndex, cTableName, acFieldName, lUnique )
   LOCAL cSql := "CREATE "
   LOCAL nResult, aEle, cFieldName := ""

   DEFAULT lUnique TO .F.

   IF lUnique
      cSql += "UNIQUE INDEX "
   ELSE
      cSql += "INDEX "
   ENDIF

   IF ValType( acFieldName ) == "C"
      acFieldName := { acFieldName }
   ENDIF

   FOR EACH aEle IN acFieldName
      cFieldName += aEle + ","
   NEXT

   IF Len( cFieldName ) > 0
      cFieldName := Left( cFieldName, Len( cFieldName ) - 1 )
   ENDIF

   cSql += cIndex + " ON " + AllTrim( Lower( cTableName ) ) + " (" + cFieldName + ")"
   nResult := sqlite3_exec( ::db, cSql )

RETURN ( nResult == SQLITE_OK )


METHOD Execute( cSql )
   RETURN sqlite3_exec( ::db, cSql )


METHOD BeginTransaction()
   RETURN sqlite3_exec( ::db, "BEGIN TRANSACTION;" )


METHOD CommitTransaction()
    RETURN sqlite3_exec( ::db, "COMMIT;" )


METHOD RollBackTransaction()
    RETURN sqlite3_exec( ::db, "ROLLBACK;" )


METHOD DeleteTable( cTableName )
   LOCAL cSql := "DROP TABLE " + Lower( cTableName )
   LOCAL nResult := sqlite3_exec( ::db, cSql )
RETURN ( nResult == SQLITE_OK )


METHOD CreateTable( cTableName, aStruct, cPrimaryKey )
   LOCAL cSql := "CREATE TABLE IF NOT EXISTS " + cTableName + "( "
   LOCAL cType
   LOCAL n
   LOCAL nResult

   FOR n := 1 TO Len( aStruct )
		IF n > 1
		   cSql += ", "
		ENDIF

		cSql += aStruct[ n, 1 ] + " "
		cType := aStruct[ n, 2 ]

		IF cType == "C"
			cSql += "VARCHAR(" + hb_ntos( aStruct[ n, 3 ] ) + ")"
		ELSEIF cType == "M"
			cSql += "TEXT"
		ELSEIF cType == "N"
			IF aStruct[ n, 4 ] == 0
				cSql += iif( aStruct[ n, 3 ] <= 9, "INTEGER", "INT64" )
			ELSE
				cSql += "FLOAT"
			ENDIF
		ELSEIF cType == "D"
			cSql += "TEXT"
		ELSEIF cType == "L"
			cSql += "TEXT"
		ELSEIF cType == "B"
			cSql += "BLOB"
		ENDIF
   NEXT

   IF ! Empty( cPrimaryKey )
      cSql += ", PRIMARY KEY (" + cPrimaryKey + ")"
   ENDIF
   cSql += " )"

   nResult := sqlite3_exec( ::db, cSql )

RETURN ( nResult == SQLITE_OK )
