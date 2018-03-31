/*
 * Harbour Project source code:
 * TDecode class
 *
 * Copyright 2001-2003 Matteo Baccan <baccan@infomedia.it>
 * www - https://harbour.github.io/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"
#include "common.ch"

/****c* TDecode/TDecode
*  NAME
*    TDecode
*  PURPOSE
*    Decode string to pass in GET and POST method
*  METHODS
*    TDecode:New
*    TDecode:Decode
*    TDecode:Encode
*    TDecode:Decode64
*    TDecode:Encode64
*    TDecode:MD5
*    TDecode:HMAC_MD5
*  EXAMPLE
*
*    oSock := TDecode():new()
*
*    ? "Authorization: Basic "+oSock:encode64( "Aladdin:open sesame" )
*    ? "Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
*
*  SEE ALSO
*    THttp
**********
*/
CLASS TDecode

   METHOD New()

   METHOD Decode( cString )
   METHOD Encode( cString )

   METHOD Encode64( cData, nLen )
   METHOD Decode64( cData )
   METHOD MD5( cData )
   METHOD HMAC_MD5( cLogin, cPwd, cChallenge )

   CLASSDATA cCharPos      HIDDEN

ENDCLASS

/****m* TDecode/TDecode:new
*  NAME
*    new - class costructor
*  SYNOPSIS
*    TDecode():new()
*  PURPOSE
*    Create a new TDecode object
*  EXAMPLE
*    oSock := TDecode():new()
**********
*/
METHOD New() CLASS TDecode
::cCharPos := "0123456789abcdef"
return Self

/****m* TDecode/TDecode:Decode
*  NAME
*    Decode - decode a String
*  SYNOPSIS
*    Decode( cString )
*  PURPOSE
*    Get a string after a POST/GET operation and transofrm in a valid value
*  EXAMPLE
*    oSock := TDecode():new()
*
*    ? oSock:decode( "hello%20world" ) // "hello world"
*  SEE ALSO
*    TDecode:Encode
**********
*/
METHOD Decode( cString ) CLASS TDecode
LOCAL cRet := ""
LOCAL nChars, nDec, i, cChar
LOCAL nPos1, nPos2

i = 1
nChars = Len(cString)

While i < (nChars + 1)
   cChar = substr( cString , i  , 1 )
   if cChar=="+"
      cRet += " "
   elseif cChar=="%"
      cChar := lower(substr( cString , i + 1 , 2 ))
      nPos1 := AT( Left(cChar,1), ::cCharPos )-1
      nPos2 := AT( Right(cChar,1), ::cCharPos )-1
      nDec := (nPos1*16) +nPos2
      cRet += CHR( nDec )
      i+=2
   else
      cRet += cChar
   endif
   i++
enddo

return cRet

//
// Encode String
//
METHOD Encode( cString ) CLASS TDecode
LOCAL cRet := ""
LOCAL nChars, nChar, i, cChar

i := 1
nChars = Len(cString)

While i < (nChars + 1)
   cChar = substr( cString , i  , 1 )
   if cChar==" "
      cRet += "+"
   Elseif cChar>="a" .And. cChar<="z"
      cRet += cChar
   Elseif cChar>="A" .And. cChar<="Z"
      cRet += cChar
   Elseif cChar>="0" .And. cChar<="9"
      cRet += cChar
   Else
      nChar = Asc(cChar)
      cRet += "%" +substr( ::cCharPos, Int(nChar/16)+1, 1 ) +substr( ::cCharPos, nChar-Int(nChar/16)*16+1, 1 )
   EndIf
   i++
enddo

return cRet

METHOD Encode64( cData, nLen ) CLASS TDecode
DEFAULT nLen TO 0
return SocketEncode64( cData, nLen )

METHOD Decode64( cData ) CLASS TDecode
return SocketDecode64( cData )

METHOD MD5( cData ) CLASS TDecode
return SocketMD5( cData )

METHOD HMAC_MD5( cLogin, cPwd, cChallenge ) CLASS TDecode
return ::Encode64( SocketHMAC_MD5( cLogin, cPwd, ::Decode64(cChallenge) ) )
