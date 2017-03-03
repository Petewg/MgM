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
			POPUP 'M&isc'
				ITEM 'Set RadioGroup 1 ReadOnly Property To {.T.,.T.,.T.,.T.}'	ACTION Form_1.Radio_1.ReadOnly := { .T. , .T. , .T. , .T. }
				ITEM 'Set RadioGroup 1 ReadOnly Property To {.F.,.F.,.F.,.F.}'	ACTION Form_1.Radio_1.ReadOnly := { .F. , .F. , .F. , .F. }
				ITEM 'Set RadioGroup 1 ReadOnly Property To {.T.,.F.,.T.,.F.}'	ACTION Form_1.Radio_1.ReadOnly := { .T. , .F. , .T. , .F. }
				ITEM 'Set RadioGroup 1 ReadOnly Property To {.F.,.T.,.F.,.T.}'	ACTION Form_1.Radio_1.ReadOnly := { .F. , .T. , .F. , .T. }
				SEPARATOR
				ITEM 'Set RadioGroup 2 ReadOnly Property To {.T.,.T.,.T.,.T.}'	ACTION Form_1.Radio_2.ReadOnly := { .T. , .T. , .T. , .T. }
				ITEM 'Set RadioGroup 2 ReadOnly Property To {.F.,.F.,.F.,.F.}'	ACTION Form_1.Radio_2.ReadOnly := { .F. , .F. , .F. , .F. }
				ITEM 'Set RadioGroup 2 ReadOnly Property To {.T.,.F.,.T.,.F.}'	ACTION Form_1.Radio_2.ReadOnly := { .T. , .F. , .T. , .F. }
				ITEM 'Set RadioGroup 2 ReadOnly Property To {.F.,.T.,.F.,.T.}'	ACTION Form_1.Radio_2.ReadOnly := { .F. , .T. , .F. , .T. }
				SEPARATOR
				ITEM 'Get RadioGroup 1 ReadOnly Property'	ACTION MsgInfo ( HB_ValToExp ( Form_1.Radio_1.ReadOnly ) )
				ITEM 'Get RadioGroup 2 ReadOnly Property'	ACTION MsgInfo ( HB_ValToExp ( Form_1.Radio_2.ReadOnly ) )
			END POPUP
		END MENU

		@ 10,10 RADIOGROUP Radio_1 ;
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
			VALUE 1 ;
			WIDTH 100 ;
			TOOLTIP 'RadioGroup 1' ;
			READONLY { .T. , .F. , .T. , .F. }

		DEFINE RADIOGROUP Radio_2 
			ROW 10
			COL 150
			OPTIONS { 'One' , 'Two' , 'Three', 'Four' } 
			VALUE 1 
			WIDTH 100 
			TOOLTIP 'RadioGroup 2' 
			READONLY { .F. , .T. , .F. , .T. }
		END RADIOGROUP

		@ 150,10 DATEPICKER Date_1 ;
		VALUE CTOD('  / /  ') ;
		TOOLTIP 'DatePicker Control' 

	END WINDOW

	Form_1.Date_1.SetFocus

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