#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain

REQUEST DESCEND

MEMV nPasdRecs

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_SetIndex()

   LOCA cTablDir := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cNtxFNam := '',;
        nNtxFNum := 0

   LOCA aNtxFils := GetFile ( {{ "Index Files", "*.ntx" }} ,;   // File Select Filter
                                  "Set Index" ,;                // Get File Window Title
                                  cTablDir,;                    // File Find Beginning folder
                                  .T. ,;                        // Multiple Select
                                  .F. )                         // Change Folder right

   IF !EMPTY( aNtxFils )

      IF LEN( aOpnDatas[ nCurDatNo ] ) < 6
         AADD( aOpnDatas[ nCurDatNo ], {} )
      ENDIF

      FOR nNtxFNum := 1 TO LEN( aNtxFils )
         cNtxFNam := aNtxFils[ nNtxFNum ]

         IF ASCAN( aOpnDatas[ nCurDatNo,  6 ], cNtxFNam ) > 0
            MsgInfo( cNtxFNam + CRLF2 + "index already has been setted." )
         ELSE
            DBSETINDEX( cNtxFNam )
            AADD( aOpnDatas[ nCurDatNo, 6 ], cNtxFNam )
         ENDIF ASCAN( ...
      NEXT nNtxFNum
      DBSETORDER( LEN( aOpnDatas[ nCurDatNo,  6 ] ) ) // Always last setted index is active
      RefrBrow()
      RefrMenu()
   ENDIF !EMPTY( aNtxFils )

RETU //  T_SetIndex()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_SetOrder()                         // Table - Set Index Order

   LOCA aNtxKeys := { "Natural" },;
        nNtxNum  := 0

   AEVAL( aOpnDatas[ nCurDatNo, 6 ], { | c1, i1 | AADD( aNtxKeys, INDEXKEY( i1 ) ), HB_SYMBOL_UNUSED( c1 ) } )

   nNtxNum := GFU1Sele( aNtxKeys, "Select index order" )

   IF nNtxNum > 0
      DBSETORDER( nNtxNum - 1 )
      RefrMenu()
      RefrBrow()
   ENDIF nNtxNum > 0

RETU // T_SetOrder()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_ReleIndex()                        // Table Release Indexs

   IF MsgYesNo( "All open indexs will be closed;" + CRLF2 +;
                "          Are you sure ? " )
      SET INDEX TO
      ADEL( aOpnDatas[ nCurDatNo ], 6 )
      ASIZE( aOpnDatas[ nCurDatNo ], LEN( aOpnDatas[ nCurDatNo ] ) - 1 )
      RefrBrow()
      RefrMenu()
   ENDIF

RETU // T_ReleIndex()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Re_Index()                         // Re_Index current table

   LOCA cTablDir := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTblName := ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        aIndxFNs := aOpnDatas[ nCurDatNo, 6 ] ,;
        aNtxKeys := {} ,;
        cNtx1Key := '' ,;
        cNtxFNam := '' ,;
        nNtxFNum := 0  ,;
        aSelects := {} ,;
        aSelectd := {} ,;
        nNtxInd  :=  0 ,;
        nCurOrd  := INDEXORD()

   AEVAL( aIndxFNs, { | c1, i1 | AADD( aNtxKeys, INDEXKEY( i1 ) ) ,;
                                 AADD( aSelects, " ON " + INDEXKEY( i1 )+ ;
                                                 " TO " + ExOFNFFP( c1 ) ) } )
   IF LEN( aSelects ) > 1
      aSelectd := GFUSList( aSelects, "ReIndex " + cTblName, .T. )
   ELSE
      aSelectd := { .T. }
   ENDIF

   IF ASCAN( aSelectd, .T. ) > 0
      SET INDEX TO
      FOR nNtxInd := 1 TO LEN( aSelectd )
         IF aSelectd[ nNtxInd ]
            cNtxFNam := aIndxFNs[ nNtxInd ]
            DBSETINDEX( cNtxFNam  )
            REINDEX                       // EVAL ve EVERY eklenecek ÝBG
         ENDIF aSelectd( nNtxInd )
         SET INDEX TO
      NEXT nNtxInd

      AEVAL( aIndxFNs, { | c1 |  DBSETINDEX( c1 ) } )

      DBSETORDER( nCurOrd )

      RefrBrow()

   ENDIF ASCAN( aSelectd, .T. ) > 0

* MsgBox( "indexing ON " + cNtx1Key + " TO " + cNtxFNam ) // ( Belki ) Sürgü'ye ad olur ...

RETU //  T_Re_Index()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ChekOWrt( cFileName,;
               cFileExtn )

   LOCA lRVal    := .T.,;
        cFileDir := IF( nCurDatNo > 0, ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ), cLastDDir )

   LOCA cFFName  := IF( "\" $ cFileName, cFileName, cFileDir  + "\" + cFileName )

   IF ISCHAR( cFileExtn ) .AND. ! "." $ cFFName
      cFFName += "." + cFileExtn
   ENDIF

   IF lPref0102     // Request user confirmation for file overwriting
      IF FILE( cFFName )
         lRVal := MsgYesNo( cFileName + " File exist;" + CRLF2 +;
                            "Overwrite them ?" )
      ENDIF
   ENDIF lPref0102

RETU lRVal // ChekOWrt()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_NewIndex()                         // Build ( and set ) a NEW index for current table

   LOCA cTablDir  := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTblName  := ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        aIndxFNs  := IF( LEN(aOpnDatas[ nCurDatNo] ) > 5, aOpnDatas[ nCurDatNo, 6 ], {} )

   LOCA aComPars  := {},;
        aComOpts  := {}

   LOCA nFNPInd   := 0,;
        a1CPPar   := {},;
        aValues   := {}

   LOCA cCbFTitl  := "Building a NEW index for " + cTblName,;
        cDfXFName := LEFT( cTblName, RAT( ".", cTblName  ) ) + "NTX"

   LOCA aNtxKeys  := {} ,;
        cNtxFNam  := '',;
        cNtxKey   := '',;
        lUnique   := .F.,;
        cFORExpr  := '',;
        lDesCend  := .F.,;
        nControl  := '',;
        cInvalid  := '',;
        cMessage

   aComPars  := { { cDfXFName, "Index", "*.ntx", .T. },;  // Target ( INDEX )FILE
                    FIELDNAME( 1 ),;                      // Default Index Key
                    '',;                                  // FOR Expression
                    { .F., .F. }}                         // UNIQUE, DESCENDING

   aComOpts  := GFUComOpts( aComPars,;  // Values of options
                            cCbFTitl,;  // Command's name
                           { {'OFN',"Index" },;      // Output file expression
                             {'EXP',"Key" },;        // Expression
                              'FOR',;                // FOR Expression
                              'UND'} )               // UNIQUE, DESCENDING

   IF !EMPTY( aComOpts )

      cNtxFNam := ALLTRIM( aComOpts[ 1 ] )

      IF EMPTY( cNtxFNam )
         MsgStop( "Index File Name must be specified." )
      ELSE
      
         IF ! ( "\" $ cNtxFNam )
            cNtxFNam := cTablDir + "\" + STRTRAN( UPPER( cNtxFNam ), ".DBF", ".NTX" )
         ENDIF ! ( "\" $ cNtxFNam )
      
         cNtxKey := ALLTRIM( aComOpts[ 2 ] )
         
         IF EMPTY( cNtxKey )
            MsgStop( "Index Key Expression must be specified." )
         ELSE
            cFORExpr := ALLTRIM( aComOpts[ 3 ] )
            lUnique  := aComOpts[ 4, 1 ]
            lDesCend := aComOpts[ 4, 2 ]

            SET INDE TO

            nControl  := CTON( IF( lUnique,           "1", "0" ) +;
                               IF( EMPTY( cFORExpr ), "0", "1" ) +;
                               IF( lDesCend,          "1", "0" ), 2 )

            DO CASE

               CASE nControl == 0  // 000 : !lUnique .AND. EMPTY( cFORExpr ) .AND. !lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam

               CASE nControl == 1  // 001 : !lUnique .AND. EMPTY( cFORExpr ) .AND. lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam DESCENDING

               CASE nControl == 2  // 010 : !lUnique .AND. !EMPTY( cFORExpr ) .AND. !lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam FOR &cFORExpr

               CASE nControl == 3  // 011 : !lUnique .AND. !EMPTY( cFORExpr ) .AND. lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam FOR &cFORExpr DESCENDING

               CASE nControl == 4  // 100 : lUnique .AND. !EMPTY( cFORExpr ) .AND. !lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam UNIQUE

               CASE nControl == 5  // 101 : lUnique .AND. !EMPTY( cFORExpr ) .AND. lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam UNIQUE FOR &cFORExpr DESCENDING

               CASE nControl == 6  // 110 : lUnique .AND. !EMPTY( cFORExpr ) .AND. !lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam FOR &cFORExpr UNIQUE

               CASE nControl == 7  // 111 : lUnique .AND. !EMPTY( cFORExpr ) .AND. lDesCend

                  INDEX ON &cNtxKey TO &cNtxFNam FOR &cFORExpr UNIQUE DESCENDING

            ENDCASE nControl

            IF ASCAN( aIndxFNs, cNtxFNam ) < 1
               AADD( aIndxFNs, cNtxFNam )
            ENDIF

            IF LEN( aOpnDatas[ nCurDatNo ] ) < 6
               AADD( aOpnDatas[ nCurDatNo ], {} )
            ENDIF

            aOpnDatas[ nCurDatNo, 6 ] := aIndxFNs

            AEVAL( aIndxFNs, { | c1 |  DBSETINDEX( c1 ) } )

            DBSETORDER( ASCAN( aIndxFNs, cNtxFNam ) )

            RefrBrow()
            RefrMenu()

            cMessage := cTblName + " table indexed"    + CRLF2 +;
                        "ON "    + cNtxKey             + CRLF2 +;
                        "TO "    + ExOFNFFP(cNtxFNam ) + CRLF2 +;
                        "and this index activated."

            MsgInfo( cMessage )

         ENDIF EMPTY( cNtxKey )

      ENDIF EMPTY( cNtxFNam )


   ENDIF !EMPTY( aComOpts )

RETU // T_NewIndex()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Copy_To(;
               nOption ) // 1: Recs, Exact, 2: Recs, Selective, 3: Struct Only, 4: Struct Extend

   LOCA cTablDir  := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTblName  := ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        cNewTNam  := ''

   LOCA aComPars  := {},;
        cCbFTitl  := "Copying " + cTblName + " TO ...",;
        aComOpts  := {},;
        cExpLst   := '',;
        lAskOpen  := .F.,;
        lSuccess  := .F.

   IF nOption # 2  // Recs, exact

      aComOpts  := GFUComOpts( { { SPAC( 256 ), "Table", "*.dbf", .F. } },;
                               cCbFTitl,;
                               { { 'OFN',"Target " } } )
   ELSE   // Recs, Selective
      AEVAL( DBSTRUCT(), { | a1, i1 | cExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", '') } )
      aComPars  := { cExpLst,;             // FIELDS list
                     {  1, ''  },;         // FOR/WHILE, Express
                     {  2,  0  },;         // Scope ( ALL/REST/NEXT n/RECORD n )
                     {  1, ''  },;         // Target FILE Type : 1: Table
                     { SPAC( 256 ), "Table", "*.dbf", .F. } }  // Target FILE

      aComOpts  := GFUComOpts( aComPars,;  // Values of options
                               cCbFTitl,;  // Command's name
                               { 'FLS',;                  // Fields List
                                 'CND',;                  // FOR Expression
                                 'SCP',;                  // Scope
                                 'TFT',;                  // Target FILE Type
                                 { 'OFN',"Target " } } )  // Output file expression

   ENDIF nOption # 2  // Recs, Selective

   IF !EMPTY( aComOpts )

      cNewTNam := aComOpts[ 1 ]
      
      IF ! "\" $ cNewTNam
         cNewTNam := cLastDDir + "\" + cNewTNam
      ENDIF 
      
* MsgMulty( cNewTNam )
      
      IF nOption # 2
         DO CASE
            CASE nOption == 1 // Recs, Exact
               COPY TO &cNewTNam
            CASE nOption == 3 // Struct Only
               COPY STRU TO &cNewTNam
            CASE nOption == 4 // Struct Extend
               COPY STRU EXTE TO &cNewTNam
         ENDCASE
         lAskOpen := lSuccess := FILE( cNewTNam )

      ELSE // Recs, Selective

         cNewTNam := aComOpts[ 5 ]

         IF CopyToBe( aComOpts ) // Copied
            lAskOpen := ( aComOpts[ 4, 1 ] == 1 ) // TFT : Table
         ENDIF CopyToBe( ...

      ENDIF nOption # 2

      IF lAskOpen
         IF MsgYesNo( "Table copied;" + CRLF2 + "Open it now ?" )
            Open1Tabl( cNewTNam )
         ENDIF
      ENDIF

   ELSE
      MsgInfo( "Escaped." )
   ENDIF !EMPTY( aComOpts )

RETU // T_CopyTo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CopyToBe( aOptions )                 // to be or not to be !..

   LOCA cExpLst  := aOptions[ 1 ],;
        aCondits := aOptions[ 2 ],;  // 1: Condition No :  1: None, 2: FOR, 3: WHILE; 2:Condition String ( IF nCondit > 1 )
        aScopes  := aOptions[ 3 ],;  // 1: Scope No : 1: No (ALL), 1: ALL, 2: REST, 3: NEXT, 4: RECORD (NO); Scope Count ( or No ) ( IF nScope > 2 );
        nTFType  := aOptions[ 4, 1 ],;  // Target File Type : 1: Table, 2: SDF, 3: DELI, 4: DELI WITH
        cDlmWith := aOptions[ 4, 2 ],;  // Delimiter ( IF cDlmWith > 3 )
        cNewTNam := aOptions[ 5 ],;
        cTmpFNam := ''

   LOCA lTextOut := ( nTFType > 1 ),;
        cTextOut := '',;
        nCurResN := RECN()

   LOCA lRVal    := .F.,;
        aNewStru := Lst2Arr( cExpLst, ',' ),;
        aOldStru := DBSTRUCT(),;
        cCurTNam := aOpnDatas[ nCurDatNo, 3 ]  // Current Table Name

   LOCA aCondExps := Cond2Exps( aScopes, aCondits )

   LOCA cContinue := aCondExps[ 1 ],;
        cApply    := aCondExps[ 2 ],;
        cCAlias   := ALIAS(),;            // Current Alias
        nFInd     := 0,;  // Field indice
        cFldNam       ,;  // Field Name
        nFldNum   := 0    // Field Number

   PRIV nPasdRecs :=  0

   FOR nFInd  := 1 TO LEN( aNewStru )
      cFldNam := aNewStru[ nFInd ]
      nFldNum := ASCAN( aOldStru, { | a1 | a1[ 1 ] == cFldNam } )
      IF nFldNum > 0
         aNewStru[ nFInd ] := aOldStru[ nFldNum ]
      ENDIF nFldNum > 0
   NEXT

   DBCREATE( cNewTNam, aNewStru )
   USE ( cNewTNam ) ALIA NEWT NEW

   DBSELECTAR( cCAlias )

   WHILE &cContinue

      IF &cApply
         DBSELECTAR( "NEWT" )
         DBAPPEND()
         FOR nFInd := 1 TO LEN( aNewStru )
            nFldNum := ASCAN( aOldStru, { | a1 | a1[ 1 ] == aNewStru[ nFInd, 1 ] } )
            IF nFldNum > 0
               FIELDPUT( nFInd, (cCAlias)->(FIELDGET( nFldNum )) )
            ENDIF
         NEXT nFInd
      ENDIF &cApply

      DBSELECTAR( cCAlias )
      DBSKIP()

      RefrStBar()
      ++nPasdRecs

   ENDDO cContinue

   DBSELECTAR( "NEWT" )

   IF lTextOut
      cTmpFNam := TempFile( cBegFoldr )
      DO CASE
         CASE nTFType == 2
            COPY TO &cTmpFNam SDF
         CASE nTFType == 3
            COPY TO &cTmpFNam DELIMITED
         CASE nTFType == 4
            COPY TO &cTmpFNam DELIMITED WITH BLANK
         CASE nTFType == 5
            COPY TO &cTmpFNam DELIMITED WITH &cDlmWith
      ENDCASE
      USE
      ERAS ( cNewTNam )
      RENA &cTmpFNam TO &cNewTNam
   ELSE
      USE // NEWT
   ENDIF

   lRVal := FILE( cNewTNam )

   DBSELECTAR( cCAlias )
   DBGOTO( nCurResN )

RETU lRVal // CopyToBe()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
     SORT TO <xcDatabase> ON <idField> [/[A | D][C]]
        [, <idField2> [/[A | D][C]]...]
        [<scope>] [WHILE <lCondition>] [FOR <lCondition>]
*/
PROC T_Sort()                             // Table SORT

   LOCA aComPars  := {},;
        cCbFTitl  := 'SORT current table',;
        aComOpts  := {},;
        cKExpLst  := '',;
        cFldList  := '',;
        cKeyExprs := '',;
        nCurWArea := SELECT(),;
        nCurRec   := RECN(),;
        cNewTNam  := '',;
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
        aCopOptns := {}

   LOCA c1Key ,;
        c1Fld ,;
        c1Swt ,;
        c2Swt ,;
        lDescend ,;
        lUpper ,;
        nFldNum ,;
        cFldType ,;
        nFldLen ,;
        nFldDec ,;
        cFldExp ,;
        cTmpFNam ,;
        cTmpXNam

   PRIV nPasdRecs :=  0

   AEVAL( aStruct, { | a1, i1 | IF( a1[ 2 ] # "M", cKExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", ''), ) } )

   IF EMPTY( cKExpLst )
      MsgStop( "There isn't any KEY-able field in the current table." )
   ELSE

      aComPars  := { { SPAC( 256 ), "Table", "*.dbf", .F. },; // Target FILE
                     cKExpLst,;                                // FIELDS list
                     {  1, ''  },;                            // FOR/WHILE, Express
                     {  2,  0  } }                            // Scope ( ALL/REST/NEXT n/RECORD n )

      aComOpts  := GFUComOpts( aComPars,;  // Values of options
                               cCbFTitl,;  // Command's name
                               { { 'OFN',"Target " },;  // Output file expression
                                 'KLS',;                // Key List
                                 'CND',;                // FOR Expression
                                 'SCP'  } )             // Scope

   ENDIF EMPTY( cExpLst )

   IF !EMPTY( aComOpts )

       cNewTNam := aComOpts[ 1 ]
       cKExpLst := aComOpts[ 2 ]

       WHILE !EMPTY( cKExpLst )
          c1Key := ALLTRIM( ExtrcSFS( @cKExpLst, ',' ) )
          c1Fld := ALLTRIM( ExtrcSFS( @c1Key, "/" ) )
          c1Swt := ALLTRIM( ExtrcSFS( @c1Key, "/" ) )
          c2Swt := ALLTRIM( ExtrcSFS( @c1Key, "/" ) )
          IF EMPTY( c2Swt )
             c2Swt := c1Swt
          ENDIF
          lDescend := !EMPTY( c1Swt ) .AND. UPPER( c1Swt ) == "D"
          lUpper   := !EMPTY( c2Swt ) .AND. UPPER( c2Swt ) == "C"
          nFldNum  := ASCAN( DBSTRUCT(), { | a1 | c1Fld == a1[ 1 ] } )
          cFldType := FIELDTYPE( nFldNum )
          DO CASE
             CASE cFldType == "N"
                nFldLen := FIELDLEN( nFldNum )
                nFldDec := FIELDDEC( nFldNum )
                cFldExp := "STR(" + c1Fld + "," + NTrim( nFldLen ) + "," + NTrim( nFldDec ) + ")"
             CASE cFldType == "L"
                cFldExp := "IF(" + c1Fld + ",'T','F')"
             CASE cFldType == "D"
                cFldExp := "DTOS(" + c1Fld + ")"
             OTHE
                cFldExp := c1Fld
          ENDCASE

          cFldExp := IF( lUpper,   "UPPER("   + cFldExp + ")", cFldExp )
          cFldExp := IF( lDescend, "DESCEND(" + cFldExp + ")", cFldExp )

          cKeyExprs += cFldExp + " + "

       ENDDO

       cKeyExprs := LEFT( cKeyExprs, LEN( cKeyExprs ) - 3 )

       IF VALTYPE( cKeyExprs ) # "C"
          MsgStop( "Unrecognized key expression : " + CRLF2 + cKeyExprs )
       ELSE
          *
          * Phase #1 : Copy to temp
          *
          AEVAL( aStruct, { | a1, i1 | cFldList += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", '') } )

          aCondits := aComOpts[ 3 ]
          aScopes  := aComOpts[ 4 ]

          cTmpFNam := TempFile( GetTempFolder () )

          aCopOptns := { cFldList,;  // (Full) Field List
                         aCondits,;  // Conditions ( FOR/WHILE )
                         aScopes,;   // Scope
                         { 1, },;    // File Type ( 1: Table )
                         cTmpFNam }  // Target File Name

          IF CopyToBe( aCopOptns )
             *
             * Phase #2 : Index temp on cKeyExprs
             *
             USE ( cTmpFNam ) NEW ALIA TEMP
             cTmpXNam := TempFile( GetTempFolder () )
             INDEX ON &cKeyExprs TO ( cTmpXNam )
             *
             * Phase #3 : Copy temp to resulting output file
             *
             COPY TO ( cNewTNam )
             USE
             DBSELECTAR(( nCurWArea ))
             *
             * Phase #4 : Wipe out temp
             *
             ERAS ( cTmpFNam )
             ERAS ( cTmpXNam )
             *
             * Phase #5 : Ask Open
             *
             IF MsgYesNo( "Table sorted;" + CRLF2 + "Open it now ?" )
                Open1Tabl( cNewTNam )
             ENDIF
          ELSE
             MsgStop( "Undetermined file operation."  )
          ENDIF CopyToBe( aCopOptns )
       ENDIF VALTYPE( cKeyExprs ) # "C"
   ENDIF !EMPTY( aComOpts )

RETU // T_Sort()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


/*
     TOTAL ON <expKey> FIELDS <idField list>
        TO <xcDatabase>
        [<scope>] [WHILE <lCondition>] [FOR <lCondition>]
*/

PROC T_Total()                            // Table TOTAL
   LOCA aComPars  := {},;
        cCbFTitl  := 'TOTAL current table',;
        aComOpts  := {},;
        cNExpLst  := '',;
        cFldList  := '',;
        cKeyExprs := '',;
        nCurWArea := SELECT(),;
        nCurRec   := RECN(),;
        cNewTNam  := '',;
        aCondits  := {},;
        aScopes   := {},;
        aCondExps := {},;
        cContinue := '',;
        cApply    := '',;
        cCAlias   := '',;
        nFInd     :=  0,;
        c1FldNam  := '',;
        n1FldNum  := 0,;
        aStruct   := DBSTRUCT(),;
        aFldLst1  := {},;   // User supplied
        aFldLst2  := {},;   // Checked all Numeric
        aTotals   := {},;
        cResult   := '',;
        nCount    :=  0,;
        lContinue := .T.,;
        aCopOptns := {},;
        nKExprLen :=  0,;
        aNewStruc := {},;
        cKeyCur   := '',;
        cKeyOld   := ''

   PRIV nPasdRecs :=  0

   AEVAL( aStruct, { | a1, i1 | IF( a1[ 2 ] # "N", ,cNExpLst += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", '') ) } )

   IF EMPTY( cNExpLst )
      MsgStop( "There isn't any NUMERIC field in the current table." )
   ELSE

      aComPars  := { SPAC( 256 ),;                            // expKey
                     { SPAC( 256 ), "Table", "*.dbf", .F. },; // Target FILE
                     cNExpLst,;                               // FIELDS list
                     {  1, ''  },;                            // FOR/WHILE, Express
                     {  2,  0  } }                            // Scope ( ALL/REST/NEXT n/RECORD n )

      aComOpts  := GFUComOpts( aComPars,;  // Values of options
                               cCbFTitl,;  // Command's name
                               { { 'EXP', 'Key' },;     // expKey
                                 { 'OFN',"Target " },;  // Output file expression
                                 'FLS',;                // Key List
                                 'CND',;                // FOR Expression
                                 'SCP'  } )             // Scope

   ENDIF EMPTY( cExpLst )

   IF !EMPTY( aComOpts )

      cFldList  := aComOpts[ 3 ]

      aFldLst1  := Lst2Arr( cFldList, ',' )

      FOR nFInd := 1 TO LEN( aFldLst1 )
        c1FldNam  := ALLTRIM( aFldLst1[ nFInd ] )
        n1FldNum  := ASCAN( aStruct, { | a1 | c1FldNam == a1[ 1 ] } )
        IF n1FldNum > 0 .AND. FIELDTYPE( n1FldNum ) == "N"
           AADD( aFldLst2, n1FldNum )
        ENDIF
      NEXT nFInd

      IF EMPTY( aFldLst2 )
         MsgStop( "There isn't any NUMERIC field in supplied field list." )
      ELSE
         cKeyExprs := aComOpts[ 1 ]
         cNewTNam  := aComOpts[ 2 ]
         aCondits  := aComOpts[ 4 ]
         aScopes   := aComOpts[ 5 ]
         aCondExps := Cond2Exps( aScopes, aCondits )
         cContinue := aCondExps[ 1 ]
         cApply    := aCondExps[ 2 ]
         cCAlias   := ALIAS()               // Current Alias
         aTotals   := ARRAY( LEN( aFldLst2 ) )
         AFILL( aTotals, 0 )

         nKExprLen := LEN( &cKeyExprs )

         aNewStruc := { { "TOTAL_KEY", "C", nKExprLen, 0 } }

         FOR nFInd := 1 TO LEN( aFldLst2 )
            n1FldNum := aFldLst2[ nFInd ]
            AADD( aNewStruc, { FIELDNAME( n1FldNum ),;
                               FIELDTYPE( n1FldNum ),;
                               FIELDLEN(  n1FldNum ),;
                               FIELDDEC( n1FldNum ) } )
         NEXT nFInd

         DBCREATE( cNewTNam, aNewStruc )
         USE ( cNewTNam ) ALIA TOTL NEW

         DBSELECTAR( cCAlias )

         cKeyCur := cKeyOld := &cKeyExprs

         WHILE &cContinue

            IF &cApply
               IF cKeyCur # cKeyOld
                  DBSELECTAR( "TOTL" )
                  DBAPPEND()
                  FIELDPUT( 1, cKeyOld )
                  AEVAL( aFldLst2, { | n1, i1 | FIELDPUT( i1 + 1, aTotals[ i1 ] ), HB_SYMBOL_UNUSED( n1 ) } )
                  cKeyOld := cKeyCur
                  AFILL( aTotals, 0 )
               ENDIF cKeyCur # cKeyOld
            ENDIF &cApply

            DBSELECTAR( cCAlias )
            AEVAL( aFldLst2, { | n1, i1 | aTotals[ i1 ] += FIELDGET( n1 ) } )
            DBSKIP()

            cKeyCur := &cKeyExprs

            RefrStBar()
            ++nPasdRecs

         ENDDO cContinue

         DBSELECTAR( "TOTL" )
         DBAPPEND()
         FIELDPUT( 1, cKeyOld )
         AEVAL( aFldLst2, { | n1, i1 | FIELDPUT( i1 + 1, aTotals[ i1 ] ), HB_SYMBOL_UNUSED( n1 ) } )
         DBCLOSEAREA()
         
         DBSELECTAR( cCAlias )
         DBGOTO( nCurRec )
         RefrBrow()

         IF MsgYesNo( "Total table builded;" + CRLF2 + "Open it now ?" )
            Open1Tabl( cNewTNam )
         ENDIF

      ENDIF EMPTY( aFldLst2 )
      
   ENDIF !EMPTY( aComOpts )


RETU //  T_Total()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Copy_Spec()                        // Copy (Current Table) to Special
   

   LOCA cTablDir  := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTblName  := ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] )

   LOCA cfrmTitle := "Options for COPY SPECIAL " +  cTblName + " TO ...",;
        cTFName   := IF( "." $ cTblName, STRTRAN( UPPER( cTblName ), "DBF", "TXT" ), cTblName + ".TXT" ) 

   LOCA aStruct   := DBSTRUCT(),;
        cFldList  := ''
   
   AEVAL( aStruct, { | a1, i1 | cFldList += a1[ 1 ] + IF( i1 < FCOUNT(), ", ", '') } )
                
    DEFINE WINDOW frmCopySpec;
        AT     154, 284;
        WIDTH  550; 
        HEIGHT 466; 
        TITLE cfrmTitle; 
        MODAL ;
        CURSOR NIL; 
        ON INIT InitCopSel(); 
        ON RELEASE Nil; 
        ON SIZE Nil 
        
        ON KEY ESCAPE ACTION frmCopySpec.Release
    
        DEFINE LABEL lblFields
            ROW    40
            COL    30
            WIDTH  90
            HEIGHT 20
            VALUE "Fields"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE LABEL lblCond
            ROW    80
            COL    40
            WIDTH  110
            HEIGHT 20
            VALUE "Condition"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            CENTERALIGN .T. 
        END LABEL
    
        DEFINE LABEL lblScope
            ROW    120
            COL    30
            WIDTH  90
            HEIGHT 20
            VALUE "Scope"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE LABEL lblTFN
            ROW    200
            COL    20
            WIDTH  100
            HEIGHT 20
            VALUE "Target File Name"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE LABEL lblTFT
            ROW    160
            COL    20
            WIDTH  100
            HEIGHT 20
            VALUE "Target File Type"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE TEXTBOX txbFields
            ROW    40
            COL    140
            WIDTH  260
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE cFldList
        END TEXTBOX
    
        DEFINE COMBOBOX combCond
            ROW    80
            COL    140
            WIDTH  140
            HEIGHT 100
            ITEMS {""}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE COMBOBOX combScope
            ROW    120
            COL    140
            WIDTH  140
            HEIGHT 80
            ITEMS {""}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE COMBOBOX combTFT
            ROW    160
            COL    140
            WIDTH  140
            HEIGHT 100
            ITEMS {""}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE TEXTBOX txbTFN
            ROW    200
            COL    140
            WIDTH  260
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE cTFName   
        END TEXTBOX
    
        DEFINE TEXTBOX txtbCond
            ROW    80
            COL    300
            WIDTH  140
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE ""
        END TEXTBOX
    
        DEFINE TEXTBOX txtbScope
            ROW    120
            COL    300
            WIDTH  140
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE ""
        END TEXTBOX
    
        DEFINE TEXTBOX txtbTFT
            ROW    160
            COL    300
            WIDTH  140
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE ""
        END TEXTBOX
    
        DEFINE BUTTON btnFields
            ROW    40
            COL    410
            WIDTH  30
            HEIGHT 20
            ACTION Nil
            CAPTION "..."
            FONTNAME "FixedSys"
            FONTSIZE 8
            TOOLTIP "Field List"
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            HELPID Nil
            FLAT .F.
            TABSTOP .T.
            VISIBLE .T.
            TRANSPARENT .F.
        END BUTTON
    
        DEFINE BUTTON btnTFN
            ROW    200
            COL    410
            WIDTH  30
            HEIGHT 20
            ACTION Nil
            CAPTION "..."
            FONTNAME "FixedSys"
            FONTSIZE 8
            TOOLTIP "Select File"
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            HELPID Nil
            FLAT .F.
            TABSTOP .T.
            VISIBLE .T.
            TRANSPARENT .F.
        END BUTTON
    
        DEFINE LABEL lblRecDelim
            ROW    240
            COL    20
            WIDTH  100
            HEIGHT 30
            VALUE "Record Delimiter"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE COMBOBOX combRecDelim
            ROW    240
            COL    140
            WIDTH  140
            HEIGHT 90
            ITEMS {"CRLF","CR Only","LF Only","NONE","OTHER"}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE TEXTBOX txtbRecDelim
            ROW    240
            COL    300
            WIDTH  140
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE ""
        END TEXTBOX
    
        DEFINE LABEL lblFielDelim
            ROW    280
            COL    30
            WIDTH  90
            HEIGHT 20
            VALUE "Field Delimiter"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE COMBOBOX combFielDelim
            ROW    280
            COL    140
            WIDTH  140
            HEIGHT 80
            ITEMS {"NONE","Comma","Semicolon","Space","CR","LF","CRLF"}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE TEXTBOX txtbFielDelim
            ROW    280
            COL    300
            WIDTH  140
            HEIGHT 20
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONENTER Nil
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            READONLY .F.
            RIGHTALIGN .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            INPUTMASK Nil
            FORMAT Nil
            VALUE ""
        END TEXTBOX
    
        DEFINE LABEL lblStrTrim
            ROW    320
            COL    20
            WIDTH  100
            HEIGHT 20
            VALUE "String Strimming"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR NIL
            FONTCOLOR NIL
            RIGHTALIGN .T. 
        END LABEL
    
        DEFINE COMBOBOX combStrTrim
            ROW    320
            COL    140
            WIDTH  140
            HEIGHT 100
            ITEMS {"LEFT","RIGTH","NONE"}
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE Nil
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
        END COMBOBOX
    
        DEFINE BUTTON btnApply
           ROW    370
           COL    220
           WIDTH  100
           HEIGHT 28
           ACTION T_CopSpcApply()
           CAPTION "Apply"
           FONTNAME "Arial"
           FONTSIZE 9
           TOOLTIP ""
           FONTBOLD .F.
           FONTITALIC .F.
           FONTUNDERLINE .F.
           FONTSTRIKEOUT .F.
           ONGOTFOCUS Nil
           ONLOSTFOCUS Nil
           HELPID Nil
           FLAT .F.
           TABSTOP .T.
           VISIBLE .T.
           TRANSPARENT .F.
        END BUTTON

    END WINDOW // frmCopySpec

   CENTER WINDOW   frmCopySpec
   ACTIVATE WINDOW frmCopySpec

RETU // T_Copy_Spec()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
      
PROC InitCopSel()                         // Initialize frmCopySpec form

   SetProperty ( "frmCopySpec", "combCond",      "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "combScope",     "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "combTFT",       "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbCond",      "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbTFT",       "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "btnFields",     "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "btnTFN",        "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbRecDelim",  "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbCond",      "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbScope",     "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbTFT",       "ENABLED", .F. )
   SetProperty ( "frmCopySpec", "txtbFielDelim", "ENABLED", .F. )

   frmCopySpec.combFielDelim.Value := 3   // Semicolon
   frmCopySpec.combStrTrim.Value   := 2   // RIGTH
   frmCopySpec.combRecDelim.Value  := 4  // NONE
         
RETU // InitCopSel()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_CopSpcApply()

   LOCA cFieldLst := frmCopySpec.txbFields.Value,;
        cTFileNam := frmCopySpec.txbTFN.Value,;
        nRecDelim := frmCopySpec.combRecDelim.Value,;
        nFldDelim := frmCopySpec.combFielDelim.Value,;
        nStrTrim  := frmCopySpec.combStrTrim.Value,;
        cRecDelim := '',;
        cFldDelim := '',;
        nCopied   :=  0,;
        nFldNum   :=  0,;
        xFldValue := NIL 
        
   LOCA aRecDelims := { CRLF, CHR(13), CHR(10), "","?"},;   
        aFldDelims := { "",",",";"," ", CHR(13), CHR(10), CRLF }

/*                                               
   MsgMulty( { frmCopySpec.txbFields.Value,;
               frmCopySpec.txbTFN.Value,;
               frmCopySpec.combRecDelim.Value,;
               frmCopySpec.combFielDelim.Value,;
               frmCopySpec.combStrTrim.Value } )
               
   MsgMulty( { cFieldLst,;
               cTFileNam,;
               nRecDelim,;
               nFldDelim,;
               nStrTrim  } )
*/

   IF EMPTY( cFieldLst )
      MsgStop( "Field(s) name not specified." )
   ELSE               
      IF EMPTY( cTFileNam )
         MsgStop( "Target File name not specified." )
      ELSE
         cRecDelim := aRecDelims[ nRecDelim ]
         cFldDelim := aFldDelims[ nFldDelim ]
         SET ALTE TO ( cTFileNam )
         SET ALTE ON
         DBGOTOP()
         WHILE !EOF()
         
            FOR nFldNum := 1 TO FCOUNT()
              IF TRIM( FIELD( nFldNum ) ) $ cFieldLst 
                xFldValue := AnyToStr( FIELDGET( nFldNum ) )
                IF nStrTrim < 3
                   IF nStrTrim < 2
                      xFldValue := LTRIM( xFldValue )
                   ELSE   
                      xFldValue := RTRIM( xFldValue )
                   ENDIF
                ENDIF    
                 ?? xFldValue + cFldDelim  
              ENDIF 
            NEXT nFldNum             
            ?? cRecDelim        
            ++nCopied 
            DBSKIP() 
         ENDDO
         SET ALTE TO 
         SET ALTE OFF
         
*         MsgMulty( { NTrim( nCopied ) + " record" + IF( nCopied > 1, "s "," " ) + "copied",;
*                     "to " + cTFileNam } )        
         
         frmCopySpec.release       
         
      ENDIF EMPTY( cTFileNam )
   ENDIF EMPTY( cFieldLst )
  
  
RETU // T_CopSpcApply()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

