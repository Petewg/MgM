/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	Set StationName	To 'John_Station'
	Set CommPath	To hb_DirTemp()
	
	SET CENTERWINDOW RELATIVE PARENT
	SET AUTOADJUST ON NOBUTTONS

	DEFINE WINDOW MainForm ;
		AT 0,370 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Communications Demo - GET DATA STATION' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Receive Data'		ACTION GetTest()
				ITEM 'Auto-Receive ON/OFF' ACTION AutoReceive() NAME AutoReceive_Menu_Item
				ITEM 'Clear Data' ACTION {|| MainForm.EDIT_1.VALUE := "" }
				SEPARATOR
				ITEM 'Exit'		ACTION MainForm.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Communications Demo") 
			END POPUP
		END MENU
		DEFINE LABEL Label_1 
			COL 250 
			ROW 0
			WIDTH 140
			HEIGHT 18
			FONTCOLOR {255,0,0}
			FONTBOLD .T.
			VALUE "Auto-receive is OFF"
		END LABEL
		
		DEFINE EDITBOX Edit_1 
		   PARENT MainForm
			COL 10
			ROW 20
			WIDTH 600
			HEIGHT 380
			VALUE ""
			READONLY .F. 
			FONTNAME "COURIER NEW"
			FONTSIZE 10
			FONTBOLD .F. 
			FONTITALIC .F. 
			FONTUNDERLINE .F. 
			FONTSTRIKEOUT .F.
			TOOLTIP "Data sent by the other station"
			BACKCOLOR {{255,255,255} , {255,255,255}}
			FONTCOLOR {{000,000,000} , {000,000,000}}
			MAXLENGTH NIL
			ONGOTFOCUS {|| THIS.FONTITALIC := .T., THIS.FONTBOLD := .T., THIS.REFRESH() }
			ONCHANGE NIL
			ONLOSTFOCUS {|| THIS.FONTITALIC := .F., THIS.FONTBOLD := .F., THIS.REFRESH() }
			HELPID NIL
			INVISIBLE .F.
			NOTABSTOP .T.
			NOVSCROLLBAR .F.
			NOHSCROLLBAR .F.
		END EDITBOX 
		
		DEFINE TIMER Timer_1 INTERVAL 1000 ACTION GetTest()
		MainForm.Timer_1.Enabled := .F.

	END WINDOW

	// CENTER WINDOW Form_0

	ACTIVATE WINDOW MainForm

Return Nil

PROCEDURE AutoReceive()
	LOCAL lStatus := ! MainForm.AutoReceive_Menu_Item.Checked
	
	MainForm.Timer_1.Enabled := lStatus
	MainForm.AutoReceive_Menu_Item.Checked := lStatus
	MainForm.Label_1.Value := "Auto-receive is " + Iif( lStatus, "ON", "OFF")
	
	RETURN

Procedure GetTest()
Local r , i, s := ""

	Repeat

		r := GetData()

		If Valtype (r) == 'A'

			If Valtype ( r [1] ) != 'A'

				// Aeval ( r, { |i| MsgInfo( i ) } )
				Aeval ( r, { |i| s := s + hb_ValToStr(i) + hb_EoL() } )

			Else

				For Each i In r

					// Aeval ( i, { |j| MsgInfo( j ) } )
					Aeval ( i, { |j| s := s + hb_ValToStr(j) + hb_EoL() } )

				Next

			EndIf

		ElseIf r # Nil

			// MsgInfo( r )
			s := s + hb_ValToStr(r) + hb_EoL()

		EndIf

	Until r # Nil
	
	MainForm.EDIT_1.VALUE := MainForm.EDIT_1.VALUE + s

	Return
