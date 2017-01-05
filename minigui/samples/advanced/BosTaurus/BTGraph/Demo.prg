#include "hmg.ch"
#include "BosTaurus.CH"

FUNCTION Main

   set font to _GetSysFont(), 10
   define window graph at 0, 0 width 1000 height 700 title 'Bos Taurus Graph' main
      define label selecttype
         row 10
         col 45
         width 115
         value 'Select Graph Type'
         vcenteralign .T.
      end label
      define combobox graphtype
         row 10
         col 160
         width 100
         items { 'Bar', 'Lines', 'Points', 'Pie' }
         onchange drawgraph()
      end combobox
      define checkbox enable3d
         row 10
         col 280
         width 100
         caption 'Enable 3D'
         onchange drawgraph()
         value .T.
      end checkbox
      define button Button_1
         row 10
         col 400
         caption 'Save as PNG'
         action BT_BitmapSaveFile( BT_HMGGetImage( "graph", "grapharea" ), "Graph.PNG", BT_FILEFORMAT_PNG )
      end button
      define image grapharea
         row 50
         col 50
         width 600
         height 600
         stretch .T.
      end image
   end window
   graph.graphtype.value := 1
   graph.center
   graph.activate

RETURN NIL


FUNCTION drawgraph

   LOCAL nImageWidth := graph.grapharea.width
   LOCAL nImageHeight := graph.grapharea.height
   LOCAL cTitle := 'Sample Graph'
   LOCAL aYValues := { "Jan", "Feb", "Mar", "Apr", "May" }
   LOCAL aData := { { 14280, 20420, 12870, 25347, 7640 }, ;
      { 8350, 10315, 15870, 5347, 12340 }, ;
      { 12345, -8945, 10560, 15600, 17610 } }
   LOCAL nBarDepth := 15
   LOCAL nBarWidth := 15
   LOCAL nHValues := 5
   LOCAL l3D := graph.enable3D.value
   LOCAL lGrid := .T.
   LOCAL lXGrid := .T.
   LOCAL lYGrid := .T.
   LOCAL lXVal := .T.
   LOCAL lYVal := .T.
   LOCAL nGraphType := graph.graphtype.value
   LOCAL lViewVal := .T.
   LOCAL lLegends := .T.
   LOCAL cPicture := '99,999.99'
   LOCAL aSeries := { "Serie 1", "Serie 2", "Serie 3" }
   LOCAL aColors := { { 128, 128, 255 }, { 255, 102, 10 }, { 55, 201, 48 } }
   LOCAL lNoBorder := .F.
   LOCAL nLegendWidth := 50
   LOCAL hBitmap
   IF graph.graphtype.value == 0
      RETURN NIL
   ENDIF
   IF graph.graphtype.value == 4 // pie
      hBitmap := HMG_PieGraph( nImageWidth, nImageHeight, { 1500, 1800, 200, 500, 800 }, { "Product 1", "Product 2", "Product 3", "Product 4", "Product 5" }, ;
         { { 255, 0, 0 }, { 0, 0, 255 }, { 255, 255, 0 }, { 0, 255, 0 }, { 255, 128, 64 }, { 128, 0, 128 } }, "Sales", BLACK, 25, l3D, lxval, lLegends, lnoborder )
   ELSE
      hBitmap := HMG_Graph( nImageWidth, nImageHeight, aData,  cTitle, aYValues, nBarDepth, nBarWidth, nil, RED, nHValues, l3d, lGrid, lXGrid, lYGrid, ;
         lXVal, lYVal, lLegends, aSeries, aColors, nGraphType, lViewVal, cPicture, nLegendWidth, lNoBorder )
   ENDIF

   BT_HMGSetImage( "graph", "grapharea", hBitmap, .T. )

RETURN NIL

