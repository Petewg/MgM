
#include <minigui.ch>
#include "DBA.ch"

DECLARE WINDOW frmDBAMain

FUNC IsAlInUse( cAlias )   // Is this alias is in use ?

   LOCA lRVal  := .F.    	,;
        nWArNo := 0			,;
        nCurWA := SELE()

   FOR nWArNo := 1 TO 15 
      DBSELECTAR((nWArNo))
      IF lRVal := ( ALIAS() == cAlias )
          EXIT FOR
      ENDIF
   NEXT nWArNo
   
   DBSELECTAR((nCurWA))
   
RETU lRVal // IsAlInUse()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.


PROC DispStru()                               // Display Structure ( Current File Only )

   LOCA aStruct :=  DBSTRUCT(),;
        aDBFInf := { aOpnDatas[ nCurDatNo, 4 ],;                   // 1. file name
                     LUPDATE(),;                                   // 2. Last Modification Date
                     LASTREC(),;                                   // 3. Record Count
                     RECSIZE(),;                                   // 4. Record Length
                     FCOUNT() }                                    // 5. Field Count

   DBStructOps( aStruct, 1, aDBFInf )
   
/*   
   cStruct := " Database File Name : " + aOpnDatas[ nCurDatNo, 4 ] + CRLF +;
              "  # of data records : " + NTrim( LASTREC() ) + CRLF +;
              "Date of last update : " + DTOC(  LUPDATE() ) + CRLF +;
              "No:  Fied Name  Type Width Dec" + CRLF +;
              "---  ---------  ---- ----- ---" + CRLF
   
   AEVAL( aStruct, { | a1, i1 | cStruct += PADL( i1, 3) + '  ' + ;
                                           PADR( a1[ 1 ], 11 ) + ;
                                           PADC( a1[ 2 ],  6 ) + ;
                                           PADL( a1[ 3 ],  4 ) + ;
                                           PADL( a1[ 4 ],  4 ) + CRLF,;
                                           nTotal += a1[ 3 ] } )
                                           
   cStruct += "---  ---------  ---- ----- ---" + CRLF +;
              "** Total ** " + PADL( nTotal, 14 )  
   
   SayBekle( cStruct, "Display Structure" )
*/      
   
RETU // DispStru()
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

/*

   DBValidate() : Test a file .dbf validity
   
   Syntax :  DBValidate(<cDBF2Vald>) -> nResult
   
   Argument : <cDBF2Vald> : Full file (.dbf) name to test validity
   
   Result : <nResult> : A numeric value to indicate file's validity status :
   
              0 : unidentified file type, highly probably none .dbf
              
             >0 : Validity check successfull; this file is a valid .dbf   
              
                2 : FoxBASE
                3 : FoxBASE+ or dBASE III+, no memo
               48 : Visual FoxPro
               67 : dBASE IV SQL, no memo
               84 : dBASE IV SQL table, with memo
               99 : dBASE IV SQL system, no memo
              131 : FoxBASE+ or dBASE III+, with memo 
              167 : FoxPro 2.x (or older), with memo
              185 : FoxBASE ( memo ? )
              226 : FoxBASE+ or dBASE III+, with memo
              239 : dBASE IV with memo
              245 : RDDFTP/CDX; catched at 8830             
              
             <0 : Error situations : 
             
                  -2  : File not found
                  -81 : .dbf with memo, memo file (.dbt) not found
                  
                   any negative number other than this two : Open Error ( FERROR() )
   
   6405 : Eski muavinden getirildi, 1az deðiþti.
   
   6504 : Fox'un pislikleri yüzünden lMemo ve müþtemilâtý eklendi.  
   
   7121 : Ayný sebepden "cMemoFNam" deðiþkeni "cMemoFNm1" ve "cMemoFNm2" halinde
          ikilendi.
   
*/

