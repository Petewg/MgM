/*
*
* MiniGUI DLL Demo
*
*/

#include "minigui.ch"

Procedure Main

	Local Buffer := Space (128)

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON RELEASE UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Get Title' ACTION ( ;
					HMG_CallDLL ( "USER32.DLL" , , "GetWindowText" , GetFormHandle ('Win_1') , @Buffer , 128 ) , ;
					MsgInfo ( Buffer , 'Title' ) ;
								)
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Win_1

Return