FUNCTION HMG_Graph( nWidth, nHeight, aData, cTitle, aYVals, nBarD, nWideB, nSep, aTitleColor, nXRanges, ;
      l3D, lGrid, lxGrid, lyGrid, lxVal, lyVal, lLegends, aSeries, aColors, nType, lViewVal, cPicture, nLegendWindth, lNoborder )

   LOCAL nI, nJ, nPos, nMax, nMin, nMaxBar, nDeep
   LOCAL nRange, nResH, nResV,  nWide, aPoint, cName
   LOCAL nXMax, nXMin, nHigh, nRel, nZero, nRPos, nRNeg
   LOCAL hBitMap, hDC, BTStruct
   LOCAL nTop := 0
   LOCAL nLeft := 0
   LOCAL nBottom := nHeight
   LOCAL nRight := nWidth

   DEFAULT cTitle   := ""
   DEFAULT nSep     := 0
   DEFAULT cPicture := "999,999.99"
   DEFAULT nLegendWindth := 50

   IF ( Len ( aSeries ) != Len ( aData ) ) .OR. ;
         ( Len ( aSeries ) != Len ( aColors ) )
      MsgMiniGuiError( "DRAW GRAPH: 'Series' / 'SerieNames' / 'Colors' arrays size mismatch." )
   ENDIF

   hBitMap := BT_BitmapCreateNew ( nWidth, nHeight, { 255, 255, 255 } )
   hDC := BT_CreateDC( hBitMap, BT_HDC_BITMAP, @BTStruct )

   IF lGrid
      lxGrid := lyGrid := .T.
   ENDIF

   IF nBottom <> NIL .AND. nRight <> NIL
      nHeight := nBottom - nTop / 2
      nWidth  := nRight - nLeft / 2
      nBottom -= IF( lyVal, 42, 32 )
      nRight  -= IF( lLegends, 32 + nLegendWindth, 32 )
   ENDIF
   nTop    += 1 + IF( Empty( cTitle ), 30, 44 )             // Top gap
   nLeft   += 1 + IF( lxVal, 80 + nBarD, 30 + nBarD )     // LEFT
   DEFAULT nBottom := nHeight - 2 - IF( lyVal, 40, 30 )    // Bottom
   DEFAULT nRight  := nWidth - 2 - IF( lLegends, 30 + nLegendWindth, 30 ) // RIGHT

   l3D     := IF( nType == POINTS, .F., l3D )
   nDeep   := IF( l3D, nBarD, 1 )
   nMaxBar := nBottom - nTop - nDeep - 5
   nResH   := nResV := 1
   nWide   := ( nRight - nLeft ) * nResH / ( nMax( aData ) + 1 ) * nResH

   // Graph area
   //
   IF ! lNoborder
      DrawWindowBoxInBitMap( hDC, Max( 1, nTop - 44 ), Max( 1, nLeft - 80 - nBarD ), nHeight - 1, nWidth - 1 )
   ENDIF

   // Back area
   //
   IF l3D
      DrawRectInBitmap( hDC, nTop + 1, nLeft, nBottom - nDeep, nRight, { 255, 255, 255 } )
   ELSE
      DrawRectInBitmap( hDC, nTop - 5, nLeft, nBottom, nRight, { 255, 255, 255 } )
   ENDIF

   IF l3D
      // Bottom area
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nBottom - nI, nLeft - nDeep + nI, nBottom - nI, nRight - nDeep + nI, { 255, 255, 255 } )
      NEXT nI

      // Lateral
      FOR nI := 1 TO nDeep
         DrawLineInBitmap( hDC, nTop + nI, nLeft - nI, nBottom - nDeep + nI, nLeft - nI, { 192, 192, 192 } )
      NEXT nI

      // Graph borders
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nBottom - nI, nLeft - nDeep + nI - 1, nBottom - nI, nLeft - nDeep + nI, GRAY )
         DrawLineInBitmap( hDC, nBottom - nI, nRight - nDeep + nI - 1, nBottom - nI, nRight - nDeep + nI, BLACK )
         DrawLineInBitmap( hDC, nTop + nDeep - nI + 1, nLeft - nDeep + nI - 1, nTop + nDeep - nI + 1, nLeft - nDeep + nI, BLACK )
         DrawLineInBitmap( hDC, nTop + nDeep - nI + 1, nLeft - nDeep + nI - 3, nTop + nDeep - nI + 1, nLeft - nDeep + nI - 2, BLACK )
      NEXT nI

      FOR nI = 1 TO nDeep + 2
         DrawLineInBitmap( hDC, nTop + nDeep - nI + 1, nLeft - nDeep + nI - 3, nTop + nDeep - nI + 1, nLeft - nDeep + nI - 2, BLACK )
         DrawLineInBitmap( hDC, nBottom + 2 -nI + 1, nRight - nDeep + nI, nBottom + 2 -nI + 1, nRight - nDeep + nI - 2, BLACK )
      NEXT nI

      DrawLineInBitmap( hDC, nTop, nLeft, nTop, nRight, BLACK )
      DrawLineInBitmap( hDC, nTop - 2, nLeft, nTop - 2, nRight + 2, BLACK )
      DrawLineInBitmap( hDC, nTop, nLeft, nBottom - nDeep, nLeft, GRAY  )
      DrawLineInBitmap( hDC, nTop + nDeep, nLeft - nDeep, nBottom, nLeft - nDeep, BLACK )
      DrawLineInBitmap( hDC, nTop + nDeep, nLeft - nDeep - 2, nBottom + 2, nLeft - nDeep - 2, BLACK )
      DrawLineInBitmap( hDC, nTop, nRight, nBottom - nDeep, nRight, BLACK )
      DrawLineInBitmap( hDC, nTop - 2, nRight + 2, nBottom - nDeep + 2, nRight + 2, BLACK )
      DrawLineInBitmap( hDC, nBottom - nDeep, nLeft, nBottom - nDeep, nRight, GRAY  )
      DrawLineInBitmap( hDC, nBottom, nLeft - nDeep, nBottom, nRight - nDeep, BLACK )
      DrawLineInBitmap( hDC, nBottom + 2, nLeft - nDeep - 2, nBottom + 2, nRight - nDeep, BLACK )
   ENDIF

   // Graph info
   //
   IF !Empty( cTitle )
      DrawTextInBitmap( hDC, nTop - 30 * nResV, nLeft + nWidth / 3, cTitle, 'Arial', 12, aTitleColor, 2 )
   ENDIF

   // Legends
   //
   IF lLegends
      nPos := nTop
      FOR nI := 1 TO Len( aSeries )
         DrawBarinbitmap( hDC, nRight + ( 8 * nResH ), nPos + ( 9 * nResV ), 8 * nResH, 7 * nResV, l3D, 1, aColors[ nI ] )
         DrawTextInBitmap( hDC, nPos, nRight + ( 20 * nResH ), aSeries[ nI ], 'Arial', 8, BLACK, 0 )
         nPos += 18 * nResV
      NEXT nI
   ENDIF

   // Max, Min values
   nMax := 0
   FOR nJ := 1 TO Len( aSeries )
      FOR nI := 1 TO Len( aData[ nJ ] )
         nMax := Max( aData[ nJ ][ nI ], nMax )
      NEXT nI
   NEXT nJ
   nMin := 0
   FOR nJ := 1 TO Len( aSeries )
      FOR nI := 1 TO Len( aData[ nJ ] )
         nMin := Min( aData[ nJ ][ nI ], nMin )
      NEXT nI
   NEXT nJ

   nXMax := IF( nMax > 0, DetMaxVal( nMax ), 0 )
   nXMin := IF( nMin < 0, DetMaxVal( nMin ), 0 )
   nHigh := nXMax + nXMin
   nMax  := Max( nXMax, nXMin )

   nRel  := ( nMaxBar / nHigh )
   nMaxBar := nMax * nRel

   nZero := nTop + ( nMax * nRel ) + nDeep + 5    // Zero pos
   IF l3D
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nZero - nI + 1, nLeft - nDeep + nI, nZero - nI + 1, nRight - nDeep + nI, { 192, 192, 192 } )
      NEXT nI
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nZero - nI + 1, nLeft - nDeep + nI - 1, nZero - nI + 1, nLeft - nDeep + nI, GRAY )
         DrawLineInBitmap( hDC, nZero - nI + 1, nRight - nDeep + nI - 1, nZero - nI + 1, nRight - nDeep + nI, BLACK )
      NEXT nI
      DrawLineInBitmap( hDC, nZero - nDeep, nLeft, nZero - nDeep, nRight, GRAY )
   ENDIF

   aPoint := Array( Len( aSeries ), Len( aData[ 1 ] ), 2 )
   nRange := nMax / nXRanges

   // xLabels
   nRPos := nRNeg := nZero - nDeep
   FOR nI := 0 TO nXRanges
      IF lxVal
         IF nRange * nI <= nXMax
            DrawTextInBitmap( hDC, nRPos, nLeft - nDeep - 70, Transform( nRange * nI, cPicture ), 'Arial', 8, BLUE )
         ENDIF
         IF nRange * ( -nI ) >= nXMin * ( -1 )
            DrawTextInBitmap( hDC, nRNeg, nLeft - nDeep - 70, Transform( nRange *- nI, cPicture ), 'Arial', 8, BLUE )
         ENDIF
      ENDIF

      IF lxGrid
         IF nRange * nI <= nXMax
            IF l3D
               FOR nJ := 0 TO nDeep + 1
                  DrawLineInBitmap( hDC, nRPos + nJ, nLeft - nJ - 1, nRPos + nJ, nLeft - nJ, BLACK )
               NEXT nJ
            ENDIF
            DrawLineInBitmap( hDC, nRPos, nLeft, nRPos, nRight, BLACK )
         ENDIF
         IF nRange *- nI >= nXMin *- 1
            IF l3D
               FOR nJ := 0 TO nDeep + 1
                  DrawLineInBitmap( hDC, nRNeg + nJ, nLeft - nJ - 1, nRNeg + nJ, nLeft - nJ, BLACK )
               NEXT nJ
            ENDIF
            DrawLineInBitmap( hDC, nRNeg, nLeft, nRNeg, nRight, BLACK )
         ENDIF
      ENDIF
      nRPos -= ( nMaxBar / nXRanges )
      nRNeg += ( nMaxBar / nXRanges )
   NEXT nI

   IF lYGrid .and. nType <> BARS 
      nPos := IF( l3D, nTop, nTop - 5 )
      nI  := nLeft + nWide
      FOR nJ := 1 TO nMax( aData )
         DrawLineInBitmap( hDC, nBottom - nDeep, nI, nPos, nI, { 100, 100, 100 } )
         DrawLineInBitmap( hDC, nBottom, nI - nDeep, nBottom - nDeep, nI, { 100, 100, 100 } )
         nI += nWide
      NEXT
   ENDIF

   DO WHILE .T.    // Bar adjust
      nPos = nLeft + ( nWide / 2 )
      nPos += ( nWide + nSep ) * ( Len( aSeries ) + 1 ) * Len( aData[ 1 ] )
      IF nPos > nRight
         nWide--
      ELSE
         EXIT
      ENDIF
   ENDDO

   nMin := nMax / nMaxBar

   nPos := nLeft + ( ( nWide + nSep ) / 2 )            // first point graph
   nRange := ( ( nWide + nSep ) * Len( aSeries ) ) / 2

   IF lyVal .AND. Len( aYVals ) > 0                // Show yLabels
      nWideB  := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
      nI := nLeft + nWideB
      FOR nJ := 1 TO nMax( aData )
         cName := "yVal_Name_" + LTrim( Str( nJ ) )
         DrawTextInBitmap( hDC, nBottom + 8, nI - nDeep - IF( l3D, 0, 8 ), aYVals[ nJ ], 'Arial', 8, BLUE )
         nI += nWideB
      NEXT
   ENDIF

   IF lYGrid .and. nType == BARS 
      nPos := IF( l3D, nTop, nTop-5 )
      nI  := nLeft + ( ( nWide + nSep ) / 2 ) + nWide
      FOR nJ := 1 TO nMax( aData )
         DrawLineInBitmap( hDC, nBottom-nDeep, nI - nWide , nPos, nI - nWide, {100,100,100} )
         DrawLineInBitmap( hDC, nBottom, nI-nDeep - nWide , nBottom-nDeep, nI - nWide, {100,100,100} )
         nI += ( Len( aSeries ) + 1 ) * ( nWide + nSep )
      NEXT
   ENDIF

   // Bars
   //
   IF nType == BARS
      IF nMin <> 0
         nPos := nLeft + ( ( nWide + nSep ) / 2 )
         FOR nI = 1 TO Len( aData[ 1 ] )
            FOR nJ = 1 TO Len( aSeries )
               DrawBarinbitmap( hDC, nPos, nZero, aData[ nJ, nI ] / nMin + nDeep, nWide, l3D, nDeep, aColors[ nJ ] )
               nPos += nWide + nSep
            NEXT nJ
            nPos += nWide + nSep
         NEXT nI
      ENDIF
   ENDIF

   // Lines
   //
   IF nType == LINES
      IF nMin <> 0
         nWideB  := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
         nPos := nLeft + nWideB
         FOR nI := 1 TO Len( aData[ 1 ] )
            FOR nJ = 1 TO Len( aSeries )
               IF !l3D
                  DrawPointinBitmap( hDC, nType, nPos, nZero, aData[ nJ, nI ] / nMin + nDeep, aColors[ nJ ] )
               ENDIF
               aPoint[ nJ, nI, 2 ] := nPos
               aPoint[ nJ, nI, 1 ] := nZero - ( aData[ nJ, nI ] / nMin + nDeep )
            NEXT nJ
            nPos += nWideB
         NEXT nI

         FOR nI := 1 TO Len( aData[ 1 ] ) -1
            FOR nJ := 1 TO Len( aSeries )
               IF l3D
                  drawpolygoninbitmap( hDC, { { aPoint[ nJ, nI, 1 ], aPoint[ nJ, nI, 2 ] }, { aPoint[ nJ, nI + 1, 1 ], aPoint[ nJ, nI + 1, 2 ] }, ;
                     { aPoint[ nJ, nI + 1, 1 ] -nDeep, aPoint[ nJ, nI + 1, 2 ] + nDeep }, { aPoint[ nJ, nI, 1 ] -nDeep, aPoint[ nJ, nI, 2 ] + nDeep }, ;
                     { aPoint[ nJ, nI, 1 ], aPoint[ nJ, nI, 2 ] } },,, aColors[ nJ ] )
               ELSE
                  DrawLineInBitmap( hDC, aPoint[ nJ, nI, 1 ], aPoint[ nJ, nI, 2 ], aPoint[ nJ, nI + 1, 1 ], aPoint[ nJ, nI + 1, 2 ], aColors[ nJ ] )
               ENDIF
            NEXT nJ
         NEXT nI

      ENDIF
   ENDIF

   // Points
   //
   IF nType == POINTS
      IF nMin <> 0
         nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
         nPos := nLeft + nWideB
         FOR nI := 1 TO Len( aData[ 1 ] )
            FOR nJ = 1 TO Len( aSeries )
               DrawPointinBitmap( hDC, nType, nPos, nZero, aData[ nJ, nI ] / nMin + nDeep, aColors[ nJ ] )
               aPoint[ nJ, nI, 2 ] := nPos
               aPoint[ nJ, nI, 1 ] := nZero - aData[ nJ, nI ] / nMin
            NEXT nJ
            nPos += nWideB
         NEXT nI
      ENDIF
   ENDIF

   IF lViewVal
      IF nType == BARS
         nPos := nLeft + nWide + ( ( nWide + nSep ) * ( Len( aSeries ) / 2 ) )
      ELSE
         nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
         nPos := nLeft + nWideB
      ENDIF
      FOR nI := 1 TO Len( aData[ 1 ] )
         FOR nJ := 1 TO Len( aSeries )
            DrawTextInBitmap( hDC, nZero - ( aData[ nJ, nI ] / nMin + nDeep + 18 ), IF( nType == BARS, nPos - IF( l3D, 44, 46 ), nPos + 10 ), Transform( aData[ nJ, nI ], cPicture ), 'Arial', 8 )
            nPos += IF( nType == BARS, nWide + nSep, 0 )
         NEXT nJ
         IF nType == BARS
            nPos += nWide + nSep
         ELSE
            nPos += nWideB
         ENDIF
      NEXT nI
   ENDIF

   IF l3D
      DrawLineInBitmap( hDC, nZero, nLeft - nDeep, nZero, nRight - nDeep, BLACK )
   ELSE
      IF nXMax <> 0 .AND. nXMin <> 0
         DrawLineInBitmap( hDC, nZero - 1, nLeft - 2, nZero - 1, nRight, RED )
      ENDIF

   ENDIF

   BT_DeleteDC( BTstruct )

