
*--------------------------------------------------------*
Function BrowStru(DBUstruct,aSqlStru,cTable,lNewTab, aSeq)
*--------------------------------------------------------*
   Local oGrid_1, n, Mod := 0
   Local aType:= { "SQLITE_TEXT", "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_BLOB", "SQLITE_NULL" }
   Default lNewTab := FALSE , aSeq := {}

   If (.Not. IsWIndowActive (FrameStru) )
      DEFINE WINDOW FrameStru;
         AT 0,0 width 900;
         HEIGHT 430 ;
         TITLE "VIEW Table Structure" ;
         NOSIZE

         @ 15,40 LABEL Lbl_TabNam ;
            VALUE "Table Name";
            WIDTH 80 ;

         @ 15,140 TEXTBOX Table_Name ;
            WIDTH 150 ;
            UPPERCASE ;
            VALUE cTable;
            ON CHANGE {|| FrameStru.Btn_AddTab.Enabled:= !empty(FrameStru.Table_Name.Value) .and. oGrid_1:nLen > 0 .and. !oGrid_1:lPhantArrRow  }

         FrameStru.Table_Name.Readonly := !lNewTab
         if lNewTab
            DBUstruct := {}
            FrameStru.Table_Name.BackColor := DBUgreen
            @ 15,310 BUTTON Btn_AddTab;
               CAPTION "Add Table" ;
               ACTION { || if(CreateNewTable(oGrid_1,FrameStru.Table_Name.Value),FrameStru.release,Nil) }
               FrameStru.Btn_AddTab.Enabled := FALSE
         endif

         @ 50,10 FRAME Frame_2;
            CAPTION "Structure of SQLITE";
            WIDTH 600;
            HEIGHT 280

         DEFINE TBROWSE oGrid_1 AT 70,20 ARRAY DBUstruct ;
            WIDTH 580 HEIGHT 250 ;
            HEADERS "Lp","Name","Type","Init Type","Size",""+CRLF+"Dec."+CRLF+"(Max)",""+CRLF+"Not"+CRLF+"Null",""+CRLF+"Prim."+CRLF+"Key","Incr",""+CRLF+"Incr."+CRLF+"Value";
            WIDTHS 20,130,110,75,40,40,30,35,30,50 ;
            SELECTOR 18 ;
            ON CHANGE onChangeRec(oGrid_1,aSqlStru);
            ON DBLCLICK EditRecStru( oGrid_1 )

            oGrid_1:nLineStyle :=  LINES_VERT
            oGrid_1:nHeightCell += 1
            oGrid_1:nHeightHead += 8
            oGrid_1:Set3DText( FALSE, FALSE )
            oGrid_1:nWheelLines := 3
            oGrid_1:SetAppendMode( TRUE )


            oGrid_1:SetColor( { 1, 3, 5, 6, 13, 15, 17 }, ;
                            { CLR_BLACK,  CLR_YELLOW,CLR_RED, -3, ;
                              CLR_HGREEN, CLR_BLACK ,;  // text colors
                              CLR_YELLOW } )  // text superheader
            oGrid_1:SetColor( { 2, 4, 14 ,16 }, ;
                            { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                              { CLR_WHITE, CLR_BLACK }, ;  // degraded headers backgroud color
                                 { CLR_HGREEN, CLR_BLACK } ,;  // degraded order column background color
                                    { CLR_WHITE, CLR_BLACK }  } ) // degraded superheaders backgroud color
            oGrid_1:SetData( 3, ComboWBlock( oGrid_1, 3, 3 , aType ) )
            oGrid_1:SetColor( { 1, 2 }, {  CLR_BLACK, { || if( !oGrid_1:lPhantArrRow .and. (rtrim(Eval( oGrid_1:aColumns[ 5 ]:bData ))== 'FLOAT'.or. Eval( oGrid_1:aColumns[ 7 ]:bData ) == 0 ),{ CLR_WHITE,CLR_HGRAY },;
               { CLR_WHITE, CLR_HRED } ) } }, 6 )

            FOR n := 7 TO 9
                  oGrid_1:aColumns[ n ]:lCheckBox  := TRUE
                  oGrid_1:aColumns[ n ]:cDataType  := 'L'
            next
            oGrid_1:aColumns[ 10 ]:nAlign     :=  DT_CENTER
         END TBROWSE



         @ 20,620 FRAME Frame_1;
            WIDTH 260 ;
            HEIGHT 310  ;
            CAPTION "Info Fields" ;

         @  50,630 LABEL Lbl_name      WIDTH 60 BACKCOLOR DBUblue  VALUE "Name"
         @  80,630 LABEL Lbl_type      WIDTH 60 BACKCOLOR DBUblue  VALUE "Type"
         @ 110,630 LABEL Lbl_IniType   WIDTH 60 BACKCOLOR DBUblue  VALUE "Init Type"
         @ 140,630 LABEL Lbl_Options   WIDTH 60 HEIGHT 25 BACKCOLOR DBUblue  VALUE "Options"
         @ 170,630 LABEL Lbl_size      WIDTH 60 BACKCOLOR DBUblue VALUE "Size"
         @ 195,630 LABEL Lbl_decimal   WIDTH 60 BACKCOLOR DBUblue VALUE "Decimals"

         @ 50,700 TEXTBOX Text_Name;
            WIDTH 100 ;
            UPPERCASE ;
            VALUE "" ;
            READONLY ;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1, Mod)


         @ 80,700  COMBOBOX Text_Type ;
            ITEMS aType ;
            WIDTH 110 ;
            VALUE 0 ;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1,Mod)


         @ 110,700 TEXTBOX Text_IniType;
            VALUE ''  ;
            WIDTH 120 ;
            READONLY



         @ 135 ,700 RADIOGROUP Radio_1 ;
            OPTIONS {'Char','Date','DateTime'} ;
            VALUE 0 ;
            WIDTH 59 ;
            SPACING 0 ;
            FONT 'Arial' SIZE 8;
            HORIZONTAL ;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1, Mod)



         @ 165,700 TEXTBOX Text_Size;
            VALUE 0  ;
            NUMERIC;
            WIDTH 90 ;
            RIGHTALIGN;
            READONLY;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1, Mod)

         @ 195,700 TEXTBOX Text_Decimals ;
            VALUE 0  ;
            NUMERIC ;
            WIDTH 90 ;
            RIGHTALIGN ;
            READONLY ;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1, Mod)


         @ 225 ,630 CHECKBOX Chk_Null;
            CAPTION 'Not Null';
            WIDTH 70;
            VALUE FALSE

         @ 225 ,710 CHECKBOX Chk_Key;
            CAPTION 'Prim.Key';
            WIDTH 70;
            VALUE FALSE ;
            ON CHANGE OnChangeType(FrameStru.Text_Type.Value, oGrid_1, Mod)


         @ 225 ,790 CHECKBOX Chk_Incr;
            CAPTION 'Incr.';
            WIDTH 50;
            VALUE FALSE



         @ 255,630 BUTTON Btn_Add ;
            CAPTION "Add";
            WIDTH 90 ;
           ACTION Mod := OnModRecStru(oGrid_1,cTable,2, lNewTab)

         @ 255,730 BUTTON Btn_Mod ;
            CAPTION "Modyfication"  ;
            WIDTH 100 ;
            ACTION  Mod := OnModRecStru(oGrid_1,cTable,1, lNewTab)

         @ 290,630 BUTTON Btn_Del ;
            CAPTION "Delete"  ;
            WIDTH 90 ;
            ACTION  Mod := OnModRecStru(oGrid_1,cTable,3, lNewTab)

         @ 290,730 BUTTON Btn_Cancel ;
            CAPTION "Cancel"  ;
            WIDTH 100 ;
            ACTION  Mod:= CancelEdit(oGrid_1)


         DEFINE BUTTON BtnChgRec
            ROW 350
            COL 20
            CAPTION "Change Rec"
            ACTION  Mod:= EditRecStru( oGrid_1,1 )
         END BUTTON

         DEFINE BUTTON BtnAddRec
            ROW 350
            COL 170
            CAPTION "Add Rec"
            ACTION Mod := EditRecStru( oGrid_1,0 )
         END BUTTON


         DEFINE BUTTON BtnModNull
            ROW 350
            COL 320
            CAPTION "Modify NULL"
            ACTION SqlNullUpdate(cTable,oGrid_1)
         END BUTTON
         DEFINE BUTTON _DBUexitnew
            ROW 350
            COL 470
            CAPTION "Exit"
            ACTION  ThisWindow.Release
         END BUTTON

      END WINDOW
      FrameStru.BtnChgRec.Enabled:= oGrid_1:nLen > 0 .and. !oGrid_1:lPhantArrRow
      FrameStru.BtnModNull.Enabled:= FALSE
      FrameStru.Btn_Add.Enabled   := FALSE
      FrameStru.Btn_Mod.Enabled   := FALSE
      FrameStru.Btn_Del.Enabled   := FALSE
      FrameStru.Btn_Cancel.Enabled:= FALSE
      FrameStru.Radio_1.Enabled   := FALSE
      FrameStru.Radio_1.Visible   := FALSE
      FrameStru.Chk_Null.Enabled  := FALSE
      FrameStru.Chk_Key.Enabled   := FALSE
      FrameStru.Chk_Incr.Enabled  := FALSE

      CENTER WINDOW FrameStru

      ACTIVATE WINDOW FrameStru
   else
      MsgInfo("The window is already active.","attention!")
   endif
