/*
 * Vista Command Link Button Demo
 * (c) 2016 Grigory Filatov
 */

#include "minigui.ch"

Procedure Main

	IF ! IsWinNT() .OR. ! ISVISTAORLATER()
		MsgStop( 'This Program Runs In WinVista Or Later!', 'Stop' )
		Return
	ENDIF

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'Vista Command Link Button Demo' ;
		MAIN ;
		ON RELEASE Win1.Test.Release

		DEFINE MAIN MENU
			DEFINE POPUP 'Methods'
				MENUITEM 'Custom Method: SetFocus' ACTION Win1.Test.SetFocus
				MENUITEM 'Custom Method: Disable' ACTION Win1.Test.Disable
				MENUITEM 'Custom Method: Enable' ACTION Win1.Test.Enable
				MENUITEM 'Custom Method: SetShield' ACTION Win1.Test.SetShield
			END POPUP
			DEFINE POPUP 'Properties'
				MENUITEM 'Custom Property: Handle (Get)' ACTION MsgInfo ( Str ( Win1.Test.Handle ) )
				MENUITEM 'Custom Property: Handle (Set)' ACTION Win1.Test.Handle := 1
				MENUITEM 'Custom Property: Caption (Get)' ACTION MsgInfo ( Win1.Test.Caption )
				MENUITEM 'Custom Property: Caption (Set)' ACTION Win1.Test.Caption := 'New Caption'
				MENUITEM 'Custom Property: NoteText (Get)' ACTION Win1.Test.NoteText
				MENUITEM 'Custom Property: NoteText (Set)' ACTION Win1.Test.NoteText := 'New Note'
				MENUITEM 'Custom Property: Picture (Get)' ACTION MsgInfo ( Win1.Test.Picture )
				MENUITEM 'Custom Property: Picture (Set)' ACTION Win1.Test.Picture := 'button.bmp'
			END POPUP
		END MENU

		@ 10 , 10 CLBUTTON test ;
			CAPTION 'Command Link' ;
			NOTETEXT "This is a test note" ;
			ACTION MsgInfo('Click!') DEFAULT

		@ 100 , 10 CLBUTTON test_2 ;
			CAPTION 'Command Link 2' ;
			NOTETEXT "This is a test note 2" ;
			ACTION MsgInfo('Click 2!')

		IF ! wapi_IsUserAnAdmin()
			Win1.Test_2.SetShield
		ENDIF

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1

Return
