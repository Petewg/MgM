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

#include "hbclass.ch"
#include "common.ch"

#define KEY_READ        25
#define KEY_WRITE       6
#define KEY_ALL_ACCESS  63

#define REG_SZ    1
#define REG_DWORD 4

#define ERROR_SUCCESS   0
#define KEY_WOW64_64KEY 0x0100   // Access a 64-bit key from either a 32-bit or 64-bit application

/*
 * TReg32 Class
*/

CREATE CLASS TReg32

   EXPORTED:
   VAR cRegKey
   VAR nHandle
   VAR nError
   VAR lError

   METHOD New( nKey, cRegKey, lShowError )
   METHOD Create( nKey, cRegKey, lShowError )
   METHOD Get( cRegVar, uVar )
   METHOD Set( cRegVar, uVar )
   METHOD Delete( cRegVar )
   METHOD KeyDelete( cSubKey )
   METHOD Close() BLOCK {|Self| iif( ::lError, , RegCloseKey( ::nHandle ) ) }

ENDCLASS


METHOD New( nKey, cRegKey, lShowError ) CLASS TReg32

   LOCAL nReturn, nHandle := 0

   DEFAULT cRegKey TO ""

   nReturn := RegOpenKeyExA( nKey, cRegKey, , ;
      iif( IsWow64(), hb_BitOr( KEY_ALL_ACCESS, KEY_WOW64_64KEY ), KEY_ALL_ACCESS ), @nHandle )
   IF nReturn != ERROR_SUCCESS
      nReturn := RegOpenKeyExA( nKey, cRegKey, , KEY_READ, @nHandle )
   ENDIF

   ::lError := ( nReturn != ERROR_SUCCESS )
   IF ::lError
      IF lShowError == NIL .OR. lShowError == .T.
         MsgStop( "Error opening TReg32 object (" + hb_ntos( nReturn ) + ")" )
      ENDIF
   ELSE
      ::cRegKey := cRegKey
      ::nHandle := nHandle
   ENDIF

RETURN Self


METHOD Create( nKey, cRegKey, lShowError ) CLASS TReg32

   LOCAL nReturn, nHandle := 0

   DEFAULT cRegKey TO ""

   nReturn := RegCreateKey( nKey, cRegKey, @nHandle )

   ::lError := ( nReturn != ERROR_SUCCESS )
   IF ::lError
      IF lShowError == NIL .OR. lShowError == .T.
         MsgStop( "Error creating TReg32 object (" + hb_ntos( nReturn ) + ")" )
      ENDIF
   ELSE
      ::nError := RegOpenKeyExA( nKey, cRegKey, , ;
         iif( IsWow64(), hb_BitOr( KEY_ALL_ACCESS, KEY_WOW64_64KEY ), KEY_ALL_ACCESS ), @nHandle )
      ::cRegKey := cRegKey
      ::nHandle := nHandle
   ENDIF

RETURN Self


METHOD Get( cRegVar, uVar ) CLASS TReg32

   LOCAL cValue := ""
   LOCAL nType := 0
   LOCAL nLen := 0
   LOCAL cType

   IF ! ::lError
      DEFAULT cRegVar TO ''
      cType := ValType( uVar )

      ::nError := RegQueryValueExA( ::nHandle, cRegVar, 0, @nType, @cValue, @nLen )

      IF Empty( ::nError )
         uVar := cValue
         SWITCH cType
         CASE "N"
            uVar := Bin2U( uVar )
            EXIT
         CASE "D"
            uVar := CToD( uVar )
            EXIT
         CASE "L"
            uVar := ( Upper( uVar ) == ".T." )
         ENDSWITCH
      ENDIF
   ENDIF

RETURN uVar


METHOD Set( cRegVar, uVar ) CLASS TReg32

   LOCAL nType, cType

   IF ! ::lError
      DEFAULT cRegVar TO ''
      cType := ValType( uVar )

      IF cType == 'N'
         nType := REG_DWORD
      ELSE
         nType := REG_SZ
         SWITCH cType
         CASE "D"
            uVar := DToC( uVar )
            EXIT
         CASE "L"
            uVar := iif( uVar, ".T.", ".F." )
         ENDSWITCH
      ENDIF

      ::nError := RegSetValueExA( ::nHandle, cRegVar, 0, nType, @uVar )
   ENDIF

