/*
 * $Id: tget.prg,v 1.116 2007/04/20 19:47:45 vszakats Exp $
 */

/*
 * Harbour Project source code:
 * Get Class
 *
 * Copyright 1999 Ignacio Ortiz de Z£niga <ignacio@fivetech.com>
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

#include "hbclass.ch"

#include "color.ch"
#include "common.ch"
#include "setcurs.ch"
#include "getexit.ch"
#include "inkey.ch"
#include "button.ch"
#include "hblang.ch"

/* TODO: :posInBuffer( <nRow>, <nCol> ) --> nPos
         Determines a position within the edit buffer based on screen
         coordinates.
         Xbase++ compatible method */

/* TOFIX: ::Minus [vszakats] */
/* TOFIX: ::DecPos [vszakats] */

#define GET_CLR_UNSELECTED      0
#define GET_CLR_ENHANCED        1

#define VK_SHIFT                16
#define VK_CONTROL              17
#define VK_MENU                 18
#define WM_LBUTTONDBLCLK        0x0203

#xtranslate _GetKeyState( <VKey> ) ;
      => ;
      CheckBit( GetKeyState( < VKey > ), 32768 )

/* ------------------------------------------------------------------------- */

CLASS Get

   EXPORTED:

   DATA BadDate        INIT .F.
   DATA Buffer
   DATA Cargo
   DATA Changed        INIT .F.
   DATA Clear          INIT .F.
   DATA Col
   DATA DecPos         INIT 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
   DATA ExitState
   DATA HasFocus       INIT .F.
   DATA Minus          INIT .F.
   DATA Name
   DATA Original
   DATA Pos            INIT 0
   DATA PostBlock
   DATA PreBlock
   DATA Reader
   DATA Rejected       INIT .F.
   DATA Row
   DATA SubScript
   DATA TypeOut        INIT .F.
#ifdef HB_COMPAT_C53
   DATA Control
   DATA Message
   DATA Caption        INIT ""
   DATA CapRow         INIT 0
   DATA CapCol         INIT 0
#endif
   DATA aKeyEvent      INIT {}

   PROTECTED:

   DATA cColorSpec
   DATA cPicture
   DATA bBlock
   DATA cType

   DATA cPicMask       INIT ""
   DATA cPicFunc       INIT ""
   DATA nMaxLen
   DATA lEdit          INIT .F.
   DATA lDecRev        INIT .F.
   DATA lPicComplex    INIT .F.
   DATA nDispLen
   DATA nDispPos       INIT 1
   DATA nOldPos        INIT 0
   DATA lCleanZero     INIT .F.
   DATA cDelimit
   DATA nMaxEdit
   DATA lMinus         INIT .F.
   DATA lMinusPrinted  INIT .F.
   DATA xVarGet

   VISIBLE:

   /* NOTE: This method is a Harbour extension */
   METHOD New( nRow, nCol, bVarBlock, cVarName, cPicture, cColorSpec )

   METHOD Assign()
#ifdef HB_COMPAT_XPP
   MESSAGE _Assign METHOD Assign()
#endif
   METHOD Type()
#ifdef HB_COMPAT_C53
   METHOD HitTest( nMRow, nMCol )
#endif
   METHOD Block( bBlock ) SETGET
   METHOD ColorSpec( cColorSpec ) SETGET
   METHOD Picture( cPicture ) SETGET
   /* NOTE: lForced is an undocumented Harbour parameter. Should not be used by app code. */
   METHOD Display( lForced )
   METHOD ColorDisp( cColorSpec )
   METHOD KillFocus()
   METHOD Reset()
   METHOD SetFocus()
   METHOD Undo()
   METHOD UnTransform( cBuffer )
   METHOD UpdateBuffer()
#ifdef HB_C52_UNDOC
   METHOD Reform()
#endif

   METHOD VarGet()
   /* NOTE: lReFormat is an undocumented Harbour parameter. Should not be used by app code. */
   METHOD VarPut( xValue, lReFormat )

   METHOD End()
#ifdef HB_COMPAT_XPP
   MESSAGE _End METHOD End()
#endif
   METHOD Home()
   MESSAGE Left( lDisplay ) METHOD _Left( lDisplay )
   MESSAGE Right( lDisplay ) METHOD _Right( lDisplay )
   METHOD ToDecPos()
   METHOD WordLeft()
   METHOD WordRight()

   /* NOTE: lDisplay is an undocumented Harbour parameter. Should not be used by app code. */
   METHOD BackSpace( lDisplay )
   MESSAGE Delete( lDisplay ) METHOD _Delete( lDisplay )
   METHOD DelEnd()
   METHOD DelLeft()
   METHOD DelRight()
   METHOD DelWordLeft()
   METHOD DelWordRight()

   METHOD Insert( cChar )
   METHOD OverStrike( cChar )

   METHOD SetKeyEvent( nKey, bKey, lCtrl, lShift, lAlt )
   METHOD DoKeyEvent ( nKey )

   METHOD Refresh()

   PROTECTED:

   METHOD DeleteAll()
   METHOD IsEditable( nPos )
   METHOD Input( cChar )
   METHOD PutMask( xValue, lEdit )
   METHOD FirstEditable()
   METHOD LastEditable()

ENDCLASS

/* ------------------------------------------------------------------------- */

METHOD New( nRow, nCol, bVarBlock, cVarName, cPicture, cColorSpec ) CLASS Get

   DEFAULT nRow       TO Row()
   DEFAULT nCol       TO Col()
   DEFAULT cVarName   TO ""
   DEFAULT bVarBlock  TO iif( ISCHARACTER( cVarName ), MemVarBlock( cVarName ), NIL )
   DEFAULT cColorSpec TO hb_ColorIndex( SetColor(), CLR_UNSELECTED ) + "," + hb_ColorIndex( SetColor(), CLR_ENHANCED )

   ::Row           := nRow
   ::Col           := nCol
   ::bBlock        := bVarBlock
   ::Name          := cVarName
   ::Picture       := cPicture
   ::ColorSpec     := cColorSpec
   IF Set( _SET_DELIMITERS )
      ::cDelimit      := Set( _SET_DELIMCHARS )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD Assign() CLASS Get

   if ::HasFocus
      ::VarPut( ::UnTransform(), .F. )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD UpdateBuffer() CLASS Get

   if ::HasFocus
      ::Buffer := ::PutMask( ::VarGet() )
      ::Display()
   ELSE
      ::PutMask( ::VarGet() )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

