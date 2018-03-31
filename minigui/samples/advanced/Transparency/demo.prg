/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "hmg.ch"

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Transparency Sample' ;
		MAIN

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			CAPTION 'Set Transparency ON'
			WIDTH	140
			ACTION	Form_1.Slider_1.Value := 70
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	140
			CAPTION 'Set Transparency OFF'
			ACTION ( Form_1.Slider_1.Value := 100, ;
				RemoveTransparency( Application.Handle ) )
		END BUTTON

		DEFINE SLIDER Slider_1
			ROW	80
			COL	10
			VALUE	100
			WIDTH	310
			HEIGHT	50
			RANGEMIN 0
			RANGEMAX 100
			ON SCROLL Slider_Change()
			ON CHANGE Slider_Change()
		END SLIDER

		DEFINE TEXTBOX TextBox_1
			ROW	85
			COL	330
			VALUE	"100 %"
			WIDTH	50
			MAXLENGTH 5
		END TEXTBOX

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

Function Slider_Change
	Local nValue := Form_1.Slider_1.Value

	Form_1.TextBox_1.Value := Str(nValue, 3) + " %"

	If nValue < 100
		If .not. SetLayeredWindowAttributes( Application.Handle, 0, (255 * nValue) / 100, LWA_ALPHA )
			MsgStop( "This Sample Runs In Win2000/XP Or Later Only!", "Error" )
                Else
			SET WINDOW Form_1 TRANSPARENT TO (255 * nValue) / 100
		EndIf
        Else
		SET WINDOW Form_1 TO OPAQUE
	EndIf

Return Nil

#define GWL_EXSTYLE	(-20)
#define WS_EX_LAYERED   524288

PROCEDURE RemoveTransparency( hWnd )

	SetWindowLong( hWnd, GWL_EXSTYLE, hb_BitAnd( GetWindowLong( hWnd, GWL_EXSTYLE ), hb_BitNot( WS_EX_LAYERED ) ) )

	RedrawWindow( hWnd )

RETURN

/*
   The SetLayeredWindowAttributes function sets the opacity and transparency color key of a layered window.
   Parameters:
   - hwnd	Handle to the layered window.
   - crKey	Pointer to a COLORREF value that specifies the transparency color key to be used.
		(When making a certain color transparent...).
   - bAlpha	Alpha value used to describe the opacity of the layered window.
		0 = Invisible, 255 = Fully visible
   - dwFlags	Specifies an action to take. This parameter can be LWA_COLORKEY
		(When making a certain color transparent...) or LWA_ALPHA.

DECLARE DLL_TYPE_BOOL SetLayeredWindowAttributes( ;
	DLL_TYPE_LONG hWnd, DLL_TYPE_INT crKey, DLL_TYPE_UINT bAlpha, DLL_TYPE_DWORD dwFlags ) ;
	IN USER32.DLL
*/