RETURN nil

*--------------------------------------------------------*
Function  EditRecStru( oGrid, Mod)
*--------------------------------------------------------*
   Local aType := { "SQLITE_TEXT","SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_BLOB", "SQLITE_NULL"}
   local nAt := oGrid:nAt
   Local nPos := 0, nKey, lKey := FALSE, lIncr := FALSE
   nPos := Max(1,nPos)

   if !oGrid:lPhantArrRow
      nKey := Ascan(oGrid:aArray, {|x| x[8] == TRUE } )
   endif

   if Mod == 0
      nPos := 0
      lKey := nKey == 0
   else
      nPos := ascan( aType,oGrid:aArray[nAt,3])
      nPos := Max(1,nPos)
      lKey := nKey == nAt
      lIncr:= lKey
    endif

      FrameStru.Text_IniType.Value     := if(Mod == 1,oGrid:aArray[nAt,4],'')
      FrameStru.Text_Name.Value        := if(Mod == 1,oGrid:aArray[nAt,2],'')
      FrameStru.Text_Type.Value        := nPos
      FrameStru.Text_Size.Value        := if(Mod == 1,oGrid:aArray[nAt,5],0 )
      FrameStru.Text_Decimals.Value    := if(Mod == 1,oGrid:aArray[nAt,6],0 )
      FrameStru.Chk_Null.Value         := if(Mod == 1,oGrid:aArray[nAt,7],FALSE)
      FrameStru.Chk_Key.Value          := if(Mod == 1,oGrid:aArray[nAt,8],FALSE)
      FrameStru.Chk_Incr.Value         := if(Mod == 1,oGrid:aArray[nAt,9],FALSE)

      FrameStru.Text_Name.BackColor    := DBUgreen
      FrameStru.Text_Type.BackColor    := DBUgreen
      FrameStru.Text_Size.BackColor    := DBUgreen
      FrameStru.Text_Decimals.BackColor := DBUgreen
      FrameStru.Text_Name.ReadOnly     := FALSE
      FrameStru.Text_Type.ReadOnly     := FALSE
      FrameStru.Text_Size.ReadOnly     := FALSE
      FrameStru.Text_Decimals.ReadOnly := FALSE
      FrameStru.Chk_Incr.Enabled       := lIncr
      FrameStru.Chk_Null.Enabled       := TRUE
      FrameStru.Chk_Key.Enabled        := lKey

      FrameStru.Btn_Cancel.Enabled     := TRUE
      FrameStru.BtnChgRec.Enabled      := FALSE
      FrameStru.BtnAddRec.Enabled      := FALSE
   if Mod == 0
      FrameStru.Btn_Mod.Enabled     := FALSE
      FrameStru.Btn_Add.Enabled     := TRUE
      FrameStru.Btn_Del.Enabled     := FALSE
      FrameStru.Text_Name.ReadOnly  := FALSE
      FrameStru.Text_Name.BackColor := DBUgreen
   else
      FrameStru.Btn_Mod.Enabled:= TRUE
      FrameStru.Btn_Add.Enabled:= FALSE
      FrameStru.Btn_Del.Enabled:= TRUE
      FrameStru.Text_Name.ReadOnly := TRUE
      FrameStru.Text_Name.BackColor := CLR_HGRAY
   endif