RETURN hBitmap


PROCEDURE DrawWindowBoxInBitmap( hDC, row, col, rowr, colr, nPenWidth )
   BT_DrawRectangle ( hDC, Row, Col, Colr - col, rowr - row, { 0, 0, 0 }, nPenWidth )

RETURN

PROCEDURE DrawRectInBitmap( hDC, row, col, row1, col1, aColor, nPenWidth )
   BT_DrawFillRectangle ( hDC, Row, Col, col1 - col, row1 - row, aColor, aColor, nPenWidth )

RETURN

PROCEDURE DrawLineInBitmap( hDC, Row1, Col1, Row2, Col2, aColor, nPenWidth )
   BT_DrawLine ( hDC, Row1, Col1, Row2, Col2, aColor, nPenWidth )

RETURN

PROCEDURE DrawTextInBitmap( hDC, Row, Col, cText, cFontName, nFontSize, aColor, nAlign )
   DEFAULT nAlign := 0
   DO CASE
   CASE nAlign == 0
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , BT_TEXT_TRANSPARENT )
   CASE nAlign == 1
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , , BT_TEXT_RIGHT + BT_TEXT_TOP )
   CASE nAlign == 2
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , , BT_TEXT_CENTER + BT_TEXT_TOP )
   ENDCASE

