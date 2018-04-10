/*
 * Program: Harbour librarian utility
 * Author: Igor Nazarov
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "tsbrowse.ch"
#include "fileio.ch"

ANNOUNCE RDDSYS

REQUEST SQLMIX

MEMVAR cIniFile
MEMVAR cTLibPath
MEMVAR cLibPath
STATIC BRW_1

/****************************************************************************/
FUNCTION Main()
   LOCAL lIniFile := .F.

   PUBLIC cIniFile   := ""
   PUBLIC cTLibPath  := ""
   PUBLIC cLibPath   := ""

   rddSetDefault( "SQLMIX" )

   SET MULTIPLE OFF

   dbCreate( "HB_LIB", { { "LIBRARY", "C", 20, 0 }, { "MODULE", "C", 30, 0 }, { "FUNCTION", "C", 30, 0 } },, .T., "HB_LIB" )

   cIniFile := SUBSTR( Exename(), 1, AT( '.', Exename() ) ) + 'ini'
   IF File( cIniFile )
      lIniFile := .T.
   ENDIF
   // Read paths from INI file
   BEGIN INI FILENAME ( cIniFile )
      GET cTLibPath SECTION 'Path' ENTRY 'TLib' DEFAULT "C:\BORLAND\BCC55\BIN"
      IF ! lIniFile
         SET SECTION 'Path' ENTRY 'TLib' TO cTLibPath
      ENDIF
      GET cLibPath SECTION 'Path' ENTRY 'Library' DEFAULT "C:\MINIGUI\HARBOUR\LIB;C:\MINIGUI\LIB;C:\MINIGUI\XLIB"
      IF ! lIniFile
         SET SECTION 'Path' ENTRY 'Library' TO cLibPath
      ENDIF
   END INI

   HB_LIB->( dbGoTop() )

   SET DEFAULT ICON TO 'tools.ico'

   // Drawing Main form
   DEFINE WINDOW Form_0 ;
      AT 0, 0 ;
      WIDTH 800 ;
      HEIGHT 590 ;
      TITLE 'Content of libraries of HARBOUR compiler for Borland C++' ;
      MAIN ;
      NOSIZE ;
      NOMAXIMIZE ;
      ON INIT { || ScanLib() }

      DEFINE CHECKBOX CHECK_LIB
            ROW	   5
            COL    10
            WIDTH  200
            HEIGHT 16
            VALUE .F.
            FONTNAME "ARIAL"
            FONTSIZE 8
            CAPTION 'Filter of LIB files'
            ON CHANGE FILTER_LIB()
            TABSTOP .F.
      END CHECKBOX

      DEFINE COMBOBOX Combo_LIB
            ROW    25
            COL    10
            WIDTH  200
            HEIGHT 200
            ITEMS {}
            FONTNAME 'Arial'
            FONTSIZE 8
            VALUE 0
            ONCHANGE FILTER_LIB()
      END COMBOBOX

      DEFINE LABEL Label_Func
            ROW    5
            COL    480
            WIDTH  300
            HEIGHT 16
            VALUE "Search by content in the function name"
      END LABEL

      DEFINE GETBOX GetBox_Func
            ROW    25
            COL    480
            WIDTH  300
            HEIGHT 20
            VALUE ''
            PICTURE Replicate( 'X', 300 )
            FONTNAME 'Arial'
            FONTSIZE 9
            TOOLTIP 'Search by content in the function name'
            ON CHANGE FILTER_LIB()
      END GETBOX

      DEFINE BUTTONEX Button_Exit
            ROW    520
            COL    670
            WIDTH  110
            HEIGHT 26
            ACTION ThisWindow.Release
            CAPTION "Close"
            TOOLTIP 'Exit from program'
      END BUTTONEX

      DEFINE BUTTONEX Button_Path
            ROW    520
            COL    10
            WIDTH  110
            HEIGHT 26
            ACTION SetupPath()
            CAPTION "Tuning"
            TOOLTIP 'Program settings'
      END BUTTONEX

      DEFINE TBROWSE BRW_1 ;
            At 55, 10 ;
            ALIAS "HB_LIB" ;
            WIDTH  770 ;
            HEIGHT 450 ;
            COLORS { CLR_BLACK, CLR_BLUE } ;
            FONT "MS Sans Serif" ;
            SIZE 9 ;
            SELECTOR TRUE
      END TBROWSE

      BRW_1:LoadFields( TRUE )
      BRW_1:lCellBrw := FALSE

      BRW_1:nSelWidth := 16
      BRW_1:lNoChangeOrd := TRUE
      BRW_1:nHeightCell += 1
      BRW_1:nWheelLines   := 1
      BRW_1:nHeightHead   := 30
      BRW_1:Setcolor( { 1, 2 }, { RGB(0,0,128),  RGB(255, 255, 210)},  )

      BRW_1:SetColSize( 1, 200 )
      BRW_1:aColumns[ 1 ]:cHeading := "Name of" + CRLF + "LIB file"
      BRW_1:aColumns[ 1 ]:lEdit    := FALSE

      BRW_1:SetColSize( 2, 250 )
      BRW_1:aColumns[ 2 ]:cHeading := "Name of" + CRLF + "module"
      BRW_1:aColumns[ 2 ]:lEdit    := FALSE

      BRW_1:SetColSize( 3, 250 )
      BRW_1:aColumns[ 3 ]:cHeading := "Function"
      BRW_1:aColumns[ 3 ]:lEdit    := FALSE

   END WINDOW

   FILTER_LIB()

   // Drawing form with progress bar
   DEFINE WINDOW Gauge ;
      AT 0 , 0 ;
      WIDTH 660 HEIGHT 100 ;
      TITLE 'Please, wait...' ;
      CHILD ;
      TOPMOST ;
      NOSIZE ;
      NOMAXIMIZE

      DEFINE PROGRESSBAR ProgressBar_1
            ROW    30
            COL    6
            WIDTH  640
            HEIGHT 28
            RANGEMIN 0
            RANGEMAX 100
      END PROGRESSBAR

      DEFINE LABEL Label_1
            ROW    8
            COL    10
            WIDTH  620
            HEIGHT 16
            VALUE ""
      END LABEL

   END WINDOW

   CENTER WINDOW Gauge
   CENTER WINDOW Form_0

   ACTIVATE WINDOW ALL

