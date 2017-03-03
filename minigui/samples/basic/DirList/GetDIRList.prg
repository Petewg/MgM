/*

  f.GetDIRList() 
  
  Syntax : GetDIRList( <acFilter>, <cTitle>, <cBegFolder>, <nIncludes>, <lMultiSelect>, <lChangeDir> ) ==> <aDIRList>
                       
  Arguments : <acFilter>     : File skeleton ( with wildcard characters )
              <cTitle>       : GetDIRList() form title
              <cBegFolder>   : Beginning path
              <nIncludes>    : 1: Files, 2: DIRs, 3: DIRs and Files
              <lMultiSelect> : Allow Multiple selection
              <lChangeDir>   : Allow Change DIR
                   
   Return   : <aDIRList> : DIR list with selected DIR entries.
   
   History  : 9.2008 : First Release
  
   Description :
   
     Reinvention of wheel ?   
     
     Not quite ...   
     
     Main difference is allowing file(s) and folder(s) selection together.
     
     Another difference is implementing of <lNoChangeDir> parameter. Unlike GetFile(), GetDIRList() uses this value 
     for allowing change directory ability to user.
     
     Furthermore sorting grid columns by three (not two) ways, GetVolumLabel(), List2Arry() and Arry2List() 
     functions may be useful.
     
     Also, test program ( TestGDL.prg ) may be a sample for .fmg based application.
     
     I need your help; please feel free to share your impressions. 
     
     Regards
     
     esgici

     Copyright 2006 Bicahi Esgici <esgici@gmail.com>


*/


#include <minigui.ch>

#define c1Tab CHR(9)
#define c2Tab CHR(9)+CHR(9)
#ifndef NTrim
#define NTrim( n )   LTrim( TRAN( n,"999,999,999,999,999,999,999" ) )
#endif

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                        ;
          =>                                                            ;
          IF <v1> == NIL ; <v1> := <x1> ; END                           ;
          [; IF <vn> == NIL ; <vn> := <xn> ; END ]

   MEMV aGDLRVal,;
        aList1,;
        aList2,;
        aColOrder,;
        aLocaRoots,;
        aLocaCurnt

   MEMV aLocaNames,;
        aLocaPaths

   MEMV npIncludes,;         // 1: Files, 2: DIRs, 3: DIRs and Files
        lpChangeDir          // Allow Change DIR

          
