/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006-08 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 545 HEIGHT 439 ;
		TITLE 'Tab Control Demo' ;
		MAIN ;
		ON INIT ReSizeControls() ;
		ON MAXIMIZE ReSizeControls() ;
		ON SIZE ReSizeControls() ;
		FONT "MS Sans Serif" SIZE 8

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
			DEFINE POPUP 'Help'
				MENUITEM 'About' ACTION MsgInfo( MiniguiVersion(), 'Tab Control Demo', , .f. )
			END POPUP
		END MENU

		DEFINE TAB Tab_1 ;
			AT 0,0 ;
			WIDTH 0 ;
			HEIGHT 0 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control 1' ;
			MULTILINE ;
			BOTTOM

			PAGE 'Tab Page 1'

				@ 50,90 BUTTON Button_1 ;
					CAPTION 'Command 1' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION MsgStop(Form_1.Button_1.Caption + " Clicked", "Info",,.f.)
                                 
				@ 140,90 BUTTON Button_2 ;
					CAPTION 'Command 2' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION MsgStop(Form_1.Button_2.Caption + " Clicked", "Info",,.f.)
                                 
				@ 230,90 BUTTON Button_3 ;
					CAPTION 'Command 3' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION MsgStop(Form_1.Button_3.Caption + " Clicked", "Info",,.f.)
                                 
			END PAGE

			PAGE 'Tab Page 2'

				@ 6,6 FRAME Frame_1 WIDTH 300 HEIGHT 300 CAPTION "Page 2"

				@ 50,120 BUTTON Button_4 ;
					CAPTION 'Command 4' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION Form_1.Label_1.Value := Form_1.Button_4.Caption + " Clicked"

				@ 175,85 LABEL Label_1 VALUE "" AUTOSIZE

				@ 230,50 BUTTON Button_5 ;
					CAPTION 'Command 5' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION Form_1.Label_1.Value := Form_1.Button_5.Caption + " Clicked"
                                 
			END PAGE

			PAGE 'Tab Page 3'

				@ 6,6 FRAME Frame_2 WIDTH 300 HEIGHT 300 CAPTION "Page 3"

				@ 50,50 BUTTON Button_6 ;
					CAPTION 'Command 6' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION Form_1.Label_2.Value := Form_1.Button_6.Caption + " Clicked"

				@ 175,85 LABEL Label_2 VALUE "" AUTOSIZE

				@ 230,120 BUTTON Button_7 ;
					CAPTION 'Command 7' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION Form_1.Label_2.Value := Form_1.Button_7.Caption + " Clicked"
                                 
			END PAGE

			PAGE 'Tab Page 4'

				@ 6,6 FRAME Frame_3 WIDTH 300 HEIGHT 300 CAPTION "Page 4"

			END PAGE

		END TAB

		Form_1.Frame_1.Caption := Form_1.Tab_1.Caption(2)
		Form_1.Frame_2.Caption := Form_1.Tab_1.Caption(3)
		Form_1.Frame_3.Caption := Form_1.Tab_1.Caption(4)

		DEFINE TAB Tab_2 ;
			AT 0,0 ;
			WIDTH 0 ;
			HEIGHT 0 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control 2' ;
			FONT "MS Sans Serif" SIZE 9 ;
			BUTTONS VERTICAL BOTTOM

			PAGE 'Page 1'

				@ 6,6 FRAME Frame_4 WIDTH 300 HEIGHT 300 CAPTION "Page 1"

				@ 24,14 LABEL Label_3 VALUE "" WIDTH 218 HEIGHT 300

			END PAGE

			PAGE 'Page 2'

				@ 6,6 FRAME Frame_5 WIDTH 300 HEIGHT 300 CAPTION "Page 2"

				@ 60,80 BUTTON Button_8 ;
					CAPTION 'Command 8' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION MsgStop(Form_1.Button_8.Caption + " Clicked", "Info",,.f.)
                                 
				@ 240,80 BUTTON Button_9 ;
					CAPTION 'Command 9' ;
					WIDTH 82 HEIGHT 82 ;
					ACTION MsgStop(Form_1.Button_9.Caption + " Clicked", "Info",,.f.)
                                 
			END PAGE

			PAGE 'Page 3'

				@ 6,6 FRAME Frame_6 WIDTH 300 HEIGHT 300 CAPTION "Page 3"

			END PAGE

			PAGE 'Page 4'

				@ 6,6 FRAME Frame_7 WIDTH 300 HEIGHT 300 CAPTION "Page 4"

			END PAGE

		END TAB

		Form_1.Frame_4.Caption := 'Tab ' + Form_1.Tab_2.Caption(1)
		Form_1.Frame_5.Caption := 'Tab ' + Form_1.Tab_2.Caption(2)
		Form_1.Frame_6.Caption := 'Tab ' + Form_1.Tab_2.Caption(3)
		Form_1.Frame_7.Caption := 'Tab ' + Form_1.Tab_2.Caption(4)

		Form_1.Label_3.Value := "Use the Tab key to navigate between tab controls." + CRLF + CRLF + ;
			"Use the arrow keys to select a tab page." + CRLF + CRLF + ;
			"Use the Tab key or arrow keys to navigate between tab page child commands." + CRLF + CRLF + ;
			"Use Enter key to execute selected command." + CRLF + CRLF + ;
			"Try resizing the window while looking at different tabs."

		ON KEY UP ACTION IF(This.FocusedControl == "Tab_2", MoveTabUp(Form_1.Tab_2.Value), InsertShiftTab())
		ON KEY DOWN ACTION IF(This.FocusedControl == "Tab_2", MoveTabDown(Form_1.Tab_2.Value), InsertTab())

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil

Procedure ReSizeControls()
Local w, h, f

	Form_1.Width := IF(Form_1.Width < 545, 545, Form_1.Width)
	Form_1.Height := IF(Form_1.Height < 439, 439, Form_1.Height)

	f := Form_1.Height - GetTitleHeight() - GetBorderHeight()* 2 - GetMenuBarHeight()
	Form_1.Tab_1.Width := Form_1.Width - ( 0.513 * Form_1.Width )
	Form_1.Tab_1.Height := f

	Form_1.Tab_2.Col := Form_1.Tab_1.Width + 6
	Form_1.Tab_2.Width := Form_1.Width - ( 0.52 * Form_1.Width )
	Form_1.Tab_2.Height := f

	w := Form_1.Tab_1.Width - 14
	h := Form_1.Tab_1.Height - 34
	Form_1.Frame_1.Width := w
	Form_1.Frame_1.Height := h - if(w<261, 20, 0)
	Form_1.Frame_2.Width := w
	Form_1.Frame_2.Height := h - if(w<261, 20, 0)
	Form_1.Frame_3.Width := w
	Form_1.Frame_3.Height := h - if(w<261, 20, 0)

	w := Form_1.Tab_2.Width - 34
	h := Form_1.Tab_2.Height - 14
	Form_1.Frame_4.Width := w
	Form_1.Frame_4.Height := h
	Form_1.Frame_5.Width := w
	Form_1.Frame_5.Height := h
	Form_1.Frame_6.Width := w
	Form_1.Frame_6.Height := h
	Form_1.Frame_7.Width := w
	Form_1.Frame_7.Height := h

Return

Procedure MoveTabUp( nTab )
	nTab--
	Form_1.Tab_2.Value := IF(nTab < 1, 1, nTab)
Return

Procedure MoveTabDown( nTab )
	nTab++
	Form_1.Tab_2.Value := IF(nTab > 4, 4, nTab)
Return
