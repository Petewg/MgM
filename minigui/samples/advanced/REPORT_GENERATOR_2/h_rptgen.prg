/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://harbour-project.org

	"Harbour Project"
	Copyright 1999-2009, http://harbour-project.org/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_rptgen.ch"
#include "winprint.ch"

#include "Fileio.ch"

Memvar Drv
* Main ************************************************************************

Procedure _DefineReport ( cName )

   _HMG_RPTDATA [ 118 ] := 0
   _HMG_RPTDATA [ 119 ] := 0

   _HMG_RPTDATA [ 120 ] := 0

   _HMG_RPTDATA [ 121 ] := {}
   _HMG_RPTDATA [ 122 ] := {}

   _HMG_RPTDATA [ 123 ] := 0
   _HMG_RPTDATA [ 124 ] := 0

   _HMG_RPTDATA [ 155 ] := 0
   _HMG_RPTDATA [ 156 ] := 0

   _HMG_RPTDATA [ 157 ] := {}
   _HMG_RPTDATA [ 158 ] := {}
   _HMG_RPTDATA [ 159 ] := {}
   _HMG_RPTDATA [ 160 ] := {}
   _HMG_RPTDATA [ 126 ] := {}
   _HMG_RPTDATA [ 127 ] := 0
   _HMG_RPTDATA [ 161 ] := 'MAIN'

   _HMG_RPTDATA [ 164 ] := Nil
   _HMG_RPTDATA [ 165 ] := Nil

   _HMG_RPTDATA [ 166 ] := Nil
   _HMG_RPTDATA [ 167 ] := {}


   If cName <> '_TEMPLATE_'

      _HMG_RPTDATA [162] := cName

   Else

      cName := _HMG_RPTDATA [162]

   EndIf

   Public &cName := {}

Return

Procedure _EndReport 
Local cReportName
Local aMiscdata

   aMiscData := {}

   aadd ( aMiscData , _HMG_RPTDATA [ 120 ] ) // nGroupCount
   aadd ( aMiscData , _HMG_RPTDATA [ 152 ] ) // nHeadeHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 153 ] ) // nDetailHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 154 ] ) // nFooterHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 127 ] ) // nSummaryHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 124 ] ) // nGroupHeaderHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 123 ] ) // nGroupFooterHeight
   aadd ( aMiscData , _HMG_RPTDATA [ 125 ] ) // xGroupExpression
   aadd ( aMiscData , _HMG_RPTDATA [ 164 ] ) // xSkipProcedure
   aadd ( aMiscData , _HMG_RPTDATA [ 165 ] ) // xEOF

   cReportName := _HMG_RPTDATA [162]

   &cReportName := { _HMG_RPTDATA [159] , _HMG_RPTDATA [160] , _HMG_RPTDATA [158] , _HMG_RPTDATA [157] , _HMG_RPTDATA [ 126 ] , _HMG_RPTDATA [ 121 ] , _HMG_RPTDATA [ 122 ] , aMiscData }

Return

* Layout **********************************************************************

Procedure _BeginLayout

   _HMG_RPTDATA [161] := 'LAYOUT'

Return

Procedure _EndLayout

   aadd ( _HMG_RPTDATA [159] , _HMG_RPTDATA [ 155 ] )
   aadd ( _HMG_RPTDATA [159] , _HMG_RPTDATA [ 156 ] )
   aadd ( _HMG_RPTDATA [159] , _HMG_RPTDATA [ 118 ] )
   aadd ( _HMG_RPTDATA [159] , _HMG_RPTDATA [ 119 ] )

Return

* Header **********************************************************************

Procedure _BeginHeader

   _HMG_RPTDATA [161] := 'HEADER'

   _HMG_RPTDATA [160] := {}

Return

Procedure _EndHeader


Return


* Detail **********************************************************************

Procedure _BeginDetail

   _HMG_RPTDATA [161] := 'DETAIL'

   _HMG_RPTDATA [158] := {}

Return

Procedure _EndDetail


Return

* Footer **********************************************************************

Procedure _BeginFooter

   _HMG_RPTDATA [161] := 'FOOTER'

   _HMG_RPTDATA [157] := {}

Return

Procedure _EndFooter


Return

* Summary **********************************************************************

Procedure _BeginSummary

   _HMG_RPTDATA [161] := 'SUMMARY'

Return

Procedure _EndSummary


Return


* Text **********************************************************************

Procedure _BeginText

   _HMG_RPTDATA[116] := ''         // Text
   _HMG_ActiveControlRow := 0         // Row
   _HMG_ActiveControlCol := 0         // Col
   _HMG_ActiveControlWidth := 0                  // Width
   _HMG_ActiveControlHeight := 0         // Height
   _HMG_ActiveControlFont := 'Arial'      // FontName
   _HMG_ActiveControlSize := 9         // FontSize
   _HMG_ActiveControlFontBold := .F.      // FontBold
   _HMG_ActiveControlFontItalic := .F.      // FontItalic
   _HMG_ActiveControlFontUnderLine := .F.      // FontUnderLine
   _HMG_ActiveControlFontStrikeOut := .F.      // FontStrikeout
   _HMG_ActiveControlFontColor := { 0 , 0 , 0 }   // FontColor
   _HMG_ActiveControlRightAlign := .F.      // Alignment
   _HMG_ActiveControlCenterAlign := .F.      // Alignment

Return

Procedure _EndText

