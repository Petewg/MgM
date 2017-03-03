/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <hmg.ch>

FUNCTION Main

   define window win_1 ;
      main ;
      clientarea 300, 300 ;
      title "JPEG Image From Resource" ;
      backcolor TEAL nosize

      on key escape action win_1.release()

      define image image_1
         row 50
         col 75
         width 150
         height 200
         picture 'OLGA'
         stretch .T.
      end image

   end window

   draw panel in window win_1 ;
      at win_1.image_1.Row - 2, win_1.image_1.Col - 2 ;
      to win_1.image_1.Row + win_1.image_1.height + 1, win_1.image_1.Col + win_1.image_1.width + 1

   win_1.minbutton := .F.
   win_1.maxbutton := .F.

   win_1.center
   win_1.activate

RETURN NIL
