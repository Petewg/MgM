#include "ArArithm.ch"

/*

   f.ACount() : Return count from an array.
   
   Syntax :  ACOUNT( <aArry2Count> [, <nFORColNo>] [, <bFORClaus>] ) -> <nCount>
             
   Parameters : <aArry2Count>  : Array to count
                <nFORColNo>    : For clause indice (Column / Field number); default is 1. 
                <bFORClaus>    : For clause code block; default is all rows in the <aArry2Count>

   Return : <nCount> : A numeric value as result of count
   
   
   Licence : This is a public domain work, it's free using any way.
   
             All right reserved.
            
   Author : Bicahi Esgici  
            
             <esgici @ gmail . com >
   
   History : July 2010; 1.st release
      
                
*/

FUNC ACOUNT( ;                            // Count from an array.
             aArry2Count ,;
             nFORColNo ,;  // For clause indise
             bFORClaus )   // For clause block

   LOCAL l2Dim  := HB_ISARRAY( aArry2Count[ 1 ] ),;
         nIndis :=  0,;
         nRVal  := 0
         
   DEFAULT nFORColNo TO 1,;
           bFORClaus TO { || .T.}

   IF l2Dim     
      AEVAL( aArry2Count, { | a1, i1 | IF( EVAL( bFORClaus, a1[nFORColNo], i1 ), ++nRVal, ) } )      
   ELSE
      AEVAL( aArry2Count, { | x1, i1 | IF( EVAL( bFORClaus, nFORColNo, i1 ), ++nRVal, ) } )  
   ENDIF   
   
RETU nRVal // ACOUNT()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   f.ASum() : Return sum value(s) from an array.
   
   Syntax :  ASUM( <aArry2Sum> [, <xFields>] [, <nFORColNo>] [, <bFORClaus>] ) -> <xSums>
             
   Parameters : <aArry2Count>  : Array to count
                <xFields>      : Field(s) (columns) no(s) to sum. A Numeric value for single, a numeric array for 
                                 multiple fields / columns. Default is all fields (columns) in the array.
                <nFORColNo>    : For clause indice (Column / Field number); default is 1. 
                <bFORClaus>    : For clause code block; default is all rows in the <aArry2Sum >

   Return : <xSums> : A single numeric value for dim-1 and a numeric array for dim-2 array as result of sum
   
   
   Licence : This is a public domain work, it's free using any way.
   
             All right reserved.
            
   Author : Bicahi Esgici  
            
             <esgici @ gmail . com >
   
   History : July 2010; 1.st release
      
                
*/


FUNC ASUM( ;                              // sum value(s) from an array.
             aArry2Sum ,;
             xFields,;     // Fields (columns) to sum 
             nFORColNo ,;  // For clause indise
             bFORClaus )   // For clause block

   LOCAL l2Dim  := HB_ISARRAY( aArry2Sum[ 1 ] ),;
         a1     := {},;
         nIndis :=  0,;
         xRVal
                                                          
   IF HB_ISNIL( xFields )
      IF l2Dim
         xFields := {}
         AEVAL( aArry2Sum[ 1 ], { | x1, i1 | IF( HB_ISNUMERIC( x1 ), AADD( xFields, i1 ), ) } )
      ENDIF l2Dim   
   ELSEIF HB_ISNUMERIC( xFields ) .AND. l2Dim
      xFields := { xFields }              
   ENDIF HB_ISNIL( xFields )
         
   DEFAULT  nFORColNo TO 1,;
            bFORClaus TO { || .T.} 
   
   IF l2Dim
   
      xRVal := ACLONE( aArry2Sum[ 1 ] )
      AEVAL( xRVal, { | x1, i1 | xRVal[ i1 ] := EmptyValue( x1 ) } )  
      
      FOR EACH a1 IN aArry2Sum
         IF EVAL( bFORClaus, a1[ nFORColNo ] )
            AEVAL( a1, { | x1, i1 | IF( ASCAN( xFields, i1 ) > 0 .AND.; 
                                        HB_ISNUMERIC( x1 ) .AND.;
                                        HB_ISNUMERIC( xRVal[ i1 ] ),;                                      
                                        xRVal[ i1 ] += x1, ) } )
         ENDIF                               
      NEXT a1
   ELSE
      xRVal := 0
      AEVAL( aArry2Sum, { | x1, i1 | IF( HB_ISNUMERIC( x1 ) .AND. ;
                                     EVAL( bFORClaus, nFORColNo, i1 ), xRVal += x1, ) } )  
   ENDIF   
   
