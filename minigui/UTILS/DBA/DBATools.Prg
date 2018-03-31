#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_CopyFile() 
   TODO()
RETU // F_CopyFile() 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_Directory()
   TODO()
RETU // F_Directory()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_Rename()   
   TODO()
RETU // F_Rename()   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_Erase()    
   TODO()
RETU // F_Erase()    
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_ListStru() 
   TODO()
RETU // F_ListStru() 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_Import()   
   TODO()
RETU // F_Import()   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
PROC F_Export()   
   TODO()
RETU // F_Export()   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FindStrg()                           // Search a string into file(s)
   *
   *
   *  TODO : include sub-dirs
   *
   *
   
   LOCA lIncLiNo := .T.,;
        lIngCase := .T.,;
        lOnlCoun := .F.
         
   DEFINE WINDOW frmFindStrg ;
      AT     0,0 ;
      WIDTH  380 ;
      HEIGHT 160 ;             
      TITLE  "Find a String into File(s)" ; 
      MODAL 

      ON KEY ESCAPE ACTION frmFindStrg.Release
            
      @ 25, 25 LABEL lblGetStrg VALUE "String to search : "

      DEFINE TEXTBOX txbGetStrg
         ROW     21
         COL    125
         WIDTH  220
         FONTNAME "FixedSys"
         FONTSIZE 10
         ON ENTER FndStrAply( this.Value, lIncLiNo, lIngCase, lOnlCoun )
      END TEXTBOX 
            
      @ 55,  25 CHECKBOX cbxLinNum CAPTION "Include Line Nums"  VALUE .T. ON CHANGE { || lIncLiNo := this.value } WIDTH 129 
      @ 55, 165 CHECKBOX cbxIgnCas CAPTION "Ignore Case"        VALUE .T. ON CHANGE { || lIngCase := this.value }
      @ 55, 265 CHECKBOX cbxCouOnl CAPTION "Only Count"         VALUE .F. ON CHANGE { || lOnlCoun := this.value }
            
      DEFINE BUTTON btnApply 
         ROW 95 
         COL 170
         CAPTION "Apply" 
         ACTION  FndStrAply( frmFindStrg.txbGetStrg.Value, lIncLiNo, lIngCase, lOnlCoun )
         WIDTH   60 
         HEIGHT  21
      END BUTTON // btnApply 
      
   END WINDOW // frmFindStrg

   CENTER   WINDOW frmFindStrg
   ACTIVATE WINDOW frmFindStrg
   
   
RETU // FindStrg()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC FndStrAply(;                           // Apply rutin for FindStrg()
                cSrchStr ,;
                lIncLiNo ,;
                lIngCase ,;
                lOnlCoun )

   LOCA aFiles   := {},;
        c1FilNam := '',;
        cFilStrg := '',;
        cResStrg := '',;
        nFileNum :=  0,;
        c1Line   := '',;
        nLineNum :=  0,;
        nFindCou :=  0

   IF !EMPTY( cSrchStr )
   
      aFiles := GetFile ( {{ "Files to search", "*.pr*;*.fmg" }}, "Select File(s)", cLastCDir, .T., .T. )

      IF !EMPTY( aFiles )
      
         LastUsed( aFiles[ 1], 'C' )
      
         cSrchStr := IF( lIngCase, UPPER( cSrchStr ), cSrchStr )
         
         FOR nFileNum := 1 TO LEN( aFiles )
            c1FilNam := aFiles[ nFileNum ]
            cResStrg += REPL( "-", 10 ) + ExOFNFFP( c1FilNam ) + CRLF
            cFilStrg := MEMOREAD( c1FilNam )
            nLineNum :=  0
            nFindCou :=  0
            
            WHILE !EMPTY( cFilStrg )
               c1Line := ExtrcSFS( @cFilStrg, CRLF )
               ++nLineNum
               IF !EMPTY( c1Line )
                  IF cSrchStr $ IF( lIngCase, UPPER( c1Line ), c1Line )
                     IF lOnlCoun 
                        ++nFindCou 
                     ELSE
                        cResStrg += IF( lIncLiNo, "[" + STR( nLineNum, 5 ) + "]",'') + c1Line + CRLF
                     ENDIF lOnlCoun 
                  ENDIF cSrchStr $ c1Line
               ENDIF !EMPTY( c1Line )
            ENDDO !EMPTY( cFilStrg )
            IF lOnlCoun 
               cResStrg += LTRIM( STR( nFindCou ) ) + " occurence" + IF( nFindCou > 1, 's','') + " found." + CRLF
            ENDIF lOnlCoun 
         NEXT nFileNum     
         
         SayBekle( cResStrg, "Find String into file(s)" )
         
      ENDIF !EMPTY( aFiles )
      
   ENDIF !EMPTY( cSrchStr )

