#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain
DECLARE WINDOW frmCombFrm

REQUEST DESCEND

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFUSList( ;                          // Get From User a Selection List
               aSelect,;
               cTitle,;
               lAllAble )   // Add an "All" option button

   LOCA nItemNum :=  0,;
        nItemCou :=  LEN( aSelect ),;
        cChkBNam := '',;
        cChkBCap := '',;
        nCaptLen :=  0,;
        nButtRow :=  0,;
        nBut1Col :=  0,;
        cString  := ''

   LOCA aGSLRVal := ARRAY( nItemCou )

   LOCA nWinWidt ,;
        nWinHigh

   AFILL( aGSLRVal, .F. ) 
   
   DEFAULT lAllAble TO .F.
           
   nWinWidt := ArMaxLen( aSelect ) * 13
   nWinHigh := ( LEN( aSelect ) + 6 ) * 20

   IF LEN( aSelect ) > 15
      DEFINE WINDOW frmGFUSL;
         AT 0, 0 ;
         WIDTH  nWinWidt ;
         HEIGHT 378 ;             // (15 + 2.6) * 20
         VIRTUAL HEIGHT nWinHigh ;
         TITLE cTitle  ;
         MODAL
      END WINDOW // frmGFUSL
   ELSE
      DEFINE WINDOW frmGFUSL;
         AT 0, 0 ;
         WIDTH  nWinWidt ;
         HEIGHT nWinHigh ;
         TITLE cTitle  ;
         MODAL
      END WINDOW // frmGFUSL
   ENDIF LEN( aDataLst ) > 10

   ON KEY ESCAPE OF frmGFUSL ACTION frmGFUSL.Release

   IF lAllAble
      DEFINE BUTTON btnAll
         PARENT frmGFUSL
         ROW  10
         COL  20
         CAPTION "All"
         ACTION  { || SetASLst( aGSLRVal ) }
         WIDTH   60
         HEIGHT  21
      END BUTTON // btnApply
   ENDIF

   FOR nItemNum := 1 TO nItemCou

      cChkBNam := "chb_" + STRZERO( nItemNum, 3 )
      cChkBCap := aSelect[ nItemNum ]
      nCaptLen := ( LEN( aSelect[ nItemNum ] ) + 2 ) * 10

      @  ( nItemNum + IF( lAllAble, 1, 0 ) ) * 20, 20 ;
         CHECKBOX &cChkBNam ;
         OF frmGFUSL ;
         CAPTION  cChkBCap ;
         WIDTH    nCaptLen  ;
         HEIGHT   15 ;
         FONT     "FixedSys" ;
         SIZE     10

   NEXT nItemNum

   DEFINE BUTTON btnApply
      PARENT frmGFUSL
      ROW nWinHigh - 80
      COL ( nWinWidt - 60 ) / 2
      CAPTION "Apply"
      ACTION  { || AplySLst( aGSLRVal ),  frmGFUSL.Release }
      WIDTH   60
      HEIGHT  21
   END BUTTON // btnApply

   CENTER   WINDOW frmGFUSL
   ACTIVATE WINDOW frmGFUSL
      
RETU aGSLRVal // GFUSList()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC AplySLst(;                            // Make Return Value for GFUSList()
               aResArray )

   LOCA cC1Name := '',;
        nChBxNo := 0

   FOR nChBxNo := 1 TO LEN( aResArray )
      cC1Name := "chb_" + STRZERO( nChBxNo, 3 )
      aResArray[ nChBxNo ] := GetProperty( "frmGFUSL", cC1Name, "VALUE" )
   NEXT nChBxNo

*  frmGFUSL.Release

RETU // AplySLst()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC SetASLst(;                           // Set All button of GFUSList()
               aResArray )

   LOCA cC1Name := '',;
        nChBxNo := 0

   FOR nChBxNo := 1 TO LEN( aResArray )

      cC1Name := "chb_" + STRZERO( nChBxNo, 3 )

      SetProperty( "frmGFUSL", cC1Name, "VALUE", .T. )

   NEXT nChBxNo

RETU // SetASLst()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GoNxCntrl( ;                         // Go ( Set Focus ) Next Control ( ON ENTER )
                  cFrmName ,;
                  cCntName ,;
                  nItemCo  ,;
                  cLastItm )

   LOCA nItemNum := VAL( RIGHT( cCntName, 3 ) )

   LOCA cNxtCNam := IF( nItemNum < nItemCo, LEFT( cCntName, LEN( cCntName ) - 3 ) + ;
                        STRZERO( nItemNum + 1, 3 ), cLastItm )

