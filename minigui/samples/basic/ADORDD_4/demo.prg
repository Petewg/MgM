/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2009 Janusz Pora <januszpora@onet.eu>
*/

#include "adordd.ch"
#include "minigui.ch"
#include "TSBrowse.ch"

#define CLR_DEFAULT   0xff000000


FUNCTION Main()

   LOCAL Brw_1

   OpenTable()

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 640 HEIGHT 588 ;
      TITLE 'ADO Rdd Demo' ;
      MAIN NOMAXIMIZE ;
      ON RELEASE CloseTable()

   @ 15,20 LABEL Lbl_1;
      VALUE "States" ;
      WIDTH 350 HEIGHT 35 ;
      FONT "Arial" SIZE 18 BOLD ;
      FONTCOLOR BLUE ;
      CENTERALIGN

   DEFINE TBROWSE Brw_1 AT 50, 20 ;
      ALIAS 'States' ;
      WIDTH 350  HEIGHT 500 ;
      HEADERS 'State', 'Name' ;
      WIDTHS  60, 270 ;
      FIELDS States->State, States->Name ;
      ON DBLCLICK  ViewState( States->State, .F. )

   Brw_1:nHeightHead += 5

   Brw_1:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
      { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
      { CLR_HBLUE, CLR_BLUE }, ; // degraded cursor background color
      CLR_HGREEN, CLR_BLACK } )  // text colors

   Brw_1:SetColor( { 2, 4, 14 }, ;
      { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
      { CLR_WHITE, CLR_BLACK }, ;    // degraded headers backgroud color
      { CLR_HGREEN, CLR_BLACK } } )  // degraded order column background color

   Brw_1:nLineStyle := LINES_VERT

   END TBROWSE

   @ 50, 430  FRAME Frame_1 CAPTION "Search in Employee for:" WIDTH 190 HEIGHT 200

   @ 70,440 RADIOGROUP Radio_1;
      OPTIONS { 'City', 'First Name', 'Last Name' };
      VALUE 1

   @ 160, 460 GETBOX GBox_1 ;
      HEIGHT 24 WIDTH 120;
      VALUE "                  " ;
      FONT "Arial" SIZE 9 ;
      ON CHANGE FindChg();
      PICTURE  '@XXXXXXXXXXXXXXXXXXXXXXX'

   @ 190,470 BUTTONEX Btn_1;
      CAPTION "Find" ;
      WIDTH 80 ;
      PICTURE "Find" ;
      ON CLICK FindPos( Form_1.Radio_1.Value, Form_1.GBox_1.Value, Brw_1 ) ;
      DEFAULT

   @ 500,470 BUTTONEX Btn_2;
      CAPTION "Exit" ;
      WIDTH 80 ;
      PICTURE "Exit2" ;
      ON CLICK thiswindow.release

   END WINDOW

   Form_1.Btn_1.Enabled := .F.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


PROCEDURE OpenTable

   IF !IsWinNT() .AND. !CheckODBC()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
      ReleaseAllWindows()
   ENDIF
   SELECT( 1 )
   IF !File( 'Employee.mdb' )
      CreateTable()
      USE Employee.mdb VIA "ADORDD" TABLE "table1"
      dbCreateIndex( "State", "State" )
      dbCreateIndex( "First", "First" )
      dbCreateIndex( "City", "City" )
   ELSE
      USE Employee.mdb VIA "ADORDD" ALIAS 'Employee' TABLE "table1" INDEX "State", "First", "City"
   ENDIF

   IF Empty( Employee->( LastRec() ) )
      APPEND FROM "Employee.DBF"
   ENDIF
   SELECT( 2 )
   USE Employee.mdb VIA "ADORDD" ALIAS 'States' TABLE "table2"
   IF Empty( States->( LastRec() ) )
      APPEND FROM "States.DBF"
   ENDIF
   dbGoTop()

RETURN


PROCEDURE CloseTable

   USE

RETURN


PROCEDURE FindChg()

   Form_1 .Btn_1. Enabled := !Empty( Form_1 .GBox_1. Value )

RETURN


