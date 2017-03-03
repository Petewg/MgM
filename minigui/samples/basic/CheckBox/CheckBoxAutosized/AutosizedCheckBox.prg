
#include "hmg.ch"

Function Main

	Set Font To "Tahoma", 9

	Define Window Win1			;
		Row	10			;
		Col	10			;
		Width	340			;
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
			AUTOSIZE .F.
			Caption		'AUTOSIZE .F. CheckBox --------------------------'
			Width		120
			OnChange MsgInfo( "CheckBox_1 Value Changed!" )
		End CheckBox
				
		@ 70, 10 CHECKBOX Check2 ;
			CAPTION		'AUTOSIZE .T. CheckBox --------------------------' ;
			WIDTH		120 HEIGHT 30 ;
			VALUE		.F. ;
			AUTOSIZE  ;
			ON CHANGE MsgInfo( "CheckBox_2 Value Changed!" )

			
	End Window

	Center Window Win1
	Activate Window Win1

Return Nil
