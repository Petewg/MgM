
#include "minigui.ch"
#include "dbinfo.ch"
#include "hbsqlit3.ch"
#include "TSBrowse.ch"


#define PROGRAM 'SQLITE Browser'
#define VERSION ' Ver. 1.3'
#define COPYRIGHT ' 2012-2016 Janusz Pora'

#define INT_LNG   8
#define FL_LNG   14
#define FL_DEC    5
#define DAT_LNG  10
#define DATTIM_LNG  19
#define BOOL_LNG  1

ANNOUNCE RDDSYS
REQUEST SDDSQLITE3, SQLMIX, DBFNTX


MEMVAR SqlDbuscrwidth, SqlDbuscrheight, SqlDbuwindowwidth, SqlDbuwindowheight
MEMVAR cLastDDir, SqlDbuTableName, SqlDbName, SqlDbulastpath, pDb
MEMVAR DBUgreen, DBUblue

#define SqlDbu_VERSION  '1.3'


#define SQLITE_ENABLE_COLUMN_METADATA


//------------------------------------------------------------------------------
Function MAIN()
//------------------------------------------------------------------------------

public SqlDbName := ""
public SqlDbuTableName := ""

public SqlDbuscrwidth := Min(870,getdesktopwidth())
public SqlDbuscrheight := Min(600,getdesktopheight())
public SqlDbuwindowwidth  := getdesktopwidth() * 0.85
public SqlDbuwindowheight := getdesktopheight() * 0.85

public DBUgreen := {200,255,200}
public DBUblue := {200,200,255}
public pDb  := 0

   public cLastDDir :=''

   SET DATE TO    BRITISH
   SET CENTURY    ON
   SET EPOCH TO   1960
   SET DELETED    ON
   SET EXCLUSIVE  ON

   SET NAVIGATION EXTENDED
   SET BROWSESYNC ON

   RDDSETDEFAULT("SQLMIX")

   SET DEFAULT ICON TO GetStartupFolder() + "\sqlite.ico"

   DEFINE WINDOW FrameDbu at 0,0 ;
      WIDTH SqlDbuscrwidth height SqlDbuscrheight ;
      TITLE "Harbour Minigui DataBase SQLITE Utility" ;
      MAIN ;
      ON INIT GetRegPosWindow("FrameDbu") ;
      ON RELEASE ( Ferase("mru.ini"), SetRegPosWindow("FrameDbu") )

   DEFINE STATUSBAR
      STATUSITEM "DataBase SQLITE Utility" //action SqlDbuopendbf()
      statusitem "Database:" width 80
      statusitem SqlDbName width 260
      statusitem "Table: " width 80
      statusitem SqlDbuTableName width 160
   end statusbar

   DEFINE MAIN MENU

      DEFINE POPUP "&File"
         ITEM " Create &New SQL Base" + Chr(9) + 'Ctrl+N' ACTION CreateDatabase() IMAGE 'MENUNEW.bmp'
         ITEM " Create New &Table "    ACTION CreateStru() NAME AddTableSql IMAGE 'MENUNEW.bmp'
         SEPARATOR
         ITEM " &Open Database "  + Chr(9) + 'Ctrl+O'     ACTION OpenDataBase()  NAME SqlDbuopen IMAGE 'MENUOPEN.bmp'
         SEPARATOR
         DEFINE POPUP  " &Open Table "    NAME SqlOpenTable IMAGE 'MENUOPEN.bmp'
                MRU ' (Empty) '
         END POPUP
         ITEM " &Close Database"       ACTION CloseDataBase()   NAME SqlDbuClose IMAGE 'MENUCLOSE.bmp'
         SEPARATOR
         ITEM " E&xit"+Chr(9)+'Ctrl+X' ACTION FrameDbu.release() IMAGE 'MENUEXIT.bmp'
      END POPUP

      POPUP "&View"
         ITEM " Browse Mode"  ACTION BrowseTable(SqlDbuTableName,FALSE)  NAME SqlDbuBrowse IMAGE 'MENUBROW.bmp'
         ITEM " Edit Mode"    ACTION BrowseTable(SqlDbuTableName,TRUE)  NAME SqlDbuEdit IMAGE 'MENUEDIT.bmp'
         SEPARATOR
         ITEM "Table struct (Fields)"        ACTION StructInfo( SqlDbuTableName)  NAME SqlDbuStru IMAGE 'MENUBROW.bmp'
      END POPUP


      POPUP "&Edit"
         ITEM " &Insert"     ACTION SqlEdit(SqlDbuTableName, pDb)  NAME SqlInsItem IMAGE 'MENUREPL.bmp'
         SEPARATOR
         ITEM " Zap Table"   ACTION ZapTable(SqlDbuTableName,pDb)  NAME SqlZapTable IMAGE 'MENUZAP.bmp'
         ITEM " Drop Table"  ACTION DropTable(SqlDbuTableName,pDb)  NAME SqlDropTable IMAGE 'MENUZAP.bmp'
      END POPUP
      POPUP "&Tools"
         ITEM " &Create from Dbf"     ACTION  CreatefromDBF( ) NAME SqlDbuitem10 IMAGE 'MENUDBFCRE.bmp'
         ITEM " &Add Table from Dbf"  ACTION  CreatefromDBF(,pDb,SqlDbName ) NAME SqlDbuitem11 IMAGE 'MENUDBFCRE.bmp'
         ITEM " Create &Backup"       ACTION  BackupDb() name SqlBackDB IMAGE 'MENUDBFCRE.bmp'

      END POPUP

      POPUP "&Help"
         ITEM ' Version'  ACTION MsgInfo ("SqlDbu version: " + SqlDbu_VERSION  + CRLF + ;
                              "GUI Library : " + MiniGuiVersion() + CRLF + ;
                             "Compiler     : " + Version(), 'Versions') IMAGE 'MENUVER.bmp'

         ITEM ' SQLITE Version'  ACTION MsgInfo ( "Version library = " + sqlite3_libversion() + CRLF + ;
               "number version library = " + LTRIM(STR( sqlite3_libversion_number() )), ;
               "SQLITE INFO" )

      END POPUP

   END MENU

     ON KEY CONTROL+N ACTION CreateDatabase()
     ON KEY CONTROL+O ACTION OpenDataBase()
     ON KEY CONTROL+X ACTION FrameDbu.release()

   END WINDOW

   FrameDbu.SqlDbuClose.Enabled   := FALSE
   FrameDbu.SqlOpenTable.Enabled  := FALSE
   FrameDbu.SqlDbuBrowse.Enabled  := FALSE
   FrameDbu.SqlDbuEdit.Enabled    := FALSE
   FrameDbu.SqlDbuStru.Enabled    := FALSE
   FrameDbu.AddTableSql.Enabled   := FALSE
   FrameDbu.SqlDropTable.Enabled  := FALSE
   FrameDbu.SqlZapTable.Enabled   := FALSE
   FrameDbu.SqlInsItem.Enabled    := FALSE
   FrameDbu.SqlBackDB.Enabled     := FALSE
   FrameDbu.SqlDbuitem11.Enabled  := FALSE

   CENTER WINDOW FrameDbu
   ACTIVATE WINDOW  FrameDbu
