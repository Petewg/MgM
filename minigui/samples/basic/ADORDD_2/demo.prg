/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2007 Janusz Pora <januszpora@onet.eu>
*/

#include "adordd.ch"
#include "minigui.ch"

#define CLR_DEFAULT   0xff000000

MEMVAR aStateTab
STATIC aItemState :={}

Function Main()
   LOCAL oBrw,pos
   PRIVATE aStateTab:={}

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 580 ;
      TITLE 'ADO Rdd Demo' ;
      MAIN NOMAXIMIZE ;
      ON INIT OpenTable() ;
      ON RELEASE CloseTable()

      @ 15 ,20 LABEL Lbl_1;
         VALUE "States" ;
         WIDTH 350 HEIGHT 35 ;
         FONT "Arial" SIZE 18 BOLD ;
         FONTCOLOR BLUE ;
         CENTERALIGN

      @ 50 ,20 GRID Grid_1;
         WIDTH 350  HEIGHT 490;
         WIDTHS {60,250};
         HEADERS {'State','Name'};
         ITEMS aStateTab;
         ON DBLCLICK {|| pos:= Form_1.Grid_1.Value, ViewState(aStateTab[pos,2],aStateTab[pos,1] ) }

         @ 50,430  FRAME Frame_1 CAPTION "Search for:" WIDTH 190 HEIGHT 200

         @ 70 ,440 RADIOGROUP Radio_1;
            OPTIONS { 'City','First Name','Last Name'};
            VALUE 1

         @ 160,460 GETBOX GBox_1 ;
               HEIGHT 24 WIDTH 120;
               VALUE "                  " ;
               FONT "Arial" SIZE 9 ;
               ON CHANGE FindChg();
               PICTURE  '@XXXXXXXXXXXXXXXXXXXXXXX'

         @ 190 ,470 BUTTONEX Btn_1;
            CAPTION "Find" ;
            WIDTH 80 ;
            PICTURE "Find" ;
            ON CLICK FindPos(Form_1.Radio_1.Value,Form_1.GBox_1.Value) ;
            DEFAULT

         @ 500 ,470 BUTTONEX Btn_2;
            CAPTION "Exit" ;
            WIDTH 80 ;
            PICTURE "Exit2" ;
            ON CLICK thiswindow.release

   END WINDOW

   Form_1.Btn_1.Enabled := .f.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return nil

Procedure OpenTable

   IF !IsWinNT() .AND. !CheckODBC()
      MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
      ReleaseAllWindows()
   ENDIF

   IF !FILE('Employee.mdb')
      CreateTable()
      USE Employee.mdb VIA "ADORDD" TABLE "table1"
      DBCreateIndex("State","State")
      DBCreateIndex("First","First")
   else
      USE Employee.mdb VIA "ADORDD" TABLE "table1" INDEX "State", "First"
   ENDIF

   IF EMPTY( Employee->( LastRec() ) )
      APPEND FROM "Employee.DBF"
   ENDIF
   USE Employee.mdb VIA "ADORDD" TABLE "table2"
   IF EMPTY( Employee->( LastRec() ) )
      APPEND FROM "States.DBF"
   ENDIF
   DBGoTop()
   WHILE  !eof()
      aadd(aStateTab, {fieldget(1),fieldget(2)} )
      ADD ITEM  {fieldget(1),fieldget(2)} TO Grid_1 OF Form_1
      DBSkip(1)
   enddo
   USE Employee.mdb VIA "ADORDD" TABLE "table1"

Return

Procedure CloseTable

   USE

RETURN

Procedure FindChg()

   Form_1.Btn_1.Enabled := !Empty( Form_1.GBox_1.Value)

RETURN