#ifdef HB_C52_UNDOC

METHOD Reform() CLASS Get

   if ::HasFocus
      ::Buffer := ::PutMask( ::xVarGet, .F. )
   ENDIF

RETURN Self

#endif

/* ------------------------------------------------------------------------- */

METHOD Display( lForced ) CLASS Get

   LOCAL nOldCursor := SetCursor( SC_NONE )
   LOCAL cBuffer
   LOCAL nDispPos

   DEFAULT lForced TO .T.

   if ::Buffer == NIL
      ::cType    := ValType( ::xVarGet )
      ::picture  := ::cPicture
   ENDIF

   if ::HasFocus
      cBuffer := ::Buffer
   ELSE
      cBuffer := ::PutMask( ::VarGet() )
   ENDIF

   if ::nMaxLen == NIL
      ::nMaxLen := iif( cBuffer == NIL, 0, Len( cBuffer ) )
   ENDIF
   IF ::nDispLen == NIL
      ::nDispLen := ::nMaxLen
   ENDIF

   if ::cType == "N" .AND. ::HasFocus .AND. ! ::lMinusPrinted .AND. ;
         ::DecPos != 0 .AND. ::lMinus .AND. ;
         ::Pos > ::DecPos .AND. Val( Left( cBuffer, ::DecPos -1 ) ) == 0

      // display "-." only in case when value on the left side of
      // the decimal point is equal 0
      cBuffer := SubStr( cBuffer, 1, ::DecPos -2 ) + "-." + SubStr( cBuffer, ::DecPos + 1 )
   ENDIF

   if ::nDispLen != ::nMaxLen .AND. ::Pos != 0 // ; has scroll?
      if ::nDispLen > 8
         nDispPos := Max( 1, Min( ::Pos - ::nDispLen + 4, ::nMaxLen - ::nDispLen + 1 ) )
      ELSE
         nDispPos := Max( 1, Min( ::Pos - Int( ::nDispLen / 2 ), ::nMaxLen - ::nDispLen + 1 ) )
      ENDIF
   ELSE
      nDispPos := 1
   ENDIF

   IF cBuffer != NIL .AND. ( lForced .OR. ( nDispPos != ::nOldPos ) )
      DispOutAt( ::Row, ::Col + iif( ::cDelimit == NIL, 0, 1 ), ;
         SubStr( cBuffer, nDispPos, ::nDispLen ), ;
         hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
      if ::cDelimit != NIL
         DispOutAt( ::Row, ::Col, Left( ::cDelimit, 1 ), hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
         DispOutAt( ::Row, ::Col + ::nDispLen + 1, SubStr( ::cDelimit, 2, 1 ), hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
      ENDIF
   ENDIF

   if ::Pos != 0
      SetPos( ::Row, ::Col + ::Pos - nDispPos + iif( ::cDelimit == NIL, 0, 1 ) )
   ENDIF

   ::nOldPos := nDispPos

   SetCursor( nOldCursor )

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD ColorDisp( cColorSpec ) CLASS Get

   ::ColorSpec := cColorSpec
   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD End() CLASS Get

   LOCAL nLastCharPos, nPos, nFor

   if ::HasFocus
      nLastCharPos := Min( Len( RTrim( ::Buffer ) ) + 1, ::nMaxEdit )
      if ::Pos != nLastCharPos
         nPos := nLastCharPos
      ELSE
         nPos := ::nMaxEdit
      ENDIF
      FOR nFor := nPos to ::FirstEditable() STEP -1
         if ::IsEditable( nFor )
            ::Pos := nFor
            EXIT
         ENDIF
      NEXT
      ::Clear := .F.
      ::Display( .F. )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD Home() CLASS Get

   if ::HasFocus
      ::Pos := ::FirstEditable()
      ::Clear := .F.
      ::Display( .F. )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD Reset() CLASS Get

   if ::HasFocus
      ::Buffer   := ::PutMask( ::VarGet(), .F. )
      ::Pos      := ::FirstEditable() // ; Simple 0 in CA-Cl*pper
      ::Clear    := ( "K" $ ::cPicFunc .OR. ::cType == "N" )
      ::lEdit    := .F.
      ::Minus    := .F.
      ::Rejected := .F.
      ::TypeOut  := ( ::Pos == 0 ) // ; Simple .f. in CA-Cl*pper
      ::Display()
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD Undo() CLASS Get

   if ::HasFocus
      ::VarPut( ::Original )
      ::Reset()
      ::Changed := .F.
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD SetFocus() CLASS Get

   LOCAL lWasNIL
   LOCAL xVarGet

   if ::HasFocus
      RETURN Self
   ENDIF

   lWasNIL := ::Buffer == NIL
   xVarGet := ::VarGet()

   ::HasFocus   := .T.
   ::Rejected   := .F.

   ::Original   := xVarGet
   ::cType      := ValType( xVarGet )
   ::Buffer     := ::PutMask( xVarGet, .F. )
   ::Picture    := ::cPicture
   ::Changed    := .F.
   ::Clear      := ( "K" $ ::cPicFunc .OR. ::cType == "N" )
   ::lEdit      := .F.
   ::Pos        := ::FirstEditable()
   ::TypeOut    := ( ::Pos == 0 )

   if ::cType == "N"
      ::DecPos := At( iif( ::lDecRev .OR. "E" $ ::cPicFunc, ",", "." ), ::Buffer )
      if ::DecPos == 0
         ::DecPos := Len( ::Buffer ) + 1
      ENDIF
      ::lMinus := ( xVarGet < 0 )
   ELSE
      ::DecPos := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
   ENDIF

   ::lMinusPrinted := .F.
   ::Minus     := .F.
   ::BadDate   := ( ::cType == "D" ) .AND. IsBadDate( ::Buffer, ::cPicFunc )

   IF lWasNIL .AND. ::Buffer != NIL
      if ::nDispLen == NIL
         ::nDispLen := ::nMaxLen
      ENDIF
   ENDIF

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD KillFocus() CLASS Get

   LOCAL lHadFocus

   if ::lEdit
      ::Assign()
   ENDIF

   lHadFocus := ::HasFocus

   ::HasFocus := .F.
   ::Pos      := 0
   ::Clear    := .F.
   ::Minus    := .F.
   ::Changed  := .F.
   ::DecPos   := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.

   IF lHadFocus
      ::Display()
   ENDIF

   ::xVarGet  := NIL
   ::Original := NIL
   ::Buffer   := NIL

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD VarPut( xValue, lReFormat ) CLASS Get

   LOCAL aSubs, nLen, aValue
   LOCAL i

   DEFAULT lReFormat TO .T.

   IF ISBLOCK( ::bBlock )
      if ::SubScript == NIL
         Eval( ::bBlock, xValue )
      ELSE
         aSubs := ::SubScript
         nLen := Len( aSubs )
         aValue := Eval( ::bBlock )
         FOR i := 1 TO nLen -1
            aValue := aValue[ aSubs[ i ] ]
         NEXT
         aValue[ aSubs[ i ] ] := xValue
      ENDIF

      IF lReFormat
         ::cType   := ValType( xValue )
         ::xVarGet := xValue
         ::lEdit   := .F.
         ::Picture := ::cPicture
      ENDIF
   ENDIF

RETURN xValue

/* ------------------------------------------------------------------------- */

METHOD VarGet() CLASS Get

   LOCAL aSubs, nLen, aValue
   LOCAL i
   LOCAL xValue

   IF ISBLOCK( ::bBlock )
      if ::SubScript == NIL
         xValue := Eval( ::bBlock )
      ELSE
         aSubs := ::SubScript
         nLen := Len( aSubs )
         aValue := Eval( ::bBlock )
         FOR i := 1 TO nLen -1
            aValue := aValue[ aSubs[ i ] ]
         NEXT
         xValue := aValue[ aSubs[ i ] ]
      ENDIF
   ELSE
      xValue := NIL
   ENDIF

   ::xVarGet := xValue

RETURN xValue

/* ------------------------------------------------------------------------- */

METHOD UnTransform( cBuffer ) CLASS Get

   LOCAL xValue
   LOCAL cChar
   LOCAL nFor

   DEFAULT cBuffer TO ::Buffer

   DO CASE
   case ::cType == "C"

      IF "R" $ ::cPicFunc
         FOR nFor := 1 TO Len( ::cPicMask )
            cChar := SubStr( ::cPicMask, nFor, 1 )
            IF !cChar $ "ANX9#!"
               cBuffer := SubStr( cBuffer, 1, nFor -1 ) + Chr( 1 ) + SubStr( cBuffer, nFor + 1 )
            ENDIF
         NEXT
         cBuffer := PadR( StrTran( cBuffer, Chr( 1 ), "" ), Len( ::Original ) )
      ENDIF

      xValue := cBuffer

   case ::cType == "N"

      // ::lMinus := .f.
      IF "X" $ ::cPicFunc
         IF Right( cBuffer, 2 ) == "DB"
            ::lMinus := .T.
         ENDIF
      ENDIF
      IF !::lMinus
         FOR nFor := 1 to ::nMaxLen
            if ::IsEditable( nFor ) .AND. IsDigit( SubStr( cBuffer, nFor, 1 ) )
               EXIT
            ENDIF
            IF SubStr( cBuffer, nFor, 1 ) $ "-(" .AND. SubStr( cBuffer, nFor, 1 ) != SubStr( ::cPicMask, nFor, 1 )
               ::lMinus := .T.
               EXIT
            ENDIF
         NEXT
      ENDIF
      cBuffer := Space( ::FirstEditable() -1 ) + SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 )

      IF "D" $ ::cPicFunc
         FOR nFor := ::FirstEditable() to ::LastEditable()
            IF !::IsEditable( nFor )
               cBuffer := Left( cBuffer, nFor - 1 ) + Chr( 1 ) + SubStr( cBuffer, nFor + 1 )
            ENDIF
         NEXT
      ELSE
         IF "E" $ ::cPicFunc .OR. ::lDecRev
            cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ".", " " ) + SubStr( cBuffer, ::LastEditable() + 1 )
            cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", "." ) + SubStr( cBuffer, ::LastEditable() + 1 )
         ELSE
            cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", " " ) + SubStr( cBuffer, ::LastEditable() + 1 )
         ENDIF

         FOR nFor := ::FirstEditable() to ::LastEditable()
            IF !::IsEditable( nFor ) .AND. SubStr( cBuffer, nFor, 1 ) != "."
               cBuffer := Left( cBuffer, nFor - 1 ) + Chr( 1 ) + SubStr( cBuffer, nFor + 1 )
            ENDIF
         NEXT
      ENDIF

      cBuffer := StrTran( cBuffer, Chr( 1 ), "" )

      cBuffer := StrTran( cBuffer, "$", " " )
      cBuffer := StrTran( cBuffer, "*", " " )
      cBuffer := StrTran( cBuffer, "-", " " )
      cBuffer := StrTran( cBuffer, "(", " " )
      cBuffer := StrTran( cBuffer, ")", " " )

      cBuffer := PadL( StrTran( cBuffer, " ", "" ), Len( cBuffer ) )

      if ::lMinus
         FOR nFor := 1 TO Len( cBuffer )
            IF IsDigit( SubStr( cBuffer, nFor, 1 ) )
               EXIT
            ENDIF
         NEXT
         nFor--
         IF nFor > 0
            cBuffer := Left( cBuffer, nFor - 1 ) + "-" + SubStr( cBuffer, nFor + 1 )
         ELSE
            cBuffer := "-" + cBuffer
         ENDIF
      ENDIF

#if ( __HARBOUR__ - 0 ) < 0x030200
      xValue  := Val( cBuffer )
#else
      xValue  := hb_Val( cBuffer )
#endif

   case ::cType == "L"
      cBuffer := Upper( cBuffer )
      xValue := "T" $ cBuffer .OR. "Y" $ cBuffer .OR. hb_langMessage( HB_LANG_ITEM_BASE_TEXT + 1 ) $ cBuffer

   case ::cType == "D"
      IF "E" $ ::cPicFunc
         cBuffer := SubStr( cBuffer, 4, 3 ) + SubStr( cBuffer, 1, 3 ) + SubStr( cBuffer, 7 )
      ENDIF
      IF cBuffer != NIL
         xValue := CToD( cBuffer )
      ENDIF

   ENDCASE

RETURN xValue

/* ------------------------------------------------------------------------- */

METHOD OverStrike( cChar ) CLASS Get

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   if ::cType == "N" .AND. ! ::lEdit .AND. ::Clear
      ::Pos := ::FirstEditable()
   ENDIF

   if ::Pos > ::nMaxEdit
      ::Rejected := .T.
      RETURN Self
   ENDIF

   cChar := ::Input( cChar )

   IF cChar == ""
      ::Rejected := .T.
      RETURN Self
   ELSE
      ::Rejected := .F.
   ENDIF

   if ::Clear .AND. ::Pos == ::FirstEditable()
      ::DeleteAll()
      ::Clear := .F.
   ENDIF

   ::lEdit := .T.

   if ::Pos == 0
      ::Pos := 1
   ENDIF

   DO WHILE ! ::IsEditable( ::Pos ) .AND. ::Pos <= ::nMaxEdit
      ::Pos++
   ENDDO

   if ::Pos > ::nMaxEdit
      ::Pos := ::FirstEditable()
   ENDIF
   ::Buffer := SubStr( ::Buffer, 1, ::Pos -1 ) + cChar + SubStr( ::Buffer, ::Pos + 1 )

   ::Changed := .T.

   ::Right( .F. )

   ::BadDate := ( ::cType == "D" ) .AND. IsBadDate( ::Buffer, ::cPicFunc )

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD Insert( cChar ) CLASS Get

   LOCAL n
   LOCAL nMaxEdit

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   nMaxEdit := ::nMaxEdit

   if ::cType == "N" .AND. ! ::lEdit .AND. ::Clear
      ::Pos := ::FirstEditable()
   ENDIF

   if ::Pos > ::nMaxEdit
      ::Rejected := .T.
      RETURN Self
   ENDIF

   cChar := ::Input( cChar )

   IF cChar == ""
      ::Rejected := .T.
      RETURN Self
   ELSE
      ::Rejected := .F.
   ENDIF

   if ::Clear .AND. ::Pos == ::FirstEditable()
      ::DeleteAll()
      ::Clear := .F.
   ENDIF

   ::lEdit := .T.

   if ::Pos == 0
      ::Pos := 1
   ENDIF

   DO WHILE ! ::IsEditable( ::Pos ) .AND. ::Pos <= ::nMaxEdit
      ::Pos++
   ENDDO

   if ::Pos > ::nMaxEdit
      ::Pos := ::FirstEditable()
   ENDIF

   if ::lPicComplex
      // Calculating diferent nMaxEdit for ::lPicComplex

      FOR n := ::Pos TO nMaxEdit
         IF !::IsEditable( n )
            EXIT
         ENDIF
      NEXT
      nMaxEdit := n
      ::Buffer := Left( SubStr( ::Buffer, 1, ::Pos - 1 ) + cChar + ;
         SubStr( ::Buffer, ::Pos, nMaxEdit - 1 -::Pos ) + ;
         SubStr( ::Buffer, nMaxEdit ), ::nMaxLen )
   ELSE
      ::Buffer := Left( SubStr( ::Buffer, 1, ::Pos - 1 ) + cChar + SubStr( ::Buffer, ::Pos ), ::nMaxEdit )
   ENDIF

   ::Changed := .T.

   ::Right( .F. )

   ::BadDate := ( ::cType == "D" ) .AND. IsBadDate( ::Buffer, ::cPicFunc )

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD _Right( lDisplay ) CLASS Get

   LOCAL nPos

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   DEFAULT lDisplay TO .T.

   ::TypeOut := .F.
   ::Clear   := .F.

   if ::Pos == ::nMaxEdit
      ::TypeOut := .T.
      RETURN Self
   ENDIF

   nPos := ::Pos + 1

   DO WHILE ! ::IsEditable( nPos ) .AND. nPos <= ::nMaxEdit
      nPos++
   ENDDO

   IF nPos <= ::nMaxEdit
      ::Pos := nPos
   ELSE
      ::TypeOut := .T.
   ENDIF

   IF lDisplay
      ::Display( .F. )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD _Left( lDisplay ) CLASS Get

   LOCAL nPos

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   DEFAULT lDisplay TO .T.

   ::TypeOut := .F.
   ::Clear   := .F.

   if ::Pos == ::FirstEditable()
      ::TypeOut := .T.
      RETURN Self
   ENDIF

   nPos := ::Pos -1

   DO WHILE ! ::IsEditable( nPos ) .AND. nPos > 0
      nPos--
   ENDDO

   IF nPos > 0
      ::Pos := nPos
   ELSE
      ::TypeOut := .T.
   ENDIF

   IF lDisplay
      ::Display( .F. )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD WordLeft() CLASS Get

   LOCAL nPos

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   ::TypeOut := .F.
   ::Clear   := .F.

   if ::Pos == ::FirstEditable()
      ::TypeOut := .T.
      RETURN Self
   ENDIF

   nPos := ::Pos -1

   DO WHILE nPos > 0
      IF SubStr( ::Buffer, nPos, 1 ) == " "
         DO WHILE nPos > 0 .AND. SubStr( ::Buffer, nPos, 1 ) == " "
            nPos--
         ENDDO
         DO WHILE nPos > 0 .AND. !( SubStr( ::Buffer, nPos, 1 ) == " " )
            nPos--
         ENDDO
         IF nPos > 0
            nPos++
         ENDIF
         EXIT
      ENDIF
      nPos--
   ENDDO

   IF nPos < 1
      nPos := 1
   ENDIF

   IF nPos > 0
      ::Pos := nPos
   ENDIF

   ::Display( .F. )

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD WordRight() CLASS Get

   LOCAL nPos

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   ::TypeOut := .F.
   ::Clear   := .F.

   if ::Pos == ::nMaxEdit
      ::TypeOut := .T.
      RETURN Self
   ENDIF

   nPos := ::Pos + 1

   DO WHILE nPos <= ::nMaxEdit
      IF SubStr( ::Buffer, nPos, 1 ) == " "
         DO WHILE nPos <= ::nMaxEdit .AND. SubStr( ::Buffer, nPos, 1 ) == " "
            nPos++
         ENDDO
         EXIT
      ENDIF
      nPos++
   ENDDO

   IF nPos > ::nMaxEdit
      nPos := ::nMaxEdit
   ENDIF

   IF nPos <= ::nMaxEdit
      ::Pos := nPos
   ENDIF

   ::Display( .F. )

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD ToDecPos() CLASS Get

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   if ::Pos == ::FirstEditable()
      ::DeleteAll()
   ENDIF

   ::Clear   := .F.
   ::lEdit   := .T.
   ::Buffer  := ::PutMask( ::UnTransform(), .F. )
   ::Changed := .T.

   if ::DecPos != 0
      if ::DecPos == Len( ::cPicMask )
         ::Pos := ::DecPos -1   // 9999.
      ELSE
         ::Pos := ::DecPos + 1   // 9999.9
      ENDIF
   ELSE
      ::Pos := ::nDispLen
   ENDIF

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD IsEditable( nPos ) CLASS Get

   LOCAL cChar

   IF Empty( ::cPicMask )
      RETURN .T.
   ENDIF

   if ::nMaxEdit == NIL .OR. nPos > ::nMaxEdit
      RETURN .F.
   ENDIF

   cChar := SubStr( ::cPicMask, nPos, 1 )

   DO CASE
   case ::cType == "C"
      RETURN cChar $ "!ANX9#"
   case ::cType == "N"
      RETURN cChar $ "9#$*"
   case ::cType == "D"
      RETURN cChar == "9"
   case ::cType == "L"
      RETURN cChar $ "LY#"   /* Clipper 5.2 undocumented: # allow T,F,Y,N for Logical [ckedem] */
   ENDCASE

RETURN .F.

/* ------------------------------------------------------------------------- */

METHOD Input( cChar ) CLASS Get

   LOCAL cPic

   DO CASE
   case ::cType == "N"

      DO CASE
      CASE cChar == "-"
         ::lMinus := .T.  /* The minus symbol can be written in any place */
         ::Minus := .T.

      CASE cChar $ ".,"
         ::toDecPos()
         RETURN ""

      CASE ! ( cChar $ "0123456789+" )
         RETURN ""
      ENDCASE

   case ::cType == "D"

      IF !( cChar $ "0123456789" )
         RETURN ""
      ENDIF

   case ::cType == "L"

      IF !( Upper( cChar ) $ "YNTF" )
         RETURN ""
      ENDIF

   ENDCASE

   IF ! Empty( ::cPicFunc )
      cChar := Left( Transform( cChar, ::cPicFunc ), 1 ) // Left needed for @D
   ENDIF

   IF ! Empty( ::cPicMask )
      cPic  := SubStr( ::cPicMask, ::Pos, 1 )

      // cChar := Transform( cChar, cPic )
      // Above line eliminated because some get picture template symbols for
      // numeric input not work in text input. eg: $ and *

      DO CASE
      CASE cPic == "A"
         IF ! IsAlpha( cChar )
            cChar := ""
         ENDIF

      CASE cPic == "N"
         IF ! IsAlpha( cChar ) .AND. ! IsDigit( cChar )
            cChar := ""
         ENDIF

      CASE cPic == "9"
         IF ! IsDigit( cChar ) .AND. ! cChar $ "-+"
            cChar := ""
         ENDIF
         if ::cType != "N" .AND. cChar $ "-+"
            cChar := ""
         ENDIF

         /* Clipper 5.2 undocumented: # allow T,F,Y,N for Logical [ckedem] */
      CASE cPic == "L" .OR. ( cPic == "#" .AND. ::cType == "L" )
         IF !( Upper( cChar ) $ "YNTF" + ;
               hb_langMessage( HB_LANG_ITEM_BASE_TEXT + 1 ) + ;
               hb_langMessage( HB_LANG_ITEM_BASE_TEXT + 2 ) )
            cChar := ""
         ENDIF

      CASE cPic == "#"
         IF ! IsDigit( cChar ) .AND. !( cChar == " " ) .AND. !( cChar $ ".+-" )
            cChar := ""
         ENDIF

      CASE cPic == "Y"
         IF !( Upper( cChar ) $ "YN" )
            cChar := ""
         ENDIF

      CASE ( cPic == "$" .OR. cPic == "*" ) .AND. ::cType == "N"
         IF ! IsDigit( cChar ) .AND. cChar != "-"
            cChar := ""
         ENDIF
      OTHERWISE
         cChar := Transform( cChar, cPic )
      END CASE
   ENDIF

RETURN cChar

/* ------------------------------------------------------------------------- */

METHOD PutMask( xValue, lEdit ) CLASS Get

   LOCAL cChar
   LOCAL cBuffer
   LOCAL cPicFunc
   LOCAL cMask
   LOCAL nFor

   if ::cType == NIL
      // Not initialized yet
      ::Original := ::VarGet()
      ::cType    := ValType( ::Original )
      ::Picture  := ::cPicture
   ENDIF

   cPicFunc := ::cPicFunc
   cMask    := ::cPicMask

   DEFAULT xValue TO ::VarGet()
   DEFAULT lEdit  TO ::HasFocus

   IF xValue == NIL .OR. ValType( xValue ) $ "AB"
      ::nMaxLen := 0
      RETURN NIL
   ENDIF

   if ::HasFocus
      cPicFunc := StrTran( cPicfunc, "B", "" )
      IF cPicFunc == "@"
         cPicFunc := ""
      ENDIF
   ENDIF
   IF lEdit .AND. ::lEdit
      IF ( "*" $ cMask ) .OR. ( "$" $ cMask )
         cMask := StrTran( StrTran( cMask, "*", "9" ), "$", "9" )
      ENDIF
   ENDIF

   cBuffer := Transform( xValue, ;
      iif( Empty( cPicFunc ), ;
      iif( ::lCleanZero .AND. !::HasFocus, "@Z ", "" ), ;
      cPicFunc + iif( ::lCleanZero .AND. !::HasFocus, "Z", "" ) + " " ) ;
      + cMask )

   if ::cType == "N"
      IF ( "(" $ cPicFunc .OR. ")" $ cPicFunc ) .AND. xValue >= 0
         cBuffer += " "
      ENDIF

      IF ( ( "C" $ cPicFunc .AND. xValue <  0 ) .OR. ;
            ( "X" $ cPicFunc .AND. xValue >= 0 ) ) .AND. ;
            !( "X" $ cPicFunc .AND. "C" $ cPicFunc )
         cBuffer += "   "
      ENDIF

      IF xValue < 0
         ::lMinusPrinted := .T.
      ELSE
         ::lMinusPrinted := .F.
      ENDIF
   ENDIF

   ::nMaxLen  := Len( cBuffer )
   ::nMaxEdit := ::nMaxLen

   if ::nDispLen == NIL
      ::nDispLen := ::nMaxLen
   ENDIF

   IF lEdit .AND. ::cType == "N" .AND. ! Empty( cMask )
      IF "E" $ cPicFunc
         cMask := Left( cMask, ::FirstEditable() -1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", Chr( 1 ) ) + SubStr( cMask, ::LastEditable() + 1 )
         cMask := Left( cMask, ::FirstEditable() -1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ".", ","      ) + SubStr( cMask, ::LastEditable() + 1 )
         cMask := Left( cMask, ::FirstEditable() -1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), Chr( 1 ), "." ) + SubStr( cMask, ::LastEditable() + 1 )
      ENDIF
      FOR nFor := 1 to ::nMaxLen
         cChar := SubStr( cMask, nFor, 1 )
         IF cChar $ ",." .AND. SubStr( cBuffer, nFor, 1 ) $ ",."
            cBuffer := SubStr( cBuffer, 1, nFor -1 ) + cChar + SubStr( cBuffer, nFor + 1 )
         ENDIF
      NEXT
      if ::lEdit .AND. Empty( xValue )
         cBuffer := StrTran( cBuffer, "0", " " )
      ENDIF
      if ::lDecRev
         cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", Chr( 1 ) ) + SubStr( cBuffer, ::LastEditable() + 1 )
         cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ".", ","      ) + SubStr( cBuffer, ::LastEditable() + 1 )
         cBuffer := Left( cBuffer, ::FirstEditable() -1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), Chr( 1 ), "." ) + SubStr( cBuffer, ::LastEditable() + 1 )
      ENDIF
   ENDIF

   if ::cType == "N"
      IF "(" $ ::cPicFunc .OR. ")" $ ::cPicFunc
         ::nMaxEdit--
      ENDIF
      IF "C" $ ::cPicFunc .OR. "X" $ ::cPicFunc
         ::nMaxEdit -= 3
      ENDIF
   ENDIF

   if ::cType == "D" .AND. ::BadDate
      cBuffer := ::Buffer
   ENDIF

