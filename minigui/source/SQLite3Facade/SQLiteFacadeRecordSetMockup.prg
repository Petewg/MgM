/*
 * SQLiteFacadeRecordSetMockup.prg
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
 */

#include "hbclass.ch"
#include "error.ch"
#include "hbsqlit3.ch"

/**
 *  This is a mock result set and is an implementation side effect for the
 *  <code>executeQuery()</code> method from <code>SQLiteFacadeStatement</code>
 *  class. When a query does not result in <code>SQLITE_ROW</code>, but
 *  <code>SQLITE_OK</code> or <code>SQLITE_DONE</code> than an instance of
 *  this mock object will be returned, meaning "no data". Thus, calls to
 *  method <code>next()</code> will always returns false (<code>.F.</code>),
 *  and a call to any of the <code>getXxxx()></code> methods will raise a
 *  run-time error. The <code>close()</code> method can be called, and will
 *  finalize the corresponding statement.
 *
 *  <p>The behavior of <code>executeQuery()</code> method
 *  (<code>SQLiteFacadeStatement</code> class) allows you to deal with loose
 *  query calls or empty result sets without notice, wich is a desirable
 *  behavior.</p>
 *
 *  @author Daniel Goncalves
 *  @since 0.1 (feb/2010)
 */
CREATE CLASS SQLiteFacadeResultSetMockup INHERIT SQLiteFacadeResultSet
   EXPORT:
      METHOD init CONSTRUCTOR
      // ---- overrides most of exported methods of SQLiteFacadeResultSet ----
      METHOD next          // returns LOGICAL
      METHOD getString     // returns CHARACTER
      METHOD getInteger    // returns NUMERIC
      METHOD getFloat      // returns NUMERIC
      METHOD getDate       // returns DATE
      METHOD getBoolean    // returns LOGICAL
   END CLASS

// ///////////////////////////////////////////////////////////////////////////
//
//    exported instance methods
//
// ///////////////////////////////////////////////////////////////////////////

/**
 *  Constructs a new <code>SQLiteFacadeResultSetMockup</code> object. See
 *  <code>SQLiteFacadeResultSet</code> constructor documentation for parameters
 *  details.
 *
 *  @see SQLiteFacadeResultSet.prg#SQLiteFacadeResultSet
 *  @constructor
 */
METHOD init( oStatement, oDB )
   ::SQLiteFacadeResultSet:init( oStatement, oDB )
   RETURN ( self )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#next
 */
METHOD next()
   RETURN ( .F. )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#getString
 */
METHOD getString( ncColumn )
   LOCAL oError := SQLiteFacadeError( "Invalid call to mockup result set" )
   oError:operation := ALLTRIM( Str( ncColumn ) )
   Throw( oError )
   RETURN ( "" )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#getInteger
 */
METHOD getInteger( ncColumn )
   LOCAL oError := SQLiteFacadeError( "Invalid call to mockup result set" )
   oError:operation := ALLTRIM( Str( ncColumn ) )
   Throw( oError )
   RETURN ( 0 )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#getFloat
 */
METHOD getFloat( ncColumn )
   LOCAL oError := SQLiteFacadeError( "Invalid call to mockup result set" )
   oError:operation := ALLTRIM( Str( ncColumn ) )
   Throw( oError )
   RETURN ( 0.0 )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#getDate
 */
METHOD getDate( ncColumn )
   LOCAL oError := SQLiteFacadeError( "Invalid call to mockup result set" )
   oError:operation := ALLTRIM( Str( ncColumn ) )
   Throw( oError )
   RETURN ( CTOD( "" ) )

/**
 *  @docfrom SQLiteFacadeResultSet.prg#getBoolean
 */
METHOD getBoolean( ncColumn )
   LOCAL oError := SQLiteFacadeError( "Invalid call to mockup result set" )
   oError:operation := ALLTRIM( Str( ncColumn ) )
   Throw( oError )
   RETURN ( .F. )

