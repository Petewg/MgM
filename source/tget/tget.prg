/*
 * $Id: tget.prg,v 1.116 2007/04/20 19:47:45 vszakats Exp $
 */

/*
 * Harbour Project source code:
 * Get Class
 *
 * Copyright 1999 Ignacio Ortiz de Z�niga <ignacio@fivetech.com>
 * www - http://harbour-project.org
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

/* ------------------------------------------------------------------------- */

CLASS Get

   EXPORTED:

   DATA BadDate        INIT .f.
   DATA Buffer
   DATA Cargo
   DATA Changed        INIT .f.
   DATA Clear          INIT .f.
   DATA Col
   DATA DecPos         INIT 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
   DATA ExitState
   DATA HasFocus       INIT .f.
   DATA Minus          INIT .f.
   DATA Name
   DATA Original
   DATA Pos            INIT 0
   DATA PostBlock
   DATA PreBlock
   DATA Reader
   DATA Rejected       INIT .f.
   DATA Row
   DATA SubScript
   DATA TypeOut        INIT .f.
#ifdef HB_COMPAT_C53
   DATA Control
   DATA Message
   DATA Caption        INIT ""
   DATA CapRow         INIT 0
   DATA CapCol         INIT 0
#endif

   PROTECTED:

   DATA cColorSpec
   DATA cPicture
   DATA bBlock
   DATA cType

   DATA cPicMask       INIT ""
   DATA cPicFunc       INIT ""
   DATA nMaxLen
   DATA lEdit          INIT .f.
   DATA lDecRev        INIT .f.
   DATA lPicComplex    INIT .f.
   DATA nDispLen
   DATA nDispPos       INIT 1
   DATA nOldPos        INIT 0
   DATA lCleanZero     INIT .f.
   DATA cDelimit
   DATA nMaxEdit
   DATA lMinus         INIT .f.
   DATA lMinusPrinted  INIT .f.
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
   DEFAULT bVarBlock  TO iif( ISCHARACTER( cVarName ), MemvarBlock( cVarName ), NIL )
   DEFAULT cColorSpec TO hb_ColorIndex( SetColor(), CLR_UNSELECTED ) + "," + hb_ColorIndex( SetColor(), CLR_ENHANCED )

   ::Row           := nRow
   ::Col           := nCol
   ::bBlock        := bVarBlock
   ::Name          := cVarName
   ::Picture       := cPicture
   ::ColorSpec     := cColorSpec
   if Set( _SET_DELIMITERS )
      ::cDelimit      := Set( _SET_DELIMCHARS )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD Assign() CLASS Get

   if ::HasFocus
      ::VarPut( ::UnTransform(), .f. )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD UpdateBuffer() CLASS Get

   if ::HasFocus
      ::Buffer := ::PutMask( ::VarGet() )
      ::Display()
   else
      ::PutMask( ::VarGet() )
   endif

return Self

/* ------------------------------------------------------------------------- */

#ifdef HB_C52_UNDOC

METHOD Reform() CLASS Get

   if ::HasFocus
      ::Buffer := ::PutMask( ::xVarGet, .f. )
   endif

return Self

#endif

/* ------------------------------------------------------------------------- */