return nil

Static Function GetRegPosWindow(FormName, cProgName)
   Local hKey:= HKEY_CURRENT_USER
   Local cKey
   local col , row , width , height
   Local actpos := {0,0,0,0}
   Default FormName := _HMG_ThisFormName
   Default cProgName := SubStr(cFileNoPath( HB_ArgV( 0 ) ),1,RAt('.',cFileNoPath( HB_ArgV( 0 ) ))-1)
   cKey := "Software\MiniGui\"+cProgName+"\"+FormName
   GetWindowRect( GetFormHandle( FormName ), actpos )
   if IsRegistryKey(hKey,cKey)
      col := GetRegistryValue( hKey, cKey, "col", 'N' )
      row := GetRegistryValue( hKey, cKey, "row", 'N' )
      width := GetRegistryValue( hKey, cKey, "width", 'N' )
      height := GetRegistryValue( hKey, cKey, "height", 'N' )
      col   := IFNIL( col, actpos[1], col )
      row   := IFNIL( row, actpos[2], row )
      width := IFNIL( width, actpos[3] - actpos[1], width )
      height:= IFNIL( height, actpos[4] - actpos[2], height )

      MoveWindow ( GetFormHandle( FormName ) , col , row , width , height , TRUE )
   endif
Return Nil

Static Function SetRegPosWindow(FormName,cProgName)
   Local hKey:= HKEY_CURRENT_USER
   Local cKey
   Local actpos := {0,0,0,0}
   local col , row , width , height

   Default FormName := _HMG_ThisFormName
   Default cProgName := SubStr(cFileNoPath( HB_ArgV( 0 ) ),1,RAt('.',cFileNoPath( HB_ArgV( 0 ) ))-1)

   cKey := "Software\MiniGui\"+cProgName+"\"+FormName
   GetWindowRect( GetFormHandle( FormName ), actpos )
   if !IsRegistryKey(hKey,cKey)
      if !CreateRegistryKey( hKey, cKey)
         Return Nil
      endif
   endif
   if IsRegistryKey(hKey,cKey)
      col   :=  actpos[1]
      row   :=  actpos[2]
      width :=  actpos[3] - actpos[1]
      height:=  actpos[4] - actpos[2]
      SetRegistryValue( hKey, cKey, "col", col )
      SetRegistryValue( hKey, cKey, "row", row )
      SetRegistryValue( hKey, cKey, "width", width )
      SetRegistryValue( hKey, cKey, "height", height )
   endif
