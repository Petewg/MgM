/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * HACKTRAY demo
 * Copyright 2011 Grigory Filatov <gfilatov@inbox.ru>
 * Based upon a nice work of Nibu babu thomas
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Static anEventIds := {;
	/*DisplayStartupMenu*/		305,;
	/*DisplayRunDialog*/		401,;
	/*DisplayLogoffDialog*/		402,;
	/*ArrangeCascade*/		403,;
	/*ArrangeTileHrz*/		404,;
	/*ArrangeTileVrt*/		405,;
	/*ShowDesktop*/			407,;
	/*ShowDateTimeDialog*/		408,;
	/*ShowTaskbarPrps*/		413,;
	/*MinAll*/			415,;
	/*MaxAll*/			416,;
	/*ShowDesktop2*/		419,;
	/*ShowTaskMngr	*/		420,;
	/*TaskBrCustomizeNtfy*/		421,;
	/*LockTaskbar*/			424,;
	/*HelpAndSuppCenter*/		503,;
	/*ControlPanel*/		505,;
	/*TurnOffCompDialog*/		506,;
	/*PrintersAndFaxesDialog*/	510,;
	/*FindFilesDialog*/		41093,;
	/*FindComputers*/		41094;
}

*--------------------------------------------------------*
Function Main
*--------------------------------------------------------*
	Local aComtoItems := {;
		"Start menu",;
		"Run dialog",;
		"Log off dialog",;
		"Cascade windows",;
		"Tile windows horizontally",;
		"Tile windows vertically",;
		"Show desktop",;
		"Date time dialog",;
		"Task bar properties",;
		"Minimize all",;
		"Maximize all",;
		"Show desktop 2",;
		"Show task manager",;
		"Task bar customize notifications",;
		"Lock taskbar",;
		"Help and support center",;
		"Control panel",;
		"Turn off computer dialog",;
		"Printers and faxes dialog",;
		"Find files dialog",;
		"Find computers" }

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 336 ;
		HEIGHT 108 ;
		TITLE 'HackTray' ;
		MAIN ;
		NOMAXIMIZE NOSIZE PALETTE

		@ 15,10 LABEL Label_1 ;
			VALUE 'Shell event:' ;
			FONT 'MS Sans Serif' SIZE 9

		DEFINE COMBOBOX Combo_1
			ROW	12
			COL	76
			WIDTH	240
			ITEMS	aComtoItems
			VALUE	0
			ON CHANGE OnComboAction()
			ON ENTER OnComboAction()
			FONTNAME 'MS Sans Serif'
			FONTSIZE 9
		END COMBOBOX

		DEFINE BUTTON Button_1
			ROW	48
			COL	240
			CAPTION '&Cancel'
			WIDTH	74
			HEIGHT  23
			ACTION  ThisWindow.Release
			FONTNAME 'MS Sans Serif'
			FONTSIZE 9
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

#define WM_COMMAND	0x0111
*--------------------------------------------------------*
Procedure OnComboAction
*--------------------------------------------------------*
	Local nIndex := Form_1.Combo_1.Value

	Static hShellWnd

        if nIndex > 0
		hShellWnd := FindWindow( "Shell_TrayWnd", NIL )
		if hShellWnd != 0
			PostMessage( hShellWnd, WM_COMMAND, anEventIds[nIndex], 0 )
		else
			hShellWnd := FindWindow( "Shell_TrayWnd", NIL )
		endif
	endif

Return

*--------------------------------------------------------*
DECLARE DLL_TYPE_LONG ;
	FindWindow ( DLL_TYPE_LPSTR lpClassName, DLL_TYPE_LPSTR lpWindowName ) ;
	IN USER32.DLL
*--------------------------------------------------------*
