/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/


#include "minigui.ch"

Function Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI Customizable ToolBar Demo' ;
      ICON 'DEMO.ICO' ;
      MAIN ;
      FONT 'Arial' SIZE 10

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!'
      END STATUSBAR

      DEFINE MAIN MENU
      POPUP '&File'
            ITEM "Customize ToolBar 1" ACTION CustomToolbar('ToolBar_a')
            ITEM "Customize ToolBar 3" ACTION CustomToolbar('ToolBar_c')
            SEPARATOR
            ITEM '&Exit'	ACTION Form_1.Release
         END POPUP
         POPUP '&Help'
            ITEM '&About'	ACTION MsgInfo ("MiniGUI Customizable ToolBar demo")
         END POPUP
      END MENU

      DEFINE SPLITBOX

         DEFINE TOOLBAREX ToolBar_a BUTTONSIZE 45,40 FONT 'Arial' SIZE 8  FLAT TOOLTIP "Double Clik for customizing" CUSTOMIZE

            BUTTON Button_1a ;
               CAPTION '&New' ;
               PICTURE 'New.bmp' ;
               ACTION MsgInfo('Click! 1')

            BUTTON Button_2a ;
               CAPTION '&Open' ;
               PICTURE 'open.bmp' ;
               ACTION MsgInfo('Click! 2')

            BUTTON Button_3a ;
               CAPTION '&Save' ;
               PICTURE 'Save.bmp' ;
               ACTION MsgInfo('Click! 3')

            BUTTON Button_4a ;
               CAPTION '&Close' ;
               PICTURE 'close.bmp' ;
               ACTION MsgInfo('Click! 4')

         END TOOLBAR

         DEFINE TOOLBAR ToolBar_b BUTTONSIZE 45,40 FONT 'ARIAL' SIZE 8 FLAT TOOLTIP "No customizing"

            BUTTON Button_1b ;
               CAPTION '&Cut' ;
               PICTURE 'cut.bmp' ;
               ACTION MsgInfo('Click! 1');

            BUTTON Button_2b ;
               CAPTION 'Copy' ;
               PICTURE 'Copy.bmp' ;
               ACTION MsgInfo('Click! 2');


            BUTTON Button_3b ;
               CAPTION '&Paste' ;
               PICTURE 'Paste.bmp' ;
               ACTION MsgInfo('Click! 3');
               SEPARATOR

            BUTTON Button_5b ;
               CAPTION '&Undo' ;
               PICTURE 'Undo.bmp' ;
               ACTION MsgInfo('Click! 4')

         END TOOLBAR

         DEFINE TOOLBAREX ToolBar_c BUTTONSIZE 45,40 FONT 'Arial' SIZE 8 CAPTION 'ToolBar 3' FLAT TOOLTIP "Double Clik for customizing" CUSTOMIZE

            BUTTON Button_1c ;
               CAPTION '&Bold' ;
               PICTURE 'bold.bmp' ;
               ACTION MsgInfo('Hey!')

            BUTTON Button_2c ;
               CAPTION '&Italic' ;
               PICTURE 'italic.bmp' ;
               ACTION MsgInfo('Hey!')

            BUTTON Button_3c ;
               CAPTION '&Under' ;
               PICTURE 'Under.bmp' ;
               ACTION MsgInfo('Hey!')

            BUTTON Button_4c ;
               CAPTION 'Strike' ;
               PICTURE 'Strike.bmp' ;
               ACTION MsgInfo('Hey!') ;
               SEPARATOR

            BUTTON Button_5c ;
               CAPTION '&Left' ;
               PICTURE 'Left.bmp' ;
               ACTION MsgInfo('Hey!')

            BUTTON Button_6c ;
               CAPTION '&Center' ;
               PICTURE 'Center.bmp' ;
               ACTION MsgInfo('Hey!')

            BUTTON Button_7c ;
               CAPTION '&Right' ;
               PICTURE 'Right.bmp' ;
               ACTION MsgInfo('Hey!')

         END TOOLBAR

      END SPLITBOX

      DEFINE CONTEXT MENU
         MENUITEM "Customize ToolBar 1" ACTION CustomToolbar('ToolBar_a')
         SEPARATOR
         MENUITEM "Customize ToolBar 3" ACTION CustomToolbar('ToolBar_c')
      END MENU

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil


Function CustomToolbar( cToolbar )
         CustomizeToolbar( _HMG_aControlHandles[ GetControlIndex( cToolbar, 'Form_1' ) ] )
Return Nil

