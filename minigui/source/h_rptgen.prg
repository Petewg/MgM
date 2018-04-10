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

#include "minigui.ch"
#include "miniprint.ch"
#include "fileio.ch"

* Main ************************************************************************

PROCEDURE _DefineReport ( cName )

   _HMG_RPTDATA[ 118 ] := 0
   _HMG_RPTDATA[ 119 ] := 0

   _HMG_RPTDATA[ 120 ] := 0

   _HMG_RPTDATA[ 121 ] := {}
   _HMG_RPTDATA[ 122 ] := {}

   _HMG_RPTDATA[ 123 ] := 0
   _HMG_RPTDATA[ 124 ] := 0

   _HMG_RPTDATA[ 155 ] := 0
   _HMG_RPTDATA[ 156 ] := 0

   _HMG_RPTDATA[ 157 ] := {}
   _HMG_RPTDATA[ 158 ] := {}
   _HMG_RPTDATA[ 159 ] := {}
   _HMG_RPTDATA[ 160 ] := {}
   _HMG_RPTDATA[ 126 ] := {}
   _HMG_RPTDATA[ 127 ] := 0
   _HMG_RPTDATA[ 161 ] := 'MAIN'

   _HMG_RPTDATA[ 164 ] := Nil
   _HMG_RPTDATA[ 165 ] := Nil

   IF cName <> '_TEMPLATE_'

      _HMG_RPTDATA[ 162 ] := cName

   ELSE

      cName := _HMG_RPTDATA[ 162 ]

   ENDIF

   Public &cName := {}

RETURN

PROCEDURE _EndReport

   LOCAL cReportName
   LOCAL aMiscdata

   aMiscData := {}

   AAdd ( aMiscData, _HMG_RPTDATA[ 120 ] ) // nGroupCount
   AAdd ( aMiscData, _HMG_RPTDATA[ 152 ] ) // nHeadeHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 153 ] ) // nDetailHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 154 ] ) // nFooterHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 127 ] ) // nSummaryHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 124 ] ) // nGroupHeaderHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 123 ] ) // nGroupFooterHeight
   AAdd ( aMiscData, _HMG_RPTDATA[ 125 ] ) // xGroupExpression
   AAdd ( aMiscData, _HMG_RPTDATA[ 164 ] ) // xSkipProcedure
   AAdd ( aMiscData, _HMG_RPTDATA[ 165 ] ) // xEOF

   cReportName := _HMG_RPTDATA[ 162 ]

   &cReportName := { _HMG_RPTDATA[ 159 ], _HMG_RPTDATA[ 160 ], _HMG_RPTDATA[ 158 ], _HMG_RPTDATA[ 157 ], _HMG_RPTDATA[ 126 ], _HMG_RPTDATA[ 121 ], _HMG_RPTDATA[ 122 ], aMiscData }

RETURN

* Layout **********************************************************************

PROCEDURE _BeginLayout

   _HMG_RPTDATA[ 161 ] := 'LAYOUT'

RETURN

PROCEDURE _EndLayout

   AAdd ( _HMG_RPTDATA[ 159 ], _HMG_RPTDATA[ 155 ] )
   AAdd ( _HMG_RPTDATA[ 159 ], _HMG_RPTDATA[ 156 ] )
   AAdd ( _HMG_RPTDATA[ 159 ], _HMG_RPTDATA[ 118 ] )
   AAdd ( _HMG_RPTDATA[ 159 ], _HMG_RPTDATA[ 119 ] )

RETURN

* Header **********************************************************************

PROCEDURE _BeginHeader

   _HMG_RPTDATA[ 161 ] := 'HEADER'

   _HMG_RPTDATA[ 160 ] := {}

RETURN

PROCEDURE _EndHeader

RETURN


* Detail **********************************************************************

PROCEDURE _BeginDetail

   _HMG_RPTDATA[ 161 ] := 'DETAIL'

   _HMG_RPTDATA[ 158 ] := {}

RETURN

PROCEDURE _EndDetail

RETURN

* Footer **********************************************************************

PROCEDURE _BeginFooter

   _HMG_RPTDATA[ 161 ] := 'FOOTER'

   _HMG_RPTDATA[ 157 ] := {}

RETURN

PROCEDURE _EndFooter

RETURN

* Summary *********************************************************************

PROCEDURE _BeginSummary

   _HMG_RPTDATA[ 161 ] := 'SUMMARY'

RETURN

PROCEDURE _EndSummary


RETURN


* Text ************************************************************************

PROCEDURE _BeginText

   _HMG_RPTDATA[ 116 ] := ''    // Text
   _HMG_ActiveControlRow := 0   // Row
   _HMG_ActiveControlCol := 0   // Col
   _HMG_ActiveControlWidth := 0   // Width
   _HMG_ActiveControlHeight := 0   // Height
   _HMG_ActiveControlFont := 'Arial'  // FontName
   _HMG_ActiveControlSize := 9   // FontSize
   _HMG_ActiveControlFontBold := .F.  // FontBold
   _HMG_ActiveControlFontItalic := .F.  // FontItalic
   _HMG_ActiveControlFontUnderLine := .F.  // FontUnderLine
   _HMG_ActiveControlFontStrikeOut := .F.  // FontStrikeout
   _HMG_ActiveControlFontColor := { 0, 0, 0 } // FontColor
   _HMG_ActiveControlRightAlign := .F.  // Alignment
   _HMG_ActiveControlCenterAlign := .F.  // Alignment

RETURN

