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

#include "minigui.ch"

*-----------------------------------------------------------------------------*
PROCEDURE _SetAddress ( ControlName , ParentForm , url )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) > 0

      _SetAddressControlProcedure ( ControlName , url , i )
      _HMG_aControlValue [i] := url

      IF _HMG_aControlType [i] == "LABEL"
         _HMG_aControlType [i] := "HYPERLINK"
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetAddressControlProcedure ( ControlName , url , i )
*-----------------------------------------------------------------------------*

   DO CASE
   CASE At( "@", url ) > 0

      _HMG_aControlProcedures [i] := {|| ShellExecute( 0, "open", "rundll32.exe", "url.dll,FileProtocolHandler mailto:" + url, , 1 ) }

   CASE At( "http", url ) > 0 .OR. File( url )

      _HMG_aControlProcedures [i] := {|| ShellExecute( 0, "open", url, , , 1 ) }

   CASE At( "file:\\", url ) > 0

      IF iswinnt()
         _HMG_aControlProcedures [i] := {|| ShellExecute( 0, "open", "explorer.exe", "/e," + url, , 1 ) }
      ELSE
         url := StrTran( url, "file:\\", "" )
         _HMG_aControlProcedures [i] := {|| ShellExecute( 0, "open", "explorer.exe", "/e,/select," + url + "\" + Directory( url + "\*.*" )[1][1], , 1 ) }
      ENDIF

   CASE At( "proc:\\", url ) > 0

      url := StrTran( url, "proc:\\", "" )
#if defined( __XHARBOUR__ ) || ( ( __HARBOUR__ - 0 ) < 0x030200 )
      IF ( Type( SubStr( url, 1, At( "(", url ) - 1 ) + "()" ) == "UI" ) 
#else
      IF hb_IsFunction( SubStr( url, 1, At( "(", url ) - 1 ) )
#endif
         _HMG_aControlProcedures [i] := &( '{||' + url + '}' )
      ELSE
         MsgMiniGuiError ( "Control " + ControlName + " Of " + GetParentFormName( i ) + " must have a valid procedure name defined." )
      ENDIF

   OTHERWISE

      MsgMiniGuiError ( "Control " + ControlName + " Of " + GetParentFormName( i ) + " must have a valid email, url or file defined." )

   ENDCASE

RETURN
