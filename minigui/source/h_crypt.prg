/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2016, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

/*
   File:  MyCrypt.prg
   Author:  Grigory Filatov
   Description: Crypto Library for MiniGUI
   Status:  Public Domain
   Notes:  This is very simple crypt algorithm based on XOR encryption.
*/

#define MSGALERT( c ) MsgEXCLAMATION( c, "Attention" )
#define MSGSTOP( c ) MsgStop( c, "Stop!" )
/*
*/
FUNCTION _ENCRYPT( cStr, cPass )

   LOCAL cXorStr := CHARXOR( cStr, "<ORIGINAL>" )

   IF !Empty( cPass )

      cXorStr := CHARXOR( cXorStr, cPass )

   ENDIF

RETURN cXorStr

FUNCTION _DECRYPT( cStr, cPass )

   LOCAL cXorStr := CHARXOR( cStr, cPass )

RETURN CHARXOR( cXorStr, "<ORIGINAL>" )

/*
*/
FUNCTION FI_CODE( cInFile, cPass, cOutFile, lDelete )

   LOCAL nHandle, cBuffer, cStr, nRead := 1
   LOCAL nOutHandle

   IF Empty( cInFile ) .OR. .NOT. File( cInFile )

      MSGSTOP( "No such file" )
      RETURN NIL

   ENDIF

   IF AllTrim( Upper( cInFile ) ) == AllTrim( Upper( cOutFile ) )

      MSGALERT( "New and old filenames must not be the same" )
      RETURN NIL

   ENDIF

   IF cPass == NIL

      cPass := "<PRIMARY>"

   ENDIF

   IF lDelete == NIL

      lDelete := .F.

   ENDIF

   IF Len( cPass ) > 10

      cPass := SubStr( cPass, 1, 10 )

   ELSE

      cPass := PadR( cPass, 10 )

   ENDIF

   nHandle := FOpen( cInFile, 2 )

   IF FError() <> 0

      MSGSTOP( "File I/O error, cannot proceed" )

   ENDIF

   cBuffer := Space( 30 )
   FRead( nHandle, @cBuffer, 30 )

   IF cBuffer == "ENCRYPTED FILE (C) ODESSA 2002"

      MSGSTOP( "File already encrypted" )
      FClose( nHandle )
      RETURN NIL

   ENDIF

   FSeek( nHandle, 0 )
   nOutHandle := FCreate( cOutFile, 0 )

   IF FError() <> 0

      MSGSTOP( "File I/O error, cannot proceed" )
      FClose( nHandle )
      RETURN NIL

   ENDIF

   FWrite( nOutHandle, "ENCRYPTED FILE (C) ODESSA 2002" )
   cStr := _ENCRYPT( cPass )
   FWrite( nOutHandle, cStr )
   cBuffer := Space( 512 )

   DO WHILE nRead <> 0

      nRead := FRead( nHandle, @cBuffer, 512 )

      IF nRead <> 512

         cBuffer := SubStr( cBuffer, 1, nRead )

      ENDIF

      cStr := _ENCRYPT( cBuffer, cPass )
      FWrite( nOutHandle, cStr )

   ENDDO

   FClose( nHandle )
   FClose( nOutHandle )

   IF lDelete

      FErase( cInFile )

   ENDIF

RETURN NIL

