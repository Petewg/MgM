/*
* MiniGUI PutFile Demo
* 18.12.2004 + 5-th parameter - default filename added
* (c) Jacek Kubica <kubica@wssk.wroc.pl>
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN 

		DEFINE MAIN MENU
			POPUP 'Common &Dialog Functions'
				
			ITEM 'PutFile() without default file name' ;
				ACTION MsgInfo ( Putfile ( { {'jpg Files','*.jpg'} , {'gif Files','*.gif'} } , 'Save Image As' , 'C:\' ) )
                        ITEM 'PutFile() without default extension' ;
				ACTION MsgInfo ( Putfile ( { {'jpg Files','*.jpg'} , {'gif Files','*.gif'} } , 'Save Image As' , 'C:\' , ;
					.f., "My_picture" ) )
			ITEM 'PutFile() with default filename - My_picture.jpg' ;
				ACTION MsgInfo ( Putfile ( { {'jpg Files','*.jpg'} , {'gif Files','*.gif'} } , 'Save Image As' , 'C:\' , ;
					.f., "My_picture.jpg" ) )
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

Return