FUNC DBValidate(;
                 cDBF2Vald ) // Full file (.dbf) name to test validity
                 
   LOCA nRVal := 0
                  
   LOCA nFilHNo :=   0,;            // File DOS handle number.
        nFerror :=   0,;            // File Error   
        lRetVal := .F.,;            // Return Value
        nHdrLen :=  32              // Length of characters to read from file

   LOCA cHeader := SPAC(nHdrLen),; // File Header -- Control String
        nReaded :=  0,;            // Length of characters readed from file
        nCtrCod :=  0,;            // .dbf validity Control Code
        nLUYear :=  0,;            // Last Update Year
        nLUMont :=  0,;            //  "     "    Month
        nLUDay  :=  0,;            //  "     "    Day
        nRECCou :=  0,;            // Record Count
        nHedLen :=  0,;            // Header Length (with Fileds)
        nRecLen :=  0,;            // Record Length
        nFldCou :=  0,;            // Field Count
        nFilSzR :=  0,;            // Recorded File Size
        nFilSzC :=  0              // Computed   "    "
        
   LOCA lMemo   :=  .F.,;          // There is M type field ? 
        cStruct := '',;            // File Structure String
        aStruct := {},;            // File Structure Array
        nSStrLn := ''              // Structure String Length
        
   LOCA cMemoFNm1 := '',;          // Added at 7121 
        cMemoFNm2 := '' 
        
   IF FILE(cDBF2Vald)            // File exists
      nFilHNo := FOPEN(cDBF2Vald)     // Open File for Read Only.
      nFerror := FERROR()   
      IF nFerror == 0                 // File open ok.
         nReaded := FREAD( nFilHNo, @cHeader, nHdrLen)
         IF nHdrLen == nReaded               // READ ok.
         
            nCtrCod :=   ASC(SUBS(cHeader, 1,1))    // dBF Validity
            nLUYear :=   ASC(SUBS(cHeader, 2,1))    // Year of Last Update
            nLUMont :=   ASC(SUBS(cHeader, 3,1))    // Month of Last Update
            nLUDay  :=   ASC(SUBS(cHeader, 4,1))    // Day of Last Update
            nRECCou := BIN2L(SUBS(cHeader, 5,4))    // Number of Records
            nHedLen := BIN2I(SUBS(cHeader, 9,2))    // Header Len (/w fields)
            nRecLen := BIN2I(SUBS(cHeader,11,2))    // Record Length
            nFldCou := INT( ( nHedLen - 33 ) / 32 ) // Field Count
            nFilSzR := FSEEK(nFilHNo,0,2)           // Recorded File Size
            nFilSzC := nHedLen + nRecLen * nRecCou  // Computed File Size
            
            IF nLUMont < 13 .AND.;
               nLUDay  < 32 .AND.;
               ABS( nFilSzC-nFilSzR ) < 2
               
               nSStrLn := nHedLen - 34            // Structure String Length
               cStruct := SPAC( nSStrLn )         // File Structure String
               FSEEK( nFilHNo, nHdrLen, 0)        // Go to beg of struct
               FREAD( nFilHNo, @cStruct, nSStrLn) // Read File Structure String
               DBStruC2A( cStruct, aStruct )
                  
               lMemo   :=  ASCAN( aStruct, { | a1 | a1[ 2 ] == "M" } ) > 0
               
               IF lMemo
                  cMemoFNm1 := LEFT( cDBF2Vald, LEN( cDBF2Vald)-3 ) + "DBT"
                  cMemoFNm2 := LEFT( cDBF2Vald, LEN( cDBF2Vald)-3 ) + "FPT" 

                  IF FILE( cMemoFNm1 ) .OR. FILE( cMemoFNm2 )
                     nRVal := nCtrCod 
                  ELSE
                     nRVal := -81 // memo file not found                 
                  ENDIF
               ELSE   
                  nRVal := nCtrCod 
               ENDIF
            ELSE  
            
/*            
SayBekle( "nLUMont : " + NTrim( nLUMont ) + CRLF + ;
          "nLUDay  : " + NTrim( nLUDay  ) + CRLF + ;
          "nHedLen : " + NTrim( nHedLen ) + CRLF + ;
          "nRecLen : " + NTrim( nRecLen ) + CRLF + ;
          "nRECCou : " + NTrim( nRECCou ) + CRLF + ;
          "nFldCou : " + NTrim( nFldCou ) + CRLF + ;
          "nFilSzC : " + NTrim( nFilSzC ) + CRLF + ;
          "nFilSzR : " + NTrim( nFilSzR )  )
*/          
      
               nRVal := 0
            ENDIF nLUMont < 13 ...                   
         ELSE
            nRVal := -30 // nHdrLen # nReaded : Error while reading (Read Fault) 
         ENDIF Read Error
         FCLOSE( nFilHNo )
      ELSE
         nRVal := nFerror  // Open Error 
      ENDIF OPEN Error
   ELSE
      nRVal := -2 // File not found
   ENDIF File existence

RETU nRVal // DBValidate()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC DBStruC2A(;                          // dBase File Struct From String to Array
                cStruct,;  // db file struct in string ( readed low level )
                aStruct )  // db file struct array
                
   LOCA nFldCou := LEN( cStruct ) / 32,;
        c1Field := '',;
        cFldNam := '',;
        cFldTyp := '',;
        nFldWdt :=  0,;
        nFldDec :=  0,;
        nFldNum :=  0
        
   FOR nFldNum := 1 TO nFldCou
      c1Field := SUBS( cStruct, ( nFldNum - 1 ) * 32 + 1, 32 )
      cFldNam := SUBS( c1Field,  1, AT( CHR(0), c1Field ) - 1 )       
      cFldTyp := SUBS( c1Field, 12,  1 ) 
      nFldWdt := ASC( SUBS( c1Field, 17,  1 ) )
      nFldDec := ASC( SUBS( c1Field, 18,  1 ) )
      AADD( aStruct, { cFldNam, cFldTyp, nFldWdt, nFldDec } )
   NEXT nFldNum
   
