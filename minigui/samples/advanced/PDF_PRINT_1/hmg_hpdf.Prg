#include <hmg.ch>
#include "harupdf.ch"

Static DASH_MODE1 := {3}
Static DASH_MODE2 := {3, 7}
Static DASH_MODE3 := {8, 7, 2, 7}


function _HMG_HPDF_INIT ( cPDFFile, nOrientation, nPaperSize, nPaperLength, nPaperWidth )
   local lReturn := .f.

   default nOrientation := 1
   default nPaperSize   := 1

   Public _HMG_HPDFDATA := Array( 1 )

   if valtype( _HMG_HPDFDATA[ 1 ] ) == 'U'
      _HMG_HPDFDATA[ 1 ] := { ;
                           nil, ;                  // PDF Object
                           cPDFFile,;              // PDF File to Save
                           0,;                     // PDF PaperSize
                           0,;                     // PDF PaperWidth
                           0,;                     // PDF PaperHeight
                           nOrientation,;          // PDF Orientation
                           nil, ;                  // PDF Current Page
                           'Helvetica',;           // PDF default font
                           12,;                    // PDF default fontsize
                           "StandardEncoding",;    // PDF default encoding
                           {},;                    // PDF Outlines Array                           
                           {},;                    // PDF Pages Array
                           0,;                     // PDF Current Page Number 
                           }
      _HMG_HPDFDATA[ 1 ][ 1 ] := HPDF_New()
      if _HMG_HPDFDATA[ 1 ][ 1 ] == nil
         _HMG_HPDF_Error( 2 )
         return lReturn
      endif
      _HMG_HPDFDATA[ 1 ][ 3 ] := nPaperSize
      if nPaperSize == 256 // user size
         if _HMG_HPDFDATA[ 1 ][ 6 ] == 1 // orientation portrait
            _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
            _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
         else // orientation landscape
            _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( nPaperLength )
            _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( nPaperWidth )
         endif         
      else
         _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )
      endif   
      lReturn := .t.
   else
      _HMG_HPDF_Error( 1 )
   endif   
return lReturn

function _hmg_hpdf_setencoding( cEncoding )
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   HPDF_SetCurrentEncoder( _HMG_HPDFDATA[ 1 ][ 1 ], cEncoding ) 
   _HMG_HPDFDATA[ 1 ] [ 10 ] := cEncoding
return nil

function _hmg_hpdf_startdoc() 

return nil

function _hmg_hpdf_startpage()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif   
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := HPDF_AddPage( _HMG_HPDFDATA[ 1 ][ 1 ] )
      if EMPTY( _HMG_HPDFDATA[ 1 ][ 7 ] )
         _HMG_HPDF_Error( 9 )
         return nil
      else
         // add current page to the pages array
         aadd( _HMG_HPDFDATA[ 1 ][ 12 ], _HMG_HPDFDATA[ 1 ][ 7 ] )
         _HMG_HPDFDATA[ 1 ][ 13 ] := len( _HMG_HPDFDATA[ 1 ][ 12 ] )
         // set page size
         HPDF_Page_SetWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 5 ] )
      endif
   else
      _HMG_HPDF_Error( 4 )
   endif   
return nil

function _HMG_HPDF_InsertPage( nPage )
   local oOldPage := nil
   local aPages := aclone( _HMG_HPDFDATA[ 1 ][ 12 ] )
   if nPage > len( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 16 )
      return nil
   endif   
   oOldPage := aPages[ nPage ]
   if empty( oOldPage )
      _HMG_HPDF_Error( 16 )
      return nil
   endif   
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := HPDF_InsertPage( _HMG_HPDFDATA[ 1 ][ 1 ], oOldPage )
      IF EMPTY( _HMG_HPDFDATA[ 1, 7 ] )
         _HMG_HPDF_Error( 9 )
         return nil
      ELSE
      // insert current page to the pages array
         asize( aPages, len( aPages ) + 1 )
         ains( aPages, nPage )
         aPages[ nPage ] := _HMG_HPDFDATA[ 1, 7 ]
         _HMG_HPDFDATA[ 1 ][ 12 ] := aclone( aPages )
         _HMG_HPDFDATA[ 1 ][ 13 ] := nPage     
         HPDF_Page_SetWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 4 ] )
         HPDF_Page_SetHeight( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDFDATA[ 1 ][ 5 ] )
      endif
   else
      _HMG_HPDF_Error( 4 )
   endif   
return nil

function _HMG_HPDF_GoToPage( nPage )
   local oPage := nil
   local aPages := aclone( _HMG_HPDFDATA[ 1 ][ 12 ] )
   if nPage > len( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 18 )
      return nil
   endif   
   oPage := aPages[ nPage ]
   if empty( oPage )
      _HMG_HPDF_Error( 18 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // Page is free
      _HMG_HPDFDATA[ 1 ][ 7 ] := aPages[ nPage ]
      IF EMPTY( _HMG_HPDFDATA[ 1, 7 ] )
         _HMG_HPDF_Error( 19 )
         return nil
      ENDIF
      _HMG_HPDFDATA[ 1 ][ 13 ] := nPage
   endif   
return nil

function _hmg_hpdf_endpage()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif   
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // Page is free
      _HMG_HPDF_Error( 5 )
      return nil
   else
      _HMG_HPDFDATA[ 1 ][ 7 ] := nil         
   endif
return nil

function HMG_HPDF_PageCount()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif   
return len( _HMG_HPDFDATA[ 1 ][ 12 ] )

function HMG_HPDF_PageNo()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif   
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // Page is free
      _HMG_HPDF_Error( 5 )
      return nil
   endif
return _HMG_HPDFDATA[ 1 ][ 13 ]

function _hmg_hpdf_enddoc()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   HPDF_SaveToFile( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 2 ] )
   HPDF_Free( _HMG_HPDFDATA[ 1 ][ 1 ] )
   _HMG_HPDFDATA[ 1 ] := nil
