/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2018, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
#   pragma -w2
#endif

#include "minigui.ch"
#include "miniprint.ch"
#include "winprint.ch"

/*
 * Copyright Alfredo Arteaga 14/10/2001 original idea
 *
 * Grigory Filatov 23/06/2003 translation for MiniGUI
 *
 * Roberto Lopez 23/06/2003 command definition
 *
 * Copyright Alfredo Arteaga TGRAPH 2, 12/03/2002
 *
 * Grigory Filatov 26/02/2004 translation #2 for MiniGUI
 *
 * Grigory Filatov 02/12/2006 updated label's backcolor
*/

#define COLOR_WINDOWTEXT     8
#define COLOR_BTNFACE       15

STATIC nGraphObj := 1, nPieObj := 1

PROCEDURE GraphShow( parent, nTop, nLeft, nBottom, nRight, nHeight, nWidth, aData, cTitle, aYVals, nBarD, nWideB, nSep, nXRanges, ;
      l3D, lGrid, lxGrid, lyGrid, lxVal, lyVal, lLegends, aSeries, aColors, nType, lViewVal, cPicture, nLegendsWidth, lNoborder, lPrint )

   LOCAL nI, nJ, nPos, nMax, nMin, nMaxBar, nDeep
   LOCAL nRange, nSeries, nResH, nResV, nWide, aPoint, cNameObj
   LOCAL nXMax, nXMin, nHigh, nRel, nZero, nRPos, nRNeg
   LOCAL nClrFore  := GetSysColor( COLOR_WINDOWTEXT ), nClrBack := GetSysColor( COLOR_BTNFACE ), atemp, lRedraw := .F.
   LOCAL aClrFore := nRGB2Arr( nClrFore )
   LOCAL aClrBack := nRGB2Arr( nClrBack )

   DEFAULT lPrint := .F., cTitle := "", nSep := 0, nLegendsWidth := 50, cPicture := "999,999.99"

   IF ( Len ( aSeries ) != Len ( aData ) ) .OR. ( Len ( aSeries ) > Len ( aColors ) )
      MsgMiniGuiError( "DRAW GRAPH: 'Series' / 'SerieNames' / 'Colors' arrays size mismatch." )
   ENDIF

   atemp := GetProperty( Parent, "BackColor" )
   IF atemp[1] # -1 .AND. atemp[2] # -1 .AND. atemp[3] # -1
      aClrBack := atemp
      lRedraw := .T.
   ENDIF

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
   IF !lPrint .AND. !lNoborder
      DrawWindowBoxIn( parent, Max( 1, nTop - 44 ), Max( 1, nLeft - 80 - nBarD ), nHeight - 1, nWidth - 1 )
   ENDIF

   // Back area
   //
   IF l3D
      drawrect( parent, nTop + 1, nLeft, nBottom - nDeep, nRight, WHITE, , WHITE )
   ELSE
      drawrect( parent, nTop - 5, nLeft, nBottom, nRight, , , WHITE )
   ENDIF

   IF l3D
      // Bottom area
      FOR nI := 1 TO nDeep + 1
         DrawLine( parent, nBottom - nI, nLeft - nDeep + nI, nBottom - nI, nRight - nDeep + nI, WHITE )
      NEXT nI

      // Lateral
      FOR nI := 1 TO nDeep
         DrawLine( parent, nTop + nI, nLeft - nI, nBottom - nDeep + nI, nLeft - nI, SILVER )
      NEXT nI

      // Graph borders
      FOR nI := 1 TO nDeep+1
         DrawLine( parent, nBottom-nI     , nLeft-nDeep+nI-1 , nBottom-nI     , nLeft-nDeep+nI  , GRAY )
         DrawLine( parent, nBottom-nI     , nRight-nDeep+nI-1, nBottom-nI     , nRight-nDeep+nI , BLACK )
         DrawLine( parent, nTop+nDeep-nI+1, nLeft-nDeep+nI-1 , nTop+nDeep-nI+1, nLeft-nDeep+nI  , BLACK )
         DrawLine( parent, nTop+nDeep-nI+1, nLeft-nDeep+nI-3 , nTop+nDeep-nI+1, nLeft-nDeep+nI-2, BLACK )
      NEXT nI

      FOR nI := 1 TO nDeep+2
         DrawLine( parent, nTop+nDeep-nI+1, nLeft-nDeep+nI-3, nTop+nDeep-nI+1, nLeft-nDeep+nI-2 , BLACK )
         DrawLine( parent, nBottom+ 2-nI+1, nRight-nDeep+nI , nBottom+ 2-nI+1, nRight-nDeep+nI-2, BLACK )
      NEXT nI

      DrawLine( parent, nTop         , nLeft        , nTop           , nRight       , BLACK )
      DrawLine( parent, nTop- 2      , nLeft        , nTop- 2        , nRight+ 2    , BLACK )
      DrawLine( parent, nTop         , nLeft        , nBottom-nDeep  , nLeft        , GRAY  )
      DrawLine( parent, nTop+nDeep   , nLeft-nDeep  , nBottom        , nLeft-nDeep  , BLACK )
      DrawLine( parent, nTop+nDeep   , nLeft-nDeep-2, nBottom+ 2     , nLeft-nDeep-2, BLACK )
      DrawLine( parent, nTop         , nRight       , nBottom-nDeep  , nRight       , BLACK )
      DrawLine( parent, nTop- 2      , nRight+ 2    , nBottom-nDeep+2, nRight+ 2    , BLACK )
      DrawLine( parent, nBottom-nDeep, nLeft        , nBottom-nDeep  , nRight       , GRAY  )
      DrawLine( parent, nBottom      , nLeft-nDeep  , nBottom        , nRight-nDeep , BLACK )
      DrawLine( parent, nBottom+ 2   , nLeft-nDeep-2, nBottom+ 2     , nRight-nDeep , BLACK )
   ENDIF

   // Graph info
   //
   IF !Empty( cTitle )
      cNameObj := 'Obj_Name_' + hb_ntos( nGraphObj++ )
      @ nTop - 36 * nResV, nLeft LABEL &cNameObj OF &parent VALUE cTitle;
         WIDTH nRight - nLeft;
         HEIGHT 24;
         FONTCOLOR aClrFore;
         BACKCOLOR iif( lPrint, WHITE, aClrBack );
         FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize + 3;
         BOLD CENTERALIGN VCENTERALIGN
      IF lPrint .OR. lRedraw
         RedrawWindow( GetControlHandle( cNameObj, parent ) )
      ENDIF
   ENDIF

   // Legends
   //
   IF lLegends
      nPos := nTop
      FOR nI := 1 TO Len( aSeries )
         DrawBar( parent, nRight + ( ( _HMG_DefaultFontSize - 1 ) * nResH ), nPos + _HMG_DefaultFontSize * nResV,;
            ( _HMG_DefaultFontSize - 1 ) * nResH, ( _HMG_DefaultFontSize - 2 ) * nResV, l3D, 1, aColors[nI] )
         cNameObj := "Obj_Name_" + hb_ntos( nGraphObj++ )
         @ nPos - 1, nRight + ( 4 + 2 * _HMG_DefaultFontSize ) * nResH LABEL &cNameObj OF &parent;
            VALUE aSeries[nI] AUTOSIZE;
            FONTCOLOR aClrFore;
            BACKCOLOR iif( lPrint, WHITE, NIL );
            FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize - 1 TRANSPARENT
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
         DrawLine( parent, nZero - nI + 1, nLeft - nDeep + nI, nZero - nI + 1, nRight - nDeep + nI, SILVER )
      NEXT nI
      FOR nI := 1 TO nDeep + 1
         DrawLine( parent, nZero - nI + 1, nLeft - nDeep + nI - 1 , nZero - nI + 1, nLeft - nDeep + nI , GRAY )
         DrawLine( parent, nZero - nI + 1, nRight - nDeep + nI - 1, nZero - nI + 1, nRight - nDeep + nI, BLACK )
      NEXT nI
      DrawLine( parent, nZero - nDeep, nLeft, nZero - nDeep, nRight, GRAY )
   ENDIF

   aPoint := Array( Len( aSeries ), Len( aData[1] ), 2 )
   nRange := nMax / nXRanges

   // xLabels
   //
   nRPos := nRNeg := nZero - nDeep
   FOR nI := 0 TO nXRanges
      IF lxVal
         IF nRange * nI <= nXMax
            cNameObj := "Obj_Name_" + hb_ntos( nGraphObj++ )
            @ nRPos, nLeft - nDeep - 75 LABEL &cNameObj OF &parent;
               VALUE Transform( nRange * nI, cPicture );
               WIDTH 65;
               HEIGHT _HMG_DefaultFontSize + 3;
               FONTCOLOR aClrFore;
               BACKCOLOR iif( lPrint, WHITE, aClrBack );
               FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize - 1 RIGHTALIGN
            IF lPrint .OR. lRedraw
               RedrawWindow( GetControlHandle( cNameObj, parent ) )
            ENDIF
         ENDIF
         IF nRange * ( - nI ) >= nXMin * ( -1 )
            cNameObj := "Obj_Name_" + hb_ntos( nGraphObj++ )
            @ nRNeg, nLeft - nDeep - 75 LABEL &cNameObj OF &parent;
               VALUE Transform( nRange *- nI, cPicture );
               WIDTH 65;
               HEIGHT _HMG_DefaultFontSize + 3;
               FONTCOLOR aClrFore;
               BACKCOLOR iif( lPrint, WHITE, aClrBack );
               FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize - 1 RIGHTALIGN
            IF lPrint .OR. lRedraw
               RedrawWindow( GetControlHandle( cNameObj, parent ) )
            ENDIF
         ENDIF
      ENDIF
      IF lxGrid
         IF nRange * nI <= nXMax
            IF l3D
               FOR nJ := 0 TO nDeep + 1
                  DrawLine( parent, nRPos + nJ, nLeft - nJ - 1, nRPos + nJ, nLeft - nJ, BLACK )
               NEXT nJ
            ENDIF
            DrawLine( parent, nRPos, nLeft, nRPos, nRight, BLACK )
         ENDIF
         IF nRange *- nI >= nXMin *- 1
            IF l3D
               FOR nJ := 0 TO nDeep + 1
                  DrawLine( parent, nRNeg + nJ, nLeft - nJ - 1, nRNeg + nJ, nLeft - nJ, BLACK )
               NEXT nJ
            ENDIF
            DrawLine( parent, nRNeg, nLeft, nRNeg, nRight, BLACK )
         ENDIF
      ENDIF
      nRPos -= ( nMaxBar / nXRanges )
      nRNeg += ( nMaxBar / nXRanges )
   NEXT nI

   IF lYGrid
      nPos := iif( l3D, nTop, nTop - 5 )
      nI := nLeft + nWide
      FOR nJ := 1 TO nMax( aData )
         Drawline( parent, nBottom - nDeep, nI, nPos, nI, { 100, 100, 100 } )
         Drawline( parent, nBottom, nI - nDeep, nBottom - nDeep, nI, { 100, 100, 100 } )
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
         cNameObj := "Obj_Name_" + hb_ntos( nGraphObj++ )
         @ nBottom + 8, nI - iif( l3D, nDeep, nDeep + 8 ) LABEL &cNameObj OF &parent;
            VALUE aYVals[nJ] AUTOSIZE;
            FONTCOLOR aClrFore;
            BACKCOLOR iif( lPrint, WHITE, aClrBack );
            FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize - 1
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
            DrawBar( parent, nPos, iif( l3D, nZero, nZero - 1 ), aData[nJ,nI] / nMin + nDeep, nWide, l3D, nDeep, ;
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
               DrawPoint( parent, nType, nPos, nZero, aData[nJ,nI] / nMin + nDeep, aColors[nJ] )
            ENDIF
            aPoint[nJ,nI,2] := nPos
            aPoint[nJ,nI,1] := nZero - ( aData[nJ,nI] / nMin + nDeep )
         NEXT nJ
         nPos += nWideB
      NEXT nI

      FOR nI := 1 TO nRange - 1
         FOR nJ := 1 TO nSeries
            IF l3D
               drawpolygon( parent, { { aPoint[nJ,nI,1],aPoint[nJ,nI,2] }, { aPoint[nJ,nI+1,1],aPoint[nJ,nI+1,2] }, ;
                  { aPoint[nJ,nI+1,1] - nDeep, aPoint[nJ,nI+1,2] + nDeep }, { aPoint[nJ,nI,1] - nDeep, aPoint[nJ,nI,2] + nDeep }, ;
                  { aPoint[nJ,nI,1], aPoint[nJ,nI,2] } }, , , aColors[nJ] )
            ELSE
               DrawLine( parent, aPoint[nJ,nI,1], aPoint[nJ,nI,2], aPoint[nJ,nI+1,1], aPoint[nJ,nI+1,2], aColors[nJ] )
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
            DrawPoint( parent, nType, nPos, nZero, aData[nJ,nI] / nMin + nDeep, aColors[nJ] )
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
            DRAW TEXT IN WINDOW &parent;
               AT nZero - ( aData[nJ,nI] / nMin + 2 * nDeep ), iif( nType == BARS, nPos - 18, nPos + 8 );
               VALUE Transform( aData[nJ,nI], cPicture );
               FONT _HMG_DefaultFontName SIZE _HMG_DefaultFontSize - 1 BOLD;
               FONTCOLOR aClrFore TRANSPARENT
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
      DrawLine( parent, nZero, nLeft - nDeep, nZero, nRight - nDeep, BLACK )
   ELSE
      IF nXMax <> 0 .AND. nXMin <> 0
         DrawLine( parent, nZero - 1, nLeft + 1, nZero - 1, nRight - 1, RED )
      ENDIF
   ENDIF

RETURN


PROCEDURE EraseBarGraph ( Parent )

   LOCAL cName, i := 1

   DO WHILE i < nGraphObj
      cName := "Obj_Name_" + hb_ntos( i++ )
      IF _IsControlDefined ( cName, Parent )
         _ReleaseControl ( cName, Parent )
      ENDIF
   ENDDO

RETURN


STATIC PROCEDURE DrawBar( parent, nY, nX, nHigh, nWidth, l3D, nDeep, aColor )

   LOCAL nI, nColTop, nShadow, nH := nHigh

   nColTop := ClrShadow( RGB( aColor[1], aColor[2], aColor[3] ), 15 )
   nShadow := ClrShadow( nColTop, 15 )
   nColTop := nRGB2Arr( nColTop )
   nShadow := nRGB2Arr( nShadow )

   FOR nI := 1 TO nWidth
      DrawLine( parent, nX, nY + nI, nX + nDeep - nHigh, nY + nI, aColor )  // front
   NEXT nI

   IF l3D
      // Lateral
      drawpolygon( parent, { { nX - 1, nY + nWidth + 1 }, { nX + nDeep - nHigh, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nDeep, nY + nWidth + nDeep }, ;
         { nX - 1, nY + nWidth + 1 } }, nShadow, , nShadow )
      // Superior
      nHigh := Max( nHigh, nDeep )
      drawpolygon( parent, { { nX - nHigh + nDeep, nY + 1 }, { nX - nHigh + nDeep, nY + nWidth + 1 }, ;
         { nX - nHigh + 1, nY + nWidth + nDeep }, { nX - nHigh + 1, nY + nDeep }, ;
         { nX - nHigh + nDeep, nY + 1 } }, nColTop, , nColTop )
   ENDIF
   // Border
   DrawBox( parent, nY, nX, nH, nWidth, l3D, nDeep )

RETURN


STATIC PROCEDURE DrawBox( parent, nY, nX, nHigh, nWidth, l3D, nDeep )

   // Set Border
   DrawLine( parent, nX, nY        , nX-nHigh+nDeep    , nY         , BLACK )  // Left
   DrawLine( parent, nX, nY+nWidth , nX-nHigh+nDeep    , nY+nWidth  , BLACK )  // Right
   DrawLine( parent, nX-nHigh+nDeep, nY, nX-nHigh+nDeep, nY+nWidth+1, BLACK )  // Top
   DrawLine( parent, nX            , nY, nX            , nY+nWidth  , BLACK )  // Bottom
   IF l3D
      // Set shadow
      DrawLine( parent, nX - nHigh + nDeep, nY + nWidth, nX - nHigh, nY + nDeep + nWidth, BLACK )
      DrawLine( parent, nX, nY + nWidth, nX - nDeep, nY + nWidth + nDeep, BLACK )
      IF nHigh > 0
         DrawLine( parent, nX - nDeep, nY + nWidth + nDeep, nX - nHigh, nY + nWidth + nDeep, BLACK )
         DrawLine( parent, nX - nHigh, nY + nDeep, nX - nHigh , nY + nWidth + nDeep, BLACK )
         DrawLine( parent, nX - nHigh + nDeep, nY, nX - nHigh, nY + nDeep, BLACK )
      ELSE
         DrawLine( parent, nX - nDeep, nY + nWidth + nDeep, nX - nHigh + 1, nY + nWidth + nDeep, BLACK )
         DrawLine( parent, nX, nY, nX - nDeep, nY + nDeep, BLACK )
      ENDIF
   ENDIF

RETURN


STATIC PROCEDURE DrawPoint( parent, nType, nY, nX, nHigh, aColor )

   IF nType == POINTS

      Circle( parent, nX - nHigh - 3, nY - 3, 8, aColor )

   ELSEIF nType == LINES

      Circle( parent, nX - nHigh - 2, nY - 2, 6, aColor )

   ENDIF

RETURN


STATIC PROCEDURE Circle( window, nCol, nRow, nWidth, aColor )

   DrawEllipse( window, nCol, nRow, nCol + nWidth - 1, nRow + nWidth - 1, , , aColor )

RETURN


STATIC FUNCTION nMax( aData )

   LOCAL nMax := 0

   AEval( aData, { | ele | nMax := Max( nMax, Len( ele ) ) } )

RETURN( nMax )


STATIC FUNCTION DetMaxVal( nNum )

   LOCAL nE, nMax, nMan, nVal, nOffset

   nE   := 9
   nNum := Abs( nNum )

   DO WHILE .T.

      nMax := 10 ** nE

      IF Int( nNum / nMax ) > 0

         nMan    := nNum / nMax - Int( nNum / nMax )
         nOffset := 1
         nOffset := iif( nMan <= .75, .75, nOffset )
         nOffset := iif( nMan <= .50, .50, nOffset )
         nOffset := iif( nMan <= .25, .25, nOffset )
         nOffset := iif( nMan <= .00, .00, nOffset )
         nVal    := ( Int( nNum / nMax ) + nOffset ) * nMax
         EXIT

      ENDIF

      nE--

   ENDDO

RETURN ( nVal )


STATIC FUNCTION ClrShadow( nColor, nFactor )

   LOCAL aHSL, aRGB

   aHSL := RGB2HSL( GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) )
   aHSL[3] -= nFactor
   aRGB := HSL2RGB( aHSL[1], aHSL[2], aHSL[3] )

