
#include "minigui.ch"
#include "DBA.ch"

/*

   f.DBStructOps()                        // DataBase Structure Operations
   p.DBStrAdjust()                        // DataBase Structure Adjust widths & Decs 
   p.DBStRefrInfo()                       // DataBase Structure Refresh DBF Infos
   p.DBStNewField()                       // DataBase Structure New Field
   f.DBStCellVald()                       // DataBase Structure Cell Validity
   f.DBStVFNam()                          // DataBase Structure Valid Field Name
   p.DBStEdDel()                          // DataBase Structure Delete Field
   p.DBStEdIns()                          // DataBase Structure Insert Field
   p.DBStReNum()                          // DataBase Structure Renumber Fields
   p.DBStInsItem()                        // DataBase Structure Insert Field 
   p.DBStEdMov()                          // DataBase Structure Move Field up or down
   p.DBStAply()                           // DataBase Structure Apply Changes 
   
*/

MEMV aDBStrAdjst ,;
     cRecLenCtrl ,; 
     cFldCouCtrl ,;
     aWrkStruct

FUNC DBStructOps(;                        // DataBase Structure Operations
                 aStruct,;
                 nOperati,;     // 1: Display, 2: Edit, 3: New
                 aDBFInfo,;
                 cFrmTitle,;
                 lMustChange )
                 
   LOCA aRVal := {}
   
   LOCA aFldTypes   := { 'Character','Numeric','Logical','Date','Memo' }
   
   LOCA aColumns :=  { { "NUM", '99' },;            // Field Num
                       { "CHR", '!!!!!!!!!!' },;    // Field Name
                       { "CMB", aFldTypes },;    // Field Type
                       { "NUM",  '999' },;          // Field Width
                       { "NUM",  '99' } }           // Field Dec

   LOCA cStruHelp := "Up/Down : Navigate"      + CRLF +;
                     "Escape    : Exit" + IF( nOperati < 2,'', CRLF +;
                     "Enter       : Edit"          + CRLF +;
                     "^Del        : Delete Field"    + CRLF +;
                     "^Ins        : Insert Field"    + CRLF +;
                     "^Up         : Move Field Up"   + CRLF +;
                     "^Down    : Move Field Down" )
                     
   LOCA nCurFieldNo :=  0,;
        nNextRow    := 10,;
        nNextCol    := 10,;
        aDBInfLabls := {},;
        aDBInfValus := {},;
        nRecLnBoxNo :=  1,;
        nFldCoBoxNo :=  2,;
        cLabelName  := '',;
        cTxBoxName  := '',;
        nDBInfoNo   :=  0

   PRIV aDBStrAdjst := {},;
        cRecLenCtrl := '',; 
        cFldCouCtrl := '',;
        aWrkStruct  := {}
        
   DEFAULT aStruct   TO {},;
           aDBFInfo  TO { 0, 0 },;
           cFrmTitle TO IF( nOperati < 2, "Display", IF( nOperati > 2, "New", "Edit" ) )+ ;
                         " Database File Structure",;
           lMustChange TO .T.              
                         

   IF LEN( aDBFInfo ) > 2
   
      aDBInfLabls := { "File name :",;
                       "Last Modification Date :",;
                       "Record Count :" }

      aDBInfValus := { aDBFInfo[ 1 ],;               // .dbf name
                       DTOC(  aDBFInfo[ 2 ] ),;      // LUPDATE
                       NTrim( aDBFInfo[ 3 ] ) }      // RECC

      AADD( aDBInfValus, NTrim( aDBFInfo[ 4 ] ) )    // reclen
      AADD( aDBInfValus, NTrim( aDBFInfo[ 5 ] ) )    // fcou

      nRecLnBoxNo :=  4
      nFldCoBoxNo :=  5
   ELSE
      AADD( aDBInfValus, NTrim( aDBFInfo[ 1 ] ) )
      AADD( aDBInfValus, NTrim( aDBFInfo[ 2 ] ) )
   ENDIF

   AADD( aDBInfLabls, "Record Length :" )
   AADD( aDBInfLabls, "Field Count :" )

   AEVAL( aStruct, { | a1, i1 | AADD( aWrkStruct, {      i1    ,;  // Field Numb
                                                      a1[ 1 ]  ,;  // Field Name  
                             ASCAN( aColumns[ 3, 2] , a1[ 2 ]) ,;  // Field Type Number
                                                      a1[ 3 ]  ,;  // Field Width
                                                      a1[ 4 ]})})  // Field Width
   
   IF nOperati > 1
      AADD( aWrkStruct, { LEN( aWrkStruct)+1,SPAC(10),0,0,0 } ) // New empty item ( row ) ready for append
   ENDIF

   cRecLenCtrl := 'txb_' + STRZERO( nRecLnBoxNo, 2 ) 
   cFldCouCtrl := 'txb_' + STRZERO( nFldCoBoxNo, 2 ) 

   DEFINE WINDOW frmDBStruct ;
      AT     0,0 ;
      WIDTH  435 ;
      HEIGHT 480 ;
      TITLE  cFrmTitle ; // VIRTUAL HEIGHT 800 ;
      MODAL 

      ON KEY ESCAPE         ACTION frmDBStruct.Release
      ON KEY CONTROL+DELETE ACTION DBStEdDel()
      ON KEY CONTROL+INSERT ACTION DBStEdIns()
      ON KEY CONTROL+UP     ACTION DBStEdMov( -1 )
      ON KEY CONTROL+DOWN   ACTION DBStEdMov( 1 )

      IF nOperati > 1
         DEFINE BUTTON btnDBStApply
            ROW         nNextRow
            COL         nNextCol
            WIDTH       64
            HEIGHT      24
            CAPTION     "Apply"
            TOOLTIP     "Apply changes and exit"
            ACTION      { || IF(EMPTY((aRVal := DBStAply( aStruct, lMustChange ))), ,frmDBStruct.Release ) }
         END BUTTON // btnDBStApply
         nNextCol += 74
      ENDIF nOperati > 1

      DEFINE BUTTON btnDBStExit
         ROW         nNextRow
         COL         nNextCol
         WIDTH       64
         HEIGHT      24
         CAPTION     "Exit"
         TOOLTIP     "Exit" + IF( nOperati > 1, " without saving changes.", "" )
         ACTION      frmDBStruct.Release
      END BUTTON // btnDBStExit
      nNextCol    += 74

      DEFINE BUTTON btnDBStNe
         ROW         nNextRow
         COL         nNextCol
         WIDTH       24
         HEIGHT      24
         CAPTION     "?"
         FONTNAME    "FixedSys"
         FONTSIZE    14
         FONTBOLD    .T.
         TOOLTIP     "Navigation and Operations Keys"
         ACTION      MsgInfo( cStruHelp )
      END BUTTON // btnDBStNe

      nNextRow := 50

      FOR nDBInfoNo := 1 TO LEN( aDBFInfo )
         cLabelName  := 'lbl_' + STRZERO( nDBInfoNo, 2 )
         cTxBoxName  := 'txb_' + STRZERO( nDBInfoNo, 2 )

         DEFINE LABEL &cLabelName
            ROW      nNextRow
            COL      10
            VALUE    aDBInfLabls[ nDBInfoNo ]
            WIDTH    190
            HEIGHT   17   
            RIGHTALIGN .T.
         END LABEL // cLabelName

         DEFINE LABEL &cTxBoxName
            ROW      nNextRow
            COL      205
            VALUE    aDBInfValus[ nDBInfoNo ]
            WIDTH    190
            HEIGHT   17   
         END LABEL // cLabelName

         nNextRow += 17

      NEXT nDBInfoNo

      DEFINE FRAME fraFInfo
         ROW         35
         COL         10
         WIDTH       405
         HEIGHT      LEN( aDBInfValus ) * 17 + 22
         CAPTION     IF( nOperati > 2, '', 'File ' ) + 'Info'
      END FRAME // fraFInfo

      DEFINE GRID grdStruct
         ROW         LEN( aDBInfValus ) * 17 + 60
         COL         10
         WIDTH      405
         HEIGHT     IF( nOperati > 2, 330, 290 )
         HEADERS    {'No:','Name','Type','Width','Dec' }
         WIDTHS     { 40,   140,    90,   74,     40 }
         ITEMS      aWrkStruct
         FONTNAME  "FixedSys"
         FONTSIZE   10
         ALLOWEDIT  ( nOperati > 1 )
         
         COLUMNCONTROLS { { 'TEXTBOX',  'NUMERIC', '999' }  ,;
                          { 'TEXTBOX',  'CHARACTER', '!!!!!!!!!!' }  ,;
                          { 'COMBOBOX', {'Character','Numeric','Logical','Date','Memo' }},;
                          { 'TEXTBOX',  'NUMERIC', '99999' },;
                          { 'TEXTBOX',  'NUMERIC', '99' }  }

         COLUMNWHEN     {{||.F.},{||.T.}, {||.T.},;
                                 {||(frmDBStruct.grdStruct.Cell(This.CellRowIndex,3) <  3)},;
                                 {||(frmDBStruct.grdStruct.Cell(This.CellRowIndex,3) == 2)}}

         COLUMNVALID    { { || DBStCellVald( This.CellRowIndex , 1, This.CellValue ) },;
                          { || DBStCellVald( This.CellRowIndex , 2, This.CellValue ) },;
                          { || DBStCellVald( This.CellRowIndex , 3, This.CellValue ) },;
                          { || DBStCellVald( This.CellRowIndex , 4, This.CellValue ) },;
                          { || DBStCellVald( This.CellRowIndex , 5, This.CellValue ) } }

       END GRID // grdStruct
       
       DEFINE TIMER DBStrTimer ;
          INTERVAL 100 ;
          ACTION   DBStrAdjust() 

   END WINDOW // frmDBStruct

   CENTER   WINDOW frmDBStruct
   ACTIVATE WINDOW frmDBStruct

