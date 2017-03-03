/*
 * MiniGUI Menu MRU Demo
 *
 * (C) 2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Function Main
   Local cPrompt

   If !File('demo2.ini')
	BEGIN INI FILENAME 'demo2.ini'
		SET SECTION "MRU" ENTRY "1" TO "Item1"
		SET SECTION "MRU" ENTRY "2" TO "Item2"
		SET SECTION "MRU" ENTRY "3" TO "Item3"
	END INI
   EndIf

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'MiniGUI MRU Demo' ;
		MAIN ;
		ON RELEASE SaveMRUFileList()

		DEFINE MAIN MENU

		    POPUP "Test"
			MENUITEM "&Manage this under MRU list" ;
                          ACTION ( cPrompt := InputBox( "Write something", "Whatever..." ),;
                                   AddMenuElement(cPrompt, "MsgInfo(cPrompt)") )

			POPUP "&MRU"
                           MRUITEM INI 'demo2.ini' SECTION "MRU" SIZE 5 ACTION MsgInfo ( cPrompt )
			END POPUP

                        MENUITEM "&Clear the MRU List" ACTION ClearMRUList()

                        SEPARATOR
                        MENUITEM  'Exit' ACTION ThisWindow.Release()
		    END POPUP

		END MENU

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return Nil
