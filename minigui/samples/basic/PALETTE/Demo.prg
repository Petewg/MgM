/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (C)2008 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

/* Standard Button Images */

#define IDB_STD_SMALL_COLOR   0
#define IDB_STD_LARGE_COLOR   1
/*
#define IDB_VIEW_LARGE_COLOR   5
#define IDB_VIEW_SMALL_COLOR   4
#define IDB_HIST_SMALL_COLOR   8
#define IDB_HIST_LARGE_COLOR   9
*/

/* Bitmap Resource Identifiers for Standard Bitmaps */

#define STD_CUT		0
#define STD_COPY	1
#define STD_PASTE	2
#define STD_UNDO	3
#define STD_REDOW	4
#define STD_DELETE	5
#define STD_FILENEW	6
#define STD_FILEOPEN	7
#define STD_FILESAVE	8
#define STD_PRINTPRE	9
#define STD_PROPERTIES	10
#define STD_HELP	11
#define STD_FIND	12
#define STD_REPLACE	13
#define STD_PRINT	14


DECLARE WINDOW Form_Fl

Function Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI Float ToolBar Demo ' ;
      ICON 'DEMO.ICO' ;
      MAIN ;
      ON INIT ToolWin()

      DEFINE STATUSBAR
         STATUSITEM '[x] Harbour Power Ready!'
      END STATUSBAR


      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'ToolWindow 1'    ACTION ToolWin()
            ITEM 'ToolWindow 2'    ACTION ToolWin1()
            ITEM 'ToolWindow 3'    ACTION ToolWin2()
            SEPARATOR
            ITEM 'Set Size of Float ToolBar' ACTION SetSizeTB(250)
            ITEM 'Move Toolbar'              ACTION If( IsWindowDefined ( Form_Fl ), MoveWindow ( GetFormHandle('Form_fl') , 40 , 100 , 300 , 100 , .t. ), )
            ITEM 'Resize Float Toolbar'      ACTION If( IsWindowDefined ( Form_Fl ), ResizeFloatToolbar( GetControlHandle ('ToolBar_i', 'Form_fl'), 150 ), )
            ITEM 'Adjust Float Toolbar'      ACTION If( IsWindowDefined ( Form_Fl ), AdjustFloatToolbar( GetFormHandle('Form_1'), GetFormHandle('Form_fl'), GetControlHandle ('ToolBar_i', 'Form_fl') ), )
            SEPARATOR
            ITEM '&Exit'           ACTION Form_1.Release
         END POPUP
         POPUP '&Help'
            ITEM '&About'          ACTION MsgInfo ("MiniGUI Float ToolBar demo")
         END POPUP
      END MENU


   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil


