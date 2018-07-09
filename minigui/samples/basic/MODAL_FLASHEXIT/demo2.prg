/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"

**************
FUNCTION MAIN
**************

   DEFINE WINDOW wMain AT 0, 0 WIDTH 400 HEIGHT 300 TITLE "Main" MAIN

   DEFINE BUTTONEX ButtonEX_1
      ROW 220
      COL 80
      WIDTH 100
      HEIGHT 30
      CAPTION "Modal"
      ACTION MODAL()
   END BUTTONEX

   DEFINE BUTTONEX ButtonEX_2
      ROW 220
      COL 220
      WIDTH 100
      HEIGHT 30
      CAPTION "&Quit"
      ACTION ThisWindow.release
   END BUTTONEX

   END WINDOW

   wMain.center
   wMain.activate

RETURN NIL

************************
STATIC FUNCTION MODAL()
************************

   DEFINE WINDOW wModal AT 0, 0 WIDTH 200 HEIGHT 200 TITLE "Modal" MODAL ;
      FLASHEXIT

   DEFINE BUTTONEX ButtonEX_1
      ROW 20
      COL 40
      WIDTH 100
      HEIGHT 30
      CAPTION "Child"
      ACTION CHILD()
   END BUTTONEX

   END WINDOW

   wModal.center
   wModal.activate

RETURN NIL

************************
STATIC FUNCTION CHILD()
************************

   IF IsWindowDefined( wChild )
      doMethod( "wChild", "HIDE" )
      doMethod( "wChild", "SHOW" )
      doMethod( "wChild", "SETFOCUS" )
      RETURN NIL
   ENDIF

   DEFINE WINDOW wChild AT 0, 0 WIDTH 100 HEIGHT 100 TITLE "Child" CHILD ;
      NOMAXIMIZE NOMINIMIZE

   DEFINE TIMER t_1 INTERVAL 50 ACTION doMethod( "wChild", "SETFOCUS" ) ONCE

   END WINDOW

   wChild.center
   ACTIVATE WINDOW wChild NOWAIT

   DO MESSAGELOOP

RETURN NIL
