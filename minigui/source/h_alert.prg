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
   Copyright 1999-2020, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

----------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
#  define __MINIPRINT__
#else
   SET PROCEDURE TO alerts.prg
#endif

#include "hmg.ch"
#include "i_winuser.ch"

/*
   Author    : Francisco Garcia Fernandez
   Objective : Simulate Clipper ALERT function
             : HMG_Alert( cText, [<aOptions>], [<cTitle>], [<nType>], [<cIcoName>], [<nIcoSize>], [<aBtnColors>], [<bInit>], [<lClosable>], [<cFontName>] )

              cText      -> As in Clipper, let's separate the lines with semicolon

              aOptions   -> same as in Clipper
                         -> if you pass a numeric value
                            wait so many seconds and cancel only
                            if a button is pressed, it stops waiting and ends

              cTitle     -> the title of the window, by default it leaves "Attention"

              nType      -> 1, 2, 3, 4
                            if aOptions has only one and is not passed nType
                            this one is equal 1
                            if aOptions has two or more and is not passed nType
                            this is equal 2

              cIcoName   -> optional an icon's name defined by user

              nIcoSize   -> 32 [default], 48, 64 optional an icon's size

              aBtnColors -> optional array of colors for the buttons

              bInit      -> optional initial block of code for additional tuning

   Last Modified by Grigory Filatov at 14-05-2020
*/

#define MARGIN          32
#define MARGIN_ICON     70
#define VMARGIN_BUTTON  4
#define HMARGIN_BUTTON  22
#define SEP_BUTTON      10

STATIC lIsWin10, lPressButton
STATIC aBackColor, aFontColor

*-----------------------------------------------------------------------------*
FUNCTION HMG_Alert( cMsg, aOptions, cTitle, nType, cIcoFile, nIcoSize, aBtnColors, bInit, lClosable, cFontName )
*-----------------------------------------------------------------------------*
   LOCAL nLineas
   LOCAL aIcon := { "ALERT", "QUESTION", "INFO", "STOP" }
   LOCAL lFont := .F.
   LOCAL lEmpty := ( Empty( aOptions ) .OR. ISNUMERIC( aOptions ) )
   LOCAL cForm := "oDlg"
   LOCAL nMaxLen := 0

   IF _IsWindowDefined( cForm )
      nLineas := 0
      WHILE _IsWindowDefined( cForm := "oDlg" + hb_ntos( ++nLineas ) )
      END
   ENDIF

   lPressButton := .F.
   lIsWin10 := hb_osIsWin10()

   hb_default( @aBackColor, nRGB2Arr( GetSysColor( COLOR_BTNFACE ) ) )
   hb_default( @aFontColor, nRGB2Arr( GetSysColor( COLOR_BTNTEXT ) ) )

   DEFAULT cTitle TO "Attention", aOptions TO { "&OK" }, lClosable TO .F., cFontName TO "DlgFont"

   IF ValType( aOptions ) == "A"
      DEFAULT nType := iif( Len( aOptions ) > 1, 2, 1 )
   ELSE
      DEFAULT nType := 1
   ENDIF

#ifdef _HMG_COMPAT_
   CHECK TYPE cMsg AS USUAL, ;
      aOptions AS USUAL, ;
      cTitle AS CHARACTER, ;
      nType AS NUMERIC, ;
      cIcoFile AS USUAL, ;
      nIcoSize AS USUAL, ;
      aBtnColors AS USUAL, ;
      bInit AS USUAL, ;
      lClosable AS LOGICAL, ;
      cFontName AS CHARACTER
