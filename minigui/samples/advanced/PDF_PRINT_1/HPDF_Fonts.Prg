#include <hmg.ch>
#include "hmg_hpdf.ch"

memvar _HMG_HPDFDATA

PROCEDURE Main()
   
   LOCAL cAFontsPFN := "HPDF_Fonts.pdf"   // HPDF_Fonts PDF File Name
   
   DEFINE WINDOW frmAnExtOfr ;
      AT 0, 0 ;
      WIDTH 300 ;
      HEIGHT 300 ;
      MAIN ;
      TITLE 'HMG-HPDF Fonts'
      
      ON KEY ESCAPE ACTION ThisWindow.Release
      
      DEFINE MAIN MENU
      
         POPUP 'HMG-HPDF Fonts'
         
            ITEM 'Build'   ACTION Text2PDF( cAFontsPFN )
            ITEM 'Display' ACTION Disp_PDF( cAFontsPFN )
            ITEM 'Print'   ACTION PrintPDF( cAFontsPFN )
            
            SEPARATOR
         
            ITEM 'Exit' ACTION ThisWindow.Release
         
         END POPUP
         
      END MENU
      
   END WINDOW
   
   CENTER WINDOW   frmAnExtOfr
   ACTIVATE WINDOW frmAnExtOfr

RETURN // HPDF_Fonts.Main()

/*

   Display .pdf file without re-build.
   
*/

PROCEDURE Disp_PDF( cPFName )

   IF File( cPFName )
      EXECUTE FILE cPFName
   ELSE
      MsgStop( cPFName + " file not found !", "ERROR !" )
   ENDIF
   
RETURN // Disp_PDF()

/*

   Print .pdf file without user intervention and Print Dialog of OS (to default printer).
   
   Thanks to Dave (BPD) for hint.
   
*/

PROCEDURE PrintPDF( cPFName )

   IF File( cPFName )
      SHELLEXECUTE( 0, "PRINT", cPFName )
   ELSE
      MsgStop( cPFName + " file not found !", "ERROR !" )
   ENDIF

RETURN // PrintPDF()

/*
   No ANY text, but specially formatted one.
   
*/

