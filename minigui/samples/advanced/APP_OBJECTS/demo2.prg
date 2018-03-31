/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

MEMVAR oMain, oWnd

Function Main
	LOCAL hSplitHandle, nY, nH

	**********
	SET OOP ON
	**********

	SET CENTURY ON

	SET DATE AMERICAN

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 800 HEIGHT 600 ;
		TITLE 'MiniGUI SplitBox Demo' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		*********************************
		PUBLIC oMain := ThisWindow.Object
		*********************************

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM 'Exit'	ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM 'About'	ACTION MsgInfo (MiniGUIVersion(), "MiniGUI SplitBox Demo") 
			END POPUP
		END MENU
	
		DEFINE SPLITBOX HANDLE hSplitHandle

			DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 85,85 FLAT

				BUTTON Button_1 CAPTION '&More ToolBars...' PICTURE 'res\button1.bmp' ACTION MsgInfo('Click! 1')  TOOLTIP 'ONE'

				BUTTON Button_2 CAPTION '&Button 2' PICTURE 'res\button2.bmp' ACTION MsgInfo('Click! 2')  TOOLTIP 'TWO'

				BUTTON Button_3 CAPTION 'Button &3' PICTURE 'res\button3.bmp' ACTION MsgInfo('Click! 3')  TOOLTIP 'THREE'

			END TOOLBAR

		END SPLITBOX

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready'
			STATUSITEM ''
			DATE
			IF "/" $ Set( 4 )
				CLOCK AMPM
			ELSE
				CLOCK
			ENDIF
		END STATUSBAR

		**********************************************************
		PRIVATE oWnd := oMain

		IF oWnd:HasStatusBar
			SetStatusbarProperties()
		ENDIF

		nY := GetWindowHeight( hSplitHandle )
		nH := oWnd:ClientHeight - iif( oWnd:HasStatusBar, oWnd:StatusBar:Height, 0 ) - nY

		@nY +  5, 10 LABEL lblClientH VALUE "Client Area Height = " + hb_ntos( nH ) + " pixels" AUTOSIZE
		@nY + 25, 10 LABEL lblClientW VALUE "Client Area Width = " + hb_ntos( oWnd:ClientWidth ) + " pixels" AUTOSIZE
		**********************************************************

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure SetStatusbarProperties
	LOCAL nItem := 2

	WITH OBJECT oWnd:StatusBar
		:Icon("res\smile.ico")

		:Icon("res\smile.ico", nItem)
		:Say(MiniGUIVersion(), nItem)
		:Width(nItem, 300)
		:Action(nItem, {|| MsgInfo('Status Item Click!')})
	END WITH

Return