FUNCTION FindPos(met,value)
   LOCAL cState,FindWar,pos,nRec
   Value   := Upper(value)

   DO CASE
   CASE met == 1
      FindWar := "CITY == '"+AllTrim(Value)+"'"
   CASE met == 2
      FindWar := "FIRST == '"+AllTrim(Value)+"'"
   CASE met == 3
      FindWar := "LAST == '"+AllTrim(Value)+"'"
   endcase
   nRec:=RecNo()
   LOCATE FOR &FindWar
   IF Found()
      cState:= EMPLOYEE->STATE
      SetFlt(cState)
      LOCATE FOR &FindWar
      nRec:=RecNo()
      IF (pos:=AScan(aStateTab,{|x| x[1] == cState })) != 0
         ViewState(aStateTab[pos,2],cState,nRec)
      ENDIF
   ELSE
      GOTO nRec
      MsgExclamation ('No Success!', 'ERROR' )
   endif
RETURN Nil

FUNCTION ViewState(title,cState,nRec)
   LOCAL Tyt :='State: '+Title
   LOCAL aPos := GetChildPos('Form_1')
   LOCAL aHead, aWidth, aFld ,cLink ,cRys, lEbl:=.f., cInfo, nPos, cPos,rec
   LOCAL n,aRow, dan, aItemState:={}

   DEFAULT nRec := 1
   cPos:= EMPLOYEE->First

   If (.Not. IsWIndowActive (Form_Gr) )
      SetFlt(cState,nRec)

      DEFINE WINDOW Form_Gr ;
         AT aPos[1]+50,aPos[2]+20 ;
         WIDTH 740 HEIGHT 580 ;
         TITLE tyt;
         CHILD NOMAXIMIZE ;
         ON INIT Refresh_Win("Form_Gr") ;
         ON RELEASE DelFlt()


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

               BUTTON Button_2 PICTUREINDEX 2 TOOLTIP 'Edit record' ACTION {||EditDan(aHead,aFld,aWidth,aItemState), Refresh_Win("Form_Gr")}
               BUTTON Button_3 PICTUREINDEX 3 TOOLTIP 'Add record' ACTION MsgInfo('Click!')
               BUTTON Button_4 PICTUREINDEX 1 TOOLTIP 'Delete record' ACTION MsgInfo('Click!') SEPARATOR
         END TOOLBAR

         DEFINE TOOLBAREX Tb_Navi BUTTONSIZE 20,20 IMAGELIST "im_navi" FLAT CAPTION 'Navigations'

               BUTTON top  PICTUREINDEX 0 TOOLTIP "Top Table"    ACTION {||BrMove(1), Refresh_Win("Form_Gr")}
               BUTTON prve PICTUREINDEX 1 TOOLTIP "Prev Screen"  ACTION {||BrMove(2), Refresh_Win("Form_Gr")}
               BUTTON prev PICTUREINDEX 2 TOOLTIP "Prev Record" ACTION {||BrMove(3), Refresh_Win("Form_Gr")}
               BUTTON next PICTUREINDEX 3 TOOLTIP "Next Record"  ACTION {||BrMove(4), Refresh_Win("Form_Gr")}
               BUTTON nxte PICTUREINDEX 4 TOOLTIP "Next Screen"   ACTION {||BrMove(5), Refresh_Win("Form_Gr")}
               BUTTON bott PICTUREINDEX 5 TOOLTIP "Botton Table"      ACTION {||BrMove(6), Refresh_Win("Form_Gr")}
         END TOOLBAR

         DEFINE TOOLBAREX ToolBar_3 BUTTONSIZE 28,28 FONT "Arial" SIZE 9 FLAT CAPTION 'Exit'
             BUTTON Exit PICTURE "exit2" ACTION Release_Brw1("Form_Gr") TOOLTIP "Exit"
         END TOOLBAR

      END SPLITBOX

      SetProperty("Form_Gr","Button_3","Enabled",.f.)
      SetProperty("Form_Gr","Button_4","Enabled",.f.)


      aHead := { 'First' , 'Last', 'Street', 'City', 'Zip','Age','Salary', 'Notes' }
      aWidth:= { 110 , 150 ,150, 150, 80,50,80, 200 }
      aFld  := {'First' , 'Last', 'Street', 'City', 'Zip','Age','Salary', 'Notes' }

   IF RecCount() > 0
      WHILE  !eof()
         aRow:={}
         for n:= 1 to len(aFld)
            dan:= fieldget(FieldPos(aFld[n]))
            dan:= IF(ValType(dan)=='N',Str(dan,6),dan)
            aadd(aRow,dan)
         next
         aadd(aItemState, aRow)
         DBSkip(1)
      enddo
      aItemState := SortCol(1,aItemState)
   ELSE
      aadd(aItemState, {Space(20),Space(20),Space(30),Space(30),Space(10),Space(2),Space(6),Space(70)})
   endif
   IF nRec != 0
      IF (nPos:=AScan(aItemState,{|x,y| AllTrim(x[1]) == AllTrim(cPos) })) != 0
         nRec:= nPos
      endif
   ENDIF

   @ 50,10 GRID Brw_1;
      WIDTH 710 ;
      HEIGHT 390;
      HEADERS aHead ;
      WIDTHS aWidth ;
      ITEMS aItemState;
      VALUE nRec;
      ON CHANGE Refresh_Win("Form_Gr") ;
      ON HEADCLICK {{||SortCol(1,aItemState)},{||  SortCol(2,aItemState)},{|| SortCol(3,aItemState)},{|| SortCol(4,aItemState)},{|| SortCol(5,aItemState)},{|| SortCol(6,aItemState)},{|| SortCol(7,aItemState)},{|| SortCol(8,aItemState)}} ;
      ON DBLCLICK  {||EditDan(aHead,aFld,aWidth,aItemState), Refresh_Win("Form_Gr")} ;
      ON GOTFOCUS  _GridScrollToPos ( "Brw_1" , "Form_Gr" )

   cInfo :=AllTrim(Str(GetProperty("Form_Gr","Brw_1","Value")))+'/'+ AllTrim(Str(recno()))
   @ 510, 520 LABEL Lbl_10a VALUE "Row/Recno:" AUTO
   @ 510, 620 LABEL Lbl_10b VALUE cInfo AUTO BOLD


   END WINDOW

   ACTIVATE WINDOW Form_Gr
   else
        RESTORE WINDOW Form_Gr
   endif

