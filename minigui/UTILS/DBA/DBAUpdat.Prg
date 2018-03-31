#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain

MEMV nPasdRecs

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Pack()                             // Table Pack
   IF MsgYesNo( "All DELETED records in the table will be PERMANENTLY discarded!" + CRLF2 + "Are You sure ?", "PACK")
      PACK
      DBGOTOP()
      RefrBrow()
      RefrMenu()
   ENDIF
RETU // T_Pack()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_Zap()                              // Table ZAP

   IF MsgYesNo( "All records in the table will be PERMANENTLY removed!" + CRLF2 + "Are You sure ?", "ZAP")
      ZAP
      RefrBrow()
      RefrMenu()
   ENDIF

RETU // T_Zap()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_AppeReco()                         // Table Append Record(s)

   LOCA cWinTitl := "Append record(s) to " + ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        aStruct  := DBSTRUCT(),;
        nCurRec  := RECN(),;
        aLabels  := {},;
        aDTypes  := {},;
        aWidths  := {},;
        aDecims  := {},;
        aValues  := {},;
        aROnlys  := {},;
        aValids  := {},;
        aButtons := { { , "Apply", "Apply Appending",,,     { 3, 106, 4 }     },;
                      { , " New ", "Another New Record",,,  { 2, 1, 105 }     },;
                      { , "Exit",  "Cancel Appending",,,,                 .T. } },;
        aCdBloks := { { || DBSKIP() },;                                            // 1
                      { || DBGOBOTTOM() },;                                        // 2
                      { || DBAPPEND() },;                                          // 3
                      { || RefrBrow(), RefrStBar() },;                             // 4
                      { | x1, i1 | x1 := FIELDGET( i1 ),;                          // 5
                                         _SetValue( Num2Name( "cfc_", i1 ), "frmCombFrm", x1 )},;
                      { | x1, i1 | x1 := _GetValue( Num2Name( "cfc_", i1 ), "frmCombFrm" ),;  // 6
                                         FIELDPUT( i1, x1 ) } }

   DBGOBOTTOM()
   DBSKIP()      // to Phantom record, for empty field values

   AEVAL( aStruct , { | a1, i1 | ;
          AADD( aLabels, a1[ 1 ] ),;         // Field Name
          AADD( aValues, FIELDGET( i1 ) ),;  // Field Value
          AADD( aDTypes, a1[ 2 ] ),;         // Field Type
          AADD( aWidths, a1[ 3 ] ),;         // Field Width
          AADD( aDecims, a1[ 4 ] ),;         // Field Decimal
          AADD( aValids,  ) } )              // Field Validity Code Blocks

   DBGOTO( nCurRec )

   ComboForm( cWinTitl,; // Combo Form's Title
              aLabels,;  // Field Name
              aValues,;  // Field Value : Value
              aDTypes,;  // Field Type
              aWidths,;  // Field Width
              aDecims,;  // Field Decimal
              aROnlys,;  // Read Onlies
              aValids,;  // Field Validity Code Blocks
              aButtons,; // Buttons
              aCdBloks ) // Actions : code blocks for Buttons

   RefrMenu()   // Ýþlem öncesi aktif kayýt sayýsý > 0 idiyse APPE, menüdeki iþlemleri etkiler.