*  SETFOCUS &cNxtCNam OF &cFrmName

   _SetFocus( cNxtCNam, cFrmName) // BU çalýþmýyor (veya çalýþtýðý görülmüyor) ( üstteki de ! )

RETU // GoNxCntrl()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFU1Sele( ;                          // Get From User 1 ( single ) selection from a list
               aSelect ,;
               cTitle  )

   LOCA nRVal    := 0,;
        nItemCo  := LEN( aSelect ),;
        nItemNum :=  0,;
        cbtn1Nam := '',;
        cbtn1Val := '',;
        nStrgLen := ArMaxLen( aSelect )

   LOCA nBtnLeng := nStrgLen * 8.5

   LOCA nWinWidt := nBtnLeng + 40,;
        nWinHigh := ( nItemCo + 4 ) * 20

   IF LEN( aSelect ) > 15
      DEFINE WINDOW frmGFU1S;
         AT 0, 0 ;
         WIDTH  nWinWidt ;
         HEIGHT 378 ;
         VIRTUAL HEIGHT nWinHigh ;
         TITLE cTitle  ;
         MODAL
      END WINDOW // frmGFU1S
   ELSE
      DEFINE WINDOW frmGFU1S;
         AT 0, 0 ;
         WIDTH  nWinWidt ;
         HEIGHT nWinHigh ;
         TITLE cTitle  ;
         MODAL
      END WINDOW // frmGFU1S
   ENDIF LEN( aDataLst ) > 10

   ON KEY ESCAPE OF frmGFU1S ACTION frmGFU1S.Release

   FOR nItemNum := 1 TO nItemCo

      cbtn1Nam := "btn_" + STRZERO( nItemNum, 3 )
      cbtn1Val := PAD( aSelect[ nItemNum ], nStrgLen )

      DEFINE BUTTON  &cbtn1Nam
         PARENT   frmGFU1S
         ROW      nItemNum * 20
         COL      10
         CAPTION  cbtn1Val
         ACTION   { | | nRVal := VAL( RIGHT( this.name, 3 ) ), frmGFU1S.Release }
         WIDTH    nBtnLeng
         HEIGHT   21
         FONTNAME "Courier New"
         FONTSIZE 9
       END BUTTON

   NEXT nItemNum

   CENTER   WINDOW frmGFU1S
   ACTIVATE WINDOW frmGFU1S

RETU nRVal // GFU1Sele()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC MakePict( nWidth, nDeci )
   LOCA cRVal := RIGHT( REPL(','+'999',10) + IF(nDeci>0,'.'+REPL('9',nDeci),''),nWidth )
   IF LEFT( cRVal, 1 ) == ","
      cRVal := "9" + SUBS( cRVal, 2 )
   ENDIF
RETU cRVal // MakePict()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CFMValLn( ;                          // Combo Form Max Value Length ( in char )
                aPrompt,;  // Prompt ( label, for Fields : Name )
                aDTypes,;  // Data Types
                aWidths,;  // Nominal Widths
                aDecims,;  // Decimals
                aValues )  // Values

   LOCA nRVal :=  0,;
        c1Prm := '',;
        nInds :=  0,;
        n1Len :=  0,;
        n1Dec :=  0,;
        c1Typ := '',;
        x1Val

   DEFAULT aPrompt TO ARRAY( LEN( aValues ) )

   FOR nInds := 1 TO LEN( aDTypes )
      c1Prm  := aPrompt[ nInds ]
      c1Typ  := aDTypes[ nInds ]
      n1Len  := aWidths[ nInds ]
      n1Dec  := aDecims[ nInds ]
      x1Val  := aValues[ nInds ]
      nRVal  := MAX( nRVal, DispLeng( { c1Prm, c1Typ, n1Len, n1Dec }, x1Val, .T., .T. ) )
   NEXT nInds

RETU nRVal // CFMValLn()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CFBtn1Act( aValues, aValids, aButtons, aCdBloks, cBtnName )

   LOCA nRVal := 0

   IF CBAppBlock( aValues, aValids, aButtons, aCdBloks, cBtnName )
      nRVal := Name2Num( cBtnName )
   ENDIF

