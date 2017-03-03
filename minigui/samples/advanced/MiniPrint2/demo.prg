#include "hmg.ch"

MEMVAR aColor

*------------------------------------------------------------------------------*
FUNCTION Main()
*------------------------------------------------------------------------------*

   // AVAILABLE LIBRARY INTERFACE LANGUAGES

   // SET LANGUAGE TO ENGLISH (DEFAULT)
   // SET LANGUAGE TO SPANISH
   // SET LANGUAGE TO PORTUGUESE
   // SET LANGUAGE TO ITALIAN
   // SET LANGUAGE TO GERMAN
   // SET LANGUAGE TO FRENCH

   PRIVATE aColor[ 10 ]

   aColor[ 1 ]  := YELLOW
   aColor[ 2 ]  := PINK
   aColor[ 3 ]  := RED
   aColor[ 4 ]  := FUCHSIA
   aColor[ 5 ]  := BROWN
   aColor[ 6 ]  := ORANGE
   aColor[ 7 ]  := GREEN
   aColor[ 8 ]  := PURPLE
   aColor[ 9 ]  := BLACK
   aColor[ 10 ] := BLUE

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'MiniPrint Test' ;
      MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Default Printer' ACTION PrintTest1()
            MENUITEM 'User Selected Printer' ACTION PrintTest2()
            MENUITEM 'User Selected Printer And Settings' ACTION PrintTest3()
            MENUITEM 'User Selected Printer And Settings (Preview)' ACTION PrintTest4()
         END POPUP
      END MENU

   END WINDOW

   MAXIMIZE WINDOW Win_1

   ACTIVATE WINDOW Win_1

RETURN NIL
*------------------------------------------------------------------------------*
PROCEDURE PrintTest1()
*------------------------------------------------------------------------------*

   SELECT PRINTER DEFAULT ;
      ORIENTATION PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE PRINTER_PAPER_LETTER ;
      QUALITY  PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo( 'Print Finished' )

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest2()
*------------------------------------------------------------------------------*
   LOCAL cPrinter

   cPrinter := GetPrinter()

   IF Empty ( cPrinter )
      RETURN
   ENDIF

   SELECT PRINTER cPrinter ;
      ORIENTATION PRINTER_ORIENT_PORTRAIT ;
      PAPERSIZE PRINTER_PAPER_LETTER ;
      QUALITY  PRINTER_RES_MEDIUM

   PrintDoc()

   MsgInfo( 'Print Finished' )

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest3()
*------------------------------------------------------------------------------*
   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo( 'Print Finished' )
   ENDIF

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintTest4()
*------------------------------------------------------------------------------*
   LOCAL lSuccess

   SELECT PRINTER DIALOG TO lSuccess PREVIEW

   IF lSuccess == .T.
      PrintDoc()
      MsgInfo( 'Print Finished' )
   ENDIF

RETURN
*------------------------------------------------------------------------------*
PROCEDURE PrintDoc
*------------------------------------------------------------------------------*
   LOCAL i

   // Measure Units Are Millimeters

   START PRINTDOC

   FOR i := 1 TO 10

      START PRINTPAGE

      @ 20, 20 PRINT RECTANGLE ;
         TO 50, 190 ;
         PENWIDTH 0.1

      @ 25, 25 PRINT IMAGE "hmg.bmp" ;
         WIDTH 20 ;
         HEIGHT 20

      @ 30, 85 PRINT "PRINT DEMO" ;
         FONT "Courier New" ;
         SIZE 24 ;
         BOLD ;
         COLOR aColor[ i ]

      @ 140, 60 PRINT "Page Number :" + Str( i, 2 ) ;
         FONT "Arial" ;
         SIZE 20 ;
         COLOR aColor[ i ]

      @ 260, 20 PRINT LINE ;
         TO 260, 190 ;
         PENWIDTH 0.1

      END PRINTPAGE

   NEXT i

   END PRINTDOC

RETURN
