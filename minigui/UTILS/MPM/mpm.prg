/*
 *
 * MINIGUI EXTENDED PROJECT MANAGER
 *
 * Based upon Harbour MiniGui Project Manager by Roberto Lopez
 * Copyright (c) 2003 Roberto Lopez <harbourminigui@gmail.com>
 *
 * MiniGUI Extended version by MiniGUI team
 * Last modifed 2013.06.14 by
 * Kevin Carmody <i@kevincarmody.com> and
 * Grigory Filatov <gfilatov@inbox.ru>
 *
*/

//***************************************************************************

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "directry.ch"

#define SOUFILE_NAME      1
#define SOUFILE_BASE      2
#define SOUFILE_EXT       3
#define SOUFILE_DEPEND    4
#define SOUFILE_TOTAL     4

#define MPMB_NOLOCFILE    -101
#define MPMB_NOLOCREAD    -102
#define MPMB_NOBUILDFILE  -103

STATIC lThemed         := .F.
STATIC lVistaOrSe7en   := .F.

STATIC cProjFile  := ''
STATIC cProjName  := ''
STATIC cProjSpec  := ''
STATIC aFileHist  := { '', '', '', '', '', '', '', '', '' }
STATIC aSouFiles  := {}
STATIC lProcess   := .N.
STATIC lEnvir     := .N.
STATIC lGo        := .N.
STATIC cMpmTitle  := 'MiniGUI Extended Project Manager'
STATIC cMpmDate   := '2017.08.01'
STATIC cMpmAuthor := ;
  E"Kevin Carmody <i@kevincarmody.com> and\r\nGrigory Filatov <gfilatov@inbox.ru>"

STATIC cBccFolder      := ''
STATIC cMiniGuiFolder  := ''
STATIC cOHarbourFolder := ''
STATIC cXHarbourFolder := ''
STATIC cEditorExe      := ''

STATIC nMpmWidth     := 0
STATIC nMpmHeight    := 0
STATIC nMpmCol       := 0
STATIC nMpmRow       := 0
STATIC lMpmMax       := .N.
STATIC nRecentWidth  := 0
STATIC nRecentHeight := 0
STATIC nRecentCol    := 0
STATIC nRecentRow    := 0
STATIC nEnvirWidth   := 0
STATIC nEnvirHeight  := 0
STATIC nEnvirCol     := 0
STATIC nEnvirRow     := 0
STATIC nHelpWidth    := 0
STATIC nHelpHeight   := 0
STATIC nHelpCol      := 0
STATIC nHelpRow      := 0
STATIC lHelpMax      := .N.

//***************************************************************************

PROCEDURE Main( cProjArg )

  LOCAL cTab := Chr( 9 )

  lThemed := IsXPThemeActive()
  lVistaOrSe7en := ( IsVista() .OR. IsSeven() )

  LoadEnvironment()

  SET FONT TO 'MS Sans Serif', 9

  DEFINE WINDOW Mpm ;
    AT nMpmRow, nMpmCol ;
    WIDTH  nMpmWidth ;
    HEIGHT nMpmHeight ;
    TITLE  cMpmTitle ;
    MAIN ;
    ICON 'MAIN' ;
    ON INIT     ( SizeMpm(), iif( lEnvir, NIL, SetEnvironment( .Y. ) ) ) ;
    ON MOVE     SizeMpm() ;
    ON SIZE     SizeMpm() ;
    ON MAXIMIZE SizeMpm( .Y. ) ;
    ON RELEASE  SaveEnvironment()

    DEFINE MAIN MENU
      POPUP '&File'
        ITEM '&New'                     ACTION New()
        ITEM '&Open...'  + cTab + 'F3'  ACTION Open()
        ITEM '&Save'     + cTab + 'F2'  ACTION Save()
        ITEM 'Save &As...'              ACTION SaveAs()
        SEPARATOR
        ITEM '&Recent...'               ACTION Recent()
        SEPARATOR
        ITEM '&Exit'     + cTab + 'F10' ACTION Exit()
      END POPUP
      POPUP '&Project'
        ITEM '&Build'    + cTab + 'F4'  ACTION Build()
        ITEM '&Stop...'  + cTab + 'F5'  ACTION StopBuild()
        ITEM '&Run'      + cTab + 'F6'  ACTION Execute()
        SEPARATOR
        ITEM '&Debug'    + cTab + 'F7'  ACTION SwitchDebug( .Y. ) ;
          NAME miDebug
        ITEM 'R&ebuild'  + cTab + 'F8'  ACTION SwitchRebuild( .Y. ) ;
          NAME miRebuild
        SEPARATOR
        ITEM '&Cleanup'                 ACTION Cleanup()
      END POPUP
      POPUP '&Tools'
        ITEM '&Environment...'          ACTION SetEnvironment()
      END POPUP
      POPUP '&Help'
        ITEM '&Contents' + cTab + 'F1'  ACTION Contents()
        SEPARATOR
        ITEM '&About'                   ACTION About()
      END POPUP
    END MENU

    DEFINE TOOLBAR ToolBarMain BUTTONSIZE 45, 35 FLAT

      BUTTON New          ;
        CAPTION 'New'     ;
        PICTURE 'new'     ;
        ACTION New()

      BUTTON Open         ;
        CAPTION 'Open'    ;
        PICTURE 'open'    ;
        ACTION Open()

      BUTTON Save         ;
        CAPTION 'Save'    ;
        PICTURE 'save'    ;
        ACTION Save()     ;
        SEPARATOR

      BUTTON Build        ;
        CAPTION 'Build'   ;
        PICTURE 'build'   ;
        ACTION Build()

      BUTTON Stop         ;
        CAPTION 'Stop'    ;
        PICTURE 'stop'    ;
        ACTION StopBuild()

      BUTTON Run          ;
        CAPTION 'Run'     ;
        PICTURE 'run'     ;
        ACTION Execute()  ;
        SEPARATOR

      BUTTON Help         ;
        CAPTION 'Help'    ;
        PICTURE 'help'    ;
        ACTION Contents() ;
        SEPARATOR

    END TOOLBAR

    DEFINE FRAME frMpm
      ROW     45
      COL     1
      WIDTH   nMpmWidth  - 10
      HEIGHT  nMpmHeight - 95
    END FRAME

    DEFINE TAB Project ;
      AT     60, 10 ;
      WIDTH  310 ;
      HEIGHT nMpmHeight - 140

      PAGE 'Sources'

        DEFINE LABEL lbBaseFolder
          ROW   30
          COL   11
          VALUE   'Base folder'
        END LABEL

        DEFINE TEXTBOX BaseFolder
          ROW     55
          COL     11
          WIDTH   250
          HEIGHT  22
        END TEXTBOX

        DEFINE BUTTON btBaseFolder
          ROW     55
          COL     270
          WIDTH   25
          HEIGHT  25
          PICTURE 'folderselect'
          TOOLTIP 'Select base folder'
          ONCLICK GetBaseFolder()
        END BUTTON

        DEFINE BUTTON AddSource
          ROW     90
          COL     11
          WIDTH   41
          HEIGHT  25
          PICTURE 'add'
          TOOLTIP 'Add source files'
          ONCLICK AddSourceFiles()
        END BUTTON

        DEFINE BUTTON RemoveSource
          ROW     90
          COL     60
          WIDTH   41
          HEIGHT  25
          PICTURE 'remove'
          TOOLTIP 'Remove source file'
          ONCLICK RemoveSourceFile()
        END BUTTON

        DEFINE BUTTON EditSource
          ROW     90
          COL     108
          WIDTH   41
          HEIGHT  25
          PICTURE 'Edit'
          TOOLTIP 'Edit source file'
          ONCLICK EditProgram()
        END BUTTON

        DEFINE BUTTON SetMainSource
          ROW     90
          COL     156
          WIDTH   41
          HEIGHT  25
          PICTURE 'SetTop'
          TOOLTIP 'Set main source file'
          ONCLICK SetMain()
        END BUTTON

        DEFINE BUTTON MoveUpSource
          ROW     90
          COL     205
          WIDTH   41
          HEIGHT  25
          PICTURE 'Up'
          TOOLTIP 'Move source file up'
          ONCLICK MoveSource( .Y. )
        END BUTTON

        DEFINE BUTTON MoveDownSource
          ROW     90
          COL     253
          WIDTH   41
          HEIGHT  25
          PICTURE 'Down'
          TOOLTIP 'Move source file down'
          ONCLICK MoveSource( .N. )
        END BUTTON

        DEFINE LISTBOX SourceList
          ROW     125
          COL     11
          WIDTH   283
          HEIGHT  Mpm.Height - 275
          ONCHANGE    LoadDependents()
          ONDBLCLICK  EditProgram()
        END LISTBOX

      END PAGE

      PAGE 'Dependents'

        DEFINE LABEL lbFile
          ROW   30
          COL   11
          WIDTH 290
          VALUE 'No source file selected'
        END LABEL

        DEFINE BUTTON AddDependent
          ROW     55
          COL     11
          WIDTH   50
          HEIGHT  25
          PICTURE 'add'
          TOOLTIP 'Add dependent files'
          ONCLICK AddDependents()
        END BUTTON

        DEFINE BUTTON RemoveDependent
          ROW     55
          COL     70
          WIDTH   50
          HEIGHT  25
          PICTURE 'remove'
          TOOLTIP 'Remove dependent file'
          ONCLICK RemoveDependent()
        END BUTTON

        DEFINE BUTTON EditDependent
          ROW     55
          COL     128
          WIDTH   50
          HEIGHT  25
          PICTURE 'Edit'
          TOOLTIP 'Edit dependent file'
          ONCLICK EditDependent()
        END BUTTON

        DEFINE BUTTON MoveUpDependent
          ROW     55
          COL     186
          WIDTH   50
          HEIGHT  25
          PICTURE 'Up'
          TOOLTIP 'Move dependent file up'
          ONCLICK MoveDependent( .Y. )
        END BUTTON

        DEFINE BUTTON MoveDownDependent
          ROW     55
          COL     244
          WIDTH   50
          HEIGHT  25
          PICTURE 'Down'
          TOOLTIP 'Move dependent file down'
          ONCLICK MoveDependent( .N. )
        END BUTTON

        DEFINE LISTBOX DependList
          ROW     90
          COL     10
          WIDTH   283
          HEIGHT  Mpm.Height - 240
          ONDBLCLICK  EditDependent()
        END LISTBOX

      END PAGE

      PAGE 'Options'

        DEFINE CHECKBOX Debug
          ROW     30
          COL     12
          WIDTH   160
          CAPTION 'Create debug EXE'
          TOOLTIP 'Compile and link in debug mode'
          ON CHANGE SwitchDebug( .N. )
        END CHECKBOX

        DEFINE CHECKBOX Rebuild
          ROW     55
          COL     12
          WIDTH   160
          CAPTION 'Rebuild project'
          TOOLTIP 'Rebuild project regardless of source file dates'
          ON CHANGE SwitchRebuild( .N. )
        END CHECKBOX

        DEFINE CHECKBOX RunAfter
          ROW     80
          COL     12
          WIDTH   160
          CAPTION 'Run after build'
          VALUE   .Y.
          TOOLTIP 'Run EXE immediately after successful build'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX HideBuild
          ROW     105
          COL     12
          WIDTH   160
          CAPTION 'Hide build window'
          VALUE   .Y.
          TOOLTIP 'Hide the temporary window in which the build process runs'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX DeleteTemp
          ROW     130
          COL     12
          WIDTH   160
          CAPTION 'Delete temporary files'
          VALUE   .Y.
          TOOLTIP 'Delete temporary files created by the build process'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX UseXHarbour
          ROW     155
          COL     12
          WIDTH   160
          CAPTION 'Use xHarbour'
          TOOLTIP 'Use xHarbour instead of Harbour - requires xHarbour path'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX MultiThread
          ROW     180
          COL     12
          WIDTH   160
          CAPTION 'Multithreaded EXE'
          TOOLTIP 'Create multithreaded EXE'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX GenPpo
          ROW     205
          COL     12
          WIDTH   160
          CAPTION 'Generate PPO'
          TOOLTIP 'Generate preprocessor output file (PPO) ' + ;
            'for each PRG file'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE LABEL lbPrgParams
          ROW     240
          COL     12
          WIDTH   160
          VALUE   'Additional compiler options'
        END LABEL

        DEFINE TEXTBOX PrgParams
          ROW     260
          COL     12
          WIDTH   160
          HEIGHT  22
          TOOLTIP 'Parameters to add to command line when compiling PRG files'
          ON CHANGE StatusLabel()
        END TEXTBOX

        DEFINE LABEL lbCParams
          ROW     290
          COL     12
          WIDTH   160
          VALUE   'Additional C compiler options'
        END LABEL

        DEFINE TEXTBOX CParams
          ROW     310
          COL     12
          WIDTH   160
          HEIGHT  22
          TOOLTIP 'Parameters to add to command line when compiling C files'
          ON CHANGE StatusLabel()
        END TEXTBOX

        DEFINE LABEL lbExeParams
          ROW     340
          COL     12
          WIDTH   160
          VALUE   'EXE command line options'
        END LABEL

        DEFINE TEXTBOX ExeParams
          ROW     360
          COL     12
          WIDTH   160
          HEIGHT  22
          TOOLTIP 'Parameters to add to command line when running EXE'
          ON CHANGE StatusLabel()
        END TEXTBOX

        DEFINE LABEL lbExeType
          ROW     40
          COL     182
          WIDTH   120
          VALUE   'Executable type'
        END LABEL

        DEFINE RADIOGROUP ExeType
          ROW     65
          COL     202
          WIDTH   100
          SPACING 25
          OPTIONS { 'GUI', 'Console', 'Mixed' }
          VALUE   1
          ON CHANGE StatusLabel()
        END RADIOGROUP

        DEFINE LABEL lbWarnings
          ROW     155
          COL     182
          WIDTH   120
          VALUE   'Compiler warnings'
        END LABEL

        DEFINE RADIOGROUP Warnings
          ROW     180
          COL     202
          WIDTH   100
          SPACING 25
          OPTIONS { 'None', 'Basic', 'Strong', 'Typed' }
          VALUE   1
          ON CHANGE StatusLabel()
        END RADIOGROUP

        DEFINE CHECKBOX GenLib
          ROW     295
          COL     182
          WIDTH   120
          CAPTION 'Generate library'
          TOOLTIP 'Generate library (LIB) file instead of executable (EXE)'
          ON CHANGE StatusLabel()
        END CHECKBOX

      END PAGE

      PAGE 'Libraries and object files'

        DEFINE CHECKBOX ZipLib
          ROW     30
          COL     12
          WIDTH   160
          CAPTION 'ZIP support'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX OdbcLib
          ROW     55
          COL     12
          WIDTH   160
          CAPTION 'ODBC support'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX AdsLib
          ROW     80
          COL     12
          WIDTH   160
          CAPTION 'ADS support'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE CHECKBOX MySqlLib
          ROW     105
          COL     12
          WIDTH   160
          CAPTION 'MySQL support'
          ON CHANGE StatusLabel()
        END CHECKBOX

        DEFINE LABEL lbAddLib
          ROW     140
          COL     12
          WIDTH   160
          VALUE   'Additional libraries and object files'
        END LABEL

        DEFINE BUTTONEX AddHarbour
          ROW     165
          COL     12
          WIDTH   41
          HEIGHT  25
          PICTURE 'addh'
          TOOLTIP 'Add additional (x)Harbour library to link script'
          ONCLICK AddLibFiles( 'H' )
        END BUTTONEX

        DEFINE BUTTONEX AddMiniGui
          ROW     165
          COL     60
          WIDTH   41
          HEIGHT  25
          PICTURE 'addm'
          TOOLTIP 'Add additional MiniGui library to link script'
          ONCLICK AddLibFiles( 'M' )
        END BUTTONEX

        DEFINE BUTTONEX AddOther
          ROW     165
          COL     108
          WIDTH   41
          HEIGHT  25
          PICTURE 'addo'
          TOOLTIP 'Add additional library or object file to link script'
          ONCLICK AddLibFiles( 'O' )
        END BUTTONEX

        DEFINE BUTTON RemoveLib
          ROW     165
          COL     156
          WIDTH   41
          HEIGHT  25
          PICTURE 'remove'
          TOOLTIP 'Remove library or object file'
          ONCLICK RemoveLib()
        END BUTTON

        DEFINE BUTTON MoveUpLib
          ROW     165
          COL     204
          WIDTH   41
          HEIGHT  25
          PICTURE 'up'
          TOOLTIP 'Move library or object file up'
          ONCLICK MoveLib( .Y. )
        END BUTTON

        DEFINE BUTTON MoveDownLib
          ROW     165
          COL     252
          WIDTH   41
          HEIGHT  25
          PICTURE 'down'
          TOOLTIP 'Move library or object file down'
          ONCLICK MoveLib( .N. )
        END BUTTON

        DEFINE LISTBOX LibList
          ROW     200
          COL     11
          WIDTH   282
          HEIGHT  Mpm.Height - 350
        END LISTBOX

      END PAGE

    END TAB

    DEFINE LABEL lbStatus
      ROW     15
      COL     355
      WIDTH   140
      VALUE   ''
      FONTBOLD .Y.
    END LABEL

    DEFINE LABEL lbDebug
      ROW     15
      COL     505
      WIDTH   45
      VALUE   ''
      FONTCOLOR PURPLE
    END LABEL

    DEFINE LABEL lbRebuild
      ROW     15
      COL     555
      WIDTH   45
      VALUE   ''
      FONTCOLOR BLUE
    END LABEL

    DEFINE EDITBOX Log
      ROW     60
      COL     335
      WIDTH   Mpm.Width  - 354
      HEIGHT  Mpm.Height - 140
      READONLY   .Y.
      HSCROLLBAR .N.
    END EDITBOX

    DEFINE LABEL Keys
      ROW     Mpm.Height - 70
      COL     10
      WIDTH   Mpm.Width  - 20
      VALUE   'F1 Help - F2 Save - F3 Open - F4 Build - F5 Stop - F6 Run - F7 Debug - F8 Rebuild - F10 Exit'
    END LABEL

    DEFINE TIMER tmStatus ;
      INTERVAL 500 ;
      ACTION StatusRefresh()

    ON KEY F1  ACTION Contents()
    ON KEY F2  ACTION Save()
    ON KEY F3  ACTION Open()
    ON KEY F4  ACTION Build()
    ON KEY F5  ACTION StopBuild()
    ON KEY F6  ACTION Execute()
    ON KEY F7  ACTION SwitchDebug( .Y. )
    ON KEY F8  ACTION SwitchRebuild( .Y. )
    ON KEY F10 ACTION Exit()

  END WINDOW

  cProjSpec := ProjSpec()
  IF !Empty( cProjArg )
    Open( cProjArg )
  ENDIF

  Mpm.MinWidth  := 675 + iif( lVistaOrSe7en, GetBorderWidth(), 0 )
  Mpm.MinHeight := 545
  IF lMpmMax
    Mpm.Maximize()
  END

  ACTIVATE WINDOW Mpm