Return nil

FUNCTION SetFlt(cState,nRec)
   LOCAL FltWar:= "STATE == '"+cState+"'"
   IF !Empty(cState)
      DBSETFILTER({|| EMPLOYEE->STATE == cState }, FltWar )
   endif
   IF nRec == 1
      DBGoTop()
   endif

RETURN Nil

FUNCTION DelFlt()
   IF Used()
      DBSETFILTER("" )
      DBGoTop()
   endif
RETURN Nil

FUNCTION Refresh_Win(fm_edit)
   LOCAL n,pos,cInfo,Val1,Val2,FindWar
   If _IsWIndowActive (fm_edit)
      pos:= GetProperty(fm_edit,"Brw_1","Value")
      IF pos !=0
         val2:=Form_Gr.Brw_1.Cell ( pos , 2 )
         FindWar := "LAST == '"+AllTrim(Val2)+"'"
         DBGoTop()
         LOCATE ALL FOR &FindWar
      endif
      cInfo :=AllTrim(Str(pos))+'/'+ AllTrim(Str(recno()))
      SetProperty(fm_edit,"Lbl_10b","Value",cInfo)
   endif
RETURN NIL

Function SortCol(nCol,aItemState)
   LOCAL n
   aItemState := ASORT( aItemState, , , {|x,y| x[nCol] < y[nCol]} )
   if IsControlDefined (Brw_1,Form_Gr)
      Form_Gr.Brw_1.DisableUpdate
      DELETE ITEM ALL FROM Brw_1 OF Form_Gr

      FOR n:=1 TO Len(aItemState)
         ADD ITEM aItemState[n] TO Brw_1 OF Form_Gr
      NEXT
      Form_Gr.Brw_1.EnableUpdate
   endif
Return aItemState

