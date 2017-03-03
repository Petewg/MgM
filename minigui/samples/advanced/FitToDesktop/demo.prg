/*
* MiniGUI FitToDesktop Demo
*(c) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
* HMG 1.0 Experimantal Build 8
*
* This demo shows how to get width and height of the client area for a full-screen window 
* on the primary display monitor, in pixels and get the coordinates of the portion of the screen 
* not obscured by the system taskbar or by application desktop toolbars
*
* MINIGUI - Harbour Win32 GUI library 
* Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"


Procedure Main

	DEFINE WINDOW Form_1 ;
		AT GetDesktopRealTop(),GetDesktopRealLeft() ;
		WIDTH GetDesktopRealWidth() ;
		HEIGHT GetDesktopRealHeight() ;
		TITLE 'MiniGUI FitToDesktop Demo' ;
		MAIN 

		DEFINE MAIN MENU
                  DEFINE POPUP "&Test"
                    MENUITEM "Fit it now !"	ACTION FitIt()
                    SEPARATOR	
                    MENUITEM 'Exit'		ACTION Form_1.Release
	          END POPUP
		END MENU

	END WINDOW
	
	ACTIVATE WINDOW Form_1

Return


Procedure FitIt()

Form_1.Row := GetDesktopRealTop()
Form_1.Col := GetDesktopRealLeft()
Form_1.Width := GetDesktopRealWidth()
Form_1.Height := GetDesktopRealHeight()

Return


#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT 0x0400
#include <windows.h>
#include "hbapi.h"

HB_FUNC (GETDESKTOPREALTOP) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.top);

}
HB_FUNC (GETDESKTOPREALLEFT) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.left);

}

HB_FUNC (GETDESKTOPREALWIDTH) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.right - rect.left);

}

HB_FUNC (GETDESKTOPREALHEIGHT) 
{
	RECT rect;
	SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

	hb_retni(rect.bottom - rect.top);
}

#pragma ENDDUMP