RETURN

//***************************************************************************

PROCEDURE SizeMpm( lMax )

LOCAL nWidth  := Mpm.Width
LOCAL nHeight := Mpm.Height
LOCAL nCol    := Mpm.Col
LOCAL nRow    := Mpm.Row

  IF Empty( lMax )
    IF nWidth < GetDesktopWidth() .AND. nHeight < GetDesktopHeight()
      nMpmWidth  := nWidth
      nMpmHeight := nHeight
      nMpmCol    := nCol
      nMpmRow    := nRow
    ENDIF
    lMpmMax    := .N.
  ELSE
    lMpmMax    := .Y.
  ENDIF
  Mpm.frMpm.Width       := nWidth  - 10 - iif( lVistaOrSe7en, GetBorderWidth(), 0 )
  Mpm.frMpm.Height      := nHeight - 95 - iif( lThemed, iif( lVistaOrSe7en, 10, 5 ), 0 )
  Mpm.Project.Height    := nHeight - 140 - iif( lThemed, iif( lVistaOrSe7en, 10, 5 ), 0 )
  Mpm.SourceList.Height := Max( 50, nHeight - 275 - iif( lThemed, 15, 0 ) )
  Mpm.DependList.Height := Max( 50, nHeight - 240 - iif( lThemed, 15, 0 ) )
  Mpm.LibList.Height    := Max( 50, nHeight - 350 - iif( lThemed, 15, 0 ) )
  Mpm.Log.Width         := Max( 90, nWidth  - 354 - iif( lVistaOrSe7en, GetBorderWidth(), 0 ) )
  Mpm.Log.Height        := Max( 50, nHeight - 140 - iif( lThemed, iif( lVistaOrSe7en, 12, 7 ), 0 ) )
  Mpm.Keys.Row          := Max( 50, nHeight - 70 - iif( lThemed, iif( lVistaOrSe7en, 12, 7 ), 0 ) )
  Mpm.Keys.Width        := Max( 50, nWidth  - 20 - iif( lVistaOrSe7en, GetBorderWidth(), 0 ) )

RETURN

//***************************************************************************

PROCEDURE GetBaseFolder

  LOCAL cFolder := GetFolder( 'Base folder', Mpm.BaseFolder.Value )

  IF !Empty( cFolder )
    Mpm.BaseFolder.Value := cFolder
  ENDIF

RETURN

//***************************************************************************

PROCEDURE New

  SaveCheck()
  cProjName := ''
  Mpm.Title := cMpmTitle
  Mpm.BaseFolder.Value  := ''
  Mpm.Debug.Value       := .N.
  Mpm.Rebuild.Value     := .N.
  Mpm.RunAfter.Value    := .Y.
  Mpm.HideBuild.Value   := .Y.
  Mpm.DeleteTemp.Value  := .Y.
  Mpm.UseXHarbour.Value := .N.
  Mpm.MultiThread.Value := .N.
  Mpm.GenPpo.Value      := .N.
  Mpm.ExeType.Value     := 1
  Mpm.Warnings.Value    := 2
  Mpm.GenLib.Value      := .N.
  Mpm.PrgParams.Value   := ''
  Mpm.CParams.Value     := ''
  Mpm.ExeParams.Value   := ''
  Mpm.ZipLib.Value      := .N.
  Mpm.OdbcLib.Value     := .N.
  Mpm.AdsLib.Value      := .N.
  Mpm.MySqlLib.Value    := .N.
  Mpm.Log.Value         := ''
  Mpm.LibList.DeleteAllItems
  aSouFiles := {}
  RefreshSource()
  SwitchDebug( .N. )
  SwitchRebuild( .N. )
  StatusLabel()
  cProjSpec := ProjSpec()
  GetBaseFolder()

RETURN

//***************************************************************************

PROCEDURE Open( cProjOpen )

  LOCAL aExeType  := { 'GUI', 'CONSOLE', 'MIXED' }
  LOCAL aWarnings := { 'NONE', 'BASIC', 'STRONG', 'TYPED' }
  LOCAL aDepend   := {}
  LOCAL cProjExt
  LOCAL cSpec
  LOCAL cExt
  LOCAL cLine
  LOCAL cLineU
  LOCAL cKey
  LOCAL cVal
  LOCAL cValU
  LOCAL nLine
  LOCAL nMaxLen   := 254
  LOCAL nPos

  BEGIN SEQUENCE

    SaveCheck()
    IF Empty( cProjOpen )
      cProjOpen := GetFile( { ;
        { 'Harbour MiniGUI project files (*.mpm)', '*.mpm' }, ;
        { '(x)Harbour source files (*.prg)', '*.prg' }, ;
        { 'C source files (*.c)', '*.c'  } }, ;
        'Open project or source file', Mpm.BaseFolder.Value )
    ENDIF
    IF Empty( cProjOpen )
      BREAK
    END
    IF !File( cProjOpen )
      MpmStop( 'Cannot find ' + cProjOpen + '.' )
      BREAK
    ENDIF

    Mpm.BaseFolder.Value  := ''
    Mpm.Debug.Value       := .N.
    Mpm.Rebuild.Value     := .N.
    Mpm.RunAfter.Value    := .Y.
    Mpm.HideBuild.Value   := .Y.
    Mpm.DeleteTemp.Value  := .Y.
    Mpm.UseXHarbour.Value := .N.
    Mpm.MultiThread.Value := .N.
    Mpm.GenPpo.Value      := .N.
    Mpm.ExeType.Value     := 1
    Mpm.Warnings.Value    := 2
    Mpm.GenLib.Value      := .N.
    Mpm.PrgParams.Value   := ''
    Mpm.ExeParams.Value   := ''
    Mpm.ZipLib.Value      := .N.
    Mpm.OdbcLib.Value     := .N.
    Mpm.AdsLib.Value      := .N.
    Mpm.MySqlLib.Value    := .N.
    Mpm.Log.Value         := ''
    Mpm.LibList.DeleteAllItems
    aSouFiles := {}
    cProjExt  := Upper( GetExt( cProjOpen ) )

    DO CASE
    CASE cProjExt == '.MPM'

      cSpec := MemoRead( cProjOpen )
      IF Empty( cSpec )
        MpmStop( 'Cannot read ' + cProjOpen + '.' )
        BREAK
      ENDIF

      cProjFile := GetPath( cProjOpen )
      cProjName := GetName( cProjFile )
      Mpm.Title := cProjName + ' - ' + cMpmTitle

      FOR nLine := 1 TO MLCount( cSpec, nMaxLen )
        cLine  := AllTrim( MemoLine( cSpec, nMaxLen, nLine ) )
        cLineU := Upper( cLine )
        nPos   := At( '=', cLine )
        cKey   := StrTran( Left( cLineU, nPos - 1 ), ' ' )
        cVal   := AllTrim( SubStr( cLine, nPos + 1 ) )
        cValU  := Upper( cVal )
        cExt   := Upper( GetExt( cLine ) )
        DO CASE
        CASE cKey == 'PROJECTFOLDER'
          Mpm.BaseFolder.Value := cVal
        CASE cKey == 'DEBUG'
          Mpm.Debug.Value       := ( 'Y' $ cValU )
        CASE cKey == 'REBUILD'
          Mpm.Rebuild.Value     := ( 'Y' $ cValU )
        CASE cKey == 'RUNAFTER'
          Mpm.RunAfter.Value    := ( 'Y' $ cValU )
        CASE cKey == 'HIDEBUILD'
          Mpm.HideBuild.Value   := ( 'Y' $ cValU )
        CASE cKey == 'DELETETEMP'
          Mpm.DeleteTemp.Value  := ( 'Y' $ cValU )
        CASE cKey == 'XHARBOUR'
          Mpm.UseXHarbour.Value := ( 'Y' $ cValU )
        CASE cKey == 'MULTITHREAD'
          Mpm.MultiThread.Value := ( 'Y' $ cValU )
        CASE cKey == 'GENPPO'
          Mpm.GenPpo.Value      := ( 'Y' $ cValU )
        CASE cKey == 'EXETYPE'
          nPos := AScan( aExeType, cValU )
          Mpm.ExeType.Value     := iif( Empty( nPos ), 1, nPos )
        CASE cKey == 'WARNINGS'
          nPos := AScan( aWarnings, cValU )
          Mpm.Warnings.Value    := iif( Empty( nPos ), 2, nPos )
        CASE cKey == 'GENLIB'
          Mpm.GenLib.Value      := ( 'Y' $ cValU )
        CASE cKey == 'PRGPARAMS'
          Mpm.PrgParams.Value   := cVal
        CASE cKey == 'CPARAMS'
          Mpm.CParams.Value     := cVal
        CASE cKey == 'EXEPARAMS'
          Mpm.ExeParams.Value   := cVal
        CASE cKey == 'ZIPSUPPORT'
          Mpm.ZipLib.Value      := ( 'Y' $ cValU )
        CASE cKey == 'ODBCSUPPORT'
          Mpm.OdbcLib.Value     := ( 'Y' $ cValU )
        CASE cKey == 'ADSSUPPORT'
          Mpm.AdsLib.Value      := ( 'Y' $ cValU )
        CASE cKey == 'MYSQLSUPPORT'
          Mpm.MySqlLib.Value    := ( 'Y' $ cValU )
        CASE Left( cLine, 1 ) == '/'
          AAdd( aDepend, AllTrim( SubStr( cLine, 2 ) ) )
        CASE cExt $ '.LIB/.OBJ/.RES'
          Mpm.LibList.AddItem( cLine )
        CASE cExt $ '.PRG/.CH/.FMG/.RC/.C/.H'
          aDepend := {}
          AddSourceFile( cLine, aDepend )
        ENDCASE
      NEXT

      UpdateFileHist()
      cProjSpec := ProjSpec()

    CASE cProjExt $ '.PRG/.C'

      cProjFile := ''
      cProjName := ''
      Mpm.Title := cMpmTitle
      Mpm.BaseFolder.Value := GetSub( cProjOpen, .Y. )
      AddSourceFile( GetName( cProjOpen ) )
      UpdateFileHist()

    ENDCASE

    RefreshSource()
    SwitchDebug( .N. )
    SwitchRebuild( .N. )
    StatusLabel()

  END SEQUENCE

RETURN

//***************************************************************************

FUNCTION ProjSpec

  LOCAL aExeType  := { 'GUI', 'CONSOLE', 'MIXED' }
  LOCAL aWarnings := { 'NONE', 'BASIC', 'STRONG', 'TYPED' }
  LOCAL bYesNo    := {| lVal| iif( lVal, 'YES', 'NO' ) }
  LOCAL nFiles
  LOCAL nFile
  LOCAL aFile

  LOCAL cSpec     := ;
    'PROJECTFOLDER=' + AllTrim( Mpm.BaseFolder.Value )      + CRLF + ;
    'DEBUG='         + bYesNo:Eval( Mpm.Debug.Value      ) + CRLF + ;
    'REBUILD='       + bYesNo:Eval( Mpm.Rebuild.Value    ) + CRLF + ;
    'RUNAFTER='      + bYesNo:Eval( Mpm.RunAfter.Value   ) + CRLF + ;
    'HIDEBUILD='     + bYesNo:Eval( Mpm.HideBuild.Value  ) + CRLF + ;
    'DELETETEMP='    + bYesNo:Eval( Mpm.DeleteTemp.Value ) + CRLF + ;
    'XHARBOUR='      + bYesNo:Eval( Mpm.UseXHarbour.Value ) + CRLF + ;
    'MULTITHREAD='   + bYesNo:Eval( Mpm.MultiThread.Value ) + CRLF + ;
    'GENPPO='        + bYesNo:Eval( Mpm.GenPpo.Value     ) + CRLF + ;
    'EXETYPE='       + aExeType[ Mpm.ExeType.Value ]        + CRLF + ;
    'WARNINGS='      + aWarnings[ Mpm.Warnings.Value ]      + CRLF + ;
    'GENLIB='        + bYesNo:Eval( Mpm.GenLib.Value     ) + CRLF + ;
    'PRGPARAMS='     + AllTrim( Mpm.PrgParams.Value )       + CRLF + ;
    'CPARAMS='       + AllTrim( Mpm.CParams.Value )         + CRLF + ;
    'EXEPARAMS='     + AllTrim( Mpm.ExeParams.Value )       + CRLF + ;
    'ZIPSUPPORT='    + bYesNo:Eval( Mpm.ZipLib.Value   )   + CRLF + ;
    'ODBCSUPPORT='   + bYesNo:Eval( Mpm.OdbcLib.Value  )   + CRLF + ;
    'ADSSUPPORT='    + bYesNo:Eval( Mpm.AdsLib.Value   )   + CRLF + ;
    'MYSQLSUPPORT='  + bYesNo:Eval( Mpm.MySqlLib.Value )   + CRLF

  nFiles := Mpm.LibList.ItemCount
  FOR nFile := 1 TO nFiles
    cSpec += AllTrim( Mpm.LibList.Item( nFile ) ) + CRLF
  NEXT

  nFiles := Len( aSouFiles )
  FOR nFile := 1 TO nFiles
    aFile   := aSouFiles[ nFile ]
    cSpec   += aFile[ SOUFILE_NAME ] + CRLF
    AEval( aFile[ SOUFILE_DEPEND ], {| cRow| cSpec += '/ ' + cRow + CRLF } )
  NEXT

RETURN cSpec

//***************************************************************************

PROCEDURE Save

  BEGIN SEQUENCE

    IF Empty( cProjFile )
      SaveAs()
      BREAK
    ENDIF

    IF MemoWrite( cProjFile, ProjSpec() )
      StatusLabel( 'Save successful', 0 )
      cProjSpec := ProjSpec()
    ELSE
      StatusLabel( 'Save unsuccessful', 1 )
    ENDIF

    UpdateFileHist()

  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE SaveAs

  LOCAL nSouFiles      := Len( aSouFiles )
  LOCAL cDefProjFile   := iif( Empty( cProjFile ), iif( Empty( nSouFiles ), '', ;
    aSouFiles[ 1 ][ SOUFILE_BASE ] + '.mpm' ), cProjFile )
  LOCAL cGetProjFile   := AllTrim( ;
    PutFile( { { 'Harbour MiniGUI project files (*.mpm)', '*.mpm' } }, ;
    'Save Project', Mpm.BaseFolder.Value,, cDefProjFile ) )

  IF !Empty( cGetProjFile )
    IF !( Upper( GetExt( cGetProjFile ) ) == '.MPM' )
      cGetProjFile += '.mpm'
    ENDIF
    IF !File( cGetProjFile ) .OR. ;
      MpmYesNo( cGetProjFile + ' already exists.  Replace it?' )
      cProjFile := cGetProjFile
      cProjName := GetName( cProjFile )
      Mpm.Title := cProjName + ' - ' + cMpmTitle
      Save()
    ENDIF
  ENDIF

RETURN

//***************************************************************************

PROCEDURE SaveCheck

  IF !( cProjSpec == ProjSpec() ) .AND. MpmYesNo( 'Save the current project?' )
    IF Empty( cProjFile )
      SaveAs()
    ELSE
      Save()
    ENDIF
  ENDIF

RETURN

//***************************************************************************

PROCEDURE Recent

  LOCAL nFile

  DEFINE WINDOW Recent ;
    AT     nRecentRow, nRecentCol ;
    WIDTH  nRecentWidth ;
    HEIGHT nRecentHeight ;
    TITLE  'Recent projects' ;
    ICON   'MAIN' ;
    MODAL ;
    ON INIT RecentSize() ;
    ON MOVE RecentSize() ;
    ON SIZE RecentSize()

    DEFINE LISTBOX ProjList
      ROW     10
      COL     10
      WIDTH   300
      HEIGHT  140
      ITEMS   aFileHist
      VALUE   1
      ONDBLCLICK ( nFile := Recent.ProjList.Value, Recent.Release )
    END LISTBOX

    DEFINE BUTTON Open
      ROW     160
      COL     85
      WIDTH   65
      HEIGHT  25
      CAPTION '&Open'
      ONCLICK ( nFile := Recent.ProjList.Value, Recent.Release )
    END BUTTON

    DEFINE BUTTON Cancel
      ROW     160
      COL     175
      WIDTH   65
      HEIGHT  25
      CAPTION '&Cancel'
      ONCLICK Recent.Release
    END BUTTON

    ON KEY RETURN ACTION ( nFile := Recent.ProjList.Value, Recent.Release )
    ON KEY ESCAPE ACTION Recent.Release

  END WINDOW

  Recent.MinWidth  := 185
  Recent.MinHeight := 135

  ACTIVATE WINDOW Recent

  IF !Empty( nFile )
    Open( aFileHist[ nFile ] )
  ENDIF