METHOD Display( lForced ) CLASS Get

   local nOldCursor := SetCursor( SC_NONE )
   local cBuffer
   local nDispPos

   DEFAULT lForced TO .t.

   if ::Buffer == NIL
      ::cType    := ValType( ::xVarGet )
      ::picture  := ::cPicture
   endif

   if ::HasFocus
      cBuffer := ::Buffer
   else
      cBuffer := ::PutMask( ::VarGet() )
   endif

   if ::nMaxLen == NIL
      ::nMaxLen := iif( cBuffer == NIL, 0, Len( cBuffer ) )
   endif
   IF ::nDispLen == NIL
      ::nDispLen := ::nMaxLen
   ENDIF

   if ::cType == "N" .and. ::HasFocus .and. ! ::lMinusPrinted .and. ;
      ::DecPos != 0 .and. ::lMinus .and. ;
      ::Pos > ::DecPos .and. Val( Left( cBuffer, ::DecPos - 1 ) ) == 0

      // display "-." only in case when value on the left side of
      // the decimal point is equal 0
      cBuffer := SubStr( cBuffer, 1, ::DecPos - 2 ) + "-." + SubStr( cBuffer, ::DecPos + 1 )
   endif

   if ::nDispLen != ::nMaxLen .and. ::Pos != 0 // ; has scroll?
      if ::nDispLen > 8
         nDispPos := Max( 1, Min( ::Pos - ::nDispLen + 4, ::nMaxLen - ::nDispLen + 1 ) )
      else
         nDispPos := Max( 1, Min( ::Pos - int( ::nDispLen / 2 ), ::nMaxLen - ::nDispLen + 1 ) )
      endif
   else
      nDispPos := 1
   endif

   if cBuffer != NIL .and. ( lForced .or. ( nDispPos != ::nOldPos ) )
      DispOutAt( ::Row, ::Col + iif( ::cDelimit == NIL, 0, 1 ),;
                 SubStr( cBuffer, nDispPos, ::nDispLen ),;
                 hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
      if ::cDelimit != NIL
         DispOutAt( ::Row, ::Col, Left( ::cDelimit, 1 ), hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
         DispOutAt( ::Row, ::Col + ::nDispLen + 1, SubStr( ::cDelimit, 2, 1 ), hb_ColorIndex( ::cColorSpec, iif( ::HasFocus, GET_CLR_ENHANCED, GET_CLR_UNSELECTED ) ) )
      endif
   endif

   if ::Pos != 0
      SetPos( ::Row, ::Col + ::Pos - nDispPos + iif( ::cDelimit == NIL, 0, 1 ) )
   endif

   ::nOldPos := nDispPos

   SetCursor( nOldCursor )

return Self

/* ------------------------------------------------------------------------- */

METHOD ColorDisp( cColorSpec ) CLASS Get

   ::ColorSpec := cColorSpec
   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD End() CLASS Get

   local nLastCharPos, nPos, nFor

   if ::HasFocus
      nLastCharPos := Min( Len( RTrim( ::Buffer ) ) + 1, ::nMaxEdit )
      if ::Pos != nLastCharPos
         nPos := nLastCharPos
      else
         nPos := ::nMaxEdit
      endif
      for nFor := nPos to ::FirstEditable() step -1
         if ::IsEditable( nFor )
            ::Pos := nFor
            exit
         endif
      next
      ::Clear := .f.
      ::Display( .f. )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD Home() CLASS Get

   if ::HasFocus
      ::Pos := ::FirstEditable()
      ::Clear := .f.
      ::Display( .f. )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD Reset() CLASS Get

   if ::HasFocus
      ::Buffer   := ::PutMask( ::VarGet(), .f. )
      ::Pos      := ::FirstEditable() // ; Simple 0 in CA-Cl*pper
      ::Clear    := ( "K" $ ::cPicFunc .or. ::cType == "N" )
      ::lEdit    := .f.
      ::Minus    := .f.
      ::Rejected := .f.
      ::TypeOut  := ( ::Pos == 0 ) // ; Simple .f. in CA-Cl*pper
      ::Display()
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD Undo() CLASS Get

   if ::HasFocus
      ::VarPut( ::Original )
      ::Reset()
      ::Changed := .f.
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD SetFocus() CLASS Get

   local lWasNIL
   local xVarGet

   if ::HasFocus
      return Self
   endif

   lWasNIL := ::Buffer == NIL
   xVarGet := ::VarGet()
   
   ::HasFocus   := .t.
   ::Rejected   := .f.
   
   ::Original   := xVarGet
   ::cType      := ValType( xVarGet )
   ::Buffer     := ::PutMask( xVarGet, .f. )
   ::Picture    := ::cPicture
   ::Changed    := .f.
   ::Clear      := ( "K" $ ::cPicFunc .or. ::cType == "N" )
   ::lEdit      := .f.
   ::Pos        := ::FirstEditable()
   ::TypeOut    := ( ::Pos == 0 )
   
   if ::cType == "N"
      ::DecPos := At( iif( ::lDecRev .or. "E" $ ::cPicFunc, ",", "." ), ::Buffer )
      if ::DecPos == 0
         ::DecPos := Len( ::Buffer ) + 1
      endif
      ::lMinus := ( xVarGet < 0 )
   else
      ::DecPos := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
   endif
   
   ::lMinusPrinted := .f.
   ::Minus     := .f.
   ::BadDate   := ( ::cType == "D" ) .and. IsBadDate( ::Buffer, ::cPicFunc )
   
   if lWasNIL .and. ::Buffer != NIL
      if ::nDispLen == NIL
         ::nDispLen := ::nMaxLen
      endif
   endif
   
   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD KillFocus() CLASS Get

   local lHadFocus

   if ::lEdit
      ::Assign()
   endif

   lHadFocus := ::HasFocus

   ::HasFocus := .f.
   ::Pos      := 0
   ::Clear    := .f.
   ::Minus    := .f.
   ::Changed  := .f.
   ::DecPos   := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.

   if lHadFocus
      ::Display()
   endif

   ::xVarGet  := NIL
   ::Original := NIL
   ::Buffer   := NIL

return Self

/* ------------------------------------------------------------------------- */

METHOD VarPut( xValue, lReFormat ) CLASS Get

   local aSubs, nLen, aValue
   local i

   DEFAULT lReFormat TO .t.

   if ISBLOCK( ::bBlock )
      if ::SubScript == NIL
         Eval( ::bBlock, xValue )
      else
         aSubs := ::SubScript
         nLen := Len( aSubs )
         aValue := Eval( ::bBlock )
         for i := 1 to nLen - 1
            aValue := aValue[ aSubs[ i ] ]
         next
         aValue[ aSubs[ i ] ] := xValue
      endif

      if lReFormat
         ::cType   := ValType( xValue )
         ::xVarGet := xValue
         ::lEdit   := .f.
         ::Picture := ::cPicture
      endif
   endif

return xValue

/* ------------------------------------------------------------------------- */

METHOD VarGet() CLASS Get

   local aSubs, nLen, aValue
   local i
   local xValue

   if ISBLOCK( ::bBlock )
      if ::SubScript == NIL
         xValue := Eval( ::bBlock )
      else
         aSubs := ::SubScript
         nLen := Len( aSubs )
         aValue := Eval( ::bBlock )
         for i := 1 to nLen - 1
            aValue := aValue[ aSubs[ i ] ]
         next
         xValue := aValue[ aSubs[ i ] ]
      endif
   else
      xValue := NIL
   endif

   ::xVarGet := xValue

return xValue

/* ------------------------------------------------------------------------- */

METHOD UnTransform( cBuffer ) CLASS Get

   local xValue
   local cChar
   local nFor

   DEFAULT cBuffer TO ::Buffer

   do case
   case ::cType == "C"

      if "R" $ ::cPicFunc
         for nFor := 1 to Len( ::cPicMask )
            cChar := SubStr( ::cPicMask, nFor, 1 )
            if !cChar $ "ANX9#!"
               cBuffer := SubStr( cBuffer, 1, nFor - 1 ) + Chr( 1 ) + SubStr( cBuffer, nFor + 1 )
            endif
         next
         cBuffer := PadR( StrTran( cBuffer, Chr( 1 ), "" ), Len( ::Original ) )
      endif

      xValue := cBuffer

   case ::cType == "N"

      //::lMinus := .f.
      if "X" $ ::cPicFunc
         if Right( cBuffer, 2 ) == "DB"
            ::lMinus := .t.
         endif
      endif
      if !::lMinus
         for nFor := 1 to ::nMaxLen
            if ::IsEditable( nFor ) .and. IsDigit( SubStr( cBuffer, nFor, 1 ) )
               exit
            endif
            if SubStr( cBuffer, nFor, 1 ) $ "-(" .and. SubStr( cBuffer, nFor, 1 ) != SubStr( ::cPicMask, nFor, 1 )
               ::lMinus := .t.
               exit
            endif
         next
      endif
      cBuffer := Space( ::FirstEditable() - 1 ) + SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 )

      if "D" $ ::cPicFunc
         for nFor := ::FirstEditable() to ::LastEditable()
            if !::IsEditable( nFor )
               cBuffer := Left( cBuffer, nFor-1 ) + Chr( 1 ) + SubStr( cBuffer, nFor+1 )
            endif
         next
      else
         if "E" $ ::cPicFunc .or. ::lDecRev
            cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ".", " " ) + SubStr( cBuffer, ::LastEditable() + 1 )
            cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", "." ) + SubStr( cBuffer, ::LastEditable() + 1 )
         else
            cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", " " ) + SubStr( cBuffer, ::LastEditable() + 1 )
         endif

         for nFor := ::FirstEditable() to ::LastEditable()
            if !::IsEditable( nFor ) .and. SubStr( cBuffer, nFor, 1 ) != "."
               cBuffer := Left( cBuffer, nFor-1 ) + Chr( 1 ) + SubStr( cBuffer, nFor+1 )
            endif
         next
      endif

      cBuffer := StrTran( cBuffer, Chr( 1 ), "" )

      cBuffer := StrTran( cBuffer, "$", " " )
      cBuffer := StrTran( cBuffer, "*", " " )
      cBuffer := StrTran( cBuffer, "-", " " )
      cBuffer := StrTran( cBuffer, "(", " " )
      cBuffer := StrTran( cBuffer, ")", " " )

      cBuffer := PadL( StrTran( cBuffer, " ", "" ), Len( cBuffer ) )

      if ::lMinus
         for nFor := 1 to Len( cBuffer )
            if IsDigit( SubStr( cBuffer, nFor, 1 ) )
               exit
            endif
         next
         nFor--
         if nFor > 0
            cBuffer := Left( cBuffer, nFor-1 ) + "-" + SubStr( cBuffer, nFor+1 )
         else
            cBuffer := "-" + cBuffer
         endif
      endif

