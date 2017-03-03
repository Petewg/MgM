/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Function Main
local nWidth := 340 + GetBorderWidth() - iif(IsSeven(), 2, 0)
local nHeight := 127 + GetTitleHeight() + GetBorderHeight() - iif(IsSeven(), 2, 0)

	DEFINE WINDOW cue ;
		AT 0,0 ;
		WIDTH nWidth ;
		HEIGHT nHeight ;
		TITLE "TextBox CueBanner Demo" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		FONT "Tahoma" SIZE 8

		define label lbl_1
			row 10
			col 10
			value "Name:"
			autosize .t.
		end label
		define textbox name
			row 26
			col 10
			width 318
			height 21
                        cuebanner "Enter your full name here"
		end textbox
		define frame frm_1
			row 54
			col 10
			width 318
			height 64
			caption "Cue banner"
		end frame
		define label lbl_2
			row 70
			col 22
			value "Cue text:"
			autosize .t.
		end label
		define textbox text
			row 86
			col 22
			width 167
			height 21
		end textbox
		define button btn_1
			row 86
			col 198
			width 58
			height 21
			caption "Set"
			action btnSet_click()
		end button
		define button btn_2
			row 86
			col 262
			width 56
			height 21
			caption "Clear"
			action cue.name.cuebanner := " "
		end button

	END WINDOW

	cue.text.setfocus()

	cue.center
	cue.activate
Return nil


function btnSet_click()
   local ctext := alltrim( cue.text.value )
   if empty(ctext)
      MsgAlert("Please specify the cue text.", "Text CueBanner demo")
   else
      cue.name.cuebanner := ctext
   endif
return nil
