//================================================================//
// Programa......: Tooltip com título e ícone
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//

#include "minigui.ch"

Function Main

	SET TOOLTIPBALLOON ON

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "Tooltip with title and icon" ;
		MAIN

		@ 75,150 BUTTON Button1 CAPTION "Ok" ACTION Form1.Release ;
	         TOOLTIP "Click here to close this window."

	END WINDOW

	ADD TOOLTIPICON INFO WITH MESSAGE "Attention" OF Form1

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil
