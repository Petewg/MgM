/*
 * HMG Test Program for Array Arithmetics module
 * (c) 2010 B. Esgici <esgici @ gmail . com >
*/

#include "minigui.ch"

#ifndef _HBMK_
   Set Procedure To ArAritms.prg
#endif

MEMVAR a1Dim, aRows

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC Main()

   PRIVATE a1Dim := ARRAY( 10 ),;
           aRows := { {'Simpson',   'Homer',     10, '555-5555'},;
                      {'Mulder',    'Fox',       10, '324-6432'},; 
                      {'Smart',     'Max',       10, '432-5892'},; 
                      {'Grillo',    'Pepe',      10, '894-2332'},; 
                      {'Kirk',      'James',     10, '346-9873'},; 
                      {'Barriga',   'Carlos',    10, '394-9654'},; 
                      {'Flanders',  'Ned',       10, '435-3211'},; 
                      {'Smith',     'John',      10, '123-1234'},; 
                      {'Pedemonti', 'Flavio',    10, '000-0000'},; 
                      {'Gomez',     'Juan',      10, '583-4832'},; 
                      {'Fernandez', 'Raul',      10, '321-4332'},; 
                      {'Borges',    'Javier',    10, '326-9430'},; 
                      {'Alvarez',   'Alberto',   10, '543-7898'},; 
                      {'Gonzalez',  'Ambo',      10, '437-8473'},; 
                      {'Batistuta', 'Gol',       10, '485-2843'},; 
                      {'Vinazzi',   'Amigo',     10, '394-5983'},; 
                      {'Pedemonti', 'Flavio',    10, '534-7984'},; 
                      {'Samarbide', 'Armando',   10, '854-7873'},; 
                      {'Pradon',    'Alejandra', 10, '???-????'},; 
                      {'Reyes',     'Monica',    10, '432-5836'} }
     
    AFILL( a1Dim, 1 )
 
    AEVAL( aRows, { | a1 | AADD( a1, 1 ) } )  
  
      DEFINE WINDOW frmArArTest ;
           AT 0,0 ;
           WIDTH 800 ;
           HEIGHT 550 ;
           TITLE 'Array Arithmetics' ;
           MAIN ;
           ON INIT frmArArTest.StatusBar.Item(2) :=  ;                      
                   LTRIM( STR( frmArArTest.grdBase.Value[ 1 ] ) ) + "\" + ;
                   LTRIM( STR( frmArArTest.grdBase.ItemCount ) ) ;

           ON KEY ESCAPE ACTION frmArArTest.Release
            
           DEFINE STATUSBAR FONT 'Verdana' SIZE 8   
              STATUSITEM "" WIDTH 400
              STATUSITEM "" WIDTH 50
              DATE          WIDTH 80
              CLOCK         WIDTH 83
           END STATUSBAR
                       
           DEFINE MAIN MENU

              POPUP 'Test'
           
                 POPUP "Dim&1"             
                    ITEM "Count (RowNo < 7)"           ACTION ArArTest( 1, 1, 1)
                    ITEM "Sum (RowNo > 3)"             ACTION ArArTest( 1, 2, 1)
                    ITEM "Average (RowNo > 2 and < 8)" ACTION ArArTest( 1, 3, 1)
                    ITEM "Total (RowNo > 2 and < 8)"   ACTION ArArTest( 1, 4, 1)                                        
                 END POPUP // Dim1
                     
                 POPUP "Dim&2"             
                    POPUP '&Count'
                       ITEM  "FOR Row No > 7" ACTION ArArTest( 2, 1, 1 )                        
                       ITEM  "FOR Area Code = '432" ACTION ArArTest( 2, 1, 2 )
                    END POPUP // Count        
                    POPUP '&Sum'    
                       ITEM  "FOR Area code beg with '5'" ACTION ArArTest( 2, 2, 1 )                        
                       ITEM  "FOR Area code > '555'"      ACTION ArArTest( 2, 2, 2 )
                    END POPUP // Sum                
                    POPUP '&Average'
                       ITEM  "FOR Lastname beg with < 'S'"  ACTION ArArTest( 2, 3, 1 )                        
                       ITEM  "FOR Lastname beg with > 'C'" ACTION ArArTest( 2, 3, 2 )
                    END POPUP // Average                
                    POPUP '&Total'
                       ITEM  "ON Initial of Last Name"  ACTION ArArTest( 2, 4, 1 )                        
                       ITEM  "ON Initial of First Name" ACTION ArArTest( 2, 4, 2 )                
                    END POPUP // Total                        
                  END POPUP // Dim2                     

                  SEPARATOR

                  ITEM "E&xit"	ACTION frmArArTest.Release

               END POPUP // Test

               POPUP 'Help'
                  ITEM 'About'	ACTION MsgInfo ('Array Arithmetics Demo'+CRLF+'Author : Bicahi Esgici', 'About')
               END POPUP // Help

           END MENU

           @ 10,10 GRID grdBase ;
               WIDTH 760 ;
               HEIGHT 340 ;
               HEADERS { 'Last Name', 'First Name', 'N1', 'Phone', "N2" } ;
               WIDTHS { 140, 140, 140, 140, 140 } ;
               ON CHANGE frmArArTest.StatusBar.Item(2) :=  ;                      
                             LTRIM( STR( frmArArTest.grdBase.Value[ 1 ] ) ) + "\" + ;
                             LTRIM( STR( frmArArTest.grdBase.ItemCount ) ) ;
               ITEMS aRows ;
               VALUE 1 ;
               TOOLTIP 'Grid for testing Array Arithmetics' ;
               EDIT ;
               COLUMNCONTROLS { {'TEXTBOX'}, {'TEXTBOX'}, {'TEXTBOX','NUMERIC','999,999.99'}, {'TEXTBOX'}, {'TEXTBOX','NUMERIC','999,999.99'} } ;
               JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT } ; 
               CELLNAVIGATION                       

           @ 370,10 GRID grdResults ;
               WIDTH 760 ;
               HEIGHT 100 ;
               HEADERS { '', '', 'N1', '', "N2" } ;
               WIDTHS { 140, 140, 140, 140, 140 } ;
               TOOLTIP 'Grid of Array Arithmetics results' ; 
               COLUMNCONTROLS { {'TEXTBOX'}, {'TEXTBOX'}, {'TEXTBOX','NUMERIC','999,999.99'}, {'TEXTBOX'}, {'TEXTBOX','NUMERIC','999,999.99'} } ;
               JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT } ;
               CELLNAVIGATION                       

       END WINDOW // frmArArTest

       CENTER WINDOW frmArArTest

       ACTIVATE WINDOW frmArArTest

