/*
 * MiniGUI User Components Demo
 * (c) 2008 Grigory Filatov
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Custom Component Demo' ;
		MAIN ;
		ON INIT OnInit()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Custom Method: SetFocus' ACTION Win1.Test.SetFocus
				MENUITEM 'Custom Method: Disable' ACTION Win1.Test.Disable
				MENUITEM 'Custom Method: Enable' ACTION Win1.Test.Enable
				MENUITEM 'Custom Property: Handle (Get)' ACTION MsgInfo ( Str ( Win1.Test.Handle ) )
				MENUITEM 'Custom Property: Handle (Set)' ACTION Win1.Test.Handle := 1
				MENUITEM 'Custom Property: Caption (Get)' ACTION MsgInfo ( Win1.Test.Caption )
			END POPUP
		END MENU

		@ 10 , 30 MYSYSLINK test ;
			OF Win1 ;
			CAPTION 'For more information, click here or here' ;
			ACTION ShellExecute(0, "open", "http://www.microsoft.com") 

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1

Return

Procedure OnInit

	IF !IsWinXPorLater()
		MsgStop( 'This Program Runs In WinXP or Later Only!', 'Stop' )
		ReleaseAllWindows()
	ENDIF

Return


#include "MySysLink.prg"