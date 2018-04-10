#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
PROC OpenQuery()      // Open Query
   TODO()
RETU // OpenQuery()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC OpenCatal()      // Open Catalog  
   TODO()
RETU // OpenCatal()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC OpenView()       // Open View
   TODO()
RETU // OpenView() 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC OpenLabel()
   TODO()
RETU // OpenLabel()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC OpenReport()          
   TODO()
RETU // OpenReport()          
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC OpenUKnw()          
   TODO()
RETU // OpenUKnw()          
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
*/

PROC OpenTabl()                           // Open a Table (.dbf) file

   LOCA aTablNams := {},;
        cTablNam  := ''

   IF nOpTablCo < nMaxTablCo
   
      aTablNams := GetFile ( {{ "Table Files", "*.dbf" }} ,;    // File Select Filter 
                          		    "Open Table" ,;               // Get File Window Title
                          		    cLastDDir,;                   // File Find Beginning folder
                          		    .T. ,;                        // Multiple Select
                                  .T. )                         // Change Folder right
   
      IF !EMPTY( aTablNams )
         AEVAL( aTablNams, { | c1 | Open1Tabl( c1 ) } )
      ENDIF !EMPTY( cTablNam )
   ENDIF nOpTablCo < nMaxDataCo   

RETU // OpenTabl()  

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC Open1Tabl( ;                         // Open ( USE ) one table    
                cTablNam,;                
                lWarnOpen )  // 6e27  Prepare for user preferences

   LOCA nDBFValid := DBValidate( cTablNam ),;
        cTabAlia  := '',;
        aBrwFilds := { "IF( DELETED(),0,1 )" },;
        aBrwHeads := { NIL },;
        aBrwJust  := {  0  },;
        aBrwWidts := { 20  },;
        nWorkArea :=  0,;
        cErrMesaj := '',;
        aDBStruct := {},;
        nFErroNum :=  0

   LOCA aFErrMesjs := { {  2, "File not found" },;
                        {  3, "Path not found" },;
                        {  4, "Too many files open" },;
                        {  5, "Access denied" },;
                        {  6, "Invalid handle" },;
                        {  8, "Insufficient memory" },;
                        { 15, "Invalid drive specified"},;
                        { 19, "Attempted to write to a write-protected disk" },;
                        { 21, "Drive not ready" },;
                        { 23, "Data CRC error" },;
                        { 29, "Write fault" },;
                        { 30, "Read fault" },;
                        { 32, "Sharing violation" },;
                        { 33, "Lock Violation" } }

   LOCA cRDDName := "DBF" + IF( FILE( STRTRAN( UPPE( cTablNam ), ".DBF", ".CDX" ) ), "CDX", "NTX" )  // 8B30

   DEFAULT lWarnOpen TO .T.   // Prepare for user preferences

* MsgMulty( RDDLIST() )   

