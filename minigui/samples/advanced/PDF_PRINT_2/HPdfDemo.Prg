/*

  HPdfDemo02 :
  
  An exercise to building a bill as a .pdf file by using new feature of HMG : HMG_PDF 
  
  Author : Bicahi Esgici
  
  Copyright : Public domain
  
  History : 2012.10.03 : First release
            2012.10.04 : - Added :
                           - a table : COMPANY  ( hard coded company info removed )
                           - a PRIVATE variable : lWayBill
                           - VAT
                           - Multiple pages 
                         - Changed : some cosmetics   
            2013.19.04 : - Added :
                         - horizontal and vertical rulers for convenient PDF design
*/

#include <hmg.ch>
#include "hmg_hpdf.ch"

MEMVAR cCmpLogo
MEMVAR cBilDate
MEMVAR cBillNum
MEMVAR cDueDate
MEMVAR nBillSum
MEMVAR nBillTot
MEMVAR lWayBill
MEMVAR nLinPPag
MEMVAR nBLineNo
MEMVAR nPageNo
MEMVAR nPageCo
MEMVAR nVATRatio

PROCEDURE Main()

   SET DATE GERM
   SET CENT ON

   DEFINE WINDOW frmHPdfDemo ;
      AT 0, 0 ;
      WIDTH 300 ;
      HEIGHT 300 ;
      MAIN ;
      ON INIT OpenTables() ;
      TITLE 'HPDF Bill Demo'

      DEFINE BUTTON btnBuildPDF
         ROW 100
         COL 100
         CAPTION 'Print to PDF'
         ACTION PrntToPdf()         
         DEFAULT .T.      
      END BUTTON

   END WINDOW // frmHPdfDemo

   frmHPdfDemo.Center
   frmHPdfDemo.Activate

RETURN // HPdfDemo.Main()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE OpenTables()

   USE COMPANY
   USE CUSTOMER NEW
   USE INVOICE  NEW
   
RETURN // OpenTables()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE PrntToPdf()

   LOCAL cPFName  := "HPdfDemo.pdf",;
         nLMargin := 20,;
         nUMargin := 20

   LOCAL lSuccess

   cCmpLogo := "CompLogo.Png"
   cBilDate := DTOC( DATE() )
   cBillNum := "RSCP0123"
   nBillSum := 0
   nBillTot := 0
   cDueDate := DTOC( DATE() + 30 )
   lWayBill := .T.
   nLinPPag := 30  // Line per page
   nBLineNo := 0
   nPageNo  := 0   
   nPageCo  := INT( INVOICE->( LASTREC()) / nLinPPag ) + 1
   nVATRatio := 1.18

   SELECT HPDFDOC cPFName TO lSuccess PAPERSIZE HPDF_PAPER_A4

   IF lSuccess

      START HPDFDOC

         DBSELECTAR( "INVOICE" )
         SUM INVOICE->LINTOTAL TO nBillSum
         nBillSum *= nVATRatio

         DBGOTOP()

         FOR nPageNo := 1 TO nPageCo

            START HPDFPAGE

               HPDFReglaH()         // Horizontal Ruler
               HPDFReglaH( 185 )    // Horizontal Ruler
               HPDFReglaV()         // Vertical Ruler

               WriteCompany( nUMargin,      nLMargin )
               WritePayer  ( nUMargin + 40, nLMargin ) 

               WriteDetail ( nUMargin + 80, nLMargin )

               @ nUMargin - 2, nLMargin - 2  HPDFPRINT RECTANGLE ;
                           TO 277, 187 ;
                           PENWIDTH .5

            END HPDFPAGE

         NEXT nPageNo

      END HPDFDOC

      IF FILE( cPFName )
         EXECUTE FILE cPFName
      ELSE
         MsgStop( "Couldn't found " + cPFName, "ERROR !" )
      ENDIF      

   ELSE

      MsgStop( "Couldn't SELECT HPDFDOC", "ERROR !" )

   ENDIF lSuccess

   QUIT

