/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Readonly Text/Edit controls colors - DEMO
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 * HMG Experimental 1.1 Build 12a
*/

#include "minigui.ch"

Function Main()

   DEFINE WINDOW Form_1 ;
      AT 0,0 WIDTH 610 HEIGHT 320 + IF(IsXPThemeActive(), 8, 0) ;
      MAIN TITLE "Readonly Text/Edit controls - Colors DEMO - J.Kubica <kubica@wssk.wroc.pl>"

      // No back and fontcolor set - READONLY standard behavior

      @ 21,38 LABEL Label_1 VALUE "FontColor: <not set>" WIDTH 163 HEIGHT 16
      @ 42,38 LABEL Label_2 VALUE "BackColor: <not set>" WIDTH 160 HEIGHT 17

      @ 67,35  TEXTBOX TextBox_1 WIDTH 163 HEIGHT 23 VALUE  "TextBox_1 "
      @ 97,35  EDITBOX EditBox_1 WIDTH 164 HEIGHT 146 VALUE "EditBox_1 "

      @ 247,34 CHECKBOX CheckBox_1 CAPTION "Readonly" WIDTH 100 HEIGHT 28;
               ON Change {|| IIf(This.Value,(Form_1.TextBox_1.Readonly:=.t.,Form_1.EditBox_1.Readonly:=.t.),(Form_1.TextBox_1.Readonly:=.f.,Form_1.EditBox_1.Readonly:=.f.))}

      // Back and fontcolor set

      @ 21,38 +180 LABEL Label_1a VALUE "FontColor: White" WIDTH 163 HEIGHT 16
      @ 42,38 +180 LABEL Label_2a VALUE "BackColor: Red" WIDTH 160 HEIGHT 17

      @ 67,35+180  TEXTBOX TextBox_1a WIDTH 163 HEIGHT 23 VALUE  "TextBox_1a " FontColor  {255,255,255}  BackColor {200,0,0}
      @ 97,35+180  EDITBOX EditBox_1a WIDTH 164 HEIGHT 146 VALUE "EditBox_1a " FontColor  {255,255,255}  BackColor {200,0,0}

      @ 247,34+180 CHECKBOX CheckBox_1a CAPTION "Readonly" WIDTH 100 HEIGHT 28;
               ON Change {|| IIf(This.Value,(Form_1.TextBox_1a.Readonly:=.t.,Form_1.EditBox_1a.Readonly:=.t.),(Form_1.TextBox_1a.Readonly:=.f.,Form_1.EditBox_1a.Readonly:=.f.))}

      // Back and fontcolor set as arrays {aEnable,aReadonly}

      @ 21,38 +180+180 LABEL Label_1b VALUE "FontColor: {White,Yellow}" WIDTH 163 HEIGHT 16
      @ 42,38 +180+180 LABEL Label_2b VALUE "BackColor: (Blue  ,DarkBlue}" WIDTH 160 HEIGHT 17

      @ 67,35+180+180  TEXTBOX TextBox_1b WIDTH 163 HEIGHT 23 VALUE  "TextBox_1b " FontColor  {{255,255,255},{255,255,0}}  BackColor {{0,0,200},{0,0,100}}
      @ 97,35+180+180  EDITBOX EditBox_1b WIDTH 164 HEIGHT 146 VALUE "EditBox_1b " FontColor  {{255,255,255},{255,255,0}}  BackColor {{0,0,200},{0,0,100}}

      @ 247,34+180+180 CHECKBOX CheckBox_1b CAPTION "Readonly" WIDTH 100 HEIGHT 28;
               ON Change {|| IIf(This.Value,(Form_1.TextBox_1b.Readonly:=.t.,Form_1.EditBox_1b.Readonly:=.t.),(Form_1.TextBox_1b.Readonly:=.f.,Form_1.EditBox_1b.Readonly:=.f.))}

	DEFINE MAIN MENU

		POPUP "Set BackColor"
			ITEM "Set backcolor of TEXT_1 to WHITE" ACTION Form_1.TextBox_1.Backcolor:={255,255,255}
			ITEM "Set backcolor of TEXT_1a to BLACK" ACTION Form_1.TextBox_1a.Backcolor:={0,0,0}
			ITEM "Set backcolor of TEXT_1b to RED" ACTION Form_1.TextBox_1b.Backcolor:={255,0,0}
			SEPARATOR
			ITEM "Set backcolor of TEXT_1 to WHITE/RED" ACTION Form_1.TextBox_1.Backcolor:={{255,255,255},{255,0,0}}
			ITEM "Set backcolor of TEXT_1a to BLACK/RED" ACTION Form_1.TextBox_1a.Backcolor:={{0,0,0},{255,0,0}}
			ITEM "Set backcolor of TEXT_1b to RED/BLUE" ACTION Form_1.TextBox_1b.Backcolor:={{255,0,0},{0,0,200}}
			SEPARATOR
			ITEM "Set backcolor of TEXT_1 to  <not set>" ACTION Form_1.TextBox_1.Backcolor:=""
			ITEM "Set backcolor of TEXT_1a to <not set>" ACTION Form_1.TextBox_1a.Backcolor:=""
			ITEM "Set backcolor of TEXT_1b to <not set>" ACTION Form_1.TextBox_1b.Backcolor:=""
		END POPUP

		POPUP "Set FontColor"
			ITEM "Set FontColor of TEXT_1 to WHITE" ACTION Form_1.TextBox_1.FontColor:={255,255,255}
			ITEM "Set FontColor of TEXT_1a to BLACK" ACTION Form_1.TextBox_1a.FontColor:={0,0,0}
			ITEM "Set FontColor of TEXT_1b to RED" ACTION Form_1.TextBox_1b.FontColor:={255,0,0}
			SEPARATOR
			ITEM "Set FontColor of TEXT_1 to WHITE/RED" ACTION Form_1.TextBox_1.FontColor:={{255,255,255},{255,0,0}}
			ITEM "Set FontColor of TEXT_1a to BLACK/RED" ACTION Form_1.TextBox_1a.FontColor:={{0,0,0},{255,0,0}}
			ITEM "Set FontColor of TEXT_1b to RED/BLUE" ACTION Form_1.TextBox_1b.FontColor:={{255,0,0},{0,0,200}}
			SEPARATOR
			ITEM "Set FontColor of TEXT_1 to  <not set>" ACTION Form_1.TextBox_1.FontColor:=""
			ITEM "Set FontColor of TEXT_1a to <not set>" ACTION Form_1.TextBox_1a.FontColor:=""
			ITEM "Set FontColor of TEXT_1b to <not set>" ACTION Form_1.TextBox_1b.FontColor:=""
		END POPUP

		POPUP "Get ReadOnly Status"
			ITEM "Get ReadOnly Status of TEXT_1" ACTION msginfo("Readonly is " + if(Form_1.TextBox_1.Readonly == .t.,"TRUE","FALSE"),"TEXT_1")
			ITEM "Get ReadOnly Status of TEXT_1a" ACTION msginfo("Readonly is " + if(Form_1.TextBox_1a.Readonly == .t.,"TRUE","FALSE"),"TEXT_1a")
			ITEM "Get ReadOnly Status of TEXT_1b" ACTION msginfo("Readonly is " + if(Form_1.TextBox_1b.Readonly == .t.,"TRUE","FALSE"),"TEXT_1b")
		END POPUP

	END MENU

   END WINDOW

   Form_1.Center
   Form_1.Activate

Return Nil
