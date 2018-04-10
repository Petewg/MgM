/*
 * SQLiteFacadeRecordSet.prg
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

/**
 *  This class is an abstraction of the results for a query. When you call the
 *  <code>executeQuery()</code> method from <code>SQLiteFacadeStatement</code>
 *  class, the return will be an instance of <code>SQLiteFacadeResultSet</code>
 *  wich exposes a nice interface to deal with the results.
 *
 *  <p>The following example shows how to iterate over rows for a query:</p>
 *
 *  <pre>
 *  stmt := db:prepare( "SELECT * FROM books WHERE year_pub=:year_pub;" )
 *  stmt:setInteger( ":year_pub", 1984 )
 *  rs := stmt:executeQuery()
 *  WHILE ( rs:next() )
 *     ? rs:getString( "title" )
 *     ? rs:getString( "author" )
 *     ? REPLICATE( "-", 40 )
 *  END
 *  // close the result set (actually finalize the statement)
 *  rs:close()
 *  </pre>
 *
 *  <p>Next example, shows a query that's expected to result a single row:</p>
 *
 *  <pre>
 *  stmt := db:prepare( "SELECT * FROM books WHERE id=:id;" )
 *  stmt:setInteger( ":id", 1 )
 *  rs := stmt:executeQuery()
 *  IF ( rs:next() )
 *     // book found!
 *     ...
 *  ENDIF
 *  </pre>
 *
 *  @see SQLiteFacadeStatement.prg#SQLiteFacadeStatement
 *
 *  @author Daniel Goncalves
 *  @since 0.1 (feb/2010)
 *	@update (june/2013)
 */
CREATE CLASS SQLiteFacadeResultSet

   PROTECTED:
      VAR statement  // SQLiteFacadeStatement() object
      VAR db         // SQLiteFacade() object
      VAR nextCalled TYPE LOGICAL

      METHOD resolveColumnIndex // returns NUMERIC

   EXPORT:
      METHOD init CONSTRUCTOR
      METHOD next          // returns LOGICAL
      METHOD getString     // returns CHARACTER
      METHOD getInteger    // returns NUMERIC
      METHOD getFloat      // returns NUMERIC
      METHOD getDate       // returns DATE
      METHOD getBoolean    // returns LOGICAL
      METHOD getBlob
      METHOD close         // returns SELF

   END CLASS

// ///////////////////////////////////////////////////////////////////////////
//
//    protected instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Resolve the column index for the given column specifier. The column
 *  specifier can be the column index (a numeric integer value starting from
 *  <code>1</code>) or the column name, wich <em>must be the actual column
 *  name</em>, not the hosted parameter name, like used in the
 *  <code>setXxxx()</code> methods from <code>SQLiteFacadeStatement</code>
 *  class. This method ensure that the index will be valid.
 *
 *  @param NUMERIC|CHARACTER This is the column specifier, wich can be the
 *     column index (a numeric integer value starting from <code>1</code>) or
 *     the actual column name.
 *
 *  @return NUMERIC Returns an integer numeric value greater than zero, wich
 *     represents the column index for the column specifier.
 *
 *  @protected
 */
METHOD resolveColumnIndex( ncColumn )
   LOCAL pStmt := ::statement:getPointer()
   LOCAL niTotalColumns := sqlite3_column_count( pStmt )
   LOCAL niColumnIndex := 0
   LOCAL ni
   LOCAL oError
   LOCAL cColumn
   IF ( HB_IsNumeric( ncColumn ) )
      niColumnIndex := ncColumn
   ELSEIF ( HB_IsString( ncColumn ) )
      // resolve column index by column name
      // TODO: implement a hash map to column indexes for all column names on first call!
      FOR ni := 1 TO niTotalColumns
         cColumn := sqlite3_column_name( pStmt, ni )
         IF ( UPPER( ALLTRIM( cColumn ) ) == UPPER( ALLTRIM( ncColumn ) ) )
            niColumnIndex := ni
            EXIT
         ENDIF
      NEXT
   ELSE
      Throw( SQLiteFacadeTypeError( "Number or String required", ncColumn ) )
   ENDIF
   IF ( niColumnIndex < 1 ) .OR. ( niColumnIndex > niTotalColumns )
      oError := SQLiteFacadeError( "Unknown column" )
      oError:operation := ALLTRIM( Str( ncColumn ) )
      Throw( oError )
   ENDIF
   RETURN ( niColumnIndex )