FUNCTION toolWin()

   If IsWindowActive ( Form_Fl )
      Form_Fl.Release
      do events
   endif

      DEFINE WINDOW Form_Fl ;
         AT 0,0 ;
         WIDTH 200 HEIGHT 80 ;
         TITLE 'ToolBar Float Custom Buttons';
         PALETTE ;
         ON SIZE flResizeTb();
         ON INIT AdjustFloatToolbar( GetFormHandle('Form_1'), GetFormHandle('Form_fl'), GetControlHandle ('ToolBar_i' , 'Form_fl' ) )


         DEFINE TOOLBAREX ToolBar_i OF Form_fl BUTTONSIZE 25,25  FLAT TOOLBARSIZE 100

            BUTTON Button_1 ;
               PICTURE "NEW.bmp" ;
               TOOLTIP 'New file';
               ACTION MsgInfo('Click 1! ')

            BUTTON Button_2 ;
               PICTURE "OPEN.bmp" ;
               TOOLTIP 'File open';
               ACTION MsgInfo('Click 2! ')

            BUTTON Button_3 ;
               PICTURE "SAVE.bmp" ;
               TOOLTIP 'Save file';
               ACTION MsgInfo('Click 3! ');

            BUTTON Button_4 ;
               PICTURE "PREVIEW.bmp" ;
               TOOLTIP 'Print Preview';
               ACTION MsgInfo('Click 4! ')

            BUTTON Button_5 ;
               PICTURE "PRINTER.bmp" ;
               TOOLTIP 'Print';
               ACTION MsgInfo('Click 5! ');

            BUTTON Button_6 ;
               PICTURE "Find2.bmp" ;
               TOOLTIP 'Find';
               ACTION MsgInfo('Click 6! ') ;

            BUTTON Button_7 ;
               PICTURE "COPY.bmp";
               TOOLTIP 'Copy';
               ACTION MsgInfo('Click 7! ')

            BUTTON Button_8 ;
               PICTURE "CUT.bmp" ;
               TOOLTIP 'Cut';
               ACTION MsgInfo('Click 8! ')

            BUTTON Button_9 ;
               PICTURE "PASTE.bmp" ;
               TOOLTIP 'Paste';
               ACTION MsgInfo('Click 9! ')

            BUTTON Button_1b ;
               PICTURE "NEW.bmp" ;
               TOOLTIP 'New file';
               ACTION MsgInfo('Click 1! ')

            BUTTON Button_2b ;
               PICTURE "OPEN.bmp" ;
               TOOLTIP 'File open';
               ACTION MsgInfo('Click 2! ')

            BUTTON Button_3b ;
               PICTURE "SAVE.bmp" ;
               TOOLTIP 'Save file';
               ACTION MsgInfo('Click 3! ');

            BUTTON Button_4b ;
               PICTURE "PREVIEW.bmp" ;
               TOOLTIP 'Print Preview';
               ACTION MsgInfo('Click 4! ')

            BUTTON Button_5b ;
               PICTURE "PRINTER.bmp" ;
               TOOLTIP 'Print';
               ACTION MsgInfo('Click 5! ');

            BUTTON Button_6b ;
               PICTURE "Find2.bmp" ;
               TOOLTIP 'Find';
               ACTION MsgInfo('Click 6! ') ;

            BUTTON Button_7b ;
               PICTURE "COPY.bmp";
               TOOLTIP 'Copy';
               ACTION MsgInfo('Click 7! ')

            BUTTON Button_8b ;
               PICTURE "CUT.bmp" ;
               TOOLTIP 'Cut';
               ACTION MsgInfo('Click 8! ')

            BUTTON Button_9b ;
               PICTURE "PASTE.bmp" ;
               TOOLTIP 'Paste';
               ACTION MsgInfo('Click 9! ')

         END TOOLBAR

      END WINDOW

   CENTER WINDOW Form_Fl

   ACTIVATE WINDOW Form_Fl

Return Nil


FUNCTION toolWin1()

   If IsWindowActive ( Form_Fl )
      Form_Fl.Release
      do events
   endif

      DEFINE WINDOW Form_Fl ;
         AT 0,0 ;
         WIDTH 200 HEIGHT 80 ;
         TITLE 'ToolBar Float Small Buttons';
         PALETTE ;
         ON SIZE flResizeTb();
         ON INIT AdjustFloatToolbar( GetFormHandle('Form_1'), GetFormHandle('Form_fl'), GetControlHandle ('ToolBar_i' , 'Form_fl' ) )

         DEFINE TOOLBAREX ToolBar_i BUTTONSIZE 25,25 IMAGELIST IDB_STD_SMALL_COLOR  CAPTION 'Small Buttons from DLL' FLAT

            BUTTON Button_1 ;
               PICTUREINDEX STD_FILENEW ;
               TOOLTIP 'New file';
               ACTION MsgInfo('Click! ')

            BUTTON Button_2 ;
               PICTUREINDEX STD_FILEOPEN ;
               TOOLTIP 'File open';
               ACTION MsgInfo('Click! ')

            BUTTON Button_3 ;
               PICTUREINDEX STD_FILESAVE ;
               TOOLTIP 'Save file';
               ACTION MsgInfo('Click! ');

            BUTTON Button_4 ;
               PICTUREINDEX STD_PRINTPRE ;
               TOOLTIP 'Print Preview';
               ACTION MsgInfo('Click! ')

            BUTTON Button_5 ;
               PICTUREINDEX STD_PRINT ;
               TOOLTIP 'Print ';
               ACTION MsgInfo('Click! ');

            BUTTON Button_6 ;
               PICTUREINDEX STD_PROPERTIES ;
               TOOLTIP 'Properties';
               ACTION MsgInfo('Click! ')

            BUTTON Button_7 ;
               PICTUREINDEX STD_REPLACE ;
               TOOLTIP 'Replace';
               ACTION MsgInfo('Click! ');

            BUTTON Button_8 ;
               PICTUREINDEX STD_FIND ;
               TOOLTIP 'Find';
               ACTION MsgInfo('Click! ');

            BUTTON Button_9 ;
               PICTUREINDEX STD_CUT ;
               TOOLTIP 'Cut';
               ACTION MsgInfo('Click! ');

            BUTTON Button_10 ;
               PICTUREINDEX STD_DELETE ;
               TOOLTIP 'Delete';
               ACTION MsgInfo('Click! ');

            BUTTON Button_11 ;
               PICTUREINDEX STD_PASTE ;
               TOOLTIP 'Paste';
               ACTION MsgInfo('Click! ');

            BUTTON Button_12 ;
               PICTUREINDEX STD_UNDO ;
               TOOLTIP 'Undo';
               ACTION MsgInfo('Click! ');

            BUTTON Button_13 ;
               PICTUREINDEX STD_REDOW ;
               TOOLTIP 'Redo';
               ACTION MsgInfo('Click! ');

            BUTTON Button_14 ;
               PICTUREINDEX STD_HELP ;
               TOOLTIP 'Help';
               ACTION MsgInfo('Click! ');


         END TOOLBAR

      END WINDOW

   CENTER WINDOW Form_Fl

   ACTIVATE WINDOW Form_Fl

