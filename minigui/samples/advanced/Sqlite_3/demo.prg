/*
 * demo.prg
 *
 * This file is part of "SQLite3Facade for Harbour".
 *
 * This work is licensed under the Creative Commons Attribution 3.0 
 * Unported License. To view a copy of this license, visit 
 * http://creativecommons.org/licenses/by/3.0/ or send a letter to 
 * Creative Commons, 444 Castro Street, Suite 900, Mountain View, 
 * California, 94041, USA.
 *
 * Copyright (c) 2010, Daniel Goncalves <daniel-at-base4-com-br>
 */
 
#include "error.ch"

FUNCTION Main()
   LOCAL aTemp
   
   ERRORBLOCK( { |_e| SQLiteFacadeErrorHandler(_e) } )
   
   //
   // ---- run test functions ----
   //
   CreateDatabaseTest()
   CreateTableTest()
   
   // the following and next test are related to each other
   aTemp := CreateAndPopulateTableTest() // expected an array of 3 elements
   // this test is based on the table populated in previous test
   QueryTest( aTemp[1], aTemp[2], aTemp[3] )
   
   DataTypeTest()
   
   //
   // ---- tests passed ----
   //
   
   SetTestsPassed()

   ?""
   WAIT
   
   RETURN ( 0 )
   
// ///////////////////////////////////////////////////////////////////////////
//
//    tests functions
//
// ///////////////////////////////////////////////////////////////////////////
   
STATIC FUNCTION CreateDatabaseTest()
   LOCAL db := SQLiteFacade():new( "test.db" )
   ? "Creating a database... "
   db:open()
   db:close()
   IF ( !FILE( "test.db" ) )
      ForceFail()
   ENDIF
   ?? "OK" ; ?
   RETURN ( NIL )
   
STATIC FUNCTION CreateTableTest()
   LOCAL db := SQLiteFacade():new( "test.db" )
   LOCAL stmt
   db:open()
   
   ? "Creating a table... "
   
   // create a simple table
   stmt := db:prepare( "CREATE TABLE IF NOT EXISTS people " + ;
                       "  (name TEXT, age INTEGER);" )
   IF !( stmt:executeUpdate() == 0 )
      ForceFail( "Creating a table isn't expected to affect rows" )
   ENDIF
   stmt:close()
   
   ?? "OK" ; ?
   
   ? "Dropping that table... "
   
   // drop created table
   stmt := db:prepare( "DROP TABLE people;" )
   IF !( stmt:executeUpdate() == 0 )
      ForceFail( "Dropping a table isn't expected to affect rows" )
   ENDIF
   stmt:close()
   
   ?? "OK" ; ?
   
   db:close()
   RETURN ( NIL )
   
