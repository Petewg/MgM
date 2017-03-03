/*
*
* MiniGUI DLL Demo
*
*/

#include "hmg.ch"



Procedure Main

	Local Buffer

	DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'Hello World!' ;
      MAIN ;
      ON RELEASE HMG_UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Get Title' ACTION ( CallDll32( "GetWindowTextA", "USER32.DLL", GetFormHandle('Win_1'), @Buffer, Len( Buffer ) ), ;
				                              MsgInfo( Buffer, 'Title' ) )
			END POPUP
		END MENU

	END WINDOW
   
   Buffer := Space( Len( Win_1.title ) )

   CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return
