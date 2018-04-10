
#include "i_PropGrid.ch"

*--------------------------------------------------------*
FUNCTION SqlEdit(cTable, db)
*--------------------------------------------------------*
   LOCAL n , aResult, nId, DBUstruct :={}

   aResult := SQLITE_COLUMNS_METADATA( db, cTable)

   AEval( aResult, {|x| aAdd(DBUstruct,{x[1],x[2],x[4],x[5],x[3],x[8]})})

   DEFINE WINDOW Form_Edit ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 500 ;
      TITLE 'Record Edit' ;
      CHILD ;
      NOMAXIMIZE NOSIZE

      DEFINE PROPGRID PropEdit   ;
         AT 25,20  ;
         WIDTH 550 HEIGHT 380 ;
         HEADER "Field Name","Value" ;
         FONTCOLOR {0,0,0} INDENT  10  DATAWIDTH 400;
         BACKCOLOR {240,240,240};
         ITEMHEIGHT 25;
         ITEMEXPAND ;
         OKBTN USEROKPROC AddNewRec(cTable, db, DBUstruct) APPLYBTN ;
         CANCELBTN;
         ON CHANGEVALUE {||SetProperty('Form_Edit','Btn_1','Enabled',TRUE)} ;
         ITEMINFO

         DEFINE CATEGORY 'Record Set'
         FOR n:=1 TO Len(DBUstruct)
            if !DBUstruct[n,6]
               nId := 1000+n*10
               do case
               case DBUstruct[n,2] == "SQLITE_TEXT"
                  If DBUstruct[n,5] = 'TEXT'
                     PROPERTYITEM USERFUN DBUstruct[n,1]  ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }" DISABLEEDIT ID nId INFO  "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  elseif substr(DBUstruct[n,5],1,4) == 'CHAR'
                     PROPERTYITEM USERFUN DBUstruct[n,1]  ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  elseif DBUstruct[n,5] == 'DATE'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'date' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  elseif  DBUstruct[n,5] == 'DATETIME'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Format: YYYY-MM-DD hh:mm:ss'
                  elseif  DBUstruct[n,5] == 'TIME'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Format: hh:mm:ss'
                  elseif DBUstruct[n,5] == 'BLOB'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  endif
               case DBUstruct[n,2] == "SQLITE_INTEGER"
                  if DBUstruct[n,5] = 'BOOL'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'check' VALUE 'No' ITEMDATA 'No;Yes' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  else
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO  "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  endif
               case DBUstruct[n,2] == "SQLITE_FLOAT"
                  PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+alltrim(str(DBUstruct[n,3]))+','+ alltrim(str(DBUstruct[n,4]))
               case DBUstruct[n,2] == "SQLITE_BLOB"
                  PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
               case DBUstruct[n,2] == "SQLITE_NULL"
                  do case
                  case DBUstruct[n,5] == 'TEXT'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }" DISABLEEDIT ID nId INFO  "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  case substr(DBUstruct[n,5],1,4) == 'CHAR'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  case DBUstruct[n,5] == 'INTEGER'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }" DISABLEEDIT ID nId INFO  "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+str(DBUstruct[n,3])
                  case DBUstruct[n,5] == 'FLOAT'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }" DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Size: '+alltrim(str(DBUstruct[n,3]))+','+ alltrim(str(DBUstruct[n,4]))
                  case DBUstruct[n,5] == 'BLOB'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'file' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  case DBUstruct[n,5] == 'DATE'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'date' VALUE '' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  case  DBUstruct[n,5] == 'DATETIME'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Format: YYYY-MM-DD hh:mm:ss'
                  case  DBUstruct[n,5] == 'TIME'
                     PROPERTYITEM USERFUN DBUstruct[n,1] ITEMDATA "{|| GetColumnData( '"+DBUstruct[n,1]+"', '"+DBUstruct[n,5]+"', "+str(DBUstruct[n,3])+", "+str(DBUstruct[n,4])+" ) }"  DISABLEEDIT ID nId INFO "Field Type:  " + DBUstruct[n,2]+CRLF+ 'Init type: '+DBUstruct[n,5]+CRLF+'Format: hh:mm:ss'
                  case DBUstruct[n,5] = 'BOOL'
                     PROPERTYITEM DBUstruct[n,1]    ITEMTYPE 'check' VALUE 'No' ITEMDATA 'No;Yes' ID nId INFO "Field Type:  " + DBUstruct[n,2] +CRLF+ 'Init type: '+DBUstruct[n,5]
                  endcase

               endcase
            endif
         NEXT
        END CATEGORY

      END PROPGRID

      @ 420,20 BUTTON btn_1;
         CAPTION "Add Record";
         ACTION {|| AddNewRec(cTable, db, DBUstruct),  Form_Edit.release } ;
         WIDTH 100 HEIGHT 24

      @ 420,220 BUTTON btn_2;
         CAPTION "Exit";
         ACTION {|| Form_Edit.release } ;
         WIDTH 100 HEIGHT 24

   END WINDOW
   Form_Edit.Btn_1.Enabled :=FALSE

   CENTER WINDOW Form_Edit
   ACTIVATE WINDOW Form_Edit

