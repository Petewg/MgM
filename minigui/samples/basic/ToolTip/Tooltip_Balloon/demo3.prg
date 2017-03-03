//================================================================//
// Programa......: Tooltip com título e ícone
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//

#include "minigui.ch"

Function Main

	Set ToolTipBalloon On

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "Tooltip with title and icon" ;
		MAIN

		@ 75,150 BUTTON Button1 CAPTION "Exit" ACTION Form1.Release ;
	         TOOLTIP "Tooltip ICON will be disabled after 3 secs."

		DEFINE TIMER Timer1 INTERVAL 3000 ACTION icon_none()

	END WINDOW

	ADD TOOLTIPICON WARNING WITH MESSAGE "Warning" OF Form1

	// NOTE: When visual styles are enabled, setting TEXTCOLOR & BACKCOLOR has no effect.
	SET TOOLTIP TEXTCOLOR TO RED OF Form1  
	SET TOOLTIP BACKCOLOR TO WHITE OF Form1

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil


procedure icon_none

	CLEAR TOOLTIPICON OF Form1

	Form1.Timer1.Release

return