/*
*/
FUNCTION FI_DECODE( cInFile, cPass, cOutFile, lDelete )

   LOCAL nHandle, cBuffer, cStr, nRead := 1
   LOCAL nOutHandle

   IF Empty( cInFile ) .OR. .NOT. File( cInFile )

      MSGSTOP( "No such file" )
      RETURN NIL

   ENDIF

   IF AllTrim( Upper( cInFile ) ) == AllTrim( Upper( cOutFile ) )

      MSGALERT( "New and old filenames must not be the same" )
      RETURN NIL

   ENDIF

   IF cPass == NIL

      cPass := "<PRIMARY>"

   ENDIF

   IF lDelete == NIL

      lDelete := .F.

   ENDIF

   IF Len( cPass ) > 10

      cPass := SubStr( cPass, 1, 10 )

   ELSE

      cPass := PadR( cPass, 10 )

   ENDIF

   nHandle := FOpen( cInFile, 2 )

   IF FError() <> 0

      MSGSTOP( "File I/O error, cannot proceed" )

   ENDIF

   cBuffer := Space( 30 )
   FRead( nHandle, @cBuffer, 30 )

   IF cBuffer <> "ENCRYPTED FILE (C) ODESSA 2002"

      MSGSTOP( "File is not encrypted" )
      FClose( nHandle )
      RETURN NIL

   ENDIF

   cBuffer := Space( 10 )
   FRead( nHandle, @cBuffer, 10 )

   IF cBuffer <> _ENCRYPT( cPass )

      MSGALERT( "You have entered the wrong password" )
      FClose( nHandle )
      RETURN NIL

   ENDIF

   nOutHandle := FCreate( cOutFile, 0 )

   IF FError() <> 0

      MSGSTOP( "File I/O error, cannot proceed" )
      FClose( nHandle )
      RETURN NIL

   ENDIF

   cBuffer := Space( 512 )

   DO WHILE nRead <> 0

      nRead := FRead( nHandle, @cBuffer, 512 )

      IF nRead <> 512

         cBuffer := SubStr( cBuffer, 1, nRead )

      ENDIF

      cStr := _DECRYPT( cBuffer, cPass )
      FWrite( nOutHandle, cStr )

   ENDDO

   FClose( nHandle )
   FClose( nOutHandle )

   IF lDelete

      FErase( cInFile )

   ENDIF

RETURN NIL

