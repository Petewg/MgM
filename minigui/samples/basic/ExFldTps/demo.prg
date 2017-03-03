/*
  Harbour extended Field Types 

  Type Short
  Code Name     Width (Bytes)     Description
  ---- -------  ----------------- -------------------------------------------------------------------
   D   Date     3, 4 or 8          Date
   M   Memo     4 or 8             Memo
   +   AutoInc  4                  Auto increment
   =   ModTime  8                  Last modified date & time of this record
   ^   RowVers  8                  Row version number; modification count of this record
   @   DayTime  8                  Date & Time
   I   Integer  1, 2, 3, 4 or 8    Signed Integer ( Width :  )" },;
   T   Time     4 or 8             Only time (if width is 4 ) or Date & Time (if width is 8 ) (?)
   V   Variant  3, 4, 6 or more    Variable type Field
   Y   Currency 8                  64 bit integer with implied 4 decimal
   B   Double   8                  Floating point / 64 bit binary

  Program : ExFldTps.prg
  Author : Bicahi Esgici ( esgici <at> gmail.com )

  All rights reserved.

  2011.10.12

  A warn :  While running, this program produce some .dbf and .txt file(s) and don't erase its upon close. 
            This is because you may want inspect its. 
            You may erase these files arbitrarily.
*/