* MsgMulty( { nDBFValid, cRDDName } )   

   IF nDBFValid > 0
      LastUsed( cTablNam, 'D' ) 

      * 
      *  DBSELECTAR() 
      *  Selecting zero: Selecting work area zero causes the lowest
      *  numbered unoccupied work area to become the current work area.
      *
      DBSELECTAR( 0 ) 
      nWorkArea := SELECT()
      cTabAlia := "F" + STRZERO( nWorkArea, 3 )

      DBUSEAREA( .T. ,;        // <lNewArea>, (.T.) selects the lowest numbered unoccupied work area
                 cRDDName,;    // <cDriver>  ( 8830 )   
                 cTablNam,;    // <cName> 
                 cTabAlia,;    // <xcAlias>
                 .F.,;         // <lShared> 
                 .F. )         // <lReadonly>

      IF ALIAS() == cTabAlia // au lieu de USED()

         aDBStruct := DBSTRUCT()

         AEVAL( aDBStruct, { | a1 | ;
                          AADD( aBrwFilds, cTabAlia + "->" + a1[ 1 ] ),;
                          AADD( aBrwHeads, a1[ 1 ] ),;
                          AADD( aBrwJust,  IF( a1[2] # "N", 0, 1 ) ),;
                          AADD( aBrwWidts, DispLeng( a1 ) * 10 ) } )  

         AADD( aOpnDatas, {} )  
         nOpDataCo := LEN( aOpnDatas )
         AADD( aOpnDatas[ nOpDataCo ],   "T" )                   // 1: Type ( T : Table )
         AADD( aOpnDatas[ nOpDataCo ],   cTabAlia )              // 2: Alias
         AADD( aOpnDatas[ nOpDataCo ],   cTablNam )              // 3: Full File Name
         AADD( aOpnDatas[ nOpDataCo ],   ExOFNFFP( cTablNam,;    // 4: Only File Name 
                                                .F., ;              // exlude Extn
                                                .T. ) )             // Squeez name to 8
         AADD( aOpnDatas[ nOpDataCo ], {;                        // 5: File Info
                                       aDBStruct,;                  // 5.1 : Struct
                                       aBrwFilds,;                  // 5.2 : Field List
                                       aBrwHeads,;                  // 5.3 : Headings
                                       aBrwWidts,;                  // 5.4 : Column Widths
                                       aBrwJust  } )                // 5.5 : Justify

         nCurDatNo := LEN( aOpnDatas )  // Current Data No = Open Data Count
         AADD( aOpnTables, nCurDatNo )
         nOpTablCo := LEN( aOpnTables )
         RefrMenu()
         FB_RefrsAll()
      ENDIF ALIAS() == cTabAlia
   ELSE
      cErrMesaj := "Table Open Failure !" + CRLF2 + ;
                   cTablNam  + CRLF2 
      IF nDBFValid == 0      
         cErrMesaj += "Unidentified Table type; highly probably none .dbf."
         *
         * There is an unconcistency in this file; USE anyway, ... 6625
         *
      ELSEIF nDBFValid < 0   
         IF nDBFValid == -2      
            cErrMesaj += "File not found." 
         ELSEIF nDBFValid == -81  
            cErrMesaj += ".dbf with memo, memo file not found."
         ELSEIF nDBFValid == -30 
            cErrMesaj += "Error while reading (Read Fault)"
         ENDIF   
      ELSE        
         nFErroNum := ASCAN( aFErrMesjs, { | a1 | a1[ 1 ] == nDBFValid } )
         IF nFErroNum  > 0
            cErrMesaj += aFErrMesjs[ nFErroNum ]
         ELSE   
            cErrMesaj += "Open Error ( " + NTrim( nDBFValid ) + " )"
         ENDIF nFErroNum  > 0
      ENDIF  
      IF lWarnOpen
         MsgStop( cErrMesaj  )    
      ENDIF   
   ENDIF nDBFValid > 0
                      
RETU // Open1Tabl()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
   
PROC ScrnPlay()                           // Playing on screen 

   LOCA cDatType := '',;
        cTabAlia := '',;
        aReadOns := {}

   IF !EMPTY( aOpnDatas ) .AND. nCurDatNo > 0     
   
      cDatType   := aOpnDatas[ nCurDatNo, 1 ]
      
      DO CASE
         CASE cDatType == "T"    // Table     
      
            IF _IsControlDefined ( "brwDBAMain", "frmDBAMain" )
               frmDBAMain.brwDBAMain.Hide
               frmDBAMain.brwDBAMain.Release
            ENDIF
            
            ON KEY CONTROL+DELETE OF frmDBAMain ACTION T_DeleReca()
            ON KEY CONTROL+INSERT OF frmDBAMain ACTION T_InseReco() 
            
            cTabAlia := aOpnDatas[ nCurDatNo, 2 ]
            
            DBSELECTAR( ( cTabAlia ) )
            
            AEVAL( aOpnDatas[ nCurDatNo, 5, 2 ], { | x1, i1 | AADD( aReadOns, IF( i1 > 1, .F., .T. ) ), HB_SYMBOL_UNUSED( x1 ) } )

            @ 25, 0 BROWSE   brwDBAMain ;
                    OF       frmDBAMain ;
                    WIDTH    nMainWWid - 15 ;
                    HEIGHT   nMainWHig - 105 ;
                    FONT     "FixedSys" ;
                    SIZE     10 ;
                    HEADERS  aOpnDatas[ nCurDatNo, 5, 3 ] ;
                    WIDTHS   aOpnDatas[ nCurDatNo, 5, 4 ] ;
                    WORKAREA &cTabAlia ;
                    FIELDS   aOpnDatas[ nCurDatNo, 5, 2 ] ;
                    JUSTIFY  aOpnDatas[ nCurDatNo, 5, 5 ] ;
                    IMAGE    { "false", "true" } ;
                    ON CHANGE RefrStBar() ;
                    EDIT INPLACE ;
                    READONLY aReadOns PAINTDOUBLEBUFFER
         
            RefrMenu()
            RefrStBar()
            frmDBAMain.brwDBAMain.Setfocus
/*    
         CASE cDatType == "C"    // Catalog 
         CASE cDatType == "V"    // View 
         CASE cDatType == "Q"    // Query
         CASE cDatType == "F"    // Format 
         CASE cDatType == "R"    // Report L/X 
         CASE cDatType == "L"    // Label
*/         
         CASE cDatType == "X"    // Text
      ENDCASE cDatType 
   ENDIF !EMPTY( aOpnDatas )     
               
RETU // ScrnPlay()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