PROCEDURE _EndText

   LOCAL aText

   aText := {      ;
      'TEXT', ;
      _HMG_RPTDATA[ 116 ], ;
      _HMG_ActiveControlRow, ;
      _HMG_ActiveControlCol, ;
      _HMG_ActiveControlWidth, ;
      _HMG_ActiveControlHeight, ;
      _HMG_ActiveControlFont, ;
      _HMG_ActiveControlSize, ;
      _HMG_ActiveControlFontBold, ;
      _HMG_ActiveControlFontItalic, ;
      _HMG_ActiveControlFontUnderLine, ;
      _HMG_ActiveControlFontStrikeOut, ;
      _HMG_ActiveControlFontColor, ;
      _HMG_ActiveControlRightAlign, ;
      _HMG_ActiveControlCenterAlign   ;
      }

   IF _HMG_RPTDATA[ 161 ] == 'HEADER'

      AAdd (  _HMG_RPTDATA[ 160 ], aText )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'DETAIL'

      AAdd ( _HMG_RPTDATA[ 158 ], aText )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'FOOTER'

      AAdd ( _HMG_RPTDATA[ 157 ], aText )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'SUMMARY'

      AAdd ( _HMG_RPTDATA[ 126 ], aText )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPHEADER'

      AAdd ( _HMG_RPTDATA[ 121 ], aText )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPFOOTER'

      AAdd ( _HMG_RPTDATA[ 122 ], aText )

   ENDIF

RETURN

* Band Height *****************************************************************

PROCEDURE _BandHeight ( nValue )

   IF _HMG_RPTDATA[ 161 ] == 'HEADER'

      _HMG_RPTDATA[ 152 ] := nValue

   ELSEIF _HMG_RPTDATA[ 161 ] == 'DETAIL'

      _HMG_RPTDATA[ 153 ] := nValue

   ELSEIF _HMG_RPTDATA[ 161 ] == 'FOOTER'

      _HMG_RPTDATA[ 154 ] := nValue

   ELSEIF _HMG_RPTDATA[ 161 ] == 'SUMMARY'

      _HMG_RPTDATA[ 127 ] := nValue

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPHEADER'

      _HMG_RPTDATA[ 124 ] := nValue

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPFOOTER'

      _HMG_RPTDATA[ 123 ] := nValue

   ENDIF

RETURN

* Execute *********************************************************************