RETU nRVal // CFBtn1Act()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CBAppBlock( ;                        // Apply a codeBlock for a button of ComboForm()
                 aValues,;      // Structured data set's values
                 aValids,;      // Validity ( Acceptence ) infos
                 aButtons,;     // Buttons
                 aCdBloks,;     // Code Blocks
                 cBttnNam )     // Name of caller Button

   LOCA nBttnNum := Name2Num( cBttnNam ) // Number of caller Button

   LOCA a1Button := aButtons[ nBttnNum ]

   LOCA lApAcce := a1Button[ 4 ],;    // Apply Acceptence
        lSavBef := a1Button[ 5 ],;    // Save Before
        aCBsSeq := a1Button[ 6 ],;    // Code Blocks List to execute
        lRelAft := a1Button[ 7 ]      // Release After

   LOCA nCBSeqNo :=   0,;
        nCBlokNo :=   0,;
        lAcceptd := .T.,;
        b1CBlock

   LOCA nVInd    := 0,;
        cCntrNam := ''

   IF lApAcce
      lAcceptd := CFCAccept( aValues, aValids )
   ENDIF

   IF lAcceptd

      IF lSavBef
         AEVAL( aValues, { | x1, i1 | aValues[ i1 ] := ;
                          _Getvalue( Num2Name( "cfc_", i1 ), "frmCombFrm" ), HB_SYMBOL_UNUSED( x1 ) } )
      ENDIF lSavBef

      FOR nCBSeqNo := 1 TO LEN( aCBsSeq )
         nCBlokNo := aCBsSeq[ nCBSeqNo ]
         IF nCBlokNo < 100
            b1CBlock := aCdBloks[ nCBlokNo ]
            EVAL( b1CBlock )
         ELSE
            b1CBlock := aCdBloks[ nCBlokNo - 100 ]
            AEVAL( aValues, b1CBlock )
         ENDIF nCBlokNo < 100
      NEXT nCBSeqNo

      IF lRelAft
         frmCombFrm.Release
      ENDIF
   ENDIF lAcceptd

RETU lAcceptd  // CBAppBlock()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CFCAccept( ;                         // Combo Form Chek Acceptence ( validities )
                 aValues,;
                 aValids )

   LOCA lRVal   := .T.,;
        nVInd   :=  0,;
        nAInd   :=  0,;
        aBlocks := {},;
        aMesags := {},;
        c1Mesag := '',;
        a1Valid ,;
        b1CBlok

   MEMV x1Value

   PRIV x1Value := NIL // for privatisation
   HB_SYMBOL_UNUSED( aValues )

   FOR nVInd := 1 TO LEN( aValids )

      a1Valid := aValids[ nVInd ]

      IF ISARRY( a1Valid )
         aBlocks := a1Valid[ 1 ]
         aMesags := a1Valid[ 2 ]
         x1Value := _GetValue( Num2Name( "cfc_", nVInd ), "frmCombFrm" )
         FOR nAInd := 1 TO LEN( aBlocks )
            b1CBlok := aBlocks[ nAInd  ]
            IF ! ( lRVal := EVAL( b1CBlok, x1Value ) )
               IF ISCHAR( aMesags[ nAInd  ] )
                  c1Mesag := aMesags[ nAInd  ]
                  MsgBox( c1Mesag )
               ENDIF
               EXIT FOR
            ENDIF
         NEXT nAInd

         IF !lRVal
            EXIT FOR
         ENDIF

      ENDIF !ISNIL( a1Valid )
   NEXT nVInd

RETU lRVal // CFCAccept()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoFoGetData(;                        // ComboForm Get ( Read ) Data
                  aValues,;      // CoFo Values
                  aRDBloks )     // CoFo Data Get (Read) Code Blocks

   LOCA cCFVCName := '',;          // Combo Box Value Control Name
        nItemNum :=  0,;
        b1RDBlock := NIL

   FOR nItemNum := 1 TO LEN ( aValues )

      b1RDBlock := aRDBloks[ nItemNum ]

      aValues[ nItemNum ] := EVAL( b1RDBlock )

      cCFVCName := "cfc_" + STRZERO( nItemNum, 3 )  // Combo Box Value Control Name

      _SetValue( cCFVCName, "frmCombFrm", aValues[ nItemNum ] )

   NEXT nItemNum

RETU // CoFoGetData()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoFoPutData(;                        // ComboForm Put ( Write ) Data
                  aValues,;      // CoFo Values
                  aWDBloks )     // CoFo Data Get (Read) Code Blocks

   LOCA cCFVCName := '',;          // Combo Box Value Control Name
        nItemNum  :=  0,;
        b1WDBlock := NIL,;
        x1Value   := NIL

   FOR nItemNum := 1 TO LEN ( aValues )

      cCFVCName := "cfc_" + STRZERO( nItemNum, 3 )  // Combo Box Value Control Name

      x1Value   := _GetValue( cCFVCName, "frmCombFrm" )

      aValues[ nItemNum ] := x1Value      // Belli olmaz, belki lâzým olur !?

      b1WDBlock := aWDBloks[ nItemNum ]

      EVAL( b1WDBlock, x1Value )

   NEXT nItemNum

