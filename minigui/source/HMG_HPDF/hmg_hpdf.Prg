#include <hmg.ch>
#include "harupdf.ch"

MEMVAR _HMG_HPDFDATA

STATIC DASH_MODE1 := { 3 }
STATIC DASH_MODE2 := { 3, 7 }
STATIC DASH_MODE3 := { 8, 7, 2, 7 }

FUNCTION _HMG_HPDF_INIT ( cPDFFile, nOrientation, nPaperSize, nPaperLength, nPaperWidth )

   DEFAULT nOrientation := 1
   DEFAULT nPaperSize   := 1

   PUBLIC _HMG_HPDFDATA := Array( 1 )

   IF ValType( _HMG_HPDFDATA[ 1 ] ) == 'U'
      _HMG_HPDFDATA[ 1 ] := { ;
         NIL, ;                  // 1 PDF Object
         cPDFFile, ;             // 2 PDF File to Save
         0, ;                    // 3 PDF PaperSize
         0, ;                    // 4 PDF PaperWidth
         0, ;                    // 5 PDF PaperHeight
         nOrientation, ;         // 6 PDF Orientation
         NIL, ;                  // 7 PDF Current Page
         'Helvetica', ;          // 8 PDF default font
         12, ;                   // 9 PDF default fontsize
         "StandardEncoding", ;   // 10 PDF default encoding
         {}, ;                   // 11 PDF Outlines Array
         {}, ;                   // 12 PDF Pages Array
         0, ;                    // 13 PDF Current Page Number
         }
      _HMG_HPDFDATA[ 1 ][ 1 ] := HPDF_New()
      IF _HMG_HPDFDATA[ 1 ][ 1 ] == nil
         _HMG_HPDF_Error( 2 )
         RETURN .F.
      ENDIF
      _HMG_HPDFDATA[ 1 ][ 3 ] := nPaperSize
      IF nPaperSize == 256 // user size
         IF _HMG_HPDFDATA[ 1 ][ 6 ] == 1 // orientation portrait
            _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
            _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
         ELSE // orientation landscape
            _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
            _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
         ENDIF
      ELSE
         _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 1 )
      RETURN .F.
   ENDIF

RETURN .T.

FUNCTION _hmg_hpdf_setencoding( cEncoding )

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   HPDF_SetCurrentEncoder( _HMG_HPDFDATA[ 1 ][ 1 ], cEncoding )
   _HMG_HPDFDATA[ 1 ][ 10 ] := cEncoding

RETURN NIL

FUNCTION _hmg_hpdf_startdoc()

RETURN NIL

FUNCTION _hmg_hpdf_startpage()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := HPDF_AddPage( _HMG_HPDFDATA[ 1 ][ 1 ] )
      IF Empty( _HMG_HPDFDATA[ 1 ][ 7 ] )
         _HMG_HPDF_Error( 9, "Start Page" )
         RETURN NIL
      ELSE
         // add current page to the pages array
         AAdd( _HMG_HPDFDATA[ 1 ][ 12 ], _HMG_HPDFDATA[ 1 ][ 7 ] )
         _HMG_HPDFDATA[ 1 ][ 13 ] := Len( _HMG_HPDFDATA[ 1 ][ 12 ] )
         // set page size
         HPDF_Page_SetWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 5 ] )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 4 )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_InsertPage( nPage )

   LOCAL oOldPage := nil
   LOCAL aPages := AClone( _HMG_HPDFDATA[ 1 ][ 12 ] )

   IF nPage > Len( aPages ) .OR. nPage < 1
      _HMG_HPDF_Error( 16 )
      RETURN NIL
   ENDIF
   oOldPage := aPages[ nPage ]
   IF Empty( oOldPage )
      _HMG_HPDF_Error( 16 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := HPDF_InsertPage( _HMG_HPDFDATA[ 1 ][ 1 ], oOldPage )
      IF Empty( _HMG_HPDFDATA[ 1, 7 ] )
         _HMG_HPDF_Error( 9, "Insert Page" )
         RETURN NIL
      ELSE
         // insert current page to the pages array
         ASize( aPages, Len( aPages ) + 1 )
         AIns( aPages, nPage )
         aPages[ nPage ] := _HMG_HPDFDATA[ 1, 7 ]
         _HMG_HPDFDATA[ 1 ][ 12 ] := AClone( aPages )
         _HMG_HPDFDATA[ 1 ][ 13 ] := nPage
         HPDF_Page_SetWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 5 ] )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 4 )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_GoToPage( nPage )

   LOCAL oPage := nil
   LOCAL aPages := AClone( _HMG_HPDFDATA[ 1 ][ 12 ] )

   IF nPage > Len( aPages ) .OR. nPage < 1
      _HMG_HPDF_Error( 18 )
      RETURN NIL
   ENDIF
   oPage := aPages[ nPage ]
   IF Empty( oPage )
      _HMG_HPDF_Error( 18 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := aPages[ nPage ]
      IF Empty( _HMG_HPDFDATA[ 1, 7 ] )
         _HMG_HPDF_Error( 19 )
         RETURN NIL
      ENDIF
      _HMG_HPDFDATA[ 1 ][ 13 ] := nPage
   ENDIF

RETURN NIL

FUNCTION _hmg_hpdf_endpage()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // Page is free
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ELSE
      _HMG_HPDFDATA[ 1 ][ 7 ] := nil
   ENDIF

RETURN NIL

FUNCTION HMG_HPDF_PageCount()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF

RETURN Len( _HMG_HPDFDATA[ 1 ][ 12 ] )

FUNCTION HMG_HPDF_PageNo()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // Page is free
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

RETURN _HMG_HPDFDATA[ 1 ][ 13 ]

FUNCTION _hmg_hpdf_enddoc()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF HPDF_SaveToFile( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 2 ] ) != 0
      _HMG_HPDF_Error( 20, "End Doc" )
   ENDIF
   HPDF_Free( _HMG_HPDFDATA[ 1 ][ 1 ] )
   _HMG_HPDFDATA[ 1 ] := nil