RETU aRVal // DBStructOps()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStrAdjust()                        // DataBase Structure Adjust widths & Decs 

   LOCA nRow, nCol, xVal, nAdjt
   
   IF !EMPTY( aDBStrAdjst ) 
      FOR nAdjt := 1 TO LEN( aDBStrAdjst )
         nRow   := aDBStrAdjst[ nAdjt, 1 ]
         nCol   := aDBStrAdjst[ nAdjt, 2 ]
         xVal   := aDBStrAdjst[ nAdjt, 3 ]
         aWrkStruct[ nRow, nCol ] := xVal
         frmDBStruct.grdStruct.Cell( nRow, nCol ) := xVal
      NEXT nAdjt
      DBStNewField( nCol )
      DBStRefrInfo()
   ENDIF !EMPTY( aDBStrAdjst ) 

   frmDBStruct.DBStrTimer.Enabled := .F.
   
RETU // DBStrAdjust() 

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStRefrInfo()                       // DataBase Structure Refresh DBF Infos
                   
   LOCA nRecLen  := 1,;
        aLastRow := aWrkStruct[ LEN( aWrkStruct ) ],;
        nFldCou  := 0
   
   AEVAL( aWrkStruct, { | a1 | nRecLen += a1[ 4 ] } )
   
   
   nFldCou := LEN( aWrkStruct ) - IF( EMPTY( aLastRow[ 2 ] ) .OR. ;
                                      EMPTY( aLastRow[ 3 ] ) .OR. ;
                                      EMPTY( aLastRow[ 4 ] ), 1, 0 ) 
      
   SetProperty( "frmDBStruct", cRecLenCtrl, "VALUE", NTrim( nRecLen ) )
   SetProperty( "frmDBStruct", cFldCouCtrl, "VALUE", NTrim( nFldCou ) )
                   
