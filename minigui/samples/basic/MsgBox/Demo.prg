/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"
#include "resource.h"

Function Main()

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 480 HEIGHT 260 ;
      TITLE 'MiniGUI Message Box Demo' ;
      ICON "HMG" ;
      MAIN ;
      FONT 'Arial' SIZE 10 ;
      ON INIT MsgInfo ("MiniGUI Extended Edition"+CRLF+" Message Box demo","Message Box demo",IDI_HMG,.f.)

      DEFINE STATUSBAR
         STATUSITEM 'Harbour Power Ready!'
      END STATUSBAR

      DEFINE MAIN MENU

      POPUP 'Classic HMG MsgBox'

         ITEM 'MsgBox()'            ACTION MsgBox("Function MsgBox()","MsgBox")
         ITEM 'MsgStop()'           ACTION MsgStop("Function MsgStop()","MsgStop",)
         ITEM 'MsgExclamation()'    ACTION MsgExclamation("Function MsgExclamation()","MsgExclamation",)
         ITEM 'MsgInfo()'           ACTION MsgInfo("Function MsgInfo()","MsgInfo",)
         SEPARATOR
         ITEM 'MsgOkCancel()'       ACTION MsgBox(MsgOkCancel("Function MsgOkCancel()","MsgOkCancel",),"Result")
         ITEM 'MsgRetryCancel()'    ACTION MsgBox(MsgRetryCancel('Function MsgRetryCancel()',"MsgRetryCancel",),"Result")
         ITEM 'MsgYesNo() '         ACTION MsgBox(MsgYesNo("MessageBox Test", "MsgYesNo", .f.),"Result")
         ITEM 'MsgYesNo() reverted' ACTION MsgBox(MsgYesNo("Function MsgYesNo()"+CRLF+'NO as default button set', "MsgNoYes", .t.),"Result")
         ITEM 'MsgYesNoCancel() '   ACTION MsgBox(MsgYesNoCancel("Function MsgYesNoCancel()", "MsgYesNoCancel",),"Result")

      END POPUP

      POPUP 'Extend HMG MsgBox'

         ITEM 'MsgBox()'            ACTION MsgBox("Function MsgBox()","MsgBox",.f.)
         ITEM 'MsgStop()'           ACTION MsgStop("Function MsgStop()","MsgStop",IDI_SNAIL,.f.)
         ITEM 'MsgExclamation()'    ACTION MsgExclamation("Function MsgExclamation()","MsgExclamation",IDI_DEMO,.f.)
         ITEM 'MsgInfo()'           ACTION MsgInfo("Function MsgInfo()","MsgInfo",IDI_PRINT,.f.)
         SEPARATOR
         ITEM 'MsgOkCancel()'       ACTION MsgOkCancel("Function MsgOkCancel()","MsgOkCancel",IDI_COMP,.f.)
         ITEM 'MsgOkCancel()  [Cancel] Default'  ACTION MsgOkCancel("Function MsgOkCancel()","MsgOkCancel",IDI_COMP,.f.,2)
         SEPARATOR
         ITEM 'MsgRetryCancel()'    ACTION MsgRetryCancel('Function MsgRetryCancel()',"MsgRetryCancel",IDI_COMP,.f.)
         ITEM 'MsgRetryCancel() [Cancel] Default' ACTION MsgRetryCancel('Function MsgRetryCancel()',"MsgRetryCancel",IDI_COMP,.f.,2)
         SEPARATOR
         ITEM 'MsgYesNo() '         ACTION MsgYesNo("Function MsgYesNo()"+CRLF+'YES - as default button set', "MsgYesNo", .f.,IDI_COMP,.f.)
         ITEM 'MsgYesNo() reverted' ACTION MsgYesNo("Function MsgYesNo()"+CRLF+'NO - as default button set', "MsgYesNo", .t.,IDI_COMP,.f.)
         SEPARATOR
         ITEM 'MsgYesNoCancel() '   ACTION MsgYesNoCancel("Function MsgYesNoCancel()"+CRLF+'YES - as default button set' , "MsgYesNoCancel", IDI_COMP,.f. )
         ITEM 'MsgYesNoCancel() [NO] default'   ACTION MsgYesNoCancel("Function MsgYesNoCancel()"+CRLF+'NO - as default button set' , "MsgYesNoCancel", IDI_COMP,.f. , 2)
         ITEM 'MsgYesNoCancel() [Cancel] Default'   ACTION MsgYesNoCancel("Function MsgYesNoCancel()"+CRLF+'Cancel - as default button set' , "MsgYesNoCancel", IDI_COMP,.f. , 3)

      END POPUP

      POPUP '&Help'

            ITEM '&About'      ACTION MsgInfo ("MiniGUI Extended Edition"+CRLF+" Message Box demo","Message Box demo",IDI_HMG,.f.)
            ITEM '&Exit'       ACTION Form_1.Release

      END POPUP

      END MENU

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil
