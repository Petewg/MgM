#include "DBA.ch"

PROC T_MdfFormat()
   TODO()
RETU // T_MdfFormat()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC T_MdfView() 
   TODO()
RETU // T_MdfView() 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC T_MdfQuery()
   TODO()
RETU // T_MdfQuery()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC T_MdfReport()
   TODO()
RETU // T_MdfReport()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC T_MdfLabel()
   TODO()
RETU // T_MdfLabel()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC T_MdfText()
   TODO()
RETU // T_MdfText()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_MdfTable()                         // Modify Table Structure

   LOCA aStruct  := DBSTRUCT(),;
        aNewStru := {},;
        aDBFInf  := { aOpnDatas[ nCurDatNo, 4 ],;                   // 1. file name
                      LUPDATE(),;                                   // 2. Last Modification Date
                      LASTREC(),;                                   // 3. Record Count
                      RECSIZE(),;                                   // 4. Record Length
                      FCOUNT() },;                                  // 5. Field Count
        cTablDir  := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTmpFNam  := '',;
        nWAreaNo  := SELE(),;
        cCurFFNm  := aOpnDatas[ nCurDatNo, 3 ],;
        cAlias    := aOpnDatas[ nCurDatNo, 2 ],;
        cOldFFNm  := '',;
        nOldFNum  :=  1,;
        cMOldFNam := '',;
        cMNewFNam := '',;
        cMemoFNam := '',;
        cMemoTFNm := ''
        
* MsgMulty( RDDNAME() )
                
   IF !EMPTY( ( aNewStru := DBStructOps( aStruct, 2, aDBFInf ) ) )
   
      cTmpFNam := TempFile( cTablDir, 'dbf' )
      
      DBCREATE( cTmpFNam, aNewStru )
      ClosData(,"C")
      USE ( cTmpFNam ) ALIAS ( cAlias )  
      APPEND FROM ( cCurFFNm )
      USE
      cOldFFNm := STRTRAN( cCurFFNm, '.', '_old.' )
      WHIL FILE( cOldFFNm ) 
         cOldFFNm := STRTRAN( cCurFFNm, '.', '_old' + LTRIM(STR( ++nOldFNum )) + '.' )
      ENDDO   
      
      RENAME ( cCurFFNm ) TO ( cOldFFNm ) 
      RENAME ( cTmpFNam ) TO ( cCurFFNm ) 
      
      cMOldFNam := ChangFExtn( cCurFFNm, 'dbt' )
      
      IF FILE( cMOldFNam )
         RENAME ( cMOldFNam ) TO ( ChangFExtn( cOldFFNm, 'dbt' ) )
      ENDIF
      
      cMOldFNam := ChangFExtn( cCurFFNm, 'fpt' )
      IF FILE( cMOldFNam )
         RENAME ( cMOldFNam ) TO ( ChangFExtn( cOldFFNm, 'fpt' ) )
      ENDIF
      
      cMNewFNam := ChangFExtn( cTmpFNam, 'dbt' )
      IF FILE( cMNewFNam )
         RENAME ( cMNewFNam ) TO ( ChangFExtn( cCurFFNm, 'dbt' ) ) 
      ENDIF
      
      cMNewFNam := ChangFExtn( cTmpFNam, 'fpt' )
      IF FILE( cMNewFNam )
         RENAME ( cMNewFNam ) TO ( ChangFExtn( cCurFFNm, 'fpt' ) ) 
      ENDIF      
            
      Open1Tabl( cCurFFNm ) 
      
   ENDIF ...
   

RETU // T_MdfTable()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ChangFExtn( cFileName, cFileExtn )

   LOCA cRVal := ''

   IF EMPTY( cFileName ) .OR. EMPTY( cFileExtn )
      cRVal := cFileName
   ELSE
      IF '.' $ cFileName
         cRVal := LEFT( cFileName, AT( '.', cFileName ) ) + cFileExtn        
      ELSE
         cRVal := cFileName + "." + cFileExtn        
      ENDIF '.' $ cFileName  
   ENDIF EMPTY( cFileName ) .OR. EMPTY( cFileExtn )
      
       
RETU cRVal // ChangFExtn()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