Local aText

   aText := {              ;
      'TEXT'            , ;
      _HMG_RPTDATA[116]      , ;
      _HMG_ActiveControlRow      , ;
      _HMG_ActiveControlCol      , ;
      _HMG_ActiveControlWidth      , ;
      _HMG_ActiveControlHeight   , ;
      _HMG_ActiveControlFont      , ;
      _HMG_ActiveControlSize      , ;
      _HMG_ActiveControlFontBold   , ;
      _HMG_ActiveControlFontItalic   , ;
      _HMG_ActiveControlFontUnderLine   , ;
      _HMG_ActiveControlFontStrikeOut   , ;
      _HMG_ActiveControlFontColor   , ;
      _HMG_ActiveControlRightAlign   , ;
      _HMG_ActiveControlCenterAlign     ;
      }

   If   _HMG_RPTDATA [161] == 'HEADER'

           aadd (    _HMG_RPTDATA [160] , aText )

   ElseIf   _HMG_RPTDATA [161] == 'DETAIL'

           aadd ( _HMG_RPTDATA [158] , aText )

   ElseIf   _HMG_RPTDATA [161] == 'FOOTER'

           aadd ( _HMG_RPTDATA [157] , aText )

   ElseIf   _HMG_RPTDATA [161] == 'SUMMARY'

           aadd ( _HMG_RPTDATA [126] , aText )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPHEADER'

           aadd ( _HMG_RPTDATA [ 121 ] , aText )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPFOOTER'

           aadd ( _HMG_RPTDATA [ 122 ] , aText )

   EndIf

Return

* Band Height *****************************************************************

Procedure _BandHeight ( nValue )

   IF   _HMG_RPTDATA [ 161 ] == 'HEADER'

      _HMG_RPTDATA [ 152 ] := nValue

   ELSEIF   _HMG_RPTDATA [ 161 ] == 'DETAIL'

      _HMG_RPTDATA [ 153 ] := nValue

   ELSEIF   _HMG_RPTDATA [ 161 ] == 'FOOTER'

      _HMG_RPTDATA [ 154 ] := nValue

   ELSEIF   _HMG_RPTDATA [ 161 ] == 'SUMMARY'

      _HMG_RPTDATA [ 127 ] := nValue

   ELSEIF   _HMG_RPTDATA [ 161 ] == 'GROUPHEADER'

      _HMG_RPTDATA [ 124 ] := nValue

   ELSEIF   _HMG_RPTDATA [ 161 ] == 'GROUPFOOTER'

      _HMG_RPTDATA [ 123 ] := nValue

   ENDIF

Return

* Execute *********************************************************************

Procedure ExecuteReport ( cReportName , lPreview , lSelect , cOutputFileName )

