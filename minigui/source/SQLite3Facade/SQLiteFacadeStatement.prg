/*
 * SQLiteFacadeStatement.prg
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

#define BIND_PARAM_INDEX 1
#define BIND_PARAM_VALUE 2

/**
 *  The class <code>SQLiteFacadeStatement</code> represents the so called
 *  "prepared statement" (or pre-compiled SQL instruction). Usually you do not
 *  need to instantiate objects of this kind directly. When you call
 *  <code>prepare()</code> method from <code>SQLiteFacade</code> object, an
 *  instance of this class will be built and returned ready to use.
 *  For example:
 *
 *  <pre>
 *  db := SQLiteFacade():new( "library.db" )
 *  db:open()
 *  // build an instance of SQLiteFacadeStatement
 *  stmt := db:prepare( "SELECT * FROM books;" )
 *  </pre>
 *
 *  <p>The basic purpose of <code>SQLiteFacadeStatement</code> is to allow
 *  execution of queries (SQL <code>SELECT</code> instructions) or updates
 *  (SQL <code>INSERT</code>, <code>UPDATE</code>, <code>DELETE</code> as well
 *  as <code>CREATE TABLE</code>, <code>PRAGMA</code>, and so on).</p>
 *
 *  <p>This facade makes the use of host parameters and parameter value
 *  bindings very easy. For example:</p>
 *
 *  <pre>
 *  stmt := db:prepare( "SELECT * FROM books WHERE isbn=:isbn;" )
 *  stmt:setString( ":isbn", "0-470-84437-X" )
 *  rs := stmt:executeQuery() // returns SQLiteFacadeResultSet
 *  IF ( rs:next() )
 *     // book found
 *     ...
 *  ENDIF
 *  </pre>
 *
 *  <p>For more information about host parameters and parameter value bindings
 *  visit the <a href="http://www.sqlite.org/">SQLite website</a> and look at
 *  the official documentation.</p>
 *
 *  @see SQLiteFacade.prg#SQLiteFacade
 *  @see SQLiteFacadeRecordSet.prg#SQLiteFacadeRecordSet
 *
 *  @author Daniel Goncalves
 *  @since 0.1 (feb/2010)
    @update ( june/2013 )
 */
CREATE CLASS SQLiteFacadeStatement

   PROTECTED:

      /**
       *  Holds the <code>SQLiteFacade</code> instance that originates this
       *  <code>SQLiteFacadeStatement</code> instance.
       *
       *  @protected
       */
      VAR db // SQLiteFacade() object

      /**
       *  Holds the SQLite statement object pointer as returned by the function
       *  <code>sqlite3_prepare()</code> or <code>NIL</code> if the statement
       *  was never instantiated (due to an incomplete SQL statement) or closed.
       *
       *  @protected
       */
      VAR statement // POINTER|NIL

      /**
       *  Holds the SQL instruction that originates this instance.
       *  @protected
       */
      VAR sql TYPE CHARACTER

      /**
       *  Holds the last bind error ocurred when the <code>preBind()</code>
       *  method was called.
       *
       *  @see .#preBind
       *  @protected
       */
      VAR lastBindError TYPE NUMERIC

      /**
       *  Holds the last execute (query or update) ocurred when the methods
       *  <code>executeQuery()</code> or <code>executeUpdate()</code>
       *  was called.
       *
       *  @see .#executeQuery
       *  @see .#executeUpdate
       *
       *  @protected
       */
      VAR lastExecuteResult TYPE NUMERIC

      METHOD preBind    // returns ARRAY

   EXPORT:
      METHOD init CONSTRUCTOR
      METHOD setString        // returns SELF
      METHOD setInteger       // returns SELF
      METHOD setFloat         // returns SELF
      METHOD setDate          // returns SELF
      METHOD setBoolean       // returns SELF
      METHOD setBlob          // returns SELF

      METHOD executeQuery     // returns SQLiteFacadeResultSet()
      METHOD executeUpdate    // returns NUMERIC
      METHOD reuse            // returns SELF
      METHOD clear            // returns SELF
      METHOD close            // returns SELF
      // ---- information methods ----
      METHOD getPointer       // returns POINTER

   END CLASS

