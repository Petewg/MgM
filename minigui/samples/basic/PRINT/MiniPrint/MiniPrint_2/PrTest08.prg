#include <hmg.ch>

FIELD CLI_ID, CLI_SNAM, CLI_NAME, CLI_DAYS, CLI_WAGE, CLI_SALARY, CLI_BDATE

MEMVAR nCharLength, nLineHeigth

MEMVAR nLinsPerPag, nLineNo1Pag

MEMVAR nPrintRow, nPrintCol

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #8  :
   
       add column headers
   
*/

PROCEDURE PrintTest8()

   LOCAL lSuccess := .F.,;
         nVMargin := 20,;    // Vertical margin
         nHMargin := 20,;      // Horizontal margin         
         cFontName := "Verdana",;
         nFontSize := 10,;   // In pixel
         nLine_Num :=  0
   
   LOCAL nPageLength := 210 - nHMargin * 2,;
         nPageHeigth := 297 - nVMargin * 3,;  // 1 Top Margin + 1 Column Headers + 1 Bottom margin
         nChrsPerLin :=  80
            
   LOCAL cItem2Prnt
   
   PRIVATE nCharLength := 2.25,;
           nLineHeigth := 6.8
           
   PRIVATE nLinsPerPag := nPageHeigth / nLineHeigth,;
           nLineNo1Pag := 0
         
   PRIVATE nPrintRow :=  0,;   // Row ( line ) number in printed page
           nPrintCol :=  0     // Column  number in printed page
   
   USE .\DATA\EMPLOYE2
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
      
         START PRINTPAGE
            
            nPrintRow := nVMargin
            nPrintCol := nHMargin + 15
            
            PrintPageHeader()
            
            DO WHILE .NOT. EOF()
            
               
               cItem2Prnt := STR( CLI_ID, 5 )
               nPrintCol := nHMargin + 15 + nCharLength * LEN( cItem2Prnt )
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
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99")
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := TRANSFORM( CLI_SALARY, "999,999.99" ) 
               nPrintCol  += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
             
               IF ++nLineNo1Pag > nLinsPerPag
                  nLineNo1Pag := 0
                  END PRINTPAGE 
                  START PRINTPAGE 
                  nPrintRow := nVMargin 
                  nPrintCol := nHMargin + 15
                  PrintPageHeader()
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

STATIC PROCEDURE PrintPageHeader()

   LOCAL cItem2Prnt, nColumnLen
   
   cItem2Prnt := STR( CLI_ID, 5 )   
   nColumnLen := nCharLength * LEN( cItem2Prnt ) - 1   
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "ID" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength

   cItem2Prnt := CLI_NAME 
   nColumnLen :=  nCharLength * LEN( cItem2Prnt ) - 1   
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Name" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
                      
   cItem2Prnt := CLI_SNAM 
   nColumnLen :=  nCharLength * ( LEN( cItem2Prnt ) - 1 )  
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Surname" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
                      
   cItem2Prnt := DTOC( CLI_BDATE )
   nColumnLen := nCharLength * ( LEN( cItem2Prnt ) - 1 )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Hire Date" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
                      
   cItem2Prnt := TRANSFORM( CLI_DAYS, "99" )
   nColumnLen := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "D." CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99") 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Wage" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength

   cItem2Prnt := TRANSFORM( CLI_SALARY, "999,999.99" ) 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Salary" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
    
   nPrintRow += nLineHeigth * 1.5 
   
RETURN // PrintPageHeader()             

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
