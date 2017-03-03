/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Explore Windows Objects'
#define VERSION ' 1.0'
#define COPYRIGHT ' 2006 Grigory Filatov'

Procedure Main

	//	Define objects paths array
	Local aCombo := {}, aCLSIDs := {}

	aadd(	aCombo, "My Computer" )
	aadd(	aCLSIDs, "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" )
	aadd(	aCombo, "Control Panel" )
	aadd(	aCLSIDs, aCLSIDs[1]+"\::{21EC2020-3AEA-1069-A2DD-08002B30309D}" )
IF IsWinNT()
	aadd(	aCombo, "Printers and telecopiers" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{2227A280-3AEA-1069-A2DE-08002B30309D}" )
	aadd(	aCombo, "Fonts" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{D20EA4E1-3957-11d2-A40B-0C5020524152}" )
	aadd(	aCombo, "Scanners and cameras" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{E211B736-43FD-11D1-9EFB-0000F8757FCD}" )
	aadd(	aCombo, "Networkhood" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{7007ACC7-3202-11D1-AAD2-00805FC1270E}" )
	aadd(	aCombo, "Administration tools" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{D20EA4E1-3957-11d2-A40B-0C5020524153}" )
	aadd(	aCombo, "Tasks Scheduler" )
	aadd(	aCLSIDs, aCLSIDs[2]+"\::{D6277990-4C6A-11CF-8D87-00AA0060F5BF}" )
ENDIF
	aadd(	aCombo, "Web folders" )
	aadd(	aCLSIDs, aCLSIDs[1]+"\::{BDEADF00-C265-11D0-BCED-00A0C90AB50F}" )
	aadd(	aCombo, "My Documents" )
	aadd(	aCLSIDs, "{450D8FBA-AD25-11D0-98A8-0800361B1103}" )
	aadd(	aCombo, "Recycle Bin" )
	aadd(	aCLSIDs, "{645FF040-5081-101B-9F08-00AA002F954E}" )
	aadd(	aCombo, "Network favorites" )
	aadd(	aCLSIDs,"{208D2C60-3AEA-1069-A2D7-08002B30309D}" )
	aadd(	aCombo, "Default Navigator" )
	aadd(	aCLSIDs, "{871C5380-42A0-1069-A2EA-08002B30309D}" )
IF IsWinNT()
	aadd(	aCombo, "Results of Computers research" )
	aadd(	aCLSIDs, "{1F4DE370-D627-11D1-BA4F-00A0C91EEDBA}" )
	aadd(	aCombo, "Results of files research" )
	aadd(	aCLSIDs,"{E17D4FC0-5564-11D1-83F2-00A0C90DC849}" )
ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 338 ;
		HEIGHT 153 - IF(IsXPThemeActive(), 0, 6) ;
		TITLE PROGRAM + VERSION ;
		ICON "MAIN" ;
		MAIN ;
		NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON PAINT ONPaint() ;
		FONT 'MS Sans Serif' SIZE 9

		@ 90,223 BUTTON Button_1 ;
			CAPTION 'Quit' ;
			ACTION ThisWindow.Release ;
			WIDTH 98 ;
			HEIGHT 23 DEFAULT

		@ 12,12 BUTTON Button_2 ;
			CAPTION 'GO TO --->' ;
			ACTION ExploreWinObjects( aCLSIDs[Form_1.Combo_1.value], Form_1.Check_1.Value, Form_1.Check_2.Value ) ;
			WIDTH 98 ;
			HEIGHT 21

		@ 12,118 COMBOBOX Combo_1 ;
			WIDTH 204 ;
			ITEMS aCombo ;
			VALUE 1 ;
			ON ENTER ExploreWinObjects( aCLSIDs[Form_1.Combo_1.Value], Form_1.Check_1.Value, Form_1.Check_2.Value )

		@ 39,12 CHECKBOX Check_1 ;
			CAPTION "Don't show left Explorer pane" ;
			WIDTH 160 ;
			HEIGHT 21 ;
			VALUE .F.

		@ 60,12 CHECKBOX Check_2 ;
			CAPTION "Start Exploring at the object root" ;
			WIDTH 170 ;
			HEIGHT 21 ;
			VALUE .F.

		@ 48,289 LABEL Label_1 ;
			VALUE 'EXP' ;
			WIDTH 32 ;
			HEIGHT 28 ;
			FONT 'Tahoma' SIZE 12 BOLD ;
			FONTCOLOR GRAY TRANSPARENT RIGHTALIGN

		@ 92,12 LABEL Label_2 ;
			VALUE 'Copyright ' + Chr(169) + COPYRIGHT ;
			WIDTH 160 ;
			HEIGHT 21

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Form_1.Label_2.Enabled := .f.

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Static Procedure ExploreWinObjects( cObject, lDoNotShowLeftPane, lStartExplAtRoot )

	ShellExecute( _HMG_MainHandle, "open", GetWindowsFolder() + '\Explorer.exe', ;
		IF(lDoNotShowLeftPane, " /n", " /e") + ", " + IF(lStartExplAtRoot, "/Root,", "") + ;
		"::" + cObject, , 1 )

Return


Static Procedure OnPaint()

	DRAW LINE IN WINDOW Form_1 ;
		AT 85,0 TO 85,332 ;
		PENCOLOR WHITE

	DRAW LINE IN WINDOW Form_1 ;
		AT 84,331 TO 84,333 ;
		PENCOLOR WHITE

	DRAW LINE IN WINDOW Form_1 ;
		AT 84,0 TO 84,331 ;
		PENCOLOR GRAY

Return

/*
#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( C_CENTER ) 
{
	RECT rect;
	int w, h, x, y;
	GetWindowRect((HWND) hb_parnl (1), &rect);
	w  = rect.right  - rect.left;
	h = rect.bottom - rect.top;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );
	x = rect.right - rect.left;
	y = rect.bottom - rect.top;
	SetWindowPos( (HWND) hb_parnl (1), HWND_TOP, (x - w) / 2, (y - h) / 2 + 1, 0, 0, SWP_NOSIZE | SWP_NOACTIVATE ) ;
}

#pragma ENDDUMP
*/