RETURN cBuffer

/* ------------------------------------------------------------------------- */

METHOD BackSpace( lDisplay ) CLASS Get

   LOCAL nPos := ::Pos
   LOCAL nMinus

   DEFAULT lDisplay TO .T.

   IF nPos > 1 .AND. nPos == ::FirstEditable() .AND. ::lMinus

      /* To delete the parenthesis (negative indicator) in a non editable position */

      nMinus := At( "(", SubStr( ::Buffer, 1, nPos - 1 ) )

      IF nMinus > 0 .AND. SubStr( ::cPicMask, nMinus, 1 ) != "("

         ::lEdit := .T.

         ::Buffer := SubStr( ::Buffer, 1, nMinus -1 ) + " " + ;
            SubStr( ::Buffer, nMinus + 1 )

         ::Changed := .T.

         IF lDisplay
            ::Display()
         ENDIF

         RETURN Self

      ENDIF

   ENDIF

   ::Left()

   if ::Pos < nPos
      ::Delete( lDisplay )
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD _Delete( lDisplay ) CLASS Get

   LOCAL nMaxLen := ::nMaxLen, n

   DEFAULT lDisplay TO .T.

   ::Clear := .F.
   ::lEdit := .T.

   if ::lPicComplex
      // Calculating diferent nMaxLen for ::lPicComplex
      FOR n := ::Pos TO nMaxLen
         IF !::IsEditable( n )
            EXIT
         ENDIF
      NEXT
      nMaxLen := n -1
   ENDIF

   if ::cType == "N" .AND. SubStr( ::Buffer, ::Pos, 1 ) $ "(-"
      ::lMinus := .F.
   ENDIF

   ::Buffer := PadR( SubStr( ::Buffer, 1, ::Pos -1 ) + ;
      SubStr( ::Buffer, ::Pos + 1, nMaxLen - ::Pos ) + " " + ;
      SubStr( ::Buffer, nMaxLen + 1 ), ::nMaxLen )

   if ::cType == "D"
      ::BadDate := IsBadDate( ::Buffer, ::cPicFunc )
   ELSE
      ::BadDate := .F.
   ENDIF

   ::Changed := .T.

   IF lDisplay
      ::Display()
   ENDIF

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD DeleteAll() CLASS Get

   LOCAL xValue

   ::lEdit := .T.

   DO CASE
   case ::cType == "C"
      xValue := Space( ::nMaxlen )
   case ::cType == "N"
      xValue   := 0
      ::lMinus := .F.
   case ::cType == "D"
      xValue := CToD( "" )
      ::BadDate := .F.
   case ::cType == "L"
      xValue := .F.
   ENDCASE

   ::Buffer := ::PutMask( xValue, .T. )
   ::Pos    := ::FirstEditable()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD DelEnd() CLASS Get

   LOCAL nPos := ::Pos

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   ::Pos := ::nMaxEdit

   ::Delete( .F. )
   DO while ::Pos > nPos
      ::BackSpace( .F. )
   ENDDO

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD DelLeft() CLASS Get

   ::Left( .F. )
   ::Delete( .F. )
   ::Right()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD DelRight() CLASS Get

   ::Right( .F. )
   ::Delete( .F. )
   ::Left()

