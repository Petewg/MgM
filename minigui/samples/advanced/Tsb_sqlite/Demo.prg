#include "minigui.ch"
#include "TSBrowse.ch"
#include "hbsqlit3.ch"
#include "dbinfo.ch"

ANNOUNCE RDDSYS
REQUEST SDDSQLITE3, SQLMIX, DBFNTX

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
   Local cFileDb := hb_dirBase() + "Employee.s3db"
   Local cTable := "Employee"

   RDDSETDEFAULT( "SQLMIX" )
   SET DELETED ON

   DEFINE WINDOW Form_0 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'SQLITE3 Database Driver Demo' ;
      MAIN NOMAXIMIZE  ;
      ON INIT InitDb( cFileDb, cTable )

      DEFINE MAIN MENU

         DEFINE POPUP 'File'
            ITEM "Exit"   ACTION ThisWindow.Release()
         END POPUP
         DEFINE POPUP 'Tests'
            MENUITEM 'Editable'  ACTION BrowseTable(cTable, 1) NAME BRW1
            MENUITEM 'Sbrowse'   ACTION BrowseTable(cTable, 2) NAME BRW2
         END POPUP

      END MENU

   END WINDOW

   CENTER WINDOW Form_0

   ACTIVATE WINDOW Form_0

Return nil

*--------------------------------------------------------*
Function InitDb( cFileDb, cTable )
*--------------------------------------------------------*
   Local lRet := .t.

   if !file( cFileDb )
      if !CreatefromDBF( cFileDb, cTable )
         MsgStop("Unable create SQL Database file from EMPLOYEE.DBF!", "Error")
         lRet := .f.
      endif
   endif
   if lRet
      IF RDDINFO( RDDI_CONNECT, {"SQLITE3", hb_dirBase() + "Employee.s3db"} ) == 0
         MsgStop("Unable connect to the server!", "Error")
         lRet := .f.
      ENDIF
   endif
   Form_0.Brw1.Enabled := lRet
   Form_0.Brw2.Enabled := lRet

Return Nil

*--------------------------------------------------------*
FUNCTION BrowseTable(cTable, mod)
*--------------------------------------------------------*
   Local cSelect, bSetup , oBrw
   Local nWinWidth  := getdesktopwidth() * 0.8
   Local nWinHeight := getdesktopheight() * 0.8
   Local cTitle := "Table: " + cTable

   if mod == 1
      cSelect := "SELECT * FROM " + cTable

      DBUSEAREA( .T.,, cSelect, "TABLE" ,,, "UTF8")

      Select TABLE

      DEFINE WINDOW Form_1 ;
         AT 0,0  ;
         WIDTH nWinWidth ;
         HEIGHT nWinHeight ;
         TITLE cTitle ;
         CHILD BACKCOLOR RGB( 191, 219, 255 )

         DEFINE TBROWSE oBrw AT 10, 10 ALIAS "TABLE" WIDTH nWinWidth - 26 HEIGHT nWinHeight - 70 ;
            AUTOCOLS SELECTOR 20 EDITABLE CELLED

            AEval( oBrw:aColumns, {| oCol |  oCol:bPostEdit := { | uVal, oBr, lApp | SqlUpdate(uVal, oBr:nCell-1, cTable, lApp) } })

            oBrw:SetAppendMode( .T. )
            oBrw:SetDeleteMode( .T., .T., {|| SqlDelete(cTable)}  )

            oBrw:nHeightCell += 2
            oBrw:nHeightHead += 5

         END TBROWSE

      END WINDOW

      CENTER WINDOW Form_1
      ACTIVATE WINDOW Form_1

      close TABLE
   else
      bSetup := { |oBrw| SetMyBrowser( oBrw ) }
      SBrowse( cTable, cTitle, bSetup,, nWinWidth, nWinHeight, .t. )
   endif

Return Nil

*--------------------------------------------------------*
Static Function SetMyBrowser( oBrw )
*--------------------------------------------------------*
       oBrw:nHeightCell += 5
       oBrw:nHeightHead += 5
       oBrw:nClrFocuFore := CLR_BLACK
       oBrw:nClrFocuBack := COLOR_GRID

Return .F.

*--------------------------------------------------------*
Function SqlUpdate(uVal, nCol, cTable, lApp)
*--------------------------------------------------------*
   Local cQuery, i, cFldName, nStart, cQuery2
   Local aDbStru := dbstruct()

   if lApp
      cQuery:= "INSERT INTO "+cTable+" ( "
      cQuery2:= " ) values ( "
      for i := 1 to len(aDbStru)
         cFldName := aDbStru[i, 1]
         if i > 1
               cQuery += " , "
               cQuery2 += " , "
         endif
         cQuery += cFldName
         cQuery2 += c2sql(&cFldName)
      next
      cQuery += cQuery2 +  " )"

   else
      nStart := if(nCol==1,2,1)
      cFldName := aDbStru[nCol, 1]
      cQuery := "UPDATE "+cTable+" SET " + cFldName + " = " + c2sql(&cFldName) + " WHERE "
      for i := 1 to len(aDbStru)
         if i != nCol
            cFldName := aDbStru[i, 1]
            if i > nStart
               cQuery += " AND "
            endif
            cQuery += cFldName + " = "+  c2sql(&cFldName)
         endif
      next
      cQuery += " "
   endif

   If ! RDDINFO(RDDI_EXECUTE, cQuery )
      MsgStop("Can't update record in table "+cTable+" !", "Error")
      Return .F.
   EndIf

