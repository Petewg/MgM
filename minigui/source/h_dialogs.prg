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
#define __SYSDATA__
#endif
#include 'minigui.ch'

*-----------------------------------------------------------------------------*
FUNCTION GetColor( aInitColor )
*-----------------------------------------------------------------------------*
   LOCAL aRetVal [3] , nColor , nInitColor

   IF IsArrayRGB ( aInitColor )
      nInitColor := RGB ( aInitColor [1] , aInitColor [2] , aInitColor [3] )
   ENDIF

   IF ( nColor := ChooseColor ( NIL, nInitColor ) ) != -1
      aRetVal := nRGB2Arr ( nColor )
   ENDIF

RETURN aRetVal

*-----------------------------------------------------------------------------*
FUNCTION GetFolder( cTitle, cInitPath, nFlags, lNewFolderButton ) // JK HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
RETURN C_BrowseForFolder( NIL, cTitle, hb_defaultValue( nFlags, BIF_USENEWUI + BIF_VALIDATE + ;
   iif( hb_defaultValue( lNewFolderButton, .T. ), 0, BIF_NONEWFOLDERBUTTON ) ), NIL, cInitPath )

*-----------------------------------------------------------------------------*
FUNCTION BrowseForFolder( nFolder, nFlags, cTitle, cInitPath ) // Contributed By Ryszard Rylko
*-----------------------------------------------------------------------------*
RETURN C_BrowseForFolder( NIL, cTitle, hb_defaultValue( nFlags, ;
   hb_BitOr( BIF_NEWDIALOGSTYLE, BIF_EDITBOX, BIF_VALIDATE ) ), nFolder, cInitPath )

*-----------------------------------------------------------------------------*
FUNCTION GetFile( aFilter, title, cIniFolder, multiselect, lNoChangeCurDir, nFilterIndex )
*-----------------------------------------------------------------------------*
   LOCAL fileslist As Array
   LOCAL cFilter As String
   LOCAL n, files

   hb_default( @multiselect, .F. )
   hb_default( @nFilterIndex, 1 )

   IF ISARRAY( aFilter )
      AEval( aFilter, { | x | cFilter += x[1] + Chr( 0 ) + x[2] + Chr( 0 ) } )
      cFilter += Chr( 0 )
   ENDIF

   files := C_GetFile ( cFilter, title, cIniFolder, multiselect, lNoChangeCurDir, nFilterIndex )

   IF multiselect
      IF Len( files ) > 0
         IF ValType( files ) == "A"
            FOR n := 1 TO Len( files )
               IF At( "\\", files[n] ) > 0 .AND. Left( files[n], 2 ) != "\\"
                  files[n] := StrTran( files[n] , "\\", "\" )
               ENDIF
            NEXT
            fileslist := AClone( files )
         ELSE
            AAdd( fileslist, files )
         ENDIF
      ENDIF
   ELSE
      fileslist := files
   ENDIF

RETURN ( fileslist )

*-----------------------------------------------------------------------------*
FUNCTION Putfile( aFilter, title, cIniFolder, lNoChangeCurDir, cDefFileName, ;
   /*@*/nFilterIndex, lPromptOverwrite ) //  p.d. 12/05/2016 added lPromptOverwrite
*-----------------------------------------------------------------------------*
   LOCAL cFilter As String

   hb_default( @cDefFileName, "" )
   hb_default( @nFilterIndex, 1 )

   IF ISARRAY( aFilter )
      AEval( aFilter, { | x | cFilter += x[1] + Chr( 0 ) + x[2] + Chr( 0 ) } )
      cFilter += Chr( 0 )
   ENDIF

RETURN C_PutFile ( cFilter, title, cIniFolder, lNoChangeCurDir, cDefFileName, @nFilterIndex, hb_defaultValue( lPromptOverwrite, .F. ) )

*-----------------------------------------------------------------------------*
FUNCTION GetFont( cInitFontName , nInitFontSize , lBold , lItalic , anInitColor , lUnderLine , lStrikeOut , nCharset )
*-----------------------------------------------------------------------------*
   LOCAL RetArray , rgbcolor := 0

   hb_default( @cInitFontName, "" )
   hb_default( @nInitFontSize, 0 )
   hb_default( @lBold, .F. )
   hb_default( @lItalic, .F. )
   hb_default( @lUnderLine, .F. )
   hb_default( @lStrikeOut, .F. )
   hb_default( @nCharSet, 0 )

   IF IsArrayRGB( anInitColor )
      rgbcolor := RGB( anInitColor [1] , anInitColor [2] , anInitColor [3] )
   ENDIF

   RetArray := ChooseFont( cInitFontName , nInitFontSize , lBold , lItalic , rgbcolor , lUnderLine , lStrikeOut , nCharSet )

   IF Empty( RetArray [1] )
      RetArray [5] := { Nil , Nil , Nil }
   ELSE
      rgbcolor := RetArray [5]
      RetArray [5] := nRGB2Arr( rgbcolor )
   ENDIF

RETURN RetArray
