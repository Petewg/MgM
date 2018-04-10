#include <minigui.ch>
#include "DBA.ch"

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  p.MakSHArr()

  Purpose  : Make a single dim array from any dim one

  Syntax   : MakSHArr(aShAr,aArry,nLvl)

  Argument : <aShAr> : Target (single dim) array
             <aArry> : Source (any dim) array
             <nLvl>  : Deep Level; 1 for 1st call, other values using by
                       proc itself.
  Return   : None
  Uses     : f.AnyToStr(), Itself
  Caution  : Recursive

  Revision : 23:360  28/07/1998
             18:19   25.04.2004  lNumbered added
             6503 : lRForm added
               
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


PROC MakSHArr(aShAr,;               // Make an arry for display
              aArry,;
              nLvl,;
              lNumbered,;
              lRForm )

   LOCA nInds := 0,;
        xElem := ''
        
   DEFAULT lNumbered TO .T. ,;
           lRForm    TO .F.
   
   FOR  nInds := 1 TO LEN(aArry)
      xElem := aArry[ nInds ]
      IF lNumbered
         AADD(aShAr,STR(nInds,nLvl+2)+'º '+ AnyToStr( xElem, lRForm ))
      ELSE
         AADD(aShAr, SPAC(nLvl+2) + AnyToStr( xElem, lRForm ))
      ENDIF
      IF VALTYPE(xElem) == "A"
         MakSHArr( aShAr, xElem, nLvl+2, lNumbered, lRForm )
      ENDIF
   NEXT nInds

   RETU // f.MakSHArr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*

   No exactly "any", but

      exactly one of Clipper's internal types and

      any of "reversible",

      which one of this : L,D, and N

*/

FUNC Strg2Any( ;                          // String To Any Type
                cStrg )
                 
   LOCA xRVal := cStrg,;
        cStr2 := '',;
        xAraV := ''      // Ara Value

   IF cStrg # NIL
      IF VALTYPE(cStrg) == "C"
         cStr2 := ALLTRIM(cStrg)
         IF LEN(cStr2) == 3 .AND. UPPE(cStr2) $ ".T..F."
            xRVal := (UPPE(cStr2) == ".T.")
         ELSEIF DTOC(CTOD(cStr2)) == cStr2
            /* This control assumes that
                  DATE SETted to GERM and
                  CENTURY SETted to ON
               and
                  <cStr> (in source) is convenient this assumptions. */
            xRVal := CTOD(cStr2)
         ELSEIF LTRIM(STR(VAL(cStr2))) == cStr2
            xRVal := VAL(cStr2)
         ENDIF
      ENDIF VALTYPE(cStrg) == "C"
   ENDIF cStrg # NIL

   RETU xRVal // Strg2Any()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*

  Return Length of largest item ( array or string ) in an array
 
  6428 : AnyToStr() added
 
  6505 : Modul name changed ( ArMaxL => ArMaxLen )
 
*/
FUNC ArMaxLen(;                             // Len of largest string in an array
              aArry ,;
              nIndc )

   LOCA nRVal := 0

   IF ISNIL( nIndc )
      AEVAL( aArry, { | x1 | nRVal := MAX( LEN( AnyToStr( x1 ) ), nRVal ) } )
   ELSE
      AEVAL( aArry, { | x1 | nRVal := MAX( ;
                    IF( ISARRY( x1 ), LEN( AnyToStr( x1[ nIndc ] ) ),;
                                      LEN( AnyToStr( x1 ) ) ), nRVal ) } )
   ENDIF

   RETU nRVal // ArMaxLen()
   
   
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

PROC ArryPack( aArray )                    // Pack ( eg after ADEL() an array )

   LOCA nDeleted := ArrCount( aArray, NIL )
   
   ASIZE( aArray, LEN( aArray ) - nDeleted )
   
RETU // ArryPack()      

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

FUNC ArrCount( aArray, xValue )             // Count of a specific value into an array

   LOCA nRVal := 0
   
   AEVAL( aArray, { | x1 | nRVal += IF( VALTYPE( xValue ) == VALTYPE( x1 ) .AND. ;
                                                 xValue   ==          x1, 1, 0 ) } ) 
   
RETU nRVal // ArrCount()  

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._
/*
   f.ArMaxVal()
   
   6503 : Initialized
   
   todo : mult dim 
   
*/
FUNC ArMaxVal( aArray )                     // Max Value in an array 
   LOCA xRVal := aArray[ 1 ] 
   AEVAL( aArray, { | x1 | xRVal := MAX( xRVal, x1 ) } )  
RETU xRVal // ArMaxVal()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

/*
   f.ArMinVal()
   
   6503 : Initialized
   
   todo : mult dim 
*/
FUNC ArMinVal( aArray )                     // Min Value in an array 
   LOCA xRVal := aArray[ 1 ]
   AEVAL( aArray, { | x1 | xRVal := MIN( xRVal, x1 ) } )  
RETU xRVal // ArMinVal()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._