RETU xRVal // ASUM()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*

   f.AAVERAGE() : Return AVERAGE value(s) from an array.
   
   Syntax :  AAVERAGE( <aArry2Average> [, <xFields>] [, <nFORColNo>] [, <bFORClaus>] ) -> <xAverages>
             
   Parameters : <aArry2Average> : Array to AVERAGE
                <xFields>       : Field(s) (columns) no(s) to sum. A Numeric value for single, a numeric array for 
                                  multiple fields / columns. Default is all fields (columns) in the array.
                <nFORColNo>     : For clause indice (Column / Field number); default is 1. 
                <bFORClaus>     : For clause code block; default is all rows in the <aArry2Average>

   Return : <xAverages> : A single numeric value for dim-1 and a numeric array for dim-2 array as result of average   
   
   Licence : This is a public domain work, it's free using any way.
   
             All right reserved.
            
   Author : Bicahi Esgici  
            
             <esgici @ gmail . com >
   
   History : July 2010; 1.st release
      
                
*/


FUNC AAVERAGE( ;
             aArry2Sum ,;
             xFields,;     // Fields (columns) to sum 
             nFORColNo ,;  // For clause indise
             bFORClaus )   // For clause block

   LOCAL l2Dim  := HB_ISARRAY( aArry2Sum[ 1 ] ),;
         a1     := {},;
         nIndis :=  0,;
         nRowCo :=  0,;  // Row count to average
         xRVal
                                                          
   IF HB_ISNIL( xFields )
      IF l2Dim
         xFields := {}
         AEVAL( aArry2Sum[ 1 ], { | x1, i1 | IF( HB_ISNUMERIC( x1 ), AADD( xFields, i1 ), ) } )
      ENDIF l2Dim   
   ELSEIF HB_ISNUMERIC( xFields ) .AND. l2Dim
      xFields := { xFields }              
   ENDIF HB_ISNIL( xFields )

   DEFAULT  nFORColNo TO 1,;
            bFORClaus TO { || .T.} 
   
   IF l2Dim
      xRVal := ACLONE( aArry2Sum[ 1 ] )
      AEVAL( xRVal, { | x1, i1 | xRVal[ i1 ] := EmptyValue( x1 ) } )  
      FOR EACH a1 IN aArry2Sum
         IF EVAL( bFORClaus, a1[ nFORColNo ] )
            ++nRowCo
            AEVAL( a1, { | x1, i1 | IF( ASCAN( xFields, i1 ) > 0 .AND.; 
                                        HB_ISNUMERIC( x1 ) .AND.;
                                        HB_ISNUMERIC( xRVal[ i1 ] ),;                                      
                                        xRVal[ i1 ] += x1, ) } )
         ENDIF                               
      NEXT a1
      AEVAL( xRVal, { | x1, i1 | IF( HB_ISNUMERIC( x1 ) .AND. x1 > 0, xRVal[ i1 ] /= nRowCo, ) } ) 
   ELSE
      xRVal := 0
      AEVAL( aArry2Sum, { | x1, i1 | IF( HB_ISNUMERIC( x1 ) .AND. ;
                                     EVAL( bFORClaus, nFORColNo, i1 ), (++nRowCo, xRVal += x1), ) } )
      xRVal /= nRowCo                                 
   ENDIF   
   
RETU xRVal // AAVERAGE()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*

   f.ATOTAL() : Return ATOTAL value(s) from an array.
   
   Syntax :  AATOTAL( <aArry2Total> [, <xFields>] [, <nFORColNo>] [, <bFORClaus>] ) -> <xTotals>
             
   Parameters : <aArry2Total> : Array to TOTAL
                <xFields>     : Field(s) (columns) no(s) to sum. A Numeric value for single, a numeric array for 
                                multiple fields / columns. Default is all fields (columns) in the array.
                <nFORColNo>   : For clause indice (Column / Field number); default is 1. 
                <bFORClaus>   : For clause code block; default is all rows in the <aArry2Total>

   Return : <xAverages> : A single numeric value for dim-1 and a numeric array for dim-2 array as result of total   
   
   Licence : This is a public domain work, it's free using any way.
   
             All right reserved.
            
   Author : Bicahi Esgici  
            
             <esgici @ gmail . com >
   
   History : July 2010; 1.st release
      
                
