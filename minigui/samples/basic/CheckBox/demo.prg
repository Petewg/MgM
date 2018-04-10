/*
 HMG Checkbox Demo
 (c) 2010 Roberto Lopez
*/

#include "minigui.ch"

Function Main

	Set Font To "Tahoma", 9

	Define Window Win1			;
		Row	10			;
		Col	10			;
		Width	400			;
		Height	300			;
		Title	'HMG Checkbox Demo'	;
		WindowType MAIN

		Define Label Label1
			Row 10
			Col 10
			Width 300
			Value 'This is for status!'
			BackColor {200,200,200}
			Alignment Center
			Alignment VCenter
		End Label

		Define CheckBox Check1
			Row		40
			Col		10
			Value		.F.
			Caption		'Simple CheckBox'
			Width		120
			OnChange MsgInfo( "CheckBox 1 Value is Changed!" )
		End CheckBox

		Define CheckBox Check2
			Row		70
			Col		10
			Width		280
			Value		.F.
			FontName	"Arial"
			FontSize	12
			FontBold	.t.
			FontItalic	.t.
			FontUnderline	.t.
			FontStrikeOut	.t.
			Caption		'CheckBox with Font Properties'
			OnChange MsgInfo( "CheckBox 2 Value is Changed!" )
		End CheckBox

		Define CheckBox Check3
			Row		120
			Col		10
			Width		250
			Value		.F.
			Caption		'CheckBox with OnGot/LostFocus Events'
			OnGotFocus { || Win1.Label1.Value := "CheckBox GotFocus!" }  
			OnLostFocus { || Win1.Label1.Value := "CheckBox LostFocus!" }  
		End CheckBox

		Define Button Button1
			Row	150
			Col	40
			Width	140
			Height	28
			Caption 'Change Event Block!'		
			OnClick Win1.Check1.OnChange := { || MsgInfo( "Event Block of 'On Change' event of Checkbox 1 is Changed dynamically!" ) }
		End Button

		Define Button Button2
			Row	180
			Col	40
			Width	140
			Height	28
			Caption 'Win1.Check1.Value'			
			OnClick MsgInfo( Win1.Check1.value ) 
		End Button

	End Window

	Center Window Win1
	Activate Window Win1

Return Nil
