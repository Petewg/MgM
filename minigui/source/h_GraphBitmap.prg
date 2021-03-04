/*
 * (c) Alfredo Arteaga, 2001-2002 ( Original Idea )
 *
 * (c) Grigory Filatov, 2003-2004 ( Translation for MiniGUI )
 *
 * (c) Siri Rathinagiri, 2016 ( Adaptation for Draw in Bitmap )
 */

#ifdef __XHARBOUR__
#pragma -w2
#define __MINIPRINT__
#endif

#include "hmg.ch"

#ifdef _HMG_COMPAT_

#define COLOR_WINDOWTEXT     8
#define COLOR_BTNFACE       15

*=============================================================================*
*                          Public Functions
*=============================================================================*


FUNCTION HMG_Graph( nWidth, nHeight, aData, cTitle, aYVals, nBarD, nWideB, nSep, aTitleColor, nXRanges, ;
      l3D, lGrid, lxGrid, lyGrid, lxVal, lyVal, lLegends, aSeries, aColors, nType, lViewVal, cPicture, nLegendsWidth, lNoborder )
                 
   LOCAL hBitmap, hDC, BTStruct
   LOCAL nTop := 0
   LOCAL nLeft := 0
   LOCAL nBottom := nHeight
   LOCAL nRight := nWidth
   LOCAL nI, nJ, nPos, nMax, nMin, nMaxBar, nDeep
   LOCAL nRange, nSeries, nResH, nResV, nWide, aPoint
   LOCAL nXMax, nXMin, nHigh, nRel, nZero, nRPos, nRNeg
   LOCAL nClrFore  := GetSysColor( COLOR_WINDOWTEXT ), lRedraw
   LOCAL aClrFore := nRGB2Arr( nClrFore )
   LOCAL nClrBack := GetSysColor( COLOR_BTNFACE )
   LOCAL aClrBack := nRGB2Arr( nClrBack )

   DEFAULT cTitle := "", nSep := 0, nLegendsWidth := 50, cPicture := "999,999.99"

   IF ( Len ( aSeries ) != Len ( aData ) ) .OR. ( Len ( aSeries ) > Len ( aColors ) )
      MsgMiniGuiError( "DRAW GRAPH: 'Series' / 'SerieNames' / 'Colors' arrays size mismatch." )
   ENDIF

   hBitmap := BT_BitmapCreateNew ( nWidth, nHeight, aClrBack )
   hDC := BT_CreateDC( hBitmap, BT_HDC_BITMAP, @BTStruct )

   IF lGrid
      lxGrid := lyGrid := .T.
   ENDIF

   IF nBottom <> NIL .AND. nRight <> NIL
      nHeight := nBottom - nTop / 2
      nWidth  := nRight - nLeft / 2
   ENDIF

   nTop    := nTop + 1 + iif( Empty( cTitle ), 30, 44 )                        // Top gap
   nLeft   := nLeft + 1 + iif( lxVal, 30 + nLegendsWidth + nBarD, 30 + nBarD ) // Left
   nBottom := nHeight - 2 - iif( lyVal, 40, 30 )                               // Bottom
   nRight  := nWidth - 2 - iif( lLegends, 30 + nLegendsWidth, 30 )             // Right

   l3D     := iif( nType == POINTS, .F., l3D )
   nDeep   := iif( l3D, nBarD, 1 )
   nMaxBar := nBottom - nTop - nDeep - 5
   nResH   := nResV := 1
   nWide   := ( nRight - nLeft ) * nResH / ( nMax( aData ) + 1 ) * nResH

   // Graph area
   //
   IF !lNoborder
      DrawWindowBoxInBitmap( hDC, Max( 1, nTop - 44 ), Max( 1, nLeft - 80 - nBarD ), nHeight - 1, nWidth - 1 )
   ENDIF

   // Back area
   //
   IF l3D
      drawrectInBitmap( hDC, nTop + 1, nLeft, nBottom - nDeep, nRight, WHITE )
   ELSE
      drawrectInBitmap( hDC, nTop - 5, nLeft, nBottom, nRight, WHITE )
   ENDIF

   IF l3D
      // Bottom area
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nBottom - nI, nLeft - nDeep + nI, nBottom - nI, nRight - nDeep + nI, WHITE )
      NEXT nI

      // Lateral
      FOR nI := 1 TO nDeep
         DrawLineInBitmap( hDC, nTop + nI, nLeft - nI, nBottom - nDeep + nI, nLeft - nI, SILVER )
      NEXT nI

      // Graph borders
      FOR nI := 1 TO nDeep+1
         DrawLineInBitmap( hDC, nBottom-nI     , nLeft-nDeep+nI-1 , nBottom-nI     , nLeft-nDeep+nI  , GRAY )
         DrawLineInBitmap( hDC, nBottom-nI     , nRight-nDeep+nI-1, nBottom-nI     , nRight-nDeep+nI , BLACK )
         DrawLineInBitmap( hDC, nTop+nDeep-nI+1, nLeft-nDeep+nI-1 , nTop+nDeep-nI+1, nLeft-nDeep+nI  , BLACK )
         DrawLineInBitmap( hDC, nTop+nDeep-nI+1, nLeft-nDeep+nI-3 , nTop+nDeep-nI+1, nLeft-nDeep+nI-2, BLACK )
      NEXT nI

      FOR nI := 1 TO nDeep+2
         DrawLineInBitmap( hDC, nTop+nDeep-nI+1, nLeft-nDeep+nI-3, nTop+nDeep-nI+1, nLeft-nDeep+nI-2 , BLACK )
         DrawLineInBitmap( hDC, nBottom+ 2-nI+1, nRight-nDeep+nI , nBottom+ 2-nI+1, nRight-nDeep+nI-2, BLACK )
      NEXT nI

      DrawLineInBitmap( hDC, nTop         , nLeft        , nTop           , nRight       , BLACK )
      DrawLineInBitmap( hDC, nTop- 2      , nLeft        , nTop- 2        , nRight+ 2    , BLACK )
      DrawLineInBitmap( hDC, nTop         , nLeft        , nBottom-nDeep  , nLeft        , GRAY  )
      DrawLineInBitmap( hDC, nTop+nDeep   , nLeft-nDeep  , nBottom        , nLeft-nDeep  , BLACK )
      DrawLineInBitmap( hDC, nTop+nDeep   , nLeft-nDeep-2, nBottom+ 2     , nLeft-nDeep-2, BLACK )
      DrawLineInBitmap( hDC, nTop         , nRight       , nBottom-nDeep  , nRight       , BLACK )
      DrawLineInBitmap( hDC, nTop- 2      , nRight+ 2    , nBottom-nDeep+2, nRight+ 2    , BLACK )
      DrawLineInBitmap( hDC, nBottom-nDeep, nLeft        , nBottom-nDeep  , nRight       , GRAY  )
      DrawLineInBitmap( hDC, nBottom      , nLeft-nDeep  , nBottom        , nRight-nDeep , BLACK )
      DrawLineInBitmap( hDC, nBottom+ 2   , nLeft-nDeep-2, nBottom+ 2     , nRight-nDeep , BLACK )
   ENDIF

   // Graph info
   //
   IF !Empty( cTitle )
      DrawTextInBitmap( hDC, nTop - 33 * nResV, ( nWidth - GetTextWidth( hDC, cTitle ) / iif( Len( cTitle ) > 40, 10, 12 ) ) / 2 + 1, cTitle, _HMG_DefaultFontName, _HMG_DefaultFontSize + 3, aTitleColor, 2 )
   ENDIF

   // Legends
   //
   IF lLegends
      nPos := nTop
      FOR nI := 1 TO Len( aSeries )
         DrawBarInBitmap( hDC, nRight + ( ( _HMG_DefaultFontSize - 1 ) * nResH ), nPos + _HMG_DefaultFontSize * nResV,;
            ( _HMG_DefaultFontSize - 1 ) * nResH, ( _HMG_DefaultFontSize - 2 ) * nResV, l3D, 1, aColors[nI] )
         DrawTextInBitmap( hDC, nPos, nRight + ( 4 + 2 * _HMG_DefaultFontSize ) * nResH, aSeries[ nI ], _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, aClrFore, 0 )
         nPos += ( _HMG_DefaultFontSize + 7 ) * nResV
      NEXT nI
   ENDIF

   // Max, Min values
   //
   nMax := nMin := 0
   FOR nJ := 1 TO Len( aSeries )
      FOR nI := 1 TO Len( aData[nJ] )
         nMax := Max( aData[nJ][nI], nMax )
         nMin := Min( aData[nJ][nI], nMin )
      NEXT nI
   NEXT nJ

   nXMax   := iif( nMax > 0, DetMaxVal( nMax ), 0 )
   nXMin   := iif( nMin < 0, DetMaxVal( nMin ), 0 )
   nHigh   := nXMax + nXMin
   nMax    := Max( nXMax, nXMin )

   nRel    := nMaxBar / nHigh
   nMaxBar := nMax * nRel

   // Zero position
   //
   IF nXMax > nXMin
      nZero := nTop + nMaxBar + nDeep + 5
   ELSE
      nZero := nBottom - nMaxBar - 5
   ENDIF
   IF l3D
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nZero - nI + 1, nLeft - nDeep + nI, nZero - nI + 1, nRight - nDeep + nI, SILVER )
      NEXT nI
      FOR nI := 1 TO nDeep + 1
         DrawLineInBitmap( hDC, nZero - nI + 1, nLeft - nDeep + nI - 1 , nZero - nI + 1, nLeft - nDeep + nI , GRAY )
         DrawLineInBitmap( hDC, nZero - nI + 1, nRight - nDeep + nI - 1, nZero - nI + 1, nRight - nDeep + nI, BLACK )
      NEXT nI
      DrawLineInBitmap( hDC, nZero - nDeep, nLeft, nZero - nDeep, nRight, GRAY )
   ENDIF

   aPoint := Array( Len( aSeries ), Len( aData[1] ), 2 )
   nRange := nMax / nXRanges

   // xLabels
   //
   nRPos := nRNeg := nZero - nDeep
   FOR nI := 0 TO nXRanges
      IF lxVal
         IF nRange * nI <= nXMax
            DrawTextInBitmap( hDC, nRPos, nLeft - nDeep - 70, Transform( nRange * nI, cPicture ), _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, aClrFore )
         ENDIF
         IF nRange * ( - nI ) >= nXMin * ( -1 )
           DrawTextInBitmap( hDC, nRNeg, nLeft - nDeep - 70, Transform( nRange *- nI, cPicture ), _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, aClrFore )
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

   IF lYGrid
      nPos := iif( l3D, nTop, nTop - 5 )
      nI := nLeft + nWide
      FOR nJ := 1 TO nMax( aData )
         DrawlineInBitmap( hDC, nBottom - nDeep, nI, nPos, nI, { 100, 100, 100 } )
         DrawlineInBitmap( hDC, nBottom, nI - nDeep, nBottom - nDeep, nI, { 100, 100, 100 } )
         nI += nWide
      NEXT
   ENDIF

   nRange := Len( aData[1] )
   nSeries := Len( aSeries )
   DO WHILE .T.    // Bar adjust
      nPos := nLeft + nWide / 2
      nPos += ( nWide + nSep ) * ( nSeries + 1 ) * nRange
      IF nPos > nRight
         nWide--
      ELSE
         EXIT
      ENDIF
   ENDDO

   nMin := nMax / nMaxBar
   nPos := nLeft + ( nWide + nSep ) / 2            // first point graph

   // yLabels
   //
   IF lyVal .AND. Len( aYVals ) > 0
      nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
      nI := nLeft + nWideB
      FOR nJ := 1 TO nMax( aData )
         DrawTextInBitmap( hDC, nBottom + 8, nI - iif( l3D, nDeep, nDeep + 8 ), aYVals[ nJ ], _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, aClrFore )
         nI += nWideB
      NEXT
   ENDIF

   // Bars
   //
   IF nType == BARS
      nPos := nLeft + ( nWide + nSep ) / 2
      lRedraw := ( nSeries == 1 .AND. Len( aColors ) >= nRange )
      FOR nI := 1 TO nRange
         FOR nJ := 1 TO nSeries
            DrawBarInBitmap( hDC, nPos, iif( l3D, nZero, nZero - 1 ), aData[nJ,nI] / nMin + nDeep, nWide, l3D, nDeep, ;
               aColors[ iif(lRedraw, nI, nJ) ] )
            nPos += nWide + nSep
         NEXT nJ
         nPos += nWide + nSep
      NEXT nI
   ENDIF

   // Lines
   //
   IF nType == LINES
      nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
      nPos := nLeft + nWideB
      FOR nI := 1 TO nRange
         FOR nJ := 1 TO nSeries
            IF !l3D
               DrawPointInBitmap( hDC, nType, nPos, nZero, aData[nJ,nI] / nMin + nDeep, aColors[nJ] )
            ENDIF
            aPoint[nJ,nI,2] := nPos
            aPoint[nJ,nI,1] := nZero - ( aData[nJ,nI] / nMin + nDeep )
         NEXT nJ
         nPos += nWideB
      NEXT nI

      FOR nI := 1 TO nRange - 1
         FOR nJ := 1 TO nSeries
            IF l3D
               drawpolygonInBitmap( hDC, { { aPoint[nJ,nI,1],aPoint[nJ,nI,2] }, { aPoint[nJ,nI+1,1],aPoint[nJ,nI+1,2] }, ;
                  { aPoint[nJ,nI+1,1] - nDeep, aPoint[nJ,nI+1,2] + nDeep }, { aPoint[nJ,nI,1] - nDeep, aPoint[nJ,nI,2] + nDeep }, ;
                  { aPoint[nJ,nI,1], aPoint[nJ,nI,2] } }, , , aColors[nJ] )
            ELSE
               DrawLineInBitmap( hDC, aPoint[nJ,nI,1], aPoint[nJ,nI,2], aPoint[nJ,nI+1,1], aPoint[nJ,nI+1,2], aColors[nJ] )
            ENDIF
         NEXT nI
      NEXT nI

   ENDIF

   // Points
   //
   IF nType == POINTS
      nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
      nPos := nLeft + nWideB
      FOR nI := 1 TO nRange
         FOR nJ := 1 TO nSeries
            DrawPointInBitmap( hDC, nType, nPos, nZero, aData[nJ,nI] / nMin + nDeep, aColors[nJ] )
         NEXT nJ
         nPos += nWideB
      NEXT nI
   ENDIF

   IF lViewVal
      IF nType == BARS
         nPos := nLeft + nWide + ( nWide + nSep ) * ( nSeries / 2 )
      ELSE
         nWideB := ( nRight - nLeft ) / ( nMax( aData ) + 1 )
         nPos := nLeft + nWideB
      ENDIF
      FOR nI := 1 TO nRange
         FOR nJ := 1 TO nSeries
            DrawTextInBitmap( hDC, nZero - ( aData[nJ,nI] / nMin + 2 * nDeep ), iif( nType == BARS, nPos - iif( l3D, 38, 18 ), nPos + 8 ), Transform( aData[nJ,nI], cPicture ), _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, aClrFore )
            nPos += iif( nType == BARS, nWide + nSep, 0 )
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
         DrawLineInBitmap( hDC, nZero - 1, nLeft + 1, nZero - 1, nRight - 1, RED )
      ENDIF
   ENDIF

   BT_DeleteDC( BTstruct )