RETURN

//***************************************************************************

PROCEDURE RecentSize

LOCAL lThemed := IsXPThemeActive()

  nRecentWidth  := Recent.Width
  nRecentHeight := Recent.Height
  nRecentCol    := Recent.Col
  nRecentRow    := Recent.Row
  Recent.ProjList.Width  := Max( 50, nRecentWidth  - 30 - iif( lVistaOrSe7en, 5, 0 ) )
  Recent.ProjList.Height := Max( 50, nRecentHeight - 80 - iif( lThemed .AND. !lVistaOrSe7en, 7, 0 ) )
  Recent.Open.Col        := Max( 10, Int( nRecentWidth / 2 ) - 80 )
  Recent.Open.Row        := Max( 70, nRecentHeight - 60 - iif( lThemed, 7, 0 ) )
  Recent.Cancel.Col      := Max( 10, Int( nRecentWidth / 2 ) + 10 ) - iif( lVistaOrSe7en, GetBorderWidth(), 0 )
  Recent.Cancel.Row      := Max( 70, nRecentHeight - 60 - iif( lThemed, 7, 0 ) )

RETURN

//***************************************************************************

PROCEDURE Exit

  IF MpmYesNo( 'Exit MPM?' )
    Mpm.Release
  ENDIF

RETURN

//***************************************************************************

PROCEDURE UpdateFileHist

  LOCAL cProjFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL lProjFile   := !Empty( cProjFile )
  LOCAL cProjFileU  := Upper( cProjFile )
  LOCAL lSouMain    := !Empty( aSouFiles )
  LOCAL cSouMain    := iif( lSouMain, ;
    cProjFolder + aSouFiles[ 1 ][ SOUFILE_NAME ], '' )
  LOCAL cSouMainU   := Upper( cSouMain )
  LOCAL nPos

  DO CASE
  CASE lProjFile .AND. lSouMain
    nPos := AScan( aFileHist, {| cVal| ;
      Upper( cVal ) == cProjFileU .OR. Upper( cVal ) == cSouMainU } )
  CASE lProjFile
    nPos := AScan( aFileHist, {| cVal| Upper( cVal ) == cProjFileU } )
  CASE lSouMain
    nPos := AScan( aFileHist, {| cVal| Upper( cVal ) == cSouMainU } )
  ENDCASE

  IF !Empty( nPos )
    ADel( aFileHist, nPos )
  ENDIF
  IF lProjFile .OR. lSouMain
    AIns( aFileHist, 1 )
    aFileHist[ 1 ] := iif( lProjFile, cProjFile, cSouMain )
  ENDIF

RETURN

//***************************************************************************

PROCEDURE AddSourceFile( cAddFile, aDepend )

  LOCAL aFile := Array( SOUFILE_TOTAL )
  LOCAL cFile := AllTrim( cAddFile )

  IF Empty( AScan( aSouFiles, ;
    {| aRow| Upper( aRow[ SOUFILE_NAME ] ) == Upper( cFile ) } ) )
    aFile[ SOUFILE_NAME ]   := cFile
    aFile[ SOUFILE_BASE ]   := DelExt( GetName( cFile ) )
    aFile[ SOUFILE_EXT ]    := Upper( GetExt( cFile ) )
    aFile[ SOUFILE_DEPEND ] := iif( aDepend == NIL, {}, aDepend)
    AAdd( aSouFiles, aFile )
    RefreshSource()
  ENDIF

RETURN

//***************************************************************************

PROCEDURE AddSourceFiles

  LOCAL cBaseFolder  := Mpm.BaseFolder.Value
  LOCAL cBaseFolderU := Upper( AddSlash( cBaseFolder ) )
  LOCAL nBaseFolderU := Len( cBaseFolderU )
  LOCAL lOutBase     := .N.
  LOCAL aNewFiles
  LOCAL aTypes
  LOCAL cNewFile
  LOCAL nFile
  LOCAL nFiles

  BEGIN SEQUENCE

    IF Empty( aSouFiles )
      aTypes := { ;
        { '(x)Harbour source files (*.prg)', '*.prg' }, ;
        { 'C source files (*.c)', '*.c'  }  }
    ELSE
      aTypes := { ;
        { '(x)Harbour source files (*.prg)', '*.prg' }, ;
        { '(x)Harbour header files (*.ch)', '*.ch' }, ;
        { 'Window definition files (*.fmg)', '*.fmg' }, ;
        { 'Resource script files (*.rc)', '*.rc' }, ;
        { 'C source files (*.c)', '*.c'  }, ;
        { 'C header files (*.h)', '*.h'  }  }
    ENDIF
    aNewFiles := GetFile( aTypes, 'Select source files', cBaseFolder, .Y. )

    IF Empty( aNewFiles )
      BREAK
    ENDIF

    nFiles := Len( aNewFiles )
    FOR nFile := 1 TO nFiles
      cNewFile := AllTrim( aNewFiles[ nFile ] )
      IF Left( Upper( cNewFile ), nBaseFolderU ) == cBaseFolderU
        aNewFiles[ nFile ] := SubStr( cNewFile, nBaseFolderU + 1 )
      ELSE
        lOutBase := .Y.
      ENDIF
    NEXT
    IF lOutBase
      MpmStop( 'Source files must be in the base folder or in folders under it.' )
      BREAK
    ENDIF

    IF Empty( cBaseFolder )
      cNewFile     := AllTrim( aNewFiles[ 1 ] )
      cBaseFolder  := GetSub( cNewFile, .Y. )
      Mpm.BaseFolder.Value := cBaseFolder
    ENDIF

    ASort( aNewFiles,,, {| cRow1, cRow2| Upper( cRow1 ) <= Upper( cRow2 ) } )
    FOR nFile := 1 TO nFiles
      AddSourceFile( aNewFiles[ nFile ] )
    NEXT

    StatusLabel()

  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE RemoveSourceFile

  LOCAL nFile  := Mpm.SourceList.Value
  LOCAL nFiles := Mpm.SourceList.ItemCount

  BEGIN SEQUENCE
    IF Empty( aSouFiles )
      MpmStop( 'You must add at least one source file.' )
      BREAK
    ENDIF
    IF Empty( nFile )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    IF nFile == 1 .AND. nFiles > 1
      MpmStop( 'You must remove the main source file last.' )
      BREAK
    ENDIF
    IF !MpmYesNo( 'Remove file ' + ;
      aSouFiles[ nFile ][ SOUFILE_NAME ] + ' from this project?' )
      BREAK
    ENDIF
    ADelete( aSouFiles, nFile )
    RefreshSource()
    StatusLabel()
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE EditProgram

  LOCAL cFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL nFile   := Mpm.SourceList.Value
  LOCAL cFile

  BEGIN SEQUENCE
    IF Empty( aSouFiles )
      MpmStop( 'You must add at least one source file.' )
      BREAK
    ENDIF
    IF Empty( nFile )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    IF Empty( cEditorExe )
      MpmStop( 'You must select a program editor.' )
      BREAK
    ENDIF
    IF !File( cEditorExe ) .AND. !FileInPath( cEditorExe )
      MpmStop( 'Cannot find program editor ' + cEditorExe + '.' )
      BREAK
    ENDIF
    cFile := AddQuote( cFolder + aSouFiles[ nFile ][ SOUFILE_NAME ] )
    MpmRun( cEditorExe, cFile, .Y. )
    StatusLabel()
  END SEQUENCE

RETURN

//***************************************************************************

#ifndef __XHARBOUR__
   # xtranslate At( < a >, < b >, [ < x, ... > ] ) => hb_At( < a >, < b >, < x > )
#endif

FUNCTION FileInPath( cFile )

  LOCAL cPath  := GetEnv( 'PATH' ) + ';'
  LOCAL lFound := .N.
  LOCAL nLPos  := 0
  LOCAL nRPos  := 0
  LOCAL cSearch

  WHILE nRPos < Len( cPath ) .AND. !lFound
    nRPos   := At( ';', cPath, nLPos + 1 )
    cSearch := AddSlash( SubStr( cPath, nLPos + 1, nRPos - nLPos - 1 ) )
    lFound  := File( cSearch + cFile )
    nLPos   := nRPos
  END WHILE

RETURN lFound

//***************************************************************************

PROCEDURE SetMain

  LOCAL aItem1
  LOCAL aItemN
  LOCAL nItem := Mpm.SourceList.Value

  BEGIN SEQUENCE
    IF Empty( aSouFiles )
      MpmStop( 'You must add at least one source file.' )
      BREAK
    ENDIF
    IF Empty( nItem )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    IF nItem == 1
      MpmStop( aSouFiles[ 1 ][ SOUFILE_NAME ] + ' is already the main file.' )
      BREAK
    ENDIF
    aItem1 := aSouFiles[ 1 ]
    aItemN := aSouFiles[ nItem ]
    IF !( aItemN[ SOUFILE_EXT ] $ '.PRG/.C' )
      MpmStop( 'You must select a PRG or C file as the main source file.' )
      BREAK
    ENDIF
    aSouFiles[ nItem ] := aItem1
    aSouFiles[ 1 ]     := aItemN
    RefreshSource()
    Mpm.SourceList.SetFocus
    StatusLabel( 'Main changed', 0 )
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE MoveSource( lUp )

  LOCAL aItem1
  LOCAL aItem2
  LOCAL nItem  := Mpm.SourceList.Value
  LOCAL nItems := Len( aSouFiles )

  BEGIN SEQUENCE
    IF nItems < 2
      MpmStop( 'You must add at least two source files.' )
      BREAK
    ENDIF
    IF Empty( nItem )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    IF lUp
      IF nItem == 1
        BREAK
      ENDIF
      aItem1 := aSouFiles[ nItem ]
      aItem2 := aSouFiles[ nItem - 1 ]
      IF nItem == 2
        IF !( aItem1[ SOUFILE_EXT ] $ '.PRG/.C' )
          MpmStop( 'You must select a PRG or C file as the main source file.' )
          BREAK
        ENDIF
        StatusLabel( 'Main changed', 0 )
      ENDIF
      aSouFiles[ nItem - 1 ] := aItem1
      aSouFiles[ nItem ]     := aItem2
      RefreshSource()
      Mpm.SourceList.Value := nItem - 1
    ELSE
      IF nItem == nItems
        BREAK
      ENDIF
      aItem1 := aSouFiles[ nItem ]
      aItem2 := aSouFiles[ nItem + 1 ]
      IF nItem == 1
        IF !( aItem2[ SOUFILE_EXT ] $ '.PRG/.C' )
          MpmStop( 'You must select a PRG or C file as the main source file.' )
          BREAK
        ENDIF
        StatusLabel( 'Main changed', 0 )
      ENDIF
      aSouFiles[ nItem + 1 ] := aItem1
      aSouFiles[ nItem ]     := aItem2
      RefreshSource()
      Mpm.SourceList.Value := nItem + 1
    ENDIF
    Mpm.SourceList.SetFocus
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE RefreshSource

  LOCAL nSouFiles := Len( aSouFiles )
  LOCAL nSouFile  := Mpm.SourceList.Value
  LOCAL aSouFile
  LOCAL cSouFile
  LOCAL aDepend
  LOCAL nDepFiles
  LOCAL nFile

  Mpm.SourceList.DeleteAllItems()
  FOR nFile := 1 TO nSouFiles
    aSouFile  := aSouFiles[ nFile ]
    cSouFile  := aSouFile[ SOUFILE_NAME ]
    aDepend   := aSouFile[SOUFILE_DEPEND]
    nDepFiles := Len( aDepend )
    Mpm.SourceList.AddItem( cSouFile + ;
      iif( Empty( nDepFiles ), '', ' [' + LTrim( Str( nDepFiles ) ) + ;
      ' dependent file' + iif( nDepFiles == 1, '', 's' ) + ']' ) )
  NEXT
  Mpm.SourceList.Value := Min( nSouFile, nSouFiles )

RETURN

//***************************************************************************

PROCEDURE LoadDependents

  LOCAL nSouFile := Mpm.SourceList.Value
  LOCAL aDepend
  LOCAL aSouFile
  LOCAL cSouFile
  LOCAL nDepFile
  LOCAL nDepFiles

  IF Empty( nSouFile )
    Mpm.lbFile.Value := 'No source file selected'
    Mpm.DependList.DeleteAllItems()
  ELSE
    aSouFile  := aSouFiles[ nSouFile ]
    cSouFile  := aSouFile[ SOUFILE_NAME ]
    aDepend   := aSouFile[SOUFILE_DEPEND]
    nDepFiles := Len( aDepend )
    Mpm.lbFile.Value := 'Dependent files for ' + cSouFile
    Mpm.DependList.DeleteAllItems()
    FOR nDepFile := 1 TO nDepFiles
      Mpm.DependList.AddItem( aDepend[ nDepFile ] )
    NEXT
  ENDIF

RETURN

//***************************************************************************

PROCEDURE AddDependents

  LOCAL cBaseFolder  := Mpm.BaseFolder.Value
  LOCAL cBaseFolderU := Upper( AddSlash( cBaseFolder ) )
  LOCAL nBaseFolderU := Len( cBaseFolderU )
  LOCAL nSouFile     := Mpm.SourceList.Value
  LOCAL aNewFiles
  LOCAL aDepend
  LOCAL aSouFile
  LOCAL aTypes
  LOCAL cNewFile
  LOCAL cSouExt
  LOCAL cSouFile
  LOCAL nFile
  LOCAL nFiles

  BEGIN SEQUENCE

    IF Empty( cBaseFolder )
      MpmStop( 'You must select a base folder.' )
      BREAK
    ENDIF
    IF Empty( aSouFiles )
      MpmStop( 'You must add at least one source file.' )
      BREAK
    ENDIF
    IF Empty( nSouFile )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    aSouFile := aSouFiles[ nSouFile ]
    cSouFile := aSouFile[ SOUFILE_NAME ]
    cSouExt  := aSouFile[ SOUFILE_EXT ]
    aDepend  := aSouFile[SOUFILE_DEPEND]
    IF !( cSouExt $ '.PRG/.C/.RC' )
      MpmStop( 'You may add dependents only for a PRG, C, or RC file.' )
      BREAK
    ENDIF

    DO CASE
    CASE cSouExt == '.PRG'
      aTypes := { ;
        { '(x)Harbour header files (*.ch)', '*.ch' },  ;
        { 'Window definition files (*.fmg)', '*.fmg' },  ;
        { '(x)Harbour source files (*.prg)', '*.prg' },  ;
        { 'C header files (*.h)', '*.h'  },  ;
        { 'All files (*.*)', '*.*'  }   }
    CASE cSouExt == '.C'
      aTypes := { ;
        { 'C header files (*.h)', '*.h'  },  ;
        { 'All files (*.*)', '*.*'  }   }
    OTHERWISE
      aTypes := { ;
        { 'All files (*.*)', '*.*'  }   }
    ENDCASE
    aNewFiles := GetFile( aTypes, ;
      'Select dependent files for ' + cSouFile, cBaseFolder, .Y. )

    IF Empty( aNewFiles )
      BREAK
    ENDIF

    ASort( aNewFiles,,, {| cRow1, cRow2| Upper( cRow1 ) <= Upper( cRow2 ) } )
    nFiles := Len( aNewFiles )
    FOR nFile := 1 TO nFiles
      cNewFile := AllTrim( aNewFiles[ nFile ] )
      IF Left( Upper( cNewFile ), nBaseFolderU ) == cBaseFolderU
        cNewFile := SubStr( cNewFile, nBaseFolderU + 1 )
      ENDIF
      IF Empty( AScan( aDepend, {| cRow| Upper( cRow ) == Upper( cNewFile ) } ) )
        Mpm.DependList.AddItem( cNewFile )
      ENDIF
    NEXT
    StoreDependents()

  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE RemoveDependent

  LOCAL nSouFile  := Mpm.SourceList.Value
  LOCAL nDepFile  := Mpm.DependList.Value
  LOCAL nDepFiles := Mpm.DependList.ItemCount
  LOCAL aSouFile
  LOCAL cSouFile

  BEGIN SEQUENCE
    IF Empty( nSouFile )
      MpmStop( 'You must select a source file.' )
      BREAK
    ENDIF
    IF Empty( nDepFiles )
      MpmStop( 'You must add at least one dependent file.' )
      BREAK
    ENDIF
    IF Empty( nDepFile )
      MpmStop( 'You must select a dependent file.' )
      BREAK
    ENDIF
    aSouFile := aSouFiles[ nSouFile ]
    cSouFile := aSouFile[ SOUFILE_NAME ]
    IF !MpmYesNo( 'Remove ' + ;
      Mpm.DependList.Item( nDepFile ) + ' as a dependent for ' + cSouFile + '?' )
      BREAK
    ENDIF
    Mpm.DependList.DeleteItem( nDepFile )
    Mpm.DependList.Value := Min( nDepFile, nDepFiles - 1 )
    StoreDependents()
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE EditDependent

  LOCAL cFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL nFile   := Mpm.DependList.Value
  LOCAL nFiles  := Mpm.DependList.ItemCount
  LOCAL cFile

  BEGIN SEQUENCE
    IF Empty( nFiles )
      MpmStop( 'You must add at least one dependent file.' )
      BREAK
    ENDIF
    IF Empty( nFile )
      MpmStop( 'You must select a dependent file.' )
      BREAK
    ENDIF
    IF Empty( cEditorExe )
      MpmStop( 'You must select a program editor.' )
      BREAK
    ENDIF
    IF !File( cEditorExe ) .AND. !FileInPath( cEditorExe )
      MpmStop( 'Cannot find program editor ' + cEditorExe + '.' )
      BREAK
    ENDIF
    cFile := AddQuote( cFolder + Mpm.DependList.Item( nFile ) )
    MpmRun( cEditorExe, cFile, .Y. )
    StatusLabel()
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE MoveDependent( lUp )

  LOCAL cItem1
  LOCAL cItem2
  LOCAL nItem  := Mpm.DependList.Value
  LOCAL nItems := Mpm.DependList.ItemCount

  BEGIN SEQUENCE
    IF nItems < 2
      MpmStop( 'You must add at least two dependent files.' )
      BREAK
    ENDIF
    IF Empty( nItem )
      MpmStop( 'You must select a dependent file.' )
      BREAK
    ENDIF
    IF lUp
      IF nItem == 1
        BREAK
      ENDIF
      cItem1 := Mpm.DependList.Item( nItem )
      cItem2 := Mpm.DependList.Item( nItem - 1 )
      Mpm.DependList.Item( nItem - 1 ) := cItem1
      Mpm.DependList.Item( nItem )     := cItem2
      Mpm.DependList.Value          := nItem - 1
    ELSE
      IF nItem == nItems
        BREAK
      ENDIF
      cItem1 := Mpm.DependList.Item( nItem )
      cItem2 := Mpm.DependList.Item( nItem + 1 )
      Mpm.DependList.Item( nItem + 1 ) := cItem1
      Mpm.DependList.Item( nItem )     := cItem2
      Mpm.DependList.Value          := nItem + 1
    ENDIF
    StoreDependents()
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE StoreDependents

  LOCAL nSouFile := Mpm.SourceList.Value
  LOCAL aSouFile
  LOCAL aDepend
  LOCAL nDepFiles
  LOCAL nDepFile

  IF !Empty( nSouFile )
    aSouFile  := aSouFiles[ nSouFile ]
    aDepend   := aSouFile[ SOUFILE_DEPEND ]
    nDepFiles := Mpm.DependList.ItemCount
    ASize( aDepend, 0 )
    FOR nDepFile := 1 TO nDepFiles
      AAdd( aDepend, Mpm.DependList.Item( nDepFile ) )
    NEXT
    RefreshSource()
    StatusLabel()
  ENDIF

