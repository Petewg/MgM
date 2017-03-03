/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2013 Grigory Filatov <gfilatov@inbox.ru>
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
				MENUITEM 'Disable Page 3' ACTION DisableTab( 3 )
				MENUITEM 'Enable Page 3' ACTION EnableTab( 3 )
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

			@  60,20 textbox txt_1 value '1-Uno'
			@  90,20 textbox txt_2 value '2-Dos'
			@ 120,20 textbox txt_3 value '3-Tres' 

			END PAGE

			PAGE 'Page &2'

			@ 60,60 textbox txt_a value 'A-Uno'
			@ 90,60 textbox txt_b value 'B-Dos'  

			@ 120,60 COMBOBOX combo_1 ITEMS {'1-Uno','2-Dos','3-Tres'} VALUE 1

			END PAGE

			PAGE 'Page &3'

			@ 60,100 textbox txt_c value 'C-Uno'
			@ 90,100 textbox txt_d value 'D-Dos'  

			@ 120,100 SPINNER spinner_1 RANGE 0,10 VALUE 5

			@ 150,100 FRAME Frame_2 WIDTH 120 HEIGHT 110 CAPTION "Page 3"

			DEFINE RADIOGROUP R1
				ROW	170
				COL	120
				OPTIONS	{ 'Uno','Dos','Tres' }
				VALUE	1
				WIDTH   80
			END RADIOGROUP

			END PAGE

		END TAB

	END WINDOW

	DisableTab( 3 )

	Form_1.Center

	Form_1.Activate

Return Nil


Procedure SizeTest()

	Form_1.Tab_1.Width := Form_1.Width - 40
	Form_1.Tab_1.Height := Form_1.Height - 80

Return

/*
Static Function DisableTab( nPage )
Local y, w, z, cPageCaption

   y := GetControlIndex ( 'Tab_1', 'Form_1' )
   FOR w := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] )
      IF ValType ( _HMG_aControlPageMap [y] [nPage] [w] ) <> "A"
         DisableWindow ( _HMG_aControlPageMap [y] [nPage] [w] )
      ELSE
         FOR z := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] [w] )
            DisableWindow ( _HMG_aControlPageMap [y] [nPage] [w] [z] )
         NEXT z
      ENDIF
   NEXT w

   cPageCaption := Form_1.Tab_1.Caption( nPage )
   IF Left( cPageCaption, 1 ) != '*'
      Form_1.Tab_1.Caption( nPage ) := '*' + cPageCaption
   ENDIF

Return Nil
*/

Static Function DisableTab( nPage, cTabName, cParentWin )
	Local y, w, z, cPageCaption
	
	hb_Default( @cParentWin, "Form_1" )
	hb_Default( @cTabName, "Tab_1" )
	
   cPageCaption := GetProperty( cParentWin, cTabName, 'Caption', nPage)
	IF  (n := At( "(Off)", cPageCaption )) > 0
		MsgExclamation("Already disabled!")
		RETURN NIL
	ENDIF

   y := GetControlIndex ( cTabName, cParentWin )
   FOR w := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] )
      IF ValType ( _HMG_aControlPageMap [y] [nPage] [w] ) <> "A"
         DisableWindow ( _HMG_aControlPageMap [y] [nPage] [w] )
      ELSE
         FOR z := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] [w] )
            DisableWindow ( _HMG_aControlPageMap [y] [nPage] [w] [z] )
         NEXT z
      ENDIF
   NEXT w

	// cPageCaption := Form_1.Tab_1.Caption( nPage )
   // IF Left( cPageCaption, 1 ) != '*'
      // Form_1.Tab_1.Caption( nPage ) := '*' + cPageCaption
		SetProperty( cParentWin, cTabName, 'Caption', nPage, cPageCaption + " (Off) " )
   // ENDIF

	RETURN NIL

Static Function EnableTab( nPage )

Local y, w, z, cPageCaption, n

   cPageCaption := Form_1.Tab_1.Caption( nPage )
   
	IF  (n := At( "(Off)", cPageCaption )) > 0
		Form_1.Tab_1.Caption( nPage ) := SubStr( cPageCaption, 1, n-1 )
	ELSE
		MsgExclamation("Page is not disabled!")
		RETURN NIL
   ENDIF
	
   y := GetControlIndex ( 'Tab_1', 'Form_1' )
   FOR w := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] )
      IF ValType ( _HMG_aControlPageMap [y] [nPage] [w] ) <> "A"
         EnableWindow ( _HMG_aControlPageMap [y] [nPage] [w] )
      ELSE
         FOR z := 1 TO Len ( _HMG_aControlPageMap [y] [nPage] [w] )
            EnableWindow ( _HMG_aControlPageMap [y] [nPage] [w] [z] )
         NEXT z
      ENDIF
   NEXT w
	
Return Nil
