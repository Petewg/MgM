/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 309 HEIGHT IF(IsXPThemeActive(), 168, 162) ;
		TITLE 'Copying Files...' ;
		MAIN ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT InitAnimRes() ;
		ON RELEASE ReleaseAnimRes() ;
		FONT 'MS Sans Serif' SIZE 9

		@ 73, 8 LABEL Label_1 ;
			VALUE 'ANI.EXE' ;
			AUTOSIZE

		@ 90, 8 PROGRESSBAR Progress_1 RANGE 0, 65535 ;
			WIDTH 284 HEIGHT 12

		@ 115, 28 LABEL Label_2 ;
			VALUE 'E-mail me at:' ;
			AUTOSIZE

		@ 115, 94 HYPERLINK Label_3 ;
			VALUE 'gfilatov@inbox.ru' ;
			ADDRESS "gfilatov@inbox.ru?cc=&bcc=" +	;
				"&subject=AVI%20Animation%20Feedback:"	;
			AUTOSIZE					;
			TRANSPARENT HANDCURSOR

		@ 107, 218 BUTTON Btn_Cancel ;
			CAPTION "Cancel" ;
			ACTION Form_1.Release ;
			WIDTH 74 HEIGHT 23

		DEFINE TIMER Timer_1 INTERVAL 2000 ACTION Animate_Progress()

		ON KEY ESCAPE ACTION Form_1.Btn_Cancel.OnClick

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*-----------------------------------------------------------------------------*
Procedure InitAnimRes
*-----------------------------------------------------------------------------*

	@ 0,0 ANIMATERES Anim_1 ;
		OF Form_1 ;
		WIDTH 300 HEIGHT 60 ;
		FILE Application.ExeName ;
		ID 161

	Form_1.Btn_Cancel.SetFocus

	Form_1.Anim_1.Play

	Animate_Progress()

Return

*-----------------------------------------------------------------------------*
Procedure ReleaseAnimRes
*-----------------------------------------------------------------------------*

	Form_1.Anim_1.Release

Return

*-----------------------------------------------------------------------------*
Procedure Animate_Progress
*-----------------------------------------------------------------------------*
Local i

Static lBusy := .F.

	IF .NOT. lBusy

		lBusy := .T.

		For i = 0 To 65535 Step 5
			Form_1.Progress_1.Value := i
			Do Events
		Next i

		lBusy := .F.

	ENDIF

Return