RETURN

//***************************************************************************

PROCEDURE AddLibFiles( cType )

  LOCAL cBaseFolder  := Mpm.BaseFolder.Value
  LOCAL cBaseFolderU := Upper( AddSlash( cBaseFolder ) )
  LOCAL nBaseFolderU := Len( cBaseFolderU )
  LOCAL lXHarbour    := Mpm.UseXHarbour.Value
  LOCAL aCurFiles    := {}
  LOCAL aNewFiles
  LOCAL aTypes
  LOCAL cLibFolder
  LOCAL cLibLabel
  LOCAL cNewFile
  LOCAL nFile

  BEGIN SEQUENCE

    FOR nFile := 1 TO Mpm.LibList.ItemCount
      AAdd( aCurFiles, AllTrim( Mpm.LibList.Item( nFile ) ) )
    NEXT

    DO CASE
    CASE cType == 'H'
      cLibLabel  := 'additional ' + iif( lXHarbour, 'x', '' ) + 'Harbour libraries'
      cLibFolder := ;
        AddSlash( iif( lXHarbour, cXHarbourFolder, cOHarbourFolder ) ) + 'LIB'
      aTypes     := { { 'Library files (*.lib)', '*.lib' } }
    CASE cType == 'M'
      cLibLabel  := 'additional MiniGui libraries'
      cLibFolder := AddSlash( cMiniGuiFolder ) + iif( lXHarbour, 'XLIB', 'LIB' )
      aTypes     := { { 'Library files (*.lib)', '*.lib' } }
    CASE cType == 'O'
      cLibLabel  := 'other additional libraries or object files'
      cLibFolder := Mpm.BaseFolder.Value
      aTypes     := { ;
        { 'Library files (*.lib)', '*.lib' }, ;
        { '(x)Harbour or C object files (*.obj)', '*.obj' }, ;
        { 'Resource compiler object files (*.res)', '*.res' }  }
    ENDCASE
    aNewFiles := GetFile( aTypes, 'Select ' + cLibLabel, cLibFolder, .Y. )

    IF Empty( aNewFiles )
      BREAK
    ENDIF

    ASort( aNewFiles,,, {| cRow1, cRow2| Upper( cRow1 ) <= Upper( cRow2 ) } )
    FOR nFile := 1 TO Len( aNewFiles )
      cNewFile := AllTrim( aNewFiles[ nFile ] )
      IF Left( Upper( cNewFile ), nBaseFolderU ) == cBaseFolderU
        cNewFile := SubStr( cNewFile, nBaseFolderU + 1 )
      ENDIF
      IF Empty( AScan( aCurFiles, {| cRow| Upper( cRow ) == Upper( cNewFile ) } ) )
        Mpm.LibList.AddItem( cNewFile )
      ENDIF
    NEXT

    StatusLabel()

  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE RemoveLib

  LOCAL nFile  := Mpm.LibList.Value
  LOCAL nFiles := Mpm.LibList.ItemCount

  BEGIN SEQUENCE
    IF Empty( nFiles )
      MpmStop( 'You must add at least one library or object file.' )
      BREAK
    ENDIF
    IF Empty( nFile )
      MpmStop( 'You must select a library or object file.' )
      BREAK
    ENDIF
    IF !MpmYesNo( 'Remove ' + Mpm.LibList.Item( nFile ) + '?' )
      BREAK
    ENDIF
    Mpm.LibList.DeleteItem( nFile )
    StatusLabel()
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE MoveLib( lUp )

  LOCAL cItem1
  LOCAL cItem2
  LOCAL nItem  := Mpm.LibList.Value
  LOCAL nItems := Mpm.LibList.ItemCount

  BEGIN SEQUENCE
    IF nItems < 2
      MpmStop( 'You must add at least two libraries or object files.' )
      BREAK
    ENDIF
    IF Empty( nItem )
      MpmStop( 'You must select a library or object file.' )
      BREAK
    ENDIF
    IF lUp
      IF nItem == 1 .OR. nItems == 1
        BREAK
      ENDIF
      cItem1 := Mpm.LibList.Item( nItem )
      cItem2 := Mpm.LibList.Item( nItem - 1 )
      Mpm.LibList.Item( nItem - 1 ) := cItem1
      Mpm.LibList.Item( nItem )     := cItem2
      Mpm.LibList.Value          := nItem - 1
    ELSE
      IF nItem == nItems
        BREAK
      ENDIF
      cItem1 := Mpm.LibList.Item( nItem )
      cItem2 := Mpm.LibList.Item( nItem + 1 )
      Mpm.LibList.Item( nItem + 1 ) := cItem1
      Mpm.LibList.Item( nItem )     := cItem2
      Mpm.LibList.Value          := nItem + 1
    ENDIF
  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE Build

  LOCAL lDebug         := Mpm.Debug.Value
  LOCAL lRebuild       := Mpm.Rebuild.Value
  LOCAL lHide          := Mpm.HideBuild.Value
  LOCAL lXHarbour      := Mpm.UseXHarbour.Value
  LOCAL lGenLib        := Mpm.GenLib.Value
  LOCAL lXp            := IsXpPlus()
  LOCAL lBlank         := BlankTest()
  LOCAL lShow          := !lHide .OR. ( !lXp .AND. ( lBlank .OR. lXHarbour ) )
  LOCAL cProjFolder    := AddSlash( Mpm.BaseFolder.Value )
  LOCAL cObjFolder     := cProjFolder + iif( lDebug, 'Deb\', 'Obj\' )
  LOCAL cHarbourFolder := iif( lXHarbour, cXHarbourFolder, cOHarbourFolder )
  LOCAL cMpmFolder     := GetSub( GETEXEFILENAME() )
  LOCAL cRBUILD        := AddQuote( cMpmFolder + '\mpmbuild.exe' )
  LOCAL cREDIR         := AddQuote( cMpmFolder + '\cmdredir.exe' )
  LOCAL cHRB           := AddQuote( cHarbourFolder + '\Bin\harbour.exe' )
  LOCAL cBCC           := AddQuote( cBccFolder + '\Bin\bcc32.exe' )
  LOCAL cBRC           := AddQuote( cBccFolder + '\Bin\brc32.exe' )
  LOCAL cILINK         := AddQuote( cBccFolder + '\Bin\ilink32.exe' )
  LOCAL cTLIB          := AddQuote( cBccFolder + '\Bin\tlib.exe' )
  LOCAL cLocFile       := AddSlash( GetTempFolder() ) + '_MpmBuild.txt'
  LOCAL nFiles         := Len( aSouFiles )
  LOCAL cBatFile
  LOCAL cCldFile
  LOCAL nExit

  BEGIN SEQUENCE

    IF lProcess .AND. !MpmYesNo( 'Start another build process?' )
      BREAK
    ENDIF
    IF Empty( cProjFolder ) .AND. Empty( nFiles )
      MpmStop( 'You must start a project before building it.' )
      BREAK
    ENDIF
    IF Empty( cProjFolder )
      MpmStop( 'You must select a base folder.' )
      BREAK
    ENDIF
    IF Empty( nFiles )
      MpmStop( 'You must add at least one source file.' )
      BREAK
    ENDIF
    IF Empty( cBccFolder )
      MpmStop( 'You must specify the BCC folder.' )
      BREAK
    ENDIF
    IF Empty( cMiniGuiFolder )
      MpmStop( 'You must specify the MiniGui folder.' )
      BREAK
    ENDIF
    IF Empty( cHarbourFolder )
      MpmStop( 'You must specify the ' + ;
        iif( lXHarbour, 'x', '' ) + 'Harbour folder.' )
      BREAK
    ENDIF
    IF !File( cRBUILD )
      MpmStop( 'Cannot find build process program file ' + cRBUILD )
      BREAK
    ENDIF
    IF !IsXpPlus() .AND. !File( cREDIR )
      MpmStop( 'Cannot find redirection program file ' + cREDIR )
      BREAK
    ENDIF
    IF !File( cHRB )
      MpmStop( 'Cannot find ' + iif( lXHarbour, 'x', '' ) + 'Harbour compiler ' + ;
        cHRB )
      BREAK
    ENDIF
    IF !File( cBCC )
      MpmStop( 'Cannot find BCC compiler ' + cBCC )
      BREAK
    ENDIF
    IF !File( cBRC )
      MpmStop( 'Cannot find resource compiler ' + cBRC )
      BREAK
    ENDIF
    IF !lGenLib .AND. !File( cILINK )
      MpmStop( 'Cannot find linker ' + cILINK )
      BREAK
    ENDIF
    IF lGenLib .AND. !File( cTLIB )
      MpmStop( 'Cannot find library manager ' + cTLIB )
      BREAK
    ENDIF

    StatusLabel()
    SETCURRENTFOLDER( cProjFolder )
    DELETE FILE ( cProjFolder + '_Build.log' )
    DELETE FILE ( cProjFolder + '_Build.rsp' )
    DELETE FILE ( cProjFolder + '_End.txt' )

    CREATEFOLDER( cObjFolder )
    cBatFile := cProjFolder + '_Build.bat'
    IF !MemoWrite( cLocFile, cBatFile )
      MpmStop( 'Cannot write ' + cLocFile + '.' )
      BREAK
    ENDIF
    IF !MemoWrite( cBatFile, BuildBatch( ;
      lDebug, lRebuild, lXHarbour, lGenLib, lXp, lShow, ;
      cProjFolder, cHarbourFolder, cREDIR, cHRB, cBCC, cBRC, cILINK, cTLIB ) )
      MpmStop( 'Cannot write ' + cBatFile + '.' )
      BREAK
    ENDIF

    cCldFile := cProjFolder + 'Init.mgd'
    IF lDebug .AND. !lGenLib .AND. !File( cCldFile )
      MemoWrite( cCldFile, 'Screen Size 50 80' )
    ENDIF
    cCldFile := cProjFolder + 'Init.cld'
    IF lDebug .AND. !lGenLib .AND. !File( cCldFile )
      MemoWrite( cCldFile, 'Options NoRunAtStartup' )
    ENDIF

    Mpm.Log.Value := ''
    lProcess := .Y.
    lGo      := .Y.
    nExit    := WaitRunTerm( AddQuote( cRBUILD ),,, {|| BuildWait() }, 500 )

    IF nExit < -1 .OR. nExit > 255
      DO CASE
      CASE nExit == MPMB_NOLOCFILE
        MpmStop( 'Cannot find build location file ' + cLocFile + '.' )
      CASE nExit == MPMB_NOLOCREAD
        MpmStop( 'Cannot read build location file ' + cLocFile + '.' )
      CASE nExit == MPMB_NOBUILDFILE
        MpmStop( 'Cannot find build file ' + cBatFile + '.' )
      OTHERWISE
        MpmStop( 'Build run error ' + LTrim( Str( nExit ) ) )
      ENDCASE
    ENDIF

  END SEQUENCE

RETURN

//***************************************************************************

FUNCTION BuildBatch( ;
  lDebug, lRebuild, lXHarbour, lGenLib, lXp, lShow, ;
  cProjFolder, cHarbourFolder, cREDIR, cHRB, cBCC, cBRC, cILINK, cTLIB )

  LOCAL aWarnings      := { '', '/w /es2 ', '/w2 /es2 ', '/w3 /es2 ' }
  LOCAL nExeType       := Mpm.ExeType.Value
  LOCAL lConsole       := nExeType == 2 .OR. nExeType == 3 .OR. lDebug
  LOCAL lGui           := nExeType == 1 .OR. nExeType == 3
  LOCAL cMainSuffix    := iif( lDebug, '_deb', '' )
  LOCAL cMainExt       := iif( lGenLib, '.lib', '.exe' )
  LOCAL nSouFiles      := Len( aSouFiles )
  LOCAL nLibFiles      := Mpm.LibList.ItemCount
  LOCAL cHarbourLib    := cHarbourFolder + '\Lib'
  LOCAL cMiniGuiLib    := cMiniGuiFolder + iif( lXHarbour, '\XLib', '\Lib' )
  LOCAL cINCDIRS       := ;
    AddQuote( cHarbourFolder + '\Include' ) + ';' + ;
    AddQuote( cMiniGuiFolder + '\Include' )
  LOCAL cBCCLIB        := cBccFolder + '\Lib\'
  LOCAL cHRBLIB        := AddSlash( cHarbourLib )
  LOCAL cMGLIB         := AddSlash( cMiniGuiLib )
  LOCAL cMGRES         := cMiniGuiFolder + '\Resources\'
  LOCAL cOBJDIR        := iif( lDebug, 'Deb\', 'Obj\' )
  LOCAL cOBJBASE
  LOCAL cHRBFLAGS      := iif( lGenLib, '/n1 ', '/n ' ) + iif( lDebug, '/b ', '' ) + ;
    iif( Mpm.GenPpo.Value, '/p ', '' ) + ;
    aWarnings[ Mpm.Warnings.Value ] + Mpm.PrgParams.Value + ;
    ' /i' + cINCDIRS
  LOCAL cMODEFLAG      := iif( lConsole .AND. lGui, ' /d_MIXEDMODE_', '' )
  LOCAL cOPTFLAGS      := '-d -6 -O2 -OS -Ov -Oi -Oc'
  LOCAL cBCCFLAGS      := '-c ' + cOPTFLAGS + ' -tW' + ;
    ' -L' + AddQuote( cBccFolder + '\Lib' ) + ;
    ' ' + Mpm.CParams.Value + ;
    ' -I' + AddQuote( cBccFolder + '\Include' ) + ';' + cINCDIRS
  LOCAL cHLog          := iif( lShow, '', ;
    iif( lXp, '', cREDIR + ' -o _Build.log -eo ' ) )
  LOCAL cTLog          := iif( lShow, '', ;
    iif( lXp, ' > _Build.log 2>&1', '' ) )
  LOCAL cLLog          := ' > _Build.log'
  LOCAL cRsp           := '_Build.rsp'
  LOCAL cErr           := 'if errorlevel 1 goto err'
  LOCAL cOut           := '@echo off' + CRLF
  LOCAL aDepend
  LOCAL aFile
  LOCAL aSeaFiles
  LOCAL cBase
  LOCAL cFile
  LOCAL cFileSub
  LOCAL cExt
  LOCAL cMainBase
  LOCAL nDepFiles
  LOCAL nFile
  LOCAL nSeaFile

  cMainBase := aSouFiles[ 1 ][ SOUFILE_BASE ] + cMainSuffix
  aSeaFiles := {}
  FOR nFile := 1 TO nSouFiles
    aFile     := aSouFiles[ nFile ]
    cFile     := Upper( aFile[ SOUFILE_NAME ] )
    aDepend   := aFile[SOUFILE_DEPEND]
    nDepFiles := Len( aDepend )
    IF Empty( AScan( aSeaFiles, {| cRow| Upper( cRow ) == cFile } ) )
      AAdd( aSeaFiles, cFile )
    ENDIF
    FOR nSeaFile := 1 TO nDepFiles
      cFile := Upper( aDepend[ nSeaFile ] )
      IF Empty( AScan( aSeaFiles, {| cRow| Upper( cRow ) == cFile } ) )
        AAdd( aSeaFiles, cFile )
      ENDIF
    NEXT
  NEXT
  FOR nFile := 1 TO nLibFiles
    cFile := AllTrim( Mpm.LibList.Item( nFile ) )
    IF Empty( AScan( aSeaFiles, {| cRow| Upper( cRow ) == cFile } ) )
      AAdd( aSeaFiles, cFile )
    ENDIF
  NEXT

  IF DateTest( lRebuild, cProjFolder, cMainBase + cMainExt, aSeaFiles )

    FOR nFile := 1 TO nSouFiles

      aFile     := aSouFiles[ nFile ]
      cFile     := aFile[ SOUFILE_NAME ]
      cBase     := aFile[ SOUFILE_BASE ]
      cExt      := aFile[ SOUFILE_EXT ]
      aDepend   := aFile[SOUFILE_DEPEND]
      nDepFiles := Len( aDepend )

      DO CASE
      CASE cExt == '.PRG'

        aSeaFiles := { cFile }
        FOR nSeaFile := 1 TO nDepFiles
          AAdd( aSeaFiles, aDepend[ nSeaFile ] )
        NEXT
        FOR nSeaFile := 1 TO nSouFiles
          IF aSouFiles[ nSeaFile ][ SOUFILE_EXT ] $ '.CH/.H/.FMG'
            AAdd( aSeaFiles, aSouFiles[ nSeaFile ][ SOUFILE_NAME ] )
          ENDIF
        NEXT
        cOBJBASE := cOBJDIR + cBase
        cFileSub := GetSub( cFile )
        IF DateTest( lRebuild, cProjFolder, cOBJBASE + '.obj', aSeaFiles )
          cOut += CRLF
          cOut += cHLog + cHRB + ' ' + ;
            cHRBFLAGS + ';' + iif( Empty( cFileSub ), '.', cFileSub ) + ;
            iif( nFile == 1, cMODEFLAG, '' ) + ;
            ' -o' + AddQuote( cOBJBASE + '.c' ) + ' ' + ;
            AddQuote( cFile ) + cTLog + CRLF
          cOut += cErr + CRLF
          cOut += CRLF
          cOut += cHLog + cBCC + ' ' + cBCCFLAGS + ;
            ' -o' + AddQuote( cOBJBASE + '.obj' ) + ;
            ' ' + AddQuote( cOBJBASE + '.c' ) + cTLog + CRLF
          cOut += cErr + CRLF
        ENDIF

      CASE cExt == '.RC'

        aSeaFiles := { cFile }
        FOR nSeaFile := 1 TO nDepFiles
          AAdd( aSeaFiles, aDepend[ nSeaFile ] )
        NEXT
        cOBJBASE := cOBJDIR + cBase
        IF DateTest( lRebuild, cProjFolder, cOBJBASE + '.res', aSeaFiles )
          cOut += CRLF
          cOut += cHLog + cBRC + ' -d__BORLANDC__ -r ' + ;
            '-fo' + AddQuote( cOBJBASE + '.res' ) + ' ' + AddQuote( cFile ) + ;
            cTLog + CRLF
          cOut += cErr + CRLF
        ENDIF

      CASE cExt == '.C'

        aSeaFiles := { cFile }
        FOR nSeaFile := 1 TO nDepFiles
          AAdd( aSeaFiles, aDepend[ nSeaFile ] )
        NEXT
        FOR nSeaFile := 1 TO nSouFiles
          IF aSouFiles[ nSeaFile ][ SOUFILE_EXT ] == '.H'
            AAdd( aSeaFiles, aSouFiles[ nSeaFile ][ SOUFILE_NAME ] )
          ENDIF
        NEXT
        cOBJBASE := cOBJDIR + cBase
        cFileSub := GetSub( cFile )
        IF DateTest( lRebuild, cProjFolder, cOBJBASE + '.obj', aSeaFiles )
          cOut += CRLF
          cOut += cHLog + cBCC + ' ' + ;
            cBCCFLAGS + ';' + iif( Empty( cFileSub ), '.', cFileSub ) + ;
            ' -o' + AddQuote( cOBJBASE + '.obj' ) + ' ' + AddQuote( cFile ) + ;
            cTLog + CRLF
          cOut += cErr + CRLF
        ENDIF

      ENDCASE

    NEXT

    IF lGenLib

      cOut += CRLF
      cOut += 'del ' + AddQuote( cMainBase + cMainExt ) + CRLF
      FOR nFile := 1 TO nSouFiles
        IF aSouFiles[ nFile ][ SOUFILE_EXT ] $ '.PRG/.C'
          nSeaFile := nFile
        ENDIF
      NEXT
      FOR nFile := 1 TO nSouFiles
        aFile := aSouFiles[ nFile ]
        IF aFile[ SOUFILE_EXT ] $ '.PRG/.C'
          cOBJBASE := cOBJDIR + aFile[ SOUFILE_BASE ]
          cOut     += 'echo + ' + AddQuote( cOBJBASE + '.obj' ) + ;
            iif( nFile == nSeaFile, ' ', ' ^& ' ) + ;
            iif( nFile == 1, '> ', '>> ' ) + cRsp + CRLF
        ENDIF
      NEXT
      cOut += cHLog + cTLIB + ' ' + cMainBase + cMainExt + ;
        ' @' + cRsp + cTLog + CRLF
      cOut += cErr + CRLF

    ELSE

      cOut += CRLF
      FOR nFile := 1 TO nSouFiles
        aFile := aSouFiles[ nFile ]
        IF aFile[ SOUFILE_EXT ] $ '.PRG/.C'
          cOBJBASE := cOBJDIR + aFile[ SOUFILE_BASE ]
          cOut     += 'echo ' + AddQuote( cOBJBASE + '.obj' ) + ;
            ' + ' + iif( nFile == 1, '> ', '>> ' ) + cRsp + CRLF
        ENDIF
      NEXT
      FOR nFile := 1 TO nLibFiles
        cFile := AllTrim( Mpm.LibList.Item( nFile ) )
        IF Upper( GetExt( cFile ) ) == '.OBJ'
          cOut  += 'echo ' + AddQuote( cFile ) + ' + >> ' + cRsp + CRLF
        ENDIF
      NEXT
      cOut += 'echo ' + AddQuote( cBCCLIB + 'c0w32.obj' ) + ', + >> ' + cRsp + CRLF
      cOut += 'echo ' + AddQuote( cMainBase + cMainExt ) + ',' + ;
        AddQuote( cMainBase + '.map' ) + ', + >> ' + cRsp + CRLF
      IF lDebug
        cOut += 'echo ' + AddQuote( cMGLIB + 'dbginit.obj' )   + ' + >> ' + cRsp + CRLF
      ENDIF
      IF lGui
        cOut += 'echo ' + AddQuote( cMGLIB + 'tsbrowse.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cMGLIB + 'propgrid.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cMGLIB + 'minigui.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'dll.lib' )      + ' + >> ' + cRsp + CRLF
      ENDIF
      IF lConsole
        cOut += 'echo ' + AddQuote( cHRBLIB + 'gtwin.lib' )    + ' + >> ' + cRsp + CRLF
      ENDIF
      IF lGui
        cOut += 'echo ' + AddQuote( cHRBLIB + 'gtgui.lib' )    + ' + >> ' + cRsp + CRLF
      ENDIF
      IF lXHarbour
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rtl.lib' )      + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'vm.lib' )       + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'lang.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'codepage.lib' ) + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'macro.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rdd.lib' )      + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'dbfntx.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'dbfcdx.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'dbffpt.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbsix.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'common.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'debug.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'pp.lib' )       + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'pcrepos.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'ct.lib' )       + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'libmisc.lib' )  + ' + >> ' + cRsp + CRLF
      ELSE
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbcplr.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbrtl.lib' )    + ' + >> ' + cRsp + CRLF
        IF Mpm.MultiThread.Value
          cOut += 'echo ' + AddQuote( cHRBLIB + 'hbvmmt.lib' )   + ' + >> ' + cRsp + CRLF
        ELSE
          cOut += 'echo ' + AddQuote( cHRBLIB + 'hbvm.lib' )     + ' + >> ' + cRsp + CRLF
        ENDIF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hblang.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbcpage.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbmacro.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbrdd.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbhsx.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rddntx.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rddcdx.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rddfpt.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbsix.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbcommon.lib' ) + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbdebug.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbpp.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbpcre.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbct.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbmisc.lib' )   + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbole.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbwin.lib' )    + ' + >> ' + cRsp + CRLF
      ENDIF
      IF lGui
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbprinter.lib' )  + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'socket.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'miniprint.lib' )  + ' + >> ' + cRsp + CRLF
      ENDIF
      IF Mpm.ZipLib.Value
        cOut += 'echo ' + AddQuote( cHRBLIB + 'ziparchive.lib' ) + ' + >> ' + cRsp + CRLF
      ENDIF
      IF Mpm.OdbcLib.Value
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbodbc.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'odbc32.lib' )     + ' + >> ' + cRsp + CRLF
      ENDIF
      IF Mpm.AdsLib.Value
        cOut += 'echo ' + AddQuote( cHRBLIB + 'rddads.lib' )     + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'ace32.lib' )      + ' + >> ' + cRsp + CRLF
      ENDIF
      IF Mpm.MySqlLib.Value
        cOut += 'echo ' + AddQuote( cHRBLIB + 'hbmysql.lib' )    + ' + >> ' + cRsp + CRLF
        cOut += 'echo ' + AddQuote( cHRBLIB + 'libmysql.lib' )   + ' + >> ' + cRsp + CRLF
      ENDIF
      FOR nFile := 1 TO nLibFiles
        cFile := AllTrim( Mpm.LibList.Item( nFile ) )
        IF Upper( GetExt( cFile ) ) == '.LIB'
          cOut  += 'echo ' + AddQuote( cFile ) + ' + >> ' + cRsp + CRLF
        ENDIF
      NEXT
      IF Mpm.MultiThread.Value
        cOut += 'echo ' + AddQuote( cBCCLIB + 'cw32mt.lib' )   + ' + >> ' + cRsp + CRLF
      ELSE
        cOut += 'echo ' + AddQuote( cBCCLIB + 'cw32.lib' )     + ' + >> ' + cRsp + CRLF
      ENDIF
      cOut += 'echo ' + AddQuote( cBCCLIB + 'PSDK\msimg32.lib' ) + ' + >> ' + cRsp + CRLF
      cOut += 'echo ' + AddQuote( cBCCLIB + 'import32.lib' ) + ', >> '  + cRsp + CRLF
      FOR nFile := 1 TO nSouFiles
        aFile := aSouFiles[ nFile ]
        IF aFile[ SOUFILE_EXT ] == '.RC'
          cOBJBASE := cOBJDIR + aFile[ SOUFILE_BASE ]
          cOut     += 'echo ' + AddQuote( cOBJBASE + '.res' ) + ' + >> ' + cRsp + CRLF
        ENDIF
      NEXT
      FOR nFile := 1 TO nLibFiles
        cFile := AllTrim( Mpm.LibList.Item( nFile ) )
        IF Upper( GetExt( cFile ) ) == '.RES'
          cOut  += 'echo ' + AddQuote( cFile ) + ' + >> ' + cRsp + CRLF
        ENDIF
      NEXT
      cOut += 'echo ' + AddQuote( cMGRES + 'hbprinter.res' ) + ' + >> ' + cRsp + CRLF
      cOut += 'echo ' + AddQuote( cMGRES + 'miniprint.res' ) + ' + >> ' + cRsp + CRLF
      cOut += 'echo ' + AddQuote( cMGRES + 'minigui.res' )   + '   >> ' + cRsp + CRLF
      cOut += CRLF

      cOut += cHLog + cILINK + ' -x -Gn -Tpe ' + iif( lConsole, '-ap', '-aa' ) + ;
        ' -L' + AddQuote( DelSlash( cBCCLIB ) ) + ' @' + cRsp + cTLog + CRLF
      cOut += cErr + CRLF
      cOut += 'del ' + AddQuote( cMainBase + '.tds' ) + CRLF

    ENDIF

  ENDIF

  cOut += CRLF
  cOut += 'echo success > _End.txt' + CRLF
  cOut += 'echo.' + cLLog + CRLF
  cOut += 'goto end' + CRLF
  cOut += CRLF
  cOut += ':err' + CRLF
  cOut += 'echo error > _End.txt' + CRLF
  IF lShow
    cOut += 'pause' + CRLF
  ENDIF
  cOut += 'goto end' + CRLF
  cOut += CRLF
  cOut += ':end' + CRLF

