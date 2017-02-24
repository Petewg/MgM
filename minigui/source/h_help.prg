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
#include "fileio.ch"

*-----------------------------------------------------------------------------*
PROCEDURE SetHelpFile( cFile )
*-----------------------------------------------------------------------------*
   LOCAL hFile

   IF File( cFile )

      hFile := FOpen( cFile, FO_READ + FO_SHARED )

      _HMG_ActiveHelpFile := iif( FError() == 0, cFile, "" )

      IF Empty( _HMG_ActiveHelpFile )
         MsgAlert( "Error opening of help file. Error: " + Str( FError(), 2, 0 ), "Alert" )
      ENDIF

      FClose( hFile )

   ELSE

      MsgAlert( "Help file " + cFile + " is not found!", "Warning" )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE DisplayHelpTopic( xTopic , nMet )
*-----------------------------------------------------------------------------*
   LOCAL cParam := ""

   IF Empty( _HMG_ActiveHelpFile )
      RETURN
   ENDIF

   _HMG_nTopic := xTopic
   _HMG_nMet   := nMet

   __defaultNIL( @nMet, 0 )

   IF Right( AllTrim( Upper( _HMG_ActiveHelpFile ) ) , 4 ) == '.CHM'

      SWITCH ValType( xTopic )
      CASE 'N'
         cParam := '-mapid ' + hb_ntos( xTopic ) + ' ' + _HMG_ActiveHelpFile
         EXIT
      CASE 'C'
         cParam := '"' + _HMG_ActiveHelpFile + '::/' + AllTrim( xTopic ) + '"'
         EXIT
      CASE 'U'
         cParam := '"' + _HMG_ActiveHelpFile + '"'
      ENDSWITCH

      _Execute( _HMG_MainHandle , "open" , "hh.exe" , cParam , , SW_SHOW )

   ELSE

      __defaultNIL( @xTopic, 0 )

      WinHelp( _HMG_MainHandle , _HMG_ActiveHelpFile , nMet , xTopic )

   ENDIF

RETURN

*=============================================================================*
*                          Auxiliary Functions
*=============================================================================*

// cFieldList is a comma delimited list of fields, f.e. "First,Last,Birth,Age".
*-----------------------------------------------------------------------------*
FUNCTION HMG_DbfToArray( cFieldList, bFor, bWhile, nNext, nRec, lRest )
*-----------------------------------------------------------------------------*
   LOCAL aRet := {}, nRecNo := RecNo(), bLine

   IF Empty( cFieldList )
      cFieldList := ""
      AEval( DbStruct(), { | a | cFieldList += "," + a[ 1 ] } )
      cFieldList := SubStr( cFieldList, 2 )
   ENDIF

   bLine := &( "{||{" + cFieldList + "}}" )

   dbEval( { || AAdd( aRet, Eval( bLine ) ) }, bFor, bWhile, nNext, nRec, lRest )

   dbGoto( nRecNo )

RETURN aRet

*-----------------------------------------------------------------------------*
FUNCTION HMG_ArrayToDBF( aData, cFieldList, bProgress )
*-----------------------------------------------------------------------------*
   LOCAL aFldName, aFieldPos, aFieldTyp, lFldName
   LOCAL nCols, nCol, nRow, nRows, aRow, uVal

   IF ValType( cFieldList ) == 'A'
      aFldName := cFieldList
   ELSEIF ValType( cFieldList ) == 'C'
      aFldName := hb_ATokens( cFieldList, ',' )
   ENDIF

   lFldName := ( Empty( aFldName ) )
   nCols := iif( lFldName, FCount(), Min( FCount(), Len( aFldName ) ) )
   aFieldPos := Array( nCols )
   aFieldTyp := Array( nCols )
   FOR nCol := 1 TO nCols
      aFieldPos[ nCol ] := iif( lFldName, nCol, FieldPos( aFldName[ nCol ] ) )
      aFieldTyp[ nCol ] := iif( lFldName, FieldType( nCol ), FieldType( aFieldPos[ nCol ] ) )
   NEXT

   nRows := Len( aData )
   IF ISBLOCK( bProgress )
      Eval( bProgress, 0, nRows )
   ENDIF

   FOR nRow := 1 TO nRows

      aRow := aData[ nRow ]
      REPEAT
         dbAppend()
      UNTIL NetErr()

      FOR nCol := 1 TO nCols

         IF ! Empty( aFieldPos[ nCol ] )

            IF ! Empty( uVal := aRow[ nCol ] )

               IF ! ( aFieldTyp[ nCol ] $ '+@' )

                  IF ValType( uVal ) != aFieldTyp[ nCol ]
                     uVal := ConvertType( uVal, aFieldTyp[ nCol ] )
                  ENDIF

                  IF ! Empty( uVal )
                     FieldPut( aFieldPos[ nCol ], uVal )
                  ENDIF

               ENDIF

            ENDIF

         ENDIF

      NEXT nCol

      dbUnLock()
      IF ISBLOCK( bProgress )
         Eval( bProgress, nRow, nRows )
      ENDIF

   NEXT nRow