FUNC GetDIRList( ;
                  acFilter,;          // File skeleton ( with wildcard characters )
                  cTitle,;            // GetDIRList() form title
                  cBegFolder,;        // Beginning path
                  nIncludes,;         // 1: Files, 2: DIRs, 3: DIRs and Files
                  lMultiSelect,;      // Allow Multiple selection
                  lChangeDir )        // Allow Change DIR

   LOCA aTypes := { "Only File(s)", "Only Folder(s)", "File(s) and Folder(s)" },;
        aGDLGFC    := ARRAY( 4 ),;    // GDL GRID Dynamic Fore Colors
        aImages    := { '01.bmp', '02.bmp' }

   SET PROGRAMMATICCHANGE OFF

   DEFAULT nIncludes       TO  3

   nIncludes := MAX( MIN( nIncludes, 3 ), 1 )

   DEFAULT acFilter        TO { '*.*' },;
           cBegFolder      TO GetCurrentFolder(),;
           lMultiSelect    TO .T.,;
           lChangeDir      TO .T.
           
   PRIV aGDLRVal   := {},;
        aList1     := {},;
        aList2     := {{,,,,.F.},{,,,,.F.}},;
        aColOrder  := ARRAY( 4 ),;
        aLocaRoots := GDL_LocaRoots(),;
        aLocaCurnt := {}

   cBegFolder += IF( RIGHT( cBegFolder, 1 ) # '\', '\','' )

   IF EMPTY( cTitle ) 
      cTitle := aTypes[ nIncludes ]
   ENDIF

   PRIV aLocaNames := {},;
        aLocaPaths := {}

   *
   * PRIVATization !
   *
   *
   PRIV npIncludes    := nIncludes,;         // 1: Files, 2: DIRs, 3: DIRs and Files
        lpChangeDir   := lChangeDir          // Allow Change DIR

   AFILL( aGDLGFC, { || IF( aList2[ This.CellRowIndex, 5 ], RGB(0, 0, 255), RGB(0, 0, 0) ) } )  // This is a DIR

   AFILL( aColOrder, 0 )

   DEFINE WINDOW frmGDL ;
       AT 138 , 235 ;
       WIDTH  553 ;
       HEIGHT 554 ;
       TITLE cTitle ;
       MODAL ;
       ON INIT GDL_Init() 
   
       ON KEY ESCAPE    ACTION frmGDL.Release
       ON KEY CONTROL+A ACTION GDL_SelectAll()
       ON KEY CONTROL+D ACTION { || frmGDL.grdDIRList.Value := iif(lMultiSelect, {}, 0) }
       
       @  40,  30 LABEL    lblLocas   WIDTH  60 HEIGHT  20 VALUE "Locations :" RIGHTALIGN  
                                      
       @  35, 100 COMBOBOX cmbLocas   WIDTH 350 HEIGHT 100 ITEMS {""} VALUE 1  ;
                                      ON CHANGE GDL_ChangeLoca() ;
                                      ON ENTER  GDL_ChangeLoca() 
                                      
       @  35, 470 BUTTON   btnGo1Up   PICTURE "Go1Up.bmp" ACTION GDL_GoUPDIR() WIDTH 25 HEIGHT 23 TOOLTIP "Up DIR"
                                      
       @  70,  30 LABEL    lblPath    WIDTH  60 HEIGHT  20 VALUE "Path :"      RIGHTALIGN
                                                        
       @  70, 100 TEXTBOX  txbPath    WIDTH 350 HEIGHT  20 ON ENTER GDL_ChangePath() VALUE cBegFolder
                                      
       @  70, 470 BUTTON   btnGoPath  PICTURE "right.bmp" ACTION GDL_ChangePath() WIDTH 25 HEIGHT 23

       @ 100,  30 LABEL    lblFilter  WIDTH  60 HEIGHT  20 VALUE "Filter :"    RIGHTALIGN
                                      
       @ 100, 100 TEXTBOX  txbFilter  WIDTH 350 HEIGHT  20 ON ENTER GDL_ChangePath() VALUE HL_Arry2List( acFilter )
       
       @ 100, 470 BUTTON   btnAppFilt PICTURE "enter.bmp" ACTION { || GDL_MakeLocas(), GDL_FillGrid() } WIDTH 25 HEIGHT 23 TOOLTIP "Apply this filter ( Enter )"
           
       @ 470,  50 BUTTON   btnDone    CAPTION "Done"  ACTION GDL_Done()  WIDTH 70 HEIGHT  20 
                                      
       @ 470, 420 BUTTON   btnExit    CAPTION "Exit"  ACTION frmGDL.Release WIDTH 80 HEIGHT 20 
       
       @ 470, 260 BUTTON   btnHelp    CAPTION " ? " ;
                                      ACTION MsgInfo( "Change Current" + c1Tab + ": Up / Down / PgUp / PgDown ..." + CRLF + ;
                                                      "Select / Deselect" + c1Tab + ": Click, Shift/Ctrl + Click / Up / Down ..." + CRLF + ;
                                                      "Select All"   + c2Tab + ": Ctrl + A" + CRLF + ;
                                                      "DeSelect All" + c1Tab + ": Ctrl + D" + CRLF + ;
                                                      "Done / Apply" + c1Tab + ": Enter / DoubleClick", "Navigation On Grid" );
                                      WIDTH 20 HEIGHT 20 ;
                                      FONT "FixedSys" SIZE 9 TOOLTIP "Navigation keys"
       
       DEFINE GRID grdDIRList
           ROW    140
           COL     30
           WIDTH  490
           HEIGHT 310
           ITEMS  { { '','','','' } }
           WIDTHS { 170, 75, 90, 135 - IF(IsXPThemeActive(), 2, 0) }
           HEADERS { 'File Name', 'Ext', 'Size', 'Date + Time' }
           ONDBLCLICK GDL_DoneOrSel(lMultiSelect)
           ONHEADCLICK { {||GDL_SortColm( 1 )}, {||GDL_SortColm( 2 )}, {||GDL_SortColm( 3 )}, {||GDL_SortColm( 4 )} }
           MULTISELECT lMultiSelect
           DYNAMICFORECOLOR aGDLGFC
           JUSTIFY { 0,0,1,0 }
           ITEMCOUNT 2
           HEADERIMAGES aImages
       END GRID
   
       DEFINE STATUSBAR
           STATUSITEM "" WIDTH 200
       END STATUSBAR
   
   END WINDOW // frmGDL
   
   frmGDL.Activate

RETU aGDLRVal // GetDIRList()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_FillGrid()

    LOCA cCurrPath := frmGDL.txbPath.Value

    LOCA cFileNam,;
         cFileExt,;
         nFileSiz,;
         cFileDat,;
         cFileTim,;
         cFAttrib,;
         lIsDIR,;
         nFile,;
         nLastDotPos

    LOCA cFilter := frmGDL.txbFilter.Value
    
    LOCA nFileCo := 0,;
         nFoldCo := 0,;
         nSeqNum := 0
         
    IF EMPTY( cFilter )
       cFilter := "*.*"
       frmGDL.txbFilter.Value := cFilter
    ENDIF

    cCurrPath += IF( RIGHT( cCurrPath, 1 ) # '\', '\','' )

    aList1 := GDL_FFList( cCurrPath, cFilter, npIncludes, lpChangeDir ) 

    aList2 := {}

    frmGDL.grdDIRList.DeleteAllItems()

    FOR nFile := 1 TO LEN( aList1 )

       cFileNam := aList1[ nFile, 1 ]

       IF "."  # cFileNam  .AND. ".." # cFileNam // THIS DIR, UP DIR

         IF ( nLastDotPos := RAT( ".", aList1[ nFile, 1 ] ) ) > 0
            cFileNam    := LEFT( aList1[ nFile, 1 ], nLastDotPos - 1 )
            cFileExt    := SUBS( aList1[ nFile, 1 ], nLastDotPos + 1 )
         ELSE
            cFileNam    := aList1[ nFile, 1 ]
            cFileExt    := ' '
         ENDIF

         nFileSiz := aList1[ nFile, 2 ]

         cFileDat := DTOS( aList1[ nFile, 3 ] )
         cFileTim := aList1[ nFile, 4 ]
         cFAttrib := aList1[ nFile, 5 ]
         lIsDIR   := "D" $ cFAttrib
         
         AADD( aList2, { cFileNam,;                     // 1° File ( Only) Name
                         cFileExt,;                     // 2° File Extention
                         nFileSiz,;                     // 3° Size / <DIR>
                         cFileDat + " " + cFileTim,;    // 4° Date + Time
                         lIsDIR ,;                      // 5° Is this entry a DIR ?
                         ++nSeqNum } )                  // 6° Sequence No ( for 'natural' order )
                    
         IF lIsDIR
            ++nFoldCo
         ELSE   
            ++nFileCo
         ENDIF   

       ENDIF "."  # cFileNam  .AND. ".." # cFileNam // THIS DIR, UP DIR

    NEXT nFile

    frmGDL.grdDIRList.DisableUpdate()
    AEVAL( aList2, { | a1 |  frmGDL.grdDIRList.AddItem( { a1[ 1 ],;       // 1° File ( Only) Name
                                                       a1[ 2 ],;          // 2° File Extention
                    IF( a1[ 5 ], '<DIR>', PADL( NTrim( a1[ 3 ]), 14 )),;  // 3° Size / <DIR>
                                            IF( EMPTY( a1[ 4 ] ),;
                                 ' ',DTOC( STOD( LEFT( a1[ 4 ], ;
                                       8 ) ) ) + SUBS( a1[ 4 ], 9 ) ) } ) } )   // 4° Date + Time
    frmGDL.grdDIRList.EnableUpdate()
                                       
   frmGDL.STATUSBAR.Item( 1 ) := IF( nFoldCo > 0, NTrim( nFoldCo )  + " Folder" + IF( nFoldCo > 1, 's', '' ), '' ) + ;
                                 IF( nFoldCo > 0 .AND. nFileCo > 0, " and ", '' ) + ; 
                                 IF( nFileCo > 0, NTrim( nFileCo )  + " File"   + IF( nFileCo > 1, 's', '' ), '' ) 
                                 
    
RETU // GDL_FillGrid()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_Done()

   LOCA aSelected := frmGDL.grdDIRList.Value
   
   IF ISNUMBER( aSelected )
      aSelected := { aSelected }
   ENDIF   

   IF !EMPTY( aSelected )

      AEVAL( aSelected, { | n1 | AADD( aGDLRVal, frmGDL.txbPath.Value + frmGDL.grdDIRList.Cell( n1, 1 ) + ;
                                                          IF( EMPTY( frmGDL.grdDIRList.Cell( n1, 2 ) ), '',;
                                                          "." +      frmGDL.grdDIRList.Cell( n1, 2 ) ) ) } )
   ENDIF

   frmGDL.Release

RETU // GDL_Done()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_SortColm(;
                nColumnNo )

  LOCA nOrder  := aColOrder[ nColumnNo ],; // 0: Natural, 1: Ascend, 2: Descend 
       aImages := ARRAY(4),;
       lAscend

  nOrder := IF( nOrder < 2, nOrder + 1, 0 ) 
  
  aColOrder[ nColumnNo ] := nOrder
  
  AEVAL( aImages, { | x, i1 | aImages[ i1 ] := 0 } )

  IF nOrder < 1 
     ASORT( aList2, , , { | x, y | x[ 6 ] < y[ 6 ] } )
  ELSE
     lAscend := nOrder < 2 
     IF nColumnNo # 3
        IF lAscend
           ASORT( aList2, , , { | x, y | UPPER( x[ nColumnNo ] ) < UPPER( y[ nColumnNo ] ) } )
        ELSE
           ASORT( aList2, , , { | x, y | UPPER( x[ nColumnNo ] ) > UPPER( y[ nColumnNo ] ) } )
        ENDIF
     ELSE // File Size
        IF lAscend
           ASORT( aList2, , , { | x, y | x[ nColumnNo ] < y[ nColumnNo ] } )
        ELSE
           ASORT( aList2, , , { | x, y | x[ nColumnNo ] > y[ nColumnNo ] } )
        ENDIF
     ENDIF nColumnNo # 3
     
     aImages[ nColumnNo ] := IF( lAscend, 1, 2 )
     
  ENDIF nOrder < 1 
  
  frmGDL.grdDIRList.DeleteAllItems

  frmGDL.grdDIRList.DisableUpdate()
  AEVAL( aList2, { | a1 |  frmGDL.grdDIRList.AddItem( { a1[ 1 ],;         // 1° File ( Only) Name
                                                     a1[ 2 ],;         // 2° File Extention
                  IF( a1[ 5 ], '<DIR>', PADL( NTrim( a1[ 3 ]), 14 )),;  // 3° Size / <DIR>
                                          IF( EMPTY( a1[ 4 ] ),;
                               ' ',DTOC( STOD( LEFT( a1[ 4 ], ;
                                     8 ) ) ) + SUBS( a1[ 4 ], 9 ) ) } ) } )   // 4° Date + Time
  frmGDL.grdDIRList.EnableUpdate()

  AEVAL( aImages, { | c1, i1 | frmGDL.grdDIRList.HeaderImage( i1 ) := {c1, (i1==3)} } )

RETU // GDL_SortColm()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC GDL_LocaRoots()

   LOCA aDrives := HL_GetDriveList()
        aGDLRVal   := { { '00000', "My DeskTop",  GetDeskTopFolder() },;
                     { '00001', "  My Documents", GetMyDocumentsFolder() } }

   AEVAL( aDrives, { | c1, i1 | aDrives[ i1 ] += ' [ ' + HL_GetVolumLabel( c1 ) + ' ]'} )

   AEVAL( aDrives, { | c1, i1 | AADD( aGDLRVal, { STRZERO( i1 * 100, 4 ), "  " + c1, LEFT( c1, 2 ) + "\" } ) } )

RETU aGDLRVal // GDL_LocaRoots()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_SelectAll()

   LOCA aTemp := ARRAY( frmGDL.grdDIRList.ItemCount + 1 ) // WHY requires this + 1 ???

   AEVAL( aTemp, { | x1, i1 | aTemp[ i1 ] := i1 } )

   frmGDL.grdDIRList.Value := aTemp

RETU // GDL_SelectAll()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_GoUpDIR()

  LOCA nCurItem := frmGDL.cmbLocas.Value    // In frmGDL.cmbLocas

  IF --nCurItem > 0
     frmGDL.cmbLocas.Value := nCurItem
     GDL_ChangeLoca()
  ENDIF

RETU // GDL_GoUpDIR()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_ChangeLoca()

   LOCA nCurrLoca := frmGDL.cmbLocas.Value

   LOCA cCurrLoca := LTRIM( frmGDL.cmbLocas.Item( nCurrLoca ) )

   frmGDL.txbPath.Value := aLocaCurnt[ nCurrLoca, 3 ] + IF( RIGHT( aLocaCurnt[ nCurrLoca, 3 ], 1 ) # '\', '\', '' )

   GDL_MakeLocas()
   GDL_FillGrid()
   frmGDL.cmbLocas.Value := ASCAN( aLocaCurnt, { | a1 | cCurrLoca $ a1[ 2 ] } )

   frmGDL.grdDIRList.SetFocus

RETU // GDL_ChangeLoca()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_MakeLocas()

   LOCA cCurrPath := frmGDL.txbPath.Value
   
   LOCA cCurrLoca := TOKEN( cCurrPath ),;
        aBFTree,;
        nDriveNo,;
        nDrivCode,;
        cNextSubD

   IF lpChangeDir     
      IF HL_IsFolderExist( cCurrPath )
      
         aBFTree    := HL_List2Arry( SUBS( cCurrPath, 4 ), '\' )
      
         nDriveNo   := ASCAN( aLocaRoots, { | a1 | UPPER( LEFT( cCurrPath, 2 ) ) == ;
                                                   UPPER( LEFT( LTRIM( a1[ 2 ] ), 2 ) ) } )

         nDriveNo   := IFEMPTY( nDriveNo, 1, nDriveNo )
         nDrivCode  := VAL( aLocaRoots[ nDriveNo, 1 ] )
      
         cNextSubD  := LEFT( cCurrPath, 2 )
      
         aLocaCurnt := ACLONE( aLocaRoots )
      
         AEVAL( aBFTree, { | c1, i1 |  ;
                           cNextSubD += "\" + c1, ;
                           AADD( aLocaCurnt, { STRZERO( nDrivCode + i1, 4 ),;
                                               SPACE( ( i1 + 1 ) * 2 ) + c1, cNextSubD } ) } )
      
         ASORT( aLocaCurnt,,,{ | x, y | x[ 1 ] < y[ 1 ] } )
      
         frmGDL.cmbLocas.DeleteAllItems
      
         AEVAL( aLocaCurnt, { | a1 | frmGDL.cmbLocas.AddItem( a1[ 2 ] ) } )
      
         frmGDL.cmbLocas.Height := LEN( aLocaCurnt ) * 20
         
         frmGDL.cmbLocas.Value := ASCAN( aLocaCurnt, { | a1 | cCurrLoca $ a1[ 2 ] } )

      ENDIF HL_IsFolderExist( cCurrPath )
   ELSE
      frmGDL.cmbLocas.DeleteAllItems
      frmGDL.cmbLocas.AddItem( cCurrLoca )  
      frmGDL.cmbLocas.Value := 1 
   ENDIF lpChangeDir     
      
   frmGDL.grdDIRList.SetFocus
   
RETU // GDL_MakeLocas()


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_ChangePath()

   LOCA cCurrPath := frmGDL.txbPath.Value

   LOCA cCurrLoca := TOKEN( cCurrPath )   // LAST token !

   IF HL_IsFolderExist( cCurrPath )
      GDL_MakeLocas()
      GDL_FillGrid()
      frmGDL.cmbLocas.Value := ASCAN( aLocaCurnt, { | a1 | cCurrLoca $ a1[ 2 ] } )
      frmGDL.grdDIRList.SetFocus
   ENDIF HL_IsFolderExist( cCurrPath )

RETU // GDL_ChangePath()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_DoneOrSel( lMultiSelect )

   LOCA nGridRow  := This.CellRowIndex,;
        cCurrPath := frmGDL.txbPath.Value,;
        cSelected := frmGDL.grdDIRList.Cell( nGridRow , 1 ) + ;
                     IF( EMPTY( frmGDL.grdDIRList.Cell( nGridRow , 2 ) ), '',;
                         "." +  frmGDL.grdDIRList.Cell( nGridRow , 2 ) )

   cCurrPath += IF( RIGHT( cCurrPath, 1 ) # '\', '\','' )

   IF !EMPTY(nGridRow) .AND. aList2[ nGridRow, 5 ] .AND. lpChangeDir // DIR
      cCurrPath  += cSelected + "\"
      frmGDL.txbPath.Value := cCurrPath
      GDL_ChangePath()
   ELSE
      nGridRow := frmGDL.grdDIRList.Value
      IF !EMPTY(nGridRow)
         nGridRow := IF( lMultiSelect, nGridRow[ 1 ], nGridRow )
         aGDLRVal := { frmGDL.txbPath.Value + frmGDL.grdDIRList.Cell( nGridRow , 1 ) + ;
                               IF( EMPTY( frmGDL.grdDIRList.Cell( nGridRow , 2 ) ), '',;
                                   "." +  frmGDL.grdDIRList.Cell( nGridRow , 2 ) ) }
      ENDIF
      frmGDL.Release
   ENDIF

RETU // GDL_DoneOrSel()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC GDL_Init()

  frmGDL.btnGo1Up.Enabled  := lpChangeDir
  frmGDL.btnGoPath.Enabled := lpChangeDir
  frmGDL.txbPath.ReadOnly  := !lpChangeDir
  
  GDL_MakeLocas()  
  GDL_FillGrid() 

RETU // GDL_Init()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
                                       
FUNC GDL_FFList( ;                        // Filtered File List  
                 cPath ,;       // Path
                 cFilter ,;     // Filter(s)
                 nIncludes ,;   // 1: Only Files, 2: Only DIRs, 3: DIRs and Files
                 lChangeDir )   // Does user will have ability for changing folder ?

    LOCA aRVal   := {},;
         aFilter := {},;
         cAttrib := '',;
         aEntry,;
         c1Entry := ''

    DEFAULT cPath     TO GetCurrentFolder() ,;
            cFilter   TO "*.*" ,;
            nIncludes TO 3

    cPath   := hb_DirSepAdd( cPath )

    aFilter := HL_List2Arry( cFilter )
    
    AEVAL( aFilter, { | c1, i1 | aFilter[ i1 ] := ALLTRIM( c1 ) } )
    
    cAttrib += IF( nIncludes > 1, 'D', '' )
    
    *
    * DIRs inclusion is depend to <nIncludes> OR lChangeDir; no <aFilter>
    *
    IF nIncludes > 1 .OR. lChangeDir
       AEVAL( DIRECTORY( cPath + "*.*", 'D' ), { | a1 | IF( "D" $ a1[ 5 ], AADD( aRVal, a1 ), ) } ) 
    ENDIF lInclDIRs 
    
    IF nIncludes # 2
       FOR EACH cFilter IN aFilter
          FOR EACH aEntry IN DIRECTORY( cPath + cFilter, cAttrib )
             c1Entry := aEntry[ 1 ]
             IF ASCAN( aRVal, { | a1 | c1Entry == a1[ 1 ] } ) < 1
                AADD( aRVal, aEntry )
             ENDIF   
          NEXT
       NEXT
    ENDIF nIncludes # 2
    
RETU aRVal // GDL_FFList()    


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


/*
   
  f.HL_Arry2List()  : Convert a an array to a list ( delimited string )
  
  Syntax     :  HL_Arry2List( <aArray>, <cDelimiter> ) => <cList>
  
  Parameters : <aArray>     : A single dimension array to convert string list.
                              Elements may be any type.
                              
               <cDelimiter> : Delimiter used in the <cList> for seperate tokens
                              Default is comma (',')
               
  Result     : <cList>      : List string produced on <aArray> 
  
  Copyright  : 2008 Bicahi Esgici <esgici@gmail.com>
  

*/

FUNC HL_Arry2List( aArray, cDelimiter )

   LOCA cRVal := ''
   
   DEFAULT aArray     TO {},;
           cDelimiter TO ','
           
   AEVAL( aArray, { | x1, i1 | cRVal += Any2Strg( x1 ) + IF( i1 < LEN( aArray ), cDelimiter, "" ) } ) 
   
RETU cRVal // HL_Arry2List()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
   
  f.HL_List2Arry()  : Convert a list ( delimited string ) to an array
  
  Syntax     :  HL_List2Arry( <cList>, <cDelimiter> ) => <aArray>
  
  Parameters : <cList>      : List string to convert
               <cDelimiter> : Delimiter used in the <cList> for seperate tokens 
                              Default is comma (',')
               
  Result     : <aArray>     : An array consist in <cList>
  
  Copyright  : 2008 Bicahi Esgici <esgici@gmail.com>
  

*/
FUNC HL_List2Arry( cList, cDelimiter )

   LOCA aRVal := {}
   
   DEFAULT cList      TO '',;
           cDelimiter TO ','
           
   TOKENINIT( cList, cDelimiter ) 
   
   WHILE !TOKENEND()
      AADD( aRVal, TOKENNEXT( cList ) ) 
   ENDDO
   
   TOKENEXIT() 
   
RETU aRVal // HL_List2Arry()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   f.HL_IsFolderExist()
    
   Syntax :  HL_IsFolderExist( <cDirName> ) --> lExist
   
   Argument : <cDirName> : Directory ( folder ) name to invoke. Can have
              drive letter. If omitted current drive assumed.
              
              You may also use something like this:

              HL_IsFolderExist( "..\..\test" )
                   
   Return   : <lExist> : If a folder named <cDirName> is exist, .T. else .F.
   
              Existence means also accessibility. If the folder is exist but 
              inaccessible, return value is .F. 
   
   History  : 9.2006 : First Release
  
   Copyright 2006 Bicahi Esgici <esgici@gmail.com>
   
*/
FUNC HL_IsFolderExist( cDirName ) 
                
   LOCA cCurDir := GetCurrentFolder(),;
        lRVal   := ( DIRCHANGE( cDirName ) == 0 )
        
   SetCurrentFolder( cCurDir )     
   
RETU lRVal // HL_IsFolderExist()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   f.HL_GetDriveList() : Produce a list of ready drives in system.
   
   Syntax :  HL_GetDriveList() --> aDrives
   
   Argument : No argument required.
   
   Return   : aDrives : An array have ready drive letter.
              Although exist, not-ready drives not included. 
   
   History  : 9.2006 : First Release
   
   Copyright 2006 Bicahi Esgici <esgici@gmail.com>
   
*/

FUNC HL_GetDriveList()

   LOCA aRVal := {},;
        nDriv,;
        cDriv,;
        cCurDir := GetCurrentFolder()
        
   FOR nDriv := 0 TO 28
      cDriv := CHR( 67 + nDriv ) + ":\"
      IF DIRCHANGE( cDriv ) < 1
         AADD( aRVal, LEFT( cDriv, 2 ) )
      ENDIF
   NEXT nDriv
   
   SetCurrentFolder( cCurDir )     
   
RETU aRVal // HL_GetDriveList()
           
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   f.HL_GetVolumLabel : Produce a list of ready drives in system.
   
   Syntax :  HL_GetVolumLabel( <cDrive> ) --> <cVolumeLabel>
   
   Argument : <cDrive> : Drive code to inspect Volume Label 
   
   Return   : <cVolumeLabel> : If assigned Volume Label of <cDrive>, else an empty string
   
   History  : 9.2008 : First Release
   
   Copyright 2006 Bicahi Esgici <esgici@gmail.com>
   
*/

FUNC HL_GetVolumLabel( cDrive )

   LOCA aList, cRVal

   DEFAULT cDrive TO "C:" 

   cDrive += IF( RIGHT( cDrive, 1 ) # ':', ':','' )

   aList := DIRECTORY( cDrive + "\", 'V' )

   cRVal := aList[ 1, 1 ]
   
RETU cRVal // HL_GetVolumLabel()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

#ifdef __XHARBOUR__

#define _ISDRIVESPEC( cDir ) ( ! Empty( hb_osDriveSeparator() ) .AND. Right( cDir, Len( hb_osDriveSeparator() ) ) == hb_osDriveSeparator() )

FUNCTION hb_DirSepAdd( cDir )

   IF ! HB_ISSTRING( cDir )
      RETURN ""
   ENDIF

   IF ! Empty( cDir ) .AND. ;
      ! _ISDRIVESPEC( cDir ) .AND. ;
      !( Right( cDir, 1 ) == hb_osPathSeparator() )

      cDir += hb_osPathSeparator()
   ENDIF

RETURN cDir

#endif