PROCEDURE Main()

   LOCAL aOperations := { { "Width",            "Testing Field Widths" }, ;
                          { "Numeric Limits",   "Determining Numeric Limits" }, ;
                          { "Integer Limits",   "Determining Integer Limits" }, ;
                          { "Set/Get",          "Set & read back field values" }, ;
                          { "Conversion",       "Convert and test signed to integer" } }, ;
      a1Oper := {}, ;
      n1Oper := 1

   LOCAL aFldTypes := { { "D", "Date",     "Date ( Width : 3, 4 or 8 )" },;
                        { "M", "Memo",     "Memo ( Width : 4 or 8 )" }, ;
                        { "+", "AutoInc",  "Auto increment ( Width : 4 )" }, ;
                        { "=", "ModTime",  "Last modified date & time of this record ( Width : 8 )" }, ;
                        { "^", "RowVers",  "Row version number; modification count of this record ( Width : 8 )" }, ;
                        { "@", "DayTime",  "Date & Time ( Width : 8 )" }, ;
                        { "I", "Integer",  "Signed Integer ( Width : 1, 2, 3, 4 or 8 )" }, ;
                        { "T", "Time",     "Only time (if width is 4 ) or Date & Time (if width is 8 )" }, ;
                        { "V", "Variant",  "Variable type (!) Field ( Width : 3, 4, 6 or more)" }, ;
                        { "Y", "Currency", "Integer 64 bit with implied 4 decimal" }, ;
                        { "B", "Double",   "Floating point / 64 bit binary ( Width : 8 )" } }, ;
      a1Type := {}, ;
      n1Type := 1, ;
      n2Type := 1

   LOCAL nMColumn :=  0, ;    // Menu Column No
      nMRow    :=  0          // Menu Row No

   SET WRAP ON
   SET MESSAGE TO 58 CENTER
   SET CENTURY ON

   * In screen resolution 1440 * 900  SetMode( 60, 150 ) seem good. 
   * In this case value of SET MESSAGE TO will be 58 ( less 2 than nRow specified in SetMod() ).  

   SetMode( 60, 150 )            


   WHILE n1Oper > 0

      CLS

      nMSutn := 0

      FOR EACH a1Oper IN aOperations
         @ 0, nMSutn PROMPT a1Oper[ 1 ] MESSAGE a1Oper[ 2 ]
         nMSutn += Len( a1Oper[ 1 ] ) + 1
      NEXT

      MENU TO n1Oper

      SWITCH n1Oper

      CASE 0
         EXIT

      CASE 1  // Testing Field Widths
         n1Type := 1
         WHILE n1Type > 0

            @ 1, 0 CLEAR TO 24, 80
            nMRow  := 2
            FOR EACH a1Type IN aFldTypes
               @ nMRow++, 0 PROMPT a1Type[ 2 ] MESSAGE a1Type[ 3 ]
            NEXT a1Type

            MENU TO n1Type

            IF n1Type > 0
               @ 1, 0 CLEAR TO 24, 80
               @ 1, 0 SAY aFldTypes[ n1Type, 2 ]  COLOR "B/W"
               FT_Widths( aFldTypes[ n1Type ] )
            ENDIF

         ENDDO n1Type
         EXIT

      CASE 2  // Determining Numeric Limits
         NumLimits()
         EXIT

      CASE 3  // Determining Integer Limits
         IntLimits()
         EXIT

      CASE 4  // Set & read back field values
         n2Type := 1
         WHILE n2Type > 0

            @ 1, 0 CLEAR TO 24, 80
            nMRow  := 2
            FOR EACH a1Type IN aFldTypes
               @ nMRow++, 36 PROMPT a1Type[ 2 ] MESSAGE a1Type[ 3 ]
            NEXT

            MENU TO n2Type

            IF n2Type > 0
               V_SetGet( aFldTypes[ n2Type ] )
            ENDIF

         ENDDO n1Type
         EXIT

      CASE 5  // Convert and test signed to integer
         SignChng()
         EXIT

      END SWITCH

   ENDDO n1Oper

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE FT_Widths( a1Type )               // Testing Field Widths

   LOCAL cType  := a1Type[ 1 ], ;
      nFldNo := 0, ;
      aStru1 := {}, ;
      aStru2 := {}, ;
      aStru3 := { { 'FldType',     "C", 1, 0 }, ; // Type of field
                  { 'WidtSpec',    "N", 2, 0 }, ; // Specified width
                  { 'Dec_Spec',    "N", 2, 0 }, ; // Specified decimal
                  { 'WidtAppl',    "N", 2, 0 }, ; // Applied (by Harbour) width
                  { 'Dec_Max',     "N", 2, 0 }, ; // Computed maximum dec
                  { 'Result',      "C", 1, 0 } }

   FOR nFldNo := 1 TO 32
      AAdd( aStru1, { "X" + StrZero( nFldNo, 2 ), cType, nFldNo, 0 } )
   NEXT nFldNo

   dbCreate( "Widths", aStru1 )
   USE Widths

   aStru2 := dbStruct()

   IF cType $ "IYB"
      AEval( aStru2, {| a1, i1 | aStru2[ i1, 4 ] := aStru2[ i1, 3 ] - 1 } )
   ENDIF

   USE
   dbCreate( "Widths", aStru2 )
   USE Widths

   aStru2 := dbStruct()

   USE


   dbCreate( "Widths", aStru3 )

   USE Widths

   FOR nFldNo := 1 TO 32
      dbAppend()

      REPLACE FldType  WITH aStru1[ nFldNo, 2 ], ;
         WidtSpec WITH aStru1[ nFldNo, 3 ], ;
         Dec_Spec WITH aStru1[ nFldNo, 4 ], ;
         WidtAppl WITH aStru2[ nFldNo, 3 ], ;
         Dec_Max  WITH aStru2[ nFldNo, 4 ], ;
         Result   WITH IF( aStru1[ nFldNo, 3 ] # aStru2[ nFldNo, 3 ], "-", "+" )

   NEXT nFldNo

   dbGoTop()
   Browse()

   USE

RETURN // FT_Widths()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE NumLimits()                              // Determining Numeric Limits

   LOCAL mBayt  := 0, ;
      nBit   := 0, ;
      nExpo  := 0

   SET ALTE TO N_Limits
   SET ALTE ON

   ? Space( 9 ), "Unsigned ( Always + )"
   ? "-- ------ ---------------------------"

   FOR nBayt := 1 TO 8
      nBit   := nBayt * 8
      nExpo  := 2 ^ nBit
      ? Str( nBayt, 2 ), "2^" + PadL( nBit, 2 ) + " : ", Transform( nExpo, "99,999,999,999,999,999,999" )
   NEXT nBayt

   ?
   ?
   ? PadC( "Signed ( - / + )", 80 )
   ? "-- ------ -----------------------------------------------------"

   FOR nBayt := 1 TO 8
      nBit   := nBayt * 8
      nExpo  := 2 ^ nBit
      ? Str( nBayt, 2 ), "2^" + PadL( nBit, 2 ) + " : ", Transform( - nExpo / 2, "99,999,999,999,999,999,999" ) + ;
         ".." + ;
         LTrim( Transform( nExpo / 2 - 1, "99,999,999,999,999,999,999" ) )
   NEXT nBayt

   SET ALTE OFF
   SET ALTE TO

   MemoEdit( MemoRead( "N_Limits.TXT" ) )

RETURN // NumLimits()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE IntLimits()                             // Determining Integer Limits

   LOCAL nFldNo := 0, ;
      aStru4 := { { 'MNMX', "C", 7, 0 }, ;
                  { 'INT1', "I", 1, 0 }, ;
                  { 'INT2', "I", 2, 0 }, ;
                  { 'INT3', "I", 3, 0 }, ;
                  { 'INT4', "I", 4, 0 }, ;
                  { 'INT8', "I", 8, 0 } }

   dbCreate( "IntLimits", aStru4 )

   USE IntLimits

   dbAppend()
   REPLACE MNMX WITH "Minimum",;
      INT1 WITH  -2 ^ 7,;
      INT2 WITH  -2 ^ 15,;
      INT3 WITH  -2 ^ 23,;
      INT4 WITH  -2 ^ 31,;
      INT8 WITH  -2 ^ 63

   dbAppend()
   REPLACE MNMX WITH "Maximum",;
      INT1 WITH   2 ^ 7  - 1,;
      INT2 WITH   2 ^ 15 - 1,;
      INT3 WITH   2 ^ 23 - 1,;
      INT4 WITH   2 ^ 31 - 1,;
      INT8 WITH   2 ^ 63 - 513    // < 513 ---> "Error DBFNTX/1021 Data width error"

   dbGoTop()

   @ 1, 0 CLEAR TO 24, 80

   SET ALTE TO IntLimits
   SET ALTE ON

   WHILE !Eof()
      ?
      ? MNMX
      ? '--------'
      FOR nFldNo := 2 TO 6
         ? FieldName( nFldNo ), ": ", LTrim( Transform( FieldGet( nFldNo ), "99,999,999,999,999,999,999" ) )
      NEXT nFldNo
      ?
      SKIP
   ENDDO

   SET ALTE OFF
   SET ALTE TO

   MemoEdit( MemoRead( "IntLimits.txt" ) )

   USE

RETURN // IntLimits()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_NoType()                             // Testing NoType ( Variant ) field type

   LOCAL aStru5 := { { "Initial",    "C", 19, 0 }, ;
                     { "Internal",   "V", 19, 0 }, ;
                     { "ReadBack",   "C", 19, 0 }, ;
                     { "ReadBackTp", "C",  1, 0 } }

   dbCreate( "SG_NoType", aStru5 )

   USE SG_NoType

   dbAppend()
   REPLACE Initial  WITH "String", Internal WITH "String"
   dbAppend()
   REPLACE Initial  WITH "12345",  Internal WITH 12345
   dbAppend()
   REPLACE Initial  WITH DToC( Date() ), Internal WITH Date()
   dbAppend()
   REPLACE Initial  WITH ".T.", Internal WITH .T.

   REPLACE ALL ReadBack WITH hb_ValToStr( Internal ), ReadBackTp WITH ValType( Internal )

   dbGoTop()

   Browse()
   USE

RETURN // SG_NoType()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE V_SetGet( aType )               // Set & read back field values

   LOCAL cType := aType[ 1 ]

   @ 1, 0 CLEAR TO 24, 80

   SWITCH cType

   CASE "D" // Date
      SG_Date()
      EXIT

   CASE "M" // Memo
      SG_Memo()
      EXIT

   CASE "+" // AutoInc
      Alert( "Read Only" )
      EXIT

   CASE "=" // ModTime
      Alert( "Read Only" )
      EXIT

   CASE "^" // RowVers
      Alert( "Read Only" )
      EXIT

   CASE "@" // DayTime
      SG_DayTime()
      EXIT

   CASE "I" // Integer
      SG_Integers()
      EXIT

   CASE "T" // Time
      SG_DayTime()
      EXIT

   CASE "V" // Variant
      SG_NoType()
      EXIT

   CASE "Y" // Currency
      SG_Currency()
      EXIT

   CASE "B" // Double
      SG_Double()
      EXIT

   END SWITCH

RETURN // V_SetGet()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_Date()                           // Date : Compare set / get

   LOCAL aStru6 := { { "Initial",  "D",  8, 0 },;
                   { "Internal3",  "D",  3, 0 },;
                   { "Internal4",  "D",  4, 0 },;
                   { "Internal8",  "D",  8, 0 },;
                   { "ReadBack3",  "C", 12, 0 },;
                   { "ReadBack4",  "C", 12, 0 },;
                   { "ReadBack8",  "C", 12, 0 } }

   dbCreate( "SG_Date", aStru6 )

   USE SG_Date

   dbAppend()
   REPLACE Initial  WITH Date() - ( 66 * 365 + 66 / 4 ), ;
         Internal3  WITH Initial,;
         Internal4  WITH Initial,;
         Internal8  WITH Initial,;
         ReadBack3  WITH hb_ValToStr( Internal3 ),;
         ReadBack4  WITH hb_ValToStr( Internal4 ),;
         ReadBack8  WITH hb_ValToStr( Internal8 )
   dbGoTop()

   Browse()
   USE

RETURN // SG_Date()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_Memo()                       // Set / Get test for MEMO fields

   LOCAL aStru7 := { { "MEMO_4",   "M",  4, 0 },;
                     { "MEMO_10",  "M", 10, 0 } }

   dbCreate( "SG_Memo", aStru7 )

   USE SG_Memo

   dbAppend()
   REPLACE MEMO_4   WITH "MEMO field with width 4", ;
           MEMO_10  WITH "MEMO field with width 4"

   dbGoTop()

   Browse()
   USE

RETURN // SG_Date()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_DayTime()                       // Set / Get test for DayTime fields

   LOCAL aStru8 := { { "ModTim",   "=",  8, 0 },;
                     { "DaTime",   "@",  8, 0 },;
                     { "Time_8",   "T",  8, 0 },;
                     { "Time_4",   "T",  4, 0 },;
                     { "Time_C",   "C", 12, 0 } }

   dbCreate( "SG_Datime", aStru8 )

   USE SG_Datime

   dbAppend()

   //  REPLACE DaTime  WITH DATE()          //  ==> Error DBFNTX/1020 Data type error: DATIME
   //  REPLACE Time_4  WITH SECO() / TIME() //  ==> Error DBFNTX/1020 Data type error: DATIME

   //  REPLACE Time_8  WITH TIME()          //  ==> Error DBFNTX/1020 Data type error: TIME_8

   //  DBAPPEND()

   //  REPLACE DaTime  WITH ModTim          //  ==> 0000-00-00 00:00:00.000
   //  REPLACE Time_4  WITH ModTim          //  ==> Error DBFNTX/1020 Data type error: TIME_4
   //  REPLACE Time_8  WITH ModTim          //  ==> 0000-00-00 00:00:00.000

   REPLACE DaTime  WITH ModTim, ;    //  ==> > 0000-00-00 00:00:00.000
           Time_8  WITH ModTim, ;    //  ==> > 0000-00-00 00:00:00.000
           Time_C  WITH Time()

   dbGoTop()

   Browse()
   USE

RETURN // SG_DayTime()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_Integers()                       // Set / Get test for INTEGER fields

   LOCAL nRecno := 0, ;
      aStru9 := { { 'INT1',  "I", 1, 0 }, ;
                  { 'NUM1',  "N", 4, 0 }, ;
                  { 'EQL1',  "L", 1, 0 }, ;
                  { 'INT11', "I", 1, 1 }, ;
                  { 'NUM11', "N", 5, 1 }, ;
                  { 'EQL11', "L", 1, 0 }, ;
                  { 'INT2',  "I", 2, 0 }, ;
                  { 'NUM2',  "N", 8, 0 }, ;
                  { 'EQL2',  "L", 1, 0 }, ;
                  { 'INT22', "I", 8, 2 }, ;
                  { 'NUM22', "N", 12, 2 }, ;
                  { 'EQL22', "L", 1, 0 }, ;
                  { 'INT3',  "I", 3, 0 }, ;
                  { 'NUM3',  "N", 8, 0 }, ;
                  { 'EQL3',  "L", 1, 0 }, ;
                  { 'INT32', "I", 3, 2 }, ;
                  { 'NUM32', "N", 12, 2 }, ;
                  { 'EQL32', "L", 1, 0 }, ;
                  { 'INT4',  "I", 4, 0 }, ;
                  { 'NUM4',  "N", 12, 0 }, ;
                  { 'EQL4',  "L", 1, 0 }, ;
                  { 'INT42', "I", 4, 2 }, ;
                  { 'NUM42', "N", 14, 2 }, ;
                  { 'EQL42', "L", 1, 0 }, ;
                  { 'INT8',  "I", 8, 0 }, ;
                  { 'NUM8',  "N", 21, 0 }, ;
                  { 'EQL8',  "L", 1, 0 }, ;
                  { 'INT84', "I", 8, 4 }, ;
                  { 'NUM84', "N", 21, 4 }, ;
                  { 'EQL84', "L", 1, 0 } }

   dbCreate( "SG_Integers", aStru9 )
   USE SG_Integers

   FOR nRecno := 1 TO 18
      dbAppend()
   NEXT nRecno

   REPL ALL INT1  WITH Int( hb_Random( -2 ^ 7, 2 ^ 7  - 1   ) ),;
      INT11 WITH Int( hb_Random( -2 ^ 7, 2 ^ 7  - 1   ) ) / 10,;
      INT2  WITH Int( hb_Random( -2 ^ 15, 2 ^ 15 - 1   ) ),;
      INT22 WITH Int( hb_Random( -2 ^ 15, 2 ^ 15 - 1   ) ),;
      INT3  WITH Int( hb_Random( -2 ^ 23, 2 ^ 23 - 1   ) ),;
      INT32 WITH Int( hb_Random( -2 ^ 23, 2 ^ 23 - 1   ) ) / 100,;
      INT4  WITH Int( hb_Random( -2 ^ 31, 2 ^ 31 - 1   ) ),;
      INT42 WITH Int( hb_Random( -2 ^ 31, 2 ^ 31 - 1   ) ) / 100,;
      INT8  WITH Int( hb_Random( -2 ^ 63, 2 ^ 63 - 513 ) ),;
      INT84 WITH Int( hb_Random( -2 ^ 63, 2 ^ 63 - 513 ) ) / 10000

   REPL ALL NUM1  WITH INT1,  EQL1  WITH NUM1  = INT1,;
      NUM11 WITH INT11, EQL11 WITH NUM11 = INT11,;
      NUM2  WITH INT2,  EQL2  WITH NUM2  = INT2,;
      NUM22 WITH INT22, EQL22 WITH NUM22 = INT22,;
      NUM3  WITH INT3,  EQL3  WITH NUM3  = INT3,;
      NUM32 WITH INT32, EQL32 WITH NUM32 = INT32,;
      NUM4  WITH INT4,  EQL4  WITH NUM4  = INT4,;
      NUM42 WITH INT42, EQL42 WITH NUM42 = INT42,;
      NUM8  WITH INT8,  EQL8  WITH NUM8  = INT8,;
      NUM84 WITH INT84, EQL84 WITH NUM84 = INT84

   dbGoTop()

   Browse()
   USE

RETURN // SG_Integers()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_Currency()                       // Set / Get test for CURRENCY fields

   LOCAL aStru10 := { { "Currenc",  "Y",  8, 4 },;
                      { "NUM2D",    "N", 21, 2 },;
                      { "NUM4D",    "N", 21, 4 },;
                      { "NUM6D",    "N", 23, 6 },;
                      { "NUM8D",    "N", 25, 8 } }

   dbCreate( "SG_Curncy", aStru10 )

   USE SG_Curncy

   FOR nRecno := 1 TO 100
      dbAppend()
      REPLACE Currenc WITH hb_Random( -2 ^ 53, 2 ^ 53 ) / 10000,;
         NUM2D   WITH Currenc,;
         NUM4D   WITH Currenc,;
         NUM6D   WITH Currenc,;
         NUM8D   WITH Currenc

   NEXT nRecno

   dbGoTop()
   Browse()
   USE

RETURN // SG_Currency()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SG_Double()                       // Set / Get test for DOUBLE ( BINARY ) fields

   LOCAL nRecno  := 0

   LOCAL aStru11 := { { "Double",  "B",  8, 4 },;
      { "NUM2D",   "N", 21, 2 },;
      { "NUM4D",   "N", 21, 4 },;
      { "NUM6D",   "N", 23, 6 },;
      { "NUM8D",   "N", 25, 8 } }

   dbCreate( "SG_Double", aStru11 )

   USE SG_Double

   FOR nRecno := 1 TO 100
      dbAppend()
      REPLACE Double WITH hb_Random( -2 ^ 53, 2 ^ 53 ) / 10000,;
         NUM2D  WITH Double,;
         NUM4D  WITH Double,;
         NUM6D  WITH Double,;
         NUM8D  WITH Double

   NEXT nRecno

   dbGoTop()
   Browse()
   USE

RETURN // SG_Double()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROCEDURE SignChng()                           // Convert and test signed to integer

   LOCAL nRecno  := 0

   LOCAL aStru12 := { { 'NUM1', "N",  3, 0 }, ;
      { 'INT1', "I",  1, 0 }, ;
      { 'RET1', "N",  3, 0 }, ;
      { 'EQL1', "L",  1, 0 }, ;
      { 'NUM2', "N",  6, 0 }, ;
      { 'INT2', "I",  2, 0 }, ;
      { 'RET2', "N",  6, 0 }, ;
      { 'EQL2', "L",  1, 0 }, ;
      { 'NUM3', "N",  9, 0 }, ;
      { 'INT3', "I",  3, 0 }, ;
      { 'RET3', "N",  9, 0 }, ;
      { 'EQL3', "L",  1, 0 }, ;
      { 'NUM4', "N", 11, 0 }, ;
      { 'INT4', "I",  4, 0 }, ;
      { 'RET4', "N", 11, 0 }, ;
      { 'EQL4', "L",  1, 0 }, ;
      { 'NUM8', "N", 21, 0 }, ;
      { 'INT8', "I",  8, 0 }, ;
      { 'RET8', "N", 21, 0 }, ;
      { 'EQL8', "L",  1, 0 } }

   dbCreate( "SignChng", aStru12 )
   USE SignChng

   FOR nRecno := 1 TO 100

      dbAppend()

      REPLACE NUM1 WITH hb_Random( 0, 2 ^ 8  - 1 ), INT1 WITH NUM1 - 2 ^ 7, RET1 WITH INT1 + 2 ^ 7,  EQL1 WITH NUM1 = RET1,;
         NUM2 WITH hb_Random( 0, 2 ^ 16 - 1 ), INT2 WITH NUM2 - 2 ^ 15, RET2 WITH INT2 + 2 ^ 15, EQL2 WITH NUM2 = RET2,;
         NUM3 WITH hb_Random( 0, 2 ^ 24 - 1 ), INT3 WITH NUM3 - 2 ^ 23, RET3 WITH INT3 + 2 ^ 23, EQL3 WITH NUM3 = RET3,;
         NUM4 WITH hb_Random( 0, 2 ^ 32 - 1 ), INT4 WITH NUM4 - 2 ^ 31, RET4 WITH INT4 + 2 ^ 31, EQL4 WITH NUM4 = RET4,;
         NUM8 WITH hb_Random( 0, 2 ^ 64 - 1 ), INT8 WITH NUM8 - 2 ^ 63, RET8 WITH INT8 + 2 ^ 63, EQL8 WITH NUM8 = RET8


   NEXT nRecno

   dbGoTop()
   Browse()
   USE

RETURN // SignChng()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
