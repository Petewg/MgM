#include <hmg.ch>

FIELD CLI_ID, CLI_SNAM, CLI_NAME, CLI_DAYS, CLI_WAGE, CLI_SALARY, CLI_BDATE

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #7  :
   
   Use a long ( has records more than one page ) table;
   
   added START PAGE to each NEW page.

*/

PROCEDURE  PrintTest7()

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
         
   LOCAL nLinsPerPag := nPageHeigth / nLineHeigth,;
         nLineNo1Pag := 0
   
   LOCAL cItem2Prnt
   
   USE .\DATA\EMPLOYE2
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
         
            nPrintRow := nVMargin 
            
            DO WHILE .NOT. EOF()
            
               cItem2Prnt := STR( CLI_ID, 5 )
               nPrintCol := nHMargin + LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := CLI_NAME 
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize 
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               
               cItem2Prnt := CLI_SNAM 
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
               
               IF ++nLineNo1Pag > nLinsPerPag
                  nLineNo1Pag := 0
                  END PRINTPAGE 
                  nPrintRow := nVMargin                     
                  START PRINTPAGE             
               ELSE
                  nPrintRow += nLineHeigth
               ENDIF   
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