STATIC FUNCTION CreateAndPopulateTableTest()
   LOCAL db := SQLiteFacade():new( "test.db" )
   LOCAL stmt
   
   LOCAL nRecord
   LOCAL aFirstNames, nFName
   LOCAL aMidNames, nMName
   LOCAL aSurNames, nSName
   LOCAL cName, nAge
   LOCAL nChanges
   
   LOCAL nTotalRecords := 0
   LOCAL nSumOfAges := 0
   LOCAL nSumOfAgesBetween40n50 := 0
   
   db:open()
   
   // create test table
   stmt := db:prepare( "CREATE TABLE IF NOT EXISTS people " + ;
                       "  (name TEXT, age INTEGER);" )
   stmt:executeUpdate()
   stmt:close()
   
   // populate table with random compounded names
   aFirstNames := { "John", "Mike", "Willian", "Richard" }
   aMidNames := { "Hammer", "Pliers", "Screw", "Bolt" }
   aSurNames := { "Strawberry", "Water", "Coffee", "Pineapple", "Crookie" }
   
   stmt := db:prepare( "INSERT INTO people (name,age) VALUES (:name,:age);" )
   
   ? "Populating table"
   
   FOR nRecord := 1 TO 100
   
      // expect these INSERT operations to be very slow;
      // for details, take a look at SQLite FAQ, question 19:
      // "INSERT is really slow - I can only do few dozen INSERTs per second" 
      // [http://www.sqlite.org/faq.html#q19]
   
      nFName := HB_RandomInt( 1, LEN( aFirstNames ) )
      nMName := HB_RandomInt( 1, LEN( aMidNames ) )
      nSName := HB_RandomInt( 1, LEN( aSurNames ) )
      
      cName := aFirstNames[ nFName ] + " " + ;
               aMidNames[ nMName ]   + " " + ;
               aSurNames[ nSName ]
               
      nAge := HB_RandomInt( 1, 95 )
      
      stmt:setString( ":name", cName )
      stmt:setInteger( ":age", nAge )
      
      IF .NOT. ( ( nChanges := stmt:executeUpdate() ) == 1 )
         ForceFail( "Update should change 1 row, but changed " + ;
            ALLTRIM( STR( nChanges ) ) )
      ENDIF
      
      nTotalRecords++
      nSumOfAges += nAge
      
      IF ( ( nAge >= 40 ) .AND. ( nAge <= 50 ) )
         nSumOfAgesBetween40n50 += nAge
      ENDIF
      
      // reuse same compiled SQL and clear bindings to host params
      stmt:reuse():clear()
      
      IF ( ( nTotalRecords % 10 ) == 0 )
         ?? "."
      ENDIF
      
   NEXT
   
   ?? " OK (" + ALLTRIM( STR( nTotalRecords ) ) + " records)" ; ?
   
   stmt:close()
   db:close()
   
   RETURN ( { nTotalRecords, nSumOfAges, nSumOfAgesBetween40n50 } )
   
STATIC FUNCTION QueryTest( nTotalRecords, nSumOfAges, nSumOfAgesBetween40n50 )
   LOCAL db := SQLiteFacade():new( "test.db" )
   LOCAL stmt
   LOCAL rs
   LOCAL nRecords
   LOCAL nAge
   LOCAL n__SumOfAges
   
   db:open()
   
   ? "Querying previous inserts... "
   
   // calculate (record-by-record) the sum of ages for all records
   stmt := db:prepare( "SELECT * FROM people;" )
   rs := stmt:executeQuery()
   
   nRecords := 0
   n__SumOfAges := 0
   
   WHILE ( rs:next() )
      nAge := rs:getInteger( "age" )
      n__SumOfAges += nAge
      nRecords++
   END
   
   stmt:close()
   
   IF ( nRecords != nTotalRecords )
      ForceFail( "Expected " + ALLTRIM( STR( nTotalRecords ) ) + ;
                 "record(s); got " + ALLTRIM( STR( nRecords ) ) + " record(s)" )
   ENDIF
   
   IF ( n__SumOfAges != nSumOfAges )
      ForceFail( "Sum of ages is " + ALLTRIM( STR( n__SumOfAges ) ) + ;
                 "; expected to be " + ALLTRIM( STR( nSumOfAges ) ) )
   ENDIF
   
   ?? "OK" ; ?
   
   ? "Querying again... "
   
   // calculate (record-by-record) the sum of ages for records whose
   // ages lies in between 40 and 50 years
   stmt := db:prepare( "SELECT * FROM people WHERE age BETWEEN 40 AND 50;" )
   rs := stmt:executeQuery()
   
   n__SumOfAges := 0
   
   WHILE ( rs:next() )
      nAge := rs:getInteger( "age" )
      n__SumOfAges += nAge
   END
   
   stmt:close()
   
   IF ( n__SumOfAges != nSumOfAgesBetween40n50 )
      ForceFail( "Sum of ages is " + ALLTRIM( STR( n__SumOfAges ) ) + ;
                 " (for people between 40 and 50 years);" + ;
                 " expected to be " + ALLTRIM( STR( nSumOfAgesBetween40n50 ) ) )
   ENDIF
   
   ?? "OK" ; ?
   
   db:close()
   
   RETURN ( NIL )
   
