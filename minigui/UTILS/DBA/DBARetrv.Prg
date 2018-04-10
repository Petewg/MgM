#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain 

MEMV nPasdRecs

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_ListRecs()                             // Table List Records

   LOCA aExpress  := {},;
        cExpress  := '',; 
        lIncRecN  := .F.,;
        lIncDelM  := .F.,;
        lHeading  := .F.,;  // SET( "HEADING" ) ???
        aFldNums  := {},;
        nCurResN  := RECN()
        
   LOCA aColumns  := {},;
        nColumnNo :=  0,;
        c1ColExpr := '',;
        c1ColValT := '',;
        x1ColValu := '',;
        n1CFldNum :=  0,;
        n1CFldLen :=  0,;
        n1CFldDec :=  0,;
        b1CWritBl := { || NIL },;
        cLstStrng := '',;
        nRecNoLen := MAX( LEN( LTRIM( STR( LASTREC() ) ) ), 4 ),; 
        cHeadLine := '',;
        x1CValue  
        
   LOCA cCPTitle  := "List records of " + ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        aStruct   := DBSTRUCT(),;
        cExpLst   := ''
                  
   LOCA aComOpts  := {},;
        aComPars  := {},;
        aCondits  := {},;
        aScopes   := {},;
        aCondExps := {}
   
   LOCA cContinue := '',;
        cApply    := '.T.'

   PRIV nPasdRecs :=  0

   AEVAL( DBSTRUCT(), { | a1, i1 | cExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), "; ", '') } )

   aComPars  := { cExpLst,;             // Expressions List
                  { .T., .T., .T. },;   // Del Mark, RecNo, Heads   
                  {  1, '' },;          // FOR/WHILE, Express
                  {  2,  0 } }          // Scope ( ALL/REST/NEXT n/RECORD n )
                     
   aComOpts  := GFUComOpts( aComPars,;  // Values of options
                             'LIST',;   // Command's name
                           { 'ELS',;    // Expressions List
                             'DRH',;    // Del Mark, RecNo, Heads  
                             'CND',;    // Cond (FOR/WHILE)
                             'SCP' } )  // Scope ( ALL/REST/NEXT n/RECORD n )
   IF !EMPTY( aComOpts )
   
      cExpress := aComOpts[ 1 ]
      aCondits := aComOpts[ 3 ]
      aScopes  := aComOpts[ 4 ]
      
      IF EMPTY( cExpress )
         * 
         * Empty Expressions List meant ALL fields
         *
         AEVAL( aStruct , { | a1 | AADD( aExpress, a1[ 1 ] ) } )
      ELSE 
         aExpress  := Lst2Arr( cExpress )
      ENDIF !EMPTY( cExpress )
      
      lIncDelM  := aComOpts[ 2, 1 ]
      lIncRecN  := aComOpts[ 2, 2 ]
      lHeading  := aComOpts[ 2, 3 ]
            
      IF aScopes[ 1 ] < 2 
         * 
         * Empty Scope meant ALL ( in LIST )
         *
         aScopes := {  2,  0 } 
      ENDIF

      aCondExps := Cond2Exps( aScopes, aCondits )  
      
      cContinue := aCondExps[ 1 ] 
      cApply    := aCondExps[ 2 ] 
      
      FOR nColumnNo := 1 TO LEN( aExpress ) 
      
         c1ColExpr := aExpress[ nColumnNo ]
         x1ColValu := &c1ColExpr
         c1ColValT := VALTYPE( x1ColValu )
         n1CFldNum := FIELDPOS( c1ColExpr )
         
         IF n1CFldNum > 0  
            n1CFldLen := aStruct[ n1CFldNum, 3 ] + IF( c1ColValT == "D", 2, 0 )
            n1CFldDec := aStruct[ n1CFldNum, 4 ]
         ELSE
            DO CASE
               CASE c1ColValT == "C"
                  n1CFldLen := LEN( x1ColValu )
                  n1CFldDec := 0
               CASE c1ColValT == "N"
                  n1CFldLen := 10
                  n1CFldDec := 2      // SET( SET_DECIMAL (?) )
               CASE c1ColValT == "L"
                  n1CFldLen := 3
                  n1CFldDec := 0
               CASE c1ColValT == "D"
                  n1CFldLen := 10     // SET( SET_CENT (?) ) 10/8  
                  n1CFldDec := 0
            ENDCASE c1ColValT 
         ENDIF n1CFldNum > 0   

         DO CASE
            CASE c1ColValT == "C"
               b1CWritBl := { | x1, n1 | PAD( x1, n1 ) }
            CASE c1ColValT == "N"
               b1CWritBl := { | x1, n1, n2 | STR( x1, n1, n2 ) }
            CASE c1ColValT == "D"
               b1CWritBl := { | x1, n1 | PADC( DTOC( x1 ), n1 ) }
            CASE c1ColValT == "L"
               b1CWritBl := { | x1 | IF( x1, "Yes", "No " ) }
         ENDCASE c1ColValT                 
                  
         AADD( aColumns, { c1ColExpr, b1CWritBl, n1CFldLen, n1CFldDec } )
         
      NEXT nColumnNo 
      
      IF lHeading  
      
         IF lIncDelM 
            cHeadLine += "Del "
         ENDIF
      
         IF lIncRecN  
            cHeadLine += PADC( "Rec#", nRecNoLen ) + " "
         ENDIF
      
         FOR nColumnNo := 1 TO LEN( aExpress ) 
             aColumns[ nColumnNo, 3 ] := MAX( aColumns[ nColumnNo, 3 ],; 
                                              LEN( aExpress[ nColumnNo ] ) )    
             cHeadLine += PADC( aExpress[ nColumnNo ], aColumns[ nColumnNo, 3 ] ) + " "
         NEXT nColumnNo 
         
         cLstStrng := cHeadLine + CRLF
         
         IF lIncDelM 
            cLstStrng += "--- "
         ENDIF
      
         IF lIncRecN  
            cLstStrng += REPL( "-", nRecNoLen ) + " "
         ENDIF
         
         AEVAL( aColumns, { | a1 | cLstStrng += REPL( "-",  a1[ 3 ] ) + " " } )
         
         cLstStrng += CRLF
         
      ENDIF lHeading  
      
      WHILE &cContinue
      
         IF &cApply
         
            IF lIncDelM 
               cLstStrng += PADC( IF( DELETED(), "*", ' '), 3 ) + " "
            ENDIF
               
            IF lIncRecN  
               cLstStrng += STR( RECN(), nRecNoLen ) + " "
            ENDIF
         
            FOR nColumnNo := 1 TO LEN( aColumns ) 
            
                c1ColExpr := aColumns[ nColumnNo, 1 ]
                b1CWritBl := aColumns[ nColumnNo, 2 ]
                n1CFldLen := aColumns[ nColumnNo, 3 ]
                n1CFldDec := aColumns[ nColumnNo, 4 ]
                x1CValue  := &c1ColExpr
                cLstStrng += EVAL( b1CWritBl, x1CValue, n1CFldLen, n1CFldDec ) + " "
                
            NEXT nColumnNo 
            
            cLstStrng += CRLF
            
         ENDIF
         
         RefrStBar()
         ++nPasdRecs 
         
         DBSKIP()
         
      ENDDO !EOF()
      
      SayBekle( cLstStrng )       

   ENDIF !EMPTY( aComOpts )
   
   DBGOTO( nCurResN )
   
   RefrBrow()
   