RETURN NIL

FUNCTION _hmg_hpdf_abortdoc()

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   HPDF_Free( _HMG_HPDFDATA[ 1 ][ 1 ] )
   _HMG_HPDFDATA[ 1 ][ 1 ] := nil

RETURN NIL

FUNCTION _HMG_HPDF_PRINT ( nRow, nCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign, nAngle )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nTextWidth
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont
   LOCAL nRad

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lBold := .F.
   DEFAULT lItalic := .F.
   DEFAULT lUnderline := .F.
   DEFAULT lStrikeout := .F.
   DEFAULT lColor := .F.
   DEFAULT lFont := .F.
   DEFAULT lSize := .F.
   DEFAULT cAlign := ''
   DEFAULT nAngle := 0

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   cFont := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
   IF Len( AllTrim( cFont ) ) == 0
      _HMG_HPDF_Error( 6, cFontName )
      RETURN NIL
   ELSE
      IF Upper( AllTrim( cFont ) ) == "SYMBOL" .OR. Upper( AllTrim( cFont ) ) == "ZAPFDINGBATS"
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, Nil )
      ELSE
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 )
      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      IF nAngle == 0
         DO CASE
         CASE Upper( AllTrim( cAlign ) ) == 'CENTER'
            nxPos -= ( nTextWidth / 2 )
         CASE Upper( AllTrim( cAlign ) ) == 'RIGHT'
            nxPos -= ( nTextWidth )
         ENDCASE
      ELSEIF nAngle == 90
         DO CASE
         CASE Upper( AllTrim( cAlign ) ) == 'CENTER'
            nyPos -= ( nTextWidth / 2 )
         CASE Upper( AllTrim( cAlign ) ) == 'RIGHT'
            nyPos -= ( nTextWidth )
         ENDCASE
      ENDIF
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      IF nAngle != 0
         nRad := nAngle / 180 * 3.141592    /* Calcurate the radian value. */
         HPDF_Page_SetTextMatrix( _HMG_HPDFDATA[ 1 ][ 7 ], cos( nRad ), sin( nRad ), -sin( nRad ), cos( nRad ), nxPos, nyPos )
      ENDIF
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      IF lStrikeout .OR. lUnderline
         HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
         IF lColor
            HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
         ELSE
            HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
         ENDIF
         nyPos += IF( lUnderline, -1, _HMG_HPDF_Pixel2MM( nFontSize ) / 2 + 1 )
         HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
         HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nTextWidth, nyPos )
         HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
      ENDIF
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_MULTILINE_PRINT ( nRow, nCol, nToRow, nToCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign, nAngle )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nTextWidth
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL nxPosLin
   LOCAL nyPosLin
   LOCAL oFont := Nil
   LOCAL cFont
   LOCAL nRad
   LOCAL nLLen
   LOCAL nLin
   LOCAL hLin

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lBold := .F.
   DEFAULT lItalic := .F.
   DEFAULT lUnderline := .F.
   DEFAULT lStrikeout := .F.
   DEFAULT lColor := .F.
   DEFAULT lFont := .F.
   DEFAULT lSize := .F.
   DEFAULT cAlign := ''
   DEFAULT nAngle := 0
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   cFont := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
   IF Len( AllTrim( cFont ) ) == 0
      _HMG_HPDF_Error( 6 )
      RETURN NIL
   ELSE
      IF Upper( AllTrim( cFont ) ) == "SYMBOL" .OR. Upper( AllTrim( cFont ) ) == "ZAPFDINGBATS"
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, Nil )
      ELSE
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 )
      RETURN NIL
   ELSE
      IF nAngle != 0
         nRad := nAngle / 180 * 3.141592   /* Calcurate the radian value. */
         HPDF_Page_GSave ( _HMG_HPDFDATA[ 1 ][ 7 ] )
         HPDF_Page_Concat ( _HMG_HPDFDATA[ 1 ][ 7 ],  cos( nRad ), sin( nRad ), -sin( nRad ), cos( nRad ), nxPos, nyPos )

         HPDF_Page_BeginText ( _HMG_HPDFDATA[ 1 ][ 7 ] )
         HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
         DO CASE
         CASE Upper( cAlign ) == 'CENTER'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], 0, 0, nToxPos - nxPos, nToyPos - nyPos, cText, HPDF_TALIGN_CENTER, NIL )
         CASE Upper( cAlign ) == 'RIGHT'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], 0, 0, nToxPos - nxPos, nToyPos - nyPos, cText, HPDF_TALIGN_RIGHT, NIL )
         CASE Upper( cAlign ) == 'JUSTIFY'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], 0, 0, nToxPos - nxPos, nToyPos - nyPos, cText, HPDF_TALIGN_JUSTIFY, NIL )
         OTHERWISE
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], 0, 0, nToxPos - nxPos, nToyPos - nyPos, cText, HPDF_TALIGN_LEFT, NIL )
         ENDCASE
         HPDF_Page_EndText ( _HMG_HPDFDATA[ 1 ][ 7 ] )
         HPDF_Page_GRestore ( _HMG_HPDFDATA[ 1 ][ 7 ] )
      ELSE
         HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
         HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
         DO CASE
         CASE Upper( cAlign ) == 'CENTER'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_CENTER, NIL )
         CASE Upper( cAlign ) == 'RIGHT'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_RIGHT, NIL )
         CASE Upper( cAlign ) == 'JUSTIFY'
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_JUSTIFY, NIL )
         OTHERWISE
            HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_LEFT, NIL )
         ENDCASE
         HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
         IF lStrikeout .OR. lUnderline
            HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
            IF lColor
               HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
            ELSE
               HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
            ENDIF
            hLin := HPDF_Page_GetTextLeading  ( _HMG_HPDFDATA[ 1 ][ 7 ] )
            nLin := 1
            nyPos += IF( lUnderline, 2, _HMG_HPDF_Pixel2MM( nFontSize ) / 2 + 3 )
            nxPosLin := nxPos

            WHILE  ( nLLen := HPDF_Page_MeasureText ( _HMG_HPDFDATA[ 1 ][ 7 ], cText, _HMG_HPDF_MM2Pixel( nToCol - nCol ), HPDF_TRUE ) ) > 1
               nyPosLin := nyPos - nLin * hLin
               nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], SubStr( cText, 1, nLLen - 1 ) )
               cText := LTrim( SubStr( cText, nLLen ) )
               DO CASE
               CASE Upper( AllTrim( cAlign ) ) == 'CENTER'
                  nxPosLin := nxPos + ( ( nToxPos - nxPos ) - nTextWidth  ) / 2
               CASE Upper( AllTrim( cAlign ) ) == 'RIGHT'
                  nxPosLin := nxPos + ( ( nToxPos - nxPos ) - nTextWidth )
               CASE Upper( AllTrim( cAlign ) ) == 'JUSTIFY'
                  IF HPDF_Page_MeasureText ( _HMG_HPDFDATA[ 1 ][ 7 ], cText, _HMG_HPDF_MM2Pixel( nToCol - nCol ), HPDF_TRUE ) > 1
                     nTextWidth := nToxPos - nxPos
                  ENDIF
               ENDCASE
               HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPosLin, nyPosLin )
               HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPosLin + nTextWidth, nyPosLin )
               HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
               nLin++
            ENDDO
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_IMAGE ( cImage, nRow, nCol, nImageheight, nImageWidth, lStretch )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oImage, cExt

   DEFAULT lStretch := .F.
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF
   IF File( cImage )
      hb_FNameSplit( cImage, , , @cExt )
      IF Upper( cExt ) == '.PNG'
         oImage := HPDF_LoadPngImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )
      ELSE
         oImage := HPDF_LoadJPEGImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )
      ENDIF
   ELSE
      _HMG_HPDF_Error( 7 )
      RETURN NIL
   ENDIF
   IF Empty( oImage )
      _HMG_HPDF_Error( 7 )
      RETURN NIL
   ENDIF
   HPDF_Page_DrawImage( _HMG_HPDFDATA[ 1 ][ 7 ], oImage, nxPos, nyPos - _HMG_HPDF_MM2Pixel( nImageHeight ), _HMG_HPDF_MM2Pixel( nImageWidth ), _HMG_HPDF_MM2Pixel( nImageHeight ) )