STATIC FUNCTION DataTypeTest()
   LOCAL db := SQLiteFacade():new( "test.db" )
   LOCAL stmt
   LOCAL rs
   LOCAL nRecord
   LOCAL aMyData
   LOCAL wMyText
   LOCAL wMyInt
   LOCAL wMyFloat
   LOCAL wMyDate
   LOCAL wMyBool
   
   aMyData := { { "ABCD", 1973, 3.14159265, HB_STOD( "19800726" ), .T. }, ;
                { "FGHI", 1980, 3.14159265, HB_STOD( "19730927" ), .F. } }
   
   ? "Testing data types... "
                
   db:open()
   
   // create a test table
   stmt := db:prepare( "CREATE TABLE IF NOT EXISTS mixed" + ;
                       "   (mytext TEXT, myint INTEGER, " + ;
                       "    myfloat FLOAT, mydate TEXT, mybool TEXT);" )
   stmt:executeUpdate()
   stmt:close()
   
   // ensure table has no records
   stmt := db:prepare( "DELETE FROM mixed;" )
   stmt:executeUpdate()
   stmt:close()
   
   // insert two records
   stmt := db:prepare( "INSERT INTO mixed (mytext,myint,myfloat,mydate,mybool)" + ;
                       "VALUES (:mytext,:myint,:myfloat,:mydate,:mybool);" )
                       
   stmt:setString( ":mytext", aMyData[1][1] )
   stmt:setInteger( ":myint", aMyData[1][2] )
   stmt:setFloat( ":myfloat", aMyData[1][3] )
   stmt:setDate( ":mydate", aMyData[1][4] )
   stmt:setBoolean( ":mybool", aMyData[1][5] )
   stmt:executeUpdate()
   
   ? "   Inserted record OK"
   
   stmt:reuse():clear()
   stmt:setString( ":mytext", aMyData[2][1] )
   stmt:setInteger( ":myint", aMyData[2][2] )
   stmt:setFloat( ":myfloat", aMyData[2][3] )
   stmt:setString( ":mydate", "1973/9-27" ) // NOTE!!
   stmt:setBoolean( ":mybool", aMyData[2][5] )
   stmt:executeUpdate()
   
   ? "   Inserted record OK"
   
   stmt:close()
   
   ? "   Retrieving records..."
   
   // retrieve those records and check it's values
   stmt := db:prepare( "SELECT * FROM mixed;" )
   rs := stmt:executeQuery()
   
   nRecord := 0
   
   WHILE ( rs:next() )
      nRecord++ // rough but works!
      
      ? "   Testing data type for record " + ALLTRIM( STR( nRecord ) ) + "... "
      
      wMyText  := rs:getString( "mytext" )
      wMyInt   := rs:getInteger( "myint" )
      wMyFloat := rs:getFloat( "myfloat" )
      wMyDate  := rs:getDate( "mydate" )
      wMyBool  := rs:getBoolean( "mybool" )
      
      IF !( wMyText == aMyData[ nRecord ][ 1 ] )
         ForceFail( 'TEXT type: expected "' + ;
            aMyData[ nRecord ][ 1 ] + '", got "' + wMyText + '"' + ;
            " (record " + ALLTRIM( STR( nRecord ) ) + ")" )
      ENDIF
      
      IF !( wMyInt == aMyData[ nRecord ][ 2 ] )
         ForceFail( 'INTEGER type: expected ' + ;
            ALLTRIM( STR( aMyData[ nRecord ][ 2 ] ) ) + '", got ' + ;
            ALLTRIM( STR( wMyInt ) ) + ;
            " (record " + ALLTRIM( STR( nRecord ) ) + ")" )
      ENDIF
      
      IF !( wMyFloat == aMyData[ nRecord ][ 3 ] )
         ForceFail( 'FLOAT type: expected ' + ;
            ALLTRIM( STR( aMyData[ nRecord ][ 3 ] ) ) + ', got ' + ;
            ALLTRIM( STR( wMyFloat ) ) + ;
            " (record " + ALLTRIM( STR( nRecord ) ) + ")" )
      ENDIF
      
      IF !( wMyDate == aMyData[ nRecord ][ 4 ] )
         ForceFail( 'DATE(Facade) type: expected ' + ;
            DTOS( aMyData[ nRecord ][ 4 ] ) + ', got ' + ;
            DTOS( wMyDate ) + " (record " + ALLTRIM( STR( nRecord ) ) + ")" )
      ENDIF
      
      IF !( wMyBool == aMyData[ nRecord ][ 5 ] )
         ForceFail( 'BOOL(Facade) type: expected "' + ;
            ALLTRIM( HB_CSTR( aMyData[ nRecord ][ 5 ] ) ) + '", got "' + ;
            ALLTRIM( HB_CSTR( wMyBool ) ) + ;
            " (record " + ALLTRIM( STR( nRecord ) ) + ")" )
      ENDIF
      
      ?? "OK" ; ?
      
   END
   
   stmt:close()
   rs:close()
   db:close()
   
   ? "   Data types OK"
   
   RETURN ( NIL )
   
