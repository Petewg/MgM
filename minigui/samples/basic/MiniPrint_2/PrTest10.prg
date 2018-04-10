#include <hmg.ch>

FIELD CLI_ID, CLI_SNAM, CLI_NAME, CLI_DAYS, CLI_WAGE, CLI_SALARY, CLI_BDATE

MEMVAR cFontName, nFontSize

MEMVAR nCharLength, nLineHeigth

MEMVAR nPageNumb, nPTLineCo, nPTPageCo, nLinsPerPag, nLineNo1Pag

MEMVAR nPrintRow, nPrintCol, nDays_Tot, nSalaryTot

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #10  :
   
       add page footer and carryover.
   
*/

PROCEDURE PrintTest10()

   LOCAL lSuccess := .F.,;
         nVMargin := 20,;    // Vertical margin
         nHMargin := 20,;      // Horizontal margin         
         nLine_Num :=  0
   
   LOCAL nPageLength := 210 - nHMargin * 2,;
         nPageHeigth := 297 - nVMargin * 5,;  // Margins + Header lines
         nChrsPerLin :=  80
            
   LOCAL cItem2Prnt
   
   PRIVATE cFontName   := "Verdana",;
           nFontSize := 10   
   
   PRIVATE nCharLength := 2.25,;
           nLineHeigth := 5
           
   PRIVATE nPageNumb   := 0,;
           nPTLineCo   := 0,;    // Total line count
           nPTPageCo   := 0,;    // Total page count 
           nLinsPerPag := nPageHeigth / nLineHeigth,;
           nLineNo1Pag := 0
         
   PRIVATE nPrintRow :=  0,;   // Row ( line ) number in printed page
           nPrintCol :=  0     // Column  number in printed page
   
   PRIVATE nDays_Tot  :=  0,;   
           nSalaryTot :=  0     
           
   USE .\DATA\EMPLOYE2

   * This value depends on filters ( SET DELE ON/OF, SET FILT ... )
   
   nPTLineCo := LASTREC()  // Print total line count 
   nPTPageCo := CEILING( nPTLineCo / nLinsPerPag )  // Total page count 
   
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
               
               cItem2Prnt := TRANSFORM( CLI_DAYS, "9999" ) 
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               nDays_Tot += CLI_DAYS
               
               cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99")
               nPrintCol += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nPrintCol += nCharLength
               
               cItem2Prnt := TRANSFORM( CLI_SALARY, "999,999.99" ) 
               nPrintCol  += nCharLength * LEN( cItem2Prnt )
               @ nPrintRow, nPrintCol PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
               nSalaryTot += CLI_SALARY
             
               IF ++nLineNo1Pag > nLinsPerPag
                  nLineNo1Pag := 0
                  nPrintCol := nHMargin + 15
                  PrintPageFooter()
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
            nPrintRow -= nLineHeigth
            nPrintCol := nHMargin + 15
            PrintPageFooter()
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   

   USE
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROCEDURE PrintPageHeader()

   LOCAL cHeadLine := "Employee Salary List"
   
   LOCAL cItem2Prnt := '',; 
         nColumnLen :=  0,; 
         nPrCol1st  := nPrintCol,;
         nPrRow1st  := nPrintRow

   ++nPageNumb
   
   @ nPrintRow + nLineHeigth, 105 PRINT cHeadLine CENTER FONT "Verdana" SIZE 15 BOLD 
   nPrintRow += nLineHeigth * 6
   
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

   IF nPageNumb > 1
      @ nPrintRow + nLineHeigth + 1, nPrintCol PRINT "Carryover :" BOLD ITALIC 
   ENDIF nPageNumb > 1
   
   cItem2Prnt := DTOC( CLI_BDATE )
   nColumnLen := nCharLength * ( LEN( cItem2Prnt ) - 1 )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Hire Date" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   cItem2Prnt := TRANSFORM( nDays_Tot, "9999" )
   nColumnLen := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Days" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01        
   IF nPageNumb > 1
      @ nPrintRow + nLineHeigth + 1, nPrintCol + nColumnLen PRINT cItem2Prnt RIGHT
   ENDIF nPageNumb > 1
   
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99") 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Wage" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength

   cItem2Prnt := TRANSFORM( nSalaryTot, "999,999.99" ) 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol + ( nColumnLen / 2 ) PRINT "Salary" CENTER BOLD
   @ nPrintRow + nLineHeigth, nPrintCol PRINT LINE TO nPrintRow + nLineHeigth, nPrintCol + nColumnLen ;
                      PENWIDTH .01  
   IF nPageNumb > 1
      @ nPrintRow + nLineHeigth + 1, nPrintCol + nColumnLen PRINT cItem2Prnt RIGHT
   ENDIF nPageNumb > 1
   
   nPrintCol += nColumnLen

   * Write backward ! 
   
   @ nPrRow1st + nLineHeigth * 3, nPrCol1st ;
                           PRINT DATE() FONT "Verdana" SIZE 12
   @ nPrRow1st + nLineHeigth * 3, nPrintCol ;
                           PRINT NTOC( nPageNumb ) + "/" + NTOC( nPTPageCo ) RIGHT FONT "Verdana" SIZE 12
   
   nPrintRow += nLineHeigth * IF( nPageNumb < 2, 1.5, 2.5 ) 
   
RETURN // PrintPageHeader()             

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROCEDURE PrintPageFooter()

   LOCAL cItem2Prnt := '',; 
         nColumnLen :=  0

   nPrintRow += + nLineHeigth
   
   cItem2Prnt := STR( CLI_ID, 5 )   
   nColumnLen := nCharLength * LEN( cItem2Prnt ) - 1   
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                                  PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := CLI_NAME 
   nColumnLen :=  nCharLength * LEN( cItem2Prnt ) - 1   
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                                  PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := CLI_SNAM 
   nColumnLen :=  nCharLength * ( LEN( cItem2Prnt ) - 1 )  
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   
   @ nPrintRow + 1, nPrintCol - nColumnLen PRINT ;
                 IF( nPageNumb > 1, IF( nPageNumb < nPTPageCo, "Sub", "Overall " ), "Page " ) + "Total : " ;
                 BOLD ITALIC 
                      
   cItem2Prnt := DTOC( CLI_BDATE )
   nColumnLen := nCharLength * ( LEN( cItem2Prnt ) - 1 )
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := TRANSFORM( nDays_Tot, "9999" )
   nColumnLen := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   @ nPrintRow + 1, nPrintCol + nColumnLen PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 
   nPrintCol += nColumnLen + nCharLength
   
   cItem2Prnt := TRANSFORM( CLI_WAGE, "999.99") 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                      PENWIDTH .01                      
   nPrintCol += nColumnLen + nCharLength

   cItem2Prnt := TRANSFORM( nSalaryTot, "999,999.99" ) 
   nColumnLen  := nCharLength * LEN( cItem2Prnt )
   @ nPrintRow, nPrintCol PRINT LINE TO nPrintRow, nPrintCol + nColumnLen ;
                      PENWIDTH .01  
   @ nPrintRow + 1, nPrintCol + nColumnLen PRINT cItem2Prnt FONT cFontName SIZE nFontSize RIGHT 

RETURN // PrintPageFooter()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