return nil

function _hmg_hpdf_abortdoc()
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   HPDF_Free( _HMG_HPDFDATA[ 1 ][ 1 ] )
   _HMG_HPDFDATA[ 1 ][ 1 ] := nil
return nil

function _HMG_HPDF_PRINT ( nRow, nCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign, nAngle )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local oFont := Nil
   local cFont := ''
   Local nRad  := 0
   default cFontName := ''
   default nFontSize := 12
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default lBold := .f.
   default lItalic := .f.
   default lUnderline := .f.
   default lStrikeout := .f.
   default lColor := .f.
   default lFont := .f.
   default lSize := .f.
   default cAlign := ''
   default nAngle := 0

   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   

   // set font
   cFont := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
   if len( alltrim( cFont ) ) == 0
      _HMG_HPDF_Error( 6 )
      return nil
   else
      if upper( alltrim( cFont ) ) == "SYMBOL" .or. upper( alltrim( cFont ) ) == "ZAPFDINGBATS"
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, Nil )
      else
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      endif
   endif
   if oFont == Nil
      _HMG_HPDF_Error( 6 )
      return nil
   else
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      do case
      case upper( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      case upper( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      endcase
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      if nAngle != 0
         nRad := nAngle / 180 * 3.141592   /* Calcurate the radian value. */
         HPDF_Page_SetTextMatrix (_HMG_HPDFDATA[ 1 ][ 7 ], cos(nRad), sin(nRad), -sin(nRad), cos(nRad), nxPos, nyPos)
      endif
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      if lStrikeout .or. lUnderline
         HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
         if lColor
            HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
         else
            HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
         endif
         nyPos += IF( lUnderline, -1, _HMG_HPDF_Pixel2MM(nFontSize)/2+1 )
         HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
         HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nTextWidth, nyPos )
         HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
      endif
   endif
return nil

function _HMG_HPDF_MULTILINE_PRINT ( nRow, nCol, nToRow, nToCol, cFontName, nFontSize, nRColor, nGColor, nBColor, cText, lBold, lItalic, lUnderline, lStrikeout, lColor, lFont, lSize, cAlign ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   local oFont := Nil
   local cFont := ''
   default cFontName := ''
   default nFontSize := 12
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default lBold := .f.
   default lItalic := .f.
   default lUnderline := .f.
   default lStrikeout := .f.
   default lColor := .f.
   default lFont := .f.
   default lSize := .f.
   default cAlign := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   

   // set font
   cFont := _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
   if len( alltrim( cFont ) ) == 0
      _HMG_HPDF_Error( 6 )
      return nil
   else
      if upper( alltrim( cFont ) ) == "SYMBOL" .or. upper( alltrim( cFont ) ) == "ZAPFDINGBATS"
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, Nil )
      else
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      endif
   endif
   if oFont == Nil
      _HMG_HPDF_Error( 6 )
      return nil
   else
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      do case
      case upper( cAlign ) == 'CENTER'
         HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_CENTER, NIL )
      case upper( cAlign ) == 'RIGHT'
         HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_RIGHT, NIL )
      case upper( cAlign ) == 'JUSTIFY'
         HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_JUSTIFY, NIL )
      otherwise         
         HPDF_Page_TextRect( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nToxPos, nToyPos, cText, HPDF_TALIGN_LEFT, NIL )
      endcase         
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif
   if lStrikeout .or. lUnderline
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
      if lColor
         HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      else
         HPDF_Page_SetRGBStroke( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
      endif
      nyPos += IF( lUnderline, -1, _HMG_HPDF_Pixel2MM(nFontSize)/2+1 )
      HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
      HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nTextWidth, nyPos )
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif
return nil

function _HMG_HPDF_IMAGE ( cImage, nRow, nCol, nImageheight, nImageWidth, lStretch ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local oImage := nil
   default lStretch := .f.
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   if file( cImage )
      oImage := HPDF_LoadPngImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )
   else
      _HMG_HPDF_Error( 7 )
      return nil
   endif   
   if empty( oImage ) 
      _HMG_HPDF_Error( 7 )
      return nil
   endif   
   HPDF_Page_DrawImage( _HMG_HPDFDATA[ 1 ][ 7 ], oImage, nxPos, nyPos - _HMG_HPDF_MM2Pixel( nImageHeight ), _HMG_HPDF_MM2Pixel( nImageWidth ), _HMG_HPDF_MM2Pixel( nImageHeight ) )
return nil

function _HMG_HPDF_LINE ( nRow , nCol , nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
return nil

function _HMG_HPDF_RECTANGLE ( nRow, nCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   default lFilled := .f.
   
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      if lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      endif
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_Rectangle( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos , nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow ), _HMG_HPDF_MM2Pixel( nToCol - nCol ), _HMG_HPDF_MM2Pixel( nToRow - nRow ) )
   if lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   else
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif   
return nil

function _HMG_HPDF_ROUNDRECTANGLE ( nRow , nCol , nToRow , nToCol , nLineWidth, nRColor , nGColor , nBColor , lWidth , lColor, lFilled, nRoundness ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   local nRectWidth := nToCol - nCol
   local nRectHeight := nToRow - nRow
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   default lFilled := .f.
   default nRoundness := 0
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      if lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      endif
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   // set line Width
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   if nRoundness == 0
      nRoundness := int( min( nRectWidth, nRectHeight ) * 10 / 100 )
   else
      if nRoundness > int( min( nRectWidth, nRectHeight ) / 2 )
         _HMG_HPDF_Error( 8 )
         return nil
      endif
   endif
   
   nRoundness := _HMG_HPDF_MM2Pixel( nRoundness )

   // start rounded rectangle path
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nRoundness, nyPos )  // top line left position
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos - nRoundness, nyPos ) // draw top line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nyPos, nToxPos, nyPos - nRoundness ) // draw top right curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos , nToyPos + nRoundness ) // draw right line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nToxPos, nToyPos, nToxPos - nRoundness, nToyPos ) // draw bottom right curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos + nRoundness , nToyPos ) // draw bottom line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nToyPos, nxPos, nToyPos + nRoundness ) // draw bottom left curve
   HPDF_Page_LineTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos - nRoundness ) // draw left line
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, nxPos + nRoundness, nyPos ) // draw top left curve

   // now start and finish drawing along the path   
   if lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   else
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif   

