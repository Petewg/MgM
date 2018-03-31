#include <hmg.ch>

MEMVAR New_rec, _qry_exp

PROCEDURE MAIN

   LOCAL nFldCnt, aFields := {}, brw_idx

   PUBLIC New_rec := .F., _qry_exp := ""

//---------------------------------------------*
   SET PROCEDURE TO Open_dbf.prg
   SET PROCEDURE TO Open_ntx.prg
   SET PROCEDURE TO Use_dbf.prg

   SET NAVIGATION EXTENDED
   SET CENTURY ON
   SET DATE GERMAN
   SET DELETED ON

   Open_dbf()
   Open_ntx()

   Use_employe()
//---------------------------------------------*

   FOR nFldCnt := 1 TO EMPLOYE->( FCount() )
      AAdd( aFields, EMPLOYE->( FieldName( nFldCnt ) ) )
   NEXT

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 800 ;
      HEIGHT 700 ;
      TITLE "Table EMPLOYE" ;
      ICON "EMPLOYE.ICO" ;
      MAIN ;
      ON INIT brw_idx := GetControlIndex( 'Browse_1', 'Win_1' )

   ON KEY ESCAPE ACTION Win_1.Release

   DEFINE STATUSBAR FONT "Arial" SIZE 12
      STATUSITEM "Table EMPLOYE"
      KEYBOARD WIDTH 90
      DATE WIDTH 100
      CLOCK WIDTH 80
   END STATUSBAR

   DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 60, 40 IMAGESIZE 32, 32 FLAT BORDER

   BUTTON FIRST_EMPL ;
      CAPTION "Fi&rst" ;
      PICTURE "go_first.bmp" ;
      ACTION ( _BrowseHome( '', '', brw_idx ), Win_1.Browse_1.Value := EMPLOYE->( RecNo() ) )

   BUTTON PREV_EMPL ;
      CAPTION "Pre&v" ;
      PICTURE "go_prev.bmp" ;
      ACTION ( _BrowseUp( '', '', brw_idx ), Win_1.Browse_1.Value := EMPLOYE->( RecNo() ) )

   BUTTON NEXT_EMPL ;
      CAPTION "Nex&t" ;
      PICTURE "go_next.bmp" ;
      ACTION ( _BrowseDown( '', '', brw_idx ), Win_1.Browse_1.Value := EMPLOYE->( RecNo() ) )

   BUTTON LAST_EMPL ;
      CAPTION "&Last" ;
      PICTURE "go_last.bmp" ;
      ACTION ( _BrowseEnd( '', '', brw_idx ), Win_1.Browse_1.Value := EMPLOYE->( RecNo() ) ) SEPARATOR

   BUTTON FIND_EMPL ;
      CAPTION "&Find" ;
      PICTURE "edit_find.bmp" ;
      ACTION Find_EMPL()

   BUTTON NEW_EMPL ;
      CAPTION "&New" ;
      PICTURE "edit_new.bmp" ;
      ACTION ( New_rec := .T. , NewRecord_EMPL() )

   BUTTON EDIT_EMPL ;
      CAPTION "&Edit" ;
      PICTURE "edit_edit.bmp" ;
      ACTION iif ( RecordStatus_EMPL(), EnableField_EMPL(), Nil )

   BUTTON DELETE_EMPL ;
      CAPTION "&Delete" ;
      PICTURE "edit_delete.bmp" ;
      ACTION iif ( RecordStatus_EMPL(), DeleteRecord_EMPL(), Nil )

   BUTTON PRINT_EMPL ;
      CAPTION "&Print" ;
      PICTURE "edit_print.bmp" ;
      ACTION PrintData_EMPL()

   BUTTON EXIT_EMPL ;
      CAPTION "E&xit" ;
      PICTURE "edit_close.bmp" ;
      ACTION Win_1.Release

   END TOOLBAR

   PaintDisplay_EMPL( aFields )

   @ 90, 20 BROWSE Browse_1 ;
      WIDTH 440 ;
      HEIGHT 450 ;
      FONT "Arial" ;
      SIZE 11 ;
      HEADERS aFields ;
      WIDTHS { 70, 130, 130, 120, 90, 90, 110, 110, 110, 110 } ;
      WORKAREA EMPLOYE ;
      FIELDS aFields ;
      JUSTIFY { BROWSE_JTFY_RIGHT, , , , BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, , , BROWSE_JTFY_RIGHT, } ;
      ON CHANGE LoadData_EMPL() ;
      ON HEADCLICK { {|| Head1_EMPL() }, , , , , , , , , {|| Head10_EMPL() } } ;
      ON DBLCLICK ( EnableField_EMPL(), iif ( ! RecordStatus_EMPL(), DisableField_EMPL(), Nil ) )

   @ 580, 50 BUTTON SAVE_EMPL ;
      CAPTION "&Save" ;
      PICTURE "ok.bmp" ;
      ACTION SaveRecord_EMPL() ;
      RIGHT ;
      WIDTH 100 ;
      HEIGHT 40

   @ 580, 150 BUTTON CANCEL_EMPL ;
      CAPTION "&Cancel" ;
      PICTURE "cancel.bmp" ;
      ACTION CancelEdit_EMPL() ;
      RIGHT ;
      WIDTH 100 ;
      HEIGHT 40

   @ 580, 300 BUTTON QUERY_EMPL ;
      CAPTION "&Query" ;
      PICTURE "edit_find.bmp" ;
      ACTION QueryRecord_EMPL() ;
      RIGHT ;
      WIDTH 100 ;
      HEIGHT 40

   END WINDOW

   DisableField_EMPL()

   Win_1.Browse_1.Value := EMPLOYE->( RecNo() )
   LoadData_EMPL()
   Win_1.Browse_1.SetFocus

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN
//---------------------------------------------*
PROCEDURE DisableField_EMPL

   LOCAL nControl

   Win_1.Browse_1.Enabled     := .T.

   FOR nControl := 1 TO 10
      SetProperty( "Win_1", "Control_" + hb_ntos( nControl ), "Enabled", .F. )
   NEXT

   Win_1.Save_EMPL.Enabled    := .F.
   Win_1.Cancel_EMPL.Enabled  := .F.
   Win_1.Query_EMPL.Enabled   := .F.

   EnableToolbar_EMPL()

   Win_1.Browse_1.SetFocus

