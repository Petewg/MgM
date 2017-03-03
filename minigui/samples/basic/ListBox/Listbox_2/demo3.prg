/*
* Harbour MiniGUI Demo
* (c) 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Win1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'DRAGITEMS LISTBOX (Alternative syntax)' ;
		MAIN 

		DEFINE LISTBOX LIST1
			ROW		10
			COL		10
			WIDTH		100
			HEIGHT		110
			ITEMS		{ '01','02','03','04','05','06' }
			DRAGITEMS	.T.
		END LISTBOX

	END WINDOW

	CENTER WINDOW Win1

	ACTIVATE WINDOW Win1 

Return Nil
