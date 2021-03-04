/* NetWork Functions */

#include "dbinfo.ch"
#include "error.ch"

STATIC s_nNetDelay   := 1
STATIC s_lNetOk      := .F.

#define NET_RECLOCK  1
#define NET_FILELOCK 2
#define NET_APPEND   3 

STATIC FUNCTION NetLock( nType, lReleaseLocks, nSeconds )

   LOCAL lSuccess    := .F.
   LOCAL bOperation
   LOCAL xIdentifier

   __defaultNIL( @lReleaseLocks, .F. )
   __defaultNIL( @nSeconds, s_nNetDelay )

   SWITCH nType
   CASE NET_RECLOCK                        // 1 = Record Lock...
      xIdentifier := iif( lReleaseLocks, NIL, RecNo() )
      bOperation  := {| x | dbRLock( x ) }
      EXIT
   CASE NET_FILELOCK                       // 2 = File Lock...
      bOperation := {|| FLock() }
      EXIT
   CASE NET_APPEND                         // 3 = Append Blank...
      xIdentifier := lReleaseLocks
      bOperation  := {| x | dbAppend( x ), ! NetErr() }
      EXIT
   ENDSWITCH

   s_lNetOk := .F.

   WHILE nSeconds > 0

      IF Eval( bOperation, xIdentifier )
         lSuccess  := .T.
         s_lNetOk  := .T.
         EXIT
      ELSE
         Inkey( .25 )
         nSeconds -= .25
      ENDIF

   ENDDO

   RETURN lSuccess


FUNCTION NetDelete()

   s_lNetOk := .F.

   IF NetLock( NET_RECLOCK )
      dbDelete()
      s_lNetOk := .T.
   ENDIF

   IF ! NetErr()
      dbSkip( 0 )
      dbCommit()
   ELSE
      s_lNetOk := .F.
      HMG_Alert( " Failed to DELETE Record -> " + hb_ntos( RecNo() ) )
   ENDIF

   RETURN s_lNetOk


FUNCTION NetRecall()

   s_lNetOk := .F.

   IF NetLock( NET_RECLOCK )
      dbRecall()
      s_lNetOk := .T.
   ENDIF

   IF ! NetErr()
      dbSkip( 0 )
      dbCommit()
   ELSE
      s_lNetOk := .F.
      HMG_Alert( " Failed to RECALL Record -> " + hb_ntos( RecNo() ) )
   ENDIF

   RETURN s_lNetOk


FUNCTION NetRecLock( nSeconds )

   __defaultNIL( @nSeconds, s_nNetDelay )

   s_lNetOk := .F.

   IF NetLock( NET_RECLOCK, , nSeconds )    // 1
      s_lNetOk := .T.
   ENDIF

   RETURN s_lNetOk


FUNCTION NetFileLock( nSeconds )

   __defaultNIL( @nSeconds, s_nNetDelay )

   s_lNetOk := .F.

   IF NetLock( NET_FILELOCK, , nSeconds )
      s_lNetOk := .T.
   ENDIF

   RETURN s_lNetOk


FUNCTION NetAppend( nSeconds, lReleaseLocks )

   LOCAL nOrd

   __defaultNIL( @lReleaseLocks, .T. )
   __defaultNIL( @nSeconds, s_nNetDelay )

   s_lNetOk := .F.

   nOrd := ordSetFocus( 0 )          // set order to 0 to append

   IF NetLock( NET_APPEND, lReleaseLocks, nSeconds )
      s_lNetOk := .T.
   ENDIF

   ordSetFocus( nOrd )

   RETURN s_lNetOk


FUNCTION IsLocked( nRecId )

   __defaultNIL( @nRecID, RecNo() )

   RETURN AScan( dbRLockList(), {| n | n == nRecID } ) > 0


FUNCTION NetError()

   RETURN ! s_lNetOk


FUNCTION SetNetDelay( nSecs )

   LOCAL nTemp := s_nNetDelay

   IF nSecs != NIL
      s_nNetDelay := nSecs
   ENDIF

   RETURN nTemp
