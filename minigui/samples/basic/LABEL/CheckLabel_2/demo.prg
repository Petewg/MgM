/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2012 Janusz Pora <januszpora@onet.eu>
 *
 * Revised by Grigory Filatov, 2017
*/

#include "minigui.ch"

Function Main
Local lChecked

   SET FONT TO 'MS Shell Dlg', 8

   DEFINE WINDOW Form_Main ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI Check Label Demo' ;
      MAIN

      @ 40,50 BUTTON Btn1 ;
         CAPTION "Check Label_2" ;
         WIDTH 120 DEFAULT ;
         ACTION Form_Main.Label_2.Checked := .T.

      @ 80,50 BUTTON Btn2 ;
         CAPTION "Uncheck Label_2" ;
         WIDTH 120 ;
         ACTION Form_Main.Label_2.Checked := .F.

      @ 150,30 CHECKLABEL Label_1 ;
         WIDTH 160 HEIGHT 24 ;
         VALUE 'Check Label_1 standard' ;
         CHECKED ;
         ON MOUSEHOVER Rc_Cursor( "MINIGUI_FINGER" ) ;
         ONCLICK ( lChecked := Form_Main.Label_1.Checked, Form_Main.Label_1.Checked := .NOT. lChecked )

      DEFINE CHECKLABEL Label_2
	ROW	200
	COL	30
	WIDTH	190
	HEIGHT	21
	VALUE	'Left Check Label_2 with images'
	LEFTCHECK .T.
	TRANSPARENT .T.
	IMAGE { 'CheckIt', 'UnCheck' }
        TOOLTIP 'CheckLabel Control'
	FONTCOLOR NAVY
	ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), Form_Main.Label_2.FontColor := BLUE, Form_Main.Label_2.Refresh )
	ON MOUSELEAVE ( Form_Main.Label_2.FontColor := NAVY, Form_Main.Label_2.Refresh )
        ON CLICK ( lChecked := Form_Main.Label_2.Checked, Form_Main.Label_2.Checked := .NOT. lChecked )
      END CHECKLABEL

      @ 200,300 CHECKBOX Check_1 CAPTION ' CheckBox Check_1 standard' ;
	WIDTH 180 ;
	HEIGHT 21 ;
	VALUE .F. ;
	TOOLTIP 'CheckBox Control' ;
	FONTCOLOR BLUE

      DEFINE CHECKLABEL Label_3
	ROW	250
	COL	30
	WIDTH	100
	HEIGHT	18
	VALUE	'One'
	LEFTCHECK .T.
	TRANSPARENT .T.
	CHECKED .T.
	IMAGE { 'radio1.bmp', 'radio2.bmp' }
        TOOLTIP 'CheckLabel Radio Control'
	FONTCOLOR NAVY
	ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), Form_Main.Label_3.FontColor := BLUE, Form_Main.Label_3.Refresh )
	ON MOUSELEAVE ( Form_Main.Label_3.FontColor := NAVY, Form_Main.Label_3.Refresh )
        ON CLICK RadioItem_Click( This.Name )
      END CHECKLABEL

      DEFINE CHECKLABEL Label_4
	ROW	275
	COL	30
	WIDTH	100
	HEIGHT	18
	VALUE	'Two'
	LEFTCHECK .T.
	TRANSPARENT .T.
	IMAGE { 'radio1.bmp', 'radio2.bmp' }
        TOOLTIP 'CheckLabel Radio Control'
	FONTCOLOR NAVY
	ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), Form_Main.Label_4.FontColor := BLUE, Form_Main.Label_4.Refresh )
	ON MOUSELEAVE ( Form_Main.Label_4.FontColor := NAVY, Form_Main.Label_4.Refresh )
        ON CLICK RadioItem_Click( This.Name )
      END CHECKLABEL

      DEFINE CHECKLABEL Label_5
	ROW	300
	COL	30
	WIDTH	100
	HEIGHT	18
	VALUE	'Three'
	LEFTCHECK .T.
	TRANSPARENT .T.
	IMAGE { 'radio1.bmp', 'radio2.bmp' }
        TOOLTIP 'CheckLabel Radio Control'
	FONTCOLOR NAVY
	ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), Form_Main.Label_5.FontColor := BLUE, Form_Main.Label_5.Refresh )
	ON MOUSELEAVE ( Form_Main.Label_5.FontColor := NAVY, Form_Main.Label_5.Refresh )
        ON CLICK RadioItem_Click( This.Name )
      END CHECKLABEL

      DEFINE CHECKLABEL Label_6
	ROW	325
	COL	30
	WIDTH	100
	HEIGHT	18
	VALUE	'Four'
	LEFTCHECK .T.
	TRANSPARENT .T.
	IMAGE { 'radio1.bmp', 'radio2.bmp' }
        TOOLTIP 'CheckLabel Radio Control'
	FONTCOLOR NAVY
	ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), Form_Main.Label_6.FontColor := BLUE, Form_Main.Label_6.Refresh )
	ON MOUSELEAVE ( Form_Main.Label_6.FontColor := NAVY, Form_Main.Label_6.Refresh )
        ON CLICK RadioItem_Click( This.Name )
      END CHECKLABEL

      DEFINE RADIOGROUP Radio_1
	ROW 246
	COL 300
	OPTIONS { 'One' , 'Two' , 'Three', 'Four' }
	VALUE 1
	WIDTH 100
	TOOLTIP 'Radio Group Control'
      END RADIOGROUP

      @ 360,30 BUTTON Btn3 ;
         CAPTION "Get CheckLabel Radio Value" ;
         WIDTH 160 ;
         ACTION MsgInfo ( GetChkLabelRadioValue() ,'CheckLabel Group')

      @ 360,300 BUTTON Btn4 ;
         CAPTION "Get Radio Group Value" ;
         WIDTH 160 ;
         ACTION MsgInfo ( Form_Main.Radio_1.Value ,'Radio Group')

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

Return Nil


PROCEDURE RadioItem_Click( CheckName )

   SetProperty( 'Form_Main', CheckName, 'Checked', .T. )
   InkeyGUI(250)
   Form_Main.Label_3.Checked := .F.
   Form_Main.Label_4.Checked := .F.
   Form_Main.Label_5.Checked := .F.
   Form_Main.Label_6.Checked := .F.
   SetProperty( 'Form_Main', CheckName, 'Checked', .T. )

RETURN


FUNCTION GetChkLabelRadioValue()
Local nValue

   DO CASE
	CASE Form_Main.Label_3.Checked == .T.
		nValue := 1
	CASE Form_Main.Label_4.Checked == .T.
		nValue := 2
	CASE Form_Main.Label_5.Checked == .T.
		nValue := 3
	CASE Form_Main.Label_6.Checked == .T.
		nValue := 4
	OTHERWISE
		nValue := 0
   END CASE

RETURN nValue
