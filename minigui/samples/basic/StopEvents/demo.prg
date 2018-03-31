/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "hmg.ch"


FUNCTION Main

   SET FONT TO 'MS Sans Serif', 10

   DEFINE WINDOW Form_1 ;
      CLIENTAREA 400, 200 ; 
      TITLE "Demo: Enable/Disable Window/Control Events" ;
      ON GOTFOCUS Form_ONGOTFOCUS() ;
      MAIN 

      @ 30,  50 BUTTON Button_1 CAPTION "Click" ACTION MsgInfo ("Hello")
      @ 80,  50 BUTTON Button_2 CAPTION "Minimize" ACTION Form_1.Minimize
      @ 135, 50 TIMEPICKER TimePicker_1 WIDTH 100 ON GOTFOCUS Control_ONGOTFOCUS ()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


PROCEDURE Form_ONGOTFOCUS
   LOCAL i := GetLastActiveControlIndex ()

   DISABLE WINDOW EVENT OF Form_1

   MsgInfo ("ON GOTFOCUS: " + ThisWindow.Name + iif( i > 0, " - Last Control Focused: " + GetControlNameByIndex (i), "" ))

   ENABLE WINDOW EVENT OF Form_1

RETURN


PROCEDURE Control_ONGOTFOCUS
   LOCAL i := GetLastActiveFormIndex ()

   DISABLE WINDOW EVENT OF Form_1                  //   -->   StopWindowEventProcedure ("Form_1", .T.)
   DISABLE CONTROL EVENT TimePicker_1 OF Form_1    //   -->   StopControlEventProcedure ("TimePicker_1", "Form_1", .T.)

   MsgInfo ("ON GOTFOCUS: " + This.Name + iif( i > 0, " - Last Form Focused: " + GetFormNameByIndex (i), "" ))

   ENABLE CONTROL EVENT TimePicker_1 OF Form_1     //   -->   StopControlEventProcedure ("TimePicker_1", "Form_1", .F.)
   ENABLE WINDOW EVENT OF Form_1                   //   -->   StopWindowEventProcedure ("Form_1", .F.)

RETURN