RETU // FndStrAply()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC SetUPrefers()                            // Set User Preferences
   LOCA cPrefFNm := cProgFold + "\" + SUBS( PROCNAME(), 4 ) + ".lst",;
        cPrefStr := '',;
        cPVarNam := '',;
        lPValVal := .F.,;
        nVInd    :=  0,;
        c1VarNam := '',;
        lNew     := .F.

   IF FILE( cPrefFNm  )  
      cPrefStr := MEMOREAD( cPrefFNm )
      IF EMPTY( cPrefStr )
         cPrefStr := UsPVals2Str()
         lNew := .T.
      ENDIF EMPTY( cPrefStr ) 
      FOR nVInd := 1 TO LEN( cPrefStr )
         c1VarNam := "lPref01" + STRZERO( nVInd, 2 )
         lPValVal := ASC( SUBS( cPrefStr, nVInd, 1 ) ) > 0
         &c1VarNam := lPValVal 
      NEXT nVInd 
   ELSE
      cPrefStr := UsPVals2Str()
      lNew := .T.
   ENDIF FILE( cPrefFNm  )  
   IF lNew
      MEMOWRIT( cPrefFNm, cPrefStr )
   ENDIF
RETU // SetUPrefers()   
      

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC UsPVals2Str()                        // User Preferences Values to String
               
   LOCA cRVal    := '',;
        nVInd    :=  0,;
        c1VarNam := '',;
        l1Value  := .F. 
        
   FOR nVInd := 1 TO LEN( aUPPromts )
      c1VarNam := "lPref01" + STRZERO( nVInd, 2 )
      cRVal    += CHR( IF( "U" $ TYPE( c1VarNam ), 0, IF( &c1VarNam, 1, 0 ) ) )  
   NEXT nVInd 
   
RETU cRVal // UsPVals2Str()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GFUUPrefers()                        // Get From User, User Preferences

   LOCA cPrefFNm := cProgFold + "\" + SUBS( PROCNAME(), 4 ) + ".lst"
   
   LOCA cPrefStr  := MEMOREAD( cPrefFNm ),;
        aUPrefrs  := {},;
        c1VarNam  := '',;
        lPValVal  := '',;
        nUPInd    :=  0,;
        nVInd     :=  0,;
        nResultCF :=  0
        
   LOCA cCbFTitl := "Set User Preferences" ,; 
        aLabels  := {},;
        aValues  := {},;
        aButtons := {{ ,;               // 1. Button Length : NIL for non-pict caption
                      "Apply Only",;    // 2. Button Caption
                      "",;              // 3. Button Tooltip
                        ,;              // 4. Check Acceptences
                      .T.,;             // 5. Save Before 
                        ,;              // 6. No Action
                      .T. },;           // 7. Release After     
                     { ,;               // 1. Button Length : NIL for non-pict caption
                      "Apply and Save",;  // 2. Button Caption
                      "",;              // 3. Button Tooltip
                        ,;              // 4. Check Acceptences
                      .T.,;             // 5. Save Before 
                        ,;              // 6. No Action
                      .T. },;           // 7. Release After     
                     { ,;               // 1. Button Length : NIL for non-pict caption
                      "Cancel",;        // 2. Button Caption
                      "",;              // 3. Button Tooltip
                        ,;              // 4. Check Acceptences
                        ,;              // 5. Save Before 
                        ,;              // 6. No Action
                      .T. }}            // 7. Release After     

   FOR nUPInd := 1 TO LEN( aUPPromts )
      AADD( aLabels, aUPPromts[ nUPInd ] )
      c1VarNam := "lPref01" + STRZERO( nUPInd, 2 )
      AADD( aValues, &c1VarNam )
   NEXT nUPInd 
   
   nResultCF := ComboForm( cCbFTitl,;  // Combo Form's Title
                           aLabels ,;  // Prompts
                           aValues ,;  // Data Values 
                                   ,;  // Data Types
                                   ,;  // Data Widths               
                                   ,;  // Data Decimals
                                   ,;  // Read Onlies
                                   ,;  // Data Validity ( Acceptences ) Infos
                           aButtons,;  // Buttons 
                                    )  // Actions : code blocks for Buttons 
                                    
   IF nResultCF > 0 .AND. nResultCF < 3
      FOR nVInd := 1 TO LEN( aValues )
         c1VarNam := "lPref01" + STRZERO( nVInd, 2 )
         lPValVal := aValues[ nVInd ]
        &c1VarNam := lPValVal 
      NEXT nVInd 
      
      IF nResultCF > 1 // ... and save
         cPrefStr := UsPVals2Str()
         MEMOWRIT( cPrefFNm, cPrefStr )
      ENDIF nResultCF > 1 // ... and save
   ENDIF nResultCF ...
   
RETU // GFUUPrefers()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

