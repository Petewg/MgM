/*
 Dec2Bin( n, lHi ) -> cBinary
   converts <n> integer decimal value to binary format.
   lHi flag if .T. try to retain as much higher-precision as possible
   NOTE: hbmisc DecToBin(n) function (IMHO incorrectly)
         for n=0 (zero) returns "" (nul string) instead of "0" as it should
         and is less accurate when dealing with very big numbers e.g. greater than UINT_MAX
			
	TODO: rewrite functions in C!
*/
#include "error.ch"

FUNCTION Dec2Bin( n, lHi )
   LOCAL cBin

   IF  ! HB_ISNUMERIC( n )
      ErrorQuit( EG_DATATYPE, /*Valtype( n )*/ n, "Expected numeric." )
   ENDIF

   lHi := hb_DefaultValue( lHi, .F. )
   IF n == 0
      RETURN "0"
   ENDIF
   cBin := ""
   WHILE n <> 0
      cBin := hb_ntos( Int( n % 2 ) ) + cBin
      // n := Int( n / 2 )
      n := Iif( lHi, n / 2, Int( n /2 ) )
   END

   RETURN cBin

FUNCTION Bin2Dec( cBinary )
/*
 Bin2Dec( cBinary ) -> nInteger
   converts <cBinary> to decimal format.
   NOTE: hbmisc BinToDec( cBinary ) function returns float (instead of integer),
         that is, adds two uneccessary '.00' zero decimal digits
*/
   LOCAL digit, nLen, nDec

   IF  ! HB_ISSTRING( cBinary )
      ErrorQuit( EG_DATATYPE, cBinary, "Expected string." )
   ELSE
      cBinary := Alltrim( cBinary )
      IF cBinary == "0"
         RETURN 0
      ENDIF
   ENDIF

   FOR EACH digit IN cBinary
       // Check if cBinary is a pure binary string
      IF ! ( digit $ "01" )
         ErrorQuit( EG_NUMERR, cBinary, "Non-numeric character in string." )
      ENDIF
   NEXT

   nLen := Len( cBinary )
   nDec := 0
   FOR EACH digit IN cBinary
      nDec += Iif( Val( digit ) > 0, 2^( nLen - digit:__enumindex ), 0 )
   NEXT

   RETURN  Int( nDec )

/*
NumDecompose( n ) -> array
  - decomposes <n> number into a series of numbers which are powers of 2,
    and  whose sum is the passed number <n>
  - returns an array of these numbers
  NOTE: uses Dec2Bin( n )
*/
/*
see updated version bellow with better var semantics
FUNCTION NumDecompose( n )
   LOCAL cBin, c, i
   LOCAL a := {}

   IF HB_ISNUMERIC( n )
      cBin := Dec2Bin( n )
      i := Len( cBin )
      FOR EACH c IN cBin
         IF Val(c) > 0
            AAdd( a,  Int( 2^(i - c:__enumindex) ) )
         ENDIF
      NEXT
      a := ASort( a )
   ENDIF

   RETURN a
*/   

FUNCTION NumDecompose( nNum )
   LOCAL cBinary, bit, nBinLen
   LOCAL aRet := {}

   IF HB_ISNUMERIC( nNum )
      cBinary := Dec2Bin( nNum, .T. )
      nBinLen := Len( cBinary )
      FOR EACH bit IN cBinary
         IF Val( bit ) > 0
            AAdd( aRet,  Int( 2^(nBinLen - bit:__enumindex) ) )
         ENDIF
      NEXT
      aRet := ASort( aRet )
   ENDIF

   RETURN aRet   
   
   

FUNCTION Proximal( n, n1, n2 )
   LOCAL nVar1, nVar2, nMinVar
   n  := hb_DefaultValue( n,  0 ) ; n1 := hb_DefaultValue( n1, 0 ) ;  n2 := hb_DefaultValue( n2, 0 )
   nVar1 := n1 - n
   nVar2 := n2 - n
   nMinVar := Min( Abs(nVar1), Abs(nVar2) )

   // RETURN Iif( nMinVar == nVar1, n1, n2 )
   RETURN Iif( nMinVar == nVar1, n1, n2 )

FUNCTION Proximal2( nTarget, aNums )
   LOCAL nCloser, n, n2
   nTarget  := hb_DefaultValue( nTarget,  0 )

   FOR EACH n IN aNums
      IF ! n:__enumIsLast()
         n2 := aNums[ n:__enumIndex + 1 ]
         nCloser := IIF( Abs(nTarget - n ) < Abs( nTarget - n2 ), n, n2 )
      ENDIF
   END
   RETURN nCloser


PROCEDURE ErrorQuit( nErrorDescription, xCulprit, cRemark )
   LOCAL nLayer := 1
   OutErr( ProcName( nLayer )+"( "+hb_ValToExp( xCulprit )+" )", hb_langErrMsg( nErrorDescription ) + ": " + hb_ValToExp( xCulprit ) + " (" + cRemark + ")" )
   // ? "func/proc: ", ProcName( nLayer++ )
   DO WHILE ! ( ProcName( ++nLayer ) == "" )
         OutErr( hb_eol() + "called from: ", ProcName( nLayer ), "(line: " + hb_NtoS( ProcLine( nLayer ) ) + ")"  )
   ENDDO
   // ? "source file: ", __FILE__
   Quit
   RETURN
