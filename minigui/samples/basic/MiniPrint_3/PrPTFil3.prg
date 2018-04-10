#include <hmg.ch>
#include "PrPTFil3.ch"

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   Print a plain text file (Comfortable way).
   
*/

FUNCTION  PPTFComf(;                      // Print plain text file, Comfortable way
                   cPLTFName,;
                   cDefaPrinter,; 
                   lSelPrnDialog,;
                   nPaprTypeNo,;
                   lWrapLoLins,;
                   cFontName,; 
                   nFontSize,;
                   nVMargin,;      // Vertical margin
                   nHMargin,;      // Horizontal margin         
                   nChrsPerLin,; 
                   nLineHeigth,;
				   aShPrgsOp,;
                   bUpdaSBar,;
                   bUpdaPBar )                   

    LOCAL lSuccess,; 
         nBytesRead,;
         c1Line,;
         nSubLinCo
         
    LOCAL nPageWidth,;
         nPageHeight
         
    LOCAL nPrintRow := nVMargin,;
         nPrintCol := nHMargin,;
         nPageLimit,;
         nEndOfLine
         
    LOCAL nPageCount := 1       
   
    LOCAL oTFR_File

    LOCAL xUSBarP1, xUSBarP2, xUSBarP3, xUSBarP4       
   
    LOCAL lUpdaPrgrsBar,;
          lUpdaSttBarI1,;
          lUpdaSttBarI3,;
          lUpdaSttBarI4
   
    LOCAL nPBarIncr
   
    IF HB_ISNIL( aShPrgsOp ) 
	   aShPrgsOp := ARRAY( 4 )
	   AFILL( aShPrgsOp, .F. )
    ENDIF   
	
    lUpdaPrgrsBar := aShPrgsOp[ 1 ]
    lUpdaSttBarI1 := aShPrgsOp[ 2 ]
    lUpdaSttBarI3 := aShPrgsOp[ 3 ]
    lUpdaSttBarI4 := aShPrgsOp[ 4 ]
   
   IF FILE( cPLTFName )    
   
      nPBarIncr := HL_FSize( cPLTFName ) / n2E16_1
	  
      IF lSelPrnDialog
         SELECT PRINTER DIALOG TO lSuccess
      ELSE   
         SELECT PRINTER cDefaPrinter TO lSuccess PAPERSIZE nPaprTypeNo 
      ENDIF
      
      IF lSuccess                                
      
         oTFR_File := TFileRead():New( cPLTFName ) 
         oTFR_File:Open()
         
         IF oTFR_File:Error()
            MsgStop( oTFR_File:ErrorMsg( "FileRead: " ) )
         ELSE
            nPageWidth  := GetPrintableAreaWidth()
            nPageHeight := GetPrintableAreaHeight()
            nPageLimit  := nPageHeight - nVMargin
            nEndOfLine  := nPageWidth  - nHMargin
            nBytesRead  := 0
            
            START PRINTDOC 
               START PRINTPAGE
                  WHILE oTFR_File:MoreToRead()
                     c1Line := oTFR_File:ReadLine() 
                     nBytesRead += LEN( c1Line ) + 2
                     IF lWrapLoLins
                        c1Line := HL_LineWordWrap( c1Line, nChrsPerLin )                     
                        nSubLinCo := HB_TOKENCOUNT( c1Line, CRLF )  
                     ELSE
                        nSubLinCo := 1
                     ENDIF                  
					 
			IF lUpdaPrgrsBar
			    EVAL( bUpdaPBar, nBytesRead / nPBarIncr   )
			 ENDIF	
					 
                     xUSBarP1 := c1Line 
                     xUSBarP3 := nBytesRead
					
                     IF lUpdaSttBarI1
			    EVAL( bUpdaSBar, xUSBarP1 )
			 ENDIF
					 
                     IF lUpdaSttBarI3
			     EVAL( bUpdaSBar, ,, xUSBarP3 )
			 ENDIF
					 
                     IF nPrintRow + nLineHeigth * nSubLinCo > nPageLimit                  
                        END PRINTPAGE
                        ++nPageCount 
                        IF lUpdaSttBarI4					 
                           xUSBarP4 := nPageCount 
	             	   EVAL( bUpdaSBar, ,,,xUSBarP4 )
			ENDIF   
                        nPrintRow := nVMargin
                        START PRINTPAGE
                     ENDIF   
                     IF lWrapLoLins
                        @ nPrintRow, nPrintCol PRINT c1Line ;
                                           TO nPrintRow + nLineHeigth * nSubLinCo, nEndOfLine ;
                                           FONT cFontName SIZE nFontSize 
                     ELSE                                        
                        @ nPrintRow, nPrintCol PRINT c1Line FONT cFontName SIZE nFontSize 
                     ENDIF
                     nPrintRow += nLineHeigth * nSubLinCo
                     DO EVENTS
                  ENDDO oTFR_File:MoreToRead()
               END PRINTPAGE             
            END PRINTDOC
			
            IF lUpdaPrgrsBar
		    EVAL( bUpdaPBar, n2E16_1 )
	    ENDIF	
			
         ENDIF oTFR_File:Error()            
      ENDIF lSuccess
   ELSE
      MsgStop( cPLTFName + " file not found !", "ERROR !" )
   ENDIF ! EMPTY( aPTFLines )    
   
RETURN  nPageCount // PPTFComf()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.