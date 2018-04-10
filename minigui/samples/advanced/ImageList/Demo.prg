/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Image and wave - Josef Planeta, Czech Republic                 *
 *               (planeta@iach.cz)                                *
 *                                                                *
*/

#include "minigui.ch"

#define HEAPPY  1
#define RUN     2
#define SIT     3
#define LIE     4
#define SLEEP   5

STATIC lPlay := .F.
STATIC lDrag := .F.
STATIC aAnim := { { 2, 3 }, { 4, 5, 6, 7 }, { 8, 9, 10, 11 }, { 12, 13 }, { 14, 15, 16 }, { 17, 18 }, { 19, 20, 21 }, { 22, 23 }, { 24, 25, 26, 27, 28, 29 } }
STATIC xDog  := 500
STATIC yDog  := 120
STATIC xCur  := 0
STATIC yCur  := 0
STATIC Faze  := SLEEP
STATIC xOld  := 0
STATIC yOld  := 0
STATIC aMovX := {}
STATIC aMovY := {}
STATIC nMov  := 1
STATIC nDir  := 1
STATIC hMenu := 20
STATIC hToolBar  := 40
STATIC ColorMask := { 192, 192, 192 }
STATIC HotSpotX  := 0
STATIC HotSpotY  := 0

MEMVAR nImg
MEMVAR nCount
MEMVAR bPlayImage

MEMVAR Image_Row
MEMVAR Image_Col
MEMVAR Image_Index

FUNCTION Main

   PUBLIC nImg := 1
   PUBLIC nCount := 1
   PUBLIC bPlayImage := {|| Nil }

   PUBLIC Image_Row := 0
   PUBLIC Image_Col := 0
   PUBLIC Image_Index := 0


   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'MiniGUI ImageList Demo (Based Upon a Contribution Of Janusz Pora)' ;
      ICON 'DOG.ICO' ;
      MAIN ;
      FONT 'Arial' SIZE 10 ;
      ON INIT initIL();
      ON SIZE RePaintImage();
      ON MOUSECLICK SetPlayImage( 0 );
      ON MOUSEDRAG DragImage();
      ON MOUSEMOVE StopDragImage();
      BACKCOLOR { 192, 192, 64 }

   DEFINE IMAGELIST imagelst_1 ;
      BUTTONSIZE 35, 35  ;
      IMAGE { 'dog.bmp' } ;
      IMAGEMASK { 'dogmask.bmp' } ;
      IMAGECOUNT 30 ;
      MASK

   DEFINE STATUSBAR
      STATUSITEM '[x] Harbour Power Ready!'
   END STATUSBAR

   DEFINE MAIN MENU
   POPUP '&Image'
      ITEM 'Masked ImageList '  ACTION CreateImageList( 1, 1 )
      ITEM 'Color Masked ImageList ' ACTION CreateImageList( 2, 1 )
      SEPARATOR
      ITEM 'Erase Image'  ACTION EraseImage( 3 )
      SEPARATOR
      ITEM '&Exit'   ACTION Form_1.Release
   END POPUP
