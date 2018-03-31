/*
 * Harbour Project source code:
 * TFtp class
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

/****c* TFtp/TFtp
*  NAME
*    TFtp
*  PURPOSE
*    Create a FTP connection
*  METHODS
*    TFtp:New
*    TFtp:Connect
*    TFtp:Login
*    TFtp:Close
*    TFtp:List
*  EXAMPLE
*
*  SEE ALSO
*    THttp
**********
*/
CLASS TFtp

   METHOD New()

   METHOD Connect( cAddress, nPort )
   METHOD Login( cUser, cPwd )
   METHOD Close()

   METHOD List()

   CLASSDATA oSocket       HIDDEN
   CLASSDATA cHostAddress  HIDDEN
   CLASSDATA nHostPort     HIDDEN

ENDCLASS

//
// New
//
METHOD New() CLASS TFtp
::oSocket := TSocket():New()
//::oSocket:bDebug := .t.
return Self

//
// Connect
//
METHOD Connect( cAddress, nPort ) CLASS TFtp
local lRet

DEFAULT nPort TO 21
::cHostAddress := cAddress
::nHostPort    := nPort

lRet := ::oSocket:Connect(::cHostAddress,::nHostPort)
if lRet
   // Consume Login string
   ::oSocket:ReceiveLine()
endif
return lRet

//
// Close
//
METHOD Close() CLASS TFtp
return ::oSocket:Close()

//
// Login
//
METHOD Login( cUser, cPwd ) CLASS TFtp
local cErr := ""
local lRet := .f.

DEFAULT cUser TO "anonymous"
DEFAULT cPwd  TO ""

if ::oSocket:SendString( "USER " +cUser +CHR(13)+CHR(10) )
   cErr := ::oSocket:ReceiveLine()
   // OK
   if LEFT(cErr,1)=="2"
      lRet := .T.
   // Error
   elseif LEFT(cErr,1)$"145"
      lRet := .F.
   // Password
   elseif LEFT(cErr,1)=="3"
      if ::oSocket:SendString( "PASS " +cPwd +CHR(13)+CHR(10) )
         cErr := ::oSocket:ReceiveLine()
         if LEFT(cErr,1)=="2"
            lRet := .T.
         elseif LEFT(cErr,1)$"145"
            lRet := .F.
         elseif LEFT(cErr,1)=="3"
            //## NEED ACCT .. to implement
            lRet := .F.
         endif
      endif
   endif
endif

// Consume long message
while substr(cErr,4,1)=="-"
   cErr := ::oSocket:ReceiveLine()
enddo

return lRet

//
// List
//
METHOD List() CLASS TFtp
//local cErr := ""

//## to improve
if ::oSocket:SendString( "PASV " +CHR(13)+CHR(10) )
   /*cErr :=*/ ::oSocket:ReceiveLine()
/*

Tells the server to enter "passive mode". In passive mode, the server will wait for the client to establish a connection with it rather than attempting to connect to a client-specified port. The server will respond with the address of the port it is listening on, with a message like:
227 Entering Passive Mode (a1,a2,a3,a4,p1,p2)
where a1.a2.a3.a4 is the IP address and p1*256+p2 is the port number.

*/
/*
   if ::oSocket:SendString( "LIST " +CHR(13)+CHR(10) )
      while len(cErr := ::oSocket:ReceiveLine())>0
         ? cErr
      enddo
   endif
*/
endif

return Self