RETU // CoFoPutData()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   p.ComboForm() : Define a multiple values form ( Window )

   SynTax :
             ComboForm( <cCFTitl>    ,;  // Combo Form's Title
                        <aLabels>    ,;  // Labels
                        <aValues>    ,;  // Data Values
                        [<aDTypes>]  ,;  // Data Types
                        [<aWidths>]  ,;  // Data Widths
                        [<aDecims>]  ,;  // Data Decimals
                        [<aROnlys>]  ,;  // ReadOnly ?
                        [<aValids>]  ,;  // Data Validity Code Blocks
                        [<aButtons>] ,;  // Buttons
                        [<aCdBloks>]  )  // Buttons's Actions ( Code Blocks )
             => nExiting Button no; if discarded, 0.

   Arguments :

       <cCFTitl>  : Combo Form's Title

       <aLabels>  : Labels
       <aValues>  : Data Values
       <aDTypes>  : Data Types; DEFAULT : Type of associated Value.
       <aWidths>  : Data Widths; DEFAULT : Width of associated Value.
       <aDecims>  : Data Decimals; DEFAULT : 0
       <aROnlys>  : ReadOnly ? DEFAULT : .F.
       <aValids>  : Data Validity Code Blocks; DEFAULT : No Validity check.

       This seven arrays combine together the dataset and all must be equal size.

       <aButtons> : Buttons array, one elem for each button;
                    each button defined as an array with seven elems :

                    1° : Button size : IF( NIL/0 : Text Caption, Picture width )
                    2° : Button caption or picture name
                    3° : Button Tooltip
                    4° : Apply Acceptences
                    5° : Save Before : Save control values to data source before execution ?
                    6° : Code Block apply sequence array. Elems of this array indicates
                         number of code block to execute. A number greather than 100
                         means the code block will be applicate on the Values array.
                         NIL or EMPTY : No Application.
                    7° : Release Combo Form after all code block executed ? :
                         NIL / .F. : Continue, .T. Release Combo Form
                    8° : Associated with : item number to associate this button


       <aCdBloks> : Code blocks array for buttons, one elem for each action;
                    each button may have own action sequence, numbers of code block
                    in this array.

*/

