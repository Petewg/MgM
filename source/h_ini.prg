/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

INI Files support procedures
(c) 2003 Grigory Filatov
(c) 2003 Janusz Pora

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

#include 'minigui.ch'
#include 'fileio.ch'

*-----------------------------------------------------------------------------*
FUNCTION _SetGetLogFile( cFile )
*-----------------------------------------------------------------------------*
   LOCAL cOld
   STATIC MLog_File

   cOld := MLog_File
   IF cFile != NIL
      MLog_File := cFile
      RETURN MLog_File
   ENDIF

RETURN cOld

*-----------------------------------------------------------------------------*
#ifndef __XHARBOUR__
FUNCTION _LogFile( lCrLf, ... )
#else
FUNCTION _LogFile( ... )
#endif
*-----------------------------------------------------------------------------*
   LOCAL hFile, i, xVal, cTp
   LOCAL aParams := hb_AParams()
   LOCAL nParams := Len( aParams )
   LOCAL cFile := hb_defaultValue( _SetGetLogFile(), GetStartUpFolder() + "\_MsgLog.txt" )
#ifdef __XHARBOUR__
   LOCAL lCrLf
#endif
   IF !Empty( cFile )
      hFile := iif( File( cFile ), FOpen( cFile, FO_READWRITE ), FCreate( cFile, FC_NORMAL ) )
      IF hFile == F_ERROR
         RETURN .F.
      ENDIF
      FSeek( hFile, 0, FS_END )
      IF nParams > 1
#ifdef __XHARBOUR__
         lCrLf := aParams[ 1 ]
#endif
         IF hb_defaultValue( lCrLf, .T. )
            FWrite( hFile, CRLF, 2 )
         ENDIF
         FOR i := 2 TO nParams
            xVal := aParams[ i ]
            cTp  := ValType( xVal )
            IF     cTp == 'C' ; xVal := iif( Empty( xVal ), "'" + "'", Trim( xVal ) )
            ELSEIF cTp == 'N' ; xVal := hb_ntos( xVal )
            ELSEIF cTp == 'L' ; xVal := iif( xVal, ".T.", ".F." )
#ifdef __XHARBOUR__
            ELSEIF cTp == 'D' ; xVal := DToC( xVal )
#else
            ELSEIF cTp == 'D' ; xVal := hb_DToC( xVal, 'DD.MM.YYYY' )
#endif
            ELSEIF cTp == 'A' ; xVal := "ARRAY["  + hb_ntos( Len( xVal ) ) + "]"
            ELSEIF cTp == 'H' ; xVal :=  "HASH["  + hb_ntos( Len( xVal ) ) + "]"
            ELSEIF cTp == 'B' ; xVal := "'" + "B" + "'"
            ELSEIF cTp == 'T' ; xVal := hb_TSToStr( xVal, .T. )
            ELSEIF cTp == 'U' ; xVal := 'NIL'
            ELSE              ; xVal := "'" + cTp + "'"
            ENDIF
            FWrite( hFile, xVal + Chr( 9 ) )
         NEXT
      ELSE
         FWrite( hFile, CRLF, 2 )
      ENDIF
      FClose( hFile )
   ENDIF

RETURN .T.

*-----------------------------------------------------------------------------*
FUNCTION _BeginIni( cIniFile )
*-----------------------------------------------------------------------------*
   LOCAL hFile

   IF At( "\", cIniFile ) == 0
      cIniFile := ".\" + cIniFile
   ENDIF

   hFile := iif( File( cIniFile ), FOpen( cIniFile, FO_READ + FO_SHARED ), FCreate( cIniFile ) )

   IF hFile == F_ERROR
      MsgInfo( "Error opening a file INI. DOS ERROR: " + Str( FError(), 2, 0 ) )
      Return( -1 )
   ELSE
      _HMG_ActiveIniFile := cIniFile
   ENDIF

   FClose( hFile )

RETURN( 0 )

*-----------------------------------------------------------------------------*
FUNCTION _GetIni( cSection, cEntry, cDefault, uVar )
*-----------------------------------------------------------------------------*
   LOCAL cVar As String

   IF !Empty( _HMG_ActiveIniFile )
      __defaultNIL( @cDefault, cVar )
      __defaultNIL( @uVar, cDefault )
      cVar  := GetPrivateProfileString( cSection, cEntry, xChar( cDefault ), _HMG_ActiveIniFile )
   ELSE
      IF cDefault != NIL
         cVar := xChar( cDefault )
      ENDIF
   ENDIF

   uVar := xValue( cVar, ValType( uVar ) )

RETURN uVar

*-----------------------------------------------------------------------------*
FUNCTION _SetIni( cSection, cEntry, cValue )
*-----------------------------------------------------------------------------*
   LOCAL ret As Logical

   IF !Empty( _HMG_ActiveIniFile )
      ret := WritePrivateProfileString( cSection, cEntry, xChar( cValue ), _HMG_ActiveIniFile )
   ENDIF

RETURN ret

*-----------------------------------------------------------------------------*
FUNCTION _DelIniEntry( cSection, cEntry )
*-----------------------------------------------------------------------------*
   LOCAL ret As Logical

   IF !Empty( _HMG_ActiveIniFile )
      ret := DelIniEntry( cSection, cEntry, _HMG_ActiveIniFile )
   ENDIF

RETURN ret

*-----------------------------------------------------------------------------*
FUNCTION _DelIniSection( cSection )
*-----------------------------------------------------------------------------*
   LOCAL ret As Logical

   IF !Empty( _HMG_ActiveIniFile )
      ret := DelIniSection( cSection, _HMG_ActiveIniFile )
   ENDIF

RETURN ret

*-----------------------------------------------------------------------------*
FUNCTION _EndIni()
*-----------------------------------------------------------------------------*
   _HMG_ActiveIniFile := ''

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION xChar( xValue )
*-----------------------------------------------------------------------------*
   LOCAL cType := ValType( xValue )
   LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS )

   DO CASE
   CASE cType $  "CM";  cValue := xValue
   CASE cType == "N" ;  nDecimals := iif( xValue == Int( xValue ), 0, nDecimals ) ; cValue := LTrim( Str( xValue, 20, nDecimals ) )
   CASE cType == "D" ;  cValue := DToS( xValue )
   CASE cType == "L" ;  cValue := iif( xValue, "T", "F" )
   CASE cType == "A" ;  cValue := AToC( xValue )
   CASE cType $  "UE";  cValue := "NIL"
   CASE cType == "B" ;  cValue := "{|| ... }"
   CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

