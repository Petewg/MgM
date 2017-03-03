#include <hmg.ch>

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #4  :
   
   define margins, resolution, page, line and char metrics;

   multiple line, multiple column.
  
  
*/

PROCEDURE  PrintTest4()

   LOCAL lSuccess := .F.,;
         nVMargin := 20,;    // Vertical margin
         nHMargin := 20      // Horizantal margin
         
   LOCAL nPrintRow :=  0,;   // Row ( line ) number in printed page
         nPrintCol :=  0,;   // Column  number in printed page
         cFontName := "Verdana",;
         nFontSize := 10,;   // In pixel
         nLine_Num :=  0
   
   LOCAL nPageLength := 210 - nHMargin * 2,;
         nPageHeigth := 297 - nVMargin * 2
         
   LOCAL nCharLength := 2.25,; 
         nLineHeigth := 6.8
         
   LOCAL cTestString := "This is a test"      
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
            nPrintRow := nVMargin 
            FOR nLine_Num := 1 TO 15 
               nPrintCol := nHMargin
               @ nPrintRow, nPrintCol PRINT StrZero( nLine_Num, 2 ) FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * 3
               @ nPrintRow, nPrintCol PRINT cTestString FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( cTestString )
               @ nPrintRow, nPrintCol PRINT cTestString FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( cTestString )
               @ nPrintRow, nPrintCol PRINT cTestString FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( cTestString )
               @ nPrintRow, nPrintCol PRINT cTestString FONT cFontName SIZE nFontSize
               nPrintCol += nCharLength * LEN( cTestString )
               @ nPrintRow, nPrintCol PRINT cTestString FONT cFontName SIZE nFontSize
              
               nPrintRow += nLineHeigth
            NEXT nLine_Num
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
