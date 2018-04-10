/*
* Harbour MiniGUI Demo
*/

#include "minigui.ch"

#xcommand  WAIT WINDOW <message> NOWAIT ;
      => ;
	ShowWait_Window(<message>) 

#xcommand  WAIT CLEAR ;
      => ;
	HideWait_Window()

Function Main
Local cTitle := 'WAIT WINDOW DEMO - Foxpro style'

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE cTitle ;
		MAIN

		@ 70,70 BUTTON Button_1 CAPTION 'WAIT WINDOW "Processing..." NOWAIT' ACTION Test1() WIDTH 250
		@ 100,70 BUTTON Button_2 CAPTION 'WAIT CLEAR' ACTION Test2(cTitle) WIDTH 250

	END WINDOW

	CENTER WINDOW Win_1 

	ACTIVATE WINDOW Win_1

Return Nil

procedure test1()

	WAIT WINDOW "Processing... " NOWAIT

	Win_1.Title := "Processing... "

	Win_1.Setfocus()

return

procedure test2( cTitle )

	WAIT CLEAR

	Win_1.Title := cTitle

	DO MESSAGE LOOP

return


#include "WaitWindowFox.prg"