RETURN
//---------------------------------------------*
PROCEDURE EnableField_EMPL

   LOCAL nControl

   Win_1.Browse_1.Enabled     := .F.

   FOR nControl := 1 TO 10
      SetProperty( "Win_1", "Control_" + hb_ntos( nControl ), "Enabled", .T. )
   NEXT

   Win_1.Save_EMPL.Enabled    := .T.
   Win_1.Cancel_EMPL.Enabled  := .T.
   Win_1.Query_EMPL.Enabled   := .F.

   DisableToolbar_EMPL()

   Win_1.Control_2.SetFocus

RETURN
//---------------------------------------------*
PROCEDURE DisableToolbar_EMPL

   Win_1.Toolbar_1.FIRST_EMPL.Enabled  := .F.
   Win_1.Toolbar_1.PREV_EMPL.Enabled   := .F.
   Win_1.Toolbar_1.NEXT_EMPL.Enabled   := .F.
   Win_1.Toolbar_1.LAST_EMPL.Enabled   := .F.
   Win_1.Toolbar_1.FIND_EMPL.Enabled   := .F.
   Win_1.Toolbar_1.NEW_EMPL.Enabled    := .F.
   Win_1.Toolbar_1.EDIT_EMPL.Enabled   := .F.
   Win_1.Toolbar_1.DELETE_EMPL.Enabled := .F.
   Win_1.Toolbar_1.PRINT_EMPL.Enabled  := .F.
   Win_1.Toolbar_1.EXIT_EMPL.Enabled   := .F.