RETURN cOut

//***************************************************************************

FUNCTION DateTest( lRebuild, cProjFolder, cTargFile, aDepFiles )

  LOCAL aDir   := Directory( cProjFolder + cTargFile )
  LOCAL nFiles := Len( aDepFiles )
  LOCAL lTest  := .N.
  LOCAL cFile
  LOCAL nFile
  LOCAL nTargDate

  IF lRebuild .OR. Empty( aDir )
    lTest := .Y.
  ELSE
    nTargDate := DateTime( aDir[ 1 ][ F_DATE ], aDir[ 1 ][ F_TIME ] )
    FOR nFile := 1 TO nFiles
      cFile := aDepFiles[ nFile ]
      aDir  := Directory( iif( ':' $ cFile, cFile, cProjFolder + cFile ) )
      IF Empty( aDir )
        lTest := .Y.
      ELSE
        IF DateTime( aDir[ 1 ][ F_DATE ], aDir[ 1 ][ F_TIME ] ) > nTargDate
          lTest := .Y.
        ENDIF
      ENDIF
    NEXT
  ENDIF

RETURN lTest

//***************************************************************************

FUNCTION BuildWait

  DO EVENTS

RETURN lGo

//***************************************************************************

PROCEDURE StopBuild

  BEGIN SEQUENCE
    IF !lProcess
      MpmStop( 'No build process is currently running.' )
      BREAK
    ENDIF
    IF !IsXpPlus()
      MpmStop( 'The stop feature requires Windows XP or higher.' )
      BREAK
    ENDIF
    IF !MpmYesNo( 'Stop build process?' )
      BREAK
    ENDIF
    lGo := .N.
  END SEQUENCE

RETURN

//***************************************************************************

FUNCTION BlankTest()

  LOCAL lXHarbour      := Mpm.UseXHarbour.Value
  LOCAL cHarbourFolder := iif( lXHarbour, cXHarbourFolder, cOHarbourFolder )
  LOCAL cProjFolder    := AllTrim( Mpm.BaseFolder.Value )
  LOCAL cMpmFolder     := GetSub( GETEXEFILENAME() )
  LOCAL nSouFiles      := Len( aSouFiles )
  LOCAL cSpace := ' '
  LOCAL lBlank := ;
    cSpace $ AllTrim( cBccFolder )     .OR. ;
    cSpace $ AllTrim( cHarbourFolder ) .OR. ;
    cSpace $ AllTrim( cMiniGuiFolder ) .OR. ;
    cSpace $ AllTrim( cProjFolder )    .OR. ;
    cSpace $ AllTrim( cMpmFolder )
  LOCAL nFile

  FOR nFile := 1 TO nSouFiles
    IF cSpace $ aSouFiles[ nFile ][ SOUFILE_NAME ]
      lBlank := .Y.
    ENDIF
  NEXT

RETURN lBlank

//***************************************************************************

PROCEDURE Execute

  LOCAL lDebug      := Mpm.Debug.Value
  LOCAL lMainSou    := !Empty( aSouFiles )
  LOCAL cProjFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL cMainSou    := iif( lMainSou, aSouFiles[ 1 ][ SOUFILE_BASE ], '' )
  LOCAL cMainSuffix := iif( lDebug, '_deb', '' )
  LOCAL cMainFile   := cProjFolder + cMainSou + cMainSuffix + '.exe'
  LOCAL cParams     := AllTrim( Mpm.ExeParams.Value )

  BEGIN SEQUENCE

    IF Mpm.GenLib.Value
      MpmStop( 'You are building a library, which cannot be directly run.' )
      BREAK
    ENDIF
    IF Empty( cProjFolder ) .OR. Empty( cMainSou )
      MpmStop( 'You must start and build a project before running it.' )
      BREAK
    ENDIF
    IF !File( cMainFile )
      MpmStop( 'Executable file does not exist.  ' + ;
        'You must successfully build the project.' )
      BREAK
    ENDIF

    SetCurrentFolder( cProjFolder )
    MpmRun( cMainFile, cParams, .Y. )

  END SEQUENCE

RETURN

//***************************************************************************

