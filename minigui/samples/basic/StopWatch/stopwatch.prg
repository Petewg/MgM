/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * StopWatch Demo
 * (c) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
*/

#include "minigui.ch"

Memvar lStop
*------------------------
Function main()
*------------------------
Public lStop:=.f.

DEFINE WINDOW Stopper AT 311,246 ;
	WIDTH 282 HEIGHT 122 MAIN ;
	TITLE "StopWatch" ;
	ICON "WATCH" ;
	NOMAXIMIZE NOSIZE

      @ 15,60 LABEL Label_1 VALUE "00:00:00"  WIDTH 251 HEIGHT 37 ;
              FONT "ARIAL" SIZE 25 BOLD
      @ 62,15 BUTTON Button_1 CAPTION "Start" WIDTH 78 HEIGHT 24;
              ACTION RunTest()
      @ 62,97 BUTTON Button_2 CAPTION "Stop"  WIDTH 78 HEIGHT 24;
              ACTION {|| (lStop:=.t.)}
      @ 62,180 BUTTON Button_3 CAPTION "Clear" WIDTH 78 HEIGHT 24;
              ACTION {|| (Stopper.Label_1.Value := "00:00:00", lStop := .f.)}

   END WINDOW

   Stopper.Button_1.Enabled:=.t.
   Stopper.Button_2.Enabled:=.f.
   Stopper.Button_3.Enabled:=.t.

   Stopper.Center
   Stopper.Activate

Return Nil
   
*-----------------------
Function RunTest()
*-----------------------
lStop:=.f.
Stopper.Button_1.Enabled:=.f.
Stopper.Button_2.Enabled:=.t.
Stopper.Button_3.Enabled:=.f.

Do while lStop == .f.

   Stopper.Label_1.Value := TIME()
   do EVENTS
   if lStop==.t.
      exit
   endif
   inkey(0.25)

enddo

Stopper.Button_1.Enabled:=.t.
Stopper.Button_2.Enabled:=.f.
Stopper.Button_3.Enabled:=.t.

Return NIL