return nil

function _HMG_HPDF_CIRCLE( nRow, nCol, nR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   default lFilled := .f.
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      if lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      endif
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   // set line Width
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_Circle( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nR ) )
   if lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   else
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif   
return nil   

function _HMG_HPDF_ELLIPSE( nRow, nCol, nHR, nVR, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor, lFilled )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   default lFilled := .f.
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      if lFilled
         HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
      endif
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   // set line Width
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_Ellipse( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nHR ), _HMG_HPDF_MM2Pixel( nVR ) )
   if lFilled
      HPDF_Page_FillStroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   else
      HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif   
return nil   

function _HMG_HPDF_ARC( nRow, nCol, nR, nFromAngle, nToAngle, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   // set line Width
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_Arc( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos , nyPos, _HMG_HPDF_MM2Pixel( nR ), nFromAngle, nToAngle )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
return nil   
   
function _HMG_HPDF_CURVE ( nRow , nCol , nFromRow, nFromCol, nToRow, nToCol, nLineWidth, nRColor, nGColor, nBColor, lWidth, lColor ) 
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   local nFromxPos := _HMG_HPDF_MM2Pixel( nFromCol )
   local nFromyPos := nHeight - _HMG_HPDF_MM2Pixel( nFromRow )
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default nWidth := 1
   default lWidth := .f.
   default lColor := .f.
   
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBSTROKE( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   
   
   if lWidth
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nlineWidth ) )
   else
      HPDF_Page_SetLineWidth( _HMG_HPDFDATA[ 1 ][ 7 ], 1 )
   endif
   HPDF_Page_MoveTo( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos )
   HPDF_Page_CurveTo2( _HMG_HPDFDATA[ 1 ][ 7 ], nFromxPos, nFromyPos, nToxPos, nToyPos )
   HPDF_Page_Stroke( _HMG_HPDFDATA[ 1 ][ 7 ] )
return nil

function _HMG_HPDF_SetPassword( cOwnerPass, cUserPass )
   default cUserPass := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   HPDF_SetPassword( _HMG_HPDFDATA[ 1 ][ 1 ], cOwnerPass, cUserPass )
return nil

function _HMG_HPDF_SetCompression( cMode )
   default cMode := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   cMode := upper( cMode )
   do case
   case cMode == 'NONE'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_NONE )
   case cMode == 'TEXT'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_TEXT )
   case cMode == 'IMAGE'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_IMAGE )
   case cMode == 'METADATA'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_METADATA )
   case cMode == 'ALL'
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_ALL )
   otherwise      
      HPDF_SetCompressionMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_COMP_NONE )
   endcase      
return nil

function _HMG_HPDF_SetPermission( cMode )
   default cMode := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   cMode := upper( cMode )
   do case
   case cMode == 'READ'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_READ )  
   case cMode == 'PRINT'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_PRINT )  
   case cMode == 'COPY'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_COPY )  
   case cMode == 'EDIT'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_EDIT )  
   case cMode == 'EDIT_ALL'
      HPDF_SetPermission( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_ENABLE_EDIT_ALL )  
   endcase      
return nil

function _HMG_HPDF_SetPageMode( cMode )
   default cMode := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   cMode := upper( cMode )
   do case
   case cMode == 'OUTLINE'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_OUTLINE )
   case cMode == 'NONE'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_NONE )
   case cMode == 'THUMBS'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_USE_THUMBS )
   case cMode == 'FULL_SCREEN'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_FULL_SCREEN )
   case cMode == 'EOF'
      HPDF_SetPageMode( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_PAGE_MODE_EOF )
   endcase      
return nil

function _HMG_HPDF_RootOutline( cTitle, cName, cParent )
   local aOutlines := {}
   local oOutline, i
   default cParent := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if len( alltrim( cTitle ) ) == 0
      _HMG_HPDF_Error( 11 )
      return nil
   endif
   if len( alltrim( cName ) ) == 0
      _HMG_HPDF_Error( 12 )
      return nil
   endif
   if len( alltrim( cParent ) ) == 0 // make this a root outline
      oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      if Empty( oOutLine )
         _HMG_HPDF_Error( 10 )
         return nil
      else
         aadd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
      endif
   else
      aOutLines := aclone( _HMG_HPDFDATA[ 1 ][ 11 ] )
      for i := 1 to len( aOutLines )
         if upper( alltrim( aOutLines[ i, 2 ] ) ) == upper( alltrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], aOutLines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            if Empty( oOutLine )
               _HMG_HPDF_Error( 10 )
               return nil
            else
               aadd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
            endif
            exit
         endif
      next i
   endif
return nil

