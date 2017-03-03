/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2012 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo' ;
		MAIN ;
		ON SIZE SizeTest()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Disable Page 1' ACTION DisableTab( 1 )
				MENUITEM 'Enable Page 1' ACTION EnableTab( 1 )
				SEPARATOR
				MENUITEM 'Disable Page 2' ACTION DisableTab( 2 )
				MENUITEM 'Enable Page 2' ACTION EnableTab( 2 )
				SEPARATOR
				MENUITEM "E&xit" ACTION Form_1.Release()
			END POPUP
		END MENU

		DEFINE TAB Tab_1 ;
			AT 10,10 ;
			WIDTH 600 ;
			HEIGHT 400 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control' 

			PAGE 'Page &1'

			@  60,10 textbox txt_1 value '1-Uno'
			@  90,10 textbox txt_2 value '2-Dos'
			@ 120,10 textbox txt_3 value '3-Tres' 

			END PAGE

			PAGE 'Page &2'

			@ 60,100 textbox txt_a value 'A-Uno'
			@ 90,100 textbox txt_b value 'B-Dos'  

			END PAGE

			PAGE 'Page &3'

			@ 60,100 textbox txt_c value 'C-Uno'
			@ 90,100 textbox txt_d value 'D-Dos'  

			END PAGE

		END TAB

	END WINDOW

        Form_1.Tab_1.Cargo := { {"txt_1","txt_2","txt_3"}, ;
				{"txt_a","txt_b"}, ;
				{"txt_c","txt_d"} }

	Form_1.Center

	Form_1.Activate

Return Nil


Procedure SizeTest()

	Form_1.Tab_1.Width := Form_1.Width - 40
	Form_1.Tab_1.Height := Form_1.Height - 80

Return


Static Function DisableTab( nPage )
Local aControls, i

   aControls := Form_1.Tab_1.Cargo  // array of child control's names

   For i:=1 To Len(aControls [nPage])
       SetProperty( "Form_1", aControls [nPage] [i], "Enabled", .f. )
   Next

   Form_1.Tab_1.Value := nPage

Return Nil


Static Function EnableTab( nPage )
Local aControls, i

   aControls := Form_1.Tab_1.Cargo

   For i:=1 To Len(aControls [nPage])
       SetProperty( "Form_1", aControls [nPage] [i], "Enabled", .t. )
   Next

   Form_1.Tab_1.Value := nPage

Return Nil
