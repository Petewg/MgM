/*
* MiniGUI Character InputMask Demo
* (c) 2003 Jacek Kubica <kubica@wssk.wroc.pl>
*/

/*

	InputMask String For Character TextBox

        9	Displays digits
	!       Displays Alphabetic Characters (uppercase) and digits
        A	Displays any Characters
        N	Displays any Characters and digits

*/


#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 200 ;
		TITLE 'InputMask Demo by Jacek Kubica' ;
		MAIN NOMAXIMIZE NOSIZE

		DEFINE MAIN MENU
			POPUP 'Test'
				ITEM 'Get Text_1 Value' ACTION MsgInfo (Form_1.Text_1.Value)
                                ITEM 'Set Text_1 Value s' ACTION Form_1.Text_1.Value := 's'
                                ITEM 'Set Text_1 Value s0' ACTION Form_1.Text_1.Value := 's0'
				ITEM 'Set Text_1 Value s01' ACTION Form_1.Text_1.Value := 's01'
                                ITEM 'Set Text_1 Value s01.' ACTION Form_1.Text_1.Value := 's01.'
                                ITEM 'Set Text_1 Value S01.0' ACTION Form_1.Text_1.Value := 'S01.0'
                                ITEM 'Set Text_1 Value  0.' ACTION Form_1.Text_1.Value := ' 0.'
                                ITEM 'Set Text_3 Value simpson' ACTION Form_1.Text_3.Value := 'simpson'
				ITEM 'Set Text_4 Value homer' ACTION Form_1.Text_4.Value := 'homer'		
				SEPARAToR
				ITEM 'Set Text_1 Focus' ACTION Form_1.Text_1.SetFocus
				ITEM 'Set Text_1 Focus' ACTION _SetFocus('Text_1','Form_1')
			END POPUP
		END MENU

		@ 20,10 LABEL label_1 ;
			VALUE 'Uppercase mask:' ;
			WIDTH 100

		@ 20,120 TEXTBOX text_1 ;
			VALUE 'S00.0' ;
			INPUTMASK '!N9.9';
                        ON ENTER {|| Form_1.text_2.SetFocus}

		@ 20,250 LABEL label_1b ;
			VALUE 'mask !N9.9' ;
			WIDTH 100;
                        FONT 'Arial' SIZE 09 BOLD;
                        Autosize

                @ 50,10 LABEL label_2 ;
			VALUE 'Character mask';
			WIDTH 100

		@ 50,120 TEXTBOX text_2 ;
			VALUE 's00.0' ;
			INPUTMASK 'A99.9' ;
                        ON ENTER {|| Form_1.text_3.SetFocus}

		@ 50,250 LABEL label_1c ;
			VALUE 'mask A99.9' ;
			WIDTH 100;
                        FONT 'Arial' SIZE 09 BOLD

                @ 80,10 LABEL label_3 ;
			VALUE 'First name:' ;
			WIDTH 100

		@ 80,120 TEXTBOX text_3 ;
			VALUE '' ;
                        INPUTMASK '!AAAAAAAAAAAA';
                        ON LOSTFOCUS {|| (Form_1.text_3.Value := ltrim(Form_1.text_3.Value))};
                        ON ENTER {|| (Form_1.text_3.Value := ltrim(Form_1.text_3.Value)),Form_1.text_4.SetFocus}
			

		@ 80,250 LABEL label_1d ;
			VALUE 'mask !AAAAAAAAAAAA' ;
			WIDTH 100;
                        FONT 'Arial' SIZE 09 BOLD;
                        Autosize 

                @ 110,10 LABEL label_4 ;
			VALUE 'Last name:' ;
			WIDTH 100

		@ 110,120 TEXTBOX text_4 ;
			VALUE '' ;
			INPUTMASK '!AAAAAAAAAAAA';
                        ON LOSTFOCUS {|| (Form_1.text_4.Value := ltrim(Form_1.text_4.Value))};
                        ON ENTER {|| (Form_1.text_4.Value := ltrim(Form_1.text_4.Value)),Form_1.text_1.SetFocus}
                         
		@ 110,250 LABEL label_1e ;
			VALUE 'mask !AAAAAAAAAAAA' ;
			WIDTH 100;
                        FONT 'Arial' SIZE 09 BOLD;
                        Autosize                

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
