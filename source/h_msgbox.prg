/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

MsgBox code rewrotten by Jacek Kubica <kubica@wssk.wroc.pl>
(c) 2006 HMG Experimental Build 16g

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
   Copyright 1999-2016, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"
#include "i_winuser.ch"

*-----------------------------------------------------------------------------*
FUNCTION MsgYesNo ( Message , Title , RevertDefault , nIcon , lSysModal , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_YESNO

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONQUESTION, MB_USERICON )

   IF hb_defaultValue( RevertDefault, .F. )
      nStyle += MB_DEFBUTTON2
   ENDIF

RETURN ( _MsgBox( Message, Title, nStyle, nIcon, lSysModal, lTopMost ) == IDYES )

*-----------------------------------------------------------------------------*
FUNCTION MsgYesNoCancel ( Message , Title , nIcon , lSysModal , nDefaultButton , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL RetVal, nStyle := MB_YESNOCANCEL

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONQUESTION, MB_USERICON )

   SWITCH hb_defaultValue( nDefaultButton, 1 )
   CASE 2
      nStyle += MB_DEFBUTTON2
      EXIT
   CASE 3
      nStyle += MB_DEFBUTTON3
   END SWITCH

   RetVal := _MsgBox( Message, Title, nStyle, nIcon, lSysModal, lTopMost )

   IF RetVal == IDYES
      RETURN 1
   ELSEIF RetVal == IDNO
      RETURN 0
   ENDIF

RETURN ( -1 )

*-----------------------------------------------------------------------------*
FUNCTION MsgRetryCancel ( Message , Title , nIcon , lSysModal , nDefaultButton , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_RETRYCANCEL

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONQUESTION, MB_USERICON )

   IF hb_defaultValue( nDefaultButton, 1 ) == 2
      nStyle += MB_DEFBUTTON2
   ENDIF

RETURN ( _MsgBox( Message, Title, nStyle, nIcon, lSysModal, lTopMost ) == IDRETRY )

*-----------------------------------------------------------------------------*
FUNCTION MsgOkCancel ( Message , Title , nIcon , lSysModal , nDefaultButton , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_OKCANCEL

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONQUESTION, MB_USERICON )

   IF hb_defaultValue( nDefaultButton, 1 ) == 2
      nStyle += MB_DEFBUTTON2
   ENDIF

RETURN ( _MsgBox( Message, Title, nStyle, nIcon, lSysModal, lTopMost ) == IDOK )

*-----------------------------------------------------------------------------*
FUNCTION MsgInfo ( Message , Title , nIcon , lSysModal , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_OK

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONINFORMATION, MB_USERICON )

RETURN _MsgBox( Message, hb_defaultValue( Title, 'Information' ), nStyle, nIcon, lSysModal, lTopMost )

*-----------------------------------------------------------------------------*
FUNCTION MsgStop ( Message , Title , nIcon , lSysModal , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_OK

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONSTOP, MB_USERICON )

RETURN _MsgBox( Message, hb_defaultValue( Title, 'Stop' ), nStyle, nIcon, lSysModal, lTopMost )

*-----------------------------------------------------------------------------*
FUNCTION MsgExclamation ( Message , Title , nIcon, lSysModal , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL nStyle := MB_OK

   nStyle += iif( Empty( hb_defaultValue( nIcon, 0 ) ), MB_ICONEXCLAMATION, MB_USERICON )

RETURN _MsgBox( Message, hb_defaultValue( Title, 'Alert' ), nStyle, nIcon, lSysModal, lTopMost )

*-----------------------------------------------------------------------------*
FUNCTION MsgBox ( Message , Title , lSysModal , lTopMost )
*-----------------------------------------------------------------------------*

RETURN _MsgBox( Message, Title, MB_OK, NIL, lSysModal, lTopMost )

*-----------------------------------------------------------------------------*
FUNCTION _MsgBox( cMessage , cTitle , nStyle , nIcon , lSysModal , lTopMost )
*-----------------------------------------------------------------------------*
   LOCAL cText

   DEFAULT cMessage TO '', cTitle TO ''

   IF ! ISCHARACTER( cMessage )
      IF ISARRAY( cMessage )
         cText := ''
         AEval( cMessage, { |x| cText += hb_ValToStr( x ) } )
         cMessage := cText
      ELSE
         cMessage := hb_ValToStr( cMessage )
      ENDIF
   ENDIF

   nStyle += iif( hb_defaultValue( lSysModal, .T. ), MB_SYSTEMMODAL, MB_APPLMODAL )

   IF hb_defaultValue( lTopMost, .T. )
      nStyle += MB_TOPMOST
   ENDIF

RETURN MessageBoxIndirect( , cMessage, cTitle, nStyle, nIcon )
