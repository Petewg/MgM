#include <hmg.ch>

#define CLR_LIGHTBLUE  { 165, 175, 245 }

FUNCTION Main()

   SET CENTURY ON

   DEFINE WINDOW Win_1 ;
      AT 0, 0 WIDTH 600 HEIGHT 450 ;
      BACKCOLOR BLUE ;
      TITLE "Get's WAIT WINDOW Demo" ;
      MAIN

      ON KEY ESCAPE ACTION ThisWindow.Release ()

      @ 030, 150 BUTTON Button_1 CAPTION 'WAIT/CLEAR WINDOW "Auto-Release" NOWAIT' ACTION Test1() WIDTH 310 DEFAULT
      @ 070, 150 BUTTON Button_2 CAPTION 'WAIT WINDOW   "Start Processing" NOWAIT' ACTION Test2() WIDTH 310
      @ 100, 150 BUTTON Button_3 CAPTION 'WAIT CLEAR     "Stop Processing"       ' ACTION Test3() WIDTH 310

      DEFINE STATUSBAR FONT "Courier New" SIZE 9
         STATUSDATE FONTCOLOR BLACK
         STATUSITEM "Press [Esc] to exit" FONTCOLOR BLACK CENTERALIGN ACTION ThisWindow.Release() RAISED WIDTH 430
         CLOCK
      END STATUSBAR

   END WINDOW

   DEFINE WINDOW Win_Wait ;
      AT 0, 0 WIDTH 400 HEIGHT 64 ;
      TOPMOST NOSHOW ;
      NOCAPTION NOSYSMENU ;
      NOAUTORELEASE ;
      BACKCOLOR CLR_LIGHTBLUE

      @ 16, 10 LABEL L1 VALUE 'Please wait...' WIDTH 380 HEIGHT 24 FONT 'Arial' SIZE 14 ;
         FONTCOLOR BLUE BOLD BACKCOLOR CLR_LIGHTBLUE CENTERALIGN

   END WINDOW

   CENTER WINDOW Win_1
   CENTER WINDOW Win_Wait
   ACTIVATE WINDOW Win_Wait, Win_1

RETURN NIL


FUNCTION Test1()

   LOCAL i

   Win_1.Button_2.Enabled := .F.
   Win_1.Button_3.Enabled := .F.
   Win_Wait.Show

   SetCursorSystem( IDC_WAIT )

   FOR i = 10 TO 1 STEP -1
      Win_Wait.L1.Value := 'Please wait for ' + hb_ntos( i ) + " second" + iif( i == 1, "", "s" )
      hb_idleSleep( 0.5 )
   NEXT

   SetCursorSystem( IDC_ARROW )

   Win_Wait.Hide
   Win_1.Button_2.Enabled := .T.
   Win_1.Button_3.Enabled := .T.

RETURN NIL


FUNCTION Test2()

   Win_1.Button_1.Enabled := .F.
   Win_Wait.Show
   Win_Wait.L1.Value := 'Processing...'

RETURN NIL


FUNCTION Test3()

   Win_1.Button_1.Enabled := .T.
   Win_Wait.Hide

RETURN NIL
