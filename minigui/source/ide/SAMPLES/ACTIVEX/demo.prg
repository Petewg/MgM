/*
* MiniGUI Activex Demo
*/

#include "minigui.ch"

Function Main

	SET AUTOADJUST ON NOBUTTONS

	Load Window Demo
	Activate Window Demo

Return Nil

Procedure demo_button_1_action

	Demo.Activex_1.Object:Navigate("http://hmgextended.com")

Return

#include "ActiveX.prg"