#if ( __HARBOUR__ - 0 ) < 0x030200
      xValue  := Val( cBuffer )
#else
      xValue  := hb_Val( cBuffer )
#endif

   case ::cType == "L"
      cBuffer := Upper( cBuffer )
      xValue := "T" $ cBuffer .or. "Y" $ cBuffer .or. hb_LangMessage( HB_LANG_ITEM_BASE_TEXT + 1 ) $ cBuffer

   case ::cType == "D"
      if "E" $ ::cPicFunc
         cBuffer := SubStr( cBuffer, 4, 3 ) + SubStr( cBuffer, 1, 3 ) + SubStr( cBuffer, 7 )
      endif
      if cBuffer != NIL
         xValue := CToD( cBuffer )
      endif

   endcase

return xValue

/* ------------------------------------------------------------------------- */

METHOD OverStrike( cChar ) CLASS Get

   if ! ::HasFocus
      return Self
   endif

   if ::cType == "N" .and. ! ::lEdit .and. ::Clear
      ::Pos := ::FirstEditable()
   endif
   
   if ::Pos > ::nMaxEdit
      ::Rejected := .t.
      return Self
   endif
   
   cChar := ::Input( cChar )
   
   if cChar == ""
      ::Rejected := .t.
      return Self
   else
      ::Rejected := .f.
   endif
   
   if ::Clear .and. ::Pos == ::FirstEditable()
      ::DeleteAll()
      ::Clear := .f.
   endif
   
   ::lEdit := .t.
   
   if ::Pos == 0
      ::Pos := 1
   endif
   
   do while ! ::IsEditable( ::Pos ) .and. ::Pos <= ::nMaxEdit
      ::Pos++
   enddo
   
   if ::Pos > ::nMaxEdit
      ::Pos := ::FirstEditable()
   endif
   ::Buffer := SubStr( ::Buffer, 1, ::Pos - 1 ) + cChar + SubStr( ::Buffer, ::Pos + 1 )
   
   ::Changed := .t.
   
   ::Right( .f. )
   
   ::BadDate := ( ::cType == "D" ) .and. IsBadDate( ::Buffer, ::cPicFunc )
   
   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD Insert( cChar ) CLASS Get

   local n
   local nMaxEdit

   if ! ::HasFocus
      return Self
   endif

   nMaxEdit := ::nMaxEdit
   
   if ::cType == "N" .and. ! ::lEdit .and. ::Clear
      ::Pos := ::FirstEditable()
   endif
   
   if ::Pos > ::nMaxEdit
      ::Rejected := .t.
      return Self
   endif
   
   cChar := ::Input( cChar )
   
   if cChar == ""
      ::Rejected := .t.
      return Self
   else
      ::Rejected := .f.
   endif

   if ::Clear .and. ::Pos == ::FirstEditable()
      ::DeleteAll()
      ::Clear := .f.
   endif
   
   ::lEdit := .t.
   
   if ::Pos == 0
      ::Pos := 1
   endif
   
   do while ! ::IsEditable( ::Pos ) .and. ::Pos <= ::nMaxEdit
      ::Pos++
   enddo
   
   if ::Pos > ::nMaxEdit
      ::Pos := ::FirstEditable()
   endif
   
   if ::lPicComplex
      // Calculating diferent nMaxEdit for ::lPicComplex
   
      for n := ::Pos to nMaxEdit
         if !::IsEditable( n )
            exit
         endif
      next
      nMaxEdit := n
      ::Buffer := Left( SubStr( ::Buffer, 1, ::Pos-1 ) + cChar +;
                  SubStr( ::Buffer, ::Pos, nMaxEdit-1-::Pos ) +;
                  SubStr( ::Buffer, nMaxEdit ), ::nMaxLen )
   else
      ::Buffer := Left( SubStr( ::Buffer, 1, ::Pos-1 ) + cChar + SubStr( ::Buffer, ::Pos ), ::nMaxEdit )
   endif
   
   ::Changed := .t.
   
   ::Right( .f. )
   
   ::BadDate := ( ::cType == "D" ) .and. IsBadDate( ::Buffer, ::cPicFunc )
   
   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD _Right( lDisplay ) CLASS Get

   local nPos

   if ! ::HasFocus
      return Self
   endif

   DEFAULT lDisplay TO .t.
   
   ::TypeOut := .f.
   ::Clear   := .f.
   
   if ::Pos == ::nMaxEdit
      ::TypeOut := .t.
      return Self
   endif
   
   nPos := ::Pos + 1
   
   do while ! ::IsEditable( nPos ) .and. nPos <= ::nMaxEdit
      nPos++
   enddo
   
   if nPos <= ::nMaxEdit
      ::Pos := nPos
   else
      ::TypeOut := .t.
   endif
   
   if lDisplay
      ::Display( .f. )
   endif
   
