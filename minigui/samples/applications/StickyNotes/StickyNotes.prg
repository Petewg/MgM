/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2012 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Sticky Notes'
#define VERSION ' version 1.5'
#define COPYRIGHT ' Grigory Filatov, 2003-2012'

#define NTRIM( n ) LTrim( Str( n ) )

MEMVAR cTopLabel
 
Procedure Main( ... )

Local nParams := PCOUNT(), cText := "", aParams, i, aText := {}, cLbl, ;
		nLang := nHex( SubStr( I2Hex( GetUserLangID() ), 3 ) )

	IF nLang == 25
		SET LANGUAGE TO RUSSIAN
	ELSEIF nLang == 10
		SET LANGUAGE TO SPANISH
	ELSEIF nLang == 9
		SET LANGUAGE TO ENGLISH
	ENDIF

	SET DATE GERMAN

	PUBLIC cTopLabel := IF( nParams > 0, DTOC(Date()) + " " + TIME(), "" )

	IF nParams == 0
		cText := padl(PROGRAM + VERSION, 32) + CRLF + CRLF
		for i:=1 to 4
			clbl := LoadResString( IF(nLang # 25, 10000, 20000) + i )
			if !Empty(clbl)
				clbl := IF( i = 4, padl(clbl, 32), clbl )
				cText += clbl + IF( i < 3, CRLF + CRLF, IF( i < 4, CRLF, "" ) )
			endif
		next
	ELSE
		aParams := HB_aParams()

		For i:=1 To Len(aParams)
			cText += IF(valtype(aParams[i])=="C", aParams[i] + " ", "")
		Next
		cText += CRLF
	ENDIF

	For i:=1 To MLCount(cText, IF(nLang = 25, 33, 40))
		Aadd( aText, MemoLine(cText, IF(nLang = 25, 33, 40), i) )
	Next

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		ICON "MAIN"

	END WINDOW

	DEFINE WINDOW Form_1 ;
		AT 0, 0 ;
		WIDTH 200 HEIGHT 20 + 14 * Len(aText) + 20 ;
		CHILD ;
		TOPMOST NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ( SET REGION OF Form_1 POLYGONAL ;
			{{0, 6}, {6, 0}, {200, 0}, {200, Form_1.Height}, {0, Form_1.Height}} ) ;
		ON GOTFOCUS OnPaint(aText) ;
		ON MOUSECLICK InterActiveMoveHandle( GetFormHandle("Form_1") ) ;
		ON MOUSEMOVE RC_CURSOR("HAND") ;
		BACKCOLOR {255, 255, 200}

		@ 0, 0 IMAGE Image_1 PICTURE "TOP" ;
			WIDTH 200 HEIGHT 14 ;
			ACTION InterActiveMoveHandle( GetFormHandle("Form_1") )

		@ 2, 8 LABEL Label_TopCenter VALUE cTopLabel ;
			WIDTH 190 HEIGHT 14 ;
			ACTION InterActiveMoveHandle( GetFormHandle("Form_1") ) ;
			BACKCOLOR {255, 255, 200} CENTERALIGN

		For i:=1 To Len(aText)
			cLbl := "Label_" + NTRIM(i)
			@ 20 + 14 * (i - 1), 4 LABEL &cLbl VALUE aText[i] ;
				WIDTH 190 HEIGHT 14 ;
				ACTION InterActiveMoveHandle( GetFormHandle("Form_1") ) ;
				BACKCOLOR {255, 255, 200} ;
				FONT 'MS Sans Serif' SIZE 8
		Next

		@ Form_1.Height - 16, 2 LABEL Label_BottomLeft VALUE "" ;
			WIDTH 92 HEIGHT 14 ;
			ACTION OnHide(aText) ;
			BACKCOLOR {255, 255, 200}

		@ Form_1.Height - 16, 107 LABEL Label_BottomRight VALUE "" ;
			WIDTH 92 HEIGHT 14 ;
			ACTION OnHide(aText) ;
			BACKCOLOR {255, 255, 200}

		@ Form_1.Height - 16, 94 IMAGE Image_2 PICTURE "CLOSE" ;
			WIDTH 13 HEIGHT 13 ;
			ACTION ( OnExit(), ReleaseAllWindows() )

		DEFINE CONTEXT MENU
			ITEM 'Hide' ACTION OnHide(aText) IMAGE "HIDE"
			ITEM 'Info' ACTION ShellAbout( "", PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) ) IMAGE "INFO"
			ITEM 'Exit' ACTION ( OnExit(), ReleaseAllWindows() ) IMAGE "EXIT"
		END MENU

	END WINDOW

	SetHandCursor( GetControlHandle("Image_2", "Form_1"), "FINGER" )

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1, Form_0

Return


Procedure OnHide( aText )
Local nRow, nCol

	DEFINE WINDOW Form_2 ;
		AT Form_1.Row, Form_1.Col ;
		WIDTH 200 HEIGHT 37 ;
		CHILD ;
		TOPMOST NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ( SET REGION OF Form_2 POLYGONAL ;
			{{0, 6}, {6, 0}, {200, 0}, {200, Form_2.Height-5}, ;
			{195, Form_2.Height}, {5, Form_2.Height}, {0, 32}}, Form_1.Hide ) ;
		ON RELEASE ( Form_1.Row := nRow, Form_1.Col := nCol, Form_1.Show ) ;
		ON GOTFOCUS OnPaint(aText, .F.) ;
		ON MOUSECLICK InterActiveMoveHandle( GetFormHandle("Form_2") ) ;
		ON MOUSEMOVE RC_CURSOR("HAND") ;
		BACKCOLOR {255, 255, 200}

		@ 0, 0 IMAGE Image_1 PICTURE "TOP" ;
			WIDTH 200 HEIGHT 14 ;
			ACTION InterActiveMoveHandle(GetFormHandle("Form_2"))

		@ 2, 8 LABEL Label_TopCenter VALUE cTopLabel ;
			WIDTH 190 HEIGHT 14 ;
			ACTION InterActiveMoveHandle( GetFormHandle("Form_2") ) ;
			BACKCOLOR {255, 255, 200} CENTERALIGN

		@ Form_2.Height - 17, 0 IMAGE Image_2 PICTURE "BOTTOM" ;
			WIDTH 200 HEIGHT 17 ;
			ACTION ( nRow := Form_2.Row, nCol := Form_2.Col, Form_2.Release )

	END WINDOW

	DRAW RECTANGLE IN WINDOW Form_2 ;
		AT 0,0 TO Form_2.Height,200 ;
		PENCOLOR {16, 8, 0} ;
		FILLCOLOR {255, 255, 200}

	ACTIVATE WINDOW Form_2

Return


Procedure OnPaint( aText, lText )
Local i

	DEFAULT lText := .T.

	IF lText

		DRAW RECTANGLE IN WINDOW Form_1 ;
			AT 0,0 TO Form_1.Height,200 ;
			PENCOLOR {16, 8, 0} ;
			FILLCOLOR {255, 255, 200}

		Form_1.Image_1.Picture := "TOP"

		DO EVENTS

		SetProperty( "Form_1", "Label_TopCenter", "Value", cTopLabel )

		For i:=1 To Len(aText)
			SetProperty( "Form_1", "Label_" + NTRIM(i), "Value", aText[i] )
		Next

		Form_1.Image_2.Picture := "CLOSE"

	ELSE

		Form_2.Image_1.Picture := "TOP"

		DO EVENTS

		SetProperty( "Form_2", "Label_TopCenter", "Value", cTopLabel )

		Form_2.Image_2.Picture := "BOTTOM"

	ENDIF

Return


Procedure OnExit()
Local nHeight := GetDesktopHeight(), nFormRow := Form_1.Row

	DO WHILE nFormRow < nHeight .And. INKEYGUI() == 0
		Form_1.Row := ( nFormRow += 4 )
	ENDDO

Return


Static function drawrect( window,row,col,row1,col1,penrgb,penwidth,fillrgb )
Local i := GetFormIndex ( Window )
Local FormHandle := _HMG_aFormHandles [i] , fill

	if formhandle > 0

		if valtype(penrgb) == "U"
			penrgb = {0,0,0}
		endif

		if valtype(penwidth) == "U"
			penwidth = 1
		endif

		if valtype(fillrgb) == "U"
			fillrgb := {255,255,255}
			fill := .f.
		else
			fill := .t.
		endif

		rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill )

		aadd( _HMG_aFormGraphTasks [i] , { || rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill) } )

	endif

