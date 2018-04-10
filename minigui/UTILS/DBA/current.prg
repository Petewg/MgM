#include <minigui.ch>
#include "DBA.ch"


FUNC ExprValid(;
                 xExpress,;    // Expression itself; strg or array or ';' delimited strg list
                 cExcpType )   // Excepted type

   LOCA cRVal    := '',;
        lValid   := .F.,;
        aExpress := {},;
        c1Type   := '',;
        c1Expres := '',;
        nExpress := 0

   IF lPref0104 // Apply Validity Checking on user supplied expressions

      IF ISCHAR( xExpress ) .AND. ';' $  xExpress
         aExpress := Lst2Arr( xExpress )
      ELSE
         aExpress := IF( ISARRY( xExpress ), xExpress, { xExpress } )
      ENDIF

      FOR nExpress := 1 TO LEN( aExpress )
         c1Expres  := aExpress[ nExpress ]
         c1Type    := TYPE( c1Expres )

         lValid    := ( ( ! ( 'U' $ c1Type ) )     .AND. ;
                        (   ( EMPTY( cExcpType ) ) .OR.  ;
                        ( c1Type == cExcpType )  )  )
         IF !lValid
            EXIT FOR
         ENDIF
      NEXT nExpress

      IF !lValid
         cRVal := c1Expres
      ENDIF

   ENDIF lPref0104

RETU cRVal // ExprValid()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


FUNC GFUComOpts( ;            // Get From User Command Options
                 aValues,;
                 cComName,;   // (Caller) Command Name
                 aOptCodes )  // Options Codes

   LOCA aRVal     := {},;
        aControls := {},;
        cCFTitl   := " Options for " + cComName,;
        nItemCo   := LEN( aOptCodes ),;
        nItemNo   := 0,;
        x1Option  := NIL,;
        c1PCode   := '',;
        c1PName   := '',;
        n1PCNum   :=  0,;
        nLnSpace  := 27,;
        n1itRow   :=  0,;
        n1ILINo   :=  0     // InLine Item No

   LOCA c1Label   := '',;
        clblNam   := '',;
        cTxBNam   := '',;
        ctxhNam   := '',;
        cBtnNam   := '',;
        cChBNam   := '',;
        cCmBNam   := '',;
        x1Value   := NIL,;
        c1Value

   LOCA aCPStru   := { { "OFN", ' File Name'  } ,;   //  1. Output File Name
                       { "EXP", ' Expression' } ,;   //  2. Expression
                       { "FLD", 'FIELD'       } ,;   //  3. ( Single ) Field
                       { "ELS", 'Expressions' } ,;   //  4. Expressions List
                       { "FLS", 'Fields'      } ,;   //  5. Field list
                       { "WTH", 'WITH'        } ,;   //  6. WITH
                       { "FOR", 'FOR'         } ,;   //  7. FOR
                       { "DRH", { 'Deleted Mark', 'Record No', 'Heading' } },;   //  8. DeleteMark, RecordNos, Heading
                       { "UND", { 'UNIQUE', 'DESCENDING' } },;                   //  9. Unique, Descending
                       { "CND", 'Condition', { '','FOR','WHILE' } } ,;          //  10. Condition ( FOR/WHILE )
                       { "SCP", 'Scope',     { '','ALL', 'REST', 'NEXT', 'RECORD' } },;   // 11. Scope ( ALL, REST, NEXT n, RECORD n )
                       { "TFT", 'Target File Type', { 'Table', 'SDF', 'DELIMITED', 'DELIMITED WITH BLANK', 'DELIMITED WITH' }   },;     // 12. I/O Type ( DBF, SDF, DLMTD, DLMTD WITH ) , 'SPECIAL' iþi: burasý karýþýk geldi, menüye alýndý 8507
                       { "SFN", ' File Name'  } ,;   //  13. Source File Name
                       { "SFT", 'Source File Type', { 'Table', 'SDF', 'DELIMITED', 'DELIMITED WITH BLANK', 'DELIMITED WITH' }   },;     // 14. I/O Type ( DBF, SDF, DLMTD, DLMTD WITH )
                       { "KLS", 'Key(s)'      } }   //  15. Key list
                       

   DEFINE WINDOW frmComOpts AT 0, 0 WIDTH 448 HEIGHT 481 TITLE cCFTitl MODAL

      ON KEY ESCAPE ACTION frmComOpts.Release

      n1itRow := nLnSpace

      FOR nItemNo := 1 TO nItemCo

         x1Option  := aOptCodes[ nItemNo ]

         IF ISCHAR( x1Option )
            c1PCode := x1Option
         ELSEIF ISARRY( x1Option )
            c1PCode := x1Option[ 1 ]
            c1PName := x1Option[ 2 ]
         ENDIF

         n1PCNum := ASCAN( aCPStru, { | a1 | c1PCode == a1[ 1 ] } )

         x1Value := aValues[ nItemNo ]

         DO CASE

            CASE c1PCode == "OFN"   //  1. File  <file.Lbl>, <txb>, <file more button>

               cLblNam := 'lbl_OFN' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_OFN' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_OFN' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, c1PName + aCPStru[ n1PCNum, 2 ] )

               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "File List"
               END BUTTON
               
               AADD( aControls, ctxbNam )

            CASE c1PCode == "EXP"   //  2. Expression  <exp.lbl>,  <txb>, <field more button>

               cLblNam := 'lbl_EXP' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_EXP' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_EXP' + STRZERO( nItemNo, 2 )


               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, c1PName + aCPStru[ n1PCNum, 2 ] )
               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )
               
               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "Field List"
               END BUTTON

               AADD( aControls, ctxbNam )

            CASE c1PCode == "FLD"   //  3. Field   <fld.lbl>,  <txb>, <field more button>

                cLblNam := 'lbl_FLD' + STRZERO( nItemNo, 2 )

                CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )

                cCmBNam  := "cmb_FLD" + STRZERO( nItemNo, 2 )

                DEFINE COMBOBOX &cCmBNam
                   ROW        n1itRow
                   COL        110
                   WIDTH      140
                   HEIGHT     100
                   ITEMS      FldNArry()
                   VALUE      aValues[ nItemNo ]