function _HMG_HPDF_PageOutline( cTitle, cParent, cName )
   local aOutlines := {}
   local oOutline, i
   local oDestination
   default cParent := ''
   default cName := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   oDestination := HPDF_Page_CreateDestination( _HMG_HPDFDATA[ 1 ][ 7 ] )
   if empty( oDestination )
      _HMG_HPDF_Error( 13 )
      return nil
   endif
   if len( alltrim( cParent ) ) == 0 // No parent make this page root element
      oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], Nil, cTitle, HPDF_GetCurrentEncoder() )
      if empty( oOutline )
         _HMG_HPDF_Error( 13 )
         return nil
      endif
   else
      aOutlines := aclone( _HMG_HPDFDATA[ 1 ][ 11 ] )
      for i := 1 to len( aOutlines )
         if upper( alltrim( aOutlines[ i, 2 ] ) ) == upper( alltrim( cParent ) )
            oOutline := HPDF_CreateOutline( _HMG_HPDFDATA[ 1 ][ 1 ], aOutlines[ i, 1 ], cTitle, HPDF_GetCurrentEncoder() )
            exit
         endif
      next i
      if empty( oOutline )
         _HMG_HPDF_Error( 14 )
         return nil
      endif
   endif
   if len( alltrim( cName ) ) > 0
      aadd( _HMG_HPDFDATA[ 1 ][ 11 ], { oOutline, cName } )
   endif      
   HPDF_Outline_SetDestination( oOutline, oDestination )
return nil      

function _HMG_HPDF_SetTextAnnot( nRow, nCol, cToolTip, cIcon )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nToRow := nRow + 5
   local nToCol := nCol + 5
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local nToxPos := nxPos + _HMG_HPDF_MM2Pixel( nToCol - nCol )
   local nToyPos := nyPos - _HMG_HPDF_MM2Pixel( nToRow - nRow )
   local aRect := { nxPos, nyPos, nToxPos, nToyPos }
   local oAnnot := nil
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   oAnnot := HPDF_Page_CreateTextAnnot ( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, cTooltip, HPDF_GetCurrentEncoder() )
   if empty( oAnnot )
      _HMG_HPDF_Error( 15 )
      return nil
   endif
   do case
   case upper( alltrim( cIcon ) ) == "COMMENT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_COMMENT )
   case upper( alltrim( cIcon ) ) == "KEY"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_KEY )
   case upper( alltrim( cIcon ) ) == "NOTE"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NOTE )
   case upper( alltrim( cIcon ) ) == "HELP"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_HELP )
   case upper( alltrim( cIcon ) ) == "NEW_PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_NEW_PARAGRAPH )
   case upper( alltrim( cIcon ) ) == "PARAGRAPH"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_PARAGRAPH )
   case upper( alltrim( cIcon ) ) == "INSERT"
      HPDF_TextAnnot_SetIcon ( oAnnot, HPDF_ANNOT_ICON_INSERT )
   endcase   
return nil

function _HMG_HPDF_SetPageLink( nRow, nCol, cText, nPage, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize, lBorder, lWidth, nBorderWidth )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local oFont := Nil
   local cFont := ''
   local aRect := { }
   local aCurXY := {}
   local oAnnot := nil
   local oDest := nil
   local aPages := {}
   local oLinkPage := nil
   default cFontName := ''
   default nFontSize := 12
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default lColor := .f.
   default lFont := .f.
   default lSize := .f.
   default cAlign := ''
   default lBorder := .f.
   default lWidth := .f.
   default nBorderWidth := 0

   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   aPages := aClone( _HMG_HPDFDATA[ 1 ][ 12 ] )
   if nPage > len( aPages ) .or. nPage < 1
      _HMG_HPDF_Error( 17 )
      return nil
   endif
      
   oLinkPage := aPages[ nPage ]
   if empty( oLinkPage )
      _HMG_HPDF_Error( 17 )
      return nil
   endif
   oDest := HPDF_Page_CreateDestination( oLinkPage )
   if empty( oDest )
      _HMG_HPDF_Error( 17 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   

   // set font
   if len( alltrim( cFontName ) ) == 0
      oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 8 ], _HMG_HPDFDATA[ 1 ][ 10 ] )
   else
      cFontName := alltrim( cFontName )
      if upper( substr( cFontName, len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .t. )
         if len( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 )
            return nil
         endif
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      else
         if upper( alltrim( cFontName ) ) == "SYMBOL" .or. upper( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, Nil )
         else   
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, _HMG_HPDFDATA[ 1 ][ 10 ] )
         endif   
      endif
   endif   
   if oFont == Nil
      _HMG_HPDF_Error( 6 )
      return nil
   else
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      do case
      case upper( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      case upper( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      endcase
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      oAnnot := HPDF_Page_CreateLinkAnnot( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, oDest )
      if lBorder
         if nBorderWidth == 0
            nBorderWidth := 1
         else
            nBorderWidth := _HMG_HPDF_MM2Pixel( nBorderWidth )
         endif
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, nBorderWidth, 0, 0)
      else
         HPDF_LinkAnnot_SetBorderStyle ( oAnnot, 0, 0, 0)
      endif      
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif
return nil   

function _HMG_HPDF_SetURLLink( nRow, nCol, cText, cLink, cFontName, nFontSize, nRColor, nGColor, nBColor, cAlign, lColor, lFont, lSize  )
   local nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   local nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   local nTextWidth := 0
   local nxPos := _HMG_HPDF_MM2Pixel( nCol )
   local nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   local oFont := Nil
   local cFont := ''
   local aRect := { }
   local aCurXY := {}
   local oAnnot := nil
   default cFontName := ''
   default nFontSize := 12
   default nRColor := 0
   default nGColor := 0
   default nBColor := 0
   default lColor := .f.
   default lFont := .f.
   default lSize := .f.
   default cAlign := ''

   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   
   // set color
   if lColor
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], nRColor/255, nGColor/255, nBColor/255 )
   else
      HPDF_Page_SetRGBFill( _HMG_HPDFDATA[ 1 ][ 7 ], 0.0, 0.0, 0.0 )
   endif   

   // set font
   if len( alltrim( cFontName ) ) == 0
      oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], _HMG_HPDFDATA[ 1 ][ 8 ], _HMG_HPDFDATA[ 1 ][ 10 ] )
   else
      cFontName := alltrim( cFontName )
      if upper( substr( cFontName, len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .t. )
         if len( alltrim( cFont ) ) == 0
            _HMG_HPDF_Error( 6 )
            return nil
         endif
         oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFont, _HMG_HPDFDATA[ 1 ][ 10 ] )
      else
         if upper( alltrim( cFontName ) ) == "SYMBOL" .or. upper( alltrim( cFontName ) ) == "ZAPFDINGBATS"
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, Nil )
         else   
            oFont := HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, _HMG_HPDFDATA[ 1 ][ 10 ] )
         endif   
      endif
   endif   
   if oFont == Nil
      _HMG_HPDF_Error( 6 )
      return nil
   else
      HPDF_Page_SetFontAndSize( _HMG_HPDFDATA[ 1 ][ 7 ], oFont, nFontSize )
      nTextWidth := HPDF_Page_TextWidth( _HMG_HPDFDATA[ 1 ][ 7 ], cText )
      do case
      case upper( alltrim( cAlign ) ) == 'CENTER'
         nxPos := nxPos - ( nTextWidth / 2 )
      case upper( alltrim( cAlign ) ) == 'RIGHT'
         nxPos := nxPos - ( nTextWidth )
      endcase
      HPDF_Page_BeginText( _HMG_HPDFDATA[ 1 ][ 7 ] )
      HPDF_PAGE_TEXTOUT( _HMG_HPDFDATA[ 1 ][ 7 ], nxPos, nyPos, cText )
      aRect := { nxPos - 4, nyPos + nFontsize + 4, nxPos + nTextWidth + 4, nyPos - 4 }
      HPDF_Page_CreateURILinkAnnot( _HMG_HPDFDATA[ 1 ][ 7 ], aRect, cLink )
      HPDF_Page_EndText( _HMG_HPDFDATA[ 1 ][ 7 ] )
   endif
