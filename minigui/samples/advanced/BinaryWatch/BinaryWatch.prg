/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Binary Watch'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

Static cCurSec := 0, lSound := .F., lClock := .T., aClockClr := BLACK, nColor := 8

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 264 HEIGHT 327 + IF(IsThemed(), 6, 0) ;
		TITLE PROGRAM ;
		ICON 'WATCH' ;
		MAIN NOMAXIMIZE NOMINIMIZE NOSIZE ;
		ON INIT ( cCurSec := Right(Time(), 2), DisplayWatch() ) ;
		FONT "MS Sans serif" SIZE 8

		//Hour
		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48,8			;
		TO 48+32,38

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+41,8			;
		TO 48+41+32,38

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+2*41,8			;
		TO 48+2*41+32,38

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+3*41,8			;
		TO 48+3*41+32,38

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+4*41,8			;
		TO 48+4*41+32,38

		//Minute
		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 7,62			;
		TO 7+32,92

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48,62			;
		TO 48+32,92

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+41,62			;
		TO 48+41+32,92

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+2*41,62			;
		TO 48+2*41+32,92

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+3*41,62			;
		TO 48+3*41+32,92

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+4*41,62			;
		TO 48+4*41+32,92

		//Second
		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 7,118			;
		TO 7+32,148

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48,118			;
		TO 48+32,148

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+41,118			;
		TO 48+41+32,148

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+2*41,118		;
		TO 48+2*41+32,148

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+3*41,118		;
		TO 48+3*41+32,148

		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+4*41,118		;
		TO 48+4*41+32,148

		@7,186 BUTTON Btn_1 CAPTION "OK" WIDTH 68 HEIGHT 23 ACTION Form_1.Release() DEFAULT

		@48+4*41+52,176 BUTTON Btn_2 CAPTION "Options" WIDTH 72 HEIGHT 23 ACTION Options()

		@ 18,156 LABEL Label_1 VALUE "32" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		@ 18+41,156 LABEL Label_2 VALUE "16" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		@ 18+2*41,156 LABEL Label_3 VALUE "8" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		@ 18+3*41,156 LABEL Label_4 VALUE "4" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		@ 18+4*41,156 LABEL Label_5 VALUE "2" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		@ 18+5*41,156 LABEL Label_6 VALUE "1" WIDTH 20 HEIGHT 28 FONT "MS Sans serif" SIZE 9 RIGHTALIGN TRANSPARENT 

		//Show Time
		DRAW BOX			;
		IN WINDOW Form_1		;
		AT 48+4*41+47,8		;
		TO 48+4*41+47+32,164

		@ 48+4*41+48,10 LABEL Label_7 VALUE "" WIDTH 152 HEIGHT 28 FONT "Courier New" SIZE 24 BOLD CENTERALIGN TRANSPARENT 

		DEFINE TIMER Timer_1 ;
			INTERVAL 250 ;
			ACTION OnTimer()

		ON KEY ESCAPE ACTION Form_1.Btn_1.OnClick

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure OnTimer()
*--------------------------------------------------------*
Local cSecond := Right(Time(), 2)

	IF cCurSec != cSecond
		DoEvents()
		DisplayWatch()
	ENDIF

	cCurSec := cSecond

Return

*--------------------------------------------------------*
Static Procedure DisplayWatch()
*--------------------------------------------------------*
Local i, aColor := { 236, 233, 216 }
Local nSecond, nMinute, nHour
Local aBkColor := aClockClr, cTime := Time()

	aClockClr := aColor
	for i := 1 to 6
		DisplayHour(i)
		DisplayMinute(i)
		DisplaySecond(i)
	next
	aClockClr := aBkColor

	IF lSound
		PLAY WAVE 'SOUNDTICK' FROM RESOURCE
	ENDIF

	Form_1.Label_7.Value := IF(lClock, cTime, "")

	// Get the current time
	nSecond := Val(Right(cTime, 2))
	nMinute := Val(Substr(cTime, 4, 2))
	nHour   := Val(Left(cTime, 2))

	// Convert decimal to binary
	IF (nHour >= 16)
		DisplayHour(5)
		nHour -= 16
	ENDIF
	IF (nHour >= 8)
		DisplayHour(4)
		nHour -= 8
	ENDIF
	IF (nHour >= 4)
		DisplayHour(3)
		nHour -= 4
	ENDIF
	IF (nHour >= 2)
		DisplayHour(2)
		nHour -= 2
	ENDIF
	IF (nHour >= 1)
		DisplayHour(1)
		nHour -= 1
	ENDIF
	IF (nMinute >= 32)
		DisplayMinute(6)
		nMinute -= 32
	ENDIF
	IF (nMinute >= 16)
		DisplayMinute(5)
		nMinute -= 16
	ENDIF
	IF (nMinute >= 8)
		DisplayMinute(4)
		nMinute -= 8
	ENDIF
	IF (nMinute >= 4)
		DisplayMinute(3)
		nMinute -= 4
	ENDIF
	IF (nMinute >= 2)
		DisplayMinute(2)
		nMinute -= 2
	ENDIF
	IF (nMinute >= 1)
		DisplayMinute(1)
		nMinute -= 1
	ENDIF
	IF (nSecond >= 32)
		DisplaySecond(6)
		nSecond -= 32
	ENDIF
	IF (nSecond >= 16)
		DisplaySecond(5)
		nSecond -= 16
	ENDIF
	IF (nSecond >= 8)
		DisplaySecond(4)
		nSecond -= 8
	ENDIF
	IF (nSecond >= 4)
		DisplaySecond(3)
		nSecond -= 4
	ENDIF
	IF (nSecond >= 2)
		DisplaySecond(2)
		nSecond -= 2
	ENDIF
	IF (nSecond >= 1)
		DisplaySecond(1)
		nSecond -= 1
	ENDIF

