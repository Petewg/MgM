#include <minigui.ch>

//declare window sql

function browseforsqlite
   local cFileName := ''
   local cDBName := ''
   local nSlash := 0
   local nDot := 0
   local aTable := {}
   local i
   sql.tables.deleteallitems()
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
      oDB1 := Connect2DB( cFileName, .f. )
      if oDB1 == Nil
         msgstop( 'Not a valid SQLite file.', 'SQLite File Selection' )
         sql.sqlconnection1.value := "DB Not Connected"
         sql.sqlconnection1.fontcolor := { 255, 0, 0 }
         return nil
      else
         sql.sqlconnection1.value := alltrim( cDBName ) + " is Connected!"
         sql.sqlconnection1.fontcolor := { 0, 98, 0 }
         aTable := sql( oDB1, "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name" )
         if len( aTable ) == 0
            msgstop( 'No Tables in the DB', 'DBF<-->SQLite Exporter' )
            return nil
         endif
         for i := 1 to len( aTable )
            sql.tables.additem( aTable[ i, 1 ] ) 
         next i
         sql.tables.value := 1
      endif
   else
      msgstop( 'You have to select a SQLite File!', 'DBF<-->SQLite Exporter' )
      return nil
   endif   

return nil

function createnewdbf
   local cFileName := ''
   local cDBName := ''
   local nSlash := 0
   local nDot := 0
   cFileName := PutFile ( { { 'DBF Files', '*.dbf' }, { 'All Files', '*.*' } }, 'Save to DBF File' )
   if len( alltrim( cFileName ) ) == 0
      msgstop( 'File name can not be empty!', 'DBF<-->SQLite Exporter' )
      return nil
   endif   
   if at( '.', cFileName ) == 0
      cFileName := cFileName + '.dbf'
   endif
   cDBName := cFileName
   cNewTable := cFileName
   nSlash := rat( '\', cDBName )
   if nSlash > 0
      cDBName := substr( cDBName, nSlash + 1 )
   endif
   nDot := at( '.', cDBName )
   if nDot > 0
      cDBName := substr( cDBName, 1, nDot - 1 )
   endif
   if file ( cNewTable )
      if .not. msgyesno( 'File already exists! Do you want to overwrite?', 'DBF<-->SQLite Exporter' )
         sql.newtablename.value := ''
         cNewTable := ''
         return nil
      endif
   endif
   sql.newtablename.value := 'Save Table to ' + cDBName
return nil

function export2dbf
   local aTable := {}
   local aTable1 := {}
   local cSQLTable := {}
   local aStruct := {}
   local cType := ''
   local cFieldName := ''
   local cFieldType := ''
   local nFieldLength := ''
   local nFieldDec := ''
   local nLength := 0
   local aRecord := {}
   local nTotalRows := 0
   local i, j
   if len( alltrim( cNewTable ) ) == 0
      msgstop( 'You have to select a DBF to export', 'DBF<-->SQLite Exporter' )
      return nil
   endif
   if sql.tables.value > 0
      cSQLTable := sql.tables.item( sql.tables.value )
      aTable := sql( oDB1, 'PRAGMA table_info( ' + c2sql( cSQLTable ) + ')' )
      if len( aTable ) == 0
         msgstop( 'This is an empty table!' ) 
         return nil
      endif
      for i := 1 to len( aTable )
         cType := upper( alltrim( aTable[ i, 3 ] ) ) 
         cFieldName := alltrim( aTable[ i, 2 ] )
         do case
         case cType == "INTEGER" 
            cFieldType := 'N'
            nFieldLength := 8
            nFieldDec := 0
         case cType == "REAL" .or. cType == "FLOAT" .or. cType == "DOUBLE"
            cFieldType := 'N'
            nFieldLength := 14
            nFieldDec := 5
         case cType == "DATE" .or. cType == 'DATETIME'
            cFieldType := 'D'
            nFieldLength := 8
            nFieldDec := 0
         case cType == "BOOL"
            cFieldType := 'L'
            nFieldLength := 1
            nFieldDec := 0
         otherwise
            cFieldType := 'C'
            nFieldDec := 0
            aTable1 := sql( oDB1, 'select max( length( ' + cFieldName + ' ) ) from ' + c2sql( cSQLTable ) )
            nLength := 0
            if len( aTable1 ) > 0
               nLength := val( alltrim( aTable1[ 1, 1 ] ) )
            endif
            do case
            case nLength == 0
               nFieldLength := 10
            case nLength < 256
               nFieldLength := nLength
            otherwise
               nFieldLength := 10
               cFieldType := 'M'
            endcase
         endcase
         aadd( aStruct, { cFieldName, cFieldType, nFieldLength, nFieldDec } )
      next i
      if len( aStruct ) > 0
         dbcreate( cNewTable, aStruct )
         use &cNewTable
         if .not. used()
            msgstop( 'DBF File Creation error!', 'DBF<-->SQLite Exporter' )
            return nil
         endif
         aTable := sql( oDB1, 'select * from ' + c2sql( cSQLTable ) )
         sql.progress1.value := 0
         sql.progress1.visible := .t.
         sql.status1.value := ""
         sql.status1.visible := .t.
         nTotalRows := len( aTable )
         for i := 1 to nTotalRows
            sql.progress1.value := i / nTotalRows * 100
            sql.status1.value := alltrim( str( i ) ) + " of " + alltrim( str( nTotalRows ) ) + " Records processed."
            append blank
            aRecord := aTable[ i ]
            for j := 1 to len( aRecord )
               cFieldName := Left( aStruct[ j, 1 ], 10 )
               replace &cFieldName with aRecord[ j ]
            next j
         next i
         commit
         sql.status1.value := ""
         sql.progress1.value := 0
         sql.progress1.visible := .f.
         sql.status1.visible := .f.
         msginfo("Successfully exported")   
         close all
         sql.newtablename.value := ''
         cNewTable := ''
      endif
   else
      msgstop( 'You have to select a Table to export!', 'DBF<-->SQLite Exporter' )
      return nil
   endif
return nil