Return Nil

Function GetColumnData(cName,cType,nSize,nDec)
   LOCAL nMLines := 0
   LOCAL bCancel := {|| _HMG_DialogCancelled := .T., DoMethod( 'ImputValueBox', 'Release' ) }
   LOCAL RetVal  := '', lOk := .F., cMask

   Local cInputPrompt := cName , cDialogCaption := cType, cDefaultValue := ""
   if cType == 'TEXT'
      nMLines := 150
   endif

   DEFINE WINDOW ImputValueBox;
      AT 0, 0;
      WIDTH 360;
      HEIGHT 135 + nMLines ;
      TITLE 'Type of Column: '+cDialogCaption;
      MODAL;
      ON INTERACTIVECLOSE iif( lOk, NIL, Eval( bCancel ) )

      ON KEY ESCAPE ACTION Eval( bCancel )

      @ 07, 10 LABEL _Label VALUE 'Value for Column: '+cInputPrompt AUTOSIZE

      do case
      case cType == 'TEXT'
         @ 30, 10 EDITBOX _TextBox VALUE cDefaultValue HEIGHT 26 + nMLines WIDTH 320

      Case substr(cType,1,4) == 'CHAR'
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 MAXLENGTH nSize;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.Value, Nil, ImputValueBox._Ok.OnClick )

      case cType == 'INTEGER'
         cMask := "'" + REPLICATE("9", nSize)+"'"
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            NUMERIC MAXLENGTH nSize;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.Value, Nil, ImputValueBox._Ok.OnClick )

      case cType == 'FLOAT'
         cMask := "'"+REPLICATE("9", nSize-nDec-1)+'.'+REPLICATE("9", nDec)+"'"
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            NUMERIC INPUTMASK  &cMask;
            ON ENTER IFEMPTY( ImputValueBox._TextBox.Value, Nil, ImputValueBox._Ok.OnClick )

      case cType == 'DATETIME'
         @ 30, 10 TEXTBOX _TextBox VALUE cDefaultValue HEIGHT 26 WIDTH 320 ;
            INPUTMASK '9999-99-99 99:99:99';
            ON ENTER IFEMPTY( ImputValueBox._TextBox.Value, Nil, ImputValueBox._Ok.OnClick )

      ENDCASE

      @ 67 + nMLines, 120 BUTTON _Ok;
         CAPTION _HMG_MESSAGE [ 6 ];
         ACTION ( lOk := .T., _HMG_DialogCancelled  := .F., ;
            RetVal := Num2Char(ImputValueBox._TextBox.Value,cType,nSize,nDec), ImputValueBox.Release )

      @ 67 + nMLines, 230 BUTTON _Cancel;
        CAPTION _HMG_MESSAGE [ 7 ];
        ACTION Eval( bCancel )

   END WINDOW

   ImputValueBox._TextBox.SetFocus

   CENTER WINDOW ImputValueBox
   ACTIVATE WINDOW ImputValueBox

RETURN ( RetVal )

*------------------------------------------------------------------------------*
Function Num2Char(xValue,cType,nSize,nDec)
*------------------------------------------------------------------------------*
   Local cRet := xValue

   do Case
   case cType == 'INTEGER'
      cRet := str(xValue,nSize)
   case cType == 'FLOAT'
      cRet := str(xValue,nSize,nDec)
   endcase
