/*
  Name: SET SHOWDETAILERROR ON | OFF Demo
  Description: Enable/Disable "Show Detail Error"
  Note: The change of the switch on|off function "on the fly"
  Author: Antonio Novo <antonionovo@gmail.com>
  Date Created: 14/11/2005
*/

#include "minigui.ch"

Function Main
	Local Pepe
	Set ShowDetailError off

	DEFINE WINDOW Form1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE "SET SHOWDETAILERROR ON | OFF Demo" ;
		MAIN NOMAXIMIZE NOSIZE

	@ 10,10 BUTTON Button1 CAPTION "Set ShowDetailError On" ACTION { || _lShowDetailError(.T.), Pepe++ } WIDTH 200 HEIGHT 40
	@ 50,10 BUTTON Button2 CAPTION "Set ShowDetailError Off" ACTION { || _lShowDetailError(.F.), Pepe++ } WIDTH 200 HEIGHT 40
	@ 90,10 BUTTON Button3 CAPTION "Show Detail Error Status" ACTION { || MsgInfo( "Detail Error is " + iif(_lShowDetailError(), "ON", "OFF") ) } WIDTH 200 HEIGHT 40

	END WINDOW

	CENTER WINDOW Form1

	ACTIVATE WINDOW Form1

Return Nil
