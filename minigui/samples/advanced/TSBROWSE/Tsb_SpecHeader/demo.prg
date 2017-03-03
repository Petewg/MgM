#include "adordd.ch"
#include "minigui.ch"
#include "TSBrowse.ch"
#include "hbsqlit3.ch"

#define CLR_DEFAULT   0xff000000

#define DB_NAME     'Employee.s3db'
#define DB_TABLE    'Employee'

#define PROGRAM 'TsBrowse Auto Function Demo'
#define VERSION ' version 1.01'
#define COPYRIGHT ' 2010-2011 by Janusz Pora'
#define IDI_GP 1001


STATIC pDb :=0
STATIC lChangeRecSql    := .f.
STATIC nEditRec         := 0

//---------------------------------------------------------------------
FUNCTION main()
//---------------------------------------------------------------------

  DEFINE WINDOW Form_1 ;
    AT 0,0 ;
    WIDTH 670 ;
    HEIGHT 500 ;
    TITLE PROGRAM ;
    ICON 'STAR.ICO' ;
    MAIN ;
    NOMAXIMIZE NOSIZE ;
    ON RELEASE CloseTable()

    DEFINE MAIN MENU
      POPUP '&Database'
        MENUITEM "ENUMERATOR"    ACTION ViewState(1,1)
        MENUITEM "AUTOSEARCH"    ACTION ViewState(1,2)
        MENUITEM "AUTOFILTER"    ACTION ViewState(1,3)
        SEPARATOR
        ITEM 'Exit' ACTION thiswindow.release
      END POPUP
/*
      POPUP '&Odbc Driver'
        MENUITEM "ENUMERATOR"    ACTION ViewState(2,1)
        MENUITEM "AUTOSEARCH"    ACTION ViewState(2,2)
        MENUITEM "AUTOFILTER"    ACTION ViewState(2,3)
      END POPUP
*/
      POPUP '&Array'
        MENUITEM "ENUMERATOR"    ACTION TsGrid(1)
        MENUITEM "AUTOSEARCH"    ACTION TsGrid(2)
      END POPUP

      POPUP '&SQL Tables'
        MENUITEM "ENUMERATOR"    ACTION TsSQL(1)
        MENUITEM "AUTOSEARCH"    ACTION TsSQL(2)
        MENUITEM "AUTOFILTER"    ACTION TsSQL(3)
        SEPARATOR
        MENUITEM "Create SQL"    ACTION CreatefromDBF( )
      END POPUP

      POPUP '&Info'
        ITEM 'About' ACTION dlg_about()

      END POPUP

    END MENU

  END WINDOW

  CENTER WINDOW Form_1

  ACTIVATE WINDOW Form_1

RETURN NIL



FUNCTION OpenTable(met)

  IF met == 2
    IF !IsWinNT() .AND. !CheckODBC()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
      ReleaseAllWindows()
    ENDIF

    SELECT(1)

    IF !FILE('Employee.mdb')
      CreateTable()
      USE Employee.mdb VIA "ADORDD" TABLE "table1"
      DBCreateIndex("State","State")
      DBCreateIndex("First","First")
      DBCreateIndex("City","City")
    ELSE
      USE Employee.mdb VIA "ADORDD" ALIAS 'Employee' TABLE "table1"
      dbSetIndex( "State" )
      dbSetIndex( "First" )
      dbSetIndex( "City" )
    ENDIF

    IF EMPTY( Employee->( LastRec() ) )
      APPEND FROM "Employee.DBF"
    ENDIF

    DBGoTop()

  ELSE

    RddSetDefault( "DBFNTX" )    // Clipper-Harbour

    USE Employee SHARED NEW
    Index On Employee->First+Employee->Last To Name    // NTX
    Index On Employee->State To State                  // NTX
    Set Index To Name, State                           // NTX

  ENDIF

RETURN NIL



PROCEDURE CloseTable

  USE

RETURN



PROCEDURE CreateTable

  DbCreate( "Employee.mdb;table1", {{"FIRST",     "C",20, 0 },;
                                   { "LAST",      "C",20, 0 },;
                                   { "STREET",    "C",30, 0 },;
                                   { "CITY",      "C",30, 0 },;
                                   { "STATE",     "C", 2, 0 },;
                                   { "ZIP",       "C",10, 0 },;
                                   { "AGE",       "N", 2, 0 },;
                                   { "SALARY",    "N", 6, 0 },;
                                   { "NOTES",     "C",70, 0 }}, "ADORDD" )

  DbCreate( "Employee.mdb;table2", {{"STATE",    "C", 2, 0 },;
                                   { "NAME",      "C",30, 0 }}, "ADORDD" )
RETURN



FUNCTION SetFlt(nCol,aDataFlt,oBrw)
  LOCAL n
  LOCAL aFld  := {'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' }
  LOCAL FltWar:= ""
  HB_SYMBOL_UNUSED( nCol )
  HB_SYMBOL_UNUSED( aDataFlt )
  HB_SYMBOL_UNUSED( oBrw )

  IF ValType(aDataFlt) == 'A'
    FOR n:=1 TO Len(aDataFlt)
      IF !Empty(aDataFlt[n])
        FltWar +=IF(!Empty( FltWar)," .and. ","")+aFld[n]+" == '"+ aDataFlt[n]+"'"
      ENDIF
    NEXT
  ENDIF

