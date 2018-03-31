
#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC ClosData(;              // Close Current Data   
               cDataType,;   // Data Type ( A : All, T: Table, U: UnKonwn ...
               cClosType )   // Clos Type : A : All, M: Multiple, C : Current 

   LOCA cDatType := '',;
        cTabAlia := '',;
        aDatNum1 := {},;
        aDatNums := {},;
        nDataNum :=  0,;
        nDInd    :=  0,;     // Data indice
        cCDaType := '',;     // Type of Current Data
        aSelData := {},;
        aSelectd := {},;
        a1Data   := {}
        

   DEFAULT cDataType TO "T",;   // Default Data Type is T : Table
           cClosType TO "C"     // Default Data Type is C : Current
           

   DO CASE
      CASE cClosType == "M"  // Multiple
      
         AEVAL( aOpnDatas, { | a1, i1 | IF( cDataType == "A" .OR. cDataType == a1[ 1 ],;
                                            ( AADD( aSelData, ExOFNFFP( a1[ 3 ] ) ),;
                                              AADD( aDatNum1, i1 ) ), ) } )

         aSelectd := GFUSList( aSelData, "Select to close", .T. )

         IF !EMPTY( aSelectd )
            AEVAL( aDatNum1, { | n1, i1 | IF( aSelectd[ i1 ], AADD( aDatNums, n1 ), ) } )
         ENDIF   
         
      CASE cClosType == "C"  // Current
         aDatNums := { nCurDatNo }
      CASE cClosType == "A"  // ALL
      
         AEVAL( aOpnDatas, { | a1, i1 | IF( ( cDataType == "A" .OR. ;
                                          aOpnDatas[ nOpDataCo, 1 ] == cDataType ), ;
                                          AADD( aDatNums, i1 ), NIL ), HB_SYMBOL_UNUSED( a1 ) } ) 

   ENDCASE cClosType 
   
   
   FOR nDInd := 1 TO LEN( aDatNums )
      nDataNum := aDatNums[ nDInd ]
      IF aOpnDatas[ nDataNum, 1 ] == "T"    // Table     
         IF nCurDatNo == nDataNum
            frmDBAMain.brwDBAMain.Release
         ENDIF
         cTabAlia := aOpnDatas[ nDataNum, 2 ]
         IF IsAlInUse( cTabAlia )
            (cTabAlia)->(DBCLOSEAREA())
         ENDIF   
      ENDIF
      aOpnDatas[ nDataNum, 1 ] := "" // Discard
   NEXT nDInd 

   nDInd := 1 
   
   WHILE nDInd <= LEN( aOpnDatas )
   
      a1Data := aOpnDatas[ nDInd ] 
      IF ISARRY( a1Data ) .AND. EMPTY( a1Data [ 1 ] )
         ADEL( aOpnDatas, nDInd )
      ELSE   
         ++nDInd 
      ENDIF 
   ENDDO nDInd 
   
   ArryPack( aOpnDatas  )
   
   aOpnTables := {}
   
   AEVAL( aOpnDatas, { | a1, i1 | IF( ISARRY( a1 ) .AND. a1[1] == "T", ;
                                      AADD( aOpnTables, i1 ), ) } )
   
   nOpDataCo  :=  LEN( aOpnDatas )  // Open Data Count
   nOpTablCo  :=  LEN( aOpnTables ) // Open Table Count
   
   IF EMPTY( nOpDataCo )
      nCurDatNo := 0    
      nCurPagNo := 0    
   ELSE 
      IF !IsInRang( nCurDatNo, 1, nOpDataCo ) 
         nCurDatNo := MAX( MIN( nCurDatNo, nOpDataCo ), 1 ) 
      ENDIF
   ENDIF   
   FB_RefrsAll() 
   RefrMenu()
   ScrnPlay()

RETU // ClosData() 
      
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
