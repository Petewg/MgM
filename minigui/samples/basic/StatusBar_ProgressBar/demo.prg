/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define TOOLTIP_STATUS "     Start ProgressBar"

FUNCTION Main()

   SET CENTURY ON
   SET DATE AMERICAN

   DEFINE WINDOW Form_1 ;
      CLIENTAREA 640, 400 ;
      TITLE 'STATUSBAR with PROGRESSBAR Demo' ;
      MAIN

      DEFINE STATUSBAR

         // Add items to statusbar
         // #1
         STATUSITEM MiniGUIVersion()
         // #2
         PROGRESSITEM WIDTH 170 RANGE 0, 100 //VALUE 20
         // #3
         STATUSITEM "  0%" + TOOLTIP_STATUS ACTION Start() WIDTH 50 TOOLTIP "Start ProgressBar"
         // #4
         DATE

      END STATUSBAR

      @ 80,145 BUTTON Button_1 ;
         CAPTION 'Start ProgressBar' ;
         ACTION Start() ;
         TOOLTIP "Start" ;
         WIDTH 180 HEIGHT 26 DEFAULT

      @ 120,145 BUTTON Button_2 ;
         CAPTION 'Reset ProgressBar' ;
         ACTION ;
            {|| SET ProgressItem OF Form_1 POSITION TO, Form_1.StatusBar.Item( 3 ) := "  0%" + TOOLTIP_STATUS } ;
         TOOLTIP "Reset" ;
         WIDTH 180 HEIGHT 26

   END WINDOW

   CENTER   WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
PROCEDURE Start

   LOCAL n, nValue
   STATIC lBusy := .F.

   IF lBusy
      RETURN
   ENDIF

   lBusy := .T.
   Form_1.Button_2.Enabled := .F.

   SET STATUSBAR ProgressItem OF Form_1 RANGE TO 0, 100

   FOR n := 1 To 10000

      nValue := Int( n / 100 )

      SET STATUSBAR ProgressItem OF Form_1 POSITION TO nValue

      IF n % 500 == 0
         Form_1.StatusBar.Item( 3 ) := Str(nValue, 3) + " %"

         InKeyGUI( 200 )
      ENDIF

   NEXT

   lBusy := .F.
   Form_1.Button_2.Enabled := .T.

RETURN
