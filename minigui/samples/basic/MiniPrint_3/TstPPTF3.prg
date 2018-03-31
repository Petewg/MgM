#include <hmg.ch>

#include "PrPTFil3.ch"

PROCEDURE MAIN()

    PRIVATE aPrinterList,;
            cDefaPrinter,;
            nSelPrintrNo,;
            lSelPrnDialog
    *
    * Paper names and size nums :
    *
    PRIVATE aPapers := MakPaprArr(),;
            nPaprLstNo := 7  // A4
    
    *
    * Print parameters :
    *
    PRIVATE cPTFilName := '',;
            nPaprTypeNo,;    
            lWordWrap,;    
            cFontName,;
            nFontSize,;
            nVMargin,;     // Vertical margin
            nHMargin,;     // Horizontal margin
            nChrsPerLin,;
            nLineHeigth,;
            bUpdaSBar,; 
            bUpdaPBar
    
    PRIVATE aSBarVals := ARRAY( 4 ),;    // Status Bar values 
            aShPrgsOp := ARRAY( 4 )      // Show Progress options
    
    InitPrOpts()                         // Initialize Printer options
    
    DEFINE WINDOW frmPPTFile ;
        AT 0,0 ;
        WIDTH 600;
        HEIGHT 200 ;
        TITLE 'Test Print a Plain Text File ( Comfortable way )' ;
        ON INIT InitMainForm() ;
        MAIN
        
        ON KEY ESCAPE ACTION ThisWindow.Release
        
        DEFINE MAIN MENU
           POPUP '&File'
              ITEM '&Select'  NAME mitFSele ACTION SeleFile()
              ITEM '&View'    NAME mitFView ACTION ViewFile()
              ITEM '&Print'   NAME mitFPrnt ACTION PrntFile()
	      SEPARATOR
              ITEM 'E&xit'    ACTION ThisWindow.Release
           END POPUP
           POPUP '&Options'
              ITEM '&Set / Reset' NAME mitPrOpts ACTION GFUPrnOpts()
           END POPUP
        END MENU

        DEFINE PROGRESSBAR prbarPrint
            ROW  50
            COL  20
            WIDTH  550
            HEIGHT 30
            RANGEMAX n2E16_1
            RANGEMIN 0
        END PROGRESSBAR
			
        DEFINE STATUSBAR FONT 'Verdana' SIZE 8
           STATUSITEM '' 
           STATUSITEM '' WIDTH 100
           STATUSITEM '' WIDTH 100
           STATUSITEM '' WIDTH 100 
        END STATUSBAR

    END WINDOW

    frmPPTFile.Center
    frmPPTFile.Activate

RETURN  // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SeleFile(;                    // Select Plain Text File
                    nCaller )

   LOCAL cSelFName := Getfile( { ;                                            // acFilter
                               { 'Text Files',      '*.txt' } ,;
                               { 'Program Files',    '*.prg' } ,;
                               { 'Format Files',     '*.fmg' } ,;
                               { 'Header Files',     '*.ch'  } ,;
                               { 'C Source Files',   '*.c'   } ,;
                               { 'CPP Source Files', '*.cpp'  } ;
                             },;
                           'Select Plain Text File' ,;   // Title
                           GetStartUpFolder(),;          // cDefaultPath
                           .F.,;                         // lMultiSelect
                           .T. )                         // lNoChangeCurrDir

   IF !EMPTY( cSelFName )
      cPTFilName := cSelFName
      UpdaSBar( cPTFilName, , HL_FSize( cPTFilName ), 0  )
   ENDIF
   
   frmPPTFile.mitFPrnt.Enabled := !EMPTY( cPTFilName ) 
   frmPPTFile.mitFView.Enabled := !EMPTY( cPTFilName ) 

RETURN  // SeleFile()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   This intermediate procedure required
   in order to keeping PPTFComf() as a "Black Box"

*/

