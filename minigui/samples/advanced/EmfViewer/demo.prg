/*
   Demo for loading and make preview of metafile (EMF extension)
   Author: Pablo Cesar Arrascaeta
   Date: October 7th, 2014
   Version: 1.1
*/

#include <hmg.ch>
#include "miniprint.ch"

MEMVAR Printers

FUNCTION Main()

   LOCAL cDefaultPrinter := GetDefaultPrinter(), nInitPosition
   PRIVATE Printers

   Printers := ASort ( aPrinters() )
   IF Len( Printers ) == 0
      MsgStop( "No printer installed !" )
      RETURN NIL
   ENDIF
   nInitPosition := GetPrintElement( cDefaultPrinter )

   DEFINE WINDOW Form_1 ;
      AT 0, 0 WIDTH 575 HEIGHT 196 ;
      TITLE "EMF Preview/Print (Metafiles)" ;
      MAIN NoSysMenu NoSize
	
   ON KEY ESCAPE ACTION ThisWindow.Release()

   DEFINE STATUSBAR FONT "Courier New" SIZE 9
      STATUSITEM PadC( "Esc to Exit", 84 )
   END STATUSBAR
	
   DEFINE FRAME Frame_1
      ROW    10
      COL    10
      WIDTH  430
      HEIGHT 54
      FONTNAME "Arial"
      FONTSIZE 9
      FONTBOLD .T.
      CAPTION "EMF (Metafiles)"
   END FRAME

   DEFINE TEXTBOX Text_1
      ROW    30
      COL    20
      WIDTH  340
      HEIGHT 24
      FONTNAME "Arial"
      FONTSIZE 9
      READONLY .T.
      VALUE ""
   END TEXTBOX

   DEFINE BUTTON Button_1
      ROW    28
      COL    370
      WIDTH  60
      HEIGHT 28
      ACTION SetProperty( "Form_1", "Text_1", "Value", Getfile( { { 'Metafiles (emf files)', '*.emf' } }, 'Meta Files' ) )
      CAPTION "Select"
      FONTNAME "Arial"
      FONTSIZE 9
   END BUTTON

   DEFINE FRAME Frame_2
      ROW    70
      COL    10
      WIDTH  430
      HEIGHT 54
      FONTNAME "Arial"
      FONTSIZE 9
      FONTBOLD .T.
      CAPTION "Printers found"
   END FRAME

   DEFINE BUTTON Button_2
      ROW    16
      COL    450
      WIDTH  100
      HEIGHT 28
      ACTION Show_EMF()
      CAPTION "Pre&view"
      FONTNAME "Arial"
      FONTSIZE 9
   END BUTTON

   DEFINE BUTTON Button_3
      ROW    56
      COL    450
      WIDTH  100
      HEIGHT 28
      ACTION ( cDefaultPrinter := _HMG_PRINTER_PrintDialog()[ 2 ], SetProperty( "Form_1", "Combo_1", "Value", GetPrintElement( cDefaultPrinter ) ) )
      CAPTION "Print &Setup"
      FONTNAME "Arial"
      FONTSIZE 9
   END BUTTON

   DEFINE BUTTON Button_4
      ROW    96
      COL    450
      WIDTH  100
      HEIGHT 28
      ACTION Print_EMF()
      CAPTION "&Print"
   END BUTTON

   DEFINE COMBOBOX Combo_1
      ROW    90
      COL    20
      WIDTH  410
      HEIGHT 100
      ITEMS Printers
      VALUE nInitPosition
      FONTNAME "Arial"
      FONTSIZE 10
   END COMBOBOX

   END WINDOW
   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION GetPrintElement( cDefaultPrinter )

   LOCAL i, nInitPosition := 0

   FOR i := 1 TO Len ( Printers )
      IF Printers[i ] == cDefaultPrinter
         nInitPosition := i
         EXIT
      ENDIF
   NEXT i

RETURN nInitPosition

FUNCTION Set_HMG_SYSDATA()

   LOCAL cEMFile := GetProperty( "Form_1", "Text_1", "Value" )
   LOCAL cPrinter := Printers[ GetProperty( "Form_1", "Combo_1", "Value" ) ]

   IF Empty( cEMFile )
      cEMFile := Getfile( { { 'Metafiles (emf files)', '*.emf' } }, 'Meta Files' )
      IF Empty( cEMFile )
         MsgStop( "Select any EMF file !" )
         RETURN .F.
      ELSE
         SetProperty( "Form_1", "Text_1", "Value", cEMFile )
      ENDIF
   ENDIF
   _hmg_printer_InitUserMessages()
   _hmg_printer_CurrentPageNumber := 1
   _hmg_printer_aPrinterProperties := _HMG_PRINTER_SetPrinterProperties( cPrinter )
   _hmg_printer_hdc := _hmg_printer_aPrinterProperties[ 1 ]
   _hmg_printer_name := _hmg_printer_aPrinterProperties[ 2 ]
   _hmg_printer_copies := _hmg_printer_aPrinterProperties[ 3 ]
   _hmg_printer_collate := _hmg_printer_aPrinterProperties[ 4 ]
   _hmg_printer_timestamp := StrZero( Seconds() * 100, 8 )
   _hmg_printer_PageCount := 1
   _hmg_printer_hdc_bak := _hmg_printer_hdc
   _hmg_printer_BasePageName := GetTempFolder() + "\" + _hmg_printer_timestamp + "_hmg_print_preview_"
   _hmg_printer_JobName := 'HMG Print System File ' + cEMFile

RETURN .T.

FUNCTION Show_EMF()

   LOCAL cEMFile, cTMPFile

   IF Set_HMG_SYSDATA()

      cEMFile := GetProperty( "Form_1", "Text_1", "Value" )
      cTMPFile := _hmg_printer_BasePageName + StrZero( _hmg_printer_CurrentPageNumber, 4 ) + ".emf"

      COPY FILE ( cEMFile ) TO ( cTMPFile )

      _hmg_printer_preview := .T.
      _HMG_PRINTER_SHOWPREVIEW()
      DELETE FILE ( cTMPFile )

   ENDIF

RETURN NIL

FUNCTION Print_EMF()

   LOCAL cTMPFile, cEMFile

   IF Set_HMG_SYSDATA()

      cEMFile := GetProperty( "Form_1", "Text_1", "Value" )
      cTMPFile := _hmg_printer_BasePageName + StrZero( _hmg_printer_CurrentPageNumber, 4 ) + ".emf"

      COPY FILE ( cEMFile ) TO ( cTMPFile )

      _HMG_PRINTER_StartDoc ( _hmg_printer_hdc_bak, _hmg_printer_JobName )
      _HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak, cTMPFile )
      _HMG_PRINTER_ENDDOC ( _hmg_printer_hdc_bak )
      DELETE FILE ( cTMPFile )

   ENDIF

RETURN NIL
