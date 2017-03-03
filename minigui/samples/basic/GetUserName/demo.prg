/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 300 ;
		HEIGHT 300 ;
		TITLE "MiniGUI Demo" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

		@  10,20 LABEL Label1 VALUE "User Name"
		@  35,20 TEXTBOX TextBox1 VALUE ""

		@  80,20 LABEL Label2 VALUE "Computer Name"
		@ 105,20 TEXTBOX TextBox2 VALUE ""

		@ 180,20 BUTTON Button1 CAPTION "Get Names" ON CLICK _GetNames()

	END WINDOW

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil


Static Function _GetNames()

   Form1.TextBox1.Value := GetUserName()
   Form1.TextBox2.Value := GetComputerName()

Return Nil