return Self

/* ------------------------------------------------------------------------- */

METHOD _Left( lDisplay ) CLASS Get

   local nPos

   if ! ::HasFocus
      return Self
   endif

   DEFAULT lDisplay TO .t.

   ::TypeOut := .f.
   ::Clear   := .f.

   if ::Pos == ::FirstEditable()
      ::TypeOut := .t.
      return Self
   endif

   nPos := ::Pos - 1

   do while ! ::IsEditable( nPos ) .and. nPos > 0
      nPos--
   enddo

   if nPos > 0
      ::Pos := nPos
   else
      ::TypeOut := .t.
   endif

   if lDisplay
      ::Display( .f. )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD WordLeft() CLASS Get

   local nPos

   if ! ::HasFocus
      return Self
   endif

   ::TypeOut := .f.
   ::Clear   := .f.

   if ::Pos == ::FirstEditable()
      ::TypeOut := .t.
      return Self
   endif

   nPos := ::Pos - 1

   do while nPos > 0
      if SubStr( ::Buffer, nPos, 1 ) == " "
         do while nPos > 0 .and. SubStr( ::Buffer, nPos, 1 ) == " "
            nPos--
         enddo
         do while nPos > 0 .and. !( SubStr( ::Buffer, nPos, 1 ) == " " )
            nPos--
         enddo
         if nPos > 0
            nPos++
         endif
         exit
      endif
      nPos--
   enddo

   if nPos < 1
      nPos := 1
   endif

   if nPos > 0
      ::Pos := nPos
   endif

   ::Display( .f. )

return Self

/* ------------------------------------------------------------------------- */