Return Nil

*--------------------------------------------------------*
FUNCTION OpenDataBase(cFileName,lCreate)
*--------------------------------------------------------*

   LOCAL  aTable, n
   LOCAL lCreateIfNotExist := FALSE
   Default lCreate := FALSE
   lCreateIfNotExist := lCreate

   If empty(cFileName)
      cFileName := GetFile ( {{ "SQLITE3 Files", "*.s3db"},{ "Database Files", "*.db"},{ "All Files", "*.*"} } ,;
                           "Open Database" , cLastDDir, FALSE , TRUE )
   endif
   If !empty(cFileName)

      ClearMRUList( )

      pDb := sqlite3_open( cFileName, lCreateIfNotExist )

      IF !DB_IS_OPEN( pDb )
         pDb:=0
         MsgStop("Unable open a database!", "Error")
         Return FALSE
      endif

      SqlDbName := cFileName
      aTable := SQLITE_TABLES(pDb)
      for n:=1 to Len(aTable)
         AddMRUItem( aTable[n] , "SeleTable()" )
      next

      IF RDDINFO( RDDI_CONNECT, {"SQLITE3", cFileName} ) == 0
         MsgStop("Unable connect to the server!", "Error")
         Return FALSE
      ENDIF

      FrameDbu.SqlDbuClose.Enabled   := TRUE
      FrameDbu.SqlOpenTable.Enabled  := len(aTable)> 0
      FrameDbu.AddTableSql.Enabled   := TRUE
      FrameDbu.SqlBackDB.Enabled     := TRUE
      FrameDbu.SqlDbuitem11.Enabled  := TRUE
      SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,3 , SqlDbName )
      SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,5 , '' )
   ENDIF

RETURN TRUE

*--------------------------------------------------------*
FUNCTION CloseDataBase()
*--------------------------------------------------------*
   ClearMRUList( )
   FrameDbu.SqlDbuClose.Enabled   := FALSE
   FrameDbu.SqlOpenTable.Enabled  := FALSE
   FrameDbu.SqlDbuBrowse.Enabled  := FALSE
   FrameDbu.SqlDbuEdit.Enabled    := FALSE
   FrameDbu.SqlDbuStru.Enabled    := FALSE
   FrameDbu.AddTableSql.Enabled   := FALSE
   FrameDbu.SqlDropTable.Enabled  := FALSE
   FrameDbu.SqlZapTable.Enabled   := FALSE
   FrameDbu.SqlInsItem.Enabled    := FALSE
   FrameDbu.SqlBackDB.Enabled     := FALSE
   FrameDbu.SqlDbuitem11.Enabled  := FALSE
   SqlDbName := ""
   SqlDbuTableName := ''
   pDb:=0
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,3 , SqlDbName )
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,5 , SqlDbuTableName )

Return NIL

*--------------------------------------------------------*
Function SeleTable(cTable)
*--------------------------------------------------------*
   IF SQLITE_TABLEEXISTS( cTable, pDb )
     SqlDbuTableName  := cTable
     FrameDbu.SqlDbuBrowse.Enabled := TRUE
     FrameDbu.SqlDbuEdit.Enabled   := TRUE
     FrameDbu.SqlDbuStru.Enabled   := TRUE
     FrameDbu.SqlDropTable.Enabled := TRUE
     FrameDbu.SqlZapTable.Enabled  := TRUE
     FrameDbu.SqlInsItem.Enabled   := TRUE
     SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,5 , SqlDbuTableName )

   endif
Return Nil

*--------------------------------------------------------*
Procedure CloseTable
*--------------------------------------------------------*

   DBCLOSEALL()
   SetProperty ( 'FrameDbu', 'StatusBar', 'Item' ,5 , '' )