FUNC ComboForm(;                          // Define a multiple values form ( Window )
                 cCFTitl ,;  //  1. Combo Form's Title
                 aLabels ,;  //  2. Labels
                 aValues ,;  //  3. Data Values
                 aDTypes ,;  //  4. Data Types
                 aWidths ,;  //  5. Data Widths
                 aDecims ,;  //  6. Data Decimals
                 aROnlys ,;  //  7. ReadOnly ?
                 aValids ,;  //  8. Data Validity Code Blocks
                 aButtons,;  //  9. Buttons
                 aCdBloks,;  // 10. Actions
                 aRDBloks,;  // 11. Read Data Blocks ( from sources to controls )
                 aWDBloks )  // 12. Write Data Blocks ( from controls to tagrgets )


   LOCA nRVal   := 0,;
        aParams := {}

   LOCA nLblMaxLen :=  0,;
        nValMaxLen :=  0,;
        nFrmMaxWid := GetDesktopWidth()  * 0.8,;
        nFrmMaxHig := GetDesktopHeight() * 0.8,;
        nItemCo    :=  0,;
        nLnSpace   := 27,;
        nFrmLinCo  :=  0,;
        nFrmWidth  :=  0,;
        nFrmHight  :=  0,;
        nItemNum   :=  0,;
        n1itRow    :=  0,;  // Combo Form 1 item Row No
        nLblCol    := 10,;
        nValueCol  :=  0,;
        nValueRow  :=  0,;
        nLblWidth  :=  0,;
        nMaxValWd  :=  0,;
        cCFVCName  := '',;   // Combo Form Value Control Name
        x1iValue   := NIL,;  // 1 item Value
        c1iVNType  := '',;   // 1 item Value Nominal Type
        n1iVNLeng  :=  0,;   // 1 item Value Length ( in char, Nominal )
        n1iVDecim  :=  0,;   // 1 item Value Decimal ( in char )
        n1iVRLeng  :=  0,;   // 1 item Value Length ( in char, Resulting )
        n1iVPLeng  :=  0,;   // 1 item Value Length ( in Pixels )
        l1iReOnly  := .F.,;
        lMultLine  := .F.,;
        lFocuSetd  := .F.

   LOCA nButtonNo  :=  0,;
        a1Button   := {},;
        nButnSize  :=  0,;
        nButnHigh  := 21,;
        cButnName  := '',;
        cButnCapt  := '',;
        cButnTTip  := '',;
        nButnsRow  :=  0,;
        nButn1Col  :=  0,;
        nButnAsso  :=  0,;  // Button associated control numb
        nButnAsCo  :=  0,;  // Control associated button count
        nButnARow  :=  0,;
        nButnACol  :=  0,;
        cBAsCName  := '',;  // Button associated control name
        nBAsCWidt  :=  0,;  // Button associated control width
        nBtnTotSz  :=  0,;
        nBtnSpace  :=  0,;
        lBtnPictr  := .F.,;
        lVirtHeig  := .F.,;
        clblNam

   IF PCOUNT() == 1
      aParams  := cCFTitl
      cCFTitl  := IF( LEN( aParams ) <  1, , aParams[  1 ] ) // Combo Form's Title
      aLabels  := IF( LEN( aParams ) <  2, , aParams[  2 ] ) // Labels
      aValues  := IF( LEN( aParams ) <  3, , aParams[  3 ] ) // Data Values
      aDTypes  := IF( LEN( aParams ) <  4, , aParams[  4 ] ) // Data Types
      aWidths  := IF( LEN( aParams ) <  5, , aParams[  5 ] ) // Data Widths
      aDecims  := IF( LEN( aParams ) <  6, , aParams[  6 ] ) // Data Decimals
      aROnlys  := IF( LEN( aParams ) <  7, , aParams[  7 ] ) // ReadOnly ?
      aValids  := IF( LEN( aParams ) <  8, , aParams[  8 ] ) // Data Validity Code Blocks
      aButtons := IF( LEN( aParams ) <  9, , aParams[  9 ] ) // Buttons
      aCdBloks := IF( LEN( aParams ) < 10, , aParams[ 10 ] ) // Actions
      aRDBloks := IF( LEN( aParams ) < 11, , aParams[ 11 ] ) // Data Get ( Read ) Blocks
      aWDBloks := IF( LEN( aParams ) < 12, , aParams[ 12 ] ) // Data Put ( Write ) Blocks
   ENDIF

   DEFAULT cCFTitl  TO '',;
           aValues  TO {},;
           aDTypes  TO {},;
           aROnlys  TO {},;
           aButtons TO {},;
           aCdBloks TO {},;
           aValids  TO {},;
           aWidths  TO {},;
           aDecims  TO {},;
           aRDBloks TO {},;
           aWDBloks TO {}

   IF EMPTY( aValues ) .AND. !EMPTY( aRDBloks )
      AEVAL( aRDBloks, { | b1 | AADD( aValues, EVAL( b1 ) ) } )
   ENDIF EMPTY( aValues )

   nLblMaxLen := ArMaxLen( aLabels )
   nItemCo    := LEN( aLabels )

   ASIZE( aValids, LEN( aValues ) )

   ASIZE( aDTypes, LEN( aValues ) )
   AEVAL( aDTypes, { | x1, i1 | IF( ISNIL( x1 ), aDTypes[ i1 ] := VALTYPE( aValues[ i1 ] ), ) } )

   ASIZE( aROnlys, LEN( aValues ) )
   AEVAL( aROnlys, { | x1, i1 | IF( ISNIL( x1 ), aROnlys[ i1 ] := .F., ) } )

   IF !EMPTY( aButtons )
       AEVAL( aButtons, { | a1 | ASIZE( a1, 8 ) } )
       AEVAL( aButtons, { | a1, i1 | IF( ISNIL( a1[ 4 ] ), aButtons[ i1, 4 ] := .F.,  ),;   // Apply Acceptences
                                     IF( ISNIL( a1[ 5 ] ), aButtons[ i1, 5 ] := .F.,  ),;   // Save Before
                                     IF( ISNIL( a1[ 6 ] ), aButtons[ i1, 6 ] := {},   ),;   // Code Blocks
                                     IF( ISNIL( a1[ 7 ] ), aButtons[ i1, 7 ] := .F.,  ),;   // Release After
                                     IF( ISNIL( a1[ 8 ] ), aButtons[ i1, 8 ] :=  0,   ) } ) // Associate with
       AEVAL( aButtons, { | a1 | nButnAsCo += IF( a1[ 8 ] > 0, 1, 0 ) } )
   ENDIF !EMPTY( aButtons )

   ASIZE( aWidths, LEN( aValues ) )
   AEVAL( aWidths, { | x1, i1 | IF( ISNIL( x1 ), aWidths[ i1 ] := ;
          IF( VALTYPE( aValues[ i1 ] ) == "C", LEN( aValues[ i1 ] ) + 2, 0 ), ) } )

   ASIZE( aDecims, LEN( aValues ) )
   AEVAL( aDecims, { | x1, i1 | IF( ISNIL( x1 ), aDecims[ i1 ] := 0, ) } )

   nValMaxLen := CFMValLn( , aDTypes, aWidths, aDecims, aValues ) - 3

   nFrmLinCo  := nItemCo + ArrCount( aDTypes, "M" ) * 2
   nFrmWidth  := MIN( ( nLblMaxLen + nValMaxLen  ) * 8 + 30, nFrmMaxWid )

   nFrmHight  := ( nFrmLinCo + IF( EMPTY( aButtons ), 3, 5 ) ) * nLnSpace

   nLblWidth  := nLblMaxLen * 8
   nMaxValWd  := MIN( nFrmWidth - ( ( nLblMaxLen + 5 ) * 8 + 30 ), ( nValMaxLen * 8 ) )

   lVirtHeig  := nFrmHight > nFrmMaxHig

   IF lVirtHeig
      DEFINE WINDOW frmCombFrm;
         AT 0, 0 ;
         WIDTH  nFrmWidth ;
         HEIGHT 378 ;             // (15 + 2.6) * 20
         VIRTUAL HEIGHT nFrmHight ;
         TITLE cCFTitl  ;
         MODAL ;
         ON INIT NIL ;  // SayBekle( { frmCombFrm.Height, nWinWidt, nWinHigh} )
         ON RELEASE NIL // EVAL( bOnRelas )
      END WINDOW // frmCombFrm
   ELSE
      DEFINE WINDOW frmCombFrm;
         AT 0, 0 ;
         WIDTH  nFrmWidth ;
         HEIGHT nFrmHight ;
         TITLE cCFTitl  ;
         MODAL ;
         ON INIT NIL ; // SayBekle( { frmCombFrm.Height, nWinWidt, nWinHigh} )
         ON RELEASE NIL // EVAL( bOnRelas )
      END WINDOW // frmCombFrm
   ENDIF lVirtHeig

   n1itRow := nLnSpace

   FOR nItemNum := 1 TO nItemCo

      clblNam  := "lbl_" + STRZERO( nItemNum, 3 )

      DEFINE LABEL  &clblNam
         PARENT     frmCombFrm
         ROW        n1itRow
         COL        nLblCol
         PARENT     frmCombFrm
         VALUE      aLabels[ nItemNum ]
         WIDTH      nLblWidth
         HEIGHT     15
         FONTNAME   "FixedSys"
         FONTSIZE   10
         RIGHTALIGN .T.
      END LABEL

      cCFVCName := "cfc_" + STRZERO( nItemNum, 3 )  // Combo Box Value Control Name

      x1iValue  := aValues[ nItemNum ]  // 1 item Value
      c1iVNType := aDTypes[ nItemNum ]  // 1 item Nominal Type
      n1iVNLeng := aWidths[ nItemNum ]  // 1 item Value Length ( in char, Nominal )
      n1iVDecim := aDecims[ nItemNum ]  // 1 item Value Decimal ( in char )
      l1iReOnly := aROnlys[ nItemNum ]  // 1 item Value is ReadOnly ?

      n1iVRLeng := ;                    // 1 item Value Length ( in char, Resulting )
                   DispLeng( { , c1iVNType, n1iVNLeng, n1iVDecim }, x1iValue, .T. ) // + 2

      n1iVPLeng  := n1iVRLeng * 8       // 1 item Value Length ( in Pixels )

      nValueRow  := n1itRow - IF( ISLOGI( x1iValue ), 5, 3 )
      nValueCol  := nLblCol + nLblWidth + 10

      lMultLine  := .F.

      DO CASE

         CASE ISDATE( x1iValue )

            DEFINE DATEPICKER &cCFVCName
               ROW       nValueRow
               COL       nValueCol
               PARENT    frmCombFrm
               VALUE     x1iValue
               FONTNAME  "FixedSys"
               FONTSIZE  10
               ON ENTER  { || GoNxCntrl( "frmCombFrm", this.name, nItemCo, "btn_001" ) }
            END DATEPICKER

         CASE ISLOGI( x1iValue )

            IF l1iReOnly
               DEFINE TEXTBOX &cCFVCName
                  ROW       nValueRow
                  COL       nValueCol
                  PARENT    frmCombFrm
                  WIDTH     n1iVPLeng
                  HEIGHT    20
                  READONLY  .T.
                  VALUE     AnyToStr( x1iValue )
                  FONTNAME  "FixedSys"
                  FONTSIZE  10
                  ON ENTER  { || GoNxCntrl( "frmCombFrm", this.name, nItemCo, "btn_001" ) }
               END TEXTBOX
            ELSE
               DEFINE CHECKBOX &cCFVCName
                  ROW       nValueRow
                  COL       nValueCol
                  PARENT    frmCombFrm
                  VALUE     x1iValue
                  FONTNAME  "FixedSys"
                  FONTSIZE  10
               END CHECKBOX
            ENDIF l1iReOnly

         CASE ISNUMB( x1iValue ) .OR. ISCHAR( x1iValue )

            IF c1iVNType == "M"
               lMultLine := .T.
               DEFINE EDITBOX &cCFVCName
                  ROW       nValueRow
                  COL       nValueCol
                  PARENT    frmCombFrm
                  WIDTH     nMaxValWd
                  MAXLENGTH nMaxValWd
                  HEIGHT    60
                  READONLY  l1iReOnly
                  VALUE     x1iValue
                  FONTNAME  "FixedSys"
                  FONTSIZE  10
                  ON ENTER  { || GoNxCntrl( "frmCombFrm", this.name, nItemCo, "btn_001" ) }
               END EDITBOX
            ELSE
               DEFINE TEXTBOX &cCFVCName
                  ROW       nValueRow
                  COL       nValueCol
                  PARENT    frmCombFrm
                  WIDTH     MIN( n1iVPLeng, nMaxValWd )
                  HEIGHT    20
                  READONLY  l1iReOnly
                  VALUE     x1iValue
                  IF ISNUMB( x1iValue   )
                     NUMERIC   .T.
                     INPUTMASK MakePict( n1iVNLeng, n1iVDecim )