RETURN // PrntToPdf()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE WriteCompany( ;                  // Print company Info to PDF
                        nRow,; 
                        nCol )

   @ nRow,       nCol  HPDFPRINT RECTANGLE ;
                       TO nRow + 35, nCol + 110 ;
                       PENWIDTH 0.1

   IF FILE( cCmpLogo )                        
     @ nRow +  3,  nCol +   3 HPDFPRINT IMAGE cCmpLogo WIDTH 50 HEIGHT 30 
   ELSE
      MsgStop( "Can not found " + cCmpLogo )    
   ENDIF

   @ nRow + 10,  nCol +  55 HPDFPRINT TRIM( COMPANY->NAME ) FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 15,  nCol +  55 HPDFPRINT TRIM( COMPANY->ADRESS1 ) + " " + ;
                                       TRIM( COMPANY->ADRESS2 ) SIZE 10                                        
   @ nRow + 20,  nCol +  55 HPDFPRINT TRIM( COMPANY->CITYSTAT ) + " " + ;
                                       TRIM( COMPANY->ZIP ) + " " + ;
                                       TRIM( COMPANY->COUNTRY ) SIZE 10 
   @ nRow + 25,  nCol +  55 HPDFPRINT TRIM( COMPANY->PHONE ) SIZE 10 
   @ nRow + 30,  nCol +  55 HPDFPRINT TRIM( COMPANY->WEBSITE ) COLOR BLUE SIZE 10 

   @ nRow +  6,  nCol + 140 HPDFPRINT "DATE :"      RIGHT SIZE 10 
   @ nRow + 13,  nCol + 140 HPDFPRINT "INVOICE # :" RIGHT SIZE 10 
   @ nRow + 20,  nCol + 140 HPDFPRINT "Page # :" RIGHT SIZE 10 
   @ nRow + 27,  nCol + 140 HPDFPRINT "Total :"     RIGHT SIZE 10 
   @ nRow + 34,  nCol + 140 HPDFPRINT "Due Date :"  RIGHT SIZE 10 

   @ nRow +  6,  nCol + 143 HPDFPRINT cBilDate
   @ nRow + 13,  nCol + 143 HPDFPRINT cBillNum
   @ nRow + 20,  nCol + 143 HPDFPRINT LTRIM( STR( nPageNo ) ) + "/" + LTRIM( STR( nPageCo ) )
   @ nRow + 27,  nCol + 143 HPDFPRINT "$ " + LTRIM( TRANSFORM( nBillSum, "99,999,999.99" ) ) FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 34,  nCol + 143 HPDFPRINT cDueDate