Return


*--------------------------------------------------------*
 FUNCTION StructInfo( cTable )
*--------------------------------------------------------*
* Shows Information about fields...
*--------------------------------------------------------*
  LOCAL aResult,aInfo :={}
  LOCAL DBUstruct :={}, aSeq :={}

  IF VALTYPE( cTable ) != "C" .OR. EMPTY( cTable ) .OR. cTable == NIL
      RETURN 0
   ELSE
      aSeq := SQLITE_TABLESEQUENCE( pDb, cTable )
      aResult := SQLITE_COLUMNS_METADATA(pDb, cTable )
   ENDIF

   IF len(aResult) > 0
     nSeq := if(len(aSeq)> 0,aSeq[2],0)
     AEval( aResult, {|x,y| aAdd(DBUstruct,{y,x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],if(x[8],nSeq,'')})})
     BrowStru(DBUstruct,aResult,cTable, ,aSeq)
  ENDIF

RETURN nil


*--------------------------------------------------------*
Function CreateDatabase()
*--------------------------------------------------------*
   Local cFileName:=''

   DEFINE window FrameNewBase ;
      AT 0,0 WIDTH 500 HEIGHT 300 ;
      TITLE "Create a new SQLITE Database" NOSIZE //nosysmenu

   @ 10,10 FRAME Frame_1 ;
      WIDTH 550;
      HEIGHT 200;
      CAPTION "Info"

   @ 40,40 LABEL Lbl_Path ;
      VALUE "Path";
      WIDTH 60 ;
      BACKCOLOR DBUblue


   @ 40,110 BTNTEXTBOX Text_Path;
      width 350 ;
      VALUE ""   ;
      BACKCOLOR DBUgreen ;
      Action  {|| FrameNewBase.Text_Path.value := GetFolder (,FrameNewBase.Text_Path.value),cFileName:= FileNameCreta() }

   @ 80,40 LABEL Lbl_Name;
      VALUE "Name" ;
      WIDTH 60;
      BACKCOLOR DBUblue


   @ 80,110 TEXTBOX Text_Name ;
      WIDTH 150 ;
      UPPERCASE ;
      BACKCOLOR DBUgreen;
      VALUE "";
      ON CHANGE {|| cFileName:= FileNameCreta(),FrameNewBase.Btn_Create.Enabled := !empty(FrameNewBase.Text_Name.Value) }

   @ 120,110 LABEL Lbl_File;
      VALUE cFileName ;
      AUTOSIZE BOLD

   DEFINE BUTTON Btn_Create
      ROW 160
      COL 75
      CAPTION "Create"
      WIDTH 100
      ACTION OpenDataBase(cFileName,TRUE)
   END BUTTON


   END WINDOW
   FrameNewBase.Btn_Create.Enabled := FALSE
   CENTER WINDOW FrameNewBase

   ACTIVATE WINDOW FrameNewBase

   Return Nil

*--------------------------------------------------------*
Function FileNameCreta()
*--------------------------------------------------------*
   Local cFile, cName

   cFile:= FrameNewBase.Text_Name.value
   if !empty(cFile) .and. at('.',cFile) == 0
      cFile:= cFile+'.s3db'
   endif
   cName := FrameNewBase.Text_Path.value+'\'+cFile
   FrameNewBase.lbl_File.value := cName
Return cName

*--------------------------------------------------------*
Function CreateStru()
*--------------------------------------------------------*
   Local DBUstruct :={}

   BrowStru(DBUstruct,{},'',TRUE)
return Nil

*--------------------------------------------------------*
Function CreateNewTable( oGrid, cTable )
*--------------------------------------------------------*
   Local cQuery, i, aTable, aStru
   Local  lRet := FALSE

   cQuery := QueryNewTbl(oGrid,cTable)

   IF !sqlite3_exec( pDb, cQuery ) == SQLITE_OK
      MsgStop( "Can't create " + cTable, "Error" )
   else
      ClearMRUList( )
      aTable := SQLITE_TABLES(pDb)
      for i:=1 to Len(aTable)
         AddMRUItem( aTable[i] , "SeleTable()" )
      next
      MsgStop( "Table "+cTable+" create successful." , "Note" )
      lRet := TRUE
      aStru:={}
      AEval(oGrid:aArray, {|x| aAdd(aStru,{x[2],x[3],x[4],x[5]})})

   endif
