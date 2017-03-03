/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Revised by P.Ch. 16.12.
 */

#include "minigui.ch"

STATIC Rot := -10, lRot := .F.

FUNCTION Main()

   LOCAL n, s, ab 

	// Try to install font by default
	DEFINE FONT font_0 FONTNAME 'Times New Roman' SIZE 10 DEFAULT

	// Check it with a new function GetFontParambyRef()
	GetFontParamByRef( NIL, @n )

	IF hb_LeftEqI( n, 'Times New Roman' )
		MsgInfo( "Default font was installed!", n )
	ELSE
		MsgInfo( "Default font was not installed correctly!", n )
		QUIT
	ENDIF

	// Go ahead now
	DEFINE FONT font_1 FONTNAME 'Arial' SIZE 24 ITALIC
	DEFINE FONT font_2 FONTNAME 'Verdana' SIZE 10 BOLD ANGLE Rot 
	DEFINE FONT font_3 FONTNAME 'Absurd New' SIZE 14 BOLD

	IF GetFontParamByRef( GetFontHandle( "font_3" ), @n, @s, @ab ) 
 		cMsg := "Good news! '" + n + "' was created!" + CRLF
		cMsg += "with size " + hb_NtoS( s ) + ","  + CRLF
		cMsg += "attribute bold: " + If( ab, "YES.", "NO." )

		MsgInfo( cMsg )
	ELSE
		MsgInfo( "Font was not installed correctly!" )
	ENDIF

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'New definitions of Fonts - by Janusz Pora' ;
		MAIN

		@ 200,250 LABEL Label_1 ;
		WIDTH 150 HEIGHT 150 ;
		VALUE 'Click Me !' ;
		ACTION fRotFont() ;
		BACKCOLOR BLUE CENTERALIGN ;
		FONT "font_1"

		@ 10,10 LABEL Label_2 ;
		WIDTH 350 HEIGHT 150 ;
		VALUE "" ;
		ACTION MsgInfo('Click!');
		BACKCOLOR YELLOW;
		FONT "font_2" CENTERALIGN

		@ 10,400 LABEL Label_3 ;
		WIDTH 150 HEIGHT 24 ;
		VALUE 'Default font' ;

		@ 40,400 LABEL Label_4 ;
		WIDTH 150 HEIGHT 44 ;
		VALUE 'Font 1' ;
		FONT "font_1"

		@ 90,400 LABEL Label_5 ;
		WIDTH 150 HEIGHT 24 ;
		VALUE 'Font 3' ;
		FONT "font_3"

		@ 400,450 BUTTON Btn_1 ;
		CAPTION 'Exit' ;
		ON CLICK thiswindow.release ;
		FONT "font_3"

	END WINDOW

	Form_Main.Label_2.Value := Space(350) + 'This Is An Rotate Label!!!'

	CENTER   WINDOW Form_Main
	ACTIVATE WINDOW Form_Main

RETURN NIL


PROCEDURE fRotFont()

	Form_Main.Label_1.Value := 'Click Me !'

	lRot := ! lRot

	IF lRot
		RotationText( Form_Main.Label_1.Handle )
	ENDIF

	Rot -= 10
	_SetFontRotate ( 'Label_2', 'Form_Main', rot )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetFontRotate ( ControlName, ParentForm, Value )
*-----------------------------------------------------------------------------*
	LOCAL i, h, n, s, ab, ai, au, as , aa , j

	i := GetControlIndex ( ControlName, ParentForm )
	DeleteObject ( _HMG_aControlFontHandle [i] )

	h := _HMG_aControlhandles [i]
	n := _HMG_aControlFontName [i]
	s := _HMG_aControlFontSize [i]
	ab := _HMG_aControlFontAttributes [i] [1]
	ai := _HMG_aControlFontAttributes [i] [2]
	au := _HMG_aControlFontAttributes [i] [3]
	as := _HMG_aControlFontAttributes [i] [4]
	
	DO CASE
	CASE _HMG_aControlType [i] == "SPINNER"
		_HMG_aControlFontHandle [i] := _SetFont ( h [1], n, s, ab, ai, au, as, Value * 10 )

	CASE _HMG_aControlType [i] == "RADIOGROUP"

		FOR j := 1 To Len (h)
			_HMG_aControlFontHandle [i] := _SetFont ( h [j], n, s, ab, ai, au, as, Value * 10 )
		NEXT j

	OTHERWISE
	   _HMG_aControlFontHandle [i] := _SetFont ( h, n, s, ab, ai, au, as, Value * 10 )
	ENDCASE

RETURN


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC ( ROTATIONTEXT )
{
	HWND hwnd = ( HWND ) HB_PARNL( 1 );

	if( IsWindow( hwnd ) )
	{
		LOGFONT lf;
		HFONT   hfnt, hfntPrev;
		HDC  hdc = GetDC( hwnd );
		RECT rc;
		int  angle;
		LPCSTR lpStr = TEXT( "The string to be rotated" );
		int cch = lstrlen( lpStr );

		// Retrieve the client-rectangle dimensions. 
		GetClientRect( hwnd, &rc) ; 
		// Set the background mode to transparent for the text-output operation. 
		SetBkMode( hdc, TRANSPARENT ); 
		// Prepare font
		memset( &lf, 0, sizeof( LOGFONT ) );
		lstrcpy( lf.lfFaceName, "Arial" );
		lf.lfWeight = FW_NORMAL; 
		// Draw the string 36 times, rotating 10 degrees counter-clockwise each time. 
		for( angle = 0; angle < 3600; angle += 100 ) 
		{
			lf.lfEscapement = angle; 
			hfnt = CreateFontIndirect( &lf ); 

			hfntPrev = SelectObject( hdc, hfnt );
			TextOut( hdc, rc.right / 2, rc.bottom / 2, lpStr, cch ); 
			SelectObject( hdc, hfntPrev ); 

			DeleteObject( hfnt ); 
		}
		// Reset the background mode to its default. 
 		SetBkMode( hdc, OPAQUE ); 
		// Release device context
		ReleaseDC( hwnd, hdc );
	}
}

#pragma ENDDUMP