#endif
   IF nType < 1 .OR. nType > 4
      nType := 1
   ENDIF

   AEval( aIcon, {| x, i | aIcon[ i ] := "ZZZ_B_" + x } )

   DEFAULT cIcoFile := aIcon[ nType ], nIcoSize := 32

   IF GetFontHandle( cFontName ) == 0
      lFont := .T.
      DEFINE FONT ( cFontName ) FONTNAME GetDefaultFontName() SIZE GetDefaultFontSize() - iif( lIsWin10, 1, 0 )
   ENDIF

   cMsg := cValToChar( cMsg )
   cMsg := StrTran( cMsg, ";", CRLF )
   nLineas := MLCount( cMsg )

   IF Chr( 9 ) $ cMsg
      cMsg := StrTran( cMsg, Chr( 9 ), Space( 3 ) )
   ENDIF

   AEval( hb_ATokens( cMsg, CRLF ), {| ct | nMaxLen := Max( nMaxLen, Len( Trim( ct ) ) ) } )

   IF lEmpty
      lClosable := .T.
      _HMG_ModalDialogReturn := 0
   ELSE
      hb_default( @_HMG_ModalDialogReturn, 0 )
   ENDIF

   DEFINE WINDOW ( cForm ) WIDTH 0 HEIGHT 0 TITLE cTitle MODAL NOSIZE BACKCOLOR aBackColor ;
      ON INTERACTIVECLOSE ( lPressButton .OR. lClosable ) ;
      ON RELEASE iif( ! lPressButton .AND. lClosable, _HMG_ModalDialogReturn := 0, NIL )

      FillDlg( cMsg, aOptions, nLineas, cIcoFile, nIcoSize, aBtnColors, bInit, lClosable, cFontName, nMaxLen )

   END WINDOW

   ACTIVATE WINDOW ( cForm )

   IF lFont
      RELEASE FONT ( cFontName )
   ENDIF

RETURN _HMG_ModalDialogReturn

*-----------------------------------------------------------------------------*
FUNCTION HMG_Alert_MaxLines( nMaxLines )
*-----------------------------------------------------------------------------*
   STATIC s_nMaxLines := 20

   LOCAL nOldLines := s_nMaxLines

   IF HB_ISNUMERIC( nMaxLines ) .AND. nMaxLines > 0
      s_nMaxLines := nMaxLines
   ENDIF

RETURN nOldLines

*-----------------------------------------------------------------------------*
FUNCTION HMG_Alert_RowStart( nRow )
*-----------------------------------------------------------------------------*
   STATIC s_nRowStart := 0

   LOCAL nOldRow := s_nRowStart

   IF HB_ISNUMERIC( nRow ) .AND. nRow >= 0
      s_nRowStart := nRow
   ENDIF

RETURN nOldRow

*-----------------------------------------------------------------------------*
STATIC FUNCTION FillDlg( cMsg, aOptions, nLineas, cIcoFile, nIcoSize, aBtnColors, bBlock, lClosable, cFont, nMaxLen )
*-----------------------------------------------------------------------------*
   LOCAL hWnd
   LOCAL hDC
   LOCAL hDlgFont
   LOCAL aBut := {}
   LOCAL cForm := ThisWindow.Name
   LOCAL cLblName
   LOCAL cBtnName
   LOCAL nRow := HMG_Alert_RowStart()
   LOCAL nCol := MARGIN * 0.6
   LOCAL nOpc := 1
   LOCAL nMaxLin := 0
   LOCAL nMaxBoton := 0
   LOCAL nMaxLines := HMG_Alert_MaxLines()
   LOCAL nMaxHeight
   LOCAL nMaxWidth
   LOCAL nLenBotones
   LOCAL nLenaOp
   LOCAL nWidthCli, nHeightCli
   LOCAL nWidthDlg, nHeightDlg
   LOCAL nChrHeight
   LOCAL nHeightBtn
   LOCAL nVMARGIN_BUTTON := VMARGIN_BUTTON
   LOCAL nSeconds
   LOCAL n
   LOCAL lExt

#ifdef _HMG_COMPAT_
   CHECK TYPE cMsg AS CHARACTER, ;
      aOptions AS USUAL, ;
      nLineas AS NUMERIC, ;
      cIcoFile AS CHARACTER, ;
      nIcoSize AS NUMERIC, ;
      aBtnColors AS USUAL, ;
      bBlock AS USUAL, ;
      lClosable AS LOGICAL, ;
      cFont AS CHARACTER, ;
      nMaxLen AS NUMERIC