Return Mod


*--------------------------------------------------------*
Function OnModRecStru(oGrid,cTable,mod,lNewTab)
*--------------------------------------------------------*
   Local cRecName, cRecType, cRecIniType, cRecSize, cRecDec,lNull, lKey, lIncr, cIncr, dBStru :={}, n, aItem
   Local nPos,DBUstruct :={}
   Local nRow
   cRecName    := FrameStru.Text_Name.Value
   cRecType    := FrameStru.Text_Type.DisplayValue
   cRecIniType := FrameStru.Text_IniType.Value
   cRecSize    := FrameStru.Text_Size.Value
   cRecDec     := FrameStru.Text_Decimals.Value
   lIncr       := FrameStru.Chk_Incr.Value
   lNull       := FrameStru.Chk_Null.Value
   lKey        := FrameStru.Chk_Key.Value
   cIncr       := if(Mod == 1, oGrid:aArray[oGrid:nAt,10 ],'')
   if lNewTab
      nPos  :=oGrid:nAt
      nRow  :=if(mod == 2,oGrid:nLen + if(oGrid:lPhantArrRow,0,1),nPos)
      aItem := { nRow,cRecName,cRecType,cRecIniType,cRecSize,cRecDec,lNull,lKey,lIncr,'' }
      if Mod == 2
         if oGrid:lPhantArrRow
            oGrid:Del()
            oGrid:lPhantArrRow := FALSE
         endif
         aadd(oGrid:aArray,aItem)
         oGrid:UpAStable()

      elseif Mod == 1
         for n:=1 to len(aItem)
            oGrid:aArray[oGrid:nAt,n ] := aItem[n]
         next
      elseif mod ==  3
         oGrid:Del()
         oGrid:UpAStable()
      endif
      CancelEdit(oGrid)
      FrameStru.Btn_AddTab.Enabled:= !empty(FrameStru.Table_Name.Value) .and. oGrid:nLen > 0 .and. !oGrid:lPhantArrRow

   else
      if Mod == 2
         if Ascan(oGrid:aArray, {|x| rtrim(x[2]) == rtrim(cRecName ) }) > 0
             MsgInfo("Column Name "+cRecName+ " exist in Table "+cTable)
             Return Mod
          endif
      endif
      AEval( oGrid:aArray, {|x| aAdd(dBStru,{x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9]})})

      if mod ==  3
         oGrid:Del()
      endif
      if mod ==  1
         oGrid:aArray[oGrid:nAt,3]:= cRecType
         oGrid:aArray[oGrid:nAt,4]:= cRecIniType
         oGrid:aArray[oGrid:nAt,5]:= cRecSize
         oGrid:aArray[oGrid:nAt,6]:= cRecDec
         oGrid:aArray[oGrid:nAt,7]:= lNull
         oGrid:aArray[oGrid:nAt,8]:= lKey
         oGrid:aArray[oGrid:nAt,9]:= lIncr
         oGrid:aArray[oGrid:nAt,10]:= cIncr
         oGrid:Refresh()
      elseif Mod == 2
         nRow := len(oGrid:aArray)
         aItem := { nRow+1,cRecName,cRecType,cRecIniType,cRecSize,cRecDec,lNull,lKey,lIncr,cIncr }
         aadd(oGrid:aArray,aItem)
         oGrid:UpAStable()
      endif
      if AlterRec(oGrid,cTable,cRecName,cRecIniType,Mod,dBStru)
         CancelEdit(oGrid)
      endif
      FrameStru.BtnChgRec.Enabled   := oGrid:nLen > 0 .and. !oGrid:lPhantArrRow
      FrameStru.BtnAddRec.Enabled   := TRUE
   endif