PROCEDURE ExecuteReport ( cReportName, lPreview, lSelect, cOutputFileName )

   LOCAL aLayout
   LOCAL aHeader
   LOCAL aDetail
   LOCAL aFooter
   LOCAL aSummary
   LOCAL aTemp
   LOCAL cPrinter
   LOCAL nPaperWidth
   LOCAL nPaperHeight
   LOCAL nOrientation
   LOCAL nPaperSize
   LOCAL nHeadeHeight
   LOCAL nDetailHeight
   LOCAL nFooterHeight
   LOCAL nCurrentOffset
   LOCAL nPreviousRecNo
   LOCAL nSummaryHeight
   LOCAL aGroupHeader
   LOCAL aGroupFooter
   LOCAL nGroupHeaderHeight
   LOCAL nGroupFooterHeight
   LOCAL xGroupExpression
   LOCAL nGroupCount
   LOCAL xPreviousGroupExpression
   LOCAL lGroupStarted
   LOCAL lSuccess
   LOCAL aMiscData
   LOCAL xTemp
   LOCAL aPaper[ 18 ][ 2 ]
   LOCAL cPdfPaperSize := ''
   LOCAL cPdfOrientation := ''
   LOCAL nOutfile
   LOCAL xSkipProcedure
   LOCAL xEOF
   LOCAL lTempEof

   IF _HMG_RPTDATA[ 120 ] > 1
      MsgMiniGUIError( 'Only One Group Level Allowed' )
   ENDIF

   _HMG_RPTDATA[ 149 ] := ''
   _HMG_RPTDATA[ 150 ] := .F.
   _HMG_RPTDATA[ 163 ] := .F.

   IF ValType ( cOutputFileName ) == 'C'

      IF AllTrim ( Upper ( Right ( cOutputFileName, 4 ) ) ) == '.PDF'

         _HMG_RPTDATA[ 150 ] := .T.

      ELSEIF AllTrim ( Upper ( Right ( cOutputFileName, 5 ) ) ) == '.HTML'

         _HMG_RPTDATA[ 163 ] := .T.

      ENDIF

   ENDIF

   IF _HMG_RPTDATA[ 163 ] == .T.

      _HMG_RPTDATA[ 149 ] += '<html>' + Chr( 13 ) + Chr( 10 )

      _HMG_RPTDATA[ 149 ] += '<style>' + Chr( 13 ) + Chr( 10 )
      _HMG_RPTDATA[ 149 ] += 'div {position:absolute}' + Chr( 13 ) + Chr( 10 )
      _HMG_RPTDATA[ 149 ] += '.line { }' + Chr( 13 ) + Chr( 10 )
      _HMG_RPTDATA[ 149 ] += '</style>' + Chr( 13 ) + Chr( 10 )

      _HMG_RPTDATA[ 149 ] += '<body>' + Chr( 13 ) + Chr( 10 )

   ENDIF

   IF _HMG_RPTDATA[ 150 ] == .T.
      PdfInit()
      pdfOpen( cOutputFileName, 200, .T. )
   ENDIF

   IF ValType ( xSkipProcedure ) == 'U'

      * If not workarea open, cancel report execution

      IF Select() == 0
         RETURN
      ENDIF

      nPreviousRecNo := RecNo()

   ENDIF

   * **********************************************************************
   * Determine Print Parameters
   * **********************************************************************

   aTemp := __mvGet ( cReportName )

   aLayout  := aTemp[ 1 ]
   aHeader  := aTemp[ 2 ]
   aDetail  := aTemp[ 3 ]
   aFooter  := aTemp[ 4 ]
   aSummary := aTemp[ 5 ]
   aGroupHeader := aTemp[ 6 ]
   aGroupFooter := aTemp[ 7 ]
   aMiscData := aTemp[ 8 ]

   nGroupCount := aMiscData[ 1 ]
   nHeadeHeight := aMiscData[ 2 ]
   nDetailHeight := aMiscData[ 3 ]
   nFooterHeight := aMiscData[ 4 ]
   nSummaryHeight := aMiscData[ 5 ]
   nGroupHeaderHeight := aMiscData[ 6 ]
   nGroupFooterHeight := aMiscData[ 7 ]
   xTemp := aMiscData[ 8 ]
   xSkipProcedure := aMiscData[ 9 ]
   xEOF  := aMiscData[ 10 ]

   nOrientation := aLayout[ 1 ]
   nPaperSize   := aLayout[ 2 ]
   nPaperWidth  := aLayout[ 3 ]
   nPaperHeight := aLayout[ 4 ]

   IF ValType ( lPreview ) <> 'L'
      lPreview := .F.
   ENDIF

   IF ValType ( lSelect ) <> 'L'
      lSelect := .F.
   ENDIF

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      IF lSelect == .T.
         cPrinter := GetPrinter()
      ELSE
         cPrinter := GetDefaultPrinter()
      ENDIF

      IF Empty ( cPrinter )
         RETURN
      ENDIF

   ENDIF

   * **********************************************************************
   * Select Printer
   * **********************************************************************

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      IF lPreview == .T.

         IF nPaperSize == PRINTER_PAPER_USER

            SELECT PRINTER cPrinter ;
               TO lSuccess ;
               ORIENTATION nOrientation ;
               PAPERSIZE nPaperSize ;
               PAPERWIDTH nPaperWidth ;
               PAPERLENGTH nPaperHeight ;
               PREVIEW

         ELSE

            SELECT PRINTER cPrinter ;
               TO lSuccess ;
               ORIENTATION nOrientation ;
               PAPERSIZE nPaperSize ;
               PREVIEW

         ENDIF

      ELSE

         IF nPaperSize == PRINTER_PAPER_USER

            SELECT PRINTER cPrinter ;
               TO lSuccess ;
               ORIENTATION nOrientation ;
               PAPERSIZE nPaperSize ;
               PAPERWIDTH nPaperWidth ;
               PAPERLENGTH nPaperHeight

         ELSE

            SELECT PRINTER cPrinter ;
               TO lSuccess ;
               ORIENTATION nOrientation ;
               PAPERSIZE nPaperSize ;

         ENDIF

      ENDIF

      IF ! lSuccess
         MsgMiniGuiError ( "Report: Can't Init Printer." )
      ENDIF

   ENDIF

   * **********************************************************************
   * Determine Paper Dimensions in mm.
   * **********************************************************************

   IF npaperSize >= 1 .AND. nPaperSize <= 18

      aPaper[ PRINTER_PAPER_LETTER      ] := { 215.9, 279.4 }
      aPaper[ PRINTER_PAPER_LETTERSMALL ] := { 215.9, 279.4 }
      aPaper[ PRINTER_PAPER_TABLOID     ] := { 279.4, 431.8 }
      aPaper[ PRINTER_PAPER_LEDGER      ] := { 431.8, 279.4 }
      aPaper[ PRINTER_PAPER_LEGAL       ] := { 215.9, 355.6 }
      aPaper[ PRINTER_PAPER_STATEMENT   ] := { 139.7, 215.9 }
      aPaper[ PRINTER_PAPER_EXECUTIVE   ] := { 184.15, 266.7 }
      aPaper[ PRINTER_PAPER_A3          ] := { 297, 420 }
      aPaper[ PRINTER_PAPER_A4          ] := { 210, 297 }
      aPaper[ PRINTER_PAPER_A4SMALL     ] := { 210, 297 }
      aPaper[ PRINTER_PAPER_A5          ] := { 148, 210 }
      aPaper[ PRINTER_PAPER_B4          ] := { 250, 354 }
      aPaper[ PRINTER_PAPER_B5          ] := { 182, 257 }
      aPaper[ PRINTER_PAPER_FOLIO       ] := { 215.9, 330.2 }
      aPaper[ PRINTER_PAPER_QUARTO      ] := { 215, 275 }
      aPaper[ PRINTER_PAPER_10X14       ] := { 254, 355.6 }
      aPaper[ PRINTER_PAPER_11X17       ] := { 279.4, 431.8 }
      aPaper[ PRINTER_PAPER_NOTE        ] := { 215.9, 279.4 }

      IF  nOrientation == PRINTER_ORIENT_PORTRAIT

         npaperHeight := aPaper[ nPaperSize ][ 2 ]

      ELSEIF nOrientation == PRINTER_ORIENT_LANDSCAPE

         npaperHeight := aPaper[ nPaperSize ][ 1 ]

      ELSE

         MsgMiniGUIError ( 'Report: Orientation Not Supported.' )

      ENDIF

   ELSE

      MsgMiniGUIError ( 'Report: Paper Size Not Supported.' )

   ENDIF


   IF _HMG_RPTDATA[ 150 ] == .T.

      * PDF Paper Size

      IF nPaperSize == PRINTER_PAPER_LETTER

         cPdfPaperSize := "LETTER"

      ELSEIF nPaperSize == PRINTER_PAPER_LEGAL

         cPdfPaperSize := "LEGAL"

      ELSEIF nPaperSize == PRINTER_PAPER_A4

         cPdfPaperSize := "A4"

      ELSEIF nPaperSize == PRINTER_PAPER_TABLOID

         cPdfPaperSize := "LEDGER"

      ELSEIF nPaperSize == PRINTER_PAPER_EXECUTIVE

         cPdfPaperSize := "EXECUTIVE"

      ELSEIF nPaperSize == PRINTER_PAPER_A3

         cPdfPaperSize := "A3"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_10

         cPdfPaperSize := "COM10"

      ELSEIF nPaperSize == PRINTER_PAPER_B4

         cPdfPaperSize := "JIS B4"

      ELSEIF nPaperSize == PRINTER_PAPER_B5

         cPdfPaperSize := "B5"

      ELSEIF nPaperSize == PRINTER_PAPER_P32K

         cPdfPaperSize := "JPOST"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_C5

         cPdfPaperSize := "C5"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_DL

         cPdfPaperSize := "DL"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_B5

         cPdfPaperSize := "B5"

      ELSEIF nPaperSize == PRINTER_PAPER_ENV_MONARCH

         cPdfPaperSize := "MONARCH"

      ELSE

         MsgMiniGUIError ( "Report: PDF Paper Size Not Supported." )

      ENDIF

      * PDF Orientation

      IF  nOrientation == PRINTER_ORIENT_PORTRAIT

         cPdfOrientation := 'P'

      ELSEIF nOrientation == PRINTER_ORIENT_LANDSCAPE

         cPdfOrientation := 'L'

      ELSE

         MsgMiniGUIError ( 'Report: Orientation Not Supported.' )

      ENDIF

   ENDIF

   ***********************************************************************
   * Print Document
   ***********************************************************************

   IF nGroupCount > 0

      xGroupExpression := &( xTemp )

   ENDIF

   _HMG_RPTDATA[ 117 ] := 1

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      START PRINTDOC

   ENDIF

   IF ValType ( xSkipProcedure ) == 'U'
      GO TOP
   ENDIF

   xPreviousGroupExpression := ''
   lGroupStarted := .F.

   IF ValType ( xSkipProcedure ) == 'U'
      lTempEof := Eof()
   ELSE
      lTempEof := Eval( xEof )
   ENDIF

   DO WHILE .NOT. lTempEof

      IF _HMG_RPTDATA[ 163 ] == .F.

         IF _HMG_RPTDATA[ 150 ] == .T.

            pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )

         ELSE

            START PRINTPAGE

         ENDIF

         nCurrentOffset := 0

         _ProcessBand ( aHeader, nCurrentOffset )

         nCurrentOffset := nHeadeHeight

         DO WHILE .T.

            IF nGroupCount > 0

               IF ( ValType ( xPreviousGroupExpression ) != ValType ( xGroupExpression ) ) .OR. ( xPreviousGroupExpression <> xGroupExpression )

                  IF lGroupStarted

                     _ProcessBand ( aGroupFooter, nCurrentOffset )
                     nCurrentOffset += nGroupFooterHeight

                  ENDIF

                  _ProcessBand ( aGroupHeader, nCurrentOffset )
                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               ENDIF

            ENDIF

            _ProcessBand ( aDetail, nCurrentOffset )

            nCurrentOffset += nDetailHeight

            IF ValType ( xSkipProcedure ) == 'U'
               SKIP
               lTempEof := Eof()
            ELSE
               Eval( xSkipProcedure )
               lTempEof := Eval( xEof )
            ENDIF

            IF lTempEof

               * If group footer defined, PRINT it.

               IF nGroupFooterHeight > 0

                  * If group footer don't fit in the current page, print page footer,
                  * start a NEW page and PRINT header first

                  IF nCurrentOffset + nGroupFooterHeight > nPaperHeight - nFooterHeight

                     nCurrentOffset := nPaperHeight - nFooterHeight
                     _ProcessBand ( aFooter, nCurrentOffset )

                     IF _HMG_RPTDATA[ 150 ] == .F.

                        END PRINTPAGE
                        START PRINTPAGE

                     ELSE

                        pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )

                     ENDIF

                     _HMG_RPTDATA[ 117 ]++

                     nCurrentOffset := 0
                     _ProcessBand ( aHeader, nCurrentOffset )
                     nCurrentOffset := nHeadeHeight

                  ENDIF

                  _ProcessBand ( aGroupFooter, nCurrentOffset )
                  nCurrentOffset += nGroupFooterHeight

               ENDIF

               * If Summary defined, PRINT it.

               IF Len ( aSummary ) > 0

                  * If summary don't fit in the current page, print footer,
                  * start a NEW page and PRINT header first

                  IF nCurrentOffset + nSummaryHeight > nPaperHeight - nFooterHeight

                     nCurrentOffset := nPaperHeight - nFooterHeight
                     _ProcessBand ( aFooter, nCurrentOffset )

                     IF _HMG_RPTDATA[ 150 ] == .F.

                        END PRINTPAGE
                        START PRINTPAGE

                     ELSE

                        pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )

                     ENDIF

                     _HMG_RPTDATA[ 117 ]++

                     nCurrentOffset := 0
                     _ProcessBand ( aHeader, nCurrentOffset )
                     nCurrentOffset := nHeadeHeight

                  ENDIF

                  _ProcessBand ( aSummary, nCurrentOffset )

                  EXIT

               ENDIF

               EXIT

            ENDIF

            IF nGroupCount > 0

               xGroupExpression := &( xTemp )

            ENDIF

            IF nCurrentOffset + nDetailHeight > nPaperHeight - nFooterHeight

               EXIT

            ENDIF

         ENDDO

         nCurrentOffset := nPaperHeight - nFooterHeight

         _ProcessBand ( aFooter, nCurrentOffset )

         IF _HMG_RPTDATA[ 150 ] == .F.

            END PRINTPAGE

         ENDIF

         _HMG_RPTDATA[ 117 ]++

      ELSE

         nCurrentOffset := 0

         _ProcessBand ( aHeader, nCurrentOffset )

         nCurrentOffset := nHeadeHeight

         DO WHILE .T.

            IF nGroupCount > 0

               IF xPreviousGroupExpression <> xGroupExpression

                  IF lGroupStarted

                     _ProcessBand ( aGroupFooter, nCurrentOffset )
                     nCurrentOffset += nGroupFooterHeight

                  ENDIF

                  _ProcessBand ( aGroupHeader, nCurrentOffset )
                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               ENDIF

            ENDIF

            _ProcessBand ( aDetail, nCurrentOffset )

            nCurrentOffset += nDetailHeight

            IF ValType ( xSkipProcedure ) == 'U'
               SKIP
               lTempEof := Eof()
            ELSE
               Eval( xSkipProcedure )
               lTempEof := Eval( xEof )
            ENDIF

            IF lTempEof

               * If group footer defined, PRINT it.

               IF nGroupFooterHeight > 0

                  _ProcessBand ( aGroupFooter, nCurrentOffset )
                  nCurrentOffset += nGroupFooterHeight

               ENDIF

               * If Summary defined, PRINT it.

               IF Len ( aSummary ) > 0
                  _ProcessBand ( aSummary, nCurrentOffset )
                  nCurrentOffset += nSummaryHeight
               ENDIF

               EXIT

            ENDIF

            IF nGroupCount > 0
               xGroupExpression := &( xTemp )
            ENDIF

         ENDDO

         _ProcessBand ( aFooter, nCurrentOffset )

      ENDIF

   ENDDO

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      END PRINTDOC

   ELSEIF _HMG_RPTDATA[ 150 ] == .T.

      pdfClose()

   ELSEIF _HMG_RPTDATA[ 163 ] == .T.

      _HMG_RPTDATA[ 149 ] += '</body>' + Chr( 13 ) + Chr( 10 )
      _HMG_RPTDATA[ 149 ] += '</html>' + Chr( 13 ) + Chr( 10 )

      nOutfile := FCreate( cOutputFileName, FC_NORMAL )

      FWrite( nOutfile, _HMG_RPTDATA[ 149 ], Len( _HMG_RPTDATA[ 149 ] ) )

      FClose( nOutfile )

   ENDIF

   IF ValType ( xSkipProcedure ) == 'U'
      GO nPreviousRecNo
   ENDIF