RETURN NIL

FUNCTION _HMG_HPDF_LINE ( nRow, nCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )

RETURN NIL

FUNCTION _HMG_HPDF_RECTANGLE ( nRow, nCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.
   DEFAULT lFilled := .F.

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Rectangle( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow ), _HMG_HPDF_MM2Pixel( nToCol - nCol ), _HMG_HPDF_MM2Pixel( nToRow - nRow ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_ROUNDRECTANGLE ( nRow, nCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled, nRoundness )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL nRectWidth := nToCol - nCol
   LOCAL nRectHeight := nToRow - nRow

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.
   DEFAULT lFilled := .F.
   DEFAULT nRoundness := 0
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF
   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   IF nRoundness == 0
      nRoundness := Int( Min( nRectWidth, nRectHeight ) * 10 / 100 )
   ELSE
      IF nRoundness > Int( Min( nRectWidth, nRectHeight ) / 2 )
         _HMG_HPDF_Error( 8 )
         RETURN NIL
      ENDIF
   ENDIF

   nRoundness := _HMG_HPDF_MM2Pixel( nRoundness )

   // start rounded rectangle path
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nRoundness, nyPos )  // top line left position
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos - nRoundness, nyPos ) // draw top line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nyPos, nToxPos, nyPos - nRoundness ) // draw top right curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nToyPos + nRoundness ) // draw right line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nToyPos, nToxPos - nRoundness, nToyPos ) // draw bottom right curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nRoundness, nToyPos ) // draw bottom line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nToyPos, nxPos, nToyPos + nRoundness ) // draw bottom left curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos - nRoundness ) // draw left line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nxPos + nRoundness, nyPos ) // draw top left curve

   // now start and finish drawing along the path
   IF lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_CIRCLE( nRow, nCol, nR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.
   DEFAULT lFilled := .F.
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Circle( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, _HMG_HPDF_MM2Pixel( nR ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_ELLIPSE( nRow, nCol, nHR, nVR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.
   DEFAULT lFilled := .F.
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      IF lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
      ENDIF
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Ellipse( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, _HMG_HPDF_MM2Pixel( nHR ), _HMG_HPDF_MM2Pixel( nVR ) )
   IF lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ELSE
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_ARC( nRow, nCol, nR, nFromAngle, nToAngle, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )

   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF
   // set line Width
   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_Arc( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, _HMG_HPDF_MM2Pixel( nR ), nFromAngle, nToAngle )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )

RETURN NIL

FUNCTION _HMG_HPDF_CURVE ( nRow, nCol, nFromRow, nFromCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL nFromxPos := _HMG_HPDF_MM2Pixel( nFromCol )
   LOCAL nFromyPos := nHeight - _HMG_HPDF_MM2Pixel( nFromRow )

   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT nLineWidth := 1
   DEFAULT lWidth := .F.
   DEFAULT lColor := .F.

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   IF lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   ELSE
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   ENDIF
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nFromxPos, nFromyPos, nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )

RETURN NIL

FUNCTION _HMG_HPDF_SetPassword( cOwnerPass, cUserPass )

   DEFAULT cUserPass := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   HPDF_SetPassword( _HMG_HPDFDATA[ 1 ][ 1 ], cOwnerPass, cUserPass )

RETURN NIL

FUNCTION _HMG_HPDF_SetCompression( cMode )

   DEFAULT cMode := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   cMode := Upper( cMode )
   DO CASE
   CASE cMode == 'NONE'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_NONE )
   CASE cMode == 'TEXT'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_TEXT )
   CASE cMode == 'IMAGE'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_IMAGE )
   CASE cMode == 'METADATA'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_METADATA )
   CASE cMode == 'ALL'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_ALL )
   OTHERWISE
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_NONE )
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_SetPermission( cMode )

   DEFAULT cMode := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   cMode := Upper( cMode )
   DO CASE
   CASE cMode == 'READ'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_READ )
   CASE cMode == 'PRINT'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_PRINT )
   CASE cMode == 'COPY'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_COPY )
   CASE cMode == 'EDIT'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_EDIT )
   CASE cMode == 'EDIT_ALL'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_EDIT_ALL )
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_SetPageMode( cMode )

   DEFAULT cMode := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   cMode := Upper( cMode )
   DO CASE
   CASE cMode == 'OUTLINE'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_OUTLINE )
   CASE cMode == 'NONE'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_NONE )
   CASE cMode == 'THUMBS'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_THUMBS )
   CASE cMode == 'FULL_SCREEN'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_FULL_SCREEN )
   CASE cMode == 'EOF'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_EOF )
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_RootOutline( cTitle, cName, cParent )

   LOCAL aOutlines
   LOCAL oOutline, i

   DEFAULT cParent := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF Len( AllTrim( cTitle ) ) == 0
      _HMG_HPDF_Error( 11 )
      RETURN NIL
   ENDIF
   IF Len( AllTrim( cName ) ) == 0
      _HMG_HPDF_Error( 12 )
      RETURN NIL
   ENDIF
   IF Len( AllTrim( cParent ) ) == 0 // make this a root outline
      oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      IF Empty( oOutLine )
         _HMG_HPDF_Error( 10 )
         RETURN NIL
      ELSE
         AAdd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
      ENDIF
   ELSE
      aOutLines := AClone( _HMG_HPDFDATA[ 1 ][ 11 ] )
      FOR i := 1 TO Len( aOutLines )
         IF Upper( AllTrim( aOutLines[ i, 2 ] ) ) == Upper( AllTrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], aOutLines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            IF Empty( oOutLine )
               _HMG_HPDF_Error( 10 )
               RETURN NIL
            ELSE
               AAdd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
            ENDIF
            EXIT
         ENDIF
      NEXT i
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_PageOutline( cTitle, cParent, cName )

   LOCAL aOutlines
   LOCAL oOutline, i
   LOCAL oDestination

   DEFAULT cParent := ''
   DEFAULT cName := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF
   oDestination := HPDF_Page_CreateDestination( _HMG_HPDFDATA[ 1 ][ 7 ] )
   IF Empty( oDestination )
      _HMG_HPDF_Error( 13 )
      RETURN NIL
   ENDIF
   IF Len( AllTrim( cParent ) ) == 0 // No parent make this page root element
      oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      IF Empty( oOutline )
         _HMG_HPDF_Error( 13 )
         RETURN NIL
      ENDIF
   ELSE
      aOutlines := AClone( _HMG_HPDFDATA[ 1 ][ 11 ] )
      FOR i := 1 TO Len( aOutlines )
         IF Upper( AllTrim( aOutlines[ i, 2 ] ) ) == Upper( AllTrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], aOutlines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            EXIT
         ENDIF
      NEXT i
      IF Empty( oOutline )
         _HMG_HPDF_Error( 14 )
         RETURN NIL
      ENDIF
   ENDIF
   IF Len( AllTrim( cName ) ) > 0
      AAdd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
   ENDIF
   HPDF_Outline_SetDestination( oOutline, oDestination )

