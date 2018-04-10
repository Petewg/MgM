/*
 * $Id: adordd.prg 8953 2008-07-08 06:06:06Z vszakats $
 */

/*
 * Harbour Project source code:
 * ADORDD - RDD to automatically manage Microsoft ADO
 *
 * Copyright 2007 Fernando Mancera <fmancera@viaopen.com> and
 * Antonio Linares <alinares@fivetechsoft.com>
 * www - https://harbour.github.io/
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
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  if not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "rddsys.ch"
#include "fileio.ch"
#include "error.ch"
#include "adordd.ch"
#include "common.ch"
#include "dbstruct.ch"

#ifndef __XHARBOUR__
#include "hbusrrdd.ch"
   #xcommand TRY              => bError := errorBlock( {|oErr| break( oErr ) } ) ;;
                                 BEGIN SEQUENCE
   #xcommand CATCH [<!oErr!>] => errorBlock( bError ) ;;
                                 RECOVER[USING < oErr > ] <- oErr->;;
                                 ErrorBlock( bError )
#else
   #include "usrrdd.ch"
#endif

#define WA_RECORDSET  1
#define WA_BOF        2
#define WA_EOF        3
#define WA_CONNECTION 4
#define WA_CATALOG    5
#define WA_TABLENAME  6
#define WA_ENGINE     7
#define WA_SERVER     8
#define WA_USERNAME   9
#define WA_PASSWORD  10
#define WA_QUERY     11
#define WA_LOCATEFOR 12
#define WA_SCOPEINFO 13
#define WA_SQLSTRUCT 14

#define WA_SIZE      14

ANNOUNCE ADORDD

STATIC bError, s_cTableName, s_cEngine, s_cServer, s_cUserName, s_cPassword, s_cQuery := ""

#ifdef __XHARBOUR__

STATIC FUNCTION hb_tokenGet( cText, nPos, cSep )

   LOCAL aTokens := hb_ATokens( cText, cSep )

RETURN iif( nPos <= Len( aTokens ), aTokens[ nPos ], "" )

#endif

STATIC FUNCTION ADO_INIT( nRDD )

   LOCAL aRData

   USRRDD_RDDDATA( nRDD, aRData )

RETURN SUCCESS

STATIC FUNCTION ADO_NEW( nWA )

   LOCAL aWAData := Array( WA_SIZE )

   aWAData[ WA_BOF ] := .F.
   aWAData[ WA_EOF ] := .F.

   USRRDD_AREADATA( nWA, aWAData )

RETURN SUCCESS

STATIC FUNCTION ADO_CREATE( nWA, aOpenInfo )

   LOCAL cDataBase   := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 1, ";" )
   LOCAL cTableName  := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 2, ";" )
   LOCAL cDbEngine   := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 3, ";" )
   LOCAL cServer     := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 4, ";" )
   LOCAL cUserName   := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 5, ";" )
   LOCAL cPassword   := hb_tokenGet( aOpenInfo[ UR_OI_NAME ], 6, ";" )
   LOCAL oConnection := TOleAuto():New( "ADODB.Connection" )
   LOCAL oCatalog    := TOleAuto():New( "ADOX.Catalog" )
   LOCAL aWAData     := USRRDD_AREADATA( nWA )
   LOCAL oError

   DO CASE
   CASE Lower( Right( cDataBase, 4 ) ) == ".mdb"
      IF ! File( cDataBase )
         oCatalog:Create( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + cDataBase )
      ENDIF
      oConnection:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + cDataBase )

   CASE Upper( cDbEngine ) == "MYSQL"
      oConnection:Open( "DRIVER={MySQL ODBC 3.51 Driver};" + ;
         "server=" + cServer + ;
         ";database=" + cDataBase + ;
         ";uid=" + cUserName + ;
         ";pwd=" + cPassword )

   ENDCASE

   TRY
      oConnection:Execute( "DROP TABLE " + cTableName )
   CATCH
   END

   TRY
      oConnection:Execute( "CREATE TABLE [" + cTableName + "] (" + aWAData[ WA_SQLSTRUCT ] + ")" )
   CATCH
      oError := ErrorNew()
      oError:GenCode     := EG_CREATE
      oError:SubCode     := 1004
      oError:Description := hb_langErrMsg( EG_CREATE ) + " (" + ;
         hb_langErrMsg( EG_UNSUPPORTED ) + ")"
      oError:FileName    := aOpenInfo[ UR_OI_NAME ]
      oError:CanDefault  := .T.
      UR_SUPER_ERROR( nWA, oError )
   END

   oConnection:Close()

RETURN SUCCESS

STATIC FUNCTION ADO_CREATEFIELDS( nWA, aStruct )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL n

   aWAData[ WA_SQLSTRUCT ] := ""

   FOR n := 1 TO Len( aStruct )
      IF n > 1
         aWAData[ WA_SQLSTRUCT ] += ", "
      ENDIF
      aWAData[ WA_SQLSTRUCT ] += "[" + aStruct[ n ][ DBS_NAME ] + "]"
      DO CASE
      CASE aStruct[ n ][ DBS_TYPE ] $ "C,Character"
         aWAData[ WA_SQLSTRUCT ] += " CHAR(" + hb_ntos( aStruct[ n ][ DBS_LEN ] ) + ") NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "V"
         aWAData[ WA_SQLSTRUCT ] += " VARCHAR(" + hb_ntos( aStruct[ n ][ DBS_LEN ] ) + ") NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "B"
         aWAData[ WA_SQLSTRUCT ] += " DOUBLE NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "Y"
         aWAData[ WA_SQLSTRUCT ] += " SMALLINT NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "I"
         aWAData[ WA_SQLSTRUCT ] += " MEDIUMINT NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "D"
         aWAData[ WA_SQLSTRUCT ] += " DATE NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "T"
         aWAData[ WA_SQLSTRUCT ] += " DATETIME NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "@"
         aWAData[ WA_SQLSTRUCT ] += " TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP"

      CASE aStruct[ n ][ DBS_TYPE ] == "M"
         aWAData[ WA_SQLSTRUCT ] += " TEXT NULL"

      CASE aStruct[ n ][ DBS_TYPE ] == "N"
         aWAData[ WA_SQLSTRUCT ] += " NUMERIC(" + hb_ntos( aStruct[ n ][ DBS_LEN ] ) + ")"

      CASE aStruct[ n ][ DBS_TYPE ] == "L"
         aWAData[ WA_SQLSTRUCT ] += " LOGICAL"
      ENDCASE
   NEXT

RETURN SUCCESS

STATIC FUNCTION ADO_OPEN( nWA, aOpenInfo )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL cName, aField, oError, nResult
   LOCAL oRecordSet, nTotalFields, n

   // When there is no ALIAS we will create new one using file name
   IF aOpenInfo[ UR_OI_ALIAS ] == nil
      hb_FNameSplit( aOpenInfo[ UR_OI_NAME ], , @cName )
      aOpenInfo[ UR_OI_ALIAS ] := cName
   ENDIF

   aWAData[ WA_CONNECTION ] := TOleAuto():New( "ADODB.Connection" )
   aWAData[ WA_TABLENAME ] := s_cTableName
   aWAData[ WA_QUERY ]    := s_cQuery
   aWAData[ WA_USERNAME ] := s_cUserName
   aWAData[ WA_PASSWORD ] := s_cPassword
   aWAData[ WA_SERVER ] := s_cServer
   aWAData[ WA_ENGINE ] := s_cEngine

   DO CASE
   CASE Lower( Right( aOpenInfo[ UR_OI_NAME ], 4 ) ) == ".mdb"
      IF Empty( aWAData[ WA_PASSWORD ] )
         aWAData[ WA_CONNECTION ]:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + aOpenInfo[ UR_OI_NAME ] )
      ELSE
         aWAData[ WA_CONNECTION ]:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + aOpenInfo[ UR_OI_NAME ] + ";Jet OLEDB:Database Password=" + AllTrim( aWAData[ WA_PASSWORD ] ) )
      ENDIF

   CASE Lower( Right( aOpenInfo[ UR_OI_NAME ], 4 ) ) == ".xls"
      aWAData[ WA_CONNECTION ]:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + aOpenInfo[ UR_OI_NAME ] + ";Extended Properties='Excel 8.0;HDR=YES';Persist Security Info=False" )

   CASE Lower( Right( aOpenInfo[ UR_OI_NAME ], 4 ) ) == ".dbf"
      aWAData[ WA_CONNECTION ]:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + aOpenInfo[ UR_OI_NAME ] + ";Extended Properties=dBASE IV;User ID=Admin;Password=;" )

   CASE Lower( Right( aOpenInfo[ UR_OI_NAME ], 3 ) ) == ".db"
      aWAData[ WA_CONNECTION ]:Open( "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + aOpenInfo[ UR_OI_NAME ] + ";Extended Properties='Paradox 3.x';" )

   CASE aWAData[ WA_ENGINE ] == "MYSQL"
      aWAData[ WA_CONNECTION ]:Open( "DRIVER={MySQL ODBC 3.51 Driver};" + ;
         "server=" + aWAData[ WA_SERVER ] + ;
         ";database=" + aOpenInfo[ UR_OI_NAME ] + ;
         ";uid=" + aWAData[ WA_USERNAME ] + ;
         ";pwd=" + aWAData[ WA_PASSWORD ] )

   CASE aWAData[ WA_ENGINE ] == "SQL"
      aWAData[ WA_CONNECTION ]:Open( "Provider=SQLOLEDB;" + ;
         "server=" + aWAData[ WA_SERVER ] + ;
         ";database=" + aOpenInfo[ UR_OI_NAME ] + ;
         ";uid=" + aWAData[ WA_USERNAME ] + ;
         ";pwd=" + aWAData[ WA_PASSWORD ] )

   CASE aWAData[ WA_ENGINE ] == "ORACLE"
      aWAData[ WA_CONNECTION ]:Open( "Provider=MSDAORA.1;" + ;
         "Persist Security Info=False" + ;
         iif( Empty( aWAData[ WA_SERVER ] ), ;
         "", ";Data source=" + aWAData[ WA_SERVER ] ) + ;
         ";User ID=" + aWAData[ WA_USERNAME ] + ;
         ";Password=" + aWAData[ WA_PASSWORD ] )

   ENDCASE

   oRecordSet := TOleAuto():New( "ADODB.Recordset" )
   oRecordSet:CursorType     := adOpenDynamic
   oRecordSet:CursorLocation := adUseClient
   oRecordSet:LockType       := adLockPessimistic
   oRecordSet:Open( aWAData[ WA_QUERY ] + aWAData[ WA_TABLENAME ], aWAData[ WA_CONNECTION ] )

   aWAData[ WA_CATALOG ] := TOleAuto():New( "ADOX.Catalog" )
   aWAData[ WA_CATALOG ]:ActiveConnection := aWAData[ WA_CONNECTION ]

   IF oRecordSet == NIL
      oError := ErrorNew()
      oError:GenCode     := EG_OPEN
      oError:SubCode     := 1001
      oError:Description := hb_langErrMsg( EG_OPEN )
      oError:FileName    := aOpenInfo[ UR_OI_NAME ]
      oError:OsCode      := 0 // To be implemented
      oError:CanDefault  := .T.

      UR_SUPER_ERROR( nWA, oError )
      RETURN FAILURE
   ENDIF

   aWAData[ WA_RECORDSET ] := oRecordSet
   aWAData[ WA_BOF ] := aWAData[ WA_EOF ] := .F.

   UR_SUPER_SETFIELDEXTENT( nWA, nTotalFields := oRecordSet:Fields:Count )

   FOR n := 1 TO nTotalFields
      aField := Array( UR_FI_SIZE )
      aField[ UR_FI_NAME ]    := oRecordSet:Fields( n - 1 ):Name
      aField[ UR_FI_TYPE ]    := ADO_GETFIELDTYPE( oRecordSet:Fields( n - 1 ):Type )
      aField[ UR_FI_TYPEEXT ] := 0
      aField[ UR_FI_LEN ]     := ADO_GETFIELDSIZE( aField[ UR_FI_TYPE ], oRecordSet:Fields( n - 1 ):DefinedSize )
      aField[ UR_FI_DEC ]     := 0
      UR_SUPER_ADDFIELD( nWA, aField )
   NEXT

   nResult := UR_SUPER_OPEN( nWA, aOpenInfo )

   IF nResult == SUCCESS
      ADO_GOTOP( nWA )
   ENDIF

RETURN nResult

STATIC FUNCTION ADO_CLOSE( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
   // oRecordSet:Close()
   CATCH
   END

RETURN UR_SUPER_CLOSE( nWA )

STATIC FUNCTION ADO_GETVALUE( nWA, nField, xValue )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   IF aWAData[ WA_EOF ] .OR. oRecordSet:RecordCount() == 0
      xValue := nil
   ELSE
      xValue := oRecordSet:Fields( nField - 1 ):Value
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_GOTOID( nWA, nRecord )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ], nRecNo

   IF oRecordSet:RecordCount() > 0
      oRecordSet:MoveFirst()
      oRecordSet:Move( nRecord - 1, 0 )
   ENDIF
   ADO_RECID( nWA, @nRecNo )

RETURN iif( nRecord == nRecNo, SUCCESS, FAILURE )

STATIC FUNCTION ADO_GOTOP( nWA )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   IF oRecordSet:RecordCount() != 0
      oRecordSet:MoveFirst()
   ENDIF

   aWAData[ WA_BOF ] := .F.
   aWAData[ WA_EOF ] := .F.

RETURN SUCCESS

STATIC FUNCTION ADO_GOBOTTOM( nWA )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   oRecordSet:MoveLast()

   aWAData[ WA_BOF ] := .F.
   aWAData[ WA_EOF ] := .F.

RETURN SUCCESS

STATIC FUNCTION ADO_SKIPRAW( nWA, nRecords )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   IF nRecords != 0
      IF aWAData[ WA_EOF ]
         IF nRecords > 0
            RETURN SUCCESS
         ENDIF
         ADO_GOBOTTOM( nWA )
         ++nRecords
      ENDIF
      IF nRecords < 0 .AND. oRecordSet:AbsolutePosition <= -nRecords
         oRecordSet:MoveFirst()
         aWAData[ WA_BOF ] := .T.
         aWAData[ WA_EOF ] := oRecordSet:EOF
      ELSEIF nRecords != 0
         oRecordSet:Move( nRecords )
         aWAData[ WA_BOF ] := .F.
         aWAData[ WA_EOF ] := oRecordSet:EOF
      ENDIF
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_BOF( nWA, lBof )

   LOCAL aWAData := USRRDD_AREADATA( nWA )

   lBof := aWAData[ WA_BOF ]

RETURN SUCCESS

STATIC FUNCTION ADO_EOF( nWA, lEof )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   lEof := ( oRecordSet:AbsolutePosition == -3 )

RETURN SUCCESS

STATIC FUNCTION ADO_DELETED( nWA, lDeleted )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
   IF oRecordSet:Status == adRecDeleted
      lDeleted := .T.
   ELSE
      lDeleted := .F.
   ENDIF
   CATCH
      lDeleted := .F.
   END

RETURN SUCCESS

STATIC FUNCTION ADO_DELETE( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   oRecordSet:Delete()

   ADO_SKIPRAW( nWA, 1 )

RETURN SUCCESS

STATIC FUNCTION ADO_RECID( nWA, nRecNo )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   nRecno := iif( oRecordSet:AbsolutePosition == -3, oRecordSet:RecordCount() + 1, oRecordSet:AbsolutePosition )

RETURN SUCCESS

STATIC FUNCTION ADO_RECCOUNT( nWA, nRecords )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   nRecords := oRecordSet:RecordCount()

RETURN SUCCESS

STATIC FUNCTION ADO_PUTVALUE( nWA, nField, xValue )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   IF ! aWAData[ WA_EOF ] .AND. !( oRecordSet:Fields( nField - 1 ):Value == xValue )
      IF ValType( xValue ) == "C" .AND. Len( xValue ) > oRecordSet:Fields( nField - 1 ):DefinedSize
         xValue := Left( xValue, oRecordSet:Fields( nField - 1 ):DefinedSize )
      ENDIF
      oRecordSet:Fields( nField - 1 ):Value := xValue
      TRY
         oRecordSet:Update()
      CATCH
      END
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_APPEND( nWA, lUnLockAll )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   HB_SYMBOL_UNUSED( lUnLockAll )

   oRecordSet:AddNew()

   TRY
      oRecordSet:Update()
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_FLUSH( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
      oRecordSet:Update()
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDINFO( nWA, nIndex, aOrderInfo )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   DO CASE
   CASE nIndex == UR_ORI_TAG
      IF aOrderInfo[ UR_ORI_TAG ] != NIL .AND. aOrderInfo[ UR_ORI_TAG ] < aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes:Count
         aOrderInfo[ UR_ORI_RESULT ] := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes( aOrderInfo[ UR_ORI_TAG ] ):Name
      ELSE
         aOrderInfo[ UR_ORI_RESULT ] := ""
      ENDIF
   ENDCASE

RETURN SUCCESS

STATIC FUNCTION ADO_PACK( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

RETURN SUCCESS

STATIC FUNCTION ADO_RAWLOCK( nWA, nAction, nRecNo )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   HB_SYMBOL_UNUSED( nAction )
   HB_SYMBOL_UNUSED( nRecNo )

RETURN SUCCESS

STATIC FUNCTION ADO_LOCK( nWA, aLockInfo  )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   aLockInfo[ UR_LI_METHOD ] := DBLM_MULTIPLE
   aLockInfo[ UR_LI_RECORD ] := RecNo()
   aLockInfo[ UR_LI_RESULT ] := .T.

RETURN SUCCESS

STATIC FUNCTION ADO_UNLOCK( nWA, xRecID )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   HB_SYMBOL_UNUSED( xRecID )

RETURN SUCCESS

STATIC FUNCTION ADO_SETFILTER( nWA, aFilterInfo )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   oRecordSet:Filter := SQLTranslate( aFilterInfo[ UR_FRI_CEXPR ] )

RETURN SUCCESS

STATIC FUNCTION ADO_CLEARFILTER( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
      oRecordSet:Filter := ""
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ZAP( nWA )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   IF aWAData[ WA_CONNECTION ] != NIL .AND. aWAData[ WA_TABLENAME ] != nil
      TRY
         aWAData[ WA_CONNECTION ]:Execute( "TRUNCATE TABLE " + aWAData[ WA_TABLENAME ] )
      CATCH
         aWAData[ WA_CONNECTION ]:Execute( "DELETE * FROM " + aWAData[ WA_TABLENAME ] )
      END
      oRecordSet:Requery()
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_SETLOCATE( nWA, aScopeInfo )

   LOCAL aWAData := USRRDD_AREADATA( nWA )

   aScopeInfo[ UR_SI_CFOR ] := SQLTranslate( aWAData[ WA_LOCATEFOR ] )

   aWAData[ WA_SCOPEINFO ] := aScopeInfo

RETURN SUCCESS

STATIC FUNCTION ADO_LOCATE( nWA, lContinue )

   LOCAL aWAData    := USRRDD_AREADATA( nWA )
   LOCAL oRecordSet := aWAData[ WA_RECORDSET ]

   oRecordSet:Find( aWAData[ WA_SCOPEINFO ][ UR_SI_CFOR ], iif( lContinue, 1, 0 ) )
   USRRDD_SETFOUND( nWA, ! oRecordSet:EOF )
   aWAData[ WA_EOF ] := oRecordSet:EOF

RETURN SUCCESS

STATIC FUNCTION ADO_CLEARREL( nWA )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL nKeys := 0, cKeyName

   IF aWAData[ WA_CATALOG ] != NIL .AND. aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys != nil
      TRY
         nKeys := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys:Count
      CATCH
      END
   ENDIF

   IF nKeys > 0
      cKeyName := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys( nKeys - 1 ):Name
      IF !( Upper( cKeyName ) == "PRIMARYKEY" )
         aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys:Delete( cKeyName )
      ENDIF
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_RELAREA( nWA, nRelNo, nRelArea )

   LOCAL aWAData := USRRDD_AREADATA( nWA )

   IF nRelNo <= aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys:Count()
      nRelArea := Select( aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys( nRelNo - 1 ):RelatedTable )
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_RELTEXT( nWA, nRelNo, cExpr )

   LOCAL aWAData := USRRDD_AREADATA( nWA )

   IF nRelNo <= aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys:Count()
      cExpr := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys( nRelNo - 1 ):Columns( 0 ):RelatedColumn
   ENDIF

RETURN SUCCESS

STATIC FUNCTION ADO_SETREL( nWA, aRelInfo )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL cParent := Alias( aRelInfo[ UR_RI_PARENT ] )
   LOCAL cChild  := Alias( aRelInfo[ UR_RI_CHILD ] )
   LOCAL cKeyName := cParent + "_" + cChild

   TRY
   aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Keys:Append( cKeyName, adKeyForeign, ;
      aRelInfo[ UR_RI_CEXPR ], cChild, aRelInfo[ UR_RI_CEXPR ] )
   CATCH
   // raise error for can't create relation
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDLSTADD( nWA, aOrderInfo )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
      oRecordSet:Index := aOrderInfo[ UR_ORI_BAG ]
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDLSTCLEAR( nWA )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
      oRecordSet:Index := ""
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDLSTFOCUS( nWA, aOrderInfo )

   LOCAL oRecordSet := USRRDD_AREADATA( nWA )[ WA_RECORDSET ]

   TRY
      oRecordSet:Index = aOrderInfo[ UR_ORI_BAG ]
   CATCH
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDCREATE( nWA, aOrderCreateInfo )

   LOCAL aWAData := USRRDD_AREADATA( nWA )
   LOCAL oIndex, oError, n, lFound := .F.

   IF aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes != nil
      FOR n := 1 TO aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes:Count
         oIndex := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes( n - 1 )
         IF oIndex:Name == iif( ! Empty( aOrderCreateInfo[ UR_ORCR_TAGNAME ] ), aOrderCreateInfo[ UR_ORCR_TAGNAME ], aOrderCreateInfo[ UR_ORCR_CKEY ] )
            lFound := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF

   TRY
   IF aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes == NIL .OR. ! lFound
      oIndex := TOleAuto():New( "ADOX.Index" )
      oIndex:Name := iif( ! Empty( aOrderCreateInfo[ UR_ORCR_TAGNAME ] ), aOrderCreateInfo[ UR_ORCR_TAGNAME ], aOrderCreateInfo[ UR_ORCR_CKEY ] )
      oIndex:PrimaryKey := .F.
      oIndex:Unique := aOrderCreateInfo[ UR_ORCR_UNIQUE ]
      oIndex:Columns:Append( aOrderCreateInfo[ UR_ORCR_CKEY ] )
      aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes:Append( oIndex )
   ENDIF
   CATCH
      oError := ErrorNew()
      oError:GenCode     := EG_CREATE
      oError:SubCode     := 1004
      oError:Description := hb_langErrMsg( EG_CREATE ) + " (" + ;
         hb_langErrMsg( EG_UNSUPPORTED ) + ")"
      oError:FileName    := aOrderCreateInfo[ UR_ORCR_BAGNAME ]
      oError:CanDefault  := .T.
      UR_SUPER_ERROR( nWA, oError )
   END

RETURN SUCCESS

STATIC FUNCTION ADO_ORDDESTROY( nWA, aOrderInfo )

   LOCAL aWAData := USRRDD_AREADATA( nWA ), n, oIndex

   IF aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes != nil
      FOR n := 1 TO aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes:Count
         oIndex := aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes( n - 1 )
         IF oIndex:Name == aOrderInfo[ UR_ORI_TAG ]
            aWAData[ WA_CATALOG ]:Tables( aWAData[ WA_TABLENAME ] ):Indexes:Delete( oIndex:Name )
         ENDIF
      NEXT
   ENDIF

RETURN SUCCESS

FUNCTION ADORDD_GETFUNCTABLE( pFuncCount, pFuncTable, pSuperTable, nRddID )

   LOCAL cSuperRDD   /* NO SUPER RDD */
   LOCAL aADOFunc[ UR_METHODCOUNT ]

   aADOFunc[ UR_INIT ]         := ( @ADO_INIT() )
   aADOFunc[ UR_NEW ]          := ( @ADO_NEW() )
   aADOFunc[ UR_CREATE ]       := ( @ADO_CREATE() )
   aADOFunc[ UR_CREATEFIELDS ] := ( @ADO_CREATEFIELDS() )
   aADOFunc[ UR_OPEN ]         := ( @ADO_OPEN() )
   aADOFunc[ UR_CLOSE ]        := ( @ADO_CLOSE() )
   aADOFunc[ UR_BOF  ]         := ( @ADO_BOF() )
   aADOFunc[ UR_EOF  ]         := ( @ADO_EOF() )
   aADOFunc[ UR_DELETED ]      := ( @ADO_DELETED() )
   aADOFunc[ UR_SKIPRAW ]      := ( @ADO_SKIPRAW() )
   aADOFunc[ UR_GOTO ]         := ( @ADO_GOTOID() )
   aADOFunc[ UR_GOTOID ]       := ( @ADO_GOTOID() )
   aADOFunc[ UR_GOTOP ]        := ( @ADO_GOTOP() )
   aADOFunc[ UR_GOBOTTOM ]     := ( @ADO_GOBOTTOM() )
   aADOFunc[ UR_RECID ]        := ( @ADO_RECID() )
   aADOFunc[ UR_RECCOUNT ]     := ( @ADO_RECCOUNT() )
   aADOFunc[ UR_GETVALUE ]     := ( @ADO_GETVALUE() )
   aADOFunc[ UR_PUTVALUE ]     := ( @ADO_PUTVALUE() )
   aADOFunc[ UR_DELETE ]       := ( @ADO_DELETE() )
   aADOFunc[ UR_APPEND ]       := ( @ADO_APPEND() )
   aADOFunc[ UR_FLUSH ]        := ( @ADO_FLUSH() )
   aADOFunc[ UR_ORDINFO ]      := ( @ADO_ORDINFO() )
   aADOFunc[ UR_PACK ]         := ( @ADO_PACK() )
   aADOFunc[ UR_RAWLOCK ]      := ( @ADO_RAWLOCK() )
   aADOFunc[ UR_LOCK ]         := ( @ADO_LOCK() )
   aADOFunc[ UR_UNLOCK ]       := ( @ADO_UNLOCK() )
   aADOFunc[ UR_SETFILTER ]    := ( @ADO_SETFILTER() )
   aADOFunc[ UR_CLEARFILTER ]  := ( @ADO_CLEARFILTER() )
   aADOFunc[ UR_ZAP ]          := ( @ADO_ZAP() )
   aADOFunc[ UR_SETLOCATE ]    := ( @ADO_SETLOCATE() )
   aADOFunc[ UR_LOCATE ]       := ( @ADO_LOCATE() )
   aADOFunc[ UR_CLEARREL ]     := ( @ADO_CLEARREL() )
   aADOFunc[ UR_RELAREA ]      := ( @ADO_RELAREA() )
   aADOFunc[ UR_RELTEXT ]      := ( @ADO_RELTEXT() )
   aADOFunc[ UR_SETREL ]       := ( @ADO_SETREL() )
   aADOFunc[ UR_ORDCREATE ]    := ( @ADO_ORDCREATE() )
   aADOFunc[ UR_ORDDESTROY ]   := ( @ADO_ORDDESTROY() )
   aADOFunc[ UR_ORDLSTADD ]    := ( @ADO_ORDLSTADD() )
   aADOFunc[ UR_ORDLSTCLEAR ]  := ( @ADO_ORDLSTCLEAR() )
   aADOFunc[ UR_ORDLSTFOCUS ]  := ( @ADO_ORDLSTFOCUS() )

RETURN USRRDD_GETFUNCTABLE( pFuncCount, pFuncTable, pSuperTable, nRddID, cSuperRDD, ;
      aADOFunc )

INIT PROCEDURE ADORDD_INIT()
   rddRegister( "ADORDD", RDT_FULL )

RETURN

STATIC FUNCTION ADO_GETFIELDSIZE( nDBFFieldType, nADOFieldSize )

   LOCAL nDBFFieldSize := 0

   DO CASE

   CASE nDBFFieldType == HB_FT_STRING
      nDBFFieldSize := nADOFieldSize

   CASE nDBFFieldType == HB_FT_INTEGER
      nDBFFieldSize := nADOFieldSize

   CASE nDBFFieldType == HB_FT_DOUBLE
      nDBFFieldSize := nADOFieldSize

   CASE nDBFFieldType == HB_FT_DATE
      nDBFFieldSize := 8

   CASE nDBFFieldType == HB_FT_LOGICAL
      nDBFFieldSize := 1

   CASE nDBFFieldType == HB_FT_MEMO
      nDBFFieldSize := 10

   ENDCASE

RETURN nDBFFieldSize

STATIC FUNCTION ADO_GETFIELDTYPE( nADOFieldType )

   LOCAL nDBFFieldType := 0

   DO CASE

   CASE nADOFieldType == adEmpty
   CASE nADOFieldType == adTinyInt
      nDBFFieldType := HB_FT_INTEGER

   CASE nADOFieldType == adSmallInt
      nDBFFieldType := HB_FT_INTEGER

   CASE nADOFieldType == adInteger
      nDBFFieldType := HB_FT_INTEGER

   CASE nADOFieldType == adBigInt
      nDBFFieldType := HB_FT_INTEGER

   CASE nADOFieldType == adUnsignedTinyInt
   CASE nADOFieldType == adUnsignedSmallInt
   CASE nADOFieldType == adUnsignedInt
   CASE nADOFieldType == adUnsignedBigInt
   CASE nADOFieldType == adSingle

   CASE nADOFieldType == adDouble
      nDBFFieldType := HB_FT_DOUBLE

   CASE nADOFieldType == adCurrency
      nDBFFieldType := HB_FT_INTEGER

   CASE nADOFieldType == adDecimal
      nDBFFieldType := HB_FT_LONG

   CASE nADOFieldType == adNumeric
      nDBFFieldType := HB_FT_LONG


   CASE nADOFieldType == adError
   CASE nADOFieldType == adUserDefined
   CASE nADOFieldType == adVariant
      nDBFFieldType := HB_FT_ANY

   CASE nADOFieldType == adIDispatch

   CASE nADOFieldType == adIUnknown

   CASE nADOFieldType == adGUID
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adDate
      nDBFFieldType := HB_FT_DATE

   CASE nADOFieldType == adDBDate
      nDBFFieldType := HB_FT_DATE

   CASE nADOFieldType == adDBTime
      //nDBFFieldType := HB_FT_DATE

   CASE nADOFieldType == adDBTimeStamp
      //nDBFFieldType := HB_FT_DATE

   CASE nADOFieldType == adFileTime
      //nDBFFieldType := HB_FT_DATE

   CASE nADOFieldType == adBSTR
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adChar
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adVarChar
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adLongVarChar
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adWChar
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adVarWChar
      nDBFFieldType := HB_FT_STRING

   CASE nADOFieldType == adBinary
   CASE nADOFieldType == adVarBinary
   CASE nADOFieldType == adLongVarBinary
   CASE nADOFieldType == adChapter

   CASE nADOFieldType == adVarNumeric