Local aLayout 
Local aHeader 
Local aDetail 
Local aFooter 
Local aSummary
Local aTemp
Local cPrinter
//Local nDetailBandsPerPage 
Local nPaperWidth 
Local nPaperHeight 
Local nOrientation 
Local nPaperSize 
Local nHeadeHeight 
Local nDetailHeight
Local nFooterHeight
Local nBandSpace
Local nCurrentOffset
Local nPreviousRecNo
Local nSummaryHeight
Local aGroupHeader
Local aGroupFooter
Local nGroupHeaderHeight
Local nGroupFooterHeight
Local xGroupExpression
Local nGroupCount
Local xPreviousGroupExpression
Local lGroupStarted
Local lSuccess
Local aMiscData
Local xTemp
Local aPaper [18] [2]
Local cPdfPaperSize := ''
Local cPdfOrientation := ''
Local nOutfile
Local xSkipProcedure
Local xEOF
Local lTempEof

   IF _HMG_RPTDATA [ 120 ] > 1
      MsgMiniGUIError('Only One Group Level Allowed')
   ENDIF

   _HMG_RPTDATA [ 149 ] := ''
   _HMG_RPTDATA [ 150 ] := .F.
   _HMG_RPTDATA [ 163 ] := .F.
   _HMG_RPTDATA [ 166 ] := .F.

   If ValType ( cOutputFileName ) == 'C'

      If AllTrim ( Upper ( Right ( cOutputFileName , 4 ) ) ) == '.PDF'

         _HMG_RPTDATA [ 150 ] := .T.

      ElseIf AllTrim ( Upper ( Right ( cOutputFileName , 5 ) ) ) == '.HTML'

         _HMG_RPTDATA [ 163 ] := .T.

      ElseIf AllTrim ( Upper ( Right ( cOutputFileName , 4 ) ) ) == '.RTF'

         _HMG_RPTDATA [ 166 ] := .T.

      EndIf

   EndIf

   IF _HMG_RPTDATA [ 163 ] == .T.

      _HMG_RPTDATA [ 149 ] += '<html>' + chr(13) + chr(10)

      _HMG_RPTDATA [ 149 ] += '<style>' + chr(13) + chr(10)
      _HMG_RPTDATA [ 149 ] += 'div {position:absolute}' + chr(13) + chr(10)
      _HMG_RPTDATA [ 149 ] += '.line { }' + chr(13) + chr(10)
      _HMG_RPTDATA [ 149 ] += '</style>' + chr(13) + chr(10)

      _HMG_RPTDATA [ 149 ] += '<body>' + chr(13) + chr(10)

   ENDIF

   IF _HMG_RPTDATA [ 150 ] == .T.
      PdfInit()
      pdfOpen( cOutputFileName , 200 , .t. )
   ENDIF

   If ValType ( xSkipProcedure ) = 'U'

      * If not workarea open, cancel report execution

      If Select() == 0
         Return
      EndIf

      nPreviousRecNo := RecNo()

   EndIf

   ***********************************************************************
   * Determine Print Parameters
   ***********************************************************************

   aTemp := __MVGET ( cReportName )

   aLayout      := aTemp [1]
   aHeader      := aTemp [2]
   aDetail      := aTemp [3]
   aFooter      := aTemp [4]
   aSummary   := aTemp [5]
   aGroupHeader   := aTemp [6]
   aGroupFooter   := aTemp [7]
   aMiscData   := aTemp [8]

   nGroupCount      := aMiscData [1]
   nHeadeHeight      := aMiscData [2]
   nDetailHeight      := aMiscData [3]
   nFooterHeight      := aMiscData [4]
   nSummaryHeight      := aMiscData [5]
   nGroupHeaderHeight   := aMiscData [6]
   nGroupFooterHeight   := aMiscData [7]
   xTemp         := aMiscData [8]
   xSkipProcedure      := aMiscData [9]
   xEOF         := aMiscData [10]

   nOrientation      := aLayout [1]
   nPaperSize      := aLayout [2]
   nPaperWidth      := aLayout [3]
   nPaperHeight      := aLayout [4]

   If ValType ( lPreview ) <> 'L'
      lPreview := .F.
   EndIf

   If ValType ( lSelect ) <> 'L'
      lSelect := .F.
   EndIf

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F.

      If lSelect == .T.
         cPrinter := GetPrinter()
      Else
         cPrinter := GetDefaultPrinter()
      EndIf

      If Empty (cPrinter)
         Return
      EndIf

   ENDIF

   ***********************************************************************
   * Select Printer
   ***********************************************************************

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F. .AND. _HMG_RPTDATA [ 166 ] == .F.
   init printsys
   SET UNITS MM

      IF lPreview == .T.

         If nPaperSize == PRINTER_PAPER_USER

            if drv = "H"
               SELECT PRINTER
               SET PAGE ORIENTATION nOrientation

            Else
             SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;
               PAPERWIDTH   nPaperWidth   ;
               PAPERLENGTH   nPaperHeight   ;
               PREVIEW
             Endif
         Else

            if drv = "H"
               SELECT PRINTER cPrinter PREVIEW
            Else

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;
               PREVIEW
               Endif
         EndIf

      ELSE

         If nPaperSize == PRINTER_PAPER_USER
            if drv = "H"

            Else

               SELECT PRINTER cPrinter         ;
                      TO lSuccess         ;
                      ORIENTATION   nOrientation   ;
                      PAPERSIZE   nPaperSize   ;
                      PAPERWIDTH   nPaperWidth   ;
                      PAPERLENGTH   nPaperHeight
            Endif
         Else
            if drv = "H"

            Else

            SELECT PRINTER cPrinter         ;
               TO lSuccess         ;
               ORIENTATION   nOrientation   ;
               PAPERSIZE   nPaperSize   ;

            Endif
            
         EndIf
      ENDIF
      if drv = "H"
         define font "f0" name "courier new" size 12
         define pen "P0" style PS_SOLID width 10
         SET PAGE ORIENTATION nOrientation PAPERSIZE nPapersize FONT "f0"
      Endif


   ENDIF

   ***********************************************************************
   * Determine Paper Dimensions in mm.
   ***********************************************************************

   If npaperSize >=1 .and. nPaperSize <= 18

      aPaper [ PRINTER_PAPER_LETTER             ] := { 215.9   , 279.4 }
      aPaper [ PRINTER_PAPER_LETTERSMALL          ] := { 215.9   , 279.4 }
      aPaper [ PRINTER_PAPER_TABLOID            ] := { 279.4   , 431.8 }
      aPaper [ PRINTER_PAPER_LEDGER            ] := { 431.8   , 279.4 }
      aPaper [ PRINTER_PAPER_LEGAL            ] := { 215.9   , 355.6 }
      aPaper [ PRINTER_PAPER_STATEMENT         ] := { 139.7   , 215.9 }
      aPaper [ PRINTER_PAPER_EXECUTIVE         ] := { 184.15   , 266.7 }
      aPaper [ PRINTER_PAPER_A3            ] := { 297   , 420   }
      aPaper [ PRINTER_PAPER_A4            ] := { 210   , 297   }
      aPaper [ PRINTER_PAPER_A4SMALL            ] := { 210   , 297   }
      aPaper [ PRINTER_PAPER_A5            ] := { 148   , 210   }
      aPaper [ PRINTER_PAPER_B4            ] := { 250   , 354   }
      aPaper [ PRINTER_PAPER_B5            ] := { 182   , 257   }
      aPaper [ PRINTER_PAPER_FOLIO            ] := { 215.9   , 330.2   }
      aPaper [ PRINTER_PAPER_QUARTO            ] := { 215   , 275   }
      aPaper [ PRINTER_PAPER_10X14            ] := { 254   , 355.6   }
      aPaper [ PRINTER_PAPER_11X17            ] := { 279.4   , 431.8   }
      aPaper [ PRINTER_PAPER_NOTE            ] := { 215.9   , 279.4 }

      If    nOrientation == PRINTER_ORIENT_PORTRAIT

//         nPaperWidth   := aPaper [ nPaperSize ] [ 1 ]
         npaperHeight   := aPaper [ nPaperSize ] [ 2 ]

      ElseIf   nOrientation == PRINTER_ORIENT_LANDSCAPE