// ///////////////////////////////////////////////////////////////////////////
//
//    exported instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Constructs a new <code>SQLiteFacadeRecordSet</code> object. Usually you do
 *  not need to instantiate an object of this yourself. It's a job for
 *  <code>executeQuery()</code> method from <code>SQLiteFacadeStatament</code>
 *  class.
 *
 *  @param oStatement SQLiteFacadeStatement The object that generates this
 *     record set via it's <code>executeQuery()</code>.
 *
 *  @param oDB SQLiteFacade The object that generates the
 *     <code>SQLiteFacadeStatement</code> passed in the the parameter
 *     <code>oStatement</code>.
 *
 *  @see SQLiteFacadeStatement.prg#SQLiteFacadeStatement
 *  @see SQLiteFacade.prg#SQLiteFacade
 *  @see SQLiteFacadeStatement.prg#executeQuery
 *
 *  @constructor
 */
METHOD init( oStatement, oDB )
   IF ( !SQLiteFacadeIsInstance( oStatement, "SQLiteFacadeStatement" ) )
      Throw( SQLiteFacadeTypeError( "SQLiteFacadeStatement() required", oStatement ) )
   ENDIF
   IF ( !SQLiteFacadeIsInstance( oDB, "SQLiteFacade" ) )
      Throw( SQLiteFacadeTypeError( "SQLiteFacade() required", oDB ) )
   ENDIF
   ::statement := oStatement
   ::db := oDB
   ::nextCalled := .F.
   RETURN ( self )

/**
 *  Enquire the next row of data for this result set. If there's another row
 *  this method will return true (<code>.T.</code>).
 *
 *  @return LOGICAL If there is another row of data (tuple) this method will
 *     return a true value (<code>.T.</code>). Otherwise, returns false.
 *
 *  @exported
 */
METHOD next()
   LOCAL nResult
   IF ( ::nextCalled )
      // issue a new step on the statement object
      nResult := sqlite3_step( ::statement:getPointer() )
      RETURN ( nResult == SQLITE_ROW )
   ENDIF
   ::nextCalled := .T.
   RETURN ( .T. )

/**
  * @param ncColumn NUMERIC|CHARACTER The column name , cFileName CHARACTER
  *  for saving blob value to file
*/

METHOD getBlob( ncColumn, cFileName )
   LOCAL oError
   LOCAL niColumn := ::resolveColumnIndex( ncColumn )
   LOCAL pStmt := ::statement:getPointer()
   LOCAL buff
   LOCAL niType := sqlite3_column_type( pStmt, niColumn )

   IF ( ASCAN( { SQLITE_BLOB }, niType ) == 0 )
      oError := SQLiteFacadeError( "Column type isn't BLOB" )
      oError:operation := ALLTRIM( Str( ncColumn ) )
      Throw( oError )
   ENDIF
   buff := sqlite3_column_blob( pStmt, niColumn )

RETURN ( sqlite3_buff_to_file( cFileName,@buff ) )


/**
 *  Get the string column value for the current row (tuple). If the column
 *  does not exists or isn't a <code>TEXT</code> column a run-time error will
 *  be raised.
 *
 *  @param ncColumn NUMERIC|CHARACTER The column name (actual column name,
 *     and have no relation with hosted parameter names) or the column index.
 *
 *  @return CHARACTER The column string value.
 *
 *  @exported
 */
METHOD getString( ncColumn )
   LOCAL oError
   LOCAL niColumn := ::resolveColumnIndex( ncColumn )
   LOCAL pStmt := ::statement:getPointer()
   LOCAL niType := sqlite3_column_type( pStmt, niColumn )

   IF ( ASCAN( { SQLITE_TEXT, SQLITE3_TEXT }, niType ) == 0 )
      oError := SQLiteFacadeError( "Column type isn't TEXT" )
      oError:operation := ALLTRIM( Str( ncColumn ) )
      Throw( oError )
   ENDIF
   RETURN ( sqlite3_column_text( pStmt, niColumn ) )

/**
 *  Get the integer column value for the current row (tuple). If the column
 *  does not exists or isn't a <code>INTEGER</code> column a run-time error
 *  will be raised.
 *
 *  @param ncColumn NUMERIC|CHARACTER The column name (actual column name,
 *     and have no relation with hosted parameter names) or the column index.
 *
 *  @return NUMERIC The column integer value.
 *
 *  @exported
 */
METHOD getInteger( ncColumn )
   LOCAL oError
   LOCAL niColumn := ::resolveColumnIndex( ncColumn )
   LOCAL pStmt := ::statement:getPointer()
   LOCAL niType := sqlite3_column_type( pStmt, niColumn )
   IF !( niType == SQLITE_INTEGER )
      oError := SQLiteFacadeError( "Column type isn't INTEGER" )
      oError:operation := ALLTRIM( Str( ncColumn ) )
      Throw( oError )
   ENDIF
   RETURN ( sqlite3_column_int( pStmt, niColumn ) )

