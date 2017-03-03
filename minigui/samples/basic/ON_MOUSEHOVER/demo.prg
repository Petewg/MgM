/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * MOUSEHOVER Demo was contributed to HMG forum by AGL
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include "minigui.ch"

#define CLR_BLUE1 { 218, 229, 243 }
#define CLR_BLUE2 { 000, 120, 187 }

STATIC lOver := .F.

FUNCTION Main
   LOCAL i, cLblName

   SET FONT TO 'Verdana', 9

   DEFINE WINDOW Win_1 ;
      AT 0 , 0 ;
      WIDTH 230 HEIGHT 380 ;
      BACKCOLOR CLR_BLUE1 ;
      TITLE "MOUSEHOVER Demo" ;
      MAIN NOMAXIMIZE NOSIZE

      ON KEY ESCAPE ACTION ThisWindow.Release()

      FOR i:=1 TO 6

         cLblName := 'Lbl_' + hb_ntos(i)

         @ 30 + 28 * (i - 1),10 LABEL &cLblName ;
           VALUE "Opcion " + hb_ntos(i) ;
           WIDTH 200 HEIGHT 23 ;
           FONTCOLOR WHITE BACKCOLOR CLR_BLUE2 ;
           CENTERALIGN VCENTERALIGN ;
           ACTION MsgInfo( GetProperty(ThisWindow.Name, This.Name, 'Value') ) ;
           ON MOUSEHOVER SelectLabel( ThisWindow.Name, This.Name ) ;
           ON MOUSELEAVE LeaveLabel( ThisWindow.Name, This.Name )

      NEXT

      @ 250,10 LABEL Lbl_7 VALUE "" WIDTH 200 HEIGHT 20 CENTERALIGN TRANSPARENT 

   END WINDOW

   CENTER   WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN Nil


FUNCTION SelectLabel( cForm, cCtrl )

   Win_1.Lbl_7.Value := 'Control ' + cCtrl + " of " + cForm

   CursorHand()

   IF ! lOver

      SetProperty(cForm, cCtrl, 'FontBold', .T.)
      SetProperty(cForm, cCtrl, 'FontSize', 12)
      SetProperty(cForm, cCtrl, 'BackColor', BLUE)

      lOver := .T.

   ENDIF

RETURN Nil


FUNCTION LeaveLabel( cForm, cCtrl )

   Win_1.Lbl_7.Value := 'Form ' + cForm

   SetProperty(cForm, cCtrl, 'FontBold', .F.)
   SetProperty(cForm, cCtrl, 'FontSize', 9)
   SetProperty(cForm, cCtrl, 'BackColor', CLR_BLUE2)

   lOver := .F.

RETURN Nil