METHOD WordRight() CLASS Get

   local nPos

   if ! ::HasFocus
      return Self
   endif

   ::TypeOut := .f.
   ::Clear   := .f.

   if ::Pos == ::nMaxEdit
      ::TypeOut := .t.
      return Self
   endif

   nPos := ::Pos + 1

   do while nPos <= ::nMaxEdit
      if SubStr( ::Buffer, nPos, 1 ) == " "
         do while nPos <= ::nMaxEdit .and. SubStr( ::Buffer, nPos, 1 ) == " "
            nPos++
         enddo
         exit
      endif
      nPos++
   enddo

   if nPos > ::nMaxEdit
      nPos := ::nMaxEdit
   endif

   if nPos <= ::nMaxEdit
      ::Pos := nPos
   endif

   ::Display( .f. )

return Self

/* ------------------------------------------------------------------------- */

METHOD ToDecPos() CLASS Get

   if ! ::HasFocus
      return Self
   endif

   if ::Pos == ::FirstEditable()
      ::DeleteAll()
   endif

   ::Clear   := .f.
   ::lEdit   := .t.
   ::Buffer  := ::PutMask( ::UnTransform(), .f. )
   ::Changed := .t.

   if ::DecPos != 0
      if ::DecPos == Len( ::cPicMask )
         ::Pos := ::DecPos - 1   //9999.
      else
         ::Pos := ::DecPos + 1   //9999.9
      endif
   else
      ::Pos := ::nDispLen
   endif

   ::Display()

return Self
	
/* ------------------------------------------------------------------------- */

METHOD IsEditable( nPos ) CLASS Get

   local cChar

   if Empty( ::cPicMask )
      return .t.
   endif

   if ::nMaxEdit == NIL .or. nPos > ::nMaxEdit
      return .f.
   endif

   cChar := SubStr( ::cPicMask, nPos, 1 )

   do case
   case ::cType == "C"
      return cChar $ "!ANX9#"
   case ::cType == "N"
      return cChar $ "9#$*"
   case ::cType == "D"
      return cChar == "9"
   case ::cType == "L"
      return cChar $ "LY#"   /* Clipper 5.2 undocumented: # allow T,F,Y,N for Logical [ckedem] */
   endcase

return .f.

/* ------------------------------------------------------------------------- */

METHOD Input( cChar ) CLASS Get

   local cPic

   do case
   case ::cType == "N"

      do case
      case cChar == "-"
         ::lMinus := .t.  /* The minus symbol can be written in any place */
         ::Minus := .t.

      case cChar $ ".,"
         ::toDecPos()
         return ""

      case ! ( cChar $ "0123456789+" )
         return ""
      endcase

   case ::cType == "D"

      if !( cChar $ "0123456789" )
         return ""
      endif

   case ::cType == "L"

      if !( Upper( cChar ) $ "YNTF" )
         return ""
      endif

   endcase

   if ! Empty( ::cPicFunc )
      cChar := Left( Transform( cChar, ::cPicFunc ), 1 ) // Left needed for @D
   endif

   if ! Empty( ::cPicMask )
      cPic  := SubStr( ::cPicMask, ::Pos, 1 )

//    cChar := Transform( cChar, cPic )
// Above line eliminated because some get picture template symbols for
// numeric input not work in text input. eg: $ and *

      do case
      case cPic == "A"
         if ! IsAlpha( cChar )
            cChar := ""
         endif

      case cPic == "N"
         if ! IsAlpha( cChar ) .and. ! IsDigit( cChar )
            cChar := ""
         endif

      case cPic == "9"
         if ! IsDigit( cChar ) .and. ! cChar $ "-+"
            cChar := ""
         endif
         if ::cType != "N" .and. cChar $ "-+"
            cChar := ""
         endif

      /* Clipper 5.2 undocumented: # allow T,F,Y,N for Logical [ckedem] */
      case cPic == "L" .or. ( cPic == "#" .and. ::cType == "L" )
         if !( Upper( cChar ) $ "YNTF" + ;
                                hb_langmessage( HB_LANG_ITEM_BASE_TEXT + 1 ) + ;
                                hb_langmessage( HB_LANG_ITEM_BASE_TEXT + 2 ) )
            cChar := ""
         endif

      case cPic == "#"
         if ! IsDigit( cChar ) .and. !( cChar == " " ) .and. !( cChar $ ".+-" )
            cChar := ""
         endif

      case cPic == "Y"
         if !( Upper( cChar ) $ "YN" )
            cChar := ""
         endif

      case ( cPic == "$" .or. cPic == "*" ) .and. ::cType == "N"
         if ! IsDigit( cChar ) .and. cChar != "-"
            cChar := ""
         endif
      otherwise
         cChar := Transform( cChar, cPic )
      end case
   endif

return cChar

/* ------------------------------------------------------------------------- */