Return cRet

*------------------------------------------------------------------------------*
FUNCTION AddNewRec(cTable,db, DBUstruct)
*------------------------------------------------------------------------------*
LOCAL aValue:={}, n, nId, cQuery, buff, Stmt, cType, cData
Local aFields :={}
Local lOk := SQLITE_OK

   cQuery := "INSERT INTO "+cTable+" ("

   FOR n:=1 TO Len(DBUstruct)
      if !DBUstruct[n,6]
         nId := 1000+n*10
         GET INFO PROPERTYITEM PropEdit OF  Form_Edit ID nId TO  aValue
         IF valtype(aValue)!='A'
            MsgInfo( " ERROR by read Property Info! ")
         ELSE
            IF aValue[PGI_ID] >= 1000
               aadd (aFields,{aValue[PGI_NAME],aValue[PGI_VALUE],DBUstruct[n,5] })
            endif
         ENDIF
      endif
   NEXT
   for n := 1 to len(aFields)
      if n > 1
         cQuery += ", "
      endif
      cQuery += aFields[n,1]
   next
   cQuery += ") VALUES ( "
   for n := 1 to len(aFields)
      if n > 1
         cQuery += ", "
      endif
      cQuery += ':'+aFields[n,1]
   next
   cQuery += "); "
   stmt := sqlite3_prepare( db, cQuery )
   IF ! Empty( stmt )
      for n := 1 to len(aFields)
         cType := aFields[n,3]
         cData := aFields[n,2]
         do case
         case substr(ctype,1,4) == 'CHAR' .or. ctype == 'TEXT'
            lOk := sqlite3_bind_text( stmt, n, cData )
         case ctype == "INTEGER"
            lOk :=sqlite3_bind_int( stmt, n, val(cData))
         case  ctype == "REAL" .or. ctype == "FLOAT" .or. ctype == "DOUBLE"
            lOk := sqlite3_bind_double( stmt, n, val(cData))
         case ctype == "DATE" .or. ctype == "DATETIME" .or. ctype == "TIME"
            if !empty(cData)
               lOk := sqlite3_bind_text( stmt, n, cData )
            endif
         case ctype == "BOOL"
            cData := if(cData == 'Yes',1,0)
            lOk :=sqlite3_bind_int( stmt, n, cData)
         case ctype == "BLOB"
            buff := sqlite3_file_to_buff( aFields[n,2] )
            lOk := sqlite3_bind_blob( stmt, n, @buff )
            buff := NIL
         endcase
         if lOk != SQLITE_OK
            exit
         endif
      next
      if lOk == SQLITE_OK
         IF sqlite3_step( stmt ) == SQLITE_DONE
            sqlite3_clear_bindings( stmt )
            sqlite3_finalize( stmt )
            MsgInfo( " Record added to table "+cTable, "Result" )
         endif
      else
         sqlite3_reset( stmt )
         MsgInfo( "Error by binding record "+ cQuery ,'Error')
      endif

   endif

RETURN Nil

*--------------------------------------------------------*
Function ZapTable(cTable)
*--------------------------------------------------------*
   Local lRet:= FALSE

//   if MsgYesNo("Deleted All records in table "+cTable+" ?", "Warning")

      lRet := SqlDelete( cTable, TRUE )
      if lRet
         MsgInfo( "All records were removed from table "+cTable, "Result" )
      endif
//   endif
Return lRet

*--------------------------------------------------------*
Function DropTable(cTable, db)
*--------------------------------------------------------*
   Local i, aTable, lRet:= FALSE
   Default cTable := SqlDbuTableName

   if MsgYesNo("Droped Table "+cTable+" from Database ?", "Warning")
      IF SQLITE_TABLEEXISTS( cTable, db )
         if SQLITE_DROPTABLE(SqlDbName, cTable)
            ClearMRUList( )
            aTable := SQLITE_TABLES(db)
            for i:=1 to Len(aTable)
               AddMRUItem( aTable[i] , "SeleTable()" )
            next
            MsgStop( "Table "+cTable+" droped successful." , "Note" )
            lRet := TRUE
         else
            MsgStop( "Can't droped " + cTable, "Error" )
         endif
      endif
   endif
Return lRet
