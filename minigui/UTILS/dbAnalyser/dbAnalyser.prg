/*****************************
* Source : dbAnalyser.prg
* System : <unkown>
* Author : Phil Ide
* Created: 18/02/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    18/02/2004 11:18 PPI - Created
*****************************/

#include "Common.ch"
#include "dbanalyser.ch"

SET PROCEDURE TO dbanUtils

ANNOUNCE RDDSYS

STATIC FUNCTION Help( nMsg )
   ?
   IF nMsg == HELP_MSG_FILE_NOT_FOUND
      ? 'File not found'
      ?
   ENDIF
   ? 'Usage: ' + cFileNoExt( ExeName() ) + ' <DbfFile>'
   ? '(extension is required)'
   ?

   RETURN ( Nil )

STATIC FUNCTION Copyright()
   cls
   ?? Lower( cFileNoExt( ExeName() ) ) + ' v' + dbaVer()
   ? '(c) Phil Ide 2004, All Rights Reserved'
   ?

   RETURN ( Nil )

STATIC FUNCTION cFileNoExt( cPathMask )

   LOCAL cName

   hb_FNameSplit( cPathMask, , @cName )

   RETURN cName

STATIC FUNCTION Analyse( cDBF )

   LOCAL nH := FOpen( cDBF )
   LOCAL lOk := TRUE

   FHandle( nH )

   IF nH > 0 .AND. idByte()
      LastUpdated()
      NumRecsReported()
      ReportHeaderSize()
      ReportRecordSize()
      IsEncrypted()
      RecordDetails()
   ELSE
      ? 'Error opening file'
      lOk := FALSE
   ENDIF
   IF FHandle() > 0
      FClose( nH )
   ENDIF

   RETURN lOk

FUNCTION FHandle( n )

   STATIC nH
   DEFAULT nH TO 0
   IF PCount() > 0 .AND. n > 0
      nH := n
   ELSEIF PCount() > 0 .AND. n < -199
      nH := 0
   ENDIF

   RETURN nH

FUNCTION dbaVer()
   RETURN LTrim( Str( VERSION_MAJOR ) ) + '.' + LTrim( Str( VERSION_MINOR ) ) + '.' + LTrim( Str( VERSION_BUILD ) )


PROCEDURE Main( cDBF )
   SET EPOCH TO 1980
   SET DATE ANSI
   Copyright()
   IF PCount() == 1
      IF hb_FileExists( cDBF )
         IF Analyse( cDBF )
            cls
         ENDIF
         ?
      ELSE
         Help( HELP_MSG_FILE_NOT_FOUND )
      ENDIF
   ELSE
      Help( HELP_MSG_NO_PARAMETERS )
   ENDIF

   RETURN