#endif
   IF ValType( aOptions ) == "N"

      nSeconds := aOptions
      aOptions := { "&OK" }

      DEFINE TIMER oTimer OF ( cForm ) INTERVAL nSeconds * 1000 ACTION ( lPressButton := .T., ThisWindow.Release() )

      This.oTimer.Enabled := .F.

   ENDIF

   nLenaOp := iif( ValType( aOptions ) == "A", Len( aOptions ), 1 )

   IF ( lExt := ( ISARRAY( aBtnColors ) .AND. Len( aBtnColors ) == nLenaOp ) )
      nVMARGIN_BUTTON := 3 * VMARGIN_BUTTON
   ENDIF

   hDlgFont := GetFontHandle( cFont )

   // calculate the column of the text output

   IF nIcoSize > 0
      nCol := MARGIN_ICON + iif( nIcoSize == 32, 0, MARGIN_ICON / iif( nIcoSize == 64, 2.8, 3.2 ) )
   ENDIF

   hWnd := This.Handle
   hDC := GetDC( hWnd )

   // calculate the character height for the dialog font

   nChrHeight := GetTextHeight( hDC, aOptions[ 1 ], hDlgFont ) + nVMARGIN_BUTTON / 2

   // calculate the maximum width of the lines

   nMaxWidth := GetFontWidth( cFont, nMaxLen )
   IF GetTextWidth( hDC, Space( 10 ), hDlgFont ) != GetTextWidth( hDC, Replicate( "B", 10 ), hDlgFont )
      nMaxWidth *= 0.7
   ENDIF

   FOR n := 1 TO nLineas
      nMaxLin := Max( nMaxLin, GetTextWidth( hDC, AllTrim( MemoLine( cMsg,, n ) ), hDlgFont ) )
   NEXT

   // calculate the maximum width of the buttons

   FOR n := 1 TO nLenaOp
      nMaxBoton := Max( nMaxBoton, GetTextWidth( hDC, aOptions[ n ], hDlgFont ) )
   NEXT

   ReleaseDC( hWnd, hDC )

   nMaxBoton += ( HMARGIN_BUTTON * iif( ! lExt .AND. lIsWin10 .AND. nLenAop > 2, 1.1, iif( nLenAop > 1, 2, 3 ) ) )

   // calculate the width of the options + their separations

   nLenBotones := ( nMaxBoton + SEP_BUTTON ) * nLenaOp

   nHeightBtn := nVMARGIN_BUTTON + nChrHeight + nVMARGIN_BUTTON

   // calculate the width of the client area

   IF nMaxWidth > nMaxLin
      nMaxLin := nMaxWidth
   ENDIF

   nWidthCli := Max( MARGIN_ICON + nMaxLin + MARGIN, MARGIN + nLenBotones + MARGIN - HMARGIN_BUTTON ) + iif( nIcoSize > 48, MARGIN / 4, 0 )
   nWidthDlg := nWidthCli + GetBorderWidth() + iif( nLineas > nMaxLines, MARGIN * 1.5, 0 )

   IF nWidthDlg > System.ClientWidth
      nMaxWidth := nWidthDlg - System.ClientWidth
      nWidthDlg := System.ClientWidth
   ELSE
      nMaxWidth := 0
   ENDIF

   nHeightCli := ( ( Min( nMaxLines, nLineas ) + iif( nLineas == 1, 4, 3 ) ) * nChrHeight ) + nVMARGIN_BUTTON + nHeightBtn + GetBorderHeight()
   nHeightDlg := nHeightCli + GetTitleHeight() + SEP_BUTTON + GetBorderHeight() / iif( lIsWin10, 2.5, 1 )

   IF MSC_VER() > 0 .AND. _HMG_IsThemed
      nWidthDlg += 10
      nHeightDlg += 10
   ENDIF

   IF nHeightDlg > System.ClientHeight
      n := 0
      WHILE ( nHeightDlg - ( nChrHeight * ( ++n ) ) ) > System.ClientHeight
      END
      nMaxHeight := nChrHeight * n
      nMaxLines  -= n
      nHeightDlg -= nMaxHeight
      nHeightCli -= nMaxHeight
   ENDIF

   This.Width := nWidthDlg

   This.Height := nHeightDlg

   IF Empty( nRow )
      nRow := nChrHeight
   ENDIF

   IF nLineas > 1

      IF nLineas > nMaxLines

         cLblName := "Say_01"

         @ nRow + GetBorderHeight(), nCol EDITBOX ( cLblName ) VALUE AllTrim( cMsg ) OF ( cForm ) ;
            FONT cFont WIDTH nWidthCli - nCol + iif( nLineas < nMaxLines + 5, 0.9, 1 ) * MARGIN - nMaxWidth ;
            HEIGHT nChrHeight * nMaxLines + GetBorderHeight() ;
            FONTCOLOR aFontColor BACKCOLOR aBackColor READONLY NOHSCROLL
      ELSE

         FOR n := 1 TO nLineas

            cLblName := "Say_" + StrZero( n, 2 )

            @ nRow * ( n + iif( nLineas == 1, .5, 0 ) ) + GetBorderHeight(), nCol ;
               LABEL ( cLblName ) VALUE AllTrim( MemoLine( cMsg,, n ) ) OF ( cForm ) ;
               FONT cFont WIDTH nWidthCli - nCol - GetBorderWidth() - MARGIN / 4 - nMaxWidth ;
               HEIGHT nChrHeight ;
               FONTCOLOR aFontColor BACKCOLOR aBackColor VCENTERALIGN

         NEXT n

      ENDIF

   ELSE

      @ nRow + GetBorderHeight(), nCol LABEL Say_01 VALUE AllTrim( cMsg ) OF ( cForm ) ;
         FONT cFont WIDTH nWidthCli - nCol - GetBorderWidth() - MARGIN / 4 HEIGHT Max( nChrHeight, nIcoSize ) ;
         FONTCOLOR aFontColor BACKCOLOR aBackColor VCENTERALIGN

   ENDIF

   IF nIcoSize > 0

      DRAW ICON IN WINDOW ( cForm ) ;
         AT nRow + GetBorderHeight(), MARGIN / iif( nIcoSize == 32, 1.4, iif( nIcoSize == 48, 1.7, 2 ) ) ;
         PICTURE cIcoFile WIDTH nIcoSize HEIGHT nIcoSize TRANSPARENT

   ENDIF

   FOR n := 1 TO nLenaOp

      cBtnName := "Btn_" + StrZero( n, 2 )

      AAdd( aBut, cBtnName )

      IF lExt

         @ 0, 0 BUTTONEX ( cBtnName ) OF ( cForm ) CAPTION aOptions[ n ] ;
            FONTCOLOR aFontColor BACKCOLOR aBtnColors[ n ] NOXPSTYLE HANDCURSOR ;
            FONT cFont WIDTH nMaxBoton HEIGHT nVMARGIN_BUTTON + nChrHeight + nVMARGIN_BUTTON ;
            ACTION ( _HMG_ModalDialogReturn := This.Cargo, lPressButton := .T., ThisWindow.Release() )

      ELSE

         @ 0, 0 BUTTON ( cBtnName ) OF ( cForm ) CAPTION aOptions[ n ] ;
            FONT cFont WIDTH nMaxBoton HEIGHT nVMARGIN_BUTTON + nChrHeight + nVMARGIN_BUTTON ;
            ACTION ( _HMG_ModalDialogReturn := This.Cargo, lPressButton := .T., ThisWindow.Release() )

      ENDIF

      This.( aBut[ nOpc ] ).Cargo := nOpc++

   NEXT n

   nOpc := 1

   FOR n := nLenaOp TO 1 STEP -1
      This.( aBut[ n ] ).Row := nHeightCli + SEP_BUTTON + GetBorderHeight() / iif( lIsWin10, 2.5, .9 ) - nChrHeight - nHeightBtn
      This.( aBut[ n ] ).Col := nWidthCli - nMaxWidth + iif( nLineas > nMaxLines, MARGIN * 1.5, 0 ) + iif( lIsWin10, 0, GetBorderWidth() / 2 ) - ( nMaxBoton + SEP_BUTTON ) * nOpc++
   NEXT n

   This.Closable := lClosable

   This.( aBut[ Max( 1, Min( nLenaOp, _HMG_ModalDialogReturn ) ) ] ).SetFocus()

   This.Center()

   IF lClosable
      ON KEY ESCAPE OF ( cForm ) ACTION ( _HMG_ModalDialogReturn := 0, lPressButton := .T., ThisWindow.Release() )
   ENDIF

   IF HB_ISBLOCK( bBlock )
      Do_WindowEventProcedure( bBlock, This.Index, 'WINDOW_INIT' )
   ENDIF

   IF _IsControlDefined( "oTimer", cForm )
      This.oTimer.Enabled := .T.
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _SetMsgAlertColors( aBackClr, aFontClr )
*-----------------------------------------------------------------------------*
   LOCAL aOldClrs := { aBackColor, aFontColor }

   IF aBackClr != NIL
      aBackColor := aBackClr
   ENDIF

   IF aFontClr != NIL
      aFontColor := aFontClr
   ENDIF