RETURN

PROCEDURE DrawBarInBitmap( hDC, nY, nX, nHigh, nWidth, l3DView, nDeep, aColor )

   LOCAL nColTop, nShadow, nShadow2, nH := nHigh
   
   nColTop := ClrShadow( RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] ), 20 )
   nShadow := ClrShadow( nColTop, 20 )
   nShadow2 := ClrShadow( nColTop, 40 )
   nColTop := { GetRed( nColTop ), GetGreen( nColTop ), GetBlue( nColTop ) }
   nShadow := { GetRed( nShadow ), GetGreen( nShadow ), GetBlue( nShadow ) }
   nShadow2 := { GetRed( nShadow2 ), GetGreen( nShadow2 ), GetBlue( nShadow2 ) }
   BT_DrawGradientFillVertical( hDC, nX + nDeep - nHigh, nY, nWidth + 1, nHigh - nDeep, aColor, nShadow2 )
   IF l3DView
      // Lateral
      DrawPolygonInBitmap( hDC, { { nX - 1, nY + nWidth + 1 }, { nX + nDeep - nHigh, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nDeep, nY + nWidth + nDeep }, ;
         { nX - 1, nY + nWidth + 1 } }, nShadow,, nShadow )
      // Superior
      nHigh   := Max( nHigh, nDeep )
      DrawPolygonInBitmap( hDC, { { nX - nHigh + nDeep, nY + 1 }, { nX - nHigh + nDeep, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nHigh + 1, nY + nDeep }, ;
         { nX - nHigh + nDeep, nY + 1 } }, nColTop,, nColTop )
      // Border
      DrawBoxInBitmap( hDC, nY, nX, nH, nWidth, l3DView, nDeep )
   ENDIF