PROCEDURE Cleanup

  LOCAL lMainSou    := !Empty( aSouFiles )
  LOCAL cProjFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL cMainSou    := iif( lMainSou, aSouFiles[ 1 ][ SOUFILE_BASE ], '' )
  LOCAL nFiles      := Len( aSouFiles )
  LOCAL aFiles
  LOCAL nFile

  StatusLabel( 'Cleaning up', 2 )
  DELETE FILE ( cProjFolder + cMainSou + '_deb.exe' )
  DELETE FILE ( cProjFolder + '_Build.bat' )
  DELETE FILE ( cProjFolder + '_Build.log' )
  DELETE FILE ( cProjFolder + '_Build.rsp' )
  DELETE FILE ( cProjFolder + '_End.txt'  )
  FOR nFile := 1 TO nFiles
    DELETE FILE ( cProjFolder + DelExt( aSouFiles[ nFile ][ SOUFILE_NAME ] ) + '.ppo' )
  NEXT
  aFiles := Directory( cProjFolder + 'Deb\*.*' )
  nFiles := Len( aFiles )
  FOR nFile := 1 TO nFiles
    DELETE FILE ( cProjFolder + 'Deb\' + aFiles[ nFile ][ F_NAME ] )
  NEXT
  aFiles := Directory( cProjFolder + 'Obj\*.*' )
  nFiles := Len( aFiles )
  FOR nFile := 1 TO nFiles
    DELETE FILE ( cProjFolder + 'Obj\' + aFiles[ nFile ][ F_NAME ] )
  NEXT
  REMOVEFOLDER( cProjFolder + 'Deb' )
  REMOVEFOLDER( cProjFolder + 'Obj' )
  StatusLabel( 'Cleanup completed', 0 )

RETURN

//***************************************************************************

PROCEDURE SetEnvironment( lInit )

  LOCAL cFolder
  LOCAL cFileName
  LOCAL lAssocMpm := IsAssociated( '.mpm', lInit )
  LOCAL lAssocPrg := IsAssociated( '.prg', lInit )
  LOCAL lAssocC   := IsAssociated( '.c', lInit )

  DEFINE WINDOW Environment ;
    AT     nEnvirRow, nEnvirCol ;
    WIDTH  nEnvirWidth ;
    HEIGHT nEnvirHeight ;
    TITLE 'Environment settings' ;
    ICON  'MAIN' ;
    MODAL ;
    ON INIT EnvironmentSize() ;
    ON MOVE EnvironmentSize() ;
    ON SIZE EnvironmentSize()

    DEFINE LABEL lbBccFolder
      ROW   10
      COL   10
      VALUE 'BCC folder'
    END LABEL

    DEFINE TEXTBOX BccFolder
      ROW     10
      COL     100
      WIDTH   180
      HEIGHT  22
      VALUE   cBccFolder
    END TEXTBOX

    DEFINE BUTTON btBccFolder
      ROW     10
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'folderselect'
      TOOLTIP 'Select folder'
      ONCLICK ( StatusLabel(), ;
        iif( !Empty( cFolder := GetFolder( 'BCC folder', ;
        Environment.BccFolder.Value ) ), ;
        Environment.BccFolder.Value := cFolder, ;
        NIL ) )
    END BUTTON

    DEFINE LABEL lbMiniGuiFolder
      ROW   40
      COL   10
      VALUE 'MiniGUI folder'
    END LABEL

    DEFINE TEXTBOX MiniGuiFolder
      ROW     40
      COL     100
      WIDTH   180
      HEIGHT  22
      VALUE   cMiniGuiFolder
    END TEXTBOX

    DEFINE BUTTON btMiniGuiFolder
      ROW     40
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'folderselect'
      TOOLTIP 'Select folder'
      ONCLICK ( StatusLabel(), ;
        iif( !Empty( cFolder := GetFolder( 'MiniGui folder', ;
        Environment.MiniGuiFolder.Value ) ), ;
        Environment.MiniGuiFolder.Value := cFolder, ;
        NIL ) )
    END BUTTON

    DEFINE LABEL lbHarbourFolder
      ROW   70
      COL   10
      VALUE 'Harbour folder'
    END LABEL

    DEFINE TEXTBOX OHarbourFolder
      ROW     70
      COL     100
      WIDTH   180
      HEIGHT  22
      VALUE   cOHarbourFolder
    END TEXTBOX

    DEFINE BUTTON btOHarbourFolder
      ROW     70
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'folderselect'
      TOOLTIP 'Select folder'
      ONCLICK ( StatusLabel(), ;
        iif( !Empty( cFolder := GetFolder( 'Harbour folder', ;
        Environment.OHarbourFolder.Value ) ), ;
        Environment.OHarbourFolder.Value := cFolder, ;
        NIL ) )
    END BUTTON

    DEFINE LABEL lbXHarbourFolder
      ROW   100
      COL   10
      VALUE 'xHarbour folder'
    END LABEL

    DEFINE TEXTBOX XHarbourFolder
      ROW     100
      COL     100
      WIDTH   180
      HEIGHT  22
      VALUE   cXHarbourFolder
    END TEXTBOX

    DEFINE BUTTON btXHarbourFolder
      ROW     100
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'folderselect'
      TOOLTIP 'Select folder'
      ONCLICK ( StatusLabel(), ;
        iif( !Empty( cFolder := GetFolder( 'xHarbour folder', ;
        Environment.XHarbourFolder.Value ) ), ;
        Environment.XHarbourFolder.Value := cFolder, ;
        NIL ) )
    END BUTTON

    DEFINE LABEL lbEditorExe
      ROW   130
      COL   10
      VALUE 'Program editor'
    END LABEL

    DEFINE TEXTBOX EditorExe
      ROW     130
      COL     100
      WIDTH   180
      HEIGHT  22
      VALUE   cEditorExe
    END TEXTBOX

    DEFINE BUTTON btEditorExe
      ROW     130
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'folderselect'
      TOOLTIP 'Select editor'
      ONCLICK ( StatusLabel(), ;
        iif( !Empty( cFileName := ;
        GetFile( { { 'Applications (*.exe)', '*.exe' } }, ;
        'Select program editor', GetSub( Environment.EditorExe.Value ) ) ), ;
        Environment.EditorExe.Value := cFileName, ;
        NIL ) )
    END BUTTON

    DEFINE CHECKBOX MpmAssociation
      ROW     160
      COL     10
      WIDTH   180
      VALUE   lAssocMpm
      CAPTION 'Associate MPM files with MPM'
      TOOLTIP 'Double click on MPM file starts MPM'
    END CHECKBOX

    DEFINE CHECKBOX PrgAssociation
      ROW     190
      COL     10
      WIDTH   180
      VALUE   lAssocPrg
      CAPTION 'Associate PRG files with MPM'
      TOOLTIP 'Double click on PRG file starts MPM'
    END CHECKBOX

    DEFINE CHECKBOX CAssociation
      ROW     220
      COL     10
      WIDTH   180
      VALUE   lAssocC
      CAPTION 'Associate C files with MPM'
      TOOLTIP 'Double click on C file starts MPM'
    END CHECKBOX

    DEFINE BUTTON btMpmAssoc
      ROW     160
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'registry'
      TOOLTIP 'Show current MPM file association'
      ONCLICK ShowAssociation( '.mpm' )
    END BUTTON

    DEFINE BUTTON btPrgAssoc
      ROW     190
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'registry'
      TOOLTIP 'Show current PRG file association'
      ONCLICK ShowAssociation( '.prg' )
    END BUTTON

    DEFINE BUTTON btCAssoc
      ROW     220
      COL     290
      WIDTH   25
      HEIGHT  25
      PICTURE 'registry'
      TOOLTIP 'Show current C file association'
      ONCLICK ShowAssociation( '.c' )
    END BUTTON

    DEFINE BUTTON Ok
      ROW     260
      COL     85
      WIDTH   65
      HEIGHT  25
      CAPTION '&OK'
      ONCLICK ( UpdateEnvironment(), Environment.Release )
    END BUTTON

    DEFINE BUTTON Cancel
      ROW     260
      COL     175
      WIDTH   65
      HEIGHT  25
      CAPTION '&Cancel'
      ONCLICK Environment.Release
    END BUTTON

    ON KEY RETURN ACTION ( UpdateEnvironment(), Environment.Release )
    ON KEY ESCAPE ACTION Environment.Release

  END WINDOW

  Environment.MinWidth  := 260
  Environment.MinHeight := 320

  ACTIVATE WINDOW Environment

RETURN

//***************************************************************************

PROCEDURE EnvironmentSize

LOCAL lThemed := IsXPThemeActive()
LOCAL nBorder := GetBorderWidth()

  nEnvirWidth  := Environment.Width
  nEnvirHeight := Environment.Height
  nEnvirCol    := Environment.Col
  nEnvirRow    := Environment.Row
  Environment.BccFolder.Width      := nEnvirWidth - 150
  Environment.btBccFolder.Col      := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.MiniGuiFolder.Width  := nEnvirWidth - 150
  Environment.btMiniGuiFolder.Col  := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.OHarbourFolder.Width := nEnvirWidth - 150
  Environment.btOHarbourFolder.Col := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.XHarbourFolder.Width := nEnvirWidth - 150
  Environment.btXHarbourFolder.Col := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.EditorExe.Width      := nEnvirWidth - 150
  Environment.btEditorExe.Col      := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.btMpmAssoc.Col       := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.btPrgAssoc.Col       := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.btCAssoc.Col         := nEnvirWidth - 40 - iif( lVistaOrSe7en, nBorder, 0 )
  Environment.Ok.Col     := Max( 10, Int( nEnvirWidth / 2 ) - 80 )
  Environment.Ok.Row     := Max( 70, nEnvirHeight - 60 - iif( lThemed, 7, 0 ) )
  Environment.Cancel.Col := Max( 10, Int( nEnvirWidth / 2 ) + 10 )
  Environment.Cancel.Row := Max( 70, nEnvirHeight - 60 - iif( lThemed, 7, 0 ) )

RETURN

//***************************************************************************

PROCEDURE UpdateEnvironment

  cBccFolder      := DelSlash( Environment.BccFolder.Value )
  cMiniGuiFolder  := DelSlash( Environment.MiniGuiFolder.Value )
  cOHarbourFolder := DelSlash( Environment.OHarbourFolder.Value )
  cXHarbourFolder := DelSlash( Environment.XHarbourFolder.Value )
  cEditorExe      := Environment.EditorExe.Value
  ChangeAssociation( '.mpm', Environment.MpmAssociation.Value )
  ChangeAssociation( '.prg', Environment.PrgAssociation.Value )
  ChangeAssociation( '.c', Environment.CAssociation.Value )
  StatusLabel()

RETURN

//***************************************************************************

PROCEDURE ShowAssociation( cExt )

  LOCAL cKey
  LOCAL cVal

  BEGIN SEQUENCE
    cKey := 'Software\CLASSES\' + cExt
    IF !IsRegistryKey( HKEY_LOCAL_MACHINE, cKey )
      BREAK
    ENDIF
    cVal := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey )
    IF Empty( cVal )
      BREAK
    ENDIF
    cKey := 'Software\CLASSES\' + cVal + '\Shell\Open\command'
    IF !IsRegistryKey( HKEY_LOCAL_MACHINE, cKey )
      BREAK
    ENDIF
    cVal := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey )
    IF Empty( cVal )
      BREAK
    ENDIF
    IF Upper( cVal ) == Upper( GETEXEFILENAME() )
      MpmInfo( Upper( cExt ) + ' files are currently associated with MPM.' )
    ELSE
      MpmInfo( Upper( cExt ) + ' files are currently associated with ' + ;
        cVal + '.' )
    ENDIF
  RECOVER
    MpmInfo( Upper( cExt ) + ;
      ' files are not currently associated with any program.' )
  END SEQUENCE

RETURN

//***************************************************************************

FUNCTION IsAssociated( cExt, lInit )

  LOCAL cKey
  LOCAL cVal
  LOCAL lAssoc

  BEGIN SEQUENCE
    cKey := 'Software\CLASSES\' + cExt
    IF !IsRegistryKey( HKEY_LOCAL_MACHINE, cKey )
      BREAK
    ENDIF
    cVal := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey )
    IF Empty( cVal )
      BREAK
    ENDIF
    cKey := 'Software\CLASSES\' + cVal + '\Shell\Open\command'
    IF !IsRegistryKey( HKEY_LOCAL_MACHINE, cKey )
      BREAK
    ENDIF
    cVal := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey )
    IF Empty( cVal )
      BREAK
    ENDIF
    cVal   := AllTrim( StrTran( StrTran( cVal, '"' ), '%1' ) )
    lAssoc := ( Upper( cVal ) == Upper( GETEXEFILENAME() ) )
  RECOVER
    lAssoc := !Empty( lInit )
  END SEQUENCE

RETURN lAssoc

//***************************************************************************

PROCEDURE ChangeAssociation( cExt, lSet )

  LOCAL lAssoc := IsAssociated( cExt )
  LOCAL cKey

  DO CASE
  CASE lSet .AND. !lAssoc
    BEGIN SEQUENCE
      cKey := 'Software\CLASSES\' + cExt
      IF !CreateRegistryKey( HKEY_LOCAL_MACHINE, cKey )
        BREAK
      ENDIF
      IF !SetRegistryValue( HKEY_LOCAL_MACHINE, cKey,, 'mpmfile' )
        BREAK
      ENDIF
      cKey := 'Software\CLASSES\mpmfile\Shell\Open\command'
      IF !CreateRegistryKey( HKEY_LOCAL_MACHINE, cKey )
        BREAK
      ENDIF
      IF !SetRegistryValue( HKEY_LOCAL_MACHINE, cKey,, ;
        AddQuote( GETEXEFILENAME() ) + ' "%1"' )
        BREAK
      ENDIF
    RECOVER
      MpmStop( 'Unable to associate ' + cExt + ' files with MPM.' )
    END SEQUENCE
  CASE !lSet .AND. lAssoc
    BEGIN SEQUENCE
      cKey := 'Software\CLASSES'
      IF !DeleteRegistryKey( HKEY_LOCAL_MACHINE, cKey, cExt )
        BREAK
      ENDIF
    RECOVER
      MpmStop( 'Unable to disassociate ' + cExt + ' files from MPM.' )
    END SEQUENCE
  ENDCASE

RETURN

//***************************************************************************

PROCEDURE StatusLabel( cLabel, nType )

  DO CASE
  CASE Empty( cLabel )
    Mpm.lbStatus.Value := ''
  CASE Empty( nType )
    Mpm.lbStatus.Value     := cLabel
    Mpm.lbStatus. FontColor := { 0x00, 0xC0, 0x00 }
  CASE nType == 1
    Mpm.lbStatus.Value     := cLabel
    Mpm.lbStatus. FontColor := { 0x80, 0x80, 0x00 }
  CASE nType == 2
    Mpm.lbStatus.Value     := cLabel
    Mpm.lbStatus. FontColor := { 0xC0, 0x00, 0x00 }
  ENDCASE

RETURN

//***************************************************************************

PROCEDURE StatusRefresh

  LOCAL cProjFolder := AddSlash( Mpm.BaseFolder.Value )
  LOCAL lSuccess

  IF lProcess
    IF File( cProjFolder + '_Build.bat' )
      StatusLabel( 'Building', 2 )
      DO CASE
      CASE File( cProjFolder + '_End.txt' )
        lProcess := .N.
        lSuccess := 'success' $ MemoRead( cProjFolder + '_End.txt' )
        Mpm.Log.Value := LogClean( MemoRead( cProjFolder + '_Build.log' ) )
        IF Mpm.DeleteTemp.Value
          DELETE FILE ( cProjFolder + '_Build.bat' )
          DELETE FILE ( cProjFolder + '_Build.log' )
          DELETE FILE ( cProjFolder + '_Build.rsp' )
          DELETE FILE ( cProjFolder + '_End.txt'  )
        ENDIF
        IF lSuccess
          StatusLabel( 'Build successful', 0 )
          IF Mpm.RunAfter.Value
            Execute()
          ENDIF
        ELSE
          StatusLabel( 'Build unsuccessful', 1 )
        ENDIF
      CASE !lGo
        lProcess := .N.
        StatusLabel( 'Build stopped', 1 )
      OTHERWISE
        Mpm.Log.Value := LogProg( MemoRead( cProjFolder + '_Build.log' ) )
      ENDCASE
    ELSE
      lProcess := .N.
      StatusLabel( 'Build unsuccessful', 1 )
    ENDIF
  ENDIF

RETURN

//***************************************************************************

FUNCTION LogClean( cInLog )

  LOCAL lXHarbour := Mpm.UseXHarbour.Value
  LOCAL cCR       := Chr( 0x0D )
  LOCAL cOutLog   := cInLog
  LOCAL cSearch   := iif( lXHarbour, '00' + cCR + ' ', '00' + cCR + cCR )
  LOCAL nLeft
  LOCAL nLen
  LOCAL nPos

  IF lXHarbour
    nPos := RAt( cSearch, cOutLog )
    WHILE !Empty( nPos )
      nLeft   := nPos + 2
      nLen    := At( cCR, cInLog, nLeft ) - nLeft
      cOutLog := Stuff( cOutLog, nLeft, nLen, '' )
      nPos    := RAt( cSearch, cOutLog )
    ENDDO
  ELSE
    nPos := RAt( cSearch, cOutLog )
    WHILE !Empty( nPos )
      nLeft   := RAt( cCR, Left( cOutLog, nPos ) ) + 1
      nLen    := nPos - nLeft + 4
      cOutLog := Stuff( cOutLog, nLeft, nLen, '' )
      nPos    := RAt( cSearch, cOutLog )
    ENDDO
    cOutLog := StrTran( StrTran( cOutLog, CRLF, cCR ), cCR, CRLF )
  ENDIF

RETURN cOutLog

//***************************************************************************

FUNCTION LogProg( cLog )

  LOCAL nMaxLen := 254
  LOCAL cCR     := Chr( 0x0D )
  LOCAL cProg   := MemoLine( cLog, nMaxLen, 1 ) + CRLF + MemoLine( cLog, nMaxLen, 2 )
  LOCAL nComPos := At( 'Compiling ', cLog )
  LOCAL nNumPos := RAt( '00' + cCR, cLog )
  LOCAL nLeft
  LOCAL nLen
  LOCAL nLine

  IF !Empty( nComPos ) .AND. !Empty( nNumPos )
    nLine := MPosToLC( cLog, nMaxLen, nComPos )[ 1 ]
    nLeft := RAt( cCR, Left( cLog, nNumPos ) ) + 1
    nLen  := At( cCR, SubStr( cLog, nLeft ) + cCR ) - 1
    cProg += CRLF + RTrim( MemoLine( cLog, nMaxLen, nLine ) ) + ' ' + ;
      SubStr( cLog, nLeft, nLen )
  ENDIF

RETURN cProg

//***************************************************************************

