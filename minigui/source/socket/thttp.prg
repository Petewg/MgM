/*
 * Harbour Project source code:
 * THttp class
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

#include "common.ch"
#include "hbclass.ch"

/****c* THttp/THttp
*  NAME
*    THttp
*  PURPOSE
*    Create a HTTP connection
*  METHODS
*    THttp:New
*    THttp:Connect
*    THttp:Close
*    THttp:SetProxy
*    THttp:SetUser
*    THttp:Get
*    THttp:Post
*    THttp:SetUserAgent
*    THttp:GetUserAgent
*    Thttp:SetReceiveTimeout
*  EXAMPLE
*
*  SEE ALSO
*    TFtp
**********
*/
CLASS THttp

   METHOD New()

   METHOD Connect( cAddress, nPort )
   METHOD Close()

   METHOD SetProxy( cProxy, nPort, cUser, cPwd )

   METHOD SetUser( cUser, cPwd )

   METHOD Get( cPage, aPair )
   METHOD Post( cPage, aPair )

   METHOD SetUserAgent( cAgent )
   METHOD GetUserAgent()

   METHOD SetReceiveTimeout( nMilliSec )

   METHOD Value2String( aPair )

   CLASSDATA oSocket       HIDDEN
   CLASSDATA cProxyAddress HIDDEN
   CLASSDATA nProxyPort    HIDDEN
   CLASSDATA cLogin        HIDDEN
   CLASSDATA cLoginRemote  HIDDEN
   CLASSDATA cHostAddress  HIDDEN
   CLASSDATA nHostPort     HIDDEN
   CLASSDATA cUserAgent    HIDDEN

ENDCLASS


METHOD New() CLASS THttp
::oSocket    := TSocket():New()
::cUserAgent := "THttp/Harbour (http://www.baccan.it; MSIE 6.0)"
return Self

/****m* THttp/THttp:Connect
*  NAME
*    Connect - connect to a remote server
*  SYNOPSIS
*    Connect( cAddress, nPort )
*  PURPOSE
*    Connect to a remote server on cAddress and nPort
*  EXAMPLE
*
*    #include "common.ch"
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    FUNCTION Main( cProxy, nProxyPort )
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    local oSock, cRet
*    local cServer  := "www.google.com" // "localhost"  //
*    local nPort    := 80               // 8080         //
*
*    DEFAULT nProxyPort TO "8080"
*
*    oSock := THttp():New()
*    if cProxy!=NIL
*       oSock:SetProxy( cProxy, VAL(nProxyPort) )
*    endif
*
*    ? "Connect to " +cServer +":" +alltrim(str( nPort ))
*    if oSock:Connect( cServer, nPort )
*       ? "Connected"
*
*       ? "Get homepage"
*       ? oSock:Get( "pippo:pluto@/" )
*
*       ? "Close connection"
*       if oSock:Close()
*          ? "Close successfull"
*       else
*          ? "Error on close connection"
*       endif
*    else
*       ? "Refused"
*    endif
*
*    RETURN NIL
*
*  SEE ALSO
*    THttp:Get
**********
*/
METHOD Connect( cAddress, nPort ) CLASS THttp
LOCAL lRet

DEFAULT nPort TO 80
::cHostAddress := cAddress
::nHostPort    := nPort

IF ::cProxyAddress!=NIL
   lRet := ::oSocket:Connect(::cProxyAddress,::nProxyPort)
ELSE
   lRet := ::oSocket:Connect(::cHostAddress,::nHostPort)
ENDIF

return lRet

//
// Close socket
//
METHOD Close() CLASS THttp
return ::oSocket:Close()

/****m* THttp/THttp:Get
*  NAME
*    Get - get a remote page
*  SYNOPSIS
*    Get( cPage, aPair )
*  PURPOSE
*    Get a remote page
*  EXAMPLE
*
*    #include "common.ch"
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    FUNCTION Main( cProxy, nProxyPort )
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    local oSock, cRet
*    local cServer  := "www.google.com" // "localhost"  //
*    local nPort    := 80               // 8080         //
*
*    DEFAULT nProxyPort TO "8080"
*
*    oSock := THttp():New()
*    if cProxy!=NIL
*       oSock:SetProxy( cProxy, VAL(nProxyPort) )
*    endif
*
*    ? "Connect to " +cServer +":" +alltrim(str( nPort ))
*    if oSock:Connect( cServer, nPort )
*       ? "Connected"
*
*       ? "Get homepage"
*       ? oSock:Get( "pippo:pluto@/" )
*
*       ? "Close connection"
*       if oSock:Close()
*          ? "Close successfull"
*       else
*          ? "Error on close connection"
*       endif
*    else
*       ? "Refused"
*    endif
*
*    RETURN NIL
*
*  SEE ALSO
*    THttp:Post
**********
*/
METHOD Get( cPage, aPair ) CLASS THttp
LOCAL cRet := ""
LOCAL cURL := ""
LOCAL cPost := ::Value2String( aPair )
LOCAL nPos

nPos := AT( "@", cPage )
IF nPos>0
   ::cLoginRemote := ::SetUser( LEFT( cPage, nPos-1 ) )
   cPage := SUBSTR( cPage, nPos+1 )
ENDIF

cURL := "GET "
IF ::cProxyAddress!=NIL
   cURL += "http://" +::cHostAddress +":" +ALLTRIM(STR(::nHostPort))