RETURN NIL

FUNCTION _HMG_HPDF_SetTextAnnot( nRow, nCol, cToolTip, cIcon )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nToRow := nRow + 5
   LOCAL nToCol := nCol + 5
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   LOCAL nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   LOCAL aRect := { nxPos, nyPos, nToxPos, nToyPos }
   LOCAL oAnnot := nil

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF
   oAnnot := HPDF_Page_CreateTextAnnot ( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, cTooltip, HPDF_GetCurrentEncoder() )
   IF Empty( oAnnot )
      _HMG_HPDF_Error( 15 )
      RETURN NIL
   ENDIF
   DO CASE
   CASE Upper( AllTrim( cIcon ) ) == "COMMENT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_COMMENT )
   CASE Upper( AllTrim( cIcon ) ) == "KEY"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_KEY )
   CASE Upper( AllTrim( cIcon ) ) == "NOTE"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NOTE )
   CASE Upper( AllTrim( cIcon ) ) == "HELP"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_HELP )
   CASE Upper( AllTrim( cIcon ) ) == "NEW_PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NEW_PARAGRAPH )
   CASE Upper( AllTrim( cIcon ) ) == "PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_PARAGRAPH )
   CASE Upper( AllTrim( cIcon ) ) == "INSERT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_INSERT )
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_SetPageLink( nRow, nCol, cText, nPage, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize, lBorder, lWidth, nBorderWidth )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nTextWidth
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont
   LOCAL aRect
   LOCAL oAnnot := nil
   LOCAL oDest := nil
   LOCAL aPages
   LOCAL oLinkPage := nil

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lColor := .F.
   DEFAULT lFont := .F.
   DEFAULT lSize := .F.
   DEFAULT cAlign := ''
   DEFAULT lBorder := .F.
   DEFAULT lWidth := .F.
   DEFAULT nBorderWidth := 0

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   aPages := AClone( _HMG_HPDFDATA[ 1 ][ 12 ] )
   IF nPage > Len( aPages ) .OR. nPage < 1
      _HMG_HPDF_Error( 17 )
      RETURN NIL
   ENDIF

   oLinkPage := aPages[ nPage ]
   IF Empty( oLinkPage )
      _HMG_HPDF_Error( 17 )
      RETURN NIL
   ENDIF
   oDest := HPDF_Page_CreateDestination( oLinkPage )
   IF Empty( oDest )
      _HMG_HPDF_Error( 17 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF Len( AllTrim( cFontName ) ) == 0
      oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 8 ], _HMG_HPDFDATA[ 1 ][ 10 ] )
   ELSE
      cFontName := AllTrim( cFontName )
      IF Upper( SubStr( cFontName, Len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .T. )
         IF Len( AllTrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 )
            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      ELSE
         IF Upper( AllTrim( cFontName ) ) == "SYMBOL" .OR. Upper( AllTrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, _HMG_HPDFDATA[ 1 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 )
      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      DO CASE
      CASE Upper( AllTrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      CASE Upper( AllTrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      ENDCASE
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      oAnnot := HPDF_Page_CreateLinkAnnot( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, oDest )
      IF lBorder
         IF nBorderWidth == 0
            nBorderWidth := 1
         ELSE
            nBorderWidth := _HMG_HPDF_MM2Pixel( nBorderWidth )
         ENDIF
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, nBorderWidth, 0, 0 )
      ELSE
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, 0, 0, 0 )
      ENDIF
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_SetURLLink( nRow, nCol, cText, cLink, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize  )

   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nTextWidth
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oFont := Nil
   LOCAL cFont
   LOCAL aRect
   LOCAL oAnnot := nil

   DEFAULT cFontName := ''
   DEFAULT nFontSize := 12
   DEFAULT nRColor := 0
   DEFAULT nGColor := 0
   DEFAULT nBColor := 0
   DEFAULT lColor := .F.
   DEFAULT lFont := .F.
   DEFAULT lSize := .F.
   DEFAULT cAlign := ''

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF

   // set color
   IF lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor / 255, nGColor / 255, nBColor / 255 )
   ELSE
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   ENDIF

   // set font
   IF Len( AllTrim( cFontName ) ) == 0
      oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 8 ], _HMG_HPDFDATA[ 1 ][ 10 ] )
   ELSE
      cFontName := AllTrim( cFontName )
      IF Upper( SubStr( cFontName, Len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .T. )
         IF Len( AllTrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 )
            RETURN NIL
         ENDIF
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      ELSE
         IF Upper( AllTrim( cFontName ) ) == "SYMBOL" .OR. Upper( AllTrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, Nil )
         ELSE
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, _HMG_HPDFDATA[ 1 ][ 10 ] )
         ENDIF
      ENDIF
   ENDIF
   IF oFont == Nil
      _HMG_HPDF_Error( 6 )
      RETURN NIL
   ELSE
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      DO CASE
      CASE Upper( AllTrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      CASE Upper( AllTrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      ENDCASE
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      HPDF_Page_CreateURILinkAnnot( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, cLink )
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_SetLineSpacing( nSpacing )

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == NIL // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      RETURN NIL
   ENDIF
   HPDF_Page_SetTextLeading( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nSpacing ) )

RETURN NIL

FUNCTION _HMG_HPDF_SetInfo( cAttrib, xValue, cTime )

   LOCAL cValue := ''
   LOCAL dValue := ''
   LOCAL nHours := 0
   LOCAL nMinutes := 0
   LOCAL nSeconds := 0

   DEFAULT cTime := ''
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   DO CASE
   CASE ValType( xValue ) == 'D'
      dValue := xValue
   OTHERWISE
      cValue := xValue
   ENDCASE
   DO CASE
   CASE Upper( AllTrim( cAttrib ) ) == "AUTHOR"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_AUTHOR, cValue )
   CASE Upper( AllTrim( cAttrib ) ) == "CREATOR"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATOR, cValue )
   CASE Upper( AllTrim( cAttrib ) ) == "TITLE"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_TITLE, cValue )
   CASE Upper( AllTrim( cAttrib ) ) == "SUBJECT"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_SUBJECT, cValue )
   CASE Upper( AllTrim( cAttrib ) ) == "KEYWORDS"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_KEYWORDS, cValue )
   CASE Upper( AllTrim( cAttrib ) ) == "DATECREATED"
      IF Len( AllTrim( cTime ) ) > 0
         nHours := Val( SubStr( cTime, 1, 2 ) )
         nMinutes := Val( SubStr( cTime, 4, 2 ) )
         nSeconds := Val( SubStr( cTime, 7, 2 ) )
      ENDIF
      HPDF_SetInfoDateAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATION_DATE, { Year( dValue ), Month( dVAlue ), Day( dValue ), nHours, nMinutes, nSeconds } )
   CASE Upper( AllTrim( cAttrib ) ) == "DATEMODIFIED"
      IF Len( AllTrim( cTime ) ) > 0
         nHours := Val( SubStr( cTime, 1, 2 ) )
         nMinutes := Val( SubStr( cTime, 4, 2 ) )
         nSeconds := Val( SubStr( cTime, 7, 2 ) )
      ENDIF
      HPDF_SetInfoDateAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_MOD_DATE, { Year( dValue ), Month( dVAlue ), Day( dValue ), nHours, nMinutes, nSeconds } )
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_GetInfo( cAttrib )

   LOCAL cRetValue := '', bd, bc

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   DO CASE
   CASE Upper( AllTrim( cAttrib ) ) == "AUTHOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_AUTHOR )
   CASE Upper( AllTrim( cAttrib ) ) == "CREATOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATOR )
   CASE Upper( AllTrim( cAttrib ) ) == "TITLE"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_TITLE )
   CASE Upper( AllTrim( cAttrib ) ) == "SUBJECT"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_SUBJECT )
   CASE Upper( AllTrim( cAttrib ) ) == "KEYWORDS"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_KEYWORDS )
   CASE Upper( AllTrim( cAttrib ) ) == "DATECREATED"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATION_DATE )
   CASE Upper( AllTrim( cAttrib ) ) == "DATEMODIFIED"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_MOD_DATE )
   ENDCASE
   IF Left( cRetValue, 2 ) == "D:"
      bd := Set( _SET_DATEFORMAT )
      bc := __SetCentury( .T. )
      SET DATE german
      cRetValue := DToC( SToD( SubStr( cRetValue, 3, 8 ) ) ) + " " + SubStr( cRetValue, 11, 2 ) + ":" + SubStr( cRetValue, 13, 2 ) + ":" + SubStr( cRetValue, 15, 2 )
      __SetCentury( bc )
      SET( _SET_DATEFORMAT, bd )
   ENDIF

