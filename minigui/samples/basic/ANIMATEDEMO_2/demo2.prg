/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Размер avi-файла на форме / Size of the avi file on the form
*/

ANNOUNCE RDDSYS
 
#include "minigui.ch"

*-------------------------------------------*
SET PROCEDURE TO resource_avi.prg
*-------------------------------------------*

#define APP_TITLE "Get Avi Size Test"

*-------------------------------------------*
FUNCTION Main()
*-------------------------------------------*
   LOCAL nFWidth, nCol, AviSW1, AviSH1, aSize1, AviSW2, AviSH2, aSize2
   LOCAL cAviFile := GetStartUpFolder() + "\RES\filedelete.avi"
   LOCAL cAviRes  := "DEMO_AVI"

   aSize1 := GetAviFileSize(cAviFile)
   AviSW1 := aSize1[1]
   AviSH1 := aSize1[2]

   aSize2 := GetAviResSize(cAviRes)
   AviSW2 := aSize2[1]
   AviSH2 := aSize2[2]

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 500 HEIGHT 250 ;
      MAIN ;
      TITLE APP_TITLE ;
      NOMAXIMIZE NOSIZE 

      nFWidth  := This.ClientWidth

      @ 10,20 BUTTON Button_1 ;
         CAPTION "Get Avi File Size" ;
         WIDTH 120 ;
         ACTION MsgDebug("Return =", GetAviFileSize(cAviFile))

      nCol := ( nFWidth - AviSW1 ) / 2 
      @ 40, nCol ANIMATEBOX Avi_1 WIDTH AviSW1 HEIGHT AviSH1  ;
         FILE cAviFile AUTOPLAY TRANSPARENT NOBORDER

      @ 120,20 BUTTON Button_2 ;
         CAPTION "Get Avi Res Size" ;
         WIDTH 120 ;
         ACTION MsgDebug("Return =", GetAviResSize(cAviRes))

      nCol := ( nFWidth - AviSW2 ) / 2 
      @ 160, nCol ANIMATEBOX Avi_2 WIDTH AviSW2 HEIGHT AviSH2  ;
         FILE cAviRes AUTOPLAY TRANSPARENT NOBORDER


      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   Form_1.Center
   Form_1.Activate

RETURN NIL