RETURN hBitmap


FUNCTION HMG_PieGraph( nWidth, nHeight, series, aname, colors, ctitle, aTitleColor, depth, l3d, lxval, lsleg, lNoborder, cPicture, placement )

   LOCAL fromrow := 0
   LOCAL fromcol := 0
   LOCAL torow := nHeight
   LOCAL tocol := nWidth
   LOCAL topleftrow
   LOCAL topleftcol
   LOCAL toprightrow
   LOCAL toprightcol
   LOCAL bottomrightrow
   LOCAL bottomrightcol
   LOCAL bottomleftrow
   LOCAL bottomleftcol
   LOCAL middletopcol
   LOCAL middleleftrow
   LOCAL middleleftcol
   LOCAL middlebottomcol
   LOCAL middlerightrow
   LOCAL middlerightcol
   LOCAL fromradialrow
   LOCAL fromradialcol
   LOCAL toradialrow
   LOCAL toradialcol
   LOCAL degrees := {}
   LOCAL cumulative := {}
   LOCAL j, i, sum, ser_sum := 0
   LOCAL shadowcolor
   LOCAL previos_cumulative := -1
   LOCAL toright := .F.  // default is bottom legend
   LOCAL hDC, hBitmap, BTStruct
   LOCAL nClrBack := GetSysColor( COLOR_BTNFACE )
   LOCAL aClrBack := nRGB2Arr( nClrBack )

   DEFAULT cPicture := "999,999.99"

   shadowcolor := GetProperty( ThisWindow.Name, "BackColor" )
   IF shadowcolor[1] # -1 .AND. shadowcolor[2] # -1 .AND. shadowcolor[3] # -1
      aClrBack := shadowcolor
   ENDIF

   hBitmap := BT_BitmapCreateNew ( nWidth, nHeight, aClrBack )
   hDC := BT_CreateDC( hBitmap, BT_HDC_BITMAP, @BTStruct )

   IF !lNoborder
      DrawWindowBoxInBitmap( hDC, fromrow, fromcol, torow - 1, tocol - 1 )
   ENDIF

   ctitle := AllTrim( ctitle )
   IF Len( ctitle ) > 0
      DrawTextInBitmap( hDC, fromrow + 11, ( tocol - fromcol ) / 2, ctitle, _HMG_DefaultFontName, _HMG_DefaultFontSize + 3, aTitleColor, 2 )
      fromrow += 25 + _HMG_DefaultFontSize
   ENDIF

   IF lsleg
      toright := ( "RIGHT" $ Upper( hb_defaultValue( placement, "bottom" ) ) )
      IF toright
         tocol := 2 / 3 * tocol + 10
      ELSE
         IF Len( aname ) * 20 > ( torow - fromrow - 60 )
            lsleg := .F.
            MsgAlert( "No space for showing legends", "Pie Graph" )
         ELSE
            torow -= ( Len( aname ) * 20 )
         ENDIF
      ENDIF
   ENDIF

   drawrectInBitmap( hDC, fromrow + 11, fromcol + 11, torow - 11, tocol - 11, WHITE )
   DrawWindowBoxInBitmap( hDC, fromrow + 10, fromcol + 10, torow - 11, tocol - 11 )

   IF l3d
      torow -= depth
   ENDIF

   fromcol += 25
   tocol -= 25
   torow -= 25
   fromrow += 25

   topleftrow := fromrow
   topleftcol := fromcol
   toprightrow := fromrow
   toprightcol := tocol
   bottomrightrow := torow
   bottomrightcol := tocol
   bottomleftrow := torow
   bottomleftcol := fromcol
   middletopcol := fromcol + Int( tocol - fromcol ) / 2
   middleleftrow := fromrow + Int( torow - fromrow ) / 2
   middleleftcol := fromcol
   middlebottomcol := fromcol + Int( tocol - fromcol ) / 2
   middlerightrow := fromrow + Int( torow - fromrow ) / 2
   middlerightcol := tocol

   torow := torow + 1
   tocol := tocol + 1

   AEval( series, {|i| ser_sum += i } )
   AEval( series, {|i| AAdd( degrees, Round( i / ser_sum * 360, 0 ) ) } )
   sum := 0
   AEval( degrees, {|i| sum += i } )
   IF sum <> 360
      degrees[len(degrees)] += 360 - sum
   ENDIF
   sum := 0
   AEval( degrees, {|i| sum += i, AAdd( cumulative,sum ) } )

   fromradialrow := middlerightrow
   fromradialcol := middlerightcol
   FOR i := 1 TO Len( cumulative )
      shadowcolor := { iif( colors[i,1] > 50, colors[i,1] - 50, 0 ), iif( colors[i,2] > 50, colors[i,2] - 50, 0 ), iif( colors[i,3] > 50, colors[i,3] - 50, 0 ) }
      IF cumulative[i] == previos_cumulative
         LOOP  // fixed by Roberto Lopez
      ENDIF
      previos_cumulative := cumulative[i]
      DO CASE
      CASE cumulative[i] <= 45
         toradialcol := middlerightcol
         toradialrow := middlerightrow - Round( cumulative[i] / 45 * ( middlerightrow - toprightrow ), 0 )
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 90 .AND. cumulative[i] > 45
         toradialrow := toprightrow
         toradialcol := toprightcol - Round( ( cumulative[i] - 45 ) / 45 * ( toprightcol - middletopcol ), 0 )
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 135 .AND. cumulative[i] > 90
         toradialrow := topleftrow
         toradialcol := middletopcol - Round( ( cumulative[i] - 90 ) / 45 * ( middletopcol - topleftcol ), 0 )
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 180 .AND. cumulative[i] > 135
         toradialcol := topleftcol
         toradialrow := topleftrow + Round( ( cumulative[i] - 135 ) / 45 * ( middleleftrow - topleftrow ), 0 )
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 225 .AND. cumulative[i] > 180
         toradialcol := topleftcol
         toradialrow := middleleftrow + Round( ( cumulative[i] - 180 ) / 45 * ( bottomleftrow - middleleftrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcInBitmap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 270 .AND. cumulative[i] > 225
         toradialrow := bottomleftrow
         toradialcol := bottomleftcol + Round( ( cumulative[i] - 225 ) / 45 * ( middlebottomcol - bottomleftcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcInBitmap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 315 .AND. cumulative[i] > 270
         toradialrow := bottomleftrow
         toradialcol := middlebottomcol + Round( ( cumulative[i] - 270 ) / 45 * ( bottomrightcol - middlebottomcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcInBitmap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 360 .AND. cumulative[i] > 315
         toradialcol := bottomrightcol
         toradialrow := bottomrightrow - Round( ( cumulative[i] - 315 ) / 45 * ( bottomrightrow - middlerightrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarcInBitmap( hDC, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpieInBitmap( hDC, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      ENDCASE
      IF l3d
         drawlineInBitmap( hDC, middleleftrow, middleleftcol, middleleftrow + depth, middleleftcol, BLACK )
         drawlineInBitmap( hDC, middlerightrow, middlerightcol, middlerightrow + depth, middlerightcol, BLACK )
         drawarcInBitmap( hDC, fromrow + depth, fromcol, torow + depth, tocol, middleleftrow + depth, middleleftcol, middlerightrow + depth, middlerightcol )
      ENDIF
   NEXT i
   IF lsleg
      IF toright
         fromrow := topleftrow
         fromcol := toprightcol + 25
      ELSE
         fromrow := torow + 20 + iif( l3d, depth, 0 )
      ENDIF
      FOR i := 1 TO Len( aname )
         drawrectInBitmap( hDC, fromrow + 1, fromcol + 1, fromrow + 14, fromcol + 14, colors[i] )
         DrawWindowBoxInBitmap( hDC, fromrow, fromcol, fromrow + 14, fromcol + 14 )
         drawtextinbitmap( hDC, fromrow, fromcol + 20, aname[ i ] + iif( lxval, " - " + LTrim( Transform( series[i], cPicture ) ) + " (" + LTrim( Str( series[i] / ser_sum * 100, 6, 2 ) ) + " %)", "" ), _HMG_DefaultFontName, _HMG_DefaultFontSize - 1, iif( RGB( colors[i][1], colors[i][2], colors[i][3] ) == RGB( 255, 255, 255 ), BLACK, colors[i] ) )
         fromrow += 20
      NEXT i
   ENDIF

   BT_DeleteDC( BTstruct )
 
RETURN hBitmap

*=============================================================================*
*                          Auxiliary Functions
*=============================================================================*


STATIC PROCEDURE DrawWindowBoxInBitmap( hDC, row, col, rowr, colr, nPenWidth )

   BT_DrawRectangle ( hDC, Row, Col, Colr - col, rowr - row, BLACK, nPenWidth )

RETURN


STATIC PROCEDURE DrawRectInBitmap( hDC, row, col, row1, col1, aColor, nPenWidth )

   BT_DrawFillRectangle ( hDC, Row, Col, col1 - col, row1 - row, aColor, aColor, nPenWidth )

RETURN


STATIC PROCEDURE DrawLineInBitmap( hDC, Row1, Col1, Row2, Col2, aColor, nPenWidth )

   BT_DrawLine ( hDC, Row1, Col1, Row2, Col2, aColor, nPenWidth )

RETURN


STATIC PROCEDURE DrawTextInBitmap( hDC, Row, Col, cText, cFontName, nFontSize, aColor, nAlign )

   DEFAULT nAlign := 0
   SWITCH nAlign
   CASE 0
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , BT_TEXT_TRANSPARENT )
      EXIT
   CASE 1
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , , BT_TEXT_RIGHT + BT_TEXT_TOP )
      EXIT
   CASE 2
      BT_DrawText ( hDC, Row, Col, cText, cFontName, nFontSize, aColor, , BT_TEXT_TRANSPARENT, BT_TEXT_CENTER + BT_TEXT_TOP )
      EXIT
   ENDSWITCH

RETURN


STATIC PROCEDURE DrawPointInBitmap( hDC, nGraphType, nY, nX, nHigh, aColor )

   IF nGraphType == POINTS
      DrawCircleInBitmap( hDC, nX - nHigh - 3, nY - 3, 8, aColor )
   ELSEIF nGraphType == LINES
      DrawCircleInBitmap( hDC, nX - nHigh - 2, nY - 2, 6, aColor )
   ENDIF

RETURN


STATIC PROCEDURE DrawCircleInBitmap( hDC, nCol, nRow, nWidth, aColor, nPenWidth )

   BT_DrawFillEllipse( hDC, nCol, nRow, nWidth, nWidth, aColor, aColor, nPenWidth )

RETURN


STATIC PROCEDURE DrawBarInBitmap( hDC, nY, nX, nHigh, nWidth, l3DView, nDeep, aColor )

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
      DrawPolygonInBitmap( hDC, { { nX -1, nY + nWidth + 1 }, { nX + nDeep - nHigh, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nDeep, nY + nWidth + nDeep }, ;
         { nX -1, nY + nWidth + 1 } }, nShadow,, nShadow )
      // Superior
      nHigh   := Max( nHigh, nDeep )
      DrawPolygonInBitmap( hDC, { { nX - nHigh + nDeep, nY + 1 }, { nX - nHigh + nDeep, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nHigh + 1, nY + nDeep }, ;
         { nX - nHigh + nDeep, nY + 1 } }, nColTop,, nColTop )
      // Border
      DrawBoxInBitmap( hDC, nY, nX, nH, nWidth, l3DView, nDeep )
   ENDIF

RETURN


STATIC PROCEDURE DrawArcInBitmap( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )

   IF ValType( penrgb ) == "U"
      penrgb = BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth = 1
   ENDIF

   BT_DrawArc ( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )

RETURN


STATIC PROCEDURE DrawPieInBitmap( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb )

   IF ValType( penrgb ) == "U"
      penrgb = BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth = 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF

   BT_DrawPie ( hDC, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb )

RETURN


STATIC PROCEDURE DrawPolygonInBitmap( hDC, apoints, penrgb, penwidth, fillrgb )

   LOCAL xarr := {}
   LOCAL yarr := {}
   LOCAL x

   IF ValType( penrgb ) == "U"
      penrgb := BLACK
   ENDIF
   IF ValType( penwidth ) == "U"
      penwidth := 1
   ENDIF
   IF ValType( fillrgb ) == "U"
      fillrgb := WHITE
   ENDIF
   FOR x := 1 TO LEN( apoints )
      AAdd( xarr, apoints[ x, 2 ] )
      AAdd( yarr, apoints[ x, 1 ] )
   NEXT x

   BT_DrawPolygon ( hDC, yarr, xarr, penrgb, penwidth, fillrgb )

RETURN


STATIC PROCEDURE DrawBoxInBitmap( hDC, nY, nX, nHigh, nWidth, l3DView, nDeep )

   // Set Border
   DrawLineInBitmap( hDC, nX, nY, nX - nHigh + nDeep, nY, BLACK )  // LEFT
   DrawLineInBitmap( hDC, nX, nY + nWidth, nX - nHigh + nDeep, nY + nWidth, BLACK )  // RIGHT
   DrawLineInBitmap( hDC, nX - nHigh + nDeep, nY, nX - nHigh + nDeep, nY + nWidth, BLACK )  // Top
   DrawLineInBitmap( hDC, nX, nY, nX, nY + nWidth, BLACK )                          // Bottom
   IF l3DView
      // Set shadow
      DrawLineInBitmap( hDC, nX - nHigh + nDeep, nY + nWidth, nX - nHigh, nY + nDeep + nWidth, BLACK )
      DrawLineInBitmap( hDC, nX, nY + nWidth, nX - nDeep, nY + nWidth + nDeep, BLACK )
      IF nHigh > 0
         DrawLineInBitmap( hDC, nX - nDeep, nY + nWidth + nDeep, nX - nHigh, nY + nWidth + nDeep, BLACK )
         DrawLineInBitmap( hDC, nX - nHigh, nY + nDeep, nX - nHigh, nY + nWidth + nDeep, BLACK )
         DrawLineInBitmap( hDC, nX - nHigh + nDeep, nY, nX - nHigh, nY + nDeep, BLACK )
      ELSE
         DrawLineInBitmap( hDC, nX - nDeep, nY + nWidth + nDeep, nX - nHigh + 1, nY + nWidth + nDeep, BLACK )
         DrawLineInBitmap( hDC, nX, nY, nX - nDeep, nY + nDeep, BLACK )
      ENDIF
   ENDIF

RETURN

#endif