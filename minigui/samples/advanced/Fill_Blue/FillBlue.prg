/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-03 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH GetDesktopWidth() HEIGHT GetDesktopHeight() ;
		TITLE 'Demo for Gradient Background' ;
		MAIN ;
		ICON 'MAIN' ;
		NOMAXIMIZE NOSIZE ;
		ON PAINT ( FillBlue(_HMG_MainHandle), TextPaint() )

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure TextPaint()

      DRAW TEXT IN WINDOW Form_1 AT 10, 14 ;
		VALUE "Program Setup" ;
		FONT "Verdana" SIZE 24 BOLD ITALIC ;
		FONTCOLOR WHITE TRANSPARENT

      DRAW TEXT IN WINDOW Form_1 AT Form_1.Height - 54, Form_1.Width - 230 ;
		VALUE "Copyright (c) 2003 by Grigory Filatov" ;
		FONT "Tahoma" SIZE 10 ITALIC ;
		FONTCOLOR WHITE TRANSPARENT

Return


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( FILLBLUE )
{   
    HWND   hwnd;
    HBRUSH brush;
    RECT   rect;
    HDC    hdc;
    int    cx;
    int    cy;
    int    blue = 200;
    int    steps;
    int    i;

    hwnd = (HWND) hb_parnl (1);
    hdc  = GetDC(hwnd);

    GetClientRect(hwnd, &rect);

    cx = rect.top;
    cy = rect.bottom;
    steps = (cy - cx) / 5 + 1;
    rect.bottom = 0;

    for( i = 0 ; i < steps ; i++ )
    {
        rect.bottom += 5;
        brush = CreateSolidBrush( RGB(0, 0, blue) );
        FillRect(hdc, &rect, brush);
        DeleteObject(brush);
        rect.top += 5;
        blue -= 1;
    }

    ReleaseDC(hwnd, hdc);
}

#pragma ENDDUMP