/*
*/
FUNCTION DB_ENCRYPT( cFile, cPass )

   LOCAL nHandle, cBuffer := Space( 4 ), cFlag := Space( 3 )

   IF cPass == NIL

      cPass := "<PRIMARY>"

   ENDIF

   IF cFile == NIL

      cFile := "TEMP.DBF"

   ENDIF

   IF Len( cPass ) > 10

      cPass := SubStr( cPass, 1, 10 )

   ELSE

      cPass := PadR( cPass, 10 )

   ENDIF

   IF At( ".", cFileName( cFile ) ) == 0

      cFile := cFile + ".DBF"

   ENDIF

   IF File( cFile )

      nHandle := FOpen( cFile, 2 )

      IF FError() <> 0

         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 28 )

      IF FError() <> 0

         MSGSTOP( "File I/O error, cannot encrypt file" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      IF FRead( nHandle, @cFlag, 3 ) <> 3

         MSGSTOP( "File I/O error, cannot encrypt file" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      IF cFlag == "ENC"

         MSGSTOP( "This database already encrypted!" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 8 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      IF FRead( nHandle, @cBuffer, 4 ) <> 4

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      cBuffer := _ENCRYPT( cBuffer, cPass )
      FSeek( nHandle, 8 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      IF FWrite( nHandle, cBuffer ) <> 4

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 12 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      cBuffer := _ENCRYPT( cPass )

      IF FWrite( nHandle, cBuffer ) <> Len( cPass )

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 28 )

      IF FWrite( nHandle, "ENC" ) <> 3

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot encrypt file" )
         RETURN NIL

      ENDIF

      FClose( nHandle )

   ELSE

      MSGSTOP( "No such file" )

   ENDIF

RETURN NIL

/*
*/
FUNCTION DB_UNENCRYPT( cFile, cPass )

   LOCAL nHandle, cBuffer := Space( 4 ), cSavePass := Space( 10 ), cFlag := Space( 3 )

   IF cPass == NIL

      cPass := "<PRIMARY>"

   ENDIF

   IF cFile == NIL

      cFile := "TEMP.DBF"

   ENDIF

   IF Len( cPass ) > 10

      cPass := SubStr( cPass, 1, 10 )

   ELSE

      cPass := PadR( cPass, 10 )

   ENDIF

   IF At( ".", cFile ) == 0

      cFile := cFile + ".DBF"

   ENDIF

   IF File( cFile )

      nHandle := FOpen( cFile, 2 )

      IF FError() <> 0

         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 28 )

      IF FError() <> 0

         MSGSTOP( "File I/O error, cannot unencrypt file" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      IF FRead( nHandle, @cFlag, 3 ) <> 3

         MSGSTOP( "File I/O error, cannot unencrypt file" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      IF cFlag <> "ENC"

         MSGSTOP( "This database is not encrypted!" )
         FClose( nHandle )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 12 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      cBuffer := _ENCRYPT( cPass )

      IF FRead( nHandle, @cSavePass, 10 ) <> Len( cPass )

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      IF cBuffer <> cSavePass

         FClose( nHandle )
         MSGALERT( "You have entered the wrong password" )
         RETURN NIL

      ENDIF

      cBuffer := Space( 4 )
      FSeek( nHandle, 8 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      IF FRead( nHandle, @cBuffer, 4 ) <> 4

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      cBuffer := _DECRYPT( cBuffer, cPass )
      FSeek( nHandle, 8 )

      IF FError() <> 0

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      IF FWrite( nHandle, cBuffer ) <> 4

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      FSeek( nHandle, 12 )

      IF FWrite( nHandle, Replicate( Chr(0 ), 20 ) ) <> 20

         FClose( nHandle )
         MSGSTOP( "File I/O error, cannot unencrypt file" )
         RETURN NIL

      ENDIF

      FClose( nHandle )

   ELSE

      MSGSTOP( "No such file" )

   ENDIF

RETURN NIL

/*
*/
STATIC FUNCTION cFileName( cMask )

   LOCAL cName := AllTrim( cMask )
   LOCAL n     := At( ".", cName )

RETURN AllTrim( iif( n > 0, Left( cName, n - 1 ), cName ) )

/*
*/
FUNCTION DB_CODE( cData, cKey, aFields, cPass, cFor, cWhile )

   LOCAL cTmpFile := "__temp__.dbf", nRecno := RecNo(), cVal, cBuf
   LOCAL aString[ Len(aFields) ] , nFields , cSeek , i , cAlias , cTmpAlias // RL

   cData := iif( cData == NIL, Alias() + ".DBF", cData )
   cData := iif( At( ".",cData ) == 0, cData + ".DBF", cData )
   cWhile := iif( cWhile == NIL, ".T.", cWhile )
   cFor := iif( cFor == NIL, ".T.", cFor )
   cSeek := cKey

   IF cPass == NIL

      cPass := "<PRIMARY>"

   ENDIF

   COPY STRU TO &(cTmpFile)
   cAlias := Alias()
   nFields := FCount()

   USE ( cTmpFile ) NEW Exclusive
   cTmpAlias := Alias()

   Select &cAlias
   DO WHILE .NOT. EOF() .AND. &( cWhile )
      IF !&( cFor )                          // Select records that meet for condition
         SKIP
         LOOP
      ENDIF

      SELECT &cTmpAlias
      dbAppend()                           // Create record at target file

      FOR i := 1 TO nFields
         FieldPut( i, &cAlias->( FieldGet( i ) ) )
      NEXT

      SELECT &cAlias
      AFill( aString, '' )

      cBuf := &cSeek
      cVal := cBuf
      DO WHILE cBuf = cVal .AND. !EOF()    // Evaluate records with same key
         IF !&( cFor )                       // Evaluate For condition within
            SKIP
            LOOP
         ENDIF

         FOR i := 1 TO Len( aString )      // Crypt values
            aString[i] := _ENCRYPT( FieldGet( FieldPos( aFields[i] ) ), cPass )
         NEXT

         SKIP                              // Evaluate condition in next record
         cVal := &cSeek
      ENDDO

      SELECT &cTmpAlias
      FOR i := 1 TO Len( aString )         // Place Crypts in target file
         FieldPut( FieldPos( aFields[i] ), aString[i] )
      NEXT

      SELECT &cAlias
   ENDDO

   SELECT &cTmpAlias
   GO TOP
   DO WHILE .NOT. EOF()
      cVal := &cSeek
      SELECT &cAlias
      SEEK cVal
      RLock()
      FOR i := 1 TO nFields
         FieldPut( i, &cTmpAlias->( FieldGet( i ) ) )
      NEXT
      dbUnlock()
      SELECT &cTmpAlias
      SKIP
   ENDDO
   USE                                     // Close target file
   FErase( cTmpFile )
   SELECT &cAlias                          // Select prior file
   GO nRecno

RETURN NIL
