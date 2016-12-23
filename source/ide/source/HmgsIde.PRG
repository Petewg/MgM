/*
   HMGS - MiniGUI - IDE - Harbour Win32 GUI Designer

   Copyright 2005-2015 Walter Formigoni <walter.formigoni@gmail.com>
   http://sourceforge.net/projects/hmgs-minigui/

   This program is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
   (or visit the web site http://www.gnu.org/).

   Parts of this project are based upon:

   MINIGUI - Harbour Win32 GUI Designer

   Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   Harbour Minigui IDE

   (c)2004-2009 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

*/

#include "hmg.ch"
#include "TSBrowse.ch"
#include "Dbstruct.ch"
#include "ide.ch"

#define MAX_CONTROL_COUNT 512


// #define MAIN_TITLE        "HMGS - IDE - 2005-2016 Walter Formigoni - http://sourceforge.net/projects/hmgs-minigui/ - OPEN SOURCE - Version 1.4.2 - "

#define MAIN_TITLE        "HMGS-IDE OPEN SOURCE - Version 1.4.2 - "
#define MAIN_TITLE2       "HMGSIDE - Version 1.4.2"
#define MsgInfo( c )      MsgInfo( c, "HMGS-IDE", , .F. )
#define MsgStop( c )      MsgStop( c, "HMGS-IDE", , .F. )
#define MsgYesNo( c, t )  MsgYesNo( c, t, .F. , , .F. )

#xcommand END TIMER =>

DECLARE WINDOW Preferences
DECLARE WINDOW Controls2
DECLARE WINDOW Controls
DECLARE WINDOW ProjectBrowser
DECLARE WINDOW ObjectInspector
DECLARE WINDOW ViewFormCode
DECLARE WINDOW BuildProcess

MEMVAR cVal       // Take out Warning W0001 Ambiguous Reference
MEMVAR xColo1
MEMVAR xValue

