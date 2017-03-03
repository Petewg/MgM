//================================================================//
// Programa......: Tooltip com título e ícone
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//

/*
  Revised: P.Ch. 16.10.
 */

#include "minigui.ch"

FUNCTION Main()

   SET TOOLTIPBALLOON ON

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "Tooltip Ballon com título e ícone (" + __FILE__ + ")" ;
		MAIN ;
		NOSIZE ;
		NOMAXIMIZE

		@ 117,150 BUTTON Button1 CAPTION "?" ACTION Form1.Release ;
			TOOLTIP "Clique aqui para fechar esta janela."

		Form1.Button1.Caption := "&Exit (" + hb_NToS( 13 ) + ")"
		Form1.Button1.Enabled := .F.

		DEFINE TIMER Timer1 INTERVAL 1000 ACTION AddToolTipIcon()

	END WINDOW

	SET TOOLTIP TEXTCOLOR TO RED   OF Form1
	SET TOOLTIP BACKCOLOR TO WHITE OF Form1

	CENTER   WINDOW Form1
	ACTIVATE WINDOW Form1

   RETURN NIL


PROCEDURE AddToolTipIcon()

   STATIC nTime := 12
   LOCAL  nIcon := If( IsVistaOrLater(), TTI_ERROR_LARGE, TTI_ERROR )

   IF nTime < 0

   	Form1.Timer1.Release
   	Form1.Button1.Caption := "&Exit"

   	// first clear
   	CLEAR TOOLTIPICON OF Form1
   	// and second - add
     	ADD TOOLTIPICON nIcon WITH MESSAGE Form1.Button1.Caption TO Form1

   	Form1.Button1.Enabled := .T.

   ELSE

   	Form1.Button1.Caption := "&Exit (" + hb_NToS( nTime -- ) + ")"

   ENDIF

   RETURN
