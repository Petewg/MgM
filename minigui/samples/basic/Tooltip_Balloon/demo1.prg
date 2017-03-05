//================================================================//
// Programa......: Tooltip com t�tulo e �cone
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//

/*
  Revized: P.Ch. 16.10.
 */

#include "minigui.ch"

FUNCTION Main

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "Tooltip com t�tulo e �cone" ;
		MAIN ;
      NOSIZE ;
      NOMAXIMIZE

		@ 117,150 BUTTON Button1 CAPTION "Close" ACTION Form1.Release ;
	         TOOLTIP "Clique aqui para fechar esta janela."

	END WINDOW

   IF IsVistaOrLater()
   	ADD TOOLTIPICON INFO_LARGE WITH TITLE "Aten��o" OF Form1
   ELSE
	   ADD TOOLTIPICON INFO       WITH TITLE "Aten��o" OF Form1
   ENDIF

	CENTER   WINDOW Form1
	ACTIVATE WINDOW Form1

   RETURN 0