RETURN // WriteCompany()   

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE WritePayer( ;
                         nRow,; 
                         nCol )

   @ nRow,       nCol  HPDFPRINT RECTANGLE ;
                       TO nRow + 35, nCol + 165 ;
                       PENWIDTH 0.1

   @ nRow +  8,  nCol +  5 HPDFPRINT "Bill to :" FONT 'Helvetica-Bold' SIZE 10 
   @ nRow +  8,  nCol + 85 HPDFPRINT "Ship to :" FONT 'Helvetica-Bold' SIZE 10 

   @ nRow + 12,  nCol + 25 HPDFPRINT "Name :"         RIGHT SIZE 9 
   @ nRow + 16,  nCol + 25 HPDFPRINT "Adress :"       RIGHT SIZE 9 
   @ nRow + 24,  nCol + 25 HPDFPRINT "City ST ZIP :"  RIGHT SIZE 9 
   @ nRow + 28,  nCol + 25 HPDFPRINT "Country :"      RIGHT SIZE 9 
   @ nRow + 32,  nCol + 25 HPDFPRINT "Phone :"        RIGHT SIZE 9 

   @ nRow + 12,  nCol + 105 HPDFPRINT "Name :"         RIGHT SIZE 9 
   @ nRow + 16,  nCol + 105 HPDFPRINT "Adress :"       RIGHT SIZE 9 
   @ nRow + 24,  nCol + 105 HPDFPRINT "City ST ZIP :"  RIGHT SIZE 9 
   @ nRow + 28,  nCol + 105 HPDFPRINT "Country :"      RIGHT SIZE 9 
   @ nRow + 32,  nCol + 105 HPDFPRINT "Contact :"      RIGHT SIZE 9 

   nCol += IF( lWayBill,  80, 0 )

   @ nRow + 12,  nCol + 27 HPDFPRINT CUSTOMER->SALUTE + TRIM( CUSTOMER->NAME ) FONT 'Times-Roman' SIZE 11
   @ nRow + 16,  nCol + 27 HPDFPRINT TRIM( CUSTOMER->ADRESS1 ) FONT 'Times-Roman' SIZE 11
   @ nRow + 20,  nCol + 27 HPDFPRINT TRIM( CUSTOMER->ADRESS2 ) FONT 'Times-Roman' SIZE 11
   @ nRow + 24,  nCol + 27 HPDFPRINT TRIM( CUSTOMER->CITYSTAT ) + " " + ;
                                     TRIM( CUSTOMER->ZIP ) FONT 'Times-Roman' SIZE 11
   @ nRow + 28,  nCol + 27 HPDFPRINT TRIM( CUSTOMER->COUNTRY ) FONT 'Times-Roman' SIZE 11
   @ nRow + 32,  nCol + 27 HPDFPRINT TRIM( CUSTOMER->PHONE ) FONT 'Times-Roman' SIZE 11
   