Function Release_Brw1(fm_edit)
    RELEASE WINDOW &fm_edit
Return Nil

Function BrMove(met)
    do case
    case met == 1
       dbGotop()
       _GridHome ( "Brw_1","Form_Gr" )
    case met == 2
       _GridPgUp ( "Brw_1","Form_Gr" )
    case met == 3
       dbSkip(-1)
       _GridPrior( "Brw_1","Form_Gr" )
    case met == 4
       dbSkip(1)
       _GridNext ( "Brw_1","Form_Gr" )
    case met == 5
       _GridPgDn ( "Brw_1","Form_Gr" )
    case met == 6
       dbGoBottom()
       _GridEnd  ( "Brw_1","Form_Gr" )
    endcase
Return Nil

FUNCTION EditDan(aHead,aFld,aWidth,aItemState)
   LOCAL aPos := GetChildPos('Form_Gr')
   LOCAL n, cLbl, cGBox, cValue, aVal, nPos
   IF  RecCount() > 0
   If .Not. IsWIndowActive (Form_Ed)

        nPos := GetProperty("Form_Gr","Brw_1","Value")

        DEFINE WINDOW Form_Ed;
          AT aPos[1]+50,aPos[2]+20 ;
          WIDTH 600 HEIGHT 125+ 30*Len(aHead) ;
          TITLE 'Edit current record' ;
          CHILD

         DEFINE SPLITBOX
            DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 28,28 FONT "Arial" SIZE 9 FLAT CAPTION 'Save'
                BUTTON saveItem PICTURE "save" ACTION SaveDan(aFld,nPos,aItemState) TOOLTIP "Save date"  SEPARATOR
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

            @  50+n*30,160 GETBOX &cGBox ;
               HEIGHT 24 WIDTH aWidth[n];
               VALUE &cValue ;
               FONT "Arial" SIZE 9
         NEXT
       END WINDOW

       Form_Ed.Activate
   else
         FOR n:=1 TO Len(aHead)
            cValue:="EMPLOYEE->"+aFld[n]
            cGBox:= "GBox_"+AllTrim(Str(n))
            SetProperty("Form_Ed",cGBox,'Value',&cValue)
         NEXT
        RESTORE WINDOW Form_Ed
    endif
    endif
    RETURN nil

FUNCTION SaveDan(aFld,nPos,aItemState)
   LOCAL n,value,cGBox, cFld
   if RLock()
         FOR n:=1 TO Len(aFld)
            cFld  := aFld[n]
            cGBox := "GBox_"+AllTrim(Str(n))
            value :=GetProperty("Form_Ed",cGBox,'Value')
            replace &cFld   with value
            IF nPos > 0
               IF cFld =='Age' .or. cFld == 'Salary'
                  aItemState[nPos,n] := Str(value,6)
               else
                  aItemState[nPos,n] := value
               endif
            endif
         NEXT
         dbUnlock()
      endif
      SetProperty("Form_Gr","Brw_1","Item",nPos,aItemState[nPos])
      thiswindow.release
RETURN nil

Procedure CreateTable

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
Return

Function GetChildPos(cFormName)
    Local i, yw, xw, hrb:=0, hTit
    Local hwnd,actpos:={0,0,0,0}

   hTit := GetMenubarHeight()
   hwnd := GetFormHandle(cFormName)
   GetWindowRect(hwnd,actpos)

   yw := actpos[2]
   xw := actpos[1]

   i := aScan ( _HMG_aFormHandles , hWnd )
   if i > 0
      If _HMG_aFormReBarHandle [i] > 0
         hrb = RebarHeight ( _HMG_aFormReBarHandle [i] )
      EndIf
   EndIf
   yw += (hrb + hTit)

Return {yw,xw}

Static Function CheckODBC()
LOCAL oReg, cKey := ""

	OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
		SECTION "Software\Microsoft\DataAccess"

	GET VALUE cKey NAME "Version" OF oReg

	CLOSE REGISTRY oReg

Return !EMPTY(cKey)