*                  ELSE
*                     INPUTMASK REPL( 'A', n1iVNLeng )
                  ENDIF
                  FONTNAME  "FixedSys"
                  FONTSIZE  10
                  MAXLENGTH nMaxValWd
                  ON ENTER  { || GoNxCntrl( "frmCombFrm", this.name, nItemCo, "btn_001" ) }
               END TEXTBOX
            ENDIF c1iVNType == "M"

         CASE ISARRY( x1iValue )

            DEFINE COMBOBOX &cCFVCName
               PARENT    frmCombFrm
               ROW       nValueRow
               COL       nValueCol
               ITEMS     x1iValue
               VALUE     1
               FONTNAME  "FixedSys"
               FONTSIZE  10
            END COMBOBOX

      ENDCASE

      IF !lFocuSetd .AND. !l1iReOnly
         lFocuSetd := .T.
         SETFOCUS &cCFVCName OF frmCombFrm
      ENDIF !lFocuSetd

      n1itRow += nLnSpace * IF( lMultLine, 3, 1 )

   NEXT nItemNum

   IF !EMPTY( aButtons )

      nButnsRow := n1itRow += nLnSpace

      AEVAL( aButtons, { | a1 | nBtnTotSz += ;
                                IF( a1[ 8 ] > 0, 0,;
                                IF( ISNIL( a1[ 1 ] ), LEN( a1[ 2 ] ) * 8 + 4, a1[ 1 ] + 4 )) } )

      nBtnSpace := ( nFrmWidth - nBtnTotSz - IF( lVirtHeig, 20, 0 ) ) / ((LEN(aButtons)-nButnAsCo)+ 1 )

      nButn1Col := nBtnSpace

      FOR nButtonNo := 1 TO LEN( aButtons )

         cButnName  := "btn_" + STRZERO( nButtonNo, 3 )

         a1Button   := aButtons[ nButtonNo ]

         lBtnPictr  := !ISNIL( a1Button[ 1 ] )

         cButnCapt  := aButtons[ nButtonNo, 2 ]
         cButnTTip  := aButtons[ nButtonNo, 3 ]

         nButnSize  := IF( !lBtnPictr, LEN( cButnCapt ) * 8, a1Button[ 1 ] ) + 4

         IF ( nButnAsso := aButtons[ nButtonNo, 8 ] ) > 0
            cBAsCName   := Num2Name( "cfc_", nButnAsso )
            nButnsRow   := GetProperty( "frmCombFrm", cBAsCName, "ROW" )
            nBAsCWidt   := GetProperty( "frmCombFrm", cBAsCName, "WIDTH" )
            nButn1Col   := GetProperty( "frmCombFrm", cBAsCName, "COL" ) + nBAsCWidt
            SetProperty( "frmCombFrm", cBAsCName, "WIDTH", nBAsCWidt - 20 )
         ENDIF nButnAsso > 0

         DEFINE BUTTON &cButnName
            PARENT frmCombFrm
            ROW    nButnsRow
            COL    nButn1Col
            IF lBtnPictr
               PICTURE cButnCapt
            ELSE
               CAPTION cButnCapt
               IF LEN( ALLTRIM( cButnCapt ) ) < 2
                  FONTNAME  "FixedSys"
                  FONTSIZE  9
                  FONTBOLD  .T.
               ENDIF   
            ENDIF lBtnPictr
            ACTION  { || nRVal := CFBtn1Act( aValues, aValids, aButtons, aCdBloks, this.name ) }
            WIDTH   nButnSize
            HEIGHT  nButnHigh
            TOOLTIP cButnTTip
         END BUTTON // btn_xxx
         
         nButn1Col += IF( nButnAsso < 1, nBtnSpace + nButnSize -1, 0 )

      NEXT nButtonNo

   ENDIF EMPTY( aButtons )

   ON KEY ESCAPE OF frmCombFrm ACTION frmCombFrm.Release

   CENTER   WINDOW frmCombFrm
   ACTIVATE WINDOW frmCombFrm