PROCEDURE Text2PDF( ;                     // Build PDF from a text file
      cPdfFName )
                   
   LOCAL cTxtFNam :=  "AbtFonts.txt", ;
      lSuccess :=  .F. , ;
      nLineNo  :=   0, ;
      nItemCo  :=   0, ;    // Line count in text array
      nItemNo  :=   0, ;    // Line in text array
      nLineRow :=  30, ;    // 25 + 5
      nLineCol :=  25, ;    // Left marj
      nMaxPRow := 272, ;    // 297 - 25  // * 2 ) - 10
      nMaxPCol := 185, ;    // 210 - 25
      nLineSpc :=   5, ;    // Line Space  ( NO for "rectangled" text )
      cTitle  := "About HMG-HPDF Fonts", ;
      nPageNo  :=   0, ;
      cFCode   :=  '', ;    // Format code
      c1Font   :=  '', ;
      cSamplStr :=  "ABCDEFGHIabcdefghi012345!#$%&+-@?", ;
      nLMargin, ;
      nTextWidth, ;
      oFont, ;
      aText, c1Line, cLSpace, nTLnWidth, nTxtHigh
         
   LOCAL aFB14List := { "Courier", ;
      "Courier-Bold", ;
      "Courier-Oblique", ;
      "Courier-BoldOblique", ;
      "Helvetica", ;
      "Helvetica-Bold", ;
      "Helvetica-Oblique", ;
      "Helvetica-BoldOblique", ;
      "Times-Roman", ;
      "Times-Bold", ;
      "Times-Italic", ;
      "Times-BoldItalic", ;
      "Symbol" }
      
   IF hb_FileExists( cTxtFNam )
   
      aText  := hb_ATokens( MemoRead( cTxtFNam ), CRLF )
      nItemCo := Len( aText )
      
      IF nItemCo > 0
      
         SELECT HPDFDOC cPdfFName TO lSuccess papersize HPDF_PAPER_A4 // A4 210 x 297 mm
   
         IF lSuccess
   
            SET HPDFDOC COMPRESS ALL
            
            SET HPDFDOC PAGEMODE TO OUTLINE

            START HPDFDOC
            
            SET HPDFDOC ROOTOUTLINE TITLE "HMG-HPDF Fonts" NAME "HPDF_Fonts"
               
            WHILE nItemNo <= nItemCo
               
               nLineNo  := 0
               nLineRow := 25
                  
               START HPDFPAGE
                  
               IF ++nPageNo < 2
                     
                  @ nLineRow, nLineCol HPDFPRINT cTitle TO nLineRow, nMaxPCol ;
                     FONT 'Times-Bold' SIZE 14 CENTER
                     
                  nLineRow += nLineSpc * 2
                        
                  SET HPDFDOC PAGEOUTLINE TITLE "About" PARENT "HPDF_Fonts"

               ENDIF
                     
               WHILE nLineRow < nMaxPRow .AND. ++nItemNo <= nItemCo
                  ++nLineNo
                  nLineRow += nLineSpc
                  c1Line := aText[ nItemNo ]
                  IF Left( LTrim( c1Line ), 1 ) = "["
                     cFCode := SubStr( LTrim( c1Line ), 2, 1 )
                     IF cFCode = "b"  // Bold
                        c1Line := StrTran( c1Line, "[b]", "" )
                        @ nLineRow, nLineCol HPDFPRINT c1Line FONT 'Times-Bold' SIZE 12
                     ELSEIF cFCode = "i"  // italic
                        c1Line := StrTran( c1Line, "[i]", "" )
                        @ nLineRow, nLineCol HPDFPRINT c1Line FONT 'Times-Italic' SIZE 12
                     ELSEIF cFCode = "u"  // URL
                        c1Line := StrTran( c1Line, "[u]", "" )
                        @ nLineRow, nLineCol HPDFURLLINK c1Line TO c1Line COLOR BLUE // { 0, 0, 255 }
                     ENDIF
                  ELSE
                        
                     oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], 'Times-Roman', _HMG_HPDFDATA[ 1 ][ 10 ] )
                     HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, 12 )
                     nTextWidth := _HMG_HPDF_Pixel2MM( HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], c1Line ) )
                           
                     IF nTextWidth > nMaxPCol
                        cLSpace   := Space( Len( c1Line ) - Len( LTrim( c1Line ) ) )
                        nLMargin  := nLineCol + _HMG_HPDF_Pixel2MM( HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cLSpace ) )
                        c1Line    := LTrim( c1Line )
                        nTLnWidth := nMaxPCol - nLMargin
                        nTxtHigh  := ( nTextWidth / nTLnWidth + 1 ) * nLineSpc
                        @ nLineRow, nLMargin HPDFPRINT c1Line ;
                           TO ( nLineRow + nTxtHigh ), nMaxPCol ;
                           FONT 'Times-Roman' SIZE 12 ;
                           JUSTIFY
                        nLineRow += nTxtHigh - nLineSpc // nLineSpc * ( nTxtHigh - 1 )
                     ELSE
                        @ nLineRow, nLineCol HPDFPRINT c1Line FONT 'Times-Roman' SIZE 12
                     ENDIF
                             
                  ENDIF
               ENDDO
                     
               END HPDFPAGE
                  
            ENDDO
               
            START HPDFPAGE
               cTitle := "Standard Base 14 Fonts Samples"
               SET HPDFDOC PAGEOUTLINE TITLE "Samples" PARENT "HPDF_Fonts"
               nLineNo  := 0
               nLineRow := 25
               @ nLineRow, nLineCol HPDFPRINT cTitle TO nLineRow, nMaxPCol ;
                  FONT 'Times-Bold' SIZE 14 CENTER
               nLineRow += nLineSpc * 2  
               @ nLineRow, nLineCol HPDFPRINT RECTANGLE ;
                  TO nMaxPRow, nMaxPCol
                    
               nLineSpc *= 3
               nLineRow += nLineSpc * 2
                  
               FOR EACH c1Font IN aFB14List
                  @ nLineRow, nLineCol + 12 HPDFPRINT cSamplStr FONT c1Font SIZE 20
                     nLineRow += nLineSpc
               NEXT c1Font 
                  
            END HPDFPAGE
                  
            END HPDFDOC
            
            IF hb_FileExists( cPdfFName )
               Disp_PDF( cPdfFName )
            ELSE
               MsgStop( "Couldn't FOUND " + cPdfFName, "ERROR !" )
            ENDIF
            
         ELSE
            MsgStop( "Couldn't START " + cPdfFName, "ERROR !" )
         ENDIF
      ELSE
         MsgStop( cTxtFNam + " file is EMPTY !", "Error !" )
      ENDIF
   ELSE
      MsgStop( cTxtFNam + " file not found !", "Error !" )
   ENDIF
   
RETURN // Text2PDF()

//-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
