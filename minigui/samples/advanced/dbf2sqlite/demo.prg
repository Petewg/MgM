#include <minigui.ch>
#include <dbstruct.ch>

Set Proc To hmgsqlite

memvar oDB, oDB1
memvar cTableName, cNewTable
memvar lOpened

Function Main

public oDB := nil
public oDB1 := nil
private cTableName := ''
private cNewTable := ''
private lOpened := .f.


set navigation extended
set date ital
set century on

define window sql at 0, 0 width 370 height 290 main title "DBF<-->SQLite Exporter" nosize nomaximize
   define tab dbtab at 10, 10 width 350 height 250 
      define page 'DBF -> SQLite'
         define frame dbfframe
            row 25
            col 5
            width 160
            caption 'DBF to be converted'
            height 110
         end frame
         define button browsedbf
            row 50
            col 10
            width 150
            caption "Select a DBF File"
            action browsefordbf()
         end button
         define label dbfname
            row 85
            col 10
            width 150
            fontbold .t.
         end label
         define label dbfconnection
            row 110
            col 10
            width 150
            value "DBF is not yet connected"
            fontbold .t.
            fontcolor {255,0,0}
         end label
         define frame sqliteframe
            row 25
            col 185
            width 160
            caption 'Create/Select SQLite DB'
            height 110
         end frame
         define button createfile
            row 50
            col 190
            width 150
            caption 'Create New...'
            action createadb()
         end button      
         define button selectfile
            row 80
            col 190
            width 150
            caption 'Select Existing...'
            action selectdb()
         end button      
         define label connection
            row 110
            col 190
            width 150
            value "DB Not Yet Connected"
            fontbold .t.
            fontcolor {255,0,0}
         end label
         define button export
            row 140
            col 150
            width 50
            caption "Export"
            fontbold .t.
            action export2sql()
         end button
         define progressbar progress
            row 170
            col 10
            width 330
         end progressbar
         define label status
            row 200
            col 10
            width 200
            value ""
         end label
      end page
      define page 'SQLite -> DBF'
         define frame sqliteframe1
            row 25
            col 5
            width 160
            caption 'SQLite to be converted'
            height 110
         end frame
         define button browsesql1
            row 50
            col 10
            width 150
            caption "Select a SQLite DB"
            action browseforsqlite()
         end button
         define label tableslabel
            row 85
            col 10
            width 50
            value 'Table'
         end label
         define combobox tables
            row 80
            col 60
            width 100
            sort .t.
         end combobox
         define label sqlconnection1
            row 110
            col 10
            width 150
            value "DB is not yet connected"
            fontbold .t.
            fontcolor {255,0,0}
         end label
         define frame dbfframe1
            row 25
            col 185
            width 160
            caption 'Enter Table Name'
            height 110
         end frame
         define button newtable
            row 50
            col 190
            width 150
            action createnewdbf()
            caption 'Save to...'
         end button
         define label newtablename
            row 85
            col 190
            width 150
            value ''
            fontbold .t.
         end label
         define button export1
            row 140
            col 150
            width 50
            caption "Export"
            fontbold .t.
            action export2dbf()
         end button
         define progressbar progress1
            row 170
            col 10
            width 330
         end progressbar
         define label status1
            row 200
            col 10
            width 200
            value ""
         end label
      end page
   end tab   
end window
on key ESCAPE of sql action sql.release()
sql.progress.visible := .f.
sql.status.visible := .f.
sql.center
sql.activate
Return nil

