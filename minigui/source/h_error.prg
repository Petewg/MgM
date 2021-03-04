/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"
#include "error.ch"
#include "hbver.ch"

*-----------------------------------------------------------------------------*
INIT PROCEDURE ClipInit()
*-----------------------------------------------------------------------------*

   IF os_isWin95()
      MsgExclamation( "The " + hb_ArgV( 0 ) + " file" + CRLF + ;
         "expects a newer version of Windows." + CRLF + ;
         "Upgrade your Windows version.", "Error Starting Program", , .F., .T. )

      ExitProcess( 1 )

   ENDIF

   Init()

RETURN

*-----------------------------------------------------------------------------*
EXIT PROCEDURE ClipExit()
*-----------------------------------------------------------------------------*

   ExitProcess()

RETURN

#ifndef __XHARBOUR__
PROCEDURE hb_GTSYS

   REQUEST HB_GT_GUI_DEFAULT

RETURN

#endif
*-----------------------------------------------------------------------------*
*-Date Created: 01-01-2003
*-Author: Antonio Novo <antonionovo@gmail.com>
*-Modified by Grigory Filatov at 24-08-2014
*-----------------------------------------------------------------------------*
FUNCTION MsgMiniGuiError( cMessage, lAddText )
*-----------------------------------------------------------------------------*

   IF hb_defaultValue( lAddText, .T. )
      cMessage += " Program terminated."
   ENDIF

RETURN Eval( ErrorBlock(), HMG_GenError( cMessage ) )

*-----------------------------------------------------------------------------*
STATIC FUNCTION HMG_GenError( cMsg )
*-----------------------------------------------------------------------------*
   LOCAL oError := ErrorNew()

   oError:SubSystem   := "MGERROR"
   oError:SubCode     := 0
   oError:Severity    := ES_CATASTROPHIC
   oError:Description := cMsg
   oError:Operation   := NIL

RETURN oError

#define MG_VERSION "Harbour MiniGUI Extended Edition 21.02 ("
*-----------------------------------------------------------------------------*
FUNCTION MiniGuiVersion( nVer )
*-----------------------------------------------------------------------------*
#ifndef __XHARBOUR__
   LOCAL cVer := MG_VERSION + hb_ntos( hb_Version( HB_VERSION_BITWIDTH ) ) + "-bit)"
#else
   LOCAL cVer := MG_VERSION + iif( IsExe64(), "64", "32" ) + "-bit)"
#endif
   LOCAL anOfs

   cVer += " " + HMG_CharsetName()

   anOfs := { Len( cVer ), 40, 15 }

   hb_default( @nVer, 0 )

   IF nVer > 2
      nVer := 2
   ELSEIF nVer < 0
      nVer := 0
   ENDIF

RETURN Left( cVer, anOfs[ nVer + 1 ] )