RETURN
//---------------------------------------------*
PROCEDURE EnableToolbar_EMPL

   Win_1.Toolbar_1.FIRST_EMPL.Enabled  := .T.
   Win_1.Toolbar_1.PREV_EMPL.Enabled   := .T.
   Win_1.Toolbar_1.NEXT_EMPL.Enabled   := .T.
   Win_1.Toolbar_1.LAST_EMPL.Enabled   := .T.
   Win_1.Toolbar_1.FIND_EMPL.Enabled   := .T.
   Win_1.Toolbar_1.NEW_EMPL.Enabled    := .T.
   Win_1.Toolbar_1.EDIT_EMPL.Enabled   := .T.
   Win_1.Toolbar_1.DELETE_EMPL.Enabled := .T.
   Win_1.Toolbar_1.PRINT_EMPL.Enabled  := .T.
   Win_1.Toolbar_1.EXIT_EMPL.Enabled   := .T.

RETURN
//---------------------------------------------*
FUNCTION RecordStatus_EMPL()

   LOCAL RetVal

   EMPLOYE->( dbGoto ( Win_1.Browse_1.Value ) )

   IF EMPLOYE->( RLock() )
      RetVal := .T.
   ELSE
      MsgExclamation ( "Record is LOCKED, try again later" )
      RetVal := .F.
   ENDIF

RETURN RetVal
//---------------------------------------------*
PROCEDURE LoadData_EMPL

   LOCAL nFldCnt

   EMPLOYE->( dbGoto ( Win_1.Browse_1.Value ) )

   FOR nFldCnt := 1 TO EMPLOYE->( FCount() )
      SetProperty( "Win_1", "Control_" + hb_ntos( nFldCnt ), "Value", EMPLOYE->( FieldGet( nFldCnt ) ) )
   NEXT

RETURN
//---------------------------------------------*
PROCEDURE CancelEdit_EMPL

   DisableField_EMPL()
   LoadData_EMPL()
   EMPLOYE->( dbUnlock() )
   New_rec := .F.

   Win_1.StatusBar.Item( 1 ) := "Table EMPLOYE"

RETURN
//---------------------------------------------*
PROCEDURE SaveRecord_EMPL

   LOCAL nRecNo, nFldCnt

   DisableField_EMPL()

   IF New_rec == .T.
      EMPLOYE->( dbAppend() )
      New_rec := .F.
   ELSE
      EMPLOYE->( dbGoto ( Win_1.Browse_1.Value ) )
   ENDIF

   nRecNo := EMPLOYE->( RecNo() )

   FOR nFldCnt := 1 TO EMPLOYE->( FCount() )
      EMPLOYE->( FieldPut( nFldCnt, GetProperty("Win_1", "Control_" + hb_ntos(nFldCnt ), "Value" ) ) )
   NEXT

   EMPLOYE->( dbCommit() )
   EMPLOYE->( dbUnlock() )

   Win_1.Browse_1.Value := nRecNo
   Win_1.Browse_1.Refresh

   Win_1.StatusBar.Item( 1 ) := "Save Record"

RETURN
//---------------------------------------------*
PROCEDURE NewRecord_EMPL

   Win_1.StatusBar.Item( 1 ) := "Editing"

   SELECT EMPLOYE
   SET ORDER TO 1
   EMPLOYE->( dbGoBottom() )

   Win_1.Control_1.Value   := EMPLOYE->CLI_ID + 1
   Win_1.Control_2.Value   := Space( 12 )
   Win_1.Control_3.Value   := Space( 12 )
   Win_1.Control_4.Value   := Space( 11 )
   Win_1.Control_5.Value   := 0
   Win_1.Control_6.Value   := 0
   Win_1.Control_7.Value   := Date()
   Win_1.Control_8.Value   := Date()
   Win_1.Control_9.Value   := 0
   Win_1.Control_10.Value  := Space( 10 )

   EnableField_EMPL()

   Win_1.Control_2.SetFocus