RETURN NIL

/****************************************************************************/
FUNCTION ScanLib()
   LOCAL cLog := "LST.$$$"
   LOCAL aPath    := {}
   LOCAL cPath
   LOCAL aDir
   LOCAL aCommon  := {}
   LOCAL n
   LOCAL i        := 0
   LOCAL nPos
   LOCAL cLine
   LOCAL cModule
   LOCAL oFile
   LOCAL nPass
   LOCAL cStr := ""

   // Recreate of database
   dbCloseArea( "HB_LIB" )
   dbCreate( "HB_LIB", { { "LIBRARY", "C", 20, 0 }, { "MODULE", "C", 30, 0 }, { "FUNCTION", "C", 30, 0 } },, .T., "HB_LIB" )

   // Redraw of empty browse
   BRW_1:Reset()
   IF BRW_1:nLen > 0
       BRW_1:GoTop()
   END
   BRW_1:Refresh(.T.)

   // Empty combobox for filter
   Form_0.Combo_Lib.DeleteAllItems()

   IF File( cTLibPath + '\tlib.exe' ) // If found the file TLib.exe
      TokenInit( cLibPath, ";" )      // Analyse of the paths through delimiter ';'
      WHILE  ( !tokenend() )
         cPath := AllTrim( TokenNext ( cLibPath ) )
         cPath := iif( Right( cPath, 1 ) == "\", SubStr( cPath, 1, Len(cPath )-1 ), cPath )
         AAdd( aPath, cPath )        // Add to array the finded path
      END

      FOR i := 1 TO Len( aPath )
         aDir := Directory( aPath[ i ] + "\*.lib" )
         AEval( aDir, {| e| AAdd( aCommon, { e[ 1 ], aPath[ i ] } ) } ) // Create the common list of LIB files
      END

      // Show progressbar
      Gauge.Show()

      FOR n := 1 TO Len( aCommon )
         // Set progressbar value
         Gauge.Label_1.Value := "Processing " + aCommon[ n ][ 1 ]
         Gauge.ProgressBar_1.Value := INT( n / Len( aCommon ) * 100 )
         DO EVENTS
         // Add to Combobox name of LIB file
         Form_0.Combo_Lib.AddItem(aCommon[ n ][ 1 ])
         // Launch tlib.exe in background with output of list to file cLog
         hb_processRun( cTLibPath + '\tlib.exe ' + aCommon[ n ][ 2 ] + "\" + aCommon[ n ][ 1 ] + ', ' + cLog,,@cStr,,.T. )

         // Analyse of cLog
         nPass := 0
         oFile := TFileRead():New( cLog )
         oFile:Open( FO_EXCLUSIVE )


         WHILE oFile:Error() .AND. nPass < 200  // do up to 200 attempts of exclusive access for waiting of ending output of list to cLog
            nPass ++
            DO EVENTS
            Millisec(10)
            oFile:Open( FO_EXCLUSIVE )
         END

         cModule := ''
         IF !oFile:Error()
            DO WHILE oFile:MoreToRead()
               cLine :=  oFile:ReadLine()
               IF ( nPos := At( "size =", cLine ) ) <> 0
                  cModule := SubStr( cLine, 1, nPos - 2 )
               ELSEIF !Empty( cModule )
                  TokenInit( cLine )
                  WHILE ( !tokenend() )
                     HB_LIB->( dbAppend() )
                     HB_LIB->LIBRARY  := aCommon[ n ][ 1 ]
                     HB_LIB->MODULE   := cModule
                     HB_LIB->FUNCTION := TokenNext ( cLine )
                  END
               END
            ENDDO
            oFile:Close()
         END
         FErase( cLog )
      END

      HB_LIB->( DBGoTop() )
      BRW_1:Reset()

      IF BRW_1:nLen > 0
         BRW_1:GoTop()
      END
      BRW_1:Refresh(.T.)
      Gauge.Hide()
   ELSE
      MsgBox(" Can not found the required EXE moduke " + CRLF + cTLibPath + '\tlib.exe ')
   END
RETURN NIL

/****************************************************************************/
// Database filter
FUNCTION FILTER_LIB()
LOCAL cFilter := ""
LOCAL bFilter

     Form_0.Combo_lib.Enabled := Form_0.Check_lib.Value

    IF !Empty(AllTrim(Form_0.GetBox_Func.Value))
      cFilter := "'" + Upper(AllTrim(Form_0.GetBox_Func.Value)) + "' $ UPPER(FUNCTION)"
    END

    IF Form_0.Check_lib.Value
       cFilter += IF( !Empty( cFilter), " .AND. ", "") + "LIBRARY = '" + Form_0.Combo_lib.DisplayValue + "'"
    END

    IF !Empty(cFilter)
       bFilter := &( "{|| " + cFilter + " }" )
       HB_LIB->(DBSETFILTER(bFilter, cFilter))
    ELSE
       HB_LIB->(DBSETFILTER())
    END

    HB_LIB->(DBGoTop())
    BRW_1:Reset()

    IF BRW_1:nLen > 0
       BRW_1:GoTop()
    END

    BRW_1:Refresh(.T.)

RETURN NIL

/****************************************************************************/
FUNCTION SetupPath()

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 150 ;
      TITLE 'Paths tuning' ;
      MODAL ;
      ON INIT {|| ISTLIB()}

      DEFINE LABEL Label_Tlib
            ROW    20
            COL    10
            WIDTH  100
            HEIGHT 16
            VALUE "Path to TLib.exe"
      END LABEL

      DEFINE GETBOX TLIB
            ROW    20
            COL    120
            WIDTH  450
            HEIGHT 20
            VALUE M->cTLibPath
            PICTURE Replicate( 'X', 200 )
            FONTNAME 'Arial'
            FONTSIZE 9
            TOOLTIP 'Path to tLib.exe'
            ON CHANGE ISTLIB()
      END GETBOX

      DEFINE LABEL Label_LIb
            ROW    50
            COL    10
            WIDTH  100
            HEIGHT 16
            VALUE "Paths to *.lib"
      END LABEL

      DEFINE GETBOX LIB
            ROW    50
            COL    120
            WIDTH  450
            HEIGHT 20
            VALUE cLibPath
            PICTURE Replicate( 'X', 200 )
            FONTNAME 'Arial'
            FONTSIZE 9
            TOOLTIP 'Paths to *.lib divided via ;'
            ON CHANGE NIL
      END GETBOX

      DEFINE BUTTONEX Button_Exit
            ROW    80
            COL    460
            WIDTH  110
            HEIGHT 25
            ACTION SavePath()
            CAPTION "Save"
            TOOLTIP 'Save settings'
      END BUTTONEX

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1
RETURN NIL

/****************************************************************************/
FUNCTION ISTLIB()
   IF File(AllTrim(Form_1.Tlib.Value )+ "\Tlib.exe" )
      Form_1.Tlib.BackColor := { 206, 250, 191 }
   ELSE
      Form_1.Tlib.BackColor := { 243, 208, 210 }
   END
   Form_1.lib.BackColor := { 206, 250, 191 }
RETURN NIL

/****************************************************************************/
FUNCTION SavePAth()
   M->cTLibPath := RemRight( AllTrim(Form_1.Tlib.Value ), "\")
   M->cLibPath := RemRight( AllTrim(Form_1.lib.Value ), "\")
   BEGIN INI FILENAME ( cIniFile )
      SET  SECTION 'Path' ENTRY 'TLib' TO M->cTLibPath
      SET  SECTION 'Path' ENTRY 'Library' TO M->cLibPath
   END INI
   Form_1.Release
   ScanLib()
RETURN NIL

/****************************************************************************/