//         nPaperWidth   := aPaper [ nPaperSize ] [ 2 ]
         npaperHeight   := aPaper [ nPaperSize ] [ 1 ]

      Else

         MsgMiniGUIError('Report: Orientation Not Supported')

      EndIf

   Else

      MsgMiniGUIError('Report: Paper Size Not Supported')

   EndIf


   IF _HMG_RPTDATA [ 150 ] == .T.

      * PDF Paper Size

      If   nPaperSize == PRINTER_PAPER_LETTER

              cPdfPaperSize := "LETTER"

      ElseIf   nPaperSize == PRINTER_PAPER_LEGAL

              cPdfPaperSize := "LEGAL"

      ElseIf nPaperSize == PRINTER_PAPER_A4

         cPdfPaperSize := "A4"

      ElseIf nPaperSize == PRINTER_PAPER_TABLOID

         cPdfPaperSize := "LEDGER"

      ElseIf nPaperSize == PRINTER_PAPER_EXECUTIVE

         cPdfPaperSize := "EXECUTIVE"

      ElseIf nPaperSize == PRINTER_PAPER_A3

         cPdfPaperSize := "A3"

      ElseIf nPaperSize == PRINTER_PAPER_ENV_10

         cPdfPaperSize := "COM10"

      ElseIf nPaperSize == PRINTER_PAPER_B4

         cPdfPaperSize := "JIS B4"

      ElseIf nPaperSize == PRINTER_PAPER_B5

         cPdfPaperSize := "B5"

      ElseIf nPaperSize == PRINTER_PAPER_P32K

         cPdfPaperSize := "JPOST"

      ElseIf nPaperSize == PRINTER_PAPER_ENV_C5

         cPdfPaperSize := "C5"

      ElseIf nPaperSize == PRINTER_PAPER_ENV_DL

         cPdfPaperSize := "DL"

      ElseIf nPaperSize == PRINTER_PAPER_ENV_B5

         cPdfPaperSize := "B5"

      ElseIf nPaperSize == PRINTER_PAPER_ENV_MONARCH

         cPdfPaperSize := "MONARCH"

      Else

         MsgMiniGUIError("Report: PDF Paper Size Not Supported")

      EndIf

      * PDF Orientation

      If    nOrientation == PRINTER_ORIENT_PORTRAIT

         cPdfOrientation := 'P'

      ElseIf   nOrientation == PRINTER_ORIENT_LANDSCAPE

         cPdfOrientation := 'L'

      Else

         MsgMiniGUIError('Report: Orientation Not Supported')

      EndIf

   ENDIF

   ***********************************************************************
   * Calculate Bands
   ***********************************************************************

   nBandSpace      := nPaperHeight - nHeadeHeight - nFooterHeight

//   nDetailBandsPerPage   := Int ( nBandSpace / nDetailHeight )

   ***********************************************************************
   * Print Document
   ***********************************************************************

   If nGroupCount > 0

      xGroupExpression := &(xTemp)

   EndIf

   _HMG_RPTDATA [ 117 ] := 1

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F. .AND. _HMG_RPTDATA [ 166 ] == .F.

      if drv = "H"
         START DOC
      Else
         START PRINTDOC
      Endif

   ENDIF

   If ValType ( xSkipProcedure ) == 'U'
      Go Top
   EndIf

   xPreviousGroupExpression := ''
   lGroupStarted := .f.

   If ValType ( xSkipProcedure ) == 'U'
      lTempEof := Eof()
   Else
      lTempEof := Eval(xEof)
   EndIf

   Do While .Not. lTempEof

      IF _HMG_RPTDATA [ 163 ] == .F.

         IF _HMG_RPTDATA [ 150 ] == .T.

            pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

         ELSEif _HMG_RPTDATA [ 166 ] == .F.

            if drv = "H"
               START PAGE
            Else
               START PRINTPAGE
            Endif

         ENDIF

         nCurrentOffset := 0

         _ProcessBand ( aHeader , 0 )

         nCurrentOffset := nHeadeHeight

         do while .t.

            If nGroupCount > 0

               If ( valtype (xPreviousGroupExpression) != valtype (xGroupExpression) ) .or. ( xPreviousGroupExpression <> xGroupExpression )

                  If lGroupStarted

                     _ProcessBand ( aGroupFooter , nCurrentOffset )
                     nCurrentOffset += nGroupFooterHeight

                  EndIf

                  _ProcessBand ( aGroupHeader , nCurrentOffset )
                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               EndIf

            EndIf

            _ProcessBand ( aDetail , nCurrentOffset )

            nCurrentOffset += nDetailHeight

            If ValType ( xSkipProcedure ) == 'U'
               Skip
               lTempEof := Eof()
            Else
               Eval(xSkipProcedure)
               lTempEof := Eval(xEof)
            EndIf

            If lTempEof

               * If group footer defined, print it.

               If nGroupFooterHeight > 0

                  * If group footer don't fit in the current page, print page footer,
                  * start a new page and print header first

                  If nCurrentOffset + nGroupFooterHeight > nPaperHeight - nFooterHeight

                     nCurrentOffset := nPaperHeight - nFooterHeight
                     _ProcessBand ( aFooter , nCurrentOffset )

                     IF _HMG_RPTDATA [ 150 ] == .F.

                        if drv = "H"
                           END PAGE
                           START PAGE
                        Else
                        END PRINTPAGE
                        START PRINTPAGE
                        Endif
                     ELSE

                        pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

                     ENDIF

                     _HMG_RPTDATA [ 117 ]++

                     nCurrentOffset := 0
                     _ProcessBand ( aHeader , 0 )
                     nCurrentOffset := nHeadeHeight

                  EndIf

                  _ProcessBand ( aGroupFooter , nCurrentOffset )
                  nCurrentOffset += nGroupFooterHeight

               EndIf

               * If Summary defined, print it.

               If Len ( aSummary ) > 0

                  * If summary don't fit in the current page, print footer,
                  * start a new page and print header first

                  If nCurrentOffset + nSummaryHeight > nPaperHeight - nFooterHeight

                     nCurrentOffset := nPaperHeight - nFooterHeight
                     _ProcessBand ( aFooter , nCurrentOffset )

                     IF _HMG_RPTDATA [ 150 ] == .F.

                        if drv = "H"
                           END PAGE
                           START PAGE
                        Else
                        END PRINTPAGE
                        START PRINTPAGE
                        Endif

                     ELSE

                        pdfNewPage( cPdfPaperSize , cPdfOrientation, 6 )

                     ENDIF

                     _HMG_RPTDATA [ 117 ]++

                     nCurrentOffset := 0
                     _ProcessBand ( aHeader , 0 )
                     nCurrentOffset := nHeadeHeight

                  EndIf

                  _ProcessBand ( aSummary , nCurrentOffset )

                  Exit

               EndIf

               Exit

            EndIf

            If nGroupCount > 0

               xGroupExpression := &(xTemp)

            EndIf

            If nCurrentOffset + nDetailHeight > nPaperHeight - nFooterHeight

               Exit

            EndIf

         EndDo

         nCurrentOffset := nPaperHeight - nFooterHeight

         _ProcessBand ( aFooter , nCurrentOffset )

         IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 166 ] == .F.

            if drv = "H"
               END PAGE
            Else
               END PRINTPAGE
            Endif

         ENDIF

         _HMG_RPTDATA [ 117 ]++

      ELSE

         nCurrentOffset := 0

         _ProcessBand ( aHeader , 0 )

         nCurrentOffset := nHeadeHeight

         do while .t.

            If nGroupCount > 0

               If xPreviousGroupExpression <> xGroupExpression

                  If lGroupStarted

                     _ProcessBand ( aGroupFooter , nCurrentOffset )
                     nCurrentOffset += nGroupFooterHeight

                  EndIf

                  _ProcessBand ( aGroupHeader , nCurrentOffset )

                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               EndIf

            EndIf

            _ProcessBand ( aDetail , nCurrentOffset )

            nCurrentOffset += nDetailHeight

            If ValType ( xSkipProcedure ) == 'U'
               Skip
               lTempEof := Eof()
            Else
               Eval(xSkipProcedure)
               lTempEof := Eval(xEof)
            EndIf

            If lTempEof

               * If group footer defined, print it.

               If nGroupFooterHeight > 0

                  _ProcessBand ( aGroupFooter , nCurrentOffset )
                  nCurrentOffset += nGroupFooterHeight

               EndIf

               * If Summary defined, print it.

               If Len ( aSummary ) > 0
                  _ProcessBand ( aSummary , nCurrentOffset )
                  nCurrentOffset += nSummaryHeight
               EndIf

               Exit

            EndIf

            If nGroupCount > 0
               xGroupExpression := &(xTemp)
            EndIf

         EndDo

         _ProcessBand ( aFooter , nCurrentOffset )

      ENDIF

   EndDo

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F. .AND. _HMG_RPTDATA [ 166 ] == .F.

            if drv = "H"
               END DOC
               RELEASE PRINTSYS
            Else
               END PRINTDOC
            Endif

   ELSEIF _HMG_RPTDATA [ 150 ] == .T.

      pdfClose()

   ELSEIF _HMG_RPTDATA [ 163 ] == .T.

      _HMG_RPTDATA [ 149 ] += '</body>' + chr(13) + chr(10)
      _HMG_RPTDATA [ 149 ] += '</html>' + chr(13) + chr(10)

      nOutfile := FCREATE( cOutputFileName , FC_NORMAL)

      FWRITE( nOutfile , _HMG_RPTDATA [ 149 ] , Len(_HMG_RPTDATA [ 149 ]) )

      FCLOSE(nOutfile)

   ENDIF

   If ValType ( xSkipProcedure ) == 'U'
      Go nPreviousRecNo
   EndIf