RETURN RGB( aRGB[1], aRGB[2], aRGB[3] )


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

   IF nMax == nMin
      nH := 0
      nS := 0
   ELSE
      IF nL < 0.5
         nS := ( nMax - nMin ) / ( nMax + nMin )
      ELSE
         nS := ( nMax - nMin ) / ( 2.0 - nMax - nMin )
      ENDIF
      DO CASE
      CASE nR == nMax
         nH := ( nG - nB ) / ( nMax - nMin )
      CASE nG == nMax
         nH := 2.0 + ( nB - nR ) / ( nMax - nMin )
      CASE nB == nMax
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
      aTmp3[1] := nH + 1 / 3
      aTmp3[2] := nH
      aTmp3[3] := nH - 1 / 3
      FOR nFor := 1 TO 3
         IF aTmp3[nFor] < 0
            aTmp3[nFor] += 1
         ENDIF
         IF aTmp3[nFor] > 1
            aTmp3[nFor] -= 1
         ENDIF
         IF 6 * aTmp3[nFor] < 1
            aTmp3[nFor] := nTmp1 + ( nTmp2 - nTmp1 ) * 6 * aTmp3[nFor]
         ELSE
            IF 2 * aTmp3[nFor] < 1
               aTmp3[nFor] := nTmp2
            ELSE
               IF 3 * aTmp3[nFor] < 2
                  aTmp3[nFor] := nTmp1 + ( nTmp2 - nTmp1 ) * ( ( 2 / 3 ) - aTmp3[nFor] ) * 6
               ELSE
                  aTmp3[nFor] := nTmp1
               ENDIF
            ENDIF
         ENDIF
      NEXT nFor
      nR := aTmp3[1]
      nG := aTmp3[2]
      nB := aTmp3[3]
   ENDIF

