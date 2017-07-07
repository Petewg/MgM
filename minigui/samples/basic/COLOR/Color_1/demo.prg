/*
* MiniGUI Color Demo
* (c) 2003 Roberto Lopez
* 2006-2008 MiniGUI Team
*/

#include "minigui.ch"

Procedure Main

	SET AUTOADJUST ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Color Demo' ;
		MAIN ;
		BACKCOLOR YELLOW

		DEFINE MAIN MENU
			POPUP 'Change FontColor'
				ITEM 'Set Text_1 FontColor' ACTION Form_1.Text_1.FontColor := GetColor() 
				ITEM 'Set Label_1 FontColor' ACTION Form_1.Label_1.FontColor := GetColor()
				ITEM 'Set Check_1 FontColor' ACTION Form_1.Check_1.FontColor := GetColor() 
				ITEM 'Set Radio_1 FontColor' ACTION Form_1.Radio_1.FontColor := GetColor()
				ITEM 'Set Frame_1 FontColor' ACTION Form_1.Frame_1.FontColor := GetColor()
				ITEM 'Set Spinner_1 FontColor' ACTION Form_1.Spinner_1.FontColor := GetColor()
				ITEM 'Set Edit_1 FontColor' ACTION Form_1.Edit_1.FontColor := GetColor()
				ITEM 'Set List_1 FontColor' ACTION Form_1.List_1.FontColor := GetColor()
				ITEM 'Set Grid_1 FontColor' ACTION Form_1.Grid_1.FontColor := GetColor()
				ITEM 'Set Combo_1 FontColor' ACTION ( Form_1.Combo_1.FontColor := GetColor(), ;
					Form_1.Combo_2.BackColor := Form_1.Combo_1.FontColor )
				SEPARATOR
				ITEM 'Exit' ACTION ThisWindow.Release
			END POPUP
			POPUP 'Change BackColor'
				ITEM 'Set Text_1 BackColor' ACTION Form_1.Text_1.BackColor := GetColor() 
				ITEM 'Set Label_1 BackColor' ACTION Form_1.Label_1.BackColor := GetColor()
				ITEM 'Set Check_1 BackColor' ACTION Form_1.Check_1.BackColor := GetColor()
				ITEM 'Set Radio_1 BackColor' ACTION Form_1.Radio_1.BackColor := GetColor()
				ITEM 'Set Frame_1 BackColor' ACTION Form_1.Frame_1.BackColor := GetColor()
				ITEM 'Set Spinner_1 BackColor' ACTION Form_1.Spinner_1.BackColor := GetColor()
				ITEM 'Set Edit_1 BackColor' ACTION Form_1.Edit_1.BackColor := GetColor()
				ITEM 'Set List_1 BackColor' ACTION Form_1.List_1.BackColor := GetColor()
				ITEM 'Set Grid_1 BackColor' ACTION Form_1.Grid_1.BackColor := GetColor()
				ITEM 'Set Combo_1 BackColor' ACTION ( Form_1.Combo_1.BackColor := GetColor(), ;
					Form_1.Combo_2.FontColor := Form_1.Combo_1.BackColor )
				ITEM 'Set Slider_1 BackColor' ACTION Form_1.Slider_1.BackColor := GetColor()
				SEPARATOR
				ITEM 'Set Form_1 BackColor' ACTION ( Form_1.BackColor := GetColor(), ;
					Form_1.Label_1.BackColor := Form_1.BackColor, ;
					Form_1.Check_1.BackColor := Form_1.BackColor, ;
					Form_1.Radio_1.BackColor := Form_1.BackColor, ;
					Form_1.Frame_1.BackColor := Form_1.BackColor, ;
					Form_1.Slider_1.BackColor := Form_1.BackColor, ;
					Form_1.Hide, Form_1.Show )
			END POPUP
		END MENU

		@ 10,10 TEXTBOX Text_1 ;
			VALUE 'This is TextBox' ;
			TOOLTIP 'TextBox Control' ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW

		@ 40,10 LABEL Label_1 VALUE 'This is Label' ;
			TOOLTIP 'Label Control' ;
			BACKCOLOR YELLOW ;
			FONTCOLOR BLUE

		@ 70,10 CHECKBOX Check_1 CAPTION 'CheckBox' ;
			VALUE .T. ;
			TOOLTIP 'CheckBox Control' ;
			BACKCOLOR YELLOW ;
			FONTCOLOR BLUE

		@ 100,10 RADIOGROUP Radio_1 ;
			OPTIONS { 'One', 'Two', 'Three', 'Four' } ;
			VALUE 1 ;
			TOOLTIP 'RadioGroup Control' ;
			BACKCOLOR YELLOW ;
			FONTCOLOR BLUE

		@ 220,10 FRAME Frame_1 CAPTION 'Frame' ;
			WIDTH 130 ;
			HEIGHT 110 ;
			BACKCOLOR YELLOW ;
			FONTCOLOR BLUE

		@ 350,10 SLIDER Slider_1 ;
			RANGE 1,10 ;
			VALUE 5 ;
			TOOLTIP 'Slider Control' ;
			BACKCOLOR YELLOW 

		@ 400,10 SPINNER Spinner_1 ;
			RANGE 0,10 ;
			VALUE 5 ;
			WIDTH 100 ;
			TOOLTIP 'Spinner Control Range: 0,10' ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW

		@ 10,200 EDITBOX Edit_1 ;
			VALUE 'This is EditBox' ;
			HEIGHT 180 ;
			TOOLTIP 'EditBox Control' ;
			NOVSCROLL NOHSCROLL ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW

		@ 225,200 LISTBOX List_1 ;
			WIDTH 120 ;
			HEIGHT 90 ;
			ITEMS {'Item 1','Item 2','Item 3'} ;
			VALUE 1  ;
			TOOLTIP 'ListBox Control' ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW

		@ 350,200 COMBOBOX Combo_1 ;
			WIDTH 120 ;
			ITEMS { '1 | One' , '2 | Two' , '3 | Three', '4 | Four' } ;
			VALUE 1 ;
			LISTWIDTH 140 ;
			TOOLTIP 'ComboBox Control' ;
			ON ENTER MsgInfo ( Str(Form_1.Combo_1.value) ) ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW

		@ 400,200 COMBOBOX Combo_2 ;
			WIDTH 120 ;
			ITEMS { '1 | One' , '2 | Two' , '3 | Three', '4 | Four' } ;
			VALUE 1 ;
			TOOLTIP 'ComboBox Control (inverted colors)' ;
			ON ENTER MsgInfo ( Str(Form_1.Combo_2.value) ) ;
			BACKCOLOR YELLOW ;
			FONTCOLOR RED

		@ 10,400 GRID Grid_1 ;
			WIDTH 200 ;
			HEIGHT 140 ;
			HEADERS { 'Last Name','First Name'} ;
			WIDTHS { 100, 100} ;
			ITEMS { { 'Simpson','Homer'} , {'Mulder','Fox'} } ;
			VALUE 1 ;
			TOOLTIP 'Grid Control' ;
			BACKCOLOR RED ;
			FONTCOLOR YELLOW ;
			ON HEADCLICK { {|| MsgInfo('Header 1 Clicked !')} , { || MsgInfo('Header 2 Clicked !')} } ;
			ON DBLCLICK MsgInfo ('DoubleClick!','Grid') 

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return
