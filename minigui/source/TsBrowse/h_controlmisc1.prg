#ifndef HB_SYMBOL_UNUSED
   #define HB_SYMBOL_UNUSED( symbol ) ( ( symbol ) )
#endif

FUNCTION cValToChar( xValue )

   LOCAL cType := ValType( xValue )
   LOCAL cValue := ""

   DO CASE
      CASE cType $  "CM";  cValue := xValue
      CASE cType == "N" ;  cValue := hb_ntos( xValue )
      CASE cType == "D" ;  cValue := DToC( xValue )
#ifdef __XHARBOUR__
      CASE cType == "T" ;  cValue := DToC( TToD( xValue ) )
#else
      CASE cType == "T" ;  cValue := DToC( hb_TToD( xValue ) )
#endif
      CASE cType == "L" ;  cValue := iif( xValue, "T", "F" )
      CASE cType == "A" ;  cValue := AToC( xValue )
      CASE cType $  "UE";  cValue := ""
      CASE cType == "B" ;  cValue := "{|| ... }"
      CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
      CASE cType == "H" ;  cValue := "{=>}"

   ENDCASE

RETURN cValue


FUNCTION _GetTextHeight( hwnd, hDC )

   HB_SYMBOL_UNUSED( hwnd )

RETURN GetTextMetric( hDC ) [1]


FUNCTION _InvertRect( hDC, aRec )  //Temporary

   LOCAL bRec

   bRec := { aRec[2], aRec[1], aRec[4], aRec[3] }
   InvertRect( hDC, bRec )

RETURN Nil