Return lRet

*--------------------------------------------------------*
 FUNCTION CreatefromDBF( cDBase, db, cSbase )
*--------------------------------------------------------*
   LOCAL cHeader, cQuery := "", NrReg:= 0, cTable := cFileNoExt(cDBase)
   LOCAL lCreateIfNotExist := FALSE, cOldRdd, aDbStru

   if empty( cDBase )
      cDBase := GetFile ( {{ "DBASE Files", "*.dbf"},{ "All Files", "*.*"} }, "Open Database" ,;
                           cLastDDir, FALSE , FALSE )
   endif
   IF FILE( cDBase )
      cTable := SubStr(cFileNoPath(cDBase ),1,RAt('.',cDBase )-1)
      cTable := cFileNoExt(cTable)
      DEFAULT cSbase := cTable+'.s3db'
      db := sqlite3_open( cSbase, .not. File(cSbase) )
      IF !DB_IS_OPEN( db )
         MsgStop( "Can't open/create " + cSbase, "Error" )
         Return Nil
      endif
      sqlite3_exec( db, "PRAGMA auto_vacuum=0" )
      IF SQLITE_TABLEEXISTS( cTable, db )
         if !SQLITE_DROPTABLE(cSbase, cTable)
            MsgStop( "Can't drop table " + cTable, "Error" )
            Return Nil
         else
            db := sqlite3_open( cSbase, .not. File(cSbase) )
         endif
      endif

      * Create table
      IF ( RDDSETDEFAULT() != "DBFNTX" )
         cOldRdd := RDDSETDEFAULT( "DBFNTX" )
      ENDIF

      DBUSEAREA(TRUE,'DBFNTX',cTable)
      IF !SQLITE_TABLEEXISTS( cTable, db )

         cHeader := QueryCrea(cTable,0)
         IF sqlite3_exec( db, cHeader ) == SQLITE_OK
            aDbStru := dbstruct()
            aDbStru:=SetFieldType(aDbStru)
         endif
      endif
      IF SQLITE_TABLEEXISTS( cTable, db )


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
         else
            MsgInfo(substr(cQuery,1,300))
         ENDIF

      ENDIF

   ENDIF

   RDDSETDEFAULT( cOldRdd )
   IF OpenDataBase( cSbase )
      SeleTable(cTable)
      BrowseTable(cTable, FALSE)
   ENDIF
RETURN 0

*--------------------------------------------------------*
Function SetFieldType(aDbStru)
*--------------------------------------------------------*
   Local i
      for i:= 1 to len( aDbStru )
        do case
         case aDbStru[i, 2] $ "CDT"
           aDbStru[i, 2] := "SQLITE_TEXT"
           aDbStru[i, 3] := 50
         case aDbStru[i, 2] = "N"
            if aDbStru[i, 4] > 0
               aDbStru[i, 2] := "SQLITE_FLOAT"
               aDbStru[i, 3] := 12
               aDbStru[i, 4] := 2
            else
               aDbStru[i, 2] := "SQLITE_INTEGER"
            endif
         case aDbStru[i, 2] = "F"
            aDbStru[i, 2] := "SQLITE_FLOAT"
         case aDbStru[i, 2] = "I"
            aDbStru[i, 2] := "SQLITE_INTEGER"
         case aDbStru[i, 2] = "B"
            aDbStru[i, 2] := "SQLITE_FLOAT"
         case aDbStru[i, 2] = "Y"
            aDbStru[i, 2] := "SQLITE_FLOAT"
         case aDbStru[i, 2] = "L"
            aDbStru[i, 2] := "SQLITE_INTEGER"
         case aDbStru[i, 2] = "M"
            aDbStru[i, 2] := "SQLITE_TEXT"
         case aDbStru[i, 2] = "G"
            aDbStru[i, 2] := "SQLITE_BLOB"
         otherwise
            aDbStru[i, 2] := "SQLITE_NULL"
         endcase
      next
Return  aDbStru