*                  FONTNAME   "FixedSys"
*                  FONTSIZE   10
                   ONCHANGE   CoOpSetValue( this.name, aValues )
                END COMBOBOX

                AADD( aControls, cCmBNam )

            CASE c1PCode == "ELS"   //  4. Expressions : <flds.lbl>,  <txb>, <fields more button>

               cLblNam := 'lbl_ELS' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_ELS' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_ELS' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )
               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "Field List"
               END BUTTON

               AADD( aControls, ctxbNam )

            CASE c1PCode == "FLS"   //  5. Fields List : <flds.lbl>,  <txb>, <fields more button>

               cLblNam := 'lbl_FLS' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_FLS' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_FLS' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )
               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "Field List"
               END BUTTON

               AADD( aControls, ctxbNam )

            CASE c1PCode == "WTH"   //  6. WITH     <txb>, <fields more button>

               cLblNam := 'lbl_WTH' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_WTH' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )
               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

               AADD( aControls, ctxbNam )

            CASE c1PCode == "FOR"   //  7. FOR,  <txb>, <fields more button>

                cLblNam := 'lbl_FOR' + STRZERO( nItemNo, 2 )
                ctxbNam := 'txb_FOR' + STRZERO( nItemNo, 2 )

                CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )
                CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

                AADD( aControls, ctxbNam )

            CASE c1PCode == "DRH"   //  8. DeleteMark, RecordNos, Heading

               AADD( aControls, {} )

               FOR n1ILINo := 1 TO LEN( aCPStru[ n1PCNum, 2 ] )   // InLine Item No

                   c1Label := aCPStru[ n1PCNum, 2, n1ILINo ]

                   clblNam := "lbl_DRH" + STRZERO( nItemNo, 2 ) + STRZERO( n1ILINo, 2 )

                   CoOp1Item( 'LBL', clblNam, n1itRow + 3, (n1ILINo - 1) * 150, 100, 15, c1Label )

                   cChBNam := "chb_DRH" + STRZERO( nItemNo, 2 ) + STRZERO( n1ILINo, 2 )

                   DEFINE CHECKBOX &cChBNam
                      ROW        n1itRow - 3
                      COL        (n1ILINo - 1) * 150 + 110
                      WIDTH      40
                      HEIGHT     27
                      CAPTION    ""
                      VALUE      x1Value[ n1ILINo ]
                  END CHECKBOX

                  AADD( aControls[ nItemNo ], cChBNam )

               NEXT n1ILINo

            CASE c1PCode == "UND"   //  9. Unique, Descending

               AADD( aControls, {} )

               FOR n1ILINo := 1 TO LEN( aCPStru[ n1PCNum, 2 ] )   // InLine Item No

                   c1Label := aCPStru[ n1PCNum, 2, n1ILINo ]

                   clblNam := "lbl_UND" + STRZERO( nItemNo, 2 ) + STRZERO( n1ILINo, 2 )

                   CoOp1Item( 'LBL', clblNam, n1itRow + 3, (n1ILINo - 1) * 150, 100, 15, c1Label )

                   cChBNam := "chb_UND" + STRZERO( nItemNo, 2 ) + STRZERO( n1ILINo, 2 )

                   DEFINE CHECKBOX &cChBNam
                      ROW        n1itRow - 3
                      COL        (n1ILINo - 1) * 150 + 110
                      WIDTH      40
                      HEIGHT     27
                      CAPTION    ""
                      VALUE      x1Value[ n1ILINo ]
                  END CHECKBOX

                  AADD( aControls[ nItemNo ], cChBNam )

               NEXT n1ILINo

            CASE c1PCode == "CND"   //  10. Condition ( FOR/WHILE ) :  "Condition", cmb { "FOR", "WHILE" }, <expression>

               cLblNam := 'lbl_CND' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3, 0, 100, 15, aCPStru[ n1PCNum, 2 ] )

               cCmBNam  := "cmb_CND" + STRZERO( nItemNo, 2 )

               DEFINE COMBOBOX &cCmBNam
                  ROW        n1itRow
                  COL        110
                  WIDTH      140
                  HEIGHT     100
                  ITEMS      aCPStru[ n1PCNum, 3 ]
                  VALUE      aValues[ nItemNo, 1 ]