PROCEDURE PrntFile()

    LOCAL nPPageCou := 0   // Printed page count
    
    IF FILE( cPTFilName )       
	    IF aShPrgsOp[ 1 ]
	       frmPPTFile.prbarPrint.Visible := .T.
	    ELSE
	       WaitWindow( "Printing ...", .T.)
	    ENDIF aShPrgsOp[ 1 ]    
		
        nPPageCou := PPTFComf( cPTFilName,;  // Source file name
                           cDefaPrinter,;
                           lSelPrnDialog,;
                           nPaprTypeNo,;
                           lWordWrap,;
                           cFontName,;
                           nFontSize,;
                           nVMargin,;        // Vertical margin
                           nHMargin,;        // Horizontal margin
                           nChrsPerLin,;
                           nLineHeigth,;
			   aShPrgsOp,;
                           bUpdaSBar,;
			   bUpdaPBar )
	 	 				 
        UpdaSBar( cPTFilName,,,nPPageCou )
	    IF aShPrgsOp[ 1 ]
	       frmPPTFile.prbarPrint.Visible := .F.
	    ELSE	
               WaitWindow()
	    ENDIF aShPrgsOp[ 1 ]			
    ELSE
        UpdaSBar( '','',0,0 )
        MsgStop( cPTFilName + " file not found !", "ERROR !" )
    ENDIF

RETURN  // PrntFile()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE GFUPrnOpts()                    // Get From User Print Options
   LOAD WINDOW PrntOpts AS frmPrntOpts
   ON KEY ESCAPE OF frmPrntOpts ACTION ThisWindow.Release
   frmPrntOpts.cmbPapers.SetFocus
   frmPrntOpts.Center
   frmPrntOpts.Activate
RETURN  // GFUPrnOpts()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE Fill_PrOps()                    // Variables => Controls
   * frmPrntOpts.txbSrcFile is RO;
   * for change source file name use File\Select
   frmPrntOpts.txbSrcFile.Value    := cPTFilName
   frmPrntOpts.cmbPrinters.Value   := nSelPrintrNo
   frmPrntOpts.chbDialog.Value     := lSelPrnDialog
   frmPrntOpts.cmbPapers.Value     := nPaprLstNo
   frmPrntOpts.chbWordWrap.Value   := lWordWrap
   frmPrntOpts.txbFontName.Value   := cFontName
   frmPrntOpts.spnFontSize.Value   := nFontSize
   frmPrntOpts.spnVertMarg.Value   := nVMargin
   frmPrntOpts.spnHorzMarg.Value   := nHMargin
   frmPrntOpts.spnChrsLine.Value   := nChrsPerLin
   frmPrntOpts.spnLineHeight.Value := nLineHeigth
   frmPrntOpts.chbPBar.Value       := aShPrgsOp[ 1 ]
   frmPrntOpts.chbSBI1.Value       := aShPrgsOp[ 2 ]
   frmPrntOpts.chbSBI3.Value       := aShPrgsOp[ 3 ]
   frmPrntOpts.chbSBI4.Value       := aShPrgsOp[ 4 ]
   frmPrntOpts.cmbPapers.SetFocus
RETURN // Fill_PrOps()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SetPrntOps()                    // Controls  => Variables ( set & exit )

    lWordWrap     :=  frmPrntOpts.chbWordWrap.Value
    nSelPrintrNo  := frmPrntOpts.cmbPrinters.Value
    cDefaPrinter  := aPrinterList[ nSelPrintrNo ]
    lSelPrnDialog := frmPrntOpts.chbDialog.Value
    nPaprLstNo    := frmPrntOpts.cmbPapers.Value
    nPaprTypeNo   := aPapers[ 1, nPaprLstNo ]
    cFontName     := frmPrntOpts.txbFontName.Value
    nFontSize     := frmPrntOpts.spnFontSize.Value
    nVMargin      := frmPrntOpts.spnVertMarg.Value
    nHMargin      := frmPrntOpts.spnHorzMarg.Value
    nChrsPerLin   := frmPrntOpts.spnChrsLine.Value
    nLineHeigth   := frmPrntOpts.spnLineHeight.Value
    aShPrgsOp     := { frmPrntOpts.chbPBar.Value,;
	                   frmPrntOpts.chbSBI1.Value,;
			       frmPrntOpts.chbSBI3.Value,;
			       frmPrntOpts.chbSBI4.Value }
					   
   frmPrntOpts.Release
   
   UpdaSBar( , cDefaPrinter )
   