FUNCTION FindPos( met, value, oBrw )

   LOCAL cState, FindWar, cWar, pos, lFound := .T.

   Value := Upper( value )
   SELECT( "Employee" )
   DO CASE
   CASE met == 1
      FindWar := "CITY == '" + AllTrim( Value ) + "'"
   CASE met == 2
      FindWar := "FIRST == '" + AllTrim( Value ) + "'"
   CASE met == 3
      FindWar := "LAST == '" + AllTrim( Value ) + "'"
   ENDCASE
   LOCATE FOR &FindWar
   IF ! Eof()
      cState := EMPLOYEE->State
      SetFlt( cState )
      LOCATE FOR &FindWar
      cState := EMPLOYEE->State
   ENDIF
   IF ! Eof()
      lFound := .T.
   ELSE
      dbGoTop()
      cState := "  "
      MsgExclamation ( 'No Success!' + CRLF + "Change Properties!", 'ERROR' )
   ENDIF

   cState := ViewState( cState, lFound )

   SELECT( "States" )
   IF lFound
      dbGoTop()
      cWar := "STATE == '" + AllTrim( cState ) + "'"
      LOCATE FOR &cWar
      IF ! Eof()
         pos := RecNo()
         oBrw:GoPos( pos )
      ENDIF
   ENDIF
   oBrw:SetFocus()
   oBrw:Refresh()

RETURN NIL