RETURN

*.............................................................................*
STATIC PROCEDURE _ProcessBand ( aBand, nOffset )
*.............................................................................*
   LOCAL i

   FOR i := 1 TO Len ( aBand )

      _PrintObject ( aBand[i ], nOffset )

   NEXT i

RETURN

*.............................................................................*
STATIC PROCEDURE _PrintObject ( aObject, nOffset )
*.............................................................................*

   IF aObject[ 1 ] == 'TEXT'

      _PrintText( aObject, nOffset )

   ELSEIF aObject[ 1 ] == 'IMAGE'

      _PrintImage( aObject, nOffset )

   ELSEIF aObject[ 1 ] == 'LINE'

      _PrintLine( aObject, nOffset )

   ELSEIF aObject[ 1 ] == 'RECTANGLE'

      _PrintRectangle( aObject, nOffset )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _PrintText( aObject, nOffset )
*-----------------------------------------------------------------------------*
   LOCAL cValue  := aObject[ 2 ]
   LOCAL nRow  := aObject[ 3 ]
   LOCAL nCol  := aObject[ 4 ]
   LOCAL nWidth  := aObject[ 5 ]
   LOCAL nHeight  := aObject[ 6 ]
   LOCAL cFontname  := aObject[ 7 ]
   LOCAL nFontSize  := aObject[ 8 ]
   LOCAL lFontBold  := aObject[ 9 ]
   LOCAL lFontItalic := aObject[ 10 ]
   LOCAL lFontUnderLine := aObject[ 11 ]
   LOCAL lFOntStrikeout := aObject[ 12 ]
   LOCAL aFontColor := aObject[ 13 ]
   LOCAL lAlignment_1  := aObject[ 14 ]
   LOCAL lAlignment_2  := aObject[ 15 ]
   LOCAL cAlignment := ''
   LOCAL nFontStyle := 0
   LOCAL nTextRowFix := 5
   LOCAL cHtmlAlignment

   cValue := &cValue

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      IF lAlignment_1 == .F. .AND.  lAlignment_2 == .T.

         cAlignment := 'CENTER'

      ELSEIF lAlignment_1 == .T. .AND.  lAlignment_2 == .F.

         cAlignment := 'RIGHT'

      ELSEIF lAlignment_1 == .F. .AND.  lAlignment_2 == .F.

         cAlignment := ''

      ENDIF

      _HMG_PRINTER_H_MULTILINE_PRINT ( _HMG_PRINTER_HDC, nRow  + nOffset, nCol, nRow + nHeight  + nOffset, nCol + nWidth, cFontName, nFontSize, aFontColor[ 1 ], aFontColor[ 2 ], aFontColor[ 3 ], cValue, lFontBold, lFontItalic, lFontUnderline, lFontStrikeout, .T., .T., .T., cAlignment )

   ELSEIF _HMG_RPTDATA[ 163 ] == .T.

      IF ValType ( cValue ) == "N"

         cValue := AllTrim( Str( cValue ) )

      ELSEIF ValType ( cValue ) == "D"

         cValue := DToC ( cValue )

      ELSEIF ValType ( cValue ) == "L"

         cValue := if ( cValue == .T., _HMG_RPTDATA[ 371 ][ 24 ], _HMG_RPTDATA[ 371 ][ 25 ] )

      ENDIF

      IF lAlignment_1 == .F. .AND.  lAlignment_2 == .T.

         cHtmlAlignment := 'center'

      ELSEIF lAlignment_1 == .T. .AND.  lAlignment_2 == .F.

         cHtmlAlignment := 'right'

      ELSEIF lAlignment_1 == .F. .AND.  lAlignment_2 == .F.

         cHtmlAlignment := 'left'

      ENDIF

      _HMG_RPTDATA[ 149 ] += '<div style=position:absolute;left:' + AllTrim( Str( nCol ) ) +  'mm;top:' +  AllTrim( Str( nRow + nOffset ) ) + 'mm;width:' +  AllTrim( Str( nWidth ) ) + 'mm;font-size:' + AllTrim( Str( nFontSize ) ) + 'pt;font-family:"' +  cFontname + '";text-align:' + cHtmlAlignment + ';font-weight:' + if( lFontBold, 'bold', 'normal' ) + ';font-style:' + if( lFontItalic, 'italic', 'normal' ) + ';text-decoration:' + if( lFontUnderLine, 'underline', 'none' ) + ';color:rgb(' + AllTrim( Str( aFontColor[ 1 ] ) ) + ',' + AllTrim( Str( aFontColor[ 2 ] ) ) + ',' +  AllTrim( Str( aFontColor[ 3 ] ) ) + ');>' + cValue + '</div>' + Chr( 13 ) + Chr( 10 )

   ELSEIF _HMG_RPTDATA[ 150 ] == .T.

      IF ValType ( cValue ) == "N"

         cValue := AllTrim( Str( cValue ) )

      ELSEIF ValType ( cValue ) == "D"

         cValue := DToC ( cValue )

      ELSEIF ValType ( cValue ) == "L"

         cValue := if ( cValue == .T., _HMG_RPTDATA[ 371 ][ 24 ], _HMG_RPTDATA[ 371 ][ 25 ] )

      ENDIF

      IF lFontBold == .F. .AND. lFontItalic == .F.

         nFontStyle := 0

      ELSEIF lFontBold == .T. .AND. lFontItalic == .F.

         nFontStyle := 1

      ELSEIF lFontBold == .F. .AND. lFontItalic == .T.

         nFontStyle := 2

      ELSEIF lFontBold == .T. .AND. lFontItalic == .T.

         nFontStyle := 3

      ENDIF

      pdfSetFont( cFontname, nFontStyle, nFontSize )

      IF lAlignment_1 == .F. .AND.  lAlignment_2 == .T. // Center

         IF lFontUnderLine

            pdfAtSay ( cValue + Chr( 254 ), nRow + nOffset + nTextRowFix, nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2, 'M' )

         ELSE

            pdfAtSay ( Chr( 253 ) + Chr( aFontColor[ 1 ] ) + Chr( aFontColor[ 2 ] ) + Chr( aFontColor[ 3 ] ) + cValue, nRow + nOffset + nTextRowFix, nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2, 'M' )

         ENDIF

      ELSEIF lAlignment_1 == .T. .AND.  lAlignment_2 == .F. // Right

         IF lFontUnderLine

            pdfAtSay ( cValue + Chr( 254 ), nRow + nOffset + nTextRowFix, nCol + nWidth - pdfTextWidth( cValue ) * 25.4, 'M' )

         ELSE

            pdfAtSay ( Chr( 253 ) + Chr( aFontColor[ 1 ] ) + Chr( aFontColor[ 2 ] ) + Chr( aFontColor[ 3 ] ) + cValue, nRow + nOffset + nTextRowFix, nCol + nWidth - pdfTextWidth( cValue ) * 25.4, 'M' )

         ENDIF

      ELSEIF lAlignment_1 == .F. .AND.  lAlignment_2 == .F. // Left

         IF lFontUnderLine

            pdfAtSay ( cValue + Chr( 254 ), nRow + nOffset + nTextRowFix, nCol, 'M' )

         ELSE

            pdfAtSay ( Chr( 253 ) + Chr( aFontColor[ 1 ] ) + Chr( aFontColor[ 2 ] ) + Chr( aFontColor[ 3 ] ) + cValue, nRow + nOffset + nTextRowFix, nCol, 'M' )

         ENDIF

      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _PrintImage( aObject, nOffset )