*                  FONTNAME   "FixedSys"
*                  FONTSIZE   10
                  ONCHANGE   CoOpSetValue( this.name, aValues )
               END COMBOBOX

               ctxbNam  := "txb_CND" + STRZERO( nItemNo, 2 )
               CoOp1Item( 'TXB', cTxBNam, n1itRow, 260, 165, 23, aValues[ nItemNo, 2 ] )
               SetProperty( 'frmComOpts', cTxBNam, 'ENABLED', aValues[ nItemNo, 1 ] > 1 )

               AADD( aControls, { cCmBNam, ctxbNam } )

            CASE c1PCode == "SCP"   //  11. Scope ( ALL, REST, NEXT n, RECORD n )

               c1Label := aCPStru[ n1PCNum, 2 ]
               cLblNam := 'lbl_CND' + STRZERO( nItemNo, 2 )
               CoOp1Item( 'LBL', clblNam, n1itRow + 3, 0, 100, 15, c1Label )

               cCmBNam  := "cmb_SCP" + STRZERO( nItemNo, 2 )

               DEFINE COMBOBOX &cCmBNam
                  ROW        n1itRow
                  COL        110
                  WIDTH      140
                  HEIGHT     100
                  ITEMS      aCPStru[ n1PCNum, 3 ]
                  VALUE      aValues[ nItemNo, 1 ]
*                  FONTNAME   "FixedSys"
*                  FONTSIZE   10
                  ONCHANGE   CoOpSetValue( this.name, aValues )
               END COMBOBOX

               cTxBNam  := "txb_SCP" + STRZERO( nItemNo, 2 )
               CoOp1Item( 'TXB', cTxBNam, n1itRow, 260, 165, 23, aValues[ nItemNo, 2 ] )
               SetProperty( 'frmComOpts', cTxBNam, 'ENABLED', aValues[ nItemNo, 1 ] > 3 )

               AADD( aControls, { cCmBNam, ctxbNam } )

            CASE c1PCode == "TFT"   // 12. I/O Type ( DBF, SDF, DLMTD, DLMTD WITH )

                cLblNam := 'lbl_TFT' + STRZERO( nItemNo, 2 )

                CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )

                cCmBNam  := "cmb_TFT" + STRZERO( nItemNo, 2 )

                DEFINE COMBOBOX &cCmBNam
                   ROW        n1itRow
                   COL        110
                   WIDTH      140
                   HEIGHT     100
                   ITEMS      aCPStru[ n1PCNum, 3 ]
                   VALUE      aValues[ nItemNo, 1 ]
*                  FONTNAME   "FixedSys"
*                  FONTSIZE   10
                   ONCHANGE   CoOpSetValue( this.name, aValues )
                END COMBOBOX

                cTxBNam  := "txb_TFT" + STRZERO( nItemNo, 2 )
                CoOp1Item( 'TXB', cTxBNam, n1itRow, 260, 165, 23, aValues[ nItemNo, 2 ] )
                SetProperty( 'frmComOpts', cTxBNam, 'ENABLED', aValues[ nItemNo, 1 ] > 3 )

                AADD( aControls, { cCmBNam, ctxbNam } )

            CASE c1PCode == "SFN"   //  12. Source File Name

               cLblNam := 'lbl_SFN' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_SFN' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_SFN' + STRZERO( nItemNo, 2 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 105, 15, c1PName + aCPStru[ n1PCNum, 2 ] )

               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, aValues[ nItemNo ] )

               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "File List"
               END BUTTON

               AADD( aControls, ctxbNam )

            CASE c1PCode == "SFT"   // 14. I/O Type ( DBF, SDF, DLMTD, DLMTD WITH )

                cLblNam := 'lbl_SFT' + STRZERO( nItemNo, 2 )

                CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )

                cCmBNam  := "cmb_SFT" + STRZERO( nItemNo, 2 )

                DEFINE COMBOBOX &cCmBNam
                   ROW        n1itRow
                   COL        110
                   WIDTH      140
                   HEIGHT     100
                   ITEMS      aCPStru[ n1PCNum, 3 ]
                   VALUE      aValues[ nItemNo, 1 ]
*                  FONTNAME   "FixedSys"
*                  FONTSIZE   10
                   ONCHANGE   CoOpSetValue( this.name, aValues )
                END COMBOBOX

                cTxBNam  := "txb_SFT" + STRZERO( nItemNo, 2 )
                CoOp1Item( 'TXB', cTxBNam, n1itRow, 260, 165, 23, aValues[ nItemNo, 2 ] )
                SetProperty( 'frmComOpts', cTxBNam, 'ENABLED', aValues[ nItemNo, 1 ] > 3 )

                AADD( aControls, { cCmBNam, ctxbNam } )

            CASE c1PCode == "KLS"   // 15. Key List

               cLblNam := 'lbl_KLS' + STRZERO( nItemNo, 2 )
               ctxbNam := 'txb_KLS' + STRZERO( nItemNo, 2 )
               ctxhNam := 'txh_KLS' + STRZERO( nItemNo, 2 )
               cbtnNam := 'btn_KLS' + STRZERO( nItemNo, 2 )

               c1Value := LEFT( aValues[ nItemNo ], AT(",", aValues[ nItemNo ]) - 1 )

               CoOp1Item( 'LBL', clblNam, n1itRow + 3,   0, 100, 15, aCPStru[ n1PCNum, 2 ] )
               CoOp1Item( 'TXB', ctxbNam, n1itRow,     110, 275, 23, c1Value  )
               CoOp1Item( 'TXB', ctxhNam, n1itRow - 60,     110, 275, 23, aValues[ nItemNo ] )

               SetProperty( 'frmComOpts', cTxhNam, 'VISIBLE', .F. )

               DEFINE BUTTON &cbtnNam
                  ROW        n1itRow
                  COL        395
                  WIDTH      30
                  HEIGHT     21
                  CAPTION    '...'
                  ACTION     CoOpSetValue( this.name, aValues )