Return Mod

*--------------------------------------------------------*
Function CancelEdit(oGrid)
*--------------------------------------------------------*
      FrameStru.Text_Name.Value     := ''
      FrameStru.Text_Type.Value     := 0
      FrameStru.Text_IniType.Value  := ''
      FrameStru.Text_Size.Value     := ''
      FrameStru.Text_Decimals.Value := ''
      FrameStru.Chk_Incr.Value      := FALSE
      FrameStru.Chk_Null.Value      := FALSE
      FrameStru.Chk_Key.Value       := FALSE

      FrameStru.Text_Name.ReadOnly     := TRUE
      FrameStru.Text_IniType.ReadOnly  := TRUE
      FrameStru.Text_Size.ReadOnly     := TRUE
      FrameStru.Text_Decimals.ReadOnly := TRUE
      FrameStru.Chk_Incr.Enabled       := FALSE
      FrameStru.Chk_Null.Enabled       := FALSE
      FrameStru.Chk_Key.Enabled        := FALSE


      FrameStru.Text_Name.BackColor    := CLR_HGRAY
      FrameStru.Text_IniType.BackColor := CLR_HGRAY
      FrameStru.Text_Size.BackColor    := CLR_HGRAY
      FrameStru.Text_Decimals.BackColor := CLR_HGRAY

      FrameStru.Btn_Mod.Enabled     := FALSE
      FrameStru.Btn_Mod.Enabled     := FALSE
      FrameStru.Btn_Add.Enabled     := FALSE
      FrameStru.Btn_Del.Enabled     := FALSE
      FrameStru.Btn_Cancel.Enabled  := FALSE
      FrameStru.BtnChgRec.Enabled   := oGrid:nLen > 0 .and. !oGrid:lPhantArrRow
      FrameStru.BtnAddRec.Enabled   := TRUE
      FrameStru.Radio_1.Value       := 0
      FrameStru.Radio_1.Visible     := FALSE
Return 0

*--------------------------------------------------------*
Function OnChangeRec(oGrid, aSqlStru)
*--------------------------------------------------------*
   Local nAt := oGrid:nAt
   if IsControlDefined (BtnModNull,FrameStru)
      if nAt <= len( aSqlStru )
         if alltrim(aSqlStru[nAt,2]) == "SQLITE_NULL"
            FrameStru.BtnModNull.Enabled := TRUE
         else
            FrameStru.BtnModNull.Enabled:= FALSE
         endif
      else
         FrameStru.BtnModNull.Enabled:= FALSE
      endif
   endif