Return Nil


FUNCTION toolWin2()

   If IsWindowActive ( Form_Fl )
      Form_Fl.Release
      do events
   endif

      DEFINE WINDOW Form_Fl ;
         AT 0,0 ;
         WIDTH 200 HEIGHT 80 ;
         TITLE 'ToolBar Float Large Buttons';
         PALETTE ;
         ON SIZE flResizeTb();
         ON INIT AdjustFloatToolbar( GetFormHandle('Form_1'), GetFormHandle('Form_fl'), GetControlHandle ('ToolBar_i' , 'Form_fl' ) )


         DEFINE TOOLBAREX ToolBar_i BUTTONSIZE 25,25 IMAGELIST IDB_STD_LARGE_COLOR  CAPTION 'Large Buttons from DLL' FLAT BREAK

            BUTTON Button_1 ;
               PICTUREINDEX STD_FILENEW ;
               TOOLTIP 'New file';
               ACTION MsgInfo('Click! ')

            BUTTON Button_2 ;
               PICTUREINDEX STD_FILEOPEN ;
               TOOLTIP 'File open';
               ACTION MsgInfo('Click! ')

            BUTTON Button_3 ;
               PICTUREINDEX STD_FILESAVE ;
               TOOLTIP 'Save file';
               ACTION MsgInfo('Click! ');

            BUTTON Button_4 ;
               PICTUREINDEX STD_PRINTPRE ;
               TOOLTIP 'Print Preview';
               ACTION MsgInfo('Click! ')

            BUTTON Button_5 ;
               PICTUREINDEX STD_PRINT ;
               TOOLTIP 'Print ';
               ACTION MsgInfo('Click! ');

            BUTTON Button_6 ;
               PICTUREINDEX STD_PROPERTIES ;
               TOOLTIP 'Properties';
               ACTION MsgInfo('Click! ')

            BUTTON Button_7 ;
               PICTUREINDEX STD_REPLACE ;
               TOOLTIP 'Replace';
               ACTION MsgInfo('Click! ');

            BUTTON Button_8 ;
               PICTUREINDEX STD_FIND ;
               TOOLTIP 'Find';
               ACTION MsgInfo('Click! ');

            BUTTON Button_9 ;
               PICTUREINDEX STD_CUT ;
               TOOLTIP 'Cut';
               ACTION MsgInfo('Click! ');

            BUTTON Button_10 ;
               PICTUREINDEX STD_DELETE ;
               TOOLTIP 'Delete';
               ACTION MsgInfo('Click! ');

            BUTTON Button_11 ;
               PICTUREINDEX STD_PASTE ;
               TOOLTIP 'Paste';
               ACTION MsgInfo('Click! ');

            BUTTON Button_12 ;
               PICTUREINDEX STD_UNDO ;
               TOOLTIP 'Undo';
               ACTION MsgInfo('Click! ');

            BUTTON Button_13 ;
               PICTUREINDEX STD_REDOW ;
               TOOLTIP 'Redo';
               ACTION MsgInfo('Click! ');

            BUTTON Button_14 ;
               PICTUREINDEX STD_HELP ;
               TOOLTIP 'Help';
               ACTION MsgInfo('Click! ');

         END TOOLBAR

      END WINDOW

   CENTER WINDOW Form_Fl

   ACTIVATE WINDOW Form_Fl

Return Nil


Procedure SetSizeTB(w)
   If IsWindowDefined ( Form_Fl )
      ResizeFloatToolbar( GetControlHandle ('ToolBar_i' , 'Form_fl'), w )
      Form_fl.SetFocus
   EndIf
Return


Procedure flResizeTb()
   ResizeFloatToolbar( GetControlHandle ('ToolBar_i' , 'Form_fl'), GetWindowWidth ( GetFormHandle ('Form_fl') ) )
   Form_fl.SetFocus
Return