RETURN Self

/* ------------------------------------------------------------------------- */

/* NOTE ::WordLeft()
        ::DelWordRight() */

METHOD DelWordLeft() CLASS Get

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   IF !( SubStr( ::Buffer, ::Pos, 1 ) == " " )
      IF SubStr( ::Buffer, ::Pos -1, 1 ) == " "
         ::BackSpace( .F. )
      ELSE
         ::WordRight()
         ::Left()
      ENDIF
   ENDIF

   IF SubStr( ::Buffer, ::Pos, 1 ) == " "
      ::Delete( .F. )
   ENDIF

   DO while ::Pos > 1 .AND. !( SubStr( ::Buffer, ::Pos -1, 1 ) == " " )
      ::BackSpace( .F. )
   ENDDO

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

METHOD DelWordRight() CLASS Get

   IF ! ::HasFocus
      RETURN Self
   ENDIF

   ::TypeOut := .F.
   ::Clear   := .F.

   if ::Pos == ::nMaxEdit
      ::TypeOut := .T.
      RETURN Self
   ENDIF

   DO while ::Pos <= ::nMaxEdit .AND. !( SubStr( ::Buffer, ::Pos, 1 ) == " " )
      ::Delete( .F. )
   ENDDO

   if ::Pos <= ::nMaxEdit
      ::Delete( .F. )
   ENDIF

   ::Display()