RETURN aOldClrs

#ifdef _HMG_COMPAT_

*-----------------------------------------------------------------------------*
#ifndef __XHARBOUR__
PROCEDURE HMG_CheckType( lSoft, ... )
#else
PROCEDURE HMG_CheckType( ... )
#endif
*-----------------------------------------------------------------------------*
   LOCAL i, j
   LOCAL aParams, aData
   LOCAL aType := { ;
      { "ARRAY", "A" }, ;
      { "BLOCK", "B" }, ;
      { "CHARACTER", "C" }, ;
      { "DATE", "D" }, ;
      { "HASH", "H" }, ;
      { "LOGICAL", "L" }, ;
      { "NIL", "U" }, ;
      { "NUMERIC", "N" }, ;
      { "MEMO", "M" }, ;
      { "POINTER", "P" }, ;
      { "SYMBOL", "S" }, ;
      { "TIMESTAMP", "T" }, ;
      { "OBJECT", "O" }, ;
      { "USUAL", "" } }
#ifdef __XHARBOUR__
   LOCAL lSoft
#endif

   aParams := hb_AParams()

#ifdef __XHARBOUR__
   lSoft := aParams[ 1 ]
#endif
   hb_ADel( aParams, 1, .T. )    // Remove lSoft param of the array

   FOR EACH aData IN aParams

      // aData := { cTypeDef, cValType, cVarName }
      // aType := { cTypeDef, cValType }

      IF Upper( AllTrim( aData[ 1 ] ) ) <> "USUAL"

         IF !( lSoft .AND. AllTrim( aData[ 2 ] ) == "U" )

            i := AScan( aType, {| x | x[ 1 ] == Upper( AllTrim( aData[ 1 ] ) ) } )

            IF i == 0 .OR. aType[ i ][ 2 ] <> aData[ 2 ]

               j := AScan( aType, {| x | x[ 2 ] == aData[ 2 ] } )

               MsgMiniGuiError( "CHECK TYPE ( Param # " + hb_ntos( aData:__enumindex() ) + " ) : " + AllTrim( aData[ 3 ] ) + " is declared as " + Upper( AllTrim( aData[ 1 ] ) ) + " but it have type " + aType[ j ][ 1 ] + "." )

            ENDIF

         ENDIF

      ENDIF

   NEXT

RETURN

#endif

#ifdef __XHARBOUR__
#include "alerts.prg"
#endif