METHOD PutMask( xValue, lEdit ) CLASS Get

   local cChar
   local cBuffer
   local cPicFunc
   local cMask
   local nFor
   //local nNoEditable := 0

   if ::cType == NIL
      // Not initialized yet
      ::Original := ::VarGet()
      ::cType    := ValType( ::Original )
      ::Picture  := ::cPicture
   endif

   cPicFunc := ::cPicFunc
   cMask    := ::cPicMask

   DEFAULT xValue TO ::VarGet()
   DEFAULT lEdit  TO ::HasFocus

   if xValue == NIL .or. ValType( xValue ) $ "AB"
      ::nMaxLen := 0
      return NIL
   endif

   if ::HasFocus
      cPicFunc := StrTran( cPicfunc, "B", "" )
      if cPicFunc == "@"
         cPicFunc := ""
      endif
   endif
   if lEdit .and. ::lEdit
      if ( "*" $ cMask ) .or. ( "$" $ cMask )
         cMask := StrTran( StrTran( cMask, "*", "9" ), "$", "9" )
      endif
   endif

   cBuffer := Transform( xValue, ;
               iif( Empty( cPicFunc ), ;
                  iif( ::lCleanZero .and. !::HasFocus, "@Z ", "" ), ;
                  cPicFunc + iif( ::lCleanZero .and. !::HasFocus, "Z", "" ) + " " ) ;
               + cMask )

   if ::cType == "N"
      if ( "(" $ cPicFunc .or. ")" $ cPicFunc ) .and. xValue >= 0
         cBuffer += " "
      endif

      if ( ( "C" $ cPicFunc .and. xValue <  0 ) .or.;
           ( "X" $ cPicFunc .and. xValue >= 0 ) ) .and.;
           !( "X" $ cPicFunc .and. "C" $ cPicFunc )
         cBuffer += "   "
      endif

      if xValue < 0
         ::lMinusPrinted := .t.
      else
         ::lMinusPrinted := .f.
      endif
   endif

   ::nMaxLen  := Len( cBuffer )
   ::nMaxEdit := ::nMaxLen

   if ::nDispLen == NIL
      ::nDispLen := ::nMaxLen
   endif

   if lEdit .and. ::cType == "N" .and. ! Empty( cMask )
      if "E" $ cPicFunc
         cMask := Left( cMask, ::FirstEditable() - 1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable( ) + 1 ), ",", Chr( 1 ) ) + SubStr( cMask, ::LastEditable() + 1 )
         cMask := Left( cMask, ::FirstEditable() - 1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable( ) + 1 ), ".", ","      ) + SubStr( cMask, ::LastEditable() + 1 )
         cMask := Left( cMask, ::FirstEditable() - 1 ) + StrTran( SubStr( cMask, ::FirstEditable(), ::LastEditable() - ::FirstEditable( ) + 1 ), Chr( 1 ), "." ) + SubStr( cMask, ::LastEditable() + 1 )
      endif
      for nFor := 1 to ::nMaxLen
         cChar := SubStr( cMask, nFor, 1 )
         if cChar $ ",." .and. SubStr( cBuffer, nFor, 1 ) $ ",."
            cBuffer := SubStr( cBuffer, 1, nFor - 1 ) + cChar + SubStr( cBuffer, nFor + 1 )
         endif
      next
      if ::lEdit .and. Empty( xValue )
         cBuffer := StrTran( cBuffer, "0", " " )
      endif
      if ::lDecRev
         cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ",", Chr( 1 ) ) + SubStr( cBuffer, ::LastEditable() + 1 )
         cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), ".", ","      ) + SubStr( cBuffer, ::LastEditable() + 1 )
         cBuffer := Left( cBuffer, ::FirstEditable() - 1 ) + StrTran( SubStr( cBuffer, ::FirstEditable(), ::LastEditable() - ::FirstEditable() + 1 ), Chr( 1 ), "." ) + SubStr( cBuffer, ::LastEditable() + 1 )
      endif
   endif

   if ::cType == "N"
      if "(" $ ::cPicFunc .or. ")" $ ::cPicFunc
         ::nMaxEdit--
      endif
      if "C" $ ::cPicFunc .or. "X" $ ::cPicFunc
         ::nMaxEdit -= 3
      endif
   endif

   if ::cType == "D" .and. ::BadDate
      cBuffer := ::Buffer
   endif

return cBuffer

/* ------------------------------------------------------------------------- */

METHOD BackSpace( lDisplay ) CLASS Get

   local nPos := ::Pos
   local nMinus

   DEFAULT lDisplay TO .t.

   if nPos > 1 .and. nPos == ::FirstEditable() .and. ::lMinus

      /* To delete the parenthesis (negative indicator) in a non editable position */

      nMinus := At( "(", SubStr( ::Buffer, 1, nPos-1 ) )

      if nMinus > 0 .and. SubStr( ::cPicMask, nMinus, 1 ) != "("

         ::lEdit := .t.

         ::Buffer := SubStr( ::Buffer, 1, nMinus - 1 ) + " " +;
                     SubStr( ::Buffer, nMinus + 1 )

         ::Changed := .t.

         if lDisplay
            ::Display()
         endif

         return Self

      endif

   endif

   ::Left()

   if ::Pos < nPos
      ::Delete( lDisplay )
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD _Delete( lDisplay ) CLASS Get

   LOCAL nMaxLen := ::nMaxLen, n

   DEFAULT lDisplay TO .t.

   ::Clear := .f.
   ::lEdit := .t.

   if ::lPicComplex
      // Calculating diferent nMaxLen for ::lPicComplex
      for n := ::Pos to nMaxLen
         if !::IsEditable( n )
            exit
         endif
      next
      nMaxLen := n - 1
   endif

   if ::cType == "N" .and. SubStr( ::Buffer, ::Pos, 1 ) $ "(-"
      ::lMinus := .f.
   endif

   ::Buffer := PadR( SubStr( ::Buffer, 1, ::Pos - 1 ) + ;
               SubStr( ::Buffer, ::Pos + 1, nMaxLen - ::Pos ) + " " +;
               SubStr( ::Buffer, nMaxLen + 1 ), ::nMaxLen )

   if ::cType == "D"
      ::BadDate := IsBadDate( ::Buffer, ::cPicFunc )
   else
      ::BadDate := .f.
   endif

   ::Changed := .t.

   if lDisplay
      ::Display()
   endif

