/*
 * Proyecto: FacturaE
 * Fichero: i2of5txt.prg
 * Descripción: i2of5 Encoder para Harbour
 * Autor: Carlos Mora
 * Fecha: 20/02/2016
 */


FUNCTION i2of5Encode( cString )
   LOCAL cCode, i, n

   cCode:= '('
   FOR i:= 1 TO Len( cString ) STEP 2
      n:= Val( SubStr( cString, i, 2 ) )
      cCode+= Chr( n + IF( n <= 49, 48, 142 ) )
   NEXT
RETURN cCode+ ')'

FUNCTION i2of5( cString )
   LOCAL nImpar, nPar, i, nFinal

   nImpar:= 0
   FOR i:= 1 TO Len( cString ) STEP 2
      nImpar+= Val( SubStr( cString, i, 1 ) )
   NEXT
   nPar:= 0
   FOR i:= 2 TO Len( cString ) STEP 2
      nPar+= Val( SubStr( cString, i, 1 ) )
   NEXT
   nFinal:= nImpar * 3 + nPar
   If (nFinal % 10 ) == 0
      Return cString+'0'
   ENDIF
RETURN cString + Str( 10 - (nFinal % 10 ), 1 )