// ///////////////////////////////////////////////////////////////////////////
//
//    protected instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Execute a pre-bind operation for the given hosted parameter. This function
 *  is called by the <code>setXxxx()</code> methods in order to perform various
 *  operations that make parameter bindings possible.
 *
 *  @param ncParam NUMERIC|CHARACTER The position of the hosted parameter to be
 *     bound to a value or the hosted parameter name.
 *
 *  @param uxValue ANY The value to be bound.
 *
 *  @param bValidator NIL|CODEBLOCK The value validator codeblock. This
 *     codeblock will be used to validate the value that's about to be bound
 *     to the hosted parameter. The form of this codeblock should be
 *     <code>{ |value| exp_with_value }</code>. If the codeblock results false
 *     then a run-time error will be raised indicating that the value isn't
 *     valid.
 *
 *  @return ARRAY Returns an array of two elements. The first element is the
 *     hosted parameter index (this value is suitable to use with the
 *     <code>sqlite3_bind_xxx()</code> functions). The second element is the
 *     value to be bound (that is, the <code>uxValue</code> parameter itself).
 *
 *  @protected
 */
METHOD preBind( ncParam, uxValue, bValidator )
   LOCAL oError
   LOCAL nParamCount
   LOCAL nIndex
   LOCAL awBind := { 0, NIL }

   // validate current statement
   IF ( EMPTY( ::statement ) )
      Throw( SQLiteFacadeError( "Invalid prepared statement (was closed?)." ) )
   ENDIF

   // get total bind parameters
   nParamCount := sqlite3_bind_parameter_count( ::statement )

   // validate the <ncParam>
   // <ncParam> should be an index (NUMERIC) or the param name (STRING)
   IF ( HB_IsNumeric( ncParam ) )
      IF ( nIndex < 1 ) .OR. ( nIndex > nParamCount )
         oError := SQLiteFacadeError( "Parameter index out of bounds" )
         oError:operation := ALLTRIM( STR( ncParam ) )
         Throw( oError )
      ENDIF
      nIndex := ncParam

   ELSEIF ( HB_IsString( ncParam ) )
      // retrieve the param index by name
      nIndex := sqlite3_bind_parameter_index( ::statement, ncParam )
      IF ( nIndex < 1 ) .OR. ( nIndex > nParamCount )
         oError := SQLiteFacadeError( "There's no such parameter" )
         oError:operation := '"' + ncParam + '" (counting ' + ;
            ALLTRIM( STR( nParamCount ) ) + ' params)'
         Throw( oError )
      ENDIF

   ELSE
      Throw( SQLiteFacadeTypeError( "Numeric or String required", ncParam ) )

   ENDIF

   // validate the user value with the validator codeblock
   IF ( HB_IsBlock( bValidator ) )
      IF !( bValidator:eval( uxValue ) )
         oError := SQLiteFacadeError( "Pre-bind param value was invalidated" )
         oError:operation := VALTOPRG( uxValue )
         Throw( oError )
      ENDIF
   ENDIF

   ::lastBindError := SQLITE_OK

   awBind[ BIND_PARAM_INDEX ] := nIndex
   awBind[ BIND_PARAM_VALUE ] := uxValue

   RETURN ( awBind )

// ///////////////////////////////////////////////////////////////////////////
//
//    exported instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Constructs a new <code>SQLiteFacadeStatement</code> object.
 *
 *  @param oDB SQLiteFacade This should be the representation of the database
 *     abstraction that the prepared statement belongs to.
 *
 *  @param cSQL CHARACTER The SQL instruction to be prepared (or pre-compiled).
 *     Note that every SQL instruction is expected to end with a semicolon
 *     (<code>;</code>). This class will check for the completeness of the SQL
 *     instruction before actually create the prepared statement.
 *
 *  @constructor
 */