*                  FONTNAME   "Tahoma"
*                  FONTSIZE   8
                  TOOLTIP    "Field List"
               END BUTTON

               AADD( aControls, ctxbNam )

         ENDCASE c1PCode
         
         n1itRow += nLnSpace

      NEXT nItemNo

      n1itRow += nLnSpace / 2

      DEFINE BUTTON Button_4
          ROW      n1itRow
          COL      200
          WIDTH    60
          HEIGHT   23
          CAPTION  "Apply"
          ACTION   CoOpAply( aRVal, aControls )
*          FONTNAME "FixedSys"
*          FONTSIZE 9
          TOOLTIP  "Apply command"
      END BUTTON

      frmComOpts.HEIGHT := n1itRow + nLnSpace * 2.6

   END WINDOW  // frmComOpts

   CENTER   WINDOW frmComOpts
   ACTIVATE WINDOW frmComOpts

RETU aRVal //  GFUComOpts()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoOpAply( ;                          // Command Options, Apply
                aValues,;
                aControls )

   LOCA nLineNo  :=  0,;
        nItemNo  :=  0,;
        cCtrNam  := '',;
        cCOpTyp  := '',;
        cCtrTyp  := '',;
        lValid   := .T.,;
        cInvalid := ''

   FOR nLineNo := 1 TO LEN( aControls )

      IF ISARRY( aControls[ nLineNo ] )                      // DRH_, CND_, SCP_ ... gibi
         FOR nItemNo := 1 TO LEN( aControls[ nLineNo ] )
            cCtrNam := aControls[ nLineNo, nItemNo ]
            IF ! ( lValid := CoOpChk1Exp( aControls, cCtrNam ) )
               EXIT FOR
            ENDIF
         NEXT nItemNo
      ELSE                                                   // ELS_ ... gibi
         cCtrNam := aControls[ nLineNo ]
         lValid  := CoOpChk1Exp( aControls, cCtrNam )
      ENDIF ISARRY( ...

      IF !lValid
         EXIT FOR
      ENDIF !lValid

   NEXT nLineNo

   IF lValid
      CoOpRVal( aValues, aControls )
      frmComOpts.Release
   ENDIF

RETU // CoOpAply()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CoOpChk1Exp( ;                       // Command Options, Check 1 Expression
                  aControls,;
                  cCtrNam )

   LOCA cCtrTyp   := LEFT( cCtrNam, 3 ),;
        cCOpTyp   := SUBS( cCtrNam, 5, 3 ),;
        cInvalid  := '',;
        cExpType  := '',;
        lRVal     := .T.,;
        cErrorMes := '',;
        cAsCtrNam := '',;    // Associated Control Name
        nAsCtrVal := 0,;     // Associated Control Value  ( Always Numeric )
        x1Value

   IF ! ( cCOpTyp $ "DRHFLDELSSFTTFTUNDWTH" ) .AND. LOWE( cCtrTyp) == 'txb'

      IF cCOpTyp $ 'CNDSCP'
         cAsCtrNam := STRTRAN( cCtrNam, "txb", "cmb" )                // Associated Control Name
         nAsCtrVal := GetProperty( 'frmComOpts', cAsCtrNam, 'VALUE' ) //     "        "     Value
      ENDIF cCOpTyp # 'ELS'

      x1Value := GetProperty( 'frmComOpts', cCtrNam, 'VALUE' )

      IF cCOpTyp == 'SCP'
         IF nAsCtrVal > 3 // NEXT / RECO
            IF x1Value < 1
               lRVal := .F.
               cErrorMes := "Invalid " + IF( nAsCtrVal > 4, 'Record Number', "NEXT Value" )
            ENDIF
         ENDIF

      ELSE
         IF EMPTY( x1Value )
            IF cCOpTyp == 'CND'
               IF nAsCtrVal > 1
                  lRVal := .F.
                  cErrorMes := "Empty " + IF( nAsCtrVal > 2,'WHILE','FOR' ) + ' Expression'
               ENDIF
            ELSEIF cCOpTyp $ "OFNSFN"
               lRVal := .F.
               cErrorMes := "Empty " + IF( cCOpTyp == "OFN", "Target", "Source" ) + " File Name"
            ENDIF cCOpTyp == 'CND'
         ELSE
            IF cCOpTyp $ "OFNSFN"
               lRVal := FNamValid( x1Value, aControls, cCtrNam, ( cCOpTyp == "OFN" ) )
            ELSE
               IF cCOpTyp == "FLS"
                  cInvalid := FieldValid( x1Value )
               ELSEIF cCOpTyp == "KLS"   
                  cInvalid := KeysValid( x1Value )
               ELSE
                  cInvalid := ExprValid( x1Value, IF( cCOpTyp == 'CND', "L", "" ) )
               ENDIF cCOpTyp == "FLS"

               lRVal := EMPTY( cInvalid )

               IF !lRVal
                  IF cCOpTyp == 'FLS'
                     cErrorMes := 'Invalid field Name : ' + CRLF2 + cInvalid
                  ELSEIF cCOpTyp == 'KLS'
                     cErrorMes := 'Invalid Key Expression : ' + CRLF2 + cInvalid
                  ELSE
                     IF cCOpTyp == 'FOR'
                        cExpType  := 'FOR'
                     ELSEIF cCOpTyp == 'CND'
                        cExpType  := IF( nAsCtrVal > 2,'WHILE','FOR' )
                     ELSE
                        cExpType  := ''
                     ENDIF
                     cErrorMes := 'Invalid ' + cExpType + ' Expression : ' + CRLF2 + ;
                                cInvalid
                  ENDIF cCOpTyp == 'FLS'

               ENDIF !lRVal
            ENDIF cCOpTyp == "OFN"
         ENDIF !EMPTY( x1Value )
      ENDIF cCOpTyp == 'SCP'

      IF !lRVal .AND. !EMPTY( cErrorMes )
         MsgBox( cErrorMes )
      ENDIF

   ENDIF cCOpTyp $ ...