Return Nil


*--------------------------------------------------------*
Function OnChangeType(nType,oGrid,Mod)
*--------------------------------------------------------*
   Local nKey := 0, lIncr := FALSE, lKey := FALSE
   if !oGrid:lPhantArrRow
   	nKey := Ascan(oGrid:aArray, {|x| x[8] == TRUE } )
   endif 
   if Mod == 1
      if nKey > 0
         lIncr := oGrid:aArray[nKey,8] .and. nKey == oGrid:nAt
         lKey  := oGrid:aArray[nKey,8] .and. nKey == oGrid:nAt
      else
         lIncr := TRUE
         lKey  := TRUE
      endif
   else
      lIncr :=  nKey == 0
      lKey  :=  nKey == 0
   endif
   FrameStru.Chk_Incr.Enabled := FALSE
   FrameStru.Chk_Key.Enabled  := lKey
   do Case
   case nType == 1
      FrameStru.Chk_Incr.Enabled    := FALSE
      FrameStru.Chk_Incr.Value      := FALSE
      FrameStru.Radio_1.Visible     := TRUE
      FrameStru.Radio_1.Enabled     := TRUE
      FrameStru.Radio_1.Caption(1)  :='Char'
      FrameStru.Radio_1.Caption(2)  :='Date'
      FrameStru.Radio_1.Caption(3)  :='DateTime'

      FrameStru.Text_Size.Value :=if(empty(FrameStru.Text_Size.Value),0,FrameStru.Text_Size.Value)
      FrameStru.Text_Size.Enabled     := TRUE
      FrameStru.Text_Decimals.Value   := 0
      FrameStru.Text_Decimals.Enabled := FALSE

      if FrameStru.Radio_1.Value == 0
         if rtrim(FrameStru.Text_IniType.Value) == 'DATETIME'
            FrameStru.Radio_1.Value := 3
         elseif rtrim(FrameStru.Text_IniType.Value) == 'DATE'
            FrameStru.Radio_1.Value := 2
         else
            FrameStru.Radio_1.Value := 1
         endif
      elseif FrameStru.Radio_1.Value == 1
         FrameStru.Text_Size.Enabled := TRUE
         if FrameStru.Text_Size.Value == 0
            FrameStru.Text_IniType.Value := 'TEXT'
         else
            FrameStru.Text_IniType.Value :="CHAR("+LTRIM(STR(FrameStru.Text_Size.Value))+")"
         endif
      elseif FrameStru.Radio_1.Value == 2
            FrameStru.Text_IniType.Value := 'DATE'
            FrameStru.Text_Size.Value := 10
            FrameStru.Text_Size.Enabled := FALSE
      elseif FrameStru.Radio_1.Value == 3
            FrameStru.Text_IniType.Value := 'DATETIME'
            FrameStru.Text_Size.Value := 19
            FrameStru.Text_Size.Enabled := FALSE
      endif
   case nType == 2
      FrameStru.Radio_1.Visible     := TRUE
      FrameStru.Radio_1.Enabled     := TRUE
      FrameStru.Radio_1.Caption(1)  :='Bool'
      FrameStru.Radio_1.Caption(2)  :='Integer'
      FrameStru.Radio_1.Caption(3)  :=''
      FrameStru.Radio_1.Enabled(3)  := FALSE
      if FrameStru.Radio_1.Value == 0
         if FrameStru.Text_IniType.Value == 'BOOL'
            FrameStru.Radio_1.Value := 1
         else
            FrameStru.Radio_1.Value := 2
         endif
      endif
      if FrameStru.Text_Size.Value == 0
         FrameStru.Text_Size.Value := INT_LNG
      endif
      if FrameStru.Text_Size.Value == 1
         FrameStru.Radio_1.Enabled(1):= TRUE
      endif
      FrameStru.Chk_Incr.Enabled       := lIncr
      FrameStru.Text_IniType.Value     := 'INTEGER'
      FrameStru.Text_Decimals.Value    := 0
      FrameStru.Text_Size.Enabled      := TRUE
      FrameStru.Text_Decimals.Enabled  := FALSE
      if   FrameStru.Chk_Key.Value
         FrameStru.Radio_1.Value := 2
         FrameStru.Radio_1.Enabled(1):= FALSE
      else
         FrameStru.Radio_1.Enabled(1):= TRUE
      endif
      if FrameStru.Text_Size.Value  == 1  .and. FrameStru.Radio_1.Value == 1
         FrameStru.Text_IniType.Value := 'BOOL'
         FrameStru.Radio_1.Enabled(1):= TRUE
      elseif FrameStru.Radio_1.Value == 2
         FrameStru.Text_IniType.Value := 'INTEGER'
         if FrameStru.Text_Size.Value  > 1
            FrameStru.Radio_1.Enabled(1):= FALSE
         endif
      endif

   case nType == 3
      FrameStru.Radio_1.Visible := FALSE
      FrameStru.Text_Size.Value := FL_LNG
      FrameStru.Text_IniType.Value :=  "FLOAT"
      FrameStru.Text_Decimals.Value := FL_DEC
      FrameStru.Text_Size.Enabled := FALSE
      FrameStru.Text_Decimals.Enabled := FALSE
      FrameStru.Radio_1.Enabled := TRUE
   case nType == 4  .or. nType == 5
      FrameStru.Radio_1.Visible := FALSE
      if nType == 4
         FrameStru.Text_IniType.Value :=  "BLOB"
      endif
      FrameStru.Text_Size.Value :=0
      FrameStru.Text_Decimals.Value := 0
      FrameStru.Text_Size.Enabled := FALSE
      FrameStru.Text_Decimals.Enabled := FALSE
   endcase
