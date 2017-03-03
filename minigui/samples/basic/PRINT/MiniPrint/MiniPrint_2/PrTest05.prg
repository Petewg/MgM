#include <hmg.ch>

FIELD CLI_ID, CLI_SNAM, CLI_NAME, CLI_DAYS, CLI_WAGE, CLI_SALARY, CLI_BDATE

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.


/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #5  :
   
   first attemp to print a list from a table ( .dbf ) file
 
  
*/

PROCEDURE  PrintTest5()

   LOCAL lSuccess := .F.,;
         nVMargin := 20,;    // Vertical margin
         nHMargin := 20      // Horizantal margin
         
   LOCAL nPrintRow :=  0,;   // Row ( line ) number in printed page
         nPrintCol :=  0,;   // Column  number in printed page
         cFontName := "Verdana",;
         nFontSize := 10,;   // In pixel
         nLine_Num :=  0
   
   LOCAL nPageLength := 210 - nHMargin * 2,;
         nPageHeigth := 297 - nVMargin * 2,;
         nChrsPerLin :=  80,;
         nLinsPerPag :=  50
         
   LOCAL nCharLength := 2.25 ,;
         nLineHeigth := 6.8
         
   LOCAL cTestString := "This is a test"      

   USE .\DATA\EMPLOYE
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
            nPrintRow := nVMargin 
            DO WHILE .NOT. EOF() // RECN() < 10
               nPrintCol := nHMargin
               @ nPrintRow, nPrintCol PRINT CLI_ID FONT cFontName SIZE nFontSize 
               nPrintCol += nCharLength * FIELDLEN( 1 )
               @ nPrintRow, nPrintCol PRINT CLI_SNAM FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * FIELDLEN( 2 )
               @ nPrintRow, nPrintCol PRINT CLI_NAME FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( CLI_NAME )
               @ nPrintRow, nPrintCol PRINT TRANSFORM( CLI_DAYS, "99" ) FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( TRANSFORM( CLI_DAYS, "99" ) )
               @ nPrintRow, nPrintCol PRINT TRANSFORM( CLI_WAGE, "999.99") FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( TRANSFORM( CLI_WAGE, "999.99") )
               @ nPrintRow, nPrintCol PRINT TRANSFORM( CLI_SALARY, "999,999.99" ) FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( TRANSFORM( CLI_SALARY, "999,999.99" ) )
               
               nPrintRow += nLineHeigth
               SKIP
            ENDDO             
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   

   USE
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
