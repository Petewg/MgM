/*
 * Harbour MiniGUI Hello World Demo
 * (c) 2002-2009 Roberto Lopez
 */

#include "minigui.ch"

PROCEDURE Main

	DEFINE WINDOW Win_1		;
		CLIENTAREA 400, 400	;
		TITLE 'Hello World!'	;
		WINDOWTYPE MAIN

	END WINDOW

	Win_1.Center

	Win_1.Activate

RETURN