Return nil


*--------------------------------------------------------*
FUNCTION SqlNullUpdate(cTable,oGrid)
*--------------------------------------------------------*
LOCAL cField, cNewValue, aResult, cQuery
LOCAL nColumn := oGrid:nAt

   If nColumn > 0
      aResult := SQLITE_COLUMNS( cTable, pDb )
      if  len(aResult) >0 .and. len(aResult) >= nColumn

         cField := aResult[nColumn,1]
         cNewValue := ""

         cQuery := "UPDATE " + cTable +" SET  "+cField+" = ''  WHERE "+cField+ " IS NULL "
         If sqlite3_exec( pDb, cQuery ) == SQLITE_OK

            MsgInfo(  "Record is updated", "Result" )

         else
            MsgInfo("Tabele "+cTable+ " is not modified. ")

         Endif

         cQuery := "select "+cField+" from " + cTable +" where "+cField+ " IS NULL"

         aResult := SQLITE_QUERY( pDb, RTRIM( cQuery ) + ";")

         IF EMPTY(LEN(aResult))
            IF !MsgRetryCancel("No record match your query. Retry ?", "Empty")
               RETURN 0
            ENDIF
         ENDIF

      endif
   EndIf

Return TRUE


*---------------------------------------------------------------------------
Function AlterRec(oGrid,cTable,cKol,cType,Mod,aDbStru)
*---------------------------------------------------------------------------
   LOCAL db
   Local lRet := FALSE
   local cQuery, cInfo, EmptyVal
   Local cTable2 := cTable+"Tmp"


   Do Case
   Case Mod==12
      cQuery := " ALTER TABLE "+ cTable + " ALTER COLLUMN "+ cKol +" "+ cType
      cInfo := " In Tabele "+cTable+ " changend type of Column "+cKol
   Case Mod==2
      cQuery := " ALTER TABLE "+ cTable + " ADD "+ cKol +" "+ cType
      cInfo := " In Tabele "+cTable+ " add Collumn "+cKol
   Case Mod==3 .or. Mod==1
      cQuery := "BEGIN TRANSACTION; " +CRLF
      cQuery += QueryCrea(cTable,2,cTable2,aDbStru)+CRLF
      cQuery += QueryCrea(cTable,3,cTable2,aDbStru)+CRLF
      cQuery += "DROP TABLE "+cTable+" ;" +CRLF
      cQuery += QueryNewTbl(oGrid,cTable) +CRLF//"CREATE TABLE t1(a,b);
      adBStru :={}
      AEval( oGrid:aArray, {|x| aAdd(adBStru,{x[2],x[3],x[4],x[5]})})
      cQuery += QueryCrea(cTable2,3,cTable,aDbStru)+CRLF
      cQuery += "DROP TABLE "+ctable2 +";" +CRLF
      cQuery += "COMMIT; "
      if Mod==1
         cInfo := " In Tabele "+cTable+ " changend type of Column "+cKol
      else
         cInfo := " In Tabel "+cTable+ " removed Column "+cKol
      endif
   endcase
   db := sqlite3_open_v2( SqlDbName , SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )
   IF DB_IS_OPEN( db )
      IF SQLITE_TABLEEXISTS( cTable,db )
         IF sqlite3_exec( db, cQuery  ) == SQLITE_OK
            lRet := TRUE
            if mod == 2
               if "TEXT" $ cType .or."CHR" $ cType
                  EmptyVal := " '' "
               else
                  EmptyVal := " 0 "
               endif
               cQuery := "UPDATE " + cTable +" SET  "+cKol+" = "+EmptyVal+"  WHERE "+cKol+ " IS NULL "
               If sqlite3_exec( db, cQuery ) == SQLITE_OK
                  lRet := TRUE
               endif
            else
               lRet := TRUE
            endif
         else
            MsgInfo("Tabele "+cTable+ " is not modified. ")
         endif
      else
         MsgInfo("Tabele "+cTable+ " not exist in Database "+SqlDbName)
      endif
   else
      MsgInfo("Baza nie mo¿e byæ otwarta w trybie EXCLUSIVE")
   endif
   if lRet
      MsgInfo(cInfo,"Report")
   endif
