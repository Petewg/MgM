/*
 * Harbour Project source code:
 * TPOP3 class
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

/****c* TPop3/TPop3
*  NAME
*    TPOP3
*  PURPOSE
*    Create a POP3 connection
*  METHODS
*    TPop3:new
*    TPop3:connect
*    TPop3:close
*    TPop3:login
*    TPop3:list
*    TPop3:GetMessageHeader
*    TPop3:GetMessageText
*    TPop3:DeleteMessage
*  EXAMPLE
*
*  SEE ALSO
*    TDecode
**********
*/
CLASS TPOP3

   METHOD New()

   METHOD Connect( cAddress, nPort )
   METHOD Close()

   METHOD Login( cUser, cPwd )
   METHOD List( lFullInfo )
   METHOD GetMessageHeader( cMessageID )
   METHOD GetMessageText( cMessageID )
   METHOD DeleteMessage( cMessageID )

   CLASSDATA oSocket HIDDEN

ENDCLASS

/****m* TPop3/TPop3:new
*  NAME
*    new - class costructor
*  SYNOPSIS
*    TPop3():new()
*  PURPOSE
*    Create a new TPop3 object
*  EXAMPLE
*    oSock := TPop3():new()
**********
*/
METHOD New() CLASS TPOP3
::oSocket := TSocket():New()
//::oSocket:SetDebug( .T. )
return Self

//
// Connect to remore site
//
METHOD Connect( cAddress, nPort ) CLASS TPOP3
local bRet

DEFAULT nPort TO 110

bRet := ::oSocket:Connect(cAddress,nPort)
// If connect read banner string
if bRet
   // Consume banner
   //## check if is ok
   ::oSocket:ReceiveLine()
endif
return bRet

//
// Close socket
//
METHOD Close() CLASS TPOP3
local bRet

if ::oSocket:SendString( "QUIT" +CHR(13)+CHR(10) )
   // Banner
   //## check if is ok
   ::oSocket:ReceiveLine()
endif

bRet := ::oSocket:Close()

return bRet

/****m* TPop3/TPop3:Login
*  NAME
*    Login - login into POP3 server
*  SYNOPSIS
*    Login( cUser, cPwd )
*  PURPOSE
*    Login into POP3 server
*  EXAMPLE
*    oSock := TPop3():New() )
*    oSock:Connect( "pop3.server-dummy.com", 110 )
*    oSock:Login( "user", "password" )
*  SEE ALSO
*    TPop3:New
**********
*/
METHOD Login( cUser, cPwd ) CLASS TPOP3
LOCAL cLine
LOCAL bRet := .T.
if ::oSocket:SendString( "USER " +cUser +CHR(13)+CHR(10) )
   // Consume reply
   cLine := ::oSocket:ReceiveLine()
   bRet  := (LEFT(cLine,3)=="+OK")
   if bRet .AND. ::oSocket:SendString( "PASS " +cPwd +CHR(13)+CHR(10) )
      // Consume reply
      cLine := ::oSocket:ReceiveLine()
      bRet  := (LEFT(cLine,3)=="+OK")
   endif
endif
return bRet

//
// List messages
//
METHOD List( lFullInfo ) CLASS TPOP3
local aRet := {}
local cMsg
local nSpace, cMsgID, cSize, cInfo, nPos, cDmm, cSubject

if ::oSocket:SendString( "LIST" +CHR(13)+CHR(10) )
   // Banner
   //## check if is ok
   ::oSocket:ReceiveLine()
   while .T.
      cMsg := ::oSocket:ReceiveLine()
      if cMsg=="."
         exit
      endif
      //? cMsg
      nSpace := at( " ", cMsg )
      cMsgID := alltrim(substr( cMsg, 1, nSpace ))
      cSize  := alltrim(substr( cMsg, nSpace ))
      aadd( aRet, { cMsgID, val(cSize) } )
   enddo

   if lFullInfo
      for nPos := 1 to len( aRet )
         cInfo    := ::GetMessageHeader( aRet[nPos][1] )

         cSubject := ""
         if at( "Subject:", cInfo )>0
            cDmm := substr( cInfo, at( "Subject:", cInfo )+8 )
            cSubject := substr( cDmm, 0, at( CHR(13)+CHR(10), cDmm )-1 )
         endif
         aadd( aRet[nPos], cSubject )
      next
   endif
endif
return aRet

//
// Get original text of mail
//
METHOD GetMessageHeader( cMessageID ) CLASS TPOP3
local cRet := ""
local cMsg

if ::oSocket:SendString( "TOP " +cMessageID +" 0" +CHR(13)+CHR(10) )
   // Banner
   //## check if is ok
   ::oSocket:ReceiveLine()
   while .T.
      cMsg := ::oSocket:ReceiveLine()
      if cMsg=="."
         exit
      endif
      cRet += cMsg +CHR(13)+CHR(10)
   enddo
endif
return cRet

//
// Get original text of mail
//
METHOD GetMessageText( cMessageID ) CLASS TPOP3
local cRet := ""
local cMsg

if ::oSocket:SendString( "RETR " +cMessageID +CHR(13)+CHR(10) )
   // Banner
   //## check if is ok
   ::oSocket:ReceiveLine()
   while .T.
      cMsg := ::oSocket:ReceiveLine()
      if cMsg=="."
         exit
      endif
      cRet += cMsg +CHR(13)+CHR(10)
   enddo
endif
return cRet

//
// Delete original text of mail
//
METHOD DeleteMessage( cMessageID ) CLASS TPOP3
local bRet := .T.

if ::oSocket:SendString( "DELE " +cMessageID +CHR(13)+CHR(10) )
   // Banner
   //## check if is ok
   ::oSocket:ReceiveLine()
endif
return bRet