RETURN .T.

#ifdef __XHARBOUR__
#include "hbcompat.ch"
#else
#xcommand TRY              => BEGIN SEQUENCE WITH {|__o| break(__o) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif
*-----------------------------------------------------------------------------*
STATIC FUNCTION ConvertType( uVal, cTypeDst )
*-----------------------------------------------------------------------------*
   LOCAL cTypeSrc := ValType( uVal )

   IF cTypeDst != cTypeSrc

      DO CASE
      CASE cTypeDst $ 'CM'
         uVal := hb_ValToStr( uVal )

      CASE cTypeDst == 'D'
         DO CASE
         CASE cTypeSrc == 'T'
            uVal := StoD( Left( hb_TToS( uVal ), 8 ) )
         CASE cTypeSrc == 'C'
            uVal := CToD( uVal )
         OTHERWISE
            uVal := CToD( '' )
         ENDCASE

      CASE cTypeDst == 'L'
         DO CASE
         CASE cTypeSrc $ 'LN'
            uVal := ! Empty( uVal )
         CASE cTypeSrc == 'C'
            uVal     := Upper( uVal ) $ "Y,YES,T,.T.,TRUE"
         OTHERWISE
            uVal := .F.
         ENDCASE

      CASE cTypeDst == 'N'
         DO CASE
         CASE cTypeSrc == 'C'
            uVal := Val( uVal )
         OTHERWISE
            uVal := 0
         ENDCASE

      CASE cTypeDst == 'T'
         DO CASE
         CASE cTypeSrc == 'D'
            uVal := hb_SToT( DtoS( uVal ) + "000000.000" )
         CASE cTypeSrc == 'C'
            uVal := hb_CToT( uVal )
         OTHERWISE
            uVal := hb_CToT( '' )
         ENDCASE

      OTHERWISE
         uVal := nil
      ENDCASE

   ENDIF

RETURN uVal

*-----------------------------------------------------------------------------*
FUNCTION HMG_DbfToExcel( cFieldList, aHeader, bFor, bWhile, nNext, nRec, lRest )
*-----------------------------------------------------------------------------*
   LOCAL nRecNo := RecNo(), bLine
   LOCAL oExcel, oBook, oSheet, oRange
   LOCAL nCols, nRow := 1

   IF Empty( cFieldList )
      cFieldList := ""
      AEval( dbStruct(), { | x | cFieldList += "," + x[ 1 ] } )
      cFieldList := SubStr( cFieldList, 2 )
   ENDIF

   hb_default( @aHeader, hb_ATokens( cFieldList, "," ) )

   TRY
      oExcel := CreateObject( "Excel.Application" )
   CATCH
      RETURN .F.
   END

   IF oExcel == Nil
      MsgAlert( "Excel not installed", "Warning" )
      RETURN .F.
   ENDIF

   oBook := oExcel:WorkBooks:Add()
   oSheet := oBook:ActiveSheet

   nCols := Len( aHeader )
   oRange := oSheet:Range( oSheet:Columns( nRow ), oSheet:Columns( nCols ) )

   oExcel:ScreenUpdating := .F.

   oRange:Rows( nRow ):Value := aHeader
   oRange:Rows( nRow ):Font:Bold := .T.

   bLine := &( "{||{" + cFieldList + "}}" )
   IF Empty( bWhile ) .AND. Empty( nNext ) .AND. Empty( nRec ) .AND. Empty( lRest )
      dbGoTop()
   ENDIF

   dbEval( { || oRange:Rows( ++nRow ):Value := Eval( bLine ), nRow }, bFor, bWhile, nNext, nRec, lRest )
   dbGoto( nRecNo )

   oRange:AutoFit()

   oExcel:ScreenUpdating := .T.
   oExcel:Visible := .T.

RETURN .T.
