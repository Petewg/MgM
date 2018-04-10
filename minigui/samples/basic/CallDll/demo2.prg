/*
* MiniGUI DLL Demo
*/

#include "minigui.ch"
#include "hbdyn.ch"

Procedure Main

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON RELEASE UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Set new title' ACTION HMG_CallDLL ( "USER32.DLL" , , "SetWindowText" , GetFormHandle ('Win_1') , "New title"  )
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Win_1

Return