Return lRet

/*
BEGIN TRANSACTION;
CREATE TEMPORARY TABLE t1_backup(a,b);
INSERT INTO t1_backup SELECT a,b FROM t1;
DROP TABLE t1;
CREATE TABLE t1(a,b);
INSERT INTO t1 SELECT a,b FROM t1_backup;
DROP TABLE t1_backup;
COMMIT;

*/

*--------------------------------------------------------*
Function QueryNewTbl(oGrid,cTable)
*--------------------------------------------------------*
   Local i, cQuery := "CREATE TABLE IF NOT EXISTS " + cTable + " ( "
   Local cFldName, cFldIniType, lNull, lKey, lIncr

   for i:= 1 to oGrid:nLen
         cFldName    := oGrid:aArray[i, 2]
         cFldIniType := oGrid:aArray[i, 4]
         lNull       := oGrid:aArray[i, 7]
         lKey        := oGrid:aArray[i, 8]
         lIncr       := oGrid:aArray[i, 9]
         if i > 1
            cQuery += ", "
         endif
         cQuery += alltrim(cFldName) +" "+ cFldIniType + " "
         if lKey
            cQuery += "  PRIMARY KEY"
         endif
         if lIncr
            cQuery += "  AUTOINCREMENT"
         endif
         if lNull
            cQuery += "  NOT NULL"
         endif
   next
   cQuery += ");"

Return cQuery

*--------------------------------------------------------*
FUNCTION BrowseTable(cTable, mod)
*--------------------------------------------------------*
   Local cSelect, bSetup , oBrw, aResult, aStruct
   cSelect := "SELECT * FROM "+cTable +" LIMIT 10 OFFSET 0 ;"
   aResult := SQLITE_QUERY( pDb, RTRIM( cSelect ) )
   IF EMPTY(LEN(aResult))
      MsgInfo("No records in Table : "+cTable, "Empty")
      RETURN 0
   ENDIF
   aStruct := SQLITE_COLUMNS( cTable, pDb )
   if mod
      cSelect := "SELECT * FROM "+cTable
      If (.Not. IsWIndowActive (Form_1) )
         DBUSEAREA( TRUE,, cSelect,"TABLE" ,,, "UTF8")

         Select TABLE
         DEFINE WINDOW Form_1 AT 0,0 WIDTH SqlDbuwindowwidth HEIGHT SqlDbuwindowheight TITLE "Tabele: "+cTable CHILD BACKCOLOR RGB( 191, 219, 255 )

            DEFINE TBROWSE oBrw AT 10, 10 ALIAS "TABLE" WIDTH SqlDbuwindowwidth - 16 HEIGHT SqlDbuwindowheight - 30 ; // HEADER aCols ;
            AUTOCOLS SELECTOR 20 EDITABLE CELLED

            AEval( oBrw:aColumns, {| oCol,nCol | PostBlob( oBrw, oCol, nCol, aStruct, cTable, mod )  })

            oBrw:SetAppendMode( TRUE )
            oBrw:SetDeleteMode( TRUE, TRUE, {|| SqlDelete(cTable,FALSE)} )
            END TBROWSE
         END WINDOW
         CENTER WINDOW Form_1
         ACTIVATE WINDOW Form_1
      else
         MsgInfo("The window is already active.","attention!")
      endif

      close TABLE
   else
      bSetup := { |oBrw| SetMyBrowser( oBrw, aStruct ) }
      SBrowse(cTable, "Tabele: "+cTable, bSetup,,SqlDbuwindowwidth,SqlDbuwindowheight,TRUE )
  endif


return nil

*--------------------------------------------------------*
Function PostBlob( oBrw, oCol, nCol, aStru, cTable, mod )
*--------------------------------------------------------*
   Local cField, cFile
   Default mod := TRUE
   if aStru[nCol,3] == 'BLOB'
      oBrw:SetData( nCol, 'Blob' )
      if mod
         oCol:lBtnGet := TRUE
         cField :=aStru[nCol,1]
         cFile := GetCurrentFolder()+'\BlobData.dat'
         oCol:bAction := {|| SQLITE_GET_BLOB( cTable, cField, pDb, cFile )}
         oCol:bAction := {|| ModBlob( cTable, cField) }
      endif
   else
      oCol:bPostEdit := { | uVal,oBr,lApp | SqlUpdate(uVal,oBr:nCell-1,cTable,lApp)}
   endif
   Return Nil

