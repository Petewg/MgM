/*
 * HMG - Harbour Win32 GUI library Demo
 *
*/

#include "hmg.ch"

FUNCTION Main()

   DEFINE WINDOW Win1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 300 ;
      TITLE 'Simple HMG AES File Encryption Demo' ;
      MAIN

   DEFINE BUTTON SourceBtn
      ROW 10
      COL 100
      WIDTH 200
      CAPTION 'Select the source file'
      ACTION SelectSourceFile()
   END BUTTON
   DEFINE LABEL SourceFile
      ROW 40
      COL 10
      WIDTH 380
      FONTBOLD .T.
   END LABEL
   DEFINE BUTTON DestBtn
      ROW 70
      COL 100
      WIDTH 200
      CAPTION 'Select the Destination file'
      ACTION SelectDestFile()
   END BUTTON
   DEFINE LABEL DestFile
      ROW 100
      COL 10
      WIDTH 380
      FONTBOLD .T.
   END LABEL
   DEFINE LABEL PassLabel
      ROW 130
      COL 10
      WIDTH 100
      VALUE 'Enter Password'
   END LABEL
   DEFINE TEXTBOX Password
      ROW 130
      COL 110
      WIDTH 200
      PASSWORD .T.
   END TEXTBOX
   DEFINE BUTTON Encrypt
      ROW 170
      COL 110
      WIDTH 80
      CAPTION 'Encrypt'
      ACTION EncryptAES()
   END BUTTON
   DEFINE BUTTON Decrypt
      ROW 170
      COL 210
      WIDTH 80
      CAPTION 'Decrypt'
      ACTION DecryptAES()
   END BUTTON

   END WINDOW

   Center Window Win1
   Activate Window Win1

RETURN NIL


FUNCTION SelectSourceFile()

   Win1.SourceFile.VALUE := GetFile( { { "All Files", "*.*" } }, "Select the source file", , .F., .F. )

RETURN NIL


FUNCTION SelectDestFile()

   Win1.DestFile.VALUE := PutFile( { { "All Files", "*.*" } }, "Select the source file", , .F., .F. )

RETURN NIL


FUNCTION EncryptAES

   LOCAL lOk

   WAIT WINDOW 'Please Wait ...' NOWAIT
   lOk := EncryptFileAES( Win1.SourceFile.VALUE, Win1.DestFile.VALUE, Win1.Password.VALUE )
   WAIT CLEAR
   IF lOk
      MsgInfo( 'Destination File Successfully Created!' )
   ENDIF

RETURN NIL


FUNCTION DecryptAES

   LOCAL lOk

   WAIT WINDOW 'Please Wait ...' NOWAIT
   lOk := DecryptFileAES( Win1.SourceFile.VALUE, Win1.DestFile.VALUE, Win1.Password.VALUE )
   WAIT CLEAR
   IF lOk
      MsgInfo( 'Destination File Successfully Created!' )
   ENDIF

RETURN NIL