RETU // T_ListRecs()   

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_DispEdit( ;                        // Table Display or Edit Record(s)
                 nOperat )   // 1: Display, 2: Edit

   LOCA lDispOnly := nOperat < 2,;
        aOperates := { 'Display', 'Edit' }

   LOCA cCPTitle  := aOperates[ nOperat ] + " records criterieas" ,;
        cDETitle  := aOperates[ nOperat ] + " records of " + ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        aStruct   := DBSTRUCT(),;
        cFldLst   := '',;
        aFldLst   := {},;
        nFldNum   :=  0,;
        nFInd     :=  0,;
        cForClaus := '',;
        nCurRec
        
   LOCA aComPars  := {},;
        aComOpts  := {}
                  
   LOCA aLabels   := {},;
        aDTypes   := {},;
        aWidths   := {},;
        aDecims   := {},;
        aValues   := {},;
        aROnlys   := {},;
        aValids   := {},;
        aButtons  := {},;
        aCdBloks  := {},;
        aRDBloks  := {},;
        aWDBloks  := {},;
        cExpLst   := '',;
        cBlock, bBlock

   AEVAL( DBSTRUCT(), { | a1, i1 | cExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), "; ", '') } )

   aComPars  := { cExpLst,;             // Expressions List
                  {  '' } }             // FOR Express

   aComOpts  := GFUComOpts( aComPars,;  // Values of options
                            aOperates[ nOperat ],;   // Command's name
                           { 'ELS',;    // Expressions List
                             'FOR' } )  // FOR

   IF !EMPTY( aComOpts )

      cFldLst   := aComOpts[ 1 ]
      cForClaus := aComOpts[ 2 ]
      
      IF !EMPTY( cFldLst )

         aDTypes  := {}
         aWidths  := {}
         aDecims  := {}
         aValues  := {}
         aROnlys  := {}
         aValids  := {}

         aFldLst  := Lst2Arr( cFldLst )

         FOR nFInd :=  1 TO LEN( aFldLst )
         
            nFldNum := FIELDPOS( aFldLst[ nFInd ] )
            
            AADD( aLabels, aStruct[ nFldNum, 1 ] )         // Field Name
            AADD( aDTypes, aStruct[ nFldNum, 2 ] )         // Field Type
            AADD( aWidths, aStruct[ nFldNum, 3 ] )         // Field Width
            AADD( aDecims, aStruct[ nFldNum, 4 ] )         // Field Decimal
            AADD( aROnlys, lDispOnly )                     // Is this Data readonly ?

            cBlock  := '{||' + IF( lDispOnly, 'AnyToStr(', '')   +;
                                   'FIELDGET(' + NTrim( nFldNum ) +;
                               IF( lDispOnly, ')','') + ')}'
            bBlock  := &cBlock
            AADD( aRDBloks, bBlock )
            
            IF !lDispOnly
               cBlock  := '{ | x1 | FIELDPUT(' + NTrim( nFldNum ) + ', x1 )}'
               bBlock  := &cBlock
               AADD( aWDBloks, bBlock )
            ENDIF !lDispOnly
            
         NEXT nFInd
