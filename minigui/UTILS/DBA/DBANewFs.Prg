#include <minigui.ch>
#include "DBA.ch"


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC NewTableBD()                         // Build by defining a New Table and USE 
              
   LOCA cNewTNam := '',;
        aNewStru := DBStructOps( , 3 ),;
        lDone    := .F.
           
   IF !EMPTY( aNewStru )
   
      WHILE !lDone
      
         cNewTNam := PutFile ( { {'Table Files','*.dbf'} }, "New Table Name", cLastDDir, .F. )
          
         IF EMPTY( cNewTNam )
            EXIT
         ELSE   
            IF FILE( cNewTNam )
               IF ASCAN( aOpnDatas, { | a1 | cNewTNam == a1[ 3 ] } ) > 0
                  MsgStop( "This table is already in use;" + CRLF2 +;
                           "Try Another" )
               ELSE               
                  IF lPref0102
                     lDone := MsgYesNo( cNewTNam + " File exist;" + CRLF2 +;
                                       "Overwrite them ?" )
                  ELSE
                    lDone := .T.
                  ENDIF      
               ENDIF
            ELSE                      
               lDone := .T.
            ENDIF
         ENDIF EMPTY( cNewTNam )
      ENDDO  
      
      IF lDone 
         IF UPPE( RIGHT( cNewTNam, 4 ) ) # ".DBF"
            cNewTNam += ".DBF" 
         ENDIF   
         DBCREATE( cNewTNam, aNewStru )
         IF FILE(  cNewTNam )
            IF MsgYesNo( "Table builded;" + CRLF2 + "Open it now ?" )
               Open1Tabl( cNewTNam ) 
            ENDIF
         ELSE 
            * ???   
         ENDIF   
      ENDIF lDone 
      
   ENDIF !EMPTY( ( aNewStru ...
   
RETU // NewTable()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC NewTableSE()                         // Build New Table from stru extended

   LOCA aComPars  := {},;         
        cCbFTitl  := "Building New Table from Structure Extended...",;
        aComOpts  := {},;
        cNewTNam  := '',;
        cStETNam  := '',;
        nCurSel   := SELECT(),;
        lDone     := .F.

   WHILE !lDone     
      aComPars  := { { SPAC( 256 ), "Table", "*.dbf", .F. },;  // Source FILE Name
                     { SPAC( 256 ), "Table", "*.dbf", .F. } }  // Target FILE 
      
                        
      aComOpts  := GFUComOpts( aComPars,;  // Values of options
                               cCbFTitl,;  // Command's name
                               { { 'SFN',"S. Ext." },;      // Source file Name
                                 { 'OFN',"New " } } )       // Output file expression   
      IF !EMPTY( aComOpts )       
         cStETNam  := aComOpts[ 1 ]
         IF STEXTValid( cStETNam )
            cNewTNam  := aComOpts[ 2 ]
            CREATE ( cNewTNam ) FROM ( cStETNam ) NEW // Otomatik USE yapar !
            USE
            DBSELECTAR( ( nCurSel ) )
            lDone := .T.
         ELSE
            IF !MsgRetryCancel( cStETNam + CRLF2 + ;
                      "File is not convenient for this operation.", "Inconvenient file" ) 
               EXIT
            ENDIF          
         ENDIF   
      ELSE
         EXIT   
      ENDIF !EMPTY( aComOpts )       
   ENDDO lDone     
   
   IF lDone
      IF FILE(  cNewTNam )
         IF MsgYesNo( cNewTNam + CRLF2 + "Table builded;" + CRLF2 + "Open it now ?" )
            Open1Tabl( cNewTNam ) 
         ENDIF
      ELSE 
         * ???   
      ENDIF   
   ENDIF lDone
   
RETU // NewTableSE()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
   
   
PROC NewTableES()                          // Build New EMPTY stru extended table 

   LOCA aComPars  := {},;         
        cCbFTitl  := "Building New EMPTY Structure Extended table...",;
        aComOpts  := {},;
        cNewTNam  := '',;
        nCurSel   := SELECT(),;
        lDone     := .F.

   aComPars  := { { SPAC( 256 ), "Table", "*.dbf", .F. } }  // Target FILE 
      
                        
   aComOpts  := GFUComOpts( aComPars,;  // Values of options
                            cCbFTitl,;  // Command's name
                            { { 'OFN',"New " } } )  // Output file expression   
   IF !EMPTY( aComOpts )       
      cNewTNam  := aComOpts[ 1 ]
      DBSELECTAR(0)                 // lowest numbered unoccupied work area 
      CREATE ( cNewTNam )
      USE
      DBSELECTAR( ( nCurSel ) )
      IF FILE(  cNewTNam )
         IF MsgYesNo( cNewTNam + CRLF2 + "Table builded;" + CRLF2 + "Open it now ?" )
            Open1Tabl( cNewTNam ) 
         ENDIF
      ELSE 
         * ???   
      ENDIF   
   ELSE
      MsgBox( "Escaped." )   
   ENDIF      
RETU // NewTableES()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


FUNC StExTValid( ;                        // Struct Extended file valid 
                 cStETNam )
                 
   LOCA lRVal   := .T.,;
        nFlds   := 0,;
        nProp   := 0,;
        nCurSel := SELECT(),;
        aStruct := {}
                          
   IF FILE( cStETNam )
      USE ( cStETNam ) NEW ALIAS TEMP
      aStruct := DBSTRUCT()
      USE      
      ***
      *** lRVal := SameStru( aStruct, aStExStru )
      ***
      *** SameStru() requires EXACT equality; DBCREATE() not.
      ***
      *** Here we must a control other than SameStru(),
      *** this is a special case; aStruct may have more than four fields.
      *** 
      *** 6A01
      *** 
      FOR nFlds := 1 TO LEN( aStExStru )  // aStExStru is defined in DBA.pbl
         FOR nProp := 1 TO 4                
            IF aStExStru[ nFlds, nProp] # aStruct[ nFlds, nProp ]
               lRVal := .F.
               EXIT FOR
            ENDIF ...
         NEXT nProp
         IF !lRVal
            EXIT FOR
         ENDIF         
      NEXT nFlds
       
   ENDIF FILE( cStETNam )
   
   DBSELECTAR( ( nCurSel ) )              
   
RETU lRVal // StExTValid()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