*-----------------------------------------------------------------------------*
   LOCAL cValue  := aObject[ 2 ]
   LOCAL nRow  := aObject[ 3 ]
   LOCAL nCol  := aObject[ 4 ]
   LOCAL nWidth  := aObject[ 5 ]
   LOCAL nHeight  := aObject[ 6 ]

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      _HMG_PRINTER_H_IMAGE ( _HMG_PRINTER_HDC, cValue, nRow + nOffset, nCol, nHeight, nWidth, .T. )

   ELSEIF _HMG_RPTDATA[ 150 ] == .T.

      IF Upper ( Right( cValue, 4 ) ) == '.JPG'

         pdfImage ( cValue, nRow + nOffset, nCol, "M", nHeight, nWidth )

      ELSE

         MsgMiniGuiError ( "Report: Only JPG images allowed." )

      ENDIF

   ELSEIF _HMG_RPTDATA[ 163 ] == .T.

      _HMG_RPTDATA[ 149 ] += '<div style=position:absolute;left:' + AllTrim( Str( nCol ) ) + 'mm;top:' + AllTrim( Str( nRow + nOffset ) )  + 'mm;> <img src="' + cValue + '" ' + 'width=' + AllTrim( Str( nWidth * 3.85 ) ) + 'mm height=' + AllTrim( Str( nHeight * 3.85 ) ) + 'mm/> </div>' + Chr( 13 ) + Chr( 10 )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _PrintLine( aObject, nOffset )
