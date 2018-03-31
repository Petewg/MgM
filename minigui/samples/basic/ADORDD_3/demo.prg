/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 *	To test this sample: 
 *
 *	- 'root' at 'localhost' with no password is assumed.
 *	- 'NAMEBOOK' database and 'NAMES' existence is assumed
 *	  (you may create them using 'demo_2.prg' sample 
 *	  at \minigui\samples\basic\mysql)
 *	
*/

#include "adordd.ch"
#include "minigui.ch"

Function Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 HEIGHT 600 ;
		TITLE 'MiniGUI MySql Browse Demo' ;
		MAIN NOMAXIMIZE 

		DEFINE MAIN MENU
			POPUP 'File'
				MENUITEM 'Query' ACTION Query()
				SEPARATOR	                                       			                                    
				ITEM "Exit" ACTION ThisWindow.Release()
			END POPUP
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure Query

Local cDatabase := 'NAMEBOOK'
Local cTable := 'Names'
Local cServer := 'localhost'
Local cUser := 'root'
Local cPass := ''
Local aFieldNames := {}
Local aHeaders := {}
Local aWidths  := {}
Local i

	If InputWindow( 'Login' , ;
		{'Server' , 'User', 'Password', 'Database', 'Table'} , ;
		{cServer , cUser, cPass, cDatabase, cTable } , ;
		{ 16 , 16 , 16 , 16 , 16 } ) [1] # Nil

		USE (cDataBase) VIA "ADORDD" TABLE cTable MYSQL ;
			FROM cServer USER cUser PASSWORD cPass

		For i := 1 To FCount()
			aadd ( aFieldNames , cDataBase + '->' + FieldName(i) )
			aadd ( aHeaders , FieldName(i) )
			aadd ( aWidths , 160 )
		Next i

		DEFINE WINDOW Query ;
			AT 0,0 ;
			WIDTH 640 HEIGHT 480 ;
			TITLE 'MiniGUI ADO RDD Sample' ;
			NOMAXIMIZE 

			@ 10,10 BROWSE Browse_1									;
				WIDTH 610  										;
				HEIGHT 390 										;	
				HEADERS aHeaders ;
				WIDTHS aWidths ;
				WORKAREA &(cDataBase) ;
				FIELDS aFieldNames 

		END WINDOW

		CENTER WINDOW Query

		ACTIVATE WINDOW Query

		USE

	EndIf

Return
