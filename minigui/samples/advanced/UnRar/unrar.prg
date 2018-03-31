/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Last revision : 2007.12.06
 *
*/

#include "common.ch"
#include "unrar.ch"

FUNCTION Hb_RarGetFilesList( ArchiveName, cPassWord, lFileTimeAsDate, lIncludeTime, lIncludeSeconds )
   LOCAL aResult

   DEFAULT lFileTimeAsDate TO FALSE
   DEFAULT lIncludeTime    TO TRUE
   DEFAULT lIncludeSeconds TO FALSE

   IF File( ArchiveName )
      aResult := Hb_RGetFilesList( ArchiveName, cPassWord, lFileTimeAsDate, lIncludeTime, lIncludeSeconds )
   ENDIF

RETURN iif( ValType( aResult ) == "A", aResult, {} )

/*
*/
FUNCTION Hb_UnrarFiles( ArchiveName, cPassWord, cPath, File )
RETURN Hb_ProcessFile( ArchiveName, cPassWord, cPath, File, RAR_EXTRACT )

/*
*/
FUNCTION Hb_RarTestFiles( ArchiveName, cPassWord, File )
RETURN Hb_ProcessFile( ArchiveName, cPassWord, , File, RAR_TEST )

   /*
*/
STATIC FUNCTION Hb_ProcessFile( ArchiveName, cPassWord, cPath, File, Operation )
   LOCAL lSuccess := .F.
   LOCAL sw, sw1, i, j
   LOCAL aFileList := {}, aFile := {}

   IF File( ArchiveName )
      IF ( HB_ISNIL( File ) )		
         lSuccess := Hb_RProcessFiles( Operation, ArchiveName, cPassWord, cPath )	
      ELSE
         aFileList := Hb_RGetFileNamesList( ArchiveName, cPassWord )

         sw := ValType( File )
         SWITCH sw
      CASE "N"
         IF ( File >= 1 .AND. File <= Len( aFileList ) )
            AAdd( aFile, aFileList[ File ] )
         ENDIF
         EXIT
      CASE "C"
         IF ( AScan( aFileList, {|e| e == File  } ) > 0  )
            AAdd( aFile, File )
         ENDIF
         EXIT
      CASE "A"
         FOR i := 1 TO Len( File )

            sw1 := ValType( File[i] )
            SWITCH sw1
         CASE "N"
            IF ( File[i] >= 1 .AND. File[i] <= Len( aFileList ) )
               AAdd( aFile, aFileList[ File[ i ] ] )
            ENDIF
            EXIT
         CASE "C"
            j := AScan( aFileList, {|e| e == File[i] } )
            IF ( j > 0 )
               AAdd( aFile, aFileList[ j ] )
            ENDIF
            EXIT
            END SWITCH
         NEXT

         END SWITCH		

         IF .NOT. Empty ( aFile )
            lSuccess := Hb_RProcessFiles( Operation, ArchiveName, cPassWord, cPath, aFile )	
         ENDIF
      ENDIF
   ENDIF

RETURN lSuccess