*-----------------------------------------------------------------------------*
   LOCAL nFromRow  := aObject[ 2 ]
   LOCAL nFromCol  := aObject[ 3 ]
   LOCAL nToRow  := aObject[ 4 ]
   LOCAL nToCol  := aObject[ 5 ]
   LOCAL nPenWidth  := aObject[ 6 ]
   LOCAL aPenColor  := aObject[ 7 ]

   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      _HMG_PRINTER_H_LINE ( _HMG_PRINTER_HDC, nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, nPenWidth, aPenColor[ 1 ], aPenColor[ 2 ], aPenColor[ 3 ], .T., .T. )

   ELSEIF _HMG_RPTDATA[ 150 ] == .T.

      IF nFromRow <> nToRow .AND. nFromCol <> nToCol
         MsgMiniGUIError ( 'Report: Only horizontal and vertical lines are supported with PDF output.' )
      ENDIF

      pdfBox ( nFromRow + nOffset, nFromCol, nToRow + nOffset + nPenWidth, nToCol, 0, 1, "M", Chr( 253 ) + Chr( aPenColor[ 1 ] ) + Chr( aPenColor[ 2 ] ) + Chr( aPenColor[ 3 ] ) )

   ELSEIF _HMG_RPTDATA[ 163 ] == .T.

      _HMG_RPTDATA[ 149 ] += '<div style="left:' + AllTrim( Str( nFromCol ) ) + 'mm;top:' +  AllTrim( Str( nFromRow + nOffset ) ) +  'mm;width:' +  AllTrim( Str( nToCol - nFromCol ) ) +  'mm;height:0mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + AllTrim( Str( aPenColor[ 1 ] ) ) + ',' + AllTrim( Str( aPenColor[ 2 ] ) ) + ',' +  AllTrim( Str( aPenColor[ 3 ] ) ) + ')' + ';BORDER-WIDTH:' + AllTrim( Str( nPenWidth ) ) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + Chr( 13 ) + Chr( 10 )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _PrintRectangle( aObject, nOffset )