RETU nRVal // ComboForm()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC CoFldList( ;                         // Conditional Field List
              aSelect )

   LOCA cRVal := ''

   AEVAL( aSelect, { | a1, i1 | cRVal += IF(aSelect[i1], FIELDNAME( i1 ) + ',' , '' ), HB_SYMBOL_UNUSED( a1 ) } )

   IF RIGHT( cRVal, 1 ) == ","
      cRVal := LEFT( cRVal, LEN( cRVal ) -1 )
   ENDIF 

RETU cRVal // CoFldList()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC FldNArry()                           // Field Names Array

   LOCA aRVal   := {}

   AEVAL( DBSTRUCT(), { | a1 | AADD( aRVal, a1[ 1 ] ) } )

RETU aRVal // FldNArry()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC CoFoSAsVal(;                        // ComboForm; Set Button associated control's value
                  aValues ,;
                  aButtons,;
                  xValue  ,;       // Value
                  cBtnNam )        // Name of Button associated to control

   LOCA nButnNo := Name2Num( cBtnNam )
   LOCA nValuNo := aButtons[ nButnNo, 8 ]
   LOCA cCtrNam := "cfc_" + STRZERO( nValuNo, 3 )  

   aValues[ nValuNo ] := xValue

   SetProperty( "frmCombFrm", cCtrNam, "VALUE", xValue )

