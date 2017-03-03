/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample
 
  Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/

  Copyright 2009 Sudip Bhattacharyya <sudipb001@gmail.com>
*/

#include "minigui.ch"
#include "miniprint.ch"

FIELD fname, lname, addr1, addr2, addr3

function main()

   SET CENTURY ON
   SET DATE GERMAN

   DEFINE WINDOW winMain ;
      AT 0, 0 WIDTH 640 HEIGHT 460 ;
      TITLE "Printing Test Sample" ;
      MAIN ;
      ON INIT CreateData()
      
      DEFINE MAIN MENU
         POPUP "&File"
            Item "Print List" action PrintList()
            Item "E&xit" action thiswindow.release()
         END POPUP
      END MENU   
      
   END WINDOW

   winMain.center
   winMain.activate

return nil


function PrintList()
   Local mPageNo, mLineNo, mPrinter
   
   mPrinter := GetPrinter()

   If Empty (mPrinter)
      return nil
   EndIf

   SELECT PRINTER mPrinter ORIENTATION PRINTER_ORIENT_PORTRAIT PREVIEW

   START PRINTDOC NAME "Address"
   START PRINTPAGE

   select addr
   GO TOP

   mPageNo:=0
   mLineNo:=0

   DO WHILE .NOT. EOF()

      IF mLineNo>=260 .OR. mPageNo=0
         mPageNo++
         IF mPageNo>1
            mLineNo += 5
            @ mLineNo, 105 PRINT "Continue to Page "+LTRIM(STR(mPageNo)) CENTER
            END PRINTPAGE
            START PRINTPAGE
         ENDIF

         @ 20, 20 PRINT "ADDRESS LIST"
         @ 20,190 PRINT "Page: "+LTRIM(STR(mPageNo)) RIGHT
         @ 25, 20 PRINT DATE()

         mLineNo:=35
         @ mLineNo, 20 PRINT "First Name"
         @ mLineNo, 50 PRINT "Last Name"
         @ mLineNo, 80 PRINT "Address"
   
         mLineNo += 5
         @ mLineNo,20 PRINT LINE TO mLineNo,140
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
      
       DoEvents()
      SKIP
   
   ENDDO

   END PRINTPAGE
   END PRINTDOC

return nil


function CreateData()
   local aDbf := {}, i
   
   REQUEST DBFCDX
   RDDSETDEFAULT( "DBFCDX" )
   
   if !file("addr.dbf")
      aadd(adbf,   {"fname",   "c",   20,   0})
      aadd(adbf,   {"lname",   "c",   20,   0})
      aadd(adbf,   {"addr1",   "c",   40,   0})
      aadd(adbf,   {"addr2",   "c",   40,   0})
      aadd(adbf,   {"addr3",   "c",   40,   0})
      
      dbcreate("addr", adbf)
      
      if select("addr") = 0
         use addr exclusive
      endif
      select addr
      
      for i = 1 to 100
         append blank
         replace fname with "First name "+ltrim(str(i))
         replace lname with "Last name "+ltrim(str(i))
         replace addr1 with "Address LineNoe One "+ltrim(str(i))
         replace addr2 with "Address LineNoe Two "+ltrim(str(i))
         replace addr3 with "Address LineNoe Three "+ltrim(str(i))
      next
   else
      if select("addr") = 0
         use addr exclusive
      endif
      select addr
   endif

return nil