RETURN
//---------------------------------------------*
PROCEDURE DeleteRecord_EMPL

   IF MsgYesNo ( "Are you sure you want to delete the current record?", "Confirmation" )
      EMPLOYE->( dbDelete() )
      EMPLOYE->( dbSkip() )
      IF EMPLOYE->( EOF() )
         EMPLOYE->( dbGoBottom() )
      ENDIF
      Win_1.Browse_1.Value := EMPLOYE->( RecNo() )
      Win_1.Browse_1.Refresh
   ENDIF
   EMPLOYE->( dbUnlock() )

RETURN
//---------------------------------------------*
PROCEDURE Find_EMPL

   Win_1.StatusBar.Item( 1 ) := "Query"

   Win_1.Control_1.Value   := 0
   Win_1.Control_2.Value   := Space( 12 )
   Win_1.Control_3.Value   := Space( 12 )
   Win_1.Control_4.Value   := Space( 11 )
   Win_1.Control_5.Value   := 0
   Win_1.Control_6.Value   := 0
   Win_1.Control_7.Value   := CToD( '' )
   Win_1.Control_8.Value   := CToD( '' )
   Win_1.Control_9.Value   := 0
   Win_1.Control_10.Value  := Space( 10 )

   EnableField_EMPL()
   Win_1.Save_EMPL.Enabled  := .F.
   Win_1.Query_EMPL.Enabled := .T.
   Win_1.Control_1.SetFocus

RETURN
//---------------------------------------------*
PROCEDURE PrintData_EMPL

   LOCAL PrevRec

   PrevRec := EMPLOYE->( RecNo() )
   EMPLOYE->( dbGoTop() )

   DO REPORT ;
      TITLE "EMPLOYE" ;
      HEADERS { "", "", "", "", "", "", "", "", "", "" }, { "CLI_ID", "CLI_SNAM", "CLI_NAME", "CLI_TLF", "CLI_DAYS", "CLI_WAGE", "CLI_BDATE", "CLI_HDATE", "CLI_SALARY", "CLI_CITY" } ;
      FIELDS { "CLI_ID", "CLI_SNAM", "CLI_NAME", "CLI_TLF", "CLI_DAYS", "CLI_WAGE", "CLI_BDATE", "CLI_HDATE", "CLI_SALARY", "CLI_CITY" } ;
      WIDTHS { 7, 13, 13, 12, 9, 9, 11, 11, 11, 11 } ;
      TOTALS { .F. , .F. , .F. , .F. , .F. , .F. , .F. , .F. , .T. , .F. } ;
      NFORMATS { '', '', '', '', '', '999.99', '', '', "99,999.99", '' } ;
      WORKAREA EMPLOYE ;
      LPP 50 ;
      CPL 80 ;
      LMARGIN 10 ;
      PREVIEW

   EMPLOYE->( dbGoto( PrevRec ) )

RETURN
//---------------------------------------------*
PROCEDURE PaintDisplay_EMPL( aFldNames )

   LOCAL nCnt, cLblNames, nRow := 100

   @  90, 495 FRAME Frame_1 WIDTH 270 HEIGHT 450

   FOR nCnt := 1 TO Len( aFldNames )
      cLblNames := "Label_" + hb_ntos( nCnt )
      @ nRow, 510 LABEL &cLblNames VALUE aFldNames[nCnt] VCENTERALIGN
      nRow += 30
   NEXT

   @ 100, 610 TEXTBOX  Control_1 NUMERIC INPUTMASK "99999"
   @ 130, 610 TEXTBOX  Control_2         INPUTMASK Replicate( "A", 12 )
   @ 160, 610 TEXTBOX  Control_3         INPUTMASK Replicate( "A", 12 )
   @ 190, 610 TEXTBOX  Control_4         INPUTMASK "999-9999"
   @ 220, 610 TEXTBOX  Control_5 NUMERIC INPUTMASK "99"
   @ 250, 610 TEXTBOX  Control_6 NUMERIC INPUTMASK "9.99"
   @ 280, 610 TEXTBOX  Control_7 DATE
   @ 310, 610 TEXTBOX  Control_8 DATE
   @ 340, 610 TEXTBOX  Control_9 NUMERIC INPUTMASK "99999.99"
   @ 370, 610 TEXTBOX  Control_10        INPUTMASK Replicate( "A", 10 )