RETURN Self

/* ------------------------------------------------------------------------- */

/* The METHOD ColorSpec and DATA cColorSpec allow to replace the
 * property ColorSpec for a function to control the content and
 * to carry out certain actions to normalize the data.
 * The particular case is that the function receives a single color and
 * be used for GET_CLR_UNSELECTED and GET_CLR_ENHANCED.
 */

METHOD ColorSpec( cColorSpec ) CLASS Get

   LOCAL cClrUnSel
   LOCAL cClrEnh

   IF cColorSpec != NIL

      cClrUnSel := iif( !Empty( hb_ColorIndex( cColorSpec, GET_CLR_UNSELECTED ) ), ;
         hb_ColorIndex( cColorSpec, GET_CLR_UNSELECTED ), ;
         hb_ColorIndex( SetColor(), CLR_UNSELECTED ) )

      cClrEnh   := iif( !Empty( hb_ColorIndex( cColorSpec, GET_CLR_ENHANCED ) ), ;
         hb_ColorIndex( cColorSpec, GET_CLR_ENHANCED ), ;
         cClrUnSel )

      ::cColorSpec := cClrUnSel + "," + cClrEnh

   ENDIF

return ::cColorSpec

/* ------------------------------------------------------------------------- */

/* The METHOD Picture and DATA cPicture allow to replace the
 * property Picture for a function to control the content and
 * to carry out certain actions to normalize the data.
 * The particular case is that the Picture is loaded later on
 * to the creation of the object, being necessary to carry out
 * several tasks to adjust the internal data of the object.
 */