*/

FUNC ATOTAL( ;
             aArry2Total ,;
             xFields,;     // Fields (columns) to sum 
             nONColNo ,;   // ON clause indise
             bONClaus ,;   // ON clause block
             nFORColNo ,;  // FOR clause indise
             bFORClaus )   // FOR clause codeblock

   LOCAL l2Dim  := HB_ISARRAY( aArry2Total[ 1 ] ),;
         a1     := {},;
         nIndis :=  0,;
         aRVal  := {},;
         a1RVal := {},;
         c1Key  := '',;
         nSTInd :=  0     // Sub-total indise
                                                          
   IF HB_ISNIL( xFields )
      IF l2Dim
         xFields := {}
         AEVAL( aArry2Total[ 1 ], { | x1, i1 | IF( HB_ISNUMERIC( x1 ), AADD( xFields, i1 ), ) } )
      ENDIF l2Dim   
   ELSEIF HB_ISNUMERIC( xFields ) .AND. l2Dim
      xFields := { xFields }              
   ENDIF HB_ISNIL( xFields )

   DEFAULT  nONColNo  TO 0,;
            bONClaus  TO { || .T.},;
            nFORColNo TO 1,;
            bFORClaus TO { || .T.} 
   
   IF l2Dim
      FOR EACH a1 IN aArry2Total
         IF EVAL( bFORClaus, a1[ nFORColNo ] )
            c1Key  := EVAL( bONClaus, a1[ nOnColNo ] )
            nSTInd := ASCAN( aRVal, { | a2 | c1Key == EVAL( bONClaus, a2[ nONColNo ] ) } )
            IF nSTInd < 1
               a1RVal := ACLONE( a1 )
               AEVAL( a1RVal, { | x1, i1 | a1RVal[ i1 ] := EmptyValue( x1 ) } )  
               a1RVal[ nOnColNo ] := c1Key 
               AADD( aRVal, a1RVal )
               nSTInd := LEN( aRVal )
            ENDIF         
            AEVAL( a1, { | x1, i1 | IF( ASCAN( xFields, i1 ) > 0 .AND.; 
                                        HB_ISNUMERIC( x1 ) .AND.;
                                        HB_ISNUMERIC( aRVal[ nSTInd, i1 ] ),;                                      
                                        aRVal[ nSTInd, i1 ] += x1, ) } )
         ENDIF                               
      NEXT a1
   ELSE
      aRVal := 0
      AEVAL( aArry2Total, { | x1, i1 | IF( HB_ISNUMERIC( x1 ) .AND. ;
                                       EVAL( bFORClaus, nFORColNo, i1 ), aRVal += x1, ) } )
   ENDIF   
                                     
RETU aRVal // ATOTAL()

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNCTION EmptyValue( xVal )     // Borrowed from EmptyValue() of ArrayRDD.prg of Harbour

   LOCAL xRet
   LOCAL cType := VALTYPE( xVal )

   SWITCH cType
   
   CASE "C"  // Char
   CASE "M"  // Memo
        xRet := ""
        EXIT
   CASE "D"  // Date
        xRet := HB_STOD()
        EXIT
   CASE "L"  // Logical
        xRet := .F.
        EXIT
   CASE "N"  // Number
        xRet := 0
        EXIT
   CASE "B"  // code block
        xRet := {|| NIL }
        EXIT
   CASE "A"  // array
        xRet := {}
        EXIT
   CASE "H"  // hash
        xRet := {=>}
        EXIT
/*

   For other types xRet is already NIL
           
   CASE "U"  // undefined
        xRet := NIL
        EXIT
        
   CASE "O"  // Object
        xRet := NIL   // Or better another value ?
        EXIT
        
*/        

   ENDSWITCH

   RETURN xRet

*.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
   