FUNCTION ViewState( cState, lFound )

   LOCAL Tyt, Brw_1
   LOCAL aPos := GetChildPos( 'Form_1' )
   LOCAL aHead, aWidth, aFld, cInfo

   LOCAL nRec := IF( lFound, RecNo(), 1 )

   Tyt := 'State: ' + cState
   SELECT( "EMPLOYEE" )
   IF .NOT. IsWIndowActive ( Form_Gr )
      IF !Empty( cState ) .AND. !lFound
         SetFlt( cState, nRec )
      ENDIF

      DEFINE WINDOW Form_Gr ;
         AT aPos[ 1 ] + 50, aPos[ 2 ] + 20 ;
         WIDTH 740 HEIGHT 580 ;
         TITLE tyt;
         CHILD NOMAXIMIZE ;
         ON INIT Refresh_Win( "Form_Gr", Brw_1 ) ;
         ON RELEASE {||  cState := EMPLOYEE->State, DelFlt() }

      DEFINE IMAGELIST Im_edit ;
         BUTTONSIZE 26, 26  ;
         IMAGE { 'edit' } ;
         COLORMASK CLR_DEFAULT;
         IMAGECOUNT 5;
         MASK

      DEFINE IMAGELIST im_navi ;
         BUTTONSIZE 20, 20  ;
         IMAGE { 'navi2' } ;
         COLORMASK CLR_DEFAULT;
         IMAGECOUNT 6;
         MASK

      DEFINE SPLITBOX

         DEFINE TOOLBAREX Tb_Edit BUTTONSIZE 26, 26 IMAGELIST "im_edit" FLAT CAPTION 'Edition'
            BUTTON Button_2 PICTUREINDEX 2 TOOLTIP 'Edit record' ACTION {|| EditDan( aHead, aFld, aWidth ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON Button_3 PICTUREINDEX 3 TOOLTIP 'Add record' ACTION MsgInfo( 'Click!' )
            BUTTON Button_4 PICTUREINDEX 1 TOOLTIP 'Delete record' ACTION MsgInfo( 'Click!' ) SEPARATOR
         END TOOLBAR

         DEFINE TOOLBAREX Tb_Navi BUTTONSIZE 20, 20 IMAGELIST "im_navi" FLAT CAPTION 'Navigations'
            BUTTON TOP  PICTUREINDEX 0 TOOLTIP "Top Table"    ACTION {|| TbMove( 1, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON prve PICTUREINDEX 1 TOOLTIP "Prev Screen"  ACTION {|| TbMove( 2, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON prev PICTUREINDEX 2 TOOLTIP "Prev Record"  ACTION {|| TbMove( 3, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON NEXT PICTUREINDEX 3 TOOLTIP "Next Record"  ACTION {|| TbMove( 4, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON nxte PICTUREINDEX 4 TOOLTIP "Next Screen"  ACTION {|| TbMove( 5, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
            BUTTON BOTT PICTUREINDEX 5 TOOLTIP "Botton Table" ACTION {|| TbMove( 6, Brw_1 ), Refresh_Win( "Form_Gr", Brw_1 ) }
         END TOOLBAR

         DEFINE TOOLBAREX ToolBar_3 BUTTONSIZE 28, 28 FONT "Arial" SIZE 9 FLAT CAPTION 'Exit'
            BUTTON EXIT PICTURE "exit2" ACTION Release_Brw1( "Form_Gr" ) TOOLTIP "Exit"
         END TOOLBAR

      END SPLITBOX

      SetProperty( "Form_Gr", "Button_3", "Enabled", .F. )
      SetProperty( "Form_Gr", "Button_4", "Enabled", .F. )


      aHead := { 'First', 'Last', 'Street', 'City', 'Zip', 'Age', 'Salary', 'Notes' }
      aWidth := { 110, 150,150, 150, 80, 50, 80, 200 }
      aFld  := { 'First', 'Last', 'Street', 'City', 'Zip', 'Age', 'Salary', 'Notes' }

      dbGoto( nRec )

      DEFINE TBROWSE Brw_1 AT 50, 10 ;
         ALIAS 'EMPLOYEE' ;
         WIDTH 710 ;
         HEIGHT 390 ;
         HEADERS 'First', 'Last', 'Street', 'City', 'Zip', 'Age', 'Salary', 'Notes' ;
         WIDTHS  110, 150, 150, 200, 80, 65, 95, 200 ;
         FIELDS EMPLOYEE->First, EMPLOYEE->Last, EMPLOYEE->Street, EMPLOYEE->City, EMPLOYEE->Zip, EMPLOYEE->Age, EMPLOYEE->Salary, EMPLOYEE->Notes ;
         VALUE nRec;
         ON CHANGE Refresh_Win( "Form_Gr", Brw_1 ) ;
         ON DBLCLICK ( EditDan( aHead, aFld, aWidth ), Refresh_Win( "Form_Gr", Brw_1 ) )

      Brw_1:nHeightHead += 5

      Brw_1:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
         { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
         { CLR_HBLUE, CLR_BLUE }, ; // degraded cursor background color
         CLR_HGREEN, CLR_BLACK } )  // text colors

      Brw_1:SetColor( { 2, 4, 14 }, ;
         { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
         { CLR_WHITE, CLR_BLACK }, ;    // degraded headers backgroud color
         { CLR_HGREEN, CLR_BLACK } } )  // degraded order column background color

      Brw_1:nLineStyle := LINES_VERT
      Brw_1:aColumns[ 1 ]:cOrder := "FIRST"
      Brw_1:aColumns[ 4 ]:cOrder := "CITY"

      END TBROWSE

      Brw_1:GoPos( nRec )
      cInfo := hb_ntos( RecNo() )
      @ 510, 520 LABEL Lbl_10a VALUE "Recno:" AUTO
      @ 510, 620 LABEL Lbl_10b VALUE cInfo AUTO BOLD

      END WINDOW

      ACTIVATE WINDOW Form_Gr
   ELSE
      RESTORE WINDOW Form_Gr
   ENDIF

RETURN cState


FUNCTION SetFlt( cState, nRec )

   LOCAL FltWar := "STATE == '" + cState + "'"

   IF !Empty( cState )
      dbSetFilter( {|| EMPLOYEE->State == cState }, FltWar )
   ENDIF
   IF nRec == 1
      dbGoTop()
   ENDIF

RETURN NIL


FUNCTION DelFlt()

   IF Used()
      dbSetFilter( "" )
      dbGoTop()
   ENDIF

RETURN NIL


FUNCTION Refresh_Win( fm_edit, oBrw )

   LOCAL cInfo

   IF _IsWindowActive ( fm_edit )
      oBrw:Refresh( .F. )
      cInfo := hb_ntos( RecNo() )
      DoMethod( fm_edit, "SetFocus" )
      SetProperty( fm_edit, "Lbl_10b", "Value", cInfo )
   ENDIF

RETURN NIL


FUNCTION Release_Brw1( fm_edit )

   RELEASE WINDOW &fm_edit

RETURN NIL


FUNCTION TbMove( met, oBrw )

   DO CASE
   CASE met == 1
      oBrw:GoTop()
   CASE met == 2
      oBrw:PageUp()
   CASE met == 3
      oBrw:GoUp()
   CASE met == 4
      oBrw:GoDown()
   CASE met == 5
      oBrw:PageDown()
   CASE met == 6
      oBrw:GoBottom()
   ENDCASE

RETURN NIL


FUNCTION EditDan( aHead, aFld, aWidth )

   LOCAL aPos := GetChildPos( 'Form_Gr' )
   LOCAL n, cLbl, cGBox, cValue

   IF RecCount() > 0
      IF .NOT. IsWindowActive ( Form_Ed )

         DEFINE WINDOW Form_Ed;
            AT aPos[ 1 ] + 50, aPos[ 2 ] + 20 ;
            WIDTH 600 HEIGHT 125 + 30 * Len( aHead ) ;
            TITLE 'Edit a current record' ;
            CHILD

         DEFINE SPLITBOX
            DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 28, 28 FONT "Arial" SIZE 9 FLAT CAPTION 'Save'
               BUTTON saveItem PICTURE "save" ACTION SaveDan( aFld ) TOOLTIP "Save data" SEPARATOR
               BUTTON exititem PICTURE "exit2" ACTION thiswindow.Release TOOLTIP "Exit"
            END TOOLBAR
         END SPLITBOX

         @ 55, 20  FRAME Frame_2 CAPTION "Fields" WIDTH 120 HEIGHT 30 * Len( aHead ) + 30

         FOR n := 1 TO Len( aHead )
            cLbl := "Lbl_" + hb_ntos( n )
            cGBox := "GBox_" + hb_ntos( n )
            cValue := "EMPLOYEE->" + aFld[ n ]

            @ 50 + n * 30, 30 LABEL &cLbl ;
               VALUE aHead[ n ] ;
               WIDTH 90 HEIGHT 24 VCENTERALIGN

            @  50 + n * 30, 160 GETBOX &cGBox ;
               HEIGHT 24 WIDTH aWidth[ n ] ;
               VALUE &cValue ;
               FONT "Arial" SIZE 9
         NEXT

         END WINDOW

         Form_Ed.Activate
      ELSE
         FOR n := 1 TO Len( aHead )
            cValue := "EMPLOYEE->" + aFld[ n ]
            cGBox := "GBox_" + hb_ntos( n )
            SetProperty( "Form_Ed", cGBox, 'Value', &cValue )
         NEXT
         RESTORE WINDOW Form_Ed
      ENDIF
   ENDIF

RETURN NIL


FUNCTION SaveDan( aFld )

   LOCAL n, value, cGBox, cFld

   IF RLock()
      FOR n := 1 TO Len( aFld )
         cFld  := aFld[ n ]
         cGBox := "GBox_" + hb_ntos( n )
         value := GetProperty( "Form_Ed", cGBox, 'Value' )
         REPLACE &cFld WITH value
      NEXT
      dbUnlock()
   ENDIF
   thiswindow.release

RETURN NIL


PROCEDURE CreateTable

   dbCreate( "Employee.mdb;table1", { { "FIRST",     "C", 20, 0 }, ;
      { "LAST",      "C", 20, 0 }, ;
      { "STREET",    "C", 30, 0 }, ;
      { "CITY",      "C", 30, 0 }, ;
      { "STATE",     "C", 2, 0 }, ;
      { "ZIP",       "C", 10, 0 }, ;
      { "AGE",       "N", 2, 0 }, ;
      { "SALARY",    "N", 6, 0 }, ;
      { "NOTES",     "C", 70, 0 } }, "ADORDD" )

   dbCreate( "Employee.mdb;table2", { { "STATE",    "C", 2, 0 }, ;
      { "NAME",      "C", 30, 0 } }, "ADORDD" )

RETURN


FUNCTION GetChildPos( cFormName )

   LOCAL i, yw, xw, hrb := 0, hTit
   LOCAL hwnd, actpos := { 0, 0, 0, 0 }

   hTit := GetMenubarHeight()
   hwnd := GetFormHandle( cFormName )
   GetWindowRect( hwnd, actpos )

   yw := actpos[ 2 ]
   xw := actpos[ 1 ]

   i := AScan ( _HMG_aFormHandles, hWnd )
   IF i > 0
      IF _HMG_aFormReBarHandle[i ] > 0
         hrb = RebarHeight ( _HMG_aFormReBarHandle[i ] )
      ENDIF
   ENDIF
   yw += ( hrb + hTit )

RETURN { yw, xw }


STATIC FUNCTION CheckODBC()

   LOCAL oReg, cKey := ""

   OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
      SECTION "Software\Microsoft\DataAccess"

   GET VALUE cKey NAME "Version" OF oReg

   CLOSE REGISTRY oReg

RETURN !Empty( cKey )