/*         
         aButtons := { { 20, "GO_TOP",  "Go to first record",,,    { 108, 1, 6, 107 }    },;
                       { 20, "GO_PREV", "Go to previous record",,, { 108, 3, 6, 107 }    },;
                       { 20, "GO_NEXT", "Go to next record",,,     { 108, 2, 5, 6, 107 } },;
                       { 20, "GO_BOTT", "Go to last record",,,     { 108, 4, 6, 107 }    },;
                       { 20, "EXIT",    "Exit",,,,                              .T. }    }
*/                       
         aButtons := { { , " « ", "Go to first record",,,    { 108, 1, 6, 107 }    },;
                       { , " < ", "Go to previous record",,, { 108, 3, 6, 107 }    },;
                       { , " > ", "Go to next record",,,     { 108, 2, 5, 6, 107 } },;
                       { , " » ", "Go to last record",,,     { 108, 4, 6, 107 }    },;
                       { , " x ", "Exit",,,,                              .T. }    }

         IF lDispOnly
            AEVAL( aButtons, { | a1, i1 | IF( i1 < LEN( aButtons ),;
                             ( ADEL( a1[6], 1 ), ASIZE( a1[6], LEN( a1[6] ) - 1) ), ) } )
         ENDIF lDispOnly

         aCdBloks := { { || DBGOTOP()   },;                                         // 1
                       { || DBSKIP() },;                                            // 2
                       { || DBSKIP(-1) },;                                          // 3
                       { || DBGOBOTTOM() },;                                        // 4
                       { || IF( EOF(), DBSKIP(-1), ) } }                            // 5

         IF lDispOnly
            AADD( aCdBloks, { || RefrStBar() } )                                    // 6
            AADD( aCdBloks, { || CoFoGetData( aValues, aRDBloks ) } )               // 7

         ELSE
            AADD( aCdBloks, { || RefrBrow(), RefrStBar() } )                        // 6
            AADD( aCdBloks, { || CoFoGetData( aValues, aRDBloks ) } )               // 7
            AADD( aCdBloks, { || CoFoPutData( aValues, aWDBloks ) } )               // 8
         ENDIF lDispOnly

         IF !EMPTY( cForClaus )
            nCurRec := RECN()
            SET FILTER TO &cForClaus
            DBGOTOP()
            RefrBrow()
         ENDIF

         ComboForm( cDETitle,;  // Combo Form's Title
                    aLabels ,;  // Field Name
                    aValues ,;  // Field Value : Value
                    aDTypes ,;  // Field Type
                    aWidths ,;  // Field Width
                    aDecims ,;  // Field Decimal
                    aROnlys ,;  // Read Onlies
                    aValids ,;  // Field Validity Code Blocks
                    aButtons,;  // Buttons
                    aCdBloks,;  // Actions : code blocks for Buttons
                    aRDBloks,;  // Data Read ( GET Blocks )
                    aWDBloks )  // Data Write ( PUT Blocks )

         IF !EMPTY( cForClaus )
            SET FILTER TO
            DBGOTO( nCurRec )
         ENDIF
         RefrBrow()
      ENDIF !EMPTY( cFldLst )
   ENDIF !EMPTY( aComOpts )