return Self

/* ------------------------------------------------------------------------- */

METHOD DeleteAll() CLASS Get

   local xValue

   ::lEdit := .t.

   do case
      case ::cType == "C"
         xValue := Space( ::nMaxlen )
      case ::cType == "N"
         xValue   := 0
         ::lMinus := .f.
      case ::cType == "D"
         xValue := CToD( "" )
         ::BadDate := .f.
      case ::cType == "L"
         xValue := .f.
   endcase

   ::Buffer := ::PutMask( xValue, .t. )
   ::Pos    := ::FirstEditable()

return Self

/* ------------------------------------------------------------------------- */

METHOD DelEnd() CLASS Get

   local nPos := ::Pos

   if ! ::HasFocus
      return Self
   endif

   ::Pos := ::nMaxEdit

   ::Delete( .f. )
   do while ::Pos > nPos
      ::BackSpace( .f. )
   enddo

   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD DelLeft() CLASS Get

   ::Left( .f. )
   ::Delete( .f. )
   ::Right()

return Self

/* ------------------------------------------------------------------------- */

METHOD DelRight() CLASS Get

   ::Right( .f. )
   ::Delete( .f. )
   ::Left()

return Self

/* ------------------------------------------------------------------------- */

/* NOTE ::WordLeft()
        ::DelWordRight() */

METHOD DelWordLeft() CLASS Get

   if ! ::HasFocus
      return Self
   endif

   if !( SubStr( ::Buffer, ::Pos, 1 ) == " " )
      if SubStr( ::Buffer, ::Pos - 1, 1 ) == " "
         ::BackSpace( .f. )
      else
         ::WordRight()
         ::Left()
      endif
   endif

   if SubStr( ::Buffer, ::Pos, 1 ) == " "
      ::Delete( .f. )
   endif

   do while ::Pos > 1 .and. !( SubStr( ::Buffer, ::Pos - 1, 1 ) == " " )
      ::BackSpace( .f. )
   enddo

   ::Display()

return Self

/* ------------------------------------------------------------------------- */

METHOD DelWordRight() CLASS Get

   if ! ::HasFocus
      return Self
   endif

   ::TypeOut := .f.
   ::Clear   := .f.

   if ::Pos == ::nMaxEdit
      ::TypeOut := .t.
      return Self
   endif

   do while ::Pos <= ::nMaxEdit .and. !( SubStr( ::Buffer, ::Pos, 1 ) == " " )
      ::Delete( .f. )
   enddo

   if ::Pos <= ::nMaxEdit
      ::Delete( .f. )
   endif

   ::Display()

return Self

/* ------------------------------------------------------------------------- */

/* The METHOD ColorSpec and DATA cColorSpec allow to replace the
 * property ColorSpec for a function to control the content and
 * to carry out certain actions to normalize the data.
 * The particular case is that the function receives a single color and
 * be used for GET_CLR_UNSELECTED and GET_CLR_ENHANCED.
 */