RETU lRVal // CoOpChk1Exp()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoOpRVal(;                           // Make Return Value for GFUComOpts()
                aValues,;
                aControls )

   LOCA nLineNo := 0,;
        nItemNo := 0,;
        cCtrNam := ''

   FOR nLineNo := 1 TO LEN( aControls )

      IF ISARRY( aControls[ nLineNo ] )
         AADD( aValues, {} )
         FOR nItemNo := 1 TO LEN( aControls[ nLineNo ] )
            cCtrNam := aControls[ nLineNo, nItemNo ]
            AADD( aValues[ nLineNo ], GetProperty( 'frmComOpts', cCtrNam, 'VALUE' ) )
         NEXT nItemNo
      ELSE
         cCtrNam := aControls[ nLineNo ]
         AADD( aValues, GetProperty( 'frmComOpts', cCtrNam, 'VALUE' ) )
      ENDIF ISARRY( ...

   NEXT nLineNo

RETU // CoOpRVal()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoOpSetValue( ;
                   cCtrNam,;
                   aValues )

   LOCA c1PCode  := SUBS( cCtrNam, 5, 3 ),;
        nItemNo  := VAL( RIGHT( cCtrNam, 2 ) ),;
        nSubItNo :=  0,;
        ctxbNam  := '',;
        ctxhNam  := '',;
        x1Value

   LOCA aSFTDpCs := { "cmb_CND03" ,;    // SFT Dependent controls ( paliative ! )
                      "txb_CND03" ,;
                      "cmb_SCP04" ,;
                      "txb_SCP04" },;
        c1CtrNam := '',;
        cFFList  := '',;
        cFCList  := '',;
        nSFDCInd := 0                   // SFT Dependent controls's indice

   DO CASE

      CASE c1PCode == "ELS"   //  Expression List

         ctxbNam := STRTRAN( cCtrNam, "btn", "txb" )
         x1Value := GFUFldLst()

         IF !EMPTY( x1Value )
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', x1Value )
         ENDIF

      CASE c1PCode $ "FLSEXP"   //  Field List

         ctxbNam := STRTRAN( cCtrNam, "btn", "txb" )
         x1Value := GFUFldLst(',')

         IF !EMPTY( x1Value )
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', x1Value )
         ENDIF

      CASE c1PCode == "CND"   //  Condition, Combo Box

         ctxbNam := STRTRAN( cCtrNam, "cmb", "txb" )
         x1Value := GetProperty( 'frmComOpts', cCtrNam , 'VALUE' )

         IF x1Value < 2
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', '' )
         ENDIF x1Value < 2

         SetProperty( 'frmComOpts', ctxbNam , 'ENABLED', ( x1Value > 1 ) )

      CASE c1PCode == "SCP"   //  Scope, Combo Box

         ctxbNam := STRTRAN( cCtrNam, "cmb", "txb" )
         x1Value := GetProperty( 'frmComOpts', cCtrNam , 'VALUE' )

         IF x1Value < 2
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', 0 )
         ENDIF x1Value < 2

         SetProperty( 'frmComOpts', ctxbNam , 'ENABLED', x1Value > 3 )

      CASE c1PCode == "OFN"   //  Output File Name

         ctxbNam := STRTRAN( cCtrNam, "btn", "txb" )

         x1Value := GFUNewTNam( aValues[ nItemNo, 2 ], aValues[ nItemNo, 3 ], aValues[ nItemNo, 4 ] )

         IF !EMPTY( x1Value )
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', x1Value )
         ENDIF

      CASE c1PCode == "TFT"   //  Target File Type, Combo Box

         ctxbNam := STRTRAN( cCtrNam, "cmb", "txb" )
         x1Value := GetProperty( 'frmComOpts', cCtrNam , 'VALUE' )

         IF x1Value < 5
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', '' )
         ENDIF x1Value < 2

         SetProperty( 'frmComOpts', ctxbNam , 'ENABLED', ( x1Value > 4 ) )

      CASE c1PCode == "SFT"   //  Source File Type, Combo Box

         ctxbNam := STRTRAN( cCtrNam, "cmb", "txb" )  // cmb_SFT01 => txb_SFT01
         x1Value := GetProperty( 'frmComOpts', cCtrNam , 'VALUE' )

         IF x1Value < 5     // 5: DELIMITED WITH
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', '' )
         ENDIF x1Value < 2

         SetProperty( 'frmComOpts', ctxbNam , 'ENABLED', ( x1Value > 4 ) )

         IF x1Value > 1     // ! table
            aValues[ 2, 2 ] := "Text"
            aValues[ 2, 3 ] := "*.txt"
         ELSE
            aValues[ 2, 2 ] := "Table"
            aValues[ 2, 3 ] := "*.dbf"
         ENDIF x1Value < 2

         FOR nSFDCInd := 1 TO LEN( aSFTDpCs )
            c1CtrNam := aSFTDpCs[ nSFDCInd ]
            SetProperty( 'frmComOpts', c1CtrNam, 'ENABLED', ( x1Value < 2 ) )
         NEXT nSFDCInd


      CASE c1PCode == "SFN"   //  Source File Name 'more' button

         ctxbNam := STRTRAN( cCtrNam, "btn", "txb" )

         x1Value := GFUSrcTNam( aValues[ nItemNo, 2 ], aValues[ nItemNo, 3 ], aValues[ nItemNo, 4 ] )

         IF !EMPTY( x1Value )
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', x1Value )
         ENDIF

      CASE c1PCode == "KLS"   //  Key List more button

         ctxbNam := STRTRAN( cCtrNam, "btn", "txb" )
         ctxhNam := STRTRAN( cCtrNam, "btn", "txh" )

         cFFList := GetProperty( 'frmComOpts', ctxhNam, 'VALUE' ) // Full Field List
         cFCList := GetProperty( 'frmComOpts', ctxbNam, 'VALUE' ) // Current Field List

         x1Value := GFUKFList( cFCList, cFFList )

         IF !EMPTY( x1Value )
            SetProperty( 'frmComOpts', ctxbNam , 'VALUE', x1Value )
         ENDIF

   ENDCASE c1PCode