RETURN cRetValue

FUNCTION _HMG_HPDF_SetPageLabel( nPage, cStyle, cCase, cPrefix )

   DEFAULT cCase := ""
   DEFAULT cStyle := "DECIMAL"
   DEFAULT nPage := 1
   DEFAULT cPrefix := ""
   IF _HMG_HPDFDATA[ 1 ][ 1 ] == NIL // PDF object not found!
      _HMG_HPDF_Error( 3 )
      RETURN NIL
   ENDIF
   DO CASE
   CASE Upper( AllTrim( cStyle ) ) == "DECIMAL"
      HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_DECIMAL, nPage, cPrefix )
   CASE Upper( AllTrim( cStyle ) ) == "ROMAN"
      IF Upper( AllTrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_ROMAN, nPage, cPrefix )
      ELSE
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_ROMAN, nPage, cPrefix )
      ENDIF
   CASE Upper( AllTrim( cStyle ) ) == "LETTERS"
      IF Upper( AllTrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_LETTERS, nPage, cPrefix )
      ELSE
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_LETTERS, nPage, cPrefix )
      ENDIF
   ENDCASE

RETURN NIL

FUNCTION _HMG_HPDF_Error( nErr, cExtraInfo )

   LOCAL cErr := ''

   DEFAULT cExtraInfo TO ''
   DO CASE
   CASE nErr == 1
      cErr := 'A PDF document is already initiated.'
   CASE nErr == 2
      cErr := 'PDF document cannot be initialized.'
   CASE nErr == 3
      cErr := 'PDF PAGE cannot be added. PDF document cannot be found.'
   CASE nErr == 4
      cErr := 'A PDF PAGE is already initiated.'
   CASE nErr == 5
      cErr := 'PDF PAGE cannot be found.'
   CASE nErr == 6
      cErr := 'Font cannot be loaded.'
   CASE nErr == 7
      cErr := 'Image cannot be loaded.'
   CASE nErr == 8
      cErr := 'Round curve can not be longer than half of the width/height.'
   CASE nErr == 9
      cErr := 'Can not start new page.'
   CASE nErr == 10
      cErr := 'Can not create new parent outline.'
   CASE nErr == 11
      cErr := 'Outline Title is not valid.'
   CASE nErr == 12
      cErr := 'Outline Name is not valid.'
   CASE nErr == 13
      cErr := 'Can not create Page Outline.'
   CASE nErr == 14
      cErr := 'Can not find Parent Node.'
   CASE nErr == 15
      cErr := 'Tooltip creation error!'
   CASE nErr == 16
      cErr := 'Page not found. New page can not be inserted.'
   CASE nErr == 17
      cErr := 'Link Page not found.'
   CASE nErr == 18
      cErr := 'Selected Page can not be found.'
   CASE nErr == 19
      cErr := 'Page Selection error!'
   CASE nErr == 20
      cErr := 'Pdf creation error!'
   ENDCASE
   cErr += CRLF + cExtraInfo
   msgstop( cErr )

