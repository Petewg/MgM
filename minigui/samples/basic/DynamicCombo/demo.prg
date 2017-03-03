/*

  HMG - Harbour Win32 GUI library Demo/Sample

  Load / Save single dimensional character array

  The ComboBox control requires a single dimensional character array.   

  So, manipulate this type array frequently required for ComboBox process.

  This sample load an external (single dimensional character) array from a text file to the program and upon exit save it to the file.

  Processing array into program we are using a dynamic ComboBox control.  

  All critics and suggestions are welcome.

  Developed under Harbour Compiler and 
  HMG - Harbour Win32 GUI library

  Thanks to "Le Roy" Roberto Lopez;

  and Carlos RD, who requested and inspired this sample.

  Copyright Bicahi Esgici < esgici <at> gmail.com >

  History : Feb 2013 : First release

  Revised by Grigory Filatov <gfilatov@inbox.ru>

*/

#include <hmg.ch>

MEMVAR aTires

PROCEDURE Main()

   LOCAL cArrFNam := "tires.lst"

   PRIVATE aTires := LoadArray( cArrFNam )

   DEFINE WINDOW frmLS1dArry ;
       AT 0,0 ;
       WIDTH 400 ;
       HEIGHT 200 ;
       TITLE 'Load / Save single dimension array sample' ;
       ON RELEASE SaveArray( cArrFNam, aTires ) ;
       MAIN

       ON KEY CONTROL+DELETE ACTION DeleteItem()

       ON KEY ESCAPE ACTION ThisWindow.Release

       @ 10,10 COMBOBOX cmbTest ;
           WIDTH  200  ;
           HEIGHT 200 ;
           ITEMS aTires ;
           VALUE 1 ;
           DISPLAYEDIT ;
           ON LOSTFOCUS RefreshCBox() ;
           ON ENTER     RefreshCBox() ;
           DROPPEDWIDTH 250

   END WINDOW

   CENTER WINDOW frmLS1dArry

   ACTIVATE WINDOW frmLS1dArry

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE RefreshCBox()

   IF frmLS1dArry.cmbTest.Value == 0 .AND. !EMPTY( frmLS1dArry.cmbTest.DisplayValue )

      AADD( aTires, )
      AINS( aTires, 1 )
      aTires[ 1 ] := ''
      aTires[ 2 ] := frmLS1dArry.cmbTest.DisplayValue
      frmLS1dArry.cmbTest.DeleteAllItems()
      AEVAL( aTires, { | c1 | frmLS1dArry.cmbTest.AddItem( c1 ) } )
      frmLS1dArry.cmbTest.Value := 2

   ENDIF

RETURN // RefreshCBox()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE DeleteItem()

   LOCAL nItem

   IF !EMPTY( frmLS1dArry.cmbTest.DisplayValue )

      nItem := ASCAN( aTires, { | c1 | c1 == frmLS1dArry.cmbTest.DisplayValue } )
      IF nItem > 0

         ADEL( aTires, nItem )
         ASIZE( aTires, LEN( aTires ) - 1 )
         frmLS1dArry.cmbTest.DeleteAllItems()
         AEVAL( aTires, { | c1 | frmLS1dArry.cmbTest.AddItem( c1 ) } )

      ENDIF

   ENDIF

RETURN // DeleteItem()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION LoadArray(;                      // Load a 1d Char array from a file
                   cFilName )

   LOCAL aRVal := {}

   aRVal := HB_ATOKENS( HB_MEMOREAD( cFilName ), CRLF )

RETURN aRVal // LoadArray()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SaveArray(;                     // Save a 1d Char array to a file
                   cFilName,;
                   aC1dArray )

   LOCAL cText := CRLF

   IF LEN( aC1dArray ) > 1

      AEVAL( aC1dArray, { | c1, C2 | IF( EMPTY( c1 ), , cText += c1 + iif( c2 < LEN( aC1dArray ), CRLF, "" ) ) } )
      HB_MEMOWRIT( cFilName, cText )

   ENDIF

RETURN // SaveArray()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
