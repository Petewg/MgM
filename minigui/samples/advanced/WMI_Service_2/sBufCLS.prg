/*
  Created : 2012-06-01
  Author : Tsakalidis G. Evangelos <tsakal@otenet.gr>
*/

#include "hbclass.ch"
//------------------------------------------------------------------//
CREATE CLASS stringBuffer

	DATA aStringBuffer

	METHOD New()
	METHOD setStr(strIn)
	METHOD getStr(sSeparator)

ENDCLASS

METHOD New() CLASS stringBuffer
	::aStringBuffer := {}
RETURN SELF

METHOD setStr( strIn ) CLASS stringBuffer
	if valType( strIn ) != 'U'
		aadd( ::aStringBuffer, strIn )
	endif
RETURN Nil

METHOD getStr( sSeparator ) CLASS stringBuffer
	default sSeparator := ''
RETURN( aJoin( ::aStringBuffer, sSeparator ) )
//------------------------------------------------------------------//
STATIC Function aJoin( aIn, sDelim )
	local sRet := ''
	local iLen := len(aIn)
	do case
	case iLen == 0
		sRet := ''
	case iLen == 1
		sRet := aIn[1]
	otherwise
		aeval( aIn, { |x| sRet += ( x + sDelim ) }, 1, iLen - 1 )
		sRet += aIn[iLen]
	endcase
RETURN( sRet )
//------------------------------------------------------------------//