RETURN NIL

FUNCTION _HMG_HPDF_Inch2Pixel( nInches )
RETURN ( nInches * 72 )

FUNCTION _HMG_HPDF_Pixel2Inch( nPixels )
RETURN ( nPixels / 72 )

FUNCTION _HMG_HPDF_MM2Pixel( nMM )
RETURN ( ( nMM / 25.4 ) * 72 )

FUNCTION _HMG_HPDF_Pixel2MM( nPixel )
RETURN ( ( nPixel / 72 ) * 25.4 )

FUNCTION _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )

   LOCAL nTemp

   DO CASE
   CASE nPaperSize == 1 .OR. nPaperSize == -999 // HPDF_PAPER_LETTER or default
      _HMG_HPDFDATA[ 1 ][ 4 ] := 612
      _HMG_HPDFDATA[ 1 ][ 5 ] := 792
   CASE nPaperSize == 2 // HPDF_PAPER_LETTERSMALL
      _HMG_HPDFDATA[ 1 ][ 4 ] := 612
      _HMG_HPDFDATA[ 1 ][ 5 ] := 792
   CASE nPaperSize == 3 // HPDF_PAPER_TABLOID
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   CASE nPaperSize == 4 // HPDF_PAPER_LEDGER
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 5 // HPDF_PAPER_LEGAL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 14 )
   CASE nPaperSize == 6 // HPDF_PAPER_STATEMENT
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 7 // HPDF_PAPER_EXECUTIVE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 8 // HPDF_PAPER_A3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   CASE nPaperSize == 9 // HPDF_PAPER_A4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 10 // HPDF_PAPER_A4SMALL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 11 // HPDF_PAPER_A5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 12 // HPDF_PAPER_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 354 )
   CASE nPaperSize == 13 // HPDF_PAPER_B5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 185 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 14 // HPDF_PAPER_FOLIO
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   CASE nPaperSize == 15 // HPDF_PAPER_QUARTO
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 275 )
   CASE nPaperSize == 16 // HPDF_PAPER_10X14
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 140 )
   CASE nPaperSize == 17 // HPDF_PAPER_11X17
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   CASE nPaperSize == 18 // HPDF_PAPER_NOTE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 19 // HPDF_PAPER_ENV_9
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + ( 7 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8 + ( 7 / 8 ) )
   CASE nPaperSize == 20 // HPDF_PAPER_ENV_10
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4 + ( 1 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
   CASE nPaperSize == 21 // HPDF_PAPER_ENV_11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 10 + ( 3 / 8 ) )
   CASE nPaperSize == 22 // HPDF_PAPER_ENV_12
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.75 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 23 // HPDF_PAPER_ENV_14
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11.5 )
   CASE nPaperSize == 24 // HPDF_PAPER_CSHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 22 )
   CASE nPaperSize == 25 // HPDF_PAPER_DSHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 22 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 34 )
   CASE nPaperSize == 26 // HPDF_PAPER_ESHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 34 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 44 )
   CASE nPaperSize == 27 // HPDF_PAPER_ENV_DL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 28 // HPDF_PAPER_ENV_C5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 162 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 29 // HPDF_PAPER_ENV_C3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   CASE nPaperSize == 30 // HPDF_PAPER_ENV_C4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   CASE nPaperSize == 31 // HPDF_PAPER_ENV_C6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 162 )
   CASE nPaperSize == 32 // HPDF_PAPER_ENV_C65
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 33 // HPDF_PAPER_ENV_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   CASE nPaperSize == 34 // HPDF_PAPER_ENV_B5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 250 )
   CASE nPaperSize == 35 // HPDF_PAPER_ENV_B6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   CASE nPaperSize == 36 // HPDF_PAPER_ENV_ITALY
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 37 // HPDF_PAPER_ENV_MONARCH
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3.875 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 7.5 )
   CASE nPaperSize == 38 // HPDF_PAPER_ENV_PERSONAL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + ( 5 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 6.5 )
   CASE nPaperSize == 39 // HPDF_PAPER_FANFOLD_US
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 14 + ( 7 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 40 // HPDF_PAPER_FANFOLD_STD_GERMAN
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 41 // HPDF_PAPER_FANFOLD_LGL_GERMAN
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   CASE nPaperSize == 42 // HPDF_PAPER_ISO_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   CASE nPaperSize == 43 // HPDF_PAPER_JAPANESE_POSTCARD
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 100 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 44 // HPDF_PAPER_9X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 45 // HPDF_PAPER_10X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 46 // HPDF_PAPER_15X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 15 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 47 // HPDF_PAPER_ENV_INVITE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 48 // HPDF_PAPER_RESERVED_48
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 49 // HPDF_PAPER_RESERVED_49
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 50 // HPDF_PAPER_LETTER_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 51 // HPDF_PAPER_LEGAL_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 15 )
   CASE nPaperSize == 52 // HPDF_PAPER_TABLOID_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11.69 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 18 )
   CASE nPaperSize == 53 // HPDF_PAPER_A4_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.27 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   CASE nPaperSize == 54 // HPDF_PAPER_LETTER_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 55 // HPDF_PAPER_A4_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 56 // HPDF_PAPER_LETTER_EXTRA_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   CASE nPaperSize == 57 // HPDF_PAPER_A_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 227 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 356 )
   CASE nPaperSize == 58 // HPDF_PAPER_B_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 305 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 487 )
   CASE nPaperSize == 59 // HPDF_PAPER_LETTER_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   CASE nPaperSize == 60 // HPDF_PAPER_A4_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 330 )
   CASE nPaperSize == 61 // HPDF_PAPER_A5_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 62 // HPDF_PAPER_B5_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 63 // HPDF_PAPER_A3_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   CASE nPaperSize == 64 // HPDF_PAPER_A5_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 174 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 65 // HPDF_PAPER_B5_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 201 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 276 )
   CASE nPaperSize == 66 // HPDF_PAPER_A2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 594 )
   CASE nPaperSize == 67 // HPDF_PAPER_A3_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   CASE nPaperSize == 68 // HPDF_PAPER_A3_EXTRA_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   CASE nPaperSize == 69 // HPDF_PAPER_DBL_JAPANESE_POSTCARD
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 200 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 70 // HPDF_PAPER_A6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 71 // HPDF_PAPER_JENV_KAKU2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 240 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 332 )
   CASE nPaperSize == 72 // HPDF_PAPER_JENV_KAKU2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 216 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 277 )
   CASE nPaperSize == 73 // HPDF_PAPER_JENV_CHOU3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 74 // HPDF_PAPER_JENV_CHOU4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 90 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 205 )
   CASE nPaperSize == 75 // HPDF_PAPER_LETTER_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   CASE nPaperSize == 76 // HPDF_PAPER_A3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   CASE nPaperSize == 77 // HPDF_PAPER_A4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   CASE nPaperSize == 78 // HPDF_PAPER_A5_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   CASE nPaperSize == 79 // HPDF_PAPER_B4_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 364 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   CASE nPaperSize == 80 // HPDF_PAPER_B5_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 257 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   CASE nPaperSize == 81 // HPDF_PAPER_B5_JAPANESE_POSTCARD_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 100 )
   CASE nPaperSize == 82 // HPDF_PAPER_B5_DBL_JAPANESE_POSTCARD_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 200 )
   CASE nPaperSize == 83 // HPDF_PAPER_A6_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   CASE nPaperSize == 84 // HPDF_PAPER_JENV_KAKU2_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 332 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 240 )
   CASE nPaperSize == 85 // HPDF_PAPER_JENV_KAKU3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 277 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 216 )
   CASE nPaperSize == 86 // HPDF_PAPER_JENV_CHOU3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 87 // HPDF_PAPER_JENV_CHOU4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 205 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 90 )
   CASE nPaperSize == 88 // HPDF_PAPER_B6_JIS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 128 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   CASE nPaperSize == 89 // HPDF_PAPER_B6_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 128 )
   CASE nPaperSize == 90 // HPDF_PAPER_12X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 12 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   CASE nPaperSize == 91 // HPDF_PAPER_JENV_YOU4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   CASE nPaperSize == 92 // HPDF_PAPER_JENV_YOU4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   CASE nPaperSize == 93 // HPDF_PAPER_P16K
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 146 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 215 )
   CASE nPaperSize == 94 // HPDF_PAPER_P32K
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   CASE nPaperSize == 95 // HPDF_PAPER_P32KBIG
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   CASE nPaperSize == 96 // HPDF_PAPER_PENV_1
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 165 )
   CASE nPaperSize == 97 // HPDF_PAPER_PENV_2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   CASE nPaperSize == 98 // HPDF_PAPER_PENV_3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 125 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   CASE nPaperSize == 99 // HPDF_PAPER_PENV_4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   CASE nPaperSize == 100 // HPDF_PAPER_PENV_5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   CASE nPaperSize == 101 // HPDF_PAPER_PENV_6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 102 // HPDF_PAPER_PENV_7
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 160 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   CASE nPaperSize == 103 // HPDF_PAPER_PENV_8
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   CASE nPaperSize == 104 // HPDF_PAPER_PENV_9
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   CASE nPaperSize == 105 // HPDF_PAPER_PENV_10
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   CASE nPaperSize == 106 // HPDF_PAPER_P16K_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 146 )
   CASE nPaperSize == 107 // HPDF_PAPER_P32K_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   CASE nPaperSize == 108 // HPDF_PAPER_P32KBIG_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   CASE nPaperSize == 109 // HPDF_PAPER_PENV_1_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 165 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   CASE nPaperSize == 110 // HPDF_PAPER_PENV_2_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   CASE nPaperSize == 111 // HPDF_PAPER_PENV_3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   CASE nPaperSize == 112 // HPDF_PAPER_PENV_4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 208 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   CASE nPaperSize == 113 // HPDF_PAPER_PENV_5_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   CASE nPaperSize == 114 // HPDF_PAPER_PENV_6_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 115 // HPDF_PAPER_PENV_7_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 160 )
   CASE nPaperSize == 116 // HPDF_PAPER_PENV_8_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 309 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   CASE nPaperSize == 117 // HPDF_PAPER_PENV_9_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   CASE nPaperSize == 118 // HPDF_PAPER_PENV_10_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 458 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   ENDCASE
   IF _HMG_HPDFDATA[ 1 ][ 6 ] == 2 // landscape
      nTemp := _HMG_HPDFDATA[ 1 ][ 5 ]
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDFDATA[ 1 ][ 4 ]
      _HMG_HPDFDATA[ 1 ][ 4 ] := nTemp
   ENDIF

