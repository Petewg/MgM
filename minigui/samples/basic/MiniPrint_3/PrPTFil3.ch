#define HL_NTOC( n )	IF( n = 0, '', hb_ntos( n ) )
#define HL_FSize( cFN )	IF( !EMPTY( cFN ) .AND. FILE( cFN ), hb_FSize( cFN ), 0 )
#define n2E16_1		100

    MEMVAR  aPrinterList,;
            cDefaPrinter,;
            nSelPrintrNo,;
            lSelPrnDialog
    MEMVAR  aPapers,;
            nPaprLstNo
    MEMVAR  cPTFilName,;
            nPaprTypeNo,;    
            lWordWrap,;    
            cFontName,;
            nFontSize,;
            nVMargin,;
            nHMargin,;
            nChrsPerLin,;
            nLineHeigth,;
            bUpdaSBar,; 
            bUpdaPBar
    
    MEMVAR  aSBarVals,;
            aShPrgsOp
