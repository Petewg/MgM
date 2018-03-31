/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 * Copyright 2017 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Системный цвет фона для avi-файла на форме
 * The system background color for the avi-file on the form
 * Прозрачный фон у avi-файла / Transparent background for the avi-file
*/

ANNOUNCE RDDSYS
 
#include "minigui.ch"

*-------------------------------------------*
SET PROCEDURE TO resource_avi.prg
*-------------------------------------------*

#define APP_TITLE "System background color for the AVI file"

*-------------------------------------------*
FUNCTION Main()
*-------------------------------------------*
   LOCAL nFWidth, nCol, nRow, aBackColorAvi, aSize, nW, nH
   LOCAL cAviFile := GetStartUpFolder() + "\RES\filedelete.avi"
   LOCAL cAviRes  := "DEMO_AVI"

   DEFINE WINDOW Form_1    ;
      AT 0,0               ;
      WIDTH 500 HEIGHT 250 ;
      MAIN                 ;
      TITLE APP_TITLE      ;
      BACKCOLOR ORANGE        

      nFWidth  := Form_1.Width

      @ 10, 10 LABEL Label_1 VALUE OS() WIDTH nFWidth HEIGHT 24 SIZE 14 TRANSPARENT

      nRow := Form_1.Label_1.Row + Form_1.Label_1.Height + 20 
      @ nRow, 0 LABEL Label_Avi VALUE '' WIDTH nFWidth HEIGHT 60 BACKCOLOR RED

      aSize := GetAviFileSize(cAviFile)  // get the size of the avi-file
      nW := aSize[1]
      nH := aSize[2]
      nCol := ( nFWidth - nW ) / 2  // place the center of the form

      @ nRow, nCol ANIMATEBOX Avi_1 WIDTH nW HEIGHT nH ;
        File cAviFile AUTOPLAY TRANSPARENT NOBORDER

      aBackColorAvi := nRGB2Arr( GetSysColor( 4/*COLOR_MENU*/ ) )
      // fix the background color as the system color
      Form_1.Label_Avi.BackColor := aBackColorAvi   
      
      aSize := GetAviResSize(cAviRes)  // get the size of the avi-file
      nW := aSize[1]
      nH := aSize[2]
      nCol := ( nFWidth - nW ) / 2  // place the center of the form
      nRow := Form_1.Label_Avi.Row + Form_1.Label_Avi.Height + 20 

      // transparent background of the avi-file
      @ nRow + 10, nCol ANIMATEBOX Avi_2 WIDTH nW HEIGHT nH ;
        File cAviRes AUTOPLAY TRANSPARENT BACKCOLOR ORANGE NOBORDER
      
      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   Form_1.Sizable   := .f.  // NOSIZE
   Form_1.MaxButton := .f.  // NOMAXIMIZE
   Form_1.Center
   Form_1.Activate

RETURN NIL