*-----------------------------------------------------------------------------*
   LOCAL nFromRow  := aObject[ 2 ]
   LOCAL nFromCol  := aObject[ 3 ]
   LOCAL nToRow  := aObject[ 4 ]
   LOCAL nToCol  := aObject[ 5 ]
   LOCAL nPenWidth  := aObject[ 6 ]
   LOCAL aPenColor  := aObject[ 7 ]


   IF _HMG_RPTDATA[ 150 ] == .F. .AND. _HMG_RPTDATA[ 163 ] == .F.

      _HMG_PRINTER_H_RECTANGLE ( _HMG_PRINTER_HDC, nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, nPenWidth, aPenColor[ 1 ], aPenColor[ 2 ], aPenColor[ 3 ], .T., .T. )

   ELSEIF _HMG_RPTDATA[ 150 ] == .T.

      pdfBox( nFromRow + nOffset, nFromCol, nFromRow + nOffset + nPenWidth, nToCol, 0, 1, "M", Chr( 253 ) + Chr( aPenColor[ 1 ] ) + Chr( aPenColor[ 2 ] ) + Chr( aPenColor[ 3 ] ) )
      pdfBox( nToRow + nOffset, nFromCol, nToRow + nOffset + nPenWidth, nToCol, 0, 1, "M", Chr( 253 ) + Chr( aPenColor[ 1 ] ) + Chr( aPenColor[ 2 ] ) + Chr( aPenColor[ 3 ] ) )
      pdfBox( nFromRow + nOffset, nFromCol, nToRow + nOffset, nFromCol + nPenWidth, 0, 1, "M", Chr( 253 ) + Chr( aPenColor[ 1 ] ) + Chr( aPenColor[ 2 ] ) + Chr( aPenColor[ 3 ] ) )
      pdfBox( nFromRow + nOffset, nToCol, nToRow + nOffset, nToCol + nPenWidth, 0, 1, "M", Chr( 253 ) + Chr( aPenColor[ 1 ] ) + Chr( aPenColor[ 2 ] ) + Chr( aPenColor[ 3 ] ) )

   ELSEIF _HMG_RPTDATA[ 163 ] == .T.

      _HMG_RPTDATA[ 149 ] += '<div style="left:' + AllTrim( Str( nFromCol ) ) + 'mm;top:' +  AllTrim( Str( nFromRow + nOffset ) ) +  'mm;width:' +  AllTrim( Str( nToCol - nFromCol ) ) +  'mm;height:' + AllTrim( Str( nToRow - nFromRow ) ) + 'mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + AllTrim( Str( aPenColor[ 1 ] ) ) + ',' + AllTrim( Str( aPenColor[ 2 ] ) ) + ',' +  AllTrim( Str( aPenColor[ 3 ] ) ) + ')' + ';BORDER-WIDTH:' + AllTrim( Str( nPenWidth ) ) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + Chr( 13 ) + Chr( 10 )

   ENDIF

RETURN

* Line **********************************************************************

PROCEDURE _BeginLine

   _HMG_RPTDATA[ 110 ] := 0  // FromRow
   _HMG_RPTDATA[ 111 ] := 0  // FromCol
   _HMG_RPTDATA[ 112 ] := 0  // ToRow
   _HMG_RPTDATA[ 113 ] := 0  // ToCol
   _HMG_RPTDATA[ 114 ] := 1  // PenWidth
   _HMG_RPTDATA[ 115 ] := { 0, 0, 0 } // PenColor

