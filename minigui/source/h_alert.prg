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
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2018, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#ifdef __XHARBOUR__
  #define __MINIPRINT__
#endif

#include "hmg.ch"

/*
   Author    : Francisco Garcia Fernandez
   Objective : Simulate clipper alert
             : Alert (cText, [<aOptions>], [<cTitle>], [<nType>])

              cText    -> As in clipper, let's separate the lines with semicolon
              aOptions -> same as in clipper
                       -> if you pass a numeric value
                          wait so many seconds and cancel only
                          if a button is pressed, it stops waiting and ends
              cTitle   -> the title of the window, by default it leaves "Attention"

              nType    -> 1, 2, 3, 4
                          if aOptions has only one and is not passed nType
                          this one is equal 1
                          if aOptions has two or more and is not passed nType
                          this is equal 2

   Modified by Grigory Filatov at 18-02-2018
*/

#define MARGIN 50
#define MARGIN_ICON 70
#define VMARGIN_BUTTON 4
#define HMARGIN_BUTTON 22
#define SEP_BUTTON 10

*-----------------------------------------------------------------------------*
FUNCTION HMG_Alert( cMsg, aOptions, cTitle, nType )
*-----------------------------------------------------------------------------*
   LOCAL aIcon := { "ALERT", "QUESTION", "INFO", "STOP" }
   LOCAL cIcoFile
   LOCAL nLineas
   LOCAL lEmpty := ( Empty( aOptions ) )

   DEFAULT cTitle    TO "Attention"
   DEFAULT aOptions TO { "&OK" }

   IF ValType( aOptions ) == "A"
      DEFAULT nType := iif( Len( aOptions ) > 1, 2, 1 )
   ELSE
      DEFAULT nType := 1
   ENDIF
#ifdef _HMG_COMPAT_
   CHECK TYPE cMsg     AS USUAL, ;
              aOptions AS USUAL, ;
              cTitle   AS CHARACTER, ;
              nType    AS NUMERIC
#endif
   IF nType < 1 .OR. nType > 4
      nType := 1
   ENDIF

   AEval( aIcon, {|x, i| aIcon[ i ] := "ZZZ_B_" + x } )

   cIcoFile := aIcon[ nType ]

   IF ! _IsControlDefined( "DlgFont", "Main" )
      DEFINE FONT DlgFont FONTNAME "MS Shell Dlg" SIZE 9
   ENDIF

   cMsg     := cValToChar( cMsg )
   cMsg     := StrTran( cMsg, ";", CRLF )
   nLineas  := MLCount( cMsg, 254 )

   DEFINE WINDOW oDlg ;
      WIDTH 0 ;
      HEIGHT 0 ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE ;
      ON INIT FillDlg( cMsg, aOptions, nLineas, cIcoFile )

   END WINDOW

   ACTIVATE WINDOW oDlg

   RELEASE FONT DlgFont

RETURN iif( lEmpty, 0, _HMG_ModalDialogReturn )

*-----------------------------------------------------------------------------*
STATIC FUNCTION FillDlg( cMsg, aOptions, nLineas, cIcoFile )
*-----------------------------------------------------------------------------*
   LOCAL n
   LOCAL nMaxLin := 0
   LOCAL nLenBotones
   LOCAL nLenaOp
   LOCAL nWidthCli, nHeightCli
   LOCAL nWidthDlg, nHeightDlg
   LOCAL nChrHeight
   LOCAL cLblName
   LOCAL cBtnName
   LOCAL nMaxBoton := 0
   LOCAL nHeightBtn
   LOCAL aBut := {}
   LOCAL nOpc := 1
   LOCAL nSeconds
   LOCAL hWnd
   LOCAL hDC
   LOCAL hDlgFont

#ifdef _HMG_COMPAT_
   CHECK TYPE cMsg      AS CHARACTER, ;
              aOptions AS USUAL, ;
              nLineas   AS NUMERIC, ;
              cIcoFile  AS CHARACTER