RETU // T_DispEdit()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Arithm( ;                          // Table arithmetics
               nAriType ) // 1: Sum, 2: Average, 3: Count

   LOCA aComPars  := {},;         
        cCbFTitl  := '',;
        aComOpts  := {},;
        cExpLst   := '',;
        nCurRec   := RECN(),;
        aCondits  := {},;
        aScopes   := {},;
        aCondExps := {},;
        cContinue := '',;
        cApply    := '',;
        nFInd     :=  0,;
        c1FldNam  := '',;
        n1FldNum  := 0,;
        aStruct   := DBSTRUCT(),;
        aFldsSum  := {},;
        aSums     := {},;
        cResult   := '',;
        nCount    :=  0,;
        lContinue := .T.,;
        cFldList, aFldList
        
   PRIV nPasdRecs :=  0

        
   AEVAL( aStruct, { | a1, i1 | IF( a1[ 2 ] # "N", , cExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", '') ) } )

   IF EMPTY( cExpLst ) .AND. nAriType < 3
      MsgStop( "There isn't any NUMERIC field in the current table." )
   ELSE   
   
      cCbFTitl := IF(nAriType<2,"SUM",IF(nAriType<3,"AVERAGE","COUNT")) + " on current table..."
      
      IF nAriType < 3 // SUM/AVER
      
         aComPars  := { cExpLst,;             // FIELDS list    
                        {  1, ''  },;         // FOR/WHILE, Express
                        {  2,  0  } }         // Scope ( ALL/REST/NEXT n/RECORD n )
                     
         aComOpts  := GFUComOpts( aComPars,;  // Values of options
                                  cCbFTitl,;  // Command's name
                                  { 'FLS',;                  // Fields List 
                                   'CND',;                  // FOR Expression
                                   'SCP' } )                // Scope
      ELSE // COUNT
      
         aComPars  := { {  1, ''  },;         // FOR/WHILE, Express
                        {  2,  0  } }         // Scope ( ALL/REST/NEXT n/RECORD n )
                     
         aComOpts  := GFUComOpts( aComPars,;  // Values of options
                                  cCbFTitl,;  // Command's name
                                  { 'CND',;                  // FOR Expression
                                    'SCP' } )                // Scope
      
      ENDIF nAriType 
                                   
   ENDIF
                            
   IF !EMPTY( aComOpts )
      IF nAriType < 3
         cFldList  := aComOpts[ 1 ]
         aFldList  := Lst2Arr( cFldList, ',' )
         FOR nFInd := 1 TO LEN( aFldList )
            c1FldNam := aFldList[ nFInd ]
            n1FldNum := ASCAN( aStruct, { | a1 | a1[ 1 ] == c1FldNam } )
            IF n1FldNum > 0
               IF FIELDTYPE( n1FldNum ) == "N"
                  AADD( aSums, 0 )
                  AADD( aFldsSum, n1FldNum )
               ENDIF        
            ENDIF n1FldNum > 0
         NEXT nFInd  
         IF EMPTY( aSums )
            MsgBox( "Nothing to " + IF( nAriType < 2, "SUM", "AVERAGE" ) )
            lContinue := .F.
         ENDIF
      ENDIF
      IF lContinue
         aCondits  := aComOpts[ 2 - IF( nAriType < 3, 0, 1 ) ]   
         aScopes   := aComOpts[ 3 - IF( nAriType < 3, 0, 1 ) ]   
         aCondExps := Cond2Exps( aScopes, aCondits )  
         cContinue := aCondExps[ 1 ]
         cApply    := aCondExps[ 2 ]
            
         WHILE &cContinue
            IF &cApply
               AEVAL( aFldsSum, { | n1, i1 | aSums[ i1 ] += FIELDGET( n1 ) } )
               ++nCount
            ENDIF &cApply 
            DBSKIP()   
            RefrStBar()
            ++nPasdRecs 
         ENDDO cContinue   
         
         IF nAriType > 2  // Count
            MsgInfo( "Count is : " + NTrim( nCount ), "Result" )        
         ELSE             // Sum, Average, 
            IF nAriType > 1 // Average
               AEVAL( aSums, { | n1, i1 | aSums[ i1 ] := n1 / nCount } )
            ENDIF   
            DispAriths( nAriType, aFldsSum, aSums )
         ENDIF   
         
      ENDIF EMPTY( aSums )
   ENDIF      
   
   DBGOTO( nCurRec )   
   RefrBrow()
   
RETU // T_Sum()    

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC DispAriths( ;                        // Display arithmetic ( sum, average, count (?) ) results
                 nAriType,; 
                 aFldNums,;
                 aResults )
                 
   LOCA aDisplay := {},;
        cTitle   := IF( nAriType < 2, "SUM","Average" ) + " results ",;
        nFInd    := 0,;
        nFldNum  := 0,;
        cFldNam  := 0,;
        nFldLen  := 0,;
        nFldDec  := 0,;
        nMaxLen  := 0,; 
        nMaxDec  := 0,;
        nFrmHig  := LEN( aFldNums ) * 20 + 40,;
        nFrmLen  := 0,;
        cNumPict     ,;
        nRestLen
        
   FOR nFInd := 1 TO LEN( aFldNums )
       nFldNum := aFldNums[ nFInd ]
       cFldNam := FIELD( nFldNum )
       nFldLen := FIELDLEN( nFldNum )
       nFldDec := FIELDDEC( nFldNum )
       nMaxLen := MAX( nMaxLen, nFldLen )
       nMaxDec := MAX( nMaxDec, nFldDec )
       AADD( aDisplay, { cFldNam, aResults[ nFInd ] } )
   NEXT nFInd 
   
   cNumPict := MakePict( nMaxLen+nMaxDec+2, nMaxDec )
   nRestLen := LEN( cNumPict ) * 12
   nFrmLen  := 120 + nRestLen
      
   nFrmHig := MIN( nFrmHig, frmDBAMain.HEIGHT )
  
   DEFINE WINDOW frmDispArt ;
      AT     0,0 ;
      WIDTH  nFrmLen + 4;
      HEIGHT nFrmHig + 4;
      TITLE  cTitle ; // VIRTUAL HEIGHT 800 ;
      MODAL 

      ON KEY ESCAPE         ACTION frmDispArt.Release

      DEFINE GRID grdDispArt
         ROW        2
         COL        2
         WIDTH      nFrmLen
         HEIGHT     nFrmHig
         HEADERS    {'Field','Result' }
         WIDTHS     { 120, nRestLen }
         ITEMS      aDisplay
         FONTNAME  "FixedSys"
         FONTSIZE   10
         ALLOWEDIT  .F.
         
         COLUMNCONTROLS { { 'TEXTBOX',  'CHARACTER' }  ,;
                          { 'TEXTBOX',  'NUMERIC', cNumPict } }
         NOLINES .T.
       END GRID // grdStruct
       
   END WINDOW // grdDispArt

   CENTER   WINDOW frmDispArt
   ACTIVATE WINDOW frmDispArt

RETU // DispAriths()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
   