*--------------------------------------------------------*
function QueryCrea(cTable, met, cTable2, aDbStru)
*--------------------------------------------------------*
   local cQuery := "",i
   local cFldName, cFldType, cFldLen, cFldDec, lNull, lKey, lIncr

   default aDbStru := dbstruct(), cTable2 := cTable+"Tmp"
   do Case
   case met ==0
      cQuery := "CREATE TABLE IF NOT EXISTS " + cTable + " ( "
      for i:= 1 to len( aDbStru )

         cFldName := aDbStru[i, 1]
         cFldType := aDbStru[i, 2]
         cFldLen  := aDbStru[i, 3]
         cFldDec  := aDbStru[i, 4]
         lNull    := aDbStru[i, 6]
         lKey     := aDbStru[i, 7]
         lIncr    := aDbStru[i, 8]


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
            if cFldDec > 0
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

      cQuery := "INSERT INTO "+cTable+" VALUES ("
      for i := 1 to len(aDbStru)
         cFldName := aDbStru[i, 1]
         if i > 1
            cQuery += ", "
         endif
         cQuery += c2sql(&cFldName)
      next
      cQuery += "); "

   case met == 2
      cQuery := "CREATE TEMPORARY TABLE "+cTable2+ " ( "
      for i := 1 to len(aDbStru)
         cFldName := aDbStru[i, 1]
         if i > 1
            cQuery += ", "
         endif
         cQuery += alltrim(cFldName)+" "

      next
      cQuery += "); "

   case met == 3
      cQuery := "INSERT INTO "+cTable2+"  SELECT "
      for i := 1 to len(aDbStru)
         cFldName := aDbStru[i, 1]
         if i > 1
            cQuery += ", "
         endif
         cQuery += alltrim(cFldName)+" "

      next
      cQuery += "FROM " + cTable +" ;"

    endcase
Return cQuery

*--------------------------------------------------------*
function c2Sql(Value)
*--------------------------------------------------------*
local cValue := ""
local cdate := ""
if valtype(value) == "C" .and. len(alltrim(value)) > 0
   value := strtran(value,"'","''")
endif
do case
   case Valtype(Value) == "N"
      cValue := AllTrim(Str(Value))
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
      cValue := AllTrim(Str(iif(Value == FALSE, 0, 1)))
   otherwise
      cValue := "''"       // NOTE: Here we lose values we cannot convert
endcase
return cValue

*--------------------------------------------------------*
 FUNCTION SQLITE_TABLEEXISTS( cTable,db )
*--------------------------------------------------------*
* Uses a (special) master table where the names of all tables are stored
*---------------------------------------------------------------------------
  LOCAL cStatement, lRet := FALSE
  LOCAL lCreateIfNotExist := FALSE

  cStatement := "SELECT name FROM sqlite_master "    +;
                "WHERE type ='table' AND tbl_name='" +;
                cTable + "'"

  IF DB_IS_OPEN( db )
    lRet := ( LEN( SQLITE_QUERY( db, cStatement ) ) > 0 )
  ENDIF

RETURN( lRet )

*--------------------------------------------------------*
 FUNCTION SQLITE_TABLESEQUENCE( db, cTable )
*--------------------------------------------------------*
* Uses a (special) sqlite_sequence table where the names of sequence tables are stored
*---------------------------------------------------------------------------
   LOCAL cStatement,aFields :={}
   Default cTable := ""
   cStatement := "SELECT name,seq FROM sqlite_sequence "
   if !empty(cTable)
      cStatement +=  "WHERE name='" + cTable + "'"
   endif
   IF DB_IS_OPEN( db )
     aFields :=  SQLITE_QUERY( db, cStatement )
   ENDIF

RETURN( aFields )


*--------------------------------------------------------*
 FUNCTION SQLITE_DROPTABLE(cBase, cTable)
*--------------------------------------------------------*
* Deletes a table from current database
* WARNING !!   It deletes forever...
*---------------------------------------------------------------------------
  LOCAL db, lRet := FALSE

  IF !EMPTY(cTable)
   IF MsgYesNo("The  table "+cTable+" will be erased" + CRLF + ;
      "without any choice to recover." + CRLF + CRLF + ;
      "       Continue ?", "Warning!" )

      db := sqlite3_open_v2( cBase, SQLITE_OPEN_READWRITE + SQLITE_OPEN_EXCLUSIVE )
      IF DB_IS_OPEN( db )
         IF sqlite3_exec( db, "drop table " + cTable ) == SQLITE_OK
            IF sqlite3_exec( db, "vacuum" ) == SQLITE_OK
               lRet := TRUE
            ENDIF
         ENDIF
      ENDIF
   ENDIF
  ENDIF

RETURN lRet

*--------------------------------------------------------*
 FUNCTION SQLITE_COLUMNS( cTable, db )