*------------------------------------------------------------*
PROCEDURE MAIN( Param AS STRING )
*------------------------------------------------------------*
   LOCAL  nSize                AS NUMERIC
   LOCAL  nSize2               AS NUMERIC
   LOCAL  nDesk                AS NUMERIC := GETDESKTOPWIDTH()

   PUBLIC xParam               AS USUAL   := Param                                          // Name of .fmg
   PUBLIC xArray               AS Array   := Array( MAX_CONTROL_COUNT, MAX_CONTROL_COUNT )  // (512 x 512)

   PUBLIC aData                AS Array   := { }   // Preferences Array
   PUBLIC aMenu                AS Array   := { }   // Init via LoadMenu()
   PUBLIC aToolbar             AS Array   := { }   // Init via LoadToolbar()
   PUBLIC aContext             AS Array   := { }   // Init via LoadContext()
   PUBLIC aStatus              AS Array   := { }   // Init via LoadStatus()
   PUBLIC aNotify              AS Array   := { }   // Init via LoadNotifyMenu()
   PUBLIC aDropdown            AS Array   := { }   // Init via LoadDropMenu()
   PUBLIC aLibs                AS Array   := { }   //? Not used
   PUBLIC aFormDir             AS Array   := { }   // Init via LoadFmg()
   PUBLIC PgMpPos              AS NUMERIC := 1    // Add By Pier 04/09/2006 22.37

   PUBLIC aReport              AS Array   := { }   // Initialised in ZeroaReport()

   PUBLIC xProp                AS Array   := { }
   PUBLIC nTotControl          AS NUMERIC := 0
   PUBLIC nPosControl          AS NUMERIC := 0    // Position of Control in xArray[] RetVal from xControle()
   PUBLIC aPrgNames            AS Array   := { }   // .Prg List each Pos contain { .prg, Path }
   PUBLIC aFmgNames            AS Array   := { }   // .Fmg List each Pos contain { .fmg, Path }
   PUBLIC aRcNames             AS Array   := { }   // .Rc  List each Pos contain { .rc , Path }
   PUBLIC aRptNames            AS Array   := { }   // .Rpt List each Pos contain { .rpt, Path }  Added By Pier 2006/05/19
   PUBLIC aMainModule          AS Array   := { }   // Name of Main .prg and path { .prg, Path }
   PUBLIC aModules             AS Array   := { }   // Same as PrgNames but Sorted
   PUBLIC aTempDeletedControls AS Array   := { }   //

   PUBLIC BuildType            AS STRING  := "full"      // Put in preferences
   PUBLIC DesignForm           AS STRING  := "Form_1"    //
   PUBLIC CurrentProject       AS STRING  := ""          // Name of Current .Hpj File
   PUBLIC CurrentControl       AS NUMERIC := 1
   PUBLIC CurrentControlName   AS STRING  := ""
   PUBLIC CurrentForm          AS STRING  := ""          // Name of Current .Fmg file
   PUBLIC ProjectFolder        AS STRING  := GetStartupFolder()
   PUBLIC MainHeight           AS NUMERIC := 57 + GetTitleHeight() + GetBorderHeight() + GetMenuBarHeight()
   PUBLIC xEvent               AS Array   := { }          //
   PUBLIC cFile                AS STRING  := ""          //
   PUBLIC cIniFile             AS STRING  := GetStartupFolder() + "\ide.ini"
   PUBLIC lChanges             AS LOGICAL := .F.             //
   PUBLIC lSnap                AS LOGICAL := .T.             //
   PUBLIC INDelete             AS LOGICAL := .F.             //
   PUBLIC lUpdate              AS LOGICAL := .T.             // Checked By cPreenchGrid(), ObjInsFillGrid()
   PUBLIC lBuildUpdate         AS LOGICAL := .T.             //
   PUBLIC lDisabled            AS LOGICAL := .F.             //
   PUBLIC ProcessFrameOk       AS LOGICAL := .F.             //
   PUBLIC mFound               AS LOGICAL := .F.             // Help File Found
   PUBLIC MainType             AS STRING  := "1"             //? complete description
   PUBLIC MainEditor           AS STRING  := "NOTEPAD.EXE"   // Name of editor default is "NOTEPAD.EXE"
   PUBLIC cTextNotes           AS STRING  := ""              //
   PUBLIC aXControls           AS Array   := { "", "BUTTON", "CHECKBOX", "LISTBOX", "COMBOBOX", "CHECKBUTTON", "GRID", "SLIDER", "SPINNER", ;
                                               "IMAGE", "TREE", "DATEPICKER", "TEXTBOX", "EDITBOX", "LABEL", "BROWSE", "RADIOGROUP",      ;
                                               "FRAME", "TAB", "ANIMATEBOX", "HYPERLINK", "MONTHCALENDAR", "RICHEDITBOX", "PROGRESSBAR", ;
                                               "PLAYER", "IPADDRESS", "TIMER", "BUTTONEX", "COMBOBOXEX", "BTNTEXTBOX", "HOTKEYBOX",      ;
                                               "GETBOX", "TIMEPICKER", "QHTM", "TBROWSE", "ACTIVEX", "PANEL", "CHECKLABEL", "CHECKLISTBOX" }
   PUBLIC aError               AS Array   := { }              // Error Line during Build process (Mpmc & hbmk2)
   PUBLIC aLinesPrg            AS Array   := { }              //? complete description

   PUBLIC aUciNames            AS Array                      // UCI Names
   PUBLIC aUciControls         AS Array   := { }              // UCI Control
   PUBLIC aUciProps            AS Array   := { }              // UCI Property
   PUBLIC aUciEvents           AS Array   := { }              // UCI Event
   PUBLIC LenUci               AS NUMERIC := 0               // UCI
   PUBLIC aItens               AS Array   := Array( 45 )     //
   PUBLIC aTbrowse             AS Array   := { }              //
   PUBLIC aOTbrowse            AS Array   := { }              //
   PUBLIC VLHASH               AS ARRAY   := HB_HASH()        //

   PUBLIC A1                   AS STRING                     //
   PUBLIC Ans                  AS LOGICAL                    // Needed in Form_1.fmg / Form_2.fmg

   AAdd( aTbrowse , Array( 1 ) )
   AAdd( aOTbrowse, Array( 1 ) )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Set Working Environment
   SET MULTIPLE OFF       WARNING
   SET PROGRAMMATICCHANGE OFF
   SET NAVIGATION         EXTENDED
   SET FONT TO "Arial" , 10

   SET DATE               BRITISH
   SET CENTURY            ON

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Load Preferences
   LoadPreferences()

   ////////////////////ADDITIONAL  LIBRARIES IN MENU OPTION  TOOLS/PREFERENCES
   //c:\minigui\LIB\TSBROWSE.LIB
   //C:\MINIGUI\HARBOUR\LIB\HBTIP.LIB
   //C:\BORLAND\BCC55\LIB\PSDK\WS2_32.LIB
   //C:\BORLAND\BCC55\LIB\PSDK\iphlpapi.lib

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Set Help file
   IF File( aData[ _MG_FOLDER ] + "\doc\minigui.chm" )
      SET HELPFILE TO aData[ _MG_FOLDER ] + "\doc\MINIGUI.CHM"
      mFound := .T.
   ELSEIF ! IsVistaOrLater() .AND. File( aData[ _MG_FOLDER ] + "\doc\MINIGUI.HLP" )
      SET HELPFILE TO aData[ _MG_FOLDER ] + "\doc\MINIGUI.HLP" // CONTRIBUTION OF JANUSZ PORA - MINIGUI.HLP
      mFound := .T.
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Load Window Form (Controls, projectBrowser, Object Inspector
   MainType := aData[ _LAYOUT ]

   IF MainType == "1"
      LOAD WINDOW Controls
      Controls.Title            := MAIN_TITLE + " " + hb_ProgName() + " " + DToC( FileDate( GetExeFileName() ) ) + " " + FileTime( GetExeFileName() )
      Controls.xCombo_1.Enabled := .F.  // UCI
      * Begin por Luiz F.B.Escobar  (alterado)
      Controls.Width        := nDesk
      // Controls.XTab_3.Width := nDesk - Controls.XTab_3.Col - 10
      * END
   ELSE
      LOAD WINDOW Controls2 AS Controls
      Controls.Title := MAIN_TITLE2
   ENDIF

   LOAD WINDOW ProjectBrowser

   LOAD WINDOW ObjectInspector

//LOAD WINDOW LOGFORM

   ProjectBrowser.Title  := "Project Browser [ ]"
   ObjectInspector.Title := "Object Inspector [ ]"

   IF ! wSizeRest()
      nSize               := Controls.Height + 1
      nSize2              := ProjectBrowser.Height
      ProjectBrowser.Row  := nSize
      ObjectInspector.Row := IIf( xParam == NIL, nSize + nSize2, nSize )
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ProcessKeys()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xParam == NIL
      DEFINE TIMER Timer_1 OF Controls INTERVAL 250 ACTION ( Controls.SetFocus, Controls.Timer_1.Release )
      END TIMER
      ACTIVATE WINDOW Controls, ProjectBrowser, ObjectInspector // ,LOGFORM
   ELSE
      IF File( xParam + ".fmg" )
         DEFINE MAIN MENU OF controls
            DEFINE POPUP "&File"
               MENUITEM "&Save Form"      ACTION SaveForm()
               MENUITEM "&Exit to caller" ACTION Run()
            END POPUP
            DEFINE POPUP "&Help"
               MENUITEM "&About"  ACTION MsgInfo( "HMGS - IDE - 2005-2016 Walter Formigoni" + CRLF + ;
                        "http://sourceforge.net/projects/hmgs-minigui/ - OPEN SOURCE" )
               MENUITEM "&Manual" ACTION manual()
            END POPUP
         END MENU

         Controls.xButtonEx_3.ToolTip := "Exit to caller"
         Controls.xButtonEx_6.ToolTip := "Save Form"
         Controls.xButtonEx_1.Enabled := .F.
         Controls.xButtonEx_2.Enabled := .F.
         Controls.xButtonEx_4.Enabled := .F.
         Controls.xButtonEx_5.Enabled := .F.

         LoadFmg()

         MAXIMIZE WINDOW Controls
         ACTIVATE WINDOW Controls, ObjectInspector, Form_1
      ENDIF
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE CopyClip()
*------------------------------------------------------------*
   LOCAL FORM      AS STRING
   LOCAL cControl  AS STRING
   LOCAL Prop      AS STRING
   LOCAL cVal      AS STRING

   FORM     := SubStr( CurrentForm, 1, ( At( ".", CurrentForm ) - 1 ) )
   cControl := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   IF ObjectInspector.XTab_2.Value     = 1
      Prop  := GetColValue( "XGRID_1", "ObjectInspector", 1 )

   ELSEIF ObjectInspector.XTab_2.Value = 2
      Prop  := GetColValue( "XGRID_2", "ObjectInspector", 1 )

   ELSEIF ObjectInspector.XTab_2.Value = 3
      Prop  := GetColValue( "XGRID_3", "ObjectInspector", 1 )

   ENDIF

   IF Upper( cControl ) # "FORM"
      cVal := FORM + "." + cControl + "." + Prop
   ELSE
      cVal := FORM + "." + cVal
   ENDIF

// MsgBox( "cVal= " + Form + "." + cControl + "." + Prop )

   CopyToClipboard( cVal )

   RETURN


*-----------------------------------------------------------------------------*
PROCEDURE VerifyForm()
*-----------------------------------------------------------------------------*
   LOCAL aFormDirNew AS Array   := { }
   LOCAL x           AS NUMERIC
   LOCAL cPath       AS STRING
   LOCAL FORM        AS STRING

   x := ProjectBrowser.xList_2.Value

   cPath := aFmgNames[ x, 2 ]
   FORM  := aFmgNames[ x, 1 ]

   IF File( cPath + FORM )

      aFormDirNew := Directory( cPath + FORM )

      IF ( DToS( aFormDirNew[ 1, 3 ] ) + aFormDirNew[ 1, 4 ] ) > ( DToS( aFormDir[ 1, 3 ] ) + aFormDir[ 1, 4 ] )
         aFormDir := aFormDirNew

         fLoadFmg()
      ENDIF

   ENDIF

   RETURN


*-----------------------------------------------------------------------------*
PROCEDURE BuildMenu()
*-----------------------------------------------------------------------------*
   DEFINE MAIN MENU OF controls
      DEFINE POPUP "File"
         MENUITEM "New Project"              ACTION NEW()                 IMAGE "NEW"
         MENUITEM "Open Project"             ACTION Open()                IMAGE "OPEN"
         SEPARATOR
         DEFINE POPUP "Recent Projects"
            MRUITEM File ( cIniFile ) SECTION "MRUFiles" ACTION mnuMRU_Click( NewItem ) ITEMS 8
         END POPUP
         MENUITEM "&Clear Recent Projects"   ACTION  ClearMRUList()
         SEPARATOR
         MENUITEM "Close Project"            ACTION ProjectClose()        IMAGE "CLOSE"
         SEPARATOR
         MENUITEM "Save Form"                ACTION SaveForm()            IMAGE "SAVE"
         MENUITEM "Save Form && Close"        ACTION ( SaveForm(), CloseForm() ) IMAGE "SAVE"
         MENUITEM "Close Form (No SAVE!)"    ACTION CloseForm()
         SEPARATOR
         MENUITEM "Exit"                     ACTION EXIT()                IMAGE "EXIT"
      END POPUP

      DEFINE POPUP "Edit"
         MENUITEM "Delete Control"           ACTION xDeleteControl()      IMAGE "DELETE"
         SEPARATOR
         MENUITEM "Change Control Order"     ACTION ControlOrder()
         SEPARATOR
         MENUITEM "Snap To Grid"             ACTION SnapChange() NAME SNAPMENU CHECKED
         SEPARATOR
         DEFINE POPUP "Delete Special Object"
            MENUITEM "Main Menu"             ACTION DeleteSpecial( 1 )
            MENUITEM "Toolbar"               ACTION DeleteSpecial( 2 )
            MENUITEM "Context Menu"          ACTION DeleteSpecial( 3 )
            MENUITEM "Status Bar"            ACTION DeleteSpecial( 4 )
            MENUITEM "Notify Menu"           ACTION DeleteSpecial( 5 )
            MENUITEM "Dropdown Menu"         ACTION DeleteSpecial( 6 )
         END POPUP
         SEPARATOR
         MENUITEM "Edit Source Code"         ACTION ViewFormCode()        IMAGE "VIEW"
      END POPUP

      DEFINE POPUP "View"
         MENUITEM "Form Code"                ACTION ViewFormCode( .T. )     IMAGE "VIEW"
         MENUITEM "ProjectBrowser"           ACTION { || ProjectBrowser.Restore , ProjectBrowser.Show, ProjectBrowser.SetFocus }
         MENUITEM "ObjectInspector"          ACTION { || ObjectInspector.Restore , ObjectInspector.Show, ObjectInspector.SetFocus }
         MENUITEM "Design Form"              ACTION zform1()
      END POPUP

      DEFINE POPUP "Project"
         MENUITEM "Build (Incremental)"      ACTION Test_Build( "NODEBUG" )
         MENUITEM "Build (Non Incremental)"  ACTION Test_Build( "NODEBUG", "/C" )
         MENUITEM "Build (With HBMK2)"       ACTION Hbmk2Build()
         SEPARATOR
         MENUITEM "Run"                      ACTION Run()                 IMAGE "RUN"
         MENUITEM "Debug"                    ACTION Test_Build( "DEBUG" )
         SEPARATOR
         MENUITEM "New Form"                 ACTION NewForm()             IMAGE "NEWFORM"
         MENUITEM "Add Form"                 ACTION AddForm()
         SEPARATOR
         MENUITEM "New Module"               ACTION NewModule()           IMAGE "NMODULE"
         MENUITEM "Add Module"               ACTION AddModule()
         SEPARATOR
         MENUITEM "New Resource"             ACTION NewResource()
         MENUITEM "Add Resource"             ACTION AddResource()
         SEPARATOR
         MENUITEM "New Report"               ACTION NewReport()
         MENUITEM "Add Report"               ACTION AddReport()
         MENUITEM "Refresh Report View"      ACTION RefreshReport()
         SEPARATOR
         MENUITEM "Edit Item"                ACTION EditItem()
         MENUITEM "Exclude Item"             ACTION DeleteItem()
         SEPARATOR
         MENUITEM "Set Module As Main"       ACTION SetModuleAsMain()
      END POPUP

      DEFINE POPUP "Tools"
         DEFINE POPUP "Builders"
            MENUITEM "Main Menu"              ACTION MenuBuilder( "MAIN" )
            MENUITEM "Status Bar"             ACTION MenuBuilder( "STATUSBAR" )   // StatusbarBuilder()
            MENUITEM "Context Menu"           ACTION MenuBuilder( "CONTEXT" )
            MENUITEM "Tool Bar"               ACTION MenuBuilder( "TOOLBAR" )     // ToolbarBuilder()
            MENUITEM "Drop Down Menu"         ACTION MenuBuilder( "DROPDOWN" )    // DropDownMenuBuilder()
            MENUITEM "Notify Menu"            ACTION MenuBuilder( "NOTIFY" )
         END POPUP
         SEPARATOR
         MENUITEM "Preferences"              ACTION Preferences()         IMAGE "PREFERENCES"
      END POPUP

      DEFINE POPUP "Help"
         MENUITEM "About"                    ACTION MsgInfo( "HMGS - IDE - 2005-2016 Walter Formigoni" + CRLF + ;
                  "http://sourceforge.net/projects/hmgs-minigui/ - OPEN SOURCE" )
         SEPARATOR
         MENUITEM "Manual"                   ACTION Manual()              IMAGE "HELPBMP"
         MENUITEM "&Update"                  ACTION Update()
/* TO DEBUG ONLY
        MENUITEM "&View xArray"             ACTION aBrowseAC( xArray, "xArray" )
*/
      END POPUP
   END MENU

   RETURN


*-----------------------------------------------------------------------------*
PROCEDURE ProcessKeys()
*-----------------------------------------------------------------------------*
   LOCAL aControls AS Array   := { "CONTROLS", "ProjectBrowser", "ObjectInspector" }
   LOCAL x         AS NUMERIC

   MEMVAR XCONTROLE

   FOR x := 1 TO 3
      XCONTROLE := aControls[ x ]

      ON KEY F1  OF &XCONTROLE ACTION MsgInfo( "F1-SHOW HELP OF HOT KEYS" + CRLF + ;
                                               "F2-SHOW OBJECT INSPECTOR" + CRLF + ;
                                               "F3-SHOW PROJECT BROWSER"  + CRLF + ;
                                               "F4-BUILD EXE"             + CRLF + ;
                                               "F5-RUN EXE"               + CRLF + ;
                                               "F6-SHOW FORM"             + CRLF + ;
                                               "F7-SHOW HMGS-IDE"         + CRLF )

      ON KEY F2 OF &XCONTROLE ACTION { || ObjectInspector.Show, ObjectInspector.SetFocus }
      ON KEY F3 OF &XCONTROLE ACTION { || ProjectBrowser.Show, ProjectBrowser.SetFocus }
      ON KEY F4 OF &XCONTROLE ACTION TEST_BUILD( "NODEBUG" )
      ON KEY F5 OF &XCONTROLE ACTION Run()
      ON KEY F6 OF &XCONTROLE ACTION zForm1()
      ON KEY F7 OF &XCONTROLE ACTION { || Controls.Show, Controls.SetFocus }

   NEXT x

   RETURN


*------------------------------------------------------------*
PROCEDURE zform1()
*------------------------------------------------------------*
   IF ISWINDOWDEFINED( Form_1 )
      DOMETHOD( "FORM_1", "RESTORE"  )
      DOMETHOD( "FORM_1", "SHOW"     )
      DOMETHOD( "FORM_1", "SETFOCUS" )
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE ZeroControls()
*------------------------------------------------------------*
   // SL : 8/24/2011 1:04:15 PM
   // Don't redeclare public only assign them to initial value
   // Declared in Main()

   aMenu        := { }
   aToolbar     := { }
   aContext     := { }
   aStatus      := { }
   aNotify      := { }
   aDropdown    := { }

   // UCI
   aUciControls := { }
   aUciProps    := { }
   aUciEvents   := { }
   LenUci       := 0

   ZeroaReport()

   RETURN


*-----------------------------------------------------------------------------*
PROCEDURE ZeroaReport()
*-----------------------------------------------------------------------------*
   // SL: 8/24/2011 1:02:33 PM
   // Take out PUBLIC definition here an put it in Main()
   aReport := { "'Your Title|Title 2'", "{},{}", "", "", "", "", "", "", "", "", "", "", "DMPAPER_A4", "", "", "", "", "", .F., .F., .F., .F., .F., .F. }
   RETURN


*-----------------------------------------------------------------------------*
FUNCTION AddControl1( ControlType AS STRING )
*-----------------------------------------------------------------------------*
   LOCAL VAR    AS NUMERIC := 0
   LOCAL xName  AS STRING
   LOCAL h      AS USUAL   := GetFormHandle( "Form_1" )

   DO WHILE .T.
      VAR ++

      xName := ControlType + LTrim( Str( VAR ) )

      // MsgBox( "xName= " + xName )

      IF AScan( _HMG_aControlNames, { | x, i | IIf( ValType( x ) == "C", Upper( x ) == Upper( xName ) .AND. _HMG_aControlParenthandles[ i ] == h, "StatusBar" ) } ) == 0
         IF _IsControlDefined( xName, "Form_1" )
            DOMETHOD( "Form_1", xName, "Release" )
         ENDIF
         EXIT
      ENDIF
   ENDDO

   lChanges := .T.
   lUpdate  := .F.

   RETURN( xName )


*------------------------------------------------------------*
PROCEDURE AddControl()
*------------------------------------------------------------*
   LOCAL aName       AS Array
   LOCAL i           AS NUMERIC
   LOCAL ControlName AS STRING
   LOCAL SupMin      AS NUMERIC := 99999999
   LOCAL iMin        AS NUMERIC := 0
   LOCAL cFrame      AS NUMERIC
   LOCAL cName       AS STRING

// MsgBox( "CurrentControl= " + Str( CurrentControl ) )
// SetProperty( "FORM_1", "TITLE", "CurrentControl= " + Str( CurrentControl ) )
   DO CASE

   CASE CurrentControl == 1
      FOR i := 1 TO Len( _HMG_aControlHandles )

    // if    _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )
    //  msgbox('value of i = ' + str(i) + ' control = '+ _HMG_aControlType[ i ] + ' controls = ' + str( Len( _HMG_aControlHandles )) )
    // endif

      IF  _HMG_aControlType[ i ] # "TOOLBAR"   .AND.  _HMG_aControlType[ i ] # "TOOLBUTTON"
         IF ( _HMG_MouseRow  >= _HMG_aControlRow[ i ] )                            .AND. ;
            ( _HMG_MouseRow  <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] ) .AND. ;
            ( _HMG_MouseCol  >= _HMG_aControlCol[ i ] )                            .AND. ;
            ( _HMG_MouseCol  <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )  .AND. ;
            _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )           .AND. ;
            _HMG_aControlType[ i ] == "FRAME"                                      .AND. ;
            IsWindowVisible( _HMG_aControlHandles[ i ] )

            IF SupMin > _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
               SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
               iMin := i
            ENDIF
         ENDIF
      ENDIF
      NEXT i

      IF iMin != 0
         i := iMin
         cFrame := 1
         cpreencheGrid( _HMG_aControlNames[ i ] )
      ELSE
         cFrame := 0
      ENDIF

   CASE CurrentControl == 2
      ControlName := AddControl1( "Button_" )
      @ SnapRow(), SnapCol() BUTTON &ControlName OF Form_1 CAPTION ControlName ACTION cpreencheGrid() TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 3
      ControlName := AddControl1( "Check_" )
      @ SnapRow(), SnapCol() CHECKBOX &ControlName OF Form_1 CAPTION ControlName TOOLTIP ControlName ON CHANGE cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 4
      ControlName := AddControl1( "List_" )
      aName       := { ControlName }
      @ SnapRow(), SnapCol() LISTBOX &ControlName OF Form_1 WIDTH 100 HEIGHT 100 ITEMS aName TOOLTIP ControlName ON CHANGE cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 5
      ControlName := AddControl1( "Combo_" )
      aName       := { ControlName }
      @ SnapRow(), SnapCol() COMBOBOXEX &ControlName OF Form_1 WIDTH 100 HEIGHT 100 ITEMS aName VALUE 1 TOOLTIP ControlName  NOTABSTOP ON GOTFOCUS cpreencheGrid( This.name ) // ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 6
      ControlName := AddControl1( "CheckBtn_" )
      @ SnapRow(), SnapCol() CHECKBUTTON &ControlName OF Form_1 CAPTION ControlName  TOOLTIP ControlName ON CHANGE cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 7
      ControlName := AddControl1( "Grid_" )
      aName       := { { ControlName , "" } }
      @ SnapRow(), SnapCol() GRID &ControlName OF Form_1 HEADERS { "Column1", "Column2" } WIDTHS { 60, 60 } ITEMS aName TOOLTIP ControlName   ON GOTFOCUS cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 8
      ControlName := AddControl1( "Slider_" )
      @ SnapRow(), SnapCol() SLIDER &ControlName OF Form_1 RANGE 1, 10 VALUE 5 TOOLTIP ControlName     ON CHANGE cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 9
      ControlName := AddControl1( "Spinner_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF FORM_1  VALUE ControlName  ACTION  { || ControlFocus(), cpreencheGrid() } WIDTH 100  HEIGHT 24   TOOLTIP ControlName BACKCOLOR WHITE  CLIENTEDGE VSCROLL
      ProcessContainers( ControlName )

   CASE CurrentControl == 10
      ControlName := AddControl1( "Image_" )
      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1 PICTURE "BITMAP48"  WIDTH 100 HEIGHT 100  VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid()  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 11
      ControlName := AddControl1( "Tree_" )
      DEFINE TREE &ControlName OF Form_1 At  SnapRow(), SnapCol() WIDTH 100 HEIGHT 100 TOOLTIP ControlName ON GOTFOCUS cpreencheGrid()
         NODE "Item 1" ID 10
            TREEITEM "Item 1.1" ID 11
            TREEITEM "Item 1.2" ID 12
            TREEITEM "Item 1.3" ID 13
         END NODE
         NODE "Item 2" ID 20
            TREEITEM "Item 2.1" ID 21
            TREEITEM "Item 2.2" ID 22
            TREEITEM "Item 2.3" ID 23
         END NODE
      END TREE
      ProcessContainers( ControlName )

   CASE CurrentControl == 12
      ControlName := AddControl1( "DatePicker_" )
      @ SnapRow(), SnapCol() DATEPICKER &ControlName OF Form_1 TOOLTIP ControlName     ON GOTFOCUS cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 13
      ControlName := AddControl1( "Text_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF FORM_1 VALUE ControlName  ACTION  { || ControlFocus(), cpreencheGrid() } WIDTH 120 HEIGHT 24  TOOLTIP ControlName BACKCOLOR WHITE CLIENTEDGE
      ProcessContainers( ControlName )

   CASE CurrentControl == 14
      ControlName := AddControl1( "Edit_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF FORM_1  VALUE ControlName  ACTION  { || ControlFocus(), cpreencheGrid() } WIDTH 120  HEIGHT 120    TOOLTIP ControlName BACKCOLOR WHITE CLIENTEDGE  HSCROLL VSCROLL
      ProcessContainers( ControlName )

   CASE CurrentControl == 15
      ControlName := AddControl1( "Label_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF Form_1 VALUE ControlName ACTION  { || ControlFocus(), cpreencheGrid() } BACKCOLOR { 228, 228, 228 } TOOLTIP ControlName
      DOMETHOD( "Form_1", ControlName, "Refresh" )
      ProcessContainers( ControlName )

   CASE CurrentControl == 16
      ControlName := AddControl1( "Browse_" )
      cName       := { ControlName, "" }
      @ SnapRow(), SnapCol() GRID &ControlName OF Form_1 HEADERS cName WIDTHS { 120, 120 } ITEMS { { "", "" } } TOOLTIP ControlName  ON GOTFOCUS  cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 17
      ControlName := AddControl1( "RadioGroup_" )
      @ SnapRow(), SnapCol() RADIOGROUP &ControlName OF Form_1 OPTIONS { "Option 1", "Option 2" } WIDTH 120  ON CHANGE cpreencheGrid( ControlName )  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 18
      ControlName := AddControl1( "Frame_" )
      @ SnapRow(), SnapCol() FRAME  &ControlName OF Form_1 CAPTION ControlName OPAQUE
      DOMETHOD( "FORM_1", "SETFOCUS" )
      ProcessContainers( ControlName )

   CASE CurrentControl == 19
      ControlName := AddControl1( "Tab_" )
      DEFINE TAB &ControlName OF Form_1 At SnapRow(), SnapCol() WIDTH 150 HEIGHT 120 VALUE 1 FONT "Arial" SIZE 9 TOOLTIP ControlName ON CHANGE { || ControlFocus(), cpreencheGrid() }
         PAGE "Page 1"
         END PAGE
         PAGE "Page 2"
         END PAGE
      END TAB
      ProcessContainers( ControlName )

   CASE CurrentControl == 20
      ControlName := AddControl1( "Animate_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF Form_1 VALUE ControlName BORDER WIDTH 100 HEIGHT 50 ACTION { || ControlFocus(), cpreencheGrid() } TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 21
      ControlName := AddControl1( "HyperLink_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF Form_1 VALUE "http://sourceforge.net/projects/hmgs-minigui"  WIDTH 245 HEIGHT 28  UNDERLINE FONTCOLOR { 0, 0, 255 } ACTION { || ControlFocus(), cpreencheGrid() } TOOLTIP ControlName
      DOMETHOD( "Form_1", ControlName, "Refresh" )
      ProcessContainers( ControlName )

   CASE CurrentControl == 22
      ControlName := AddControl1( "MonthCal_" )
      @  SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1 PICTURE "BITMAP47" WIDTH 192 HEIGHT 175 VERTICAL ADJUST NOHOTLIGHT  ACTION cpreencheGrid()  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 23
      ControlName := AddControl1( "RichEdit_" )
      @ SnapRow(), SnapCol() RICHEDITBOX &ControlName OF Form_1 WIDTH 100 HEIGHT 100 VALUE  ControlName  TOOLTIP ControlName  ON GOTFOCUS cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 24
      ControlName := AddControl1( "ProgressBar_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF Form_1 VALUE ControlName BORDER WIDTH 120 HEIGHT 24 ACTION { || ControlFocus(), cpreencheGrid() } TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 25
      ControlName := AddControl1( "Player_" )
      @  SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1 PICTURE "BITMAP49" WIDTH 100 HEIGHT 100 VERTICAL ADJUST NOHOTLIGHT  ACTION cpreencheGrid()  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 26
      ControlName := AddControl1( "IpAddress_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF Form_1  VALUE ControlName BORDER WIDTH 120 HEIGHT 24 ACTION { || ControlFocus(), cpreencheGrid() } TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 27
      ControlName := AddControl1( "Timer_" )
      @ SnapRow(), SnapCol() BUTTON &ControlName OF Form_1 PICTURE "BITMAP34"  FLAT ACTION cpreencheGrid() WIDTH 32 HEIGHT 32  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 28
      ControlName := AddControl1( "ButtonEX_" )
      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1   CAPTION ControlName  PICTURE "BITMAP51"  WIDTH 120 HEIGHT 24    ACTION { || ControlFocus(), cpreencheGrid() }     FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP ControlName     BACKCOLOR WHITE
      ProcessContainers( ControlName )

   CASE CurrentControl == 29
      ControlName := AddControl1( "ComboBoxEX_" )
      @ SnapRow(), SnapCol() COMBOBOXEX &ControlName OF Form_1 ITEMS { "one", "two", "tree" } VALUE 1  WIDTH 120 HEIGHT 150  TOOLTIP ControlName ON GOTFOCUS  cpreencheGrid( ControlName )   IMAGE { "BITMAP52", "BITMAP53", "BITMAP54" } NOTABSTOP
      ProcessContainers( ControlName )

   CASE CurrentControl == 30
      ControlName := AddControl1( "BtnTextBox_" )
      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1    CAPTION ControlName PICTURE "BITMAP58"  WIDTH 120 HEIGHT 24  ACTION { || ControlFocus(), cpreencheGrid() } LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE  TOOLTIP ControlName BACKCOLOR WHITE  // Renaldo
      ProcessContainers( ControlName )

   CASE CurrentControl == 31
      ControlName := AddControl1( "HotKeyBox_" )
      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1    CAPTION  ControlName PICTURE "BITMAP48"  WIDTH 120 HEIGHT 84 VERTICAL ADJUST NOHOTLIGHT  ACTION { || ControlFocus(), cpreencheGrid() } TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 32
      ControlName := AddControl1( "GetBox_" )
      @ SnapRow(), SnapCol() LABEL &ControlName OF FORM_1 VALUE ControlName  ACTION  { || ControlFocus(), cpreencheGrid() } WIDTH 120 HEIGHT 24  TOOLTIP ControlName BACKCOLOR WHITE CLIENTEDGE
      ProcessContainers( ControlName )

   CASE CurrentControl == 33
      ControlName := AddControl1( "TimePicker_" )
      @ SnapRow(), SnapCol() TIMEPICKER &ControlName  OF FORM_1  WIDTH 80 TOOLTIP ControlName   ON GOTFOCUS cpreencheGrid()
      ProcessContainers( ControlName )

   CASE CurrentControl == 34
      ControlName := AddControl1( "QHTM_" )
      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1   CAPTION ControlName  WIDTH 120 HEIGHT 24    ACTION { || ControlFocus(), cpreencheGrid() }     FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP ControlName     BACKCOLOR WHITE
      ProcessContainers( ControlName )

   CASE CurrentControl == 35
      ControlName := AddControl1( "TBROWSE_" )

      cFile       := System.TempFolder + "\Test.dbf"

      USE ( cFile ) ALIAS Test SHARED

      @ SnapRow(), SnapCol() TBROWSE &ControlName OF Form_1  WIDTH 300 HEIGHT 300  HEADERS  "Code", "First", "Last", "Birth", "Bio" ;
      WIDTHS 50, 150, 150, 100, 200  FIELDS Test->Code, Test->First, Test->Last, Test->Birth, Test->Bio ;
      WORKAREA "TEST" TOOLTIP ControlName  ON GOTFOCUS cpreencheGrid()

      AAdd( aTbrowse[ 1 ] , ControlName )
      AAdd( aOTbrowse[ 1 ], &ControlName )
      ProcessContainers( ControlName )

   CASE CurrentControl == 36
      ControlName := AddControl1( "ActiveX_" )
      @ SnapRow(), SnapCol() BUTTONEX  &ControlName OF Form_1   CAPTION ControlName  WIDTH 120 HEIGHT 24    ACTION { || ControlFocus(), cpreencheGrid() }     FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP ControlName     BACKCOLOR WHITE
      ProcessContainers( ControlName )

   CASE CurrentControl == 37
      ControlName := AddControl1( "Panel_" )
      @  SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1   CAPTION ControlName  PICTURE "BITMAP64"  WIDTH 120 HEIGHT 60  VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid()  TOOLTIP ControlName
      ProcessContainers( ControlName )

   CASE CurrentControl == 38
      ControlName := AddControl1( "CheckLbl_" )
       @ SnapRow(), SnapCol()  BUTTONEX &ControlName OF Form_1  CAPTION ControlName  PICTURE "BITMAP58"  WIDTH 120 HEIGHT 24  ACTION { || ControlFocus(), cpreencheGrid() }     FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP ControlName     BACKCOLOR WHITE
       ProcessContainers( ControlName )

   CASE CurrentControl == 39
      ControlName := AddControl1( "CheckLst_" )
       @ SnapRow(), SnapCol() LISTBOX &ControlName OF Form_1 WIDTH 100 HEIGHT 100 ITEMS aName TOOLTIP ControlName ON CHANGE cpreencheGrid()
       ProcessContainers( ControlName )

   ENDCASE


   IF CurrentControl # 1
      IF Empty( ( Controls.xCombo_1.Item( 1 ) ) ) .OR. Controls.xCombo_1.Item( 1 ) = "User Components..."   // UCI
         StoreControlVal( ControlName )
      ELSE
         // MsgBox( "Adding user components" )
         ControlName := AddUci()
         IF ControlName # NIL
            UciFillGrid( ControlName )
         ENDIF
      ENDIF                                                 // UCI END
      // Control_Click( 1 )
   ELSE
      IF cFrame = 0
         ObjectInspector.xCombo_1.Value := 1
         xpreencheGrid()
      ENDIF
   ENDIF

   RETURN


*------------------------------------------------------------*
FUNCTION AddUci()
*------------------------------------------------------------*
   LOCAL ControlName AS STRING
   LOCAL cValue      AS STRING  := Controls.xCombo_1.Value

   IF ! Empty( cValue )
      cValue      := Controls.xCombo_1.Item( Controls.xCombo_1.Value ) + "_"
      ControlName := AddControl1( cValue )

      @ SnapRow(), SnapCol() BUTTONEX &ControlName OF Form_1   CAPTION ControlName  WIDTH 120 HEIGHT 24    ACTION { || ControlFocus(), UCIFillGrid( this.name ) }     FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP ControlName     BACKCOLOR WHITE

      ProcessContainers( ControlName )
      UciToArray( ControlName )

   ENDIF

   RETURN( ControlName )


*------------------------------------------------------------*
FUNCTION DifRow()
*------------------------------------------------------------*
   LOCAL RetVal AS NUMERIC := DifRowCol( "ROW" )
   RETURN( RetVal )


*------------------------------------------------------------*
FUNCTION DifCol()
*------------------------------------------------------------*
   LOCAL RetVal AS NUMERIC := DifRowCol( "COL" )
   RETURN( RetVal )


*------------------------------------------------------------*
FUNCTION DifRowCol( Param AS STRING )
*------------------------------------------------------------*
   LOCAL h       AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL nRetVal AS NUMERIC := 0
   LOCAL nDifRow AS NUMERIC := GetScrollPos( h, 1 )
   LOCAL nDifCol AS NUMERIC := GetScrollPos( h, 0 )

   IF Param = "ROW"
      nRetVal := nDifRow
   ELSEIF Param = "COL"
      nRetVal := nDifCol
   ENDIF

   IF lSnap
      nRetVal := Int( nRetVal / 10 ) * 10
   ENDIF

   RETURN( nRetVal )


*------------------------------------------------------------*
FUNCTION SnapRow()
*------------------------------------------------------------*
   LOCAL nRet AS NUMERIC

   IF ! lSnap
      nRet := _HMG_MouseRow - DifRow()
   ELSE
      nRet := Int( ( _HMG_MouseRow - DifRow() ) / 10 ) * 10
   ENDIF

   RETURN( nRet )


*------------------------------------------------------------*
FUNCTION SnapCol()
*------------------------------------------------------------*
   LOCAL nRet AS NUMERIC

   IF ! lSnap
      nRet := _HMG_MouseCol - DifCol()
   ELSE
      nRet := Int( ( _HMG_MouseCol - DifCol() ) / 10 ) * 10
   ENDIF

   RETURN( nRet )


*------------------------------------------------------------*
PROCEDURE SnapChange()
*------------------------------------------------------------*
   lSnap                     := ! lSnap
   Controls.SnapMenu.Checked := lSnap
   RETURN


*------------------------------------------------------------*
PROCEDURE ControlFocus()
*------------------------------------------------------------*
   LOCAL ControlName AS STRING := This.Name

// MsgBox( "SETFOCUS-CONTROLNAME= " + ControlName )
   DOMETHOD( "FORM_1", ControlName, "SETFOCUS" )
   RETURN


*------------------------------------------------------------*
FUNCTION xControle( pcControlName AS STRING )  // Rename to FindControlPos
*------------------------------------------------------------*
   LOCAL x       AS NUMERIC := 0
   LOCAL xArray2 AS Array   := { }

   IF pcControlName == "Form"
      RETURN( x )
   ENDIF

   FOR x := 1 TO nTotControl
      // MsgBox( "nTotControl= "      + Str( nTotControl )     )
      // MsgBox( "nTotControl= "      + Str( nTotControl ) + " x= " + Str( x ) )
      // MsgBox( "valtype xArray= " + ValType( xArray )    )
      // MsgBox( "len= "            + Str( Len( xArray ) ) )
      // MsgBox( "A1= "             + xArray[ x, 1 ]       )
      // MsgBox( "A2= "             + xArray[ x, 2 ]       )
      // MsgBox( "A3= "             + xArray[ x, 3 ]       )
      IF ! Empty( xArray[ x, 3 ] )
         AAdd( xArray2, Upper( xArray[ x, 3 ] ) ) // ARRAY with name of controls & uci
      ENDIF
   NEXT x

   x := aScan2( xArray2, Upper( pcControlName ) )   // UCI

   RETURN( x )


*------------------------------------------------------------*
PROCEDURE AddResource()
*------------------------------------------------------------*
   LOCAL ic          AS NUMERIC
   LOCAL xPosRc      AS NUMERIC //? Invalid Hungarian
   LOCAL x           AS NUMERIC
   LOCAL xPos        AS NUMERIC //? Invalid Hungarian
   LOCAL cPath       AS STRING
   LOCAL cOpen       AS STRING  := aData[ _RESOURCEPATH ]
   LOCAL AddResource AS STRING
   LOCAL xRcName     AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ic          := ProjectBrowser.xlist_3.ItemCount
   AddResource := GETFILE( { { "*.rc", "*.rc" } } , "Add Resource", cOpen, .F., .T. )
   xPos        := RAt( "\", AddResource )

   IF xPos > 0
      xRcName := SubStr( AddResource, xPos + 1, Len( AddResource ) )
      cPath   := SubStr( AddResource, 1, xPos )
   ELSE
      xRcName := ""
      cPath   := ""
   ENDIF

   IF Empty( xRcName )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aData[ _RESOURCEPATH ] := SubStr( AddResource, 1, xPos-1 )

   SavePreferences()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ic > 0
      FOR x := 1 TO ic
         IF Upper( xRcName ) == Upper( ProjectBrowser.xlist_3.Item( x ) )
            MsgStop( "Resource Already in Project" )
            RETURN
         ENDIF
      NEXT x

      IF ic = 1 .AND. Empty( ProjectBrowser.xlist_3.Item( 1 ) )
         ProjectBrowser.xlist_3.DeleteAllitems
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   AAdd( aRcNames, { xRcName, cPath } )

   aSort2( aRcNames )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Erase all items and reload RC Names
   ProjectBrowser.xlist_3.DeleteAllitems

   FOR x := 1 TO Len( aRcNames )
      ProjectBrowser.xlist_3.AddItem( aRcNames[ x, 1 ] )
      IF aRcNames[ x, 1 ] = xRcName
         xPosRc := x
      ENDIF
   NEXT x

   ProjectBrowser.xlist_3.Value := xPosRc

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   RETURN


*------------------------------------------------------------*
PROCEDURE AddModule()
*------------------------------------------------------------*
   LOCAL ic             AS NUMERIC            // Item Count in ProjectBrowse.xList_1
   LOCAL xPosPrg        AS NUMERIC
   LOCAL x              AS NUMERIC
   LOCAL cOpen          AS STRING  := aData[ _MODULEPATH ]
   LOCAL AddModule      AS STRING
   LOCAL xPos           AS NUMERIC
   LOCAL xPrgName       AS STRING
   LOCAL cPath          AS STRING
   LOCAL aTempPrgNames  AS Array

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ic := ProjectBrowser.xlist_1.ItemCount

   AddModule := GETFILE( { { "*.prg", "*.prg" } }, "Add Module", cOpen, .F., .T. )

   xPos := RAt( "\", AddModule )

   IF xPos > 0
      xPrgName := SubStr( AddModule, xPos + 1, Len( AddModule ) )
      cPath    := SubStr( AddModule, 1, xPos )
   ELSE
      xPrgName := ""
      cPath    := "" //? Should it be "<ProjectFolder>\" instead
   ENDIF

   IF Empty( xPrgName )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// MsgBox( "cPath= " + cPath )
   aData[ _MODULEPATH ] := SubStr( AddModule, 1, xPos-1 )

   SavePreferences()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF
// MsgBox( "cPath= " + cPath )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ic = 0
      ProjectBrowser.xlist_1.AddItem( xPrgName + " (Main)" )
      AAdd( aPrgNames, { xPrgName, cPath } )
      aMainModule := { { xPrgName, cPath } }
   ELSE
      FOR x := 1 TO ic
         IF Upper( xPrgName ) $ Upper( ProjectBrowser.xlist_1.Item( x ) )
            MsgStop( "Module Already in Project" )
            RETURN
         ENDIF
      NEXT x

      AAdd( aPrgNames, { xPrgName, cPath } )
      AAdd( aModules , { xPrgName, cPath } )

      aSort2( aModules )

      ProjectBrowser.xlist_1.DeleteAllitems

      ProjectBrowser.xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )

      FOR x := 1 TO Len( aModules )
         ProjectBrowser.xlist_1.AddItem( aModules[ x, 1 ] )
      NEXT x

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      // Load ProjectBrowse.xList_1 keeping Main() prg in 1st Position
      aTempPrgNames := {}

      FOR x := 2 TO Len( aPrgNames )
         AAdd( aTempPrgNames, { aPrgNames[ x, 1 ], aPrgNames[ x, 2 ] } )
      NEXT x

      aSort2( aTempPrgNames )

      ASize( aPrgNames, 1 )

      AEval( aTempPrgNames, { | x | AAdd( aPrgNames, { x[ 1 ], x[ 2 ] } ) } )

      FOR x := 2 TO ProjectBrowser.xlist_1.ItemCount
         IF ProjectBrowser.xlist_1.Item( x ) = xPrgName
            xPosPrg := x
         ENDIF
      NEXT x

      ProjectBrowser.xlist_1.Value := xPosPrg

   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   RETURN


*------------------------------------------------------------*
PROCEDURE AddForm()
*------------------------------------------------------------*
   LOCAL ic       AS NUMERIC
   LOCAL xPosFmg  AS NUMERIC
   LOCAL x        AS NUMERIC
   LOCAL xPos     AS NUMERIC  //? Invalid Hungarian
   LOCAL cPath    AS STRING
   LOCAL cOpen    AS STRING  := aData[ _FORMPATH ]
   LOCAL AddForm  AS STRING
   LOCAL xFmgName AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ic      := ProjectBrowser.xlist_2.ItemCount
   AddForm := GETFILE( { { "*.fmg", "*.fmg" } } , "Add Form", cOpen, .F., .T. )

// MsgBox( "ADDFORM= " + ADDFORM )
   xPos := RAt( "\", AddForm )
   IF xPos > 0
      cPath    := SubStr( AddForm, 1, xPos )
      xFmgName := SubStr( AddForm, xPos + 1, Len( AddForm ) )
   ELSE
      cPath    := GETCURRENTFOLDER() + "\"
      xFmgName := StrTran( AddForm, cPath, "" )
   ENDIF

   IF Empty( xFmgName )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aData[ _FORMPATH ] := SubStr( AddForm, 1, xPos-1 )

   SavePreferences()
// MsgBox( " cPath= " + cPath + " ProjectFolder= " + ProjectFolder )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ic > 0
      FOR x := 1 TO ic
         IF Upper( xFmgName ) == Upper( ProjectBrowser.xlist_2.Item( x ) )
            MsgStop( "Form Already in Project", xFmgName )
            RETURN
         ENDIF
      NEXT x

      IF ic = 1 .AND. Empty( ProjectBrowser.xlist_2.Item( 1 ) )
         ProjectBrowser.xlist_2.DeleteAllitems
      ENDIF
   ENDIF

   AAdd( aFmgNames, { xFmgName, cPath } )

   aSort2( aFmgNames )

   ProjectBrowser.xlist_2.DeleteAllitems

   FOR x := 1 TO Len( aFmgNames )
      ProjectBrowser.xlist_2.AddItem( aFmgNames[ x, 1 ] )
      IF aFmgNames[ x, 1 ] = xFmgName
         xPosFmg := x
      ENDIF
   NEXT x

   ProjectBrowser.xlist_2.Value := xPosFmg

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   RETURN


*------------------------------------------------------------*
PROCEDURE AddTables()
// Pete D. 04-07-2010
//? to be implement
*------------------------------------------------------------*


*------------------------------------------------------------*
//PROCEDURE AddHeaders()
// Pete D. 04-07-2010
//? to be implement
*------------------------------------------------------------*


*------------------------------------------------------------*
PROCEDURE LoadPicture()
*------------------------------------------------------------*
   LOCAL LoadPicture AS STRING := GETFILE( { { "*.bmp", "*.bmp" }, { "*.ico", "*.ico" }, { "*.jpg", "*.jpg" }, { "*.gif", "*.gif" } } , "Add Picture" , ProjectFolder, .F., .T. )

   IF ! Empty( LoadPicture )
      SETPROPERTY( "xGridPropTxt", "TEXT_1", "VALUE", LoadPicture )
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE NEW()
*------------------------------------------------------------*
   LOCAL RetProject AS STRING
   LOCAL xName      AS STRING        // Name of hpj File

   RetProject := Putfile( { { "*.hpj", "*.hpj" } } , "New Project", ProjectFolder, , , , .T. ) // prompt on overwrite. p.d. 12/05/2016

   IF Empty( RetProject )
      RETURN
   ENDIF

   aPrgNames      := { }
   aFmgNames      := { }
   aRcNames       := { }
   aRptNames      := { }
   aModules       := { }
   CurrentProject := RetProject
   ProjectFolder  := GETCURRENTFOLDER()
   xName          := StrTran( CurrentProject, ProjectFolder + "\", "" )
   cIniFile       := SubStr( CurrentProject, 1, ( Len( CurrentProject ) - 4 ) ) + ".ini"

   MemoWrit( CurrentProject, "" )

   ProjectBrowser.Title :=  "Project Browser [" + xName + "]"

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Clear all ProjectBrowser.xList_*
   ProjectBrowser.xlist_1.DeleteAllitems
   ProjectBrowser.xlist_2.DeleteAllitems
   ProjectBrowser.xlist_3.DeleteAllitems              // Renaldo
   ProjectBrowser.xlist_4.DeleteAllitems              // Renaldo
//TBC : ProjectBrowser.xlist_5.DeleteAllitems //SL : For Tables   .DBF
//TBC : ProjectBrowser.xlist_6.DeleteAllitems //SL : For Includes .CH

   ObjectInspector.xCombo_1.DeleteAllitems

   CloseForm()

   RETURN


*------------------------------------------------------------*
PROCEDURE ProjectClose()
*------------------------------------------------------------*
   IF xParam # NIL
      ReleaseAllWindows()
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.Title == "Project Browser [ ]"
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF aData[ _DISABLEWARNINGS ] = ".F."
      IF MsgYesNo( "Are You Sure?", "Close Project" ) == .F.
         RETURN
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Form_1 )
      RELEASE WINDOW Form_1
   ENDIF

   IF ISWINDOWDEFINED( ViewFormCode )
      RELEASE WINDOW ViewFormCode
   ENDIF

   IF ISWINDOWDEFINED( _ControlPos_ )
      RELEASE WINDOW _ControlPos_
   ENDIF

   IF ISWINDOWDEFINED( ControlOrder )
      RELEASE WINDOW ControlOrder
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Clear StatusBar Data
   Controls.Statusbar.Item( 4 ) := ""
   Controls.StatusBar.Item( 5 ) := ""
   Controls.StatusBar.Item( 6 ) := ""

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Clear ProjectBrowser Data
   ProjectBrowser.Title :=  "Project Browser [ ]"

   ProjectBrowser.xlist_1.DeleteAllitems
   ProjectBrowser.xlist_2.DeleteAllitems
   ProjectBrowser.xlist_3.DeleteAllitems
   ProjectBrowser.xlist_4.DeleteAllitems

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Clear ObjectInspector Data
   ObjectInspector.Title := "Object Inspector [ ]"

   ObjectInspector.xCombo_1.DeleteAllitems
   ObjectInspector.xGrid_1.DeleteAllitems
   ObjectInspector.xGrid_2.DeleteAllitems

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Reset Control List
   xArray   := Array( MAX_CONTROL_COUNT, MAX_CONTROL_COUNT )
   lChanges := .F.

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //?
   Mnu_Act( 5 )

   RETURN


*------------------------------------------------------------*
PROCEDURE CloseForm()
*------------------------------------------------------------*

   IF ISWINDOWDEFINED( _ControlPos_ )
      IF ISWINDOWACTIVE( _ControlPos_ )
         RELEASE WINDOW _ControlPos_
      ELSE
         InteractiveCloseHandle( GetFormHandle( "_ControlPos_" ) )
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Form_1 )
      RELEASE WINDOW Form_1
   ENDIF

   IF ISWINDOWDEFINED( ControlOrder )
      RELEASE WINDOW ControlOrder
   ENDIF

   IF ISWINDOWDEFINED( ViewFormCode )
      RELEASE WINDOW ViewFormCode
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Used()
      USE
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CurrentControl               := 1
   CurrentControlName           := ""
   Controls.Statusbar.Item( 4 ) := ""
   Controls.StatusBar.Item( 5 ) := ""
   Controls.StatusBar.Item( 6 ) := ""

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ObjectInspector.Title        := "Object Inspector [ ]"
   ObjectInspector.xCombo_1.DeleteAllitems
   ObjectInspector.xGrid_1.DeleteAllitems
   ObjectInspector.xGrid_2.DeleteAllitems

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Controls.xCombo_1.Enabled := .F.  // UCI
   xArray                    := Array( MAX_CONTROL_COUNT, MAX_CONTROL_COUNT )
   lChanges                  := .F.

   RETURN


*------------------------------------------------------------*
PROCEDURE EditItem()
*------------------------------------------------------------*

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 1       // PRG
      IF ProjectBrowser.xlist_1.Value # 0
         EditPrg()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 2       // FMG
      IF ProjectBrowser.xlist_2.Value # 0
         SaveForm()
         fLoadFmg()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 3       // RESOURCE
      IF ProjectBrowser.xlist_3.Value # 0
         EditRC()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 4       // REPORT
      IF ProjectBrowser.xlist_4.Value # 0
         LoadReport()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //TBC : Table

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //TBC : Includes

   RETURN


*------------------------------------------------------------*
PROCEDURE EditFile()
*------------------------------------------------------------*

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 1       // PRG
      IF ProjectBrowser.xlist_1.Value # 0
         EditPrg()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 2       // FMG
      IF ProjectBrowser.xlist_2.Value # 0
         EditFmg()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 3       // RESOURCE
      IF ProjectBrowser.xlist_3.Value # 0
         EditRC()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTab_1.Value = 4       // REPORT
      IF ProjectBrowser.xlist_4.Value # 0
         EditRpt()
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //TBC : Table

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //TBC : Includes

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteSpecial( ITEM AS NUMERIC )
*------------------------------------------------------------*
   LOCAL cTitle AS STRING
   LOCAL lresp  AS LOGICAL

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Form_1 )

      IF ! ( ITEM = 1 .AND. Len( aMenu     ) = 0 ) .AND. ;
         ! ( ITEM = 2 .AND. Len( aToolbar  ) = 0 ) .AND. ;
         ! ( ITEM = 3 .AND. Len( aContext  ) = 0 ) .AND. ;
         ! ( ITEM = 4 .AND. Len( aStatus   ) = 0 ) .AND. ;
         ! ( ITEM = 5 .AND. Len( aNotify   ) = 0 ) .AND. ;
         ! ( ITEM = 6 .AND. Len( aDropdown ) = 0 )


         DO CASE
         CASE ITEM = 1 ; cTitle := "Main Menu"
         CASE ITEM = 2 ; cTitle := "ToolBar"
         CASE ITEM = 3 ; cTitle := "Context Menu"
         CASE ITEM = 4 ; cTitle := "StatusBar"
         CASE ITEM = 5 ; cTitle := "Notify Menu"
         CASE ITEM = 6 ; cTitle := "Dropdown Menu"
         ENDCASE

         IF aData[ _DISABLEWARNINGS ] = ".F."
            lresp := MsgYesNo( "Are You Sure?", "Delete " + cTitle )
         ELSE
            lresp := .T.
         ENDIF

         IF lresp

            IF ITEM = 1
               aMenu := { }
               DEFINE MAIN MENU OF FORM_1
               END MENU

            ELSEIF ITEM = 2
               aToolbar := { }

            ELSEIF ITEM = 3
               aContext := { }

            ELSEIF ITEM = 4
               aStatus := { }
               IF ISCONTROLDEFINED( STATUSBAR, Form_1 )
                  DOMETHOD( "FORM_1", "STATUSBAR", "RELEASE" )
               ENDIF

            ELSEIF ITEM = 5
               aNotify := { }

            ELSEIF ITEM = 6
               aDropdown := { }
            ENDIF

            lChanges := .T.

         ENDIF

      ELSE
         MsgStop( "Control Does Not Exist" )
      ENDIF

   ELSE
      NO_FORM_MSG()   // MsgStop( "No Active Form!" )
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteItem()
*------------------------------------------------------------*
   LOCAL cTitle AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xTAB_1.Value = 1
      IF aData[ _DISABLEWARNINGS ] = ".T."
         DeleteModule()
         RETURN
      ENDIF
      cTitle := "Exclude " +  ProjectBrowser.xlist_1.Item( ProjectBrowser.Xlist_1.Value )
      IF MsgYesNo( "Are You Sure?", cTitle ) == .T.
         DeleteModule()
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF ProjectBrowser.xTAB_1.Value = 2
      IF aData[ _DISABLEWARNINGS ] = ".T."
         DeleteForm()
         RETURN
      ENDIF
      cTitle := "Exclude " +  ProjectBrowser.xlist_2.Item( ProjectBrowser.Xlist_2.Value )
      IF MsgYesNo( "Are You Sure?", cTitle ) == .T.
         DeleteForm()
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF ProjectBrowser.xTAB_1.Value = 3
      IF aData[ _DISABLEWARNINGS ] = ".T."
         DeleteResource()
         RETURN
      ENDIF
      cTitle := "Exclude " +  ProjectBrowser.xlist_3.Item( ProjectBrowser.Xlist_3.Value )
      IF MsgYesNo( "Are You Sure?", cTitle ) == .T.
         DeleteResource()
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF ProjectBrowser.xTAB_1.Value = 4
      IF aData[ _DISABLEWARNINGS ] = ".T."
         DeleteReport()
         RETURN
      ENDIF
      cTitle := "Exclude " +  ProjectBrowser.xlist_4.Item( ProjectBrowser.Xlist_4.Value )
      IF MsgYesNo( "Are You Sure?", cTitle ) == .T.
         DeleteReport()
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      // TBC : Table

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      // TBC : Includes


   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteForm()
*------------------------------------------------------------*
   LOCAL aTempFmgNames AS Array   := { }
   LOCAL A1            AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A1 := ProjectBrowser.xlist_2.Value

   IF A1 = 0
      RETURN
   ENDIF

   aFmgNames[ A1, 1 ] := NIL

   AEval( aFmgNames, { | x | IIf( x[ 1 ] # NIL, AAdd( aTempFmgNames, x ), "" ) } )

   aFmgNames := { }

   ProjectBrowser.xlist_2.DeleteAllitems

   aSort2( aTempFmgNames )

   AEval( aTempFmgNames, { | x | ( ProjectBrowser.xlist_2.AddItem( x[ 1 ] ), AAdd( aFmgNames, { x[ 1 ], x[ 2 ] } ) ) } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( FORM_1 )
      lChanges := .F.
      RELEASE WINDOW FORM_1
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ObjectInspector.Title := "Object Inspector [ ]"

   ObjectInspector.xCombo_1.DeleteAllitems
   ObjectInspector.xGrid_1.DeleteAllitems
   ObjectInspector.xGrid_2.DeleteAllitems

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteModule()
*------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL nitem     AS NUMERIC
   LOCAL cDeleted  AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.Xlist_1.ItemCount > 1

      IF ProjectBrowser.Xlist_1.Value = 1
         // MsgBox( "aMainModule1= " + aMainModule[ 1, 1 ] + " aMainModule2= " + aMainModule[ 1, 2 ] )
         // MsgBox( "new value1= "+ProjectBrowser.Xlist_1.Item(2)+ " newvalue2= "+aPrgNames[ 2, 2 ])

         cDeleted := aMainModule[ 1, 1 ]
         // MsgBox( "oldvalue= " + aMainModule[ 1, 1 ] + " deleted from aPrgNames" )

         aMainModule := { { ProjectBrowser.Xlist_1.Item( 2 ), aPrgNames[ 2, 2 ] } }
         // MsgBox( "aMainModule1= " + aMainModule[ 1, 1 ] + " aMainModule2= "+aMainModule[1,2] )

         ProjectBrowser.Xlist_1.DeleteItem( 1 )
         // MsgBox( "newvalue= "+ProjectBrowser.Xlist_1.Item(1)+ " deleted from amodules")

         DeleteArray( aPrgNames, cDeleted )
         DeleteArray( aModules, ProjectBrowser.Xlist_1.Item( 1 ) )

      ELSE
         nitem    := ProjectBrowser.Xlist_1.Value
         cDeleted := ProjectBrowser.Xlist_1.Item( nitem )

         ProjectBrowser.Xlist_1.DeleteItem( nitem )

         DeleteArray( aPrgNames, cDeleted )
         DeleteArray( aModules,  cDeleted )

      ENDIF

      aSort2( aModules )

      ProjectBrowser.Xlist_1.DeleteAllitems
      ProjectBrowser.Xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )

      FOR x := 1 TO Len( aModules )
         ProjectBrowser.Xlist_1.AddItem( aModules[ x, 1 ] )
      NEXT x

      //aEval(aModules,{|x|ProjectBrowser.Xlist_1.AddItem([ x, 1 ]) )

   ELSE
      ProjectBrowser.Xlist_1.DeleteItem( ProjectBrowser.Xlist_1.Value )

      aMainModule := { }
      aPrgNames   := { }
      aModules    := { }

   ENDIF

   SaveModules()

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteArray( param1 AS Array, param2 AS STRING )
*------------------------------------------------------------*
   LOCAL x          AS NUMERIC
   LOCAL aTempArray AS Array   := AClone( param1 )

   FOR x := 1 TO Len( param1 )

      // MsgBox( "x= " + str(x) )
      // MsgBox( "value= " + aPrgNames[x,1] )

      IF aTempArray[ x, 1 ] = param2
         ADel( param1, x )
         ASize( param1, ( Len( param1 ) - 1 ) )
         EXIT
      ENDIF

   NEXT x

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteResource()
*------------------------------------------------------------*
   LOCAL x             AS NUMERIC
   LOCAL atempresource AS Array   := { }
   LOCAL A1            AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A1 := ProjectBrowser.Xlist_3.Value

   ProjectBrowser.Xlist_3.DeleteItem( ProjectBrowser.Xlist_3.Value )

   aRcNames[ A1, 1 ] := NIL

   AEval( aRcNames, { | x | IIf( x[ 1 ] # NIL, AAdd( atempresource, { x[ 1 ], x[ 2 ] } ), "" ) } )

   aRcNames := { }

   aSort2( atempresource )

   AEval( atempresource, { | x | ( ProjectBrowser.xlist_3.AddItem( x ), AAdd( aRcNames, { x[ 1 ], x[ 2 ] } ) ) } )

   aSort2( aRcNames )

   ProjectBrowser.Xlist_3.DeleteAllitems

   FOR x := 1 TO Len( aRcNames )
      ProjectBrowser.Xlist_3.AddItem( aRcNames[ x, 1 ] )
   NEXT x

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   RETURN


*------------------------------------------------------------*
PROCEDURE SetModuleAsMain()
*------------------------------------------------------------*
   LOCAL A1            AS NUMERIC
   LOCAL A2            AS STRING
   LOCAL xPosPrg       AS NUMERIC   := 1
   LOCAL x             AS NUMERIC
   LOCAL aTempPrgNames AS Array

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A1 := ProjectBrowser.Xlist_1.Value

   IF A1 > 0

      A2 := aMainModule[ 1 ]

      FOR x := 1 TO Len( aPrgNames )
         IF aPrgNames[ x, 1 ] = ProjectBrowser.Xlist_1.Item( A1 )
            xPosPrg := x
         ENDIF
      NEXT x

      aPrgNames[ 1 ]       := aPrgNames[ xPosPrg ]
      aMainModule[ 1 ]     := aPrgNames[ 1 ]
      aPrgNames[ xPosPrg ] := A2

      ProjectBrowser.xlist_1.DeleteAllitems
      aModules := { }

      FOR x := 2 TO Len( aPrgNames )
         AAdd( aModules, { aPrgNames[ x, 1 ], aPrgNames[ x, 2 ] } )
      NEXT x

      aSort2( aModules )

      ProjectBrowser.xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )

      FOR x := 1 TO Len( aModules )
         ProjectBrowser.xlist_1.AddItem( aModules[ x, 1 ] )
      NEXT x

      aTempPrgNames := AClone( aPrgNames )

      ASize( aPrgNames, 1 )

      FOR x := 2 TO ProjectBrowser.Xlist_1.ItemCount
         AAdd( aPrgNames, { ProjectBrowser.Xlist_1.Item( x ), aTempPrgNames[ x, 2 ] } )
      NEXT x

      ProjectBrowser.xlist_1.Value := 1

      ProjectBrowser.xlist_1.SetFocus()

      SaveModules()

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE NewForm()
*------------------------------------------------------------*
   LOCAL NewForm     AS STRING
   LOCAL xPos        AS NUMERIC
   LOCAL cPath       AS STRING
   LOCAL xFmgName    AS STRING
   LOCAL x           AS NUMERIC
   LOCAL xPosFmg     AS NUMERIC //? Invalid Hungarian
   LOCAL h           AS NUMERIC
   LOCAL BaseRow     AS NUMERIC
   LOCAL BaseCol     AS NUMERIC
   LOCAL BaseWidth   AS NUMERIC
   LOCAL BaseHeight  AS NUMERIC
   LOCAL aFormProp   AS Array
   LOCAL aFormEvent  AS Array

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Form_1 )
      RELEASE WINDOW Form_1
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   DO EVENTS

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ZeroControls()

   nTotControl := 0

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   NewForm := PUTFILE( { { "*.fmg", "*.fmg" } } , "New Form", ProjectFolder )
   // MsgBox("newForm= " + NewForm)

   xPos := RAt( "\", NewForm )

   IF xPos > 0
      xFmgName := SubStr( NewForm, xPos + 1, Len( NewForm ) )
      xFmgName := Left( xFmgName, Len( xFmgName ) - 4 )
      cPath    := SubStr( NewForm, 1, xPos )
   ELSE
      xFmgName := ""
      cPath    := ""
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF
   // MsgBox( "cPath= " + cPath )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Empty( xFmgName ) // REVISED BY PIER 2005.11.06
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.xlist_2.ItemCount > 0
      FOR x := 1 TO ProjectBrowser.xlist_2.ItemCount

         IF Empty( ProjectBrowser.xlist_2.Item( x ) ) // Clear EMPTY items REVISED BY PIER 2006.05.21
            ProjectBrowser.xlist_2.DeleteItem( x )
         ENDIF

         IF Upper( xFmgName ) + ".fmg" == Upper( ProjectBrowser.xlist_2.Item( x ) ) // == CLAUSOLE REVISED BY PIER 2005.11.06
            MsgStop( "Form Already in Project" )
            RETURN
         ENDIF
      NEXT x
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CurrentForm := xFmgName + ".fmg"

   ObjectInspector.xCombo_1.DeleteAllitems
   ObjectInspector.xCombo_1.AddItem( "Form" )

   ObjectInspector.xCombo_1.Value := 1
   ObjectInspector.Title          := "Object Inspector [" + xFmgName + ".fmg" + "]"

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   AAdd( aFmgNames, { xFmgName + ".fmg", cPath } )
   ProjectBrowser.xlist_2.DeleteAllitems

   aSort2( aFmgNames )

   FOR x := 1 TO Len( aFmgNames )
      ProjectBrowser.xlist_2.AddItem( aFmgNames[ x, 1 ] )
      IF Upper( aFmgNames[ x, 1 ] ) = Upper( xFmgName ) + ".FMG"    // Renaldo
         xPosFmg := x
      ENDIF
   NEXT x

   ProjectBrowser.xlist_2.Value := xPosFmg

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveModules()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   /* CRITICAL! "IF" line added to avoide to overwrite existent form
                 in the case it is selected  -Pete 26/03/2013 */
   IF ! File( xFmgName + ".fmg" )

      IF ! ISWINDOWDEFINED( Form_1 )

         LOAD WINDOW FORM_1

         _DisableMenuItem( "PtaB", "Form_1" )

         h          := GetFormHandle( DesignForm )
         BaseRow    := GetWindowRow( h )
         BaseCol    := GetWindowCol( h )
         BaseWidth  := GetWindowWidth( h )
         BaseHeight := GetWindowHeight( h )

         Controls.Statusbar.Item( 4 ) := "r:" + AllTrim( Str( BaseRow   ) ) + " c:" + AllTrim( Str( BaseCol    ) )
         Controls.Statusbar.Item( 5 ) := "w:" + AllTrim( Str( BaseWidth ) ) + " h:" + AllTrim( Str( BaseHeight ) )

         aFormProp := { { "AutoRelease"  , ".T."                            }, ;
                        { "BackColor"    , "NIL"                            }, ;
                        { "Break"        , ".F."                            }, ;
                        { "Col"          , AllTrim( Str( BaseCol ) )        }, ;
                        { "Cursor"       , ""                               }, ;
                        { "Focused"      , ".F."                            }, ;
                        { "GripperText"  , ".F."                            }, ;
                        { "Height"       , AllTrim( Str( BaseHeight ) )     }, ;
                        { "HelpButton"   , ".F."                            }, ;
                        { "Icon"         , ""                               }, ;
                        { "MaxButton"    , ".T."                            }, ;
                        { "MinButton"    , ".T."                            }, ;
                        { "MinWidth"     , "NIL"                            }, ;
                        { "MinHeight"    , "NIL"                            }, ;
                        { "MaxWidth"     , "NIL"                            }, ;
                        { "MaxHeight"    , "NIL"                            }, ;
                        { "NotifyIcon"   , ""                               }, ;
                        { "NotifyTooltip", ""                               }, ;
                        { "Palette"      , ".F."                            }, ;
                        { "Row"          , AllTrim( Str( BaseRow ) )        }, ;
                        { "Sizable"      , ".T."                            }, ;
                        { "SysMenu"      , ".T."                            }, ;
                        { "Title"        , ""                               }, ;
                        { "TitleBar"     , ".T."                            }, ;
                        { "TopMost"      , ".F."                            }, ;
                        { "Visible"      , ".T."                            }, ;
                        { "Width"        , AllTrim( Str( BaseWidth ) )      }, ;
                        { "WindowType"   , "STANDARD"                       }, ;
                        { "VirtualWidth" , "NIL"                            }, ;
                        { "VirtualHeight", "NIL"                            }, ;
                        { "Font"         , "NIL"                            }, ;
                        { "Size"         , "NIL"                            } ;
                      }

         ObjectInspector.xGrid_1.DeleteAllitems
         xProp := { }

         AEval( aFormProp, { | x | AAdd( xProp, x[ 2 ] ) } )

         aFormEvent := { { "OnGotFocus" , "NIL" }, { "OnHScrollBox", "NIL" }, { "OnInit"              , "NIL" }, { "OnInteractiveClose", "NIL" }, ;
                         { "OnLostFocus", "NIL" }, { "OnMaximize"  , "NIL" }, { "OnMinimize"          , "NIL" }, { "OnMouseClick"      , "NIL" }, ;
                         { "OnMouseDrag", "NIL" }, { "OnMouseMove" , "NIL" }, { "OnNotifyClick"       , "NIL" }, { "OnPaint"           , "NIL" }, ;
                         { "OnRelease"  , "NIL" }, { "OnScrollDown", "NIL" }, { "OnScrollLeft"        , "NIL" }, { "OnScrollRight"     , "NIL" }, ;
                         { "OnScrollUp" , "NIL" }, { "OnSize"      , "NIL" }, { "OnVScrollBox"        , "NIL" }, { "OnRestore"         , "NIL" }, ;
                         { "OnMove"     , "NIL" }, { "OnDropFiles" , "NIL" }, { "OnNotifyBalloonClick", "NIL" }  }

         ObjectInspector.xGrid_2.DeleteAllitems

         xEvent := { }

         AEval( aFormEvent, { | x | AAdd( xEvent, x[ 2 ] ) } )

         LoadFormProps()

         aStatus := { }

         SaveForm()

         Form_1.Activate()

      ENDIF

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE AddSizeForm()
*------------------------------------------------------------*
   LOCAL X1          AS USUAL                                     //? Vartype
   LOCAL h           AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL BaseRow     AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol     AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth   AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight  AS NUMERIC := GetWindowHeight( h )

   Controls.Statusbar.Item( 4 ) := "r:" + AllTrim( Str( BaseRow   ) ) + " c:" + AllTrim( Str( BaseCol    ) )
   Controls.Statusbar.Item( 5 ) := "w:" + AllTrim( Str( BaseWidth ) ) + " h:" + AllTrim( Str( BaseHeight ) )

   if ObjectInspector.xCombo_1.Value # 1
      ObjectInspector.xCombo_1.Value := 1
      xpreencheGrid()
   endif

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   X1 := ObjectInspector.xGrid_1.Value

   ObjectInspector.xGrid_1.Value := NposObject( "Col" )       //16
   SetColValue( "XGRID_1", "ObjectInspector", 2, AllTrim( Str( BaseCol ) ) )

   ObjectInspector.xGrid_1.Value := NposObject( "Height" )    //4
   SetColValue( "XGRID_1", "ObjectInspector", 2, AllTrim( Str( BaseHeight ) ) )

   ObjectInspector.xGrid_1.Value := NposObject( "Row" )       //26
   SetColValue( "XGRID_1", "ObjectInspector", 2, AllTrim( Str( BaseRow ) ) )

   ObjectInspector.xGrid_1.Value := NposObject( "Width" )     //9
   SetColValue( "XGRID_1", "ObjectInspector", 2, AllTrim( Str( BaseWidth ) ) )

   ObjectInspector.xGrid_1.Value := X1

   lChanges := .T.

   RETURN


*------------------------------------------------------------*
FUNCTION NposObject( Prop AS STRING )
*------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL nRetValue AS NUMERIC
   LOCAL v1        AS NUMERIC
   LOCAL ic        AS NUMERIC := ObjectInspector.xGrid_1.ItemCount

   FOR x := 1 TO ic

      ObjectInspector.xGrid_1.Value := x
      v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

      IF v1 == Prop
         nRetValue := x
         EXIT
      ENDIF

   NEXT x

   RETURN( nRetValue )


*------------------------------------------------------------*
PROCEDURE AddRowCol()
*------------------------------------------------------------*
   //OPT: Controls.StatusBar.Item( 5 ) := Transform( _HMG_MouseRow, "9999" ) + "," + Transform( _HMG_MouseCol, "9999" )
   Controls.StatusBar.Item( 6 ) := PadL( _HMG_MouseRow, 4 ) + "," + PadL( _HMG_MouseCol, 4 )
   RETURN


*------------------------------------------------------------*
PROCEDURE Manual()
*------------------------------------------------------------*
   IF mFound
      DISPLAY HELP MAIN

   ELSEIF ! isVista()
      MsgStop( "MINIGUI.HLP or MINIGUI.CHM not found in /doc folder!" )
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE EditPrg()
*------------------------------------------------------------*
   IF ProjectBrowser.xlist_1.Value # 0

      Chk_Editor()

      IF Len( AllTrim( aPrgNames[ ProjectBrowser.xlist_1.Value, 2 ] ) ) = 0 .OR. At( "<ProjectFolder>\", aPrgNames[ ProjectBrowser.xlist_1.Value, 2 ] ) > 0
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + aPrgNames[ ProjectBrowser.xlist_1.Value, 1 ]
      ELSE
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( aPrgNames[ ProjectBrowser.xlist_1.Value, 2 ] ) + aPrgNames[ ProjectBrowser.xlist_1.Value, 1 ]
      ENDIF
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE EditFmg()
*------------------------------------------------------------*
   IF ProjectBrowser.xlist_2.Value # 0

      Chk_Editor()

      IF Len( AllTrim( aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] ) ) = 0 .OR. At( "<ProjectFolder>\", aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] ) > 0
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + aFmgNames[ ProjectBrowser.xlist_2.Value, 1 ]
      ELSE
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] ) + aFmgNames[ ProjectBrowser.xlist_2.Value, 1 ]
      ENDIF
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE EditRc()
*------------------------------------------------------------*
   IF ProjectBrowser.xlist_3.Value # 0

      Chk_Editor()

      IF Len( AllTrim( aRcNames[ ProjectBrowser.xlist_3.Value, 2 ] ) ) = 0 .OR. At( "<ProjectFolder>\", aRcNames[ ProjectBrowser.xlist_3.Value, 2 ] ) > 0
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + aRcNames[ ProjectBrowser.xlist_3.Value, 1 ]
      ELSE
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( aRcNames[ ProjectBrowser.xlist_3.Value, 2 ] ) + aRcNames[ ProjectBrowser.xlist_3.Value, 1 ]
      ENDIF
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE EditRpt()
*------------------------------------------------------------*
   IF ProjectBrowser.xlist_4.Value # 0

      Chk_Editor()

      IF Len( AllTrim( aRptNames[ ProjectBrowser.xlist_4.Value, 2 ] ) ) = 0 .OR. At( "<ProjectFolder>\", aRptNames[ ProjectBrowser.xlist_4.Value, 2 ] ) > 0
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + aRptNames[ ProjectBrowser.xlist_4.Value, 1 ]
      ELSE
         EXECUTE File MainEditor PARAMETERS  _GetShortPathName( aRptNames[ ProjectBrowser.xlist_4.Value, 2 ] ) + aRptNames[ ProjectBrowser.xlist_4.Value, 1 ]
      ENDIF
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE Open()
*------------------------------------------------------------*
   LOCAL cRetProject AS STRING
   LOCAL cOpen       AS STRING := aData[ _PROJECTPATH ]

   cRetProject := GETFILE( { { "*.hpj", "*.hpj" } } , "Open Project" , cOpen )

   IF Empty( cRetProject )
      RETURN
   ENDIF

   CurrentProject := cRetProject

   AddMRUItem( CurrentProject , "mnuMRU_Click(NewItem)" )

   OpenProject()

   RETURN   //? Should be a function and return a value RetProject ?


*------------------------------------------------------------*
PROCEDURE OpenProject()
*------------------------------------------------------------*
   LOCAL A1        AS STRING
   LOCAL x         AS NUMERIC
   LOCAL x2        AS STRING         // Content of Project File (.hpj)
   LOCAL nCount    AS NUMERIC        // Nb of Line in Project File (.hpj)
   LOCAL xName     AS STRING
   LOCAL cPath     AS STRING  := ""  // File Path
   LOCAL cFileName AS STRING         // Filename without extension
   LOCAL cExt      AS STRING         // File extension including "." ex: ".prg"
   LOCAL cFile     AS STRING         // Full filename with extension
   LOCAL nPos      AS NUMERIC := 0

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   x2                    := MemoRead( CurrentProject )
   nCount                := MLCount( x2 )
   ProjectFolder         := GETCURRENTFOLDER()
   xName                 := StrTran( CurrentProject, ProjectFolder + "\", "" )
   aData[ _PROJECTPATH ] := ProjectFolder
   cIniFile              := SubStr( CurrentProject, 1, ( Len( CurrentProject ) - 4 ) ) + ".ini"

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LoadPreferences()

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Clear Project Browser Title and clear all List (Module, Form, Resource, Report)
   ProjectBrowser.Title := "Project Browser [" + xName + "]"
   ProjectBrowser.xlist_1.DeleteAllitems
   ProjectBrowser.xlist_2.DeleteAllitems
   ProjectBrowser.xlist_3.DeleteAllitems
   ProjectBrowser.xlist_4.DeleteAllitems
//TBC : ProjectBrowser.xlist_5.DeleteAllitems // Tables
//TBC : ProjectBrowser.xlist_6.DeleteAllitems // Includes

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CloseForm()

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWDEFINED( ViewFormCode )
      RELEASE WINDOW ViewFormCode
   ENDIF

   IF ISWINDOWDEFINED( _ControlPos_ )
      RELEASE WINDOW _ControlPos_
   ENDIF

   IF ISWINDOWDEFINED( ControlOrder )
      RELEASE WINDOW ControlOrder
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aPrgNames := { }  // Modules
   aFmgNames := { }  // Forms
   aModules  := { }  // Modules
   aRcNames  := { }  // RC-Bat
   aRptNames := { }  // Reports

   ZeroaReport()    //SL was missing

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR x := 1 TO nCount

      A1 := AllTrim( MemoLine( x2, NIL, x ) )

      HB_FNameSplit( A1, @cPath, @cFileName, @cExt )

      cFile := cFileName + cExt    // reform file name then upper ext (not to change of real ext)
      cExt  := Upper( cExt )       // Upper cExt for testing

      DO CASE

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cExt == ".PRG"
         IF cPath == ProjectFolder
            cPath := "<ProjectFolder>\"
         ENDIF
         AAdd( aPrgNames, { cFile, cPath } )

         IF x = 1
            aMainModule := { { cFile, cPath } }
            // MsgBox( "amain1= " + aMainModule[ 1, 1 ] + " amain2= " + aMainModule[ 1, 2 ] )
         ELSE
            AAdd( aModules, { cFile, cPath } )
         ENDIF

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cExt == ".FMG"
         AAdd( aFmgNames, { cFile, cPath } )

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cExt == ".RC"
         AAdd( aRcNames, { cFile, cPath } )

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cExt == ".RPT"
         AAdd( aRptNames, { cFile, cPath } )

         //TBC : CASE cExt == "DBF"
         //TBC : CASE cExt == "CH"

      ENDCASE


      /*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF Upper( Right( A1, 4 ) ) == ".PRG"
         nPos := Rat( "\", A1 )
         IF nPos > 0
            cPath := SubStr( A1, 1, nPos )
            A1    := SubStr( A1, nPos + 1, Len( A1 ) )
         ELSE
            cPath := ""
         ENDIF
         // MsgBox( "A1= " + A1 + " cPath= " + cPath )

         IF cPath = ProjectFolder
            cPath := "<ProjectFolder>\"
         ENDIF

         aAdd( aPrgNames, { A1, cPath } )

         IF x = 1
            aMainModule := { { A1, cPath } }
            // MsgBox( "amain1= " + aMainModule[ 1, 1 ] + " amain2= " + aMainModule[ 1, 2 ] )
         ELSE
            aAdd( aModules, { A1, cPath } )
         ENDIF
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF Upper( Right( A1, 4 ) ) == ".FMG"
         nPos := Rat( "\", A1 )
         IF nPos > 0
            cPath := SubStr( A1, 1, nPos )
            A1    := SubStr( A1, nPos + 1, Len( A1 ) )
         ELSE
            cPath := ""
         ENDIF
         // MsgBox("cPath= "+cPath+ " A1 = "+A1)
         aAdd( aFmgNames, { A1, cPath } )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF Upper( Right( A1, 3 ) ) == ".RC"
         nPos := Rat( "\", A1 )
         IF nPos > 0
            cPath := SubStr( A1, 1, nPos )
            A1    := SubStr( A1, nPos + 1, Len( A1 ) )
         ELSE
            cPath := ""
         ENDIF
         aAdd( aRcNames, { A1, cPath } )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF Upper( Right( A1, 4 ) ) == ".RPT"
         nPos := Rat( "\", A1 )  //SL 8/24/2011 10:51:13 PM was Pos
         IF nPos > 0
            cPath := SubStr( A1, 1, nPos )
            A1    := SubStr( A1, nPos + 1, Len( A1 ) )
         ELSE
            cPath := ""
         ENDIF
         aAdd( aRptNames, { A1, cPath } )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //TBC : Table file .DBF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //TBC : Include File .CH
      */

   NEXT

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add to Xlist_1 all PRG in alphabetic order
   IF Len( aPrgNames ) > 0
      ProjectBrowser.xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )
      IF Len( aModules ) > 0
         aSort2( aModules )
         FOR x := 1 TO Len( aModules )
            ProjectBrowser.xlist_1.AddItem( aModules[ x, 1 ] )
         NEXT x
      ENDIF
      ASize( aPrgNames, 1 )
      // MsgBox( aPrgNames[1,1]+ " " + aPrgNames[1,2])

      FOR x := 2 TO ProjectBrowser.Xlist_1.ItemCount
         AAdd( aPrgNames, { ProjectBrowser.Xlist_1.Item( x ), aModules[ x - 1, 2 ] } )
      NEXT x

      ProjectBrowser.xlist_1.Value := ProjectBrowser.xlist_1.ItemCount
      ProjectBrowser.xlist_1.SetFocus()
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add to Xlist_2 all FMG in alphabetic order
   IF Len( aFmgNames ) > 0
      aSort2( aFmgNames )
      FOR x := 1 TO Len( aFmgNames )
         // MSGBOX("VALUE= "+aFmgNames[x,1])
         ProjectBrowser.xlist_2.AddItem( aFmgNames[ x, 1 ] )
      NEXT x

      ProjectBrowser.xlist_2.Value := ProjectBrowser.xlist_2.ItemCount
      ProjectBrowser.xlist_2.SetFocus()
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add to Xlist_3 all RC in alphabetic order
   IF Len( aRcNames ) > 0
      aSort2( aRcNames )
      FOR x := 1 TO Len( aRcNames )
         ProjectBrowser.xlist_3.AddItem( aRcNames[ x, 1 ] )
      NEXT x

      ProjectBrowser.xlist_3.Value := ProjectBrowser.xlist_3.ItemCount
      ProjectBrowser.xlist_3.SetFocus()
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add to Xlist_4 all RPT in alphabetic order
   IF Len( aRptNames ) > 0
      aSort2( aRptNames )
      FOR x := 1 TO Len( aRptNames )
         ProjectBrowser.xlist_4.AddItem( aRptNames[ x, 1 ] )
      NEXT x

      ProjectBrowser.xlist_4.Value := ProjectBrowser.xlist_4.ItemCount
      ProjectBrowser.xlist_4.SetFocus()
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//TBC : Add to Xlist_5 all DBF in alphabetic order

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//TBC : Add to Xlist_6 all CH in alphabetic order


   RETURN


*-----------------------------------------------------------------------------*
FUNCTION Chk_Prj( Msg AS LOGICAL )
*-----------------------------------------------------------------------------*
   LOCAL lRet AS LOGICAL := .F.

   DEFAULT Msg TO .T.

   IF ProjectBrowser.Title == "Project Browser [ ]"
      IF Msg
         NO_FORM_MSG() // MsgStop( "No Active Form!" )
      ENDIF
      lRet := .T.
   ENDIF

   RETURN( lRet )


*------------------------------------------------------------*
PROCEDURE NewResource()
*------------------------------------------------------------*
   LOCAL xRcName  AS STRING
   LOCAL cPath    AS STRING
   LOCAL x        AS NUMERIC
   LOCAL x2       AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xRcName := INPUTBOX( "Enter Name:", "New Resource", "" )
   cPath   := GETCURRENTFOLDER() + "\"

   IF Len( xRcName ) # 0
      xRcName := IIf( ( x := At( ".", xRcName ) ) > 0, Left( xRcName, x - 1 ), xRcName )
      IF  ProjectBrowser.xlist_3.ItemCount = 0
         ProjectBrowser.xlist_3.AddItem( xRcName + ".rc" )
         AAdd( aRcNames, { xRcName + ".rc", cPath } )
      ELSE
         //SL: New version but not for now
         //IF aScan( aRcNames, { |a| Upper( xRcName ) == Upper( a[ 1 ] ) } ) # 0
         //   MsgStop( "Resource Already in Project" )
         //   RETURN
         //ENDIF

         FOR x := 1 TO Len( aRcNames )
            IF Upper( xRcName ) + ".RC" = Upper( aRcNames[ x, 1 ] )
               MsgStop( "Resource Already in Project" )
               RETURN
            ENDIF
         NEXT x

         AAdd( aRcNames, { xRcName + ".rc", cPath } )
         aSort2( aRcNames )
         ProjectBrowser.xlist_3.DeleteAllitems
         FOR x := 1 TO Len( aRcNames )
            ProjectBrowser.xlist_3.AddItem( aRcNames[ x, 1 ] )
         NEXT x
      ENDIF

      x2 := "//hmgs-ide resource file created" + CRLF + ""
      MemoWrit( ProjectFolder + "\" + xRcName + ".rc", x2 )

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      SaveModules()

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Chk_Editor()

      EXECUTE File MainEditor PARAMETERS  _getshortpathname( aRcNames[ ProjectBrowser.xlist_3.ItemCount, 2 ] ) + aRcNames[ ProjectBrowser.xlist_3.ItemCount, 1 ]

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE NewModule()
*------------------------------------------------------------*
   LOCAL NewModule      AS STRING
   LOCAL xPrgName       AS STRING
   LOCAL xPosPrg        AS STRING
   LOCAL x              AS NUMERIC
   LOCAL cPath          AS STRING
   LOCAL xPos           AS NUMERIC
   LOCAL aTempPrgNames  AS Array
   LOCAL cSrc           AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   NewModule :=  PUTFILE( { { "*.prg", "*.prg" } } , "New Module" , ProjectFolder, .T. )

   IF Empty( NewModule )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xPos := RAt( "\", NewModule )

   IF xPos > 0
      xPrgName := SubStr( NewModule, xPos + 1, Len( NewModule ) )
      xPrgName := Left( xPrgName, Len( xPrgName ) - 4 )
      cPath    := SubStr( NewModule, 1, xPos )
   ELSE
      xPrgName := ""
      cPath    := ""
   ENDIF
// MsgBox( "xPrgName= " + xPrgName )
// MsgBox( "cPath= "    + cPath    )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Len( xPrgName ) # 0
      xPrgName := IIf( ( x := At( ".", xPrgName ) ) > 0, Left( xPrgName, x - 1 ), xPrgName )

      IF ProjectBrowser.xlist_1.ItemCount = 0
         aMainModule := { { xPrgName + ".prg", cPath } }
         ProjectBrowser.xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )
         ProjectBrowser.xlist_1.Value := 1
         xPosPrg := 1
         cSrc := "#include <minigui.ch>"      + CRLF + CRLF + ;
              "FUNCTION Main"                 + CRLF + CRLF + ;
              Space( 3 ) + "LOAD WINDOW Main" + CRLF +        ;
              Space( 3 ) + "Main.Center"      + CRLF +        ;
              Space( 3 ) + "Main.Activate"    + CRLF + CRLF + ;
              "RETURN( NIL )"                 + CRLF + ""
      ELSE
         FOR x := 1 TO Len( aPrgNames )
            IF Upper( xPrgName ) + ".PRG" = Upper( aPrgNames[ x, 1 ] )
               MsgStop( "Module Already in Project" )
               RETURN
            ENDIF
         NEXT x

         AAdd( aModules, { xPrgName + ".prg", cPath } )

         aSort2( aModules )

         ProjectBrowser.xlist_1.DeleteAllitems
         ProjectBrowser.xlist_1.AddItem( aMainModule[ 1, 1 ] + " (Main)" )

         FOR x := 1 TO Len( aModules )
            ProjectBrowser.xlist_1.AddItem( aModules[ x, 1 ] )
         NEXT x

         FOR x := 2 TO ProjectBrowser.xlist_1.ItemCount
            IF Upper( ProjectBrowser.xlist_1.Item( x ) ) = Upper( xPrgName ) + ".PRG"
               xPosPrg := x
            ENDIF
         NEXT x

         ProjectBrowser.xlist_1.Value := xPosPrg

         cSrc := "#include <minigui.ch>"      + CRLF + CRLF + ;
              "FUNCTION Template"             + CRLF + CRLF + ;
              "RETURN( NIL )"                 + CRLF + ""
      ENDIF

      AAdd( aPrgNames, { xPrgName + ".prg", cPath } )

      aTempPrgNames := { }

      FOR x := 2 TO Len( aPrgNames )
         AAdd( aTempPrgNames, { aPrgNames[ x, 1 ], aPrgNames[ x, 2 ] } )
      NEXT x

      aSort2( aTempPrgNames )

      ASize( aPrgNames, 1 )

      AEval( aTempPrgNames, { | x | AAdd( aPrgNames, { x[ 1 ], x[ 2 ] } ) } )

      IF ! File( xPrgName + ".prg" )   /* Avoid to overwrite an existent file */
         MemoWrit( iif( cPath = "<ProjectFolder>\", ProjectFolder + "\", cPath ) + xPrgName + ".prg", cSrc )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      SaveModules()

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Chk_Editor()

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF xPosPrg = 1
         IF cPath = "<ProjectFolder>\"
            EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + xPrgName + ".prg"
         ELSE
            EXECUTE File MainEditor PARAMETERS  _GetShortPathName( cPath )               + xPrgName + ".prg"
         ENDIF
      ELSE
         IF cPath = "<ProjectFolder>\"
            EXECUTE File MainEditor PARAMETERS  _GetShortPathName( ProjectFolder ) + "\" + aPrgNames[ xPosPrg, 1 ]
         ELSE
            EXECUTE File MainEditor PARAMETERS  _GetShortPathName( cPath )               + aPrgNames[ xPosPrg, 1 ]
         ENDIF
      ENDIF

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE SaveModules()
*------------------------------------------------------------*
   LOCAL a AS STRING := ""

   IF Len( aPrgNames ) > 0 .AND. aPrgNames[ 1, 2 ] == ""
      aPrgNames[ 1, 2 ] := "<ProjectFolder>\"
   ENDIF

   IF Len( aFmgNames ) > 0 .AND. aFmgNames[ 1, 2 ] == ""
      aFmgNames[ 1, 2 ] := "<ProjectFolder>\"
   ENDIF

   /********
   ac := ""
   FOR x := 1 TO Len( aPrgNames )
       ac += aPrgNames[ x, 2 ] + aPrgNames[ x, 1 ] + CRLF
   NEXT x
   MsgBox( ac )
   *********/

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   AEval( aPrgNames, { | x | a += x[ 2 ] + x[ 1 ] + CRLF } )
   AEval( aFmgNames, { | x | a += x[ 2 ] + x[ 1 ] + CRLF } )
   AEval( aRcNames , { | x | a += x[ 2 ] + x[ 1 ] + CRLF } )
   AEval( aRptNames, { | x | a += x[ 2 ] + x[ 1 ] + CRLF } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   MemoWrit( CurrentProject, a )

   RETURN


*------------------------------------------------------------*
FUNCTION EXIT()
*------------------------------------------------------------*
   LOCAL cSect AS STRING
   LOCAL xResp AS LOGICAL := .T.

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SaveMRUFileList()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF aData[ _DISABLEWARNINGS ] = ".F."
      IF xParam == NIL
         xResp := MsgYesNo( "Are You Sure?", "Exit" )
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xResp
      // SadStar begin --------------------------------------------
      BEGIN INI File cIniFile

         cSect := "wObjectInspector"
         SET SECTION cSect ENTRY "wRow"    TO ObjectInspector.Row
         SET SECTION cSect ENTRY "wHeight" TO ObjectInspector.Height
         SET SECTION cSect ENTRY "wCol"    TO ObjectInspector.Col
         SET SECTION cSect ENTRY "wWidth"  TO ObjectInspector.Width

         cSect := "wProjectBrowser"
         SET SECTION cSect ENTRY "wRow"    TO ProjectBrowser.Row
         SET SECTION cSect ENTRY "wHeight" TO ProjectBrowser.Height
         SET SECTION cSect ENTRY "wCol"    TO ProjectBrowser.Col
         SET SECTION cSect ENTRY "wWidth"  TO ProjectBrowser.Width

         cSect := "wMainForm"
         SET SECTION cSect ENTRY "wRow"    TO Controls.Row
         SET SECTION cSect ENTRY "wHeight" TO Controls.Height
         SET SECTION cSect ENTRY "wCol"    TO Controls.Col
         SET SECTION cSect ENTRY "wWidth"  TO Controls.Width
      END INI
      // SadStar end -----------------------------------------

      IF lChanges .AND. MsgYesNo( "You want to save the form " + CurrentForm + " ?", "HMGS-IDE" )
         SaveForm()
      ENDIF

      RELEASE WINDOW ALL

   ENDIF

   RETURN xResp


*------------------------------------------------------------*
PROCEDURE ProcessContainers( ControlName AS STRING )
*------------------------------------------------------------*
   LOCAL i           AS NUMERIC
   LOCAL ActivePage  AS NUMERIC
   LOCAL z           AS NUMERIC
   LOCAL k           AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// MsgBox( "PROCESS-CONTAINERS" )
   z := GetControlIndex( ControlName , "Form_1" )
   /* msgbox("difrow= "+str(difrow()) + "difcol = "+ str(difcol())+ " z= "+str(z) )
       msgbox("name= "+_HMG_aControlNames[z]+ "row = "+ str(_HMG_aControlRow[z])+ " col= "+ str(_HMG_aControlCol[z]))
   */
   FOR i := 1 TO Len( _HMG_aControlhandles )
      IF _HMG_aControlType[ i ] == "TAB" .AND. _HMG_aControlNames[ i ] # "XTab_1"    .AND. _HMG_aControlNames[ i ] # "XTab_2"  .AND. _HMG_aControlNames[ i ] # "XTab_3"
         IF ( _HMG_MouseRow > _HMG_aControlRow[ i ] ) .AND. ( _HMG_MouseRow < _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] ) .AND. ( _HMG_MouseCol > _HMG_aControlCol[ i ] ) .AND. ( _HMG_MouseCol < _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )
            // MsgBox("ControlName= "+ControlName+" is inside tab -> "+_HMG_aControlNames[i] )
            IF ControlName # _HMG_aControlNames[ i ]
               // MsgBox("ok is inside tab ")
               ActivePage := _GetValue( _HMG_aControlNames[ i ] , "Form_1" )
               IF _HMG_aControlType[ z ] # "RADIOGROUP"
                  AAdd( _HMG_aControlPageMap[ i, ActivePage ], GetControlHandle( ControlName, "Form_1" ) )
                  CHideControl( GetControlHandle( ControlName, "Form_1" ) )
                  CShowControl( GetControlHandle( ControlName, "Form_1" ) )
               ELSE
                  // MsgBox("radio1")
                  AAdd( _HMG_aControlPageMap[ i, ActivePage ],  _HMG_aControlhandles[ z ] )  // TO VERIFY
                  CHideControl( _HMG_aControlhandles[ z, 1 ] )
                  CShowControl( _HMG_aControlhandles[ z, 1 ] )
               ENDIF
               // Msgbox( _HMG_aControlNames[i] + " row = " + Str( _HMG_aControlRow[i] ) )
               // Msgbox( _HMG_aControlNames[i] + " col = " + Str( _HMG_aControlCol[i] ) )

               _HMG_aControlContainerRow[ z ] := _HMG_aControlRow[ i ]
               _HMG_aControlContainerCol[ z ] := _HMG_aControlCol[ i ]

               k := AScan( _HMG_aControlNames, ControlName )

               IF _HMG_aControlType[ k ] == "FRAME"      .OR. ;
                  _HMG_aControlType[ k ] == "CHECKBOX"   .OR. ;
                  _HMG_aControlType[ k ] == "RADIOGROUP"

                  _HMG_aControlRangeMin[ k ] :=  _HMG_aControlNames[ i ]  //TABNAME
                  _HMG_aControlRangeMax[ k ] := "FORM_1"

               ELSEIF _HMG_aControlType[ k ] == "SLIDER"
                  _HMG_aControlFontHandle[ k ] :=  _HMG_aControlNames[ i ]  //TABNAME
                  _HMG_aControlMiscDatA1[ k ]  := "FORM_1"
               ENDIF

               EXIT

            ENDIF
         ENDIF
      ENDIF
   NEXT i

   RETURN


*------------------------------------------------------------*
PROCEDURE Control_Click( wpar AS NUMERIC )
*------------------------------------------------------------*
   LOCAL x AS NUMERIC

   IF wpar = 1
      Controls.Statusbar.Item( 3 ) := ""
      Controls.control_40.Value  := .F.
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ! Empty( Controls.Statusbar.Item( 3 ) )
      IF xTypeControl( Controls.Statusbar.Item( 3 ) ) # aXControls[ wpar ]
         Controls.Statusbar.Item( 3 ) := ""
         Controls.Control_40.Value    := .F.
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   FOR x := 1 TO 39
      _SetValue( "Control_" + StrZero( x, 2 ), "Controls", .F. )
   NEXT


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Form_1 )
      CurrentControl := wpar
      IF wpar > 0 .AND. wpar < 40
         _SetValue( "Control_" + StrZero( wpar, 2 ), "Controls", .T. )
         OpenUci()  // UCI
      ENDIF
   ELSE
      _SetValue( "Control_01", "Controls", .T. )
      NO_FORM_MSG() // MsgStop( "No Active Form!" )
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE AddTabPage( i AS NUMERIC )
*------------------------------------------------------------*
   LOCAL CAPTION   AS STRING
   LOCAL nPos      AS NUMERIC
   LOCAL Position  AS NUMERIC

   IF i > 0
      CAPTION  := "Page " + AllTrim( Str( Len( _HMG_aControlPageMap[ i ] ) + 1 ) )
      Position := Len( _HMG_aControlPageMap[ i ] ) + 1

      _AddTabPage( _HMG_aControlNames[ i ], "Form_1", Position, CAPTION, "", "" )

      //? Document
      nPos               := xControle( _HMG_aControlNames[ i ] )
      xArray[ nPos, 47 ] := AllTrim( Str( ( Val( xArray[ nPos, 47 ] ) + 1 ) ) )
      xArray[ nPos, 49 ] := SubStr( xArray[ nPos, 49 ], 1, ( Len( xArray[ nPos, 49 ] ) - 1 ) ) + ",''}"
      xArray[ nPos, 51 ] := SubStr( xArray[ nPos, 51 ], 1, ( Len( xArray[ nPos, 51 ] ) - 1 ) ) + ",'" + CAPTION + "'}"
      xArray[ nPos, 53 ] := SubStr( xArray[ nPos, 53 ], 1, ( Len( xArray[ nPos, 53 ] ) - 1 ) ) + ",''}"

      DOMETHOD( "Form_1", _HMG_aControlNames[ i ], "SETFOCUS" )

      CurrentControlName := "TAB"

      lUpdate  := .T.

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ObjInsFillGrid()

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      lUpdate  := .F.
      lChanges := .T.

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE DeleteTabPage( i AS NUMERIC )
*------------------------------------------------------------*
   LOCAL NewMap       AS Array   := [ 0 ]
   LOCAL l            AS NUMERIC
   LOCAL TrashPage    AS Array
   LOCAL k            AS NUMERIC
   LOCAL j            AS NUMERIC
   LOCAL x            AS NUMERIC
   LOCAL nPos         AS NUMERIC
   LOCAL aVal         AS Array
   LOCAL aVal2        AS STRING
   LOCAL PAGE         AS NUMERIC

   PRIVATE cVal

   IF i > 0

      PAGE := _GetValue( _HMG_aControlNames[ i ] , "Form_1" )
      l    := Len( _HMG_aControlPageMap[ i ] )

      IF PAGE == l
         PAGE := 1
      ENDIF

      IF l == 1
         RETURN
      ENDIF

      TrashPage := _HMG_aControlPageMap[ i, l ]

      FOR j := 1 TO Len( TrashPage )

         DestroyWindow( TrashPage[ j ] )

         k := AScan( _HMG_aControlHandles, TrashPage[ j ] )

         IF k > 0
            _HMG_aControlDeleted            [ k ] := .T.
            _HMG_aControlType               [ k ] := ""
            _HMG_aControlNames              [ k ] := ""
            _HMG_aControlHandles            [ k ] := 0
            _HMG_aControlParentHandles      [ k ] := 0
            _HMG_aControlIds                [ k ] := 0
            _HMG_aControlProcedures         [ k ] := ""
            _HMG_aControlPageMap            [ k ] := { }
            _HMG_aControlValue              [ k ] :=  NIL
            _HMG_aControlInputMask          [ k ] := ""
            _HMG_aControllostFocusProcedure [ k ] := ""
            _HMG_aControlGotFocusProcedure  [ k ] := ""
            _HMG_aControlChangeProcedure    [ k ] := ""
            _HMG_aControlBkColor            [ k ] := NIL
            _HMG_aControlFontColor          [ k ] := NIL
            _HMG_aControlDblClick           [ k ] := ""
            _HMG_aControlHeadClick          [ k ] := { }
            _HMG_aControlRow                [ k ] := 0
            _HMG_aControlCol                [ k ] := 0
            _HMG_aControlWidth              [ k ] := 0
            _HMG_aControlHeight             [ k ] := 0
         ENDIF

      NEXT j

      FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] ) - 1
         AAdd( NewMap, _HMG_aControlPageMap[ i, j ] )
      NEXT j

      _HMG_aControlPageMap[ i ] := NewMap

      TabCtrl_DeleteItem( _HMG_aControlhandles[ i ] , Len( _HMG_aControlPageMap[ i ] ) )

      _SetValue( _HMG_aControlNames[ i ] , "Form_1" , PAGE )

      nPos := xControle( _HMG_aControlNames[ i ] )

      // MsgBox( "pageimages  = " +  xArray[ nPos, 49] )
      cVal := xArray[ nPos, 49 ]
      aVal := &cVal
      // MsgBox( "valtype= "+ ValType( aVal ) )
      // MsgBox( "aval= "   + aval[ 1 ] )
      // MsgBox( "len= "    + Str( Len( aVal ) )  )

      aVal2 := "{"
      FOR x := 1 TO Len( aVal ) - 1
         IF x < Len( aVal ) - 1
            aVal2 := aVal2 + "'" + aVal[ x ] + "',"
         ELSE
            aVal2 := aVal2 + "'" + aVal[ x ] + "'"
         ENDIF
      NEXT x
      aVal2 := aVal2 + "}"
      // MsgBox("aval2 = " + aVal2)

      xArray[ nPos, 49 ] := aVal2

      // MsgBox("pagecaptions  = "+  xArray[nPos,51])
      cVal := xArray[ nPos, 51 ]
      aVal := &cVal
      // MsgBox( "valtype= " + ValType(aVal) )
      // MsgBox( "aval= "    + aVal[1] )
      // MsgBox( "len= "     + Str(Len(aVal)) )
      aVal2 := "{"
      FOR x := 1 TO Len( aVal ) - 1
         IF x < Len( aVal ) - 1
            aVal2 := aVal2 + "'" + aVal[ x ] + "',"
         ELSE
            aVal2 := aVal2 + "'" + aVal[ x ] + "'"
         ENDIF
      NEXT x

      aVal2 := aVal2 + "}"

      // MsgBox("aval2 = " +aval2)
      xArray[ nPos, 51 ] := aVal2

      cVal  := xArray[ nPos, 53 ]
      aVal  := &cVal
      aVal2 := "{"

      FOR x := 1 TO Len( aVal ) - 1
         IF x < Len( aVal ) - 1
            aVal2 := aVal2 + "'" + aVal[ x ] + "',"
         ELSE
            aVal2 := aVal2 + "'" + aVal[ x ] + "'"
         ENDIF
      NEXT x

      aVal2 := aVal2 + "}"
      // MsgBox("aval2 = " +aval2)

      xArray[ nPos, 53 ] := aVal2

      xArray[ nPos, 47 ] := AllTrim( Str( ( Val( xArray[ nPos, 47 ] ) - 1 ) ) )

      DOMETHOD( "Form_1", _HMG_aControlNames[ i ], "SETFOCUS" )

      CurrentControlName := "TAB"
      lUpdate            := .T.

      ObjInsFillGrid()

      lUpdate  := .F.
      lChanges := .T.

   ENDIF

   RETURN


*------------------------------------------------------------*
FUNCTION Properties_Click( arg1 AS LOGICAL )
*------------------------------------------------------------*
   LOCAL i AS NUMERIC
   LOCAL r AS LOGICAL := .T.

   DEFAULT arg1 TO .T.

   i := AScan( _HMG_aControlhandles, GetFocus() )

   IF i > 0
      IF _HMG_aControlType[ i ] == "TAB"
         IF arg1
            TabProp( i )
         ENDIF
      ELSE
         r := .F.
         IF arg1
            MsgInfo( "Properties Available Only For Tab Control" )
         ENDIF
      ENDIF
   ENDIF

   RETURN( r )


*------------------------------------------------------------*
PROCEDURE TabProp( i )
*------------------------------------------------------------*

   DEFINE WINDOW TabProp             ;
          At 0, 0 WIDTH 240 HEIGHT 320  ;
          TITLE "Tab Properties"        ;
          MODAL                         ;
          ON INIT TabPropFill( i )

      ON KEY Escape of TabProp ACTION TabProp.Release

      @  20,  10 BUTTON button_1 CAPTION "PageCount ++"  ACTION AddTabPage( i )
      @  20, 120 BUTTON button_2 CAPTION "PageCount --"  ACTION DeleteTabPage( i )
      @  60,  10 LABEL Label_1 AUTOSIZE
      @  80,  10 COMBOBOX Combo_1
      @ 200,  10 SPINNER spinner_1 RANGE 1, 2
      @ 240,  10 BUTTON Button_3 CAPTION "CHANGE"        ACTION ChangeTabPos( TabProp.Spinner_1.Value )
      @ 240, 120 BUTTON Button_4 CAPTION "EXIT"          ACTION TabProp.Release
   END WINDOW

   CENTER WINDOW TabProp
   ACTIVATE WINDOW TabProp

   RETURN


*------------------------------------------------------------*
PROCEDURE TabPropFill( i AS NUMERIC )
*------------------------------------------------------------*
   LOCAL j             AS NUMERIC
   LOCAL k             AS NUMERIC
   LOCAL z             AS NUMERIC
   LOCAL ControlHandle AS NUMERIC
   LOCAL CurrentPage   AS NUMERIC

   TabProp.Combo_1.DeleteAllitems

   FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

      FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

         IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
            ControlHandle := _HMG_aControlPageMap[ i, j, k ]
         ELSE
            ControlHandle := _HMG_aControlPageMap[ i, j, k, 1 ] // Radio
         ENDIF

         IF ControlHandle <> 0
            z := AScan( _HMG_aControlHandles , ControlHandle )
            IF z = 0
               z :=  FindRadioName( ControlHandle )
            ENDIF
         ENDIF

         TabProp.Combo_1.AddItem( _HMG_aControlNames[ z ] )

      NEXT k

   NEXT j

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   TabProp.Combo_1.Value      := 1

   CurrentPage                := _GetValue( _HMG_aControlNames[ i ], "Form_1" )
//? What do we do with CurrentPage it's a local?

   TabProp.Label_1.Value      := _HMG_aControlNames[ i ]
   TabProp.Spinner_1.RangeMax := j - 1
   TabProp.Button_3.Enabled   := ( TabProp.Combo_1.ItemCount > 0 )
   lUpdate                    := .F.

   RETURN


*------------------------------------------------------------*
PROCEDURE ChangeTabPos( nrPagina AS NUMERIC )
*------------------------------------------------------------*
   LOCAL TabName       AS STRING
   LOCAL ControlName   AS STRING
   LOCAL ParentForm    AS STRING
   LOCAL XROW          AS NUMERIC
   LOCAL XCOL          AS NUMERIC
   LOCAL i             AS NUMERIC
   LOCAL i2            AS NUMERIC
   LOCAL h             AS NUMERIC
   LOCAL j             AS NUMERIC
   LOCAL k             AS NUMERIC
   LOCAL b0            AS NUMERIC
   LOCAL b1            AS NUMERIC
   LOCAL b2            AS NUMERIC
   LOCAL x1            AS NUMERIC
   LOCAL acOptions     AS Array
   LOCAL nSpacing      AS NUMERIC
   LOCAL acBackColor   AS STRING
   LOCAL z             AS USUAL     //? VarType
   LOCAL ControlHandle AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   TabName     := TabProp.Label_1.Value
   ControlName := TabProp.Combo_1.Item( TabProp.Combo_1.Value )
   ParentForm  := "Form_1"
   i           := GetControlIndex( TabName    , ParentForm )
   i2          := GetControlIndex( ControlName, ParentForm )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xTypeControl( ControlName ) # "RADIO"
      h := GetControlHandle( ControlName, ParentForm )
   ELSE
      h := _HMG_aControlHandles[ i2, 1 ]
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   XROW := GETPROPERTY( "Form_1", ControlName, "ROW" )
   XCOL := GETPROPERTY( "Form_1", ControlName, "COL" )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

      FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] ) // page

         IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
            ControlHandle := _HMG_aControlPageMap[ i, j, k ] // handle
            // MsgBox( "controlhandle= " + Str( ControlHandle ) + " = h = " + Str(h) + " page= " + Str(j) + " = " + Str(nrpagina) )
            IF ControlHandle = h .AND. j # nrPagina

               _HMG_aControlPageMap[ i, j, k ] := 0
               DOMETHOD( "FORM_1", ControlName, "HIDE" )

               _AddTabControl( TabName, ControlName, "FORM_1", nrPagina, XROW, XCOL )
               DOMETHOD( "FORM_1", ControlName, "Show" )

            ENDIF
         ELSE
            ControlHandle := _HMG_aControlPageMap[ i, j, k, 1 ] // radio  handle
            // MsgBox( "ControlHandleRadio= "+str(controlhandle)+" = h = " + str(h)+ " page= "+str(j)+ " = "+ str(nrpagina) )

            IF ControlHandle = h .AND. j # nrPagina
               b0 := _HMG_aControlRow[ i2 ]
               b1 := _HMG_aControlCol[ i2 ]
               b2 := _HMG_aControlWidth[ i2 ]
               x1 := xControle( ControlName )

               DOMETHOD( "Form_1", ControlName, "Release" )

               acOptions   := &( xArray[ x1, 13 ] )
               nSpacing    := &( xArray[ x1, 41 ] )
               acBackColor := &( xArray[ x1, 43 ] )

               IF  xArray[ x1, 49 ] = ".T."
                  @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOptions VALUE 1 WIDTH b2 SPACING nSpacing BACKCOLOR acBackColor ON CHANGE cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName HORIZONTAL
               ELSE
                  @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOptions VALUE 1 WIDTH b2 SPACING nSpacing BACKCOLOR acBackColor ON CHANGE cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName
               ENDIF

               //z := aScan( _HMG_aControlNames, ControlName )
               z := GetControlIndex( ControlName, "Form_1" )
               _AddTabControl( TabName, ControlName, "FORM_1", nrPagina, XROW, XCOL )
            ENDIF

         ENDIF

      NEXT k

   NEXT j

   lChanges := .T.

   RETURN


*------------------------------------------------------------*
PROCEDURE ViewFormCode( READONLY AS LOGICAL )
*------------------------------------------------------------*
   LOCAL xFile  AS STRING
   LOCAL xValue AS USUAL  := GETPROPERTY( "ProjectBrowser", "xList_" + Str( ProjectBrowser.XTab_1.Value, 1 ), "value" )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   DEFAULT READONLY := .F.

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Empty( xValue )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF READONLY
      IF ! ISWINDOWDEFINED( ViewFormCode )
         LOAD WINDOW ViewFormCode
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xFile := GETPROPERTY( "ProjectBrowser", "xList_" + Str( ProjectBrowser.XTab_1.Value, 1 ), "item", xValue )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.XTab_1.Value = 1 // prg
      IF Len( AllTrim( aPrgNames[ ProjectBrowser.xlist_1.Value, 2 ] ) ) = 0 .OR. aPrgNames[ ProjectBrowser.xList_1.Value, 2 ] = "<ProjectFolder>\"
         xFile := ProjectFolder + "\" + xFile
      ELSE
         xFile := aPrgNames[ ProjectBrowser.xList_1.Value, 2 ] + "\" + xFile
      ENDIF

      IF SubStr( xFile, Len( xFile ) - 5, 6 ) = "(Main)"
         xFile := AllTrim( SubStr( xFile, 1, Len( xFile ) - 6 ) )
      ENDIF

   ELSEIF ProjectBrowser.XTab_1.Value = 2 // fmg
      IF Len( AllTrim( aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] ) ) = 0 .OR. aFmgNames[ ProjectBrowser.xList_2.Value, 2 ] = "<ProjectFolder>\"
         xFile := ProjectFolder + "\" + xFile
      ELSE
         xFile := aFmgNames[ ProjectBrowser.xList_2.Value, 2 ] + xFile
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF lChanges
      SaveForm()
      lChanges := .F.
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF READONLY
      ViewFormCode.Edit_1.Value     := MemoRead( xFile )
      ViewFormCode.Edit_1.ReadOnly  := READONLY
      ViewFormCode.Button_1.Enabled := .F.
      ViewFormCode.Label_1.Value    := xFile

      IF ! ISWINDOWACTIVE( ViewFormCode )
         CENTER WINDOW ViewFormCode
         ACTIVATE WINDOW ViewFormCode
      ELSE
         SHOW WINDOW ViewFormCode
         ViewFormCode.SetFocus
      ENDIF

   ELSE

      EditFile() // <Added by Pete 04-Jul-2010

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE MakeMenu()
*------------------------------------------------------------*
   LOCAL A1         AS STRING
   LOCAL A2         AS NUMERIC
   LOCAL x          AS NUMERIC
   LOCAL CAPTION    AS STRING
   LOCAL xName      AS NUMERIC //?Invalid Hungarian
   LOCAL cName      AS STRING
   LOCAL NAME       AS STRING
   LOCAL CHECKED    AS LOGICAL
   LOCAL Disabled   AS LOGICAL
   LOCAL cMessage   AS STRING
   LOCAL Z1         AS NUMERIC
   LOCAL Z2         AS NUMERIC
   LOCAL ACTION     AS STRING
   LOCAL IMAGE      AS STRING
   LOCAL cCaption   AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xItens := { "MAINMENU", "DEFINE MAIN MENU", "DEFINE POPUP", "MENUITEM", "ACTION", "NAME", "IMAGE", "CHECKED", "MESSAGE", "SEPARATOR", "END POPUP", "END MENU" }
   A1     := ""

   AEval( aMenu, { | x | A1 += x + CRLF } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Len( aMenu ) > 0

      FOR x := 1 TO Len( aMenu )
         A1 := AllTrim( aMenu[ x ] )
         A2 := At( "DEFINE MAIN MENU", A1 )

         IF A2 > 0
            _DefineMainMenu( "FORM_1" )
         ENDIF

         A2 := At( "DEFINE POPUP", A1 )
         IF A2 > 0
            CAPTION := SubStr( A1, 14, Len( A1 ) - 13 )
            xName   := At( "NAME", CAPTION )
            IF xName > 0
               // MsgBox( "CAPTION1= " + CAPTION )
               cCaption := SubStr( CAPTION, 1, xName - 1 )
               cName    := SubStr( CAPTION, xName + 4, Len( CAPTION ) )
               cName    := AllTrim( cName )
               CAPTION  := AllTrim( cCaption )
               // MsgBox( "CAPTION= " + Caption + " NAME= " + cName )
            ELSE
               cName := "NIL"
            ENDIF
            CAPTION := SubStr( CAPTION, 2, Len( CAPTION ) - 2 )
            NAME    := NIL
            _DefineMenuPopup( CAPTION, NAME )
         ENDIF

         A2 := At( "MENUITEM", A1 )

         IF A2 > 0
            Z1      := At( "ACTION", A1 )
            CAPTION := SubStr( A1, 10, Z1 - 11 )
            CAPTION := SubStr( CAPTION, 2, Len( CAPTION ) - 2 )
            Z2      := At( "IMAGE", A1 )

            IF Z2 > 0
               ACTION := SubStr( A1, Z1 + 7, Z2 - Z1 - 7 )
               IMAGE  := SubStr( A1, Z2 + 6, Len( A1 ) )
               IMAGE  := SubStr( IMAGE, 2, Len( IMAGE ) - 2 )
            ELSE
               ACTION := SubStr( A1, Z1 + 7, Len( A1 ) )
               IMAGE  := NIL

            ENDIF

            NAME     := NIL
            CHECKED  := .F.
            Disabled := .F.
            cMessage := ""

            _DefineMenuItem( CAPTION, ACTION, NAME, IMAGE, CHECKED, Disabled, cMessage )
         ENDIF

         A2 := At( "SEPARATOR", A1 )
         IF A2 > 0
            _DefineSeparator()
         ENDIF

         A2 := At( "END POPUP", A1 )
         IF A2 > 0
            _EndMenuPopup()
         ENDIF

         A2 := At( "END MENU", A1 )
         IF A2 > 0
            _EndMenu()
         ENDIF
      NEXT x

      SaveMRUFileList()

      BuildMenu()
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   MakeStatus()
   MakeToolbar()


   RETURN


*------------------------------------------------------------*
PROCEDURE LoadFormProps()
*------------------------------------------------------------*
   LOCAL xm         AS STRING  := "CHILD,MAIN,STANDARD,MDI"      // Add  By Pier 2006.11.26
   LOCAL h          AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL BaseRow    AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol    AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth  AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight AS NUMERIC := GetWindowHeight( h )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ObjectInspector.xGrid_1.DeleteAllitems

   ObjectInspector.xGrid_1.AddItem( { "Row"        , AllTrim( Str( BaseRow ) )         } )
   ObjectInspector.xGrid_1.AddItem( { "Col"        , AllTrim( Str( BaseCol ) )         } )
   ObjectInspector.xGrid_1.AddItem( { "Width"      , AllTrim( Str( BaseWidth ) ) } )
   ObjectInspector.xGrid_1.AddItem( { "Height"     , AllTrim( Str( BaseHeight ) )      } )

   ObjectInspector.xGrid_1.AddItem( { "AutoRelease", AllTrim( xProp[ 1 ] )             } )
   ObjectInspector.xGrid_1.AddItem( { "BackColor"  , xProp[ 2 ]                        } )
   ObjectInspector.xGrid_1.AddItem( { "Break"      , ".F."                             } )  // Only in splitchild

   ObjectInspector.xGrid_1.AddItem( { "Cursor"     , AllTrim( NoQuota( xProp[ 5 ] ) )  } )
   ObjectInspector.xGrid_1.AddItem( { "Focused"    , ".F."                             } )  // only in splitchild
   ObjectInspector.xGrid_1.AddItem( { "Font"       , AllTrim( xProp[ 31 ] )            } )
   ObjectInspector.xGrid_1.AddItem( { "GripperText", ".F."                             } )  // only in splitchild

   ObjectInspector.xGrid_1.AddItem( { "HelpButton" , AllTrim( xProp[ 9 ] )             } )
   ObjectInspector.xGrid_1.AddItem( { "Icon"       , AllTrim( noquota( xProp[ 10 ] ) ) } )

   IF At( AllTrim( xProp[ 28 ] ), xm ) > 0   // Add  By Pier 2006.11.26
      ObjectInspector.xGrid_1.AddItem( { "MaxButton", AllTrim( xProp[ 11 ] ) } )
      ObjectInspector.xGrid_1.AddItem( { "MinButton", AllTrim( xProp[ 12 ] ) } )
   ENDIF

   ObjectInspector.xGrid_1.AddItem( { "MinWidth" , AllTrim( xProp[ 13 ] ) } )
   ObjectInspector.xGrid_1.AddItem( { "MinHeight", AllTrim( xProp[ 14 ] ) } )
   ObjectInspector.xGrid_1.AddItem( { "MaxWidth" , AllTrim( xProp[ 15 ] ) } )
   ObjectInspector.xGrid_1.AddItem( { "MaxHeight", AllTrim( xProp[ 16 ] ) } )

   IF At( AllTrim( xProp[ 28 ] ), xm ) > 0   // Add  By Pier 2006.11.26
      ObjectInspector.xGrid_1.AddItem( { "NotifyIcon"   , AllTrim( noquota( xProp[ 17 ] ) ) } )
      ObjectInspector.xGrid_1.AddItem( { "NotifyTooltip", AllTrim( noquota( xProp[ 18 ] ) ) } )
   ENDIF

   ObjectInspector.xGrid_1.AddItem( { "Palette" , AllTrim( xProp[ 19 ] )            } )

   ObjectInspector.xGrid_1.AddItem( { "Size"    , AllTrim( xProp[ 32 ] )            } )
   ObjectInspector.xGrid_1.AddItem( { "Sizable" , AllTrim( xProp[ 21 ] )            } )
   ObjectInspector.xGrid_1.AddItem( { "SysMenu" , AllTrim( xProp[ 22 ] )            } )
   ObjectInspector.xGrid_1.AddItem( { "Title"   , AllTrim( NoQuota( xProp[ 23 ] ) ) } )
   ObjectInspector.xGrid_1.AddItem( { "TitleBar", AllTrim( xProp[ 24 ] )            } )

   IF At( AllTrim( xProp[ 28 ] ), xm ) > 0
      ObjectInspector.xGrid_1.AddItem( { "TopMost", AllTrim( xProp[ 25 ] ) } )
   ENDIF

   ObjectInspector.xGrid_1.AddItem( { "VirtualWidth" , AllTrim( xProp[ 29 ] )      } )
   ObjectInspector.xGrid_1.AddItem( { "VirtualHeight", AllTrim( xProp[ 30 ] )      } )
   ObjectInspector.xGrid_1.AddItem( { "Visible"      , AllTrim( xProp[ 26 ] )      } )

   ObjectInspector.xGrid_1.AddItem( { "WindowType"   , AllTrim( xProp[ 28 ] )      } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ObjectInspector.xGrid_2.DeleteAllitems

   ObjectInspector.xGrid_2.AddItem( { "OnDropFiles"       , xEvent[ 22 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnGotFocus"        , xEvent[  1 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnHScrollBox"      , xEvent[  2 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnInit"            , xEvent[  3 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnInteractiveClose", xEvent[  4 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnLostFocus"       , xEvent[  5 ] } )

   IF At( AllTrim( xProp[ 28 ] ), xm ) > 0
      ObjectInspector.xGrid_2.AddItem( { "OnMaximize", xEvent[ 6 ] } )
      ObjectInspector.xGrid_2.AddItem( { "OnMinimize", xEvent[ 7 ] } )
   ENDIF

   ObjectInspector.xGrid_2.AddItem( { "OnMouseClick", xEvent[  8 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnMouseDrag" , xEvent[  9 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnMouseMove" , xEvent[ 10 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnMove"      , xEvent[ 21 ] } )

   IF At( AllTrim( xProp[ 28 ] ), xm ) > 0
      ObjectInspector.xGrid_2.AddItem( { "OnNotifyClick", xEvent[ 11 ] } )
   ENDIF

   ObjectInspector.xGrid_2.AddItem( { "OnNotifyBalloonClick" , xEvent[ 23 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnPaint"              , xEvent[ 12 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnRelease"            , xEvent[ 13 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnRestore"            , xEvent[ 20 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnScrollDown"         , xEvent[ 14 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnScrollLeft"         , xEvent[ 15 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnScrollRight"        , xEvent[ 16 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnScrollUp"           , xEvent[ 17 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnSize"               , xEvent[ 18 ] } )
   ObjectInspector.xGrid_2.AddItem( { "OnVScrollBox"         , xEvent[ 19 ] } )


   RETURN


*------------------------------------------------------------*
PROCEDURE StoreControlVal( ControlName  )
*------------------------------------------------------------*
   LOCAL xArray1 AS ARRAY
   LOCAL i       AS NUMERIC
   LOCAL Row     AS STRING
   LOCAL Col     AS STRING
   LOCAL WIDTH   AS STRING
   LOCAL HEIGHT  AS STRING
   LOCAL nPos    AS NUMERIC
   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF CurrentControl # 1
      nTotControl += 1

      ObjectInspector.xCombo_1.AddItem( ControlName )

      ObjectInspector.xCombo_1.Value := ObjectInspector.xCombo_1.ItemCount
      i                              := GetControlIndex( ControlName, "Form_1" )

      IF _HMG_aControlContainerRow[ i ] # - 1
         Row := AllTrim( Str( _HMG_aControlRow[ i ] - _HMG_aControlContainerRow[ i ] ) )
      ELSE
         Row := AllTrim( Str( _HMG_aControlRow[ i ] ) )
      ENDIF

      IF _HMG_aControlContainerCol[ i ] # - 1
         Col := AllTrim( Str( _HMG_aControlCol[ i ] - _HMG_aControlContainerCol[ i ] ) )
      ELSE
         Col := AllTrim( Str( _HMG_aControlCol[ i ] ) )
      ENDIF

      WIDTH  := AllTrim( Str( _HMG_aControlWidth[ i ] ) )
      HEIGHT := AllTrim( Str( _HMG_aControlHeight[ i ] ) )

   ELSE
      ObjectInspector.xCombo_1.Value := 1
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xArray1       := Array( 39 )

   xArray1[  2 ] := { "BUTTON"       , "DEFINE BUTTON"       , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "CAPTION", "'" + ControlName + "'", "ACTION", "NIL", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "HELPID", "NIL", "FLAT", ".F.", "TABSTOP", ".T.", "VISIBLE", ".T.", "TRANSPARENT", ".F.", "PICTURE", "NIL", "DEFAULT", ".F.", "ICON", "NIL", "MULTILINE", ".F.", "NOXPSTYLE", ".F.","ENDPROP" }
   xArray1[  3 ] := { "CHECKBOX"     , "DEFINE CHECKBOX"     , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "CAPTION", "'" + ControlName + "'", "VALUE", ".F.", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "FIELD", "", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "TRANSPARENT", ".F.", "LEFTJUSTIFY", ".F.", "THREESTATE", ".F.","AUTOSIZE",".F.","ONENTER","NIL","ENDPROP" }
   xArray1[  4 ] := { "LISTBOX"      , "DEFINE LISTBOX"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "ITEMS", "{''}", "VALUE", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "ONDBLCLICK", "NIL", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "SORT", ".F.", "MULTISELECT", ".F.", "DRAGITEMS", ".F.","MULTITAB", ".F.", "MULTICOLUMN",".F.", "ENDPROP" }
   xArray1[  5 ] := { "COMBOBOX"     , "DEFINE COMBOBOX"     , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "ITEMS", "{''}", "VALUE", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "SORT", ".F.", "ONENTER", "NIL", "ONDISPLAYCHANGE", "NIL", "DISPLAYEDIT", ".F.", "ITEMSOURCE", "NIL", "VALUESOURCE", "", "LISTWIDTH", "", "ONLISTDISPLAY", "NIL", "ONLISTCLOSE", "NIL", "GRIPPERTEXT", "", "BREAK", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL","UPPERCASE",".F.","LOWERCASE",".F.","NONE",".T.","ENDPROP" }
   xArray1[  6 ] := { "CHECKBUTTON"  , "DEFINE CHECKBUTTON"  , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "CAPTION", "'" + ControlName + "'", "VALUE", ".F.", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "PICTURE", "NIL", "ENDPROP" }
   xArray1[  7 ] := { "GRID"         , "DEFINE GRID"         , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "HEADERS","{'Column1','Column2'}","WIDTHS","{60,60}","ITEMS",'{{"",""}}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","DYNAMICBACKCOLOR","NIL","DYNAMICFORECOLOR","NIL","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","ALLOWEDIT",".F.","ONHEADCLICK","NIL","ONCHECKBOXCLICKED","NIL","INPLACEEDIT",'""',"CELLNAVIGATION",".F.","COLUMNCONTROLS","NIL","COLUMNVALID","NIL","COLUMNWHEN","NIL","VALIDMESSAGES","NIL","VIRTUAL",".F.","ITEMCOUNT","NIL","ONQUERYDATA","NIL","MULTISELECT",".F.","NOLINES",".F.","SHOWHEADERS",".T.","NOSORTHEADERS",".F.","IMAGE","NIL","JUSTIFY","NIL","HELPID","NIL","BREAK",".F.","HEADERIMAGE",'""',"NOTABSTOP",".F.","CHECKBOXES",".F.","LOCKCOLUMNS","NIL","PAINTDOUBLEBUFFER",".F.","ENDPROP" }
   xArray1[  8 ] := { "SLIDER"       , "DEFINE SLIDER"       , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "RANGEMIN", "1", "RANGEMAX", "10", "VALUE", "0", "TOOLTIP", "''", "ONCHANGE", "NIL", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "NOTICKS", "NIL", "BACKCOLOR", "NIL", "ORIENTATION", "1", "TICKMARKS", "2", "VERTICAL", ".F.", "HORIZONTAL", ".T.", "BOTH", ".F.", "NONE", ".F.", "TOP", ".F.", "BOTTOM", ".T.", "LEFT", ".F.", "RIGHT", ".T.", "ONSCROLL", "NIL", "ENDPROP" }
   xArray1[  9 ] := { "SPINNER"      , "DEFINE SPINNER"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "RANGEMIN", "1", "RANGEMAX", "10", "VALUE", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "WRAP", ".F.", "READONLY", ".F.", "INCREMENT", "1", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "ENDPROP" }
   xArray1[ 10 ] := { "IMAGE"        , "DEFINE IMAGE"        , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "PICTURE", "", "HELPID", "NIL", "VISIBLE", ".T.", "STRETCH", ".F.", "ACTION", "NIL", "WHITEBACKGROUND", ".F.", "ONMOUSEHOVER", "NIL", "ONMOUSELEAVE", "NIL", "TRANSPARENT", ".F.", "BACKGROUNDCOLOR","NIL","ADJUSTIMAGE",".F.","TOOLTIP",'""',"ENDPROP" }
   xArray1[ 11 ] := { "TREE"         , "DEFINE TREE"         , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "0", "FONT", "Arial", "SIZE", "9", "TOOLTIP", "''", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONDBLCLICK", "NIL", "NODEIMAGES", "NIL", "ITEMIMAGES", "NIL", "NOROOTBUTTON", ".F.", "HELPID", "NIL", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "LINECOLOR", "NIL", "INDENT", "17", "ITEMHEIGHT", "18", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "BREAK", ".F.", "ITEMIDS", ".F.", "ENDPROP" }
   xArray1[ 12 ] := { "DATEPICKER"   , "DEFINE DATEPICKER"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "CTOD('')", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "ONENTER", "NIL", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "SHOWNONE", ".F.", "UPDOWN", ".F.", "RIGHTALIGN", ".F.", "FIELD", "", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "DATEFORMAT", "", "TITLEBACKCOLOR", "NIL", "TITLEFONTCOLOR", "NIL", "ENDPROP" }
   xArray1[ 13 ] := { "TEXTBOX"      , "DEFINE TEXTBOX"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "ONENTER", "NIL", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "READONLY", ".F.", "RIGHTALIGN", ".F.", "LOWERCASE", ".F.", "UPPERCASE", ".F.", "NONE", ".T.", "PASSWORD", ".F.", "MAXLENGTH", "0", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "FIELD", "NIL", "INPUTMASK", "''", "FORMAT", "''", "DATE", ".F.", "NUMERIC", ".F.", "CHARACTER", ".T.", "VALUE", "''", "CASECONVERT", ".F.", "DATATYPE", "CHARACTER","BORDER",".T.", "ENDPROP" } //? 2 Times Character is this OK
   xArray1[ 14 ] := { "EDITBOX"      , "DEFINE EDITBOX"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "''", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "READONLY", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "MAXLENGTH", "NIL", "FIELD", "NIL", "HSCROLLBAR", ".T.", "VSCROLLBAR", ".T.", "BREAK", ".F.", "ENDPROP" }
   xArray1[ 15 ] := { "LABEL"        , "DEFINE LABEL"        , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", '"' + ControlName + '"', "FONTNAME", '"Arial"', "FONTSIZE", "9", "TOOLTIP", '""', "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "VISIBLE", ".T.", "TRANSPARENT", ".F.", "ACTION", "NIL", "AUTOSIZE", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "ALIGNMENT", "1", "LEFTALIGN", ".T.", "RIGHTALIGN", ".F.", "CENTERALIGN", ".F.", "BORDER", ".F.", "CLIENTEDGE", ".F.", "HSCROLL", ".F.", "VSCROLL", ".F.", "BLINK", ".F.", "ONMOUSEHOVER", "NIL", "ONMOUSELEAVE", "NIL", "ENDPROP" }
   xArray1[ 16 ] := { "BROWSE"       , "DEFINE BROWSE"       , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT ,"HEADERS","{''}","WIDTHS","{0}","FIELDS","{''}","VALUE","0","WORKAREA","NIL","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","DYNAMICBACKCOLOR","NIL","DYNAMICFORECOLOR","NIL","FONTCOLOR","NIL","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","ALLOWEDIT",".F.","INPLACEEDIT",".F.","ALLOWAPPEND",".F.","INPUTITEMS","NIL","DISPLAYITEMS","NIL","ONHEADCLICK","NIL","WHEN","NIL","VALID","NIL","VALIDMESSAGES","NIL","PAINTDOUBLEBUFFER",".F.","READONLYFIELDS","NIL","LOCK",".F.","ALLOWDELETE",".F.","NOLINES",".F.","IMAGE","NIL","JUSTIFY","NIL","VSCROLLBAR",".T.","HELPID","NIL","BREAK",".F.","HEADERIMAGE","","NOTABSTOP",".F.","DATABASENAME","NIL","DATABASEPATH","NIL","END BROWSE"} // "INPUTMASK","NIL","FORMAT","NIL",
   xArray1[ 17 ] := { "RADIOGROUP"   , "DEFINE RADIOGROUP"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "OPTIONS", "{'Option 1','Option 2'}", "VALUE", "1", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "TRANSPARENT", ".F.", "SPACING", "25", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "LEFTJUSTIFY", ".F.", "HORIZONTAL", ".F.", "READONLY", "", "ENDPROP" }
   xArray1[ 18 ] := { "FRAME"        , "DEFINE FRAME"        , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "CAPTION", "'" + ControlName + "'", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "OPAQUE", ".T.", "INVISIBLE", ".F.", "TRANSPARENT", ".F.", "ENDPROP" }
   xArray1[ 19 ] := { "TAB"          , "DEFINE TAB"          , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "1", "FONTNAME", "'Arial'", "FONTSIZE", "9", "BOLD", ".F.", "ITALIC", ".F.", "UNDERLINE", ".F.", "STRIKEOUT", ".F.", "TOOLTIP", "''", "BUTTONS", ".F.", "FLAT", ".F.", "HOTTRACK", ".F.", "VERTICAL", ".F.", "ON CHANGE", "NIL", "BOTTOM", ".F.", "NOTABSTOP", ".F.", "MULTILINE", ".F.", "BACKCOLOR", "NIL", "PAGECOUNT", "2", "PAGEIMAGES", "{'',''}", "PAGECAPTIONS", "{'Page 1','Page 2'}", "PAGETOOLTIPS", "{'',''}", "ENDPROP" }
   xArray1[ 20 ] := { "ANIMATEBOX"   , "DEFINE ANIMATEBOX"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FILE", "''", "HELPID", "NIL", "TRANSPARENT", ".F.", "AUTOPLAY", ".F.", "CENTER", ".F.", "BORDER", ".T.", "ENDPROP" }
   xArray1[ 21 ] := { "HYPERLINK"    , "DEFINE HYPERLINK"    , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", '"http://sourceforge.net/projects/hmgs-minigui"', "ADDRESS", '"http://sourceforge.net/projects/hmgs-minigui"', "FONTNAME", '"Arial"', "FONTSIZE", "9", "TOOLTIP", '""', "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "AUTOSIZE", ".F.", "HELPID", "NIL", "VISIBLE", ".T.", "HANDCURSOR", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "RIGHTALIGN", ".F.", "CENTERALIGN", ".F.", "ENDPROP" }
   xArray1[ 22 ] := { "MONTHCALENDAR", "DEFINE MONTHCALENDAR", ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "CTOD('')", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "NOTODAY", ".F.", "NOTODAYCIRCLE", ".F.", "WEEKNUMBERS", ".F.", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "TITLEBACKCOLOR", "NIL", "TITLEFONTCOLOR", "NIL", "BACKGROUNDCOLOR", "NIL", "TRAILINGFONTCOLOR", "NIL", "BACKGROUNDCOLOR", "NIL", "ENDPROP" }
   xArray1[ 23 ] := { "RICHEDITBOX"  , "DEFINE RICHEDITBOX"  , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "''", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "READONLY", ".F.", "BACKCOLOR", "NIL", "FIELD", "NIL", "MAXLENGTH", "NIL", "FILE", "NIL", "ONSELECT", "NIL", "PLAINTEXT", ".F.", "HSCROLLBAR", ".T.", "VSCROLLBAR", ".T.", "FONTCOLOR", "NIL", "BREAK", ".F.", "ONVSCROLL", "NIL", "ENDPROP" }
   xArray1[ 24 ] := { "PROGRESSBAR"  , "DEFINE PROGRESSBAR"  , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "RANGEMIN", "1", "RANGEMAX", "10", "VALUE", "0", "TOOLTIP", "''", "HELPID", "NIL", "VISIBLE", ".T.", "SMOOTH", ".F.", "VERTICAL", ".F.", "BACKCOLOR", "NIL", "FORECOLOR", "NIL", "ORIENTATION", "1","MARQUEE",".F.","VELOCITY","40","ENDPROP" }
   xArray1[ 25 ] := { "PLAYER"       , "DEFINE PLAYER"       , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FILE", "", "HELPID", "NIL", "NOAUTOSIZEWINDOW", ".F.", "NOAUTOSIZEMOVIE", ".F.", "NOERRORDLG", ".F.", "NOMENU", ".F.", "NOOPEN", ".F.", "NOPLAYBAR", ".F.", "SHOWALL", ".F.", "SHOWMODE", ".F.", "SHOWNAME", ".F.", "SHOWPOSITION", ".F.", "ENDPROP" }
   xArray1[ 26 ] := { "IPADDRESS"    , "DEFINE IPADDRESS"    , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "{0,0,0,0}", "FONTNAME", "'Arial'", "FONTSIZE", "9", "TOOLTIP", "''", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "HELPID", "NIL", "TABSTOP", ".T.", "VISIBLE", ".T.", "ENDPROP" }
   xArray1[ 27 ] := { "TIMER"        , "DEFINE TIMER"        , ControlName,                                                           "INTERVAL", "0", "ACTION", "NIL", "ENDPROP" }
   xArray1[ 28 ] := { "BUTTONEX"     , "DEFINE BUTTONEX"     , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "CAPTION", "'" + ControlName + "'", "PICTURE", "", "ICON", "", "ACTION", "NIL", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "FONTCOLOR", "NIL", "VERTICAL", ".F.", "LEFTTEXT", ".F.", "UPPERTEXT", ".F.", "ADJUST", ".F.", "TOOLTIP", "''", "BACKCOLOR", "NIL", "NOHOTLIGHT", ".F.", "FLAT", ".F.", "NOTRANSPARENT", ".F.", "NOXPSTYLE", ".F.", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "TABSTOP", ".T.", "HELPID", "NIL", "VISIBLE", ".T.", "DEFAULT", ".F.", "HANDCURSOR", ".F.", "ENDPROP" }
   xArray1[ 29 ] := { "COMBOBOXEX"   , "DEFINE COMBOBOXEX"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "ITEMS", "", "ITEMSOURCE", "", "VALUE", "0", "VALUESOURCE", "", "DISPLAYEDIT", ".F.", "LISTWIDTH", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "TOOLTIP", "''", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONENTER", "NIL", "ONDISPLAYCHANGE", "NIL", "ONLISTDISPLAY", "NIL", "ONLISTCLOSE", "NIL", "TABSTOP", ".T.", "HELPID", "NIL", "GRIPPERTEXT", "''", "BREAK", ".F.", "VISIBLE", ".T.", "IMAGE", "", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "IMAGELIST", "", "ENDPROP" }

// 07/09/2016 p.d.  { "BTNTEXTBOX"   , "DEFINE BTNTEXTBOX"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FIELD", "", "VALUE", '""', "ACTION", "NIL", "PICTURE", '""', "BUTTONWIDTH", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "NUMERIC", ".F.", "PASSWORD", ".F.", "TOOLTIP", '""', "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "MAXLENGTH", "0", "UPPERCASE", ".F.", "LOWERCASE", ".F.", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONENTER", "NIL", "RIGHTALIGN", ".F.", "VISIBLE", ".T.", "TABSTOP", ".T.", "HELPID", "NIL", "DISABLEEDIT", ".F.", "NIL", "CHARACTER", ".F.", "NONE", ".F.", "CASECONVERT", ".F.", "ENDPROP" }
   xArray1[ 30 ] := { "BTNTEXTBOX"   , "DEFINE BTNTEXTBOX"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FIELD", "", "VALUE", '""', "ACTION", "NIL", "PICTURE", '""', "BUTTONWIDTH", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "NUMERIC", ".F.", "PASSWORD", ".F.", "TOOLTIP", '""', "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "MAXLENGTH", "0", "UPPERCASE", ".F.", "LOWERCASE", ".F.", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONENTER", "NIL", "RIGHTALIGN", ".F.", "VISIBLE", ".T.", "TABSTOP", ".T.", "HELPID", "NIL", "DISABLEEDIT", ".F.", "NIL", "CHARACTER", ".F.", "NONE", ".F.", "CASECONVERT", ".F.", '""',  "ENDPROP" }

   xArray1[ 31 ] := { "HOTKEYBOX"    , "DEFINE HOTKEYBOX"    , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "TOOLTIP", "''", "ONCHANGE", "NIL", "HELPID", "NIL", "VISIBLE", ".T.", "TABSTOP", ".T.", "ENDPROP" }
   xArray1[ 32 ] := { "GETBOX"       , "DEFINE GETBOX"       , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "FIELD", "", "VALUE", "NIL", "PICTURE", "''", "VALID", "NIL", "RANGE", "NIL", "VALIDMESSAGE", "''", "MESSAGE", "''", "WHEN", "NIL", "READONLY", ".F.", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "PASSWORD", ".F.", "TOOLTIP", "''", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "ONCHANGE", "NIL", "ONGOTFOCUS", "NIL", "ONLOSTFOCUS", "NIL", "RIGHTALIGN", ".F.", "VISIBLE", ".T.", "TABSTOP", ".T.", "HELPID", "NIL", "ACTION", "NIL", "ACTION2", "NIL", "IMAGE", "''", "BUTTONWIDTH", "0", "BORDER",".T.","NOMINUS",".F.", "ENDPROP" }
   xArray1[ 33 ] := { "TIMEPICKER"   , "DEFINE TIMEPICKER"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH,                   "VALUE", "", "FIELD", "", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "TOOLTIP", "''", "SHOWNONE", ".F.", "UPDOWN", ".F.", "TIMEFORMAT", "", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONENTER", "NIL", "HELPID", "NIL", "VISIBLE", ".T.", "TABSTOP", ".T.", "ENDPROP" }
   xArray1[ 34 ] := { "QHTM"         , "DEFINE QHTM"         , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE", "", "FILE", "", "RESOURCE", "", "ONCHANGE", "NIL", "BORDER", ".F.", "CWIDTH", "", "CHEIGHT", "", "ENDPROP" }
   xArray1[ 35 ] := { "TBROWSE"      , "DEFINE TBROWSE"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "HEADERS", "{'CODE','FIRST','LAST','MARRIED','BIRTH','BIO'}", "COLSIZES", "100,100,100,100,100,100", "WORKAREA", "TEST", "FIELDS", "'CODE','FIRST','LAST','MARRIED','BIRTH','BIO'", "SELECTFILTER", "", "FOR", "", "TO", "", "VALUE", "0", "FONTNAME", "'Arial'", "FONTSIZE", "9", "FONTBOLD", ".F.", "FONTITALIC", ".F.", "FONTUNDERLINE", ".F.", "FONTSTRIKEOUT", ".F.", "TOOLTIP", "''", "BACKCOLOR", "NIL", "FONTCOLOR", "NIL", "COLORS", "NIL", "ONGOTFOCUS", "NIL", "ONCHANGE", "NIL", "ONLOSTFOCUS", "NIL", "ONDBLCLICK", "NIL", "EDIT", ".F.", "GRID", ".F.", "APPEND", ".F.", "ONHEADCLICK", "NIL", "WHEN", "NIL", "VALID", "NIL", "VALIDMESSAGES", "NIL", "MESSAGE", "", "READONLY", "NIL", "LOCK", ".F.", "DELETE", ".F.", "NOLINES", ".F.", "IMAGE", "NIL", "JUSTIFY", "NIL", "HELPID", "", "BREAK", ".F.", "ENDPROP" }
   xArray1[ 36 ] := { "ACTIVEX"      , "DEFINE ACTIVEX"      , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "PROGID", "", "ENDPROP" }
   xArray1[ 37 ] := { "PANEL"        , "LOAD WINDOW"         , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, , "ENDPROP" }
   xArray1[ 38 ] := { "CHECKLABEL"   , "DEFINE CHECKLABEL"   , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "VALUE","'CHECKLABEL'","ACTION","NIL","ONMOUSEHOVER","NIL","ONMOUSELEAVE","NIL","AUTOSIZE",".F.","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","IMAGE","NIL" , "HELPID","NIL","VISIBLE",".T.","BORDER",".T.","CLIENTEDGE",".F.","HSCROLL",".F.","VSCROLL", ".F.","TRANSPARENT",".F."  ,"BLINK", ".F.","ALIGNMENT", "1", "LEFTALIGN", ".T.", "RIGHTALIGN", ".F.", "CENTERALIGN", ".F.","LEFTCHECK",".F.","CHECKED",".F.","ENDPROP"}
   xArray1[ 39 ] := { "CHECKLISTBOX" , "DEFINE CHECKLISTBOX" , ControlName, "ROW", Row, "COL", Col, "WIDTH", WIDTH, "HEIGHT", HEIGHT, "ITEMS",'{""}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","ONDBLCLICK","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","SORT",".F.","MULTISELECT",".F.","CHECKBOXITEM","{0}","ITEMHEIGHT","0","END CHECKLISTBOX"}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   nPos := nTotControl
   AEval( xArray1[ CurrentControl ], { | x, y | xArray[ nPos, Y ] := xArray1[ CurrentControl, Y ] } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ControlCopy( nTotControl, ControlName )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   lUpdate := .T.

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   xpreencheGrid()

   RETURN


*------------------------------------------------------------*
PROCEDURE CopyControl()
*------------------------------------------------------------*
   LOCAL ControlName AS USUAL   := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value ) //? Vartype
   LOCAL x           AS NUMERIC
   LOCAL cType       AS STRING

   IF ISWINDOWACTIVE( Form_1 )

      IF ControlName == "Form"
         Controls.CONTROL_40.Value := .F.
         RETURN
      ENDIF

      IF Controls.CONTROL_40.Value = .T.
         Controls.Statusbar.Item( 3 ) := ControlName
         cType := xTypeControl( ControlName )
         FOR x := 2 TO 39
            IF aXControls[ x ] == cType
               Control_Click( x )
               EXIT
            ENDIF
         NEXT x
      ELSE
         Controls.Statusbar.Item( 3 ) := ""
         Control_ClicK( 1 )
      ENDIF
   ELSE
      Controls.CONTROL_40.Value := .F.
      NO_FORM_MSG() // MsgStop( "No Active Form!" )
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE ControlCopy( param, param2 )
*------------------------------------------------------------*
   LOCAL lnPosControl AS NUMERIC  // Keep Local
   LOCAL x            AS NUMERIC
   LOCAL nrcopy       AS NUMERIC
   LOCAL ControlName  AS USUAL    //? Vartype
   LOCAL cn           AS STRING
   LOCAL prop         AS STRING

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ControlName := Controls.Statusbar.Item( 3 )

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Empty( ControlName )
      RETURN
   ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   nrcopy    := xControle( ControlName )
   lnPosControl := param
   CN := param2

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR x := 9 TO Len( xArray[ nrcopy ] ) - 2 STEP 2

      IF ValType( xArray[ lnPosControl, x ] ) = "U"
         EXIT
      ENDIF

      IF xArray[ lnPosControl , x - 1 ] # "ENDPROP"
         IF xArray[ lnPosControl , x - 1 ] # "CAPTION"
            IF ! ( xArray[ lnPosControl , 1 ] = "LABEL" .AND. xArray[ lnPosControl , x - 1 ] = "VALUE" )
               xArray[ lnPosControl , x ] := xArray[ nrcopy, x ]
            ENDIF
            IF xArray[ lnPosControl , x - 1 ] = "WIDTH" .OR. xArray[ lnPosControl , x - 1 ] = "HEIGHT"
               prop := xArray[ lnPosControl , x - 1 ]
               SetProperty( "Form_1", cn, prop, GetProperty( "Form_1", ControlName, prop ) )
            ENDIF
         ENDIF
      ENDIF

   NEXT x

   RETURN


*------------------------------------------------------------*
PROCEDURE CreateTable
*------------------------------------------------------------*
   LOCAL aDbf AS Array := Array( 6, 4 )
   LOCAL i    AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aDbf[ 1, DBS_NAME ] := "Code"
   aDbf[ 1, DBS_TYPE ] := "Numeric"
   aDbf[ 1, DBS_LEN ]  := 10
   aDbf[ 1, DBS_DEC ]  := 0
//
   aDbf[ 2, DBS_NAME ] := "First"
   aDbf[ 2, DBS_TYPE ] := "Character"
   aDbf[ 2, DBS_LEN ]  := 25
   aDbf[ 2, DBS_DEC ]  := 0
//
   aDbf[ 3, DBS_NAME ] := "Last"
   aDbf[ 3, DBS_TYPE ] := "Character"
   aDbf[ 3, DBS_LEN ]  := 25
   aDbf[ 3, DBS_DEC ]  := 0
//
   aDbf[ 4, DBS_NAME ] := "Married"
   aDbf[ 4, DBS_TYPE ] := "Logical"
   aDbf[ 4, DBS_LEN ]  := 1
   aDbf[ 4, DBS_DEC ]  := 0
//
   aDbf[ 5, DBS_NAME ] := "Birth"
   aDbf[ 5, DBS_TYPE ] := "Date"
   aDbf[ 5, DBS_LEN ]  := 8
   aDbf[ 5, DBS_DEC ]  := 0
//
   aDbf[ 6, DBS_NAME ] := "Bio"
   aDbf[ 6, DBS_TYPE ] := "Memo"
   aDbf[ 6, DBS_LEN ]  := 10
   aDbf[ 6, DBS_DEC ]  := 0

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   DBCreate( System.TempFolder + "\Test", aDbf )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   USE (System.TempFolder + "\Test.dbf")

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR i := 1 TO 100
      APPEND BLANK
      REPLACE CODE    WITH i
      REPLACE FIRST   WITH "First Name " + LTrim( Str( i ) )
      REPLACE LAST    WITH "Last Name "  + LTrim( Str( i ) )
      REPLACE MARRIED WITH ( i / 2 == Int( i / 2 ) )
      REPLACE BIRTH   WITH Date() + i - 10000
   NEXT i

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   USE

   RETURN


*------------------------------------------------------------*
PROCEDURE DefineColors()
*------------------------------------------------------------*

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ! ISWINDOWACTIVE( Form_1 )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF nTotControl = 0
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ! ISWINDOWDEFINED( DefineColors )
      LOAD WINDOW DefineColors
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CENTER WINDOW  DefineColors

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ! ISWINDOWACTIVE( DefineColors )
      ACTIVATE WINDOW DefineColors
   ELSE
      SHOW WINDOW DefineColors
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE DefColo0()
*------------------------------------------------------------*
   LOCAL x       AS NUMERIC
   LOCAL y       AS NUMERIC
   LOCAL xValue  AS USUAL    //? Vartype
   LOCAL xExist  AS LOGICAL

   DefineColors.Combo_1.DeleteAllitems
   DefineColors.List_1.DeleteAllitems

   FOR x := 1 TO nTotControl
      xValue :=  xArray[ x, 1 ]
      xExist := .F.

      FOR y := 1 TO DefineColors.Combo_1.ItemCount
         IF DefineColors.Combo_1.Item( y ) = xValue
            xExist := .T.
         ENDIF
      NEXT y

      IF ! xExist
         DefineColors.Combo_1.AddItem( xArray[ x, 1 ] )
      ENDIF

      DefineColors.List_1.AddItem( xArray[ x, 3 ] )

   NEXT x

   DefineColors.Combo_1.Value := 1
// MsgBox("stop -> items= " + Str( DefineColors.List_1.ItemCount ) )
// DefineColors.List_1.Value := 1

   RETURN

*------------------------------------------------------------*
PROCEDURE DefColo1()
*------------------------------------------------------------*
   LOCAL COLOR  AS USUAL  := GETCOLOR()  //? VarType
   LOCAL xColor AS STRING

   IF COLOR[ 1 ] # NIL
      xColor                    := "{" + AllTrim( Str( COLOR[ 1 ] ) ) + "," + AllTrim( Str( COLOR[ 2 ] ) ) + "," + AllTrim( Str( COLOR[ 3 ] ) ) + "}"
      DefineColors.Text_1.Value := xColor

      SETPROPERTY( "DefineColors", "text_1", "FONTCOLOR", COLOR )
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE DefColo2()
*------------------------------------------------------------*
   LOCAL COLOR  AS USUAL  := GETCOLOR() //? Vartype
   LOCAL xColor AS STRING

   IF COLOR[ 1 ] # NIL
      xColor                    := "{" + AllTrim( Str( COLOR[ 1 ] ) ) + "," + AllTrim( Str( COLOR[ 2 ] ) ) + "," + AllTrim( Str( COLOR[ 3 ] ) ) + "}"
      DefineColors.Text_2.Value := xColor
      SETPROPERTY( "DefineColors", "text_2", "BACKCOLOR", COLOR )
   ENDIF
   RETURN


*------------------------------------------------------------*
PROCEDURE PutColo()
*------------------------------------------------------------*
   LOCAL xProp      AS STRING
   LOCAL xTipo
   LOCAL xColo2     AS NUMERIC
   LOCAL xItens     AS NUMERIC
   LOCAL xNome
   LOCAL xControl
   LOCAL aControlS1 AS Array
   LOCAL bOldError
   LOCAL xResult

   PRIVATE xColo1 //  Accessible to ColorChange()
   PRIVATE xValue //  Var for Macro

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF DefineColors.RadioGroup_2.Value = 1
      xProp := "FONTCOLOR"
      IF Empty( DefineColors.Text_1.Value )
         RETURN
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF DefineColors.RadioGroup_2.Value = 2
      xProp := "BACKCOLOR"
      IF Empty( DefineColors.Text_2.Value )
         RETURN
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF DefineColors.RadioGroup_2.Value = 3
      xProp := "BOTH"
      IF Empty( DefineColors.Text_1.Value ) .AND. Empty( DefineColors.Text_2.Value )
         RETURN
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF DefineColors.RadioGroup_1.Value = 1

      xTipo := DefineColors.Combo_1.Item( DefineColors.Combo_1.Value )   // mudar

      FOR xColo1 := 1 TO nTotControl

         xControl := xArray[ xColo1, 3 ]

         IF xArray[ xColo1, 1 ] = xTipo          //mudar

            FOR xColo2 := 1 TO 70

               IF xProp # "BOTH"
                    **************************************************
                  IF xArray[ xColo1, xColo2 ] = xProp // ""FONTCOLOR" OR "BACKCOLOR"
                     xArray[ xColo1, xColo2 + 1 ] := IIf( xProp = "FONTCOLOR", DefineColors.Text_1.Value, DefineColors.Text_2.Value )

                     ColorChange()

                     xValue := IIf( xProp = "FONTCOLOR", DefineColors.Text_1.Value, DefineColors.Text_2.Value )

                     bOldError := ErrorBlock( { |e| Break( e ) } )
                     BEGIN SEQUENCE
                        xResult := &xValue
                     RECOVER
                        xResult := Nil
                     END SEQUENCE
                     ErrorBlock( bOldError )

                     IF xResult <> Nil .AND. ISARRAY( xResult )
                        SETPROPERTY( "Form_1", xControl , xProp, xResult )
                     ENDIF
                     EXIT
                  ENDIF
               ELSE
                    ************************* BOTH
                  IF xArray[ xColo1, xColo2 ] = "FONTCOLOR"
                     xArray[ xColo1, xColo2 + 1 ] := DefineColors.Text_1.Value

                     ColorChange()

                     xValue := DefineColors.Text_1.Value

                     bOldError := ErrorBlock( { |e| Break( e ) } )
                     BEGIN SEQUENCE
                        xResult := &xValue
                     RECOVER
                        xResult := Nil
                     END SEQUENCE
                     ErrorBlock( bOldError )

                     IF xResult <> Nil .AND. ISARRAY( xResult )
                        SETPROPERTY( "Form_1",  xControl, "FONTCOLOR", xResult )
                     ENDIF
                  ENDIF

                  IF xArray[ xColo1, xColo2 ] = "BACKCOLOR"
                     xArray[ xColo1, xColo2 + 1 ] := DefineColors.Text_2.Value

                     ColorChange()

                     xValue :=  DefineColors.Text_2.Value

                     bOldError := ErrorBlock( { |e| Break( e ) } )
                     BEGIN SEQUENCE
                        xResult := &xValue
                     RECOVER
                        xResult := Nil
                     END SEQUENCE
                     ErrorBlock( bOldError )

                     IF xResult <> Nil .AND. ISARRAY( xResult )
                        SETPROPERTY( "Form_1",  xControl, "BACKCOLOR", xResult )
                     ENDIF
                  ENDIF
               ENDIF
            NEXT
         ENDIF
      NEXT

      DefineColors.Release

   ELSE
      aControls1 := DefineColors.List_1.Value   // nr item of selected controls

      FOR xItens := 1 TO Len( aControls1 )

          xNome := DefineColors.List_1.Item( aControls1[ xItens ] )

         FOR xColo1 := 1 TO nTotControl

            xControl := xArray[ xColo1, 3 ]

            IF xArray[ xColo1, 3 ] = xNome

               FOR xColo2 := 1 TO 70
                  IF xProp # "BOTH"
                        **************************************************
                     IF xArray[ xColo1, xColo2 ] = xProp // ""FONTCOLOR" OR "BACKCOLOR"
                        xArray[ xColo1, xColo2 + 1 ] := IIf( xProp = "FONTCOLOR", DefineColors.Text_1.Value, DefineColors.Text_2.Value )
                        ColorChange()
                        xValue :=  IIf( xProp = "FONTCOLOR", DefineColors.Text_1.Value, DefineColors.Text_2.Value )
                        SETPROPERTY( "Form_1", xControl , xProp, &xValue )
                        EXIT
                     ENDIF
                  ELSE
                        ************************* BOTH
                     IF xArray[ xColo1, xColo2 ] = "FONTCOLOR"
                        xArray[ xColo1, xColo2 + 1 ] := DefineColors.Text_1.Value

                        ColorChange()

                        xValue :=  DefineColors.Text_1.Value
                        SETPROPERTY( "Form_1",  xControl, "FONTCOLOR", &xValue )
                     ENDIF

                     IF xArray[ xColo1, xColo2 ] = "BACKCOLOR"
                        xArray[ xColo1, xColo2 + 1 ] := DefineColors.Text_2.Value

                        ColorChange()

                        xValue :=  DefineColors.Text_2.Value
                        SETPROPERTY( "Form_1",  xControl, "BACKCOLOR", &xValue )
                     ENDIF

                  ENDIF

               NEXT xColo2

            ENDIF

         NEXT xColo1

      NEXT xItens

      DefineColors.Release

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE ColorChange()
*------------------------------------------------------------*
   LOCAL ControlName := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   IF ControlName # "Form" .AND. ControlName = xArray[ xColo1, 3 ]
      lChanges := .T.
      DOMETHOD( "FORM_1", ControlName, "SETFOCUS" )

      cpreencheGrid( ControlName )

      **PUT COLOR EM FORM
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE RUN()
*------------------------------------------------------------*
   LOCAL A2    AS USUAL   //? Vartype
   LOCAL A4    AS STRING
   LOCAL cExe  AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xParam # NIL
      SaveForm()
      ReleaseAllWindows()
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   A2   := ProjectBrowser.xList_1.Item( 1 )
   A4   := SubStr( A2, 1, Len( A2 ) - 11 ) + ".EXE"
   cExe := ProjectFolder + "\" + A4

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF File( cExe )
      IF MsgYesNo( "File " + A4 + " Already Exist, Rebuild ?", "HMGS-IDE" )
         TEST_BUILD( "NODEBUG" )
      ELSE
         EXECUTE File cExe
      ENDIF
   ELSE
      TEST_BUILD( "NODEBUG" )
   ENDIF

   RETURN


/* last update: 26/03/2013 - Pete.
   (heavy rewritten.)
*/
*------------------------------------------------------------*
FUNCTION hbmk2Build()
*------------------------------------------------------------*
   LOCAL Output        AS STRING  := ""
   LOCAL x             AS NUMERIC
   LOCAL cItem         AS STRING
   LOCAL cExeName      AS STRING
   LOCAL cOutputFolder AS STRING  := aData[ _OUTPUTFOLDER ]
   LOCAL lError        AS LOGICAL := .T.
   LOCAL oFile         AS STRING
   LOCAL ProjectFile   AS STRING
   LOCAL cLine         AS STRING
   LOCAL nPos1         AS NUMERIC
   LOCAL nPos2         AS NUMERIC
   LOCAL nPos3         AS NUMERIC
   LOCAL nResult       AS NUMERIC
   LOCAL cCommand      AS STRING


   IF ProjectBrowser.Title == "Project Browser [ ]"
      NO_FORM_MSG() // MsgStop( "No Active Form!" )
      RETURN( lError )
   ENDIF

   FOR x := 1 TO ProjectBrowser.xlist_1.ItemCount
      cItem := AllTrim( ProjectBrowser.xlist_1.Item( x ) )
      IF SubStr( cItem, Len( cItem ) - 5, 6 ) = "(Main)"
         cItem    := AllTrim( SubStr( cItem, 1, Len( cItem ) - 6 ) )
         cExeName := hb_FNameName( cItem ) + ".exe"
      ENDIF
      Output   += cItem + CRLF
   NEXT i

   IF Empty( cExeName )
      MsgStop( "No Main Module!" )
      RETURN .F.
   ENDIF

   aError      := { }

   ProjectFile := hb_FNameName( CurrentProject )

   IF ! Empty( cOutputFolder )
      Output := "-o" + cOutputFolder + "\" + cExeName + CRLF + CRLF + OutPut
   ENDIF

   MemoWrit( ProjectFile + ".hbp", Output )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   Output := "incPaths=" + ProjectFolder + " " + StrTran( aData[ _ADDLIBINCBCCHB ], ";", " " ) + CRLF + ;
             "libpaths=" + aData[ _BCC_FOLDER ] + "\lib" + CRLF  + ;
             "libs=hbwin " + StrTran( aData[ _ADDLIBMINBCCHB ], ";", " " ) + CRLF  + ;
             "gt=" + IIf( aData[ _CONSOLE ] = ".F.", "gtgui", "gtwin" )   + CRLF  + ;
             "mt=" + IIf( aData[ _MULTITHREAD ] == ".T.", "yes", "no" )   + CRLF  + ;
             "instpaths="

   MemoWrit( ProjectFile + ".hbc" , Output )


   DELETE File ( ProjectFolder + IIf( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "End.txt" )

   /*NOTE!  below "bcc" specific settings must be revised-expanded to support mingw too.
            Added to my todo-list.
            -Pete 26/03/2013
   */

   hb_SetEnv("HB_COMPILER", "bcc")
   hb_SetEnv("PATH", aData[ _BCC_FOLDER ] + "\bin" + ";" + ;
                     aData[ _HARBOURFOLDER ] + "\bin")

   ShowInfo2( "Building " + ProjectFile + " using harbour's make (hbmk2)" )

   cCommand := "hbmk2 -inc -head=native -workdir=OBJ -L${HB_DYN} " + ProjectFile + ".hbp " + ;
              IIf( aData[ _CONSOLE ] = ".F.", aData[ _MG_FOLDER ] + "\harbour\bin\minigui.hbc ", "")+;
              ProjectFile + ".hbc"

   nResult := Hbmk2Process( cCommand )

   ShowInfo2( .F. )

   DELETE File ( ProjectFolder + IIf( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "_Build2.Bat" )

   DELETE File ( ProjectFolder + IIf( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "End.Txt" )

   lError := (nResult == -1)

   oFile  := TFileRead():NEW( "_temp" )

   oFile:Open()

   IF oFile:ERROR()

      MsgBox( oFile:ErrorMsg( "FileRead: " ) )

   ELSE

      WHILE oFile:MoreToRead()
         cLine := oFile:ReadLine()
         nPos1 := At( "error", cLine )
         nPos2 := At( "Error", cLine )

         IF ( nPos1 > 0 .OR. nPos2 > 0 ) .AND. At( "minigui.ch", cLine ) > 0
            LOOP
         ENDIF

         nPos3 := At( "Fatal", cLine )

         IF nPos1 > 0 .OR. nPos2 > 0 .OR. nPos3 > 0
            lError := .T.
            AAdd( aError, cLine )
         ENDIF

      END WHILE

      oFile:CLOSE()

      IF lError

         IF ! ISWINDOWDEFINED( BuildLog )
            LOAD WINDOW BuildLog

            ON KEY F8     OF BuildLog ACTION BuildLogDebug()
            ON KEY F5     OF BuildLog ACTION BuildLogRun()
            ON KEY Escape OF BuildLog ACTION BuildLogClose()

            BuildLog.Grid_1.DeleteAllitems
            AEval( aError, { | cLine | buildlog.Grid_1.AddItem( { cLine } ) } )
            BuildLog.Grid_1.Value := 1
         ENDIF

         IF ! ISWINDOWACTIVE( BuildLog )
            ACTIVATE WINDOW BuildLog
         ELSE
            BuildLogInit( "BuildLog" )
            SHOW WINDOW BuildLog
         ENDIF

      ENDIF

   ENDIF

   IF ! lError

      PLAYBEEP()

      IF aData[ _UPX ] = ".T."
         IF Empty( cOutputFolder )
            hb_ProcessRun( GetStartupFolder() + "\upx.exe --best --lzma " + ProjectFolder + "\" + cExeName )
         ELSE
            hb_ProcessRun( GetStartupFolder() + "\upx.exe --best --lzma " + cOutputFolder + "\" + cExeName )
         ENDIF
      ENDIF

      IF Empty( cOutputFolder )
         EXECUTE File ( cExeName )
      ELSE
         EXECUTE File (cOutputFolder + "\" + cExeName )
      ENDIF

   ENDIF

   IF File( "_temp")
      FErase( "_temp" )
   ENDIF

   DECLARE WINDOW Hbmk2Win

   IF IsWindowDefined( Hbmk2Win )
      Hbmk2Win.Animate_1.Stop()
   ENDIF

   RETURN( lError )


*------------------------------------------------------------*
PROCEDURE BuildLogDblClick()
*------------------------------------------------------------*
   LOCAL cOldLine AS STRING
   LOCAL lResp    AS LOGICAL
   LOCAL nLine    AS NUMERIC
   LOCAL Parent   AS STRING  := ThisWindow.Name

   cOldLine := GetColValue( "GRID_2", Parent, 2 )

   IF ! Empty( cOldLine )
      SETPROPERTY( Parent, "Topmost", .F. )

      lResp := INPUTBOX( "New Value", "Change Line Value", cOldLine )

      SETPROPERTY( Parent, "Topmost", .T. )

      IF Len( lResp ) > 0
         SetColValue( "GRID_2", Parent, 2, lResp )

         nLine              := Val( GetColValue( "GRID_2", Parent, 1 ) )
         aLinesPrg[ nLine ] := lResp

         BuildLogChange( cOldLine )

         DOMETHOD( Parent, "SETFOCUS" )
      ENDIF

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE BuildLogChange()
*------------------------------------------------------------*
   LOCAL nNewLine AS NUMERIC
   LOCAL cfile    AS STRING
   LOCAL cNewFile AS STRING  := ""

   cfile := GETPROPERTY( ThisWindow.Name, "GRID_2", "CARGO" )

   FOR nNewLine := 1 TO Len( aLinesPrg )
      cNewFile += aLinesPrg[ nNewLine ] + CRLF
   NEXT

   #ifndef __XHARBOUR__
      hb_MemoWrit( cfile, cNewFile )
   #else
      MemoWrit( cfile, cNewFile, .N. )
   #endif

   RETURN


*------------------------------------------------------------*
PROCEDURE BuildLogDebug()
*------------------------------------------------------------*
   BuildLogRun()

   RETURN


*------------------------------------------------------------*
PROCEDURE BuildLogRun()
*------------------------------------------------------------*
   LOCAL cName     AS STRING
   LOCAL cExeName  AS STRING

   IF ISWINDOWACTIVE( Build2 )
      BuildLogClose()
      Test_Build( "NODEBUG" )
      Check_Modules( "" )

      cName    := ProjectBrowser.XList_1.Item( 1 )
      cExeName := SubStr( cName, 1, Len( cName ) - 11 )

      mpmc( cExeName + ".mpm", "", "" )
   ELSE
      HBMK2Build()
   ENDIF

   RETURN


*------------------------------------------------------------*
FUNCTION BuildLogClose()
*------------------------------------------------------------*
   DOMETHOD( ThisWindow.Name, "HIDE" )

   IF ISWINDOWDEFINED( Build )
      DOMETHOD( "build", "SETFOCUS" )
   ENDIF

   RETURN( NIL )


*------------------------------------------------------------*
PROCEDURE ReleaseBuild()
*------------------------------------------------------------*
   IF ISWINDOWACTIVE( Build )
      RELEASE WINDOW Build
   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE BuildLogLoadPrg()
*------------------------------------------------------------*
   LOCAL aDados  AS Array
   LOCAL nPos1   AS NUMERIC
   LOCAL nPos2   AS NUMERIC
   LOCAL cFile   AS STRING
   LOCAL nrline  AS STRING    //? invalid Hungarian
   LOCAL nLine   AS NUMERIC
   LOCAL cLine   AS STRING
   LOCAL oFile   AS OBJECT
   LOCAL cValue  AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF lBuildUpdate == .F.
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   lBuildUpdate := .F.
   cLine        := GetColValue( "GRID_1", ThisWindow.Name, 1 )
   nPos1        := At( "(", cLine )
   nPos2        := At( ")", cLine )
   cFile        := SubStr( cLine, 1, nPos1 - 1 )
   nrline       := SubStr( cLine, nPos1 + 1, nPos2 - nPos1 - 1 )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cFile # GETPROPERTY( ThisWindow.Name, "GRID_2", "CARGO" )

      DOMETHOD( ThisWindow.Name, "GRID_2", "DeleteAllitems" )

      aLinesPrg := { }

      IF Empty( cFile )
         cValue := "File Name"
      ELSE
         cValue := cFile
      ENDIF

      SETPROPERTY( ThisWindow.Name, "GRID_2", "CARGO", cValue )

      oFile := TFileRead():NEW( cFile, 65535 )

      oFile:Open()

      IF oFile:ERROR()
         MsgBox( oFile:ErrorMsg( "FileRead: " ) )////
      ELSE
         nLine := 1
         WHILE oFile:MoreToRead()

            cLine := oFile:ReadLine()

            AAdd( aLinesPrg, cLine )

            aDados := { StrZero( nLine, 5 ), cLine }

            DOMETHOD( ThisWindow.Name, "GRID_2", "AddItem", aDados )

            nLine ++
         END WHILE
      ENDIF

      oFile:CLOSE()

   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   SETPROPERTY( ThisWindow.Name, "GRID_2", "VALUE", Val( nrline ) )

   DOMETHOD( ThisWindow.Name, "GRID_2", "SETFOCUS" )

   lBuildUpdate := .T.

   RETURN


*------------------------------------------------------------*
PROCEDURE Test_Build( xDebug, cIncrem )
*------------------------------------------------------------*
   LOCAL output    AS STRING  := ""
   LOCAL i         AS NUMERIC
   LOCAL cItem     AS STRING
   LOCAL nPos      AS NUMERIC
   LOCAL cExeName  AS STRING
   LOCAL c         AS STRING  := ""
   LOCAL cPrjFile  AS STRING
   LOCAL xName     AS STRING

   DEFAULT cIncrem TO ""

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LoadPreferences()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.Title == "Project Browser [ ]"
      NO_FORM_MSG() // MsgStop( "No Active Form!" )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF lChanges
      IF ISWINDOWACTIVE( Form_1 )
         RELEASE WINDOW Form_1

      ELSEIF ISWINDOWACTIVE( Form_2 )
         RELEASE WINDOW Form_2
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ISWINDOWACTIVE( Build )
      HIDE WINDOW Build
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// make exe with mpmc
   c += "BccFolder=" + Upper( aData[ _BCC_FOLDER ] ) + CRLF

   IF aData[ _HMG2 ] = ".T." // HMG2
      c += "MiniGuiFolder=" + Upper( aData[ _HMG2FOLDER ] ) + CRLF
   ELSE
      c += "MiniGuiFolder=" + Upper( aData[ _MG_FOLDER ] )  + CRLF
   ENDIF

   IF aData[ _HARBOUR ] = ".T."
      c += "HarbourFolder=" + Upper( aData[ _HARBOURFOLDER ] )  + CRLF
   ELSE
      c += "HarbourFolder=" + Upper( aData[ _XHARBOURFOLDER ] ) + CRLF
   ENDIF

   c += "PROGRAMEDITOR=" + Upper( MainEditor ) + CRLF

   MemoWrit( GetStartupFolder() + "\mpm.ini", c )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   output += "ProjectFolder=" + Upper( ProjectFolder )                      + CRLF
   output += "ADSSUPPORT="    + IIf( aData[ _ADS   ] = ".T.", "YES", "NO" ) + CRLF
   output += "MYSQLSUPPORT="  + IIf( aData[ _MYSQL ] = ".T.", "YES", "NO" ) + CRLF
   output += "ODBCSUPPORT="   + IIf( aData[ _ODBC  ] = ".T.", "YES", "NO" ) + CRLF
   output += "ZIPSUPPORT="    + IIf( aData[ _ZIP   ] = ".T.", "YES", "NO" ) + CRLF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR i := 1 TO ProjectBrowser.xlist_1.ItemCount
      cItem := AllTrim( ProjectBrowser.xlist_1.Item( i ) )

      IF SubStr( cItem, Len( cItem ) - 5, 6 ) = "(Main)"
         cItem    := AllTrim( SubStr( cItem, 1, Len( cItem ) - 6 ) )
         nPos     := At( ".", cItem )
         cExeName := SubStr( cItem, 1, nPos - 1 )
         output   += cItem + CRLF
      ENDIF
   NEXT i

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Empty( cExeName )
      MsgStop( "No Main Module!" )
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR i := 1 TO ProjectBrowser.xlist_1.ItemCount
      cItem := AllTrim( ProjectBrowser.xlist_1.Item( i ) )
      IF SubStr( cItem, Len( cItem ) - 5, 6 ) # "(Main)"
         output += cItem + CRLF
      ENDIF
   NEXT i

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   cPrjFile := ProjectFolder + "\" + cExeName + ".mpm"

   MemoWrit( cPrjFile, output + CRLF + CRLF )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF aData[ _BUILDTYPE ] = "1" // buildtype is full

      IF ! ISWINDOWDEFINED( build )
         LOAD WINDOW BUILDPROCESS AS BUILD
      ENDIF

      xName                := StrTran( Upper( CurrentProject ), Upper( ProjectFolder ) + "\", "" )
      BUILD.Label_9.Value  := ProjectFolder + "\" + xName                         // PROJECT FILE
      BUILD.Label_10.Value := ProjectFolder                                       // PROJECT FOLDER

      IF aData[ _MINIGUIEXT ] = ".T."
         IF aData[ _BCC55 ] = ".T."
            BUILD.Label_11.Value := aData[ _MG_FOLDER ] // MINIGUI WITH BCC FOLDER
         ELSE
            BUILD.Label_11.Value := aData[ _HMGFOLDER ] // MINIGUI WITH MINGW FOLDER
         ENDIF
      ELSE
         BUILD.Label_3.Value  := "Hmg2 Folder:"
         BUILD.Label_11.Value := aData[ _HMG2FOLDER ]   // HMG2 FOLDER
      ENDIF

      IF aData[ _MINIGUIEXT ] = ".T."                             // MiniGUI EXTENDED

         IF aData[ _BCC55 ] = ".T."   // BCC
            IF aData[ _HARBOUR ] = ".T."   // HARBOUR
               BUILD.Label_12.Value := aData[ _ADDLIBMINBCCHB ]   // bcchb                         // ADD LIBS
               BUILD.Label_13.Value := aData[ _ADDLIBINCBCCHB ]   // bcchb                         // ADD PATHS
            ELSE                    // XHARBOUR
               BUILD.Label_12.Value := aData[ _ADDLIBMINNCCXHB ]  // bccxhb
               BUILD.Label_13.Value := aData[ _ADDLIBINCBCCXHB ]  // bccxhb
            ENDIF

         ELSE                   // MINGW
            IF aData[ 30 ] = ".T."
               BUILD.Label_12.Value := aData[ _ADDLIBMINMINGHB ]  // minghb
               BUILD.Label_13.Value := aData[ _ADDLIBINCMINGHB ]  // minghb
            ELSE
               BUILD.Label_12.Value := aData[ _ADDLIBMINMINGXHB ] // mingxhb
               BUILD.Label_13.Value := aData[ _ADDLIBINCMINGXHB ] // mingxhb
            ENDIF
         ENDIF

      ELSE   // HMG (OFFICIAL) + HARBOUR
         BUILD.Label_12.Value := aData[ _ADDLIBHMG2HB ]           // hmg2hb
         BUILD.Label_13.Value := aData[ _ADDLIBINCHMG2HB ]        // hmg2hb
      ENDIF

      BUILD.Label_14.Value := IIf( cIncrem == "", "Incremental", "No Incremental" )  // BUILD TYPE  CINCREM = NIL

      BUILD.Label_15.Value := IIf( xDebug = "NODEBUG", "No", "YES" )                 // DEBUG INFO
      BUILD.Label_16.Value := IIf( aData[ _CONSOLE ] = ".F.", "No", "YES" )          // BUILD CONSOLE/MIXED

      SETPROPERTY( "build", "label_17", "fontcolor", { 255, 0, 0 } )

      BUILD.Label_17.Value := "Building..."                                          // STATUS

      SETPROPERTY( "build", "edit_2", "value", "START..." )

      CENTER WINDOW BUILD

      IF ISWINDOWACTIVE( build )
         SHOW WINDOW build
      ELSE
         ACTIVATE WINDOW BUILD
      ENDIF

   ELSE

      DEFINE WINDOW Form_Splash ;
             At 0, 0 ;
             WIDTH 310 HEIGHT 85 ;
             TITLE "" ;
             CHILD TOPMOST NOCAPTION ;
             ON INIT { || Check_Modules( cIncrem ), mpmc( cExeName + ".mpm", IIf( xDebug = "DEBUG", "/D", " " ), cIncrem ) }

         @ 32, 05 LABEL Label_1 ;
         WIDTH 300 HEIGHT 20 ;
         VALUE "Building... Please Wait..." ;
         CENTERALIGN

      END WINDOW

      CENTER WINDOW Form_Splash
      ACTIVATE WINDOW Form_Splash

   ENDIF

   RETURN


*------------------------------------------------------------*
PROCEDURE ViewErrors()
*------------------------------------------------------------*
   LOAD WINDOW ViewFormCode

   ViewFormCode.Title         := "Error Log"
   ViewFormCode.Edit_1.Value  := MemoRead( ProjectFolder + "\_temp" )
   ViewFormCode.Label_1.Value := ""

   CENTER WINDOW ViewFormCode
   ACTIVATE WINDOW ViewFormCode

   RETURN


*------------------------------------------------------------*
FUNCTION GetColValue( xObj, xForm, nCol ) //? Renamed to GridGetColValue()
*------------------------------------------------------------*
   LOCAL nPos AS NUMERIC := GETPROPERTY( xForm, xObj, "Value" )
   LOCAL aRet AS Array   := GETPROPERTY( xForm, xObj, "Item", nPos )

   RETURN( aRet[ nCol ] )


*------------------------------------------------------------*
FUNCTION SetColValue(                    ;  // Set Value in Grid Column
         xObj   AS STRING,  ;  // GridName
         xForm  AS STRING,  ;  // Form
         nCol   AS NUMERIC, ;  // Column
         cValue AS STRING   ;  // Value or property
       ) //? Renamed to GridSetColValue()
*------------------------------------------------------------*
   LOCAL nPos AS NUMERIC := GETPROPERTY( xForm, xObj, "Value" )
   LOCAL aRet AS Array   := GETPROPERTY( xForm, xObj, "Item", nPos )

   aRet[ nCol ] := cValue

   SETPROPERTY( xForm, xObj, "Item", nPos, aRet )

   RETURN( NIL ) //? Check what value to return


//SadStar begin -----------------------------------

*------------------------------------------------------------*
FUNCTION wObjInspResize()
*------------------------------------------------------------*
   LOCAL wh AS NUMERIC
   LOCAL ww AS NUMERIC
   LOCAL wc AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ObjectInspector.Height < 340
      ObjectInspector.Height := 340
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ObjectInspector.Width < 280
      ObjectInspector.Width := 280
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   wh                              := ObjectInspector.Height
   ww                              := ObjectInspector.Width
   wc                              := ObjectInspector.Col

   ObjectInspector.XTab_2.Width    := ww -  12
   ObjectInspector.XTab_2.Height   := wh -  64
   ObjectInspector.xGrid_1.Width   := ww -  27
   ObjectInspector.xGrid_1.Height  := wh - 102
   ObjectInspector.xGrid_2.Width   := ww -  27
   ObjectInspector.xGrid_2.Height  := wh - 102
   ObjectInspector.xGrid_3.Width   := ww -  27
   ObjectInspector.xGrid_3.Height  := wh - 102
   ObjectInspector.xCombo_1.Width  := ww -  12 - iif( IsVistaOrLater() .And. IsAppXPThemed(), GetBorderWidth(), 0 )
   ObjectInspector.xCombo_1.Height := wh -  54

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   /*
   IF ProjectBrowser.Width <> ww
      ProjectBrowser.Width := ww
      ProjectBrowser.Col   := wc
      wProjBrowResize()             // to horizontal resize both windows simultaneously
   ENDIF
   */
   RETURN NIL


*------------------------------------------------------------*
FUNCTION wProjBrowResize()
*------------------------------------------------------------*
   LOCAL wh AS NUMERIC
   LOCAL ww AS NUMERIC
   LOCAL wc AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.Height < 250
      ProjectBrowser.Height := 250
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ProjectBrowser.Width < 280
      ProjectBrowser.Width := 280
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   wh                            := ProjectBrowser.Height
   ww                            := ProjectBrowser.Width
   wc                            := ProjectBrowser.Col

   ProjectBrowser.XTab_1.Width   := ww - 12
   ProjectBrowser.XTab_1.Height  := wh - 40
   ProjectBrowser.XList_1.Width  := ww - 27
   ProjectBrowser.XList_1.Height := wh - 98
   ProjectBrowser.XList_2.Width  := ww - 27
   ProjectBrowser.XList_2.Height := wh - 98
   ProjectBrowser.XList_3.Width  := ww - 27
   ProjectBrowser.XList_3.Height := wh - 98
   ProjectBrowser.XList_4.Width  := ww - 27
   ProjectBrowser.XList_4.Height := wh - 98
   ProjectBrowser.XList_5.Width  := ww - 27
   ProjectBrowser.XList_5.Height := wh - 98

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   /*
   IF ObjectInspector.Width <> ww
      ObjectInspector.Width := ww
      ObjectInspector.Col   := wc
      wObjInspResize()              // to horizontal resize both windows simultaneously
   ENDIF
   */
   RETURN NIL


*------------------------------------------------------------*
FUNCTION wSizeRest()
*------------------------------------------------------------*
   LOCAL wr    AS NUMERIC := 0
   LOCAL wh    AS NUMERIC := 0
   LOCAL wc    AS NUMERIC := 0
   LOCAL ww    AS NUMERIC := 0
   LOCAL lLoad AS LOGICAL := File( cIniFile )
   LOCAL cSect AS STRING  := "wObjectInspector"

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF lLoad

      BEGIN INI File cIniFile
         GET wr SECTION cSect ENTRY "wRow"    DEFAULT 522
         GET wh SECTION cSect ENTRY "wHeight" DEFAULT 340
         GET wc SECTION cSect ENTRY "wCol"    DEFAULT 0
         GET ww SECTION cSect ENTRY "wWidth"  DEFAULT 280
      END INI

      IF wc < 0 ; wc := 0   ; ENDIF
      IF wr < 0 ; wr := 200 ; ENDIF

      ObjectInspector.Height := wh
      ObjectInspector.Width  := ww
      ObjectInspector.Row    := wr
      ObjectInspector.Col    := wc

      wObjInspResize()

      cSect := "wProjectBrowser"

      BEGIN INI File cIniFile
         GET wr SECTION cSect ENTRY "wRow"    DEFAULT 182
         GET wh SECTION cSect ENTRY "wHeight" DEFAULT 340
         GET wc SECTION cSect ENTRY "wCol"    DEFAULT 0
         GET ww SECTION cSect ENTRY "wWidth"  DEFAULT 280
      END INI

      IF wc < 0 ; wc := 0   ; ENDIF
      IF wr < 0 ; wr := 130 ; ENDIF

      ProjectBrowser.Height := wh
      ProjectBrowser.Width  := ww
      ProjectBrowser.Row    := wr
      ProjectBrowser.Col    := wc

      wProjBrowResize()

   ENDIF

   RETURN( lLoad )

//SadStar end -------------------------------------


*------------------------------------------------------------*
FUNCTION wSizeMainForm()           // Called From Controls.fmg
*------------------------------------------------------------*
   LOCAL wr    AS NUMERIC := 0
   LOCAL wh    AS NUMERIC := 0
   LOCAL wc    AS NUMERIC := 0
   LOCAL ww    AS NUMERIC := 0
   LOCAL lLoad AS LOGICAL := File( cIniFile )
   LOCAL cSect AS STRING  := "wMainForm"

   IF lLoad
      BEGIN INI File cIniFile
         GET wr SECTION cSect ENTRY "wRow"    DEFAULT 0
         GET wh SECTION cSect ENTRY "wHeight" DEFAULT 170 + IIf( _HMG_IsXPorLater .AND. ! _HMG_IsXP, 14, IIf( _HMG_IsXP, 10, 6 ) )
         GET wc SECTION cSect ENTRY "wCol"    DEFAULT 0
         GET ww SECTION cSect ENTRY "wWidth"  DEFAULT 1048
      END INI

      Controls.Height := wh
      Controls.Width  := ww
      Controls.Row    := wr
      Controls.Col    := wc

      // MsgBox( "wh= " + Str(wh) + " ww= " + Str(ww) + " wr= " + Str(wr) + " wc= " + Str(wc) )
   ELSE
      ThisWindow.Maximize
   ENDIF

   RETURN( lLoad )


*------------------------------------------------------------*
FUNCTION aScan2( Array AS Array, xFind AS USUAL, nStart AS NUMERIC )
*------------------------------------------------------------*
   LOCAL x      AS NUMERIC
   LOCAL lExact AS LOGICAL := SET( _SET_EXACT, .T. )  //SL Save current SET EXACT Setting

   DEFAULT nStart TO 1

   x := AScan( Array, xFind, nStart )

   SET( _SET_EXACT, lExact )  // Restore Set Exact Setting to what it was before

   RETURN( x )


*------------------------------------------------------------*
FUNCTION aSort2( aArray AS Array )
*------------------------------------------------------------*
   RETURN ASort( aArray, , , { | x, y | Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )


*------------------------------------------------------------*
FUNCTION SavePath( pcControlName AS STRING, pcValue AS STRING )
*------------------------------------------------------------*
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL cSection    AS STRING := "DatabasePaths_" + FormName + "_" + pcControlName

   BEGIN INI File ProjectName
      IF pcValue # "NIL" .AND. Len( AllTrim( pcValue ) ) > 0
         SET SECTION cSection ENTRY FormName + "_" + pcControlName TO pcValue
      ELSE
         DEL SECTION cSection
      ENDIF
   END INI

   RETURN NIL


*------------------------------------------------------------*
FUNCTION LoadPath( pcControlName AS STRING )
*------------------------------------------------------------*
   LOCAL RetValue    AS STRING := "NIL"
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL cSection    AS STRING := "DatabasePaths_" + FormName + "_" + pcControlName

   IF File( ProjectName )
      BEGIN INI File ProjectName
         GET RetValue SECTION cSection ENTRY FormName + "_" + pcControlName DEFAULT "NIL"
      END INI
   ENDIF

   RETURN( RetValue )


/* Start code - added by Arcangelo Molinaro 25/11/2007 */
*------------------------------------------------------------*
FUNCTION SaveAlias( pcControlName AS STRING, pcValue AS STRING )
*------------------------------------------------------------*
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL cSection    AS STRING := "AliasValue_" + FormName + "_" + pcControlName

   BEGIN INI File ProjectName
      IF pcValue # "NIL" .AND. Len( AllTrim( pcValue ) ) > 0
         SET SECTION cSection ENTRY FormName + "_" + pcControlName TO pcValue
      ELSE
         DEL SECTION cSection
      ENDIF
   END INI

   RETURN( NIL )


*------------------------------------------------------------*
FUNCTION LoadAlias( pcControlName AS STRING )
*------------------------------------------------------------*
   LOCAL RetValue    AS STRING := "NIL"
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm, 1, ( At( ".", CurrentForm ) - 1 ) )
   LOCAL cSection    AS STRING := "AliasValue_" + FormName + "_" + pcControlName

   IF File( ProjectName )
      BEGIN INI File ProjectName
         GET RetValue SECTION cSection ENTRY FormName + "_" + pcControlName DEFAULT "NIL"
      END INI
   ENDIF

   RETURN( RetValue )
/* End code - added by Arcangelo Molinaro 25/11/2007 */


/* Start code - added by Arcangelo Molinaro 08/12/2007 */
*------------------------------------------------------------*
FUNCTION SaveStruct( pcControlName AS STRING, paValue AS Array )
*------------------------------------------------------------*
   LOCAL ProjectName AS STRING  := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING  := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL nLen        AS NUMERIC := Len( paValue )
   LOCAL i           AS NUMERIC := 0
   LOCAL cSection    AS STRING  := "DatabaseStruct_" + FormName + "_" + pcControlName

   BEGIN INI File ProjectName
      IF ! Empty( paValue ) .AND. Len( paValue ) > 0
         _SetIni( cSection, FormName + "_" + pcControlName + "_FieldNumber", nLen )
         FOR i := 1 TO nLen
            _SetIni( cSection, FormName + "_" + pcControlName + "_FieldName_"   + AllTrim( Str( i ) ), paValue[ i, 1 ] )
            _SetIni( cSection, FormName + "_" + pcControlName + "_FieldType_"   + AllTrim( Str( i ) ), paValue[ i, 2 ] )
            _SetIni( cSection, FormName + "_" + pcControlName + "_FieldLenght_" + AllTrim( Str( i ) ), paValue[ i, 3 ] )
            _SetIni( cSection, FormName + "_" + pcControlName + "_FieldDec_"    + AllTrim( Str( i ) ), paValue[ i, 4 ] )
         NEXT i
      ELSE
         DEL SECTION cSection
      ENDIF
   END INI

   RETURN NIL


*------------------------------------------------------------*
FUNCTION LoadStruct( pcControlName AS STRING )
*------------------------------------------------------------*
   LOCAL ProjectName   AS STRING  := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName      AS STRING  := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL aKeyValueList AS Array   := { }
   LOCAL aField        AS Array   := { }
   LOCAL cSection      AS STRING  := "DatabaseStruct_" + FormName + "_" + pcControlName
   LOCAL nLen          AS NUMERIC := 0
   LOCAL i

   IF File( ProjectName )
      BEGIN INI File ProjectName
         nLen := _GetIni( cSection, FormName + "_" + pcControlName + "_FieldNumber", NIL, 0 )
         FOR i := 1 TO nLen
            aField := { }
            AAdd( aField, _GetIni( cSection, FormName + "_" + pcControlName + "_FieldName_"   + AllTrim( Str( i ) ) , , "C" ) )
            AAdd( aField, _GetIni( cSection, FormName + "_" + pcControlName + "_FieldType_"   + AllTrim( Str( i ) ) , , "C" ) )
            AAdd( aField, _GetIni( cSection, FormName + "_" + pcControlName + "_FieldLenght_" + AllTrim( Str( i ) ) , , 0   ) )
            AAdd( aField, _GetIni( cSection, FormName + "_" + pcControlName + "_FieldDec_"    + AllTrim( Str( i ) ) , , 0   ) )

            AAdd( aKeyValueList , aField )
         NEXT i
      END INI
   ENDIF

   RETURN( aKeyValueList )
/* End code - added by Arcangelo Molinaro 08/12/2007 */


/* Start code - added by Arcangelo Molinaro 15/12/2007 */
*------------------------------------------------------------*
FUNCTION SaveDbfName( pcControlName AS STRING, pcValue AS STRING )
*------------------------------------------------------------*
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL cSection    AS STRING := "DatabaseName_" + FormName + "_" + pcControlName

   BEGIN INI File ProjectName
      IF pcValue # "NIL" .AND. Len( AllTrim( pcValue ) ) > 0
         SET SECTION cSection ENTRY FormName + "_" + pcControlName TO pcValue
      ELSE
         DEL SECTION cSection
      ENDIF
   END INI

   RETURN NIL


*------------------------------------------------------------*
FUNCTION ldDbfName( pcControlName AS STRING )
*------------------------------------------------------------*
   LOCAL RetValue    AS STRING := "NIL"
   LOCAL ProjectName AS STRING := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL FormName    AS STRING := SubStr( CurrentForm   , 1, ( At( ".", CurrentForm    ) - 1 ) )
   LOCAL cSection    AS STRING := "DatabaseName_" + FormName + "_" + pcControlName

   IF File( ProjectName )
      BEGIN INI File ProjectName
         GET RetValue SECTION cSection ENTRY FormName + "_" + pcControlName DEFAULT "NIL"
      END INI
   ENDIF

   RETURN( RetValue )
/* End code - added by Arcangelo Molinaro 15/12/2007 */


/* Start code - added by Arcangelo Molinaro 23/12/2007 */
*------------------------------------------------------------*
FUNCTION _IsIniDef()
*------------------------------------------------------------*
   LOCAL ProjectName AS STRING  := SubStr( CurrentProject, 1, ( At( ".", CurrentProject ) - 1 ) ) + ".ini"
   LOCAL lMode       AS LOGICAL := .F.

   IF File( ProjectName )
      lMode := .T.
   ENDIF

   RETURN( lMode )
/* End code - added by Arcangelo Molinaro 23/12/2007 */


*********************CONTRIBUTION OF CAS
*------------------------------------------------------------*
FUNCTION f_pontos()
*------------------------------------------------------------*
   LOCAL i       AS NUMERIC
   LOCAL j       AS NUMERIC
   LOCAL fHandle AS NUMERIC := GetformHandle( "Form_1" )
   LOCAL t_l     AS NUMERIC := Form_1.Height - IIf( Len( aStatus ) > 0, GetTitleHeight() + 2 * GetBorderHeight() + 24, 0 )
   LOCAL t_c     AS NUMERIC := Form_1.Width
   LOCAL hdc     AS NUMERIC := HB_GetDC( fHandle )

   FOR i := 0 TO t_c STEP 10
      FOR j := 0 TO t_l STEP 10
         SetPixel( hdc, i, j, RGB( 0, 0, 0 ) )
      NEXT
   NEXT

   HB_ReleaseDC( fHandle, hdc )

   RETURN( NIL )


* Begin news  Luiz Fernando Bardon Escobar
*------------------------------------------------------------*
PROCEDURE ReSize_VFC()
*------------------------------------------------------------*
   ViewFormCode.Edit_1.Width  := ViewFormCode.Width  -  9
   ViewFormCode.Edit_1.Height := ViewFormCode.Height - 78

   RETURN


*------------------------------------------------------------*
PROCEDURE SaveViewFormCode()
*------------------------------------------------------------*
   IF ViewFormCode.Title <> "Error Log"

      MemoWrit( ViewFormCode.Label_1.Value, ViewFormCode.Edit_1.Value )

      IF ProjectBrowser.XTAB_1.Value = 2   // FMG
         IF ProjectBrowser.xlist_2.Value # 0
            FLoadFMG()
         ENDIF
      ENDIF

   ENDIF

   RETURN
* END news  Luiz Fernando Bardon Escobar


*------------------------------------------------------------------------
FUNCTION XToC( pxValue AS USUAL )   // Return a String Value for Any Type
*------------------------------------------------------------------------
   LOCAL lcString AS STRING

   DO CASE
   CASE ValType( pxValue ) == "C"  ; lcString := pxValue
   CASE ValType( pxValue ) == "N"  ; lcString := AllTrim( Str( pxValue ) )
   CASE ValType( pxValue ) == "D"  ; lcString := DToC( pxValue )
   CASE ValType( pxValue ) == "A"  ; lcString := aToc( pxValue )
   CASE ValType( pxValue ) == "B"  ; lcString := "{ || ... }"
   CASE ValType( pxValue ) == "L"  ; lcString := IIf( pxValue, ".T.", ".F." )
   CASE ValType( pxValue ) == "U"  ; lcString := "NIL"
   ENDCASE

   RETURN( lcString )


*------------------------------------------------------------------------
FUNCTION Chk_Editor()
*------------------------------------------------------------------------
   IF ! File( MainEditor )
      MainEditor :=  "NOTEPAD.EXE"
   ENDIF

   RETURN( NIL )


/* TO DEBUG ONLY

*------------------------------------------------------------*
PROCEDURE xLogForm( Param )
*------------------------------------------------------------*
   IF PARAM = NIL
      PARAM := ""
   ENDIF

   LOGFORM.LIST_1.AddItem(STR(PROCLINE(1))+" "+PROCNAME(1)+" "+ TIME()+ " "+ PARAM )
RETURN


*---------------------------------------------------------------------------
FUNCTION aBrowseAC( paData AS ARRAY, pcTitle AS STRING )
*---------------------------------------------------------------------------
   Local oBrw AS OBJECT

   DEFAULT pcTitle TO "Array Browsing"

   DEFINE WINDOW Form_999 AT 40,60 ;
         WIDTH 600                 ;
         HEIGHT 600                ;
         TITLE pcTitle             ;
         CHILD

      @  30, 50 TBROWSE oBrw ARRAY paData WIDTH 500 HEIGHT 500 CELLED AUTOCOLS SELECTOR .T. EDITABLE ;
                COLORS CLR_BLACK, CLR_WHITE, CLR_BLUE, { CLR_WHITE, GetSysColor( COLOR_GRADIENTINACTIVECAPTION  ) }

      oBrw:nClrLine := GetSysColor( COLOR_GRADIENTINACTIVECAPTION  )

   END WINDOW

   ACTIVATE WINDOW Form_999

Return Nil

*/

*------------------------------------------------------------*
* Begin of codes in language C
*------------------------------------------------------------*
#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0400

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
  #define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
  #define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

HB_FUNC ( INTERACTIVEMOVE )
{

   keybd_event(
      VK_RIGHT,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
      );

   keybd_event(
      VK_LEFT,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
      );

   SendMessage( GetFocus() , WM_SYSCOMMAND , SC_MOVE ,10 );
   RedrawWindow(GetFocus(),NULL,NULL,
      RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW
      );
}

HB_FUNC ( INTERACTIVESIZE )
{

   keybd_event(
      VK_DOWN,
      0,
      0,
      0
      );

   keybd_event(
      VK_RIGHT,
      0,
      0,
      0
      );

   SendMessage( GetFocus() , WM_SYSCOMMAND , SC_SIZE , 0 );

}

HB_FUNC ( INTERACTIVECLOSE )
{
   SendMessage( GetFocus() , WM_SYSCOMMAND , SC_CLOSE , 0 ) ;
}

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{

   keybd_event(
      VK_RIGHT,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
      );
   keybd_event(
      VK_LEFT,   // virtual-key code
      0,      // hardware scan code
      0,      // flags specifying various function options
      0      // additional data associated with keystroke
   );

   SendMessage( (HWND) hb_parnl(1) , WM_SYSCOMMAND , SC_MOVE ,10 );

}

HB_FUNC ( INTERACTIVESIZEHANDLE )
{

   keybd_event(
      VK_DOWN,
      0,
      0,
      0
      );

   keybd_event(
      VK_RIGHT,
      0,
      0,
      0
      );

   SendMessage( (HWND) hb_parnl(1) , WM_SYSCOMMAND , SC_SIZE , 0 );

}

HB_FUNC ( INTERACTIVECLOSEHANDLE )
{
   SendMessage( (HWND) hb_parnl(1) , WM_SYSCOMMAND , SC_CLOSE , 0 ) ;
}

HB_FUNC ( CHIDECONTROL )
{
   HWND hwnd;

   hwnd = (HWND) hb_parnl (1);

   ShowWindow(hwnd, SW_HIDE);
   }

   // para deixar mais rapido os pontos na tela
   HB_FUNC ( HB_GETDC )
   {
   hb_retnl( (ULONG) GetDC( (HWND) hb_parnl(1) ) ) ;
   }

   HB_FUNC ( HB_RELEASEDC )
   {
   hb_retl( ReleaseDC( (HWND) hb_parnl(1), (HDC) hb_parnl(2) ) ) ;
   }

   HB_FUNC( SETPIXEL )
   {
   hb_retnl( (ULONG) SetPixel( (HDC) hb_parnl( 1 ),
      hb_parni( 2 )      ,
      hb_parni( 3 )      ,
      (COLORREF) hb_parnl( 4 ) ) ) ;
}

HB_FUNC ( CHANGEWINDOWBITMAP )
{
      RECT rc;
      HWND hwnd;
      HBITMAP hbmp;
      HBRUSH hbrush;
      HDC hdc;

      hwnd = (HWND) hb_parnl(1);
      hbmp = (HBITMAP) LoadImage( GetModuleHandle(NULL), hb_parc(2), IMAGE_BITMAP, 0, 0, 0 );

      GetClientRect( hwnd, &rc );
      hbrush = CreatePatternBrush( hbmp );

      hdc = GetDC( hwnd );
      FillRect( hdc, &rc, hbrush );

      ReleaseDC( hwnd, hdc );
      DeleteObject( hbrush );
      DeleteObject( hbmp );
}

static far int nFontIndex = 0;
static far BOOL bGetName = FALSE;

#if defined( __BORLANDC__ ) // pacify 'uknown pragma' warning in gcc - p.d.01/04/2016
   #pragma argsused
#endif
static int CALLBACK EnumFontsCallBack( LOGFONT FAR *lpLogFont,
     TEXTMETRIC FAR *lpTextMetric, int nFontType, LPARAM lParam )
{
      ++nFontIndex;
      if ( bGetName )
        HB_STORC( lpLogFont->lfFaceName, -1, nFontIndex );
      return 1;
}

// GetFontNames: Count and return an unsorted array of font names
HB_FUNC( GETFONTNAMES )
{
     FONTENUMPROC lpEnumFontsCallBack = ( FONTENUMPROC )
     MakeProcInstance( ( FARPROC ) EnumFontsCallBack, GetModuleHandle( 0 ) );

     // Get the number of fonts
     nFontIndex = 0;
     bGetName = FALSE;
     EnumFonts( ( HDC ) hb_parnl( 1 ), NULL, lpEnumFontsCallBack, NULL );

     // Get the font names
     hb_reta( nFontIndex );
     nFontIndex = 0;
     bGetName = TRUE;
     EnumFonts( ( HDC ) hb_parnl( 1 ), NULL, lpEnumFontsCallBack, NULL );
}

#pragma ENDDUMP


/*
Function StoreControlVal() in HmgsIde.prg
xArray1[  1, ? ] := ?
xArray1[  2, 1 ] := "BUTTON"
xArray1[  3, 1 ] := "CHECKBOX"
xArray1[  4, 1 ] := "LISTBOX"
xArray1[  5, 1 ] := "COMBOBOX"
xArray1[  6, 1 ] := "CHECKBUTTON"
xArray1[  7, 1 ] := "GRID"
xArray1[  8, 1 ] := "SLIDER"
xArray1[  9, 1 ] := "SPINNER"
xArray1[ 10, 1 ] := "IMAGE"
xArray1[ 11, 1 ] := "TREE"
xArray1[ 12, 1 ] := "DATEPICKER"
xArray1[ 13, 1 ] := "TEXTBOX"
xArray1[ 14, 1 ] := "EDITBOX"
xArray1[ 15, 1 ] := "LABEL"
xArray1[ 16, 1 ] := "BROWSE"
xArray1[ 17, 1 ] := "RADIOGROUP"
xArray1[ 18, 1 ] := "FRAME"
xArray1[ 19, 1 ] := "TAB"
xArray1[ 20, 1 ] := "ANIMATEBOX"
xArray1[ 21, 1 ] := "HYPERLINK"
xArray1[ 22, 1 ] := "MONTHCALENDAR"
xArray1[ 23, 1 ] := "RICHEDITBOX"
xArray1[ 24, 1 ] := "PROGRESSBAR"
xArray1[ 25, 1 ] := "PLAYER"
xArray1[ 26, 1 ] := "IPADDRESS"
xArray1[ 27, 1 ] := "TIMER"
xArray1[ 28, 1 ] := "BUTTONEX"
xArray1[ 29, 1 ] := "COMBOBOXEX"
xArray1[ 30, 1 ] := "BTNTEXTBOX"
xArray1[ 31, 1 ] := "HOTKEYBOX"
xArray1[ 32, 1 ] := "GETBOX"
xArray1[ 33, 1 ] := "TIMEPICKER"
xArray1[ 34, 1 ] := "QHTM"
xArray1[ 35, 1 ] := "TBROWSE"
xArray1[ 36, 1 ] := "ACTIVEX"
xArray1[ 37, 1 ] := "PANEL"


Function InitValue() in LoadForm.prg
aItens[ 1] := "BUTTON"
aItens[ 2] := "CHECKBOX"
aItens[ 3] := "LISTBOX"
aItens[ 4] := "COMBOBOX"
aItens[ 5] := "CHECKBUTTON"
aItens[ 6] := "GRID"
aItens[ 7] := "SLIDER"
aItens[ 8] := "SPINNER"
aItens[ 9] := "IMAGE"
aItens[32] := "TREE"
aItens[10] := "DATEPICKER"
aItens[11] := "TEXTBOX"
aItens[12] := "EDITBOX"
aItens[13] := "LABEL"
aItens[14] := "BROWSE"
aItens[15] := "RADIOGROUP"
aItens[16] := "FRAME"
aItens[33] := "TAB"
aItens[17] := "ANIMATEBOX"
aItens[18] := "HYPERLINK"
aItens[19] := "MONTHCALENDAR"
aItens[20] := "RICHEDITBOX"
aItens[21] := "PROGRESSBAR"
aItens[22] := "PLAYER"
aItens[23] := "IPADDRESS"
aItens[31] := "TIMER"
aItens[24] := "BUTTONEX"
aItens[25] := "COMBOBOXEX"
aItens[29] := "BTNTEXTBOX"
aItens[30] := "HOTKEYBOX"
aItens[28] := "GETBOX"
aItens[26] := "TIMEPICKER"
aItens[42] := "QHTM"
aItens[40] := "TBROWSE"
aItens[27] := "ACTIVEX"
aItens[43] := "PANEL"

aItens[34] := "MAINMENU"
aItens[35] := "TOOLBAR"
aItens[36] := "CONTEXT MENU"
aItens[37] := "STATUSBAR"
aItens[38] := "NOTIFY MENU"
aItens[39] := "DROPDOWN MENU"
aItens[41] := "UCI"

aXControl[] same order as xArray
aXControl[  1 ] = ""
aXControl[  2 ] = "BUTTON"
aXControl[  3 ] = "CHECKBOX"
aXControl[  4 ] = "LISTBOX"
aXControl[  5 ] = "COMBOBOX"
aXControl[  6 ] = "CHECKBUTTON"
aXControl[  7 ] = "GRID"
aXControl[  8 ] = "SLIDER"
aXControl[  9 ] = "SPINNER"
aXControl[ 10 ] = "IMAGE"
aXControl[ 11 ] = "TREE"
aXControl[ 12 ] = "DATEPICKER"
aXControl[ 13 ] = "TEXTBOX"
aXControl[ 14 ] = "EDITBOX"
aXControl[ 15 ] = "LABEL"
aXControl[ 16 ] = "BROWSE"
aXControl[ 17 ] = "RADIOGROUP"
aXControl[ 18 ] = "FRAME"
aXControl[ 19 ] = "TAB"
aXControl[ 20 ] = "ANIMATEBOX"
aXControl[ 21 ] = "HYPERLINK"
aXControl[ 22 ] = "MONTHCALENDAR"
aXControl[ 23 ] = "RICHEDITBOX"
aXControl[ 24 ] = "PROGRESSBAR"
aXControl[ 25 ] = "PLAYER"
aXControl[ 26 ] = "IPADDRESS"
aXControl[ 27 ] = "TIMER"
aXControl[ 28 ] = "BUTTONEX"
aXControl[ 29 ] = "COMBOBOXEX"
aXControl[ 30 ] = "BTNTEXTBOX"
aXControl[ 31 ] = "HOTKEYBOX"
aXControl[ 32 ] = "GETBOX"
aXControl[ 33 ] = "TIMEPICKER"
aXControl[ 34 ] = "QHTM"
aXControl[ 35 ] = "TBROWSE"
aXControl[ 36 ] = "ACTIVEX"
aXControl[ 37 ] = "PANEL"


aControls    := { "DEFINE BUTTON "         1
                  "DEFINE CHECKBOX"        2
                  "DEFINE LISTBOX"         3
                  "DEFINE COMBOBOX "       4
                  "DEFINE CHECKBUTTON"     5
                  "DEFINE GRID"            6
                  "DEFINE SLIDER"          7
                  "DEFINE SPINNER"         8
                  "DEFINE IMAGE"           9
                  "DEFINE DATEPICKER"     10
                  "DEFINE TEXTBOX"        11
                  "DEFINE EDITBOX"        12
                  "DEFINE LABEL"          13
                  "DEFINE BROWSE"         14
                  "DEFINE RADIOGROUP"     15
                  "DEFINE FRAME"          16
                  "DEFINE ANIMATEBOX"     17
                  "DEFINE HYPERLINK"      18
                  "DEFINE MONTHCALENDAR"  19
                  "DEFINE RICHEDITBOX"    20
                  "DEFINE PROGRESSBAR"    21
                  "DEFINE PLAYER"         22
                  "DEFINE IPADDRESS"      23
                  "DEFINE BUTTONEX"       24
                  "DEFINE COMBOBOXEX"     25
                  "DEFINE TIMEPICKER"     26
                  "DEFINE ACTIVEX"        27
                  "DEFINE GETBOX"         28
                  "DEFINE BTNTEXTBOX"     29
                  "DEFINE HOTKEYBOX"      30

*/