RETURN

STATIC FUNCTION ClrShadow( nColor, nFactor )

   LOCAL aHSL, aRGB

   aHSL := RGB2HSL( GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) )
   aHSL[ 3 ] -= nFactor
   aRGB := HSL2RGB( aHSL[ 1 ], aHSL[ 2 ], aHSL[ 3 ] )

RETURN RGB( aRGB[ 1 ], aRGB[ 2 ], aRGB[ 3 ] )

STATIC FUNCTION nMax( aData )

   LOCAL nI, nMax := 0

   FOR nI := 1 TO Len( aData )
      nMax := Max( Len( aData[ nI ] ), nMax )
   NEXT nI

RETURN( nMax )

STATIC FUNCTION DetMaxVal( nNum )

   LOCAL nE, nMax, nMan, nVal, nOffset

   nE := 9
   nVal := 0
   nNum := Abs( nNum )

   DO WHILE .T.

      nMax := 10 ** nE

      IF Int( nNum / nMax ) > 0

         nMan := ( nNum / nMax ) -Int( nNum / nMax )
         nOffset := 1
         nOffset := IF( nMan <= .75, .75, nOffset )
         nOffset := IF( nMan <= .50, .50, nOffset )
         nOffset := IF( nMan <= .25, .25, nOffset )
         nOffset := IF( nMan <= .00, .00, nOffset )
         nVal := ( Int( nNum / nMax ) + nOffset ) * nMax
         EXIT

      ENDIF

      nE--

   ENDDO