RETU // CoOpSetValue()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoOp1Item( ;            // Make 1 Item ( Control ) for GFUComOpts()
                cCntrType,;  // Control type
                cCntrName,;  // Control name
                nRow     ,;
                nCol     ,;
                nWidth   ,;
                nHeigth  ,;
                xValue )

   DO CASE
      CASE cCntrType == "LBL"

         DEFINE LABEL  &cCntrName
            ROW        nRow
            COL        nCol
            VALUE      xValue
            WIDTH      nWidth
            HEIGHT     nHeigth
*            FONTNAME   "Tahoma"
*            FONTSIZE   10
            RIGHTALIGN .T.
         END LABEL

      CASE cCntrType == "TXB"

         DEFINE TEXTBOX  &cCntrName
            ROW         nRow
            COL         nCol
            VALUE       xValue
            NUMERIC     ISNUMB( xValue )
            WIDTH       nWidth
            HEIGHT      nHeigth
*            IF ISLOGI( lLoFoProc )
*               ONCHANGE CoOpLoFo( this.name, xValue )
*            ENDIF
*            FONTNAME   "FixedSys"
*            FONTSIZE   10
         END TEXTBOX
/*
      CASE cCntrType == "BTN"

         DEFINE BUTTON &cCntrName
            PARENT     'frmComOpts'
            ROW        nRow
            COL        nCol
            WIDTH      nWidth
            HEIGHT     nHeigth
            CAPTION    xValue
            ACTION     CoOpSetValue( this.name, aValues )
            FONTNAME   "FixedSys"
            FONTSIZE   6
         END BUTTON

      CASE cCntrType == "CHB"

         DEFINE CHECKBOX &cCntrName
            ROW        nRow
            COL        nCol
            WIDTH      nWidth
            HEIGHT     nHeigth
            CAPTION    ""
            VALUE      xValue
*            ONCHANGE   CoOpSetValue( this.name, aValues )
         END CHECKBOX

      CASE cCntrType == "CMB"

         DEFINE COMBOBOX &cCntrName
            ROW        nRow
            COL        nCol
            WIDTH      nWidth
            HEIGHT     nHeigth
            ITEMS      xValue
            VALUE      1
            FONTNAME   "FixedSys"
            FONTSIZE   10
         END COMBOBOX
*/
   ENDCASE cCntrType

RETU // CoOp1Item()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFUFldLst(;               // Get From User Field List ( as String )
                cDelimiter )

   LOCA cRVal   := '',;
        aFldLst := FldNArry()

   LOCA aSelect := GFUSList( aFldLst, "Select Field(s)", .T. )

   DEFAULT cDelimiter TO ';'

   AEVAL( aSelect, { | l1, i1 | cRVal += IF( l1, aFldLst[ i1 ] + cDelimiter,'' ) } )

   cRVal := ALLTRIM( LEFT( cRVal, LEN( cRVal ) - 1 ) )