// ///////////////////////////////////////////////////////////////////////////
//
//    support functions
//
// ///////////////////////////////////////////////////////////////////////////
   
STATIC FUNCTION ForceFail( cDescription )
   LOCAL oError := ErrorNew()
   oError:severity := ES_ERROR
   oError:subcode := 0
   oError:subsystem := "SQLiteFacadeTests"
   //oError:modulename := PROCFILE( 1 )
   //oError:procname := PROCNAME( 1 )
   //oError:procline := PROCLINE( 1 )
   oError:candefault := .F.
   oError:cansubstitute := .F.
   oError:canretry := .F.
   oError:operation := HB_METHODNAME( 1 ) + " (" + ;
                       ALLTRIM( STR( PROCLINE( 1 ) ) ) + ") " + ;
                       PROCFILE( 1 )
   oError:description := "Tests Failed"
   IF ( HB_IsString( cDescription ) )
      oError:description := cDescription
   ENDIF
   ERRORBLOCK():eval( oError )
   RETURN ( NIL )
   
STATIC FUNCTION SetTestsPassed()
   LOCAL cBuffer := "Tests PASSED @ " + DTOC( DATE() ) + " " + TIME()
   MEMOWRIT( "RESULTS.PASSED", cBuffer )
   RETURN ( NIL )

STATIC FUNCTION SQLiteFacadeErrorHandler( oError )
   LOCAL cBuffer
   LOCAL nDeep
   LOCAL cCaller
   LOCAL nParam
   LOCAL wuParam
   
   cBuffer := "Tests FAILED @ " + DTOC( DATE() ) + " " + TIME() + ;
              HB_OsNewLine()
   
   cBuffer += "ERROR: " + oError:description + ;
              IIF( EMPTY( oError:operation ), "", ;
              HB_OsNewLine() + oError:operation ) + ;
              HB_OsNewLine()
              
   cBuffer += oError:subsystem + "/" + ALLTRIM( STR( oError:subcode ) ) + ;
              " (generic code " + ALLTRIM( STR( oError:genCode ) ) + ;
              ", os code " + ALLTRIM( STR( oError:osCode ) ) + ")" + ;
              HB_OsNewLine()
   
   FOR nDeep := 2 TO 5000
      IF ( EMPTY( cCaller := HB_METHODNAME( nDeep ) ) )
         EXIT
      ENDIF
      cBuffer += "   at " + cCaller + ;
                 " (" + ALLTRIM( STR( PROCLINE( nDeep ) ) ) + ")" + ;
                 HB_OsNewLine()
   NEXT
   
   IF ( HB_IsArray( oError:args ) )
      cBuffer += HB_OsNewLine() + "---- Parameters ----" + ;
                 HB_OsNewLine()
                 
      FOR nParam := 1 TO LEN( oError:args )
          wuParam := oError:args[ nParam ]
          cBuffer += "   " + ALLTRIM( STR( nParam ) ) + ': "' + ;
                     VALTYPE( wuParam ) + '": ' + HB_CStr( wuParam ) + ;
                     HB_OsNewLine()
      NEXT
   ENDIF                     
   
   MEMOWRIT( "RESULTS.ERRORS", cBuffer )
   QUIT
   
   RETURN ( NIL )
   