return nil   

function _HMG_HPDF_SetLineSpacing( nSpacing )
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   if _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )
      return nil
   endif
   HPDF_Page_SetTextLeading( _HMG_HPDFDATA[ 1 ][ 7 ], _HMG_HPDF_MM2Pixel( nSpacing ) )
return nil

function _HMG_HPDF_SetInfo( cAttrib, xValue, cTime )
   local cValue := ''
   local dValue := ''
   local nHours := 0
   local nMinutes := 0
   local nSeconds := 0
   default cTime := ''
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   do case
   case valtype( xValue ) == 'D'
      dValue := xValue
   otherwise
      cValue := xValue
   endcase      
   do case
   case upper( alltrim( cAttrib ) ) == "AUTHOR"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_AUTHOR, cValue )
   case upper( alltrim( cAttrib ) ) == "CREATOR"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATOR, cValue )
   case upper( alltrim( cAttrib ) ) == "TITLE"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_TITLE, cValue )
   case upper( alltrim( cAttrib ) ) == "SUBJECT"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_SUBJECT, cValue )
   case upper( alltrim( cAttrib ) ) == "KEYWORDS"
      HPDF_SetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_KEYWORDS, cValue )
   case upper( alltrim( cAttrib ) ) == "DATECREATED"
      if len( alltrim( cTime ) ) > 0
         nHours := val( SUBSTR( cTime, 1, 2) )
         nMinutes := val( SUBSTR( cTime, 4, 2) )
         nSeconds := val( SUBSTR( cTime, 7, 2) )
      endif
      HPDF_SetInfoDateAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATION_DATE, { year( dValue ), month( dVAlue ), day( dValue ), nHours, nMinutes, nSeconds } )
   case upper( alltrim( cAttrib ) ) == "DATEMODIFIED"
      if len( alltrim( cTime ) ) > 0
         nHours := val( SUBSTR( cTime, 1, 2) )
         nMinutes := val( SUBSTR( cTime, 4, 2) )
         nSeconds := val( SUBSTR( cTime, 7, 2) )
      endif
      HPDF_SetInfoDateAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_MOD_DATE, { year( dValue ), month( dVAlue ), day( dValue ), nHours, nMinutes, nSeconds } )
   endcase
return nil

function _HMG_HPDF_GetInfo( cAttrib )
   local cRetValue := '', bd, bc
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   do case
   case upper( alltrim( cAttrib ) ) == "AUTHOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_AUTHOR )
   case upper( alltrim( cAttrib ) ) == "CREATOR"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATOR )
   case upper( alltrim( cAttrib ) ) == "TITLE"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_TITLE )
   case upper( alltrim( cAttrib ) ) == "SUBJECT"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_SUBJECT )
   case upper( alltrim( cAttrib ) ) == "KEYWORDS"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_KEYWORDS )
   case upper( alltrim( cAttrib ) ) == "DATECREATED"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_CREATION_DATE )
   case upper( alltrim( cAttrib ) ) == "DATEMODIFIED"
      cRetValue := HPDF_GetInfoAttr( _HMG_HPDFDATA[ 1 ][ 1 ], HPDF_INFO_MOD_DATE )
   endcase
   if left( cRetValue, 2 ) == "D:"
      bd := Set( _SET_DATEFORMAT )
      bc := __SetCentury( .t. )
      set date german
      cRetValue := DTOC( STOD( Substr(cRetValue, 3, 8) ) ) + " " + Substr(cRetValue, 11, 2) + ":" + Substr(cRetValue, 13, 2) + ":" + Substr(cRetValue, 15, 2)
      __SetCentury( bc )
      Set( _SET_DATEFORMAT, bd )
   endif