RETU cRVal // GFUFldLst()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC Cond2Exps(;              // Conditions ( & scopes ) to Expressions
                 aScopes,;    // Scopes
                 aCondits )   // Conditions

   LOCA aRVal     := {},;
        cForClaus := '',;
        cWhlClaus := '',;
        cContinue := '',;
        cApply    := '.T.',;
        nScope    := aScopes[ 1 ]

   LOCA lRestRecs := ( nScope == 3 ),;
        nNextRecs := IF( nScope == 4, aScopes[ 2 ], 0 ),;
        nRecoNumb := IF( nScope == 5, aScopes[ 2 ], 0 )

   IF nNextRecs > 0
      cContinue := "nPasdRecs<" + NTrim( nNextRecs )
   ELSE
      IF nRecoNumb > 0
         cContinue := "nPasdRecs < 1"
      ENDIF
   ENDIF

   IF aCondits[ 1 ] > 1 // Condition setted
      IF aCondits[ 1 ] > 2 // WHILE
         cWhlClaus := aCondits[ 2 ]
         cContinue += IF( EMPTY( cContinue ), '', '.AND.') + cWhlClaus
      ELSE  // FOR
         cForClaus := aCondits[ 2 ]
         cApply    := cForClaus
      ENDIF
   ENDIF Condition setted

   cContinue += IF( EMPTY( cContinue ), '', '.AND.') + "!EOF()"

   IF nRecoNumb > 0
      DBGOTO( nRecoNumb )
   ELSE
      IF !EMPTY( cForClaus ) .OR. nScope == 2
         DBGOTOP()
      ENDIF
   ENDIF

   aRVal := { cContinue, cApply }

RETU aRVal // Cond2Exps()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC FieldValid( ;
                 cFieldList )

   LOCA cRVal  := '',;
        c1FNam := '',;
        aStruc := DBSTRUCT()

   WHILE !EMPTY( cFieldList )
      c1FNam := UPPER( ALLTRIM( ExtrcSFS( @cFieldList, ',' ) ) )
      IF !EMPTY( c1FNam )
         IF ASCAN( aStruc, { | a1 | a1[ 1 ] == c1FNam } ) < 1
            cRVal := c1FNam
            EXIT
         ENDIF ASCAN( aStruc ...
      ENDIF !EMPTY( c1FNam )
   ENDDO

RETU cRVal // FieldValid()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC FNamValid( ;                          // Validity Check for Output or Input File Name
               cOFName,;
               aControls,;
               cCtrNam,;
               lOutput )

   LOCA lRVal     := '',;
        nCtrlNo   :=  0,;
        a1Control := {},;
        nTFCtrNo  :=  0,;
        cTFCtrNam := '',;
        nOFType   :=  0

   DEFAULT lOutput TO .T.
   
* DispAnya( aControls )

   IF ! ( "." $ cOFName )

      FOR nCtrlNo := 1 TO LEN( aControls )

         IF ISARRY( aControls[ nCtrlNo ] )
            a1Control := aControls[ nCtrlNo ]
            nTFCtrNo  := ASCAN( a1Control, { | c1 | "cmb_TFT" $ c1 } )
         ENDIF ISARRY( ...

         IF nTFCtrNo > 0
            cTFCtrNam := aControls[ nCtrlNo, nTFCtrNo ]
            EXIT FOR
         ENDIF nTFCtrNo > 0

      NEXT nLineNo
      
      IF EMPTY( cTFCtrNam )
         cOFName += '.dbf'
         
      ELSE
         nOFType   := GetProperty( 'frmComOpts', cTFCtrNam, 'VALUE' )
         
         IF nOFType > 0
            IF nOFType == 1
               cOFName += '.dbf'
            ELSE
               cOFName += '.txt'
            ENDIF
         ENDIF nOFType > 0

      ENDIF
      
      SetProperty( 'frmComOpts', cCtrNam, 'VALUE', cOFName )
      
   ENDIF ! ( "." $ cOFName )

   IF lOutput
      lRVal := ChekOWrt( cOFName )
   ELSE
      lRVal := FILE( cOFName )
   ENDIF lOutput

RETU lRVal // FNamValid()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFUKFList( ;          // Key Field List ( for SORT )
                cCFList,;  // Current Field List
                cFFList )  // Full Field List

   LOCA cRVal     := '',;
        aFFldList := Lst2Arr( cFFList, ',' ),;
        aCFldList := Lst2Arr( cCFList, ',' ),;
        aGrItems  := KFL2Arr( cCFList, aFFldList )


   DEFINE WINDOW frmKFList ;
      AT 0,0 ;
      WIDTH  334 ;
      HEIGHT 280 ;
      TITLE 'Key fields and options' ;
      MODAL
      
      ON KEY ESCAPE ACTION frmKFList.Release

      @ 10,10 GRID grdKFList ;
          WIDTH  310 ;
          HEIGHT 200 ; // ( LEN( aCFldList ) + 1 )* 20  ;
          HEADERS { 'Field','Order','Case' } ;
          WIDTHS { 120, 90, 90 } ;
          ITEMS aGrItems ;
          EDIT ;
          COLUMNCONTROLS { { 'COMBOBOX', aFFldList },;
                           { 'CHECKBOX', 'Ascending' , 'Descending' },;
                           { 'CHECKBOX', 'Sensitive' , 'Ignore' } }

      DEFINE BUTTON btnAdd
         ROW        220
         COL        48
         WIDTH      48
         HEIGHT     20
         CAPTION    "Add"
         ACTION     { || IF(frmKFList.grdKFList.Cell( frmKFList.grdKFList.ItemCount, 1 ) > 0,;
                            frmKFList.grdKFList.AddItem( { 0, .T., .T. } ), ) }