Return

*.............................................................................*
Procedure _ProcessBand ( aBand  , nOffset )
*.............................................................................*
Local i

   For i := 1 To Len ( aBand )

      _PrintObject ( aBand [i] , nOffset )

   Next i

Return

*.............................................................................*
Procedure _PrintObject ( aObject , nOffset )
*.............................................................................*


   If   aObject [1] == 'TEXT'

      _PrintText( aObject , nOffset )

   ElseIf aObject [1] == 'IMAGE'

      _PrintImage( aObject , nOffset )

   ElseIf aObject [1] == 'LINE'

      _PrintLine( aObject , nOffset )

   ElseIf aObject [1] == 'RECTANGLE'

      _PrintRectangle( aObject , nOffset )

   EndIf

Return

*-----------------------------------------------------------------------------*
Procedure _PrintText( aObject , nOffset )
*-----------------------------------------------------------------------------*

Local cValue      := aObject [ 2]
Local nRow      := aObject [ 3]
Local nCol      := aObject [ 4]
Local nWidth      := aObject [ 5]
Local nHeight      := aObject [ 6]
Local cFontname      := aObject [ 7]
Local nFontSize      := aObject [ 8]
Local lFontBold      := aObject [ 9]
Local lFontItalic   := aObject [10]
Local lFontUnderLine   := aObject [11]
Local lFOntStrikeout   := aObject [12]
Local aFontColor   := aObject [13]
Local lAlignment_1    := aObject [14]
Local lAlignment_2    := aObject [15]
Local cAlignment   := ''
Local nFontStyle   := 0
Local nTextRowFix   := 5
Local cHtmlAlignment
Local HBPcOffset     := 0

   cValue := &cValue

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F.

      If   lAlignment_1 == .F. .and.  lAlignment_2 == .T.

         cAlignment   := 'CENTER'
         hbprn:settextalign(TA_CENTER)
         
      ElseIf   lAlignment_1 == .T. .and.  lAlignment_2 == .F.

         cAlignment   := 'RIGHT'
         hbprn:settextalign(TA_RIGHT)

      ElseIf   lAlignment_1 == .F. .and.  lAlignment_2 == .F.

         cAlignment   := ''
         hbprn:settextalign(TA_LEFT)
         
      EndIf

      if drv = "H"

         hbprn:modifyfont("F0", cFontName ,nFontSize, ,0,lFontBold,!lFontBold , ;
               lFontitalic,!lFontitalic ,lFontUnderline ,!lFontUnderline,;
               lFontStrikeout,!lFontStrikeout)

         hbPrn:SetTextColor( { aFontColor[1] , aFontColor[2] , aFontColor[3] } )

         IF ! ISCHARACTER( cValue )
            cValue := alltrim( HB_ValToStr( cValue ) )
         ENDIF
         if cAlignment  = 'RIGHT'
            HBPcOffset := nWidth
         Elseif cAlignment  = 'CENTER'
            HBPcOffset := nWidth / 2
         Endif

         @nRow + nOffset + 3 , nCol + HBPcOffset SAY cValue FONT "F0" TO PRINT

      Else

      _HMG_PRINTER_H_MULTILINE_PRINT ( _HMG_PRINTER_HDC , nRow  + nOffset , nCol , nRow + nHeight  + nOffset , nCol + nWidth , cFontName , nFontSize , aFontColor[1] , aFontColor[2] , aFontColor[3] , cValue , lFontBold , lFontItalic , lFontUnderline , lFontStrikeout , .T. , .T. , .T. , cAlignment )

      Endif

   ELSEIF _HMG_RPTDATA [ 163 ] == .T.

      if   ValType (cValue) == "N"

         cValue := AllTrim(Str(cValue))

      Elseif   ValType (cValue) == "D"

         cValue := dtoc (cValue)

      Elseif   ValType (cValue) == "L"

         cValue := if ( cValue == .T. , _HMG_RPTDATA [ 371 ] [24] , _HMG_RPTDATA [ 371 ] [25] )

      EndIf

      If   lAlignment_1 == .F. .and.  lAlignment_2 == .T.

         cHtmlAlignment   := 'center'

      ElseIf   lAlignment_1 == .T. .and.  lAlignment_2 == .F.

         cHtmlAlignment   := 'right'

      ElseIf   lAlignment_1 == .F. .and.  lAlignment_2 == .F.

         cHtmlAlignment   := 'left'

      EndIf

      _HMG_RPTDATA [ 149 ] += '<div style=position:absolute;left:' + alltrim(str(nCol)) +  'mm;top:' +  alltrim(str(nRow+nOffset)) + 'mm;width:' +  alltrim(str(nWidth)) + 'mm;font-size:' + alltrim(str(nFontSize)) + 'pt;font-family:"' +  cFontname + '";text-align:' + cHtmlAlignment + ';font-weight:' + if(lFontBold,'bold','normal') + ';font-style:' + if(lFontItalic,'italic','normal') + ';text-decoration:' + if(lFontUnderLine,'underline','none') + ';color:rgb(' + alltrim(str(aFontColor[1])) + ',' + alltrim(str(aFontColor[2])) + ',' +  alltrim(str(aFontColor[3])) + ');>' + cValue + '</div>' + chr(13) + chr(10)

   ELSEIF _HMG_RPTDATA [ 150 ] == .T.

      if   ValType (cValue) == "N"

         cValue := AllTrim(Str(cValue))

      Elseif   ValType (cValue) == "D"

         cValue := dtoc (cValue)

      Elseif   ValType (cValue) == "L"

         cValue := if ( cValue == .T. , _HMG_RPTDATA [ 371 ] [24] , _HMG_RPTDATA [ 371 ] [25] )

      EndIf

      If   lFontBold == .f. .and. lFontItalic == .f.

         nFontStyle := 0

      ElseIf   lFontBold == .t. .and. lFontItalic == .f.

         nFontStyle := 1

      ElseIf   lFontBold == .f. .and. lFontItalic == .t.

         nFontStyle := 2

      ElseIf   lFontBold == .t. .and. lFontItalic == .t.

         nFontStyle := 3

      EndIf

      pdfSetFont( cFontname , nFontStyle , nFontSize )

      If   lAlignment_1 == .F. .and.  lAlignment_2 == .T. // Center

         If lFontUnderLine

            pdfAtSay ( cValue + chr(254) , nRow + nOffset + nTextRowFix , nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2  , 'M' )

         Else

            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2  , 'M' )

         EndIf

      ElseIf   lAlignment_1 == .T. .and.  lAlignment_2 == .F. // Right

         If lFontUnderLine

            pdfAtSay ( cValue + chr(254) , nRow + nOffset + nTextRowFix , nCol + nWidth - pdfTextWidth( cValue ) * 25.4 , 'M' )

         Else

            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol + nWidth - pdfTextWidth( cValue ) * 25.4 , 'M' )

         EndIf

      ElseIf   lAlignment_1 == .F. .and.  lAlignment_2 == .F. // Left

         If lFontUnderLine

            pdfAtSay ( cValue + chr(254) , nRow + nOffset + nTextRowFix , nCol , 'M' )

         Else

            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue , nRow + nOffset + nTextRowFix , nCol , 'M' )

         EndIf

      EndIf

   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure _PrintImage( aObject , nOffset )