return cRetValue

function _HMG_HPDF_SetPageLabel( nPage, cStyle, cCase, cPrefix )
   default cCase := ""
   default cStyle := "DECIMAL"
   default nPage := 1
   default cPrefix := ""
   if _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )
      return nil
   endif
   do case
   case upper( alltrim( cStyle ) ) == "DECIMAL"
      HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_DECIMAL, nPage, cPrefix )
   case upper( alltrim( cStyle ) ) == "ROMAN" 
      if upper( alltrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_ROMAN, nPage, cPrefix )
      else
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_ROMAN, nPage, cPrefix )
      endif
   case upper( alltrim( cStyle ) ) == "LETTERS" 
      if upper( alltrim( cCase ) ) == "LOWER"
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_LOWER_LETTERS, nPage, cPrefix )
      else
         HPDF_AddPageLabel( _HMG_HPDFDATA[ 1 ][ 1 ], nPage, HPDF_PAGE_NUM_STYLE_UPPER_LETTERS, nPage, cPrefix )
      endif
   endcase
return nil
   
function _HMG_HPDF_Error( nErr )
   local cErr := ''
   do case
   case nErr == 1
      cErr := 'A PDF document is already initiated.'
   case nErr == 2
      cErr := 'PDF document cannot be initialized.'
   case nErr == 3
      cErr := 'PDF PAGE cannot be added. PDF document cannot be found.'
   case nErr == 4
      cErr := 'A PDF PAGE is already initiated.'
   case nErr == 5
      cErr := 'PDF PAGE cannot be found.'
   case nErr == 6
      cErr := 'Font cannot be loaded.'
   case nErr == 7
      cErr := 'Image cannot be loaded.'
   case nErr == 8
      cErr := 'Round curve can not be longer than half of the width/height.'
   case nErr == 9
      cErr := 'Can not start new page.'
   case nErr == 10
      cErr := 'Can not create new parent outline.'
   case nErr == 11
      cErr := 'Outline Title is not valid.'
   case nErr == 12
      cErr := 'Outline Name is not valid.'
   case nErr == 13
      cErr := 'Can not create Page Outline.'
   case nErr == 14
      cErr := 'Can not find Parent Node.'
   case nErr == 15
      cErr := 'Tooltip creation error!'
   case nErr == 16
      cErr := 'Page not found. New page can not be inserted.'
   case nErr == 17
      cErr := 'Link Page not found.'
   case nErr == 18
      cErr := 'Selected Page can not be found.'
   case nErr == 19
      cErr := 'Page Selection error!'
   endcase
   msgstop( cErr )
return nil

function _HMG_HPDF_Inch2Pixel( nInches )
   return ( nInches * 72 )
   
function _HMG_HPDF_Pixel2Inch( nPixels )
   return ( nPixels / 72 )

function _HMG_HPDF_MM2Pixel( nMM )
   return ( ( nMM / 25.4 ) * 72 )

function _HMG_HPDF_Pixel2MM( nPixel )
   return ( ( nPixel / 72 ) * 25.4 )
   
