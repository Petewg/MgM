/*
 * SQLiteFacadeHelper.prg
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

#include "error.ch"
#include "hbsqlit3.ch"

/**
 *  This module contains helper functions to deal with common tasks.
 *
 *  @author Daniel Goncalves
 *  @since 0.1 (feb/2010)
 */
#define APIX_MODULE_INTRO

#define SQLITEFACADE_ERRORS  { { SQLITE_OK        ,  'SQLITE_OK'         }, ;
                               { SQLITE_ERROR     ,  'SQLITE_ERROR'      }, ;
                               { SQLITE_INTERNAL  ,  'SQLITE_INTERNAL'   }, ;
                               { SQLITE_PERM      ,  'SQLITE_PERM'       }, ;
                               { SQLITE_ABORT     ,  'SQLITE_ABORT'      }, ;
                               { SQLITE_BUSY      ,  'SQLITE_BUSY'       }, ;
                               { SQLITE_LOCKED    ,  'SQLITE_LOCKED'     }, ;
                               { SQLITE_NOMEM     ,  'SQLITE_NOMEM'      }, ;
                               { SQLITE_READONLY  ,  'SQLITE_READONLY'   }, ;
                               { SQLITE_INTERRUPT ,  'SQLITE_INTERRUPT'  }, ;
                               { SQLITE_IOERR     ,  'SQLITE_IOERR'      }, ;
                               { SQLITE_CORRUPT   ,  'SQLITE_CORRUPT'    }, ;
                               { SQLITE_NOTFOUND  ,  'SQLITE_NOTFOUND'   }, ;
                               { SQLITE_FULL      ,  'SQLITE_FULL'       }, ;
                               { SQLITE_CANTOPEN  ,  'SQLITE_CANTOPEN'   }, ;
                               { SQLITE_PROTOCOL  ,  'SQLITE_PROTOCOL'   }, ;
                               { SQLITE_EMPTY     ,  'SQLITE_EMPTY'      }, ;
                               { SQLITE_SCHEMA    ,  'SQLITE_SCHEMA'     }, ;
                               { SQLITE_TOOBIG    ,  'SQLITE_TOOBIG'     }, ;
                               { SQLITE_CONSTRAINT,  'SQLITE_CONSTRAINT' }, ;
                               { SQLITE_MISMATCH  ,  'SQLITE_MISMATCH'   }, ;
                               { SQLITE_MISUSE    ,  'SQLITE_MISUSE'     }, ;
                               { SQLITE_NOLFS     ,  'SQLITE_NOLFS'      }, ;
                               { SQLITE_AUTH      ,  'SQLITE_AUTH'       }, ;
                               { SQLITE_FORMAT    ,  'SQLITE_FORMAT'     }, ;
                               { SQLITE_RANGE     ,  'SQLITE_RANGE'      }, ;
                               { SQLITE_NOTADB    ,  'SQLITE_NOTADB'     }, ;
                               { SQLITE_ROW       ,  'SQLITE_ROW'        }, ;
                               { SQLITE_DONE      ,  'SQLITE_DONE'       } }

/**
*  Safely checks wheter a value is an instance of a particular class.
*  This function should be used instead of a direct call to
*  <code>isKindOf()</code> since different versions of Harbour doesn't provide
*  properly scalar type object wrappers. Refer to the Harbour methods
*  <code>isKindOf()</code> or <code>isDerivedFrom()</code> for details.
*
*  @param wuInstance OBJECT An instance to be checked against a class or a
*     sub-class. This is the object that's supposed to belong to (or is a)
*     <code>wuType</code>.
*
*  @param wuType OBJECT|CHARACTER An instance or the type class to be compared
*     to <code>wuInstance</code>. This parameter can be a character string
*     with the name of a particular class.
*
*  @return LOGICAL Returns true if <code>wuInstance</code> belongs to (or is a)
*     <code>wuType</code>.
*/
FUNCTION SQLiteFacadeIsInstance( wuInstance, wuType )
   IF ( HB_IsObject( wuInstance ) )
      IF ( HB_IsObject( wuType ) )
         RETURN ( wuInstance:isKindOf( wuType ) )
      ELSEIF ( HB_IsString( wuType ) )
         RETURN ( wuInstance:isKindOf( UPPER( ALLTRIM( wuType ) ) ) )
      ENDIF
   ENDIF
   RETURN ( .F. )

/**
 *  Build a ready to use <code>Error</code> object.
 *  @param cDescription CHARACTER (optional) The error description.
 *  @return Error Return a ready to use <code>Error</code> object.
 */
FUNCTION SQLiteFacadeError( cDescription )
   LOCAL oError := ErrorNew()
   oError:severity := ES_ERROR
   oError:subcode := 0
   oError:subsystem := "SQLiteFacade"
   //oError:modulename := PROCFILE( 1 )
   //oError:procname := PROCNAME( 1 )
   //oError:procline := PROCLINE( 1 )
   oError:candefault := .F.
   oError:cansubstitute := .F.
   oError:canretry := .F.
   oError:operation := ""
   IF ( HB_IsString( cDescription ) )
      oError:description := cDescription
   ENDIF
   RETURN ( oError )

/**
 *  Build an <code>Error</code> object that's suitable for a type error.
 *  @param cDescription CHARACTER (optional) The error description.
 *  @param wuParam ? The offending value, wich is usually the invalid parameter
 *     variable in the calling code.
 *  @return Error Return an <code>Error</code> object.
 */
FUNCTION SQLiteFacadeTypeError( cDescription, wuParam )
   LOCAL oError := SQLiteFacadeError( cDescription )
   oError:args := { wuParam }
   //oError:modulename := PROCFILE( 1 )
   //oError:procname := PROCNAME( 1 )
   //oError:procline := PROCLINE( 1 )
   RETURN ( oError )

/**
 *  Return the name of an error constant. For example, if you pass a parameter
 *  of value 10, you'll got the string <code>&quot;SQLITE_IOERR&quot;</code>.
 *
 *  @param nErrorCode NUMERIC The SQLite version 3 error code.
 *
 *  @return CHARACTER The name of an error constant based on the constant value.
 */
FUNCTION SQLiteFacadeErrorName( nErrorCode )
   LOCAL n
   IF ( !HB_IsNumeric( nErrorCode ) )
      RETURN ( "Unknow: " + ALLTRIM ( Str( nErrorCode ) ) )
   ENDIF
   IF ( n := ASCAN( SQLITEFACADE_ERRORS, { |_e| _e[1]==nErrorCode } ) ) > 0
      RETURN ( SQLITEFACADE_ERRORS[n][2] )
   ENDIF
   RETURN ( "Code " + ALLTRIM( STR( nErrorCode ) ) )