*--------------------------------------------------------*
Function ModBlob(cTable, cField )
*--------------------------------------------------------*
   Local cfile, lRet := FALSE
   cFile := GetFile ( {{ "Blob Files", "*.*"} } ,  "Open Files" , GetCurrentFolder(), FALSE , TRUE )
   if !empty(cFile)
      if SQLITE_SET_BLOB( cTable, cField, pDb, cFile )
         MsgInfo("Save BLOB into field "+cField+" - Done")
         lRet := TRUE
      endif
   endif
Return lRet


*--------------------------------------------------------*
Function SetMyBrowser( oBrw, aStruct )
*--------------------------------------------------------*
   oBrw:nHeightCell += 5
   oBrw:nHeightHead += 5
   oBrw:nClrFocuFore := CLR_BLACK
   oBrw:nClrFocuBack := COLOR_GRID
   AEval( oBrw:aColumns, {| oCol,nCol | PostBlob( oBrw, oCol, nCol, aStruct )  })

Return FALSE

*--------------------------------------------------------*
Function SqlUpdate(uVal, nCol, cTable, lApp)
*--------------------------------------------------------*
   Local cQuery, i, cFldName, cQuery2, cSep:=""
   Local aDbStru := dbstruct()
   Local aInfo := SQLITE_COLUMNS_METADATA(pDb, cTable )
   uVal := nil
   if lApp
      cQuery:= "INSERT INTO "+cTable+" ( "
      cQuery2:= " ) values ( "
      for i := 1 to len(aDbStru)
         if !aInfo[i,8]
            cFldName := aDbStru[i, 1]
            cQuery += cSep+cFldName
            cQuery2 += cSep+c2sql(&cFldName)
            cSep := " , "
         endif
      next
      cQuery += cQuery2 +  " )"
   else
      cFldName := aDbStru[nCol, 1]
      cQuery := "UPDATE "+cTable+" SET " + cFldName + " = " + c2sql(&cFldName) + " WHERE "
      for i := 1 to len(aDbStru)
         if i != nCol .and.  aDbStru[i, 2] != 'W' .and. !aInfo[i,8]
            cFldName := aDbStru[i, 1]
            cQuery += cSep + cFldName + " = "+  c2sql(&cFldName)
            cSep := " AND "
         endif
      next
      cQuery += " "
   endif

   If ! RDDINFO( RDDI_EXECUTE, cQuery )
      MsgStop("Can't update record in table "+cTable+" !", "Error")
      Return FALSE
   EndIf

Return TRUE

*--------------------------------------------------------*
Function SqlDelete(cTable,lAll )
*--------------------------------------------------------*
   Local cQuery, i, cFldName,cQueryTest, aResult
   local aDbStru := dbstruct(), cTest

   cQuery := "DELETE FROM "+cTable
   cQueryTest := "SELECT * FROM "+cTable
   if lAll
      IF !MsgYesNo("All Records from table "+cTable+" will be deleted" + CRLF + ;
      "without any choice to recover." + CRLF + CRLF + ;
      "       Continue ?", "Warning!" )
      Return FALSE
     endif
   else
      cQuery += " WHERE "
      cQueryTest += " WHERE "
      for i := 1 to len(aDbStru)  //test
         cFldName := aDbStru[i, 1]
         if i > 1  .and.  aDbStru[i, 2] != 'W'
            cQuery += " AND "
            cQueryTest += " AND "
         endif
         cQuery += cFldName + " = "+  c2sql(&cFldName)
         cQueryTest += cFldName + " = "+  c2sql(&cFldName)
       cTest :=  c2sql(&cFldName)
      next
      cQuery += " "
      cQueryTest += " "
   endif

   aResult := SQLITE_QUERY( pDb, RTRIM( cQueryTest) )
   IF EMPTY(LEN(aResult))
      MsgStop("Can't Find record in table "+cTable+" !", "Error")
      RETURN FALSE
   Else


   If ! RDDINFO(RDDI_EXECUTE, cQuery )
      MsgStop("Can't Delete record in table "+cTable+" !", "Error")
      Return FALSE
   else
      aResult := SQLITE_QUERY( pDb, RTRIM( cQueryTest) )
      IF !EMPTY(LEN(aResult))
         MsgStop("Can't Delete record in table "+cTable+" !", "Error")
         RETURN FALSE
      Else
         MsgInfo("Deleted record in table "+cTable+" !", "Info")
      endif
   EndIf
   endif
Return TRUE