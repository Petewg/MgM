/*
 * MiniGUI User Components Demo
 * (c) 2017 Grigory Filatov
 */

#include "minigui.ch"

Procedure Main

	IF !IsWinNT() .OR. !IsVistaOrLater()
		MsgStop( 'This Program Runs In WinVista Or Later!', 'Stop' )
		Return
	ENDIF

	SET FONT TO 'MS Shell Dlg', 8

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'Vista Split Button Demo' ;
		MAIN

		DEFINE MAIN MENU
			DEFINE POPUP 'Methods'
				MENUITEM 'Custom Method: SetFocus' ACTION Win1.Test.SetFocus
				MENUITEM 'Custom Method: Disable'  ACTION Win1.Test.Disable
				MENUITEM 'Custom Method: Enable'   ACTION Win1.Test.Enable
			END POPUP
		END MENU

		@ 10 , 10 SPLITBUTTON test ;
			CAPTION 'Split Button' ;
			ACTION MsgInfo( "Split Button 1", "Pressed" ) ;
			TOOLTIP 'Split Button 1' ;
			DEFAULT

		DEFINE DROPDOWN MENU BUTTON test
			MENUITEM "Split"  ACTION Win1.Test.Caption := "Split"
			MENUITEM "Button" ACTION Win1.Test.Caption := "Button"
		END MENU

		DEFINE SPLITBUTTON test_2
			ROW    100
			COL    10
			CAPTION 'Split Button 2'
			ACTION MsgInfo( "Split Button 2", "Pressed" )
			TOOLTIP 'Split Button 2'
		END SPLITBUTTON

		DEFINE DROPDOWN MENU BUTTON test_2
			MENUITEM "Drop Down Menu 1" ACTION MsgInfo( "Button Drop Down Menu 1", "Pressed" )
			MENUITEM "Drop Down Menu 2" ACTION MsgInfo( "Button Drop Down Menu 2", "Pressed" )
		END MENU

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1

Return