METHOD Picture( cPicture ) CLASS Get

   LOCAL cChar
   LOCAL nAt
   LOCAL nFor
   LOCAL cNum

   IF cPicture != NIL

      ::nDispLen := NIL

      ::cPicture := cPicture

      cNum := ""

      IF Left( cPicture, 1 ) == "@"

         nAt := At( " ", cPicture )

         IF nAt == 0
            ::cPicFunc := Upper( cPicture )
            ::cPicMask := ""
         ELSE
            ::cPicFunc := Upper( SubStr( cPicture, 1, nAt -1 ) )
            ::cPicMask := SubStr( cPicture, nAt + 1 )
         ENDIF

         IF "D" $ ::cPicFunc

            ::cPicMask := Set( _SET_DATEFORMAT )
            ::cPicMask := StrTran( ::cPicmask, "y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "Y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "m", "9" )
            ::cPicMask := StrTran( ::cPicmask, "M", "9" )
            ::cPicMask := StrTran( ::cPicmask, "d", "9" )
            ::cPicMask := StrTran( ::cPicmask, "D", "9" )

         ENDIF

         IF ( nAt := At( "S", ::cPicFunc ) ) > 0
            FOR nFor := nAt + 1 TO Len( ::cPicFunc )
               IF ! IsDigit( SubStr( ::cPicFunc, nFor, 1 ) )
                  EXIT
               ELSE
                  cNum += SubStr( ::cPicFunc, nFor, 1 )
               ENDIF
            NEXT
            IF Val( cNum ) > 0
               ::nDispLen := Val( cNum )
            ENDIF
            ::cPicFunc := SubStr( ::cPicFunc, 1, nAt -1 ) + SubStr( ::cPicFunc, nFor )
         ENDIF

         IF "Z" $ ::cPicFunc
            ::lCleanZero := .T.
         ELSE
            ::lCleanZero := .F.
         ENDIF
         ::cPicFunc := StrTran( ::cPicFunc, "Z", "" )

         if ::cPicFunc == "@"
            ::cPicFunc := ""
         ENDIF
      ELSE
         ::cPicFunc   := ""
         ::cPicMask   := cPicture
         ::lCleanZero := .F.
      ENDIF

      if ::cType == NIL
         ::Original := ::xVarGet
         ::cType    := ValType( ::Original )
      ENDIF

      if ::cType == "D"
         ::cPicMask := LTrim( ::cPicMask )
      ENDIF

      // Comprobar si tiene la , y el . cambiado (Solo en Xbase++)

      ::lDecRev := "," $ Transform( 1.1, "9.9" )

      // Generate default picture mask if not specified

      IF Empty( ::cPicMask )

         DO CASE
         case ::cType == "D"

            ::cPicMask := Set( _SET_DATEFORMAT )
            ::cPicMask := StrTran( ::cPicmask, "y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "Y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "m", "9" )
            ::cPicMask := StrTran( ::cPicmask, "M", "9" )
            ::cPicMask := StrTran( ::cPicmask, "d", "9" )
            ::cPicMask := StrTran( ::cPicmask, "D", "9" )

         case ::cType == "N"

            cNum := Str( ::xVarGet )
            IF ( nAt := At( iif( ::lDecRev, ",", "." ), cNum ) ) > 0
               ::cPicMask := Replicate( "9", nAt -1 ) + iif( ::lDecRev, ",", "." )
               ::cPicMask += Replicate( "9", Len( cNum ) - Len( ::cPicMask ) )
            ELSE
               ::cPicMask := Replicate( "9", Len( cNum ) )
            ENDIF

         case ::cType == "C" .AND. ::cPicFunc == "@9"
            ::cPicMask := Replicate( "9", Len( ::xVarGet ) )
            ::cPicFunc := ""

         ENDCASE

      ENDIF

      // Comprobar si tiene caracteres embebidos no modificables en la plantilla

      ::lPicComplex := .F.

      IF ! Empty( ::cPicMask )
         FOR nFor := 1 TO Len( ::cPicMask )
            cChar := SubStr( ::cPicMask, nFor, 1 )
            IF !( cChar $ "!ANX9#" )
               ::lPicComplex := .T.
               EXIT
            ENDIF
         NEXT
      ENDIF

      if ::HasFocus
         if ::cType == "N"
            ::DecPos := At( iif( ::lDecRev .OR. "E" $ ::cPicFunc, ",", "." ), ;
               Transform( 1, iif( Empty( ::cPicFunc ), "", ::cPicFunc + " " ) + ::cPicMask ) )
            if ::DecPos == 0
               ::DecPos := Len( ::Buffer ) + 1
            ENDIF
         ELSE
            ::DecPos := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
         ENDIF
      ENDIF

      if ::nDispLen == NIL
         ::nDispLen := ::nMaxLen
      ENDIF

   ENDIF