PROCEDURE LoadEnvironment

  LOCAL cWinFolder  := AddSlash( GetWindowsFolder() )
  LOCAL cIniFile    := cWinFolder + 'mpm.ini'
  LOCAL nDeskWidth  := GetDesktopWidth()
  LOCAL nDeskHeight := GetDesktopHeight()
  LOCAL nMaxLen     := 254
  LOCAL lThemed     := IsXPThemeActive()
  LOCAL cEnvir
  LOCAL nLine
  LOCAL nPos
  LOCAL cLine
  LOCAL cLineU
  LOCAL cKey
  LOCAL cVal
  LOCAL cValU

  IF lEnvir := File( cIniFile )

    cEnvir := MemoRead( cIniFile )
    FOR nLine := 1 TO MLCount( cEnvir, nMaxLen )
      cLine  := AllTrim( MemoLine( cEnvir, nMaxLen, nLine ) )
      cLineU := Upper( cLine )
      nPos   := At( '=', cLine )
      cKey   := StrTran( Left( cLineU, nPos - 1 ), ' ' )
      cVal   := AllTrim( SubStr( cLine, nPos + 1 ) )
      cValU  := Upper( cVal )
      DO CASE
      CASE cKey == 'BCCFOLDER'
        cBccFolder      := cVal
      CASE cKey == 'MINIGUIFOLDER'
        cMiniGuiFolder  := cVal
      CASE cKey == 'HARBOURFOLDER'
        cOHarbourFolder := cVal
      CASE cKey == 'XHARBOURFOLDER'
        cXHarbourFolder := cVal
      CASE cKey == 'PROGRAMEDITOR'
        cEditorExe      := cVal
      CASE cKey == 'PROGRAMEDITOR'
        cEditorExe      := cVal
      CASE cKey == 'MPMWIDTH'
        nMpmWidth     := Max( 640, Val( cVal ) )
      CASE cKey == 'MPMHEIGHT'
        nMpmHeight    := Max( 480, Val( cVal ) )
      CASE cKey == 'MPMCOL'
        nMpmCol       := Val( cVal )
      CASE cKey == 'MPMROW'
        nMpmRow       := Val( cVal )
      CASE cKey == 'MPMMAX'
        lMpmMax       := 'Y' $ cValU
      CASE cKey == 'RECENTWIDTH'
        nRecentWidth  := Max( 185, Val( cVal ) )
      CASE cKey == 'RECENTHEIGHT'
        nRecentHeight := Max( 130, Val( cVal ) )
      CASE cKey == 'RECENTCOL'
        nRecentCol    := Val( cVal )
      CASE cKey == 'RECENTROW'
        nRecentRow    := Val( cVal )
      CASE cKey == 'ENVIRWIDTH'
        nEnvirWidth   := Max( 185, Val( cVal ) )
      CASE cKey == 'ENVIRHEIGHT'
        nEnvirHeight  := Max( 320, Val( cVal ) )
      CASE cKey == 'ENVIRCOL'
        nEnvirCol     := Val( cVal )
      CASE cKey == 'ENVIRROW'
        nEnvirRow     := Val( cVal )
      CASE cKey == 'HELPWIDTH'
        nHelpWidth    := Max( 120, Val( cVal ) )
      CASE cKey == 'HELPHEIGHT'
        nHelpHeight   := Max( 100, Val( cVal ) )
      CASE cKey == 'HELPCOL'
        nHelpCol      := Val( cVal )
      CASE cKey == 'HELPROW'
        nHelpRow      := Val( cVal )
      CASE cKey == 'HELPMAX'
        lHelpMax      := 'Y' $ cValU
      CASE cKey == 'FILEHISTORY1'
        aFileHist[ 1 ]  := cVal
      CASE cKey == 'FILEHISTORY2'
        aFileHist[ 2 ]  := cVal
      CASE cKey == 'FILEHISTORY3'
        aFileHist[ 3 ]  := cVal
      CASE cKey == 'FILEHISTORY4'
        aFileHist[ 4 ]  := cVal
      CASE cKey == 'FILEHISTORY5'
        aFileHist[ 5 ]  := cVal
      CASE cKey == 'FILEHISTORY6'
        aFileHist[ 6 ]  := cVal
      CASE cKey == 'FILEHISTORY7'
        aFileHist[ 7 ]  := cVal
      CASE cKey == 'FILEHISTORY8'
        aFileHist[ 8 ]  := cVal
      CASE cKey == 'FILEHISTORY9'
        aFileHist[ 9 ]  := cVal
      ENDCASE
    NEXT

  ENDIF

  SET DECIMALS TO
  IF Empty( nMpmWidth )
    nMpmWidth  := Max( 640, Min( 750, nDeskWidth ) )
  ENDIF
  IF Empty( nMpmHeight )
    nMpmHeight := Max( 480, Min( 500, nDeskHeight ) )
  ENDIF
  IF Empty( nMpmCol )
    nMpmCol    := Max( 0, ( nDeskWidth  - nMpmWidth ) / 2 )
  ENDIF
  IF Empty( nMpmRow )
    nMpmRow    := Max( 0, ( nDeskHeight - nMpmHeight ) / 2 )
  ENDIF

  IF Empty( nRecentWidth )
    nRecentWidth  := 330
  ENDIF
  IF Empty( nRecentHeight )
    nRecentHeight := 220 + iif( lThemed, 7, 0 )
  ENDIF
  IF Empty( nRecentCol )
    nRecentCol    := Max( 0, ( nDeskWidth  - nRecentWidth ) / 2 )
  ENDIF
  IF Empty( nRecentRow )
    nRecentRow    := Max( 0, ( nDeskHeight - nRecentHeight ) / 2 )
  ENDIF

  IF Empty( nEnvirWidth )
    nEnvirWidth   := 330 + iif( lVistaOrSe7en, GetBorderWidth(), 0 )
  ENDIF
  IF Empty( nEnvirHeight )
    nEnvirHeight  := 320 + iif( lThemed, 7, 0 ) + iif( lVistaOrSe7en, GetBorderHeight(), 0 )
  ENDIF
  IF Empty( nEnvirCol )
    nEnvirCol     := Max( 0, ( nDeskWidth  - nEnvirWidth ) / 2 )
  ENDIF
  IF Empty( nEnvirRow )
    nEnvirRow     := Max( 0, ( nDeskHeight - nEnvirHeight ) / 2 )
  ENDIF
  SET DECIMALS TO 2

  IF Empty( nHelpWidth )
    nHelpWidth    := 500
  ENDIF
  IF Empty( nHelpHeight )
    nHelpHeight   := 500
  ENDIF
  IF Empty( nHelpCol )
    nHelpCol      := 10
  ENDIF
  IF Empty( nHelpRow )
    nHelpRow      := 10
  ENDIF

  IF Empty( cBccFolder )
    cBccFolder      := 'C:\Borland\BCC55'
  ENDIF
  IF Empty( cMiniGuiFolder )
    cMiniGuiFolder  := 'C:\MiniGUI'
  ENDIF
  IF Empty( cOHarbourFolder )
    cOHarbourFolder := 'C:\MiniGUI\Harbour'
  ENDIF
  IF Empty( cXHarbourFolder )
    cXHarbourFolder := 'C:\xHarbour'
  ENDIF
  IF Empty( cEditorExe )
    cEditorExe      := 'NOTEPAD.EXE'
  ENDIF

RETURN

//***************************************************************************

PROCEDURE SaveEnvironment

  LOCAL cWinFolder := AddSlash( GetWindowsFolder() )
  LOCAL cEnvir     := ;
    'BCCFOLDER='      + AllTrim( cBccFolder )       + CRLF + ;
    'MINIGUIFOLDER='  + AllTrim( cMiniGuiFolder )   + CRLF + ;
    'HARBOURFOLDER='  + AllTrim( cOHarbourFolder )  + CRLF + ;
    'XHARBOURFOLDER=' + AllTrim( cXHarbourFolder )  + CRLF + ;
    'PROGRAMEDITOR='  + AllTrim( cEditorExe )       + CRLF + ;
    'MPMWIDTH='       + hb_ntos( nMpmWidth )        + CRLF + ;
    'MPMHEIGHT='      + hb_ntos( nMpmHeight )       + CRLF + ;
    'MPMCOL='         + hb_ntos( nMpmCol )          + CRLF + ;
    'MPMROW='         + hb_ntos( nMpmRow )          + CRLF + ;
    'MPMMAX='         + Transform( lMpmMax, 'Y' )   + CRLF + ;
    'RECENTWIDTH='    + hb_ntos( nRecentWidth )     + CRLF + ;
    'RECENTHEIGHT='   + hb_ntos( nRecentHeight )    + CRLF + ;
    'RECENTCOL='      + hb_ntos( nRecentCol )       + CRLF + ;
    'RECENTROW='      + hb_ntos( nRecentRow )       + CRLF + ;
    'ENVIRWIDTH='     + hb_ntos( nEnvirWidth )      + CRLF + ;
    'ENVIRHEIGHT='    + hb_ntos( nEnvirHeight )     + CRLF + ;
    'ENVIRCOL='       + hb_ntos( nEnvirCol )        + CRLF + ;
    'ENVIRROW='       + hb_ntos( nEnvirRow )        + CRLF + ;
    'HELPWIDTH='      + hb_ntos( nHelpWidth )       + CRLF + ;
    'HELPHEIGHT='     + hb_ntos( nHelpHeight )      + CRLF + ;
    'HELPCOL='        + hb_ntos( nHelpCol )         + CRLF + ;
    'HELPROW='        + hb_ntos( nHelpRow )         + CRLF + ;
    'HELPMAX='        + Transform( lHelpMax, 'Y' )  + CRLF + ;
    'FILEHISTORY1='   + aFileHist[ 1 ]              + CRLF + ;
    'FILEHISTORY2='   + aFileHist[ 2 ]              + CRLF + ;
    'FILEHISTORY3='   + aFileHist[ 3 ]              + CRLF + ;
    'FILEHISTORY4='   + aFileHist[ 4 ]              + CRLF + ;
    'FILEHISTORY5='   + aFileHist[ 5 ]              + CRLF + ;
    'FILEHISTORY6='   + aFileHist[ 6 ]              + CRLF + ;
    'FILEHISTORY7='   + aFileHist[ 7 ]              + CRLF + ;
    'FILEHISTORY8='   + aFileHist[ 8 ]              + CRLF + ;
    'FILEHISTORY9='   + aFileHist[ 9 ]              + CRLF

  SaveCheck()
  MemoWrite( cWinFolder + 'mpm.ini', cEnvir )

RETURN

//***************************************************************************

PROCEDURE MpmInfo( cMsg, cTitle )

  MsgInfo( cMsg, iif( Empty( cTitle ), 'MPM', cTitle ),, .N., .N. )

RETURN

//***************************************************************************

PROCEDURE MpmStop( cMsg, cTitle )

  MsgStop( cMsg, iif( Empty( cTitle ), 'MPM', cTitle ),, .N., .N. )

RETURN

//***************************************************************************

FUNCTION MpmYesNo( cMsg, cTitle )

  LOCAL lYesNo := MsgYesNo( cMsg, iif( Empty( cTitle ), 'MPM', cTitle ),,, .N., .N. )

RETURN lYesNo

//***************************************************************************

FUNCTION MpmRun( cFile, cParams, lShow )

  LOCAL hProcErr := { ;
    2  => 'File not found', ;
    3  => 'Path not found', ;
    5  => 'Access denied', ;
    8  => 'Out of memory', ;
    11 => 'Corrupt EXE file', ;
    26 => 'Sharing violation', ;
    27 => 'Invalid file association', ;
    28 => 'DDE timeout', ;
    29 => 'DDE transaction failed', ;
    30 => 'DDE busy', ;
    31 => 'No file association', ;
    32 => 'DLL not found'             }
  LOCAL nProc := _Execute( GetActiveWindow(),, ;
      AddQuote( cFile ), cParams,, iif( lShow, 5, 0 ) )
  LOCAL lRun := ( nProc > 32 )

  IF !lRun
    IF nProc $ hProcErr
      MpmStop( 'Run error ' + LTrim( Str( nProc ) ) + ': ' + hProcErr[ nProc ] )
    ELSE
      MpmStop( 'Unknown run error ' + LTrim( Str( nProc ) ) )
    ENDIF
  ENDIF

RETURN lRun

//***************************************************************************

PROCEDURE SwitchDebug( lToggle )

  StatusLabel()
  IF lToggle
    Mpm.Debug.Value := !Mpm.Debug.Value
  ENDIF
  Mpm.miDebug. Checked := Mpm.Debug.Value
  Mpm.lbDebug.Value   := iif( Mpm.Debug.Value, 'Debug', '' )

RETURN

//***************************************************************************

PROCEDURE SwitchRebuild( lToggle )

  StatusLabel()
  IF lToggle
    Mpm.Rebuild.Value := !Mpm.Rebuild.Value
  ENDIF
  Mpm.miRebuild. Checked := Mpm.Rebuild.Value
  Mpm.lbRebuild.Value   := iif( Mpm.Rebuild.Value, 'Rebuild', '' )

RETURN

//***************************************************************************

FUNCTION AddSlash( cInFolder )

  LOCAL cOutFolder := AllTrim( cInFolder )

  IF !Empty( cOutFolder ) .AND. Right( cOutfolder, 1 ) != '\'
    cOutFolder += '\'
  ENDIF

RETURN cOutFolder

//***************************************************************************

FUNCTION DelSlash( cInFolder )

  LOCAL cOutFolder := AllTrim( cInFolder )

  IF !Empty( cOutFolder ) .AND. Right( cOutfolder, 1 ) == '\'
    cOutFolder := Left( cOutFolder, Len( cOutFolder ) - 1 )
  ENDIF

RETURN cOutFolder

//***************************************************************************

FUNCTION AddQuote( cInPath )

  LOCAL cOutPath := AllTrim( cInPath )
  LOCAL cQuote   := '"'
  LOCAL cSpace   := Space( 1 )

  IF cSpace $ cOutPath .AND. ;
    !( Left( cOutPath, 1 ) == cQuote ) .AND. !( Right( cOutPath, 1 ) == cQuote )
    cOutPath := cQuote + cOutPath + cQuote
  ENDIF

RETURN cOutPath

//***************************************************************************

FUNCTION GetPath( cFileName )

  LOCAL cTrim  := AllTrim( cFileName )
  LOCAL nColon := At( ':', cTrim )
  LOCAL cDrive
  LOCAL cPath

  IF Empty( nColon )
    cDrive := DiskName()
    IF Left( cTrim, 1 ) == '\'
      cPath := cDrive + ':' + cTrim
    ELSE
      cPath := cDrive + ':\' + CurDir( cDrive ) + '\' + cTrim
    ENDIF
  ELSE
    IF SubStr( cTrim, nColon + 1, 1 ) == '\'
      cPath := cTrim
    ELSE
      cDrive := Left( cTrim, nColon - 1 )
      cPath  := cDrive + ':\' + CurDir( cDrive ) + '\' + ;
        SubStr( cTrim, nColon + 1 )
    ENDIF
  ENDIF

RETURN cPath

//***************************************************************************