RETU // DBStRefrInfo()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStNewField(;                       // DataBase Structure New Field
                  nCurColNo ) // Current Column Number

   LOCA nItemCount := frmDBStruct.grdStruct.ItemCount,;
        nColumNumb := 0,;
        lLastRowOk := .T.,;
        aNewItem   := {}

   LOCA aLastItem := frmDBStruct.grdStruct.Item( nItemCount )

   FOR nColumNumb := 2 TO 4
      IF EMPTY( aLastItem[ nColumNumb ] ) .AND. nColumNumb # nCurColNo
         lLastRowOk := .F.
         EXIT
      ENDIF
   NEXT nColumNumb

   IF lLastRowOk
      aNewItem   := { nItemCount+1,SPAC(10),0,0,0  }
      frmDBStruct.grdStruct.AddItem( aNewItem )
      AADD( aWrkStruct, aNewItem )
   ENDIF

RETU // DBStNewField()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC DBStCellVald(;                       // DataBase Structure Cell Validity
                  nGRow,;
                  nGCol ,;
                  xGVal )

   LOCA nItemCo := frmDBStruct.grdStruct.ItemCount,;
        nFldNam := frmDBStruct.grdStruct.Cell( nGRow, 2 ),;
        nFldTyp := frmDBStruct.grdStruct.Cell( nGRow, 3 ),;
        nFldLen := frmDBStruct.grdStruct.Cell( nGRow, 4 ),;
        lRVal   := .F.,;
        nSamNam := 0

   DO CASE

      CASE nGCol == 1 // FldNum

         * .F. : ReadOnly

      CASE nGCol == 2 // FldNam

         lRVal := DBStVFNam( xGVal, nGRow )

      CASE nGCol == 3 // FldType

         lRVal := ( xGVal > 0 )    // *  Always .t., Because ComboBox !edit-able (dispedit : .f. ) ( 8b30 )
         
         IF lRVal
            aDBStrAdjst := {}
            IF xGVal # 2
               IF xGVal == 3 // L 
                  AADD( aDBStrAdjst, { nGRow, 4, 1 } )
               ELSEIF xGVal == 4 // D 
                  AADD( aDBStrAdjst, { nGRow, 4, 8 } )
               ELSEIF xGVal == 5 // M 
                  AADD( aDBStrAdjst, { nGRow, 4, 10 } )
               ENDIF
               AADD( aDBStrAdjst, { nGRow, 5, 0 } )
               frmDBStruct.DBStrTimer.Enabled := .T.
            ENDIF   
         ENDIF lRVal

      CASE nGCol == 4 // FldWidth

         IF xGVal > 0
            IF     nFldTyp == 1 // C
               lRVal := ( xGVal < 10000 )
            ELSEIF nFldTyp == 2 // N
               lRVal := ( xGVal < 20 )
            ELSEIF nFldTyp == 3 // L
               lRVal := ( xGVal == 1 )
            ELSEIF nFldTyp == 4 // D
               lRVal := ( xGVal == 8 )
            ELSEIF nFldTyp == 5 // M
               lRVal := ( xGVal == 10 .OR. xGVal == 4 )
            ENDIF nFldTyp ...
            IF lRVal
               aWrkStruct[ nGRow, nGCol ] := xGVal
               DBStRefrInfo()
            ENDIF   
         ENDIF xGVal > 0
      CASE nGCol == 5 // FldDec
         IF nFldTyp == 2 .AND. xGVal > 0
            lRVal  := ( xGVal + 1 ) < nFldLen
         ELSE
            lRVal  := ( xGVal == 0 )
         ENDIF
   ENDCASE nGCol

   IF lRVal
      aWrkStruct[ nGRow, nGCol ] := xGVal
      DBStNewField( nGCol )
   ENDIF

