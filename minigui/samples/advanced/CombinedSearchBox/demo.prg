/*
 

   Multiple CSBox ( Combined Search Box ) with tabbing test


*/

#include "minigui.ch"
#include "combosearchbox.ch"


PROC Main()

   Local aCountries := HB_ATOKENS( MEMOREAD( "Countries.lst" ),   CRLF )
   Local aLargCits  := HB_ATOKENS( MEMOREAD( "LargCits.lst" ),    CRLF )
   Local aNationals := HB_ATOKENS( MEMOREAD( "Nationality.lst" ), CRLF )
   
   ASORT( aCountries )                    
   ASORT( aLargCits )                    
   ASORT( aNationals )                    
       
   DEFINE WINDOW frmMCSBTest ;
      AT     0,0 ;
      WIDTH  550 ;
      HEIGHT 300 ;
      TITLE  'Multiple CSBox ( Combined Search Box ) Sample' ;
      MAIN
     
      ON KEY ESCAPE ACTION frmMCSBTest.Release
     
      DEFINE LABEL lblCountries
         ROW        27
         COL        10
         WIDTH      70
         VALUE      "Country :"
         RIGHTALIGN .T.
      END LABEL
      
      DEFINE LABEL lblCities
         ROW        57
         COL        10
         WIDTH      70
         VALUE      "City :"
         RIGHTALIGN .T.
      END LABEL
     
     
      DEFINE COMBOSEARCHBOX csbxCountries
         ROW        25
         COL        90
         WIDTH      150
         ITEMS      aCountries
         ON ENTER    MsgBox( this.Value )
      END COMBOSEARCHBOX
     
      DEFINE COMBOSEARCHBOX csbxLargCits  
         ROW        55
         COL        90
         WIDTH      150
         ITEMS      aLargCits  
      END COMBOSEARCHBOX

      DEFINE TAB tabMCSBox ;
         AT     20, 250  ;
         WIDTH  280      ;
         HEIGHT 240

         DEFINE PAGE "Blank Page"
            @ 90, 5 LABEL lblBlank WIDTH 270 VALUE "This page left intentionally blank." CENTERALIGN
         END PAGE
         
         DEFINE PAGE "Tabbed CSBox"

            DEFINE LABEL lblNations
               ROW        37
               COL        10
               WIDTH      70
               VALUE      "Nationality :"
               RIGHTALIGN .T.
            END LABEL
            
            DEFINE COMBOSEARCHBOX csbxNations
               ROW        35
               COL        90
               WIDTH      150
               ITEMS      aNationals 
            END COMBOSEARCHBOX
            
         END PAGE

       END TAB
   
   END WINDOW // frmMCSBTest
   
   frmMCSBTest.Center

   frmMCSBTest.Activate

     
RETU // Main()


#include "combosearchbox.prg"