*-----------------------------------------------------------------------------*
Local cValue      := aObject [ 2]
Local nRow      := aObject [ 3]
Local nCol      := aObject [ 4]
Local nWidth      := aObject [ 5]
Local nHeight      := aObject [ 6]
Local lStretch      := aObject [ 7]

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F.

      if drv = "H"
         hbprn:picture(nRow + nOffset,nCol, nHeight , nWidth ,cValue, , )
      Else
         _HMG_PRINTER_H_IMAGE ( _HMG_PRINTER_HDC , cValue , nRow + nOffset , nCol , nHeight , nWidth , .T. )
      Endif

   ELSEIF _HMG_RPTDATA [ 150 ] == .T.

      IF UPPER ( RIGHT( cValue , 4 ) ) == '.JPG'

         pdfImage( cValue , nRow + nOffset , nCol , "M" , nHeight , nWidth )

      ELSE

         MsgMiniGuiError("Report: Only JPG images allowed" )

      ENDIF

   ELSEIF _HMG_RPTDATA [ 163 ] == .T.

      _HMG_RPTDATA [ 149 ] += '<div style=position:absolute;left:' + alltrim(str(nCol)) + 'mm;top:' + alltrim(str(nRow+nOffset))  + 'mm;> <img src="' + cValue + '" ' + 'width=' + alltrim(str(nWidth*3.85)) + 'mm height=' + alltrim(str(nHeight*3.85)) + 'mm/> </div>' + chr(13) + chr(10)

   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure _PrintLine( aObject , nOffset )
