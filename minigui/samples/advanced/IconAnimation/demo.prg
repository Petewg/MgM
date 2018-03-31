/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2006 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "resource.h"

#define NUM_ICON_FOR_ANIMATION	8

Static lFlag := .f., nCounter := 1
Static aIconResource := { IDI_ICON8, IDI_ICON7, IDI_ICON6, IDI_ICON5, IDI_ICON4, IDI_ICON3, IDI_ICON2, IDI_ICON1 }

*-------------------------------------------------------------
Function Main
*-------------------------------------------------------------

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 432 ;
		TITLE 'Icon Animation Demo' ;
		ICON aIconResource[nCounter] ;
		MAIN ;
		ON INIT ( _ExtDisableControl( 'Edit_1', 'Form_1' ), ResizeEdit() ) ;
		ON PAINT PaintChildWindow( GetControlHandle( 'Edit_1', 'Form_1' ), "Animation of Tray Icon, TaskBar Icon and TitleBar Icon" ) ;
		ON SIZE ResizeEdit() ;
		ON MAXIMIZE ResizeEdit() ;
		NOTIFYICON aIconResource[nCounter] ;
		NOTIFYTOOLTIP 'Animated System Tray Icons' ;
		ON NOTIFYCLICK ProcessNotifyClick()

		DEFINE MAIN MENU
			POPUP "Tray Icon"
				MENUITEM "Hide Window"	ACTION ( lFlag := .t., Form_1.Hide )
				MENUITEM "Minimize Window"	ACTION Form_1.Minimize
				MENUITEM "Maximize Window"	ACTION Form_1.Maximize
				SEPARATOR	
				ITEM 'Exit Application'	ACTION Form_1.Release
			END POPUP
		END MENU

		DEFINE NOTIFY MENU
			MENUITEM "Hide Window"	ACTION ( lFlag := .t., Form_1.Hide )
			MENUITEM "Minimize Window"	ACTION ( lFlag := .f., Form_1.Minimize, Form_1.Show )
			MENUITEM "Maximize Window"	ACTION ( lFlag := .f., Form_1.Maximize, Form_1.Show )
			SEPARATOR	
			ITEM 'Exit Application'	ACTION Form_1.Release
		END MENU

		@ 0,0 EDITBOX Edit_1 ;
			WIDTH 0 ;
			HEIGHT 0 ;
	   		VALUE '' ;
			FONT 'Arial' SIZE 11 BOLD ;
			BACKCOLOR WHITE ;
			NOHSCROLL NOVSCROLL

		DEFINE TIMER Timer_1 ;
			INTERVAL 500 ;
			ACTION AnimationIcons()

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*-------------------------------------------------------------
Procedure ResizeEdit
*-------------------------------------------------------------

	Form_1.Edit_1.Width := Form_1.Width - 2 * GetBorderWidth()
	Form_1.Edit_1.Height := Form_1.Height - GetTitleHeight() - 2 * GetBorderHeight() - GetMenuBarHeight()

Return

*-------------------------------------------------------------
Procedure ProcessNotifyClick()
*-------------------------------------------------------------

	If lflag == .f.
		Form_1.Hide
	Else
		Form_1.Restore
	EndIf

	lflag := .NOT. lflag

Return

*-------------------------------------------------------------
Procedure AnimationIcons
*-------------------------------------------------------------

	nCounter++
	nCounter := iif(nCounter > NUM_ICON_FOR_ANIMATION, 1, nCounter)

	Form_1.NotifyIcon := aIconResource[nCounter]
	AnimationTitleIcon( App.Handle, aIconResource[nCounter] )

Return


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( ANIMATIONTITLEICON )
{
	HWND hWnd = (HWND) hb_parnl(1);
	HICON hIconAtIndex = LoadIcon(GetModuleHandle(NULL), (LPCTSTR) MAKEINTRESOURCE(hb_parni(2)));

	SendMessage(hWnd, WM_SETICON, NULL, (LONG) hIconAtIndex);

	if(hIconAtIndex)
		DestroyIcon(hIconAtIndex);
}

HB_FUNC( PAINTCHILDWINDOW )
{
	HWND hwnd  = (HWND) hb_parnl(1);
	RECT r;
	PAINTSTRUCT ps;
	HDC hDC = BeginPaint(hwnd, &ps);

	GetClientRect(hwnd, &r);

	hb_retni( DrawText(hDC, (LPCTSTR) hb_parc(2), -1, &r, DT_CENTER | DT_VCENTER | DT_SINGLELINE) );

	EndPaint(hwnd, &ps);
}

#pragma ENDDUMP
