/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2007 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#command DEFINE STATUSITEM <n> ;
         OF <Form> ;
         ACTION <action> ;
      => ;
	_SetStatusItemAction( <n>, <{action}>, GetFormHandle(<"Form">) )


Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Statusbar Demo' ;
		MAIN 

		DEFINE STATUSBAR FONT 'Tahoma' SIZE 9

		END STATUSBAR

	END WINDOW

	DEFINE STATUSITEM 1 OF Form_1 ACTION OnClick()

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

#define STATUS_MESSAGE "HMG Power Ready!"

Procedure OnClick

	If Form_1.StatusBar.Item(1) == ThisWindow.Title
		Form_1.StatusBar.Item(1) := STATUS_MESSAGE
	Else
		Form_1.StatusBar.Item(1) := ThisWindow.Title
	EndIf

Return