RETURN // WritePayer()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE WriteDetail(;
                        nRow,; 
                        nCol )
   LOCAL nRow1    := nRow,;
          nPLinNo := 0

   @ nRow,       nCol  HPDFPRINT RECTANGLE ;
                       TO nRow + 175, nCol + 165 ;
                       PENWIDTH 0.1

   @ nRow + 10,  nCol  HPDFPRINT LINE ;
                       TO nRow + 10, nCol + 165 ;
                       PENWIDTH 0.1

   @ nRow,  nCol + 13  HPDFPRINT LINE ;
                       TO nRow + 163, nCol + 13 ;
                       PENWIDTH 0.1

   @ nRow,  nCol + 105 HPDFPRINT LINE ;
                       TO nRow + 163, nCol + 105 ;
                       PENWIDTH 0.1

   @ nRow,  nCol + 125 HPDFPRINT LINE ;
                       TO nRow + 163, nCol + 125 ;
                       PENWIDTH 0.1

   @ nRow,  nCol + 143 HPDFPRINT LINE ;
                       TO nRow + 175, nCol + 143 ;
                       PENWIDTH 0.1

   @ nRow + 7, nCol +   7  HPDFPRINT "#" FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 7, nCol +  15  HPDFPRINT "Product" FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 7, nCol + 107  HPDFPRINT "Unit Price" FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 7, nCol + 127  HPDFPRINT "Quantity" FONT 'Helvetica-Bold' SIZE 10 
   @ nRow + 7, nCol + 146  HPDFPRINT "Line Total" FONT 'Helvetica-Bold' SIZE 10 

   nRow += 10

   IF nPageNo > 1
      @ nRow + 5, nCol + 141 HPDFPRINT "Carryover" RIGHT FONT 'Helvetica-Bold'  SIZE 9 
      @ nRow + 5, nCol + 162 HPDFPRINT TRANSFORM( nBillTot, "99,999,999" ) RIGHT FONT 'Helvetica-Bold' SIZE 10 
      nRow += 5
      ++nPLinNo
   ENDIF   

   WHILE ++nPLinNo <= nLinPPag .AND. .NOT. EOF()   
      nRow += 5
      @ nRow, nCol +  10 HPDFPRINT TRANSFORM( INVOICE->(RECNO()), "999" ) RIGHT  SIZE 9 
      @ nRow, nCol +  15 HPDFPRINT            INVOICE->PRODUCT         SIZE 9 
      @ nRow, nCol + 122 HPDFPRINT TRANSFORM( INVOICE->UNITPRIC, "99,999.99" )  RIGHT SIZE 9 
      @ nRow, nCol + 140 HPDFPRINT TRANSFORM( INVOICE->QUANTITY, "99999.99" )     RIGHT SIZE 9 
      @ nRow, nCol + 162 HPDFPRINT TRANSFORM( INVOICE->LINTOTAL, "99,999,999.99" )     RIGHT SIZE 9 
      nBillTot += INVOICE->LINTOTAL
      ++nBLineNo
      DBSKIP()
   ENDDO   

   @ nRow +  3,  nCol  HPDFPRINT LINE ;
                       TO nRow + 3, nCol + 165 ;
                       PENWIDTH 0.1
   IF EOF()    
      @ nRow1 + 163,  nCol  HPDFPRINT LINE ;
                        TO nRow1 + 163, nCol + 165 ;
                        PENWIDTH 0.1
   ENDIF

   IF EOF() .AND. nPLinNo < nLinPPag
      @ nRow + 8, nCol + 140 HPDFPRINT " Total" FONT 'Helvetica-Bold' RIGHT SIZE 10 
      @ nRow + 8, nCol + 162 HPDFPRINT TRANSFORM( nBillTot, "99,999,999.99" ) RIGHT FONT 'Helvetica-Bold' SIZE 10 
      @ nRow1 + 160, nCol + 143 HPDFPRINT "VAT (" + LTRIM( STR( ( nVATRatio - 1 ) * 100, 2 ) ) + "%)" ;
                                 FONT 'Helvetica-Bold' RIGHT SIZE 10 
      @ nRow1 + 160, nCol + 162 HPDFPRINT TRANSFORM( nBillTot * nVATRatio - nBillTot, "99,999,999.99" ) RIGHT FONT 'Helvetica-Bold' SIZE 10 
      
      @ nRow1 + 171, nCol + 140 HPDFPRINT "Total" FONT 'Helvetica-Bold' RIGHT SIZE 10 
      @ nRow1 + 171, nCol + 162 HPDFPRINT TRANSFORM( nBillTot * nVATRatio, "99,999,999.99" ) RIGHT FONT 'Helvetica-Bold' SIZE 10 
   ELSE
      @ nRow1 + 171, nCol + 140 HPDFPRINT "Carry forward" FONT 'Helvetica-Bold' RIGHT SIZE 10 
      @ nRow1 + 171, nCol + 162 HPDFPRINT TRANSFORM( nBillTot, "99,999,999" ) RIGHT FONT 'Helvetica-Bold' SIZE 10 
   ENDIF      

RETURN // WriteDetail()                        

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION HPDFReglaH( nRenMM )
    LOCAL i1

    DEFAULT nRenMM:=4

    FOR i1=10 TO 209
        @ nRenMM,(000+i1)-1 HPDFPRINT IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") SIZE 6 COLOR BLACK
        @ nRenMM,000+i1 HPDFPRINT LINE TO IF( RIGHT( STR( INT( i1 ) ),1 )="0",nRenMM+007, ;
                                          IF( RIGHT( STR( INT( i1 ) ),1 )="5", nRenMM+005, nRenMM+4 ) ),000+i1 ;
                                          PENWIDTH .1 COLOR GRAY
    NEXT

RETURN( Nil )

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FUNCTION HPDFReglaV( nColMM )
    LOCAL i1

    DEFAULT nColMM:=4

    FOR i1=10 TO 280
        @ 000+i1,nColMM-1 HPDFPRINT IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") SIZE 6 COLOR BLACK
        @ 000+i1,nColMM HPDFPRINT LINE TO 000+i1, IF( RIGHT( STR( INT( i1 ) ),1 )="0", nColMM+007, ;
                                                  IF( RIGHT( STR( INT( i1 ) ),1 )="5", nColMM+005, nColMM+4 ) ) ;
                                                  PENWIDTH .1 COLOR GRAY
    NEXT

RETURN( Nil )
