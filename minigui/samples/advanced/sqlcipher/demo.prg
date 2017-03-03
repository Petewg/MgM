#include <hmg.ch>

Function Main
   local oDB := nil
   local cKey := 'password123'
   local cFile := 'sample.sqlite'
   local aTable := {}
   local nRecs, cName, cCity
   
   if file( cFile )
      oDB := connect2db( 'sample.sqlite', .f. )
      if oDB == Nil
         msgstop( 'Database File can not be connected' )
      else
         msginfo( iif( miscsql( oDB, 'pragma key = ' + c2sql( cKey ) ), 'Encryption Key is set', 'Encryption key can not be set' ) )
         
         aTable := sql( oDB, 'select name, city from master' )
         nRecs := len( aTable )
         
         cName := "Name" + hb_ntos( nRecs + 1)
         cCity := "City" + hb_ntos( nRecs + 1)
         
         miscsql( oDB, 'insert into master ( name, city ) ' + ;
                          'values ( ' + c2sql( cName ) + ', ' + c2sql( cCity ) + ' )' )
         
         if (nRecs := len( aTable )) > 0
         
                          
            msginfo( "records in table <master>: " + hb_ntos(nRecs) + hb_eol() + ;
                     'Name: ' + aTable[ nRecs, 1 ] + hb_eol() + ;
                     'City: ' + aTable[ nRecs, 2 ] )

         endif   
      endif   
   else
      oDB := connect2db( 'sample.sqlite', .t. )
      if oDB == Nil
         msgstop( 'Database File can not be connected' )
      else
         msginfo( iif( miscsql( oDB, 'pragma key = ' + c2sql( cKey ) ), 'Encryption Key is set', 'Encryption key can not be set!' ) )
         msginfo( iif( miscsql( oDB, 'create table master (name, city)' ), 'Master table is created successfully!', 'Table can not be created!' ) )
         msginfo( iif( miscsql( oDB, 'insert into master ( name, city ) values ( ' + c2sql( 'Name1' ) + ', ' + c2sql( 'City1' ) + ' )' ), 'Sample Data updated', 'sample data can not be updated!' ) )
      endif
   endif      
Return nil