FUNCTION GetSub( cFileName, lGetDefault )

  LOCAL cTrim  := ;
    iif( Empty( lGetDefault ), AllTrim( cFileName ), GetPath( cFileName ) )
  LOCAL nSlash := Max( RAt( '\', cTrim ), At( ':', cTrim ) )
  LOCAL cSub   := Left( cTrim, nSlash - 1 )

RETURN cSub

//***************************************************************************

FUNCTION GetName( cFileName )

  LOCAL cTrim  := AllTrim( cFileName )
  LOCAL nSlash := Max( RAt( '\', cTrim ), At( ':', cTrim ) )
  LOCAL cName  := iif( Empty( nSlash ), cTrim, SubStr( cTrim, nSlash + 1 ) )

RETURN cName

//***************************************************************************

FUNCTION GetExt( cFileName )

  LOCAL cTrim  := AllTrim( cFileName )
  LOCAL nDot   := RAt( '.', cTrim )
  LOCAL nSlash := Max( RAt( '\', cTrim ), At( ':', cTrim ) )
  LOCAL cExt   := iif( nDot <= nSlash .OR. nDot == nSlash + 1, ;
    '', SubStr( cTrim, nDot ) )

RETURN cExt

//***************************************************************************

FUNCTION DelExt( cFileName )

  LOCAL cTrim  := AllTrim( cFileName )
  LOCAL nDot   := RAt( '.', cTrim )
  LOCAL nSlash := Max( RAt( '\', cTrim ), At( ':', cTrim ) )
  LOCAL cBase  := iif( nDot <= nSlash .OR. nDot == nSlash + 1, ;
    cTrim, Left( cTrim, nDot - 1 ) )

RETURN cBase

//***************************************************************************

FUNCTION DateTime( dDate, cTime )

  LOCAL nDateTime := ( dDate - CToD( '' ) ) + Secs( cTime ) / 86400

RETURN nDateTime

//***************************************************************************

FUNCTION MemoWrite( cFile, cCont )

#ifndef __XHARBOUR__
  LOCAL lWrite := hb_MemoWrit( cFile, cCont )
#else
  LOCAL lWrite := MemoWrit( cFile, cCont, .N. )
#endif

RETURN lWrite

//***************************************************************************

FUNCTION IsXpPlus

RETURN _HMG_IsXPorLater

//***************************************************************************

FUNCTION AInsert( aArray, nPos, xVal )

  AAdd( aArray, NIL )
  AIns( aArray, nPos )
  aArray[ nPos ] := xVal

RETURN aArray

//***************************************************************************

FUNCTION ADelete( aArray, nPos )

  ADel( aArray, nPos )
  ASize( aArray, Len( aArray ) - 1 )

RETURN aArray

//***************************************************************************

PROCEDURE About

  MpmInfo( cMpmTitle + CRLF + ;
    CRLF + ;
    'Based on Harbour MiniGUI Project Manager by Roberto Lopez' + CRLF + ;
    'Copyright (c) 2003 Roberto Lopez <harbourminigui@gmail.com>' + CRLF + ;
    CRLF + ;
    'MiniGUI Extended version by the MiniGUI team' + CRLF + ;
    MiniGUIVersion() + CRLF + ;
    CRLF + ;
    'Last modified ' + cMpmDate + ' by' + CRLF + ;
    cMpmAuthor, 'About MPM' )

RETURN

//***************************************************************************

PROCEDURE Contents

  IF IsWindowDefined( Help )
    DoMethod( 'Help', 'Setfocus' )
    RETURN
  ENDIF

  DEFINE WINDOW Help ;
    AT     nHelpRow, nHelpCol ;
    WIDTH  nHelpWidth ;
    HEIGHT nHelpHeight ;
    TITLE 'MPM Help' ;
    ICON  'MAIN' ;
    ON INIT SizeHelp() ;
    ON MAXIMIZE SizeHelp( .Y. ) ;
    ON MOVE SizeHelp() ;
    ON SIZE SizeHelp()

    ON KEY ESCAPE ACTION Help.Release

    DEFINE RICHEDITBOX Contents
      ROW     10
      COL     10
      WIDTH   520
      HEIGHT  500
      READONLY   .Y.
      HSCROLLBAR .N.
    END RICHEDITBOX

  END WINDOW

  Help.Contents.RichValue( RICHVALUE_RTF ) := HelpText()
  Help.MinWidth  := 120
  Help.MinHeight := 100
  IF lHelpMax
    Help.Maximize()
  ENDIF

  ACTIVATE WINDOW Help

RETURN

//***************************************************************************

PROCEDURE SizeHelp( lMax )

  LOCAL lThemed := IsXPThemeActive()
  LOCAL nWidth  := Help.Width
  LOCAL nHeight := Help.Height
  LOCAL nCol    := Help.Col
  LOCAL nRow    := Help.Row

  IF Empty( lMax )
    IF nWidth < GetDesktopWidth() .AND. nHeight < GetDesktopHeight()
      nHelpWidth  := nWidth
      nHelpHeight := nHeight
      nHelpCol    := nCol
      nHelpRow    := nRow
    ENDIF
    lHelpMax    := .N.
  ELSE
    lHelpMax    := .Y.
  ENDIF
  Help.Contents.Width  := nWidth  - 30
  Help.Contents.Height := nHeight - 50 - iif( lThemed, 5, 0 )

RETURN

//***************************************************************************

FUNCTION HelpText

  LOCAL cText := ;
    "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 MS Sans Serif;}{\f1\fswiss\fcharset0 Arial;}{\f2\fnil\fcharset2 Symbol;}}" + CRLF + ;
    "{\*\generator Msftedit 5.41.15.1515;}\viewkind4\uc1\pard\f0\fs20\par" + CRLF + ;
    "\pard\qc\b\fs32 MINIGUI EXTENDED PROJECT MANAGER\par" + CRLF + ;
    "\b0\fs20\par" + CRLF + ;
    "\pard\qc\b\fs24 CONTENTS\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 Introduction\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}First time setup\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Basic operation\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Menus\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Toolbar\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Sources tab\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Dependents tab\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Options tab\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Libraries and object files tab\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Status information\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Hotkeys\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Environment window\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Optional command line parameter\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}SET PROCEDURE statements\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}LOAD WINDOW statements\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Libraries that are always linked in\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\pard\qc\b\fs24 INTRODUCTION\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "This program builds a set of (x)Harbour source files into an EXE, using Harbour MiniGUI Extended.  Source files may include .PRG, .CH, .FMG, .RC, .C, and .H files.\par" + CRLF + ;
    "\par" + CRLF + ;
    "Unless you request otherwise, this program builds the EXE only when at least one source file is newer than the EXE, and it compiles only the newer source files.  This is called incremental compiling.\par" + CRLF + ;
    "\par" + CRLF + ;
    "Only .PRG, .C, and .RC files are actually compiled.  If any of the .FMG, .C, or .H files change, then all of the .PRG files are compiled.  If any .H file changes, then all of the .C files are compiled.  You can also specify a list of files that causes an individual .PRG, .C, or .RC to be compiled, with the Dependent files window, explained below.\par" + CRLF + ;
    "\par" + CRLF + ;
    "You must select a base folder and use source files only from this folder and folders below it.  The EXE has the same base name as the first source file, called the main source file.  In debug mode, the base name of the EXE has \'22_deb\'22 appended to it.  Object files are put into an OBJ folder under the base folder, except in debug mode, when they are put into a DEB folder.  Other files generated by the build process are deleted after the build finishes, unless you request otherwise.\par" + CRLF + ;
    "\par" + CRLF + ;
    "You may save the settings for each set of source files into an MPM file, and then open the MPM file with this program later.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 FIRST TIME SETUP\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "The first time you use this program, the envronment window comes up.  In this window, you are prompted to set the locations of BCC, (x)Harbour, MiniGUI, and your program editor, and to decide whether to associate MPM with .MPM, .PRG, and .C files.  Association means that when you double click on a file with this extension, MPM opens the file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "It is recommended to always associate MPM with .MPM files, and to associate MPM with .PRG and .C files if you have no other program associated with them.  For more information, see below.\par" + CRLF + ;
    "\par" + CRLF + ;
    "These settings are stored in the file MPM.INI in the Windows folder.  This file is created the first time you run MPM and is updated every time you run the program.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 BASIC OPERATION\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720  For the base folder, select the folder containing source files.\par" + CRLF + ;
    "{\pntext\f2\'B7\tab} Use the plus button to add source files the project.\par" + CRLF + ;
    "{\pntext\f2\'B7\tab} Press the \b Build \b0 button to build the EXE.\par" + CRLF + ;
    "{\pntext\f2\'B7\tab} Press the \b Run \b0 button to run the EXE.\par" + CRLF + ;
    "{\pntext\f2\'B7\tab} If desired, press the \b Save \b0 button to save the project settings to an MPM file.\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\pard\qc\b\fs24 MENUS\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\b File / New\b0 :  Starts a new project.  Clears the list of source files, resets options to defaults, and prompts for a new base folder.  Same as the \b New \b0 button.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b File / Open\b0 :  Opens a saved project from an .MPM file, or a .PRG or .C file as the first file of a new project.  Same as the \b Open \b0 button, or \b F3\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b File / Save\b0 :  Saves the current project to the current .MPM file if there is one, or a new one otherwise.  Same as the \b Save \b0 button, or \b F2\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b File / Save As\b0 :  Saves the current project to a new .MPM file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b File / Recent\b0 :  Allows you to open a recently used project.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b File / Exit\b0 :  Exits the program.  Same as \b F10\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project / Build\b0 :  Compiles and links the source files into an EXE.  Same as the \b Build \b0 button, or \b F4\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project / Stop\b0 :  Stops the build process if it is running.  Same as the \b Stop \b0 button, or \b F5\b0 .  This feature requires Windows XP or higher.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project / Run\b0 :  Runs the EXE.  Same as the \b Run \b0 button, or \b F6\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project / Debug\b0 :  Sets or clears the option to build a debug EXE.  Same as \b Options \b0 tab / \b Create debug EXE\b0 , or \b F7\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project / Rebuild\b0 :  Sets or clears the option to rebuild the EXE regardless of source file dates.  Same as \b Options \b0 tab / \b Rebuild project\b0 , or \b F8\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Project menu / Cleanup\b0 :  Deletes files created by the build process, except the executable.  It is recommended to use this option only when you no longer need to compile or debug the program.  Files deleted include: \par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 Debug executable,\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}All files in the OBJ and DEB folders,\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}PPO files,\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}Temporary files created by the build process.\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\b Tools / Environment\b0 :  Allows you to set the locations of BCC, (x)Harbour, MiniGUI, and your program editor, and to decide whether to associate MPM with .MPM, .PRG, and .C files.  See below.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 TOOLBAR\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\b New\b0 :  Starts a new project.  Clears the list of source files, resets options to defaults, and prompts for a new base folder.  Same as \b File \b0 menu / \b New\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Open\b0 :  Opens a saved project from an .MPM file, or a .PRG or .C file as the first file of a new project.  Same as \b File \b0 menu / \b Open\b0 , or \b F3\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Save\b0 :  Saves the current project to the current .MPM file if there is one, or a new one otherwise.  Same as \b File \b0 menu / \b Save\b0 , or \b F2\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Build\b0 :  Compiles and links the source files into an EXE.  Same as \b Project \b0 menu / \b Build\b0 , or \b F4\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Stop\b0 :  Stops the build process if it is running.  Same as the Stop button, or F5.  This feature requires Windows XP or higher.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Run\b0 :  Runs the EXE.  Same as \b Project \b0 menu / \b Run\b0 , or \b F6\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 SOURCES TAB\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\b Project folder\b0 :  The folder that contains the source files.  If source files are in multiple folders, this is the topmost folder that contains the files.  The EXE is built in this folder.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Plus \b0 button:  Adds one or more source files from the project base folder to the source file list.  Source files may include .PRG, .CH, .FMG, .RC, .C, and .H files.  The first source file in the list becomes the main source file and must contain the main procedure.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b X \b0 button:  Removes the highlighted source file from the list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Write \b0 button:  Edits the highlighted source file.  Set the editor in the Environment window.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Up top \b0 button:  Moves the highlighted source file to the top of the list, making it the main source file.  Only a .PRG or .C file may be the main source file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Up \b0 and \b down \b0 buttons:  Move the highlighted source file up or down one position within the list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 DEPENDENTS TAB\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "For each source file, you may specify a list of dependent files, which are files that trigger the source file to be compiled, even if the source file itself has not been changed.  This typically includes header files that the source file references, but it may include any type of file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "You may specify dependent files only for files that are compiled, namely .PRG, .C, and .RC files.  When dependent files have been specified for a source file, the number of dependent files appears in brackets after the source file name.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Plus \b0 button:  Adds one or more files to the dependent files list.  Dependent files may be of any file type.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b X \b0 button:  Removes the highlighted file from the dependent files list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Write \b0 button:  Edits the highlighted dependent file.  Set the editor in the \b Environment \b0 window.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Up \b0 and \b down \b0 buttons:  Move the highlighted file up or down one position within the dependent files list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 OPTIONS TAB\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\b Create debug EXE\b0 :  Compile and link in debug mode.  Same as \b Project \b0 menu / \b Debug\b0 , or \b F7\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Rebuild project\b0 :  Rebuild the EXE regardless of source file dates.  Same as \b Project \b0 menu / \b Rebuild\b0 , or \b F8\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Run after build\b0 :  Run the EXE immediately after a successful build.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Hide build window\b0 :  Hide the temporary window that this program creates to run the build process.  Output from the build process is shown in the log instead.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Delete temporary files\b0 :  Delete temporary files created by the build process after the build is completed,\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Use xHarbour\b0 :  Use xHarbour instead of Harbour.  Set the xHarbour path in the \b Environment \b0 window.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Multithreaded EXE\b0 :  Create a multithreaded EXE.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Generate PPO\b0 :  Generate preprocessor output in a PPO file for each PRG file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Additional compiler options\b0 :  Additional parameters to add to the compiler command when a .PRG file is compiled with (x)Harbour.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Additional C compiler options\b0 :  Additional parameters to add to the compiler command when a .C file is compiled with BCC.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b EXE ccmmand line options\b0 :  Parameters to add to the EXE command line when it is run.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Executable type\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 GUI\b0 :  A Windows program the uses the usual graphical user interface.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Console\b0 :  A Windows program that uses the character based interface.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Mixed\b0 :  A Windows program that uses both GUI and console modes.\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\b Compiler warnings\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 None\b0 :  The compiler reports only errors.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Basic\b0 :  The compiler reports errors and undeclared or ambiguous names.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Strong\b0 :  The compiler generates basic warnings and additional warnings.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Typed\b0 :  The compiler generates strong warnings and does type checking.\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\b Generate library\b0 :  Create a library from the source code instead of an EXE file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 LIBRARIES AND OBJECT FILES TAB\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "This tab allows you to link in libraries and object files that are not otherwise linked in.  See below for a list of libraries and object files that are always linked in.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b ZIP support\b0 :  Add zip file support using the (x)Harbour library ziparchive.lib.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b ODBC support\b0 :  Add ODBC support using the (x)Harbour libraries hdodbc.lib and odbc32.lib.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b ADS support\b0 :  Add ADS support using the (x)Harbour libraries rddads.lib and ace32.lib.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b MySQL support\b0 :  Add MySQL support using the (x)Harbour libraries hbmysql.lib and libmysql.lib.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Additional libraries and object files\b0 :  Add libraries and object files not in the above categories.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Plus-H \b0 button:  Add a (x)Harbour library.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Plus-M \b0 button:  Add a MiniGUI library.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Plus-O \b0 button:  Add any other library or object file.  A library may be any .LIB file.  An object file may be any .OBJ or .RES file.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b X \b0 button:  Delete the highlighted library or object file from the list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Up \b0 and \b down \b0 buttons:  Move the highlighted library or object file up or down one position within the list.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 STATUS INFORMATION\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "Status line:  This line displays to the right of the toolbar and shows the following status indicators.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-720\li720\b Building\b0 :  The current project is currently being built.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Debug\b0 :  The debug option has been selected.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}Rebuild\b0 :  The rebuild option has been selected.\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "Log:  During a build process, the log displays progress output from the compiler or linker.  After a build process has completed, the log displays error and warning output from the compiler or linker.  You can show this output in a temporary window instead of this box by deselecting \b Options \b0 tab / \b Hide build window\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 HOTKEYS\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-720\li720\b F1 \b0 Help:  Same as \b Help \b0 menu / \b Contents\b0 .\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F2 \b0 Save:  Same as \b File \b0 menu / \b Save\b0 , or the \b Save \b0 button.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F3 \b0 Open:  Same as \b File \b0 menu / \b Open\b0 , or the \b Open \b0 button.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F4 \b0 Build:  Same as \b Project \b0 menu / \b Build\b0 , or the \b Build \b0 button.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F5 \b0 Stop:  Same as \b Project \b0 menu / \b Stop\b0 , or the \b Stop \b0 button.  This feature requires Windows XP or higher.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F6 \b0 Run:  Same as \b Project \b0 menu / \b Run\b0 , or the \b Run \b0 button.\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F7 \b0 Debug:  Same as \b Project \b0 menu / \b Debug\b0 , or \b Options \b0 tab / \b Create debug EXE\b0 .\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F8 \b0 Rebuild:  Same as \b Project \b0 menu / \b Rebuild\b0 , or \b Options \b0 tab / \b Rebuild project\b0 .\par" + CRLF + ;
    "\b{\pntext\f2\'B7\tab}F10 \b0 Exit:  Same as \b File \b0 menu / \b Exit\b0 .\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "\pard\qc\b\fs24 ENVIRONMENT WINDOW\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "This window comes up the first time you run the program.  After that, use \b Tools \b0 menu / \b Environment\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b BCC folder\b0 :  Location of BCC, the folder cotaining its Bin, Include, and Lib folders.  Defaults to \b C:\\Borland\\BCC55\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b MiniGUI folder\b0 :  Location of MiniGUI, the folder containing its Bin, Include, and Lib folders.  Defaults to \b C:\\MiniGUI\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Harbour folder\b0 :  Location of Harbour, the folder containing its Bin, Include, and Lib folders.  Defaults to \b C:\\MiniGUI\\Harbour\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b xHarbour folder\b0 :  Location of xHarbour, the folder containing its Bin, Include, and Lib folders.  Defaults to \b C:\\xHarbour\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Program editor\b0 :  Location and file name of the editor for the edit button to use to edit a PRG file.  Defaults to \b NOTEPAD.EXE\b0 .\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Associate MPM files with MPM\b0 :  Whether a double click on an .MPM file opens the file with this program.  It is recommended to always associate .MPM files with MPM.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Associate PRG files with MPM\b0 :  Whether a double click on a .PRG file opens the file with this program.  It is recommended to associate .PRG files with MPM if you have no other program associated with them.  To check the current association, click on the button to the right of the checkbox.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\b Associate C files with MPM\b0 :  Whether a double click on an .MPM file opens the file with this program.  It is recommended to associate .C files with MPM if you have no other program associated with them.  To check the current association, click on the button to the right of the checkbox.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 OPTIONAL COMMAND LINE PARAMETER\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "This program accepts an MPM, PRG, or C file as an optional command line argument.  To associate any of these extensions with this program, use \b Tools \b0 menu / \b Environment\b0 .  An MPM file is created by the \b Save \b0 options of this program to contain the settings for a project.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 SET PROCEDURE STATEMENTS\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "A SET PROCEDURE statement instructs (x)Harbour to compile one or more additional .PRG files.  It is recommended to put a PRG file containing a SET PROCEDURE into the source file list, and to put .PRG files referenced by the SET PROCEDURE statement into the dependent files list for the source PRG.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 LOAD WINDOW STATEMENTS\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "A LOAD WINDOW statement instructs (x)Harbour to load a window definition from an .FMG file.  It is recommended to put a PRG file containing a LOAD WINDOW statement into the source file list, and to put an FMG file referenced by the LOAD WINDOW statement into the dependent files list for the source PRG.\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard\qc\b\fs24 LIBRARIES THAT ARE ALWAYS LINKED IN\par" + CRLF + ;
    "\pard\b0\fs20\par" + CRLF + ;
    "The following libraries and object files are linked into every project.\par" + CRLF + ;
    "\par" + CRLF + ;
    "(x)Harbour libraries:\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 dll.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}gtwin.lib (console programs only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}gtgui.lib (GUI programs only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbcplr.lib (Harbour only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]rtl.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]vm.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]lang.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hbcpage]codepage.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]macro.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]rdd.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]hsx.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[rddntx]dbfntx.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[rddcdx]dbfcdx.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[rddfpt]dbffpt.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbsix.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]common.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]debug.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]pp.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbpcre.lib (Harbour only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}pcrepos.lib (xHarbour only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hb]ct.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}[hbmisc]libmisc.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbole.lib (Harbour only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbprinter.lib (GUI programs only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}socket.lib (GUI programs only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}miniprint.lib (GUI programs only)\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "MiniGUI libraries and object files:\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 dbginit.obj (debug EXE only)\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}tsbrowse.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}propgrid.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}minigui.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}hbprinter.res\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}miniprint.res\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}minigui.res\par" + CRLF + ;
    "\pard\par" + CRLF + ;
    "Borland libraries and object files:\par" + CRLF + ;
    "\par" + CRLF + ;
    "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li720 c0w32.obj\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}cw32.lib\par" + CRLF + ;
    "{\pntext\f2\'B7\tab}import32.lib\par" + CRLF + ;
    "\pard\f1\par" + CRLF + ;
    "}"

RETURN cText

//***************************************************************************