*--------------------------------------------------------*
* Returns an 2-dimensional array with field names and types
*---------------------------------------------------------------------------
   LOCAL aCType :=  { "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_TEXT", "SQLITE_BLOB", "SQLITE_NULL" }
   LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
   LOCAL lCreateIfNotExist := FALSE
   LOCAL stmt, nCCount, nI, nCType, cType, cName, aSize

   stmt := sqlite3_prepare( db, cStatement )

   sqlite3_step( stmt )
   nCCount := sqlite3_column_count( stmt )

   IF nCCount > 0
      FOR nI := 1 TO nCCount
         cName := sqlite3_column_name( stmt, nI )
         nCType := sqlite3_column_type( stmt, nI )
         cType := upper(alltrim(sqlite3_column_decltype( stmt,nI)))
         aSize := FieldSize(cType,cname,db, cTable)
         AADD( aFields, { cName, aCType[ nCType ],cType ,aSize[1],aSize[2]} )
      NEXT nI
   ENDIF

   sqlite3_finalize( stmt )

RETURN( aFields )

*--------------------------------------------------------*
 FUNCTION SQLITE_COLUMNS_METADATA( db, cTable)
*--------------------------------------------------------*
* Returns an 2-dimensional array with field names and types
*---------------------------------------------------------------------------
   LOCAL aCType :=  { "SQLITE_INTEGER", "SQLITE_FLOAT", "SQLITE_TEXT", "SQLITE_BLOB", "SQLITE_NULL" }
   LOCAL aFields := {}, cStatement := "SELECT * FROM " + cTable
   LOCAL stmt, nCCount, nI, nCType, cName, aInfo := {'','',FALSE,FALSE,FALSE,''}
   Local cType, aSize
   stmt := sqlite3_prepare( db, cStatement )

   sqlite3_step( stmt )
   nCCount := sqlite3_column_count( stmt )
   IF nCCount > 0
      FOR nI := 1 TO nCCount
         cName  := sqlite3_column_name( stmt, nI )
         nCType := sqlite3_column_type( stmt, nI )
         cType  := upper(alltrim(sqlite3_column_decltype( stmt,nI)))
         aSize  := FieldSize(cType,cname,db, cTable)

#ifdef SQLITE_ENABLE_COLUMN_METADATA
         aInfo  := sqlite3_table_column_metadata( db,,cTable,cName)
#endif

//VIEW cTable,cName,aInfo
         AADD( aFields, { cName, aCType[ nCType ],cType ,aSize[1],aSize[2],aInfo[3],aInfo[4],aInfo[5] } )

      NEXT nI
   ENDIF

   sqlite3_finalize( stmt )

RETURN( aFields )


*--------------------------------------------------------*
 FUNCTION SQLITE_TABLES(db)
*--------------------------------------------------------*
* Uses a (special) master table where the names of all tables are stored
* Returns an array with names of tables inside of the database
*---------------------------------------------------------------------------
  LOCAL aTables, cStatement

  cStatement := "SELECT name FROM sqlite_master "      +;
                "WHERE type IN ('table','view') "      +;
                "AND name NOT LIKE 'sqlite_%' "        +;
                "UNION ALL "                           +;
                "SELECT name FROM sqlite_temp_master " +;
                "WHERE type IN ('table','view') "      +;
                "ORDER BY 1;"

  IF DB_IS_OPEN( db )
    aTables := SQLITE_QUERY( db, cStatement )
  ENDIF

RETURN( aTables )

*--------------------------------------------------------*
FUNCTION SQLITE_QUERY( db, cStatement )
*--------------------------------------------------------*
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

*--------------------------------------------------------*
FUNCTION SQLITE_SET_BLOB( cTable, cField, db, cFile )
*--------------------------------------------------------*
   LOCAL stmt, nI, cQuery, aFields
   LOCAL Buff, lRet := FALSE
//      sqlite3_exec( db, "PRAGMA auto_vacuum=0" )
//      sqlite3_exec( db, "PRAGMA page_size=8192" )

   aFields :=SQLITE_COLUMNS( cTable, db )
   If (nI := ascan(aFields,{|x| x[1] == cField .and. x[3] =='BLOB'} )) == 0
      Return lRet
   endif
   cQuery := "INSERT INTO "+cTable+" ("+cField+ ') VALUES ( :'+cField+ ');'

   stmt := sqlite3_prepare( db, cQuery )

   IF STMT_IS_PREPARED( stmt )
      buff := sqlite3_file_to_buff( cFile )

      IF sqlite3_bind_blob( stmt, 1, @buff ) == SQLITE_OK
         IF sqlite3_step( stmt ) == SQLITE_DONE
            lRet := TRUE
         ENDIF
      ENDIF
      buff := NIL
      sqlite3_clear_bindings( stmt )
      sqlite3_finalize( stmt )

   ENDIF