/*
   POPUP '&Animation'
    ITEM 'Heappy Dog'  ACTION SetPlayImage(4)
    ITEM 'Running Dog'  ACTION SetPlayImage(3)
    ITEM 'Sitdown Dog'  ACTION SetPlayImage(5)
    ITEM 'Lying Dog'  ACTION SetPlayImage(6)
    ITEM 'Sleeping Dog'  ACTION SetPlayImage(9)
   END POPUP
*/
   POPUP '&Help'
      ITEM '&About'   ACTION MsgInfo ( "MiniGUI ImageList demo" )
   END POPUP
   END MENU

   DEFINE SPLITBOX

   DEFINE TOOLBAR ToolBar_a BUTTONSIZE 85, 35 SIZE 8  FLAT RIGHTTEXT

   BUTTON Button_1a ;
      CAPTION '&Run' ;
      PICTURE 'm5.bmp' ;
      TOOLTIP 'Running Dog';
      ACTION ImageAnimat( 3 )

   BUTTON Button_2a ;
      CAPTION '&Sit' ;
      PICTURE 'm20.bmp' ;
      TOOLTIP 'Sitdown Dog';
      ACTION ImageAnimat( 5 )

   BUTTON Button_3a ;
      CAPTION '&Heappy' ;
      PICTURE 'm3.bmp' ;
      TOOLTIP 'Heaping Dog';
      ACTION ImageAnimat( 4 )

   BUTTON Button_4a ;
      CAPTION '&Lie' ;
      PICTURE 'm22.bmp' ;
      TOOLTIP 'Lying Dog';
      ACTION ImageAnimat( 6 )

   BUTTON Button_5a ;
      CAPTION '&Sleep' ;
      PICTURE 'm29.bmp' ;
      TOOLTIP 'Sleeping Dog';
      ACTION ImageAnimat( 9 )

   END TOOLBAR

   END SPLITBOX

   @ 150,200   IMAGE image_1 ;
      PICTURE 'dog.gif' ;
      WIDTH 100 HEIGHT 100 ;
      STRETCH TRANSPARENT BACKGROUNDCOLOR { 192, 192, 64 }

   @ 200, 40 LABEL label_1;
      VALUE 'Click here!' + CRLF + 'or drag Dog.';
      ACTION SetPlayImage( 0 );
      HEIGHT 40;
      TRANSPARENT

   DEFINE TIMER Timer_1 ;
      INTERVAL 70 ;
      ACTION TimerPlayImage()

   Form_1.Timer_1.Enabled := .F.

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION initIL()

   DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog, xDog IMAGEINDEX 28

   Image_Row := yDog
   Image_Col := xDog
   Image_Index := 28

RETURN NIL


FUNCTION TimerPlayImage()

   Eval( bPlayImage, nImg )

RETURN NIL


FUNCTION SetPlayImage( typ )

   HB_SYMBOL_UNUSED( typ )

   IF MoveDat()
      ERASE IMAGE imagelst_1 OF Form_1 AT yDog, xDog

      HotSpotX = _HMG_MouseCol - Image_Col
      HotSpotY = _HMG_MouseRow - Image_Row

      BEGINDRAG IMAGE imagelst_1 OF Form_1 AT _HMG_MouseRow - HotSpotY, _HMG_MouseCol - HotSpotX ;
         IMAGEINDEX Image_Index

      ENTERDRAG IMAGE AT _HMG_MouseRow - HotSpotY, _HMG_MouseCol - HotSpotX
      lDrag := .T.
   ELSE
      bPlayImage := {|| MoveImage() }
      Form_1.Timer_1.Enabled := .T.
   ENDIF

RETURN NIL


FUNCTION ImageAnimat( typ )

   bPlayImage := {|| animation( typ ) }
   IF typ < 5
      nCount := 4
   ELSE
      nCount := 1
   ENDIF

   Form_1.Timer_1.Enabled := .T.

RETURN NIL


FUNCTION SetColor_IL()

   _ImageListSetBkColor( 'imagelst_1', 'Form_1', ColorMask )

RETURN NIL


FUNCTION CreateImageList( typ )

   IF typ == 2
      ColorMask := GetColor ( ColorMask )
      IF ColorMask[ 1 ] == Nil
         ColorMask := { 192, 192, 192 }
         MsgInfo( "Color no selected!" )
         RETURN NIL
      ENDIF
   ENDIF

   IF _IsControlDefined ( 'imagelst_1', 'Form_1' )
      RELEASE IMAGELIST imagelst_1 OF Form_1
   ENDIF

   IF typ == 1
      DEFINE IMAGELIST imagelst_1 ;
         OF Form_1 ;
         BUTTONSIZE 35, 35  ;
         IMAGE { 'dog.bmp' } ;
         IMAGEMASK { 'dogmask.bmp' } ;
         IMAGECOUNT 30 ;
         MASK
   ELSE
      DEFINE IMAGELIST imagelst_1 ;
         OF Form_1 ;
         BUTTONSIZE 35, 35  ;
         IMAGE { 'dog.bmp' } ;
         COLORMASK ColorMask ;
         IMAGECOUNT 30 ;
         MASK
   ENDIF