RETURN
//---------------------------------------------*
PROCEDURE Head1_EMPL

   SELECT EMPLOYE
   SET ORDER TO 1
   EMPLOYE->( dbGoTop() )
   Win_1.Browse_1.Value := EMPLOYE->( RecNo() )
   Win_1.Browse_1.Refresh
   LoadData_EMPL()

RETURN
//---------------------------------------------*
PROCEDURE Head10_EMPL

   SELECT EMPLOYE
   SET ORDER TO 2
   EMPLOYE->( dbGoTop() )
   Win_1.Browse_1.Value := EMPLOYE->( RecNo() )
   Win_1.Browse_1.Refresh
   LoadData_EMPL()

RETURN
//---------------------------------------------*
PROCEDURE QueryRecord_EMPL

   LOCAL found_rec

   PreQuery_EMPL()

   SELECT EMPLOYE
   SET FILTER TO
   EMPLOYE->( dbGoTop() )

   IF ! Empty( _qry_exp )
      COUNT TO found_rec FOR &_qry_exp
      dbGoTop()

      IF found_rec = 0
         Win_1.Statusbar.Item( 1 ) := "Not found!"
      ELSE
         SET FILTER TO &_qry_exp
         EMPLOYE->( dbGoTop() )
         Win_1.Statusbar.Item( 1 ) := "Found " + hb_ntos( found_rec ) + " record(s)!"
      ENDIF
   ELSE
      Win_1.StatusBar.Item( 1 ) := "Table EMPLOYE"
   ENDIF

   DisableField_EMPL()

   Win_1.Browse_1.Enabled := .T.
   Win_1.Browse_1.Value := EMPLOYE->( RecNo() )
   Win_1.Browse_1.Refresh
   LoadData_EMPL()

RETURN
//---------------------------------------------*
PROCEDURE PreQuery_EMPL

   LOCAL _ima_filter

   _qry_exp := ""
   _ima_filter := .F.

   IF ! Empty ( Win_1.Control_1.Value )         // CLI_ID
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_ID = " + Str( Win_1.Control_1.Value )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_2.Value )         // CLI_SNAM
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_SNAM = " + Chr( 34 ) + Win_1.Control_2.Value + Chr( 34 )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_3.Value )         // CLI_NAME
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_NAME = " + Chr( 34 ) + Win_1.Control_3.Value + Chr( 34 )
      _ima_filter := .T.
   ENDIF

   IF !( Win_1.Control_4.Value == "   -    " )  // CLI_TLF
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_TLF = " + Chr( 34 ) + Win_1.Control_4.Value + Chr( 34 )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_5.Value )         // CLI_DAYS
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_DAYS = " + Str( Win_1.Control_5.Value, 2 )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_6.Value )         // CLI_WAGE
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_WAGE = " + Str( Win_1.Control_6.Value, 4, 2 )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_7.Value )         // CLI_BDATE
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_BDATE = " + "CTOD(" + Chr( 34 ) + DToC( Win_1.Control_7.Value ) + Chr( 34 ) + ")"
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_8.Value )         // CLI_HDATE
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_HDATE = " + "CTOD(" + Chr( 34 ) + DToC( Win_1.Control_8.Value ) + Chr( 34 ) + ")"
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_9.Value )         // CLI_SALARY
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_SALARY = " + Str( Win_1.Control_9.Value, 8, 2 )
      _ima_filter := .T.
   ENDIF

   IF ! Empty ( Win_1.Control_10.Value )        // CLI_CITY
      IF _ima_filter
         _qry_exp += " .AND. "
      ENDIF
      _qry_exp += "CLI_CITY = " + Chr( 34 ) + Win_1.Control_10.Value + Chr( 34 )
   ENDIF

RETURN

// end of program *