RETURN

PROCEDURE _EndLine

   LOCAL aLine

   aLine := {     ;
      'LINE', ;
      _HMG_RPTDATA[ 110 ], ;
      _HMG_RPTDATA[ 111 ], ;
      _HMG_RPTDATA[ 112 ], ;
      _HMG_RPTDATA[ 113 ], ;
      _HMG_RPTDATA[ 114 ], ;
      _HMG_RPTDATA[ 115 ]   ;
      }

   IF _HMG_RPTDATA[ 161 ] == 'HEADER'

      AAdd (  _HMG_RPTDATA[ 160 ], aLine )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'DETAIL'

      AAdd ( _HMG_RPTDATA[ 158 ], aLine )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'FOOTER'

      AAdd ( _HMG_RPTDATA[ 157 ], aLine )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'SUMMARY'

      AAdd ( _HMG_RPTDATA[ 126 ], aLine )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPHEADER'

      AAdd ( _HMG_RPTDATA[ 121 ], aLine )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPFOOTER'

      AAdd ( _HMG_RPTDATA[ 122 ], aLine )

   ENDIF

RETURN

* Image **********************************************************************

PROCEDURE _BeginImage

   _HMG_ActiveControlValue := ''   // Value
   _HMG_ActiveControlRow := 0   // Row
   _HMG_ActiveControlCol := 0   // Col
   _HMG_ActiveControlWidth := 0   // Width
   _HMG_ActiveControlHeight := 0   // Height
   _HMG_ActiveControlStretch := .F.  // Stretch

RETURN

PROCEDURE _EndImage

   LOCAL aImage

   aImage := {      ;
      'IMAGE', ;
      _HMG_ActiveControlValue, ;
      _HMG_ActiveControlRow, ;
      _HMG_ActiveControlCol, ;
      _HMG_ActiveControlWidth, ;
      _HMG_ActiveControlHeight, ;
      _HMG_ActiveControlStretch   ;
      }

   IF _HMG_RPTDATA[ 161 ] == 'HEADER'

      AAdd (  _HMG_RPTDATA[ 160 ], aImage )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'DETAIL'

      AAdd ( _HMG_RPTDATA[ 158 ], aImage )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'FOOTER'

      AAdd ( _HMG_RPTDATA[ 157 ], aImage )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'SUMMARY'

      AAdd ( _HMG_RPTDATA[ 126 ], aImage )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPHEADER'

      AAdd ( _HMG_RPTDATA[ 121 ], aImage )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPFOOTER'

      AAdd ( _HMG_RPTDATA[ 122 ], aImage )

   ENDIF

RETURN

* Rectangle **********************************************************************

PROCEDURE _BeginRectangle

   _HMG_RPTDATA[ 110 ] := 0  // FromRow
   _HMG_RPTDATA[ 111 ] := 0  // FromCol
   _HMG_RPTDATA[ 112 ] := 0  // ToRow
   _HMG_RPTDATA[ 113 ] := 0  // ToCol
   _HMG_RPTDATA[ 114 ] := 1  // PenWidth
   _HMG_RPTDATA[ 115 ] := { 0, 0, 0 } // PenColor

RETURN

PROCEDURE _EndRectangle

   LOCAL aRectangle

   aRectangle := {     ;
      'RECTANGLE', ;
      _HMG_RPTDATA[ 110 ], ;
      _HMG_RPTDATA[ 111 ], ;
      _HMG_RPTDATA[ 112 ], ;
      _HMG_RPTDATA[ 113 ], ;
      _HMG_RPTDATA[ 114 ], ;
      _HMG_RPTDATA[ 115 ]   ;
      }

   IF _HMG_RPTDATA[ 161 ] == 'HEADER'

      AAdd (  _HMG_RPTDATA[ 160 ], aRectangle )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'DETAIL'

      AAdd ( _HMG_RPTDATA[ 158 ], aRectangle )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'FOOTER'

      AAdd ( _HMG_RPTDATA[ 157 ], aRectangle )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'SUMMARY'

      AAdd ( _HMG_RPTDATA[ 126 ], aRectangle )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPHEADER'

      AAdd ( _HMG_RPTDATA[ 121 ], aRectangle )

   ELSEIF _HMG_RPTDATA[ 161 ] == 'GROUPFOOTER'

      AAdd ( _HMG_RPTDATA[ 122 ], aRectangle )

   ENDIF

RETURN

*..............................................................................
PROCEDURE _BeginGroup()
*..............................................................................

   _HMG_RPTDATA[ 161 ] := 'GROUP'

   _HMG_RPTDATA[ 120 ]++

RETURN

*..............................................................................
PROCEDURE _EndGroup()
*..............................................................................

RETURN

*..............................................................................
PROCEDURE _BeginGroupHeader()
*..............................................................................

   _HMG_RPTDATA[ 161 ] := 'GROUPHEADER'

RETURN

*..............................................................................
PROCEDURE _EndGroupHeader()
*..............................................................................

RETURN

*..............................................................................
PROCEDURE _BeginGroupFooter()
*..............................................................................

   _HMG_RPTDATA[ 161 ] := 'GROUPFOOTER'

RETURN

*..............................................................................
PROCEDURE _EndGroupFooter()
*..............................................................................

RETURN

*..............................................................................
FUNCTION _dbSum( cField )
*..............................................................................
   LOCAL nVar

   IF Type ( cField ) == 'N'
      SUM &( cField ) TO nVar
      RETURN nVar
   ENDIF

RETURN 0

*..............................................................................
PROCEDURE _BeginData()
*..............................................................................

RETURN

*..............................................................................
PROCEDURE _EndData()
*..............................................................................

RETURN
