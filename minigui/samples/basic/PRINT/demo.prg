/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/

  Copyright 2009 Sudip Bhattacharyya <sudipb001@gmail.com>
*/

#include "minigui.ch"
#include "miniprint.ch"

FIELD fname, lname, addr1, addr2, addr3

FUNCTION Main()

   REQUEST DBFCDX
   rddSetDefault( "DBFCDX" )

   SET CENTURY ON
   SET DATE GERMAN

   DEFINE WINDOW winMain ;
      AT 0, 0 WIDTH 640 HEIGHT 460 ;
      TITLE "Printing Test Sample" ;
      MAIN ;
      ON INIT CreateData()

      DEFINE MAIN MENU
         POPUP "&File"
            ITEM "Print List" ACTION PrintList()
            ITEM "E&xit" ACTION ThisWindow.Release()
         END POPUP
      END MENU

   END WINDOW

   winMain.Center()
   winMain.Activate()

RETURN NIL


FUNCTION PrintList()

   LOCAL mPageNo, mLineNo, mPrinter

   mPrinter := GetPrinter()

   IF Empty ( mPrinter )
      RETURN NIL
   ENDIF

   SELECT PRINTER mPrinter ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW

   START PRINTDOC NAME "Address"
   START PRINTPAGE

   SELECT addr
   GO TOP

   mPageNo := 0
   mLineNo := 0

   DO WHILE .NOT. Eof()

      IF mLineNo >= 260 .OR. mPageNo == 0
         IF ++mPageNo > 1
            mLineNo += 5
            @ mLineNo, 105 PRINT "Continue to Page " + LTrim( Str( mPageNo ) ) CENTER
            END PRINTPAGE
            START PRINTPAGE
         ENDIF

         @ 20, 20 PRINT "ADDRESS LIST"
         @ 20, 190 PRINT "Page: " + LTrim( Str( mPageNo ) ) RIGHT
         @ 25, 20 PRINT Date()

         mLineNo := 35
         @ mLineNo, 20 PRINT "First Name"
         @ mLineNo, 50 PRINT "Last Name"
         @ mLineNo, 80 PRINT "Address"

         mLineNo += 5
         @ mLineNo, 20 PRINT LINE TO mLineNo, 140
         mLineNo += 2
      ENDIF

      @ mLineNo, 20 PRINT fname
      @ mLineNo, 50 PRINT lname
      @ mLineNo, 80 PRINT addr1
      mLineNo += 5
      @ mLineNo, 80 PRINT addr2
      mLineNo += 5
      @ mLineNo, 80 PRINT addr3
      mLineNo += 5

      DO EVENTS
      SKIP

   ENDDO

   END PRINTPAGE
   END PRINTDOC

RETURN NIL


FUNCTION CreateData()

   LOCAL aDbf := {}, i

   IF !File( "addr.dbf" )
      AAdd( adbf, { "fname",   "C",   20,   0 } )
      AAdd( adbf, { "lname",   "C",   20,   0 } )
      AAdd( adbf, { "addr1",   "C",   40,   0 } )
      AAdd( adbf, { "addr2",   "C",   40,   0 } )
      AAdd( adbf, { "addr3",   "C",   40,   0 } )

      dbCreate( "addr", adbf )

      IF SELECT( "addr" ) = 0
         USE addr EXCLUSIVE
      ENDIF
      SELECT addr

      FOR i = 1 TO 100
         APPEND BLANK
         REPLACE fname WITH "First name " + hb_ntos( i )
         REPLACE lname WITH "Last name " + hb_ntos( i )
         REPLACE addr1 WITH "Address LineNo One " + hb_ntos( i )
         REPLACE addr2 WITH "Address LineNo Two " + hb_ntos( i )
         REPLACE addr3 WITH "Address LineNo Three " + hb_ntos( i )
      NEXT
   ELSE
      IF SELECT( "addr" ) = 0
         USE addr EXCLUSIVE
      ENDIF
      SELECT addr
   ENDIF

RETURN NIL
