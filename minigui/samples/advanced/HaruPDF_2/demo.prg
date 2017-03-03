/*
 * MiniGUI HaruPDF Class Demo
 *
 * (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PDF_PORTRAIT  1
#define PDF_LANDSCAPE 2
#define PDF_TXT       3

PROCEDURE Main
  
	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'HaruPDF Class Demo' ;
		MAIN ;
		ON INTERACTIVECLOSE MsgYesNo ( 'Are You Sure ?', 'Exit' )

		ON KEY ESCAPE ACTION ThisWindow.Release

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	180
			CAPTION 'Generate PDF Portrait'
			ACTION Test( PDF_PORTRAIT )
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	50
			COL	10
			WIDTH	180
			CAPTION 'Generate PDF Landscape'
			ACTION Test( PDF_LANDSCAPE )
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	90
			COL	10
			WIDTH	180
			CAPTION 'Generate TEXT List'
			ACTION Test( PDF_TXT )
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

RETURN


PROCEDURE Test( nType )

   LOCAL oPDF, nCont

   oPDF := PDFClass():New()
   oPDF:nType := nType
   oPDF:cHeader := "TEST REPORT" + Str( nType, 2 ) + "   " + TxtSaida()[nType]
   oPDF:cFileName := "test" + Str( nType, 1 ) + "." + iif( nType < 3, "pdf", "txt" )

   oPDF:Begin()
   //            cAuthor,        cCreator,       cTitle,        cSubject
   oPDF:SetInfo( 'Jose Quintas', 'MiniGUI Demo', 'TEST REPORT', TxtSaida()[nType] )

      FOR nCont := 1 TO 1000

         oPDF:MaxRowTest()
         oPDF:DrawText( oPDF:nRow++, 0, nCont )

      NEXT

   oPDF:End()

RETURN

* PDFClass
*----------------------------------------------------------------

#require "hbhpdf"
#include "hbclass.ch"
#include "harupdf.ch"

CREATE CLASS PDFClass

   VAR    oPdf
   VAR    oPage
   VAR    cFileName         INIT ""
   VAR    nRow              INIT 999
   VAR    nCol              INIT 0
   VAR    nAngle            INIT 0
   VAR    cFontName         INIT "Courier"
   VAR    nFontSize         INIT 9
   VAR    nLineHeight       INIT 1.3
   VAR    nMargin           INIT 30
   VAR    nType             INIT 1
   VAR    nPdfPage          INIT 0
   VAR    nPageNumber       INIT 0
   VAR    cHeader           INIT {}
   VAR    cCodePage         INIT "CP1252"
   METHOD AddPage()
   METHOD RowToPDFRow( nRow )
   METHOD ColToPDFCol( nCol )
   METHOD MaxRow()
   METHOD MaxCol()
   METHOD DrawText( nRow, nCol, xValue, cPicture, nFontSize, cFontName, nAngle, anRGB )
   METHOD DrawLine( nRowi, nColi, nRowf, nColf, nPenSize )
   METHOD DrawRetangle( nTop, nLeft, nWidth, nHeight, nPenSize, nFillType, anRGB )
   METHOD DrawImage( cJPEGFile, nRow, nCol, nWidth, nHeight )
   METHOD Cancel()
   METHOD PrnToPdf( cInputFile )
   METHOD SetType( nType )
   METHOD PageHeader()
   METHOD MaxRowTest( nRows )
   METHOD SetInfo( cAuthor, cCreator, cTitle, cSubject )
   METHOD Begin()
   METHOD End()
   ENDCLASS

METHOD Begin() CLASS PDFClass

   IF ::nType == PDF_TXT
      IF Empty( ::cFileName )
         ::cFileName := MyTempFile( "LST" )
      ENDIF
      SET PRINTER TO ( ::cFileName )
      SET DEVICE TO PRINT
   ELSE
      IF Empty( ::cFileName )
         ::cFileName := MyTempFile( "PDF" )
      ENDIF
      ::oPdf := HPDF_New()
      HPDF_SetCompressionMode( ::oPdf, HPDF_COMP_ALL )
      IF ::cCodePage != NIL
         HPDF_SetCurrentEncoder( ::oPDF, ::cCodePage )
      ENDIF
   ENDIF
   RETURN NIL

METHOD End() CLASS PDFClass

   IF ::nType == PDF_TXT
      SET DEVICE TO SCREEN
      SET PRINTER TO
   ELSE
      IF ::nPdfPage == 0
         ::AddPage()
         ::DrawText( 10, 10, "NO CONTENT",, ::nFontSize * 2 )
      ENDIF
      IF File( ::cFileName )
         fErase( ::cFileName )
      ENDIF
      HPDF_SaveToFile( ::oPdf, ::cFileName )
      HPDF_Free( ::oPdf )
   ENDIF
   EXECUTE FILE ::cFileName

   RETURN NIL

METHOD SetInfo( cAuthor, cCreator, cTitle, cSubject ) CLASS PDFClass

   IF ::nType == PDF_TXT .OR. Empty( ::oPDF )
      RETURN NIL
   ENDIF
   cAuthor  := iif( cAuthor == NIL, "JPA Tecnologia", cAuthor )
   cCreator := iif( cCreator == NIL, "Harupdf", cCreator )
   cTitle   := iif( cTitle == NIL, "", cTitle )
   cSubject := iif( cSubject == NIL, cTitle, cSubject )
   HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_AUTHOR, cAuthor )
   HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_CREATOR, cCreator )
   HPDF_SetInfoAttr( ::oPDF, HPDF_INFO_TITLE, cTitle )
   HPDF_SetInfoAttr( ::oPdf, HPDF_INFO_SUBJECT, cSubject )
   HPDF_SetInfoDateAttr( ::oPDF, HPDF_INFO_CREATION_DATE, { Year( Date() ), Month( Date() ), Day( Date() ), ;
      Val( Substr( Time(), 1, 2 ) ), Val( Substr( Time(), 4, 2 ) ), Val( Substr( Time(), 7, 2 ) ), "+", 4, 0 } )
   RETURN NIL

METHOD SetType( nType ) CLASS PDFClass

   IF nType != NIL
      ::nType := nType
   ENDIF
   ::nFontSize := iif( ::nType == 1, 9, 6 )
   RETURN NIL

METHOD AddPage() CLASS PDFClass

   IF ::nType != PDF_TXT
      ::oPage := HPDF_AddPage( ::oPdf )
      HPDF_Page_SetSize( ::oPage, HPDF_PAGE_SIZE_A4, iif( ::nType == 1, HPDF_PAGE_PORTRAIT, HPDF_PAGE_LANDSCAPE ) )
      HPDF_Page_SetFontAndSize( ::oPage, HPDF_GetFont( ::oPdf, ::cFontName, ::cCodePage ), ::nFontSize )
   ENDIF
   ::nRow := 0
   RETURN NIL

METHOD Cancel() CLASS PDFClass

   IF ::nType != PDF_TXT
      HPDF_Free( ::oPdf )
   ENDIF
   RETURN NIL

METHOD DrawText( nRow, nCol, xValue, cPicture, nFontSize, cFontName, nAngle, anRGB ) CLASS PDFClass

   LOCAL nRadian , cTexto

   nFontSize := iif( nFontSize == NIL, ::nFontSize, nFontSize )
   cFontName := iif( cFontName == NIL, ::cFontName, cFontName )
   cPicture  := iif( cPicture == NIL, "", cPicture )
   nAngle    := iif( nAngle == NIL, ::nAngle, nAngle )
   cTexto    := Transform( xValue, cPicture )
   ::nCol := nCol + Len( cTexto )
   IF ::nType == PDF_TXT
      @ nRow, nCol SAY cTexto
   ELSE
      nRow := ::RowToPDFRow( nRow )
      nCol := ::ColToPDFCol( nCol )
      HPDF_Page_SetFontAndSize( ::oPage, HPDF_GetFont( ::oPdf, cFontName, ::cCodePage ), nFontSize )
      IF anRGB != NIL
         HPDF_Page_SetRGBFill( ::Page, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
         HPDF_Page_SetRGBStroke( ::Page, anRGB[ 1 ], anRGB[ 2], anRGB[ 3] )
      ENDIF
      HPDF_Page_BeginText( ::oPage )
      nRadian := ( nAngle / 180 ) * 3.141592
      HPDF_Page_SetTextMatrix( ::oPage, Cos( nRadian ), Sin( nRadian ), -Sin( nRadian ), Cos( nRadian ), nCol, nRow )
      HPDF_Page_ShowText( ::oPage, cTexto )
      HPDF_Page_EndText( ::oPage )
      IF anRGB != NIL
         HPDF_Page_SetRGBFill( ::Page, 0, 0, 0 )
         HPDF_Page_SetRGBStroke( ::Page, 0, 0, 0 )
      ENDIF
   ENDIF
   RETURN NIL

METHOD DrawLine( nRowi, nColi, nRowf, nColf, nPenSize ) CLASS PDFClass

   IF ::nType == PDF_TXT
      nRowi := Round( nRowi, 0 )
      nColi := Round( nColi, 0 )
      @ nRowi, nColi SAY Replicate( "-", nColf - nColi )
      ::nCol := Col()
   ELSE
      nPenSize := iif( nPenSize == NIL, 0.2, nPenSize )
      nRowi := ::RowToPDFRow( nRowi )
      nColi := ::ColToPDFCol( nColi )
      nRowf := ::RowToPDFRow( nRowf )
      nColf := ::ColToPDFCol( nColf )
      HPDF_Page_SetLineWidth( ::oPage, nPenSize )
      HPDF_Page_MoveTo( ::oPage, nColi, nRowi )
      HPDF_Page_LineTo( ::oPage, nColf, nRowf )
      HPDF_Page_Stroke( ::oPage )
   ENDIF
   RETURN NIL

METHOD DrawImage( cJPEGFile, nRow, nCol, nWidth, nHeight ) CLASS PDFClass

   LOCAL oImage

   IF ::nType == PDF_TXT
      RETURN NIL
   ENDIF
   nRow    := ::RowToPDFRow( nRow )
   nCol    := ::ColToPDFCol( nCol )
   nWidth  := Int( nWidth * ::nFontSize / 2 )
   nHeight := nHeight * ::nFontSize
   oImage := HPDF_LoadJPEGImageFromFile( ::oPdf, cJPEGFile )
   HPDF_Page_DrawImage( ::oPage, oImage, nCol, nRow, nWidth, nHeight )
   RETURN NIL

METHOD DrawRetangle( nTop, nLeft, nWidth, nHeight, nPenSize, nFillType, anRGB ) CLASS PDFClass

   IF ::nType == PDF_TXT
      RETURN NIL
   ENDIF
   nFillType := iif( nFillType == NIL, 1, nFillType )
   nPenSize  := iif( nPenSize == NIL, 0.2, nPenSize )
   nTop      := ::RowToPDFRow( nTop )
   nLeft     := ::ColToPDFCol( nLeft )
   nWidth    := ( nWidth ) * ::nFontSize / 1.666
   nHeight   := -( nHeight ) * :: nFontSize
   HPDF_Page_SetLineWidth( ::oPage, nPenSize )
   IF anRGB != NIL
      HPDF_Page_SetRGBFill( ::oPage, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
      HPDF_Page_SetRGBStroke( ::oPage, anRGB[ 1 ], anRGB[ 2 ], anRGB[ 3 ] )
   ENDIF
   HPDF_Page_Rectangle( ::oPage, nLeft, nTop, nWidth, nHeight )
   IF nFillType == 1
      HPDF_Page_Stroke( ::oPage )     // borders only
   ELSEIF nFillType == 2
      HPDF_Page_Fill( ::oPage )       // inside only
   ELSE
      HPDF_Page_FillStroke( ::oPage ) // all
   ENDIF
   IF anRGB != NIL
      HPDF_Page_SetRGBStroke( ::oPage, 0, 0, 0 )
      HPDF_Page_SetRGBFill( ::oPage, 0, 0, 0 )
   ENDIF
   RETURN NIL

METHOD RowToPDFRow( nRow ) CLASS PDFClass

   RETURN HPDF_Page_GetHeight( ::oPage ) - ::nMargin - ( nRow * ::nFontSize * ::nLineHeight )

METHOD ColToPDFCol( nCol ) CLASS PDFClass

   RETURN nCol * ::nFontSize / 1.666 + ::nMargin

METHOD MaxRow() CLASS PDFClass

   LOCAL nPageHeight, nMaxRow

   IF ::nType == PDF_TXT
      RETURN 63
   ENDIF
   nPageHeight := HPDF_Page_GetHeight( ::oPage ) - ( ::nMargin * 2 )
   nMaxRow     := Int( nPageHeight / ( ::nFontSize * ::nLineHeight )  )
   RETURN nMaxRow

METHOD MaxCol() CLASS PDFClass

   LOCAL nPageWidth, nMaxCol

   IF ::nType == PDF_TXT
      RETURN 132
   ENDIF
   nPageWidth := HPDF_Page_GetWidth( ::oPage ) - ( ::nMargin * 2 )
   nMaxCol    := Int( nPageWidth / ::nFontSize * 1.666 )
   RETURN nMaxCol

METHOD PrnToPdf( cInputFile ) CLASS PDFClass

   LOCAL cTxtReport, cTxtPage, cTxtLine, nRow

   cTxtReport := MemoRead( cInputFile ) + Chr(12)
   TokenInit( @cTxtReport, Chr(12) )
   DO WHILE .NOT. TokenEnd()
      cTxtPage := TokenNEXT( cTxtReport ) + HB_EOL()
      IF Len( cTxtPage ) > 5
         IF Substr( cTxtPage, 1, 1 ) == Chr(13)
            cTxtPage := Substr( cTxtPage, 2 )
         ENDIF
         ::AddPage()
         nRow := 0
         DO WHILE At( HB_EOL(), cTxtPage ) != 0
            cTxtLine := Substr( cTxtPage, 1, At( HB_EOL(), cTxtPage ) - 1 )
            cTxtPage := Substr( cTxtPage, At( HB_EOL(), cTxtPage ) + 2 )
            ::DrawText( nRow++, 0, cTxtLine )
         ENDDO
      ENDIF
   ENDDO
   RETURN NIL

METHOD PageHeader() CLASS PDFClass

   ::nPdfPage    += 1
   ::nPageNumber += 1
   ::nRow        := 0
   ::AddPage()
   ::DrawText( 0, 0, "YOU NAME HERE" )
   ::DrawText( 0, ( ::MaxCol() - Len( ::cHeader ) ) / 2, ::cHeader )
   ::DrawText( 0, ::MaxCol() - 12, "Page " + hb_ntos( ::nPageNumber ) )
   ::DrawLine( 0.5, 0, 0.5, ::MaxCol() )
   ::nRow := 2
   ::nCol := 0
   RETURN NIL

METHOD MaxRowTest( nRows ) CLASS PDFClass

   nRows := iif( nRows == NIL, 0, nRows )
   IF ::nRow > ::MaxRow() - 2 - nRows
      ::PageHeader()
   ENDIF
   RETURN NIL

FUNCTION TxtSaida()

   RETURN { "PDF Portrait", "PDF Landscape", "Matrix" }

FUNCTION MyTempFile( cExtensao )

   RETURN "temp." + cExtensao
