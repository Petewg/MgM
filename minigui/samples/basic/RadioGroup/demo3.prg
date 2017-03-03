/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo 3' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10

		DEFINE MAIN MENU
			POPUP '&RadioGroup Test'
				ITEM 'Set RadioGroup Value to ZERO'	      ACTION Form_1.Radio_1.Value := 0
				ITEM 'Set RadioGroup Value to Out of Bound'   ACTION Form_1.Radio_1.Value := 5
				ITEM 'Set RadioGroup User Value'              ACTION Form_1.Radio_1.Value := max(Val(InputBox('Radio Value','Input Value',Ltrim(Str(Form_1.Radio_1.Value)))),0)
                                SEPARATOR
				ITEM 'Get RadioGroup Value Property'   	      ACTION MsgInfo ( Str(Form_1.Radio_1.Value) ,'Radio_1')
			END POPUP
		END MENU

		@ 10,10 RADIOGROUP Radio_1 ;
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
			VALUE 0 ;
			WIDTH 100

	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil

