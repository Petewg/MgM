/*
 * HMG - Harbour Win32 GUI library
 * 
 * MiniSql (a Simple MySql Access Layer)
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
*/

*------------------------------------------------------------------------------*
Function SqlDoQuery( nHandle , cQuery )
*------------------------------------------------------------------------------*
Local nNumRows
Local nNumFields
Local nQueryResultHandle
Local aQuery := {}
Local aRow := {}
Local i

	if __mvexist ('SqlTrace')
		If SqlTrace
			MsgInfo (cQuery)
		EndIf
	endif

	SqlQuery ( nHandle , cQuery ) ; SqlErrorCheck ( nHandle )

	nQueryResultHandle := sqlStoreR( nHandle ) ; SqlErrorCheck ( nHandle )

	nNumRows := sqlNRows( nQueryResultHandle ) ; SqlErrorCheck ( nHandle )
	nNumFields := sqlNumFi( nQueryResultHandle ) ; SqlErrorCheck ( nHandle )

	For i := 1 To nNumRows

		aRow := sqlFetchR(nQueryResultHandle) ; SqlErrorCheck ( nHandle )

		aadd ( aQuery , aRow )

	Next i

Return aQuery

*------------------------------------------------------------------------------*
Function SqlDoCommand ( nHandle , cQuery )
*------------------------------------------------------------------------------*
Local ar

	if __mvexist ('SqlTrace')
		If SqlTrace
			msginfo(cQuery)
		EndIf
	endif

	SqlQuery ( nHandle , cQuery ) ; SqlErrorCheck ( nHandle )

	ar := SqlAffRows(nHandle)  ; SqlErrorCheck ( nHandle )

Return ar

*------------------------------------------------------------------------------*
Procedure SqlErrorCheck ( nHandle )
*------------------------------------------------------------------------------*
Local SqlCurrentError

	SqlCurrentError := SqlGetErr ( nHandle )

	If .Not. Empty ( SqlCurrentError )

		SqlQuery ( nHandle , 'UNLOCK TABLES' )
		nHandle := NIL

		MsgStop ( SqlCurrentError , "MiniSql" )		

	EndIf

Return

#ifndef __XHARBOUR__

#pragma BEGINDUMP

#include "hbapi.h"

HB_FUNC_EXTERN( MYSQL_GET_SERVER_VERSION      ); HB_FUNC( SQLVERSION      ) { HB_FUNC_EXEC( MYSQL_GET_SERVER_VERSION      ); }
HB_FUNC_EXTERN( MYSQL_REAL_CONNECT            ); HB_FUNC( SQLCONNECT      ) { HB_FUNC_EXEC( MYSQL_REAL_CONNECT            ); }
HB_FUNC_EXTERN( MYSQL_COMMIT                  ); HB_FUNC( SQLCOMMIT       ) { HB_FUNC_EXEC( MYSQL_COMMIT                  ); }
HB_FUNC_EXTERN( MYSQL_ROLLBACK                ); HB_FUNC( SQLROLLBACK     ) { HB_FUNC_EXEC( MYSQL_ROLLBACK                ); }
HB_FUNC_EXTERN( MYSQL_SELECT_DB               ); HB_FUNC( SQLSELECTD      ) { HB_FUNC_EXEC( MYSQL_SELECT_DB               ); }
HB_FUNC_EXTERN( MYSQL_QUERY                   ); HB_FUNC( SQLQUERY        ) { HB_FUNC_EXEC( MYSQL_QUERY                   ); }
HB_FUNC_EXTERN( MYSQL_STORE_RESULT            ); HB_FUNC( SQLSTORER       ) { HB_FUNC_EXEC( MYSQL_STORE_RESULT            ); }
HB_FUNC_EXTERN( MYSQL_USE_RESULT              ); HB_FUNC( SQLUSERES       ) { HB_FUNC_EXEC( MYSQL_USE_RESULT              ); }
HB_FUNC_EXTERN( MYSQL_FETCH_ROW               ); HB_FUNC( SQLFETCHR       ) { HB_FUNC_EXEC( MYSQL_FETCH_ROW               ); }
HB_FUNC_EXTERN( MYSQL_DATA_SEEK               ); HB_FUNC( SQLDATAS        ) { HB_FUNC_EXEC( MYSQL_DATA_SEEK               ); }
HB_FUNC_EXTERN( MYSQL_NUM_ROWS                ); HB_FUNC( SQLNROWS        ) { HB_FUNC_EXEC( MYSQL_NUM_ROWS                ); }
HB_FUNC_EXTERN( MYSQL_FETCH_FIELD             ); HB_FUNC( SQLFETCHF       ) { HB_FUNC_EXEC( MYSQL_FETCH_FIELD             ); }
HB_FUNC_EXTERN( MYSQL_FIELD_SEEK              ); HB_FUNC( SQLFSEEK        ) { HB_FUNC_EXEC( MYSQL_FIELD_SEEK              ); }
HB_FUNC_EXTERN( MYSQL_NUM_FIELDS              ); HB_FUNC( SQLNUMFI        ) { HB_FUNC_EXEC( MYSQL_NUM_FIELDS              ); }
HB_FUNC_EXTERN( MYSQL_FIELD_COUNT             ); HB_FUNC( SQLFICOU        ) { HB_FUNC_EXEC( MYSQL_FIELD_COUNT             ); }
HB_FUNC_EXTERN( MYSQL_LIST_FIELDS             ); HB_FUNC( SQLLISTF        ) { HB_FUNC_EXEC( MYSQL_LIST_FIELDS             ); }
HB_FUNC_EXTERN( MYSQL_ERROR                   ); HB_FUNC( SQLGETERR       ) { HB_FUNC_EXEC( MYSQL_ERROR                   ); }
HB_FUNC_EXTERN( MYSQL_LIST_DBS                ); HB_FUNC( SQLLISTDB       ) { HB_FUNC_EXEC( MYSQL_LIST_DBS                ); }
HB_FUNC_EXTERN( MYSQL_LIST_TABLES             ); HB_FUNC( SQLLISTTBL      ) { HB_FUNC_EXEC( MYSQL_LIST_TABLES             ); }
HB_FUNC_EXTERN( MYSQL_AFFECTED_ROWS           ); HB_FUNC( SQLAFFROWS      ) { HB_FUNC_EXEC( MYSQL_AFFECTED_ROWS           ); }
HB_FUNC_EXTERN( MYSQL_GET_HOST_INFO           ); HB_FUNC( SQLHOSTINFO     ) { HB_FUNC_EXEC( MYSQL_GET_HOST_INFO           ); }
HB_FUNC_EXTERN( MYSQL_GET_SERVER_INFO         ); HB_FUNC( SQLSRVINFO      ) { HB_FUNC_EXEC( MYSQL_GET_SERVER_INFO         ); }
HB_FUNC_EXTERN( MYSQL_ESCAPE_STRING           ); HB_FUNC( DATATOSQL       ) { HB_FUNC_EXEC( MYSQL_ESCAPE_STRING           ); }
HB_FUNC_EXTERN( MYSQL_ESCAPE_STRING_FROM_FILE ); HB_FUNC( FILETOSQLBINARY ) { HB_FUNC_EXEC( MYSQL_ESCAPE_STRING_FROM_FILE ); }

#pragma ENDDUMP

#endif
