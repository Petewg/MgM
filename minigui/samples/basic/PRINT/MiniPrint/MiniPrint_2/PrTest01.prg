#include <hmg.ch>

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   HMG Print ( Mini Print ) for beginners in 10 easy steps
   
   Step #1  :
   
   Use everything with default values,
   
   write only "This is a test"  
   
   to four corners and center of paper.
   
*/

PROCEDURE  PrintTest1()

   /*
      Default paper size is A4 Sheet; 210- by 297-millimeters
   */
   
   LOCAL lSuccess := .F.,;
         cTestString   := "This is a test",;
         nMostRightCol := 210,;  // Default page size is A4 : 210 x 297 mm
         nMostBottmRow := 297
   
   SELECT PRINTER DEFAULT TO lSuccess PREVIEW 
   
   IF lSuccess
      START PRINTDOC 
         START PRINTPAGE
             @ 5, 5 PRINT cTestString                                    // Top Left   
             @ 5, nMostRightCol-5 PRINT cTestString  RIGHT                    // Top Right
             @ nMostBottmRow / 2, nMostRightCol / 2  PRINT cTestString CENTER  // Center of paper
             @ nMostBottmRow - 9, 5 PRINT cTestString                       // Bottom Left   
             @ nMostBottmRow - 9, nMostRightCol-5 PRINT cTestString RIGHT       // Bottom Right
         END PRINTPAGE             
      END PRINTDOC
   ELSE
      MsgStop( "Couldn't select default printer !", "ERROR !" )
   ENDIF   
   
RETURN  // PrintTest()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