RETURN // Main()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC ArArTest( ;            // Array arithmetics tests
                 nDim,;     // Array dimention : 1: Single, 2: Two dimension
                 nTest,;    // Test No : 1: Count, 2: Sum, 3: Average, 4: Total
                 nOptn  )   // Options
                  
    LOCAL aResults := {},;
          aDescrpt := {},;
          cDescrpt := ''
   
    aResults := {}
    frmArArTest.grdResults.DeleteAllItems()
    frmArArTest.StatusBar.Item(1) := ''
    
    IF nDim < 2
       cDescrpt := "Dim-1 : " 
       DO CASE
          CASE nTest == 1   // Count
             cDescrpt += "COUNT for RowNo > 7 is : " + LTRIM( STR( ACOUNT( a1Dim,   1, { | x1, i1 | i1 < 7 } ) ) )
          CASE nTest == 2   // Sum
             cDescrpt += "SUM for 'RowNo > 3' is : " + LTRIM( STR( ASUM(   a1Dim, , 1, { | x1, i1 | i1 > 3 } ) ) )                             
          CASE nTest == 3   // Average
             cDescrpt += "AVERAGE for 'Row No > 2 and < 8' is : " + LTRIM( STR( AAVERAGE( a1Dim,  , 1, { | x1, i1 | i1 < 8 .AND. i1 > 2 } ) ) )
          CASE nTest == 4   // Total
             cDescrpt += "TOTAL for '< 8 Row No > 2' is : " + LTRIM( STR( ATOTAL( a1Dim,,, , 1, { | x1, i1 | i1 < 8 .AND. i1 > 2 } ) ) )
       END CASE                                     
    ELSE           
    
       cDescrpt := "Dim-2 : " 
       
       DO CASE
     
          CASE nTest == 1   // Count
       
             DO CASE 
                CASE nOptn == 1
                   cDescrpt += "COUNT for RowNo > 7 is : " + LTRIM( STR( ACOUNT( aRows, 1, { | x1, i1 | i1 > 7 } ) ) )
                CASE nOptn == 2
                   cDescrpt += "COUNT for Area Code = 432 is : " + LTRIM( STR( ACOUNT( aRows, 4, { | x1, i1 | LEFT( x1, 3 ) = '432' } ) ) )          
             END CASE     
             
          CASE nTest == 2   // Sum
       
             DO CASE              
                CASE nOptn == 1
                   cDescrpt += "SUM for area code beg with '5'"
                   aResults := ASUM( aRows, , 4, { | x1, i1 | LEFT( x1, 1 ) > '5'   } )   
                CASE nOptn == 2
                   cDescrpt := "SUM for area code > '555'"
                   aResults := ASUM( aRows, , 4, { | x1, i1 | LEFT( x1, 3 ) > '555' } )    
             END CASE     
             
             aResults := { aResults }
                     
          CASE nTest == 3   // Average
          
             DO CASE 
                CASE nOptn == 1
                   cDescrpt += "AVERAGE for Lastname beg with < 'S'"  
                   aResults := AAVERAGE( aRows, , 1, { | x1, i1 | LEFT( x1, 1 ) < 'S' } )
                CASE nOptn == 2
                   cDescrpt += "AVERAGE for Lastname beg with > 'C'"   
                   aResults := AAVERAGE( aRows, , 1, { | x1, i1 | LEFT( x1, 1 ) > 'C' } )
             END CASE     
             
             aResults := { aResults }
                                  
          CASE nTest == 4   // Total
       
             DO CASE 
                CASE nOptn == 1
                   cDescrpt += "TOTAL ON Initial of Last Name"
                   aResults := ATOTAL( aRows, , 1, { | x1, i1 | LEFT( x1, 1 ) } )
                   ASORT( aResults ,,, { | a1, a2 | a1[ 1 ] < a2[ 1 ] } )
                CASE nOptn == 2
                   cDescrpt += "TOTAL ON Initial of First Name"
                   aResults := ATOTAL( aRows, , 2, { | x1, i1 | LEFT( x1, 1 ) } )
                   ASORT( aResults ,,, { | a1, a2 | a1[ 2 ] < a2[ 2 ] } )
             END CASE     
             
       END CASE     
       
       IF !EMPTY( aResults )
          AEVAL( aResults , { | a1 | frmArArTest.grdResults.AddItem( a1 ) } )
       ENDIF   

    ENDIF nDim < 2           
    
    frmArArTest.StatusBar.Item(1) := cDescrpt
    
RETU // ArArTest()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

