/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2013-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

FUNCTION Main

 DEFINE WINDOW Form_1 ;
  AT 0,0 ;
  WIDTH 640 HEIGHT 480 ;
  TITLE 'Harbour MiniGUI Demo' ;
  MAIN ;
  ON SIZE SizeTest()

  DEFINE MAIN MENU
   DEFINE POPUP 'Test'
    MENUITEM 'Disable Page 1' ACTION Form_1.Tab_1.Enabled( 1 ) := .F.
    MENUITEM 'Enable Page 1' ACTION Form_1.Tab_1.Enabled( 1 ) := .T.
    SEPARATOR
    MENUITEM 'Disable Page 2' ACTION Form_1.Tab_1.Enabled( 2 ) := .F.
    MENUITEM 'Enable Page 2' ACTION Form_1.Tab_1.Enabled( 2 ) := .T.
    SEPARATOR
    MENUITEM 'Disable Page 3' ACTION Form_1.Tab_1.Enabled( 3 ) := .F.
    MENUITEM 'Enable Page 3' ACTION Form_1.Tab_1.Enabled( 3 ) := .T.
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
    ROW 170
    COL 120
    OPTIONS { 'Uno','Dos','Tres' }
    VALUE 1
    WIDTH   80
   END RADIOGROUP

   END PAGE

  END TAB

 END WINDOW

 SetProperty( 'Form_1', 'Tab_1', 'Enabled', 1, .F. )

 Form_1.Center

 Form_1.Activate

RETURN Nil


PROCEDURE SizeTest()

 Form_1.Tab_1.Width := Form_1.Width - 40
 Form_1.Tab_1.Height := Form_1.Height - 80

RETURN