function _HMG_HPDF_INIT_PAPERSIZE( nPaperSize )
   local nTemp := 0
   do case
   case nPaperSize == 1 .or. nPaperSize == -999 // HPDF_PAPER_LETTER or default
      _HMG_HPDFDATA[ 1 ][ 4 ] := 612
      _HMG_HPDFDATA[ 1 ][ 5 ] := 792
   case nPaperSize == 2 // HPDF_PAPER_LETTERSMALL
      _HMG_HPDFDATA[ 1 ][ 4 ] := 612
      _HMG_HPDFDATA[ 1 ][ 5 ] := 792
   case nPaperSize == 3 // HPDF_PAPER_TABLOID
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   case nPaperSize == 4 // HPDF_PAPER_LEDGER
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 5 // HPDF_PAPER_LEGAL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 14 )
   case nPaperSize == 6 // HPDF_PAPER_STATEMENT
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   case nPaperSize == 7 // HPDF_PAPER_EXECUTIVE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   case nPaperSize == 8 // HPDF_PAPER_A3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   case nPaperSize == 9 // HPDF_PAPER_A4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 10 // HPDF_PAPER_A4SMALL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 11 // HPDF_PAPER_A5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   case nPaperSize == 12 // HPDF_PAPER_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 354 )
   case nPaperSize == 13 // HPDF_PAPER_B5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 185 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   case nPaperSize == 14 // HPDF_PAPER_FOLIO
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   case nPaperSize == 15 // HPDF_PAPER_QUARTO
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 275 )
   case nPaperSize == 16 // HPDF_PAPER_10X14
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 140 )
   case nPaperSize == 17 // HPDF_PAPER_11X17
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 17 )
   case nPaperSize == 18 // HPDF_PAPER_NOTE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 19 // HPDF_PAPER_ENV_9
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + (7 / 8) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8 + (7 / 8) )
   case nPaperSize == 20 // HPDF_PAPER_ENV_10
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4 + (1 / 8) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
   case nPaperSize == 21 // HPDF_PAPER_ENV_11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 10 + (3 / 8) )
   case nPaperSize == 22 // HPDF_PAPER_ENV_12
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 4.75 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 23 // HPDF_PAPER_ENV_14
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11.5 )
   case nPaperSize == 24 // HPDF_PAPER_CSHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 17 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 22 )
   case nPaperSize == 25 // HPDF_PAPER_DSHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 22 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 34 )
   case nPaperSize == 26 // HPDF_PAPER_ESHEET
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 34 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 44 )
   case nPaperSize == 27 // HPDF_PAPER_ENV_DL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   case nPaperSize == 28 // HPDF_PAPER_ENV_C5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 162 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   case nPaperSize == 29 // HPDF_PAPER_ENV_C3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   case nPaperSize == 30 // HPDF_PAPER_ENV_C4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   case nPaperSize == 31 // HPDF_PAPER_ENV_C6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 162 )
   case nPaperSize == 32 // HPDF_PAPER_ENV_C65
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 114 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   case nPaperSize == 33 // HPDF_PAPER_ENV_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   case nPaperSize == 34 // HPDF_PAPER_ENV_B5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 250 )
   case nPaperSize == 35 // HPDF_PAPER_ENV_B6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   case nPaperSize == 36 // HPDF_PAPER_ENV_ITALY
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   case nPaperSize == 37 // HPDF_PAPER_ENV_MONARCH
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3.875 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 7.5 )
   case nPaperSize == 38 // HPDF_PAPER_ENV_PERSONAL
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 3 + ( 5 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 6.5 )
   case nPaperSize == 39 // HPDF_PAPER_FANFOLD_US
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 14 + ( 7 / 8 ) )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 40 // HPDF_PAPER_FANFOLD_STD_GERMAN
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   case nPaperSize == 41 // HPDF_PAPER_FANFOLD_LGL_GERMAN
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 13 )
   case nPaperSize == 42 // HPDF_PAPER_ISO_B4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 250 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 353 )
   case nPaperSize == 43 // HPDF_PAPER_JAPANESE_POSTCARD
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 100 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   case nPaperSize == 44 // HPDF_PAPER_9X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 45 // HPDF_PAPER_10X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 10 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 46 // HPDF_PAPER_15X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 15 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 47 // HPDF_PAPER_ENV_INVITE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   case nPaperSize == 48 // HPDF_PAPER_RESERVED_48
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 49 // HPDF_PAPER_RESERVED_49
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 50 // HPDF_PAPER_LETTER_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   case nPaperSize == 51 // HPDF_PAPER_LEGAL_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 15 )
   case nPaperSize == 52 // HPDF_PAPER_TABLOID_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11.69 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 18 )
   case nPaperSize == 53 // HPDF_PAPER_A4_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.27 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   case nPaperSize == 54 // HPDF_PAPER_LETTER_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 55 // HPDF_PAPER_A4_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 56 // HPDF_PAPER_LETTER_EXTRA_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 9.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12 )
   case nPaperSize == 57 // HPDF_PAPER_A_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 227 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 356 )
   case nPaperSize == 58 // HPDF_PAPER_B_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 305 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 487 )
   case nPaperSize == 59 // HPDF_PAPER_LETTER_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 12.69 )
   case nPaperSize == 60 // HPDF_PAPER_A4_PLUS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 330 )
   case nPaperSize == 61 // HPDF_PAPER_A5_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   case nPaperSize == 62 // HPDF_PAPER_B5_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   case nPaperSize == 63 // HPDF_PAPER_A3_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   case nPaperSize == 64 // HPDF_PAPER_A5_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 174 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   case nPaperSize == 65 // HPDF_PAPER_B5_EXTRA
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 201 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 276 )
   case nPaperSize == 66 // HPDF_PAPER_A2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 594 )
   case nPaperSize == 67 // HPDF_PAPER_A3_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 420 )
   case nPaperSize == 68 // HPDF_PAPER_A3_EXTRA_TRANSVERSE
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 322 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 445 )
   case nPaperSize == 69 // HPDF_PAPER_DBL_JAPANESE_POSTCARD
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 200 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   case nPaperSize == 70 // HPDF_PAPER_A6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   case nPaperSize == 71 // HPDF_PAPER_JENV_KAKU2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 240 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 332 )
   case nPaperSize == 72 // HPDF_PAPER_JENV_KAKU2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 216 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 277 )
   case nPaperSize == 73 // HPDF_PAPER_JENV_CHOU3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   case nPaperSize == 74 // HPDF_PAPER_JENV_CHOU4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 90 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 205 )
   case nPaperSize == 75 // HPDF_PAPER_LETTER_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 11 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 8.5 )
   case nPaperSize == 76 // HPDF_PAPER_A3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 420 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 297 )
   case nPaperSize == 77 // HPDF_PAPER_A4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 297 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 210 )
   case nPaperSize == 78 // HPDF_PAPER_A5_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 210 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 148 )
   case nPaperSize == 79 // HPDF_PAPER_B4_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 364 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 257 )
   case nPaperSize == 80 // HPDF_PAPER_B5_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 257 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   case nPaperSize == 81 // HPDF_PAPER_B5_JAPANESE_POSTCARD_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 100 )
   case nPaperSize == 82 // HPDF_PAPER_B5_DBL_JAPANESE_POSTCARD_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 200 )
   case nPaperSize == 83 // HPDF_PAPER_A6_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 148 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   case nPaperSize == 84 // HPDF_PAPER_JENV_KAKU2_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 332 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 240 )
   case nPaperSize == 85 // HPDF_PAPER_JENV_KAKU3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 277 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 216 )
   case nPaperSize == 86 // HPDF_PAPER_JENV_CHOU3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   case nPaperSize == 87 // HPDF_PAPER_JENV_CHOU4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 205 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 90 )
   case nPaperSize == 88 // HPDF_PAPER_B6_JIS
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 128 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 182 )
   case nPaperSize == 89 // HPDF_PAPER_B6_JIS_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 182 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 128 )
   case nPaperSize == 90 // HPDF_PAPER_12X11
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_Inch2Pixel( 12 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_Inch2Pixel( 11 )
   case nPaperSize == 91 // HPDF_PAPER_JENV_YOU4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 235 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 105 )
   case nPaperSize == 92 // HPDF_PAPER_JENV_YOU4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 105 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 235 )
   case nPaperSize == 93 // HPDF_PAPER_P16K
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 146 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 215 )
   case nPaperSize == 94 // HPDF_PAPER_P32K
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   case nPaperSize == 95 // HPDF_PAPER_P32KBIG
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 97 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 151 )
   case nPaperSize == 96 // HPDF_PAPER_PENV_1
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 165 )
   case nPaperSize == 97 // HPDF_PAPER_PENV_2
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 102 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   case nPaperSize == 98 // HPDF_PAPER_PENV_3
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 125 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 176 )
   case nPaperSize == 99 // HPDF_PAPER_PENV_4
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   case nPaperSize == 100 // HPDF_PAPER_PENV_5
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 110 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 220 )
   case nPaperSize == 101 // HPDF_PAPER_PENV_6
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   case nPaperSize == 102 // HPDF_PAPER_PENV_7
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 160 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 230 )
   case nPaperSize == 103 // HPDF_PAPER_PENV_8
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 120 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 208 )
   case nPaperSize == 104 // HPDF_PAPER_PENV_9
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 229 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   case nPaperSize == 105 // HPDF_PAPER_PENV_10
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 458 )
   case nPaperSize == 106 // HPDF_PAPER_P16K_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 215 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 146 )
   case nPaperSize == 107 // HPDF_PAPER_P32K_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   case nPaperSize == 108 // HPDF_PAPER_P32KBIG_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 151 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 97 )
   case nPaperSize == 109 // HPDF_PAPER_PENV_1_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 165 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   case nPaperSize == 110 // HPDF_PAPER_PENV_2_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 102 )
   case nPaperSize == 111 // HPDF_PAPER_PENV_3_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 176 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 125 )
   case nPaperSize == 112 // HPDF_PAPER_PENV_4_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 208 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   case nPaperSize == 113 // HPDF_PAPER_PENV_5_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 220 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 110 )
   case nPaperSize == 114 // HPDF_PAPER_PENV_6_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   case nPaperSize == 115 // HPDF_PAPER_PENV_7_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 230 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 160 )
   case nPaperSize == 116 // HPDF_PAPER_PENV_8_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 309 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 120 )
   case nPaperSize == 117 // HPDF_PAPER_PENV_9_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 324 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 229 )
   case nPaperSize == 118 // HPDF_PAPER_PENV_10_ROTATED
      _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( 458 )
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( 324 )
   endcase
   if _HMG_HPDFDATA[ 1 ][ 6 ] == 2 // landscape
      nTemp := _HMG_HPDFDATA[ 1 ][ 5 ]
      _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDFDATA[ 1 ][ 4 ]
      _HMG_HPDFDATA[ 1 ][ 4 ] := nTemp
   endif
   return nil   