RETURN { Int( nR * 255 ), Int( nG * 255 ), Int( nB * 255 ) }


/*
 * Copyright (c) 2003 Rathinagiri <srgiri@dataone.in>
 *
 * Revised by Grigory Filatov
*/
FUNCTION drawpiegraph( windowname, fromrow, fromcol, torow, tocol, series, aname, colors, ctitle, depth, l3d, lxval, lsleg, cPicture, lNoborder, placement, lPrint )

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
   LOCAL cname
   LOCAL backcolor
   LOCAL shadowcolor
   LOCAL previos_cumulative := -1
   LOCAL toright := .F.  // default is bottom legend

   DEFAULT lPrint := .F., cPicture := "999,999.99"

   IF !lPrint .AND. !lNoborder
      DrawWindowBoxIn( windowname, fromrow, fromcol, torow - 1, tocol - 1 )
   ENDIF

   ctitle := AllTrim( ctitle )
   IF Len( ctitle ) > 0
      backcolor := GetProperty( windowname, "BackColor" )
      IF backcolor[1] == -1 .AND. backcolor[2] == -1 .AND. backcolor[3] == -1
         backcolor := NIL
      ENDIF
      cname := "title_of_pie" + hb_ntos( nPieObj++ )
      define label &cname
        parent &windowname
        row fromrow + 10
        col fromcol + iif( Len( ctitle ) * 8 > ( tocol - fromcol ), 0, 5 )
        width iif( Len( ctitle ) * 8 > ( tocol - fromcol ), Len( ctitle ) * 10, tocol - fromcol - 10 )
        height 16 + _HMG_DefaultFontSize
        fontbold .T.
        fontname _HMG_DefaultFontName
        fontsize _HMG_DefaultFontSize + 3
        centeralign ( Len( ctitle ) * 8 < ( tocol - fromcol ) )
        vcenteralign .T.
        value ctitle
        fontcolor { 0, 0, 0 }
        backcolor iif( lPrint, WHITE, backcolor )
      end label
      RedrawWindow( GetControlHandle( cname, windowname ) )
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

   drawrect( windowname, fromrow + 10, fromcol + 10, torow - 10, tocol - 10, BLACK, 1, WHITE )

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

   torow++
   tocol++

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
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 90 .AND. cumulative[i] > 45
         toradialrow := toprightrow
         toradialcol := toprightcol - Round( ( cumulative[i] - 45 ) / 45 * ( toprightcol - middletopcol ), 0 )
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 135 .AND. cumulative[i] > 90
         toradialrow := topleftrow
         toradialcol := middletopcol - Round( ( cumulative[i] - 90 ) / 45 * ( middletopcol - topleftcol ), 0 )
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 180 .AND. cumulative[i] > 135
         toradialcol := topleftcol
         toradialrow := topleftrow + Round( ( cumulative[i] - 135 ) / 45 * ( middleleftrow - topleftrow ), 0 )
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 225 .AND. cumulative[i] > 180
         toradialcol := topleftcol
         toradialrow := middleleftrow + Round( ( cumulative[i] - 180 ) / 45 * ( bottomleftrow - middleleftrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarc( windowname, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 270 .AND. cumulative[i] > 225
         toradialrow := bottomleftrow
         toradialcol := bottomleftcol + Round( ( cumulative[i] - 225 ) / 45 * ( middlebottomcol - bottomleftcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarc( windowname, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 315 .AND. cumulative[i] > 270
         toradialrow := bottomleftrow
         toradialcol := middlebottomcol + Round( ( cumulative[i] - 270 ) / 45 * ( bottomrightcol - middlebottomcol ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarc( windowname, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      CASE cumulative[i] <= 360 .AND. cumulative[i] > 315
         toradialcol := bottomrightcol
         toradialrow := bottomrightrow - Round( ( cumulative[i] - 315 ) / 45 * ( bottomrightrow - middlerightrow ), 0 )
         IF l3d
            FOR j := 1 TO depth
               drawarc( windowname, fromrow + j, fromcol, torow + j, tocol, fromradialrow + j, fromradialcol, toradialrow + j, toradialcol, shadowcolor )
            NEXT j
         ENDIF
         drawpie( windowname, fromrow, fromcol, torow, tocol, fromradialrow, fromradialcol, toradialrow, toradialcol, , , colors[i] )
         fromradialrow := toradialrow
         fromradialcol := toradialcol
      ENDCASE
      IF l3d
         drawline( windowname, middleleftrow, middleleftcol, middleleftrow + depth, middleleftcol )
         drawline( windowname, middlerightrow, middlerightcol, middlerightrow + depth, middlerightcol )
         drawarc( windowname, fromrow + depth, fromcol, torow + depth, tocol, middleleftrow + depth, middleleftcol, middlerightrow + depth, middlerightcol )
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
         cname := "pielegend_" + hb_ntos( nPieObj++ )
         drawrect( windowname, fromrow, fromcol, fromrow + 15, fromcol + 15, { 0, 0, 0 }, 1, colors[i] )
         define label &cname
           parent &windowname
           row fromrow
           col fromcol + 20
           fontname _HMG_DefaultFontName
           fontsize _HMG_DefaultFontSize - 1
           autosize .T.
           IF !lPrint .AND. !lNoborder
              height 16
           ENDIF
           value aname[i] + iif( lxval, " - " + LTrim( Transform( series[i], cPicture ) ) + " (" + LTrim( Str( series[i] / ser_sum * 100, 6, 2 ) ) + " %)", "" )
           fontcolor iif( RGB( colors[i][1], colors[i][2], colors[i][3] ) == RGB( 255, 255, 255 ), BLACK, colors[i] )
           backcolor iif( lPrint, WHITE, NIL )
           transparent .T.
         end label
         fromrow += 20
      NEXT i
   ENDIF

RETURN nil


PROCEDURE ErasePieGraph( windowname )

   LOCAL cname, i := 1

   DO WHILE i < nPieObj
      cname := "title_of_pie" + hb_ntos( i )
      IF _IsControlDefined ( cname, windowname )
         _ReleaseControl( cname, windowname )
      ENDIF
      cname := "pielegend_" + hb_ntos( i++ )
      IF _IsControlDefined ( cname, windowname )
         _ReleaseControl( cname, windowname )
      ENDIF
   ENDDO

RETURN


FUNCTION _PiePrint( cForm, fromrow, fromcol, torow, tocol, series, aname, colors, ctitle, depth, l3d, lxval, lsleg, cPicture, x, y, cLibrary, placement )

   LOCAL b := _HMG_IsModalActive

   _HMG_IsModalActive := .F.
   DEFAULT cLibrary := ""
   Define Window _PieGraph;
      At GetProperty( cForm, 'Row' ), GetProperty( cForm, 'Col' );
      Width GetProperty( cForm, 'Width' );
      Height GetProperty( cForm, 'Height' );
      Child;
      On Init ( drawpiegraph( "_PieGraph",fromrow,fromcol,torow,tocol,series,aname,colors,ctitle,depth,l3d,lxval,lsleg,cPicture, .T., placement, .T. ),;
         _bmpprint( ThisWindow.Name, x, y, iif( "HBPRINT" $ Upper( cLibrary ), 2, 1 ) ) );
      BackColor WHITE

   End Window
   Activate Window _PieGraph
   _HMG_IsModalActive := b

RETURN nil


FUNCTION _GraphPrint( cForm, nTop, nLeft, nBottom, nRight, nHeight, nWidth, aData, cTitle, aYVals, nBarD, nWideB, nSep, nXRanges, ;
      l3D, lGrid, lxGrid, lyGrid, lxVal, lyVal, lLegends, aSeries, aColors, nType, lViewVal, cPicture, nLegendsWidth, x, y, cLibrary )

   LOCAL b := _HMG_IsModalActive

   _HMG_IsModalActive := .F.
   DEFAULT cLibrary := ""
   Define Window _Graph;
      At GetProperty( cForm, 'Row' ), GetProperty( cForm, 'Col' );
      Width GetProperty( cForm, 'Width' );
      Height GetProperty( cForm, 'Height' );
      Child;
      On Init ( GraphShow("_Graph",nTop,nLeft,nBottom,nRight,nHeight,nWidth,aData,cTitle,aYVals,nBarD,nWideB,nSep,nXRanges,;
         l3D, lGrid, lxGrid, lyGrid, lxVal, lyVal, lLegends, aSeries, aColors, nType, lViewVal, cPicture, nLegendsWidth, .T. , .T. ),;
         _bmpprint( ThisWindow.Name, x, y, iif( "HBPRINT" $ Upper( cLibrary ), 2, 1 ) ) );
      BackColor WHITE

   End Window
   Activate Window _Graph
   _HMG_IsModalActive := b

RETURN nil


STATIC FUNCTION _bmpprint( cForm, x, y, nLibrary )

   LOCAL cTempFile := TempFile( GetTempFolder(), 'BMP' )
   LOCAL aSize, nOrientation, lSuccess
   LOCAL W, H, HO, VO, bw, bh, r, tW := 0, tH

   SuppressKeyAndMouseEvents()

   DoMethod( cForm, 'SaveAs', cTempFile )

   aSize := BmpSize( cTempFile )

   bw := aSize[ 1 ]
   bh := aSize[ 2 ]

   r := bw / bh

   nOrientation := iif( bw > bh, PRINTER_ORIENT_LANDSCAPE, PRINTER_ORIENT_PORTRAIT )

   IF hb_defaultValue( nLibrary, 1 ) == 2

      INIT PRINTSYS

      SELECT PRINTER DEFAULT PREVIEW

      IF HBPRNERROR != 0
         DoMethod ( cForm, 'Release' )
         FErase( cTempFile )
         RETURN .F.
      ENDIF

      IF nOrientation == PRINTER_ORIENT_PORTRAIT
         SET ORIENTATION PORTRAIT
      ELSE
         SET ORIENTATION LANDSCAPE
      ENDIF

      SET PREVIEW RECT MAXIMIZED

      SET UNITS MM

      HO := hbprn:devcaps[ 10 ] / hbprn:devcaps[ 6 ] * 25.4
      VO := hbprn:devcaps[ 9 ] / hbprn:devcaps[ 5 ] * 25.4

      W := HBPRNMAXCOL - x - HO * 2
      H := HBPRNMAXROW - y - VO * 2

      REPEAT

         th := ++tw / r

      UNTIL ( tw < w - x .OR. th < h - y )

      DoMethod ( cForm, 'Hide' )

      START DOC
         START PAGE

            @ VO + y + ( h - th ) / 2, HO + x + ( w - tw ) / 2 PICTURE cTempFile SIZE tH, tW

         END PAGE
      END DOC

      RELEASE PRINTSYS

   ELSE

      SELECT PRINTER DEFAULT TO lSuccess ORIENTATION nOrientation PREVIEW

      IF .NOT. lSuccess
         DoMethod ( cForm, 'Release' )
         FErase( cTempFile )
         RETURN .F.
      ENDIF

      HO := GetPrintableAreaHorizontalOffset()
      VO := GetPrintableAreaVerticalOffset()

      W := GetPrintableAreaWidth() - x - HO * 2
      H := GetPrintableAreaHeight() - y - VO * 2

      REPEAT

         th := ++tw / r

      UNTIL ( tw < w - x .OR. th < h - y )

      DoMethod ( cForm, 'Hide' )

      START PRINTDOC NAME 'MINIPRINT'
         START PRINTPAGE

            @ VO + y + ( h - th ) / 2, HO + x + ( w - tw ) / 2 PRINT IMAGE cTempFile WIDTH tW HEIGHT tH

         END PRINTPAGE
      END PRINTDOC

   ENDIF

   DO EVENTS

   DoMethod ( cForm, 'Release' )
   FErase( cTempFile )

RETURN .T.

#ifdef _HMG_COMPAT_
*-----------------------------------------------------------------------------*
FUNCTION PrintWindow ( cWindowName, lPreview, ldialog, nRow, nCol, nWidth, nHeight )
*-----------------------------------------------------------------------------*
   LOCAL lSuccess, nOrientation
   LOCAL TempName, W, H, HO, VO
   LOCAL bw, bh, r, tw := 0, th
   LOCAL ntop, nleft, nbottom, nright

   IF ValType ( nRow ) == 'U' .OR. ;
      ValType ( nCol ) == 'U' .OR. ;
      ValType ( nWidth ) == 'U' .OR. ;
      ValType ( nHeight ) == 'U'

      ntop := -1
      nleft := -1
      nbottom := -1
      nright := -1

   ELSE

      ntop := nRow
      nleft := nCol
      nbottom := nHeight + nRow
      nright := nWidth + nCol

   ENDIF

   IF ValType ( lDialog ) == 'U'
      lDialog := .F.
   ENDIF

   IF ValType ( lPreview ) == 'U'
      lPreview := .F.
   ENDIF

   IF ! _IsWIndowDefined ( cWindowName )
      MsgMiniGuiError ( _HMG_BRWLangError[ 1 ] + cWindowName + _HMG_BRWLangError[ 2 ], .F. )
   ENDIF

   IF ntop == -1

      bw := GetProperty ( cWindowName, 'Width' )
      bh := GetProperty ( cWindowName, 'Height' ) - GetTitleHeight ()

   ELSE

      bw := nright - nleft
      bh := nbottom - ntop

   ENDIF

   IF lDialog

      IF lPreview
         SELECT PRINTER DIALOG TO lSuccess PREVIEW
      ELSE
         SELECT PRINTER DIALOG TO lSuccess
      ENDIF

      IF ! lSuccess
         RETURN NIL
      ENDIF

   ELSE

      nOrientation := iif( bw > bh, PRINTER_ORIENT_LANDSCAPE, PRINTER_ORIENT_PORTRAIT )

      IF lPreview
         SELECT PRINTER DEFAULT TO lSuccess ORIENTATION nOrientation PREVIEW
      ELSE
         SELECT PRINTER DEFAULT TO lSuccess ORIENTATION nOrientation
      ENDIF

      IF ! lSuccess
         MsgMiniGuiError ( _HMG_aLangUser[ 25 ] )
      ENDIF

   ENDIF

   TempName := TempFile( GetTempFolder(), 'BMP' )

   SaveWindowByHandle ( GetFormHandle ( cWindowName ), TempName, ntop, nleft, nbottom, nright )

   HO := GetPrintableAreaHorizontalOffset()
   VO := GetPrintableAreaVerticalOffset()

   W := GetPrintableAreaWidth() - 10 - HO * 2
   H := GetPrintableAreaHeight() - 10 - VO * 2

   r := bw / bh

   REPEAT

      th := ++tw / r

   UNTIL ( tw < w .OR. th < h )

   START PRINTDOC

      START PRINTPAGE

         @ VO + 10 + ( h - th ) / 2, HO + 10 + ( w - tw ) / 2 PRINT IMAGE TempName WIDTH tW HEIGHT tH

      END PRINTPAGE

   END PRINTDOC

   DO EVENTS
   FErase( TempName )

RETURN NIL

#endif