RETU // T_AppeReco()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC T_DeleReca( ;                        // Table Delete / Recall Record(s)
                 nDeleReca,;   // 1: Delete,  2: Recall
                 nHowRecor )   // 1: Current, 2: Selective, 3: All

   LOCA nCurRec   := RECN(),;
        cCPTitle  := " Records Criterias",;
        aComPars  := {},;
        aComOpts  := {},;
        nRecoNum  :=  0,;
        aCondits  := {},;
        aScopes   := {},;
        aCondExps := {},;
        cContinue := '',;
        cApply    := '.T.',;
        lAllRecs  := .F.,;
        cFORExpr  := ''

   PRIV nPasdRecs :=  0

   DEFAULT nDeleReca TO IF( DELETED(), 2, 1 ),;
           nHowRecor TO 1

   IF nHowRecor < 2         // Only Current
      IF nDeleReca < 2      // DELETE
         DELETE
      ELSE
         RECALL
      ENDIF
      _SetItem ( "StatusBar", cMWinName, 3, IF( DELETED(), '*', '' ) )
   ELSEIF nHowRecor > 2     // All
      IF nDeleReca < 2
         DELETE ALL
      ELSE
         RECALL ALL
      ENDIF
   ELSE                     // Selective

      aComPars  := { {  1, '' },;          // FOR/WHILE, Express
                     {  4,  1 } }          // Scope ( ALL/REST/NEXT n/RECORD n ) Deflt : NEXT 1

      aComOpts  := GFUComOpts( aComPars,;  // Values of options
                               IF( nDeleReca < 2, "Delete", "Recall" ),;   // Command's name
                              { 'CND',;    // Condition ( FOR/WHILE )
                                'SCP' } )  // SCOPE     ( ALL/REST/NEXT/RECORD)

      IF !EMPTY( aComOpts )

         aCondits := aComOpts[ 1 ]
         aScopes  := aComOpts[ 2 ]
         lAllRecs := (aScopes[ 1 ]  == 2 )
         cFORExpr := IF( aCondits[ 1 ] == 2, aCondits[ 2 ], '' )

         IF aScopes[ 1 ] < 2
            *
            * Empty Scope meant NEXT 1 ( in DELE/RECA )
            *
            *
            * ( .AND. NO CONDITION SETTED ! )
            *
            IF aCondits[ 1 ] < 2
               aScopes := {  4,  1 }
            ENDIF
         ENDIF

         aCondExps := Cond2Exps( aScopes, aCondits )

         cContinue := aCondExps[ 1 ]
         cApply    := aCondExps[ 2 ]

         IF lAllRecs .OR. !EMPTY( cFORExpr )
            DBGOTOP()
         ENDIF

         WHILE &cContinue
            IF &cApply
               IF nDeleReca < 2
                  DELETE
               ELSE
                  RECALL
               ENDIF
            ENDIF

            ++nPasdRecs
            RefrStBar()

            DBSKIP()
         ENDDO

      ENDIF !EMPTY( aComOpts )

   ENDIF nHowRecor

   DBGOTO( nCurRec )

   WHIL DELETED() .AND. !EOF()
      DBSKIP()
   ENDDO

   IF EOF()
      DBGOBOTTOM()
      WHIL DELETED() .AND. !BOF()
         DBSKIP(-1)
      ENDDO
   ENDIF

   RefrMenu()
   RefrBrow()

RETU // T_DeleReca()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_Replace()                          // Table Replace

   LOCA nCurRec   := RECN(),;
        aStruct   := DBSTRUCT(),;
        aFieldLst := {},;
        nFieldNum :=  0,;
        cFieldTyp := '',;
        cCPTitle  := "Replace",;
        aComPars  := {},;
        aComOpts  := {},;
        lAllRecs  := .F.,;
        cFORExpr  := '',;
        cWhlExpr  := '',;
        cWitExpr  := '',;
        xWitExpr  := '',;
        aCondits  := {},;
        aScopes   := {},;
        aCondExps := {},;
        cContinue := '',;
        cApply    := '',;
        nNextRecs :=  0,;
        lRestRecs := .F.,;
        cAlias    := ALIAS(),;
        nRecords  := 0

   PRIV nPasdRecs :=  0

   AEVAL( aStruct, { | a1, i1 | AADD( aFieldLst, FIELDNAME( i1 ) ), HB_SYMBOL_UNUSED( a1 ) } )

   aComPars  := {    1,;                // FIELDS COMBOBOX VALUE
                    '' ,;               // WITH expression
                  {  1, '' },;          // FOR/WHILE, Express
                  {  4,  1 } }          // Scope ( ALL/REST/NEXT n/RECORD n ) Deflt : NEXT 1

   aComOpts  := GFUComOpts( aComPars,;    // Values of options
                            'REPLACE',;   // Command's name
                           { 'FLD',;
                             'WTH',;
                             'CND',;    // Cond (FOR/WHILE)
                             'SCP' } )  // Scope ( ALL/REST/NEXT n/RECORD n )
                             
   IF !EMPTY( aComOpts )

      cWitExpr  := aComOpts[ 2 ]

      IF !EMPTY( cWitExpr )

         nFieldNum := aComOpts[ 1 ]
         cFieldTyp := FIELDTYPE( nFieldNum )

         xWitExpr := &cWitExpr

         IF VALTYPE( xWitExpr ) # cFieldTyp
            MsgStop( "Data type mismatch;" + CRLF2 + "Please try again." )
         ELSE
            aCondits  := aComOpts[ 3 ]
            aScopes   := aComOpts[ 4 ]
            lAllRecs  := (aScopes[ 1 ]  == 2 )
            cFORExpr  := IF( aCondits[ 1 ] == 2, aCondits[ 2 ], '' )

            IF aScopes[ 1 ] < 2
               *
               * Empty Scope meant NEXT 1 ( in REPLACE )
               *
               *
               * ( .AND. NO CONDITION SETTED ! )
               *
               IF aCondits[ 1 ] < 2
                  aScopes := {  4,  1 }
               ENDIF
            ENDIF

            aCondExps := Cond2Exps( aScopes, aCondits )

            cContinue := aCondExps[ 1 ]
            cApply    := aCondExps[ 2 ]

            IF lAllRecs .OR. !EMPTY( cFORExpr )
               DBGOTOP()
            ENDIF

            WHILE &cContinue
               IF &cApply
                  FIELDPUT( nFieldNum, &cWitExpr )
               ENDIF
               ++nPasdRecs
               RefrStBar()
               DBSKIP()
            ENDDO
         ENDIF VALTYPE( xWitExpr ) # cFieldTyp
      ENDIF !EMPTY( cWitExpr )

   ENDIF !EMPTY( aComOpts )

   DBGOTO( nCurRec )

   RefrMenu()
   RefrBrow()