Return .T.

*--------------------------------------------------------*
Function SqlDelete(cTable )
*--------------------------------------------------------*
   Local cQuery, i, cFldName
   Local aDbStru := dbstruct()

   cQuery := "DELETE FROM "+cTable+ " WHERE "
   for i := 1 to len(aDbStru)
      cFldName := aDbStru[i, 1]
      if i > 1
         cQuery += " AND "
      endif
      cQuery += cFldName + " = "+  c2sql(&cFldName)
   next
   cQuery += " "

   If ! RDDINFO(RDDI_EXECUTE, cQuery )
      MsgStop("Can't Delete record in table "+cTable+" !", "Error")
      Return .F.
   EndIf

Return .T.


*--------------------------------------------------------*
FUNCTION CreatefromDBF(cSbase, cDBase  )
*--------------------------------------------------------*
   LOCAL cHeader, cQuery := "", NrReg:= 0, cTable := cFileNoExt(cDBase)
   LOCAL lCreateIfNotExist := .t., cOldRdd, db, lRet := .f.

   IF !FILE( hb_dirBase()+cDBase+".dbf" )
      RETURN .f.
   endif
   cTable := cDBase
   db := sqlite3_open( cSbase, lCreateIfNotExist )
   IF !DB_IS_OPEN( db )
      MsgStop( "Can't open/create " + cSbase, "Error" )
      Return .f.
   endif
   sqlite3_exec( db, "PRAGMA auto_vacuum=0" )

   * Create table
   IF ( RDDSETDEFAULT() != "DBFNTX" )
      cOldRdd := RDDSETDEFAULT( "DBFNTX" )
   ENDIF

   DBUSEAREA(.T.,'DBFNTX',cTable)
   cHeader := QueryCrea(cTable,0)
   IF sqlite3_exec( db, cHeader ) == SQLITE_OK
      go top
      Do While !Eof()
         cQuery += QueryCrea(cTable,1)
         NrReg++
         skip
      EndDo
      use

      IF sqlite3_exec( db, ;
         "BEGIN TRANSACTION;" + ;
         cQuery + ;
         "COMMIT;" ) == SQLITE_OK

         MsgInfo( AllTrim(Str(NrReg))+" records added to table "+cTable, "Result" )
         lRet := .t.
      ENDIF

   ENDIF
   RDDSETDEFAULT( cOldRdd )

RETURN .t.

*--------------------------------------------------------*
FUNCTION QueryCrea(cDBase,met)
*--------------------------------------------------------*
   Local cQuery := "",i
   Local cFldName, cFldType, cFldLen, cFldDec
   Local aDbStru := dbstruct()

   Do Case
   case met == 0
      cQuery := "CREATE TABLE IF NOT EXISTS " + cDBase + " ( "
      for i:= 1 to len( aDbStru )

         cFldName := aDbStru[i, 1]
         cFldType := aDbStru[i, 2]
         cFldLen  := aDbStru[i, 3]
         cFldDec  := aDbStru[i, 4]

         if i > 1
            cQuery += ", "
         endif
         cQuery += alltrim(cFldName)+" "

         do case
         case cFldType = "C"
            cQuery += "CHAR("+LTRIM(STR(cFldLen))+")"
         case cFldType = "D"
            cQuery += "DATE"
         case cFldType = "T"
            cQuery += "DATETIME"
         case cFldType = "N"
            if cFldDec > 0 .or. cFldLen > 5
               cQuery += "FLOAT"
            else
               cQuery += "INTEGER"
            endif
         case cFldType = "F"
            cQuery += "FLOAT"
         case cFldType = "I"
            cQuery += "INTEGER"
         case cFldType = "B"
            cQuery += "DOUBLE"
         case cFldType = "Y"
            cQuery += "FLOAT"
         case cFldType = "L"
            cQuery += "BOOL"
         case cFldType = "M"
            cQuery += "TEXT"
         case cFldType = "G"
            cQuery += "BLOB"
         otherwise
            msginfo("Invalid Field Type: "+cFldType)
            return nil
         endcase
      next

      cQuery += ")"

   case met == 1

      cQuery := "INSERT INTO "+cDBase+" VALUES ("
      for i := 1 to len(aDbStru)
         cFldName := aDbStru[i, 1]
         if i > 1
            cQuery += ", "
         endif
         cQuery += c2sql(&cFldName)
      next
      cQuery += "); "

   EndCase

Return cQuery

*--------------------------------------------------------*
Function c2Sql(Value)
*--------------------------------------------------------*
   Local cValue := ""
   Local cdate := ""

   if valtype(value) == "C" .and. len(alltrim(value)) > 0
      value := strtran(value,"'","''")
   endif
   do case
   case Valtype(Value) == "N"
      cValue := hb_ntos(Value)
   case Valtype(Value) == "D"
      if !Empty(Value)
         cdate := dtos(value)
         cValue := "'"+substr(cDate,1,4)+"-"+substr(cDate,5,2)+"-"+substr(cDate,7,2)+"'"
      else
         cValue := "''"
      endif
   case Valtype(Value) $ "CM"
      IF Empty( Value)
         cValue="''"
      ELSE
         cValue := "'" + value + "'"
      ENDIF
   case Valtype(Value) == "L"
      cValue := AllTrim(Str(iif(Value == .F., 0, 1)))
   otherwise
      cValue := "''"
   endcase

Return cValue
