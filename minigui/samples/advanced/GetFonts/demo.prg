/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Procedure Main()

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Main Window' ;
		MAIN ;
		BACKCOLOR BLUE

	DEFINE BUTTON Btn_1
		ROW 290
		COL Form_Main.Width - 344
		CAPTION "Switch To Child"
		ACTION IF( IsWindowDefined(Form_Child), ( DoMethod("Form_Child", "Show"), SwitchToThisWindow( GetFormHandle( "Form_Child" ), 1 ) ), )
		DEFAULT .T.
	END BUTTON

	DEFINE BUTTON Btn_2
		ROW 290
		COL Form_Main.Width - 234
		CAPTION "Cancel"
		ACTION Form_Main.Release()
	END BUTTON

	END WINDOW

	DEFINE WINDOW Form_Child ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Child Window' ;
		ON GOTFOCUS Form_Child.Btn_1.Setfocus ;
		BACKCOLOR GREEN

	DEFINE LABEL Label_1
		ROW 	205
		COL	Form_Main.Width - 294
		VALUE   'Fonts:' 
		WIDTH   48
		HEIGHT  16
		BACKCOLOR GREEN
	END LABEL

	DEFINE COMBOBOX Combo_1
		ROW	200
		COL	Form_Main.Width - 244
		ITEMS   GetFonts()
		VALUE   1
		TOOLTIP 'Fonts'
                WIDTH   170
	END COMBOBOX

	DEFINE BUTTON Btn_1
		ROW 290
		COL Form_Main.Width - 244
		CAPTION "Switch To Main"
		ACTION SwitchToThisWindow( GetFormHandle( "Form_Main" ), 1 )
	END BUTTON

	END WINDOW

	CENTER WINDOW Form_Main
	CENTER WINDOW Form_Child

	ACTIVATE WINDOW ALL

Return


Function GetFonts()
   Local aFontList := {}, aTmpList, a

   aTmpList := GetFontList( , , ANSI_CHARSET )

   FOR EACH a IN aTmpList
      If a[ 4 ] != 0      /* TrueType fonts only */
         Aadd( aFontList, a[ 1 ] )
      EndIf
   NEXT

Return ( aFontList )

*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_VOID SwitchToThisWindow( DLL_TYPE_LONG hWnd, DLL_TYPE_BOOL lRestore ) ;
	IN USER32.DLL
*-----------------------------------------------------------------------------*