METHOD ColorSpec( cColorSpec ) CLASS Get

   local cClrUnSel
   local cClrEnh

   if cColorSpec != NIL

      cClrUnSel := iif( !Empty( hb_ColorIndex( cColorSpec, GET_CLR_UNSELECTED ) ),;
                                hb_ColorIndex( cColorSpec, GET_CLR_UNSELECTED ),;
                                hb_ColorIndex( SetColor(), CLR_UNSELECTED ) )

      cClrEnh   := iif( !Empty( hb_ColorIndex( cColorSpec, GET_CLR_ENHANCED ) ),;
                                hb_ColorIndex( cColorSpec, GET_CLR_ENHANCED ),;
                                cClrUnSel )

      ::cColorSpec := cClrUnSel + "," + cClrEnh

   endif

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

   local cChar
   local nAt
   local nFor
   local cNum

   if cPicture != NIL

      ::nDispLen := NIL

      ::cPicture := cPicture

      cNum := ""
      
      if Left( cPicture, 1 ) == "@"
      
         nAt := At( " ", cPicture )
      
         if nAt == 0
            ::cPicFunc := Upper( cPicture )
            ::cPicMask := ""
         else
            ::cPicFunc := Upper( SubStr( cPicture, 1, nAt - 1 ) )
            ::cPicMask := SubStr( cPicture, nAt + 1 )
         endif
      
         if "D" $ ::cPicFunc
      
            ::cPicMask := Set( _SET_DATEFORMAT )
            ::cPicMask := StrTran( ::cPicmask, "y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "Y", "9" )
            ::cPicMask := StrTran( ::cPicmask, "m", "9" )
            ::cPicMask := StrTran( ::cPicmask, "M", "9" )
            ::cPicMask := StrTran( ::cPicmask, "d", "9" )
            ::cPicMask := StrTran( ::cPicmask, "D", "9" )
      
         endif
      
         if ( nAt := At( "S", ::cPicFunc ) ) > 0
            for nFor := nAt + 1 to Len( ::cPicFunc )
               if ! IsDigit( SubStr( ::cPicFunc, nFor, 1 ) )
                  exit
               else
                  cNum += SubStr( ::cPicFunc, nFor, 1 )
               endif
            next
            if Val( cNum ) > 0
               ::nDispLen := Val( cNum )
            endif
            ::cPicFunc := SubStr( ::cPicFunc, 1, nAt - 1 ) + SubStr( ::cPicFunc, nFor )
         endif
      
         if "Z" $ ::cPicFunc
            ::lCleanZero := .t.
         else
            ::lCleanZero := .f.
         endif
         ::cPicFunc := StrTran( ::cPicFunc, "Z", "" )
      
         if ::cPicFunc == "@"
            ::cPicFunc := ""
         endif
      else
         ::cPicFunc   := ""
         ::cPicMask   := cPicture
         ::lCleanZero := .f.
      endif
      
      if ::cType == NIL
         ::Original := ::xVarGet
         ::cType    := ValType( ::Original )
      endif
      
      if ::cType == "D"
         ::cPicMask := LTrim( ::cPicMask )
      endif
      
      // Comprobar si tiene la , y el . cambiado (Solo en Xbase++)
      
      ::lDecRev := "," $ Transform( 1.1, "9.9" )
      
      // Generate default picture mask if not specified
      
      if Empty( ::cPicMask )
      
         do case
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
            if ( nAt := At( iif( ::lDecRev, ",", "." ), cNum ) ) > 0
               ::cPicMask := Replicate( "9", nAt - 1 ) + iif( ::lDecRev, ",", "." )
               ::cPicMask += Replicate( "9", Len( cNum ) - Len( ::cPicMask ) )
            else
               ::cPicMask := Replicate( "9", Len( cNum ) )
            endif
      
         case ::cType == "C" .and. ::cPicFunc == "@9"
            ::cPicMask := Replicate( "9", Len( ::xVarGet ) )
            ::cPicFunc := ""
      
         endcase
      
      endif
      
      // Comprobar si tiene caracteres embebidos no modificables en la plantilla
      
      ::lPicComplex := .f.
      
      if ! Empty( ::cPicMask )
         for nFor := 1 to Len( ::cPicMask )
            cChar := SubStr( ::cPicMask, nFor, 1 )
            if !( cChar $ "!ANX9#" )
               ::lPicComplex := .t.
               exit
            endif
         next
      endif
      
      if ::HasFocus
         if ::cType == "N"
            ::DecPos := At( iif( ::lDecRev .or. "E" $ ::cPicFunc, ",", "." ), ;
                        Transform( 1, iif( Empty( ::cPicFunc ), "", ::cPicFunc + " " ) + ::cPicMask ) )
            if ::DecPos == 0
               ::DecPos := Len( ::Buffer ) + 1
            endif
         else
            ::DecPos := 0 // ; CA-Cl*pper NG says that it contains NIL, but in fact it contains zero.
         endif
      endif

      if ::nDispLen == NIL
         ::nDispLen := ::nMaxLen
      endif

   endif

return ::cPicture

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

   if bBlock != NIL .and. !::HasFocus

      ::bBlock   := bBlock
      ::cType    := ValType( ::Original )
      ::xVarGet  := NIL

   endif

return ::bBlock

/* ------------------------------------------------------------------------- */

#ifdef HB_COMPAT_C53

METHOD HitTest( nMRow, nMCol ) CLASS Get

   if ::Row != nMRow
      return HTNOWHERE
   endif

   if nMCol >= ::Col .and. ;
      nMCol <= ::Col + ::nDispLen + iif( ::cDelimit == NIL, 0, 2 )
      return HTCLIENT
   endif

   return HTNOWHERE

#endif

/* ------------------------------------------------------------------------- */

METHOD FirstEditable() CLASS Get

   local nFor

   if ::nMaxLen != NIL

      if ::IsEditable( 1 )
         return 1
      endif

      for nFor := 2 to ::nMaxLen
         if ::IsEditable( nFor )
            return nFor
         endif
      next

   endif

   ::TypeOut := .t.

   return 0

/* ------------------------------------------------------------------------- */

METHOD LastEditable() CLASS Get

   local nFor

   if ::nMaxLen != NIL

      for nFor := ::nMaxLen to 1 step -1
         if ::IsEditable( nFor )
            return nFor
         endif
      next

   endif

   ::TypeOut := .t.

   return 0

/* ------------------------------------------------------------------------- */

STATIC FUNCTION IsBadDate( cBuffer, cPicFunc )

   local nFor, nLen

   if "E" $ cPicFunc
      cBuffer := SubStr( cBuffer, 4, 3 ) + SubStr( cBuffer, 1, 3 ) + SubStr( cBuffer, 7 )
   endif

   if cBuffer == NIL .or. ! Empty( CToD( cBuffer ) )
      return .f.
   endif

   nLen := Len( cBuffer )

   for nFor := 1 to nLen
      if IsDigit( SubStr( cBuffer, nFor, 1 ) )
         return .t.
      endif
   next

   return .f.

/* ------------------------------------------------------------------------- */