ENDIF
cURL += cPage
if len(cPost)>0
   cURL += "?" +cPost
endif
cURL += " HTTP/1.0" +CHR(13)+CHR(10)
if ::cLogin!=NIL
   cURL += "Proxy-authorization: Basic " +::cLogin +CHR(13)+CHR(10)
endif
if ::cLoginRemote!=NIL
   cURL += "Authorization: Basic " +::cLoginRemote +CHR(13)+CHR(10)
endif
cURL += "Host: " +::cHostAddress +CHR(13)+CHR(10)
cURL += "User-Agent: " +::cUserAgent +CHR(13)+CHR(10)
cURL += CHR(13)+CHR(10)

IF ::oSocket:SendString( cURL )
   cRet := ::oSocket:ReceiveString()
ENDIF
return cRet

/****m* THttp/THttp:Post
*  NAME
*    Post - post some value to a page
*  SYNOPSIS
*    Post( cPage, aPair )
*  PURPOSE
*    post some value to a page
*  EXAMPLE
*
*    #include "common.ch"
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    FUNCTION Main( cProxy, nProxyPort )
*    * ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*    local oSock, cRet
*    local cServer  := "www.google.com" // "localhost"  //
*    local nPort    := 80               // 8080         //
*
*    DEFAULT nProxyPort TO "8080"
*
*    oSock := THttp():New()
*    if cProxy!=NIL
*       oSock:SetProxy( cProxy, VAL(nProxyPort) )
*    endif
*
*    ? "Connect to " +cServer +":" +alltrim(str( nPort ))
*    if oSock:Connect( cServer, nPort )
*       ? "Connected"
*
*       ? "Get homepage"
*       ? oSock:Get( "pippo:pluto@/" )
*
*       ? "Close connection"
*       if oSock:Close()
*          ? "Close successfull"
*       else
*          ? "Error on close connection"
*       endif
*    else
*       ? "Refused"
*    endif
*
*    RETURN NIL
*
*  SEE ALSO
*    THttp:Get
**********
*/
METHOD Post( cPage, aPair ) CLASS THttp
LOCAL cRet := ""
LOCAL cURL := ""
LOCAL cPost := ::Value2String( aPair )
LOCAL nPos

nPos := AT( "@", cPage )
IF nPos>0
   ::cLoginRemote := ::SetUser( LEFT( cPage, nPos-1 ) )
   cPage := SUBSTR( cPage, nPos+1 )
ENDIF

cURL := "POST "
IF ::cProxyAddress!=NIL
   cURL += "http://" +::cHostAddress +":" +ALLTRIM(STR(::nHostPort))
ENDIF
cURL += cPage +" HTTP/1.0" +CHR(13)+CHR(10)
cURL += "Content-Length: " +ALLTRIM(STR(LEN(cPost))) +CHR(13)+CHR(10)
cURL += "Content-Type: application/x-www-form-urlencoded" +CHR(13)+CHR(10)
if ::cLogin!=NIL
   cURL += "Proxy-authorization: Basic " +::cLogin +CHR(13)+CHR(10)
endif
if ::cLoginRemote!=NIL
   cURL += "Authorization: Basic " +::cLoginRemote +CHR(13)+CHR(10)
endif
cURL += "Host: " +::cHostAddress +CHR(13)+CHR(10)
cURL += "User-Agent: " +::cUserAgent +CHR(13)+CHR(10)
cURL += CHR(13)+CHR(10)
cURL += cPost

IF ::oSocket:SendString( cURL )
   cRet := ::oSocket:ReceiveString()
ENDIF
return cRet

METHOD Value2String( aPair ) CLASS THttp
local cPost := ""
local nPair
local oDecode

DEFAULT aPair TO {}

oDecode := TDecode():New()

for nPair := 1 to len( aPair )
   if nPair!=1
      cPost += "&"
   endif
   cPost += aPair[nPair]:cKey +"=" +oDecode:encode(aPair[nPair]:cValue)
next

return cPost

//
// Set proxy port
//
METHOD SetProxy( cProxy, nPort, cUser, cPwd ) CLASS THttp
local oSock

DEFAULT nPort TO 8080
::cProxyAddress := cProxy
::nProxyPort    := nPort
if cUser!=NIL
   oSock := TDecode():new()
   if cPwd!=nil
      ::cLogin := oSock:encode64( cUser+":"+cPwd )
   else
      ::cLogin := oSock:encode64( cUser )
   endif
else
   ::cLogin := NIL
endif
return nil

//
// Set user and password method
//
METHOD SetUser( cUser, cPwd ) CLASS THttp
local oSock
if cUser!=NIL
   oSock := TDecode():new()
   if cPwd!=nil
      ::cLoginRemote := oSock:encode64( cUser+":"+cPwd )
   else
      ::cLoginRemote := oSock:encode64( cUser )
   endif
else
   ::cLoginRemote := NIL
endif
return nil

//
// Set user agent
//
METHOD SetUserAgent( cAgent ) CLASS THttp
::cUserAgent := cAgent
return nil

//
// Get user agent
//
METHOD GetUserAgent() CLASS THttp
return ::cUserAgent

//
// Set receive timeout
//
METHOD SetReceiveTimeout( nMilliSec ) CLASS THttp
::oSocket:SetReceiveTimeout( nMilliSec )
return nil
