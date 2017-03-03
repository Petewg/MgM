#include <hmg.ch>

*----------------------------------------------------------------------------*
FUNCTION Query_001( cQueryString )
*----------------------------------------------------------------------------*
LOCAL aRecordSet := {} , cIndex

	cQueryString := UPPER( ALLTRIM ( cQueryString ) )

	cIndex := TempFile ( , 'ntx' )

	USE TEST SHARED

		INDEX ON TEST->LAST TO (cIndex) FOR UPPER( ALLTRIM ( TEST->LAST ) ) = cQueryString .AND. ( .NOT. DELETED() )

		GO TOP

		DO WHILE .NOT. EOF()

			AADD( aRecordSet , ;
				{ STR(RECNO()) , TEST->LAST , TEST->FIRST , TEST->STREET , TEST->CITY , TEST->STATE , TEST->ZIP , ;
				DTOC(TEST->HIREDATE) , IF(TEST->MARRIED,'.T.','.F.') , STR(TEST->AGE) , STR(TEST->SALARY) } )

			SKIP

		ENDDO

	USE

	DELETE FILE (cIndex)

RETURN aRecordSet

*----------------------------------------------------------------------------*
FUNCTION Query_002(nRecNo)
*----------------------------------------------------------------------------*
LOCAL lResult

	USE TEST SHARED

		DBGOTO(nRecNo)

		IF .NOT. DELETED()

			DO WHILE .NOT. RLOCK() ; ENDDO

			DBDELETE()

			UNLOCK

			lResult := .T.

		ELSE

			lResult := .F.

		ENDIF

	USE

RETURN lResult

*----------------------------------------------------------------------------*
FUNCTION Query_003(aValues)
*----------------------------------------------------------------------------*
LOCAL I

	USE TEST SHARED

		APPEND BLANK

		FOR I := 1 TO LEN(aValues)

			FIELDPUT( I , aValues[I] )

		NEXT I

	USE

RETURN NIL

*----------------------------------------------------------------------------*
FUNCTION Query_004(nRecNo,aValues)
*----------------------------------------------------------------------------*
LOCAL I

	USE TEST SHARED

		DBGOTO(nRecNo)		

		DO WHILE .NOT. RLOCK() ; ENDDO

		FOR I := 1 TO LEN(aValues)

			FIELDPUT( I , aValues[I] )

		NEXT I

		UNLOCK

	USE

RETURN NIL