RETURN FltWar



FUNCTION DelFlt()

  IF Used()
    DBSETFILTER("" )
    DBGoTop()
  ENDIF

RETURN NIL



FUNCTION Refresh_Win(fm_edit, oBrw)
  LOCAL cInfo

  IF _IsWIndowActive (fm_edit)
    oBrw:Refresh(.f.)
    cInfo := AllTrim(Str(recno()))+"/"+ AllTrim(Str(RecCount()))
    SetProperty(fm_edit,"Lbl_10b","Value",cInfo)
  ENDIF

RETURN NIL



FUNCTION Release_Brw1(fm_edit)

    RELEASE WINDOW &fm_edit

RETURN NIL



FUNCTION TbMove(met,oBrw)

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



FUNCTION EditDan(aHead,aFld,aWidth)
  LOCAL aPos:= GetChildPos('Form_Gr')
  LOCAL n, cLbl, cGBox, cValue

  IF RecCount() > 0
    IF .Not. IsWIndowActive (Form_Ed)

      DEFINE WINDOW Form_Ed;
        AT aPos[1]+50,aPos[2]+20 ;
        WIDTH 600 HEIGHT 125+ 30*Len(aHead) ;
        TITLE 'Edit current record' ;
        MODAL

        DEFINE SPLITBOX
          DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 28,28 FONT "Arial" SIZE 9 FLAT CAPTION 'Save'
            BUTTON saveItem PICTURE "save" ACTION SaveDan(aFld) TOOLTIP "Save date"  SEPARATOR
            BUTTON exititem PICTURE "exit2" ACTION thiswindow.release TOOLTIP "Exit"
          END TOOLBAR
        END SPLITBOX


        @ 50,20  FRAME Frame_2 CAPTION "Fields" WIDTH 120 HEIGHT 30*Len(aHead)+30

        FOR n:=1 TO Len(aHead)
          cLbl := "Lbl_"+AllTrim(Str(n))
          cGBox:= "GBox_"+AllTrim(Str(n))
          cValue:="EMPLOYEE->"+aFld[n]

          @ 50+n*30,30 LABEL &cLbl ;
            VALUE aHead[n] ;
            AUTO

          @ 50+n*30,160 GETBOX &cGBox ;
            HEIGHT 24 WIDTH aWidth[n];
            VALUE &cValue ;
            FONT "Arial" SIZE 9
        NEXT

      END WINDOW

         Form_Ed.Activate

    ELSE
      FOR n:=1 TO Len(aHead)
        cValue:="EMPLOYEE->"+aFld[n]
        cGBox:= "GBox_"+AllTrim(Str(n))
        SetProperty("Form_Ed",cGBox,'Value',&cValue)
      NEXT

      RESTORE WINDOW Form_Ed

    ENDIF

  ENDIF

RETURN NIL



FUNCTION SaveDan(aFld)
  LOCAL n,value,cGBox, cFld

  IF RLock()

    FOR n:=1 TO Len(aFld)
      cFld  := aFld[n]
      cGBox := "GBox_"+AllTrim(Str(n))
      value :=GetProperty("Form_Ed",cGBox,'Value')
      replace &cFld   with value
    NEXT

    dbUnlock()

  ENDIF

  thiswindow.release

RETURN NIL



*-------------------------------------------------------------
FUNCTION dlg_about()
*-------------------------------------------------------------

RETURN MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
   "Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
   hb_compiler() + CRLF + version() + CRLF + ;
   Left(MiniGuiVersion(), 38), "About " + PROGRAM, 0, .f. )




