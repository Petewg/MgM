#command EXIT <x> => exit

#translate ISNIL(  <xVal> )   => ( <xVal> == NIL )
#translate ISARRY( <xVal> )   => ( VALTYPE( <xVal> ) == "A" )
#translate ISBLOK( <xVal> )   => ( VALTYPE( <xVal> ) == "B" )
#translate ISCHAR( <xVal> )   => ( VALTYPE( <xVal> ) == "C" )
#translate ISDATE( <xVal> )   => ( VALTYPE( <xVal> ) == "D" )
#translate ISLOGI( <xVal> )   => ( VALTYPE( <xVal> ) == "L" )
#translate ISMEMO( <xVal> )   => ( VALTYPE( <xVal> ) == "M" )
#translate ISNUMB( <xVal> )   => ( VALTYPE( <xVal> ) == "N" )
#translate ISOBJE( <xVal> )   => ( VALTYPE( <xVal> ) == "O" )

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                        ;
          =>                                                            ;
          IF <v1> == NIL ; <v1> := <x1> ; END                           ;
          [; IF <vn> == NIL ; <vn> := <xn> ; END ]

#define lFBDebug .F.

#ifndef TRUE     
# define TRUE  .T.
# define FALSE .F.
# define YES   .T.
# define NO    .F.
#endif
#define CRLF2 CRLF + CRLF

#define c1Tab CHR(9)
#define NTrim2( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ))

#define NTrim( n )   LTrim( TRAN( n,"999,999,999,999,999,999,999" ) )
#define Crocked(x1)  ( ">" + AnyToStr( x1 ) + "<" )
#define IsInRang( xVal, xMin, xMax ) ( xVal >= xMin .AND. xVal <= xMax ) 
#define ISNArr( x )  ( ISARRY(x) .AND. LEN(x) == 2  .AND. ISCHAR( x[1] ) )
#define IsData( n1)  ( n1 >= 32 .AND. n1 <= 256)   // determine a key is data
#define Lecced( x1 ) ( ">" + AnyToStr( x1 ) + "<" )

*
*  Bunun için bak (ÝNCELE) : SetCurrentFolder() 
*
#define CurrDisk() ( LEFT( GetCurrentFolder(), 1 ) ) // Attention ! No ":", only letter.

#define nMaxDataCo  52   // Maximum openable data (file) count
#define nMaxTablCo  25   // Maximum openable Table count
#define nMaxPageCo  10   // Azami sayfa sayýsý ( == tarif edilmiþ düðme sayýsý )
#define nMinBtWdt   88   // Asgari düðme geniþliði ( vasati 11 karakter için )
#define nNavBtWdt   21   // Yön düðmeleri geniþliði 

* #define nOpTableCo LEN( aOpTables ) // Açýk "table" sayýsý

*
*   nMinMWWid : Ana pencerenin asgari eni; 3 asgari düðmelik.
*
#define nMinMWWid ( nMinBtWdt + 2 ) * 3 + nPrvBtLen + nNxtBtLen + 1 // Ana pencerenin asgari eni
#define nMinMWHig ( nMainWHig / 3 ) // Ana pencerenin asgari yüksekliði 

#define Name2Num( cName )  ( VAL( RIGHT( cName, 3 ) ) )
#define Num2Name( c1, n1 ) ( c1 + STRZERO( n1, 3 ) )

#define Strg2Hex( cStrng ) ;                  // Convert a string to hex
        ( SEVAL( cStrng, '', ,{ | c1, i1, cTrg | cTrg += NTOC( ASC( c1 ), 16, 2, "0" ) } ) )


   MEMV cInTFName

   MEMV aOpnDatas  ,;   // Open Datas
        aOpnTables ,;   // Open Tables
        nOpDataCo  ,;   // Open Data Count
        nOpTablCo  ,;   // Open Table Count
        nOpUKnwCo  ,;   // Open UnKnowns Count
        nOpQueris  ,;   // Open Queries
        nOpnViews  ,;   // Open Views
        nOpLabels  ,;   // Open Labels
        nOpReports ,;   // Open Reports
        nOpFormats ,;   // Open Formats
        nOpTexts   ,;   // Open Textts
        lOpnCatal  ,;   //
        nCurDatNo  ,;   // Current Data No
        nCurPagNo  ,;   // Current Page No
        nOpnPagCo  ,;   // Open (Active, visible ) Page Count
        n1PagDtNo  ,;   // 1st Page Data No
        n1OpPagNo  ,;   // 1st Open Page No // CDC
        nBtnWidth  ,;   // Button width
        nMainWWid  ,;
        nMainWHig  ,;
        nPrvBtLen  ,;
        nNxtBtLen  ,;
        cMWinName  ,;
        cProgFold  ,;   // GetExeFileName()
        cLastCDir  ,;   // Last Used Code Folder
        cLastDDir       // Last Used Data Folder

   MEMV cBegFoldr  ,;
        cCDsKunye

   MEMV cCDskLabl  ,;
        cCDskSerN

   MEMV aUPPromts  ,;
        lPref0101  ,;  // Open Recent Files at Start Up
        lPref0102  ,;  // Request user confirmation for file overwriting
        lPref0103  ,;  // Request confirmation for Shutdown
        lPref0104      // Apply Validity Cheking on user supplied expressions

   MEMV aStExStru  ,;
        aMnuItems