function browsefordbf
local fname := sql.dbfname.value
local structarr := {}
local i := 0
local nDot := 0
local nSlash := 0
fname := GetFile( { { "DBF Files", "*.dbf" } }, "Select a dbf file" , , .f., .f. )
sql.dbfname.value := alltrim(fname)
if len(alltrim(fname)) > 0
   cTableName := fname
   nSlash := rat( '\', cTableName )
   if nSlash > 0
      cTableName := substr( cTableName, nSlash + 1 )
   endif
   nDot := at( '.', cTableName )
   if nDot > 0
      cTableName := substr( cTableName, 1, nDot - 1 )
   endif
   if file(fname)
      use &fname
      if used()
         lOpened := .t.
         sql.dbfconnection.value := alltrim( cTableName ) + ' is Connected'
         sql.dbfconnection.fontcolor := { 0, 98, 0 }
      else
         lOpened := .f.
         sql.dbfconnection.value := 'DBF is not yet connected'
         sql.dbfconnection.fontcolor := { 255, 0, 0 }
      endif      
   else
      lOpened := .f.
   endif
endif
return nil      

Function export2sql()
   local aStruct := {}, cSql, i, mFldNm, mFldtype, mFldLen, mFldDec, mSql
   local totrec, nrec, nvalues, count1
   
   if oDB == nil
      msgstop( "No Connection to SQLite DB! Try to create a new SQLite DB or select an existing SQLite DB", 'DBF->SQLite Exporter' )
      return nil
   endif
      
   do while .not. lOpened
      if msgyesno("You had not selected a DBF table. Do you want to do now?")
         browsefordbf()
      else
         return nil
      endif
   enddo

   && for i := 1 to sql.tables.itemcount
      && if upper(alltrim(sql.tables.item(i))) == upper(alltrim(cTablename))
         && msgstop("Destination table already exists. Either you can give a new name or select an existing table from the list","DBF2MySQL")
         && sql.newtable.setfocus()
         && return nil
      && endif
   && next i

   aStruct = DbStruct()

   mSql := "CREATE TABLE IF NOT EXISTS "+cTablename+" ("

   for i := 1 to len(aStruct)
      mFldNm := aStruct[i, DBS_NAME]
      mFldType := aStruct[i, DBS_TYPE]
      mFldLen := aStruct[i, DBS_LEN]
      mFldDec := aStruct[i, DBS_DEC]

      if i > 1
         mSql += ", "
      endif
      mSql += alltrim(mFldnm)+" "

      do case
      case mFldType = "C"
         mSql += "CHAR("+LTRIM(STR(mFldLen))+")"
      case mFldType = "D"
         mSql += "DATE"
      case mFldType = "T"
         mSql += "DATETIME"
      case mFldType = "N"
         if mFldDec > 0
            mSql += "FLOAT"
         else
            mSql += "INTEGER"
         endif
      case mFldType = "F"
         mSql += "FLOAT"
      case mFldType = "I"
         mSql += "INTEGER"
      case mFldType = "B"
         mSql += "DOUBLE"
      case mFldType = "Y"
         mSql += "FLOAT"
      case mFldType = "L"
         mSql += "BOOL"
      case mFldType = "M"
         mSql += "TEXT"
      case mFldType = "G"
         mSql += "BLOB"
      otherwise
         msginfo("Invalid Field Type: "+mFldType)
         return nil
      endcase
   next

   mSql += ")"

   //msginfo(mSql)

   if !miscsql( oDB, mSql )
      msginfo( 'Table Creation Error!', 'DBF2SQLite' )
      return nil
   endif

   sql.progress.value := 0
   sql.progress.visible := .t.
   sql.status.value := ""
   sql.status.visible := .t.
   totrec := reccount()
   nrec := 1
   go top
   if !miscsql( oDB, 'begin transaction' )
      return nil
   endif
   do while !eof()
      sql.progress.value := nrec/totrec *100
      sql.status.value := alltrim(str(nrec))+" of "+alltrim(str(totrec))+" Records processed."

      mSql := "INSERT INTO "+cTablename+" VALUES "
      msql := msql + "("
      for i := 1 to len(aStruct)
         mFldNm := aStruct[i, DBS_NAME]
         if i > 1
            mSql += ", "
         endif
         mSql += c2sql(&mFldNm)
      next
      mSql += ")"
      if !miscsql( oDB, mSql)
      	msgbox("Problem in Query: "+mSql)
         return nil
      endif
      nrec := nrec + 1
      skip
   enddo
   if !miscsql( oDB, 'end transaction' )
      return nil
   endif
   sql.status.value := ""
   sql.progress.value := 0
   sql.progress.visible := .f.
   sql.status.visible := .f.
   msginfo("Successfully exported")   
   close all
   lOpened := .f.
   sql.dbfname.value := ''
   sql.dbfconnection.value := "DBF is not yet Connected"
   sql.dbfconnection.fontcolor := { 255, 0, 0 }
return nil

function selectdb
   local cFileName := ''
   local cDBName := ''
   local nSlash := 0
   local nDot := 0
   cFileName := GetFile ( { { 'SQLite Files', '*.sqlite' }, { 'All Files', '*.*' } }, 'Select an Existing SQLite File' )
   if len( alltrim( cFileName ) ) > 0
      cDBName := cFileName
      nSlash := rat( '\', cDBName )
      if nSlash > 0
         cDBName := substr( cDBName, nSlash + 1 )
      endif
      nDot := at( '.', cDBName )
      if nDot > 0
         cDBName := substr( cDBName, 1, nDot - 1 )
      endif
      oDB := Connect2DB( cFileName, .f. )
      if oDB == Nil
         msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
         sql.connection.value := "DB Not Connected"
         sql.connection.fontcolor := { 255, 0, 0 }
         return nil
      else
         sql.connection.value := alltrim( cDBName ) + " is Connected!"
         sql.connection.fontcolor := { 0, 98, 0 }
      endif
   else
      msgstop( 'You have to select a SQLite File!', 'DBF2SQLite Exporter' )
      return nil
   endif   
return nil

function createadb
   local cFileName := ''
   local cDBName := ''
   local nSlash := 0
   local nDot := 0
   cFileName := PutFile ( { { 'SQLite Files', '*.sqlite' }, { 'All Files', '*.*' } }, 'Create a SQLite File' )
   if len( alltrim( cFileName ) ) == 0
      msgstop( 'File name can not be empty!', 'DBF2SQLite Exporter' )
      return nil
   endif   
   if at( '.', cFileName ) == 0
      cFileName := cFileName + '.sqlite'
   endif
   cDBName := cFileName
   nSlash := rat( '\', cDBName )
   if nSlash > 0
      cDBName := substr( cDBName, nSlash + 1 )
   endif
   nDot := at( '.', cDBName )
   if nDot > 0
      cDBName := substr( cDBName, 1, nDot - 1 )
   endif
   oDB := Connect2DB( cFileName, .t. )
   if oDB == Nil
      msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
      sql.connection.value := "DB Not Connected"
      sql.connection.fontcolor := { 255, 0, 0 }
      return nil
   else
      sql.connection.value := cDBName + " is Connected!"
      sql.connection.fontcolor := { 0, 98, 0 }
   endif
return nil

#include <sqlite2dbf.prg>
