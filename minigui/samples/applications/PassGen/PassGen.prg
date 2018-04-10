/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include <minigui.ch>

STATIC cIniFile
*------------------------------------------------------------------------------*
PROCEDURE Main()
*------------------------------------------------------------------------------*
   LOCAL cDefCharSet := "QqWwEeRr456_TtYyUuIi#OoPpAaSs123-DdFfGgHhJj#KkL_Zz7890XxC-cVvBbNnMm"
   LOCAL nPassword := 10, cCharSet := cDefCharSet

   cIniFile := GetStartupFolder() + '\passgen.ini'

   IF File( cIniFile )

      BEGIN INI FILE cIniFile

         GET nPassword SECTION "SETTINGS" ENTRY "Length" DEFAULT nPassword
         GET cCharSet SECTION "SETTINGS" ENTRY "CharSet" DEFAULT cDefCharSet

      END INI

   ELSE

      SaveIni( nPassword, cDefCharSet )

   ENDIF

   LOAD WINDOW main

   CENTER WINDOW main

   ACTIVATE WINDOW main

RETURN

*------------------------------------------------------------------------------*
PROCEDURE GenPass( nLen, cSet )
*------------------------------------------------------------------------------*
   LOCAL nCnt := Len( cSet ), cPass := "", i, cLet

   FOR i := 1 TO nLen

      cLet := SubStr( cSet, Random( nCnt ), 1 )
      cPass += cLet

   NEXT

   main.text_12.value := cPass

RETURN

*------------------------------------------------------------------------------*
PROCEDURE SaveIni( nLen, cSet )
*------------------------------------------------------------------------------*

   BEGIN INI FILE cIniFile

      SET SECTION "SETTINGS" ENTRY "Length" TO nLen
      SET SECTION "SETTINGS" ENTRY "CharSet" TO cSet

   END INI

RETURN

#define MsgInfo( c, t ) MsgInfo( c, t, , .F. )
*------------------------------------------------------------------------------*
FUNCTION MsgAbout()
*------------------------------------------------------------------------------*

RETURN MsgInfo( PadC( 'Password Generator - FREEWARE', 40 ) + CRLF + ;
      "Copyright " + Chr( 169 ) + " 2003-2006 Grigory Filatov" + CRLF + CRLF + ;
      PadC( "eMail: gfilatov@inbox.ru", 40 ) + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 40 ) + CRLF + ;
      PadC( "Copying is allowed!", 42 ), 'About' )