#if 0
   CASE nADOFieldType == adArray
#endif

   CASE nADOFieldType == adBoolean
      nDBFFieldType := HB_FT_LOGICAL

   CASE nADOFieldType == adLongVarWChar
      nDBFFieldType := HB_FT_MEMO

   CASE nADOFieldType == adPropVariant
      nDBFFieldType := HB_FT_MEMO

   ENDCASE

RETURN nDBFFieldType

FUNCTION HB_AdoSetTable( cTableName )

   s_cTableName := cTableName

RETURN NIL

FUNCTION HB_AdoSetEngine( cEngine )

   s_cEngine := cEngine

RETURN NIL

FUNCTION HB_AdoSetServer( cServer )

   s_cServer := cServer

RETURN NIL

FUNCTION HB_AdoSetUser( cUser )

   s_cUserName := cUser

RETURN NIL

FUNCTION HB_AdoSetPassword( cPassword )

   s_cPassword := cPassword

RETURN NIL

FUNCTION HB_AdoSetQuery( cQuery )

   DEFAULT cQuery TO "SELECT * FROM "

   s_cQuery := cQuery

RETURN NIL

FUNCTION HB_AdoSetLocateFor( cLocateFor )

   USRRDD_AREADATA( Select() )[ WA_LOCATEFOR ] := cLocateFor