*         FONTNAME   "FixedSys"
*         FONTSIZE   6
      END BUTTON
                           
      DEFINE BUTTON btnDelete
         ROW        220
         COL        144
         WIDTH      48
         HEIGHT     20
         CAPTION    "Delete"
         ACTION     { || IF(frmKFList.grdKFList.ItemCount > 1,;
                            frmKFList.grdKFList.DeleteItem( frmKFList.grdKFList.Value ), ) }
*         FONTNAME   "FixedSys"
*         FONTSIZE   6
      END BUTTON
                           
      DEFINE BUTTON btnApply
         ROW        220
         COL        240
         WIDTH      48
         HEIGHT     20
         CAPTION    "Apply"
         ACTION     { || cRVal := AplyKLst(aFFldList),  frmKFList.Release }
*         FONTNAME   "FixedSys"
*         FONTSIZE   6
      END BUTTON
                           
   END WINDOW

   CENTER WINDOW frmKFList

   ACTIVATE WINDOW frmKFList

RETU cRVal // GFUKFList()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC KFL2Arr( ;                           // Key field list to array
               cKFList,;
               aFFldList )

   LOCA aRVal    := {},;
        c1Field  := '',;
        c1FldNam := '',;
        n1FldNum :=  0,;
        c1Switch := '',;
        c2Switch := '',;
        l1Order  := .T.,;  // .T. : Ascending, .F. : Descending
        l1Case   := .T.    // .T. : Ignore, .F. : Apply

   cKFList := UPPER( cKFList )

   WHILE !EMPTY( cKFList )
      c1Field := ALLTRIM( ExtrcSFS( @cKFList, ',' ) )
      IF !EMPTY( c1Field )
         c1FldNam := ExtrcSFS( @c1Field, '/' )
         n1FldNum := ASCAN( aFFldList, c1FldNam )
         IF EMPTY( c1Field )
            l1Order := .T.
            l1Case  := .T.
         ELSE
            l1Order := !( "/D" $ c1Field )
            l1Case  := !( "/C" $ c1Field )
         ENDIF
         AADD( aRVal, { n1FldNum, l1Order, l1Case } )
      ENDIF
   ENDDO

RETU aRVal // KFL2Arr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC AplyKLst( ;                          // Make Return Value for GFUKFList()
              aFFldList )
              
   LOCA nCBItCo := frmKFList.grdKFList.ItemCount,;  // Grid\ComboBox\Item Count
        nCBIInd := 0,;                              // Grid\ComboBox\Item indice
        cKFList := '',;                             // Key fields list
        nFldNum :=  0,;
        cFldNam := '',;
        lOrdAsc := .F.,;
        lCasSen := .F.,;
        nCBRInd

   FOR nCBRInd := 1 TO nCBItCo
        nFldNum := frmKFList.grdKFList.Cell( nCBRInd, 1 )
        cFldNam := aFFldList[ nFldNum ]
        lOrdAsc := frmKFList.grdKFList.Cell( nCBRInd, 2 )
        lCasSen := frmKFList.grdKFList.Cell( nCBRInd, 3 )
        cKFList += TRIM( cFldNam ) + " " + IF( lOrdAsc,'','/D' ) + IF( lCasSen,'','/C' ) + ", "
   NEXT nCBRInd 
   
   cKFList := LEFT( cKFList, LEN( cKFList ) - 2 )
    
RETU cKFList // AplyKLst()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC KeysValid( ;
                 cKeysList )
                 
   LOCA cRVal := '',;
        c1Key := '',;
        c1Fld := '',;
        c1Swt := '',;
        c2Swt := ''
   
   WHILE !EMPTY( cKeysList )
      c1Key := ALLTRIM( ExtrcSFS( @cKeysList, ',' ) )
      c1Fld := ALLTRIM( ExtrcSFS( @c1Key, "/" ) ) 
      IF EMPTY(FieldValid( c1Fld ))
         c1Swt := ALLTRIM( ExtrcSFS( @c1Key, "/" ) ) 
         c2Swt := ALLTRIM( ExtrcSFS( @c1Key, "/" ) ) 
         IF !EMPTY( c1Swt ) .AND. ! c1Swt $ "ACD"
            cRVal := c1Swt 
         ENDIF
         IF !EMPTY( c2Swt ) .AND. ! c2Swt $ "ACD"
            cRVal := c2Swt 
         ENDIF
      ELSE
         cRVal := c1Fld
      ENDIF    
      IF !EMPTY( cRVal )
         EXIT
      ENDIF
   ENDDO   
   
RETU cRVal // KeysValid()
                 
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