return ::cPicture

/* ------------------------------------------------------------------------- */

METHOD SetKeyEvent( nKey, bKey, lCtrl, lShift, lAlt ) CLASS Get

   LOCAL n, cKey

   cKey := hb_ntos( iif( HB_ISNUMERIC( nKey ), nKey, WM_LBUTTONDBLCLK ) )
   cKey += iif( Empty( lCtrl ), '', '#' )
   cKey += iif( Empty( lShift ), '', '^' )
   cKey += iif( Empty( lAlt  ), '', '@' )

   IF ( n := AScan( ::aKeyEvent, {| a| a[ 1 ] == cKey } ) ) > 0
      ::aKeyEvent[ n ] := { cKey, bKey }
   ELSE
      AAdd( ::aKeyEvent, { cKey, bKey } )
   ENDIF

RETURN NIL

/* ------------------------------------------------------------------------- */

METHOD DoKeyEvent( nKey ) CLASS Get

   LOCAL n, r := 0, cKey := hb_ntos( nKey )

   IF Len( ::aKeyEvent ) > 0

      cKey += iif( _GetKeyState( VK_CONTROL ), '#', '' )
      cKey += iif( _GetKeyState( VK_SHIFT   ), '^', '' )
      cKey += iif( _GetKeyState( VK_MENU    ), '@', '' )
      IF ( n := AScan( ::aKeyEvent, {| a| a[ 1 ] == cKey } ) ) > 0
         IF HB_ISBLOCK( ::aKeyEvent[ n ][ 2 ] )
            Eval( ::aKeyEvent[ n ][ 2 ], Self, nKey, cKey )
            r := 1
         ENDIF
      ENDIF

   ENDIF

