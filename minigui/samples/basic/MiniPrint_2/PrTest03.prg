#include <hmg.ch>

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #3  :
   
      specify font name and size as variables,
      
      multi line, combined data value.
      
   
*/   


PROCEDURE  PrintTest3()

   LOCAL lSuccess := .F.,;
         nPrintRow := 10,;   // Top margin    
         nPrintCol := 10,;   // Left margin    
         nFontSize := 10,;
         nLine_Num :=  0
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
            FOR nLine_Num := 1 TO 15 
               @ nPrintRow, nPrintCol PRINT "This is a test _ " + StrZero( nLine_Num, 2 ) ;
                 FONT "Verdana" ;
                 SIZE nFontSize
               nPrintRow += nFontSize  
            NEXT nLine_Num
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