RETU lRVal // DBStCellVald()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC DBStVFNam( ;                         // DataBase Structure Valid Field Name
               cFldNam, ;     // Candidate Field Name
               nFldNum )      // Number of this Field

   LOCA lRVal  := .T.,;
        nCInd  :=  0,;
        c1Char := ''

   cFldNam := TRIM( cFldNam )

   IF ( lRVal :=  !EMPTY( cFldNam ) .AND. ISALPHA( LEFT( cFldNam, 1 ) ) )
      FOR nCInd := 2 TO LEN( cFldNam )
         c1Char := SUBS( cFldNam, nCInd, 1 )
         lRVal  := ISALPHA( c1Char ) .OR. ISDIGIT( c1Char ) .OR. c1Char == '_'
         IF !lRVal
            EXIT // FOR
         ENDIF
      NEXT nCInd
      *
      * is it unique ?
      *
      IF lRVal
         lRVal := ASCAN( aWrkStruct, { | a1, i1 | cFldNam == TRIM( a1[ 2 ] ) .AND. ;
                                          i1 # nFldNum } ) == 0
      ENDIF
   ENDIF ( lRVal ...

RETU lRVal // DBStVFNam()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStEdDel()                          // DataBase Structure Delete Field

   LOCA nRowNum := frmDBStruct.grdStruct.Value
   
   IF nRowNum < LEN( aWrkStruct )
     ADEL( aWrkStruct, nRowNum )
     ASIZE( aWrkStruct, LEN( aWrkStruct ) - 1)
     frmDBStruct.grdStruct.DeleteItem( nRowNum )
     DBStReNum()
     DBStRefrInfo()
   ELSE
     PlayExclamation()
   ENDIF nRowNum < LEN( aWrkStruct )

RETU // DBStEdDel()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStEdIns()                          // DataBase Structure Insert Field

   LOCA nRowNum := frmDBStruct.grdStruct.Value

   IF nRowNum < LEN( aWrkStruct )
      ASIZE( aWrkStruct, LEN( aWrkStruct ) + 1 )
      AINS(  aWrkStruct, nRowNum )
      aWrkStruct[ nRowNum ] := { 0,SPAC(10),0,0,0 }
      DBStInsItem( nRowNum )
      DBStReNum()
   ELSE
      PlayExclamation()
   ENDIF nRowNum > 1

RETU // DBStEdIns()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStReNum()                          // DataBase Structure Renumber Fields

   LOCA nRowNum := 0,;
        a1Item  := {}

   FOR nRowNum := 1 TO LEN( aWrkStruct )
      aWrkStruct[ nRowNum, 1 ] := nRowNum
      a1Item  := frmDBStruct.grdStruct.ITEM( nRowNum )
      a1Item[ 1 ] := nRowNum
      frmDBStruct.grdStruct.ITEM( nRowNum ) := a1Item
   NEXT nRowNum

RETU // DBStReNum()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStInsItem( ;                       // DataBase Structure Insert Field 
                  nRowNum )

   LOCA nRInd   := 0,;
        nItemCo := frmDBStruct.grdStruct.ItemCount

   frmDBStruct.grdStruct.AddItem( { 0,SPAC(10),0,0,0 } )

   FOR nRInd := nItemCo - 1 TO nRowNum STEP - 1
      frmDBStruct.grdStruct.ITEM( nRInd + 1 ) := frmDBStruct.grdStruct.ITEM( nRInd )
   NEXT nRInd

   frmDBStruct.grdStruct.ITEM( nRowNum ) := { 0,SPAC(10),0,0,0 }

RETU // DBStInsItem()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROC DBStEdMov( ;                         // DataBase Structure Move Field up or down
                nMove   )  // -1 : Up, 1 : Down

   LOCA nRowNum := frmDBStruct.grdStruct.Value,;
        aSwap   := {}

   IF ( nMove < 0 .AND. nRowNum > 1 .AND. nRowNum < LEN( aWrkStruct ) ) .OR. ;
      ( nMove > 0 .AND. nRowNum < LEN( aWrkStruct ) - 1 ) 
   
      aSwap := aWrkStruct[ nRowNum ] 
      aWrkStruct[ nRowNum ] := aWrkStruct[ nRowNum + nMove  ] 
      aWrkStruct[ nRowNum + nMove  ] := aSwap 
      
      aSwap := frmDBStruct.grdStruct.Item( nRowNum )
      frmDBStruct.grdStruct.Item( nRowNum ) := frmDBStruct.grdStruct.Item( nRowNum + nMove )
      frmDBStruct.grdStruct.Item( nRowNum + nMove ) := aSwap 
      
      frmDBStruct.grdStruct.Value := nRowNum + nMove 
      
      DBStReNum()
      
   ELSE
      PlayExclamation()
   ENDIF 

RETU // DBStEdMov()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

FUNC DBStAply( ;                          // DataBase Structure Apply Changes 
               aOldStruct,;
               lMustChange ) 
               
   LOCA cFldTypes := 'CNLDM',;
        a1Field   := {},;
        nFldNum   :=  0,;
        nInComplt :=  0,;
        aNewStruc := {},;
        cMisMatch := '',;
        aRVal     := {}  
        
   DEFAULT lMustChange TO .T.
        
   nInComplt :=  ASCAN( aWrkStruct, ;
             { | a1, i1 | i1 < LEN(aWrkStruct) .AND. ;
             ( EMPTY( a1[ 2 ] ) .OR. EMPTY( a1[ 2 ] ) .OR. EMPTY( a1[ 3 ] ) ) } ) 
             
   IF nInComplt > 0          
      MsgStop( "Can't Apply !"   + CRLF2 + ;
               "Incomplete Entry" + CRLF2 + ;
               "No : " + NTrim( nInComplt ) )
   ELSE
      AEVAL( aWrkStruct, { | a1 | IF( ; 
          !( EMPTY( a1[ 2 ] ) .OR. EMPTY( a1[ 2 ] ) .OR. EMPTY( a1[ 3 ] ) ),; 
          AADD( aNewStruc, {   ALLTRIM( a1[ 2 ] ) ,;                         
                    SUBS( cFldTypes,   a1[ 3 ], 1 ),; 
                                       a1[ 4 ]     ,; 
                                       a1[ 5 ] } ), ) } )
      IF EMPTY( aNewStruc )
         MsgStop( "Noting to Apply !"   + CRLF2 + ;
                  "Empty Structure"  )
      ELSE                                  
         IF SameStru( aOldStruct, aNewStruc ) .AND. lMustChange
            MsgStop( "No need to Apply !"   + CRLF2 + ;
                     "No change made."  )
         ELSE            
            IF !EMPTY( cMisMatch := DBStMMFld( aNewStruc, aOldStruct ) ) .AND. ;
               LASTREC() > 0
                MsgStop( "Cant't Apply !"   + CRLF2 + ;
                         "There is type mismatch." + CRLF2 + ;
                         "Field : " + cMisMatch  )
            ELSE  
               aRVal := aNewStruc
            ENDIF   
         ENDIF SameStru( aOldStruct, aNewStruc )
      ENDIF EMPTY( aNewStruc )
   ENDIF nInComplt > 0                   
      
RETU aRVal // DBStAply()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

