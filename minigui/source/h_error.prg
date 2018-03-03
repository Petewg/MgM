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
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2017, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
# define __SYSDATA__
#endif
#include "minigui.ch"
#include "error.ch"

*-----------------------------------------------------------------------------*
INIT PROCEDURE ClipInit()
*-----------------------------------------------------------------------------*

   IF "95" $ WindowsVersion()[1]
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

   cMessage += iif( hb_defaultValue( lAddText, .T. ), " Program terminated.", "" )

RETURN Eval( ErrorBlock(), _HMG_GenError( cMessage ) )

*-----------------------------------------------------------------------------*
STATIC FUNCTION _HMG_GenError( cMsg )
*-----------------------------------------------------------------------------*
   LOCAL oError := ErrorNew()

   oError:SubSystem   := "MGERROR"
   oError:SubCode     := 0
   oError:Severity    := ES_CATASTROPHIC
   oError:Description := cMsg
   oError:Operation   := NIL

RETURN oError

*-----------------------------------------------------------------------------*
FUNCTION MiniGuiVersion
*-----------------------------------------------------------------------------*

RETURN( "Harbour MiniGUI Extended Edition 18.01 (" + iif( IsExe64(), "64", "32" ) + "-bit)" )