RETURN NIL


FUNCTION DelImage( ImgIndex )

   DELETE IMAGE ImgIndex FROM imagelst_1 OF Form_1

RETURN NIL


FUNCTION animation( typ )

   LOCAL pos, aTab

   aTab := aAnim[ typ ]
   IF nImg <= Len( aTab )
      pos := aTab[ nImg ]
      ERASE IMAGE imagelst_1 OF Form_1 AT yDog, xDog
      DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog, xDog IMAGEINDEX pos
      Image_Index := pos
      nImg++
   ELSE
      nCount--
      nImg := 1
      IF nCount <= 0
         Form_1.Timer_1.Enabled := .F.
      ENDIF
   ENDIF

RETURN NIL


FUNCTION EraseImage()

   ERASE IMAGE imagelst_1 OF Form_1 AT yDog, xDog

RETURN NIL

FUNCTION MoveImage()

   LOCAL pos, aTab

   xOld := xDog
   yOld := yDog
   aTab := aAnim[ if( nDir == 1, 2, 3 ) ]
   IF nMov <= Len( aMovX ) .AND. nMov > 0
      xDog := aMovX[ nMov ]
      yDog := aMovY[ nMov ]
   ENDIF

   ERASE IMAGE imagelst_1 OF Form_1 AT yOld, xOld
   IF nImg <= Len( aTab )
      pos := aTab[ nImg ]
      DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog, xDog IMAGEINDEX pos
      Image_Row := yDog
      Image_Col := xDog
      Image_Index := pos
      nImg++
   ELSE
      DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog, xDog IMAGEINDEX Image_Index
      nCount--
      nImg := 1
   ENDIF
   nMov++
   IF nMov > Len( aMovX )
      Form_1.Timer_1.Enabled := .F.
      PLAY WAVE 'dog.wav'
      nMov := 1
      nImg := 1
      ImageAnimat( if( nDir == 1, 1, 4 ) )
   ENDIF

RETURN NIL


FUNCTION MoveDat()

   LOCAL dx, dy, nA, n, InDog := .F.

   yCur := _HMG_MouseRow
   xCur := _HMG_MouseCol
   IF yCur >= yDog .AND. yCur <= yDog + 35 .AND. xCur >= xDog .AND. xCur <= xDog + 35
      InDog := .T.
   ELSE
      nDir := if( xCur > xDog, 1, -1 )
      nA := Int( ( xCur - xDog ) * nDir / 5 )
      dx := ( xCur - xDog ) * nDir / na
      dy :=  ( yCur - yDog ) / na
      aMovX := Array( nA )
      aMovY := Array( nA )
      FOR n := 1 TO nA
         aMovX[ n ] := xDog + dx * n * nDir
         aMovY[ n ] := yDog + dy * n
      NEXT
      nMov := 1
   ENDIF

RETURN InDog


FUNCTION DragImage()

   MOVE IMAGE AT _HMG_MouseRow - HotSpotY,_HMG_MouseCol - HotSpotX

   IF lDrag
      xDog := _HMG_MouseCol
      yDog := _HMG_MouseRow
   ENDIF

RETURN NIL


FUNCTION StopDragImage()

   IF lDrag == .T.
      ENDDRAG IMAGE
      RePaintImage()
      lDrag := .F.
   ENDIF

RETURN NIL


FUNCTION RePaintImage()

   DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog, xDog IMAGEINDEX Image_Index

RETURN NIL
