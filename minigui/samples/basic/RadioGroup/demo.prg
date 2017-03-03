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
		TITLE 'Harbour MiniGUI Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE MAIN MENU 
			POPUP '&Test'
				ITEM 'Set RadioGroup 1a Item 1 Disable'	ACTION Form_1.Radio_1a.Enabled( 1 ) := .F.
				ITEM 'Get RadioGroup 1a Item 1 Enable Property'	ACTION MsgInfo ( if(Form_1.Radio_1a.Enabled( 1 ), 'Enabled', 'Disabled') ,'Item 1')
				ITEM 'Set RadioGroup 1a Item 1 Enable'	ACTION Form_1.Radio_1a.Enabled( 1 ) := .T.
                                SEPARATOR
				ITEM 'Set RadioGroup 1a Item 2 Disable'	ACTION SetProperty ( 'Form_1' , 'Radio_1a' , 'Enabled' , 2 , .F. )
				ITEM 'Get RadioGroup 1a Item 2 Enable Property'	ACTION MsgInfo ( if(GetProperty ( 'Form_1' , 'Radio_1a' , 'Enabled' , 2 ), 'Enabled', 'Disabled') ,'Item 2')
				ITEM 'Set RadioGroup 1a Item 2 Enable'	ACTION SetProperty ( 'Form_1' , 'Radio_1a' , 'Enabled' , 2 , .T. )
                                SEPARATOR
				ITEM 'Get RadioGroup 1a ReadOnly Property'	ACTION MsgInfo ( HB_ValToExp ( Form_1.Radio_1a.ReadOnly ) )
			END POPUP
			POPUP 'M&isc'
				ITEM 'Set RadioGroup 1 Caption 1 Property'  ACTION Form_1.Radio_1.Caption(1) := 'New Caption'
				ITEM 'Get RadioGroup 1 Caption 1 Property'  ACTION MsgInfo ( Form_1.Radio_1.Caption (1) ,'Radio_1')
                          	ITEM 'Set RadioGroup 1a Caption 1 Property' ACTION Form_1.Radio_1a.Caption(1) := 'New Caption'
				ITEM 'Get RadioGroup 1a Caption 1 Property' ACTION MsgInfo ( Form_1.Radio_1a.Caption (1) ,'Radio_1')
				ITEM 'Set RadioGroup 1 Value Property'	    ACTION Form_1.Radio_1.Value := max(Val(InputBox('Radio Value','')),0)
				ITEM 'Get RadioGroup 1 Value Property'	    ACTION MsgInfo ( Str(Form_1.Radio_1.Value) ,'Radio_1')
				ITEM 'Set RadioGroup 1 Row Property'	    ACTION Form_1.Radio_1.Row := max(Val(InputBox('Enter Row','')),0)
				ITEM 'Set RadioGroup 1 Col Property'	    ACTION Form_1.Radio_1.Col := max(Val(InputBox('Enter Col','')),0)
                        	ITEM 'Set RadioGroup 1a Row Property'	    ACTION Form_1.Radio_1a.Row := max(Val(InputBox('Enter Row','')),0)
				ITEM 'Set RadioGroup 1a Col Property'	    ACTION Form_1.Radio_1a.Col := max(Val(InputBox('Enter Col','')),0)
                                SEPARATOR
                                ITEM 'Set RadioGroup 2 Caption Property'    ACTION ( Form_1.Radio_2.Caption(1) := 'New Caption' )
				ITEM 'Get RadioGroup 2 Caption Property'    ACTION MsgInfo ( Form_1.Radio_2.Caption (1) ,'Radio_2')
				ITEM 'Set RadioGroup 2 Value Property'	    ACTION Form_1.Radio_2.Value := Val(InputBox('Radio Value',''))
				ITEM 'Get RadioGroup 2 Value Property'	    ACTION MsgInfo ( Str(Form_1.Radio_2.Value) ,'Radio_2')
				ITEM 'Set RadioGroup 2 Row Property'	    ACTION Form_1.Radio_2.Row := max(Val(InputBox('Enter Row',str(Form_1.Radio_2.Row))),0)
				ITEM 'Set RadioGroup 2 Col Property'	    ACTION Form_1.Radio_2.Col := max(Val(InputBox('Enter Col',str(Form_1.Radio_2.Col))),0)
			END POPUP
		END MENU


		@ 10,10 RADIOGROUP Radio_1 ;
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
			VALUE 1 ;
			WIDTH 100 ;
			TOOLTIP 'RadioGroup 1 leftjustify vertical(default)';
                        LEFTJUSTIFY 

           	
                @ 10,200 RADIOGROUP Radio_1a ;
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
			VALUE 1 ;
			WIDTH 100 ;
			TOOLTIP 'RadioGroup 1a rightjustify (default) vertical(default)'


		@ 10,300 RADIOGROUP Radio_2 ;
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
			VALUE 1 ;
			WIDTH 50 ;
			SPACING 10 ;
			TOOLTIP 'RadioGroup 2 horizontal rightjustify (default)' HORIZONTAL

// altsyntax test
                        	DEFINE RADIOGROUP Radio_3
					ROW	150
					COL	10
					OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
					VALUE 1 
					WIDTH 100 
					SPACING 35
					TOOLTIP 'RadioGroup 3 leftjustify spacing 10 vertical(default)'
				        LEFTJUSTIFY .t.
				END RADIOGROUP



	                    	DEFINE RADIOGROUP Radio_2a
					ROW	150
					COL	300
					OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
					VALUE 1 
					WIDTH 50
                                        SPACING 25  
					TOOLTIP 'RadioGroup 3 leftjustify horizontal'
                                        HORIZONTAL  .t.
                                        LEFTJUSTIFY .t.
				 END RADIOGROUP

                            

                                 DEFINE RADIOGROUP Radio_4b
					ROW	300
					COL	10
					OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
					VALUE 1 
					WIDTH 100
                                        SPACING 25  
					TOOLTIP 'RadioGroup 3a horizontal'
                                        HORIZONTAL  .t.
				 END RADIOGROUP

                                 DEFINE RADIOGROUP Radio_4c
					ROW	330
					COL	10
					OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
					VALUE 1 
					WIDTH 100
                                        SPACING 25  
					TOOLTIP 'RadioGroup 4c leftjustify horizontal'
                                        HORIZONTAL  .t.
                                        LEFTJUSTIFY .t.
				 END RADIOGROUP


	END WINDOW

	Form_1.Center

	Form_1.Activate

Return Nil

#ifdef __XHARBOUR__

Function HB_ValToExp ( lArray )
Local RetVal := '{' , i

	For i := 1 To Len ( lArray )

		If lArray [i]
			RetVal := RetVal + ' ".T." '
		Else
			RetVal := RetVal + ' ".F." '
		EndIf

	Next i

Return RetVal + '}'

#endif