RETURN // SetPrntOps()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ReSetPrntOps()

   InitPrOpts()

   Fill_PrOps()
   UpdaSBar( cPTFilName,,0 )
   
   frmPrntOpts.Release

RETURN // ReSetPrntOps()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE SelectPrinter()
   LOCAL cNewPrinter := GetPrinter()
   IF !EMPTY( cNewPrinter )
      nSelPrintrNo := ASCAN( aPrinterList, cNewPrinter )
      frmPrntOpts.cmbPrinters.Value := nSelPrintrNo
   ENDIF   
RETURN // SelectPrinter()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE InitMainForm()		
    frmPPTFile.prbarPrint.Visible := .F.
	frmPPTFile.mitFPrnt.Enabled := !EMPTY( cPTFilName ) 
    frmPPTFile.mitFView.Enabled := !EMPTY( cPTFilName ) 
	UpdaSBar( cPTFilName, cDefaPrinter, HL_FSize( cPTFilName ), 0 ) 	
RETURN // InitMainForm()				

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE InitPrOpts()                           // Initialize Printer options

   cPTFilName := ''
   aPrinterList := aPrinters()
   cDefaPrinter := GetDefaultPrinter()
   nSelPrintrNo := ASCAN( aPrinterList, cDefaPrinter )

   lSelPrnDialog := .F.
   nPaprLstNo    := 7  // A4
   nPaprTypeNo   := aPapers[ 1, nPaprLstNo ]
   lWordWrap     := .T.    // Wrap long lines
   cFontName     := "Lucida Console"
   nFontSize     := 10
   nVMargin      := 20    // Vertical margin
   nHMargin      := 20     // Horizontal margin
   nChrsPerLin   := 80
   nLineHeigth   := 5
   AFILL( aShPrgsOp, .F. )
   bUpdaSBar     := { | xi1, xi2, xi3, xi4 | UpdaSBar( xi1, xi2, xi3, xi4 ) }
   bUpdaPBar     := { | n1 | UpdaPBar( n1 ) }
   
RETURN // InitPrOpts()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE DialogChanged()
   frmPrntOpts.cmbPrinters.Enabled   := ! frmPrntOpts.chbDialog.Value
   frmPrntOpts.btnSelPrinter.Enabled := ! frmPrntOpts.chbDialog.Value
   frmPrntOpts.cmbPapers.Enabled     := ! frmPrntOpts.chbDialog.Value
RETURN  // DialogChanged()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE UpdaSBar( ... )                 // Update Status Bar

    LOCAL aParams := hb_AParams()
	
    IF EMPTY( aParams )
       aParams := ARRAY( 4 )
    ENDIF	  
	
    AEVAL( aParams, { | x1, i1 | IF( HB_ISNIL( x1 ),, aSBarVals[ i1 ] := x1 )} )

    frmPPTFile.StatusBar.Item( 1 ) := HL_ShrinkString( aSBarVals[ 1 ], 40 )         // cPTFilName / c1Line
    frmPPTFile.StatusBar.Item( 2 ) := xPADC( aSBarVals[ 2 ], 20 )                    // cDefaPrinter
    frmPPTFile.StatusBar.Item( 3 ) := xPADC( HL_BytesVerbal( aSBarVals[ 3 ] ), 20 )  // nFileSize / nBytesRead
    frmPPTFile.StatusBar.Item( 4 ) := xPADC( HL_NTOC( aSBarVals[ 4 ] ), 20 )         // nPPageCou

RETURN // UpdaSBar()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE UpdaPBar( ;                 // Update Progress Bar
                    nValue )
					
    frmPPTFile.prbarPrint.Value := nValue
					
RETURN // UpdaPBar()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ViewFile()
   IF !EMPTY( cPTFilName )
      EXECUTE FILE "NOTEPAD.EXE" PARAMETERS cPTFilName 	  
   ENDIF
RETURN // ViewFile()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
