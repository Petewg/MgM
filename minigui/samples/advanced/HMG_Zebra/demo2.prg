#include "hmg.ch"
#include "hmg_hpdf.ch"

Set Procedure To HMG_Zebra.prg

Function Main()

SELECT HPDFDOC "sample.pdf" PAPERLENGTH 300 PAPERWIDTH 300
SET HPDFDOC ENCODING TO "WinAnsiEncoding"
START HPDFDOC
       
    START HPDFPAGE	

	@10, 10 HPDFPRINT "QRCODE"
	HPDFDrawBarcode(10, 50, "RFC-Emisor|RFC-Receptor|12345.00|20172106-3164-5644-225876345685|", "QRCODE", 4)

    END HPDFPAGE

END HPDFDOC

EXECUTE FILE 'sample.pdf'

Return Nil

*******************************
PROCEDURE HPDFDrawBarcode( nRow, nCol, cCode, cType, nLineWidth, nLineHeight, lShowDigits, lCheckSum, lWide2_5, lWide3 )

   Local hZebra, cTxt, nFlags, nSizeWidth, nSizeHeight, nTextWidth 
   
   Local hPdf        := _HMG_HPDFDATA[ 1 ][ 1 ]
   Local hPage       := _HMG_HPDFDATA[ 1 ][ 7 ]

   Local nWidth      := _HMG_HPDFDATA[ 1 ][ 4 ]
   Local nHeight     := _HMG_HPDFDATA[ 1 ][ 5 ]
   Local nxPos       := _HMG_HPDF_MM2Pixel( nCol )
   Local nyPos       := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   Local cFont       := "Helvetica"
   Local nFontSize   := 9
   Local nTextHeight := 0 

   DEFAULT nLineWidth  := 1
   DEFAULT nLineHeight := 18
   DEFAULT lCheckSum   := .F.
   DEFAULT lWide2_5    := .F.
   DEFAULT lWide3      := .F.
   DEFAULT lShowDigits := .F.

   nFlags := 0
   IF lChecksum
      nFlags := nFlags + HB_ZEBRA_FLAG_CHECKSUM
   ENDIF
   IF lWide2_5
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE2_5
   ENDIF
   IF lWide3
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE3
   ENDIF
      
   IF nFlags == 0
      nFlags := Nil
   ENDIF

   SWITCH cType
   CASE "EAN13"      ; hZebra := hb_zebra_create_ean13( cCode, nFlags )   ; EXIT
   CASE "EAN8"       ; hZebra := hb_zebra_create_ean8( cCode, nFlags )    ; EXIT
   CASE "UPCA"       ; hZebra := hb_zebra_create_upca( cCode, nFlags )    ; EXIT 
   CASE "UPCE"       ; hZebra := hb_zebra_create_upce( cCode, nFlags )    ; EXIT
   CASE "CODE39"     ; hZebra := hb_zebra_create_code39( cCode, nFlags )  ; EXIT
   CASE "ITF"        ; hZebra := hb_zebra_create_itf( cCode, nFlags )     ; EXIT
   CASE "MSI"        ; hZebra := hb_zebra_create_msi( cCode, nFlags )     ; EXIT
   CASE "CODABAR"    ; hZebra := hb_zebra_create_codabar( cCode, nFlags ) ; EXIT
   CASE "CODE93"     ; hZebra := hb_zebra_create_code93( cCode, nFlags )  ; EXIT
   CASE "CODE11"     ; hZebra := hb_zebra_create_code11( cCode, nFlags )  ; EXIT
   CASE "CODE128"    ; hZebra := hb_zebra_create_code128( cCode, nFlags ) ; EXIT
   CASE "PDF417"     ; hZebra := hb_zebra_create_pdf417( cCode, nFlags ); nLineHeight := nLineWidth * 3 ; lShowDigits := .f. ; EXIT
   CASE "DATAMATRIX" ; hZebra := hb_zebra_create_datamatrix( cCode, nFlags ); nLineHeight := nLineWidth ; lShowDigits := .f. ; EXIT
   CASE "QRCODE"     ; hZebra := hb_zebra_create_qrcode( cCode, nFlags ); nLineHeight := nLineWidth ; lShowDigits := .f. ; EXIT
   ENDSWITCH

   IF hZebra != NIL
      IF hb_zebra_geterror( hZebra ) == 0
            	
         IF lShowDigits
         
            cTxt := ALLTRIM(hb_zebra_getcode( hZebra ))
            nSizeWidth  := HMGZebra_GetWidth  (hZebra, nLineWidth, nLineHeight, NIL)
            nSizeHeight := HMGZebra_GetHeight (hZebra, nLineWidth, nLineHeight, NIL)
           
            HPDF_Page_SetFontAndSize( hPage, HPDF_GetFont( hPdf, cFont, NIL ), nFontSize )
            nTextWidth := HPDF_Page_TextWidth( hPage, cTxt )
            nTextHeight:= nFontSize - 1
            HPDF_Page_BeginText( hPage )
            HPDF_Page_TextOut( hPage, (nxPos + ( nSizeWidth / 2 )) - ( nTextWidth / 2 ), nyPos - nSizeHeight, cTxt )
            HPDF_Page_EndText( hPage )         
         ENDIF

         
         hb_zebra_draw_hpdf( hZebra, hPage, nxPos, nyPos, nLineWidth, -(nLineHeight-nTextHeight))
      
      ELSE

         MsgInfo ("Type "+ cType + CRLF +"Code "+ cCode+ CRLF+ "Error  "+LTrim(hb_valtostr(hb_zebra_geterror(hZebra))))

      ENDIF
      hb_zebra_destroy( hZebra )
   ELSE
      MsgStop("Invalid barcode type !", cType)
   ENDIF
   RETURN

***************************************
STATIC FUNCTION hb_zebra_draw_hpdf( hZebra, hPage, ... )

   IF hb_zebra_geterror( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF

   hb_zebra_draw( hZebra, {| x, y, w, h | HPDF_Page_Rectangle( hPage, x, y, w, h ) }, ... )

   HPDF_Page_Fill( hPage )

   RETURN 0 