return nil


Static function nHex( cHex )
local n, nChar, nResult := 0
local nLen := Len( cHex )

	For n = 1 To nLen
		nChar = Asc( Upper( SubStr( cHex, n, 1 ) ) )
		nResult += ( ( nChar - If( nChar <= 57, 48, 55 ) ) * ( 16 ^ ( nLen - n ) ) )
	Next

return nResult


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC( GETUSERLANGID )
{
   hb_retni( GetUserDefaultLangID() ) ;
}

static char * u2Hex( WORD wWord )
{
    static far char szHex[ 5 ];

    WORD i= 3;

    do
    {
        szHex[ i ] = 48 + ( wWord & 0x000F );

        if( szHex[ i ] > 57 )
            szHex[ i ] += 7;

        wWord >>= 4;

    }
    while( i-- > 0 );

    szHex[ 4 ] = 0;

    return szHex;
}

HB_FUNC( I2HEX )
{
   hb_retc( u2Hex( hb_parni( 1 ) ) );
}

HB_FUNC( LOADRESSTRING )
{
	HGLOBAL cBuffer;
	cBuffer = ( char * ) GlobalAlloc( GPTR, 255 );

	LoadString( GetModuleHandle(NULL), hb_parni(1), (LPSTR) cBuffer, 254 );

	hb_retc( cBuffer );
	GlobalFree( cBuffer );
}

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{
	keybd_event(
		VK_RIGHT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
	keybd_event(
		VK_LEFT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	SendMessage( (HWND) hb_parnl(1), WM_SYSCOMMAND, SC_MOVE, 10 );
}

#pragma ENDDUMP