RETURN NIL

FUNCTION _HMG_HPDF_SetFont( cFontName, lBold, lItalic )

   LOCAL nPos, cFont
   LOCAL aHpdf_Font := { 'Courier', ;
      'Courier-Bold', ;
      'Courier-Oblique', ;
      'Courier-BoldOblique', ;
      'Helvetica', ;
      'Helvetica-Bold', ;
      'Helvetica-Oblique', ;
      'Helvetica-BoldOblique', ;
      'Times-Roman', ;
      'Times-Bold', ;
      'Times-Italic', ;
      'Times-BoldItalic', ;
      'Symbol', ;
      'ZapfDingbats' }

   DEFAULT lBold := .F., lItalic := .F.
   IF Len( AllTrim( cFontName ) ) == 0
      cFont := _HMG_HPDFDATA[ 1 ][ 8 ]
      IF lBold .AND. lItalic
         cFont += '-BoldOblique'
      ELSEIF lBold
         cFont += '-Bold'
      ELSEIF lItalic
         cFont += '-Oblique'
      ENDIF
   ELSEIF ( nPos := AScan( aHpdf_Font, {| cFont| At( cFontName, cFont ) > 0 } ) ) > 0
      cFont := aHpdf_Font[ nPos ]
      IF ( nPos := At( '-', cFont ) ) > 0 .AND. At( '-', cFontName ) == 0
         cfont := SubStr( cFont, 1, nPos - 1 )
      ENDIF
      IF SubStr( cFont, 1, 5 ) == 'Times'
         IF lBold .AND. lItalic
            cFont += '-BoldItalic'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Italic'
         ELSE
            IF At( '-', cFontName ) != 0
               cFont := cFontName
            ELSE
               cFont := 'Times-Roman'
            ENDIF
         ENDIF
      ELSEIF AllTrim( cFontName ) == "Symbol" .OR. AllTrim( cFontName ) == "ZapfDingbats"

      ELSE
         IF lBold .AND. lItalic
            cFont += '-BoldOblique'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Oblique'
         ELSE
            IF At( '-', cFontName ) != 0
               cFont := cFontName
            ENDIF
         ENDIF
      ENDIF
   ELSEIF Upper( SubStr( cFontName, Len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
      cFont := SubStr( cFontName, 1, Len( cFontName ) - 4 )
      IF lBold .AND. lItalic
         cFontName := cFont + 'bi.ttf'
      ELSEIF lBold
         cFontName := cFont + 'bd.ttf'
      ELSEIF lItalic
         cFontName := cFont + 'i.ttf'
      ENDIF
      cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .T. )
      IF Len( AllTrim( cFont ) ) == 0
         RETURN ''
      ENDIF
   ELSE
      cFont := cFontName
   ENDIF

RETURN cFont

FUNCTION _HMG_HPDF_SetDash( nMode )

   LOCAL aPtn, nNum := 0, nFase := 0

   DEFAULT nMode := 0
   DO CASE
   CASE nMode == 1
      aPtn := DASH_MODE1  // {3}
      nNum := 1
      nFase := 1
   CASE nMode == 2
      aPtn := DASH_MODE2  // {7,3}
      nNum := 2
      nFase := 2
   CASE nMode == 3
      aPtn := DASH_MODE3  // {8,7,2,7}
      nNum := 4
      nFase := 0
   ENDCASE
   HPDF_Page_SetDash ( _HMG_HPDFDATA[ 1 ][ 7 ], @aPtn, nNum, nFase )

RETURN NIL

FUNCTION _HMG_HPDF_SetOrientation( nMode )

   LOCAL nPaperWidth, nPaperLength

   DEFAULT nMode := 1
   _HMG_HPDFDATA[ 1 ][ 6 ] := nMode
   nPaperWidth  := _HMG_HPDFDATA[ 1 ][ 4 ]
   nPaperLength := _HMG_HPDFDATA[ 1 ][ 5 ]
   IF _HMG_HPDFDATA[ 1 ][ 6 ] == 1  // orientation portrait
      IF nPaperWidth > nPaperLength
         _HMG_HPDFDATA[ 1 ][ 4 ] := nPaperLength
         _HMG_HPDFDATA[ 1 ][ 5 ] := nPaperWidth
      ENDIF
   ELSE  // orientation landscape
      IF nPaperWidth < nPaperLength
         _HMG_HPDFDATA[ 1 ][ 4 ] := nPaperLength
         _HMG_HPDFDATA[ 1 ][ 5 ] := nPaperWidth
      ENDIF
   ENDIF

RETURN NIL
