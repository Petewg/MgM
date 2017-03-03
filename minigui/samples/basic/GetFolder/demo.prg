/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * http://harbourminigui.googlepages.com/
 *
 * Enhanced GetFolder() function. Demo contributed by Jacek Kubica <kubica@wssk.wroc.pl>
 * Based upon contribution of Andy Wos <andywos@unwired.com.au>. Thank you Andy!
 * Demo demonstrate use of GetFolder([<cTitle>],[<cInitFolder>],[nFlags],[lNewFolderButton])
 * HMG 1.0 Experimental Build 8
*/

#include "minigui.ch"

#define MsgInfo( c, t ) MsgInfo( c, t, , .F. )

Procedure Main()
	Local cWinDir := GetWindowsFolder()

	DEFINE WINDOW Form_1 ;
		AT 0,0 WIDTH 530 HEIGHT 145 ;
		MAIN ;
		TITLE "GetFolder Sample by Jacek Kubica <kubica@wssk.wroc.pl>" ;
		BACKCOLOR { 212, 208, 200};
		NOSIZE

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'GetFolder()' ACTION MsgInfo(GetFolder(),"You select ...")
				MENUITEM 'GetFolder("My Title")' ACTION MsgInfo(GetFolder("My Title",,,.F.),"You select ...")
				MENUITEM 'GetFolder("My Title",'+cWinDir+')' ;
					ACTION MsgInfo(GetFolder("My Title",cWinDir),"You select ...")
				SEPARATOR
				MENUITEM 'BrowseForFolder()' ACTION MsgInfo(BrowseForFolder(),"You select ...")
				MENUITEM 'Desktop Folders' ACTION MsgInfo(BrowseForFolder(0),"You select ...")
				SEPARATOR
				MENUITEM 'Exit' ACTION Form_1.Release
			END POPUP
		END MENU

		@ 25,461 BUTTON Button_1 PICTURE 'OPEN_BMP' WIDTH 39 HEIGHT 24;
		         ACTION  {|| Form_1.Textbox_1.Value := GetFolder("Browse for ...",Form_1.Textbox_1.Value) }
		@ 26,97  TEXTBOX TextBox_1 VALUE cWinDir BACKCOLOR {255,255,255} WIDTH 359 HEIGHT 21 FONT "MS Sans Serif" 
		@ 27,18  LABEL Label_1 VALUE "Folder" WIDTH 73 HEIGHT 20 FONT "MS Sans serif" BOLD TRANSPARENT
		@ 0,2   FRAME Frame_1 CAPTION "" WIDTH 518 HEIGHT 70

		DEFINE STATUSBAR ;
			FONT "MS Sans serif" ;
			SIZE 9 BOLD 
                 
			STATUSITEM "Based upon contribution of Andy Wos <andywos@unwired.com.au>" FLAT
		END STATUSBAR


	END WINDOW

	Form_1.Center
	Form_1.Activate

Return