RETURN ( nVal )

PROCEDURE DrawPointInBitmap( hDC, nType, nY, nX, nHigh, aColor )

   IF nType == POINTS
      DrawCircleinBitmap( hDC, nX - nHigh - 3, nY - 3, 8, aColor )
   ELSEIF nType == LINES
      DrawCircleinBitmap( hDC, nX - nHigh - 2, nY - 2, 6, aColor )
   ENDIF

RETURN

PROCEDURE DrawCircleInBitmap( hDC, nCol, nRow, nWidth, aColor, nPenWidth )
   BT_DrawFillEllipse( hDC, nCol, nRow, nWidth, nWidth, aColor, aColor, nPenWidth )

RETURN


FUNCTION HMG_PieGraph( nWidth, nHeight, series, aname, colors, ctitle, aTitleColor, depth, l3d, lxval, lsleg, lnoborder )

   LOCAL fromrow := 0
   LOCAL fromcol := 0
   LOCAL torow := nHeight
   LOCAL tocol := nWidth
   LOCAL topleftrow := fromrow
   LOCAL topleftcol := fromcol
   LOCAL toprightrow := fromrow
   LOCAL toprightcol := tocol
   LOCAL bottomrightrow := torow
   LOCAL bottomrightcol := tocol
   LOCAL bottomleftrow := torow
   LOCAL bottomleftcol := fromcol
   LOCAL middletoprow := fromrow
   LOCAL middletopcol := fromcol + Int( tocol - fromcol ) / 2
   LOCAL middleleftrow := fromrow + Int( torow - fromrow ) / 2
   LOCAL middleleftcol := fromcol
   LOCAL middlebottomrow := torow
   LOCAL middlebottomcol := fromcol + Int( tocol - fromcol ) / 2
   LOCAL middlerightrow := fromrow + Int( torow - fromrow ) / 2
   LOCAL middlerightcol := tocol
   LOCAL fromradialrow := 0
   LOCAL fromradialcol := 0
   LOCAL toradialrow := 0
   LOCAL toradialcol := 0
   LOCAL degrees := {}
   LOCAL cumulative := {}
   LOCAL j, i, sum := 0
   LOCAL cname := ""
   LOCAL shadowcolor := {}
   LOCAL previos_cumulative
   LOCAL hDC, hBitMap, BTStruct

   hBitMap := BT_BitmapCreateNew ( nWidth, nHeight, { 255, 255, 255 } )
   hDC := BT_CreateDC( hBitMap, BT_HDC_BITMAP, @BTStruct )

   IF ! lnoborder
      DrawWindowBoxInBitMap( hDC, fromrow, fromcol, torow - 1, tocol - 1 )
   ENDIF

   IF Len( AllTrim( ctitle ) ) > 0
      DrawTextInBitmap( hDC, fromrow + 10, iif( Len( AllTrim( ctitle ) ) * 12 > ( tocol - fromcol ), fromcol, Int( ( ( tocol - fromcol ) - ( Len( AllTrim( ctitle ) ) * 12 ) ) / 2 ) + fromcol ), AllTrim( ctitle ), 'Arial', 12, aTitleColor )
      fromrow := fromrow + 40
   ENDIF

   IF lsleg
      IF Len( aname ) * 20 > ( torow - fromrow )
         msginfo( "No space for showing legends" )
      ELSE
         torow := torow - ( Len( aname ) * 20 )
      ENDIF
   ENDIF

   drawrectinbitmap( hDC, fromrow + 10, fromcol + 10, torow - 10, tocol - 10, { 255, 255, 255 } )

   IF l3d
      torow := torow - depth
   ENDIF

   fromcol := fromcol + 25
   tocol := tocol - 25
   torow := torow - 25
   fromrow := fromrow + 25

   topleftrow := fromrow
   topleftcol := fromcol
   toprightrow := fromrow
   toprightcol := tocol
   bottomrightrow := torow
   bottomrightcol := tocol
   bottomleftrow := torow
   bottomleftcol := fromcol
   middletoprow := fromrow
   middletopcol := fromcol + Int( tocol - fromcol ) / 2
   middleleftrow := fromrow + Int( torow - fromrow ) / 2
   middleleftcol := fromcol
   middlebottomrow := torow
   middlebottomcol := fromcol + Int( tocol - fromcol ) / 2
   middlerightrow := fromrow + Int( torow - fromrow ) / 2
   middlerightcol := tocol

   torow := torow + 1
   tocol := tocol + 1

   FOR i := 1 TO Len( series )
      sum := sum + series[ i ]
   NEXT i
   FOR i := 1 TO Len( series )
      AAdd( degrees, Round( series[ i ] / sum * 360, 0 ) )
   NEXT i
   sum := 0
   FOR i := 1 TO Len( degrees )
      sum := sum + degrees[ i ]
   NEXT i
   IF sum <> 360
      degrees[ Len( degrees ) ] := degrees[ Len( degrees ) ] + ( 360 - sum )
   ENDIF

   sum := 0
   FOR i := 1 TO Len( degrees )
      sum := sum + degrees[ i ]
      AAdd( cumulative, sum )
   NEXT i

   previos_cumulative := -1

   fromradialrow := middlerightrow
   fromradialcol := middlerightcol
   FOR i := 1 TO Len( cumulative )

      IF cumulative[ i ] == previos_cumulative
         LOOP
      ENDIF

      previos_cumulative := cumulative[ i ]

      shadowcolor := { iif( colors[ i, 1 ] > 50, colors[ i, 1 ] - 50, 0 ), iif( colors[ i, 2 ] > 50, colors[ i, 2 ] - 50, 0 ), iif( colors[ i, 3 ] > 50, colors[ i, 3 ] - 50, 0 ) }

      DO CASE
      CASE cumulative[ i ] <= 45
         toradialcol := middlerightcol
         toradialrow := middlerightrow - Round( cumulative[ i ] / 45 * ( middlerightrow - toprightrow ), 0 )
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 90 .AND. cumulative[ i ] > 45
         toradialrow := toprightrow
         toradialcol := toprightcol - Round( ( cumulative[ i ] - 45 ) / 45 * ( toprightcol - middletopcol ), 0 )
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 135 .AND. cumulative[ i ] > 90
         toradialrow := topleftrow
         toradialcol := middletopcol - Round( ( cumulative[ i ] - 90 ) / 45 * ( middletopcol - topleftcol ), 0 )
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 180 .AND. cumulative[ i ] > 135
         toradialcol := topleftcol
         toradialrow := topleftrow + Round( ( cumulative[ i ] - 135 ) / 45 * ( middleleftrow - topleftrow ), 0 )
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 225 .AND. cumulative[ i ] > 180
         toradialcol := topleftcol
         toradialrow := middleleftrow + Round( ( cumulative[ i ] - 180 ) / 45 * ( bottomleftrow - middleleftrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcinBitMap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 270 .AND. cumulative[ i ] > 225
         toradialrow := bottomleftrow
         toradialcol := bottomleftcol + Round( ( cumulative[ i ] - 225 ) / 45 * ( middlebottomcol - bottomleftcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcinbitmap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 315 .AND. cumulative[ i ] > 270
         toradialrow := bottomleftrow
         toradialcol := middlebottomcol + Round( ( cumulative[ i ] - 270 ) / 45 * ( bottomrightcol - middlebottomcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcinBitMap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[ i ] <= 360 .AND. cumulative[ i ] > 315
         toradialcol := bottomrightcol
         toradialrow := bottomrightrow - Round( ( cumulative[ i ] - 315 ) / 45 * ( bottomrightrow - middlerightrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcinBitMap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieinbitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol,,, colors[ i ] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      ENDCASE
      IF l3d
         drawlineinbitmap( hDC, middleleftrow, middleleftcol, middleleftrow + depth, middleleftcol, { 0, 0, 0 } )
         drawlineinbitmap( hDC, middlerightrow, middlerightcol, middlerightrow + depth, middlerightcol, { 0, 0, 0 } )
         drawarcinBitMap( hDC, fromrow + depth, fromcol, torow + depth, tocol, middleleftrow + depth, middleleftcol, middlerightrow + depth, middlerightcol )
      ENDIF
   NEXT i
   IF lsleg
      fromrow := torow + 20 + iif( l3d, depth, 0 )
      FOR i := 1 TO Len( aname )
         drawrectinbitmap( hDC, fromrow, fromcol, fromrow + 15, fromcol + 15, colors[ i ] )
         drawtextinbitmap( hDC, fromrow, fromcol + 20, aname[ i ] + iif( lxval, " - " + AllTrim( Str( series[ i ], 19, 2 ) ) + " (" + AllTrim( Str( degrees[ i ] / 360 * 100, 6, 2 ) ) + " %)", "" ), 'Arial', 8, colors[ i ] )
         fromrow := fromrow + 20
      NEXT i
   ENDIF

   BT_DeleteDC( BTstruct )

RETURN hBitmap

PROCEDURE DrawArcInBitmap( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )
   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF

   BT_DrawArc ( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )

RETURN

PROCEDURE DrawPieInBitmap( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb )
   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF

   BT_DrawPie ( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb )

RETURN

PROCEDURE DrawPolygonInBitmap( hDC, apoints, penrgb, penwidth, fillrgb )

   LOCAL xarr := {}
   LOCAL yarr := {}
   LOCAL x := 0
   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF
   FOR x := 1 TO Len( apoints )
      AAdd( xarr, apoints[ x, 2 ] )
      AAdd( yarr, apoints[ x, 1 ] )
   NEXT x

   BT_DrawPolygon ( hDC, yarr, xarr, penrgb, penwidth, fillrgb )

RETURN

STATIC FUNCTION RGB2HSL( nR, nG, nB )

   LOCAL nMax, nMin
   LOCAL nH, nS, nL

   IF nR < 0
      nR := Abs( nR )
      nG := GetGreen( nR )
      nB := GetBlue( nR )
      nR := GetRed( nR )
   ENDIF

   nR := nR / 255
   nG := nG / 255
   nB := nB / 255
   nMax := Max( nR, Max( nG, nB ) )
   nMin := Min( nR, Min( nG, nB ) )
   nL := ( nMax + nMin ) / 2

   IF nMax = nMin
      nH := 0
      nS := 0
   ELSE
      IF nL < 0.5
         nS := ( nMax - nMin ) / ( nMax + nMin )
      ELSE
         nS := ( nMax - nMin ) / ( 2.0 - nMax - nMin )
      ENDIF
      DO CASE
      CASE nR = nMax
         nH := ( nG - nB ) / ( nMax - nMin )
      CASE nG = nMax
         nH := 2.0 + ( nB - nR ) / ( nMax - nMin )
      CASE nB = nMax
         nH := 4.0 + ( nR - nG ) / ( nMax - nMin )
      ENDCASE
   ENDIF

   nH := Int( ( nH * 239 ) / 6 )
   IF nH < 0 ; nH += 240 ; ENDIF
   nS := Int( nS * 239 )
   nL := Int( nL * 239 )

RETURN { nH, nS, nL }


STATIC FUNCTION HSL2RGB( nH, nS, nL )

   LOCAL nFor
   LOCAL nR, nG, nB
   LOCAL nTmp1, nTmp2, aTmp3 := { 0, 0, 0 }

   nH /= 239
   nS /= 239
   nL /= 239
   IF nS == 0
      nR := nL
      nG := nL
      nB := nL
   ELSE
      IF nL < 0.5
         nTmp2 := nL * ( 1 + nS )
      ELSE
         nTmp2 := nL + nS - ( nL * nS )
      ENDIF
      nTmp1 := 2 * nL - nTmp2
      aTmp3[ 1 ] := nH + 1 / 3
      aTmp3[ 2 ] := nH
      aTmp3[ 3 ] := nH - 1 / 3
      FOR nFor := 1 TO 3
         IF aTmp3[ nFor ] < 0
            aTmp3[ nFor ] += 1
         ENDIF
         IF aTmp3[ nFor ] > 1
            aTmp3[ nFor ] -= 1
         ENDIF
         IF 6 * aTmp3[ nFor ] < 1
            aTmp3[ nFor ] := nTmp1 + ( nTmp2 - nTmp1 ) * 6 * aTmp3[ nFor ]
         ELSE
            IF 2 * aTmp3[ nFor ] < 1
               aTmp3[ nFor ] := nTmp2
            ELSE
               IF 3 * aTmp3[ nFor ] < 2
                  aTmp3[ nFor ] := nTmp1 + ( nTmp2 - nTmp1 ) * ( ( 2 / 3 ) - aTmp3[ nFor ] ) * 6
               ELSE
                  aTmp3[ nFor ] := nTmp1
               ENDIF
            ENDIF
         ENDIF
      NEXT nFor
      nR := aTmp3[ 1 ]
      nG := aTmp3[ 2 ]
      nB := aTmp3[ 3 ]
   ENDIF

RETURN { Int( nR * 255 ), Int( nG * 255 ), Int( nB * 255 ) }


STATIC PROC DrawBoxinBitmap( hDC, nY, nX, nHigh, nWidth, l3D, nDeep )

   // Set Border
   DrawLineinbitmap( hDC, nX, nY, nX - nHigh + nDeep, nY, BLACK )  // LEFT
   DrawLineinbitmap( hDC, nX, nY + nWidth, nX - nHigh + nDeep, nY + nWidth, BLACK )  // RIGHT
   DrawLineinbitmap( hDC, nX - nHigh + nDeep, nY, nX - nHigh + nDeep, nY + nWidth, BLACK )  // Top
   DrawLineinbitmap( hDC, nX, nY, nX, nY + nWidth, BLACK )                          // Bottom
   IF l3D
      // Set shadow
      DrawLineinbitmap( hDC, nX - nHigh + nDeep, nY + nWidth, nX - nHigh, nY + nDeep + nWidth, BLACK )
      DrawLineinbitmap( hDC, nX, nY + nWidth, nX - nDeep, nY + nWidth + nDeep, BLACK )
      IF nHigh > 0
         DrawLineinbitmap( hDC, nX - nDeep, nY + nWidth + nDeep, nX - nHigh, nY + nWidth + nDeep, BLACK )
         DrawLineinbitmap( hDC, nX - nHigh, nY + nDeep, nX - nHigh, nY + nWidth + nDeep, BLACK )
         DrawLineinbitmap( hDC, nX - nHigh + nDeep, nY, nX - nHigh, nY + nDeep, BLACK )
      ELSE
         DrawLineinbitmap( hDC, nX - nDeep, nY + nWidth + nDeep, nX - nHigh + 1, nY + nWidth + nDeep, BLACK )
         DrawLineinbitmap( hDC, nX, nY, nX - nDeep, nY + nDeep, BLACK )
      ENDIF
   ENDIF

RETURN
