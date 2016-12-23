#include "minigui.ch"
#include "ide.ch"

MEMVAR cNameC
MEMVAR cDate1
MEMVAR cTime1
MEMVAR cPath

DECLARE WINDOW ProjectBrowser

*------------------------------------------------------------*
PROCEDURE Check_Modules( param AS STRING ) // verify .prg ->.c
*------------------------------------------------------------*
   LOCAL x        AS NUMERIC
   LOCAL A1       AS STRING
   LOCAL cName    AS STRING
   LOCAL lCheck   AS LOGICAL
   LOCAL aDir     AS ARRAY
   LOCAL cDate    AS STRING
   LOCAL cTime    AS STRING
   LOCAL cFile    AS STRING
   LOCAL aDir1    AS ARRAY
   LOCAL cFile1   AS STRING
   LOCAL X5       AS STRING
   LOCAL X6       AS NUMERIC
   LOCAL xLin     AS STRING
   LOCAL cNameF   AS STRING
   LOCAL cFileF   AS STRING
   LOCAL nPos     AS NUMERIC
   LOCAL cFile2   AS STRING

   SetCurrentFolder( ProjectFolder )

   IF param == "/C" // do not check if is not incremental

      BuildType := iif( aData[ _BUILDTYPE ] = "1", "full", "not" )

      IF BuildType = "full"

         FOR x := 1 TO ProjectBrowser.xlist_1.ItemCount

             IF x = 1
                cName := AllTrim( ProjectBrowser.xlist_1.Item( x ) )
                cName := SubStr( cName, 1, Len( cName ) - 7 ) // TRIM ' (MAIN)' Token
             ELSE
                cName := AllTrim( ProjectBrowser.xlist_1.Item( x ) )
             ENDIF

             IF Len( AllTrim( aPrgNames[ X, 2 ] ) ) > 0
                cPath := aPrgNames[ X, 2 ]
             ELSE
                cPath := GetCurrentFolder() + "\"
             ENDIF

             IF cPath == "<ProjectFolder>\"
                cPath := ProjectFolder + "\"
             ENDIF

             cFile  := cPath + cName
             cNamec := SubStr( cName, 1, Len( cName ) - 4 )
             x5     := MemoRead( cFile )
             x6     := MLCount( x5, 1000 )

             FOR xLin := 1 TO x6

                DO EVENTS

                A1 := Upper( AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) ) )

                IF SubStr( AllTrim( A1 ), 1, 11 ) = "LOAD WINDOW"

                   cNamef := AllTrim( SubStr( AllTrim( A1 ), 13, Len( A1 ) ) )
                   cFileF := Findfmg( cNamef )

                   IF ! Empty( cFileF ) .AND. File( cFileF )
                      nPos   := RAt( "\", cFileF )
                      cFile2 := SubStr( cFileF, nPos + 1, Len( cFileF ) )

                      SetProperty( "build", "edit_1", "value", GetProperty( "build", "edit_1", "value" ) + Upper( cFile2 ) + " -> " )

                      xDelete()
                   ENDIF

                ENDIF

             NEXT xLIN
         NEXT x
      ENDIF
      RETURN
   ENDIF

   //? Why here
   PRIVATE cNamec AS STRING
   PRIVATE cDate1 AS STRING
   PRIVATE cTime1 AS STRING
   PRIVATE cPath  AS STRING  := GetCurrentFolder()

   FOR x := 1 TO ProjectBrowser.xlist_1.ItemCount

      IF X = 1
         cName := AllTrim( ProjectBrowser.xlist_1.Item( x ) )
         cName := SubStr( cName, 1, Len( cName ) - 7 )
      ELSE
         cName := AllTrim( ProjectBrowser.xlist_1.Item( x ) )
      ENDIF

      IF Len( AllTrim( aPrgNames[ x, 2 ] ) ) > 0
         cPath := aPrgNames[ x, 2 ]
      ELSE
         cPath := GetCurrentFolder() + "\"
      ENDIF

      IF cPath == "<ProjectFolder>\"
         cPath := ProjectFolder + "\"
      ENDIF

      cFile  := cPath + cName
       //MsgBox( "cFile= " + cFile )

      aDir   := Directory( cFile )
      //MSGBOX('LEN= ' + STR(LEN(ADIR)) )
      cDate  := aDir[ 1, 3 ]
      cTime  := aDir[ 1, 4 ]
      cNameC := SubStr( cName, 1, Len( cName ) - 4 )
      cFile1 := cPath + "OBJ\" + cNameC + ".c"
      // MsgBox( "cFile= " + cFile1 )

      IF File( cFile1 )
         aDir1  := Directory( cFile1 )
         cDate1 := aDir1[ 1, 3 ]
         cTime1 := aDir1[ 1, 4 ]
         lCheck := .T.

         IF ( dTos( cDate ) + cTime ) > ( dTos( cDate1 ) + cTime1 )
             // MsgBox( "FIRST-DELETE" )
            xDelete()
            lCheck := .F.  // not necessary checkdeps
         ENDIF

         IF lCheck
            Check_Dependences( cFile )
         ENDIF
      ELSE
        IF BuildType = "full"
           IF IsWindowDefined( BUILD )
              SetProperty( "build", "edit_1", "value", GetProperty( "build","edit_1","value" ) + Upper( cNameC ) + ".PRG" + CRLF )
           ENDIF
        ENDIF
      ENDIF

   NEXT x

RETURN


*------------------------------------------------------------*
PROCEDURE Check_Dependences( x4 AS STRING )  // verify .PRG->.FMG->.c
*------------------------------------------------------------*
   LOCAL x5      AS STRING
   LOCAL x6      AS NUMERIC
   LOCAL xlin    AS STRING
   LOCAL A1      AS STRING
   LOCAL cNamef  AS STRING
   LOCAL cFileF  AS STRING
   LOCAL aDir2   AS ARRAY
   LOCAL cDate2  AS STRING
   LOCAL cTime2  AS STRING
   LOCAL nPos    AS NUMERIC
   LOCAL cFile2  AS STRING

   x5        := MemoRead( x4 )
   x6        := MLCount( x5, 1000 )
   BuildType := iif( aData[ _BUILDTYPE ] = "1", "full", "not" )

   FOR xLin := 1 TO x6

      DO EVENTS

      A1 := Upper( AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) ) )

      IF SubStr( AllTrim( A1 ), 1, 11 ) = "LOAD WINDOW"

         cNameF := AllTrim( SubStr( AllTrim( A1 ), 13, Len( A1 ) ) )
         cFileF := FindFmg( cNamef )

         IF ! Empty( cFileF ) .AND. File( cFileF )

            aDir2  := Directory( cFileF )
            cDate2 := aDir2[ 1, 3 ]
            cTime2 := aDir2[ 1, 4 ]

            IF ( dToS( cDate2 ) + cTime2 ) > ( dToS( cDate1 ) + cTime1 )
               // MsgBox("SECOND-DELETE")
               IF BuildType = "full"
                  nPos   := Rat( "\", CFILEF )
                  cFile2 := SubStr( cFileF, nPos + 1, Len( cFileF ) )
                  IF IsWindowDefined( BUILD )
                     SetProperty( "build", "edit_1", "value", GetProperty( "build","edit_1","value" ) + Upper( cFile2 ) + " -> " + x4 + " -> " )
                  ENDIF
               ENDIF

               xDelete()

               EXIT
            ENDIF
         ENDIF
      ENDIF

   next xLIN

RETURN


*------------------------------------------------------------*
FUNCTION FindFmg( Param AS STRING )
*------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL cRetValue AS STRING  := ""

   FOR x := 1 TO Len( aFmgNames )
       IF Upper( aFmgNames[ x, 1 ] ) = Upper( Param + ".fmg" )
          IF aFmgNames[ x, 2 ] = "<ProjectFolder>\"
             cRetValue := ProjectFolder + "\" + aFmgNames[ x, 1 ]
          ELSE
             cRetValue := aFmgNames[ x, 2 ]   + aFmgNames[ x, 1 ]
          ENDIF
          EXIT
       ENDIF
   NEXT x

RETURN( cRetValue )


*------------------------------------------------------------*
PROCEDURE xDelete()
*------------------------------------------------------------*
   LOCAL cPath1 AS STRING := cPath + iif( Right( cPath, 1 ) != "\", "\", "" )

   DELETE File ( cPath1 + "obj\" + cNameC + ".c" )

   IF BuildType = "full"
      SetProperty( "build", "edit_1", "value", GetProperty( "build", "edit_1", "value" ) + Upper( cNameC ) + ".PRG" + CRLF )
   ENDIF

   DELETE File ( cPath1 + "obj\" + cNameC + ".obj" )

RETURN
