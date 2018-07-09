/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 */

#include "minigui.ch"

*************
function MAIN
*************

DEFINE WINDOW WinMain AT 0 , 0 WIDTH 400 HEIGHT 300 TITLE "Main" MAIN

   DEFINE BUTTONEX ButtonEX_1
	ROW 220
	COL 80
	WIDTH 100
	HEIGHT 30
	CAPTION "&Modal"
	ACTION SHOW_MODAL()
   END BUTTONEX

   DEFINE BUTTONEX ButtonEX_2
	ROW 220
	COL 220
	WIDTH 100
	HEIGHT 30
	CAPTION "&Quit"
	ACTION WinMain.RELEASE
   END BUTTONEX

END WINDOW

DEFINE WINDOW WinChild1 AT 0 , 0 WIDTH 400 HEIGHT 300 TITLE "Child" CHILD

   DEFINE BUTTONEX ButtonEX_1
	ROW 220
	COL 80
	WIDTH 100
	HEIGHT 30
	CAPTION "&Close"
	ACTION doMethod( "WinChild1", "HIDE" )
   END BUTTONEX

END WINDOW

DEFINE WINDOW WinModal1 AT 0 , 0 WIDTH 400 HEIGHT 300 TITLE "Modal" MODAL ;
   FLASHEXIT

   DEFINE BUTTONEX ButtonEX_1
	ROW 220
	COL 80
	WIDTH 100
	HEIGHT 30
	CAPTION "&Child"
	ACTION ( doMethod( "WinChild1", "SHOW" ), doMethod( "WinChild1", "ButtonEX_1", "SETFOCUS" ) )
   END BUTTONEX

   DEFINE BUTTONEX ButtonEX_2
	ROW 220
	COL 220
	WIDTH 100
	HEIGHT 30
	CAPTION "&Main"
	ACTION ( doMethod( "WinModal1", "HIDE" ), doMethod( "WinMain", "ButtonEX_1", "SETFOCUS" ) )
   END BUTTONEX

END WINDOW

WinMain.CENTER

ACTIVATE WINDOW ALL

return NIL

**************************
static function SHOW_MODAL
**************************

LOCAL y1 := App.Row + 40
LOCAL x1 := App.Col + 40
LOCAL y2 := y1 + 40
LOCAL x2 := x1 + 40

WinChild1.ROW := y2
WinChild1.COL := x2
WinChild1.HIDE

WinModal1.ROW := y1
WinModal1.COL := x1
WinModal1.SHOW

return NIL