#endif
   IF ValType( aOptions ) == "N"

      nSeconds  := aOptions
      aOptions := { "&OK" }

      DEFINE TIMER oTimer OF oDlg INTERVAL nSeconds * 1000 ACTION oDlg.Release()

      oDlg.oTimer.Enabled := .F.

   ENDIF

   nLenaOp := iif( ValType( aOptions ) == "A", Len( aOptions ), 1 )

   hWnd := This.Handle
   hDC := GetDC( hWnd )

   nChrHeight := GetTextMetric( hDC )[ 1 ] + VMARGIN_BUTTON / 2

   hDlgFont := GetFontHandle( "DlgFont" )

   // calculate the maximum line width

   FOR n := 1 TO nLineas

      nMaxLin := Max( nMaxLin, GetTextWidth( hDC, AllTrim( MemoLine( cMsg,, n ) ), hDlgFont ) )

   NEXT

   // calculate the maximum width of the buttons

   FOR n := 1 TO nLenaOp

      nMaxBoton := Max( nMaxBoton, GetTextWidth( hDC, aOptions[ n ], hDlgFont ) )

   NEXT

   ReleaseDC( hWnd, hDC )

   nMaxBoton += ( HMARGIN_BUTTON * iif( nLenAop > 1, 2, 3 ) )

   // calculate the width of the options + their separations
   nLenBotones := ( nMaxBoton + SEP_BUTTON ) * nLenaOp

   nHeightBtn := nChrHeight + VMARGIN_BUTTON + VMARGIN_BUTTON

   // calculate the width of the client area

   nWidthCli := Max( MARGIN_ICON + nMaxLin + MARGIN,;
      MARGIN + nLenBotones + MARGIN - HMARGIN_BUTTON )

   nWidthDlg := nWidthCli + iif( _HMG_IsXPorLater, 2, 1 ) * GetBorderWidth()

   nHeightCli := ( ( nLineas + iif( nLineas == 1, 4, 3 ) ) * nChrHeight ) + VMARGIN_BUTTON + nHeightBtn

   nHeightDlg := nHeightCli + GetTitleHeight() + SEP_BUTTON + GetBorderHeight()

   IF MSC_VER() > 0 .AND. _HMG_IsThemed
      nWidthDlg += 10
      nHeightDlg += 10
   ENDIF

   oDlg.Width := nWidthDlg
   oDlg.Height := nHeightDlg
   oDlg.Center()

   IF nLineas > 1

      FOR n := 1 TO nLineas

         cLblName := "Say_" + StrZero( n, 2 )

         @ nChrHeight * ( n + iif( nLineas == 1, .5, 0 ) ) + GetBorderHeight(), MARGIN_ICON ;
            LABEL &cLblName VALUE AllTrim( MemoLine( cMsg,, n ) ) OF oDlg ;
            FONT "DlgFont" WIDTH nWidthCli - MARGIN_ICON HEIGHT nChrHeight CENTERALIGN

      NEXT n

   ELSE

      @ nChrHeight * 1.5 + GetBorderHeight(), MARGIN_ICON ;
         LABEL Say_01 VALUE AllTrim( cMsg ) OF oDlg ;
         FONT "DlgFont" WIDTH nWidthCli - MARGIN_ICON HEIGHT nChrHeight

   ENDIF

   DRAW ICON IN WINDOW oDlg AT nChrHeight + GetBorderHeight(), MARGIN / 2 PICTURE cIcoFile WIDTH 32 HEIGHT 32

   FOR n := 1 TO nLenaOp

      cBtnName := "Btn_" + StrZero( n, 2 )

      AAdd( aBut, cBtnName )

      @ 0, 0 BUTTON &cBtnName OF oDlg CAPTION aOptions[ n ] ;
         FONT "DlgFont" WIDTH nMaxBoton HEIGHT VMARGIN_BUTTON + nChrHeight + VMARGIN_BUTTON ;
         ACTION ( _HMG_ModalDialogReturn := oDlg.&( This.Name ).Cargo, oDlg.Release() )

      oDlg.&( aBut[ nOpc ] ).Cargo := nOpc++

   NEXT n

   nOpc := 1
   FOR n := nLenaOp TO 1 STEP -1

      oDlg.&( aBut[ n ] ).Row := nHeightCli + SEP_BUTTON + GetBorderHeight() - nChrHeight - nHeightBtn
      oDlg.&( aBut[ n ] ).Col := nWidthCli + GetBorderWidth() - ( nMaxBoton + SEP_BUTTON ) * nOpc++

   NEXT n

   oDlg.&( aBut[ 1 ] ).SetFocus()

   _HMG_ModalDialogReturn := 0

   ON KEY ESCAPE OF oDlg ACTION oDlg.Release()

   IF _IsControlDefined( "oTimer", "oDlg" )
      oDlg.oTimer.Enabled := .T.
   ENDIF

RETURN NIL