RETURN( lRet )

*--------------------------------------------------------*
FUNCTION SQLITE_GET_BLOB( cTable, cField, db, cFile )
*--------------------------------------------------------*
   LOCAL stmt, nI, cQuery, aFields, i, cFldName
   LOCAL Buff, lRet := FALSE

   aFields :=SQLITE_COLUMNS( cTable, db )
   If (nI := ascan(aFields,{|x| x[1] == cField .and. x[3] =='BLOB'} )) == 0
      Return lRet
   endif
   cQuery := "SELECT "+cField+ " FROM "+cTable+" WHERE "
   for i := 1 to len(aFields)
      if aFields[i, 3] != 'BLOB'
         cFldName := aFields[i, 1]
         if i > 1
            cQuery += " AND "
         endif
         cQuery += cFldName + " = "+  c2sql(&cFldName)
      endif
   next

   stmt := sqlite3_prepare( db, cQuery )

   IF STMT_IS_PREPARED( stmt )
      IF sqlite3_step( stmt ) == SQLITE_ROW
         buff := sqlite3_column_blob( stmt, 1 )

         IF ( sqlite3_buff_to_file( cFile, @buff ) == SQLITE_OK )
            MsgInfo("Save BLOB into "+cFile+"- Done")
            lRet := TRUE
         ENDIF
         buff := NIL
      ENDIF
      sqlite3_clear_bindings( stmt )
      sqlite3_finalize( stmt )

   ENDIF

RETURN( lRet )

*--------------------------------------------------------*
Function FieldSize(cType,cFieldName,db,cTable)
*--------------------------------------------------------*
   Local aSize := {0,0}, cQuery, aLength

   do Case
   case substr(ctype,1,4) == 'CHAR'
      aSize[1] := val(CHARONLY ("0123456789",cType))
   case ctype == 'TEXT'
      aSize[1] := 0
      cQuery := 'select max( length( ' + cFieldName + ' ) ) from ' +  cTable
      aLength := SQLITE_QUERY( db, cQuery )
      if len( aLength ) > 0
         aSize[2] := val( alltrim( aLength[ 1 ] ) )
      endif
   case ctype == "INTEGER"
      aSize[1]:= INT_LNG  //8
   case  ctype == "REAL" .or. ctype == "FLOAT" .or. ctype == "DOUBLE"
      aSize[1]:= FL_LNG   //14
      aSize[2]:= FL_DEC   //5
   case ctype == "DATE" .or. ctype == "TIME"
      aSize[1]:= DAT_LNG //10
   case  ctype == "DATETIME"
      aSize[1]:=DATTIM_LNG //19
   case ctype == "BOOL"
      aSize[1]:= BOOL_LNG //1
   endcase
Return aSize

*--------------------------------------------------------*
Function BackupDb()
*--------------------------------------------------------*
  Local cFileDest, pDbDest, nDbFlags, pBackup

   cFileDest := cFileNoExt(SqlDbName)+'.s3bac'

   IF sqlite3_libversion_number() < 3006011
      RETURN 0
   ENDIF

   IF Empty( pDb )
      RETURN 0
   ENDIF

   nDbFlags := SQLITE_OPEN_CREATE + SQLITE_OPEN_READWRITE + ;
               SQLITE_OPEN_EXCLUSIVE
   pDbDest := sqlite3_open_v2( cFileDest, nDbFlags )

   IF Empty( pDbDest )
      MsgInfo( "Can't open database : "+ cFileDest )

      RETURN 0
   ENDIF

   pBackup := sqlite3_backup_init( pDbDest, "main", pDb, "main" )
   IF Empty( pBackup )
     MsgInfo( "Can't initialize backup" )
      RETURN 0
   ENDIF

  If MsgYesNo( "Backup File "+SqlDbName+ " to "+cFileDest+CRLF+ "Start backup ?", "Backup Database" )

      IF sqlite3_backup_step(pBackup, -1) == SQLITE_DONE
         MsgInfo( "Backup successful."+CRLF+'File created : '+cFileDest )
      ENDIF
      sqlite3_backup_finish( pBackup )
   endif
Return 1

#include 'SqlEdit.Prg'
#include 'SqlBrowse.Prg'