*-----------------------------------------------------------------------------*
Local nFromRow      := aObject [ 2]
Local nFromCol      := aObject [ 3]
Local nToRow      := aObject [ 4]
Local nToCol      := aObject [ 5]
Local nPenWidth      := aObject [ 6]
Local aPenColor      := aObject [ 7]

   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F.
      if drv = "H"
         Hbprn:modifypen("P0", , nPenWidth*25.4 , { aPenColor[1] , aPenColor[2] , aPenColor[3] } )
         hbprn:line(nFromRow + nOffset, nFromCol , nToRow  + nOffset , nToCol ,"P0" )
      Else
      _HMG_PRINTER_H_LINE ( _HMG_PRINTER_HDC , nFromRow + nOffset , nFromCol , nToRow  + nOffset , nToCol , nPenWidth , aPenColor[1] , aPenColor[2] , aPenColor[3]  , .T. , .T. )
      Endif

   ELSEIF _HMG_RPTDATA [ 150 ] == .T.

      If nFromRow <> nToRow .and. nFromCol <> nToCol
         MsgMiniGUIError('Report: Only horizontal and vertical lines are supported with PDF output')
      EndIf

      pdfBox( nFromRow + nOffset , nFromCol, nToRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_RPTDATA [ 163 ] == .T.

      _HMG_RPTDATA [ 149 ] += '<div style="left:' + alltrim(str(nFromCol)) + 'mm;top:' +  alltrim(str(nFromRow+nOffset)) +  'mm;width:' +  alltrim(str(nToCol-nFromCol)) +  'mm;height:0mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + alltrim(str(aPenColor[1])) + ',' + alltrim(str(aPenColor[2])) + ',' +  alltrim(str(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + alltrim(str(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + chr(13) + chr(10)

   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure _PrintRectangle( aObject , nOffset )
*-----------------------------------------------------------------------------*
Local nFromRow      := aObject [ 2]
Local nFromCol      := aObject [ 3]
Local nToRow      := aObject [ 4]
Local nToCol      := aObject [ 5]
Local nPenWidth      := aObject [ 6]
Local aPenColor      := aObject [ 7]


   IF _HMG_RPTDATA [ 150 ] == .F. .AND. _HMG_RPTDATA [ 163 ] == .F.

      if drv = "H"
         Hbprn:modifypen("P0", , nPenWidth*25.4 , { aPenColor[1] , aPenColor[2] , aPenColor[3] } )
         hbprn:rectangle( nFromRow + nOffset , nFromCol , nToRow  + nOffset ,nToCol ,"p0" , )
      Else
      _HMG_PRINTER_H_RECTANGLE ( _HMG_PRINTER_HDC , nFromRow + nOffset , nFromCol , nToRow  + nOffset , nToCol , nPenWidth , aPenColor[1] , aPenColor[2] , aPenColor[3] , .T. , .T. )
      Endif
      
   ELSEIF _HMG_RPTDATA [ 150 ] == .T.

      pdfBox( nFromRow + nOffset , nFromCol, nFromRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nToRow + nOffset , nFromCol, nToRow + nOffset + nPenWidth , nToCol , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset , nFromCol, nToRow + nOffset , nFromCol + nPenWidth , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset , nToCol, nToRow + nOffset , nToCol + nPenWidth , 0 , 1 , "M" , CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_RPTDATA [ 163 ] == .T.

      _HMG_RPTDATA [ 149 ] += '<div style="left:' + alltrim(str(nFromCol)) + 'mm;top:' +  alltrim(str(nFromRow+nOffset)) +  'mm;width:' +  alltrim(str(nToCol-nFromCol)) +  'mm;height:' + alltrim(str(nToRow-nFromRow)) + 'mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + alltrim(str(aPenColor[1])) + ',' + alltrim(str(aPenColor[2])) + ',' +  alltrim(str(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + alltrim(str(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + chr(13) + chr(10)

   ENDIF

Return

* Line **********************************************************************

Procedure _BeginLine

   _HMG_RPTDATA [ 110 ] := 0      // FromRow
   _HMG_RPTDATA [ 111 ] := 0      // FromCol
   _HMG_RPTDATA [ 112 ] := 0      // ToRow
   _HMG_RPTDATA [ 113 ] := 0      // ToCol
   _HMG_RPTDATA [ 114 ] := 1      // PenWidth
   _HMG_RPTDATA [ 115 ] := { 0 , 0 , 0 }   // PenColor

Return

Procedure _EndLine

Local aLine

   aLine := {           ;
      'LINE'         , ;
      _HMG_RPTDATA [ 110 ]   , ;
      _HMG_RPTDATA [ 111 ]   , ;
      _HMG_RPTDATA [ 112 ]   , ;
      _HMG_RPTDATA [ 113 ]   , ;
      _HMG_RPTDATA [ 114 ]   , ;
      _HMG_RPTDATA [ 115 ]     ;
      }

   If   _HMG_RPTDATA [161] == 'HEADER'

           aadd (    _HMG_RPTDATA [160] , aLine )

   ElseIf   _HMG_RPTDATA [161] == 'DETAIL'

           aadd ( _HMG_RPTDATA [158] , aLine )

   ElseIf   _HMG_RPTDATA [161] == 'FOOTER'

           aadd ( _HMG_RPTDATA [157] , aLine )

   ElseIf   _HMG_RPTDATA [161] == 'SUMMARY'

           aadd ( _HMG_RPTDATA [126] , aLine )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPHEADER'

           aadd ( _HMG_RPTDATA [ 121 ] , aLine )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPFOOTER'

           aadd ( _HMG_RPTDATA [ 122 ] , aLine )

   EndIf

Return

* Image **********************************************************************

Procedure _BeginImage

   _HMG_ActiveControlValue := ''         // Value
   _HMG_ActiveControlRow := 0         // Row
   _HMG_ActiveControlCol := 0         // Col
   _HMG_ActiveControlWidth := 0         // Width
   _HMG_ActiveControlHeight := 0         // Height
   _HMG_ActiveControlStretch := .F.      // Stretch

Return

Procedure _EndImage

Local aImage

   aImage := {              ;
      'IMAGE'            , ;
      _HMG_ActiveControlValue      , ;
      _HMG_ActiveControlRow      , ;
      _HMG_ActiveControlCol      , ;
      _HMG_ActiveControlWidth      , ;
      _HMG_ActiveControlHeight   , ;
      _HMG_ActiveControlStretch     ;
      }

   If   _HMG_RPTDATA [161] == 'HEADER'

           aadd (    _HMG_RPTDATA [160] , aImage )

   ElseIf   _HMG_RPTDATA [161] == 'DETAIL'

           aadd ( _HMG_RPTDATA [158] , aImage )

   ElseIf   _HMG_RPTDATA [161] == 'FOOTER'

           aadd ( _HMG_RPTDATA [157] , aImage )

   ElseIf   _HMG_RPTDATA [161] == 'SUMMARY'

           aadd ( _HMG_RPTDATA [126] , aImage )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPHEADER'

           aadd ( _HMG_RPTDATA [ 121 ] , aImage )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPFOOTER'

           aadd ( _HMG_RPTDATA [ 122 ] , aImage )

   EndIf

Return

* Rectangle **********************************************************************

Procedure _BeginRectangle

   _HMG_RPTDATA [ 110 ] := 0      // FromRow
   _HMG_RPTDATA [ 111 ] := 0      // FromCol
   _HMG_RPTDATA [ 112 ] := 0      // ToRow
   _HMG_RPTDATA [ 113 ] := 0      // ToCol
   _HMG_RPTDATA [ 114 ] := 1      // PenWidth
   _HMG_RPTDATA [ 115 ] := { 0 , 0 , 0 }   // PenColor

Return

Procedure _EndRectangle

Local aRectangle

   aRectangle := {           ;
      'RECTANGLE'      , ;
      _HMG_RPTDATA [ 110 ]   , ;
      _HMG_RPTDATA [ 111 ]   , ;
      _HMG_RPTDATA [ 112 ]   , ;
      _HMG_RPTDATA [ 113 ]   , ;
      _HMG_RPTDATA [ 114 ]   , ;
      _HMG_RPTDATA [ 115 ]     ;
      }

   If   _HMG_RPTDATA [161] == 'HEADER'

           aadd (    _HMG_RPTDATA [160] , aRectangle )

   ElseIf   _HMG_RPTDATA [161] == 'DETAIL'

           aadd ( _HMG_RPTDATA [158] , aRectangle )

   ElseIf   _HMG_RPTDATA [161] == 'FOOTER'

           aadd ( _HMG_RPTDATA [157] , aRectangle )

   ElseIf   _HMG_RPTDATA [161] == 'SUMMARY'

           aadd ( _HMG_RPTDATA [126] , aRectangle )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPHEADER'

           aadd ( _HMG_RPTDATA [ 121 ] , aRectangle )

   ElseIf   _HMG_RPTDATA [161] == 'GROUPFOOTER'

           aadd ( _HMG_RPTDATA [ 122 ] , aRectangle )

   EndIf

Return

*..............................................................................
Procedure _BeginGroup()
*..............................................................................

   _HMG_RPTDATA [161] := 'GROUP'

   _HMG_RPTDATA [ 120 ]++

Return

*..............................................................................
Procedure _EndGroup() 
*..............................................................................

Return

*..............................................................................
Procedure _BeginGroupHeader()
*..............................................................................

   _HMG_RPTDATA [161] := 'GROUPHEADER'

Return

*..............................................................................
Procedure _EndGroupHeader() 
*..............................................................................

Return

*..............................................................................
Procedure _BeginGroupFooter()
*..............................................................................

   _HMG_RPTDATA [161] := 'GROUPFOOTER'

Return

*..............................................................................
Procedure _EndGroupFooter() 
*..............................................................................

Return

*..............................................................................
Function _dbSum( cField ) 
*..............................................................................
Local nVar := 0

   if type ( cField ) == 'N'

      SUM &(cField) TO nVar

   EndIf

Return nVar

*..............................................................................
Procedure _BeginData()
*..............................................................................
Return

*..............................................................................
Procedure _EndData() 
*..............................................................................
Return
