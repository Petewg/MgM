/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2012 Rossine <qiinfo@ig.com.br>
*/

#include "minigui.ch"

#define SRCCOPY		0x00CC0020

static hWnd
static nZoom := 3 // Zoom default

**************
Procedure Main
**************

Define Window Form_1 ;
	At 0, 0 ;
	Width 600 ;
	Height 400 ;
	Title 'Zoom' ;
	Main ;
	Nosize ;
   On Init hWnd := This.Handle

	DEFINE LABEL Label_1
		ROW 5
		COL 5
		WIDTH 120
		HEIGHT 40
		VALUE ""
		CLIENTEDGE .T.
	END LABEL

	DEFINE LABEL Label_2
		ROW 50
		COL 5
		WIDTH 120
		HEIGHT 30
		VALUE ""
		FONTNAME "Courier New"
		FONTSIZE 12
		FONTBOLD .T.
		FONTCOLOR {255,255,255}
		BACKCOLOR {000,105,000}
		CENTERALIGN .T.
		CLIENTEDGE .T.
	END LABEL

	Define Main Menu
		Popup 'Zoom'
			Item 'Factor 1' name Factor1 Action check_menu( 1 )
			Item 'Factor 2' name Factor2 Action check_menu( 2 )
			Item 'Factor 3' name Factor3 Action check_menu( 3 ) Checked
			Item 'Factor 4' name Factor4 Action check_menu( 4 )
			Item 'Factor 5' name Factor5 Action check_menu( 5 )
			Separator
			Item 'Exit' Action Form_1.Release

		End Popup
	End Menu

	On Key Escape Action thiswindow.Release

	Define Timer oTimer Interval 40 Action ZoomImage()

End Window

Center window Form_1

Activate window Form_1

Return

**************************
static function check_menu( nFactor )
**************************

local n

	nZoom := nFactor

	for n := 1 to 5
		SetProperty( "Form_1", "Factor" + str(n, 1), "Checked", ( n == nFactor ) )
	next

return NIL

*************************
static function ZoomImage
*************************

local hDeskTop
local aPos
local hDC
local hPen
local hOldPen, aColor
local nTop, nLeft, nWidth, nHeight

	hDeskTop := GetDC(0)
	aPos := GetCursorPos()

	aColor := nRGB2Arr( GetPixel( hDeskTop, aPos[2], aPos[1] ) )
	Form_1.Label_1.Backcolor := aColor
	Form_1.Label_2.Value := StrZero( aColor[1], 3 ) + "," + StrZero( aColor[2], 3 ) + "," + StrZero( aColor[3], 3 )

	nTop := 10
	nLeft := 130
	nWidth := 400
	nHeight := 300

	hDC := GetDC( hWnd )
	hPen := CreatePen( 0, 1, 255 )

	Moveto( hDC, nLeft-1, nTop-1 )
	Lineto( hDC, nLeft + nWidth, nTop-1 )
	Lineto( hDC, nLeft + nWidth, nTop+nHeight )
	Lineto( hDC, nLeft -1, nTop+nHeight )
	Lineto( hDC, nLeft-1, nTop-1 )

	StretchBlt( hDC, nLeft, nTop, nWidth, nHeight, hDeskTop, aPos[2]-nWidth/(nZoom*2), aPos[1]-nHeight/(2*nZoom), nWidth/nZoom, nHeight/nZoom, SRCCOPY )

	hOldPen := SelectObject( hDC, hPen )

	Moveto( hDC, nLeft+nWidth/2+1, nTop-1 )
	Lineto( hDC, nLeft+nWidth/2+1, nTop+nHeight+1 )

	Moveto( hDC, nLeft+1, nTop+nHeight/2+1 )
	Lineto( hDC, nLeft+nWidth+1, nTop+nHeight/2+1 )

	SelectObject( hDC, hOldPen )
	DeleteObject( hPen )

	ReleaseDC( hWnd, hDC )

	ReleaseDC( 0, hDeskTop )

return nil


#pragma BEGINDUMP

#include "windows.h"
#include "hbapi.h"

HB_FUNC( STRETCHBLT )
{
   hb_retl( StretchBlt( (HDC) hb_parnl( 1 ) ,
			hb_parni( 2 ) ,
			hb_parni( 3 ) ,
			hb_parni( 4 ) ,
			hb_parni( 5 ) ,
			(HDC) hb_parnl( 6 ) ,
			hb_parni( 7 ) ,
			hb_parni( 8 ) ,
			hb_parni( 9 ) ,
			hb_parni( 10 ) ,
			(DWORD) hb_parnl( 11 )
			) );
}

HB_FUNC( GETPIXEL )
{
   hb_retnl( GetPixel( ( HDC ) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

#pragma ENDDUMP
