/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "hmg.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 365 HEIGHT 245 ;
      TITLE "MiniGUI ProgressBar Demo" ;
      MAIN

   @ 20, 145 BUTTON Button_1 ;
      CAPTION 'Start' ;
      ACTION OnStart() ;
      WIDTH 80 HEIGHT 26 DEFAULT

   @ 70, 31 PROGRESSBAR Progress_1 ;
      RANGE 0, 100 ;
      WIDTH 300 HEIGHT 26 ;
      TOOLTIP "ProgressBar"

   @ 120, 155 TEXTBOX TextBox_1 ;
      VALUE " 50 %" WIDTH 60 MAXLENGTH 5

   @ 150, 80 SLIDER Slider_1 ;
      RANGE 0, 100 VALUE 50 ;
      WIDTH 200 HEIGHT 40 ;
      ON CHANGE {|| Slider_Change() }

   END WINDOW

   Form_1.Progress_1.Value := 50

   IF .NOT. IsWinNT()
      Form_1.Progress_1.BackColor := RED
      Form_1.Progress_1.ForeColor := YELLOW
   ENDIF

   Form_1.TextBox_1.Enabled := .F.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION Slider_Change

   LOCAL nValue := Form_1.Slider_1.Value

   Form_1.TextBox_1.Value := Str( nValue, 3 ) + " %"

   Form_1.Progress_1.Value := nValue

RETURN NIL


FUNCTION OnStart

   LOCAL n, nValue, aPos

   SetWaitCursor( Application.Handle )
   SetWaitCursor( GetControlHandle( 'Button_1', 'Form_1' ) )
   SetWaitCursor( GetControlHandle( 'Progress_1', 'Form_1' ) )
   SetWaitCursor( GetControlHandle( 'TextBox_1', 'Form_1' ) )
   SetWaitCursor( GetControlHandle( 'Slider_1', 'Form_1' ) )

   SetCursorSystem( IDC_WAIT )

   FOR n := 1 TO 10000

      nValue := Int( n / 100 )

      Form_1.Progress_1. Value := nValue
      Form_1.TextBox_1. Value := Str( nValue, 3 ) + " %"
      Form_1.Slider_1. Value := nValue

      IF n % 500 == 0

         SuppressKeyAndMouseEvents()

      ENDIF

   NEXT

   SetArrowCursor( Application.Handle )
   SetArrowCursor( GetControlHandle( 'Button_1', 'Form_1' ) )
   SetArrowCursor( GetControlHandle( 'Progress_1', 'Form_1' ) )
   SetArrowCursor( GetControlHandle( 'TextBox_1', 'Form_1' ) )
   SetArrowCursor( GetControlHandle( 'Slider_1', 'Form_1' ) )

   SetCursorSystem( IDC_ARROW )

RETURN NIL