METHOD init( oDB, cSQL )
   LOCAL oError
   IF ( !SQLiteFacadeIsInstance( oDB, "SQLiteFacade" ) )
      Throw( SQLiteFacadeTypeError( "SQLiteFacade() required", oDB ) )
   ENDIF
   IF ( !HB_IsString( cSQL ) )
      Throw( SQLiteFacadeTypeError( "String required", cSQL ) )
   ENDIF
   ::db := oDB
   ::sql := cSQL
   ::statement := NIL
   ::lastBindError := SQLITE_OK
   ::lastExecuteResult := SQLITE_OK
   IF ( !EMPTY( ::db:getPointer() ) )
     IF ( sqlite3_complete( cSQL ) )
         ::statement := sqlite3_prepare( ::db:getPointer(), cSQL )
     ELSE
        oError := SQLiteFacadeError( "SQL statement isn't complete" )
        oError:operation := '(ensure it ends with ";")'
         Throw( oError )
      ENDIF
   ENDIF
   RETURN ( self )


METHOD SetBlob( ncParam, cValue )
   LOCAL oError
   LOCAL buff
   LOCAL awBind := ::preBind( ncParam, cValue, { |_p| HB_IsString(_p) } )

   buff := sqlite3_file_to_buff( cValue )

   ::lastBindError := sqlite3_bind_blob( ::statement,   ;
                        awBind[ BIND_PARAM_INDEX ], ;
                        @buff )

   IF !( ::lastBindError == SQLITE_OK )
      oError := SQLiteFacadeError( "Blob bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, cValue }
      Throw( oError )
   ENDIF

RETURN ( self )


/**
 *  Binds a string value to the given hosted parameter.
 *
 *  @param ncParam NUMERIC|CHARACTER The position or name of the hosted
 *     parameter to be bound. Note that the name should include the name prefix.
 *     This means that, if you name a parameter as <code>":name"</code>, the
 *     hosted parameter name should be <code>":name"</code> (note the prefix).
 *
 *  @param cValue CHARACTER The string value to be bound.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @exported
 */
METHOD setString( ncParam, cValue )
   LOCAL oError
   LOCAL awBind := ::preBind( ncParam, cValue, { |_p| HB_IsString(_p) } )
   ::lastBindError := sqlite3_bind_text( ::statement,   ;
                        awBind[ BIND_PARAM_INDEX ], ;
                        awBind[ BIND_PARAM_VALUE ] )
   IF !( ::lastBindError == SQLITE_OK )
      oError := SQLiteFacadeError( "String bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, cValue }
      Throw( oError )
   ENDIF
   RETURN ( self )

/**
 *  Binds an integer value to the given hosted parameter.
 *
 *  @param ncParam NUMERIC|CHARACTER The position or name of the hosted
 *     parameter to be bound. Note that the name should include the name prefix.
 *     This means that, if you name a parameter as <code>":name"</code>, the
 *     hosted parameter name should be <code>":name"</code> (note the prefix).
 *
 *  @param iValue NUMERIC The integer value to be bound.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @exported
 */
METHOD setInteger( ncParam, iValue )
   LOCAL oError
   LOCAL awBind := ::preBind( ncParam, iValue, { |_p| HB_IsNumeric(_p) } )
   ::lastBindError := sqlite3_bind_int( ::statement,    ;
                        awBind[ BIND_PARAM_INDEX ], ;
                        awBind[ BIND_PARAM_VALUE ] )
   IF !( ::lastBindError == SQLITE_OK )
      oError := SQLiteFacadeError( "Integer bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, iValue }
      Throw( oError )
   ENDIF
   RETURN ( self )

/**
 *  Binds a float (numeric) value to the given hosted parameter.
 *
 *  @param ncParam NUMERIC|CHARACTER The position or name of the hosted
 *     parameter to be bound. Note that the name should include the name prefix.
 *     This means that, if you name a parameter as <code>":name"</code>, the
 *     hosted parameter name should be <code>":name"</code> (note the prefix).
 *
 *  @param nValue NUMERIC The float value to be bound.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @exported
 */
METHOD setFloat( ncParam, nValue )
   LOCAL oError
   LOCAL awBind := ::preBind( ncParam, nValue, { |_p| HB_IsNumeric(_p) } )
   ::lastBindError := sqlite3_bind_double( ::statement, ;
                        awBind[ BIND_PARAM_INDEX ], ;
                        awBind[ BIND_PARAM_VALUE ] )
   IF !( ::lastBindError == SQLITE_OK )
      oError := SQLiteFacadeError( "Float bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, nValue }
      Throw( oError )
   ENDIF
   RETURN ( self )

/**
 *  Binds a date value to the given hosted parameter. SQLite databases cannot
 *  deal directly with date values, since there's no DATE or DATETIME like data
 *  type. This method is an abstraction for a TEXT data type field that just
 *  holds a string in the form <code>"yyyy-dd-mm"</code> (or with slashes in
 *  place of hifens). This way, when you do:
 *
 *  <pre>
 *  stmt:setDate( ":birth", STOD( "19800726" ) )
 *  </pre>
 *
 *  <p>you're actually binding a string value <code>"1980-07-26"</code> to a
 *  hosted parameter named <code>":birth"</code>.</p>
 *
 *  @param ncParam NUMERIC|CHARACTER The position or name of the hosted
 *     parameter to be bound. Note that the name should include the name prefix.
 *     This means that, if you name a parameter as <code>":name"</code>, the
 *     hosted parameter name should be <code>":name"</code> (note the prefix).
 *
 *  @param dValue DATE The date value to be bound. If it's an empty date, then
 *     the resulting bound value will be the string <code>"0000-00-00"</code>.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @see SQLiteFacadeResultSet.prg#getDate
 *
 *  @exported
 */
METHOD setDate( ncParam, dValue )
   LOCAL oError
   LOCAL iYear  := 0
   LOCAL iMonth := 0
   LOCAL iDay   := 0
   LOCAL cValue
   LOCAL awBind

   awBind := ::preBind( ncParam, dValue, { |_p| HB_IsDate(_p) } )

   IF ( !EMPTY( awBind[ BIND_PARAM_VALUE ] ) )
      iYear  := YEAR( awBind[ BIND_PARAM_VALUE ] )
      iMonth := MONTH( awBind[ BIND_PARAM_VALUE ] )
      iDay   := DAY( awBind[ BIND_PARAM_VALUE ] )
   ENDIF

   cValue := STRZERO( iYear,  4, 0 ) + "-" + ;
             STRZERO( iMonth, 2, 0 ) + "-" + ;
             STRZERO( iDay,   2, 0 )

   ::lastBindError := sqlite3_bind_text( ::statement, ;
                        awBind[ BIND_PARAM_INDEX ], cValue )
   IF !( ::lastBindError  == SQLITE_OK )
      oError := SQLiteFacadeError( "Date bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, dValue }
      Throw( oError )
   ENDIF
   RETURN ( self )

/**
 *  Binds a boolean value to the given hosted parameter. SQLite databases cannot
 *  deal directly with boolean values, since there's no BIT nor BOOLEAN like
 *  data type. This method is an abstraction for a TEXT data type field that
 *  just holds a string like <code>"yes"</code> or <code>"no"</code>. This way,
 *  when you do:
 *
 *  <pre>
 *  stmt:setBoolean( ":sold", .T. )
 *  </pre>
 *
 *  <p>you're actually binding a string value <code>"yes"</code> to a
 *  hosted parameter named <code>":sold"</code>. The corresponding result set
 *  method <code>getBoolean()</code> interpret other values than
 *  <code>"yes"</code> as <code>.T.</code> (true) values.
 *
 *  @param ncParam NUMERIC|CHARACTER The position or name of the hosted
 *     parameter to be bound. Note that the name should include the name prefix.
 *     This means that, if you name a parameter as <code>":name"</code>, the
 *     hosted parameter name should be <code>":name"</code> (note the prefix).
 *
 *  @param lValue LOGICAL The logical (boolean) value to be bound. If it's
 *     true (<code>.T.</code>) then the resulting bound value will the string
 *     <code>"yes"</code>. Otherwise, if it's false (<code>.F.</code>), then
 *     the resulting bound value will be <code>"no"</code>.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @see SQLiteFacadeResultSet.prg#getBoolean
 *
 *  @exported
 */
METHOD setBoolean( ncParam, lValue )
   LOCAL oError
   LOCAL cValue
   LOCAL awBind
   awBind := ::preBind( ncParam, lValue, { |_p| HB_IsLogical(_p) } )
   cValue := IIF( awBind[ BIND_PARAM_VALUE ], "yes", "no" )
   ::lastBindError := sqlite3_bind_text( ::statement, ;
                        awBind[ BIND_PARAM_INDEX ], cValue )
   IF !( ::lastBindError  == SQLITE_OK )
      oError := SQLiteFacadeError( "Boolean bind error" )
      oError:operation := SQLiteFacadeErrorName( ::lastBindError )
      oError:args := { ncParam, lValue }
      Throw( oError )
   ENDIF
   RETURN ( self )

/**
 *  Execute the SQL query. Usually queries results data (or rows), wich in this
 *  context is an object <code>SQLiteFacadeResultSet</code>. Such queries are
 *  actual <code>SELECT</code> SQL statements. If you call this method with an
 *  SQL instruction that does not results any data, the corresponding result
 *  set object will be empty, meaning no data.
 *
 *  <p>IMPLEMENTATION NOTE #1: When <code>sqlite3_step()</code> returns
 *  <code>SQLITE_OK</code> or <code>SQLITE_DONE</code> then an instance of
 *  <code>SQLiteFacadeResultSetMockup</code> will be returned. An actual
 *  result set (<code>SQLiteFacadeResultSet</code> object) will be built when
 *  <code>sqlite3_step()</code> function returns <code>SQLITE_ROW</code>.</p>
 *
 *  <p>IMPLEMENTATION NOTE #2: When <code>lastExecuteResult()</code> is
 *  <code>SQLITE_ERROR</code> or <code>SQLITE_DONE</code>, then a
 *  <code>sqlite3_reset()</code> will be issued (so the current SQL statement
 *  becomes usable again -- it is, ready to be re-executed) and the variable
 *  <code>lastExecuteResult</code> will be set to <code>SQLITE_OK</code>.</p>
 *
 *  @return SQLiteFacadeResultSet The result set for the query.
 *
 *  @see .#executeUpdate
 *  @exported
 */
METHOD executeQuery()
   LOCAL oResultSet
   IF ( EMPTY( ::statement ) )
      Throw( SQLiteFacadeError( "Invalid prepared statement (was closed?)." ) )
   ELSE
      //IF ( ::lastExecuteResult $ { SQLITE_DONE, SQLITE_ERROR } )
      IF ( ASCAN( { SQLITE_DONE, SQLITE_ERROR }, ::lastExecuteResult ) > 0 )
         // help the user and make this statement reusable (reset) first
         ::reuse()
      ENDIF
      ::lastExecuteResult := sqlite3_step( ::statement )
      //IF ( ::lastExecuteResult $ { SQLITE_OK, SQLITE_DONE } )
      IF ( ASCAN( { SQLITE_OK, SQLITE_DONE }, ::lastExecuteResult ) > 0 )
         // no data!
         oResultSet := SQLiteFacadeResultSetMockup():new( self, ::db )
      ELSEIF ( ::lastExecuteResult == SQLITE_ROW )
         // build the resultset object
         oResultSet := SQLiteFacadeResultSet():new( self, ::db )
      ENDIF
   ENDIF
   RETURN ( oResultSet )

/**
 *  Execute the SQL update. Usually updates do not results data (rows).
 *  Such updates are actual <code>INSERT</code>, <code>UPDATE</code>,
 *  <code>DELETE</code>, or any other SQL statements that do not results data.
 *  If you call this method with an SQL instruction that results data you'll
 *  get <code>0</code> as return value instead of a result set.
 *
 *  <p>IMPLEMENTATION NOTE #1: When <code>sqlite3_step()</code> returns
 *  <code>SQLITE_OK</code> or <code>SQLITE_DONE</code> the return value will be
 *  the number of rows affected (<code>sqlite3_changes()</code> function).</p>
 *
 *  <p>IMPLEMENTATION NOTE #2: When <code>lastExecuteResult()</code> is
 *  <code>SQLITE_ERROR</code> or <code>SQLITE_DONE</code>, then a
 *  <code>sqlite3_reset()</code> will be issued (so the current SQL statement
 *  becomes usable again -- it is, ready to be re-executed) and the variable
 *  <code>lastExecuteResult</code> will be set to <code>SQLITE_OK</code>.</p>
 *
 *  @return NUMERIC The number of actual rows affected by the SQL statement.
 *
 *  @see .#executeQuery
 *  @exported
 */
METHOD executeUpdate()
   LOCAL nChanges := 0
   IF ( EMPTY( ::statement ) )
      Throw( SQLiteFacadeError( "Invalid prepared statement (was closed?)." ) )
   ELSE
      //IF ( ::lastExecuteResult $ { SQLITE_DONE, SQLITE_ERROR } )
      IF ( ASCAN( { SQLITE_DONE, SQLITE_ERROR }, ::lastExecuteResult ) > 0 )
         // help the user and make this statement reusable (reset) first
        ::reuse()
      ENDIF
      ::lastExecuteResult := sqlite3_step( ::statement )
      //IF ( ::lastExecuteResult $ { SQLITE_OK, SQLITE_DONE } )
      IF ( ASCAN( { SQLITE_OK, SQLITE_DONE }, ::lastExecuteResult ) > 0 )
         // count rows affected
         nChanges := sqlite3_changes( ::db:getPointer() )
      ENDIF
   ENDIF
   RETURN ( nChanges )

/**
 *  Make the SQL statement reusable, it is, ready to be re-executed. Note that
 *  any bindings to hosted parameters will be kept, so to clear the previous
 *  bindings use the method <code>clear()</code>.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @see .#clear
 *  @exported
 */
METHOD reuse()
   IF ( EMPTY( ::statement ) )
      Throw( SQLiteFacadeError( "Invalid prepared statement (was closed?)." ) )
   ENDIF
   ::lastExecuteResult := SQLITE_OK
   sqlite3_reset( ::statement )
   RETURN ( self )

/**
 *  Clear bindings to hosted parameters. It's a common idiom to call
 *  <code>stmt:reuse():clear()</code> before anothor call to
 *  <code>executeQuery()</code> or <code>executeUpdate()</code> methods.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *
 *  @see .#reuse
 *  @exported
 */
METHOD clear()
   IF ( EMPTY( ::statement ) )
      Throw( SQLiteFacadeError( "Invalid prepared statement (was closed?)." ) )
   ENDIF
   sqlite3_clear_bindings( ::statement )
   RETURN ( self )

/**
 *  Close (finalize) this statement object. After closing a statement object,
 *  calls to any other method (except <code>getPointer()</code>) will raise a
 *  run-time error.
 *
 *  @return SELF Returns a reference to this <code>SQLiteFacadeStatement</code>.
 *  @exported
 */
METHOD close()
   IF ( !EMPTY( ::statement ) )
      ::clear()
      sqlite3_finalize( ::statement )
      ::statement := NIL
   ENDIF
   RETURN ( self )

/**
 *  Get the <code>POINTER</code> to the actual statement from the Harbour
 *  SQLite3 contribution (see <code>sqlite3_prepare()</code> function for more
 *  details).
 *
 *  @return POINTER|NIL A pointer to the actual statement from the Harbour
 *     SQLite3 contribution. Returns <code>NIL</code> if <code>close()</code>
 *     method was called or this instance was built with an incomplete SQL
 *     statement, the return value will be
 *
 *  @exported
 */
METHOD getPointer()
   RETURN ( ::statement )
