/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	SET DEFAULT ICON TO GetStartupFolder() + "\demo.ico"
	SET CENTERWINDOW RELATIVE PARENT

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI ToolBar Demo' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		ON KEY F2 ACTION MsgInfo('F2 (Main)')
		ON KEY F10 ACTION TB_ReplacePictureClick()

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM '&Disable ToolBar Button'	ACTION Form_1.Toolbar_1.Button_1.Enabled := .F. 
				ITEM '&Enable ToolBar Button'	ACTION Form_1.Toolbar_1.Button_1.Enabled :=  .T. 
				SEPARATOR
				ITEM 'Get ToolBar Button Caption' ACTION MsgInfo( Form_1.Toolbar_1.Button_1.Caption ) 
				ITEM 'Set ToolBar Button Caption' ACTION SetProperty ( 'Form_1' , 'ToolBar_1' , 'Button_1' , 'Caption' , 'New Caption' )
				SEPARATOR
				ITEM 'Get ToolBar Button Picture' ACTION MsgInfo( Form_1.Toolbar_1.Button_1.Picture )
				ITEM 'Set ToolBar Button Picture' ACTION TB_ReplacePictureClick()
				SEPARATOR
				ITEM '&Exit'			ACTION Form_1.Release
			END POPUP
			POPUP '&Help'
				ITEM '&About'			ACTION MsgInfo ("MiniGUI ToolBar demo") 
			END POPUP
		END MENU

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 85,85 FLAT BORDER 

			BUTTON Button_1 ;
			CAPTION '&More ToolBars...' ;
			PICTURE 'button1.bmp' ;
			ACTION Modal_Click()  TOOLTIP 'ONE'

			BUTTON Button_2 ;
			CAPTION '&Button 2' ;
			PICTURE 'button2.bmp' ;
			ACTION MsgInfo('Click! 2')  TOOLTIP 'TWO'

			BUTTON Button_3 ;
			CAPTION 'Button &3' ;
			PICTURE 'button3.bmp' ;
			ACTION MsgInfo('Click! 3')  TOOLTIP 'THREE'

		END TOOLBAR

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Procedure Modal_CLick
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 300 ;
		TITLE 'ToolBar Test'  ;
		MODAL NOSIZE

		ON KEY F2 ACTION MsgInfo('F2 (Child)')
		ON KEY F10 ACTION MsgInfo('F10 (Child)')

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready!' 
		END STATUSBAR

		DEFINE TOOLBAR ToolBar_1 FLAT BUTTONSIZE 100,30 BOTTOM RIGHTTEXT 

			BUTTON Button_1 ;
			CAPTION '&Undo' ;
			PICTURE 'button4.bmp' ;
			ACTION MsgInfo('UnDo Click!') 

			BUTTON Button_2 ;
			CAPTION '&Save' ;
			PICTURE 'button5.bmp' ;
			ACTION MsgInfo('Save Click!') 

			BUTTON Button_3 ;
			CAPTION '&Close' ;
			PICTURE 'button6.bmp' ;
			ACTION Form_2.Release

		END TOOLBAR

	END WINDOW

	Form_2.Center

	Form_2.Activate

Return

*-----------------------------------------------------------------------------*
Function TB_ReplacePictureClick
*-----------------------------------------------------------------------------*
STATIC i := 1

   i++
   IF i > 3
      i := 1
   ENDIF
   
   DO CASE
      CASE i == 1
         Form_1.Button_1.Caption := 'ONE'
         Form_1.Button_1.Picture := 'button1.bmp'
      CASE i == 2
         Form_1.Button_1.Caption := 'TWO'
         Form_1.Button_1.Picture := 'button2.bmp'
      CASE i == 3
         Form_1.Button_1.Caption := 'THREE'
         Form_1.Button_1.Picture := 'button3.bmp'
   ENDCASE

Return Nil
