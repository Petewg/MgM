/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Procedure Main

   SET CENTURY ON

   SET DATE AMERICAN

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 780 ;
      HEIGHT 400 ;
      TITLE 'Statusbar with ProgressBar Demo' ;
      MAIN

      DEFINE STATUSBAR

      STATUSITEM MiniGUIVersion()

         PROGRESSITEM WIDTH 170 RANGE 0 , 100 //VALUE 20

         STATUSITEM "  0%" ACTION Start() TOOLTIP "Start ProgressBar"

         DATE

      END STATUSBAR

      @ 80,145 BUTTON Button_1 ;
         CAPTION 'Start ProgressBar' ;
         ACTION Start() ;
         WIDTH 180 HEIGHT 26 DEFAULT

      @ 120,145 BUTTON Button_2 ;
         CAPTION 'Hide ProgressBar' ;
         ACTION {|| ( Set ProgressItem Of Form_1 Position To ), Form_1.StatusBar.Item(3) := "  0%" } ;
         WIDTH 180 HEIGHT 26

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return


Function Start
   Local n, nValue

   Set StatusBar ProgressItem Of Form_1 Range To 0, 100

   For n := 1 To 10000

      nValue := Int( n / 100 )

      Set StatusBar ProgressItem Of Form_1 Position To nValue

      If n % 500 == 0
         Form_1.StatusBar.Item(3) := Str(nValue, 3)+" %"
          DoEvents()
         InKey(.1)
      EndIf

   Next

Return Nil
