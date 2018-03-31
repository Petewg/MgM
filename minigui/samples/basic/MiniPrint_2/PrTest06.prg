#include <hmg.ch>

FIELD CLI_ID, CLI_SNAM, CLI_NAME, CLI_DAYS, CLI_WAGE, CLI_SALARY, CLI_BDATE

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #6  :
   
      right adjust (formatted) numeric fields
   
      Note that when RIGHT clause is used, <Row> , <Col> 
      indicates the right coordinates of <xData>

*/

PROCEDURE  PrintTest6()

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
         nChrsPerLin :=  80
         
   LOCAL nCharLength := 2.25,;
         nLineHeigth := 6.8
         
   LOCAL cItem2Prnt

   USE .\DATA\EMPLOYE
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
            nPrintRow := nVMargin 
            DO WHILE .NOT. EOF() // RECN() < 10
            
               cItem2Prnt := STR( CLI_ID, 5 )
               nPrintCol := nHMargin + LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := CLI_SNAM 
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize 
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               
               cItem2Prnt := CLI_NAME 
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize 
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               
               cItem2Prnt := DTOC( CLI_BDATE )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize 
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               
               cItem2Prnt := TRANSFORM( CLI_DAYS, "99" ) 
               nPrintCol += nHMargin + LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99")
               nPrintCol += nHMargin + LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := TRANSFORM( CLI_SALARY, "999,999.99" ) 
               nPrintCol += nHMargin + LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
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
