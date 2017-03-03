/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Make Your Project Look Great!
*/

#include "minigui.ch"

PROCEDURE Main()

   LOCAL hCursor

   DEFINE WINDOW Win_1 ;
       AT 0,0 ;
       WIDTH 400 ;
       HEIGHT 200 ;
       TITLE 'Window: CURSOR & BACKGROUND ' ;
       CURSOR ( hCursor := _GetRandomCursor() ) ;
       BKBRUSH _GetRandomImageOrColor() ;
       MAIN 

       @ 10,10 BUTTON Button_1 CAPTION 'Close' ACTION ThisWindow.Release DEFAULT

       SetWindowCursor( This.Button_1.Handle, hCursor )

   END WINDOW

   MAXIMIZE WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN


STATIC FUNCTION _GetRandomCursor()

   LOCAL aCurNames := { "Smiley 3.ani" , "Smiley 4.ani" , "Smiley.ani" , "Blue Spirit Busy.ani" }
   LOCAL nCurIndex := hb_RandomInt( Len( aCurNames ) )

   RETURN GetStartUpFolder() + "\ANI\" + aCurNames[ nCurIndex ]


STATIC FUNCTION _GetRandomImageOrColor()

   LOCAL aImgNames := { { 120, 100, 120 }, "img.png", "Color_720x40.jpg", "basn3p01.png", "basn4a16.png", "bShop.bmp", NIL }
   LOCAL nImgIndex := hb_RandomInt( Len( aImgNames ) )

   RETURN If( HB_ISCHAR( aImgNames[ nImgIndex ] ), GetStartUpFolder() + "\IMG\" + aImgNames[ nImgIndex ], aImgNames[ nImgIndex ] )
