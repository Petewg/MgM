/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

FUNCTION Main

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'Harbour MiniGUI Demo' ;
      ICON 'demo.ico' ;
      MAIN ;
      ON INIT ( Form_1.Edit_1.Value := 'demo' ) ;
      FONT 'Arial' SIZE 10

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!'
      END STATUSBAR

      @ 30, 10 EDITBOX Edit_1 ;
         WIDTH 410 ;
         HEIGHT 140 ;
         VALUE '' ;
         TOOLTIP 'EditBox' ;
         MAXLENGTH 255 ;
         ON CHANGE ShowRowCol() NOHSCROLL

      DEFINE BUTTON B
         ROW 250
         COL 10
         CAPTION 'Set CaretPos'
         ACTION ( Form_1.Edit_1.CaretPos := Val( InputBox( 'Set Caret Position', '' ) ), Form_1.Edit_1.SetFocus )
      END BUTTON

      DEFINE TIMER Timer_1 INTERVAL 100 ACTION ShowRowCol()

   END WINDOW

   Form_1.Center()

   Form_1.Activate()

RETURN NIL


PROCEDURE ShowRowCol

   LOCAL s, c, i, e, q
	
   s := Form_1.Edit_1.Value
   c := Form_1.Edit_1.CaretPos
   e := 0
   q := 0

   FOR i := 1 TO c
      IF SubStr ( s, i, 1 ) == Chr( 13 )
         e++
         q := 0
      ELSE
         q++
      ENDIF
   NEXT i

   Form_1.StatusBar.Item( 1 ) := 'Row: ' + hb_ntos( e + 1 ) + ' Col: ' + hb_ntos( q )

   IF e < 7
      Form_1.Edit_1.Refresh
   ENDIF

RETURN
