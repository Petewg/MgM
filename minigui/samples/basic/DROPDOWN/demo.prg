/*
* MiniGUI Pseudo DropDownButton
* by Adam Lubszczyk
* mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

MEMVAR Btn_1_DropMenuHandle

PROCEDURE Main

   DEFINE WINDOW Win_1 ;
      AT 0, 0 WIDTH 550 HEIGHT 270 ;
      TITLE "Pseudo DropDownButton sample by Adam Lubszczyk <adam_l@poczta.onet.pl>" ;
      MAIN ;
      FONT "Arial" SIZE 9

      DEFINE BUTTON Button_1
        ROW 50
        COL 200
        WIDTH 100
        HEIGHT 100
        CAPTION "Pseudo Drop"
        ACTION MsgInfo("Button Click!", "Pressed")
        FLAT .T.
      END BUTTON

      DEFINE BUTTON Button_2
        ROW 50
        COL 300
        WIDTH 15
        HEIGHT 100
        CAPTION "V"
        ACTION ShowBtn_1_DropDownMenu()
        FLAT .T.
      END BUTTON

      // make popup menu (must be after DEFINE BUTTON Button_2)
      DEFINE CONTEXT MENU CONTROL Button_2
        // Level 1 (Top)
        MENUITEM "Drop Menu 1" ACTION MsgInfo("Button Drop Menu 1", "Pressed")
        MENUITEM "Drop Menu 2" ACTION MsgInfo("Button Drop Menu 2", "Pressed")
        MENUITEM "Drop Menu 3" ACTION MsgInfo("Button Drop Menu 3", "Pressed")

        Separator

        Popup 'More actions'  // Level 2
          MenuItem 'Action 1' Action MsgInfo( 'Action 1', 'Pressed' )
          MenuItem 'Action 2' Action MsgInfo( 'Action 2', 'Pressed' )
          MenuItem 'Action 3' Action MsgInfo( 'Action 3', 'Pressed' )
          
          Popup '... and more'   // Level 3
            MenuItem 'Something 1' Action MsgInfo( 'Something 1', 'Pressed' )
            MenuItem 'Something 2' Action MsgInfo( 'Something 2', 'Pressed' )
            MenuItem 'Something 3' Action MsgInfo( 'Something 3', 'Pressed' )
          End Popup

        End Popup

      END MENU

   END WINDOW

   // for easy use in future (must be below DEFINE CONTEXT MENU CONTROL command)
   PUBLIC Btn_1_DropMenuHandle := _HMG_xContextMenuHandle

   // no show context menu of Button_2
   SET CONTEXT MENU CONTROL Button_2 OF Win_1 OFF

   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

RETURN

PROCEDURE ShowBtn_1_DropDownMenu()
   LOCAL aPos:={0,0,0,0}
   // get SCREEN (no window) position of Button_1
   GetWindowRect( GetControlHandle( "Button_1", "Win_1" ), aPos )
   TrackPopupMenu( Btn_1_DropMenuHandle, aPos[1], ;
      aPos[2] + Win_1.Button_1.Height, GetFormHandle( "Win_1" ) )

RETURN