RETU // DBStruC2A()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


/*

   f.DispLeng()  : Bir saha'nýn Display ( gösterim ) boyu
                   Özellikle brows'da sütun geniþliðinin tesbiti için 
                   
   6216 : Muawin6'da doðdu
   
   6505 : 1 az 1 þeyler eklendi ama karýþtý, dokümante edilemedi; ÝBG ...
                   
*/   

FUNC DispLeng( ;                          // Bir saha'nýn gösterim boyu
                 a1Field,;
                 x1Value,;  
                 lMFValu,;   // Memo for value ( .F. : memo len is 10; .T. : memo len is 64
                 lDFValu )   // Date for value ( .F. : date len is 10; .T. : memo len is 20  
   LOCA nRVal := 0 
   
   DEFAULT lMFValu TO .F.,;
           lDFValu TO .F.
           
   DO CASE
   
      CASE a1Field[ 2 ] == "C"
         nRVal := IF( ISCHAR( x1Value ), LEN( x1Value ), a1Field[ 3 ] )
      CASE a1Field[ 2 ] == "N"
         nRVal := LEN( BBTUsing( 0, a1Field[ 3 ], a1Field[ 4 ] ) )
      CASE a1Field[ 2 ] == "D"
         nRVal := IF( lDFValu, 20, 10 ) // for DatePicker
      CASE a1Field[ 2 ] == "L"
         nRVal := 3
      CASE a1Field[ 2 ] == "M"
         nRVal := IF( lMFValu, 64, 10 )
   ENDCASE a1Field[ 2 ]   

   IF LEN( a1Field ) > 4
      nRVal := MAX( nRVal, LEN( a1Field[ 5 ] ) )
   ELSE   
      IF ISCHAR( a1Field[ 1 ] )
         nRVal := MAX( nRVal, LEN( a1Field[ 1 ] ) )
      ENDIF   
   ENDIF   
   
   nRVal += 3   // for tolerence
   
RETU nRVal // DispLeng()
         
*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

   f.SameStru() : // Does two .dbf's structs idendical ?


   Syntax       : SameStru( <aStru1>, <aStru2> ) => <lIdentical>

   Arguments    : <aStru1> : 1.st .dbf's structure
                  <aStru2> : 2.st .dbf's structure

   Result       : <lIdentical> : If two structure are identical, else .F.


   History      : 03.1999 : Begun 
                  05.2000 : Revized
                  05.2006 : Two RETURN reduced to one


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

FUNC SameStru(;                           // Does two .dbf's structs idendical ?
                aStru1,;
                aStru2 )              

   LOCA lRVal := .T.,;
        nFlds := 0,;
        nProp := 0
        
   IF LEN( aStru1 ) == LEN( aStru2 )
      FOR nFlds := 1 TO LEN( aStru2 )
         FOR nProp := 1 TO 4                
            IF aStru1[ nFlds, nProp] # aStru2[ nFlds, nProp ]
               lRVal := .F.
               EXIT FOR
            ENDIF aStru1[ nFlds, nProp ] == aStru2[ nFlds, nProp ]
         NEXT nProp
         IF !lRVal
            EXIT FOR
         ENDIF         
      NEXT nFlds
   ELSE   
      lRVal := .F.
   ENDIF LEN( aStru1 ) == LEN( aStru2 )

RETU lRVal // SameStru()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._


FUNC DBStMMFld( ;                         // Is there any type mismatched field in two structs ?
                aStruct1,; 
                aStruct2 )
   LOCA cRVal  := '',;
        nFInd  :=  0,;
        c1Fld  := '',;
        nMatch :=  0
        
   FOR nFInd := 1 TO LEN( aStruct1 )
      c1Fld  := aStruct1[ nFInd, 1 ]
      nMatch :=  ASCAN( aStruct2, { | a1 | a1[ 1 ] == c1Fld } ) 
      IF nMatch > 0
         IF aStruct1[ nFInd, 2 ] # aStruct2[ nMatch, 2 ] 
            cRVal := c1Fld 
            EXIT FOR
         ENDIF    
      ENDIF ASCAN( ...
   NEXT nFInd
                   
RETU cRVal // DBStMMFld()                
                
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