Return

*--------------------------------------------------------*
Static Procedure DisplayHour( nBit )
*--------------------------------------------------------*

	do case
	case nBit == 1

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+4*41+1,9		;
		TO 48+4*41+32,38		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 2

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+3*41+1,9		;
		TO 48+3*41+32,38		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 3

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+2*41+1,9		;
		TO 48+2*41+32,38		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 4

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+42,9			;
		TO 48+41+32,38		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 5

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 49,9			;
		TO 48+32,38			;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	endcase

Return

*--------------------------------------------------------*
Static Procedure DisplayMinute( nBit )
*--------------------------------------------------------*

	do case
	case nBit == 1

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+4*41+1,63		;
		TO 48+4*41+32,92		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 2

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+3*41+1,63		;
		TO 48+3*41+32,92		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 3

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+2*41+1,63		;
		TO 48+2*41+32,92		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 4

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+42,63			;
		TO 48+41+32,92		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 5

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 49,63			;
		TO 48+32,92			;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 6

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 8,63			;
		TO 7+32,92			;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	endcase

Return

*--------------------------------------------------------*
Static Procedure DisplaySecond( nBit )
*--------------------------------------------------------*

	do case
	case nBit == 1

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+4*41+1,119		;
		TO 48+4*41+32,148		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 2

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+3*41+1,119		;
		TO 48+3*41+32,148		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 3

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+2*41+1,119		;
		TO 48+2*41+32,148		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 4

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 48+42,119		;
		TO 48+41+32,148		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 5

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 49,119			;
		TO 48+32,148		;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	case nBit == 6

		DRAW RECTANGLE		;
		IN WINDOW Form_1		;
		AT 8,119			;
		TO 7+32,148			;
		PENCOLOR aClockClr	;
		FILLCOLOR aClockClr

	endcase

Return

*--------------------------------------------------------*
Static Procedure Options()
*--------------------------------------------------------*
Local lBkSound := lSound, lBkClock := lClock, aBkClockClr := aClockClr, nBkColor := nColor

DEFINE WINDOW Form_2 AT 0, 0 WIDTH 204 HEIGHT 268 ;
	TITLE "Options" ICON "WATCH" MODAL ;
	ON INIT ( Form_1.Timer_1.Enabled := .F. ) ;
	ON RELEASE ( Form_1.Timer_1.Enabled := .T. ) ;
	FONT "MS Sans serif" SIZE 8

    DEFINE BUTTON Button_1
        ROW    10
        COL    110
        WIDTH  74
        HEIGHT 23
        CAPTION "OK"
        ACTION ThisWindow.Release
        TABSTOP .T.
    END BUTTON

    DEFINE BUTTON Button_2
        ROW    40
        COL    110
        WIDTH  74
        HEIGHT 23
        CAPTION "Cancel"
        ACTION ( lSound := lBkSound, lClock := lBkClock, aClockClr := aBkClockClr, nColor := nBkColor, ThisWindow.Release )
        TABSTOP .T.
    END BUTTON

    DEFINE BUTTON Button_3
        ROW    70
        COL    110
        WIDTH  74
        HEIGHT 23
        CAPTION "About"
        ACTION MsgAbout()
        TABSTOP .T.
    END BUTTON

    DEFINE FRAME Frame_1
        ROW    5
        COL    10
        WIDTH  90
        HEIGHT 225
        CAPTION "Colors"
        OPAQUE .T.
    END FRAME

    DEFINE FRAME Frame_2
        ROW    150
        COL    110
        WIDTH  74
        HEIGHT 80
        CAPTION "Enable"
        OPAQUE .T.
    END FRAME

    DEFINE RADIOGROUP RadioGroup_1
        ROW    20
        COL    20
        WIDTH  60
        HEIGHT 200
        OPTIONS { 'Red', 'Green', 'Blue', 'White', 'Orange', 'Yellow', 'Cyan', 'Black' }
        VALUE nColor
        ONCHANGE SetClockColor( Form_2.RadioGroup_1.Value )
        TABSTOP .T.
        SPACING 25
    END RADIOGROUP

    DEFINE CHECKBOX Check_1
        ROW    170
        COL    120
        WIDTH  60
        HEIGHT 20
        CAPTION "Clock"
        VALUE lClock
        ONCHANGE lClock := Form_2.Check_1.Value
        TABSTOP .T.
    END CHECKBOX

    DEFINE CHECKBOX Check_2
        ROW    200
        COL    120
        WIDTH  60
        HEIGHT 20
        CAPTION "Sound"
        VALUE lSound
        ONCHANGE lSound := Form_2.Check_2.Value
        TABSTOP .T.
    END CHECKBOX

END WINDOW

CENTER WINDOW Form_2

ACTIVATE WINDOW Form_2

Return

*--------------------------------------------------------*
Static Procedure SetClockColor( nClr )
*--------------------------------------------------------*

	do case

	case nClr == 1
		aClockClr := RED

	case nClr == 2
		aClockClr := GREEN

	case nClr == 3
		aClockClr := BLUE

	case nClr == 4
		aClockClr := WHITE

	case nClr == 5
		aClockClr := {255, 165, 0}

	case nClr == 6
		aClockClr := YELLOW

	case nClr == 7
		aClockClr := {0, 255, 255}

	otherwise
		aClockClr := BLACK

	endcase

	nColor := nClr

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

Return MsgInfo( padc(PROGRAM + VERSION, 38) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 36) + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	SubStr(MiniGuiVersion(), 1, 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About..." )


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
