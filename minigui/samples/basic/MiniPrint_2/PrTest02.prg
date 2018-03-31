#include <hmg.ch>

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #2  :
   
   
      Define margins,
      
      specify Font ( name and size ),      
      
      write to four corners and center of paper.
   
*/

PROCEDURE  PrintTest2()

   LOCAL lSuccess := .F.,;
         cTestString := "This is a test",;
         nVertMargin  := 20,;   // Vertical margin    
         nHorzMargin  := 20,;   // Horizontal margin    
         nMostRightCol := 210 - nHorzMargin,;
         nMostBottmRow := 297 - nVertMargin
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
             @ nVertMargin,      nHorzMargin      PRINT cTestString        FONT "Verdana" SIZE 20  // Top Left   
             @ nVertMargin,      nMostRightCol     PRINT cTestString  RIGHT FONT "Verdana" SIZE 20 // Top Right            
             @ nMostBottmRow / 2, nMostRightCol / 2 PRINT cTestString CENTER FONT "Verdana" SIZE 20  // Center of paper
             @ nMostBottmRow - 4, nHorzMargin      PRINT cTestString        FONT "Verdana" SIZE 20  // Bottom Left   
             @ nMostBottmRow - 4, nMostRightCol     PRINT cTestString RIGHT FONT "Verdana" SIZE 20   // Bottom Right
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
