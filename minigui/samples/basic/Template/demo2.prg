/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * NoAutoRelease Style Demo - ACTIVATE WINDOW ALL command usage
 *
 * Copyright 2002 Roberto Lopez <mail.box.hmg@gmail.com>
*/

#include "minigui.ch"

/******
*
*       Template for application
*
*/

Function Main

   SET FONT TO GetDefaultFontName(), GetDefaultFontSize()

   SET DEFAULT ICON TO ".\..\..\..\RESOURCES\DEFAULT.ICO"

   If .Not. IsWindowDefined( MainWin )

      *--------------------------------------------------------------------*
      * Main Form Definition
      *--------------------------------------------------------------------*
      DEFINE WINDOW MainWin ;
         MAIN ;
         CLIENTAREA 600, 400 ;
         TITLE 'NoAutoRelease Template Demo' ;
         BKBRUSH 'PAPER.GIF' ;
         ON INIT OnInit()

         CreateMainMenu()

         DEFINE STATUSBAR KEYBOARD FONT 'Tahoma' SIZE 9

         END STATUSBAR

         ON KEY ALT+X ACTION { || QuickExit() }

      END WINDOW

      *--------------------------------------------------------------------*
      * Child Form Definition
      *--------------------------------------------------------------------*
      DEFINE WINDOW ChildWin ;
         CHILD ;
         CLIENTAREA 400, 300 ;
         MINWIDTH 200 ;
         MINHEIGHT 200 ;
         TITLE 'Child Window'

         ON KEY ESCAPE ACTION ThisWindow.Hide()

      END WINDOW

      *--------------------------------------------------------------------*
      * Modal Form Definition
      *--------------------------------------------------------------------*
      DEFINE WINDOW ModalWin ;
         MODAL ;
         CLIENTAREA 400, 300 ;
         MINWIDTH 200 ;
         MINHEIGHT 200 ;
         TITLE 'Modal Window'

         ON KEY ESCAPE ACTION ThisWindow.Hide()

      END WINDOW

      CENTER WINDOW MainWin

      * Using ACTIVATE WINDOW ALL command, all defined windows will be activated 
      * simultaneously. NOAUTORELEASE and NOSHOW styles in the non-main windows 
      * are forced.

      ACTIVATE WINDOW ALL 

   EndIf

Return Nil


Static Procedure OnInit()

   CENTER WINDOW ChildWin
   CENTER WINDOW ModalWin

Return


Static Procedure CreateMainMenu

   DEFINE MAIN MENU OF MainWin
          
      POPUP '&File'
        ITEM '&Child Window' ACTION ( ChildWin.Show(), ChildWin.SetFocus() )
        ITEM '&Modal Window' ACTION ModalWin.Show()
        SEPARATOR
        ITEM 'E&xit' + Chr(9) + 'Alt+X' ACTION {|| QuickExit() }
      END POPUP
                  
   END MENU

Return


Static Procedure QuickExit

   QUIT

Return
