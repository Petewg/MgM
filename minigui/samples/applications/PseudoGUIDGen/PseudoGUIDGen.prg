/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Based on:
 * Password Generator by Grigory Filatov <gfilatov@inbox.ru>
 *
 * Author: Christian T. Kurowski <xharbour@wp.pl>
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include <minigui.ch>

STATIC cIniFile
*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
  LOCAL cDefCharSet := "QWER456TYUIOPAS123DFGHJKLZ7890XCVBNM"
  LOCAL nGUID := 40, cCharSet := cDefCharSet

  cIniFile := GetStartupFolder() + '\pseudoguidgen.ini'

  IF FILE(cIniFile)
     BEGIN INI FILE cIniFile
        GET nGUID SECTION "SETTINGS" ENTRY "Length" DEFAULT nGUID
        GET cCharSet  SECTION "SETTINGS" ENTRY "CharSet" DEFAULT cDefCharSet
     END INI
  ELSE
     SaveIni(nGUID, cDefCharSet)
  ENDIF

  LOAD WINDOW main

  CENTER WINDOW main

  ACTIVATE WINDOW main

RETURN

*--------------------------------------------------------*
FUNCTION GUID_Random(GUID_Len, cSet)
*--------------------------------------------------------*

  LOCAL cGUID := ""
  LOCAL i
  LOCAL nGUID_Len
  LOCAL cRand

  nGUID_Len := GUID_Len         

  DO WHILE ( nGUID_Len % 5 ) != 0
    nGUID_Len++
  ENDDO

  FOR i := 1 TO nGUID_Len-1

    IF ( i%5 == 0 )

      cGUID := cGUID + "-"

    ELSE

      cRand := SubStr( cSet, hb_RandomInt( Len(cSet) ), 1 )
      cGUID += cRand

    ENDIF

  NEXT i

  main.text_12.value := cGUID

RETURN cGUID

*--------------------------------------------------------*
PROCEDURE SaveIni(nLen, cSet)
*--------------------------------------------------------*
  BEGIN INI FILE cIniFile
	SET SECTION "SETTINGS" ENTRY "Length" TO nLen
	SET SECTION "SETTINGS" ENTRY "CharSet" TO cSet
  END INI

RETURN


#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )
*--------------------------------------------------------*
FUNCTION MsgAbout()
*--------------------------------------------------------*
RETURN MsgInfo( PadC('Pseudo GUID Generator - FREEWARE', 46) + CRLF + ;
	"Author: Christian T. Kurowski <xharbour@wp.pl>" + CRLF + CRLF + ;
	PadC("This program is Freeware!", 46) + CRLF + ;
	PadC("Copying is allowed!", 50), 'About' )
