/*
 HMG RadioGroup Demo
 (c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include "minigui.ch"

Function Main

	Define Window Win1			;	
		Row	10			;
		Col	10			;
		Width	400			;	
		Height	400			;	
		Title	'HMG RadioGroup Demo'	;
		WindowType MAIN			;
		On Init	Win1.Center()
		
		Define main menu
			define popup "&Properties"
				MenuItem "Change value" action Win1.RadioGroup2.Value := 3
				MenuItem "Get Value" action Msginfo(Win1.RadioGroup2.Value)
				Separator
				MenuItem "Change options" action SetRadioOptions('RadioGroup2','Win1',{"New Item 1","New Item 2","New Item 3","New Item 4"})
				MenuItem "Change Spacing" action ChangeSpacing('RadioGroup2','Win1',32)
				MenuItem "Set horizontal orientation" action sethorizontal('RadioGroup2','Win1')
			End popup
		End Menu
      
		@ 40,10 RadioGroup RadioGroup1;   		      
			Options {"New 1","New 2","New 3"}; 
			Width	60;
			Spacing 20;
			Value	2;
			Horizontal;
			Tooltip	'Horizontal Radiogroup';
			on change MsgInfo("OOP Radiogroup 1 Value Changed!")

		@ 110, 10 RadioGroup Radiogroup2;
			Options {"Option 1","Option 2","Option 3","Option 4"} ; 
			Width 240;
			Tooltip	'Vertical Radiogroup' ;
			on change {||MsgInfo("OOP Radiogroup 2 Value Changed!")}

	End Window

	Activate Window Win1

Return Nil


Procedure SetRadioOptions(control,form,aoptions)
local i:=getcontrolindex(control,form), n
local noptions:=len(_HMG_aControlCaption [i])

if len(aoptions) >= noptions
      for n := 1 to noptions
         Win1.Radiogroup2.Caption(n) := aoptions[n]
      next n
endif

Return


Procedure ChangeSpacing(control,form,nspace)
local i:=getcontrolindex(control,form)
local Row:=_HMG_aControlRow [i]
local Col:=_HMG_aControlCol [i]
local Width:=_HMG_aControlWidth [i]
local Height:=_HMG_aControlHeight [i]

      _HMG_aControlSpacing [i] := nspace

      _SetControlSizePos ( Control, Form, row, col, width, height )

      domethod(Form, Control, 'hide')
      domethod(Form, Control, 'show')

Return


Procedure sethorizontal(control,form)
local i:=getcontrolindex(control,form)
local aoptions:=_HMG_aControlCaption [i]
local nvalue:=_HMG_aControlValue [i]

      domethod(Form, Control, 'release')
      do events

      @ 110, 10 RadioGroup Radiogroup2 of &form ;
		Options aoptions ;
		Horizontal;
		Width 80;
		Spacing 12;
		Value nvalue;
		Tooltip	'Horizontal Radiogroup' ;
		on change {||MsgInfo("OOP Radiogroup 2 Value Changed!")}

Return
