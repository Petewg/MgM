/*
 * Proyecto: DemoPdf
 * Fichero: DemoPdf.prg
 * Descripción: Ejemplo de uso de THaruPdf
 * Autor: Carlos Mora
 * Fecha: 06/01/2017
 */

/*
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"

#include "harupdf.ch"

//----------------------------------------------------------------------//
PROCEDURE Main
//----------------------------------------------------------------------//

	DEFINE WINDOW Win_1 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello PDF Report' ;
		WINDOWTYPE MAIN ;
		ONINIT ReciboImprime()

		DEFINE MAIN MENU
			POPUP 'File'
				ITEM 'Exit'	ACTION Win_1.Release
			END POPUP
		END MENU


	END WINDOW

	Win_1.Center
	Win_1.Activate

RETURN

//----------------------------------------------------------------------//
PROCEDURE ReciboImprime( cFileToSave )
//----------------------------------------------------------------------//
   LOCAL oPrint
   LOCAL oFontBold, oFontRed, oFontBig, oFont, oFontMin, oFontPrint, oFontPrintR, oFont2of5

   LOCAL nOffset // En una hoja A4 imprimo 2 copias del mismo comprobante. Esta variable ayuda con el truco
   LOCAL cLetras := 'Tres mil quinientos treinta y cuatro con 10 ctvs.'
   LOCAL lBanco := .F.
   LOCAL nCheque:= 87667676
   LOCAL cBanco := 'NACION'
   LOCAL cSucursal := 'PUENTE LEON'
   LOCAL aConceptos, aObservaciones, i

   IF Empty( cFileToSave )
      cFileToSave := "myharu.pdf"
   ENDIF

   // Configuración de los FONTs a utilizar en la impresión.
   GetHaruFontList()
   HaruAddFont( 'Arial Black', 'ariblk.ttf' )
   HaruAddFont( 'i2of5txt', 'i2of5txt.ttf', .T. )

   // Para tener código que pueda intercambiar TPrinter y THaru es importante
   // separar muy bien la declaración del objeto TPrinter y las fuentes del resto
   // del código de impresión

   oPrint := THaruPdf():New()
   //oPrint:SetCompression( HPDF_COMP_ALL )

   oPrint:cFileName := cFileToSave
   // Define Preview mode
   oPrint:lPreview := .T.

   oFontBold := oPrint:DefineFont( 'Arial Black', 10 )
   oFontBig := oPrint:DefineFont( 'Arial Black', 16 )
   oFont := oPrint:DefineFont( 'Helvetica', 10 )
   oFontRed := oPrint:DefineFont( 'Helvetica', 8 )
   oFontMin := oPrint:DefineFont( 'Helvetica', 6 )
   oFontPrint := oPrint:DefineFont( 'Courier', 10 )
   oFontPrintR := oPrint:DefineFont( 'Courier', 8 )
   oFont2of5 := oPrint:DefineFont( 'i2of5txt', 14, .T. )

   oPrint:StartPage()

   FOR nOffset := 0 TO 14.85 STEP 14.85

      WITH OBJECT oPrint

         // Datos Empresa
         :CmSayBitmap( nOffset + 0.5, 1, 'Logo.png', 3, 3 )
         :CmSay( nOffset + 1.65, 7.0, 'Av. Haru 135', oFont, 5.0,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 2.0, 7.0, 'Tel.: (+34) 618362245', oFont, 5.0,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 2.35, 7.0, '91 040 55 32 ', oFont, 5.0,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 2.7, 7.0, 'C.P.: 28014 - CORDOBA', oFont, 5.0,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 3.7, 3.0, 'I.V.A. RESPONSABLE INSCRIPTO', oFont )

         // Tipo de Comprobante
         :CmRect( nOffset + 0.5, 10, nOffset + 1.5, 11, 0.1 )
         :CmSay( nOffset + 0.6, 10.3, 'B', oFontBig, , , , 0 )
         :CmSay( nOffset + 1.6, 10, 'Código 09', oFontMin, , , , 0 )

         // Numero de comprobante, fecha, inscripciones
         :CmRect( nOffset + 0.5, 13.5, nOffset + 4.0, 20.5, 0.1 )
         :CmLine( nOffset + 2.6, 13.5, nOffset + 2.6, 20.5 )
         :CmRect( nOffset + 1.6, 16.5, nOffset + 2.5, 20.4 )
         :CmSay( nOffset + 1.8, 17.4, DToC( Date() ), oFontPrint )
         :CmSay( nOffset + 0.6, 16.0, 'R E C I B O', oFontBold )
         :CmSay( nOffset + 1.0, 15.2, 'Nº 0001-00001044', oFontBold )
         :CmSay( nOffset + 1.8, 14.0, 'CORDOBA', oFont )

         :CmSay( nOffset + 2.7, 13.8, 'C.U.I.T.: 30-66666666-6', oFontRed )
         :CmSay( nOffset + 3.0, 13.8, 'ING.BRUTOS: 250777777', oFontRed )
         :CmSay( nOffset + 3.3, 13.8, 'C. e I. MUNICIPAL CBA: 30-66666666-6', oFontRed )
         :CmSay( nOffset + 3.6, 13.8, 'Inicio Actividades: 07/03/1994', oFontRed )
         :CmSay( nOffset + 2.7, 20.1, If( nOffset == 0,'ORIGINAL', 'DUPLICADO' ), oFontBold,,,, HPDF_TALIGN_RIGHT )

         // Datos del Cliente
         :CmRect( nOffset + 4.2, 0.5, nOffset + 5, 20.5 )
         :CmSay( nOffset + 4.4, 1.0, 'SEÑOR:', oFont )
         :CmSay( nOffset + 4.35, 2.6, 'Baudilio Cuevas Ibañez', oFontPrint )

         // Categoria IVA del Cliente
         :CmRect( nOffset + 5.0, 0.5, nOffset + 5.8, 20.5 )

         :CmSay( nOffset + 5.2, 1.0, 'A CONSUMIDOR FINAL', oFont )
         :CmRect( nOffset + 5.1, 5.0, nOffset + 5.7, 5.7 )
         :CmSay( nOffset + 5.15, 5.25, 'X', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )

         :CmSay( nOffset + 5.2, 7.0, 'EXENTO', oFont )
         :CmRect( nOffset + 5.1, 9.0, nOffset + 5.7, 9.7 )
         // :CmSay( nOffset + 5.15, 9.35, 'X', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )

         :CmSay( nOffset + 5.2, 12.0, 'C.U.I.T.', oFont )
         :CmRect( nOffset + 5.1, 13.5, nOffset + 5.7, 20.0 )
         // :CmSay( nOffset + 5.15, 14, '20-17078759-6', oFontPrint )

         // Importe en letras
         :CmSay( nOffset + 5.9, 1.0, 'Recibimos la suma de', oFont )
         :CmSay( nOffset + 5.9, 4.8, PadR( AllTrim(MemoLine(cLetras,50,1)), 65, '/'), oFontPrint )
         :CmSay( nOffset + 6.4, 4.8, PadR( AllTrim(MemoLine(cLetras,50,2)), 65, '/'), oFontPrint )

         // Forma de Pago
         :CmRect( nOffset + 7.0, 0.5, nOffset + 8.3, 20.5 )

         :CmRect( nOffset + 7.1, 1.0, nOffset + 7.7, 1.6 )
         :CmSay( nOffset + 7.2, 1.8, 'EFECTIVO', oFontRed )

         :CmRect( nOffset + 7.1, 3.8, nOffset + 7.7, 4.4 )
         IF !Empty( cBanco )
            :CmSay( nOffset + 7.15, 1.25, 'X', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         ELSE
            :CmSay( nOffset + 7.15, 4.1, 'X', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         ENDIF
         :CmSay( nOffset + 7.2, 4.6, 'CON CHEQUE Nº', oFontRed )
         IF !Empty( cBanco )
            :CmSay( nOffset + 7.2, 7.0, LTrim(Str(nCheque)), oFontPrintR )
         ENDIF

         :CmSay( nOffset + 7.2, 9.2, 'C/BANCO', oFontRed )
         IF !Empty( cBanco )
            :CmSay( nOffset + 7.2, 10.6, cBanco, oFontPrintR )
         ENDIF

         :CmSay( nOffset + 7.2, 14.5, 'SUC', oFontRed )
         IF !Empty( cBanco )
            :CmSay( nOffset + 7.2, 15.2, cSucursal, oFontPrintR )
         ENDIF

         :CmSay( nOffset + 7.2, 18.8, 'sujeto a', oFontRed )
         :CmSay( nOffset + 7.8,  1.0, 'acreditación, el que una vez hecho efectivo se aplicará al pago de los conceptos detallados', oFontRed )

         :CmRect( nOffset + 8.5, 0.5, nOffset + 9.8, 20.5 )
         :CmLine( nOffset + 8.9, 0.5, nOffset + 8.9, 20.5 )
         :CmLine( nOffset + 8.5, 4.5, nOffset + 9.8, 4.5 )
         :CmSay( nOffset + 8.55, 2.5, 'Nº Factura', oFontRed, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 9.1, 2.25, 'X 0001-0003401', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         :CmLine( nOffset + 8.5, 8.5, nOffset + 9.8, 8.5 )
         :CmSay( nOffset + 8.55, 6.5, 'Nº Código', oFontRed, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 9.1, 6.5, '04', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         :CmLine( nOffset + 8.5, 12.5, nOffset + 9.8, 12.5 )
         :CmSay( nOffset + 8.55, 10.5, 'Nº Crédito', oFontRed, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 9.1, 10.5, '92104', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         :CmLine( nOffset + 8.5, 16.5, nOffset + 9.8, 16.5 )
         :CmSay( nOffset + 8.55, 14.5, 'Nº Cuota', oFontRed, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 9.1, 14.5, '3 de 10', oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 8.55, 18.5, 'Vencimiento Cuota', oFontRed, 0.7,,, HPDF_TALIGN_CENTER )
         :CmSay( nOffset + 9.1, 18.5, DtoC(Date()), oFontPrint, 0.7,,, HPDF_TALIGN_CENTER )

         // Conpceptos
         :CmSay( nOffset + 10, 1.0, 'Descripción del cobro', oFontRed )
         aConceptos := { { 'Cuota Capital', 100 } ;
            , { 'Cuota Intereses',     6.2 } ;
            , { 'Intereses Moratorios',  1.2 } ;
            , { 'Gastos Recuperados',  0.25 } ;
            , { 'Anticipos a cuenta', 0 } ;
            , { 'Descuento de Intereses', 2 } ;
            , { 'Otros',     0.00 } ;
            }
         FOR i := 1 TO Len( aConceptos )
            :CmSay( nOffset + 10.5 + ( i - 1 ) * 0.43, 1.0, aConceptos[ i ][ 1 ], oFontRed )
            :CmRect( nOffset + 10.4 + ( i - 1 ) * 0.43, 5.0, nOffset + 10.4 + ( i ) * 0.43, 8.5 )
            :CmSay( nOffset + 10.4 + ( i - 1 ) * 0.43, 8.3, Str( aConceptos[ i ][ 2 ],12,2 ), oFontPrintR,,,, HPDF_TALIGN_RIGHT )
         NEXT
         :CmSay( nOffset + 10.5 + ( i - 1 ) * 0.43, 1.0, 'TOTAL', oFontBold )
         :CmRect( nOffset + 10.4 + ( i - 1 ) * 0.43, 5.0, nOffset + 10.6 + ( i ) * 0.43, 8.5, 1.5 )
         :CmSay( nOffset + 10.5 + ( i - 1 ) * 0.43, 8.3, Str( 150.66,12,2 ), oFontBold,,,, HPDF_TALIGN_RIGHT )

         // Observaciones
         aObservaciones := { 'Recuerde que para renovar su crédito' ;
            , 'deberá presentar su último Recibo de Haberes,' ;
            , 'y una boleta de servicios reciente.' ;
            }
         :CmRect( nOffset + 10.4, 8.9, nOffset + 12.9, 16.5, 0.1 )
         FOR i := 1 TO Len( aObservaciones )
            :CmSay( nOffset + 10.5 + ( i - 1 ) * 0.43, 9.0, aObservaciones[ i ], oFontPrintR )
         NEXT

         // Sello
         :CmRect( nOffset + 10.4, 16.9, nOffset + 14.3, 20.5 )
//         :CmSay( nOffset + 10.50, 18.7, 'SELLO', oFont,,,, HPDF_TALIGN_CENTER )
//         :CmSay( nOffset + 11.00, 18.7, 'DE'   , oFont,,,, HPDF_TALIGN_CENTER )
//         :CmSay( nOffset + 11.50, 18.7, 'CAJA' , oFont,,,, HPDF_TALIGN_CENTER )

         // Codigo
         :CmSay( nOffset + 12.9, 8.9, 'CAE: 66110123456789 Vencimiento: '+DToC(Date()), oFontPrintR )
         :CmSay( nOffset + 13.5, 8.9, i2of5Encode( i2Of5('30666666666009000466110123456789'+DtoS(Date()) ) ), oFont2of5 )

      END OBJECT

   NEXT

   oPrint:CmDashLine( 14.85, 0.5, 14.85, 20.5 )
   oPrint:EndPage()

   IF oPrint:End() != 0 // End object and start Preview of PDF
      MsgDebug( "0x" + hb_NumToHex( HPDF_GetError( oPrint:hpdf ), 4 ), ;
                hb_HPDF_GetErrorString( HPDF_GetError( oPrint:hpdf ) ), ;
                HPDF_GetErrorDetail( oPrint:hpdf ) )
   ENDIF

RETURN
