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


FUNCTION TxtSaida()

RETURN { "PDF Portrait", "PDF Landscape", "Matrix" }

*----------------------------------------------------------------
#include "pdf.prg"