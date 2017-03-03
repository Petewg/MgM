/*
  MINIGUI - Harbour Win32 GUI library Demo

  Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  Author: S.Rathinagiri <srgiri@dataone.in>

  Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

FUNCTION Main

   SET NAVIGATION EXTENDED
   SET FONT TO "Tahoma", 10

   DEFINE WINDOW Form_Main ;
      AT 0, 0 ;
      WIDTH 330 HEIGHT 470 ;
      TITLE 'ON LOST FOCUS Event Test' ;
      MAIN

   ON KEY ESCAPE ACTION ThisWindow.Release

   @ 20, 10 LABEL Warning WIDTH 310 FONTCOLOR { 255, 0, 0 } CENTERALIGN

   @ 90, 10 LABEL L1 ;
      WIDTH 90 HEIGHT 23 ;
      VALUE 'Field T1' VCENTERALIGN

   @ 90, 90 TEXTBOX T1 ;
      WIDTH 150 HEIGHT 23 ;
      VALUE '' ;
      ON GOTFOCUS Form_Main.L_Info1.Value := 'Focused control: ' + ThisWindow.FocusedControl ;
      ON LOSTFOCUS Fld_CheckValue( this.name )

   @ 120, 10 LABEL L2 ;
      WIDTH 90 HEIGHT 23 ;
      VALUE 'Field T2' VCENTERALIGN

   @ 120, 90 TEXTBOX T2 ;
      WIDTH 150 HEIGHT 23 ;
      VALUE '' ;
      ON GOTFOCUS Form_Main.L_Info1.Value := 'Focused control: ' + ThisWindow.FocusedControl ;
      ON LOSTFOCUS Fld_CheckValue( this.name )

   @ 180, 10 LABEL L_Info1 ;
      WIDTH 120 HEIGHT 18 ;
      VALUE ''

   @ 200, 10 LABEL L_Info2 ;
      WIDTH 300 HEIGHT 230 ;
      BACKCOLOR { 255, 255, 0 } ;
      FONTCOLOR { 255, 0, 0 } ;
      VALUE 'Info label'

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

RETURN NIL

// ------------------------------------------------
FUNCTION Fld_CheckValue( fieldname )
// ------------------------------------------------
   Form_Main.L_Info1.Value := 'Focused control: ' + ThisWindow.FocusedControl
   Form_Main.L_Info2.Value := ViewCallStack()

   IF Empty( GetProperty( "Form_Main", fieldname, "Value" ) )

      Form_Main .Warning. Value := 'Field ' + fieldname + ' can NOT be EMPTY !'

      IF fieldname == "T1"
         DISABLE CONTROL EVENT T2 OF Form_Main
      ELSE
         DISABLE CONTROL EVENT T1 OF Form_Main
      ENDIF

      Domethod( "Form_Main", fieldname, "SetFocus" )

      IF fieldname == "T1"
         ENABLE CONTROL EVENT T2 OF Form_Main
      ELSE
         ENABLE CONTROL EVENT T1 OF Form_Main
      ENDIF

   ELSE

      Form_Main.Warning.Value := ''

   ENDIF

RETURN .T.

// ------------------------------------------------
STATIC FUNCTION ViewCallStack
// ------------------------------------------------
   LOCAL i := 1, cStack := ""

   DO WHILE ! Empty( ProcName( ++i ) )
      cStack += ProcName( i ) + "(" + hb_ntos( ProcLine( i ) ) + ")" + CRLF
   ENDDO

RETURN cStack