RETURN cValue

*-----------------------------------------------------------------------------*
FUNCTION xValue( cValue, cType )
*-----------------------------------------------------------------------------*
   LOCAL xValue

   DO CASE
   CASE cType $  "CM";  xValue := cValue
   CASE cType == "D" ;  xValue := SToD( cValue )
   CASE cType == "N" ;  xValue := Val( cValue )
   CASE cType == "L" ;  xValue := ( cValue == 'T' )
   CASE cType == "A" ;  xValue := CToA( cValue )
   OTHERWISE;           xValue := NIL                   // Nil, Block, Object
   ENDCASE

RETURN xValue

*-----------------------------------------------------------------------------*
FUNCTION AToC( aArray )
*-----------------------------------------------------------------------------*
   LOCAL elem, cElement, cType, cArray := ""

   FOR EACH elem IN aArray
      cElement := xChar( elem )
      IF ( cType := ValType( elem ) ) == "A"
         cArray += cElement
      ELSE
         cArray += Left( cType, 1 ) + Str( Len( cElement ), 4 ) + cElement
      ENDIF
   NEXT

RETURN( "A" + Str( Len( cArray ), 4 ) + cArray )

*-----------------------------------------------------------------------------*
FUNCTION CToA( cArray )
*-----------------------------------------------------------------------------*
   LOCAL cType, nLen, aArray := {}

   cArray := SubStr( cArray, 6 )    // strip off array and length
   WHILE Len( cArray ) > 0
      nLen := Val( SubStr( cArray, 2, 4 ) )
      IF ( cType := Left( cArray, 1 ) ) == "A"
         AAdd( aArray, CToA( SubStr( cArray, 1, nLen + 5 ) ) )
      ELSE
         AAdd( aArray, xValue( SubStr( cArray, 6, nLen ), cType ) )
      ENDIF
      cArray := SubStr( cArray, 6 + nLen )
   END

RETURN aArray

// JK HMG 1.0 experimental build 6
*-----------------------------------------------------------------------------*
FUNCTION _GetSectionNames( cIniFile )
*-----------------------------------------------------------------------------*
   // return 1-dimensional array with section list in cIniFile
   // or empty array if no sections are present
   LOCAL aSectionList := {}, cLista, aLista

   IF File( cIniFile )
      cLista := _GetPrivateProfileSectionNames( cIniFile )
      aLista := hb_ATokens( cLista, Chr( 0 ) )
      IF !Empty( aLista )
         AEval( aLista, {|cVal| iif( Empty( cVal ), , AAdd( aSectionList, cVal ) ) }, , Len( aLista ) -1 )
      ENDIF
   ELSE
      MsgStop( "Can`t open " + cIniFile, "Error" )
   ENDIF

RETURN aSectionList

*-----------------------------------------------------------------------------*
FUNCTION _GetSection( cSection, cIniFile )
*-----------------------------------------------------------------------------*
   // return 2-dimensional array with {key,value} pairs from section cSection in cIniFile
   LOCAL aKeyValueList := {}, cLista, aLista, i, n

   IF File( cIniFile )
      cLista := _GetPrivateProfileSection( cSection, cIniFile )
      aLista := hb_ATokens( cLista, Chr( 0 ) )
      IF !Empty( aLista )
         FOR i := 1 TO Len( aLista ) -1
            IF ( n := At( "=", aLista[ i ] ) ) > 0
               AAdd( aKeyValueList, { Left( aLista[ i ], n -1 ), SubStr( aLista[ i ], n + 1 ) } )
            ENDIF
         NEXT i
      ENDIF
   ELSE
      MsgStop( "Can`t open " + cIniFile, "Error" )
   ENDIF

RETURN aKeyValueList