FUNCTION ViewState(met,nVer)
  LOCAL Tyt, Brw_1
  LOCAL aPos := GetChildPos('Form_1')
  LOCAL aHead, aWidth, aFld , cInfo
  LOCAL blUserSearch := NIL
  LOCAL blUserFilter := NIL
  LOCAL nRec :=1

  IF .Not. IsWindowActive (Form_Gr)

    OpenTable(met)

    Tyt :='Browse Database Via '+IF(met==2,"ADORDD","DBFNTX")
    Select("EMPLOYEE")

    DEFINE WINDOW Form_Gr ;
      AT aPos[1]+50,aPos[2]+20 ;
      WIDTH 740 HEIGHT 580 ;
      TITLE tyt;
      CHILD NOMAXIMIZE ;
      ON INIT Refresh_Win("Form_Gr", Brw_1) ;
      ON RELEASE CloseTable()

      DEFINE IMAGELIST Im_edit ;
        BUTTONSIZE 26 , 26  ;
        IMAGE {'edit'} ;
        COLORMASK CLR_DEFAULT;
        IMAGECOUNT 5;
        MASK

      DEFINE IMAGELIST im_navi ;
        BUTTONSIZE 20 , 20  ;
        IMAGE {'navi2'} ;
        COLORMASK CLR_DEFAULT;
        IMAGECOUNT 6;
        MASK

      DEFINE SPLITBOX

        DEFINE TOOLBAREX Tb_Edit BUTTONSIZE 26,26 IMAGELIST "im_edit" FLAT CAPTION 'Edition'

          BUTTON Button_2 PICTUREINDEX 2 TOOLTIP 'Edit record' ACTION {||EditDan(aHead,aFld,aWidth), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON Button_3 PICTUREINDEX 3 TOOLTIP 'Add record' ACTION MsgInfo('Click!')
          BUTTON Button_4 PICTUREINDEX 1 TOOLTIP 'Delete record' ACTION MsgInfo('Click!') SEPARATOR

        END TOOLBAR

        DEFINE TOOLBAREX Tb_Navi BUTTONSIZE 20,20 IMAGELIST "im_navi" FLAT CAPTION 'Navigations'

          BUTTON top  PICTUREINDEX 0 TOOLTIP "Top Table"    ACTION {||TbMove(1, Brw_1), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON prve PICTUREINDEX 1 TOOLTIP "Prev Screen"  ACTION {||TbMove(2, Brw_1), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON prev PICTUREINDEX 2 TOOLTIP "Prev Record"  ACTION {||TbMove(3, Brw_1), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON next PICTUREINDEX 3 TOOLTIP "Next Record"  ACTION {||TbMove(4, Brw_1), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON nxte PICTUREINDEX 4 TOOLTIP "Next Screen"  ACTION {||TbMove(5, Brw_1), Refresh_Win("Form_Gr", Brw_1)}
          BUTTON bott PICTUREINDEX 5 TOOLTIP "Botton Table" ACTION {||TbMove(6, Brw_1), Refresh_Win("Form_Gr", Brw_1)}

        END TOOLBAR

        DEFINE TOOLBAREX ToolBar_3 BUTTONSIZE 28,28 FONT "Arial" SIZE 9 FLAT CAPTION 'Exit'
          BUTTON Exit PICTURE "exit2" ACTION Release_Brw1("Form_Gr") TOOLTIP "Exit"
        END TOOLBAR

      END SPLITBOX

      SetProperty("Form_Gr","Button_3","Enabled",.f.)
      SetProperty("Form_Gr","Button_4","Enabled",.f.)

      aHead := { 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' }
      aWidth:= { 110 , 150 ,150, 150, 50, 80,50,80, 200 }
      aFld  := {'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' }

      DBGoTo(nRec)

      DO CASE

        CASE nVer == 1

          DEFINE TBROWSE Brw_1 AT 50,10 ALIAS 'EMPLOYEE' ;
            WIDTH 710   ;
            HEIGHT 390   ;
            HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
            WIDTHS  110 , 150 ,150, 150,50, 80, 50, 80, 200 ;
            FIELDS EMPLOYEE->First , EMPLOYEE->Last, EMPLOYEE->Street, EMPLOYEE->City,EMPLOYEE->State, EMPLOYEE->Zip,EMPLOYEE->Age,EMPLOYEE->Salary, EMPLOYEE->Notes ;
            ENUMERATOR ;
            VALUE nRec;
            ON CHANGE Refresh_Win("Form_Gr",Brw_1) ;
            ON DBLCLICK  (EditDan(aHead,aFld,aWidth), Refresh_Win("Form_Gr", Brw_1))
          END TBROWSE

        CASE nVer == 2

          DEFINE TBROWSE Brw_1 AT 50,10 ALIAS 'EMPLOYEE' ;
            WIDTH 710   ;
            HEIGHT 390   ;
            HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
            WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
            FIELDS EMPLOYEE->First , EMPLOYEE->Last, EMPLOYEE->Street, EMPLOYEE->City,EMPLOYEE->State, EMPLOYEE->Zip,EMPLOYEE->Age,EMPLOYEE->Salary, EMPLOYEE->Notes ;
            AUTOSEARCH  ;
            CELLED EDIT;
            VALUE nRec;
            ON CHANGE Refresh_Win("Form_Gr",Brw_1) ;
            ON DBLCLICK  (EditDan(aHead,aFld,aWidth), Refresh_Win("Form_Gr", Brw_1))

            :aColumns[ 1 ]:lEdit := .t.
            :aColumns[ 3 ]:lEditSpec := .F.

          END TBROWSE

        CASE nVer == 3

          IF met== 2

            DEFINE TBROWSE Brw_1 AT 50,10 ALIAS 'EMPLOYEE' ;
              WIDTH 710   ;
              HEIGHT 390   ;
              HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
              WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
              FIELDS EMPLOYEE->First , EMPLOYEE->Last, EMPLOYEE->Street, EMPLOYEE->City,EMPLOYEE->State, EMPLOYEE->Zip,EMPLOYEE->Age,EMPLOYEE->Salary, EMPLOYEE->Notes ;
              AUTOFILTER USERFILTER {|x,y,z| SetFlt(x,y,z) } ;
              CELLED EDIT;
              VALUE nRec;
              ON CHANGE Refresh_Win("Form_Gr",Brw_1)

            END TBROWSE

          ELSE

            DEFINE TBROWSE Brw_1 AT 50,10 ALIAS 'EMPLOYEE' ;
              WIDTH 710   ;
              HEIGHT 390   ;
              HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
              WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
              FIELDS EMPLOYEE->First , EMPLOYEE->Last, EMPLOYEE->Street, EMPLOYEE->City,EMPLOYEE->State, EMPLOYEE->Zip,EMPLOYEE->Age,EMPLOYEE->Salary, EMPLOYEE->Notes ;
              AUTOFILTER  ;
              CELLED EDIT;
              VALUE nRec;
              ON CHANGE Refresh_Win("Form_Gr",Brw_1)

            END TBROWSE

          ENDIF

      ENDCASE


      Brw_1:nHeightHead += 5

      Brw_1:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                      { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
                      { CLR_HBLUE, CLR_BLUE }, ;     // degraded cursor background color
                      CLR_HGREEN, CLR_BLACK } )      // text colors
      Brw_1:SetColor( { 2, 4, 14 }, ;
                      { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                      { CLR_WHITE, CLR_BLACK }, ;    // degraded headers backgroud color
                      { CLR_HGREEN, CLR_BLACK } } )  // degraded order column background color

      Brw_1:nLineStyle := LINES_VERT
      Brw_1:aColumns[ 1 ]:cOrder := "FIRST"
      Brw_1:aColumns[ 4 ]:cOrder := "CITY"
      Brw_1:SetAppendMode( .T. )
      Brw_1:SetIndexCols( 1, 2 )


      Brw_1:GoPos(nRec)

      cInfo := AllTrim(Str(recno()))+"/"+ AllTrim(Str(RecCount()))
      @ 510, 520 LABEL Lbl_10a VALUE "Recno:" AUTO
      @ 510, 620 LABEL Lbl_10b VALUE cInfo AUTO BOLD

    END WINDOW

    ACTIVATE WINDOW Form_Gr

  ELSE

    RESTORE WINDOW Form_Gr

  ENDIF


RETURN NIL



FUNCTION GetChildPos(cFormName)
  LOCAL i, yw, xw, hrb:=0, hTit
  LOCAL hwnd,actpos:={0,0,0,0}

  hTit := GetMenubarHeight()
  hwnd := GetFormHandle(cFormName)
  GetWindowRect(hwnd,actpos)

  yw := actpos[2]
  xw := actpos[1]

  i := aScan ( _HMG_aFormHandles , hWnd )
  IF i > 0
    IF _HMG_aFormReBarHandle [i] > 0
      hrb = RebarHeight ( _HMG_aFormReBarHandle [i] )
    ENDIF
  ENDIF

  yw += (hrb + hTit)

RETURN {yw,xw}



STATIC FUNCTION CheckODBC()
  LOCAL oReg, cKey := ""

  OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
    SECTION "Software\Microsoft\DataAccess"

  GET VALUE cKey NAME "Version" OF oReg

  CLOSE REGISTRY oReg

RETURN !EMPTY(cKey)



FUNCTION TsGrid (nVer)

  LOCAL aRows [20] [8] , Grid1 , hFont
  LOCAL aTab := {}
  LOCAL aPos := GetChildPos('Form_1')
  LOCAL blUserSearch := NIL
  LOCAL blUserFilter := NIL

  aRows [1]   := {1,'Simpson','Homer','555-5555',113.12,date(),1 , .t. }
  aRows [2]   := {3,'Mulder','Fox','324-6432',123.12,date(),2 , .f. }
  aRows [3]   := {2,'Smart','Max','432-5892',133.12,date(),3 , .t. }
  aRows [4]   := {1,'Grillo','Pepe','894-2332',143.12,date(),4 , .f. }
  aRows [5]   := {2,'Kirk','James','346-9873',153.12,date(),5 , .t. }
  aRows [6]   := {1,'Barriga','Carlos','394-9654',163.12,date(),6 , .f. }
  aRows [7]   := {3,'Flanders','Ned','435-3211',173.12,date(),7 , .t. }
  aRows [8]   := {3,'Smith','John','123-1234',183.12,date(),8 , .f. }
  aRows [9]   := {2,'Pedemonti','Flavio','000-0000',193.12,date(),9 , .t. }
  aRows [10]  := {2,'Gomez','Juan','583-4832',113.12,date(),10, .f. }
  aRows [11]  := {3,'Fernandez','Raul','321-4332',123.12,date(),11, .t. }
  aRows [12]  := {1,'Borges','Javier','326-9430',133.12,date(),12, .f. }
  aRows [13]  := {2,'Alvarez','Alberto','543-7898',143.12,date(),13, .t. }
  aRows [14]  := {1,'Gonzalez','Ambo','437-8473',153.12,date(),14, .f. }
  aRows [15]  := {1,'Batistuta','Gol','485-2843',163.12,date(),15, .t. }
  aRows [16]  := {1,'Vinazzi','Amigo','394-5983',173.12,date(),16, .f. }
  aRows [17]  := {2,'Pedemonti','Flavio','534-7984',183.12,date(),17, .t. }
  aRows [18]  := {1,'Samarbide','Armando','854-7873',193.12,date(),18, .f. }
  aRows [19]  := {3,'Pradon','Alejandra','???-????',113.12,date(),19, .t. }
  aRows [20]  := {1,'Reyes','Monica','432-5836',123.12,date(),20, .f. }


  IF .Not. IsWIndowActive (Form_11)
    DEFINE FONT Font_1  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC
    hFont := GetFontHandle( "Font_1" )

    DEFINE WINDOW Form_11 ;
      AT aPos[1]+20,aPos[2]+10 ;
      WIDTH 640 HEIGHT 450 ;
      TITLE 'Browse of Tables (Grid Form)';
      CHILD NOMAXIMIZE ;
      ON INIT  LoadTabDan(Grid1,aRows);


      DO CASE

        CASE nVer == 1

          @ 10,10 TBROWSE Grid1 ARRAY aTab;
             WIDTH 620 ;
             HEIGHT 326 ;
             HEADERS ' ','Last~Name','First~Name','Phone','Value~Data Types','Date~Data Types','Num.~Data Types','Logic~Data Types' ;
             WIDTHS 18,100,100,100,60,80,40,40 ;
             ENUMERATOR ;
             IMAGE "br_em","br_ok","br_no";
             EDIT CELLED;
             JUSTIFY { DT_CENTER, DT_LEFT, DT_LEFT, DT_CENTER, DT_RIGHT, DT_CENTER, DT_RIGHT, DT_CENTER}

        CASE nVer == 2

          @ 10,10 TBROWSE Grid1 ARRAY aTab;
            WIDTH 620 ;
            HEIGHT 326 ;
            HEADERS ' ','Last~Name','First~Name','Phone','Value~Data Types','Date~Data Types','Num.~Data Types','Logic~Data Types' ;
            WIDTHS 18,100,100,100,60,80,40,40 ;
            AUTOSEARCH ;
            IMAGE "br_em","br_ok","br_no";
            EDIT CELLED;
            JUSTIFY { DT_CENTER, DT_LEFT, DT_LEFT, DT_CENTER, DT_RIGHT, DT_CENTER, DT_RIGHT, DT_CENTER}

            Grid1:aColumns[ 1 ]:lBitMap  := .t.
            Grid1:aColumns[ 1 ]:lEdit  := .f.
            Grid1:aColumns[ 1 ]:lEditSpec  := .F.

      ENDCASE

      Grid1:nLineStyle :=  LINES_VERT
      Grid1:nHeightCell += 1
      Grid1:nHeightHead += 10
      Grid1:nHeightSuper+= 15
      Grid1:Set3DText( .F., .F. )
      Grid1:ChangeFont( hFont, 4, 4 )   // 4 = SupeColumn  4 = Nivel SuperHeader

      Grid1:SetColor( { 1, 3, 5, 6, 13, 15 ,17}, ;
                      { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
                      { CLR_HBLUE, CLR_BLUE }, ; // degraded cursor background color
                        CLR_HGREEN, CLR_BLACK ,;
                        CLR_HRED } )  // text superheader
      Grid1:SetColor( { 2, 4, 14,16 }, ;
                      { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                      { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                      { CLR_HGREEN, CLR_BLACK }, ;  // degraded order column background color
                      { CLR_WHITE, CLR_BLUE }  } ) // degraded superheaders backgroud color

      Grid1:SetColor( {17}, {CLR_HGREEN}, 4 )


      Grid1:SetDeleteMode( .T., .T. )  // Activate Key DEL and confirm
      Grid1:SetSelectMode( .t. )
      Grid1:SetAppendMode( .T. )

    END WINDOW

    CENTER WINDOW Form_11

    ACTIVATE WINDOW Form_11
    RELEASE FONT Font_1

  ELSE

    RESTORE WINDOW Form_11

  ENDIF

RETURN NIL



FUNCTION LoadTabDan(Grid1,aRow)
  LOCAL n

  DELETE ITEM ALL FROM Grid1 OF Form_11
    FOR n :=1 TO Len(aRow)
      Grid1:AddItem( aRow[n] )
    NEXT

    Grid1:aColumns[ 1 ]:lBitMap    := .t.
    Grid1:aColumns[ 1 ]:lEdit      := .f.
    Grid1:aColumns[ 2 ]:bArraySort := {|x,y| x[2]+x[4] < y[2]+y[4] }
    Grid1:aColumns[ 4 ]:bArraySort := {|x,y| x[4]+Str(x[5],5,2) < y[4]+Str(x[5],5,2) }
    Grid1:aColumns[ 5 ]:bArraySort := {|x,y| Str(x[5],5,2)+x[4] < Str(x[5],5,2)+y[4] }

RETURN NIL



FUNCTION TsSQL (nVer)

  LOCAL Grid1, n
  LOCAL aTab := {}
  LOCAL aPos := GetChildPos('Form_1')
  LOCAL blUserSearch := NIL
  LOCAL blUserFilter := NIL
  LOCAL nRec :=1

  IF .Not. IsWIndowActive (Form_SQL)

    DEFINE FONT Font_1  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC
    pDb := sqlite3_open( DB_NAME, .t. )


    DEFINE WINDOW Form_SQL ;
      AT aPos[1]+50,aPos[2]+20 ;
      WIDTH 740 HEIGHT 580 ;
      TITLE 'Browse of SQL Tables';
      CHILD NOMAXIMIZE ;
      ON INIT {|| LoadTabSQL(Grid1,pDb) }

      DEFINE IMAGELIST im_navi ;
        BUTTONSIZE 20 , 20  ;
        IMAGE {'navi2'} ;
        COLORMASK CLR_DEFAULT;
        IMAGECOUNT 6;
        MASK

      DEFINE SPLITBOX

        DEFINE TOOLBAREX Tb_Navi BUTTONSIZE 20,20 IMAGELIST "im_navi" FLAT CAPTION 'Navigations'

          BUTTON top  PICTUREINDEX 0 TOOLTIP "Top Table"    ACTION {||TbMove(1, Grid1)}
          BUTTON prve PICTUREINDEX 1 TOOLTIP "Prev Screen"  ACTION {||TbMove(2, Grid1)}
          BUTTON prev PICTUREINDEX 2 TOOLTIP "Prev Record"  ACTION {||TbMove(3, Grid1)}
          BUTTON next PICTUREINDEX 3 TOOLTIP "Next Record"  ACTION {||TbMove(4, Grid1)}
          BUTTON nxte PICTUREINDEX 4 TOOLTIP "Next Screen"  ACTION {||TbMove(5, Grid1)}
          BUTTON bott PICTUREINDEX 5 TOOLTIP "Botton Table" ACTION {||TbMove(6, Grid1)}

        END TOOLBAR

        DEFINE TOOLBAREX ToolBar_3 BUTTONSIZE 28,28 FONT "Arial" SIZE 9 FLAT CAPTION 'Exit'
          BUTTON Exit PICTURE "exit2" ACTION Release_Brw1("Form_SQL") TOOLTIP "Exit"
        END TOOLBAR

      END SPLITBOX


      DO CASE

        CASE nVer == 1

          DEFINE TBROWSE Grid1 AT 50,10  ARRAY aTab;
            WIDTH 710   ;
            HEIGHT 390   ;
            HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
            WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
            ENUMERATOR ;
            ON CHANGE Change_TsSql(pDb,Grid1);

          END TBROWSE

        CASE nVer == 2

          DEFINE TBROWSE Grid1 AT 50,10  ARRAY aTab;
            WIDTH 710   ;
            HEIGHT 390   ;
            HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
            WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
            AUTOSEARCH  ;
            CELLED EDIT;
            ON CHANGE Change_TsSql(pDb,Grid1);

            :aColumns[ 3 ]:lEditSpec := .F.
            :aColumns[ 6 ]:lEditSpec := .F.
            :aColumns[ 7 ]:lEditSpec := .F.
            :aColumns[ 8 ]:lEditSpec := .F.
            :aColumns[ 9 ]:lEditSpec := .F.

          END TBROWSE

        CASE nVer == 3

          DEFINE TBROWSE Grid1 AT 50,10  ARRAY aTab;
            WIDTH 710   ;
            HEIGHT 390   ;
            HEADERS 'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' ;
            WIDTHS  110 , 150 ,150, 150,50, 80,50,80, 200 ;
            AUTOFILTER USERFILTER {|x,y,z| SetFltSQL(x,y,z) } ;
            CELLED EDIT;
            ON CHANGE Change_TsSql(pDb,Grid1);

            :aColumns[ 3 ]:lEditSpec := .F.
            :aColumns[ 6 ]:lEditSpec := .F.
            :aColumns[ 7 ]:lEditSpec := .F.
            :aColumns[ 8 ]:lEditSpec := .F.
            :aColumns[ 9 ]:lEditSpec := .F.

          END TBROWSE

          @ 450, 20 LABEL Lb1 VALUE "Note:" BOLD

          @ 470, 40 LABEL Lb2 VALUE "Try filtering on any piece of text, for example enter '%OO' in SpecHader of Colunm 'Last' " ;
            WIDTH 500 HEIGHT 40


      ENDCASE

      Grid1:nHeightHead += 5

      Grid1:SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                         { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
                         { CLR_HBLUE, CLR_BLUE }, ; // degraded cursor background color
                           CLR_HGREEN, CLR_BLACK } )  // text colors
      Grid1:SetColor( { 2, 4, 14 }, ;
                         { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                           { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                           { CLR_HGREEN, CLR_BLACK } } )  // degraded order column background color

      Grid1:nLineStyle := LINES_VERT
      Grid1:SetAppendMode( .T. )
      Grid1:SetDeleteMode( .T., .F.)   // Activate Key DEL and confirm

      FOR n:=1 TO 5
         Grid1:acolumns[n]:lEdit:=.T.
         Grid1:aColumns[n]:bPrevEdit := { || nEditRec := Grid1:nAt  }
         Grid1:aColumns[n]:bPostEdit := { || lChangeRecSql := IF(Grid1:lChanged, .t., lChangeRecSql ) }
      NEXT


    END WINDOW

    CENTER WINDOW Form_SQL

    ACTIVATE WINDOW Form_SQL

    RELEASE FONT Font_1

  ELSE

    RESTORE WINDOW Form_SQL

  ENDIF

RETURN NIL



FUNCTION LoadTabSql(Grid1,db,cWar)
  LOCAL cTable := DB_TABLE
  LOCAL i , cQuery, aResult

  Grid1:DeleteRow(.t.)

  IF Empty(cWar )
     cQuery :=  'SELECT FIRST ,LAST, STREET, CITY, STATE, ZIP, HIREDATE, '+;
                'MARRIED, AGE, SALARY, NOTES  FROM '+ cTable + ' ORDER BY FIRST '
  ELSE
     cQuery :=  'SELECT FIRST ,LAST, STREET, CITY, STATE, ZIP, HIREDATE, '+;
                'MARRIED, AGE, SALARY, NOTES  FROM '+ cTable +;
                ' WHERE '+ cWar+ ' ORDER BY FIRST '
  ENDIF

  aResult := SQLITE_QUERY( db, cQuery )

  IF Len(aResult) > 0
    FOR i := 1 TO Len(aResult) STEP 11
      ADD ITEM  { aResult[i], aResult[i+1], aResult[i+2], aResult[i+3], aResult[i+4],;
                  aResult[i+5], aResult[i+6],ctod(aResult[i+7]), aResult[i+8],;
                  , aResult[i+9], aResult[i+10]} TO Grid1 OF Form_SQL
    NEXT
  ENDIF

RETURN NIL



FUNCTION SetFltSQL(nCol,aDataFlt,oBrw)
  LOCAL n
  LOCAL aFld  := {'First' , 'Last', 'Street', 'City','State', 'Zip','Age','Salary', 'Notes' }
  LOCAL FltWar:= ""

  HB_SYMBOL_UNUSED( nCol )

  IF ValType(aDataFlt) == 'A'
    FOR n:=1 TO Len(aDataFlt)
      IF !Empty(aDataFlt[n])
        IF Empty( FltWar)
          FltWar := aFld[n]+" LIKE '"+ AllTrim(aDataFlt[n])+"%'"
        ELSE
          FltWar +=" AND "+aFld[n]+" LIKE '"+ AllTrim(aDataFlt[n])+"%'"
        ENDIF
      ENDIF
    NEXT
  ENDIF

  IF !Empty(FltWar)
    LoadTabSql(oBrw,pDb,FltWar)
  ENDIF

RETURN FltWar



FUNCTION Change_TsSql(db,oGrid)
  LOCAL nSel

  IF (IsWIndowActive (Form_SQL) )

    IF lChangeRecSql

      nSel := MsgYesNoCancel ( "Save the data? "," Record " )

      DO CASE

        CASE nSel == 1
          SaveRecSql(db,oGrid)

        CASE nSel == -1
          oGrid:Refresh(.t.)
          lChangeRecSql := .f.

      ENDCASE

    ENDIF

  ENDIF

RETURN NIL



FUNCTION SaveRecSql(db, oGrid)
  LOCAL cTable := cFileNoExt(DB_NAME),  cQuery
  LOCAL nPos := nEditRec

  HB_SYMBOL_UNUSED( db )

  IF lChangeRecSql .and. nEditRec  != 0

    cQuery := "UPDATE "+ cTable + " SET "
    cQuery +="FIRST = '" + oGrid:aArray[nPos,1] + "'"
    cQuery += ", LAST = '" + oGrid:aArray[nPos,2] + "'"
    cQuery += ", STREET = '" + oGrid:aArray[nPos,3] + "'"
    cQuery += ", CITY = '" + oGrid:aArray[nPos,4] + "'"
    cQuery += ", STATE = '" + oGrid:aArray[nPos,5] + "'"
    cQuery +="  WHERE ZIP = '" + oGrid:aArray[nPos,6]+"'"

    nEditRec  := 0

    IF sqlite3_exec( pDB, cQuery ) == SQLITE_OK
      lChangeRecSql :=.f.
    ELSE
      msginfo(cQuery)
      msgInfo('Changes not saved',"Save Error")
    ENDIF

  ENDIF

RETURN NIL



*------------------------------
 FUNCTION CreatefromDBF( )
*---------------------------------------------------------------------------
  LOCAL cHeader, cQuery := "", NrReg:= 0, cTable := DB_TABLE
  LOCAL lCreateIfNotExist := .f., nErr
  LOCAL db

  IF FILE( cTable+'.dbf' )

    IF Empty( db:=OpenBase( cTable ))
      MsgStop( "Can't open/create " + DB_NAME, "Error" )
      RETURN NIL
    ENDIF

    IF SQLITE_TABLEEXISTS( cTable )
      IF SQLITE_DROPTABLE(cTable)
        cHeader := QueryCrea(cTable,0)

        IF !sqlite3_exec( db, cHeader ) == SQLITE_OK
          RETURN NIL
        ENDIF

      ELSE
        RETURN NIL
      ENDIF
      
    ELSE
      cHeader := QueryCrea(cTable,0)
      nErr:=sqlite3_exec( db, cHeader )

      IF !nErr == SQLITE_OK
        Msginfo(cHeader+CRLF+str(nErr))
        RETURN NIL

      ENDIF
      
    ENDIF

    IF SQLITE_TABLEEXISTS( cTable )
      USE Employee ALIAS Employee NEW
      GO TOP
      cQuery := ''

      DO WHILE !Eof()
        cQuery +=  QueryCrea(cTable,1)
        IF sqlite3_exec( db, "BEGIN TRANSACTION;" + cQuery + "COMMIT;" ) == SQLITE_OK
          NrReg++
        ELSE
          Msginfo(cQuery,'Table: '+cTable + Str(NrReg) )
          EXIT
        ENDIF

        cQuery := ''
        skip

      ENDDO

      MsgInfo( ALLTRIM(STR(NrReg))+" records added to table "+cTable, "Result" )


    ENDIF

    USE

  ELSE
    MsgStop( "File "+cTable+" doesn't exist!" )
  ENDIF

RETURN 0



STATIC FUNCTION OpenBase(cTable)
  LOCAL lExistDB  := File( DB_NAME )
  LOCAL pDB := SQLite3_Open( DB_NAME, .t. )
  LOCAL cQuery

  IF !EMPTY( pDB )
    SQLite3_Exec( pDB, 'PRAGMA auto_vacuum = 0' )
    IF !lExistDB

      cQuery := QueryCrea(cTable,0)
      SQLite3_Exec( pDB, cQuery )

    ENDIF
  ENDIF

RETURN pDB


FUNCTION QueryCrea(cTable,met)
  LOCAL cQuery := ""

  DO CASE
    CASE met ==0
      cQuery := "create table " + cTable + "( FIRST CHAR(20) , "+;
                "LAST CHAR(20), "+;
                "STREET CHAR(30), "+;
                "CITY CHAR(30), "+;
                "STATE CHAR(2), "+;
                "ZIP CHAR(10), "+;
                "HIREDATE DATE , "+;
                "MARRIED INTEGER , "+;
                "AGE INTEGER , "+;
                "SALARY INTEGER, "+;
                "NOTES TEXT ); "

    CASE met == 1

      cQuery := 'INSERT INTO '+ cTable + ' ( FIRST ,LAST, STREET, CITY, STATE, ZIP, HIREDATE, '+;
                'MARRIED, AGE, SALARY, NOTES  ) VALUES ( "'
      cQuery += RTrim(Employee->FIRST)+'" , "'+RTrim(Employee->LAST)+'", "'+RTrim(Employee->STREET)+'" , "'
      cQuery += RTrim(Employee->CITY)+'" , "'+RTrim(Employee->STATE)+'" , "'+RTrim(Employee->ZIP)+'" , "'
      cQuery += dtoc(Employee->HIREDATE)+'" , '+str(IF(Employee->MARRIED,1,0),1)+' , '
      cQuery += str(Employee->AGE,2)+' , '+str(Employee->SALARY,6)+' , "'+RTrim(Employee->NOTES)+ '"  );'

    CASE met == 2
      cQuery := 'SELECT FIRST ,LAST, STREET, CITY, STATE, ZIP, HIREDATE, '+;
                'MARRIED, AGE, SALARY, NOTES  FROM '+ cTable + ' ORDER BY FIRST '

  ENDCASE

RETURN cQuery



*------------------------------------
 FUNCTION SQLITE_TABLEEXISTS( cTable )
*---------------------------------------------------------------------------
* Uses a (special) master table where the names of all tables are stored
*---------------------------------------------------------------------------
  LOCAL cStatement, lRet := .f.
  LOCAL lCreateIfNotExist := .f.
  LOCAL db := sqlite3_open( DB_NAME, lCreateIfNotExist )

  cStatement := "SELECT name FROM sqlite_master "    +;
                "WHERE type ='table' AND tbl_name='" +;
                cTable + "'"

  IF DB_IS_OPEN( db )
    lRet := ( Len( SQLITE_QUERY( db, cStatement ) ) > 0 )
  ENDIF

RETURN( lRet )



*--------------------------------------
 FUNCTION SQLITE_QUERY( db, cStatement )
*---------------------------------------------------------------------------
  LOCAL stmt, nCCount, nI, nCType
  LOCAL aRet := {}

  stmt := sqlite3_prepare( db, cStatement )

  IF STMT_IS_PREPARED( stmt )
  
    DO WHILE sqlite3_step( stmt ) == SQLITE_ROW
      nCCount := sqlite3_column_count( stmt )

      IF nCCount > 0
        FOR nI := 1 TO nCCount
          nCType := sqlite3_column_type( stmt, nI )

          SWITCH nCType
            CASE SQLITE_NULL
              AADD( aRet, "NULL")
              EXIT

            CASE SQLITE_FLOAT
            CASE SQLITE_INTEGER
              AADD( aRet, LTRIM(STR( sqlite3_column_int( stmt, nI ) )) )
              EXIT

            CASE SQLITE_TEXT
              AADD( aRet, sqlite3_column_text( stmt, nI ) )
              EXIT
          END SWITCH
        NEXT nI
      ENDIF

    ENDDO

    sqlite3_finalize( stmt )

  ENDIF

RETURN( aRet )



*--------------------------------
 FUNCTION SQLITE_DROPTABLE(cTable)
*---------------------------------------------------------------------------
* Deletes a table from current database
* WARNING !!   It deletes forever...
*---------------------------------------------------------------------------
  LOCAL db, lRet := .F.

  IF !EMPTY(cTable)
    IF MsgYesNo("The  table "+cTable+" will be erased" + CRLF + ;
                "without any choice to recover." + CRLF + CRLF + ;
                "       Continue ?", "Warning!" )

      db := sqlite3_open_v2(DB_NAME, SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )

      IF DB_IS_OPEN( db )
        IF sqlite3_exec( db, "drop table " + cTable ) == SQLITE_OK
          IF sqlite3_exec( db, "vacuum" ) == SQLITE_OK
            lRet := .T.
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF

RETURN lRet
