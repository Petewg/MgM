#include "minigui.ch"

/*
      Autor : Francisco Garc¡a Fernandez
   Objetivo : Simular el alert de clipper
            : Alert( cTexto, [<aOpciones>], [<cTitulo>], [<nTipo>] )

             cTexto -> igual que en clipper, separamemos las lineas con ;
             aOpciones -> igual que en clipper
                       -> si se le pasa un valor num‚rico
                          espera tantos segundos y cancela solo
                          si se pulsa un boton deja de esperar y termina
             cTitulo -> el titulo de la ventana, por defecto sale "Atenci¢n"

             nTipo   -> 1, 2, 3, 4
                        si aOpciones tiene solo una y no se pasa nTipo
                        este vale 1
                        si aOpciones tiene 2 o mas y no se pasa nTipo
                        este vale 2
*/

#define MARGEN 50
#define MARGEN_ICON 70
#define VMARGEN_BOTON 4
#define HMARGEN_BOTON 20
#define SEP_BOTON 10

// -----------------------------------------------------------------//

FUNCTION _Alert( cMsg, aOpciones, cTitle, nTipo )

   LOCAL aIcon := { "ALERT", "QUESTION", "INFO", "STOP", "FLOPPY" }
   LOCAL cIcoFile
   LOCAL nLineas
   LOCAL lEmpty := ( Empty( aOpciones ) )

   DEFAULT cTitle    TO "Attention"
   DEFAULT aOpciones TO { "&OK" }

   IF ValType( aOpciones ) == "A"
      DEFAULT nTipo := iif( Len( aOpciones ) > 1, 2, 1 )
   ELSE
      DEFAULT nTipo := 1
   ENDIF

   IF nTipo < 1 .OR. nTipo > 5
      nTipo := 1
   ENDIF

   cIcoFile := aIcon[ nTipo ]

   IF ! _IsControlDefined( "DlgFont", "Main" )
      DEFINE FONT DlgFont FONTNAME "Ms Sans Serif" SIZE 10
   ENDIF

   cMsg    := cValToChar( cMsg )
   cMsg    := StrTran( cMsg, ";", CRLF )
   nLineas := MLCount( cMsg, 254 )

   DEFINE WINDOW oDlg ;
      At 0, 0 ;
      WIDTH 0 ;
      HEIGHT 0 ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE ;
      ON INIT FillDlg( cMsg, aOpciones, nLineas, cIcoFile )

   END WINDOW

   ACTIVATE WINDOW oDlg

   RELEASE FONT DlgFont

RETURN iif( lEmpty, 0, _HMG_ModalDialogReturn )

// -----------------------------------------------------------------//

STATIC FUNCTION FillDlg( cMsg, aOpciones, nLineas, cIcoFile )

   LOCAL n
   LOCAL nMaxLin := 0
   LOCAL nLenBotones
   LOCAL nLenaOp
   LOCAL nWidthCli
   LOCAL nHeightCli
   LOCAL nWidthDlg, nHeightDlg
   LOCAL nChrHeight
   LOCAL cLblName
   LOCAL cBtnName
   LOCAL nMaxBoton := 0
   LOCAL nHeightBtn
   LOCAL aBut := {}
   LOCAL nOpc := 1
   LOCAL nSeconds
   LOCAL hWnd := This.Handle
   LOCAL hDC := GetDC( hWnd )
   LOCAL hDlgFont := GetFontHandle( "DlgFont" )

   IF ValType( aOpciones ) == "N"

      nSeconds  := aOpciones
      aOpciones := { "&OK" }

      DEFINE TIMER oTimer OF oDlg INTERVAL nSeconds * 1000 ACTION oDlg.Release()

      oDlg.oTimer.Enabled := .F.

   ENDIF

   nLenaOp := iif( ValType( aOpciones ) == "A", Len( aOpciones ), 1 )

   nChrHeight := GetTextMetric( hDC )[ 1 ] + VMARGEN_BOTON

   // calculo el m ximo ancho de linea

   FOR n := 1 TO nLineas

      nMaxLin := Max( nMaxLin, GetTextWidth( hDC, AllTrim( MemoLine( cMsg,, n ) ), hDlgFont ) )

   NEXT

   // calculo el m ximo ancho de los botones

   FOR n := 1 TO nLenaOp

      nMaxBoton := Max( nMaxBoton, GetTextWidth( hDC, aOpciones[ n ], hDlgFont ) )

   NEXT

   ReleaseDC( hWnd, hDC )

   nMaxBoton += ( HMARGEN_BOTON * iif( nLenAop > 1, 2, 3 ) )

   // calculo el ancho de las opciones + sus separaciones
   nLenBotones := ( nMaxBoton + SEP_BOTON ) * nLenaOp

   nHeightBtn := nChrHeight + VMARGEN_BOTON + VMARGEN_BOTON

   // calculo el ancho del area cliente

   nWidthCli := Max( MARGEN_ICON + nMaxLin + MARGEN,;
      MARGEN + nLenBotones + MARGEN - HMARGEN_BOTON )

   nWidthDlg := nWidthCli + iif( _HMG_IsXP, 2, 1 ) * GetBorderWidth()

   nHeightCli := ( ( nLineas + iif( nLineas == 1, 4, 3 ) ) * nChrHeight ) + VMARGEN_BOTON + nHeightBtn

   nHeightDlg := nHeightCli + GetTitleHeight()

   oDlg.Width := nWidthDlg
   oDlg.Height := nHeightDlg
   oDlg.Center()

   FOR n := 1 TO nLineas

      cLblName := "Say_" + StrZero( n, 2 )

      @ nChrHeight * ( n + iif( nLineas == 1, .5, 0 ) ), MARGEN_ICON ;
         LABEL &cLblName VALUE AllTrim( MemoLine( cMsg,, n ) ) OF oDlg ;
         FONT "DlgFont" WIDTH nWidthCli - MARGEN_ICON HEIGHT nChrHeight CENTERALIGN

   NEXT n

   DRAW ICON IN WINDOW oDlg AT nChrHeight, MARGEN / 2 PICTURE cIcoFile WIDTH 32 HEIGHT 32

   FOR n := 1 TO nLenaOp

      cBtnName := "Btn_" + StrZero( n, 2 )

      AAdd( aBut, cBtnName )

      @ 0, 0 BUTTON &cBtnName OF oDlg CAPTION aOpciones[ n ] ;
         FONT "DlgFont" WIDTH nMaxBoton HEIGHT VMARGEN_BOTON + nChrHeight + VMARGEN_BOTON ;
         ACTION ( _HMG_ModalDialogReturn := oDlg.&( This.Name ).Cargo, oDlg.Release() )

      oDlg.&( aBut[ nOpc ] ).Cargo := nOpc++

   NEXT n

   nOpc := 1
   FOR n := nLenaOp TO 1 STEP -1

      oDlg.&( aBut[ n ] ).Row := nHeightCli - nChrHeight - nHeightBtn
      oDlg.&( aBut[ n ] ).Col := nWidthCli - ( nMaxBoton + SEP_BOTON ) * nOpc++

   NEXT n

   oDlg.&( aBut[ 1 ] ).SetFocus()

   _HMG_ModalDialogReturn := 0

   ON KEY ESCAPE OF oDlg ACTION oDlg.Release()

   IF _IsControlDefined( "oTimer", "oDlg" )
      oDlg.oTimer.Enabled := .T.
   ENDIF

RETURN NIL