RETURN r

/* ------------------------------------------------------------------------- */

METHOD Refresh() CLASS Get

   ::UpdateBuffer()
   _DispGetBoxText( ::Control, ::Buffer )

RETURN NIL

/* ------------------------------------------------------------------------- */

METHOD Type() CLASS Get

   ::cType := ValType( iif( ::HasFocus, ::xVarGet, ::VarGet() ) )

return ::cType

/* ------------------------------------------------------------------------- */

/* The METHOD Block and DATA bBlock allow to replace the
 * property Block for a function to control the content and
 * to carry out certain actions to normalize the data.
 * The particular case is that the Block is loaded later on
 * to the creation of the object, being necessary to carry out
 * several tasks to adjust the internal data of the object
 * to display correctly.
 */

METHOD Block( bBlock ) CLASS Get

   IF bBlock != NIL .AND. !::HasFocus

      ::bBlock   := bBlock
      ::cType    := ValType( ::Original )
      ::xVarGet  := NIL

   ENDIF

return ::bBlock

/* ------------------------------------------------------------------------- */

#ifdef HB_COMPAT_C53

METHOD HitTest( nMRow, nMCol ) CLASS Get

   if ::Row != nMRow
      RETURN HTNOWHERE
   ENDIF

   IF nMCol >= ::Col .AND. ;
         nMCol <= ::Col + ::nDispLen + iif( ::cDelimit == NIL, 0, 2 )
      RETURN HTCLIENT
   ENDIF

RETURN HTNOWHERE

#endif

/* ------------------------------------------------------------------------- */

METHOD FirstEditable() CLASS Get

   LOCAL nFor

   if ::nMaxLen != NIL

      if ::IsEditable( 1 )
         RETURN 1
      ENDIF

      FOR nFor := 2 to ::nMaxLen
         if ::IsEditable( nFor )
            RETURN nFor
         ENDIF
      NEXT

   ENDIF

   ::TypeOut := .T.

RETURN 0

/* ------------------------------------------------------------------------- */

METHOD LastEditable() CLASS Get

   LOCAL nFor

   if ::nMaxLen != NIL

      FOR nFor := ::nMaxLen TO 1 STEP -1
         if ::IsEditable( nFor )
            RETURN nFor
         ENDIF
      NEXT

   ENDIF

   ::TypeOut := .T.

RETURN 0

/* ------------------------------------------------------------------------- */

STATIC FUNCTION IsBadDate( cBuffer, cPicFunc )

   LOCAL nFor, nLen

   IF "E" $ cPicFunc
      cBuffer := SubStr( cBuffer, 4, 3 ) + SubStr( cBuffer, 1, 3 ) + SubStr( cBuffer, 7 )
   ENDIF

   IF cBuffer == NIL .OR. ! Empty( CToD( cBuffer ) )
      RETURN .F.
   ENDIF

   nLen := Len( cBuffer )

   FOR nFor := 1 TO nLen
      IF IsDigit( SubStr( cBuffer, nFor, 1 ) )
         RETURN .T.
      ENDIF
   NEXT

RETURN .F.
