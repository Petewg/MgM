/*
* MiniGUI GetFile Demo
*/

#include "minigui.ch"

Procedure Main
Local a

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'GetFile Test' ;
		MAIN 

		DEFINE MAIN MENU
			DEFINE POPUP 'Common &Dialog Functions'
				MENUITEM 'Select single file' ACTION MsgInfo( Getfile ( , 'Open a File' , , , .t. ), "Result" )
				MENUITEM 'Select file(s)' ACTION ( a := Getfile ( { {'All Files','*.*'} } , 'Open File(s)' , GetCurrentFolder() , .t. , .t. ), ;
								aEval( a, {|x,i| msginfo ( x, ltrim( str ( i ) ) )} ) )
				SEPARATOR
				ITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

Return