RETU // T_Replace()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


PROC T_AppeFrom()

   LOCA cTablDir  := ExOPFFFS( aOpnDatas[ nCurDatNo, 3 ] ),;
        cTblName  := ExOFNFFP( aOpnDatas[ nCurDatNo, 3 ] ),;
        cNewTNam  := ''

   LOCA aComPars  := {},;
        cCbFTitl  := "Appending from to " + cTblName + " ...",;
        aComOpts  := {},;
        lSuccess  := .F.


   LOCA nSFType   :=  0,;
        cDelmtr   := '',;
        cSFName   := '',;
        nCondit   :=  0,;
        cCondit   :=  0,;
        nScopNo   :=  0,;
        nNextRecs :=  0,;
        nScpRecNo :=  0

   aComPars  := { {  1, ''  },;         // Source FILE Type : 1: Table
                  { SPAC( 256 ), "Table", "*.dbf", .F. },;  // Source FILE Name
                  {  1, ''  },;         // FOR/WHILE, Express
                  {  2,  0  } }         // Scope ( ALL/REST/NEXT n/RECORD n )

   aComOpts  := GFUComOpts( aComPars,;  // Values of options
                            cCbFTitl,;  // Command's name
                            { 'SFT',;                  // Source FILE Type
                            { 'SFN',"Source " },;      // Source file Name
                              'CND',;                  // FOR Expression
                              'SCP' } )                // UNIQUE, DESCENDING

   IF ! EMPTY( aComOpts )

      nSFType := aComOpts[ 1, 1 ]
      cDelmtr := aComOpts[ 1, 2 ]
      cSFName := aComOpts[ 2 ]
      nCondit := aComOpts[ 3, 1 ]
      cCondit := aComOpts[ 3, 2 ]
      nScopNo := aComOpts[ 4, 1 ]

      IF nScopNo == 4
         nNextRecs := aComOpts[ 4, 2 ]
      ELSEIF nScopNo == 5
         nScpRecNo := aComOpts[ 4, 2 ]
      ENDIF
/*
MsgMulty( { "SFT : " + NTrim( nSFType ),;
            "DLM : " + cDelmtr,;
            "SFN : " + cSFName,;
            "nCN : " + NTrim( nCondit ),;
            "cCN : " + cCondit,;
            "nSC : " + NTrim( nScopNo ),;
            "nNR : " + NTrim( nNextRecs ),;
            "nRN : " + NTrim( nScpRecNo ) } )
*/
      IF nSFType > 1 // Non-table
         DO CASE
            CASE nSFType == 2
               APPEND FROM ( cSFName ) SDF
            CASE nSFType == 3
               APPEND FROM ( cSFName ) DELIMITED
            CASE nSFType == 4
               APPEND FROM ( cSFName ) DELIMITED WITH BLANK
            CASE nSFType == 5 
               APPEND FROM ( cSFName ) DELIMITED WITH ( cDelmtr )
         ENDCASE nSFType
      ELSE // table
         IF nCondit < 2 .AND. nScopNo < 3 // No Cond, No Scop
            APPEND FROM ( cSFName ) 
         ELSEIF nCondit < 2               // No Cond, but scop  
            DO CASE 
               CASE nScopNo == 3  
                  APPEND FROM ( cSFName ) REST
               CASE nScopNo == 4
                  APPEND FROM ( cSFName ) NEXT nNextRecs
               CASE nScopNo == 5
                  APPEND FROM ( cSFName ) RECORD nScpRecNo
            ENDCASE nScopNo
         ELSEIF nCondit == 2              // FOR 
            DO CASE 
               CASE nScopNo <  3
                  APPEND FROM ( cSFName ) FOR &cCondit
               CASE nScopNo == 3
                  APPEND FROM ( cSFName ) FOR &cCondit REST
               CASE nScopNo == 4
                  APPEND FROM ( cSFName ) FOR &cCondit NEXT nNextRecs
               CASE nScopNo == 5
                  APPEND FROM ( cSFName ) FOR &cCondit RECORD nScpRecNo
            ENDCASE nScopNo
         ELSEIF nCondit == 3              // WHILE 
            DO CASE 
               CASE nScopNo <  3
                  APPEND FROM ( cSFName ) WHILE &cCondit
               CASE nScopNo == 3
                  APPEND FROM ( cSFName ) WHILE &cCondit REST
               CASE nScopNo == 4
                  APPEND FROM ( cSFName ) WHILE &cCondit NEXT nNextRecs
               CASE nScopNo == 5
                  APPEND FROM ( cSFName ) WHILE &cCondit RECORD nScpRecNo
            ENDCASE nScopNo
         ENDIF
      ENDIF nSFType ...
      
      DBGOTOP()
      RefrMenu()
      RefrBrow()
   ELSE
      MsgBox( "Escaped." )
   ENDIF