/**
 *  Get the float (numeric) column value for the current row (tuple). If the
 *  column does not exists or isn't a <code>FLOAT</code> column a run-time error
 *  will be raised.
 *
 *  @param ncColumn NUMERIC|CHARACTER The column name (actual column name,
 *     and have no relation with hosted parameter names) or the column index.
 *
 *  @return NUMERIC The column float value.
 *
 *  @exported
 */
METHOD getFloat( ncColumn )
   LOCAL oError
   LOCAL niColumn := ::resolveColumnIndex( ncColumn )
   LOCAL pStmt := ::statement:getPointer()
   LOCAL niType := sqlite3_column_type( pStmt, niColumn )
   IF !( niType == SQLITE_FLOAT )
      oError := SQLiteFacadeError( "Column type isn't FLOAT" )
      oError:operation := ALLTRIM( Str( ncColumn ) )
      Throw( oError )
   ENDIF
   RETURN ( sqlite3_column_double( pStmt, niColumn ) )

/**
 *  Get the date column value for the current row (tuple). If the column does
 *  not exists or isn't a <code>TEXT</code> column a run-time error will be
 *  raised. SQLite doesn't have a date type on it's own. Date values are
 *  abstracted by this facade using a <code>TEXT</code> data type column with
 *  values in the form <code>"yyyy-mm-dd"</code> (slashes in place of hifens
 *  are valid too).
 *
 *  @param ncColumn NUMERIC|CHARACTER The column name (actual column name,
 *     and have no relation with hosted parameter names) or the column index.
 *
 *  @return DATE The column date value. If the column <code>TEXT</code> value
 *     format isn't in the form <code>"yyyy-mm-dd"</code>
 *     (or <code>"yyyy/mm/dd"</code>) then an empty date will be returned.
 *
 *  @exported
 */
METHOD getDate( ncColumn )
   LOCAL cBruteValue := ::getString( ncColumn )
   LOCAL dValue := CTOD( "" )
   LOCAL cRegEx := "([0-9]{4})[-/]([0-9]{1,2})[-/]([0-9]{1,2})"
   LOCAL aMatches := HB_RegEx( cRegEx, cBruteValue )
   IF !( aMatches == NIL )
      IF ( LEN( aMatches ) == 4 )
         dValue := STOD( STRZERO( VAL( aMatches[ 2 ] ), 4, 0 ) + ;
                            STRZERO( VAL( aMatches[ 3 ] ), 2, 0 ) + ;
                            STRZERO( VAL( aMatches[ 4 ] ), 2, 0 ) )
      ENDIF
   ENDIF
   RETURN ( dValue )

/**
 *  Get the boolean (logical) column value for the current row (tuple).
 *  If the column does not exists or isn't a <code>TEXT</code> column a
 *  run-time error will be raised. SQLite doesn't have a boolean type on it's
 *  own. Boolean values are abstracted by this facade using a <code>TEXT</code>
 *  data type column with values <code>"yes"</code>, <code>"ok"</code>,
 *  <code>"true"</code> or <code>".t."</code> considered true values
 *  (<code>.T.</code>). Any other value will be considered false
 *  (<code>.F.</code>).
 *
 *  @param ncColumn NUMERIC|CHARACTER The column name (actual column name,
 *     and have no relation with hosted parameter names) or the column index.
 *
 *  @return LOGICAL The column boolean value. If the column <code>TEXT</code>
 *     value is <code>"yes"</code>, <code>"ok"</code>, <code>"true"</code>
 *     or <code>".t."</code>, then the return value will be true
 *     (<code>.T.</code>). Any other value will be considered false
 *     (<code>.F.</code>).
 *
 *  @exported
 */
METHOD getBoolean( ncColumn )
   LOCAL cBruteValue := ::getString( ncColumn )
   LOCAL nMatches := ASCAN( { "yes", "ok", "true", ".t." }, ;
                           LOWER( ALLTRIM( cBruteValue ) ) )
   RETURN ( nMatches > 0 )

/**
 *  Close this result set and finalize the corresponding
 *  <code>SQLiteFacadeStatement</code> object.
 *
 *  @return SELF Returns a reference for this
 *     <code>SQLiteFacadeResultSet</code> instance.
 *
 *  @exported
 */
METHOD close()
   // QUESTION: is this usefull? desired? needed?
   ::statement:close()
   RETURN ( self )