RETURN NIL


METHOD Delete( cRegVar ) CLASS TReg32

   IF ! ::lError
      ::nError := RegDeleteValueA( ::nHandle, cRegVar )
   ENDIF

RETURN NIL


METHOD KeyDelete( cSubKey ) CLASS TReg32

   IF ! ::lError
      ::nError := RegDeleteKey( ::nHandle, cSubkey )
   ENDIF

RETURN NIL


STATIC FUNCTION Bin2U( c )

   LOCAL l := Bin2L( c )

RETURN iif( l < 0, l + 4294967296, l )

/*
 * Registry Access Functions
*/

FUNCTION IsRegistryKey( nKey, cRegKey )

   LOCAL oReg
   LOCAL lExist

   oReg   := TReg32():New( nKey, cRegKey, .F. )
   lExist := ( oReg:lError == .F. )

   oReg:Close()

RETURN lExist


FUNCTION CreateRegistryKey( nKey, cRegKey )

   LOCAL oReg
   LOCAL lSuccess

   oReg     := TReg32():Create( nKey, cRegKey, .F. )
   lSuccess := ( oReg:lError == .F. )

   oReg:Close()

RETURN lSuccess


FUNCTION GetRegistryValue( nKey, cRegKey, cRegVar, cType )

   LOCAL oReg
   LOCAL uVal

   DEFAULT cRegVar TO '', cType TO 'C'

   oReg := TReg32():New( nKey, cRegKey, .F. )

   IF ! oReg:lError

      DO CASE
      CASE cType == 'N'
         uVal := 0
      CASE cType == 'D'
         uVal := CToD( '' )
      CASE cType == 'L'
         uVal := .F.
      OTHERWISE
         uVal := ''
      ENDCASE

      uVal := oReg:Get( cRegVar, uVal )
      IF oReg:nError != ERROR_SUCCESS
         uVal := NIL
      ENDIF

   ENDIF

   oReg:Close()

RETURN uVal


FUNCTION SetRegistryValue( nKey, cRegKey, cRegVar, uVal )

   LOCAL oReg
   LOCAL lSuccess := .F.

   DEFAULT cRegVar TO ''

   oReg := TReg32():New( nKey, cRegKey, .F. )

   IF ! oReg:lError
      oReg:Set( cRegVar, uVal )
      lSuccess := ( oReg:nError == ERROR_SUCCESS )
   ENDIF

   oReg:Close()

RETURN lSuccess


FUNCTION DeleteRegistryVar( nKey, cRegKey, cRegVar )

   LOCAL oReg
   LOCAL lSuccess := .F.

   DEFAULT cRegVar TO ''

   oReg := TReg32():New( nKey, cRegKey, .F. )

   IF ! oReg:lError
      oReg:Delete( cRegVar )
      lSuccess := ( oReg:nError == ERROR_SUCCESS )
   ENDIF

   oReg:Close()

RETURN lSuccess


FUNCTION DeleteRegistryKey( nKey, cRegKey, cSubKey )

   LOCAL oReg
   LOCAL lSuccess := .F.

   oReg := TReg32():New( nKey, cRegKey, .F. )

   IF ! oReg:lError
      oReg:KeyDelete( cSubKey )
      lSuccess := ( oReg:nError == ERROR_SUCCESS )
   ENDIF

   oReg:Close()

RETURN lSuccess

/*
 * C-level
*/
#pragma BEGINDUMP

#include <mgdefs.h>

// http://msdn.microsoft.com/en-us/library/ms684139(VS.85).aspx
typedef BOOL ( WINAPI *LPFN_ISWOW64PROCESS ) ( HANDLE, PBOOL );

HB_FUNC( ISWOW64 )
{
   BOOL bIsWow64 = FALSE;

   LPFN_ISWOW64PROCESS fnIsWow64Process;

   fnIsWow64Process = ( LPFN_ISWOW64PROCESS ) GetProcAddress( GetModuleHandle( "kernel32" ), "IsWow64Process" );
   if( NULL != fnIsWow64Process )
   {
      fnIsWow64Process( GetCurrentProcess(), &bIsWow64 );
   }

   hb_retl( bIsWow64 );
}

#pragma ENDDUMP
