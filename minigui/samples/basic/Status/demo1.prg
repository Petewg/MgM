/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
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
Local nItem

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Statusbar Keyboard Demo' ;
		MAIN 

		DEFINE STATUSBAR KEYBOARD FONT 'Tahoma' SIZE 9

		END STATUSBAR

	END WINDOW

	DEFINE STATUSITEM 1 OF Form_1 ACTION OnClick()

	For nItem := 2 To 4
		DEFINE STATUSITEM nItem OF Form_1 ACTION MsgInfo("Click!")
	Next

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

#define STATUS_MESSAGE "HMG Power Ready!"

Procedure OnClick

	If Form_1.StatusBar.Item(1) == ThisWindow.Title
		Form_1.StatusBar.Item(1) := STATUS_MESSAGE
	EndIf

Return
