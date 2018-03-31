/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2014-2017 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"

MEMVAR count, pressed

FUNCTION Main

   LOCAL i, img_name, col

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 400 HEIGHT 340 ;
      TITLE 'Rating Test' ;
      ICON 'star.ico' ;
      MAIN ;
      BACKCOLOR WHITE

   DEFINE MAINMENU
      DEFINE POPUP "File"
         MENUITEM "Exit" ONCLICK ThisWindow.Release()
      END POPUP
   END MENU

   count := 10
   pressed := 0
   col := 100

   FOR i := 1 TO count

      img_name := "Image_" + hb_ntos( i )

      DEFINE IMAGE &img_name
         PARENT            Win_1
         ROW               100
         COL               col
         WIDTH             18
         HEIGHT            17
         PICTURE           'empty.bmp'
         ONMOUSEHOVER      OnHoverRate()
         ONMOUSELEAVE      OnLeaveRate()
         ONCLICK           ( pressed := Val( SubStr( This.Name, RAt( '_', This.Name ) + 1 ) ), OnSelectRate() )
      END IMAGE

      col += 18

   NEXT

   DRAW RECTANGLE ;
      IN WINDOW Win_1 ;
      AT 99, 99 ;
      TO 100 + 18, col + 2 ;
      PENCOLOR { 192, 192, 192 }

   DEFINE LABEL Label_1
      ROW 100
      COL col + 10
      WIDTH 82
      HEIGHT 17
      VALUE "0 %"
      VCENTERALIGN .T.
      TRANSPARENT .T.
   END LABEL

   DEFINE BUTTON Button_1
      ROW 140
      COL 100
      WIDTH 182
      HEIGHT 28
      CAPTION "Clear Rating"
      ACTION ( pressed := 0, ClearRate(), Win_1.Label_1.Value := "0 %" )
      FLAT .T.
   END BUTTON

   END WINDOW

   Win_1.Center()
   ACTIVATE WINDOW Win_1

RETURN NIL


FUNCTION OnHoverRate()

   LOCAL i, img_name
   LOCAL select := Val( SubStr( This.Name, RAt( '_', This.Name ) + 1 ) )

   ClearRate()

   FOR i := 1 TO select

      img_name := "Image_" + hb_ntos( i )
      Win_1.&( img_name ).Picture := 'full.bmp'

   NEXT

RETURN NIL


FUNCTION OnLeaveRate()

   IF pressed == 0

      ClearRate()
      Win_1.Label_1.Value := "0 %"

   ELSE

      OnSelectRate()

   ENDIF

RETURN NIL


FUNCTION OnSelectRate()

   LOCAL i, img_name, lShift

   IF pressed > 0

      lShift := _GetKeyState( VK_SHIFT )

      ClearRate()

      FOR i := 1 TO pressed

         img_name := "Image_" + hb_ntos( i )
         Win_1.&( img_name ).Picture := 'full.bmp'

      NEXT

      IF lShift .OR. Left( Right( Win_1.Label_1.Value, 3), 1 ) <> "0"

         img_name := "Image_" + hb_ntos( pressed )
         Win_1.&( img_name ).Picture := 'left.bmp'

         Win_1.Label_1.Value := hb_ntos( Int( ( pressed - 1 + .5 ) * 10 ) ) + " %"

      ELSE

         Win_1.Label_1.Value := hb_ntos( pressed * 10 ) + " %"

      ENDIF

   ENDIF

RETURN NIL


STATIC FUNCTION ClearRate()

   LOCAL i, img_name

   FOR i := 1 TO count

      img_name := "Image_" + hb_ntos( i )
      Win_1.&( img_name ).Picture := 'empty.bmp'

   NEXT

RETURN NIL
