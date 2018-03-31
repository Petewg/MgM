/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Показ avi-файла на форме / Show of the avi file on the form
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

FUNCTION Main()
Local cPathAvi := GetStartUpFolder()+"\Res\filedelete.avi"
Local cPathAvi2 := GetStartUpFolder()+"\Res\scanfiles.avi"

   DEFINE WINDOW Form_1 ;
       AT 0,0 WIDTH 530 HEIGHT 400      ;
       TITLE "Show AVI file"            ;
       MAIN                             ;
       NOMAXIMIZE NOSIZE 

      @ 20,20 ANIMATEBOX Avi_1 WIDTH 20 HEIGHT 20   ;
         FILE cPathAvi AUTOPLAY

      @ 90,20 ANIMATEBOX Avi_2 WIDTH 20 HEIGHT 20   ;
         FILE cPathAvi AUTOPLAY TRANSPARENT NOBORDER


      @ 170,20 ANIMATEBOX Avi_3 WIDTH 20 HEIGHT 20   ;
         FILE cPathAvi2 AUTOPLAY

      @ 240,20 ANIMATEBOX Avi_4 WIDTH 20 HEIGHT 20   ;
         FILE cPathAvi2 AUTOPLAY TRANSPARENT NOBORDER

      @ 320,15 BUTTON Button_Exit CAPTION 'Exit' WIDTH 490 HEIGHT 40  ;
         BOLD ACTION  {|| ThisWindow.Release }

   END WINDOW

  Form_1.Center
  Form_1.Activate

Return Nil