RETURN NIL

STATIC FUNCTION SQLTranslate( cExpr )

   IF Left( cExpr, 1 ) == '"' .AND. Right( cExpr, 1 ) == '"'
      cExpr := SubStr( cExpr, 2, Len( cExpr ) - 2 )
   ENDIF

   cExpr := StrTran( cExpr, '""', "" )
   cExpr := StrTran( cExpr, '"', "'" )
   cExpr := StrTran( cExpr, "''", "'" )
   cExpr := StrTran( cExpr, "==", "=" )
   cExpr := StrTran( cExpr, ".and.", "AND" )
   cExpr := StrTran( cExpr, ".or.", "OR" )
   cExpr := StrTran( cExpr, ".AND.", "AND" )
   cExpr := StrTran( cExpr, ".OR.", "OR" )

RETURN cExpr

FUNCTION HB_AdoRddGetConnection( nWA )

   DEFAULT nWA TO Select()

RETURN USRRDD_AREADATA( nWA )[ WA_CONNECTION ]

FUNCTION HB_AdoRddGetCatalog( nWA )

   DEFAULT nWA TO Select()

RETURN USRRDD_AREADATA( nWA )[ WA_CATALOG ]

FUNCTION HB_AdoRddGetRecordSet( nWA )

   LOCAL aWAData

   DEFAULT nWA TO Select()

   aWAData := USRRDD_AREADATA( nWA )

RETURN iif( aWAData != nil, aWAData[ WA_RECORDSET ], nil )
