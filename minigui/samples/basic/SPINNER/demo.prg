/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

PROCEDURE Main()

   DEFINE WINDOW Form_Main ;
      AT 0,0 ;
      WIDTH 540 HEIGHT 380 ;
      TITLE "MiniGUI Spinner Demo" ;
      MAIN

      @ 10,250 SPINNER Spinner_1 ;
         RANGE 0,10 ;
         VALUE 5 ;
         WIDTH 50 ;
         TOOLTIP "Range 0,10" ;
         ON CHANGE PlayBeep()
/*
      @ 50,250 SPINNER Spinner_2 ;
         RANGE 0,100 ;
         VALUE 5 ;
         WIDTH 50 ;
         TOOLTIP "Range 0,100 HORIZONTAL WRAP READONLY INCREMENT 5" ;
         HORIZONTAL WRAP READONLY INCREMENT 5
*/
      DEFINE SPINNER Spinner_2
         ROW 50
         COL 250
         RANGEMIN 0
         RANGEMAX 100
         VALUE 5
         WIDTH 50
         TOOLTIP "Range 0,100 HORIZONTAL WRAP READONLY INCREMENT 5"
         HORIZONTAL .T.
         WRAP .T.
         READONLY .T.
         INCREMENT 5
      END SPINNER

      @ 10,10 BUTTON Button_1 ;
         CAPTION "Set value" ;
         ACTION ( Form_Main.Spinner_1.Value := 1 , Form_Main.Spinner_2.Value := 15 )

      @ 50,10 BUTTON Button_2 ;
         CAPTION "Get value" ;
         ACTION MsgInfo( "Spinner_1 Value: " + hb_NToS( Form_Main.Spinner_1.Value ) + CRLF + ;
                         "Spinner_2 Value: " + hb_NToS( Form_Main.Spinner_2.Value ) )

      @ 90,10 BUTTON Button_3 ;
         CAPTION "Disable state" ;
         ACTION ( Form_Main.Spinner_1.Enabled := .F. , Form_Main.Spinner_2.Enabled := .F. )

      @ 130,10 BUTTON Button_4 ;
         CAPTION "Enable state" ;
         ACTION ( Form_Main.Spinner_1.Enabled := .T. , Form_Main.Spinner_2.Enabled := .T. )

      @ 170,10 BUTTON Button_5 ;
         CAPTION "Hide spinners" ;
         ACTION ( Form_Main.Spinner_1.Hide , Form_Main.Spinner_2.Hide )

      @ 210,10 BUTTON Button_6 ;
         CAPTION "Show spinners" ;
         ACTION ( Form_Main.Spinner_1.Show , Form_Main.Spinner_2.Show )

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

   RETURN
