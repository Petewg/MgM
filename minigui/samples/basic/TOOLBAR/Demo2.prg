/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 *
 * (c) 2010 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

Function Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI ToolBar WRAP Demo' ;
      ICON 'DEMO.ICO' ;
      MAIN ;
      FONT 'Arial' SIZE 10

      ON KEY F2 ACTION MsgInfo('F2 (Main)')

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!'
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM '&Disable ToolBar Button'	ACTION Form_1.Button_1.Enabled := .F.
            ITEM '&Enable ToolBar Button'	ACTION Form_1.Button_1.Enabled := .T.
            SEPARATOR
            ITEM '&Disable ToolBar Button'	ACTION SetProperty ( 'Form_1' , 'Toolbar_1' , 'Button_1' , 'Enabled' , .F. )
            ITEM '&Enable ToolBar Button'	ACTION SetProperty ( 'Form_1' , 'Toolbar_1' , 'Button_1' , 'Enabled' , .T. )
            SEPARATOR
            ITEM '&Disable ToolBar Button'	ACTION Form_1.Toolbar_1.Button_1.Enabled := .F.
            ITEM '&Enable ToolBar Button'	ACTION Form_1.Toolbar_1.Button_1.Enabled :=  .T.
            SEPARATOR
            ITEM 'Get ToolBar Button Caption'	ACTION MsgInfo( GetProperty ( 'Form_1' ,'Toolbar_1','Button_1','Caption'))
            ITEM 'Get ToolBar Button Caption'	ACTION MsgInfo( GetProperty ( 'Form_1' ,'Button_1','Caption'))
            ITEM 'Get ToolBar Button Caption'	ACTION MsgInfo( Form_1.Toolbar_1.Button_1.Caption)
            ITEM 'Get ToolBar Button Caption'	ACTION MsgInfo( Form_1.Button_1.Caption)
            SEPARATOR
            ITEM 'Set ToolBar Button Caption'	ACTION SetProperty ( 'Form_1' , 'Button_1' , 'Caption' , 'New Caption' )
            ITEM 'Set ToolBar Button Caption'	ACTION Form_1.Button_1.Caption := 'Other Caption'
            ITEM 'Set ToolBar Button Caption'	ACTION SetProperty ( 'Form_1' , 'ToolBar_1' , 'Button_1' , 'Caption' , 'Newest Caption' )
            ITEM 'Set ToolBar Button Caption'	ACTION Form_1.ToolBar_1.Button_1.Caption := 'Other New Caption'
            SEPARATOR
            ITEM '&Exit'	ACTION Form_1.Release
         END POPUP
         POPUP '&Help'
            ITEM '&About'	ACTION MsgInfo ("MiniGUI ToolBar WRAP demo")
         END POPUP
      END MENU

      DEFINE SPLITBOX HORIZONTAL

         DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 85,85 FLAT BORDER WRAP

         BUTTON Button_1 ;
         CAPTION '&More ToolBars...' ;
         PICTURE 'button1.bmp' ;
         ACTION Modal_Click() ;
         TOOLTIP 'ONE'

         BUTTON Button_2 ;
         CAPTION '&Button 2' ;
         PICTURE 'button2.bmp' ;
         ACTION MsgInfo('Click 2') ;
         TOOLTIP 'TWO'

         BUTTON Button_3 ;
         CAPTION 'Button &3' ;
         PICTURE 'button3.bmp' ;
         ACTION MsgInfo('Click 3') ;
         TOOLTIP 'THREE'

         END TOOLBAR

      END SPLITBOX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Procedure Modal_CLick
*-----------------------------------------------------------------------------*

   DEFINE WINDOW Form_2 ;
      AT 0,0 ;
      WIDTH 400 HEIGHT 300 ;
      TITLE 'ToolBar Test' ;
      MODAL

      ON KEY F2 ACTION MsgInfo('F2 (Child)')
      ON KEY F10 ACTION MsgInfo('F10 (Child)')

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 100,30 RIGHTTEXT BORDER WRAP

         BUTTON Button_1 ;
         CAPTION '&Undo' ;
         PICTURE 'button4.bmp' ;
         ACTION MsgInfo('UnDo Click!')

         BUTTON Button_2 ;
         CAPTION '&Save' ;
         PICTURE 'button5.bmp' ;
         ACTION MsgInfo('Save Click!')

         BUTTON Button_3 ;
         CAPTION '&Close' ;
         PICTURE 'button6.bmp' ;
         ACTION Form_2.Release

      END TOOLBAR

   END WINDOW

   Form_2.Center

   Form_2.Activate

Return