Function _HMG_HPDF_SetFont( cFontName, lBold, lItalic )
   LOCAL nPos, cFont := ''
   LOCAL aHpdf_Font := {'Courier',;
                   'Courier-Bold',;
                   'Courier-Oblique',;
                   'Courier-BoldOblique',;
                   'Helvetica',;
                   'Helvetica-Bold',;
                   'Helvetica-Oblique',;
                   'Helvetica-BoldOblique',;
                   'Times-Roman',;
                   'Times-Bold',;
                   'Times-Italic',;
                   'Times-BoldItalic',;
                   'Symbol',;
                   'ZapfDingbats'}
   Default lBold := .f., lItalic := .f.
   IF len( alltrim( cFontName ) ) == 0
      cFont := _HMG_HPDFDATA[ 1 ][ 8 ]
      IF lBold .and. lItalic
         cFont += '-BoldOblique'
      ELSEIF lBold
         cFont += '-Bold'
      ELSEIF lItalic
         cFont += '-Oblique'
      ENDIF
   ELSEIF (nPos := AScan(aHpdf_Font, {|cFont| At(cFontName, cFont) > 0 })) > 0
      cFont := aHpdf_Font[nPos]
      IF (nPos := At('-',cFont)) > 0 .and. At('-',cFontName) == 0
         cfont := SubStr(cFont, 1, nPos-1)
      ENDIF
      IF SubStr(cFont, 1, 5) == 'Times'
         IF lBold .and. lItalic
            cFont += '-BoldItalic'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Italic'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ELSE
               cFont := 'Times-Roman'
            ENDIF 
         ENDIF
      ELSEIF alltrim( cFontName ) == "Symbol" .or. alltrim( cFontName ) == "ZapfDingbats"

      ELSE
         IF lBold .and. lItalic
            cFont += '-BoldOblique'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Oblique'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ENDIF
         ENDIF
      ENDIF
   ELSEIF upper( substr( cFontName, len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
      cFont := substr( cFontName, 1, len( cFontName ) - 4 )
      IF lBold .and. lItalic
         cFontName := cFont + 'bi.ttf'
      ELSEIF lBold
         cFontName := cFont + 'bd.ttf'
      ELSEIF lItalic
         cFontName := cFont + 'i.ttf'
      ENDIF
      cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .t. )
      IF len( alltrim( cFont ) ) == 0
         Return ''
      ENDIF
   ELSE
      cFont := cFontName
   ENDIF
Return cFont

Function _HMG_HPDF_SetDash( nMode )
   Local aPtn, nNum:=0, nFase:=0
   Default nMode := 0
   do case
   case nMode == 1
      aPtn := DASH_MODE1 //{3}
      nNum := 1
      nFase:= 1
   case nMode == 2
      aPtn := DASH_MODE2  //{7,3}
      nNum := 2
      nFase:= 2
   case nMode == 3
      aPtn := DASH_MODE3  //{8,7,2,7}
      nNum := 4
      nFase:= 0
   endcase
   HPDF_Page_SetDash ( _HMG_HPDFDATA[ 1 ][ 7 ], @aPtn, nNum, nFase )
Return nil