RETU // CoFoSAsVal()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFUNewTNam(;                         // Get From User New Table Name  
                 cFilKind,;
                 cExtention,;
                 lNoChngDir )

   LOCA cNewTNam := '',;
        lDone := .F.

   WHILE !lDone

      cNewTNam  := PutFile ( { { cFilKind + ' Files', cExtention} }, ;
                                 "New " + cFilKind + " Name", ;
                                 cLastDDir, ;
                                 lNoChngDir )

      IF EMPTY( cNewTNam )
         EXIT
      ELSE   
         IF FILE( cNewTNam )
            IF ASCAN( aOpnDatas, { | a1 | cNewTNam == a1[ 3 ] } ) > 0
               MsgStop( "This table is already in use;" + CRLF2 +;
                        "Try Another" )
            ELSE               
               lDone := .T.  // ChekOWrt( cNewTNam ) bu kontrol "CoOpAply" da 
            ENDIF
         ELSE                      
            lDone := .T.
         ENDIF
      ENDIF EMPTY( cNewTNam )
   ENDDO  

RETU cNewTNam  // GFUNewTNam()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GFUSrcTNam(;                         // Get From User Source Table Name  
                 cFilKind,;
                 cExtention,;
                 lNoChngDir )

   LOCA cSrcTNam := '',;
        lDone := .F.

   WHILE !lDone

      cSrcTNam  := GetFile ( { { cFilKind + ' Files', cExtention} }, ;
                                 "Source " + cFilKind + " Name", ;
                                 cLastDDir, ;
                                 lNoChngDir )

      IF EMPTY( cSrcTNam )
         EXIT
      ELSE   
         IF FILE( cSrcTNam )
            IF ASCAN( aOpnDatas, { | a1 | cSrcTNam == a1[ 3 ] } ) > 0
               MsgStop( "This table is already in use;" + CRLF2 +;
                        "Try Another" )
            ELSE               
               lDone := .T.  // ChekOWrt( cNewTNam ) bu kontrol "CoOpAply" da 
            ENDIF
         ELSE                      
            lDone := .T.
         ENDIF
      ENDIF EMPTY( cSrcTNam )
   ENDDO  

RETU cSrcTNam  // GFUSrcTNam()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