RETU // T_AppeFrom()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

#command INSERT [<before: BEFORE>] => dbInsert( <.before.> )

PROC T_InseReco()
   IF MsgYesNo( "A blank record will be inserted before the current record." + CRLF2 + "Are You sure ?", "Insert Record")
      INSERT BEFORE
      RefrMenu()
      RefrBrow()
   ENDIF
RETU // T_InseReco()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

This is a Clipper 5.x function which emulates dBase's INSERT command.  I 
believe it's as fast as it can be for pure Clipper code, but feel free to 
improve upon it if you can (and let me know what you did).

Todd MacDonald

*/

//--------------------------------------------------------------------------//
  FUNCTION dbInsert( lBefore )
//--------------------------------------------------------------------------//

/*

Syntax

  dbInsert( [<lBefore>] )  ->  nil

Arguments

  <lBefore> is true if you wish to insert the record before the current
  record, false (or not passed) if after.

Returns

  nil

Description

  dbInsert emulates the dBase INSERT command by appending a blank record
  at the end of the current file and "moving" all the records down leaving
  a blank record at the current position (or current position + 1 depending
  on the value of <lBefore>).

Examples

  #command INSERT [<b4: BEFORE>] => dbInsert( <.b4.> )

  use WHATEVER

  INSERT BEFORE

Author

  Todd C. MacDonald

Notes

  This function is an original work and is placed into the Public Domain by 
  the author.

History

  05/19/92 TCM Created
  05/20/92 TCM Bug fix: Added code to carry each record's deleted status 
               forward when the record is "moved".  
  05/21/92 TCM Bug fix: Fixed the aeval responsible for blanking out the 
               "inserted" record so that it really *does* blank it out.

*/

#define DBS_NAME  1
#define FLD_BLK   1
#define FLD_VAL   2

LOCAL nRec     := recno() + 1
LOCAL lSavDel  := SET( _SET_DELETED, .f. )
LOCAL nSavOrd  := indexord()
LOCAL aFields  := {}
LOCAL lDeleted := .f.

IF lBefore = nil; lBefore := .f.; ENDIF

IF lBefore

  // stop moving records when the current record is reached
  --nRec

ENDIF

// build the array of field get/set blocks with cargo space for field values
aeval( dbstruct(), { | a | ;
  aadd( aFields, { fieldblock( a[ DBS_NAME ] ), nil } ) } )

// process in physical order for speed
dbsetorder( 0 )

// add a new record at eof
dbappend()

// back up through the file moving records down as we go
WHILE recno() > nRec

  // store all values from previous record in the appropriate cargo space
  dbskip( -1 )
  aeval( aFields, { | a | a[ FLD_VAL ] := eval( a[ FLD_BLK ] ) } )

  // save deleted status
  lDeleted := deleted()

  // replace all values in next record with stored cargo values
  dbskip()
  aeval( aFields, { | a | eval( a[ FLD_BLK ], a[ FLD_VAL ] ) } )

  // set deleted status
  iif( lDeleted, dbdelete(), dbrecall() )

  // go to previous record
  dbskip( -1 )

END

// blank out the "inserted" record
aeval( aFields, { | a, cType | ;
  cType := valtype( eval( a[ FLD_BLK ] ) ), ;
  eval( a[ FLD_BLK ], ;
    iif( cType $ 'CM', '', ;
    iif( cType = 'N',  0, ;
    iif( cType = 'D',  ctod( '  /  /  ' ), ;
    iif( cType = 'L',  .f., nil ) ) ) ) ) } )

// make sure it's not deleted
dbrecall()

// leave things the way we found them
dbsetorder( nSavOrd )
SET( _SET_DELETED, lSavDel )

RETURN nil
